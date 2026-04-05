#!/bin/bash
set -e

WEBROOT="/var/www/paywith.nyc"
DOMAIN="paywith.nyc"
WWW="www.paywith.nyc"
EMAIL="community@nycoin.community"

echo "==> Installing Nginx if needed..."
if ! command -v nginx &>/dev/null; then
  apt-get update -qq
  apt-get install -y nginx
fi

echo "==> Writing HTTP-only Nginx config (pre-SSL)..."
cat > /etc/nginx/sites-available/paywith.nyc << 'NGINXCONF'
server {
    listen 80;
    listen [::]:80;
    server_name paywith.nyc www.paywith.nyc;

    root /var/www/paywith.nyc;
    index index.html;

    location /.well-known/acme-challenge/ {
        root /var/www/paywith.nyc;
    }

    location / {
        try_files $uri $uri/ =404;
    }
}
NGINXCONF

echo "==> Enabling site..."
ln -sf /etc/nginx/sites-available/paywith.nyc /etc/nginx/sites-enabled/paywith.nyc
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx
echo "    Nginx running OK on port 80."

echo "==> Installing Certbot if needed..."
if ! command -v certbot &>/dev/null; then
  apt-get update -qq
  apt-get install -y certbot python3-certbot-nginx
fi

echo "==> Issuing Let's Encrypt certificate..."
certbot --nginx \
  -d "$DOMAIN" \
  -d "$WWW" \
  --non-interactive \
  --agree-tos \
  --email "$EMAIL" \
  --redirect
echo "    Certificate issued."

echo "==> Adding gzip, cache, and security headers..."
# Patch the nginx config certbot wrote to add performance + security headers
cat > /etc/nginx/snippets/paywith-extras.conf << 'EXTRAS'
    # Gzip
    gzip on;
    gzip_vary on;
    gzip_types text/plain text/css application/javascript image/svg+xml;
    gzip_min_length 256;

    # Cache static assets
    location ~* \.(png|jpg|jpeg|gif|ico|svg|woff2|woff|ttf)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    location ~* \.(css|js)$ {
        expires 1M;
        add_header Cache-Control "public";
    }

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options SAMEORIGIN always;
    add_header X-Content-Type-Options nosniff always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
EXTRAS

# Insert include into the HTTPS server block certbot created
if ! grep -q "paywith-extras" /etc/nginx/sites-available/paywith.nyc; then
    sed -i '/listen 443 ssl/a\    include /etc/nginx/snippets/paywith-extras.conf;' \
        /etc/nginx/sites-available/paywith.nyc
fi

nginx -t && systemctl reload nginx
echo "    Headers and gzip active."

echo ""
echo "==> Certificate info:"
certbot certificates | grep -A5 "$DOMAIN" || true

echo ""
echo "====================================="
echo "DONE. Site is live at https://$DOMAIN"
echo "====================================="
