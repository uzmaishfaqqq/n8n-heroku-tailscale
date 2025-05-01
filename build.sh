#!/bin/sh
docker build -t scottjwalter/n8n-heroku-tailscale .
docker push scottjwalter/n8n-heroku-tailscale:latest
