#### Use latest Ubuntu docker pull osgeo/gdal:ubuntu-small-latest
FROM osgeo/gdal:ubuntu-small-latest

# Ensure locales configured correctly
RUN apt-get clean && apt-get update && apt-get install -y locales
RUN locale-gen en_US.UTF-8
ENV LC_ALL='en_US.utf8'
ENV TZ='Asia/Bangkok' \
    DEBIAN_FRONTEND=noninteractive

RUN echo $TZ > /etc/timezone && \
    apt-get update && apt-get install -y tzdata && \
    rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean

RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install python3-pip python3-dev libcairo2-dev nano -y

# download snap installer version 9.0.0
RUN apt-get install wget
RUN wget https://download.esa.int/step/snap/9.0/installers/esa-snap_sentinel_unix_9_0_0.sh

#change file execution rights for snap installer
RUN chmod +x esa-snap_sentinel_unix_9_0_0.sh

# install snap with gpt
RUN ./esa-snap_sentinel_unix_9_0_0.sh -q

# App code will be deployed into /root/kubota-mpd within docker container
WORKDIR /root/kubota-mpd

# link gpt so it can be used systemwide
RUN ln -s /usr/local/snap/bin/gpt /usr/bin/gpt

# set gpt max memory to 4GB
RUN sed -i -e 's/-Xmx1G/-Xmx4G/g' /usr/local/snap/bin/gpt.vmoptions
