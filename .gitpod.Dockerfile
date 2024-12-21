FROM gitpod/workspace-full:latest

# Installer Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter
RUN echo 'export PATH="$PATH:$HOME/flutter/bin"' >> $HOME/.bashrc

# Installer Android SDK et autres outils nécessaires (par exemple, openjdk)
RUN sudo apt-get update && sudo apt-get install -y openjdk-11-jdk wget unzip
RUN mkdir -p $HOME/Android/Sdk && wget https://dl.google.com/android/repository/commandlinetools-linux-8092744_latest.zip -O $HOME/commandlinetools.zip && unzip $HOME/commandlinetools.zip -d $HOME/Android/Sdk
RUN echo 'export ANDROID_SDK_ROOT=$HOME/Android/Sdk' >> $HOME/.bashrc

# Vous pouvez ajouter d'autres configurations ou outils ici

# Mettre à jour PATH et les configurations
RUN echo 'export PATH="$PATH:$HOME/flutter/bin"' >> $HOME/.bashrc
RUN echo 'export PATH="$PATH:$HOME/Android/Sdk/tools/bin:$HOME/Android/Sdk/platform-tools"' >> $HOME/.bashrc
