# Simple WordPress Installer

This script provides a **simple and fast way to install WordPress** on your server with just one command. It automatically sets up Apache, MySQL, PHP, phpMyAdmin, and WordPress with randomly generated credentials.

## 📒 What This Script Does
- Installs and configures Apache, MySQL, PHP, and phpMyAdmin.
- Downloads and sets up the latest WordPress version.
- Creates a random WordPress database, user, and password.
- Configures WordPress to connect to the new database.
- Installs phpMyAdmin (uses the same credentials as the WordPress database).

## ⚙️ How To Run The Script
You can run this script directly from GitHub using `curl` or `wget`:

```sh
curl -sSL https://raw.githubusercontent.com/kbkozlev/simple-wordpress/refs/heads/master/simple-wordpress.sh | bash
```
```sh
wget -qO- https://raw.githubusercontent.com/kbkozlev/simple-wordpress/refs/heads/master/simple-wordpress.sh | bash
```

## 📌 Important Information
- **When setting up phpMyAdmin do not provide a password, if you wish to use the WP DB Password**
- **Save the credentials displayed at the end of the installation!**
- The script will output the following:
  - MySQL root password
  - WordPress Database Name
  - WordPress Database User
  - WordPress Database Password
  - phpMyAdmin User
  - phpMyAdmin Password
- **If you lose these credentials, you will not be able to access the database.**

## 💡 Additional Information
- This script uses the same credentials for phpMyAdmin as the WordPress database.
- Make sure your server is running a Debian-based system (e.g., Ubuntu).

## 📄 License
This script is open-source and under a [MIT License](LICENSE), feel free to modify and distribute it as needed.

## 🙌 Honorable Mentions
This script is inspired by "ZacsTech" and his [YouTube video](https://www.youtube.com/watch?v=DLzEU4naGGI&ab_channel=ZacsTech) 
