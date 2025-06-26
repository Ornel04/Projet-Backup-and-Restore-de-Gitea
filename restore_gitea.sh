#!/bin/bash
# Mot de passe MySQL pour root et clomtz
MYSQL_USER_PASSWORD="myceo"

# Mise à jour des paquets
sudo apt update

# Installation de Git
sudo apt install -y git
# Vérification de la version de Git
git --version

# Téléchargement de Gitea
wget -O gitea https://dl.gitea.io/gitea/1.23.6/gitea-1.23.6-linux-amd64
# Changer les permissions de l'exécutable
chmod +x gitea
# Déplacement de Gitea dans /usr/local/bin
sudo mv gitea /usr/local/bin/

# Création de l'utilisateur système pour Gitea
sudo adduser --system --group --home /var/lib/gitea --shell /bin/sh git

# Création des répertoires nécessaires pour Gitea
sudo mkdir -p /var/lib/gitea/
sudo chown -R git:git /var/lib/gitea/
sudo chmod -R 750 /var/lib/gitea/

# Configuration des répertoires de configuration de Gitea
sudo mkdir -p /etc/gitea/conf
sudo chown -R git:git /etc/gitea
sudo chmod -R 750 /etc/gitea

# Installation de MariaDB
sudo apt install -y mariadb-server

# Création de la base de données et utilisateur Gitea
sudo mysql -u root --skip-password <<EOF
CREATE DATABASE gitea;
CREATE USER 'clomtz'@'localhost' IDENTIFIED BY '$MYSQL_USER_PASSWORD';
GRANT ALL PRIVILEGES ON gitea.* TO 'clomtz'@'localhost';
FLUSH PRIVILEGES;
EOF

# Création du fichier de service systemd pour Gitea
cat <<EOF | sudo tee /etc/systemd/system/gitea.service
[Unit]
Description=Gitea
After=network.target mysql.service
Requires=mysql.service
[Service]
RestartSec=2s
Type=simple
User=git
Group=git
WorkingDirectory=/var/lib/gitea/
ExecStart=/usr/local/bin/gitea web --config /etc/gitea/app.ini
Restart=always
Environment=USER=git HOME=/var/lib/gitea/
[Install]
WantedBy=multi-user.target
EOF

# Trouver le backup le plus récent
LATEST_BACKUP=$(find /vagrant -maxdepth 1 -name "gitea-backup-*" -type d | sort -r | head -n 1)
echo "Utilisation du backup le plus récent: $LATEST_BACKUP"

# Copier le backup vers le répertoire de l'utilisateur
cp -r "$LATEST_BACKUP" /home/vagrant/
BACKUP_NAME=$(basename "$LATEST_BACKUP")

# Déplacement des fichiers de backup dans les répertoires Gitea
sudo cp -a "/home/vagrant/$BACKUP_NAME/var/lib/gitea/data" /var/lib/gitea/
sudo chown -R git:git /var/lib/gitea/data
sudo chmod -R 750 /var/lib/gitea/data

# Création des répertoires de logs
sudo mkdir -p /var/lib/gitea/log && sudo chown -R git:git /var/lib/gitea/log && sudo chmod -R 750 /var/lib/gitea/log

# Restauration du fichier de configuration app.ini
sudo cp -a "/home/vagrant/$BACKUP_NAME/etc/gitea/app.ini" /etc/gitea/
sudo chown git:git /etc/gitea/app.ini
sudo chmod 640 /etc/gitea/app.ini

# Restauration de la base de données en passant le mot de passe de l'utilisateur clomtz
# Trouver le fichier SQL le plus récent
SQL_BACKUP=$(find "/home/vagrant/$BACKUP_NAME/backup/gitea" -name "gitea-db-*.sql" | sort -r | head -n 1)
echo "Restauration de la base de données depuis: $SQL_BACKUP"
mysql -u clomtz -p$MYSQL_USER_PASSWORD gitea < "$SQL_BACKUP"

# Modification du fichier app.ini
sudo sed -i 's/^PROTOCOL = https/PROTOCOL = http/' /etc/gitea/app.ini
sudo sed -i 's/^DOMAIN = .*/DOMAIN = 192.168.56.26/' /etc/gitea/app.ini
sudo sed -i 's|^ROOT_URL = .*|ROOT_URL = http://192.168.56.26/|' /etc/gitea/app.ini
sudo sed -i 's/^HTTP_PORT = .*/HTTP_PORT = 3000/' /etc/gitea/app.ini
sudo sed -i '/^CERT_FILE =/d' /etc/gitea/app.ini
sudo sed -i '/^KEY_FILE =/d' /etc/gitea/app.ini
sudo sed -i 's/^SSH_DOMAIN = .*/SSH_DOMAIN = 192.168.56.26/' /etc/gitea/app.ini

# Modification du fichier app.ini
#sudo sed -i 's/^PROTOCOL = https/PROTOCOL = http/' /etc/gitea/app.ini
#sudo sed -i 's/^DOMAIN = .*/DOMAIN = 10.128.21.40/' /etc/gitea/app.ini
#sudo sed -i 's|^ROOT_URL = .*|ROOT_URL = http://10.128.21.40/|' /etc/gitea/app.ini
#sudo sed -i 's/^HTTP_PORT = .*/HTTP_PORT = 3000/' /etc/gitea/app.ini
#sudo sed -i '/^CERT_FILE =/d' /etc/gitea/app.ini
#sudo sed -i '/^KEY_FILE =/d' /etc/gitea/app.ini
#sudo sed -i 's/^SSH_DOMAIN = .*/SSH_DOMAIN = 10.128.21.40/' /etc/gitea/app.ini

# Rechargement et redémarrage de Gitea
sudo systemctl daemon-reload
sudo systemctl enable gitea
sudo systemctl restart gitea
sudo systemctl status gitea
