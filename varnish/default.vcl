# This is a basic VCL configuration file for varnish.  See the vcl(7)
# man page for details on VCL syntax and semantics.
#
# Default backend definition.  Set this to point to your content
# server.
vcl 4.0;
backend default {
    .host = "${backend_ip}";
    .port = "80";
    .first_byte_timeout = 90s;
}

sub vcl_recv {
   unset req.http.X-Forwarded-For;
   if (req.http.cf-connecting-ip) {
        set req.http.X-Forwarded-For = req.http.cf-connecting-ip;
   } else {
        set req.http.X-Forwarded-For = client.ip;
   }
   if (req.method != "GET" &&
           req.method != "HEAD" &&
           req.method != "PUT" &&
           req.method != "POST" &&
           req.method != "TRACE" &&
           req.method != "OPTIONS" &&
           req.method != "DELETE") {
               return (pipe);
   }
   if (req.http.Expect) {
        return (pipe);
   }
   if (req.method != "GET" && req.method != "HEAD") {
        return (pass);
   }
   #if (req.http.Authorization ~ "Basic cHRyOnNlcmxvcHRy" || req.http.Cookie ~ "(authenticated)") {
   if (req.http.Authorization || req.http.Cookie ~ "(authenticated)") {
        return (pass);
   }
   if (req.http.X-Requested-With ~ "XMLHttpRequest") {
      return (pass);
   }
   return (hash);
}
sub vcl_backend_response {
    # set beresp.http.Access-Control-Allow-Origin = "*";
    # set beresp.http.Access-Control-Allow-Headers = "origin, x-requested-with, content-type";
    # set beresp.http.Access-Control-Allow-Methods = "PUT, GET, POST, DELETE, OPTIONS";
    # set beresp.http.X-Frame-Options = "SAMEORIGIN";
    set beresp.http.X-XSS-Protection = "1; mode=block";
    set beresp.http.Content-Security-Policy = "default-src https: http://*.hotjar.com:* https://*.hotjar.com:* http://*.hotjar.io https://*.hotjar.io wss://*.hotjar.com 'unsafe-inline' 'unsafe-eval'; font-src 'unsafe-inline' 'unsafe-eval' *; script-src https: www.google-analytics.com ajax.googleapis.com http://*.hotjar.com https://*.hotjar.com http://*.hotjar.io https://*.hotjar.io 'unsafe-inline' 'unsafe-eval'; img-src * data:";
    if (beresp.http.X-Stroker-Cache ~ "Hit") {
       set beresp.ttl = 120m;
    }

    # Varnish determined the object was not cacheable
    if (beresp.ttl <= 0s) {
        set beresp.http.X-Cacheable = "NO:TTL is 0";
        # set beresp.ttl = 120s;
        set beresp.uncacheable = true;
        return (deliver);
    } elsif (bereq.http.Cookie ~ "(authenticated)") {
        set beresp.http.X-Cacheable = "NO:Got Session";
        # set beresp.ttl = 120s;
        set beresp.uncacheable = true;
        return (deliver);
    } else {
        set beresp.http.X-Cacheable = "YES";
    }
    if (bereq.url ~ "(?i)\.(pdf|asc|dat|txt|doc|xls|ppt|tgz|csv|png|gif|jpeg|jpg|ico|swf|css|js)(\?.*)?$") {
      unset beresp.http.set-cookie;
    }
    # You don't wish to cache content for logged in users
    # } elsif (bereq.http.Cookie ~ "(UserID|_session)") {
    #    set beresp.http.X-Cacheable = "NO:Got Session";
    #    # set beresp.ttl = 120s;
    # set beresp.uncacheable = true;
    # return (deliver);
    # You are respecting the Cache-Control=private header from the backend
    # } elsif (beresp.http.Cache-Control ~ "private") {
    #    set beresp.http.X-Cacheable = "NO:Cache-Control=private";
    #    # set beresp.ttl = 120s;
    # set beresp.uncacheable = true;
    # return (deliver);
    # Varnish determined the object was cacheable
    # } else {
    #    set beresp.http.X-Cacheable = "YES";
    #}
    # ....
    return(deliver);
}
sub vcl_deliver {
  if (obj.hits > 0) {
    set resp.http.X-Varnish-Cache = "HIT";
  }
  else {
    set resp.http.X-Varnish-Cache = "MISSED";
  }
}
