# This Project

## Contains:

- Symfony v5.3 skeleton,
- Docker Stack for both FPM and Swoole, and
- A handy Makefile.

## Setup Locally

- Update values in `.env` (choose `fpm` or `swoole` for `${RUNTIME}`).
- `docker-compose build --pull`
- `make password`
- `make mock-ssl`
- `bin/env composer install`
- `docker-compose up -d`
- Go to `https://${DOMAIN}:${SSL_PORT}`

## Todo

- Generate Nginx config using `DOMAIN` specified in `.env` during build process.

## Production

You probably shouldn't use this for production, but if you did:

- `sudo mkdir -p "/etc/letsencrypt/challenges"`
- `docker-compose -f "docker-compose.yaml" run -d --name "acme" server nginx -c "/etc/nginx/acme.conf"`
- `sudo certbot certonly --webroot --webroot-path="/etc/letsencrypt/challenges" --cert-name="docker" -d "${YOUR_DOMAIN}"`
- `sudo openssl dhparam -out "/etc/letsencrypt/dhparam.pem" 4096`
