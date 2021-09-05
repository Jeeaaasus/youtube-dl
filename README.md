# Jeeaaasus - youtube-dl
[![Docker Automated build](https://img.shields.io/docker/cloud/automated/jeeaaasustest/youtube-dl?style=flat&logo=docker&label=build)](https://github.com/Jeeaaasus/youtube-dl/actions/workflows/push-release-version-image.yml/)
[![Image Size](https://img.shields.io/docker/image-size/jeeaaasustest/youtube-dl/latest?style=flat&logo=docker)](https://hub.docker.com/r/jeeaaasustest/youtube-dl/)
[![Docker Pulls](https://img.shields.io/docker/pulls/jeeaaasustest/youtube-dl?style=flat&logo=docker)](https://hub.docker.com/r/jeeaaasustest/youtube-dl/)
[![Docker Stars](https://img.shields.io/docker/stars/jeeaaasustest/youtube-dl?style=flat&logo=docker)](https://hub.docker.com/r/jeeaaasustest/youtube-dl/)

**Automated yt-dlp Docker image for downloading YouTube subscriptions**

Docker hub page [here](https://hub.docker.com/r/jeeaaasustest/youtube-dl).  
yt-dlp documentation [here](https://github.com/yt-dlp/yt-dlp).

## Recent Changes

### ***2021-09-05 - "The king is dead, long live the king!"***
Image tags `latest`, `v2021.09.02` and future `v<VERSION>` now contains [yt-dlp](https://github.com/yt-dlp/yt-dlp).  
`v2021.06.06` is the last image to contain [youtube-dl](https://github.com/ytdl-org/youtube-dl).

There are many new and changed default arguments, if you have modified your `args.conf` you might want to take a look at the new [default args](https://github.com/Jeeaaasus/youtube-dl/blob/master/root/config.default/args.conf). If you have not modified your `args.conf` it should update to the new one.  

With yt-dlp comes many improvments, such as, bypass age gate in most cases, better video format selection, [SponsorBlock API](https://sponsor.ajay.app/) support to generate chapters when there are sponsored segments, although cutting out segments are not yet supported.  
Other new stuff include, arm64 image, new ENVs: `youtubedl_lockfile`, to help with external scripts. `youtubedl_cookies`, an easy way to pass cookies without the need to modify your `args.conf`. `youtubedl_watchlater`, an easy way to download your Watch Later playlist.
#

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
   * SponsorBlock*
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
| `youtubedl_webuiport` | (`8080`) | If you need to change the web-ui port.
| `youtubedl_cookies` | `true` (`false`) | Used to pass cookies for authentication.
| `youtubedl_watchlater` | `true` (`false`) | If you want to download your Watch Later playlist. Authentication is required.
| `youtubedl_interval` | `1h` (`3h`) `12h` `3d` | If you want to change the default download interval.<br>1 hour, (3 hours), 12 hours, 3 days.
| `youtubedl_quality` | `720` (`1080`) `1440` `2160` | If you want to change the default download resolution.<br>720p, (1080p), 1440p, 4k.

# Image Tags
* **`latest`**
    * Automatically built when a yt-dlp version is released.
    * Container updates to latest yt-dlp while running.
* **`v<VERSION>`**
    * Automatically built when a yt-dlp version is released.
    * Does not update.

# Configure youtube-dl
* **channels.txt**

    File location: `/config/channels.txt`.  
    This is where you input all the YouTube channels you want to have videos downloaded from.
    ```
    # One per line
    # Name
    https://www.youtube.com/user/channel_username
    # Another one
    https://www.youtube.com/channel/UC0vaVaSyV14uvJ4hEZDOl0Q
    ```
    Adding with Docker:  
    `docker exec youtube-dl bash -c 'echo "# NAME" >> ./channels.txt'`  
    `docker exec youtube-dl bash -c 'echo "URL" >> ./channels.txt'`

    It is recommended to use the ID-based URLs, they look like: `/channel/UC0vaVaSyV14uvJ4hEZDOl0Q`, as the other ones might get changed.
    You find the ID-based URL by going to a video and clicking on the uploader.

* **Authentication**

    Cookies are used to authenticate your YouTube account which is necessary if you want to download members only videos you have access to or your own private videos and playlists like Watch Later.

    In order to pass your cookies to youtube-dl, you first need a browser extension to extract your cookies, for example, [Get cookies.txt](https://chrome.google.com/webstore/detail/get-cookiestxt/bgaddhkoddajcdgocldbbfleckgcbcid/) (for Chrome) or [cookies.txt](https://addons.mozilla.org/en-US/firefox/addon/cookies-txt/) (for Firefox).  
    Once you've extracted your cookies, place the `cookies.txt` file inside your Docker volume named `youtube-dl_data` or the folder `/config/` inside your container. One way of doing this would be using the `docker cp` command: `docker cp ./cookies.txt youtube-dl:/config/`  
    Then set the ENV Parameter `youtubedl_cookies` to `true`, by adding it to your Docker run command when creating your container:  
    `-e youtubedl_cookies=true`.

* **archive.txt**

    File location: `/config/archive.txt`.&nbsp;&nbsp;&nbsp;*delete to make youtube-dl forget downloaded videos*  
    This is where youtube-dl stores all previously downloaded video IDs.

* **args.conf**

    File location: `/config/args.conf`.&nbsp;&nbsp;&nbsp;*delete and restart container to restore [default arguments](https://github.com/Jeeaaasus/youtube-dl/blob/master/root/config.default/args.conf)*  
    This is where all youtube-dl execution arguments are, you can add or remove them however you like. If unmodified this file is automatically updated.

    **Unsupported arguments**
    * `--config-location`, hardcoded to `/config/args.conf`.
    * `--batch-file`, hardcoded to `/config/channels.txt`.
    * `--sponsorblock-remove`, currently unsupported because of a bug with ffmpeg.

    **Default arguments**
    * `--output "/downloads/%(uploader)s/%(title)s.%(ext)s"`, makes youtube-dl create separate folders for each channel and use the video title for the filename.
    * `--playlist-end 8`, makes youtube-dl only download the latest 8 videos. Be careful changing this! YouTube may feel like you are making too many requests and therefore might ip ban you.
    * `--match-filter "! is_live"`, makes youtube-dl ignore live streams.
    * `--windows-filenames`, restricts filenames to only Windows allowed characters.
    * `--no-write-playlist-metafiles`, makes youtube-dl not download channel posters.
    * `--no-progress`, removes a lot of unnecessary clutter from the logs.
    * `--merge-output-format mp4`, makes youtube-dl create mp4 files.
    * `--sub-langs all,-live_chat`, makes youtube-dl embed subtitles.
    * `--embed-metadata`, makes youtube-dl embed metadata like video description and chapters.
    * `--sponsorblock-mark all`, makes youtube-dl create chapters from [SponsorBlock](https://sponsor.ajay.app/) segments.

    yt-dlp configuration options documentation [here](https://github.com/yt-dlp/yt-dlp#usage-and-options).
