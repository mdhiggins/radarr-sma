FROM mdhiggins/radarr-sma
MAINTAINER StevenChorkley

# set environment variables
ENV GOROOT /usr/local/bin/golang
ENV GOPATH $HOME/go
ENV PATH $GOROOT/bin:$GOPATH/bin:$PATH
ENV RCLONE_VERSION=current

# install go
RUN \
  wget https://dl.google.com/go/go1.11.5.linux-amd64.tar.gz -O /tmp/go.tar.gz && \
  tar -xvf /tmp/go.tar.gz -C /tmp/ && mv /tmp/go /usr/local/bin/golang/ && \

# install rclone
  wget https://downloads.rclone.org/rclone-current-linux-amd64.zip -O /tmp/rclone.zip && \
  unzip /tmp/rclone.zip -d /tmp && \
  mv /tmp/rclone-*-linux-amd64/rclone /usr/local/bin && \

# cleanup
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*