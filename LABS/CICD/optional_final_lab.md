```yaml
stages:
  - create
  - build
  - deploy
  - document
  - release

image: maven

variables:
    USER: java-gitlab
    AWS_IP: 54.93.216.209
    CUSTOM_REG: $CI_REGISTRY/$CI_PROJECT_NAMESPACE/$CI_PROJECT_NAME

cache:
    - paths:
        - src
        - ./public

generate:
    stage: create
    script:
        - rm -r src || true; mkdir src
        - cd src; mvn archetype:generate -DgroupId=com.app.example -DartifactId=java-app -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false

compile:
    stage: create
    script:
        - cp pom.xml src/java-app
        - cp App.java src/java-app/src/main/java/com/app/example/App.java
        - cd src/java-app/ ; mvn package
    needs:
        - ["generate"]

docker-image:
    image: docker
    stage: build
    services:
        - docker:dind
    script:
        - docker login $CI_REGISTRY -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD
        - docker build -t $CUSTOM_REG/java-app:latest .
        - docker push $CUSTOM_REG/java-app:latest

docker-run:
    image: alpine
    stage: deploy
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
        - echo "starting docker container..."
        - ssh "$USER@$AWS_IP" "docker login $CI_REGISTRY -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD; docker container rm -f java-app; docker container run -d -p 8888:8080 --name java-app $CUSTOM_REG/java-app:latest"
    environment:
        name: production
        url: http://$AWS_IP:8888/hello-world-1/

package-register:
    image: curlimages/curl:latest
    stage: document
    script:
        - 'curl --header "JOB-TOKEN: $CI_JOB_TOKEN" --upload-file ./src/java-app/target/hello-world-1.war "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/java-app/1.0.0/hello-world-1.war"'


pages:
    image: alpine
    stage: document
    script:
        - test -d public || mkdir public
        - cp src/java-app/target/hello-world-1.war public
    artifacts:
        paths:
            - public

create-release:
    image: registry.gitlab.com/gitlab-org/release-cli:latest
    stage: release
    script:
        - echo 'create-release job $CI_COMMIT_SHORT_SHA'
    variables:
        RELEASE_VERSION: ""
    when: manual
    release:
        name: 'Release Java-App $RELEASE_VERSION $CI_COMMIT_SHORT_SHA'
        tag_name: '$CI_COMMIT_SHORT_SHA'
        description: 'java-app $RELEASE_VERSION $CI_COMMIT_SHORT_SHA'
        assets:
            links:
            - name: 'hello-world-1.war'
              url: 'https://lab-final-e65276.gitlab.io/hello-world-1.war'
```
