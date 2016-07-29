FROM ubuntu:16.04

RUN apt-get update && apt-get install -y \
    ipppd \
    iproute \
    iptables \
    expect

WORKDIR /root

ADD forticlient-sslvpn_amd64.deb /root

RUN dpkg -i /root/forticlient-sslvpn_amd64.deb || echo "Was expected to fail, as dependencies are not yet installed" >&2
RUN apt-get -f install -y

ADD run.sh /

CMD /run.sh
