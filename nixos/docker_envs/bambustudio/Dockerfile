FROM ubuntu:latest
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y xorg libqt5gui5 libraw-bin libglx-mesa0 libnss3 libopengl0 fuse libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio libwebkit2gtk-4.1-0 dbus-x11 locales
COPY bambu-studio /usr/local/bin/
RUN sed -i '/en_GB.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG=en_GB.UTF-8  
ENV LANGUAGE=en_GB:en  
ENV LC_ALL=en_GB.UTF-8     
WORKDIR /tmp
