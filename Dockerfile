
FROM alpine:3.5

RUN apk add --no-cache bash file iptables libc6-compat libgcc libstdc++ wget

RUN mkdir -p /lib64 && \
    ln -s /lib/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2

ADD ./files/* /root/

CMD /root/run.sh
