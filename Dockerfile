
FROM alpine:latest

RUN apk add --no-cache bash file iptables libc6-compat libgcc libstdc++ wget

RUN mkdir -p /lib64 && \
    ln -s /lib/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2

RUN mkdir -p /root/f5fpc && \
    cd /root/f5fpc && \
    wget --no-check-certificate https://72.3.241.247/public/download/linux_sslvpn.tgz && \
    tar xfz linux_sslvpn.tgz && \
    yes "yes" | ./Install.sh && \
    rm -rf /root/f5fpc

COPY ./files/connect.sh /root/connect.sh

CMD /root/connect.sh

