#!/usr/bin/with-contenv bash

python3 -m pip --no-cache-dir --disable-pip-version-check install --upgrade youtube_dl > /dev/null

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

youtubedl_exec="youtube-dl"
if ! $youtubedl_args_downloadarchive; then youtubedl_exec+=" --download-archive "/config/archive.txt""; fi
if ! $youtubedl_args_dateafter; then youtubedl_exec+=" --dateafter $(cat /config/dateafter.txt)"; fi
youtubedl_exec+=" --config-location "/config/args.conf""
youtubedl_exec+=" --batch-file "/config/channels.txt""

youtubedl_last_run_date=$(date "+%s")

if ! $youtubedl_args_format
then
  $youtubedl_exec --format "bestvideo[height<=$youtubedl_quality][vcodec=vp9][fps>30]+bestaudio[acodec!=opus] / bestvideo[height<=$youtubedl_quality][vcodec=vp9]+bestaudio[acodec!=opus] / bestvideo[height<=$youtubedl_quality]+bestaudio[acodec!=opus]"
else
  $youtubedl_exec
fi

if [ $(( ($(date "+%s") - $youtubedl_last_run_date) / 60 )) -ge 2 ]
then
  echo "$(date "+%Y-%m-%d %H:%M:%S") - execution took $(( ($(date "+%s") - $youtubedl_last_run_date) / 60 )) minutes"
else
  echo "$(date "+%Y-%m-%d %H:%M:%S") - execution took $(( ($(date "+%s") - $youtubedl_last_run_date) )) seconds"
fi

echo "youtube-dl version: $(youtube-dl --version)"
echo "waiting $youtubedl_interval.."
sleep $youtubedl_interval
date "+%Y-%m-%d %H:%M:%S"
