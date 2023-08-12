ARG ffmpeg_source=ghcr.io/linuxserver/ffmpeg
ARG ffmpeg_tag=latest
ARG radarr_tag=nightly
ARG extra_packages

FROM ${ffmpeg_source}:${ffmpeg_tag} as ffmpeg

FROM ghcr.io/linuxserver/radarr:${radarr_tag}
LABEL maintainer="mdhiggins <mdhiggins23@gmail.com>"

# copy ffmpeg install from source
COPY --from=ffmpeg /usr/lib/ /usr/lib/
COPY --from=ffmpeg /usr/local/ /usr/local/
COPY --from=ffmpeg /etc/ /etc/
COPY --from=ffmpeg /lib/ /lib/

ENV \
  LIBVA_DRIVERS_PATH="/usr/local/lib/x86_64-linux-gnu/dri" \
  LD_LIBRARY_PATH="/usr/local/lib" \
  NVIDIA_DRIVER_CAPABILITIES="compute,video,utility" \
  NVIDIA_VISIBLE_DEVICES="all"

ENV SMA_PATH /usr/local/sma
ENV SMA_RS Radarr
ENV SMA_UPDATE false

RUN \
  # ubuntu
  if [ -f /usr/bin/apt ]; then \
    apt-get update && \
    apt-get install -y \
      git \
      wget \
      xz-utils \
      python3 \
      python3-pip \
      python3-venv \
      ${extra_packages} && \
    # cleanup
    apt-get purge --auto-remove -y && \
    apt-get clean && \
    rm -rf \
      /tmp/* \
      /var/lib/apt/lists/* \
      /var/tmp/*; \
  # alpine
  elif [ -f /sbin/apk ]; then \
    apk update && \
    apk add --no-cache \
      git \
      wget \
      xz \
      python3 \
      py3-pip \
      ${extra_packages} && \
    # cleanup
    apk del --purge && \
    rm -rf \
      /root/.cache \
      /tmp/*; \
  fi && \
  # make directory
  mkdir ${SMA_PATH} && \
  # download repo
  git config --global --add safe.directory ${SMA_PATH} && \
  git clone https://github.com/mdhiggins/sickbeard_mp4_automator.git ${SMA_PATH}

EXPOSE 8989

VOLUME /config
VOLUME /usr/local/sma/config

# update.py sets FFMPEG/FFPROBE paths, updates API key and Sonarr/Radarr settings in autoProcess.ini
COPY extras/ ${SMA_PATH}/
COPY root/ /
