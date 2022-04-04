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

## Debugging locally

### Systemd-nspawn

Notes:

- It's recommended to test container image in a VM, as the configuration of systemd-nspawn may need to change system network configuration.
- Host and guest both need systemd-network to manage their network.

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

5. Clear iptables settings in **guest** (to test VNC)

    ```console
    $ sudo iptables -D INPUT ! -s 172.31.0.2/32 ! -i lo -p tcp -m tcp --dport 5900 -j DROP
    ```

    Then you can connect to guest with `vncviewer` on host.
