# Jeeaaasus - youtube-dl
[![Docker Automated build](https://img.shields.io/docker/cloud/automated/jeeaaasustest/youtube-dl?style=flat&logo=docker&label=build)](https://hub.docker.com/r/jeeaaasustest/youtube-dl/)
[![Image Layers](https://img.shields.io/microbadger/layers/jeeaaasustest/youtube-dl/latest?style=flat&logo=docker&label=image+layers)](https://hub.docker.com/r/jeeaaasustest/youtube-dl/)
[![Image Size](https://img.shields.io/microbadger/image-size/jeeaaasustest/youtube-dl/latest?style=flat&logo=docker)](https://hub.docker.com/r/jeeaaasustest/youtube-dl/)
[![Docker Stars](https://img.shields.io/docker/stars/jeeaaasustest/youtube-dl?style=flat&logo=docker)](https://hub.docker.com/r/jeeaaasustest/youtube-dl/)
[![Docker Pulls](https://img.shields.io/docker/pulls/jeeaaasustest/youtube-dl?style=flat&logo=docker)](https://hub.docker.com/r/jeeaaasustest/youtube-dl/)

**Automated youtube-dl Docker image for downloading YouTube subscriptions**

Docker hub page: [here](https://hub.docker.com/r/jeeaaasustest/youtube-dl)

youtube-dl documentation: [here](https://ytdl-org.github.io/youtube-dl/documentation.html)

# Features
* **Self Updating youtube-dl**
* **Automated Downloading**
    * Interval options
* **Subscriptions Downloading**
    * Login with YouTube
    * Channels from file
* **PUID/PGID**
* **All youtube-dl Options**
    * Quality
    * Download achive
    * Format merging
    * Subtitles
    * Thumbnails
    * Geo bypass
    * Metadata

# Usage
```
docker run -d \
    --name=youtube-dl \
    --mount 'type=volume,source=youtube-dl_data,target=/config' \
    --mount 'type=bind,source=<PATH>,target=/downloads' \
    jeeaaasustest/youtube-dl
```
**Explanation**
* `--mount 'type=volume,source=youtube-dl_data,target=/config'`
  
  This makes a volume where your config files are saved, named: `youtube-dl_data`.
 
* `--mount 'type=bind,source=<PATH>,target=/downloads'`
  
  Here you have to replace `<PATH>`.
  
  This is where on your Docker host you want youtube-dl to download videos.

  Remember that if the directory that does not yet exist on the Docker host, Docker does not automatically create it for you and the command will fail.

# Env Parameters
`-e <Parameter>=<Option>`

| Parameter | Option (Default) | What it does
| :---: | :---: | :--- |
| `PGID` | (`911`) | If you need to specify GroupID for file permission reasons.
| `PUID` | (`911`) | If you need to specify UserID for file permission reasons.
| `TZ` | `Europe/London` | Specify TimeZone for the log timestamps to be correct.
| `youtubedl_interval` | `1h` (`3h`) `12h` `2d` | If you want to change the default download interval. 1 hour, (3 hours), 12 hours, 2 days.
| `youtubedl_quality` | `720` (`1080`) `1440` `2160` | If you want to change the default download resolution. 720p, (1080p), 1440p, 4k.
| `youtubedl_youtube_login` | (`no`) `yes` | If you want to login to YouTube and download **all** your subscriptions instead of adding them to *channels.txt*. Requires both `youtubedl_youtube_username` and `youtubedl_youtube_password`.
| `youtubedl_youtube_username` | `<username>` | YouTube username
| `youtubedl_youtube_password` | `<password>` | YouTube password

# Configure youtube-dl
* **args.conf**

    File located: `/config/args.conf`. > *delete to restore default options*

    This is where all youtube-dl execution options are and you can add or remove them however you like, one exception being `--format` cannot be used.

    Don't want a folder for every channel? Change the line with `--output` to suit your needs.
    
    Don't want mp4 files? Change the line with `--merge-output-format` to suit your needs.

    youtube-dl configuration options documentation: [here](https://github.com/ytdl-org/youtube-dl/blob/master/README.md#options)

* **channels.txt**

    File located: `/config/channels.txt`.

    This is where you input all the YouTube channels you want to download.
    Ignored if you use `youtubedl_youtube_login`=`yes`
    ```
    # One per line
    # Name
    https://www.youtube.com/user/url
    # Another one
    https://www.youtube.com/channel/anotherurl
    ```
    Adding with Docker: `docker exec youtube-dl bash -c "echo URL >> ./channels.txt"`

* **archive.txt**

    File located: `/config/archive.txt`. > *delete to make youtube-dl forget downloaded videos*

    This is where youtube-dl stores all previously downloaded video IDs.
