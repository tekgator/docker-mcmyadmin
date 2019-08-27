#Download base image
FROM openjdk:11-jdk-slim

# set environment variables
ARG DEBIAN_FRONTEND="noninteractive"

ENV INSTALL_PATH="/McMyAdmin"
ENV USER="minecraft"

# Install required apps 
# Note: GIT is required to compile spigot within McMyAdmin
RUN \
  apt-get update && \
  apt-get install -y \
  unzip \
  wget \
  git && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Create non root user
RUN useradd ${USER} -m -s /bin/bash

# Download & install Mono
WORKDIR /usr/local
RUN \
  wget http://mcmyadmin.com/Downloads/etc.zip && \
  unzip etc.zip && \
  rm etc.zip

# Download & install McMyAdmin
WORKDIR ${INSTALL_PATH}
RUN \
  wget http://mcmyadmin.com/Downloads/MCMA2_glibc26_2.zip && \
  unzip MCMA2_glibc26_2.zip && \
  rm MCMA2_glibc26_2.zip

# Fix Permissions
RUN chown -R ${USER}:${USER} ${INSTALL_PATH}

# Change user to non-root user
USER ${USER}

# Configure McMyAdmin
WORKDIR ${INSTALL_PATH}
RUN \
  mkdir Minecraft && \
  echo 'eula=true' > Minecraft/eula.txt && \
  touch McMyAdmin.conf && \
  ./MCMA2_Linux_x86_64 -nonotice -updateonly && \
  ./MCMA2_Linux_x86_64 -configonly -setpass pass123

# Open ports
EXPOSE 8080 
EXPOSE 25565

# Map McMyAdmin installation to external volume
# so the user can configure the 
VOLUME ${INSTALL_PATH}

# start up
WORKDIR ${INSTALL_PATH}
ENTRYPOINT ./MCMA2_Linux_x86_64