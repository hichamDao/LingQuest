FROM gitpod/workspace-full:latest


# Installer les outils nécessaires
RUN sudo apt-get install -y wget curl git unzip zip libglu1-mesa || \
    (echo "APT-GET INSTALL FAILED" && cat /var/log/apt/term.log && exit 1)

# Installer Google Chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    dpkg -i google-chrome-stable_current_amd64.deb || sudo  apt-get install -f -y && \
    rm google-chrome-stable_current_amd64.deb

# Configurer la variable CHROME_EXECUTABLE pour Flutter
ENV CHROME_EXECUTABLE=/usr/bin/google-chrome

# Installer Xvfb (serveur X virtuel)
RUN sudo apt-get install -y xvfb


# Remplacer Chrome par la commande utilisant Xvfb
ENV CHROME_EXECUTABLE="xvfb-run-chrome google-chrome"

