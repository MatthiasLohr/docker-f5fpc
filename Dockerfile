
FROM ubuntu:latest

RUN apt-get update && apt-get install -y iptables vim wget && apt-get clean
RUN mkdir -p /root/f5fpc && cd /root/f5fpc && wget --no-check-certificate https://72.3.241.247/public/download/linux_sslvpn.tgz && tar xfz linux_sslvpn.tgz && yes "yes" | ./Install.sh && rm -rf /root/f5fpc

COPY ./connect.sh /root/connect.sh

CMD /root/connect.sh
