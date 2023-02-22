build:
	docker build -t app .
run:
	xhost local:root
	docker run -it -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
		                  -v ${HOME}:${HOME} \
				  -v /dev/dri:/dev/dri \
				  -v /etc/passwd:/etc/passwd:ro \
	                          -v /etc/group:/etc/group:ro \
				  --user="$(shell id --user):$(shell id --group)" app AstroPixelProcessor

shell:
	xhost local:root
	docker run -it -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
		                  -v ${HOME}:${HOME} \
				  -v /dev/dri:/dev/dri \
				  -v /etc/passwd:/etc/passwd:ro \
	                          -v /etc/group:/etc/group:ro \
				  --user="$(shell id --user):$(shell id --group)" app bash

starnet:
	xhost local:root
	@echo "***************************************"
	@echo "To use starnet:" 
	@echo "  cd ~/BMSO/StarNetv2CLI_linux"
	@echo "  ./starnet++"
	@echo "***************************************"
	docker run -it -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
		                  -v ${HOME}:${HOME} \
				  -v /dev/dri:/dev/dri \
				  -v /etc/passwd:/etc/passwd:ro \
	                          -v /etc/group:/etc/group:ro \
				  --user="$(shell id --user):$(shell id --group)" app bash


