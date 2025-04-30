
FROM golang:1.16.2-alpine3.13 AS builder

WORKDIR /app

COPY . ./

FROM n8nio/n8n:latest
USER root
RUN apk update && apk add ca-certificates  & rm -rf /var/cache/apk/*

# Copy binary to production image.
COPY --from=builder /app/start.sh /app/start.sh
COPY --from=builder /app/app.json /app/app.json

# Copy Tailscale binaries from the tailscale image on Docker Hub.
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscaled /app/tailscaled
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscale /app/tailscale
RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale

# Run on container startup.
CMD ["/app/start.sh"]
