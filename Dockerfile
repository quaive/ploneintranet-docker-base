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

#============================================
# Google Chrome
#============================================
# can specify versions by CHROME_VERSION;
#  e.g. google-chrome-stable=53.0.2785.101-1
#       google-chrome-beta=53.0.2785.92-1
#       google-chrome-unstable=54.0.2840.14-1
#       latest (equivalent to google-chrome-stable)
#       google-chrome-beta  (pull latest beta)
#============================================
ARG CHROME_VERSION="google-chrome-stable"
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update -qqy \
  && apt-get -qqy install \
    ${CHROME_VERSION:-google-chrome-stable} \
  && rm /etc/apt/sources.list.d/google-chrome.list \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

#============================================
# Chrome webdriver
#============================================
# can specify versions by CHROME_DRIVER_VERSION
# Latest released version will be used by default
#============================================
ARG CHROME_DRIVER_VERSION
RUN if [ -z "$CHROME_DRIVER_VERSION" ]; \
  then CHROME_MAJOR_VERSION=$(google-chrome --version | sed -E "s/.* ([0-9]+)(\.[0-9]+){3}.*/\1/") \
    && CHROME_DRIVER_VERSION=$(wget --no-verbose -O - "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROME_MAJOR_VERSION}"); \
  fi \
  && echo "Using chromedriver version: "$CHROME_DRIVER_VERSION \
  && wget --no-verbose -O /tmp/chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip \
  && rm -rf /opt/selenium/chromedriver \
  && unzip /tmp/chromedriver_linux64.zip -d /opt/selenium \
  && rm /tmp/chromedriver_linux64.zip \
  && mv /opt/selenium/chromedriver /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
  && chmod 755 /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
  && sudo ln -fs /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION /usr/bin/chromedriver

#=================================
# Chrome Launch Script Wrapper
#=================================
COPY wrap_chrome_binary /opt/bin/wrap_chrome_binary
RUN /opt/bin/wrap_chrome_binary


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
