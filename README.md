# NewYorkCoin Website 2026

Community website for [NewYorkCoin (NYC)](https://paywith.nyc) — the fast, free, people's blockchain since March 6, 2014.

**Live site:** https://paywith.nyc
**Blog:** https://paywith.nyc/blog
**GitHub (coin):** https://github.com/NewYorkCoinNYC/newyorkcoin

## Files

| File | Purpose |
|------|---------|
| `index.html` | Main single-page site |
| `blog.html` | Blog & News page (served at `/blog`) |
| `nyc-logo.png` | Full-size logo |
| `nyc-logo-sm.png` | 160×160px nav logo |
| `setup_server.sh` | Nginx + Let's Encrypt setup script (run once on VPS) |
| `nginx-paywith-nyc.conf` | Nginx site config reference |

## Deploy

Pushes to `main` automatically deploy to the VPS via GitHub Actions.

To deploy manually from your local machine:

```powershell
$KEY = "$env:USERPROFILE\.ssh\balr_VPS"; $R = "root@74.208.146.8"
scp -i $KEY index.html blog.html nyc-logo.png nyc-logo-sm.png "${R}:/var/www/paywith.nyc/"
ssh -i $KEY $R "mkdir -p /var/www/paywith.nyc/blog && cp /var/www/paywith.nyc/blog.html /var/www/paywith.nyc/blog/index.html"
```

## Tech Stack

- Single-file HTML/CSS/JS — no build step required
- GSAP 3.12.5 + ScrollTrigger (animations)
- Lenis 1.1.14 (smooth scroll)
- SplitType 0.3.4 (text animations)
- Space Grotesk · Inter · JetBrains Mono (fonts)
- Nginx + Let's Encrypt on Ubuntu VPS

## Brand

| Token | Value |
|-------|-------|
| Navy | `#041E42` |
| Blue | `#0a5498` |
| Sky | `#009EDC` |
