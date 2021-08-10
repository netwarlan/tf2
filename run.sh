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
║ github issue. Thanks!                         ║
║                                               ║
║ For more information:                         ║
║ github.com/netwarlan                          ║
╚═══════════════════════════════════════════════╝
"


## Set default values if none were provided
## ==============================================
[[ -z "$TF2_SERVER_PORT" ]] && TF2_SERVER_PORT="27015"
[[ -z "$TF2_SERVER_MAXPLAYERS" ]] && TF2_SERVER_MAXPLAYERS="24"
[[ -z "$TF2_SERVER_MAP" ]] && TF2_SERVER_MAP="ctf_2fort"
[[ -z "$TF2_SVLAN" ]] && TF2_SVLAN="0"
[[ -z "$TF2_SERVER_HOSTNAME" ]] && TF2_SERVER_HOSTNAME="TF2 Server"
[[ ! -z "$TF2_SERVER_PW" ]] && TF2_SERVER_PW="sv_password $TF2_SERVER_PW"
[[ ! -z "$TF2_SERVER_RCONPW" ]] && TF2_SERVER_RCONPW="rcon_password $TF2_SERVER_RCONPW"
[[ -z "$TF2_SERVER_ENABLE_REMOTE_CFG" ]] && TF2_SERVER_ENABLE_REMOTE_CFG=false
[[ -z "$TF2_SERVER_UPDATE_ON_START" ]] && TF2_SERVER_UPDATE_ON_START=true
[[ -z "$TF2_SERVER_VALIDATE_ON_START" ]] && TF2_SERVER_VALIDATE_ON_START=false




## Update on startup
## ==============================================
if [[ "$TF2_SERVER_UPDATE_ON_START" = true ]] || [[ "$TF2_SERVER_VALIDATE_ON_START" = true ]]; then
echo "
╔═══════════════════════════════════════════════╗
║ Checking for updates                          ║
╚═══════════════════════════════════════════════╝
"
  if [[ "$TF2_SERVER_VALIDATE_ON_START" = true ]]; then
    VALIDATE_FLAG='validate'
  else 
    VALIDATE_FLAG=''
  fi

  $STEAMCMD_DIR/steamcmd.sh \
  +login $STEAMCMD_USER $STEAMCMD_PASSWORD $STEAMCMD_AUTH_CODE \
  +force_install_dir $GAME_DIR \
  +app_update $STEAMCMD_APP $VALIDATE_FLAG \
  +quit

fi





## Download config if needed
## ==============================================
if [[ "$TF2_SERVER_ENABLE_REMOTE_CFG" = true ]]; then
echo "
╔═══════════════════════════════════════════════╗
║ Downloading remote config                     ║
╚═══════════════════════════════════════════════╝
"
  if [[ -z "$TF2_SERVER_REMOTE_CFG" ]]; then
    echo "  Remote config enabled, but no URL provided..."
  else
    echo "  Downloading config..."
    wget -q $TF2_SERVER_REMOTE_CFG -O $GAME_DIR/tf/cfg/server.cfg
  fi

fi




## Build server config
## ==============================================
echo "
╔═══════════════════════════════════════════════╗
║ Building server config                        ║
╚═══════════════════════════════════════════════╝
"
cat <<EOF >> $GAME_DIR/tf/cfg/server.cfg
// Values passed from Docker environment
$TF2_SERVER_PW
$TF2_SERVER_RCONPW
EOF





## Run
## ==============================================
echo "
╔═══════════════════════════════════════════════╗
║ Starting server                               ║
╚═══════════════════════════════════════════════╝
  Hostname: ${TF2_SERVER_HOSTNAME}
  Port: ${TF2_SERVER_PORT}
  Max Players: ${TF2_SERVER_MAXPLAYERS}
  Map: ${TF2_SERVER_MAP}
"

## Escaped double quotes help to ensure hostnames with spaces are kept intact
$GAME_DIR/srcds_run -game tf -console -usercon +hostname \"${TF2_SERVER_HOSTNAME}\" +port $TF2_SERVER_PORT +maxplayers $TF2_SERVER_MAXPLAYERS +map $TF2_SERVER_MAP +sv_lan $TF2_SVLAN