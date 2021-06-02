# Development

- Update values in `.env` (choose `fpm` or `swoole` for `RUNTIME`).
- `docker-compose build --pull`
- `make mock-ssl`
- `bin/env composer install`
- `make password`
- `docker-compose up -d`

# Todo

- Generate Nginx config using `DOMAIN` specified in `.env` during build process.

# Production

- `sudo mkdir -p "/etc/letsencrypt/challenges"`
- `docker-compose -f "docker-compose.yaml" run -d --name "acme" server nginx -c "/etc/nginx/acme.conf"`
- `sudo certbot certonly --webroot --webroot-path="/etc/letsencrypt/challenges" --cert-name="docker" -d "${YOUR_DOMAIN}"`
- `sudo openssl dhparam -out "/etc/letsencrypt/dhparam.pem" 4096`
