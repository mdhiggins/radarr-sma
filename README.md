# Official SMA container based on linuxserver/radarr
Docker container for Radarr that includes all FFMPEG and python requirements to run SMA with Radarr.

## Version Tags

|Tag|Description|
|---|---|
|latest|Stable release from linuxserver/radarr with FFMPEG compiled from linuxserver/ffmpeg|
|develop|Develop release from linuxserver/radarr with FFMPEG compiled from linuxserver/ffmpeg|
|nightly|Stable release from linuxserver/radarr with FFMPEG compiled from linuxserver/ffmpeg|

## Usage

### docker-compose
~~~yml
services:
  radarr:
    image: mdhiggins/radarr-sma
    container_name: radarr
    volumes:
      - /opt/appdata/radarr:/config
      - /opt/appdata/sma:/usr/local/sma/config
      - /mnt/storage/movies:/movies
      - /mnt/storage/downloads:/downloads
    ports:
      - 7878:7878
    restart: always
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
~~~

### autoProcess.ini
- Mount autoProcess.ini containing directory to `/usr/local/sma/config` using volumes
 - Consider making this writable as new options will be auto written to the config as they are added
- Radarr configuration options are read from `config.xml` inside the container and injected at runtime into `autoProcess.ini`
 - ffmpeg
 - ffprobe
 - host (read from environment variable or set to 127.0.0.1)
 - webroot
 - port
 - ssl

### Python Environment
The script installs all dependencies in a virtual environment, not the container/system level Python environment. In order to use the Python environment with the dependencies installed, please execute using `/usr/local/sma/venv/bin/python3`. Use this same Python executable if using manual.py

## Configuring Radarr

###  Enable completed download handling
- Settings > Download Client > Completed Download Handling > Enable: Yes

### Add Custom Script
- Settings > Connect > + Add > Custom Script

|Parameter|Value|
|---|---|
|On Grab| No|
|On Import| Yes|
|On Upgrade| Yes|
|On Rename| No|
|On Movie Delete| No|
|On Movie File Delete| No|
|On Health Issue| No|
|On Application Update| No|
|Path|`/usr/local/sma/postRadarr.sh`|

**Make sure you're using the .sh file, no the .py file, the .sh file points to the appropriate virtual environment**

## Logs

Located at `/usr/local/sma/config/sma.log` inside the container and your mounted config folder

## Environment Variables

|Variable|Description|
|---|---|
|PUID|User ID|
|PGID|Group ID|
|HOST|Local IP address for callback requests, default `127.0.0.1`|
|SMA_PATH|`/usr/local/sma`|
|SMA_UPDATE|Default `false`. Set `true` to pull git update of SMA on restart|
|SMA_FFMPEG_URL|If provided, override linuxserver/ffmpeg with a static build provided by the URL|
|SMA_STRIP_COMPONENTS|Default `1`. Number of components to strip from your tar.xz file when extracting so that FFmpeg binaries land in `/usr/local/bin`|

## Hardware Acceleration
The default image is built with [linuxserver/ffmpeg](https://hub.docker.com/r/linuxserver/ffmpeg), which supports VAAPI, QSV, and NVEnc/NVDec.

For VAAPI/QSV, you need to mount the hardware device from `/dev/dri`. 

Nvidia GPU support requires the `nvidia` runtime, available by installing [nvidia-container-toolkit](https://github.com/NVIDIA/nvidia-container-toolkit).

### VAAPI docker-compose sample
~~~yml
services:
  sonarr:
    container_name: sonarr
    devices:
      - /dev/dri/renderD128:/dev/dri/renderD128
~~~

### NVIDIA / NVEnc  NVDec docker-compose sample
~~~yml
services:
  sonarr:
    container_name: sonarr
    runtime: nvidia
~~~
