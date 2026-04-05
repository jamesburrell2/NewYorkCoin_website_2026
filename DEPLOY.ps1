$KEY     = "$env:USERPROFILE\.ssh\balr_VPS"
$REMOTE  = "root@74.208.146.8"
$WEBROOT = "/var/www/paywith.nyc"

Write-Host ""
Write-Host "Deploying NewYorkCoin to paywith.nyc ..." -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/5] Creating web root..." -ForegroundColor Yellow
& ssh -i $KEY -o StrictHostKeyChecking=no $REMOTE "mkdir -p $WEBROOT"

Write-Host "[2/5] Uploading site files..." -ForegroundColor Yellow
& scp -i $KEY -o StrictHostKeyChecking=no "index.html"             "${REMOTE}:${WEBROOT}/"
& scp -i $KEY -o StrictHostKeyChecking=no "nyc-logo.png"           "${REMOTE}:${WEBROOT}/"
& scp -i $KEY -o StrictHostKeyChecking=no "nyc-logo-sm.png"        "${REMOTE}:${WEBROOT}/"
Write-Host "    Files uploaded OK" -ForegroundColor Green

Write-Host "[3/5] Uploading Nginx config..." -ForegroundColor Yellow
& scp -i $KEY -o StrictHostKeyChecking=no "nginx-paywith-nyc.conf" "${REMOTE}:/etc/nginx/sites-available/paywith.nyc"

Write-Host "[4/5] Uploading server setup script..." -ForegroundColor Yellow
& scp -i $KEY -o StrictHostKeyChecking=no "setup_server.sh" "${REMOTE}:/tmp/setup_nyc.sh"

Write-Host "[5/5] Running server setup (Nginx + SSL)..." -ForegroundColor Yellow
& ssh -i $KEY -o StrictHostKeyChecking=no $REMOTE "bash /tmp/setup_nyc.sh && rm /tmp/setup_nyc.sh"

Write-Host ""
Write-Host "Deployment complete!" -ForegroundColor Green
Write-Host "Visit: https://paywith.nyc" -ForegroundColor Cyan
Write-Host ""
