``` kubectl version                                     # ukaze verziu
kubectl cluster-info                                # zobrazi na akej adrese bezi K8s master 
kubectl config view                                 # ukaze konfiguraciu K8s 
kubectl explain pod                                 # vypise info o KINDe 


kubectl run weather --image bletvaska/weather       # spusti container v pode 
kubectl get pods                                    # vypise pody 
kubectl get all                                     # vrati info o vsetkom
kubectl get all --all-namespaces                    # vrati info o vsetkom vo vsetkych namespaceoch
kubectl get pods --output wide --show-labels   
kubectl get all --output wide --show-labels
kubectl get all --show-labels                               # zobrazi vsetko s labels 
kubectl get pods --selector app=weather --show-labels       # vrati pody ktore maju selector app=weather
kubectl get pods --selector app=rambo,country=sk
kubectl get rs --show-labels
kubectl get pods --watch                            # interaktivne sleduje pody 

kubectl logs pods/<pod_name>                # zobrazi logy podu 
kubectl logs pods/weather   
kubectl logs pods/weather --follow --tail 1

kubectl delete pods <pod_name>              # zmaze pod 
kubectl delete pods weather                     
kubectl delete pods --all                   # zmaze vsetky pody
``` 
### DESCRIBE 
``` 
kubectl describe pods/weather               # rozsirene info o pode, ake containeri tam bezia a pod.
kubectl describe service minio              # rozsireny vypis o service 
```
#### RUN COMMAND INSIDE POD  
```
kubectl exec pods/weather -- hostname       # spusti prikaz v containeri 
kubectl exec -it pods/weather -- bash       # spusti bash v containeri ktory viem pouzivat 
kubectl exec pods/weather-58496f7b88-5gnrt -- env
```

### PORT FORWARD 
```
kubectl port-forward pods/weather 8080:8000                     # forwardnem porty 
kubectl port-forward --address 0.0.0.0 pods/weather 8080:8000   # forwardnem porty ake chcem a cez --address umoznim pripojit sa z vonku z hociakej IP
```

### DEPLOYMENT
``` 
kubectl create deployment weather --image bletvaska/weather                   # vytvori deployment 
kubectl create deployment weather --image bletvaska/weather --replicas 5      # vytvori deployment s 5 replikami 
kubectl get <pods, replicas...> --watch                                       # sleduje zmeny v podoch, replikach ...
kubectl delete deployment.apps <name>                                         # zmaze deployment 
kubectl logs deployments/weather                                              # ukaze logy aplikacie co bezia v containeri 
```

### SCALE
```
kubectl scale deployment weather --replicas 2                           # zvysi pocet replicat na 2 
kubectl scale deployment weather --replicas 0                           # zrusim vsetky pody (nieco ako restart)
kubectl autoscale deployment wp --min 2 --max 5 --cpu-percent 50        # autoscale max a min pocet podov 
```

### SERVICES
Je metoda pre spristupnenie aplikacie na sieti ktora bezi v pode, selector vie vybrat podla nazvu ktore pody bude ovladat. 

```
kubectl expose deployment weather --port 8000           # exposne deployment na nejakom porte 
kubectl get service                                     # vypise info o service 
kubectl describe service weather
kubectl port-forward service/weather 8000:8000                      # service/weather bude nieco ako loadbalancer, adresa z ktorej pristupujem len localhost 
kubectl port-forward --address 0.0.0.0 service/weather 8000:8000    # adresa z ktorej pristupujem moze byt hociaka 
```
Ak chcem pristupovat na service z vonku na port 7500 ale apka bezi na 8800 tak v prikaze expose musim specifikovat aj Target Port 
``` kubectl expose deployment rambo --port 7500 --target-port 8800 ```

**target-port** je port na ktorom bezi apka defaultne (napr. NGINX 80, MARIADB 3306)
Ak chcem zmenit port na service z vonku ale z vnutra je iny port tak to urobim nasledovne:
```
kubectl expose deployment rambo --port 9000 --target-port 8000      # specifikujem target port (na ktorom ide apka)
kubectl port-forward --address 0.0.0.0 service/rambo 9000:9000

kubectl expose deployment rambo --port 8080 --target-port 8000 --name rambo-cl
kubectl port-forward --address 0.0.0.0 services/rambo-cl 8080:8000
```

### LABELS
```
kubectl get all --show-labels                                        # zobrazi labels pre vsetko 
kubectl label pods weather org=shmu                                  # prida novy label pre pod 
kubectl delete deployments,services --selector environment=dev       # vymaze na zaklade zadaneho selectora 
kubectl apply -f manifest.yaml --selector env=prod,customer=custA    # aplikuje zmeny v manifeste len pre veci ktore vyhovuju selectoru 
```

### ROLLING UPDATE
Podla mena viem identifikovat containery, tento prikaz updatuje z ktoreho imagu sa maju urobit containeri uz na beziacich podoch 
``` kubectl set image deployments rambo rambo=bletvaska/rambo:2 ```
nabehnu nove pody s novy imageom a aj replicaset a tie so starym imageom sa zmazu

### NAMESPACES
```
kubectl get namespaces 
kubectl create namespace rambo 
kubectl create deployment rambo --image beltvaska/rambo:2 --replicas 3 --namespace rambo
kubectl get all --namespace rambo
kubectl delete namespaces rambo                                 # zmaze namespace (ak tam su veci a nieco bezi aj tak to zmaze)
kubectl get all --all-namespaces                                # vypise vsetko zo vsetkych namespaces 
kubectl config set-context --current --namespace rambo          # prepne do ineho namespacu 
alias kubens='kubectl config set-context --current --namespace' 
kubectl config get-contexts

code ~/.kube/config            # config file pre kubernetes 
context: 

k config get-contexts
```

## Lab: MariadDB + Adminer by Imperative Commands ###
### create mariadb 
```
kubectl create deployment db --image mariadb
kubectl set env deployment.apps/db MARIADB_ROOT_PASSWORD=secret

kubectl expose deployment db --type ClusterIP --port 3306 --name mariadb
```

### create adminer 
```
kubectl create deployment adminer --image adminer --replicas 3
```

### adminer service as ClusterIP 
```
kubectl expose deployment adminer --type ClusterIP --port 8000 --target-port 8080 --name adminer-cl
kubectl port-forward --address 0.0.0.0 service/adminer-cl 8000:8000
http head http://$HOSTIP:8000
```

### adminer serivce as NodePort 
```
kubectl expose deployment adminer --type NodePort --port 8080 --name adminer-np
http head http://$HOSTIP:30643
```

### adminer service as LoadBalancer
```
kubectl expose deployment adminer --type LoadBalancer --name adminer-lb --port 8080
http head http://$HOSTIP:8080
```
```
nmap localhost

kubectl run nginx \
    --image nginx \
    --labels app=nginx \
    --port 80 \ 
    --name nginx \ 
    --dryrun

kubectl api-resources           # zobrazi zoznam kubernetes objektov (kindy)
kubectl api-versions            # zoznam verzii 

NAME                                SHORTNAMES   APIVERSION                        NAMESPACED   KIND
bindings                                         v1                                true         Binding
componentstatuses                   cs           v1                                false        ComponentStatus
configmaps                          cm           v1                                true         ConfigMap
endpoints                           ep           v1                                true         Endpoints
```
```
kubectl apply --filename pod.yaml      # nacita manifest 
```
```
k create namespace the-project --dry-run=client --output yaml
```
```
kubectl create deployment db --image mariadb --dry-run=client --output yaml
kubectl set env deployment.apps/db MARIADB_ROOT_PASSWORD=secret --dry-run=client --output yaml
```
```
kubectl create deployment adminer --image adminer --replicas 3 --dry-run=client --output yaml
kubectl expose deployment adminer --type ClusterIP --port 8000 --target-port 8080 --name adminer-cl --dry-run=client output yaml
kubectl expose deployment adminer --type ClusterIP --port 8000 --target-port 8080 --name adminer-cl --dry-run=client --output yaml
kubectl expose deployment adminer --type NodePort --port 8080 --name adminer-np --dry-run=client --output yaml
 k apply -f the-project/
 k delete the-project/
 k delete --filename the-project/
```
 wrk = na testovanie vytazenia 
 k autoscale deployment wp --min 2 --max 5 --cpu-percent 50

### Rolling update
```
kubectl set image deployments rambo-po rambo=bletvaska/rambo:3                  # aktualizuje image pre zadany deployment 
kubectl set image deployments rambo=bletvaska/rambo:2 --all                     # aktualizuje image pre vsetky deploymenty s nazvom rambo
kubectl set image deployments rambo=bletvaska/rambo:3 --selector city=po        # na zaklade selectora updateuje image 
```

### Config maps
```
kubectl create configmap        # vytvori config mapu 

kubectl create configmap weather \
  --from-literal=WEATHER_UPDATE_INTERVAL=30 \
  --from-literal=WEATHER_UNITS=standard \
  --from-literal=WEATHER_QUERY=poprad,sk

kubectl get configmaps                                  # zoznam config map 
kubectl describe configmaps weather                     # zobrazi config mapu 
kubectl delete configmaps weather                       # zmaze config mapu 
kubectl create configmap weather --from-env-file .env   # vytvori configmapu z env fileu
```

## LABAK Running minIO with configmap 
```
kubectl create namespace minio 
kubectl create configmap minio-conf --from-env-file .env
kubectl apply -f manifest.yaml 
```

### Secrets
```
kubectl create secret generic my-secret --from-literal=key1=supersecret --from-literal=key2=topsecret
kubectl create secret generic my-secret --from-env-file=path/to/foo.env --from-env-file=path/to/bar.env
kubectl create secret generic weather --from-literal WEATHER_TOKEN=6140e74f1f31235b3116e56f00d9a7b6
kubectl get secret
kubectl describe secrets weather
kubectl delete secret weather
kubectl create secret generic weather --from-env-file secret.env
```

AKO ZAHASHOVAT text 
``` echo -n "text" | base64 ```

### INGRESS
```
kubectl create ingress <ingress_name> --rule /=<service_name>:<port>
kubectl create ingress weather --rule /=weather:8000
kubectl create ingress weather --rule /*=weather:8000
kubectl create ingress weather --rule /*=weather:8000 --namespace the-project
``` 
### Host based rule 
```
kubectl create ingress weather --rule www.weather.sk/*=weather:8000 --namespace the-project 
```

https://k9scli.io/
k9s - kubernetes klient 
:     - otvori cmd line 

## VOLUMES
```
kubectl get pv 
kubectl describe pv 
kubectl get pvc 
```

### EMPTY DIR
``` yml
containers:
  - image: nginx
    name: nginx
    volumeMounts:
    - name: storage
      mountPath: /usr/share/nginx/html
  volumes:
    - name: storage
      emptyDir: {}
```
-------------------------
### HOST PATH
``` yaml
containers:
  - image: nginx
    name: nginx
    volumeMounts:
    - name: storage
      mountPath: /usr/share/nginx/html
  volumes:
    - name: storage
      hostPath:
        path: /tmp/www              # na hostovskom stroji 
        type: DirectoryOrCreate
```
---------------------------
### PERSISTENT VOLUME
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: 400m
spec:
  capacity:
    storage: 500Mi
  accessModes:
  - ReadWriteOnce
  hostPath:
    path: "/mnt/500m"
    type: DirectoryOrCreate
```
----------------------------
### PERSISTENT VOLUME CLAIM
``` yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: wp-data
spec:
  storageClassName: ""
  resources:
    requests:
      storage: 460Mi
  accessModes:
  - ReadWriteOnce
 ```
---------------------------
### USE OF PVC
``` yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: wp
    tier: frontend
    env: prod
    customer: tuke
  name: wp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: wp
  template:
    metadata:
      labels:
        app: wp
        tier: frontend
        env: prod
        customer: tuke
    spec:
      containers:
      - image: wordpress
        name: wordpress
        envFrom:
        - configMapRef:
            name: config-wp
        - secretRef:
            name: secrets-wp
        volumeMounts:
        - name: data
          mountPath: /var/www/html
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: wp-data    # nazov musi byt rovnaky ako vytvoreny PV 
```
-------------------------------
