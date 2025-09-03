#!/bin/sh
set -e

echo "Starting Tailscale..."

# Start tailscaled in userspace mode
/tailscale/tailscaled \
  --tun=userspace-networking \
  --socks5-server=localhost:1055 &

# Bring up Tailscale
/tailscale/tailscale up \
  --auth-key=${TAILSCALE_AUTHKEY} \
  --hostname=${TAILSCALE_NODE_NAME}

echo "Tailscale started"

# Check if Heroku gave us a $PORT, otherwise default
export N8N_PORT=${PORT:-5678}
export N8N_HOST=0.0.0.0
echo "n8n will listen on port $N8N_PORT"

# Parse DATABASE_URL
parse_url() {
  eval $(echo "$1" | sed -e "s#^\(\(.*\)://\)\?\(\([^:@]*\)\(:\(.*\)\)\?@\)\?\([^/?]*\)\(/\(.*\)\)\?#${PREFIX:-URL_}SCHEME='\2' ${PREFIX:-URL_}USER='\4' ${PREFIX:-URL_}PASSWORD='\6' ${PREFIX:-URL_}HOSTPORT='\7' ${PREFIX:-URL_}DATABASE='\9'#")
}
PREFIX="N8N_DB_" parse_url "$DATABASE_URL"

N8N_DB_HOST="$(echo $N8N_DB_HOSTPORT | sed -e 's,:.*,,g')"
N8N_DB_PORT="$(echo $N8N_DB_HOSTPORT | sed -e 's,^.*:,:,g' -e 's,.*:\([0-9]*\).*,\1,g' -e 's,[^0-9],,g')"

export DB_TYPE=postgresdb
export DB_POSTGRESDB_HOST=$N8N_DB_HOST
export DB_POSTGRESDB_PORT=$N8N_DB_PORT
export DB_POSTGRESDB_DATABASE=$N8N_DB_DATABASE
export DB_POSTGRESDB_USER=$N8N_DB_USER
export DB_POSTGRESDB_PASSWORD=$N8N_DB_PASSWORD

# Start n8n using Tailscale SOCKS5 proxy
ALL_PROXY=socks5://localhost:1055 n8n
