#!/bin/sh
if [ "$APP_NAME" != '' ]; then
    sed -i "s|APP_NAME=.*|APP_NAME=${APP_NAME}|i" /conf/.env
fi
if [ "$APP_ENV" != '' ]; then
    sed -i "s|APP_ENV=.*|APP_ENV=${APP_ENV}|i" /conf/.env
fi
if [ "$APP_DEBUG" != '' ]; then
    sed -i "s|APP_DEBUG=.*|APP_DEBUG=${APP_DEBUG}|i" /conf/.env
fi
if [ "$APP_URL" != '' ]; then
    sed -i "s|APP_URL=.*|APP_URL=${APP_URL}|i" /conf/.env
fi
if [ "$PHP_TZ" != '' ]; then
    sed -i "s|;*date.timezone =.*|date.timezone = ${PHP_TZ}|i" /etc/php7/php.ini
fi
if [ "$DEBUGBAR_ENABLED" != '' ]; then
    sed -i "s|DEBUGBAR_ENABLED=.*|DEBUGBAR_ENABLED=${DEBUGBAR_ENABLED}|i" /conf/.env
fi
if [ "$TUMBLR_API_KEY" != '' ]; then
    sed -i "s|TUMBLR_API_KEY=.*|TUMBLR_API_KEY=${TUMBLR_API_KEY}|i" /conf/.env
fi
if [ "$TUMBLR_SECRET_KEY" != '' ]; then
    sed -i "s|TUMBLR_SECRET_KEY=.*|TUMBLR_SECRET_KEY=${TUMBLR_SECRET_KEY}|i" /conf/.env
fi
if [ "$PHP_TZ" != '' ]; then
    sed -i "s|;*date.timezone =.*|date.timezone = ${PHP_TZ}|i" /etc/php/8.2/cli/php.ini
    sed -i "s|;*date.timezone =.*|date.timezone = ${PHP_TZ}|i" /etc/php/8.2/fpm/php.ini
fi
