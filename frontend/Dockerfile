# 1. Utiliser l'image de base Flutter
FROM cirrusci/flutter:latest AS build

# 2. Passer à l'utilisateur root pour les étapes d'installation
USER root

# 3. Créer un utilisateur non-root (flutteruser)
RUN useradd -m flutteruser

# 4. Définir le répertoire de travail
WORKDIR /app

# 5. Copier tout le projet dans le conteneur
COPY . /app/

# 6. Changer les permissions de tous les fichiers du projet
RUN chown -R flutteruser:flutteruser /sdks/flutter /app

# 7. Passer à l'utilisateur non-root pour exécuter les étapes suivantes
USER flutteruser

# 8. Configurer git pour accepter Flutter comme un répertoire sûr
RUN git config --global --add safe.directory /sdks/flutter

# 9. Vérifier si le fichier de verrouillage existe, et si nécessaire, supprimer tout fichier erroné
RUN rm -f /sdks/flutter/bin/cache/lockfile

# 10. Installer les dépendances Flutter
RUN flutter pub get

# 11. Exposer le port pour Flutter (si tu utilises le mode web)
EXPOSE 5000

# 12. Lancer Flutter en mode web
CMD ["flutter", "run", "-d", "web-server", "--web-port", "5000"]
