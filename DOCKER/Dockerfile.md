### Priklady Dockerfileov

```Dockerfile
# aky image sa pouzije
FROM  python:3.11-slim

# Meta data
LABEL maintainer="Duri"
LABEL description="Weather  app"

# ak pushujem do MTR tak tymto nastavujem expiraciu imageu
LABEL quay.expires-after='1w'

# prida lokalne alebo remote subory alebo priecinky
ADD weather.tgz /

# co sa spusti pri buildovani
RUN addgroup pythonista \
    && adduser --no-create-home --uid 1000 --gid 1000 --disabled-password --gecos pythonista pythonista

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
    curl=7.88.1-10+deb12u7 \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir --break-system-packages \
    uvicorn==0.30.6 \
    fastapi==0.115.0 \
    sqlmodel==0.0.22 \
    pydantic_settings==2.5.2 \
    apscheduler==3.10.4 \
    sqladmin==0.19.0 \
    httpx==0.27.2 \
    pendulum==3.0.0 \
    loguru==0.7.2 \
    fastapi_health==0.4.0 \
    && mkdir /data \
    && chown -R pythonista:pythonista /data

# env premmenne
ENV  WEATHER_DB_URI=sqlite:///data/db.sqlite

# na akych portoch bude pocuvat
EXPOSE 8000

# vytvori volume mount
VOLUME [ "/data" ]

# nastavi usera
USER pythonista

# skontroluje health containera pri starte
HEALTHCHECK  \
    --interval=10s  \
    --timeout=3s  \
    --start-period=5s  \
    --retries=3  \
    CMD  \
    curl -f http://localhost:8000/ || exit 1

# specifikuje default prikaz
CMD [ "python", "-m", "weather" ]
CMD [ "usr/sbin/httpd", "-D", "FOREGROUND" ]
```

###########################################################
``` Dockerfile
# aky image
FROM  nginx:alpine

# premmenna pri buildovani
ARG  AUTHOR="Juraj Fabry"
ARG  VERSION="2024.1"

# meta udaje
LABEL author=$AUTHOR
LABEL version=$VERSION
LABEL description="image  based  on  nginx  with  freelancer  homepage  template"

# nakopiruje z lokalu nieco do kontainera
COPY www/. /usr/share/nginx/html

# na akom porte pocuva
EXPOSE 80

# zmeni working directory
WORKDIR /usr/share/nginx/html

# env variables (vezme z ARG)
ENV  AUTHOR=$AUTHOR
ENV  VERSION=$VERSION

# commandy ktore sa spustia pri buildovani
RUN sed -i 's/{{  AUTHOR  }}/'"${AUTHOR}"'/g' index.html
RUN sed -i 's/{{  VERSION  }}/'"${VERSION}"'/g' index.html

# zmena listen portu na apachi
RUN sed -i 's/Listen  80/Listen  8080/g' /etc/apache2/httpd.conf
```
##########################################################
``` Dockerfile
FROM  alpine:latest

LABEL org.opencontiainers.image.authors="Juraj.Fabry"

RUN apk add apache2

# nakopiruje nieco do danej cesty
ADD src/. /var/www/localhost/htdocs

# zmeni port v danom file
RUN sed -i 's/Listen  80/Listen  8080/g' /etc/apache2/httpd.conf

EXPOSE 8080

# nastavi env variables
ENV  http_proxy='http://10.14.38.3:3128'
ENV  https_proxy='http://10.14.38.3:3128'

# command co sa spusti pri starte
CMD [ "/usr/sbin/httpd", "-D", "FOREGROUND" ]
```
##########################################################
``` Dockerfile
FROM nginx

LABEL maintainer="Juraj Fabry"

ADD src/. /usr/share/nginx/html

WORKDIR /etc/nginx/conf.d

RUN sed -i 's/listen       80;/listen       8080;/g' default.conf

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
```
########################################################
``` Dockerfile
FROM alpine:latest

LABEL org.opencontiainers.image.authors="Juraj.Fabry"

RUN apk add apache2 curl 

ADD src/. /var/www/localhost/htdocs

RUN sed -i 's/Listen 80/Listen 8080/g' /etc/apache2/httpd.conf

EXPOSE 8080

ENV http_proxy='http://10.14.38.3:3128'
ENV https_proxy='http://10.14.38.3:3128'

ENTRYPOINT [ "/usr/sbin/httpd" ]
CMD [ "-D", "FOREGROUND" ]
```
#######################################################
``` Dockerfile
FROM alpine:latest

LABEL org.opencontiainers.image.authors="Juraj.Fabry"

RUN apk add apache2 curl wget

ADD src/. /var/www/localhost/htdocs

WORKDIR /var/www/localhost/htdocs/img
RUN wget https://images.squarespace-cdn.com/content/v1/56e8fcc03c44d89db7df9b3e/1554359150041-FS043JZG6F79BEDSZIY2/11+Picture-Perfect+Views+of+the+Golden+Gate+Bridge+in+San+Francisco?format=2500w \
    && mv * bridge.jpg 

RUN sed -i 's/Listen 80/Listen 8080/g' /etc/apache2/httpd.conf

EXPOSE 8080

ENV http_proxy='http://10.14.38.3:3128'
ENV https_proxy='http://10.14.38.3:3128'

# co je v entrypointe sa spusta vzdy
ENTRYPOINT [ "/usr/sbin/httpd" ]
# co je v CMD viem upravit
CMD [ "-D", "FOREGROUND" ]
```
#######################################################
```Dockerfile
FROM nginx:latest

ADD https://github.com/startbootstrap/startbootstrap-freelancer/archive/gh-pages.zip /tmp

RUN apt-get update && \
    apt-get install -y unzip

WORKDIR /tmp

RUN unzip gh-pages.zip \
    && cp -r startbootstrap-freelancer-gh-pages/. /usr/share/nginx/html \
    && rm gh-pages.zip

WORKDIR /etc/nginx/conf.d
RUN sed -i 's/listen       80;/listen       8080;/g' default.conf

WORKDIR /usr/share/nginx/html
EXPOSE 8080

CMD [ "nginx", "-g", "daemon off;" ]
```
