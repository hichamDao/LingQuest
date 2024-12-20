# Utilisation de l'image de base Gitpod
FROM gitpod/workspace-full

# Pré-configurer l'installation pour ne pas demander d'interaction
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

# Ajouter les réponses nécessaires pour éviter les invites interactives
RUN echo "keyboard-configuration keyboard-configuration/xkb-keymap select us" | sudo debconf-set-selections \
    && echo "keyboard-configuration keyboard-configuration/layout select English (US)" | sudo debconf-set-selections \
    && echo "keyboard-configuration keyboard-configuration/modelcode string pc105" | sudo debconf-set-selections \
    && echo "keyboard-configuration keyboard-configuration/variant select English (US)" | sudo debconf-set-selections \
    && echo "keyboard-configuration keyboard-configuration/optionscode string" | sudo debconf-set-selections \
    && echo "keyboard-configuration keyboard-configuration/unsupported_config_options note" | sudo debconf-set-selections \
    && echo "keyboard-configuration keyboard-configuration/store_defaults_in_debconf_db boolean true" | sudo debconf-set-selections \
    && echo "keyboard-configuration keyboard-configuration/unsupported_config_layout boolean true" | sudo debconf-set-selections \
    && echo "keyboard-configuration keyboard-configuration/unsupported_options boolean true" | sudo debconf-set-selections

# Mise à jour des paquets et installation sans interaction
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    locales \
    keyboard-configuration \
    xfce4 \
    xfce4-terminal \
    tightvncserver \
    openjdk-11-jdk \
    wget \
    dbus-x11 \
    && sudo apt-get clean

# Configurer la langue et les locales (évite l'interaction)
RUN sudo locale-gen en_US.UTF-8 && sudo update-locale LANG=en_US.UTF-8

# Télécharger IntelliJ IDEA
RUN wget https://download.jetbrains.com/idea/ideaIC-2023.2.1.tar.gz -O /tmp/idea.tar.gz \
    && tar -xzf /tmp/idea.tar.gz -C /opt \
    && rm /tmp/idea.tar.gz

# Configurer le mot de passe pour le serveur VNC
RUN echo "vncpassword" | vncpasswd -f > ~/.vnc/passwd \
    && chmod 600 ~/.vnc/passwd

# Exposer le port pour VNC
EXPOSE 5901

# Commande pour lancer le serveur VNC et IntelliJ IDEA
CMD ["sh", "-c", "vncserver :1 -geometry 1280x1024 -depth 24 && /opt/idea-IC-*/bin/idea.sh && tail -f /dev/null"]
