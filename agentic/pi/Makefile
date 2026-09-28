build:
	docker build -t pi-sandbox -f Dockerfile.pi .
run:
	docker run --rm -it \
        -e TF_FORCE_GPU_ALLOW_GROWTH \
        -v "${PWD}:/workspace" \
        -v "/nix:/nix" \
        -v "/home/bzizou/.nix-profile:/root/.nix-profile" \
        -v "${HOME}/.pi/agent:/root/.pi/agent" \
        pi-sandbox

