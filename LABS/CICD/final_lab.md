
Cielom ulohy je vytvorenie pipeline, ktora skompiluje Java aplikaciu beziacu pod Tomcat serverom. Vyslednu aplikaciu skopiruje do Docker image. A vysledny docker image spustite na vzdialenom AWS systeme.

1. Vytvorenie projektu
2. Do projektu pridajte konfiguracny subor pom.xml
```xml
<?xml version = "1.0" encoding = "UTF-8"?>
<project xmlns = "http://maven.apache.org/POM/4.0.0"
   xmlns:xsi = "http://www.w3.org/2001/XMLSchema-instance"

xsi:schemaLocation = "http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
<modelVersion>4.0.0</modelVersion>

   <groupId>com.tutorialspoint</groupId>
   <artifactId>hello-world</artifactId>
   <version>1</version>
   <packaging>war</packaging>
   
   <parent>
  	<groupId>org.springframework.boot</groupId>
  	<artifactId>spring-boot-starter-parent</artifactId>
  	<version>2.3.0.RELEASE</version>
  	<relativePath/>
   </parent>

   <properties>
  	<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
  	<project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
  	<java.version>1.8</java.version>
  	<tomcat.version>9.0.37</tomcat.version>
   </properties>

   <dependencies>
  	<dependency>
     	<groupId>org.springframework.boot</groupId>
     	<artifactId>spring-boot-starter-web</artifactId>
  	</dependency>
  	<dependency>  
     	<groupId>org.springframework.boot</groupId>  
     <artifactId>spring-boot-starter-tomcat</artifactId>  
     <scope>provided</scope>  
  	</dependency>   
  	<dependency>
     	<groupId>org.springframework.boot</groupId>
     	<artifactId>spring-boot-starter-test</artifactId>
     	<scope>test</scope>
  	</dependency>
   </dependencies>

   <build>
  	<plugins>
     	<plugin>
        	<groupId>org.springframework.boot</groupId>
        	<artifactId>spring-boot-maven-plugin</artifactId>
     	</plugin>
  	</plugins>
   </build>
   
</project>
``` 

3. Pridajte do projektu App.java
```java
package com.app.example;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class App extends SpringBootServletInitializer {
   @Override
   protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
  	return application.sources(App.class);
   }
   public static void main(String[] args) {
  	SpringApplication.run(App.class, args);
   }

   @RequestMapping(value = "/")
   public String hello() {
  	return "<center>Hello World Aahhh Mantaapp</center>";
   }
}
```

4. Pridajte do projektu Dockerfile
```Dockerfile
FROM tomcat:9
ADD src/java-app/target/hello-world-1.war /usr/local/tomcat/webapps/
EXPOSE 8080
CMD ["catalina.sh", "run"]
```

5. Vytvorte pipeline config kde
a. Vytvorte job “generate”, ktory vytvori kostru java aplikacie pomocou nastroja maven; stage S1
```        
rm -r src || true;  mkdir src
cd src; mvn archetype:generate -DgroupId=com.app.example -DartifactId=java-app -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
```
Vysledok je adresarova struktura
b. Pouzite globalnu cache na prenos adresara src do dalsich jobov.

6. V pipeline vytvorte vyslednu aplikaciu pre aplikacny server pomocou maven, v pipeline job “compile”, stage S2

```
cp pom.xml src/java-app
cp App.java src/java-app/src/main/java/com/app/example/App.java
cd src//java-app/ ; mvn package
```

7. Do pipeline pridajte vytvorenie kontajnera z Dockerfile - job docker_image, stage S3
8. Otestujte spustenie vysledneho docker image na AWS
```
docker login registry.gitlab.com…
docker run -d -p  80:8080 CONTAINER_IMAGE_URL
firefox aws_ip/hello-world-1/
```

9. Do pipeline pridajte job “deploy” na automaticke spustenie/nasadenie image na AWS systeme pomocou ssh. Stage S4. Len pripade ak sa jedna o hlavnu vetvu projektu main.
10. Pridajte do jobu deploy, environments s oznacenim url nasadenia aplikacie.
11. Vyzdielajte vyslednu aplikaciu hello-world-1.war pomocou pages.
12. Ak vsetko funguje oznacte cely projekt - release ako verzia 1.0 aplikacie. Pridajte do URL aplikacie odkaz na vyzdielanu aplikaciu cez pages.
13. Z vyslednej aplikacie ( hello-world-1.war) spravte artefakt, plus ulozte aplikaciu do Generic package repozitara.
14. Vytvorte webhook vzhladom na pushsaver ak prebehne v projekte operacia nad pipeline.

SOLUTION:
.gitlab-ci.yml
```yaml
stages:
  - S1
  - S2
  - S3
  - S4
  - S5

image: maven

variables:
    USER: java-gitlab
    AWS_IP: 54.93.216.209

cache:
    - paths:
        - "src"
        - "../public"

generate:
    stage: S1
    script:
        - rm -r src || true; mkdir src
        - cd src; mvn archetype:generate -DgroupId=com.app.example -DartifactId=java-app -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false

compile:
    stage: S2
    script:
        - cp pom.xml src/java-app
        - cp App.java src/java-app/src/main/java/com/app/example/App.java
        - cd src/java-app/ ; mvn package

docker_image:
    image: docker
    stage: S3
    services:
        - docker:dind
    script:
        - docker login $CI_REGISTRY -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD   
        - docker build -t registry.gitlab.com/jjfabry/lab-final/java-app:latest .
        - docker push registry.gitlab.com/jjfabry/lab-final/java-app:latest

deploy:
    image: alpine
    stage: S4
    only: 
        - main
    script:
        - apk update ; apk add openssh-client
        - eval $(ssh-agent -s)
        - echo "connecting to AWS machine..."
        - echo "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add - > /dev/null
        - mkdir -p ~/.ssh
        - chmod 700 ~/.ssh
        - ssh-keyscan $AWS_IP >> ~/.ssh/known_hosts
        - chmod 644 ~/.ssh/known_hosts
        - ssh "$USER@$AWS_IP" "docker login $CI_REGISTRY -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD; docker container rm -f java-app; docker container run -d -p 8888:8080 --name java-app registry.gitlab.com/jjfabry/lab-final/java-app:latest"
    environment:
        name: prod
        url: http://$AWS_IP:8888/hello-world-1/

package-register:
    image: curlimages/curl:latest
    stage: S4
    script:
        - 'curl --header "JOB-TOKEN: $CI_JOB_TOKEN" --upload-file ./src/java-app/target/hello-world-1.war "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/java-app/1.0.0/hello-world-1.war"'


pages:
    image: alpine
    stage: S4
    script:
        - test -d public || mkdir public
        - cp src/java-app/target/hello-world-1.war public
    artifacts:
        paths:
            - public

create-release:
    image: registry.gitlab.com/gitlab-org/release-cli:latest
    stage: S5
    script:
        - echo 'iOS release job $CI_COMMIT_SHORT_SHA'
    when: manual
    release:
        name: 'Release Java-App $CI_COMMIT_SHORT_SHA'
        tag_name: '$CI_COMMIT_SHORT_SHA'
        description: 'java-app v1.0.0 $CI_COMMIT_SHORT_SHA'
        assets:
            links:
            - name: 'hello-world-1.war'
              url: 'https://lab-final-e65276.gitlab.io/hello-world-1.war'

```

Na VM je potrebne vyrobit usera a kluce pre neho, pridat ho do skupiny docker.
User: java-gitlab Password: heslo 

Na AWS treba cez security povolit IPcky a Porty 
