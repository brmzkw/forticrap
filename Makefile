all: ~/.forticrap
	docker build -t forticrap .
	docker network create --subnet=172.20.0.0/16 forticrap || echo "Docker network forticrap already exists"
	docker run --privileged --net forticrap --ip 172.20.0.2 --name forticrap --rm -ti -v ~/.forticrap:/etc/forticrap:ro forticrap

config:
	test -f ~/.forticrap && echo "~/.forticrap already exists. Abort." >&2 || cp config_template ~/.forticrap

dl:
	# https://hadler.me/linux/forticlient-sslvpn-deb-packages/
	wget https://hadler.me/files/forticlient-sslvpn_4.4.2329-1_amd64.deb -O forticlient-sslvpn_amd64.deb
