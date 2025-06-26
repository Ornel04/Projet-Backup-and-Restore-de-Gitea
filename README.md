# Projet-Backup-and-Restore-de-Gitea
Stratégie sauvegarde/restauration Gitea automatisée : sauvegardes régulières, validation d'intégrité, restauration rapide. Protection des dépôts Git contre pannes, erreurs et attaques pour continuité d'activité.

# Installation et Configuration de Gitea

Le script restore.sh automatise l'installation et la configuration de Gitea, un service d'hébergement Git léger, sur une machine Linux.

## Étapes effectuées par le script

1. **Mise à jour du système**  
   Met à jour la liste des logiciels disponibles.

2. **Installation de Git**  
   Installe Git, l'outil de gestion de versions.

3. **Installation de Gitea**  
   Télécharge Gitea, le place dans le système et crée un utilisateur dédié pour le service.

4. **Installation et configuration de MariaDB**  
   Installe MariaDB (base de données), crée une base de données `gitea` et un utilisateur avec mot de passe.

5. **Création du service systemd pour Gitea**  
   Configure Gitea pour qu'il démarre automatiquement avec le système.

6. **Restauration depuis la dernière sauvegarde**  
   Trouve la dernière sauvegarde disponible et restaure les fichiers, la configuration et la base de données.

7. **Configuration réseau**  
   Modifie la configuration de Gitea pour fonctionner sur l'adresse IP `192.168.56.26` et le port `3000`.

8. **Redémarrage de Gitea**  
   Recharge la configuration et redémarre le service pour appliquer les changements.

---

Après exécution, Gitea sera accessible à l'adresse :  
`http://192.168.56.26:3000`

---

## Remarques

- Le mot de passe MySQL est défini dans la variable `MYSQL_USER_PASSWORD`.
- Le script suppose que la sauvegarde de Gitea se trouve dans `/vagrant`. /vagrant/gitea-backup-XXXX-XX-XX/
    Dans gitea-backup-XXXX-XX-XX On a:
      la base de donnée, etc, usr, var
- Il faut lancer ce script restore.sh avec les droits administrateur (sudo).

