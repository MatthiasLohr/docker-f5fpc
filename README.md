
# F5 VPN client

*inspired by from https://github.com/brk3/docker-f5fpc*

## Run from Dockerhub

```
docker run \
    --env USER=<username> \
    --env PASSWORD=<password> \
    --env HOST=<host> \
    --name f5fpc \
    -d \
    --privileged \
    --net=host \
    matthiaslohr/f5fpc
```

