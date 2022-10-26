FROM ubuntu:latest
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y libldap-2.4-2 shared-mime-info xorg qt5-default
COPY zed_free-2020.4.Ubuntu14.04.amd64.deb /tmp
RUN dpkg -i /tmp/zed_free-2020.4.Ubuntu14.04.amd64.deb
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y xvfb
