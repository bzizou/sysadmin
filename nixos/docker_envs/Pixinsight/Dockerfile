FROM debian:latest
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y xorg libqt5gui5 libraw-bin libglx-mesa0 libnss3 libasound2
COPY PixInsight /tmp/PixInsight
COPY installer /tmp
WORKDIR /tmp
