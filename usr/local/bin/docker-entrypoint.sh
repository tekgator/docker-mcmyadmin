#!/bin/bash
set -e

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
DOCKER_USER='dockeruser'
DOCKER_GROUP='dockergroup'

if ! id "$DOCKER_USER" >/dev/null 2>&1; then
    echo -e "\nFirst start of the docker container, start initialization process."

    USER_ID=${UID:-9001}
    GROUP_ID=${GID:-9001}
    echo -e "\nStarting with UID:GID : $USER_ID:$GROUP_ID"

    groupadd -f -g $GROUP_ID $DOCKER_GROUP
    useradd --shell /bin/bash -u $USER_ID -g $GROUP_ID -o -c "" -m $DOCKER_USER
    
    cp /opt/mcmyadmin2/MCMA2_Linux_x86_64 .
    chown -R $USER_ID:$GROUP_ID $INSTALL_PATH
    chown -R $USER_ID:$GROUP_ID $SCRIPTPATH/mcmyadmin.sh
    chmod +x MCMA2_Linux_x86_64
    chmod +x $SCRIPTPATH/mcmyadmin.sh
fi
export HOME=/home/$DOCKER_USER

exec gosu $DOCKER_USER $SCRIPTPATH/mcmyadmin.sh