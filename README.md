# radarr-sma-rclone
[LinuxServer/Radarr](https://hub.docker.com/r/linuxserver/radarr/) build with [sickbeard_mp4_automator](https://github.com/mdhiggins/sickbeard_mp4_automator) and [rclone](https://github.com/ncw/rclone) included. 

Sample docker-compose file:
```
radarr:
    image: stevepork/radarr-sma-rclone
    container_name: radarr
    volumes:
      - /opt/appdata/sma/autoProcess.ini:/usr/local/bin/sma/sickbeard_mp4_automator/autoProcess.ini
      - /opt/appdata/rclone/:/config/xdg/rclone
      - /opt/appdata/radarr:/config
      - /mnt/media/Movies:/movies
      - /mnt/media/Downloads:/downloads
      - /etc/localtime:/etc/localtime:ro
    ports:
      - 7878:7878
    restart: always
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
```

autoProcess.ini configuration documentation is here: https://github.com/mdhiggins/sickbeard_mp4_automator

### Configuring postRadarr.py:
1. Setup the postRonarr.py script via Settings > Connect > Connections > + (Add)
    * `name` - SMA Post Process
    * `on grab` - no
    * `on download` - yes
    * `on upgrade` - yes
    * `on rename` - no
2. Configure the path and args
    * `path` - `/usr/local/bin/sma/env/bin/python3`
    * `arguments` - `/usr/local/bin/sma/sickbeard_mp4_automator/postRonarr.py`
    
![SCREENSHOT](https://user-images.githubusercontent.com/10834935/52353094-c9d75600-2a25-11e9-9bde-21e437d48b9c.png)
