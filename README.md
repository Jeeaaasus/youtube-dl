# Jeeaaasus - youtube-dl
[![Docker Automated build](https://img.shields.io/docker/cloud/automated/jeeaaasustest/youtube-dl?style=flat&logo=docker&label=build)](https://github.com/Jeeaaasus/youtube-dl/actions/workflows/push-release-version-image.yml/)
[![Image Size](https://img.shields.io/docker/image-size/jeeaaasustest/youtube-dl/latest?style=flat&logo=docker)](https://hub.docker.com/r/jeeaaasustest/youtube-dl/)
[![Docker Pulls](https://img.shields.io/docker/pulls/jeeaaasustest/youtube-dl?style=flat&logo=docker)](https://hub.docker.com/r/jeeaaasustest/youtube-dl/)
[![Docker Stars](https://img.shields.io/docker/stars/jeeaaasustest/youtube-dl?style=flat&logo=docker)](https://hub.docker.com/r/jeeaaasustest/youtube-dl/)

**Automated yt-dlp Docker image for downloading YouTube subscriptions**

Docker hub page [here](https://hub.docker.com/r/jeeaaasustest/youtube-dl).  
yt-dlp documentation [here](https://github.com/yt-dlp/yt-dlp).

## Recent Changes
   ### ***2021-08-22***
   
   Because [youtube-dl](https://github.com/ytdl-org/youtube-dl) seems to have seized development, this image will soon be changing over to use [yt-dlp](https://github.com/yt-dlp/yt-dlp) instead.
Because of this change some current setups might not work the same, the major differences are listed [here](https://github.com/yt-dlp/yt-dlp#differences-in-default-behavior).

Hopefully this wont affect most users but if you are someone with a heavily customized configuration I ask you to try out the beta image (`jeeaaasustest/youtube-dl:yt-dlp-beta`) containing [yt-dlp](https://github.com/yt-dlp/yt-dlp) and let me know about any issues or questions [here](https://github.com/Jeeaaasus/youtube-dl/issues/49).

# Features
* **Easy Usage with Minimal Setup**
    * Quality options with env parameter
    * Included format selection argument
    * Included set of starter arguments
* **Automatic Updates**
    * Self updating container
    * Automated image building
* **Automatic Downloads**
    * Interval options with env parameter
    * Channel URLs from file
* **PUID/PGID**
* **yt-dlp Options**
   * SponsorBlock
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
   * Etc

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
  This makes a Docker volume where your config files are saved, named: `youtube-dl_data`.
 
* `-v <PATH>:/downloads`  
  This makes a bind mount where the videos are downloaded.
  
  This is where on your Docker host you want youtube-dl to download videos.  
  Replace `<PATH>`, example: `-v /media/youtube-dl:/downloads`

# Env Parameters
`-e <Parameter>=<Value>`

| Parameter | Value (Default) | What it does
| :---: | :---: | :--- |
| `TZ` | `Europe/London` | Specify TimeZone for the log timestamps to be correct.
| `PUID` | (`911`) | If you need to specify UserID for file permission reasons.
| `PGID` | (`911`) | If you need to specify GroupID for file permission reasons.
| `youtubedl_debug` | `true` (`false`) | Used to enable verbose mode.
| `youtubedl_lockfile` | `true` (`false`) | Used to enable youtubedl-running, youtubedl-completed files in downloads directory. Useful for external scripts.
| `youtubedl_webui` | `true` (`false`) | If you would like to beta test the unfinished web-ui feature, might be broken!
| `youtubedl_webuiport` | (`8080`) | If you want to change the default web-ui port.
| `youtubedl_interval` | `1h` (`3h`) `12h` `3d` | If you want to change the default download interval. 1 hour, (3 hours), 12 hours, 3 days.
| `youtubedl_quality` | `720` (`1080`) `1440` `2160` | If you want to change the default download resolution. 720p, (1080p), 1440p, 4k.

# Image Tags
* **`latest`**
    * Automatically built when a youtube-dl version is released.
    * Container updates to latest youtube-dl while running.
* **`v<VERSION>`**
    * Automatically built when a youtube-dl version is released.
    * Does not update.

# Configure youtube-dl
* **channels.txt**

    File location: `/config/channels.txt`.  
    This is where you input all the YouTube channels you want to have videos downloaded from.
    ```
    # One per line
    # Name
    https://www.youtube.com/user/channel_username/videos
    # Another one
    https://www.youtube.com/channel/UC0vaVaSyV14uvJ4hEZDOl0Q/videos
    ```
    Adding with Docker:  
    `docker exec youtube-dl bash -c 'echo "# NAME" >> ./channels.txt'`  
    `docker exec youtube-dl bash -c 'echo "URL" >> ./channels.txt'`
    
    It is recommended to use the ID-based URLs, they look like: `/channel/UC0vaVaSyV14uvJ4hEZDOl0Q`, as the other ones might get changed.
    You find the ID-based URL by going to a video and clicking on the uploader.

* **archive.txt**

    File location: `/config/archive.txt`.&nbsp;&nbsp;&nbsp;*delete to make youtube-dl forget downloaded videos*  
    This is where youtube-dl stores all previously downloaded video IDs.

* **args.conf**

    File location: `/config/args.conf`.&nbsp;&nbsp;&nbsp;*delete and restart container to restore default arguments*  
    This is where all youtube-dl execution arguments are, you can add or remove them however you like, 
    exceptions being that `--config-location` and `--batch-file` cannot be used.
    
    Keep in mind that if you define `--format`, the ENV `youtubedl_quality` is not used anymore.
    
    The default `--playlist-end 8` makes youtube-dl only download the latest 8 videos.
    Be careful changing this! YouTube may feel like you are making too many requests and therefore ip banning you.
    
    The default `--match-filter "! is_live"` makes youtube-dl ignore live streams.
    
    The default `--sponsorblock-mark all` makes youtube-dl create chapters using the [SponsorBlock API](https://sponsor.ajay.app/).

    Don't want a folder for every channel? Change the line with `--output` to suit your needs.
    
    Don't want mp4 files? Change the line with `--merge-output-format` to suit your needs.

    yt-dlp configuration options documentation [here](https://github.com/yt-dlp/yt-dlp#usage-and-options).
