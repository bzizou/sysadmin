build:
	docker build -t app .
run:
	xhost local:root
	docker run -it -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v ${HOME}:${HOME} --user="$(id --user):$(id --group)" app app
