#Download base image
FROM ubuntu:18.04

# set environment variables
ARG DEBIAN_FRONTEND="noninteractive"

ENV INSTALL_PATH="/McMyAdmin"

RUN \
  # Install required apps (Note: GIT is required to compile spigot within McMyAdmin)
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    unzip \
    ca-certificates \
    curl \
    git \
    screen \
    gosu \
    openjdk-11-jdk-headless && \
  # download and unpack McMyAdmin
  echo "**** download mcmyadmin ****" && \
  curl -o /tmp/MCMA2_glibc26_2.zip -L	http://mcmyadmin.com/Downloads/MCMA2_glibc26_2.zip && \
  curl -o /tmp/etc.zip -L http://mcmyadmin.com/Downloads/etc.zip && \
  unzip -q /tmp/etc.zip -d /usr/local && \
  unzip -q /tmp/MCMA2_glibc26_2.zip -d /opt/mcmyadmin2 && \
  # Cleanup
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
	  /tmp/* \
	  /var/lib/apt/lists/* \
	  /var/tmp/*

# copy local files (this is a seperate layer, so in case the script changes the above will not be touched)
COPY usr/ /usr/
RUN \
  echo "**** allow execution of the entrypoint script ****" && \
  chmod +x /usr/local/bin/docker-entrypoint.sh

# Create volume path
WORKDIR ${INSTALL_PATH}

# Map McMyAdmin installation to external volume so the user can configure the 
VOLUME ${INSTALL_PATH}

# Expose required ports
EXPOSE 8080 25565

# start up
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]