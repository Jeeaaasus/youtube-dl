#!/usr/bin/with-contenv bash

echo "youtube-dl version: $(youtube-dl --version)"
echo "checking for updates..."
python3 -m pip --no-cache-dir --disable-pip-version-check install --upgrade youtube_dl > /dev/null

if grep -qe '--format ' "/config/args.conf"; then youtubedl_args_format=true; else youtubedl_args_format=false; fi
if grep -qe '--dateafter ' "/config/args.conf"; then youtubedl_args_dateafter=true; else youtubedl_args_dateafter=false; fi

if [ -f "/config/archive.txt" ]
then
  if ! [ -f "/config/dateafter.txt" ]
  then
    if ! $youtubedl_args_dateafter
    then
      echo "'--dateafter' not found in args.conf"
      echo "creating temporary 'dateafter.txt'."
      date --date "-1 days" "+%Y%m%d" > "/config/dateafter.txt"
    fi
  fi
else
  echo "'archive.txt' not found."
  echo "creating 'archive.txt'."
  touch "/config/archive.txt"
  if ! $youtubedl_args_dateafter
  then
    echo "'--dateafter' not found in args.conf"
    echo "creating temporary 'dateafter.txt'."
    date --date "-1 days" "+%Y%m%d" > "/config/dateafter.txt"
  fi
fi

youtubedl_last_run_date=$(date "+%s")

youtube-dl \
  $(if ! $youtubedl_args_format; then echo "--format "bestvideo[height<=$youtubedl_quality][vcodec=vp9][fps>30]+bestaudio[acodec!=opus] / bestvideo[height<=$youtubedl_quality][vcodec=vp9]+bestaudio[acodec!=opus] / bestvideo[height<=$youtubedl_quality]+bestaudio[acodec!=opus]" \\"; fi)
  $(if ! $youtubedl_args_dateafter; then echo "--dateafter "$(cat "/config/dateafter.txt")" \\"; fi)
  --config-location "/config/args.conf" \
  --download-archive "/config/archive.txt" \
  --batch-file "/config/channels.txt"

if [ $(( ($(date "+%s") - $youtubedl_last_run_date) / 60 )) -ge 2 ]
then
  echo "$(date "+%Y-%m-%d %H:%M:%S") - execution took $(( ($(date "+%s") - $youtubedl_last_run_date) / 60 )) minutes"
else
  echo "$(date "+%Y-%m-%d %H:%M:%S") - execution took $(( ($(date "+%s") - $youtubedl_last_run_date) )) seconds"
fi
echo "waiting $youtubedl_interval.."
sleep $youtubedl_interval
date "+%Y-%m-%d %H:%M:%S"
