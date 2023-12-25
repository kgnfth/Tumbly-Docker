FROM debian:bookworm-slim

# Set version label
LABEL maintainer="kgnfth"

# Environment variables
ENV PUID='1000'
ENV PGID='1000'
ENV USER='tumbly'
ENV PHP_TZ=UTC

# Arguments
# To use the latest Tumbly release instead of main pass `--build-arg TARGET=release` to `docker build`
ARG TARGET=dev

# Install base dependencies, add user and group, clone the repo and install php libraries
RUN \
    set -ev && \
    apt-get update && \
    apt-get upgrade -qy && \
    apt-get install -qy --no-install-recommends \
    adduser \
    nginx-light \
    php8.2-mysqli \
    php8.2-pgsql \
    php8.2-sqlite3 \
    php8.2-imagick \
    php8.2-mbstring \
    php8.2-gd \
    php8.2-xml \
    php8.2-zip \
    php8.2-fpm \
    php8.2-redis \
    php8.2-dom \
    php8.2-xmlwriter \
    php8.2-tokenizer \
    php8.2-bcmath \
    php8.2-ctype \
    php8.2-pdo \
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
    mv Tumbly/.git/refs/heads/main Tumbly/main || cp Tumbly/.git/HEAD Tumbly/main && \
    mv Tumbly/.git/HEAD Tumbly/HEAD && \
    rm -r Tumbly/.git/* && \
    mkdir -p Tumbly/.git/refs/heads && \
    mv Tumbly/HEAD Tumbly/.git/HEAD && \
    mv Tumbly/main Tumbly/.git/refs/heads/main && \
    cd /var/www/html/Tumbly && \
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
