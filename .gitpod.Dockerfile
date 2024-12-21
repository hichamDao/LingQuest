FROM gitpod/workspace-full:latest

# Mise à jour du système
RUN apt update && apt install -y wget

# Installer Google Chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    dpkg -i google-chrome-stable_current_amd64.deb || apt install -f -y && \
    rm google-chrome-stable_current_amd64.deb

# Configurer la variable CHROME_EXECUTABLE pour Flutter
ENV CHROME_EXECUTABLE=/usr/bin/google-chrome

# Installer Xvfb (serveur X virtuel)
RUN apt update && apt install -y xvfb

# Créer un script de démarrage pour Xvfb et Chrome
RUN echo '#!/bin/bash\n\
export DISPLAY=:99\n\
Xvfb :99 -screen 0 1024x768x16 &\n\
exec "$@"' > /usr/local/bin/xvfb-run-chrome && \
chmod +x /usr/local/bin/xvfb-run-chrome

# Remplacer Chrome par la commande utilisant Xvfb
ENV CHROME_EXECUTABLE="xvfb-run-chrome google-chrome"

# Démarrer Flutter Web avec Xvfb
ENTRYPOINT [ "bash", "-c", "flutter run -d chrome" ]
