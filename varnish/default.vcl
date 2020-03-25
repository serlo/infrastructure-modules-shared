vcl 4.0;
backend default {
  .host = "${host}";
  .port = "80";

  # How long to wait before we receive a first byte from our backend?
  .first_byte_timeout = 90s;
}

# vcl_recv is the first VCL subroutine executed, right after Varnish has parsed the client request into its basic data structure.
#
# In vcl_recv you can perform the following terminating actions:
# - pass: It passes over the cache lookup, but it executes the rest of the Varnish request flow. pass does not store the response from the backend in the cache.
# - pipe: This action creates a full-duplex pipe that forwards the client request to the backend without looking at the content. Backend replies are forwarded back to the client without caching the content. Since Varnish does no longer try to map the content to a request, any subsequent request sent over the same keep-alive connection will also be piped. Piped requests do not appear in any log.
# - hash: It looks up the request in cache.
# - purge: It looks up the request in cache in order to remove it.
# - synth - Generate a synthetic response from Varnish. This synthetic response is typically a web page with an error message. synth may also be used to redirect client requests.
#
# see https://book.varnish-software.com/4.0/chapters/VCL_Subroutines.html#vcl-vcl-recv
sub vcl_recv {
  # The X-Forwarded-For (XFF) header is a de-facto standard header for identifying the originating IP address of a client
  # connecting to a web server through an HTTP proxy or a load balancer.
  #
  # If Cloudflare provided the original client IP address, we use that.
  #
  # see https://support.cloudflare.com/hc/en-us/articles/200170986-How-does-Cloudflare-handle-HTTP-Request-headers-
  # see https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Forwarded-For
  unset req.http.X-Forwarded-For;
  if (req.http.cf-connecting-ip) {
    set req.http.X-Forwarded-For = req.http.cf-connecting-ip;
  } else {
    set req.http.X-Forwarded-For = client.ip;
  }

  # Forward "weird" requests to the backend
  if (
    req.method != "GET" &&
    req.method != "HEAD" &&
    req.method != "PUT" &&
    req.method != "POST" &&
    req.method != "TRACE" &&
    req.method != "OPTIONS" &&
    req.method != "DELETE"
  ) {
    return (pipe);
  }

  # The Expect HTTP request header indicates expectations that need to be fulfilled by the server in order to properly handle the request.
  # Therefore, forward request to the backend
  #
  # see https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Expect
  if (req.http.Expect) {
    return (pipe);
  }

  # Only cache GET and HEAD requests, still execute vcl_backend_response
  if (req.method != "GET" && req.method != "HEAD") {
    return (pass);
  }

  # Don't cache when user is authenticated, still execute vcl_backend_response
  if (req.http.Authorization || req.http.Cookie ~ "(authenticated)") {
    return (pass);
  }

  # Don't cache XMLHttpRequest
  if (req.http.X-Requested-With ~ "XMLHttpRequest") {
    return (pass);
  }

  # Lookup request in cache
  return (hash);
}

# The backend response is processed by vcl_backend_response or vcl_backend_error depending on the response from the server.
# If Varnish receives a syntactically correct HTTP response, Varnish pass control to vcl_backend_response.
sub vcl_backend_response {
  # There is also a backend response, beresp. beresp will contain the HTTP headers from the backend.

  # The HTTP X-XSS-Protection response header is a feature of Internet Explorer, Chrome and Safari that stops pages from
  # loading when they detect reflected cross-site scripting (XSS) attacks.
  #
  # Enables XSS filtering. Rather than sanitizing the page, the browser will prevent rendering of the page if an attack is detected.
  #
  # see https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-XSS-Protection
  set beresp.http.X-XSS-Protection = "1; mode=block";

  # Set Content Security Policies for Hotjar
  #
  # see https://help.hotjar.com/hc/en-us/articles/115011640307-Content-Security-Policies
  set beresp.http.Content-Security-Policy = "default-src https: http://*.hotjar.com:* https://*.hotjar.com:* http://*.hotjar.io https://*.hotjar.io wss://*.hotjar.com 'unsafe-inline' 'unsafe-eval'; font-src 'unsafe-inline' 'unsafe-eval' *; script-src https: www.google-analytics.com ajax.googleapis.com http://*.hotjar.com https://*.hotjar.com http://*.hotjar.io https://*.hotjar.io 'unsafe-inline' 'unsafe-eval'; img-src * data:";

  # If the backend is a cached response (using StrokerCache), keep that response for 2 hours
  if (beresp.http.X-Stroker-Cache ~ "Hit") {
    set beresp.ttl = 120m;
  }

  # Varnish determined the object was not cacheable
  if (beresp.ttl <= 0s) {
    # Custom header for debugging
    set beresp.http.X-Cacheable = "NO:TTL is 0";

    # To avoid request serialization, beresp.uncacheable is set to true, which in turn creates a hit-for-pass object.
    #
    # Some requested objects should not be cached. A typical example is when a requested page contains the Set-Cookie
    # response header, and therefore it must be delivered only to the client that requests it. In this case, you can
    # tell Varnish to create a hit-for-pass object and stores it in the cache, instead of storing the fetched object.
    # Subsequent requests are processed in pass mode.
    set beresp.uncacheable = true;

    # For some reason, we don't mark the object as "Hit-For-Pass" for the next 2 minutes (which is mentioned in the Varnish Docs)
    # set beresp.ttl = 120s;

    return (deliver);
  }

  # User is now logged in
  if (bereq.http.Cookie ~ "(authenticated)") {
    # Custom header for debugging
    set beresp.http.X-Cacheable = "NO:Got Session";

    # To avoid request serialization, beresp.uncacheable is set to true, which in turn creates a hit-for-pass object.
    #
    # Some requested objects should not be cached. A typical example is when a requested page contains the Set-Cookie
    # response header, and therefore it must be delivered only to the client that requests it. In this case, you can
    # tell Varnish to create a hit-for-pass object and stores it in the cache, instead of storing the fetched object.
    # Subsequent requests are processed in pass mode.
    set beresp.uncacheable = true;

    # For some reason, we don't mark the object as "Hit-For-Pass" for the next 2 minutes (which is mentioned in the Varnish Docs)
    # set beresp.ttl = 120s;
    return (deliver);
  }

  # Custom header for debugging
  set beresp.http.X-Cacheable = "YES";

  # Don't set cookies for files
  if (bereq.url ~ "(?i)\.(pdf|asc|dat|txt|doc|xls|ppt|tgz|csv|png|gif|jpeg|jpg|ico|swf|css|js)(\?.*)?$") {
    unset beresp.http.set-cookie;
  }

  return(deliver);
}

# Common last exit point for all request workflows, except requests through vcl_pipe
#
# see https://book.varnish-software.com/4.0/chapters/VCL_Subroutines.html#vcl-vcl-deliver
sub vcl_deliver {
  # Custom header for debugging
  if (obj.hits > 0) {
    set resp.http.X-Varnish-Cache = "HIT";
  }
  else {
    set resp.http.X-Varnish-Cache = "MISSED";
  }
}


# Disable keep-alive
sub vcl_pipe {
  set bereq.http.connection = "close";
}
sub vcl_backend_fetch {
  set bereq.http.connection = "close";
  return (fetch);
}
