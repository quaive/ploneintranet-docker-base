FROM ubuntu:16.04
MAINTAINER guido.stevens@cosent.net
RUN apt-get update && apt-get install -y \
    cron \
    curl \
    file \
    firefox \
    gcc \
    gettext \
    ghostscript \
    git-core \
    graphicsmagick \
    jed \
    libenchant-dev \
    libffi-dev \
    libfreetype6-dev \
    libjpeg-dev \
    libldap2-dev \
    libreoffice \
    libsasl2-dev \
    libsqlite3-dev \
    libxslt1-dev \
    locales \
    make \
    pdftk \
    poppler-data \
    poppler-utils \
    python-dev \
    python-gdbm \
    python-lxml \
    python-pip \
    python-tk \
    python-virtualenv \
    redis-server \
    ruby2.3 \
    ruby2.3-dev \
    sudo \
    wget \
    wv \
    xvfb \
    zlib1g-dev
# downgrade firefox because https://github.com/SeleniumHQ/selenium/issues/2110
RUN cd /tmp && \
    wget https://launchpad.net/~ubuntu-mozilla-security/+archive/ubuntu/ppa/+build/9629817/+files/firefox_46.0+build5-0ubuntu0.16.04.2_amd64.deb && \
    apt-get -y purge firefox && \
    dpkg -i firefox_46.0+build5-0ubuntu0.16.04.2_amd64.deb
RUN gem install docsplit
RUN locale-gen en_US.UTF-8 nl_NL@euro
COPY buildout.d /tmp/buildout.d
COPY buildout.cfg /tmp/
COPY requirements.txt /tmp/
RUN cd /tmp && \
    wget https://launchpad.net/plone/5.0/5.0.8/+download/Plone-5.0.8-UnifiedInstaller.tgz && \
    tar xzf Plone-5.0.8-UnifiedInstaller.tgz && \
    tar xjf Plone-5.0.8-UnifiedInstaller/packages/buildout-cache.tar.bz2 && \
    mv buildout-cache/* /var/tmp/ && \
    mkdir /var/tmp/extends && \
    rm -rf Plone* buildout-cache
RUN mkdir /tmp/build && cd /tmp/build && \
    cp -r /tmp/buildout.* /tmp/requirements.txt . && \
    virtualenv -p python2.7 . && \
    bin/pip install -r requirements.txt && \
    bin/buildout -c buildout.cfg && \
    chmod -R a+rwX /var/tmp/eggs /var/tmp/downloads /var/tmp/extends && \
    cd /tmp && rm -rf /tmp/build
CMD ["/bin/bash"]
