FROM openjdk:18.0.1.1-jdk-slim-bullseye

ARG DEBIAN_FRONTEND="noninteractive"

ENV \
  APP_PATH="/app" \
  DATA_PATH="/data" \
  MC_PWD=pass123

# Map installation to external volume so the user can configure
VOLUME ${DATA_PATH}

# Create install path and change dir
WORKDIR ${DATA_PATH}

# Install required packages
RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends dumb-init procps locales unzip curl git screen gosu libgdiplus && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /var/tmp/*

# setup environment
RUN \
  sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
  dpkg-reconfigure --frontend=noninteractive locales && \
  update-locale LANG=en_US.UTF-8

# download and unpack McMyAdmin
RUN \
  curl -o /tmp/MCMA2_glibc26_2.zip -L http://mcmyadmin.com/Downloads/MCMA2_glibc26_2.zip && \
  curl -o /tmp/etc.zip -L http://mcmyadmin.com/Downloads/etc.zip && \
  unzip /tmp/etc.zip -d /usr/local && \
  mkdir -vp $APP_PATH/config && \
  unzip /tmp/MCMA2_glibc26_2.zip -d $APP_PATH/config && \
  chmod -v a+rx $APP_PATH/config/MCMA2_Linux_x86_64 && \
  rm -rf /tmp/*

# Copy local files to image
COPY app/ /app/

# allow read and execution of the script
RUN chmod -v a+rx $APP_PATH/*.sh

# Expose required ports
EXPOSE 8080 25565

# Start up
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/app/docker-entrypoint.sh"]