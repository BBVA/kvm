# Docker KVM simple container

Generic container for launching a Virtual Machine inside a Docker container.

Features:
- It uses QEMU/KVM to launch the VM directly with PID 1.
- Non libvirt dependant.
- It attaches to the VM as many NICs as the docker container has.
- The VM gets the original container IPs. The container gets non-conflicting IPs
- Uses macvtap tun devices for best network throughput

Partially based on [RancherVM](https://github.com/rancher/vm) project.

## Running:

* It is mandatory to define the **`AUTO_ATTACH`** variable:
  * If `AUTO_ATTACH` is set to `yes`, then all the container interfaces are attached to the VM. This is the typical use case.
  * If `AUTO_ATTACH` is set to `no`, a list of interfaces have to be declared in the `ATTACH_IFACES` variable. This is useful when launching the container with `net=host` flag, and only a subset of network interfaces need to be attached to the container.
* The VM image needs to be located in `/image/image.qcow2`
* Any additional parameter for QEMU/KVM can be specified as CMD argument when launching the container.
* When launching the VM, its serial port is accesible through `docker attach`


```
$ docker run                                            \
      --name kvm                                        \
      -td                                               \
      --privileged                                      \
      -v /path_to/image_file.qcow2:/image/image.qcow2   \
      -v /lib/modules:/lib/modules                      \
      -v /var/run:/var/run                              \
      -e AUTO_ATTACH=yes                                \
      bbvainnotech/kvm:latest
```

### Using more than one interface for the container (and the VM)

Before running the container, it is needed to create the networks first:
```
$ docker network create --driver=bridge network1 --subnet=172.19.0.0/24
$ docker network create --driver=bridge network2 --subnet=172.19.2.0/24
```

Then, create the container and attach the network prior to start the container:
```
$ docker create                                         \
      --name container_name                             \
      -td                                               \
      --privileged                                      \
      --network=network1                                \
      -v /path_to/image_file.qcow2:/image/image.qcow2   \
      -v /lib/modules:/lib/modules                      \
      -v /var/run:/var/run                              \
      -e AUTO_ATTACH=yes                                \
      bbvainnotech/kvm:latest

$ docker network connect network2 container_name
$ docker start container_name
```

### Using the dockerhost interfaces

```
$ docker run                                            \
      --name container_name                             \
      -net=host                                         \
      -td                                               \
      --privileged                                      \
      -v /path_to/image_file.qcow2:/image/image.qcow2   \
      -v /lib/modules:/lib/modules                      \
      -v /var/run:/var/run                              \
      -e AUTO_ATTACH=yes                                \
      bbvainnotech/kvm:latest
```

### Debug mode

Passing `bash` keyword as argument to the container will launch a bash shell:

```
$ docker run                                            \
      --name container_name                             \
      -net=host                                         \
      -td                                               \
      --privileged                                      \
      -v /path_to/image_file.qcow2:/image/image.qcow2   \
      -v /lib/modules:/lib/modules                      \
      -v /var/run:/var/run                              \
      -e AUTO_ATTACH=yes                                \
      bbvainnotech/kvm:latest
```

## Environment variables

### SELECTED_NETWORK
If the container has more than one IP configured in a given interface, the user can select which one to use. The `SELECTED_NETWORK` environment variable is used to select that IP. This env variable must be in the form IP/MASK (e.g. 1.2.3.4/24).
If this env variable is not set, the IP to be given to the VM is the first in the list for that interface (default behaviour).

This usecase is found when working with Kubernetes: Kubernetes assigns two IP addresses to the docker eth0 interface.

### AUTO_ATTACH
When this env variable is set to 'yes', the entrypoint will scan all the vNICs present in the Docker container, and it will configure the hosted VM to get as many vNICs as the host container.

If this variable is set to "no", only the interface name specified in the env variable $ATTACH_IFS will be connected to the guest VM.

## Notes / Troubleshooting

* Privileged mode is needed in order for the container to access to KVM layer.
* If you get the following error from KVM:
  ```
  qemu-kvm: -netdev tap,id=net0,vhost=on,fd=3: vhost-net requested but could not be initialized
  qemu-kvm: -netdev tap,id=net0,vhost=on,fd=3: Device 'tap' could not be initialized
  ```

  you will need to load the `vhost-net` kernel module in your dockerhost (as root) prior to launch this container:

  ```
  # modprobe vhost-net
  ```

  This is probed to be needed when using RancherOS.

## ToDo
* Migrate to a lightweight container base
* Add VNC capability for video console (using noVNC or socat to a unix socket provided by KVM)
* Try to use macvlan L3 device to connect host and guest machines for dnsmasq service

## Authors
* BBVA Innotech - Fernando Alvarez (@methadata)
* BBVA Innotech - Pancho Horrillo (@panchoh)
* BBVA Innotech - Rodrigo de la Fuente (@rodrigofuente)