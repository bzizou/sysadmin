build:
	docker build -t pixinsight .
	echo "Now do 'docker run -it pixinsight bash'"
	echo "and 'cd /tmp && ./installer -y'"
	echo "Then commit the container."

run:
	xhost local:root
	docker run -it -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
		                  -v ${HOME}:${HOME} \
				  -v /dev/dri:/dev/dri \
				  -v /etc/passwd:/etc/passwd:ro \
	                          -v /etc/group:/etc/group:ro \
				  --user="$(shell id --user):$(shell id --group)" pixinsight /opt/PixInsight/bin/PixInsight.sh
