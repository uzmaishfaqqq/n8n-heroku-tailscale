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
RUN apk update && apk add ca-certificates  & rm -rf /var/cache/apk/*

# Copy file(s) to production image
COPY --from=builder /app/start.sh /app/start.sh
#COPY --from=builder /app/app.json /app/app.json

# Copy Tailscale binaries from the tailscale image on Docker Hub.
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscaled /app/tailscaled
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscale /app/tailscale
RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale

# Run on container startup.
RUN chmod +x /app/start.sh
CMD ["/app/start.sh"]
