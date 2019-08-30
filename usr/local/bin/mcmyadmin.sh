#!/bin/bash
set -e

MCSERVICE='./MCMA2_Linux_x86_64'
MCSESSION='minecraft'

function install_server {
    cd $INSTALL_PATH

    if [ ! -f McMyAdmin.conf ]; then
        echo -e "\nFirst start of the docker container start installation of McMyAdmin."
        echo "Please be patient, this will only take a few seconds!"
        
        touch McMyAdmin.conf

        # unfortunately updating and setting the initial password cannot be combined, so two calls are made
        ./MCMA2_Linux_x86_64 -nonotice -updateonly
        ./MCMA2_Linux_x86_64 -configonly -setpass pass123

        if [ "$EULA" == "1" ]; then
            echo -e "\nUser accepts EULA, create EULA.txt file."
            mkdir -p Minecraft
            echo 'eula=true' > Minecraft/eula.txt
        fi

        echo -e "\n************************************************************************" \
                "\n* Installation of McMyAdmin finished, access via http://localhost:8080 *" \
                "\n* Username: admin                                                      *" \
                "\n* Password: pass123 (must be changed on first login)                   *" \
                "\n************************************************************************\n"
    fi
}

function run_server {
    cd $INSTALL_PATH

    if ps ax | grep -v grep | grep $MCSERVICE > /dev/null
    then
        echo "$MCSERVICE is already running!"
    else
        echo "Starting $MCSERVICE..."
        screen -dmS $MCSESSION $MCSERVICE
        sleep 1
        echo "$MCSERVICE started."
    fi

    echo -e "\n************************************************************************" \
            "\n* McMyAdmin started, access via http://localhost:8080                  *" \
            "\n************************************************************************\n"    
}

function stop_server {
    if ps ax | grep -v grep | grep $MCSERVICE > /dev/null
    then
        echo "Stopping server..."

        echo -n "Try safly stopping Minecraft Server jar"
        screen -p 0 -S $MCSESSION -X eval 'stuff /stop\015'
        sync
        echo -n "." ; sleep 2 ; echo -n "." ; sleep 1 ; echo "." ; sleep 1
        echo -n "Try safly stopping $MCSERVICE"
        screen -p 0 -S $MCSESSION -X eval 'stuff /quit\015'
        sync
        echo -n "." ; sleep 1 ; echo -n "." ; sleep 1 ; echo "." ; sleep 1

        if ps ax | grep -v grep | grep $MCSERVICE > /dev/null
        then
            echo -e "\033[31m$MCSERVICE is still running!\033[0m"
            exit 1
        else
            echo -e "\033[32mServer stopped.\033[0m"
        fi
    else
        echo -e "\033[32mServer stopped.\033[0m"
    fi
    exit 0
}

install_server
run_server
trap stop_server SIGTERM

echo "Script going to sleep now."
sleep 10

while true; do 
  if ps ax | grep -v grep | grep $MCSERVICE > /dev/null
  then
    sleep 5
  else
    echo "$MCSERVICE not running anymore, stop script to stop container!"
    exit 2
  fi
done