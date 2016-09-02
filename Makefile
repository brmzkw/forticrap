FORTICRAP_SUBNET=172.20.0.0/16
FORTICRAP_IP=172.20.0.2

FORTIGATE_PACKAGE=https://hadler.me/files/forticlient-sslvpn_4.4.2329-1_amd64.deb


all: ~/.forticrap
	docker build -t forticrap .
	docker network create --subnet=${FORTICRAP_SUBNET} forticrap || true
	docker rm forticrap || true
	docker run                             \
	  --privileged                         \
	  --net forticrap --ip ${FORTICRAP_IP} \
	  --name forticrap                     \
	  --rm -ti                             \
	  -v ~/.forticrap:/etc/forticrap:ro    \
	  forticrap

config:
	test -f ~/.forticrap && echo "~/.forticrap already exists. Abort." >&2 || cp config_template ~/.forticrap

dl:
	# https://hadler.me/linux/forticlient-sslvpn-deb-packages/
	wget ${FORTIGATE_PACKAGE} -O forticlient-sslvpn_amd64.deb


osx-routes: IPTABLES_POSTROUTING = $(shell \
	docker-machine ssh default sudo /usr/local/sbin/iptables -L -t nat \
		| grep MASQUERADE.*all.*anywhere.*anywhere)
osx-routes: DOCKER_MACHINE = $(shell docker-machine ip)
osx-routes:
	@if [ "${SUBNETS}" = "" ]; then \
		echo "SUBNETS not defined. Re-run with make osx-routes "   \
		     "SUBNETS=<subnets> where subnet is a coma separated " \
		     "list of subnets." | xargs >&2; \
		exit 1 \
	; fi

	# Add OSX routes to docker-machine then add docker-machine routes to the container.
	@for subnet in $$(echo ${SUBNETS} | tr ',' ' '); do                 \
		sudo route -n delete -net $$subnet 2>/dev/null;             \
		sudo route -n add -net $$subnet ${DOCKER_MACHINE};          \
		                                                            \
		docker-machine ssh default sudo                             \
		  ip route delete $$subnet via ${FORTICRAP_IP} 2>/dev/null; \
		docker-machine ssh default sudo                             \
		  ip route add $$subnet via ${FORTICRAP_IP};                \
	done

	# Enable routing.
	@if [ "${IPTABLES_POSTROUTING}" = "" ]; then                            \
		docker-machine ssh default sudo                                 \
		  /usr/local/sbin/iptables -t nat -A POSTROUTING -j MASQUERADE; \
	fi

	@exit 0
