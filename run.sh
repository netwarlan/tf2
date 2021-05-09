#!/usr/bin/env bash

echo "


╔═══════════════════════════════════════════════╗
║                                               ║
║       _  _____________      _____   ___       ║  
║      / |/ / __/_  __/ | /| / / _ | / _ \      ║
║     /    / _/  / /  | |/ |/ / __ |/ , _/      ║
║    /_/|_/___/ /_/   |__/|__/_/ |_/_/|_|       ║
║                                 OFFICIAL      ║
║                                               ║
╠═══════════════════════════════════════════════╣
║ Thanks for using our DOCKER image! Should you ║
║ have issues, please reach out or create a     ║
║ a github issue. Thanks!                       ║
║                                               ║
║ For more information:                         ║
║ https://github.com/netwarlan                  ║
╚═══════════════════════════════════════════════╝
"

## Startup
[[ -z "$TF2_SERVER_PORT" ]] && TF2_SERVER_PORT="27015"
[[ -z "$TF2_SERVER_MAXPLAYERS" ]] && TF2_SERVER_MAXPLAYERS="24"
[[ -z "$TF2_SERVER_MAP" ]] && TF2_SERVER_MAP="ctf_2fort"

## Config
[[ -z "$TF2_SERVER_HOSTNAME" ]] && TF2_SERVER_HOSTNAME="TF2 Server"
[[ ! -z "$TF2_SERVER_PW" ]] && TF2_SERVER_PW="sv_password $TF2_SERVER_PW"
[[ ! -z "$TF2_SERVER_RCONPW" ]] && TF2_SERVER_RCONPW="rcon_password $TF2_SERVER_RCONPW"

cat <<EOF >$GAME_DIR/tf/cfg/server.cfg
hostname $TF2_SERVER_HOSTNAME
$TF2_SERVER_PW
$TF2_SERVER_RCONPW
EOF


## Update
if [[ "$TF2_SERVER_UPDATE_ON_START" = true ]];
then
echo "
╔═══════════════════════════════════════════════╗
║ Checking for Updates                          ║
╚═══════════════════════════════════════════════╝
"
$STEAMCMD_DIR/steamcmd.sh \
+login $STEAMCMD_USER $STEAMCMD_PASSWORD $STEAMCMD_AUTH_CODE \
+force_install_dir $GAME_DIR \
+app_update $STEAMCMD_APP validate \
+quit

echo "
╔═══════════════════════════════════════════════╗
║ SERVER up to date                             ║
╚═══════════════════════════════════════════════╝
"
fi

## Run
echo "
╔═══════════════════════════════════════════════╗
║ Starting SERVER                               ║
╚═══════════════════════════════════════════════╝
"
$GAME_DIR/srcds_run -game tf -console -usercon +port $TF2_SERVER_PORT +maxplayers $TF2_SERVER_MAXPLAYERS +map $TF2_SERVER_MAP +sv_lan 1 -secure
