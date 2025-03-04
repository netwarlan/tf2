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
╚═══════════════════════════════════════════════╝"


## Set default values if none were provided
## ==============================================
[[ -z "$TF2_SERVER_PORT" ]] && TF2_SERVER_PORT="27015"
[[ -z "$TF2_SERVER_MAXPLAYERS" ]] && TF2_SERVER_MAXPLAYERS="24"
[[ -z "$TF2_SERVER_MAP" ]] && TF2_SERVER_MAP="ctf_2fort"
[[ -z "$TF2_SVLAN" ]] && TF2_SVLAN="0"
[[ -z "$TF2_SERVER_HOSTNAME" ]] && TF2_SERVER_HOSTNAME="TF2 Server"
[[ ! -z "$TF2_SERVER_PW" ]] && TF2_SERVER_PW="sv_password $TF2_SERVER_PW"
[[ ! -z "$TF2_SERVER_RCONPW" ]] && TF2_SERVER_RCONPW="rcon_password $TF2_SERVER_RCONPW"
[[ -z "$TF2_SERVER_REMOTE_CFG" ]] && TF2_SERVER_REMOTE_CFG=""
[[ -z "$TF2_SERVER_UPDATE_ON_START" ]] && TF2_SERVER_UPDATE_ON_START=true
[[ -z "$TF2_SERVER_VALIDATE_ON_START" ]] && TF2_SERVER_VALIDATE_ON_START=false
[[ -z "$TF2_SERVER_ENABLE_PROPHUNT" ]] && TF2_SERVER_ENABLE_PROPHUNT=false
[[ -z "$TF2_SERVER_CONFIG" ]] && TF2_SERVER_CONFIG="server.cfg"



## Update on startup
## ==============================================
if [[ "$TF2_SERVER_UPDATE_ON_START" = true ]] || [[ "$TF2_SERVER_VALIDATE_ON_START" = true ]]; then
echo "
╔═══════════════════════════════════════════════╗
║ Checking for updates                          ║
╚═══════════════════════════════════════════════╝"
  VALIDATE_FLAG=''
  if [[ "$TF2_SERVER_VALIDATE_ON_START" = true ]]; then
    VALIDATE_FLAG='validate'
  fi

  $STEAMCMD_DIR/steamcmd.sh \
  +force_install_dir $GAME_DIR \
  +login $STEAMCMD_USER $STEAMCMD_PASSWORD $STEAMCMD_AUTH_CODE \
  +app_update $STEAMCMD_APP $VALIDATE_FLAG \
  +quit

fi




## Build server config
## ==============================================
echo "
╔═══════════════════════════════════════════════╗
║ Building server config                        ║
╚═══════════════════════════════════════════════╝"
cat <<EOF > ${GAME_DIR}/tf/cfg/$TF2_SERVER_CONFIG
// Values passed from Docker environment
$TF2_SERVER_PW
$TF2_SERVER_RCONPW
host_name_store 1
host_info_show 1
host_players_show 2
EOF




## Download config if needed
## ==============================================
if [[ ! -z "$TF2_SERVER_REMOTE_CFG" ]]; then
echo "
╔═══════════════════════════════════════════════╗
║ Downloading remote config                     ║
╚═══════════════════════════════════════════════╝"
  echo "  Downloading config..."
  TF2_SERVER_CONFIG=$(basename "$TF2_SERVER_REMOTE_CFG")
  curl --silent -O --output-dir $GAME_DIR/tf/cfg/ $TF2_SERVER_REMOTE_CFG
  echo "  Setting $FILENAME as our server exec"
  chmod 770 $GAME_DIR/tf/cfg/$TF2_SERVER_CONFIG
fi




## Check if we are running Prop Hunt
## ==============================================
if [[ "$TF2_SERVER_ENABLE_PROPHUNT" = true ]]; then
echo "
╔═══════════════════════════════════════════════╗
║ Setting up Prop Hunt                          ║
╚═══════════════════════════════════════════════╝"
METAMOD_BASE_URL="https://mms.alliedmods.net/mmsdrop/1.11"
SOURCEMOD_BASE_URL="https://sm.alliedmods.net/smdrop/1.11"
TF2ITEMS_BUILD_URL="https://builds.limetech.io/files/tf2items-1.6.4-hg279-linux.zip"
METAMOD_LATEST=$(curl -s ${METAMOD_BASE_URL}/mmsource-latest-linux)
SOURCEMOD_LATEST=$(curl -s ${SOURCEMOD_BASE_URL}/sourcemod-latest-linux)

echo "Installing MetaMod"
curl -s ${METAMOD_BASE_URL}/${METAMOD_LATEST} | tar -xzC $GAME_DIR/tf
cat <<EOF >> $GAME_DIR/tf/metamod.vdf
"Plugin"
{
  "file" "../tf/addons/metamod/bin/server"
}
EOF

echo "Installing SourceMod"
curl -s ${SOURCEMOD_BASE_URL}/${SOURCEMOD_LATEST} | tar -xzC $GAME_DIR/tf

echo "Installing PropHunt Plugins"
curl -s ${TF2ITEMS_BUILD_URL} --output /tmp/items.zip
unzip -qq -o /tmp/items.zip -d $GAME_DIR/tf

echo "Installing Maps/Sounds/Configs"
mkdir /tmp/prophunt-data
curl -sL https://github.com/netwarlan/tf2-extras/archive/main.tar.gz | tar -xzC /tmp/prophunt-data
cp -R /tmp/prophunt-data/tf2-extras-main/prophunt/maps/. $GAME_DIR/tf/maps
cp -R /tmp/prophunt-data/tf2-extras-main/prophunt/sound/. $GAME_DIR/tf/sound
cp -R /tmp/prophunt-data/tf2-extras-main/prophunt/addons/. $GAME_DIR/tf/addons
cp /tmp/prophunt-data/tf2-extras-main/prophunt/mapcycle_prophunt.txt $GAME_DIR/tf/cfg/mapcycle_prophunt.txt
rm -rf /tmp/prophunt-data #Clean up our temp files

echo "Setting up Fast Downloading of map files"
echo 'sv_downloadurl "https://raw.githubusercontent.com/netwarlan/tf2-extras/main/prophunt"' >> $GAME_DIR/tf/cfg/server.cfg

fi



## Print Variables
## ==============================================
echo "
╔═══════════════════════════════════════════════╗
║ Server set with provided values               ║
╚═══════════════════════════════════════════════╝"
printenv | grep TF2



## Run
## ==============================================
echo "
╔═══════════════════════════════════════════════╗
║ Starting server                               ║
╚═══════════════════════════════════════════════╝"

## Escaped double quotes help to ensure hostnames with spaces are kept intact
$GAME_DIR/srcds_run -game tf -console -usercon \
+hostname \"${TF2_SERVER_HOSTNAME}\" \
+exec $TF2_SERVER_CONFIG \
+port $TF2_SERVER_PORT \
+maxplayers $TF2_SERVER_MAXPLAYERS \
+map $TF2_SERVER_MAP \
+sv_lan $TF2_SVLAN