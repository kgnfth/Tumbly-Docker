FROM debian:bullseye

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
    php7.3-mysqli \
    php7.3-pgsql \
    php7.3-sqlite3 \
    php7.3-imagick \
    php7.3-mbstring \
    php7.3-gd \
    php7.3-xml \
    php7.3-json \
    php7.3-zip \
    php7.3-fpm \
    php7.3-redis \
    php7.3-dom \
    php7.3-xmlwriter \
    php7.3-tokenizer \
    php7.3-bcmath \
    php7.3-ctype \
    php7.3-pdo \
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
