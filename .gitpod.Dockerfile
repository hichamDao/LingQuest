# Utilisation de l'image de base Gitpod
FROM gitpod/workspace-full

# Passer à l'utilisateur root pour installer des paquets
USER root

# Pré-configurer l'installation pour ne pas demander d'interaction
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

# Ajouter des réponses non interactives pour le clavier et les locales
RUN echo "keyboard-configuration keyboard-configuration/xkb-keymap select us" | debconf-set-selections \
    && echo "keyboard-configuration keyboard-configuration/layout select English (US)" | debconf-set-selections \
    && echo "keyboard-configuration keyboard-configuration/modelcode string pc105" | debconf-set-selections \
    && echo "keyboard-configuration keyboard-configuration/variant select English (US)" | debconf-set-selections \
    && echo "keyboard-configuration keyboard-configuration/optionscode string" | debconf-set-selections \
    && echo "keyboard-configuration keyboard-configuration/store_defaults_in_debconf_db boolean true" | debconf-set-selections \
    && echo "keyboard-configuration keyboard-configuration/unsupported_options boolean true" | debconf-set-selections

# Mise à jour et installation des paquets nécessaires
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \
    keyboard-configuration \
    xfce4 \
    xfce4-terminal \
    tightvncserver \
    openjdk-11-jdk \
    wget \
    dbus-x11 \
    && apt-get clean

# Configurer la langue et les locales
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen && update-locale LANG=en_US.UTF-8

# Correction des permissions pour les répertoires temporaires
RUN chmod -R 777 /tmp

# Télécharger IntelliJ IDEA
RUN wget https://download.jetbrains.com/idea/ideaIC-2023.2.1.tar.gz -O /tmp/idea.tar.gz \
    && tar -xzf /tmp/idea.tar.gz -C /opt \
    && rm /tmp/idea.tar.gz

# Configurer le serveur VNC
RUN mkdir -p ~/.vnc \
    && echo "vncpassword" | vncpasswd -f > ~/.vnc/passwd \
    && chmod 600 ~/.vnc/passwd

# Correction des permissions pour l'utilisateur par défaut
RUN chown -R gitpod:gitpod /home/gitpod

# Revenir à l'utilisateur non-root
USER gitpod

# Exposer le port pour VNC
EXPOSE 5901

# Commande pour lancer VNC et IntelliJ IDEA
CMD ["sh", "-c", "vncserver :1 -geometry 1280x1024 -depth 24 && /opt/idea-IC-*/bin/idea.sh && tail -f /dev/null"]
