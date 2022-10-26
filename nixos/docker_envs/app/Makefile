build:
	docker build -t app .
run:
	xhost local:root
	docker run -it -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
		                  -v ${HOME}:${HOME} \
				  -v /dev/dri:/dev/dri \
				  -v /etc/passwd:/etc/passwd:ro \
	                          -v /etc/group:/etc/group:ro \
				  --user="$(shell id --user):$(shell id --group)" app astropixelprocessor
