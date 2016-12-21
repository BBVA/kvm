# Docker KVM simple container

Generic container for launching a Virtual Machine inside a Docker container.

Features:
- Non libvirt dependant.
- It uses QEMU/KVM to launch the VM directly with PID 1.
- It attaches to the VM as many NICs as the docker container has.
- The VM gets the original container IPs.
- Uses macvtap tun devices for best network throughput.
- Outputs serial console to stdio, thus visible using `docker logs`

Partially based on [RancherVM](https://github.com/rancher/vm) project.

## Running:

* It is mandatory to define the **`AUTO_ATTACH`** variable:
  * If `AUTO_ATTACH` is set to `yes`, then all the container interfaces are attached to the VM. This is the typical use case.
  * If `AUTO_ATTACH` is set to `no`, a list of interfaces have to be declared in the `ATTACH_IFACES` variable. This is useful when launching the container with `net=host` flag, and only a subset of network interfaces need to be attached to the container.
* The VM image needs to be located in `/image/image` (no extension)
* Any additional parameters for QEMU/KVM can be specified as CMD argument when launching the container.
* When launching the VM, its serial port is accesible through `docker attach`


```
$ docker run                                     \
      --name kvm                                 \
      -td                                        \
      --privileged                               \
      -v /path_to/image_file.qcow2:/image/image  \
      -e AUTO_ATTACH=yes                         \
      bbvainnotech/kvm:latest
```

### Using more than one interface for the container (and the VM)

Before running the container, it is needed to create the networks:
```
$ docker network create --driver=bridge network1 --subnet=172.19.0.0/24
$ docker network create --driver=bridge network2 --subnet=172.19.2.0/24
```

Then, create the container and attach the network prior to start the container:
```
$ docker create                                 \
      --name container_name                     \
      -td                                       \
      --privileged                              \
      --network=network1                        \
      -v /path_to/image_file.qcow2:/image/image \
      -e AUTO_ATTACH=yes                        \
      bbvainnotech/kvm:latest

$ docker network connect network2 container_name
$ docker start container_name
```

### Using the dockerhost interfaces

```
$ docker run                                    \
      --name container_name                     \
      -net=host                                 \
      -td                                       \
      --privileged                              \
      -v /path_to/image_file.qcow2:/image/image \
      -e AUTO_ATTACH=yes                        \
      bbvainnotech/kvm:latest
```

### Debug mode

Passing `bash` keyword as argument to the container will launch a bash shell:

```
$ docker run                                    \
      -ti                                       \
      --privileged                              \
      -v /path_to/image_file.qcow2:/image/image \
      -e AUTO_ATTACH=yes                        \
      bbvainnotech/kvm:latest
```

## Environment variables

### SELECTED_NETWORK
If the container has more than one IP configured in a given interface, the user can select which one to use. The `SELECTED_NETWORK` environment variable is used to select that IP. This env variable must be in the form IP/MASK (e.g. 1.2.3.4/24).
If this env variable is not set, the IP to be given to the VM is the first in the list for that interface (default behaviour).

This usecase is found when working with Kubernetes: Kubernetes assigns two IP addresses to the docker eth0 interface.

### AUTO_ATTACH
When this env variable is set to `yes`, the entrypoint will scan all the vNICs present in the Docker container, and it will configure the hosted VM to get as many vNICs as the host container.

If this variable is set to `no`, only the interface names specified in the env variable `$ATTACH_IFACES` will be connected to the guest VM. Interfaces shall be separated by spaces (eg. `ATTACH_IFACES='eth0 eth2'`).

If `AUTO_ATTACH` is set to `no` and no interfaces are defined, the VM will start with no NICs (and thus no vtap devices connected to container interfaces).

### DNSMASQ_OPTS
This var controls the invocation parameters for `dnsmasq` daemon, used to give IP addresses to the VM. See [dnsmasq's man page](http://www.thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html) for info about available options.

It's specially useful the following options when debugging dnsmasq behaviour:

```
--log-facility=/var/log/dnsmasq.log --log-dhcp
```
### DEBUG
When this env varable is set to `yes`, the verbosity is increased.

### USE_NET_BRIDGES
This container uses macvlan devices to setup network connectivity. If an old kernel or limited host is used, it is possible to use linux bridge by setting the variable `USE_NET_BRIDGES` to `yes`.


## Notes / Troubleshooting

* Privileged mode (`--privileged`) is needed in order for KVM to access to macvtap devices [see issue #3](https://github.com/BBVA/kvm/issues/3) for further information.
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

# License
Licensed to the Apache Software Foundation (ASF) under one or more contributor license agreements. See the NOTICE file distributed with this work for additional information regarding copyright ownership. The ASF licenses this file to you under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

## Authors
* BBVA Innotech - Fernando Alvarez (@methadata)
* BBVA Innotech - Pancho Horrillo (@panchoh)
* BBVA Innotech - Rodrigo de la Fuente (@rodrigofuente)