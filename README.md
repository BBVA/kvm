# Docker KVM simple container

## Build instructions:

* `docker build -t docker-kvm:0.2 .`

## Notes

* Privileged mode is needed in order for the container to access to KVM layer.
* Net=host mode in container is needed to use docker host networking

## Authors
* BBVA Innotech - Fernando Alvarez (@methadata)
* BBVA Innotech - Pancho Horrillo (@panchoh)
* BBVA Innotech - Rodrigo de la Fuente (@rodrigofuente)