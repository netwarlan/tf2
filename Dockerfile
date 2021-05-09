## Pull our base image
FROM ubuntu:18.04

## Image Information
LABEL maintainer="Jeff Nelson <jeff@netwar.org>"
ARG DEBIAN_FRONTEND=noninteractive

## Set Build Arguments
ENV GAME_DIR="/app/tf2" \
    GAME_USER="steam" \
    STEAMCMD_APP="232250" \
    STEAMCMD_USER="anonymous" \
    STEAMCMD_PASSWORD="" \
    STEAMCMD_AUTH_CODE="" \
    STEAMCMD_DIR="/app/steamcmd"

## Start building our server
RUN dpkg --add-architecture i386
RUN apt-get update \
    && apt-get install -y \
        curl \
        lib32gcc1 \
        lib32ncurses5 \
        lib32stdc++6 \
        lib32tinfo5 \
        lib32z1 \
        libc6:i386 \
        libcurl3-gnutls:i386 \
        libncurses5 \
        libncurses5:i386 \
        libstdc++6:i386 \
        zlib1g:i386 \
        libsdl2-2.0-0:i386 \
    && apt-get clean \
    && rm -rf /var/tmp/* /var/lib/apt/lists/* /tmp/* \

    ## Create Directory Structure
    && mkdir -p $GAME_DIR \
    && mkdir -p $STEAMCMD_DIR \

    ## Create our User
    && useradd -ms /bin/bash $GAME_USER

## Copy our run script into the image
COPY run.sh $GAME_DIR/run.sh

    ## Set Directory Permissions
RUN chown -R $GAME_USER:$GAMEUSER $GAME_DIR \
    && chown -R $GAME_USER:$GAMEUSER $STEAMCMD_DIR

## Change to our User
USER $GAME_USER

## Download SteamCMD
RUN curl -s http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar -xzC $STEAMCMD_DIR \
    && $STEAMCMD_DIR/steamcmd.sh \
        +login $STEAMCMD_USER $STEAMCMD_PASSWORD $STEAMCMD_AUTH_CODE \
        +force_install_dir $GAME_DIR \
        +app_update $STEAMCMD_APP validate \
        +quit \

    ## Create symlinks and appid for Steam
    && mkdir -p ~/.steam/sdk32 \
    && ln -s $STEAMCMD_DIR/linux32/steamclient.so ~/.steam/sdk32/steamclient.so \
    && echo "$STEAMCMD_APP" > $GAME_DIR/steam_appid.txt

## Set working directory
WORKDIR $GAME_DIR

## Start the run script
CMD ["bash", "run.sh"]
