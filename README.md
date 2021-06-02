# This Project

## Contains:

- Symfony v5.3 skeleton,
- Docker Stack for both FPM, Swoole and RoadRunner, and
- A handy Makefile for the SSL stuff.

## Setup Locally

- You will need [`git`](https://git-scm.com/), [`openssl`](https://www.openssl.org/),
  [`make`](https://www.gnu.org/software/make/), and [`mkcert`](https://mkcert.dev/).
- Update values in `.env` (choose `fpm`, `swoole` or `roadrunner` for `${RUNTIME}`).
- `docker-compose build --pull`
- `make password`
- `make mock-ssl`
- `bin/env composer install`
- `docker-compose up -d`
- `mkcert -install`
- Go to `https://${DOMAIN}:${SSL_PORT}`

## Production

You probably shouldn't use this for production, but if you did:

- `sudo mkdir -p "/etc/letsencrypt/challenges"`
- `docker-compose -f "docker-compose.yaml" run -d --name "acme" server nginx -c "/etc/nginx/acme.conf"`
- `sudo certbot certonly --webroot --webroot-path="/etc/letsencrypt/challenges" --cert-name="docker" -d "${YOUR_DOMAIN}"`
- `sudo openssl dhparam -out "/etc/letsencrypt/dhparam.pem" 4096`
