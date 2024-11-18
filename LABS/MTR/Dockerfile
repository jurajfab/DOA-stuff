FROM    dockerhub.devops.telekom.de/python:3.12-slim
LABEL   quay.expires-after='1w'
WORKDIR /app
COPY    . .
RUN     pip install -r requirements.txt
EXPOSE  8080
CMD     [ "python", "/app/src/main.py" ]