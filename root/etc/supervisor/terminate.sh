#!/bin/bash

sleep 2s
kill -3 $(cat "/etc/supervisor/supervisord.pid")
