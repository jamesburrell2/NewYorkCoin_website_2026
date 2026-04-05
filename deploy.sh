#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# deploy.sh — NewYorkCoin Community Site → paywith.nyc VPS
# Usage: bash deploy.sh <user>@<vps-ip>  [ssh-key-path]
# Example: bash deploy.sh root@1.2.3.4
#          bash deploy.sh ubuntu@1.2.3.4 ~/.ssh/my_key
# ─────────────────────────────────────────────────────────────────────────────
set -e

TARGET="${1:?Usage: bash deploy.sh user@host [key]}"
KEY_ARG=""
[ -n "$2" ] && KEY_ARG="-i $2"

REMOTE_DIR="/var/www/paywith.nyc"
NGINX_CONF="nginx-paywith-nyc.conf"
DOMAIN="paywith.nyc"
WWW_DOMAIN="www.paywith.nyc"

echo "🚀  Deploying NewYorkCoin site to $TARGET ..."

# 1. Create remote web root
ssh $KEY_ARG "$TARGET" "mkdir -p $REMOTE_DIR"

# 2. Upload site files
scp $KEY_ARG index.html        "$TARGET:$REMOTE_DIR/"
scp $KEY_ARG nyc-logo.png      "$TARGET:$REMOTE_DIR/"
scp $KEY_ARG nyc-logo-sm.png   "$TARGET:$REMOTE_DIR/"

echo "✅  Files uploaded."

# 3. Upload Nginx config
scp $KEY_ARG "$NGINX_CONF" "$TARGET:/etc/nginx/sites-available/paywith.nyc"

# 4. Enable site + install Certbot + issue cert + reload
ssh $KEY_ARG "$TARGET" bash << EOF
set -e

# Enable Nginx site
ln -sf /etc/nginx/sites-available/paywith.nyc /etc/nginx/sites-enabled/paywith.nyc
nginx -t && systemctl reload nginx

# Install Certbot if not present
if ! command -v certbot &>/dev/null; then
  apt-get update -qq
  apt-get install -y certbot python3-certbot-nginx
fi

# Issue Let's Encrypt certificate
certbot --nginx \
  -d $DOMAIN \
  -d $WWW_DOMAIN \
  --non-interactive \
  --agree-tos \
  --email community@nycoin.community \
  --redirect

# Final reload
systemctl reload nginx

echo "✅  SSL certificate issued and Nginx reloaded."

# Verify cert
echo "📋  Certificate info:"
certbot certificates | grep -A4 "$DOMAIN"
EOF

echo ""
echo "🎉  Done! Site is live at https://$DOMAIN"
echo "    www redirect:  https://$WWW_DOMAIN → https://$DOMAIN"
