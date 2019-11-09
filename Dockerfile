#Download base image
FROM debian:buster-slim

# set environment variables
ARG DEBIAN_FRONTEND="noninteractive"

ENV \
  INSTALL_PATH="/opt/app" \
  VOLUME_PATH="/data" \
  MC_PWD=pass123

RUN \
  # Install required apps
  echo "**** install packages ****" && \
  mkdir -p /usr/share/man/man1 && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    dumb-init \
    procps \
    locales \
    unzip \
    ca-certificates \
    curl \
    git \
    screen \
    gosu \
    libgdiplus \
    openjdk-11-jdk-headless && \
  # setup environment
  echo "**** setup environment ****" && \
  sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
  dpkg-reconfigure --frontend=noninteractive locales && \
  update-locale LANG=en_US.UTF-8 && \
  # download and unpack McMyAdmin
  echo "**** download mcmyadmin ****" && \
  curl -o /tmp/MCMA2_glibc26_2.zip -L http://mcmyadmin.com/Downloads/MCMA2_glibc26_2.zip && \
  curl -o /tmp/etc.zip -L http://mcmyadmin.com/Downloads/etc.zip && \
  unzip -q /tmp/etc.zip -d /usr/local && \
  unzip -q /tmp/MCMA2_glibc26_2.zip -d $INSTALL_PATH && \
  chmod +x $INSTALL_PATH/MCMA2_Linux_x86_64 && \
  # Cleanup
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
      /tmp/* \
      /var/lib/apt/lists/* \
      /var/tmp/*

# copy local files
COPY usr/ /usr/
COPY opt/ /opt/
  
RUN \
  echo "**** allow execution of the entrypoint script ****" && \
  chmod +x /usr/local/bin/docker-entrypoint.sh

# Create volume path
WORKDIR ${VOLUME_PATH}

# Map installation to external volume so the user can configure
VOLUME ${VOLUME_PATH}

# Expose required ports
EXPOSE 8080 25565

# start up
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/local/bin/docker-entrypoint.sh"]