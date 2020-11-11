#!/usr/bin/with-contenv bash

youtubedl_binary="youtube-dlc"

if grep -qe '--format ' "/config/args.conf"; then youtubedl_args_format=true; else youtubedl_args_format=false; fi
if grep -qe '--dateafter ' "/config/args.conf"; then youtubedl_args_dateafter=true; else youtubedl_args_dateafter=false; fi
if grep -qe '--download-archive ' "/config/args.conf"; then youtubedl_args_downloadarchive=true; else youtubedl_args_downloadarchive=false; fi

if [ -f "/config/archive.txt" ]
then
  if ! [ -f "/config/dateafter.txt" ]
  then
    if ! $youtubedl_args_dateafter
    then
      echo "'--dateafter' not found in args.conf"
      echo "creating 'dateafter.txt'."
      date --date "-1 days" "+%Y%m%d" > "/config/dateafter.txt"
    fi
  fi
else
  if ! $youtubedl_args_downloadarchive
  then
    echo "'--download-archive' not defined in args."
    echo "creating and using 'archive.txt'."
    touch "/config/archive.txt"
    if ! $youtubedl_args_dateafter
    then
      echo "'--dateafter' not found in args.conf"
      echo "creating 'dateafter.txt'."
      date --date "-1 days" "+%Y%m%d" > "/config/dateafter.txt"
    fi
  fi
fi

exec=$youtubedl_binary
if ! $youtubedl_args_downloadarchive; then exec+=" --download-archive "/config/archive.txt""; fi
if ! $youtubedl_args_dateafter; then exec+=" --dateafter $(cat /config/dateafter.txt)"; fi
exec+=" --config-location "/config/args.conf""
exec+=" --batch-file "/config/channels.txt""

youtubedl_last_run_date=$(date "+%s")

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

echo "youtube-dl version: $($youtubedl_binary --version)"
echo "waiting $youtubedl_interval.."
sleep $youtubedl_interval
date "+%Y-%m-%d %H:%M:%S"
