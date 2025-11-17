build:
	docker build -t bambustudio .

run:
	xhost local:root
	export GDK_SYNCHRONIZE=1
	docker run -it -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
		                  -v ${HOME}:${HOME} \
				  -v /data:/data \
				  -v /dev/dri:/dev/dri \
				  -v /etc/passwd:/etc/passwd:ro \
	                          -v /etc/group:/etc/group:ro \
                                  --device /dev/fuse \
                                  --cap-add SYS_ADMIN \
                                  --security-opt apparmor:unconfined \
                                  --ipc=host -e DISPLAY \
				  --user="$(shell id --user):$(shell id --group)" bambustudio /usr/local/bin/bambu-studio
shell:
	xhost local:root
	docker run -it -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
		                  -v ${HOME}:${HOME} \
				  -v /data:/data \
				  -v /dev/dri:/dev/dri \
				  -v /etc/passwd:/etc/passwd:ro \
	                          -v /etc/group:/etc/group:ro \
                                  --device /dev/fuse \
                                  --cap-add SYS_ADMIN \
                                  --security-opt apparmor:unconfined \
                                  --ipc=host -e DISPLAY \
				  --user="$(shell id --user):$(shell id --group)" bambustudio bash

rootshell:
	xhost local:root
	docker run -it -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
		                  -v ${HOME}:${HOME} \
				  -v /data:/data \
				  -v /dev/dri:/dev/dri \
				  -v /etc/passwd:/etc/passwd:ro \
	                          -v /etc/group:/etc/group:ro \
                                  --device /dev/fuse \
                                  --cap-add SYS_ADMIN \
                                  --security-opt apparmor:unconfined \
                                  --ipc=host -e DISPLAY \
				  --user=root bambustudio bash


