FROM ubuntu:14.04.2
MAINTAINER guido.stevens@cosent.net
# we need ruby>2.0.0 for jekyll>3.0.0
RUN apt-get update && apt-get install -y software-properties-common && apt-add-repository -y ppa:brightbox/ruby-ng
RUN apt-get update && apt-get install -y \
    curl \
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
    libxslt1-dev \
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
    wget \
    xvfb \
    zlib1g-dev
RUN gem install docsplit
RUN locale-gen en_US.UTF-8 nl_NL@euro
COPY buildout.d /tmp/buildout.d
COPY buildout.cfg /tmp/
COPY requirements.txt /tmp/
RUN cd /tmp && \
    wget https://launchpad.net/plone/5.0/5.0.4/+download/Plone-5.0.4-UnifiedInstaller.tgz && \
    tar xzf Plone-5.0.4-UnifiedInstaller.tgz && \
    tar xjf Plone-5.0.4-UnifiedInstaller/packages/buildout-cache.tar.bz2 && \
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
