#!/bin/bash

# Certifique-se de estar executando como root
if [ "$(id -u)" -ne 0 ]; then
    echo "Por favor, execute este script como root."
    exit 1
fi

echo "Atualizando o sistema..."
apt update && apt upgrade -y

echo "Instalando dependências..."
apt install -y apache2 mariadb-server libapache2-mod-php \
php php-cli php-mysql php-gd php-curl php-mbstring \
php-intl php-bcmath php-imagick php-xml php-zip unzip wget curl

echo "Baixando o Nextcloud..."
NEXTCLOUD_VERSION=27.0.2
wget https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.zip

echo "Extraindo o Nextcloud..."
unzip nextcloud-${NEXTCLOUD_VERSION}.zip -d /var/www/
chown -R www-data:www-data /var/www/nextcloud
chmod -R 755 /var/www/nextcloud

echo "Configurando o Apache..."
cat <<EOF > /etc/apache2/sites-available/nextcloud.conf
<VirtualHost *:80>
    ServerName yourdomain.com
    DocumentRoot /var/www/nextcloud
    <Directory /var/www/nextcloud>
        Require all granted
        AllowOverride All
        Options FollowSymLinks MultiViews
    </Directory>
</VirtualHost>
EOF

a2ensite nextcloud.conf
a2enmod rewrite headers env dir mime setenvif
systemctl restart apache2

echo "Configurando o banco de dados..."
mysql -u root -e "CREATE DATABASE nextcloud;"
mysql -u root -e "CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY 'password';"
mysql -u root -e "GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'localhost';"
mysql -u root -e "FLUSH PRIVILEGES;"

echo "Instalação do Nextcloud concluída! Acesse http://yourdomain.com para continuar a configuração via navegador."