#!/usr/bin/with-contenv bash

apk update > /dev/null && apk upgrade > /dev/null
python3 -m pip --no-cache-dir --disable-pip-version-check install --upgrade git+https://github.com/blackjack4494/yt-dlc > /dev/null

sleep 3h
