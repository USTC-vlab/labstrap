#!/bin/sh

if test "$#" -ne 1; then
  echo "Usage: $0 <image.tar.gz>" >&2
  exit 1
fi

NAME=labstrap
docker build -t "$NAME" .
docker run --rm -it --name="$NAME" --privileged \
  -v "$PWD":/srv:ro \
  -v /opt/vlab/rootfs:/target \
  -v "$1":/input.tar.gz:ro \
  "$NAME"
