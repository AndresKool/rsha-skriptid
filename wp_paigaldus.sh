APACHE2=$(dpkg-query -W -f='${status}' apache2 2>/dev/null | grep -c 'ok installed')
if [ $APACHE2 -eq 0 ]; then
        echo "Paigaldame apache2"
        apt install apache2
        echo "apache2 on paigaldatud"
elif [ $APACHE2 -eq 1 ]; then
        echo "apache on juba paigaldatud"
        systemctl restart apache2
        systemctl status apache2
fi
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
MYSQL=$(dpkg-query -W -f='${status}' mysql-server 2>/dev/null | grep -c 'ok installed')
if [ $MYSQL -eq 0 ]; then
        echo "Paigaldame mysql ja vajalikud lisad"
        apt install mysql-server
        echo "mysql on paigaldatud"
        touch $HOME/.my.conf
        echo "[client]" >> $HOME/.my.cnf
        echo "host = localhost" >> $HOME/.my.cnf
        echo "user = root" >> $HOME/.my.cnf
        echo "password = qwerty" >> $HOME/.my.cnf
elif [ $MYSQL -eq 1 ]; then
        echo "mysql on juba paigaldatud"
fi

read -p "Kirjuta Mysql root parool:  " rootpass
read -p "Andmebaasi nimi? " dbname
read -p "Andmebaasi kasutajanimi?  " dbuser
read -p "Kirjuta $dbuser parool:  " userpass
echo "CREATE DATABASE $dbname;" | mysql -u root -p$rootpass
echo "CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$userpass';" | mysql -u root -p$rootpass
echo "GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'localhost';" | mysql -u root -p$rootpass
echo "FLUSH PRIVILEGES;" | mysql -u root -p$rootpass
echo "Andmebaas on tehtud"

read -r -p "Kirjuta WordPress URL. [e.g. mywebsite.com]: " wpURL
wget -q -O - "http://wordpress.org/latest.tar.gz" | tar -xzf - -C /var/www --transform s/wordpress/$wpURL/
chown www-data: -R /var/www/$wpURL && cd /var/www/$wpURL
cp wp-config-sample.php wp-config.php
chmod 640 wp-config.php
mkdir uploads
sed -i "s/database_name_here/$dbname/;s/username_here/$dbuser/;s/password_here/$userpass/" wp-config.php

echo "
<VirtualHost *:80>
        ServerName $wpURL
        ServerAlias wp.$wpURL
        DocumentRoot /var/www/$wpURL
        DirectoryIndex index.php

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
" > /etc/apache2/sites-available/wp.$wpURL.conf

a2ensite wp.$wpURL.conf
service apache2 restart

echo "WordPress on installitud"
