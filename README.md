# youtube-dl
Automated youtube-dl Docker image for downloading YouTube subscriptions

Docker hub page: [here](https://hub.docker.com/r/jeeaaasustest/youtube-dl)

youtube-dl documentation: [here](http://ytdl-org.github.io/youtube-dl/documentation.html)

# Usage

```
docker run -d \
    --name=youtube-dl \
    --mount 'type=volume,source=youtube-dl_data,target=/config' \
    --mount 'type=bind,source=<path>,target=/downloads' \
    jeeaaasustest/youtube-dl
```
**Explanation**
* `--mount 'type=volume,source=youtube-dl_data,target=/config'`
  
  This makes a volume where your config files are saved, named: `youtube-dl_data`.
 
* `--mount 'type=bind,source=<path>,target=/downloads'`
  
  Here you have to replace `<path>`.
  
  This is where on your Docker host you want youtube-dl to download videos.

  Remember that if the directory that does not yet exist on the Docker host, Docker does not automatically create it for you and the command will fail.

**Configure youtube-dl**

Once the container is running you need to edit the file `/config/channels.txt`.

This is where you input all the channels you would like to download.

```
# One per line
# Name
https://www.youtube.com/user/examplefakeurl
# Another one
https://www.youtube.com/channel/anotherexamplefakeurl
```

**Optional Env Parameters**

* `-e PGID=<GroupID>` - If you need to specify GroupID for file permission reasons
* `-e PUID=<UserID>` - If you need to specify UserID for file permission reasons
* `-e TZ=<TimeZone>` - Specify TimeZone if you want the log timestamps to be correct

e.g. `-e TZ=Europe/London`
* `-e youtubedl_interval` - If you want to change the default download interval (3 hours)

e.g. `-e youtubedl_interval=1h` or `-e youtubedl_interval=2d`
* `-e youtubedl_quality` - If you want to change the default download resolution (1080p)

e.g. `-e youtubedl_quality=1440` or `-e youtubedl_quality=2160`
