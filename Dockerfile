
FROM ubuntu:16.04

LABEL maintainer="Matthias Lohr <matthias@lohr.me>"

RUN apt-get update
RUN apt-get install -y ca-certificates file iptables wget

#RUN mkdir -p /lib64 && \
#    ln -s /lib/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2

RUN mkdir -p /tmp/f5fpc && \
    cd /tmp/f5fpc && \
    wget https://vpn.mtu.edu/public/download/linux_sslvpn.tgz && \
    tar xfz linux_sslvpn.tgz && \
    yes "yes" | ./Install.sh && \
    rm -rf /tmp/f5fpc

ADD ./files/opt/* /opt/
ADD vpn.sh /vpn.sh
CMD /opt/run.sh

RUN apt-get update
RUN apt-get install -y openssh-client \
	gedit
