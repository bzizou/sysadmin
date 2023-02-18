FROM debian:latest
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y xorg libqt5gui5 libraw-bin
COPY AstroPixelProcessor-2.0.0-beta13-Linux-DEB-64-bit.deb /tmp
RUN dpkg -i /tmp/AstroPixelProcessor-2.0.0-beta13-Linux-DEB-64-bit.deb
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y libglx-mesa0
