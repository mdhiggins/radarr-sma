# Official SMA container based on linuxserver/radarr
Docker container for Radarr that includes all FFMPEG and python requirements to run SMA with Radarr.

## Version Tags

|Tag|Description|
|---|---|
|latest|Stable release from Radarr with precompiled FFMPEG binaries|
|develop|Develop release from Radarr with precompiled FFMPEG binaries|
|nightly|Nightly release from Radarr with precompiled FFMPEG binaries|
|build|Stable release from Radarr with FFMPEG compiled from jrottenberg/ffmpeg|

## Usage

### Recent update
As of 3/9/2020 the containers were overhauled and the location of the script was changed from `/usr/local/bin/sma/sickbeard_mp4_automator` to `/usr/local/sma`. The autoProcess mount point has been modified as well to be more docker friendly in a `/usr/local/sma/config` directory. Please review and update accordingly.

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
|SMA_FFMPEG_URL|Defaults to latest static build from https://johnvansickle.com but can override by changing this var|
|SMA_STRIP_COMPONENTS|Default `1`. Number of components to strip from your tar.xz file when extracting so that FFmpeg binaries land in `/usr/local/bin`|
|SMA_HWACCEL|Default `false`. Set `true` to pull additional packages used for hardare acceleration (will require custom FFmpeg binaries)|
|SMA_USE_REPO|Default `false`. Set `true` to download FFMPEG binaries for default repository (will likely be older versions)|

## Special Considerations
Using the `build` tag leverages mulit-stage docker builds to generate FFMPEG compiled using [jrottenberg/ffmpeg's](https://hub.docker.com/r/jrottenberg/ffmpeg) containers. This allows flexibility with building FFMPEG using special options such as VAAPI or NVENC. Building locally allows `ARG` values to be set to change the underlying parent container tags as below. It is recommended that you match your Ubuntu version in the ffmpeg_tag and radarr_tag to ensure no missing dependencies.

|ARG|Default|Description|
|---|---|---|
|ffmpeg_tag|latest|Set tag to correspond to jrottenberg/ffmpeg:tag|
|radarr_tag|latest|Set tag to correspond to linuxserver/radarr:tag|
|extra_packages||Set additional packages/dependencies that might need to be installed via apt-get or apk, separated by spaces|

### VAAPI docker-compose sample
~~~yml
services:
  radarr:
    container_name: radarr
    build:
      context: https://github.com/mdhiggins/radarr-sma.git#build
      args:
        ffmpeg_tag: 4.4-vaapi2004
    devices:
      - /dev/dri/renderD128:/dev/dri/renderD128
~~~


For the newer Linuxserver Radarr builds based on mono the jrottenberg FFMpeg builds are not compatible and will have issues with VAAPI. The repo build of FFMpeg however includes VAAPI with appropriate libaries so you can use non-build tags with the `SMA_USE_REPO` environment variable set to `true` to enable VAAPI supported FFMpeg builds

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
      - SMA_USE_REPO=true
    devices:
      - /dev/dri/renderD128:/dev/dri/renderD128
~~~

### NVIDIA / NVEnc
Currently nVidia and NVEnc are not supported on mono which is used by the lastest Linuxserver containers. In order to use NVEnc or nVidia hardare accleration you will need to use an older tag that is still based on Ubuntu
