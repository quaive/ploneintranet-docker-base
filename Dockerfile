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
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    apt-get install -y git-lfs
RUN cd /tmp && \
    wget https://github.com/mozilla/geckodriver/releases/download/v0.19.1/geckodriver-v0.19.1-linux64.tar.gz && \
    tar xvzf geckodriver-v0.19.1-linux64.tar.gz && \
    mv geckodriver /usr/local/bin
RUN gem install docsplit
RUN locale-gen en_US.UTF-8 nl_NL@euro
COPY buildout.d /tmp/buildout.d
COPY buildout.cfg /tmp/
COPY requirements.txt /tmp/
RUN cd /tmp && \
    wget https://launchpad.net/plone/5.1/5.1.5/+download/Plone-5.1.5-UnifiedInstaller.tgz && \
    tar xzf Plone-5.1.5-UnifiedInstaller.tgz && \
    tar xjf Plone-5.1.5-UnifiedInstaller/packages/buildout-cache.tar.bz2 && \
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
