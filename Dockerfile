
FROM alpine:3.8

LABEL maintainer="Matthias Lohr <mail@mlohr.com>"
LABEL architecture="amd64"

RUN apk add --no-cache bash ca-certificates file iptables libc6-compat libgcc libstdc++ wget && \
	update-ca-certificates

RUN mkdir -p /tmp/f5fpc && \
    cd /tmp/f5fpc && \
    wget https://vpn.mtu.edu/public/download/linux_sslvpn.tgz && \
    tar xfz linux_sslvpn.tgz && \
    yes "yes" | ./Install.sh && \
    rm -rf /tmp/f5fpc

ADD ./files/opt/* /opt/

CMD ["/opt/idle.sh"]

