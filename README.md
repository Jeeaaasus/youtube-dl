# Jeeaaasus - youtube-dl
[![Docker Automated build](https://img.shields.io/docker/cloud/automated/jeeaaasustest/youtube-dl?style=flat&logo=docker&label=build)](https://github.com/Jeeaaasus/youtube-dl/actions/workflows/push-release-version-image.yml/)
[![Image Size](https://img.shields.io/docker/image-size/jeeaaasustest/youtube-dl/latest?style=flat&logo=docker)](https://hub.docker.com/r/jeeaaasustest/youtube-dl/)
[![Docker Pulls](https://img.shields.io/docker/pulls/jeeaaasustest/youtube-dl?style=flat&logo=docker)](https://hub.docker.com/r/jeeaaasustest/youtube-dl/)
[![Docker Stars](https://img.shields.io/docker/stars/jeeaaasustest/youtube-dl?style=flat&logo=docker)](https://hub.docker.com/r/jeeaaasustest/youtube-dl/)

**Automated yt-dlp Docker image for downloading YouTube subscriptions**

Docker hub page [here](https://hub.docker.com/r/jeeaaasustest/youtube-dl).  
yt-dlp documentation [here](https://github.com/yt-dlp/yt-dlp).

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

# Quick Start
"I want to download all my subscriptions and my watch later playlist in 4k"
```
docker run -d \
    --name youtube-dl \
    -v youtube-dl_data:/config \
    -v <PATH>:/downloads \
    -e youtubedl_cookies=true \
    -e youtubedl_subscriptions=true \
    -e youtubedl_watchlater=true \
    -e youtubedl_quality=2160 \
    jeeaaasustest/youtube-dl
```
Then add your cookies as explained in the [Configure youtube-dl](https://github.com/Jeeaaasus/youtube-dl#configure-youtube-dl) section below.

<br>

"I want to download only certain channels"
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
| `UMASK` | (`022`) | If you need to specify umask for file permission reasons.
| `youtubedl_debug` | `true` (`false`) | Used to enable verbose mode.
| `youtubedl_lockfile` | `true` (`false`) | Used to enable youtubedl-running, youtubedl-completed files in downloads directory. Useful for external scripts.
| `youtubedl_webui` | `true` (`false`) | If you would like to beta test the unfinished web-ui feature, might be broken!
| `youtubedl_webuiport` | (`8080`) | If you need to change the web-ui port.
| `youtubedl_cookies` | `true` (`false`) | Used to pass cookies for authentication.
| `youtubedl_subscriptions` | `true` (`false`) | If you want to download all your subscriptions. Authentication is required.
| `youtubedl_watchlater` | `true` (`false`) | If you want to download your Watch Later playlist. Authentication is required.
| `youtubedl_interval` | `1h` (`3h`) `12h` `3d` | If you want to change the default download interval.<br>1 hour, (3 hours), 12 hours, 3 days.
| `youtubedl_quality` | `720` (`1080`) `1440` `2160` | If you want to change the default download resolution.<br>720p, (1080p), 1440p, 4k.

# Image Tags
* **`unstable`**
    * Automatically built when a new GitHub commit is pushed.
    * Container updates to the newest yt-dlp commit while running.
* **`latest`**
    * Automatically built when a new version of yt-dlp is released.
    * Container updates to the latest version of yt-dlp while running.
* **`v<VERSION>`**
    * Automatically built when a new version of yt-dlp is released.
    * Does not update.

# Configure youtube-dl
* **Authentication**

    Cookies are used to authenticate your YouTube account which is necessary if you want to download members only videos you have access to or your own private videos and playlists like Watch Later.

    In order to pass your cookies to youtube-dl, you first need a browser extension to extract your cookies, for example, [Get cookies.txt](https://chrome.google.com/webstore/detail/get-cookiestxt/bgaddhkoddajcdgocldbbfleckgcbcid/) (Chrome) or [cookies.txt](https://addons.mozilla.org/en-US/firefox/addon/cookies-txt/) (Firefox).  
    Once you've extracted your cookies, place the `cookies.txt` file inside your Docker volume named `youtube-dl_data` or the folder `/config/` inside your container. One way of doing this would be using the command: `docker cp ./cookies.txt youtube-dl:/config/`.  
    Then use `-e youtubedl_cookies=true` in your Docker run command when creating your container.

* **channels.txt**

    File location: `/config/channels.txt`.  
    This is where you input all the YouTube channels (or any valid URL) you want to have videos downloaded from.
    ```
    # One per line
    # Name
    https://www.youtube.com/user/channel_username
    # Another one
    https://www.youtube.com/channel/UC0vaVaSyV14uvJ4hEZDOl0Q
    ```
    You can also specify additional args to be used per URL. This is done by adding args after the URL separated by the ` | ` character.  
    These will override any conflicting args from `args.conf`.
    ```
    # Examples
    # Output to 'named' folder instead of channel name
    https://www.youtube.com/channel/UC0vaVaSyV14uvJ4hEZDOl0Q | --output '/downloads/named/%(title)s.%(ext)s'

    # Use regex to only download videos matching words
    https://www.youtube.com/channel/UC0vaVaSyV14uvJ4hEZDOl0Q | --no-match-filter --match-filter '!is_live & title~=(?i)words.*to.*match'

    # Use regex to only download videos not matching words
    https://www.youtube.com/channel/UC0vaVaSyV14uvJ4hEZDOl0Q | --no-match-filter --match-filter '!is_live & title!~=(?i)words.*to.*exclude'

    # Download a whole playlist, also disable reverse download order
    https://www.youtube.com/playlist?list=D9sLB5EVaCarZ7lbpQfGch3jJuYCRt | --playlist-end '-1' --no-playlist-reverse
    ```
    Adding with Docker:  
    `docker exec youtube-dl bash -c 'echo "# NAME" >> ./channels.txt'`  
    `docker exec youtube-dl bash -c 'echo "URL" >> ./channels.txt'`

    It is recommended to use the UCID-based URLs, they look like: `/channel/UC0vaVaSyV14uvJ4hEZDOl0Q`, as the other ones might get changed.
    You find the UCID-based URL by going to a video and clicking on the uploader.

* **archive.txt**

    File location: `/config/archive.txt`.&nbsp;&nbsp;&nbsp;*delete to make youtube-dl forget downloaded videos*  
    This is where youtube-dl stores all previously downloaded video IDs.

* **args.conf**

    File location: `/config/args.conf`.&nbsp;&nbsp;&nbsp;*delete and restart container to restore [default arguments](https://github.com/Jeeaaasus/youtube-dl/blob/master/root/config.default/args.conf)*  
    This is where all youtube-dl execution arguments are, you can add or remove them however you like. If unmodified this file is automatically updated.

    **Unsupported arguments**
    * `--config-location`, hardcoded to `/config/args.conf`.
    * `--batch-file`, hardcoded to `/config/channels.txt`.

    **Default arguments**
    * `--output '/downloads/%(uploader)s/%(title)s.%(ext)s'`, makes youtube-dl create separate folders for each channel and use the video title for the filename.
    * `--playlist-end '16'`, makes youtube-dl only download the latest 16 videos, per channel.
    * `--playlist-reverse`, makes youtube-dl download channel videos in the order they were uploaded.
    * `--match-filter '!is_live'`, makes youtube-dl ignore live streams.
    * `--windows-filenames`, restricts filenames to only Windows allowed characters.
    * `--ignore-no-formats-error`, keeps youtube-dl from crashing when trying to download a video premiere.
    * `--no-progress`, removes a lot of unnecessary clutter from the logs.
    * `--sleep-requests '1'`, makes youtube-dl wait 1 second between requests. Be careful changing this! YouTube might feel you are making too many requests and ip ban you.
    * `--merge-output-format 'mp4'`, makes youtube-dl create mp4 video files.
    * `--sub-langs 'all,-live_chat'`, makes youtube-dl embed subtitles.
    * `--embed-metadata`, makes youtube-dl embed metadata like video description and chapters.
    * `--sponsorblock-mark 'all'`, makes youtube-dl create chapters from [SponsorBlock](https://sponsor.ajay.app/) segments.

    yt-dlp configuration options documentation [here](https://github.com/yt-dlp/yt-dlp#usage-and-options).
