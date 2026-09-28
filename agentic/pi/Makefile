build:
	docker build -t pi-sandbox -f Dockerfile.pi .
run:
	docker run --rm -it \
        -e TF_FORCE_GPU_ALLOW_GROWTH \
        -v "${PWD}:/workspace" \
        -v "${HOME}/.pi/agent:/root/.pi/agent" \
        pi-sandbox

