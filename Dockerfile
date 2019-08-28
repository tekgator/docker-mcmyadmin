#Download base image
FROM ubuntu:18.04

# set environment variables
ARG DEBIAN_FRONTEND="noninteractive"

ENV INSTALL_PATH="/McMyAdmin"
ENV USER="minecraft"

# Create volume path
WORKDIR ${INSTALL_PATH}

RUN \
  # Install required apps (Note: GIT is required to compile spigot within McMyAdmin)
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    unzip \
    wget \
    git-core \
    screen \
    openjdk-11-jdk-headless && \
  # download and unpack McMyAdmin
  echo "**** install mcmyadmin ****" && \
  #curl -o /tmp/MCMA2_glibc26_2.zip -L	http://mcmyadmin.com/Downloads/MCMA2_glibc26_2.zip && \
  wget --no-check-certificate -O /tmp/MCMA2_glibc26_2.zip http://mcmyadmin.com/Downloads/MCMA2_glibc26_2.zip && \
  #curl -o /tmp/etc.zip -L http://mcmyadmin.com/Downloads/etc.zip && \
  wget --no-check-certificate -O /tmp/etc.zip http://mcmyadmin.com/Downloads/etc.zip && \
  unzip -q /tmp/etc.zip -d /usr/local && \
  unzip -q /tmp/MCMA2_glibc26_2.zip -d /opt/mcmyadmin2 && \
  # Create non root user 
  echo "**** create non-root user and change permissions on files ****" && \
  useradd ${USER} -m -s /bin/bash && \
  chown -R ${USER}:${USER} ${INSTALL_PATH} && \
  chown -R ${USER}:${USER} /opt/mcmyadmin2 && \
  # Cleanup
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
	  /tmp/* \
	  /var/lib/apt/lists/* \
	  /var/tmp/*

# copy local files (this is a sperate layer, so in case the script changes the above will not be touched)
COPY usr/ /usr/
RUN \
  echo "**** change permission on entrypoint script and on the volume ****" && \
  chmod +x /usr/local/bin/docker-entrypoint.sh && \
  chown ${USER}:${USER} /usr/local/bin/docker-entrypoint.sh  

# Change user to non-root user
USER ${USER}

# Map McMyAdmin installation to external volume so the user can configure the 
VOLUME ${INSTALL_PATH}

# Expose required ports
EXPOSE 8080 25565

# start up
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]