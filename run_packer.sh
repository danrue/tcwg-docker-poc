#!/bin/sh

#distros="xenial trusty"
#arch="amd64 arm64 armhf"
distros="xenial"
arch="amd64"
case "${arch}" in
   "amd64")
      url="http://archive.ubuntu.com/ubuntu/"
      ;;
   "arm64")
      url="http://ports.ubuntu.com/ubuntu-ports"
      ;;
esac

for distro in $distros; do
	packer build -var arch=${arch} -var distro=$distro -var url=$url packer.json
done
