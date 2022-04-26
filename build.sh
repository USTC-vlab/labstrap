#!/bin/sh

if test "$#" -ne 1; then
  echo "Usage: $0 <image.tar.zst>" >&2
  exit 1
fi

NAME=labstrap
ROOTFS=/opt/vlab/rootfs

docker build -t "$NAME" .
docker run --rm -it --name="$NAME" --privileged \
  -v "$PWD":/srv:ro \
  -v "$ROOTFS":/target \
  -v "$1":/input.tar.zst:ro \
  "$NAME"
