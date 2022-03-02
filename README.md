# labstrap

Bootstrap VM images for Vlab

## Steps

Build Docker image:

```shell
docker build -t labstrap .
```

Grab a base image from <http://download.proxmox.com/images/system/> or a mirror site at your option.

Run the build script in Docker, supplying the image and a rootfs directory:

```shell
docker run --rm -it --name=labstrap --privileged \
  -v "$PWD":/srv:ro \
  -v /path/to/rootfs:/target \
  -v /path/to/image.tar.gz:/input.tar.gz:ro \
  labstrap
```

Pack the generated image:

```shell
sudo tar zcf output.tar.gz -C /path/to/rootfs .
```
