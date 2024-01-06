# labstrap (Debian 12)

Bootstrap VM images for Vlab

## Pre-built images

The [Auto builds](https://github.com/USTC-vlab/labstrap/releases/tag/auto-build-debian12) release holds VM images built on GitHub Actions.

## Building the image locally

Build Docker image:

```shell
docker build -t labstrap:debian12 .
```

Grab a base image from <http://download.proxmox.com/images/system/> or a mirror site at your option.

Run the build script in Docker, supplying the image and a rootfs directory:

```shell
docker run --rm -it --name=labstrap --privileged \
  -v "$PWD":/srv:ro \
  -v /path/to/rootfs:/target \
  -v /path/to/image.tar.zst:/input.tar.zst:ro \
  labstrap:debian12
```

Pack the generated image:

```shell
sudo tar cf output.tar.zst --zstd -C /path/to/rootfs .
```

## Debugging locally

### Systemd-nspawn

Notes:

- It's recommended to test container image in a VM, as the configuration of systemd-nspawn may need to change system network configuration.
- Host and guest both need systemd-network to manage their network.
- You MUST NOT use ["host networking"](https://wiki.archlinux.org/title/systemd-nspawn#Use_host_networking), otherwise bind() to `/tmp/.X11-unix/X0` will throw an error (if you are using X in host).

Following insts are tested in Debian 11.

1. Set iptables to legacy

    Systemd-nspawn in Debian 11 still requires `iptables-legacy`.

    ```console
    # update-alternatives --set iptables /usr/sbin/iptables-legacy
    ```

2. Set NAT with iptables. Assuming that your network interface is `ens33`.

    ```console
    # iptables -t nat -A POSTROUTING -o ens33 -j MASQUERADE
    # iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    # iptables -A FORWARD -i ve-+ -o ens33 -j ACCEPT
    ```

3. Prepare Vlab software

    At least the following files and folders should be copied to local:

    ```
    /opt/vlab/applications/
    /opt/vlab/bin/
    /opt/vlab/path.sh
    /opt/vlab/share/
    ```

    `scp` does not perserve POSIX attrs by default, so `rsync` is more recommended:

    ```
    $ rsync -avH vlab-container:/opt/vlab/applications .
    $ rsync -avH vlab-container:/opt/vlab/bin .
    $ rsync -avH vlab-container:/opt/vlab/path.sh .
    $ rsync -avH vlab-container:/opt/vlab/share .
    ```

4. Boot container

    ```console
    # systemd-nspawn -D /path/to/rootfs -M ubuntu -n --boot --resolv-conf=copy-host -p 5900:5900 --bind=/path/to/opt/vlab:/opt/vlab
    ```

#### Configuring container network without systemd-networkd on host

(If you just wanna run labstrap on your Linux host without a VM)

Following insts are tested in Arch Linux (2022/07).

1. Start container with `systemd-nspawn -D /path/to/rootfs -M vlab-ubuntu -n -U --boot --bind=/path/to/opt/vlab:/opt/vlab`
2. Set a static IP for `ve-vlab-ubuntu` in **host**: `ip address add 192.168.233.1/24 dev ve-vlab-ubuntu`
3. Activate `ve-vlab-ubuntu` in **host**: `ip link set ve-vlab-ubuntu up`
4. Configure network in **container**. Add file `/etc/systemd/network/20-wired.network` with:

    ```
    [Match]
    Name=host0

    [Network]
    Address=192.168.233.2/24
    Gateway=192.168.233.1
    DNS=8.8.8.8
    ```

    And restart `systemd-networkd.service`.

5. Configure NAT in **host**.

    ```
    iptables -t nat -A POSTROUTING -s 192.168.233.0/24 -j MASQUERADE
    iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -i ve-vlab-ubuntu -j ACCEPT
    ```

6. Connect to container with VNC: `vncviewer 192.168.233.2`
