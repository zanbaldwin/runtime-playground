ARG MYSQL_VERSION="8.0.25"

FROM "mysql:${MYSQL_VERSION}" AS production
MAINTAINER Zan Baldwin "hello@zanbaldwin.com"

COPY "./php.conf" "/etc/mysql/conf.d/php.conf"

FROM production AS development
COPY "./memory.conf" "/etc/mysql/conf.d/memory.conf"
