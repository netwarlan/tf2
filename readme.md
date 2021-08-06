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

Environment Variable | Default Value
-------------------- | -------------
TF2_SERVER_PORT | 27015
TF2_SERVER_MAXPLAYERS | 24
TF2_SERVER_MAP | ctf_2fort
TF2_SERVER_HOSTNAME | TF2 Server
TF2_SVLAN | 0
TF2_SERVER_PW | No password set
TF2_SERVER_RCONPW | No password set
TF2_SERVER_UPDATE_ON_START | true
TF2_SERVER_VALIDATE_ON_START | false
TF2_SERVER_ENABLE_REMOTE_CFG | false
TF2_SERVER_REMOTE_CFG | No url set