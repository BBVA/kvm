# Docker KVM simple container

Generic container for launching a Virtual Machine inside a Docker container.

Features:
- It uses QEMU/KVM to launch the VM directly with PID 1.
- Non libvirt dependant.
- It attaches to the VM as many NICs as the docker container has.
- The VM gets the original container IPs. The container gets non-conflicting IPs

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
      kvm:latest                                        \
      bbvainnotech/kvm:latest
```

## Notes

* Privileged mode is needed in order for the container to access to KVM layer.

## ToDo
* Migrate to a lightweight container base
* Review and document $KVM_ARGS
* Add VNC capability for video console (using noVNC or socat to a unix socket provided by KVM)

## Authors
* BBVA Innotech - Fernando Alvarez (@methadata)
* BBVA Innotech - Pancho Horrillo (@panchoh)
* BBVA Innotech - Rodrigo de la Fuente (@rodrigofuente)