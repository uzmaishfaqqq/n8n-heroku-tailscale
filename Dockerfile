FROM n8nio/n8n:latest

USER root

WORKDIR /home/node/packages/cli
ENTRYPOINT []

RUN apk update && apk add ca-certificates  && rm -rf /var/cache/apk/*

COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Copy Tailscale binaries from the tailscale image on Docker Hub.
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscaled /tailscale/tailscaled
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscale /tailscale/tailscale
RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale

# Run on container startup.
CMD ["/entrypoint.sh"]
