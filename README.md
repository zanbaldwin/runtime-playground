# This Project

This is a working example of Symfony's Runtime component.
Do not use this project, look through the code and pull out the parts you find interesting. Copy+paste is your friend.

## Contains:

- Symfony v5.3 skeleton,
- Docker Stack for both FPM, Swoole and RoadRunner, and
- A handy Makefile for the SSL stuff.

## How?

Depending on the Docker build target (`fpm`, `swoole`, or `roadrunner`) the PHP container does the following:

- For build target `fpm`:
  - Execute `php-fpm --nodaemonize`
  - `APP_RUNTIME` is set to `Symfony\Component\Runtime\SymfonyRuntime`
- For build target `swoole`:
  - Execute `php "<project-dir>/public/index.php"`
  - `APP_RUNTIME` is set to `Runtime\Swoole\Runtime`
  - Environment variables `SWOOLE_HOST` and `SWOOLE_PORT` are set.
- For build target `roadrunner`
  - Execute `/sbin/rr serve`
  - `APP_RUNTIME` is set to `Runtime\RoadRunnerSymfonyNyholm\Runtime`
  - `.rr.yaml` configuration file is created
  
In the Nginx container, build target `fpm` uses FastCGI, while build targets `swoole` and `roadrunner` use Reverse Proxy.

## Setup Locally

- You will need [`git`](https://git-scm.com/), [`openssl`](https://www.openssl.org/),
  [`make`](https://www.gnu.org/software/make/), and [`mkcert`](https://mkcert.dev/).
- Update values in `.env` (choose `fpm`, `swoole` or `roadrunner` for `${RUNTIME}`).
- `docker-compose build --pull`
- `make password`
- `make mock-ssl`
- `composer install` (or `bin/env composer install` to run it inside the PHP container)
- `docker-compose up -d`
- `mkcert -install`
- Go to `https://${DOMAIN}:${SSL_PORT}`

## Production

You probably shouldn't use this for production, but if you did:

- `sudo mkdir -p "/etc/letsencrypt/challenges"`
- `docker-compose -f "docker-compose.yaml" run -d --name "acme" server nginx -c "/etc/nginx/acme.conf"`
- `sudo certbot certonly --webroot --webroot-path="/etc/letsencrypt/challenges" --cert-name="docker" -d "${YOUR_DOMAIN}"`
- `sudo openssl dhparam -out "/etc/letsencrypt/dhparam.pem" 4096`
