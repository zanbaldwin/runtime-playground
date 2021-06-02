ARG PHP_VERSION="8.0-fpm-alpine3.13"
FROM "php:${PHP_VERSION}" AS base
MAINTAINER Zan Baldwin "hello@zanbaldwin.com"

# Compiles a statically-linked version of the init (PID 1) process bundled with Docker since v1.13 (API v1.25).
# Alpine uses musl instead of glibc, so it's best not to use the dynamically-linked version.
# See https://github.com/krallin/tini/issues/8#issuecomment-146135930
RUN    apk add --no-cache --virtual .tini-build-deps cmake gcc git libc-dev make \
    && git clone 'git://github.com/krallin/tini.git' '/tmp/tini' \
    && ( \
        cd '/tmp/tini'; \
        git checkout "$(git describe --tags)"; \
        export CFLAGS='-DPR_SET_CHILD_SUBREAPER=36 -DPR_GET_CHILD_SUBREAPER=37'; \
        cmake . && make; \
    ) \
    && mv '/tmp/tini/tini-static' '/tini' && chmod +x '/tini' \
    && rm -rf '/tmp/tini' \
    && apk del '.tini-build-deps'
ENTRYPOINT [ "/tini", "--" ]

# Install all standardised PHP extensions that are likely to be used by most applications.
RUN    apk add --no-cache --upgrade --virtual ".extension-build-deps" \
        gmp-dev icu-dev libffi-dev libxml2-dev \
    && apk add --no-cache --upgrade --virtual ".extension-runtime-deps" \
        gmp icu libffi libxml2 \
    && docker-php-ext-install \
        ffi gmp intl opcache pcntl pdo_mysql sockets xml \
    && apk del ".extension-build-deps"
# Plus other PECL extensions that could be useful.
# NOTE: If you want to install XDebug, make sure that you DON'T have it enabled when running Swoole.
RUN    apk add --no-cache --upgrade --virtual ".pecl-build-deps" $PHPIZE_DEPS \
    && apk add --no-cache --upgrade --virtual ".pecl-runtime-deps" \
    && pecl install swoole && docker-php-ext-enable swoole \
    && apk del ".pecl-build-deps"

# Composer (see https://github.com/composer/docker/blob/master/1.8/Dockerfile)
RUN    curl --silent --fail --location --retry 3 --output "/tmp/installer.sig" --url "https://composer.github.io/installer.sig" \
    && curl --silent --fail --location --retry 3 --output "/tmp/installer.php" --url "https://getcomposer.org/installer" \
    && php -r "if (hash_file('sha384', '/tmp/installer.php') === file_get_contents('/tmp/installer.sig')) { echo 'Installer verified.' . PHP_EOL; } else { echo 'Installer corrupt.' . PHP_EOL; unlink('/tmp/installer.php'); exit(1); }" \
    && php "/tmp/installer.php" --no-ansi --install-dir="/sbin" --filename="composer" \
    && rm -f "/tmp/installer.sig" "/tmp/installer.php"

COPY "./php.ini" "/usr/local/etc/php/php.ini"
COPY "./emergency_restart.conf" "/usr/local/etc/php-fpm.d/emergency_restart.conf"

# Create a new user with UID#1000 (the UID that the user on the host machine is likely to have).
# Instruct PHP-FPM to run as that user.
ARG PHP_USER="www-data"
RUN    apk add --no-cache --virtual .user-build-deps shadow \
    && (userdel "www-data" || true) \
    && useradd --no-create-home --uid 1000 --user-group "${PHP_USER}" \
    && sed -i -e "s/www-data/${PHP_USER}/g" "/usr/local/etc/php-fpm.d/www.conf" \
    && apk del '.user-build-deps'

WORKDIR "/srv"

FROM base AS swoole
ENV APP_RUNTIME="Runtime\Swoole\Runtime"
ENV SWOOLE_HOST="0.0.0.0"
# Use a port number above 1024 so it doesn't require root privileges. Might as well reuse the FPM port.
ENV SWOOLE_PORT="9000"
ARG PHP_USER="www-data"
USER "${PHP_USER}"
CMD [ "php", "/srv/public/index.php" ]

FROM base AS roadrunner
RUN    apk add --no-cache --virtual '.rr-build-deps' curl zip \
    && mkdir -p "/tmp/rr" \
    && curl -L -o "/tmp/rr/release.zip" "https://github.com/spiral/roadrunner-binary/releases/download/v2.2.1/roadrunner-2.2.1-unknown-musl-amd64.zip" \
    && unzip "/tmp/rr/release.zip" -d "/tmp/rr" \
    && mv "/tmp/rr/roadrunner-2.2.1-unknown-musl-amd64/rr" "/sbin/rr" \
    && rm -rf "/tmp/rr" \
    && apk del '.rr-build-deps'
ENV APP_RUNTIME="Runtime\RoadRunnerSymfonyNyholm\Runtime"
COPY "./rr.yaml" "/.rr.yaml"
ARG PHP_USER="www-data"
USER "${PHP_USER}"
CMD [ "/sbin/rr", "-c", "/.rr.yaml", "serve" ]

FROM base as fpm
# PHP-FPM initializes as the root user, and will then switch to "${PHP_USER}" according to pool directive.
USER "root"
ENV APP_RUNTIME="Symfony\Component\Runtime\SymfonyRuntime"
CMD [ "php-fpm", "--nodaemonize" ]
