#!/usr/bin/with-contenv bash

if $youtubedl_debug; then youtubedl_args_verbose=true; else youtubedl_args_verbose=false; fi
if grep -qPe '^(--output |-o ).*\$\(' '/config/args.conf'; then youtubedl_args_output_expand=true; else youtubedl_args_output_expand=false; fi
if grep -qPe '^(--format |-f )' '/config/args.conf'; then youtubedl_args_format=true; else youtubedl_args_format=false; fi
if grep -qPe '^--download-archive ' '/config/args.conf'; then youtubedl_args_download_archive=true; else youtubedl_args_download_archive=false; fi

youtubedl_binary='yt-dlp'
exec="$youtubedl_binary"
exec+=" --config-location '/config/args.conf'"
exec+=" --batch-file '/tmp/urls'"; (cat '/config/channels.txt'; echo '') > '/tmp/urls.temp'
if $youtubedl_args_verbose; then exec+=" --verbose"; fi
if $youtubedl_args_output_expand; then exec+=" $(grep -Pe '^(--output |-o ).*\$\(' '/config/args.conf')"; fi
if [ -f '/config/cookies.txt' ]; then exec+=" --cookies '/config/cookies.txt'"; fi
if $youtubedl_subscriptions; then echo 'https://www.youtube.com/feed/channels' >> '/tmp/urls.temp'; fi
if $youtubedl_watchlater; then echo ":ytwatchlater | --playlist-end '-1' --no-playlist-reverse" >> '/tmp/urls.temp'; fi
if ! $youtubedl_args_format; then exec+=" --format '$(cat '/config.default/format')'"; fi
if ! $youtubedl_args_download_archive; then exec+=" --download-archive '/config/archive.txt'"; fi

if [ -f '/config/pre-execution.sh' ]
then
  echo '[pre-execution] running pre-execution script...'
  bash '/config/pre-execution.sh'
  echo '[pre-execution] finished pre-execution script.'
fi

while [ -f '/tmp/updater-running' ]; do sleep 1s; done
youtubedl_version="$($youtubedl_binary --version)"
youtubedl_last_run_time="$(date '+%s')"
echo ''; echo "$(date '+%Y-%m-%d %H:%M:%S') - starting execution"

if $youtubedl_lockfile; then touch '/downloads/.youtubedl-running' && rm -f '/downloads/.youtubedl-completed'; fi

while [ -f '/tmp/urls.temp' ]
do
  extra_url_args=''
  if grep -qPe '\|' '/tmp/urls.temp'
  then
    grep -m 1 -nPe '\|' '/tmp/urls.temp' > '/tmp/urls'
    sed -i -E "$(grep -oPe '^[0-9]+' /tmp/urls)d" '/tmp/urls.temp'
    extra_url_args="$(grep -oPe '.*?\|\K.*' '/tmp/urls')"
    sed -i -E 's!([0-9]*:)?(.*?)(\|.*)!\2!' '/tmp/urls'
  else
    mv '/tmp/urls.temp' '/tmp/urls'
  fi
  eval "$exec $extra_url_args"
  rm -f '/tmp/urls'
done

if $youtubedl_lockfile; then touch '/downloads/.youtubedl-completed' && rm -f '/downloads/.youtubedl-running'; fi

if [ $(( ($(date '+%s') - $youtubedl_last_run_time) / 60 )) -ge 2 ]
then
  echo ''; echo "$(date '+%Y-%m-%d %H:%M:%S') - execution took $(( ($(date '+%s') - $youtubedl_last_run_time) / 60 )) minutes"
else
  echo ''; echo "$(date '+%Y-%m-%d %H:%M:%S') - execution took $(( ($(date '+%s') - $youtubedl_last_run_time) )) seconds"
fi

if [ -f '/config/post-execution.sh' ]
then
  echo '[post-execution] running post-execution script...'
  bash '/config/post-execution.sh'
  echo '[post-execution] finished post-execution script.'
fi

echo "$youtubedl_binary version: $youtubedl_version"

if [ "$youtubedl_interval" != 'false' ]
then
  echo "waiting $youtubedl_interval.."
  sleep $youtubedl_interval
else
  echo "youtubedl_interval is set to 'false', container will now exit."
  s6-svscanctl -t '/var/run/s6/services'
fi
