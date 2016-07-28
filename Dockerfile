FROM ubuntu:16.04

RUN apt-get update

RUN apt-get install -y ipppd iproute

WORKDIR /root

ADD forticlient-sslvpn_amd64.deb /root

RUN dpkg -i /root/forticlient-sslvpn_amd64.deb || echo "Was expected to fail, as dependencies are not yet installed" >&2
RUN apt-get -f install -y

RUN apt-get update
RUN apt-get install -y expect
RUN apt-get install -y iptables

ADD run.sh /

CMD /run.sh
