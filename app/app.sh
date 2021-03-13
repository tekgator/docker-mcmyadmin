#!/bin/bash
set -e

MC_SERVICE='./MCMA2_Linux_x86_64'
MC_SESSION='minecraft'

MC_LOG_PATH="./MCMA_Logs/*.log"

function install_server {
    if [ ! -f McMyAdmin.conf ]; then
        echo -e "\nFirst start of the docker container start installation of McMyAdmin."
        echo "Please be patient, this will only take a few minutes!"

        cp -vR $APP_PATH/config/* .

        if [ "$EULA" == "1" ]; then
            echo -e "\nUser accepts EULA"
            echo 'eula=true' > ./Minecraft/eula.txt
        fi

        ./MCMA2_Linux_x86_64 -nonotice -updateonly
        ./MCMA2_Linux_x86_64 -configonly -setpass ${MC_PWD}

        # 1GB RAM is way to less to start running in a docker, therefore adjust conf to 2048 by default
        sed -i 's/Java.Memory=1024/Java.Memory=2048/g' ./McMyAdmin.conf

        echo -e "\n************************************************************************" \
                "\n*                                                                      *" \
                "\n* Installation of McMyAdmin finished                                   *" \
                "\n* Use following credentials for the first login                        *" \
                "\n*                                                                      *" \
                "\n* Username: admin                                                      *" \
                "\n* Password: ${MC_PWD} (should be changed on first login)               *" \
                "\n*                                                                      *" \
                "\n************************************************************************\n"
    fi
}

function run_server {
    if ps ax | grep -v grep | grep "./MCMA2_Linux_x86_64" > /dev/null; then
        echo "$MC_SERVICE is already running!"
    else
        echo "Starting $MC_SERVICE..."
        screen -dmS $MC_SESSION $MC_SERVICE
        sleep 1
        echo "$MC_SERVICE started."
    fi

    echo -e "\n************************************************************************" \
            "\n*                                                                      *" \
            "\n* McMyAdmin started, access via http://localhost:8080                  *" \
            "\n*                                                                      *" \
            "\n************************************************************************\n"    
}

function stop_server {
    if ps ax | grep -v grep | grep $MC_SERVICE > /dev/null; then
        echo "Stopping server..."

        # Stop Minecraft server java file, if running
        if ps ax | grep -v grep | grep java > /dev/null; then
            stdbuf -o0 echo -n "Try safly stopping Minecraft Server jar"
            screen -p 0 -S $MC_SESSION -X eval 'stuff /stop\015'
            sync

            for run in {1..10}
            do
                if ps ax | grep -v grep | grep java > /dev/null; then
                    stdbuf -o0 echo -n "."
                    sleep 1
                else
                    break;
                fi
            done
            echo
            if ps ax | grep -v grep | grep java > /dev/null; then
                echo -e "\033[31mMinecraft is still running, possible data loss!\033[0m"
            fi
        fi
        
        # Stop McMyAdmin
        stdbuf -o0 echo -n "Try safly stopping $MC_SERVICE"
        screen -p 0 -S $MC_SESSION -X eval 'stuff /quit\015'
        sync
        
        for run in {1..10}
        do
            if ps ax | grep -v grep | grep $MC_SERVICE > /dev/null; then
                stdbuf -o0 echo -n "."
                sleep 1
            else
                break;
            fi
        done
        echo
        if ps ax | grep -v grep | grep $MC_SERVICE > /dev/null; then
            echo -e "\033[31m$MC_SERVICE is still running!\033[0m"
            exit 1
        else
            echo -e "\033[32mServer stopped.\033[0m"
        fi
    else
        echo -e "\033[32mServer not running.\033[0m"
    fi
    exit 0
}

function kill_tail {
    if ps ax | grep -v grep | grep tail > /dev/null; then
        pgrep -f tail | xargs kill
    fi
}

install_server
run_server
trap stop_server SIGTERM
trap kill_tail EXIT

echo "Script finished, attaching to the McMyAdmin log now."
sleep 3

ACTIVELOGFILE=
while true; do 
    if ps ax | grep -v grep | grep $MC_SERVICE > /dev/null; then
        LOGFILE=`ls -t ${MC_LOG_PATH} 2>/dev/null | head -n1`

        if [[ "${LOGFILE}" != "${ACTIVELOGFILE}" ]]; then
            kill_tail
            ACTIVELOGFILE=${LOGFILE}
            tail -f "${ACTIVELOGFILE}" &
            TAILPID=$!
        fi
        sleep 1
    else
        echo "$MC_SERVICE not running anymore, stop script to stop container!"
        exit 2
    fi
done