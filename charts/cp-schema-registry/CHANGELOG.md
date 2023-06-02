# Changelog

## cp-schema-registry-v7.3.1-bbc-2

* chore: Upgraded Caddy server to 2.6.4 for the UI
* ref: Standardized configuration with a hard-coded config in the Docker image, no
   entrypoint
* fix: `Oidc_*` Headers are not proxied anymore to the backend Schema
   Registry. This reduces a lot the total header length, avoiding hitting
   the max header length limit on the backend side.
