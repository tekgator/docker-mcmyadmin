#Download base image ubuntu 18.04
FROM ubuntu:18.04

# set version label
LABEL  maintainer="Tekgator"

# set environment variables
ARG DEBIAN_FRONTEND="noninteractive"
ENV install_path="/McMyAdmin"
ENV user="minecraft"

# Update OS
RUN \
  echo "**** update OS *****" && \
  apt-get update && \
  apt-get install -y apt-utils && \
  apt-get upgrade -y

# Install required apps
RUN \
  echo "*** install required apps ****" && \
  apt-get install -y \
  openjdk-11-jdk-headless \
  unzip \
  wget \
  libgdiplus && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Create non root user
RUN  \
  echo "**** create ${user} user *****" && \
  useradd ${user} -m -s /bin/bash

# Download & install Mono
WORKDIR  /usr/local
RUN \
  echo "**** download Mono *****" && \
  wget http://mcmyadmin.com/Downloads/etc.zip && \
  unzip etc.zip && \
  rm etc.zip

# Download & install McMyAdmin
WORKDIR  ${install_path}
RUN \
  echo "**** download McMyAdmin *****" && \
  wget http://mcmyadmin.com/Downloads/MCMA2_glibc26_2.zip && \
  unzip MCMA2_glibc26_2.zip && \
  rm MCMA2_glibc26_2.zip

# Accept Minecraft EULA
WORKDIR  ${install_path}/Minecraft
RUN \
  echo 'eula=true' > eula.txt

#Fix Permissions
RUN  chown -R ${user}:${user} ${install_path}

# Change user
USER ${user}

# Configure McMyAdmin
WORKDIR  ${install_path}
RUN \
  touch McMyAdmin.conf && \
  ./MCMA2_Linux_x86_64 -nonotice -updateonly && \
  ./MCMA2_Linux_x86_64 -configonly -setpass pass123

# Open ports
EXPOSE 8080 25565

# Map external volume
VOLUME ${install_path}

# start up
WORKDIR  ${install_path}
ENTRYPOINT  ["./MCMA2_Linux_x86_64"]
#CMD  ["-setpass", "pass123"]
