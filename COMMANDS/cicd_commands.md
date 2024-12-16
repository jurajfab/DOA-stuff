``` 
sudo -s             # switch to root
```

## Instalacia Docker ##
```
curl -fsSL https://get.docker.com -o get-docker.sh      # stiahne script na nainstalovanie dockeru 
sh get-docker.sh                                        # spusti script a nainstaluje docker 
systemctl enable docker                                 # enable docker 
systemctl restart docker                                # restartovat docker, ak nepojde deamon 
```

## Instalacia RUNNER ## 
```
apt update 
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash   # nainstaluje git runner repositar 
apt install gitlab-runner                               # nainstaluje gitlab runner 

gitlab-runner -version          # ukaze verziu runnera 
gitlab-runner restart           # restartuje runnera
gitlab-runner verify            # overi/skontroluje runnera 
gitlab-runner list              # vylistuje runnery 
```
## Vytvorenie usera
```
useradd -m devops               # vytovri usera devops 
ssh-keygen -o                   # vytvorim par klucov
Na gitlabe si vytvorim variable SSH_PRIVATE_KEY
passwd <user>                   # nastavim heslo 
switchnem sa na ROOTa 
v .ssh nakopirujem .pub do authorized_keys
cp id_ed25519.pub authorized_keys
otestujem prihlasenie cez kluc: ssh -i id_ed25519 devops@127.0.0.1
```

.gitlab-ci.yml
```yml
image: alpine
variables:
    AWS_IP: "54.93.216.209"
    USER: devops
```
## Test SSH:
```yml
script:
    - apk update ; apk add openssh-client
    - eval $(ssh-agent -s)
    - echo "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add - > /dev/null
    - mkdir -p ~/.ssh
    - chmod 700 ~/.ssh
    - ssh-keyscan $AWS_IP >> ~/.ssh/known_hosts
    - chmod 644 ~/.ssh/known_hosts
    - ssh $USER@$AWS_IP "date;"
    - echo "54.93.216.209" > data_ip.txt
    - scp data_ip.txt $USER@$AWS_IP:/tmp
```

## Trigger pipeline from VM ###
1. vygenerujes TOKEN 
2. pustis tento command na VM 
```
curl -X POST \
     --fail \
     -F token=glptt-8090932eadbf18438fce15a9098a7b0d33203378 \    # moj vygenerovany token
     -F ref=main \                                                # na akej branchi spustam pipeline 
     -F variables[VAR]="value123"                                 # mozem posunut aj nejaku premmennu 
     https://gitlab.com/api/v4/projects/64210314/trigger/pipeline
```
mozem to pustit tak ze vystup z commandu mi da do formatu jq 
``` curl -X POST --fail -F token=glptt-8090932eadbf18438fce15a9098a7b0d33203378 -F ref=main -F variables[VAR]="value123" https://gitlab.com/api/v4/projects/64210314/trigger/pipeline | jq ```

## Container registry build
1. vytvoris si Dockerfile 
```Dockerfile
FROM busybox
MAINTAINER Juraj Fabry
ENTRYPOINT ["/bin/cat"]
CMD ["/etc/passwd"]
```

2. vytvoris pipeline 
```yml
build:
  image: docker
  stage: build
  services:
    - docker
  script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY     # premmenne ktorymi sa prihlasujem do gitlabu 
    - docker build -t registry.gitlab.com/jjfabry/test-container-registry .     #-t TAG, 
    - docker push registry.gitlab.com/jjfabry/test-container-registry
```

Spustis Pipeline
skontrolujes ci vytvorilo register Project / Deploy / Container Registry 

NA VM pod ROOTom : 
```
docker login registry.gitlab.com
docker run registry.gitlab.com/jjfabry/test-container-registry
```

https://gitlab.com/api/v4/projects/64210314/ref/main/trigger/pipeline?token=glptt-8090932eadbf18438fce15a9098a7b0d33203378

## Package register
Command example: 
``` 
    - 'curl --header "JOB-TOKEN: $CI_JOB_TOKEN" --upload-file <source_to_the_file> "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/<package_name>/<version>/<file>"'
    
    - 'curl --header "JOB-TOKEN: $CI_JOB_TOKEN" --upload-file src/java-app/target/hello-world-1.war "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/java_package/1.0.0/HelloWorld.class"'
```

java-registry-test
ACCESS TOKEN: token
Project ID: 64291359


## Upload z VM do Gitlab package register: 
``` curl --header "PRIVATE-TOKEN: token" --upload-file /etc/passwd "https://gitlab.com/api/v4/projects/64291359/packages/generic/users-groups/0.0.1/file.txt?status=default" ``` 

## Download z Gitlab package register na VM:
``` curl --header "PRIVATE-TOKEN: token" "https://gitlab.com/api/v4/projects/64291359/packages/generic/users-groups/0.0.1/file.txt" ```
