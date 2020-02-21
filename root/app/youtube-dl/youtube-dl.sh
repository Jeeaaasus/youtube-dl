#!/usr/bin/with-contenv bash

python3 -m pip --no-cache-dir --disable-pip-version-check install --upgrade youtube_dl > /dev/null
echo "youtube-dl version: $(youtube-dl --version)"

if [ -f "/config/archive.txt" ]
then
  if [ ! -f "/config/dateafter.txt" ]
  then
    echo "'dateafter.txt' not found."
    echo "creating 'dateafter.txt'."
    date --date "-1 days" "+%Y%m%d" > "/config/dateafter.txt"
  fi
else
  echo "'archive.txt' not found."
  echo "creating 'archive.txt'."
  touch "/config/archive.txt"
  echo "creating 'dateafter.txt'."
  date --date "-1 days" "+%Y%m%d" > "/config/dateafter.txt"
fi

YOUTUBEDL_LAST_RUN_DATE=$(date "+%s")

youtube-dl \
  --format "bestvideo[height<=$youtubedl_quality][vcodec=vp9][fps>30]+bestaudio[acodec!=opus] / bestvideo[height<=$youtubedl_quality][vcodec=vp9]+bestaudio[acodec!=opus] / bestvideo[height<=$youtubedl_quality]+bestaudio[acodec!=opus]" \
  --config-location "/config/args.conf" \
  --download-archive "/config/archive.txt" \
  --dateafter "$(cat "/config/dateafter.txt")" \
  --batch-file "/config/channels.txt"

if [ $(( ($(date "+%s") - $YOUTUBEDL_LAST_RUN_DATE) / 60 )) -ge 2 ]
then
  echo "$(date "+%Y-%m-%d %H:%M:%S") - execution took $(( ($(date "+%s") - $YOUTUBEDL_LAST_RUN_DATE) / 60 )) minutes"
else
  echo "$(date "+%Y-%m-%d %H:%M:%S") - execution took $(( ($(date "+%s") - $YOUTUBEDL_LAST_RUN_DATE) )) seconds"
fi
echo "waiting $youtubedl_interval.."
sleep $youtubedl_interval
date "+%Y-%m-%d %H:%M:%S"
