#!/bin/bash
set -e

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"
DOCKER_USER='dockeruser'
DOCKER_GROUP='dockergroup'

if ! id "$DOCKER_USER" >/dev/null 2>&1; then
    echo -e "\nFirst start of the docker container, start initialization process."

    USER_ID=${PUID:-9001}
    GROUP_ID=${PGID:-9001}
    echo -e "\nStarting with"
    echo "UID: $USER_ID"
    echo "GID: $GROUP_ID"

    groupadd -f -g $GROUP_ID $DOCKER_GROUP
    useradd --shell /bin/bash -u $USER_ID -g $GROUP_ID -o -c "" -m $DOCKER_USER
    
    chown -R $USER_ID:$GROUP_ID $INSTALL_PATH
    chown -R $USER_ID:$GROUP_ID $VOLUME_PATH
    chown -R $USER_ID:$GROUP_ID $SCRIPT_PATH/app.sh
    chmod +x $SCRIPT_PATH/app.sh
fi
export HOME=/home/$DOCKER_USER

exec gosu $DOCKER_USER $SCRIPT_PATH/app.sh