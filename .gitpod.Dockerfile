FROM gitpod/workspace-full:latest


# Installer les outils nécessaires
RUN apt-get install -y wget curl git unzip zip libglu1-mesa || \
    (echo "APT-GET INSTALL FAILED" && cat /var/log/apt/term.log && exit 1)

# Installer Google Chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    dpkg -i google-chrome-stable_current_amd64.deb || apt-get install -f -y && \
    rm google-chrome-stable_current_amd64.deb

# Configurer la variable CHROME_EXECUTABLE pour Flutter
ENV CHROME_EXECUTABLE=/usr/bin/google-chrome

# Installer Xvfb (serveur X virtuel)
RUN apt-get install -y xvfb

# Créer un script de démarrage pour Xvfb et Chrome
RUN echo '#!/bin/bash\n\
export DISPLAY=:99\n\
Xvfb :99 -screen 0 1024x768x16 &\n\
exec "$@"' > /usr/local/bin/xvfb-run-chrome && \
chmod +x /usr/local/bin/xvfb-run-chrome

# Remplacer Chrome par la commande utilisant Xvfb
ENV CHROME_EXECUTABLE="xvfb-run-chrome google-chrome"

