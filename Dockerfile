
FROM alpine:latest

RUN apk add --no-cache bash file iproute2 \
    iptables iputils libc6-compat libgcc \
    libstdc++ net-tools wget make gcc g++

WORKDIR /root/

RUN mkdir -p /root/f5fpc && cd /root/f5fpc \
    && wget --no-check-certificate https://72.3.241.247/public/download/linux_sslvpn.tgz \
    && tar xfz linux_sslvpn.tgz \
    && yes "yes" | ./Install.sh \
    && rm -rf /root/f5fpc

COPY ./files/connect.sh /root/connect.sh

CMD /root/connect.sh
