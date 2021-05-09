# Team Fortress 2
              
The following repository contains the source files for building a Team Fortress 2 server.


### Running
To run the container, issue the following example command:
```
docker run -d \
-p 27015:27015/udp \
-p 27015:27015/tcp \
-e TF2_SERVER_HOSTNAME="DOCKER TF2" \
-e TF2_SERVER_MAXPLAYERS="32" \
netwarlan/tf2
```

### Environment Variables
We can make dynamic changes to our TF2 containers by adjusting some of the environment variables passed to our image.
Below are the ones currently supported and their (defaults):

```
TF2_SERVER_PORT (27015)
TF2_SERVER_MAXPLAYERS (24)
TF2_SERVER_MAP (ctf_2fort)
TF2_SERVER_HOSTNAME (TF2 Server)
TF2_SERVER_PW (No password set)
TF2_SERVER_RCONPW (No password set)
TF2_SERVER_UPDATE_ON_START (false)
```

#### Descriptions

* `TF2_SERVER_PORT` Determines the port our container runs on.
* `TF2_SERVER_MAXPLAYERS` Determines the max number of players the * server will allow.
* `TF2_SERVER_MAP` Determines the starting map.
* `TF2_SERVER_HOSTNAME` Determines the name of the server.
* `TF2_SERVER_PW` Determines the password needed to join the server.
* `TF2_SERVER_RCONPW` Determines the RCON password needed to administer the server.
* `TF2_SERVER_UPDATE_ON_START` Determines whether the server should update itself to latest when the container starts up.