FROM ubuntu:20.04
LABEL maintainer Ascensio System SIA <support@onlyoffice.com>

<<<<<<< HEAD
ENV LANG=de_DE.UTF-8 LANGUAGE=de_DE:de LC_ALL=de_DE.UTF-8 DEBIAN_FRONTEND=noninteractive PG_VERSION=12
=======
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive PG_VERSION=12
>>>>>>> 93740b7c37cee9b7018b3a1c32cc1cb7a999e0c8

ARG ONLYOFFICE_VALUE=onlyoffice

RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d && \
    apt-get -y update && \
    apt-get -yq install wget apt-transport-https gnupg locales && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0x8320ca65cb2de8e5 && \
    locale-gen de_DE.UTF-8 && \
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections && \
    apt-get -yq install \
        adduser \
        apt-utils \
        bomstrip \
        certbot \
        curl \
        gconf-service \
        htop \
        libasound2 \
        libboost-regex-dev \
        libcairo2 \
        libcurl3-gnutls \
        libcurl4 \
        libgtk-3-0 \
        libnspr4 \
        libnss3 \
        libstdc++6 \
        libuser \
        libxml2 \
        libxss1 \
        libxtst6 \
        mysql-client \
        nano \
        net-tools \
        netcat \
        nginx-extras \
        postgresql \
        postgresql-client \
        pwgen \
        rabbitmq-server \
        redis-server \
        software-properties-common \
        sudo \
        supervisor \
        ttf-mscorefonts-installer \
        xvfb \
        zlib1g && \
    if [  $(ls -l /usr/share/fonts/truetype/msttcorefonts | wc -l) -ne 61 ]; \
        then echo 'msttcorefonts failed to download'; exit 1; fi  && \
    echo "SERVER_ADDITIONAL_ERL_ARGS=\"+S 1:1\"" | tee -a /etc/rabbitmq/rabbitmq-env.conf && \
    sed -i "s/bind .*/bind 127.0.0.1/g" /etc/redis/redis.conf && \
    sed 's|\(application\/zip.*\)|\1\n    application\/wasm wasm;|' -i /etc/nginx/mime.types && \
    sudo -u postgres pg_conftool 10 main set listen_addresses 'localhost' && \
    service postgresql restart && \
    sudo -u postgres psql -c "CREATE DATABASE $ONLYOFFICE_VALUE;" && \
    sudo -u postgres psql -c "CREATE USER $ONLYOFFICE_VALUE WITH password '$ONLYOFFICE_VALUE';" && \
    sudo -u postgres psql -c "GRANT ALL privileges ON DATABASE $ONLYOFFICE_VALUE TO $ONLYOFFICE_VALUE;" && \ 
    service postgresql stop && \
    service redis-server stop && \
    service rabbitmq-server stop && \
    service supervisor stop && \
    service nginx stop && \
    rm -rf /var/lib/apt/lists/*

COPY config /app/ds/setup/config/
COPY run-document-server.sh /app/ds/run-document-server.sh

EXPOSE 80

ARG REPO_URL="deb http://download.onlyoffice.com/repo/debian squeeze main"
ARG COMPANY_NAME=onlyoffice
ARG PRODUCT_NAME=documentserver

ENV COMPANY_NAME=$COMPANY_NAME \
    PRODUCT_NAME=$PRODUCT_NAME

RUN echo "$REPO_URL" | tee /etc/apt/sources.list.d/ds.list && \
    apt-get -y update && \
    service postgresql start && \
    apt-get -yq install $COMPANY_NAME-$PRODUCT_NAME && \
    service postgresql stop && \
    service supervisor stop && \
    chmod 755 /app/ds/*.sh && \
    rm -rf /var/log/$COMPANY_NAME && \
    rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8
RUN groupmod -g 800 ds
RUN usermod -u 800 ds

VOLUME /var/log/$COMPANY_NAME /var/lib/$COMPANY_NAME /var/www/$COMPANY_NAME/Data /var/lib/postgresql /var/lib/rabbitmq /var/lib/redis /usr/share/fonts/truetype/custom

ENTRYPOINT ["/app/ds/run-document-server.sh"]
