# Docker KVM simple container

Generic container for launching a Virtual Machine inside a Docker container.

It uses QEMU/KVM to launch the VM directly with PID 1, thus it doesn't depend on libvirt package.

## Build instructions:

* `docker build -t kvm:0.3 .`
* `docker tag kvm:0.3 kvm:latest`

## Running:

* It is mandatory to define the **`AUTO_ATTACH`** variable:
  * If `AUTO_ATTACH` is set to `yes`, then all the container interfaces are attached to the VM. This is the typical use case.
  * If `AUTO_ATTACH` is set to `no`, a list of interfaces have to be declared in the `ATTACH_IFACES` variable. This is useful when launching the container with `net=host` flag, and only a subset of network interfaces need to be attached to the container.
* The VM image needs to be located in `/image/image.qcow2`


```
$ docker run                                            \
      --name kvm                                        \
      -td                                               \
      --privileged                                      \
      -v /path_to/image_file.qcow2:/image/image.qcow2   \
      -v /lib/modules:/lib/modules                      \
      -v /var/run:/var/run                              \
      -e AUTO_ATTACH=yes                                \
      kvm:latest
```

### Using more than one interface for the container (and the VM)

Before running the container, it is needed to create the networks first:
```
$ docker network create --driver=bridge network1 --subnet=172.19.0.0/24
$ docker network create --driver=bridge network2 --subnet=172.19.1.0/24
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
      kvm:latest

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
      kvm:latest
```

### Debug mode

Passing `bash` as argument to the container will launch a bash shell:

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
      bash
```

## Notes

* Privileged mode is needed in order for the container to access to KVM layer.

## ToDo

* Review and document $KVM_ARGS

## Authors
* BBVA Innotech - Fernando Alvarez (@methadata)
* BBVA Innotech - Pancho Horrillo (@panchoh)
* BBVA Innotech - Rodrigo de la Fuente (@rodrigofuente)