#!/usr/bin/with-contenv bash

if $youtubedl_debug; then youtubedl_args_verbose=true; else youtubedl_args_verbose=false; fi
if grep -qiEe '--format ' "/config/args.conf"; then youtubedl_args_format=true; else youtubedl_args_format=false; fi
if grep -qiEe '--download-archive ' "/config/args.conf"; then youtubedl_args_download_archive=true; else youtubedl_args_download_archive=false; fi

youtubedl_binary="yt-dlp"
exec=$youtubedl_binary
if $youtubedl_args_verbose; then exec+=" --verbose"; fi
if ! $youtubedl_args_download_archive; then exec+=" --download-archive /config/archive.txt"; fi
if $youtubedl_cookies; then exec+=" --cookies /config/cookies.txt"; fi
exec+=" --config-location /config/args.conf"
exec+=" --batch-file -"; (cat '/config/channels.txt'; echo '') > '/app/urls'
if $youtubedl_watchlater; then echo 'https://www.youtube.com/playlist?list=WL' >> '/app/urls'; fi

while ! [ -f "$(which $youtubedl_binary)" ]; do sleep 10s; done
youtubedl_version=$($youtubedl_binary --version)
youtubedl_last_run_time=$(date "+%s")
echo ""
echo "$(date "+%Y-%m-%d %H:%M:%S") - starting execution"

if $youtubedl_lockfile; then touch '/downloads/youtubedl-running' && rm -f '/downloads/youtubedl-completed'; fi

while [ -f '/app/urls' ]
do
  extra_params=''
  if grep -qiPe '\|' '/app/urls'
  then
    grep -m 1 -niPe '\|' '/app/urls' > '/app/url'
    sed -i -E "$(grep -oiPe '^[0-9]+' /app/url)d" '/app/urls'
    extra_params=" $(grep -oiPe '.*\| *\K.*' '/app/url')"
    sed -i -E 's!([0-9]*:)?(.*?)(\|.*)!\2!i' '/app/url'
  else
    mv '/app/urls' '/app/url'
  fi
  while ! [ -f "$(which $youtubedl_binary)" ]; do sleep 10s; done
  if $youtubedl_args_format; then cat '/app/url' | eval "$exec$extra_params"; else cat '/app/url' | eval "$exec --format '$(cat '/config.default/format')'$extra_params"; fi
done

if $youtubedl_lockfile; then touch '/downloads/youtubedl-completed' && rm -f '/downloads/youtubedl-running'; fi

echo ""
if [ $(( ($(date "+%s") - $youtubedl_last_run_time) / 60 )) -ge 2 ]
then
  echo "$(date "+%Y-%m-%d %H:%M:%S") - execution took $(( ($(date "+%s") - $youtubedl_last_run_time) / 60 )) minutes"
else
  echo "$(date "+%Y-%m-%d %H:%M:%S") - execution took $(( ($(date "+%s") - $youtubedl_last_run_time) )) seconds"
fi
echo "$youtubedl_binary version: $youtubedl_version"
echo "waiting $youtubedl_interval.."
sleep $youtubedl_interval

