#!/bin/bash
set -e

MC_SERVICE='./MCMA2_Linux_x86_64'
MC_SESSION='minecraft'

MC_LOG_PATH="$VOLUME_PATH/MCMA_Logs/*.log"

function install_server {
    if [ ! -f McMyAdmin.conf ]; then
        echo -e "\nFirst start of the docker container start installation of McMyAdmin."
        echo "Please be patient, this will only take a few seconds!"

        touch $VOLUME_PATH/McMyAdmin.conf
        mkdir -p $VOLUME_PATH/Minecraft
        mkdir -p $VOLUME_PATH/Backups
        mkdir -p $VOLUME_PATH/Exec
        mkdir -p $VOLUME_PATH/MCMA_Logs
        mkdir -p $VOLUME_PATH/Public
		cp $INSTALL_PATH/server.properties $VOLUME_PATH/Minecraft
        
        ln -s $VOLUME_PATH/McMyAdmin.conf $INSTALL_PATH
        ln -s $VOLUME_PATH/Minecraft $INSTALL_PATH
        ln -s $VOLUME_PATH/Backups $INSTALL_PATH
        ln -s $VOLUME_PATH/Exec $INSTALL_PATH
        ln -s $VOLUME_PATH/MCMA_Logs $INSTALL_PATH
        ln -s $VOLUME_PATH/Public $INSTALL_PATH

        if [ "$EULA" == "1" ]; then
            echo -e "\nUser accepts EULA, create EULA.txt file."
            echo 'eula=true' > $VOLUME_PATH/Minecraft/eula.txt
        fi

        # unfortunately updating and setting the initial password cannot be combined, so two calls are made
        cd $INSTALL_PATH
        ./MCMA2_Linux_x86_64 -nonotice -updateonly
        ./MCMA2_Linux_x86_64 -configonly -setpass $MC_PWD

        # 1GB RAM is way to less to start running in a docker, therefore adjust conf to 2048 by default
        sed -i 's/Java.Memory=1024/Java.Memory=2048/g' $VOLUME_PATH/McMyAdmin.conf

        echo -e "\n************************************************************************" \
                "\n* Installation of McMyAdmin finished, access via http://localhost:8080 *" \
                "\n* Username: admin                                                      *" \
                "\n* Password: ${MC_PWD} (should be changed on first login)               *" \
                "\n************************************************************************\n"
    fi
}

function run_server {
    if ps ax | grep -v grep | grep "./MCMA2_Linux_x86_64" > /dev/null
    then
        echo "$MC_SERVICE is already running!"
    else
        echo "Starting $MC_SERVICE..."
        cd $INSTALL_PATH
        screen -dmS $MC_SESSION $MC_SERVICE
        sleep 1
        echo "$MC_SERVICE started."
    fi

    echo -e "\n************************************************************************" \
            "\n* McMyAdmin started, access via http://localhost:8080                  *" \
            "\n************************************************************************\n"    
}

function stop_server {
    if ps ax | grep -v grep | grep $MC_SERVICE > /dev/null
    then
        echo "Stopping server..."

		# Stop Minecraft server java file, if running
		if ps ax | grep -v grep | grep java > /dev/null
		then
			stdbuf -o0 echo -n "Try safly stopping Minecraft Server jar"
			screen -p 0 -S $MC_SESSION -X eval 'stuff /stop\015'
			sync

			for run in {1..10}
			do
				if ps ax | grep -v grep | grep java > /dev/null
				then
					stdbuf -o0 echo -n "."
					sleep 1
				else
					break;
				fi
			done
			echo
			if ps ax | grep -v grep | grep java > /dev/null
			then
				echo -e "\033[31mMinecraft is still running, possible data loss!\033[0m"
			fi
		fi
		
		# Stop McMyAdmin
		stdbuf -o0 echo -n "Try safly stopping $MC_SERVICE"
        screen -p 0 -S $MC_SESSION -X eval 'stuff /quit\015'
        sync
		
		for run in {1..10}
		do
			if ps ax | grep -v grep | grep $MC_SERVICE > /dev/null
			then
				stdbuf -o0 echo -n "."
				sleep 1
			else
				break;
			fi
		done
        echo
		if ps ax | grep -v grep | grep $MC_SERVICE > /dev/null
        then
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
    if ps ax | grep -v grep | grep tail > /dev/null
    then
        pgrep -f tail | xargs kill
    fi
}

install_server
run_server
trap stop_server SIGTERM
trap kill_tail EXIT

echo -e "\n************************************************************************" \
        "\n* Script is finished and going to sleep now, attaching to the log.     *" \
        "\n************************************************************************\n"    
sleep 3


ACTIVELOGFILE=
while true; do 
    if ps ax | grep -v grep | grep $MC_SERVICE > /dev/null
    then
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