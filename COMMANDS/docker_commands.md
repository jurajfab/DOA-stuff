Login via Remote Explorer VSCode 
Change settings in VSCode: ssh path:
    ``` ssh ubuntu:Docker101@docker.training ```
    remote.SSH.path": "C:\\Program Files\\Git\\usr\\bin\\ssh.exe"
    ssh key: id_docker.pub

``` echo $HOSTIP  # show host IP ``` 
https://github.com/startbootstrap/startbootstrap-freelancer/archive/gh-pages.zip

Container = proces, spustit container znamena spustit proces v izolovanom prostredi nad jadrom hostitelskeho OS
Image = nieco ako instalacka, alebo zip. ktory viem pustit ako container kolko krat chcem
Docker = demon, ktory spusta a riadi containery 


## COMMANDS
```
docker --version                # show docker version installed on server
systemctl status docker         # show status of service docker
docker version                  # shows client and server info 
docker info                     # show info about client/server and server itself
systemctl stop/start docker     # vypne zapne sluzbu docker 
```

## CONTAINERS
```
docker container run <container_name>                               # run container (if image is not present, will be downloaded)
docker container run bletvaska/hello-world 
docker container ls                                                 # list of running containers
docker container ls --all                                           # list of all containers including stopped 
docker image ls                                                     # list of running images 
docker container exec -it <container_name> <command>                # v pustenom kontainer pusti nejaky prikaz 
docker container exec -it relaxed_goodall /bin/bash
```
```
                                ## Description of command ls ## 
CONTAINER ID   IMAGE               COMMAND                  CREATED         STATUS         PORTS      NAMES
242b2ea038e4   bletvaska/weather   "/usr/bin/python3.11…"   9 seconds ago   Up 8 seconds   8000/tcp   infallible_euclid
```
- CONTAINER ID = unique number 
- IMAGE = name of container (generated automatically) 
- COMMAND = command that starts image 
- CREATED = time when it was created 
- STATUS = status of container (created, dead, exited, paused, removing, restarting, running)
- PORTS = port which we can use 
- NAMES = name of container (unique name)
```
docker container run --name <my_container_name> <container_name> 
docker container stop <container_name>                                              # stop running container 
docker container kill --signal TERM <container_name>                                # send signal to TERMinate, KILL, CONTinue...
docker container start <container_name>                                             # start of stopped container (in background)
docker container attach <container_name>                                            # move running (started) container from background 
docker container rename <container_name> <container_new_name>                       # rename container 
docker container rm <container_id>                                                  # delete container from ls (only stopped)
docker container rm --force <container_id>                                          # delete container even running
docker container rm $(docker container ls --all --quiet --filter status=exited)     # delete of all stoped container from ls
docker container prune                                                              # delete all stoped containers from ls 
docker container run --rm <container_name>                                          # start, after stop will delete container from ls, good for testing
docker container run --detach <container_name>                                      # start container on background 
docker container stop <container_name>                                              # show logs from container 
docker container logs --follow <container_name>                                     # shows logs live 
docker container logs --follow --tail 5 <container_name>                            # shows last 5 rows from logs 
docker container run --rm --env MESSAGE="hello world" bletvaska/weather printenv    # enter variable(helloworld) to envrironment
docker container run --rm --env MESSAGE="hello world" -it bletvaska/weather bash    # spusti command bash -it (interactive)
```
## Spristupnenie portov:
``` 
docker container run --publish <host_port>:<port> <image_name>
docker container run --name weather --rm --publish 8000:8000 bletvaska/weather 
``` 
### Example of command with more variables on entry: 
``` 
docker container run --name weather --env WEATHER_QUERY="Bratislava" --env WEATHER_UPDATE_INTERVAL="30" --env WEATHER_TOKEN=9e547051a2a00f2bf3e17a160063002d bletvaska/weather
docker container run --name weather-ba --env WEATHER_QUERY="Bratislava" --env WEATHER_UPDATE_INTERVAL="30" --env WEATHER_TOKEN=9e547051a2a00f2bf3e17a160063002d -it --publish 9000:8000 bletvaska/weather
       - hostitelsky port (nalavo) musi byt vzdy iny ak spustam rovnaky container viac krat
http://18.193.119.12:9000/
```

## Ovladanie containera 
```
docker container run --env-file <file_with_variables>                  # start with variables from env file 
docker container inspect <container_name>...<container_name>           # detail info about container, can input more containers
docker container pause <container_name>                                # pause container                            
docker container unpause <container_name>                              # unpause container  
docker container stop <container_name>                                 # stop container 
docker container start <container_name>                                # start container in background
docker container attach <container_name>                               # move container to foreground 
docker container rm --force <container_name>                           # stop, remove running container with force 
docker container create <container_name>                               # create container but not start 
docker container restart <container_name>                              # restart (start/stop) container 
docker container kill <container_name>                                 # kill container 
```

### Spusti container s inym prikazom ako je definovany v dockerfile: 
```
docker container run <container_name> <command> 
docker container run nginx bash 
docker container run nginx date 
```

### Spusti container v interaktivnom mode: 
```
docker container exec -it <container_name> <command> 
docker container exec -it nginx 
```

### ENV FILE
vytvorim variables.env kde dam premmenne potom ho pouzijem v prikaze
```
WEATHER_QUERYkosice
WEATHER_TOKEN=9e547051a2a00f2bf3e17a160063002d

docker container run --rm --env-file variables.env bletvaska/weather

start kontainera bez pouzitia .env filu 
docker container run --env <"env_variable"> --env <"env_variable"> <image>
docker container run --name weather --env WEATHER_QUERY="Bratislava" --env WEATHER_UPDATE_INTERVAL="30" --env WEATHER_TOKEN=9e547051a2a00f2bf3e17a160063002d bletvaska/weather
``` 

## jq / JSON QUERRY TOOL
```
jq = nastroj na prehliadanie dokumentov v json formate (jq = json querry)
jq --help 
jq .address.krajina person.json         
```

## INSPECT CONTAINER
```
docker container inspect minio | jq .[0].NetworkSettings.Networks.bridge.IPAddress      # [0]=first  shows IP address from inspect output
docker container inspect minio | jq .[0].Config.Env
docker container inspect minio sharp_ritchie | jq .[1].NetworkSettings                                      
docker container inspect minio | jq -r .                                      # bodka = cely dokument  
docker container inspect minio weather-pp | jq .[0]
```
```
docker image pull <image_name>          # download image 
docker image rm <image_name>            # remove image 
```

## VOLUMES
```
docker image inspect bitnami/minio:latest | jq .[0].Config.Volumes      # priklad na zobrazenie volumes v image minio
docker container inspect minio | jq .[0].Mounts                         # priklad na zobrazenie volumes ake pouziva container 
docker volume ls                    # list volumes 
docker volume rm <volume_name>      # zmaze volume 
docker volume prune                 # zmaze vsetky nepouzivane anonymne volumes 
```
``` json
  {
    "Type": "volume",
    "Name": "30dc736d004500992beacb70df39a912875a2dc5791847c72a5618ba184edb4d",
    "Source": "/var/lib/docker/volumes/30dc736d004500992beacb70df39a912875a2dc5791847c72a5618ba184edb4d/_data",
    "Destination": "/certs",
    "Driver": "local",
    "Mode": "",
    "RW": true,
    "Propagation": ""
  },
  {
    "Type": "volume",
    "Name": "34aa88749ff02e08ceeba0540b1b29f723e02af17a76c608b7884d4ce2b6fac6",
    "Source": "/var/lib/docker/volumes/34aa88749ff02e08ceeba0540b1b29f723e02af17a76c608b7884d4ce2b6fac6/_data",
    "Destination": "/bitnami/minio/data",
    "Driver": "local",
    "Mode": "",
    "RW": true,
    "Propagation": ""
  }
```
```
docker container cp <files> <container_name>:<dest_path_in_container>     # nakopiruje obsah priecinka lokalne do cesty v containeri 
docker container cp freelancer/. homepage:/usr/share/nginx/html              
```

spusti container nginx homepage, vytvor volume 
``` docker container run --rm --detach --publish 80:80 --name homepage --volume homepage:/etc/nginx/templates ```
nakopiruj do volume obsah freelancer priecinku 
``` docker container cp freelancer/. homepage:/usr/share/nginx/html ```
```
docker container run <container_name> --volume <my_volume_name>:<path_to_volume_on_container> 
/var/lib/docker/volumes/minio_data/_data 
docker container run --name minio -p 9000:9000 -p 9001:9001 --env-file env-files/minio.env --volume minio_data:/bitnami/minio/data bitnami/minio
docker container run --volume minio_data:/home/work 
```

## Bind mount (local)
```
docker container run --volume home/ubuntu/freelancer:/home/work 
docker container run --rm -it --env-file minio.env --publish 9000:9000 --publish 8000:8000 --volueme $(pwd)/data:/bitnami/minio/data:Z --name minio bitnami/minio 
docker container run --rm --it --volume .:/app --user $(id --user):$(group --group) alpine        # spusti kontainer s pravami lokalneho pouzivatela 

docker container exec ui hostname           # exec spusti prikaz v containeri (shows hostname, same as container ID)
```
## DOCKER NETWORKS
```
docker network ls                   # shows networks 
NETWORK ID     NAME      DRIVER    SCOPE
b5090fe47c56   bridge    bridge    local            # ak neurobim nic a nezadam tak kontaner otava v sieti bridge
f12c9c6e247d   host      host      local            # IP addresa HOSTa (servra na ktorom bezi container), pouziva otvorene porty ktore ma otvorene HOST
c677db4d5979   none      null      local             

docker container exec ui hostname                             # exec spusti prikaz v containeri (shows hostname, same as container ID)
docker network create <network_name> 
docker network connect <network_name> <container_name>        # connect running container to other network 
docker network inspect <network_name> 
docker network disconnect <network_name> <container_name>     # disconnect container 
docker container rm <network_name>                            # delete network 

docker container run --rm --name rambo --network rambo bletvaska/rambo:1
```

## DOCKER COMPOSE
vytvori file kde nadefinujem vsetky premmenne a prepinace 
```
code docker-compose.yaml 
docker compose up                   # start containera z docker filu 
docker compose down                 # vypnutie containera z docker filu (zmaze aj siet)
docker compose down --volume        # vypne a vymaze volumes 
docker compose ps                   # shows list of running 
docker compose ls                   # shows list of running containers 


docker compose --env-file all.env up
docker compose up                 # defualt run .env 
docker compose exec -it wp bash 
```

## TAGS:
POZOR na verzie

## PUSH IMAGE TO DOCKERHUB
- prihlasim sa na dockerhub cez 
``` docker login -u <username> ```
	Zadam heslo
- pretagujem repositar ktory chcem poslat 
``` docker image tag matrix:2024 durisimo44/matrix:2024 ```
-  pushnem repositar na dockerhub 
``` docker image push durisimo44/matrix –-all-tags ```

## zobrazim historiu imageu 
``` docker image history matrix:latest ```

## Vychytavky:
Vytvorim si image kde nahazdem nastroje co chcem mat (pozri bletvaska/toolbox na github)
```
docker container run -it --rm --volume .:/home/work bletvaska/toolbox vi Dockerfile
docker container run -it --rm --volume .:/home/work --user $(id --user):$(id --group) bletvaska/toolbox touch file
alias dvim='docker container run -it --rm --volume .:/home/work --user $(id --user):$(id --group) bletvaska/toolbox vim'
```

## DOCKER CONTEXT
context = docker endpoint with docker deamon installed
```
docker context ls                 # show contexts
docker context inspect default    # shows configuration of context
docker context rm <context_name>               # delete context 
```
### Context creation
```
docker context create –description <some description> --docker <connection> <name of context >                        # create context 
docker context create --description "AWS machine for docker training" --docker "host=ssh://ubuntu@3.121.22.38" aws
docker context create atlantis --docker "host=ssh://mirek@atlantis.cnl.sk" --description "Docker Machine" 

docker context use <name_of_context>        # pouzitie ineho contextu 
docker context use aws 
```

### DOCKER STATS
```
docker container stats        # ukaze ako vytazuju containeri zdroje host servera 
docker container run --name toolbox -it --rm --memory 100M bletvaska/toolbox bash             # limitujem container, nevyuzije viac ako 100M 
docker container run --name toolbox -it --rm --cpus 2 --memory 100M bletvaska/toolbox bash    # limituje CPU a pamat 
      stress-ng --vm 1 --vm-bytes 200M -t 10
# viem zapisovat tieto limity do docker-compose.yaml 
```

### CREATING OF OWN REGISTRY
```
docker container run --rm -it --detach --name registry --publish 5000:5000 --volume registry_data:/var/lib/registry registry

# Vybuildujem image :
docker image build --tag matrix:latest .
# Pretagujem image aby mal v nazve register ktory som vytvoril 
docker image tag matrix:latest localhost:5000/matrix
# Pushnem image do registra 
docker image push localhost:5000/matrix
# Pull/Run container z imagu z mojho registra 
docker container run --rm -it localhost:5000/matrix
# Zobraz co je v mojom vytvorenom repository
http http://localhost:5000/v2/_catalog
```

### Start of Portainer 
```
docker container run \
  --detach \
  --publish 9443:9443 \
  --name portainer \
  --restart always \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  --volume portainer_data:/data \
  portainer/portainer-ce
```

### watchtower 
```
docker container run --rm -it --name watchtower --volume /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower
docker container run --rm -it --name watchtower --volume /var/run/docker.sock:/var/run/docker.sock --env TZ=Europe/Bratislava containrrr/watchtower --interval 30 portainer duri-db-1 adminer
```
