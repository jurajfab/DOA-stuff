## aky image sa pouzije
FROM python:3.11-slim                   

## Meta data 
LABEL maintainer="Duri"
LABEL description="Weather app"

## prida lokalne alebo remote subory alebo priecinky 
ADD weather.tgz /

## co sa spusti pri buildovani 
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
ENV WEATHER_DB_URI=sqlite:///data/db.sqlite

# na akych portoch bude pocuvat 
EXPOSE 8000

# vytvori volume mount 
VOLUME [ "/data" ]

# nastavi usera 
USER pythonista

# skontroluje health containera pri starte 
HEALTHCHECK \
    --interval=10s \ 
    --timeout=3s \ 
    --start-period=5s \
    --retries=3 \
        CMD \
        curl -f http://localhost:8000/ || exit 1

# specifikuje default prikaz        
CMD [ "python", "-m", "weather" ]

###########################################################
# aky image 
FROM nginx:alpine 

# premmenna pri buildovani 
ARG AUTHOR="Juraj Fabry"
ARG VERSION="2024.1"

# meta udaje 
LABEL author=$AUTHOR
LABEL version=$VERSION
LABEL description="image based on nginx with freelancer homepage template"

# nakopiruje z lokalu nieco do kontainera 
COPY www/. /usr/share/nginx/html

# na akom porte pocuva 
EXPOSE 80

# zmeni working directory 
WORKDIR /usr/share/nginx/html 

# env variables (vezme z ARG)
ENV AUTHOR=$AUTHOR
ENV VERSION=$VERSION 

# commandy ktore sa spustia pri buildovani 
RUN sed -i 's/{{ AUTHOR }}/'"${AUTHOR}"'/g' index.html 
RUN sed -i 's/{{ VERSION }}/'"${VERSION}"'/g' index.html 

##########################################################

