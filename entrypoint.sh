#!/bin/sh

set -e

# Read Last commit hash from .git
# This prevents installing git, and allows display of commit
read -r longhash < /var/www/html/Tumbly/.git/refs/heads/main
shorthash=$(echo $longhash |cut -c1-7)
target=dev
echo '
-------------------------------------
 _______                  __     __        
|_     _|.--.--.--------.|  |--.|  |.--.--.
  |   |  |  |  |        ||  _  ||  ||  |  |
  |___|  |_____|__|__|__||_____||__||___  |
                                    |_____|
-------------------------------------
Tumbly Version: '$target'
Tumbly Commit:  '$shorthash'
https://github.com/kgnfth/Tumbly/commit/'$longhash'
-------------------------------------'

if [ -n "$STARTUP_DELAY" ]
	then echo "**** Delaying startup ($STARTUP_DELAY seconds)... ****"
	sleep $STARTUP_DELAY
fi


echo "**** Make sure the /conf and /uploads folders exist ****"
[ ! -d /conf ]    && mkdir -p /conf
[ ! -d /logs ]    && mkdir -p /logs


cd /var/www/html/Tumbly

echo "**** Copy the .env to /conf ****" && \
[ ! -e /conf/.env ] && \
	sed 's|^#TUMBLR_API_KEY=$|TUMBLR_API_KEY='$TUMBLR_API_KEY'|' /var/www/html/Tumbly/.env.example > /conf/.env
[ ! -L /var/www/html/Tumbly/.env ] && \
	ln -s /conf/.env /var/www/html/Tumbly/.env
echo "**** Inject .env values ****" && \
	/inject.sh

[ ! -e /tmp/first_run ] && \
	echo "**** Generate the key (to make sure that cookies cannot be decrypted etc) ****" && \
	./artisan key:generate -n && \
	touch /tmp/first_run

echo "**** Create user and use PUID/PGID ****"
PUID=${PUID:-1000}
PGID=${PGID:-1000}
if [ ! "$(id -u "$USER")" -eq "$PUID" ]; then usermod -o -u "$PUID" "$USER" ; fi
if [ ! "$(id -g "$USER")" -eq "$PGID" ]; then groupmod -o -g "$PGID" "$USER" ; fi
echo -e " \tUser UID :\t$(id -u "$USER")"
echo -e " \tUser GID :\t$(id -g "$USER")"
usermod -a -G "$USER" www-data

echo "**** Make sure Laravel's log exists ****" && \
touch /logs/laravel.log

echo "**** Set Permissions ****" && \
chown -R "$USER":"$USER" /conf/.env
chmod -R ug+w,ugo+rX /conf/.env

echo "**** Setup complete, starting the server. ****"
php-fpm7.4
exec $@
