#!/usr/bin/with-contenv bash

youtubedl_binary="youtube-dl"

if grep -qe '--format ' "/config/args.conf"; then youtubedl_args_format=true; else youtubedl_args_format=false; fi
if grep -qe '--download-archive ' "/config/args.conf"; then youtubedl_args_downloadarchive=true; else youtubedl_args_downloadarchive=false; fi

if ! [ -f "/config/archive.txt" ]
then
  if ! $youtubedl_args_downloadarchive
  then
    echo "'--download-archive' not defined in args."
    echo "creating and using 'archive.txt'."
    touch "/config/archive.txt"
  fi
fi

exec=$youtubedl_binary
if ! $youtubedl_args_downloadarchive; then exec+=" --download-archive "/config/archive.txt""; fi
if [ -f "/config/dateafter.txt" ]; then exec+=" --dateafter $(cat /config/dateafter.txt)"; fi
exec+=" --config-location "/config/args.conf""
exec+=" --batch-file "/config/channels.txt""

while ! [ -f /usr/bin/$youtubedl_binary ]; do sleep 1s; done
youtubedl_version=$($youtubedl_binary --version)
youtubedl_last_run_date=$(date "+%s")
sed -Ei 's!  *$!!; s!//*$!!; s!(youtube.*(channel|user|c))/([^/]+$)!\1/\3/videos!i' /config/channels.txt
if ! $youtubedl_args_format
then
  $exec --format "bestvideo[height<=$youtubedl_quality][vcodec=vp9][fps>30]+bestaudio[acodec!=opus] / bestvideo[height<=$youtubedl_quality][vcodec=vp9]+bestaudio[acodec!=opus] / bestvideo[height<=$youtubedl_quality]+bestaudio[acodec!=opus] / best"
else
  $exec
fi

if [ $(( ($(date "+%s") - $youtubedl_last_run_date) / 60 )) -ge 2 ]
then
  echo "$(date "+%Y-%m-%d %H:%M:%S") - execution took $(( ($(date "+%s") - $youtubedl_last_run_date) / 60 )) minutes"
else
  echo "$(date "+%Y-%m-%d %H:%M:%S") - execution took $(( ($(date "+%s") - $youtubedl_last_run_date) )) seconds"
fi

echo "youtube-dl version: $youtubedl_version"
echo "waiting $youtubedl_interval.."
sleep $youtubedl_interval
date "+%Y-%m-%d %H:%M:%S"
