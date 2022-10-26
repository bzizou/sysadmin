FROM debian:latest
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y xorg libqt5gui5 libraw-bin
COPY astropixelprocessor_2.0.0-beta6.deb /tmp
RUN dpkg -i /tmp/astropixelprocessor_2.0.0-beta6.deb
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y libglx-mesa0
