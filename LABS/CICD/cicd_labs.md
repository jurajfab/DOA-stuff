## Lab01: vytvorenie .gitlab-ci.yml
1. Vytvor novy projekt a vytvor .gitlab-ci.yml 

Build / Pipeline editor / Configure pipeline
.gitlab-ci.yml 
```yml
stages:          # List of stages for jobs, and their order of execution
  - build
  - test
  - deploy

build-job:       # This job runs in the build stage, which runs first.
  stage: build
  script:
    - echo "Compiling the code..."
    - echo "Compile complete."

unit-test-job:   # This job runs in the test stage.
  stage: test    # It only starts when the job in the build stage completes successfully.
  script:
    - echo "Running unit tests... This will take about 60 seconds."
    - sleep 60
    - echo "Code coverage is 90%"

lint-test-job:   # This job also runs in the test stage.
  stage: test    # It can run at the same time as unit-test-job (in parallel).
  script:
    - echo "Linting code... This will take about 10 seconds."
    - sleep 10
    - echo "No lint issues found."

deploy-job:      # This job runs in the deploy stage.
  stage: deploy  # It only runs when *both* jobs in the test stage complete successfully.
  environment: production
  script:
    - echo "Deploying application..."
    - echo "Application successfully deployed."
```
Commit changes 

Build / Pipelines / New Pipeline / Run pipeline 

######################################################

## Lab02: Create new project
1. Create new .gitlab-ci.yml
2. use docker busybox
3. job named welcome
4. script run echo “Ahoj svet”
5. Commit .yml
6. Check result of CI/CD

SOLUTION:
.gitlab-ci.yml
```yml
image: busybox

stages:          
  - build

welcome:      
  stage: build
  script:
    - echo "Hello World!"
```
commit 

#########################################################

## Lab03: Vytvorenie runnera
SOLUTION:
Project / Settings / CICD / Runners / New project runner 
Vyplnis par veci a das vytvorit 

Registracia Runnera na serveri: 
``` gitlab-runner register --url https://gitlab.com --token <token> 

root@ip-172-31-27-171:/home/ubuntu# gitlab-runner register --url https://gitlab.com --token <token>
Runtime platform                                    arch=amd64 os=linux pid=383722 revision=12030cf4 version=17.5.3
Running in system-mode.                            
                                                   
Enter the GitLab instance URL (for example, https://gitlab.com/):
[https://gitlab.com]: 
Verifying runner... is valid                        runner=t3_h8tPzz
Enter a name for the runner. This is stored only in the local config.toml file:
[ip-172-31-27-171]: lab03       # zadas mu meno     
Enter an executor: shell, ssh, docker-windows, docker+machine, kubernetes, docker-autoscaler, instance, custom, parallels, virtualbox, docker:
docker
Enter the default Docker image (for example, ruby:2.7):
busybox
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded!
```

na gitlabe: view runners 

.gitlab-ci.yml 
```yml
image: ubuntu 
job1:
    script: echo "hello world"
    tags:   # staci ak dam jeden tag ktory obsahuje aj moj runner, ak dam viac musim dat vsetky ktore ma runner inac nepojde 
        - doa924
        - telekom
        - devops
```
Viem zadefinovat aj default tagy pre vsetky joby 
```yml
image: ubuntu 
default:
    tags: 
        - doa924
        - telekom
        - devops 
job1:
    script: echo "hello world"
job2:
    script: echo "hello slovakia"
```

#########################################################

## Lab04: Runner pre skupinu
Groups / create new group / group04
Build / Runners / new group runner 
```
gitlab-runner register --url https://gitlab.com --token glrt-t2_Rgr5HbBnJoTo5bzgu6DD
lab04
```
Ak dam enable na projekt 
```yml
job1:
    script: echo "test of group runner"
    tags:
        - devops 
job2:
    script: hostname
    tags:
        - telekom
```
## Lab05: 
1. vytvorim si program.c 
2. vytovrim si testovaci script 
3. vytvorim si pipelinu 
- before_script cast je ze pred kazdym jobom daco spravi
- after_script urobi nieco po jobe 
```
#!/bin/bash
VYS=$(echo -e "2\n3\n"| ./program)
if test $VYS -eq 5
then
  exit 0
else
  exit 1
fi
```
###############################################################

## Lab06: Pipeline podla zadania
1. Create new project.
2. Create stages : build, test, deploy.
3. Before anything run update process of apt (apt update; apt -y upgrade)
4. Use docker image ubuntu.
5. During stage build create job compiling with script gcc -o ./binary/demo demo.c
    - create some funny demo.c program in git repo
    
```
#include<stdio.h>
int main() {
printf("Hello World");
return 0;
}
```
``` install gcc package “apt update;apt install -y gcc” ```

6. During stage test, create job testing_file with script which test existence of file ./binary/demo.
7. During stage deploy, create job uploading which save results of the build into artifacts.
8. Create job which cleanup binary folder in case of any error, stage - deploy.
9. Create job named button performed manually which generate some output “echo” only on the branch main, stage - deploy.

SOLUTION:
```c
demo.c 
#include<stdio.h>
int main() {
printf("Hello World");
return 0;
}
```
.gitlab-ci.yml
```yml
image: ubuntu

cache:
  paths:
    - "./binary/demo"

stages:
  - build
  - test
  - deploy

before_script:
    - apt update; apt -y upgrade

compiling:       
  stage: build
  script:
    - apt update; apt install -y gcc
    - mkdir -p ./binary
    - gcc -o ./binary/demo demo.c

testing_file:   
  stage: test    
  script:
    - test -f "./binary/demo"
#    - '[ ! -d "./binary/demo" ] && mkdir -p "./binary/demo" && echo "Directory ./binary/demo created." || echo "Directory ./binary/demo already exists."'

uploading:     
  stage: deploy
  environment: production
  script:
    - echo "creating artifact..."
  artifacts:
    paths:
        - "./binary/demo"

cleanup:   
  stage: deploy    
  script:
    - rm ./binary/demo
  when: on_failure

button:   
  stage: deploy    
  script:
    - echo "job done..."
  when: manual
  only:
      - main
```
#######################################################

## Lab07: Clone git project
1. clone to your new project repo https://github.com/kriru/firstJava
2. use image: openjdk
3. create pipeline to compile and execute HelloWorld.java
- javac HelloWorld.java (compile)
- java HelloWorld (run)
4. download compiled HelloWorld.class 

SOLUTION:
Project / New Project / Import project / Repository by URL
```yml
image: openjdk

build-and-run:
    script:
        - echo "compiling..."
        - javac HelloWorld.java
        - echo "executing..."
        - java HelloWorld
        - echo "creating artifact..."
    artifacts:
        paths:
            - ./HelloWorld.class
```
##############################################################

## Lab08: Prepojenie gitlabu s VM cez SSH ---
SOLUTION: 
### vytvorenie usera
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
```yml
.gitlab-ci.yml
image: alpine
variables:
    AWS_IP: "54.93.216.209"
    USER: devops
```
Test SSH:
``` 
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
#################################################################

## Lab09: Pages
Create a new project 
Create config .gitlab-ci.yml
  image: fedora:32
  job: pages 

SOLUTION:
```yml
image: fedora:32

pages:
    script:
        - yum -y install publican-doc publican wget
        - wget http://zeus.fei.tuke.sk/devops.tar
        - tar xvf devops.tar
        - cd devops
        - publican build --langs en-US --formats html-single
        - test -d ../public || mkdir ../public
        - cp -r tmp/en-US/html-single/* ../public/
    artifacts:
        paths:
            - public
```
################################################################

## Lab10: Service mysql --- 
SOLUTION:
```yml
variables:
    MYSQL_DATABASE: "db_name"
    MYSQL_ROOT_PASSWORD: "dbpass"
    MYSQL_USER: "username"
    MYSQL_PASSWORD: "dbpass"
    MYSQL_HOST: mysql

test:
  image: python:latest
  services:
    - mysql:5.7
  script:
    - apt-get update && apt-get install -y git curl libmcrypt-dev default-mysql-client
    - mysql --version
    - wget http://zeus.fei.tuke.sk/mysqlsampledatabase.zip
    - unzip mysqlsampledatabase.zip
    - cat mysqlsampledatabase.sql | mysql --user=$MY_SQL_USER --password=$MYSQL_ROOT_PASSWORD --host=$MYSQL_HOST mysql
    - echo "select * from customers" | mysql --user=$MY_SQL_USER --password=$MYSQL_ROOT_PASSWORD --host=$MYSQL_HOST classicmodels > customers
  artifacts:
    paths:
        - customers 
```
######################################################################

--- Lab11: Creating dockerfile and registry --- 
1. Create one Dockerfile for calculating 2+3 and print result.
2. Create second Dockerfile config for calculating 3*3 and print result.
3. Create gitlab-ci.yml for building docker images.
    ○ First config will be for main branch
    ○ Second config for other branches
    ○ Create job to push and run master image on GitLab infrastructure.
4. Try newly created images on shared runner

SOLUTION: 
Dockerfile1
```Dockerfile
FROM alpine
CMD ["sh", "-c", "echo $((2+3))"]
```

Dockerfile2
```Dockerfile
FROM alpine
CMD ["sh", "-c", "echo $((3*3))"]
```

.gitlab-ci.yml
```yml
stages:
    - build
    - test1
    - test2 

build:
  image: docker
  stage: build
  services:
    - docker:dind
  script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    # docker build -f <dockerfile> -- tag register/user/projekt:tag .
    - docker build -f Dockerfile1 -t registry.gitlab.com/jjfabry/lab-calculator:1 .
    - docker build -f Dockerfile2 -t registry.gitlab.com/jjfabry/lab-calculator:2 .
    - docker push registry.gitlab.com/jjfabry/lab-calculator:1
    - docker push registry.gitlab.com/jjfabry/lab-calculator:2

test1:
  image: docker
  stage: test1
  services:
    - docker:dind
  script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker run registry.gitlab.com/jjfabry/lab-calculator:1
  only:
    - main 

test2:
  image: docker
  stage: test2
  services:
    - docker:dind
  script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker run registry.gitlab.com/jjfabry/lab-calculator:2
  except:
    - main
```
#####################################################################################

## Lab: Vytvorenie package registra --- 
SOLUTION: 
Naimportujem si projekt: https://github.com/kriru/firstJava

.gitlab-ci.yml
```
image: curlimages/curl:latest

cache:
   paths:
     - HelloWorld.class

stages:
 - compile
 - upload
 - download

compile:
   image: openjdk
   stage: compile
   script:
       - javac HelloWorld.java

upload:
 stage: upload
 script:
   - 'curl --header "JOB-TOKEN: $CI_JOB_TOKEN" --upload-file ./HelloWorld.class  "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/my_package/1.0.1/HelloWorld.class"'

download:
 image: openjdk:23-oraclelinux8
 stage: download
 script:
   - microdnf install -y wget
   - 'wget --header="JOB-TOKEN: $CI_JOB_TOKEN" ${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/my_package/1.0.1/HelloWorld.class'
   - java HelloWorld
```
############################################################################

## Lab12: API token test
Vytvor token pre nejaky projekt 
<vygenerovany_token>

Na VM pustim prikaz 
zobrazenie pipeline:
``` curl --header "PRIVATE-TOKEN:<vygenerovany_token>" "https://gitlab.com/api/v4/projects/64248593/pipelines" ```
zobrazenie konkretnej pipeline, pridam jej ID: 
``` curl --header "PRIVATE-TOKEN:<vygenerovany_token>" "https://gitlab.com/api/v4/projects/64248593/pipelines/1530969396" | jq ```

Test of Personal TOKEN:
<vygenerovany_token>
zobrazenie vsetkych projektov: 
``` curl --header "PRIVATE-TOKEN:<vygenerovany_token>" "https://gitlab.com/api/v4/projects/64291359" | jq ```

##################################################################
