PMA=$(dpkg-query -W -f='${status}' phpmyadmin 2>/dev/null | grep -c 'ok installed')
if [ $PMA -eq 0 ]; then
        echo "Paigaldame phpmyadmin ja vajalikud lisad"
        apt install phpmyadmin
        echo "phpmyadmin on paigaldatud"
elif [ $PMA -eq 1 ]; then
        echo "phpmyadmin on juba paigaldatud"
fi

