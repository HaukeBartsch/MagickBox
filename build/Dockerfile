FROM amd64/ubuntu:20.04
# build using:
# docker build --no-cache -t magickbox -f ./build/Dockerfile .
#
# Run with:
#   docker run --rm -it -p 80:3000 -p 2813:2813 -v /var/run/docker.sock:/var/run/docker.sock magickbox

ARG DEBIAN_FRONTEND=noninteractive

#----------------------------------------------------------
# Install common dependencies and create default entrypoint
#----------------------------------------------------------
ENV LANG="en_US.UTF-8" \
    LC_ALL="C.UTF-8" \
    ND_ENTRYPOINT="/mb-startup.sh"

RUN apt-get update -qq && apt-get install -yq --no-install-recommends  \
    apache2 \
    apt-utils \
    build-essential \
    bzip2 \
    ca-certificates \
    cron \
    curl \
    emacs-nox \
    php7.4 \
    php7.4-cli \
    php7.4-curl \
    php7.4-mbstring \
    libapache2-mod-php7.4 \
    jq \
    sudo \
    cron \
    file \
    less \
    procps \
    git \
    gearman-job-server \
    gearman \
    gearman-tools \
    monit \
    dcmtk \
    python \
    python3 \
    python3-pip \
    docker.io \
    && pip install dicom \
    && apt-get clean \
    && rm /var/www/html/index.html \
    && cd /var/www/html/ \
    && git init \
    && git pull https://github.com/HaukeBartsch/MagickBox.git \
    && mkdir /data/ \
    && cp -R /var/www/html/code /data/ \
    && cp -R /var/www/html/streams /data/ \
    && mkdir -p /data/.pids/ \
    && mkdir -p /data/logs/ \
    && mkdir -p /data/scratch/archive/ \
    && mkdir /data/scratch/raw/ \
    && chmod 777 /data/.pids/ \
    && cp /var/www/html/code/assets/monit/processing.conf /etc/monit/conf.d/processing.conf \
    && cp /var/www/html/code/assets/monit/monitrc /etc/monit/monitrc \
    && touch /var/log/cron.log \
    && cron /var/www/html/code/assets/crontab.txt \
    && chown -R www-data:www-data /var/www/html/ \
    && cp /var/www/html/code/assets/apache2/001-processing.conf /etc/apache2/sites-available/ \
    && useradd -m -s /bin/bash -U processing \
    && usermod -a -G docker processing


RUN if [ ! -f "$ND_ENTRYPOINT" ]; then \
    echo '#!/usr/bin/env bash' >> $ND_ENTRYPOINT \
    && echo 'set +x' >> $ND_ENTRYPOINT \
    && echo 'if [ -z "$*" ]; then /usr/bin/env bash; else' >> $ND_ENTRYPOINT \
    && echo '  if [ "$1" == "start" ]; then' >> $ND_ENTRYPOINT \
    && echo '    echo "Start system services and apache...";' >> $ND_ENTRYPOINT \
    && echo '    mkdir -p /usr/local/;' >> $ND_ENTRYPOINT \
    && echo '  else $*;' >> $ND_ENTRYPOINT \
    && echo '  fi' >> $ND_ENTRYPOINT \
    && echo 'fi' >> $ND_ENTRYPOINT \
    && echo 'cron' >> $ND_ENTRYPOINT \
    && echo 'gearmand &' >> $ND_ENTRYPOINT \
    && echo 'monit start all &' >> $ND_ENTRYPOINT \
    && echo 'apachectl -D FOREGROUND' >> $ND_ENTRYPOINT \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf \
    && echo "<Directory /var/www/html/>\n    Options -Indexes +FollowSymLinks\n    AllowOverride None\n    Require all granted\n</Directory>" >> /etc/apache2/apache2.conf \
    && echo "<FilesMatch \"\\.Rds\$\">\n    Require all denied\n</FilesMatch>" >> /etc/apache2/apache2.conf; \
    fi \
    && chmod -R 777 $ND_ENTRYPOINT

EXPOSE 80
ENTRYPOINT ["/mb-startup.sh", "start"]