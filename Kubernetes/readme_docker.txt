DOCKER REGISTRY --------------------------------------------
docker container stop registry && docker container rm -v registry
openssl req -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key -x509 -days 365 -out certs/domain.crt
docker run --entrypoint htpasswd registry:2 -Bbn user password > auth/htpasswd
copy /etc/docker/certs.d/docker-registry:5000/ca.crt
scp -r /etc/docker/certs.d/ root@k8s-worker-1:/etc/docker/

---for auth by cert
docker run -d --restart=always --name registry -v "$(pwd)"/certs:/certs -e REGISTRY_HTTP_ADDR=0.0.0.0:443 -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key -p 443:443 registry:2
---for auth by cert and login
docker run -d -p 5000:5000 --restart=always --name registry -v "$(pwd)"/auth:/auth -e "REGISTRY_AUTH=htpasswd" -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd -v "$(pwd)"/certs:/certs -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key registry:2

docker build . -t time-service
docker tag time-service:latest docker-registry:5000/time-service:latest
docker push docker-registry:5000/time-service:latest
docker pull docker-registry:5000/time-service:latest
docker login docker-registry:5000
curl -k https://user:password@docker-registry:5000/v2/_catalog
curl -k https://user:password@docker-registry:5000/v2/time-service/tags/list

scp -r certs.d/ lk@k8s-worker-1:/home/lk/
cp certs.d/* /etc/docker/certs.d/

docker image prune
docker exec -it time-service /bin/bash
