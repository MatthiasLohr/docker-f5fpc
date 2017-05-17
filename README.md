
# F5 VPN client

*inspired by https://github.com/brk3/docker-f5fpc*

## General setup

* Install Docker. **Important:** Do **not** use the packages provided by your
  distribution packages sources.
  Use the officical resources from docker: https://docs.docker.com/engine/installation/.

## Run as router

```
sudo ./f5fpc-client.py
```

## Run image in standalone mode from Dockerhub

```
docker run \
    --privileged \
    --name f5fpc \
    matthiaslohr/f5fpc
```


### Useful commands

* Show VPN status
```
docker exec f5fpc f5fpc -i
```

* Show VPN resolv.conf
```
docker exec f5fpc cat /etc/resolv.conf.fp-tmp
```
