# Utilisation de l'image de base Gitpod
FROM gitpod/workspace-full

# Pré-configurer l'installation pour ne pas demander d'interaction
ENV DEBIAN_FRONTEND=noninteractive

# Mise à jour des paquets et installation des dépendances nécessaires pour IntelliJ IDEA et VNC
RUN sudo apt-get update && sudo apt-get install -y \
    locales \
    keyboard-configuration \
    xfce4 \
    xfce4-terminal \
    tightvncserver \
    openjdk-11-jdk \
    wget \
    dbus-x11 \
    && sudo apt-get clean

# Pré-configurer les paramètres régionaux et clavier pour éviter l'interaction
RUN echo "en_US.UTF-8 UTF-8" | sudo tee -a /etc/locale.gen
RUN sudo locale-gen
RUN sudo update-locale LANG=en_US.UTF-8 LC_CTYPE="en_US.UTF-8"

# Pré-configurer les paramètres du clavier sans interaction
RUN echo "keyboard-configuration keyboard-configuration/modelcode 00" | sudo debconf-set-selections
RUN echo "keyboard-configuration keyboard-configuration/layoutcode us" | sudo debconf-set-selections
RUN echo "keyboard-configuration keyboard-configuration/variantcode us" | sudo debconf-set-selections
RUN echo "keyboard-configuration keyboard-configuration/unsupported_options boolean false" | sudo debconf-set-selections
RUN sudo dpkg-reconfigure -f noninteractive keyboard-configuration

# Télécharger et installer IntelliJ IDEA
RUN wget https://download.jetbrains.com/idea/ideaIC-2023.2.1.tar.gz -O /tmp/idea.tar.gz \
    && tar -xzf /tmp/idea.tar.gz -C /opt \
    && rm /tmp/idea.tar.gz

# Configurer le mot de passe du serveur VNC (à remplacer par un mot de passe sécurisé)
RUN echo "123456" | vncpasswd -f > ~/.vnc/passwd
RUN chmod 600 ~/.vnc/passwd

# Exposer le port VNC
EXPOSE 5901

# Lancer le serveur VNC et IntelliJ IDEA
CMD ["sh", "-c", "vncserver :1 -geometry 1280x1024 -depth 24 && /opt/idea-IC-*/bin/idea.sh && tail -f /dev/null"]
