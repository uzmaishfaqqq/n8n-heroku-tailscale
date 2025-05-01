# builder image 
# (not really necessary for this simple a setup, but if you needed to do serious
# assembly/compiling, etc., you could do that here.  If your build takes alot of 
# space, but you only need a binary, this is a way to keep the final image small.)
FROM golang:1.16.2-alpine3.13 AS builder
WORKDIR /app
COPY . ./

# at this point, any additional building could take place.

# final image, starting with n8n
FROM n8nio/n8n:latest

USER root
WORKDIR /home/node/packages/cli
ENTRYPOINT []

RUN apk update && apk add ca-certificates  & rm -rf /var/cache/apk/*

COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Copy Tailscale binaries from the tailscale image on Docker Hub.
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscaled /
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscale /
RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale

# Run on container startup.
CMD ["./entrypoint.sh"]
