#!/bin/sh

# Simple Menu for Installing or Reinstalling WordPress
echo "Select an option:"
echo "1. Install WordPress"
echo "2. Reinstall WordPress (Overwrite everything)"
echo "3. Exit"

read -p "Enter your choice: " choice

# Function to install WordPress
install_wordpress() {
    echo "Starting WordPress installation..."

    install_dir="/var/www/html"
    # Creating Random WP Database Credentials
    db_name="wp$(date +%s)"
    db_user="$db_name"
    db_password=$(date | md5sum | cut -c '1-12')
    sleep 1
    mysqlrootpass=$(date | md5sum | cut -c '1-12')
    sleep 1

    # Install Packages for HTTPS and MySQL
    apt -y update
    apt -y upgrade
    apt -y install apache2 mysql-server php php-bz2 php-mysqli php-curl php-gd php-intl php-common php-mbstring php-xml php-cli phpmyadmin wget lynx

    # Start Apache
    rm -f /var/www/html/index.html
    systemctl enable apache2
    systemctl start apache2

    # Start MySQL and Set Root Password
    systemctl enable mysql
    systemctl start mysql

    /usr/bin/mysql -e "USE mysql;"
    /usr/bin/mysql -e "UPDATE user SET Password=PASSWORD('$mysqlrootpass') WHERE user='root';"
    /usr/bin/mysql -e "FLUSH PRIVILEGES;"

    touch /root/.my.cnf
    chmod 600 /root/.my.cnf  # Secure the .my.cnf file
    echo "[client]" > /root/.my.cnf
    echo "user=root" >> /root/.my.cnf
    echo "password=$mysqlrootpass" >> /root/.my.cnf

    # Allow .htaccess in Apache
    sed -i '0,/AllowOverride None/! {0,/AllowOverride None/ s/AllowOverride None/AllowOverride All/}' /etc/apache2/apache2.conf

    systemctl restart apache2

    # Download and Extract Latest WordPress Package
    if [ -f /tmp/latest.tar.gz ]; then
        echo "WP is already downloaded."
    else
        echo "Downloading WordPress"
        cd /tmp/ && wget "http://wordpress.org/latest.tar.gz"
    fi

    /bin/tar -C "$install_dir" -zxf /tmp/latest.tar.gz --strip-components=1
    chown www-data:www-data "$install_dir" -R
    rm -f /tmp/latest.tar.gz  # Clean up the downloaded tarball

    # Create WP-config and Set DB Credentials
    /bin/mv "$install_dir/wp-config-sample.php" "$install_dir/wp-config.php"
    /bin/sed -i "s/database_name_here/$db_name/g" "$install_dir/wp-config.php"
    /bin/sed -i "s/username_here/$db_user/g" "$install_dir/wp-config.php"
    /bin/sed -i "s/password_here/$db_password/g" "$install_dir/wp-config.php"

    cat << EOF >> "$install_dir/wp-config.php"
define('FS_METHOD', 'direct');
EOF

    cat << EOF >> "$install_dir/.htaccess"
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
EOF

    chown www-data:www-data "$install_dir" -R

    # Set WP Salts
    grep -A50 'table_prefix' "$install_dir/wp-config.php" > /tmp/wp-tmp-config
    /bin/sed -i '/\/**#@/,/$p/d' "$install_dir/wp-config.php"
    /usr/bin/lynx --dump -width 200 https://api.wordpress.org/secret-key/1.1/salt/ >> "$install_dir/wp-config.php"
    /bin/cat /tmp/wp-tmp-config >> "$install_dir/wp-config.php" && rm -f /tmp/wp-tmp-config

    # Create Database and User
    /usr/bin/mysql -u root -e "CREATE DATABASE $db_name"
    /usr/bin/mysql -u root -e "CREATE USER '$db_user'@'localhost' IDENTIFIED WITH mysql_native_password BY '$db_password';"
    /usr/bin/mysql -u root -e "GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'localhost';"

    # Display generated passwords to log file.
    echo "Database Name: $db_name"
    echo "Database User: $db_user"
    echo "Database Password: $db_password"
    echo "Mysql root password: $mysqlrootpass"
    echo "phpMyAdmin User: $db_user"
    echo "phpMyAdmin Password: $db_password"
}

# Function to reinstall everything (delete and re-install WordPress)
reinstall_wordpress() {
    echo "Reinstalling WordPress... This will overwrite everything!"

    # Stop Apache and MySQL services before cleanup
    systemctl stop apache2
    systemctl stop mysql

    # Remove existing WordPress files and database
    rm -rf /var/www/html/*
    /usr/bin/mysql -u root -e "DROP DATABASE IF EXISTS $db_name;"
    /usr/bin/mysql -u root -e "DROP USER IF EXISTS '$db_user'@'localhost';"

    # Re-run the install function
    install_wordpress
}

# Case to handle the menu selection
case "$choice" in
    1)
        install_wordpress
        ;;
    2)
        reinstall_wordpress
        ;;
    3)
        echo "Exiting script."
        exit 0
        ;;
    *)
        echo "Invalid choice, exiting."
        exit 1
        ;;
esac
