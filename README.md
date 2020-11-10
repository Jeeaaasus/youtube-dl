# Jeeaaasus - youtube-dl
[![Docker Automated build](https://img.shields.io/docker/cloud/automated/jeeaaasustest/youtube-dl?style=flat&logo=docker&label=build)](https://hub.docker.com/r/jeeaaasustest/youtube-dl/)
[![Image Layers](https://img.shields.io/microbadger/layers/jeeaaasustest/youtube-dl/latest?style=flat&logo=docker&label=image+layers)](https://hub.docker.com/r/jeeaaasustest/youtube-dl/)
[![Image Size](https://img.shields.io/microbadger/image-size/jeeaaasustest/youtube-dl/latest?style=flat&logo=docker)](https://hub.docker.com/r/jeeaaasustest/youtube-dl/)
[![Docker Stars](https://img.shields.io/docker/stars/jeeaaasustest/youtube-dl?style=flat&logo=docker)](https://hub.docker.com/r/jeeaaasustest/youtube-dl/)
[![Docker Pulls](https://img.shields.io/docker/pulls/jeeaaasustest/youtube-dl?style=flat&logo=docker)](https://hub.docker.com/r/jeeaaasustest/youtube-dl/)

**Automated youtube-dl Docker image for downloading YouTube subscriptions**

Docker hub page: [here](https://hub.docker.com/r/jeeaaasustest/youtube-dl)

youtube-dl documentation: ~~[here](https://ytdl-org.github.io/youtube-dl/documentation.html)~~  [internet archive link](https://web.archive.org/web/20200924161811/https://github.com/ytdl-org/youtube-dl/blob/master/README.md#readme)

# Features
* **Self Updating youtube-dl**
* **Automated Downloading**
    * Interval options
* **Subscriptions Downloading**
    * Channel urls from file
* **PUID/PGID**
* **All youtube-dl Options**
    * Format
    * Quality
    * High fps videos
    * Download archive
    * Output
    * Subtitles
    * Thumbnails
    * Geo bypass
    * Proxy support
    * Metadata

# Usage
```
docker run -d \
    --name youtube-dl \
    -v youtube-dl_data:/config \
    -v <PATH>:/downloads \
    jeeaaasustest/youtube-dl
```
Then configure the channels as explained in the [Configure youtube-dl](https://github.com/Jeeaaasus/youtube-dl#configure-youtube-dl) section below.

**Explanation**
* `-v youtube-dl_data:/config`
  
  This makes a docker volume where your config files are saved, named: `youtube-dl_data`.
 
* `-v <PATH>:/downloads`
  
  Here you have to replace `<PATH>`. This is where on your Docker host you want youtube-dl to download videos. Example: `-v /media/youtube-dl:/downloads`

# Env Parameters
`-e <Parameter>=<Option>`

| Parameter | Option (Default) | What it does
| :---: | :---: | :--- |
| `PUID` | (`911`) | If you need to specify UserID for file permission reasons.
| `PGID` | (`911`) | If you need to specify GroupID for file permission reasons.
| `TZ` | `Europe/London` | Specify TimeZone for the log timestamps to be correct.
| `youtubedl_interval` | `1h` (`3h`) `12h` `2d` | If you want to change the default download interval. 1 hour, (3 hours), 12 hours, 2 days.
| `youtubedl_quality` | `720` (`1080`) `1440` `2160` | If you want to change the default download resolution. 720p, (1080p), 1440p, 4k.

# Configure youtube-dl
* **channels.txt**

    File location: `/config/channels.txt`.

    This is where you input all the YouTube channels you want to have videos downloaded from.
    ```
    # One per line
    # Name
    https://www.youtube.com/user/url
    # Another one
    https://www.youtube.com/channel/anotherurl
    ```
    Adding with Docker: `docker exec youtube-dl bash -c "echo URL >> ./channels.txt"`

* **args.conf**

    File location: `/config/args.conf`.&nbsp;&nbsp;&nbsp;*delete and restart container to restore default options*

    This is where all youtube-dl execution options are and you can add or remove them however you like, 
    exceptions being that `--config-location` and `--batch-file` cannot be used.

    Don't want a folder for every channel? Change the line with `--output` to suit your needs.
    
    Don't want mp4 files? Change the line with `--merge-output-format` to suit your needs.
    
    Please keep in mind that if you define `--format`, the ENV `youtubedl_quality` is no longer used.

    youtube-dl configuration options documentation: ~~[here](https://github.com/ytdl-org/youtube-dl/blob/master/README.md#options)~~  [internet archive link](https://web.archive.org/web/20200924161811/https://github.com/ytdl-org/youtube-dl/blob/master/README.md#options)

* **archive.txt**

    File location: `/config/archive.txt`.&nbsp;&nbsp;&nbsp;*delete to make youtube-dl forget downloaded videos*

    This is where youtube-dl stores all previously downloaded video IDs.

* **dateafter.txt**

    File location: `/config/dateafter.txt`.

    If you do not define `--dateafter` in args.conf, this is where youtube-dl gets that value. It is used as a workaround to help against YouTube thinking you are making too many requests and therefore ip banning you.
