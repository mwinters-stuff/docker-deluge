#!/bin/sh
VERSION="$(curl -s https://api.github.com/repos/linuxserver/docker-deluge/releases/latest | grep -o '"tag_name": ".*"' | sed 's/"//g' | sed 's/tag_name: //g')"
echo "${VERSION}"
