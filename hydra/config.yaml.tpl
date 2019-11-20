ingress:
  public:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: nginx
      kubernetes.io/tls-acme: "true"
    hosts:
      - host: ${public_host}
        paths:
          - "/"
    tls:
      - hosts:
          - ${public_host}
        secretName: ${tls_secret_name}

hydra:
  autoMigrate: true

  config:
    dsn: ${dsn}
    oidc:
      subject_identifiers:
        enabled:
          -pairwise
      pairwise:
        salt: ${salt}

    urls:
      self:
        issuer: "https://${public_host}"
      login: ${url_login}
      consent: ${url_consent}

    secrets:
      system: ${system_secret}
