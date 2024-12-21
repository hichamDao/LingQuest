# Image de base complète pour Gitpod
FROM gitpod/workspace-full:latest

# Mise à jour du système et installation des outils de base
RUN apt update && apt install -y wget curl git unzip zip libglu1-mesa

# Installer Google Chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    dpkg -i google-chrome-stable_current_amd64.deb || apt install -f -y && \
    rm google-chrome-stable_current_amd64.deb

# Configurer la variable CHROME_EXECUTABLE pour Flutter
ENV CHROME_EXECUTABLE=/usr/bin/google-chrome

# Installer Xvfb (X virtual framebuffer)
RUN apt install -y xvfb

# Créer un script pour exécuter Chrome avec Xvfb
RUN echo '#!/bin/bash\n\
export DISPLAY=:99\n\
Xvfb :99 -screen 0 1024x768x16 &\n\
exec "$@"' > /usr/local/bin/xvfb-run-chrome && \
chmod +x /usr/local/bin/xvfb-run-chrome

# Remplacer l'exécution de Chrome par la commande avec Xvfb
ENV CHROME_EXECUTABLE="xvfb-run-chrome google-chrome"


