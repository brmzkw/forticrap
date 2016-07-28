all:
	docker build -t forticrap .
	docker run --privileged -v /etc/forticrap.conf:/etc/forticrap.conf:ro --rm -t forticrap

dl:
	# https://hadler.me/linux/forticlient-sslvpn-deb-packages/
	wget https://hadler.me/files/forticlient-sslvpn_4.4.2329-1_amd64.deb -O forticlient-sslvpn_amd64.deb
