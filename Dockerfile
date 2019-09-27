FROM ubuntu:18.04
MAINTAINER guido.stevens@cosent.net
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    cron \
    curl \
    file \
    gcc \
    gdebi \
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
    pdf2svg \
    poppler-data \
    poppler-utils \
    python-dev \
    python-gdbm \
    python-lxml \
    python-pip \
    python-tk \
    python-virtualenv \
    redis-server \
    ruby \
    ruby-dev \
    software-properties-common \
    sudo \
    wget \
    wv \
    xvfb \
    zlib1g-dev
RUN add-apt-repository ppa:malteworld/ppa && \
    apt-get update && \
    apt-get install -y pdftk
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    apt-get install -y git-lfs
RUN cd /tmp && \
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    gdebi -n google-chrome-stable_current_amd64.deb && \
    apt-get -fy install && \
    rm google-chrome-stable_current_amd64.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*  && \
    mv /usr/bin/google-chrome /usr/bin/google-chrome-real && \
    echo "/usr/bin/google-chome-real --no-sandbox --disable-gpu" > /usr/bin/google-chrome && \
    chmod +x /usr/bin/google-chrome && \
    wget -q  http://chromedriver.storage.googleapis.com/LATEST_RELEASE && \
    echo $(cat LATEST_RELEASE) && \
    chromedriver_version=$(cat LATEST_RELEASE) && \
    wget -N http://chromedriver.storage.googleapis.com/$chromedriver_version/chromedriver_linux64.zip && \
    unzip chromedriver_linux64.zip && \
    chmod +x chromedriver && \
    mv -f chromedriver /usr/local/bin/chromedriver && \
    ln -s /usr/local/bin/chromedriver /usr/bin/chromedriver && \
    chromedriver --version && \
    google-chrome --version
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
