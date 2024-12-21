# Utiliser une image Flutter comme base
FROM cirrusci/flutter:stable

# Définir le répertoire de travail
WORKDIR /app

# Copier le code source Flutter
COPY . /app

# Installer les dépendances
RUN flutter pub get

# Exposer le port Flutter
EXPOSE 8080

# Lancer Flutter Web
CMD ["flutter", "run", "-d", "web-server", "--web-port", "8080", "--web-hostname", "0.0.0.0"]
