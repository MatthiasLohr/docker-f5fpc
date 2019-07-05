FROM alpine:3.10@sha256:ca1c944a4f8486a153024d9965aafbe24f5723c1d5c02f4964c045a16d19dc54

LABEL maintainer="Matthias Lohr <mail@mlohr.com>"
LABEL architecture="amd64"

ENV F5FPC_SHA="49b7f4d470f75142271c3c52e168e800c9957db033ef99c37aee293d479b60f3"

RUN apk add --no-cache bash ca-certificates file iptables libc6-compat libgcc libstdc++ wget && \
    update-ca-certificates

RUN mkdir -p /tmp/f5fpc && \
    cd /tmp/f5fpc && \
    wget -q https://vpn.mtu.edu/public/download/linux_sslvpn.tgz && \
    echo "${F5FPC_SHA}  linux_sslvpn.tgz" | sha256sum -c - && \
    tar xfz linux_sslvpn.tgz && \
    yes "yes" | ./Install.sh && \
    rm -rf /tmp/f5fpc

ADD ./files/opt/* /opt/

CMD ["/opt/idle.sh"]
