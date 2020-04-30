PHP=$(dpkg-query -W -f='${status}' php7.0 2>/dev/null | grep -c 'ok installed')
if [ $PHP -eq 0 ]; then
	echo "Paigaldame php ja vajalikud lisad"
	apt install php7.0 libapache2-mod-php7.0 php7.0-mysql
	echo "php on paigaldatud"
elif [ $PHP -eq 1 ]; then
	echo "php on juba paigaldatud"
	which php
	php -v
fi
