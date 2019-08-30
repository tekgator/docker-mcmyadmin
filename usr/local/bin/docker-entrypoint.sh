#!/bin/bash
set -e

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
DOCKER_USER='docker'

if ! id "$DOCKER_USER" >/dev/null 2>&1; then
    echo -e "\nFirst start of the docker container, start initialization process."

    USER_ID=${UID:-9001}
    echo -e "\nStarting with UID : $USER_ID"

    useradd --shell /bin/bash -u $USER_ID -o -c "" -m $DOCKER_USER
    
    cp /opt/mcmyadmin2/MCMA2_Linux_x86_64 .
    chown -R ${DOCKER_USER}:${DOCKER_USER} $INSTALL_PATH
    chown -R ${DOCKER_USER}:${DOCKER_USER} $SCRIPTPATH/mcmyadmin.sh
    chmod +x $SCRIPTPATH/mcmyadmin.sh
fi
export HOME=/home/$DOCKER_USER

exec gosu $DOCKER_USER $SCRIPTPATH/mcmyadmin.sh