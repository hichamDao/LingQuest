FROM gitpod/workspace-full

# Mettre à jour et installer les dépendances nécessaires pour IntelliJ IDEA
RUN sudo apt-get update && sudo apt-get install -y \
    openjdk-11-jdk \
    wget \
    xfce4 \
    xfce4-terminal \
    tightvncserver \
    dbus-x11 \
    && sudo apt-get clean

# Télécharger et installer IntelliJ IDEA
RUN wget https://download.jetbrains.com/idea/ideaIC-2023.2.1.tar.gz -O /tmp/idea.tar.gz \
    && tar -xzf /tmp/idea.tar.gz -C /opt \
    && rm /tmp/idea.tar.gz

# Configurer le mot de passe du serveur VNC
RUN echo "vncpassword" | vncpasswd -f > ~/.vnc/passwd
RUN chmod 600 ~/.vnc/passwd

# Exposer le port VNC
EXPOSE 5901

# Lancer le serveur VNC et IntelliJ IDEA
CMD ["sh", "-c", "vncserver :1 -geometry 1280x1024 -depth 24 && /opt/idea-IC-*/bin/idea.sh && tail -f /dev/null"]
