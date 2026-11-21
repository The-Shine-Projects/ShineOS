#!/bin/sh

if [ "$(id -u)" -ne 0 ]; then
  echo "Please run this script as root." >&2
  exit 1
fi

lb clean
lb config
lb build
