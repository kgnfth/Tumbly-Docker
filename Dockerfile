FROM debian:bookworm-slim

# Set version label
LABEL maintainer="kgnfth"

# Environment variables
ENV PUID='101'
ENV PGID='101'
ENV USER='tumbly'
ENV PHP_TZ=UTC

# Arguments
# To use the latest Tumbly release instead of master pass `--build-arg TARGET=release` to `docker build`
ARG TARGET=dev

# Install base dependencies, add user and group, clone the repo and install php libraries
RUN \
    set -ev && \
    apt-get update && \
    apt-get upgrade -qy && \
    apt-get install -qy --no-install-recommends\
    adduser \
    nginx-light \
    php7-mysqli \
    php7-pgsql \
    php7-sqlite3 \
    php7-imagick \
    php7-mbstring \
    php7-json \
    php7-gd \
    php7-xml \
    php7-zip \
    php7-fpm \
    php7-redis \
    php7-dom \
    php7-xmlwriter \
    php7-tokenizer \
    php7-bcmath \
    php7-ctype \
    php7-pdo \
    curl \
    git \
    npm \
    libimage-exiftool-perl \
    ffmpeg \
    jpegoptim \
    optipng \
    pngquant \
    gifsicle \
    webp \
    cron \
    composer \
    unzip && \
    addgroup --gid "$PGID" "$USER" && \
    adduser --gecos '' --no-create-home --disabled-password --uid "$PUID" --gid "$PGID" "$USER" && \
    cd /var/www/html && \
    git clone https://github.com/kgnfth/Tumbly.git && \
    mv Tumbly/.git/refs/heads/master Tumbly/master || cp Tumbly/.git/HEAD Tumbly/master && \
    mv Tumbly/.git/HEAD Tumbly/HEAD && \
    rm -r Tumbly/.git/* && \
    mkdir -p Tumbly/.git/refs/heads && \
    mv Tumbly/HEAD Tumbly/.git/HEAD && \
    mv Tumbly/master Tumbly/.git/refs/heads/master && \
    cd /var/www/html && \
    composer install --prefer-dist && \
    composer dump-autoload && \
    npm install && \
    npm run production && \
    rm -r storage/framework/cache/data/* 2> /dev/null || true && \
    rm    storage/framework/sessions/* 2> /dev/null || true && \
    rm    storage/framework/views/* 2> /dev/null || true && \
    rm    storage/logs/* 2> /dev/null || true && \
    chown -R www-data:www-data /var/www/html/Tumbly && \
    chmod -R 777 /var/www/html/Tumbly

# Add custom Nginx configuration
COPY default.conf /etc/nginx/nginx.conf

EXPOSE 80
VOLUME /conf

WORKDIR /var/www/html/Tumbly

COPY entrypoint.sh inject.sh /

RUN chmod +x /entrypoint.sh && \
    chmod +x /inject.sh && \
    if [ ! -e /run/php ] ; then mkdir /run/php ; fi

HEALTHCHECK CMD curl --fail http://localhost:80/ || exit 1

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "nginx" ]
