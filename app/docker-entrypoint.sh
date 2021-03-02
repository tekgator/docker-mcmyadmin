#!/bin/bash
set -e

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"
DOCKER_USER='dockeruser'
DOCKER_GROUP='dockergroup'

if ! id "$DOCKER_USER" >/dev/null 2>&1; then
    echo "First start of the docker container, start initialization process."

    USER_ID=${PUID:-9001}
    GROUP_ID=${PGID:-9001}
    echo "Starting with $USER_ID:$GROUP_ID (UID:GID)"

    groupadd -f -g $GROUP_ID $DOCKER_GROUP
    useradd --shell /bin/bash -u $USER_ID -g $GROUP_ID -o -c "" -m $DOCKER_USER
    
    echo $SCRIPT_PATH
    chown -R $USER_ID:$GROUP_ID $INSTALL_PATH
    chown -R $USER_ID:$GROUP_ID $VOLUME_PATH
    chown -R $USER_ID:$GROUP_ID $SCRIPT_PATH/app.sh
    chmod a+x $SCRIPT_PATH/app.sh
    ls -al $SCRIPT_PATH
fi
export HOME=/home/$DOCKER_USER

exec gosu $DOCKER_USER $SCRIPT_PATH/app.sh