#!/usr/bin/with-contenv bash

if $youtubedl_debug; then youtubedl_args_verbose=true; else youtubedl_args_verbose=false; fi
if grep -qPe '(--format |-f )' '/config/args.conf'; then youtubedl_args_format=true; else youtubedl_args_format=false; fi
if grep -qPe '--download-archive ' '/config/args.conf'; then youtubedl_args_download_archive=true; else youtubedl_args_download_archive=false; fi

youtubedl_binary='yt-dlp'
exec="$youtubedl_binary"
exec+=" --config-location '/config/args.conf'"
exec+=" --batch-file '/app/urls'"; (cat '/config/channels.txt'; echo '') > '/app/urls.temp'
if $youtubedl_args_verbose; then exec+=" --verbose"; fi
if $youtubedl_cookies; then exec+=" --cookies '/config/cookies.txt'"; fi
if $youtubedl_watchlater; then echo 'https://www.youtube.com/playlist?list=WL | --no-playlist-reverse' >> '/app/urls.temp'; fi
if ! $youtubedl_args_format; then exec+=" --format '$(cat '/config.default/format')'"; fi
if ! $youtubedl_args_download_archive; then exec+=" --download-archive '/config/archive.txt'"; fi

while [ -f '/app/updater-running' ]; do sleep 1s; done
youtubedl_version="$($youtubedl_binary --version)"
youtubedl_last_run_time="$(date '+%s')"
echo ''; echo "$(date '+%Y-%m-%d %H:%M:%S') - starting execution"

if $youtubedl_lockfile; then touch '/downloads/youtubedl-running' && rm -f '/downloads/youtubedl-completed'; fi

while [ -f '/app/urls.temp' ]
do
  extra_url_args=''
  if grep -qPe '\|' '/app/urls.temp'
  then
    grep -m 1 -nPe '\|' '/app/urls.temp' > '/app/urls'
    sed -i -E "$(grep -oPe '^[0-9]+' /app/urls)d" '/app/urls.temp'
    extra_url_args="$(grep -oPe '.*\| *\K.*' '/app/urls')"
    sed -i -E 's!([0-9]*:)?(.*?)(\|.*)!\2!' '/app/urls'
  else
    mv '/app/urls.temp' '/app/urls'
  fi
  eval "$exec $extra_url_args"
done

if $youtubedl_lockfile; then touch '/downloads/youtubedl-completed' && rm -f '/downloads/youtubedl-running'; fi

if [ $(( ($(date '+%s') - $youtubedl_last_run_time) / 60 )) -ge 2 ]
then
  echo ''; echo "$(date '+%Y-%m-%d %H:%M:%S') - execution took $(( ($(date '+%s') - $youtubedl_last_run_time) / 60 )) minutes"
else
  echo ''; echo "$(date '+%Y-%m-%d %H:%M:%S') - execution took $(( ($(date '+%s') - $youtubedl_last_run_time) )) seconds"
fi
echo "$youtubedl_binary version: $youtubedl_version"
echo "waiting $youtubedl_interval.."
sleep $youtubedl_interval
