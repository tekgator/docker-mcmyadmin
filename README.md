# docker-mcmyadmin

McMyAdmin Panel docker file to administrate and run all variants of a Java Minecraft Server.

## Description

Goal of this docker image is to create an easy to use docker file providing the up to date McMyAdmin Panel which can run all kinds of Java Minecraft versions. Inspiration came from [McMyAdmin Docker image](https://hub.docker.com/r/jchaney/mcmyadmin/) by [jchaney](https://hub.docker.com/r/jchaney), a special thanks to him. I needed a little fine tuning and bugfixing here and there so I decided to create a own Docker file.

## Details

* Utilizing openjdk:11-jdk-slim
* McMyAdmin Minecraft web based admin panel
* The McMyAdmin Admin panel runs under minecraft user on port tcp/8080
* The actual Minecraft server runs on default port tcp/25565
* Maps a volume so you are free to make changes to configuration of McMyAdmin and Minecraft
* Includes GIT so the Spigot server jar can be build by McMyAdmin
* Java.Memory defaults to 1GB RAM / recommend are at least 2GB RAM on server
* If you like to run the [Dynmap](https://dev.bukkit.org/projects/dynmap/files) plugin consider using the extension of this image [tekgator/docker-mmcmyadmin-dynmap](https://hub.docker.com/r/tekgator/docker-mcmyadmin-dynmap)

## Run

docker run -i -d --name McMyAdmin -p 8080:8080 -p 25565:25565 -v McMyAdmin_data:/McMyAdmin tekgator/docker-mcmyadmin

## Next steps

1. Open http://localhost:8080
2. Login with admin/pass123
3. Change the password!!!
4. Select the Minecraft version to run in the settings e.g. Vanilla, Spigot, etc. and press the install button (note Spigot build will take a while)
5. Configure your Minecraft server in the server settings
6. Click Start Server from Status tab (this will stop/restart a couple times, be patient)

## Adding Plugins or changing configuration of McMyAdmin / Minecraft

Within the mounted volume you can find.

* The `McMyAdmin.conf` file to configure the McMyAdmin Panel like Java RAM usage, etc.
* The `Minecraft` where you can find the `server.properties`, `logs`, etc.
* The `plugin` folder to add mods and change the configuration of mods