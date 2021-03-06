#!/bin/bash

set -e
set -x

if groups tcwg-buildslave 2>/dev/null | grep -q docker; then
    # If tcwg-buildslave user is present, use it to start the container
    # to have [sudo] log record of container startups.
    DOCKER="sudo -u tcwg-buildslave docker"
elif groups 2>/dev/null | grep -q docker; then
    # Run docker straight up if $USER is in "docker" group.
    DOCKER="docker"
else
    # Fallback to sudo otherwise.
    DOCKER="sudo docker"
fi

image=linaro/ci-dev--ubuntu:tcwg
name=$USER-tcwg
# Bind-mount $HOME and /home/tcwg-buildslave (to get access to
# /home/tcwg-buildslave/snapshots-ref/)
mounts="-v $HOME:$HOME -v /home/tcwg-buildslave:/home/tcwg-buildslave:ro"
# Use at most half of all available RAM.
memlimit=$(($(free -g | awk '/^Mem/ { print $2 }') / 2))G
# IPC_LOCK is required for some implementations of ssh-agent (e.g., MATE's).
# SYS_PTRACE is required for debugger work.
caps="--cap-add=IPC_LOCK --cap-add=SYS_PTRACE"
# Fetch ssh public key from LDAP.
pubkey="$(/etc/ssh/ssh_keys.py $USER 2>/dev/null || sss_ssh_authorizedkeys $USER 2>/dev/null)"

$DOCKER pull $image
$DOCKER run --name=$name -dt -p 22 $mounts --memory=$memlimit --pids-limit=5000 $caps $image "$(getent passwd $USER)" "$(id -gn)" "$pubkey"

port=$($DOCKER port $name 22 | cut -d: -f 2)

set +x
echo "NOTE: the warning about kernel not supporting swap memory limit is expected"
echo "To connect to container run \"ssh -p $port localhost\""
echo "To stop container run \"docker stop $name\""
echo "To restart container run \"docker start $name\""
echo "To remove container run \"docker rm -fv $name\""
echo "See https://collaborate.linaro.org/display/TCWG/How+to+setup+personal+dev+environment+using+docker for additional info"
