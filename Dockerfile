FROM linuxserver/deluge 

RUN \
  echo "install packages" && \
  apt-get update && \
  apt-get install -y python3 python3-pip && \
  pip3 install mnamer && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /provision
