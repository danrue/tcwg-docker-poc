#!/bin/sh

set -e
set -x

if [ -z "${arch}" ] || [ -z "${distro}" ] || [ -z "${url}" ]; then
    echo "Usage: arch=[amd64|arm64|armhf] distro=[xenial|trusty] url=[apt base url] $0"
    exit 1
fi

if [ "${distro}" = "trusty" ]; then
    export gnat="gnat"
else
    export gnat="gnat-5"
fi

(for i in ${distro} ${distro}-updates ${distro}-backports ${distro}-security; do
  for j in deb deb-src; do
    echo "$j $url $i main restricted universe multiverse";
  done;
  echo;
done) > /etc/apt/sources.list
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y
DEBIAN_FRONTEND=noninteractive apt-get install -y devscripts
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
 alien \
 autoconf \
 autogen \
 automake \
 bc \
 bison \
 build-essential \
 byacc \
 ccache \
 ccrypt \
 chrpath \
 clang \
 cmake \
 debhelper \
 dejagnu \
 dh-autoreconf \
 dh-translations \
 distro-info-data \
 emacs \
 fakeroot \
 flex \
 gawk \
 gdb \
 gdbserver \
 git \
 ${gnat} \
 groff \
 libexpat1-dev \
 liblzma-dev \
 libncurses5-dev \
 libpython2.7-dev \
 libreadline-dev \
 libssl-dev \
 libtcnative-1 \
 libtool \
 lzop \
 make \
 net-tools \
 netcat \
 ninja-build \
 openjdk-8-jdk \
 openssh-server \
 python-dev \
 pxz \
 qemu-user \
 rsync \
 subversion \
 sudo \
 tclsh \
 texinfo \
 texlive-fonts-recommended \
 texlive-latex-recommended \
 time \
 valgrind \
 vim \
 virtualenv \
 wget \
 xz-utils \
 zip \
 zlib1g-dev
apt-get clean
rm -rf \
 /var/lib/apt/lists/* \
 /tmp/* \
 /var/tmp/*

install -D -p -m0755 /usr/share/doc/git/contrib/workdir/git-new-workdir /usr/local/bin/git-new-workdir
sed -i -e 's:^session *required *pam_loginuid.so:# session required pam_loginuid.so:' /etc/pam.d/sshd
mkdir -p /var/run/sshd
sed -i -e "/.*MaxStartups.*/d" -e "/.*MaxSesssions.*/d" /etc/ssh/sshd_config
echo "MaxStartups 256" >> /etc/ssh/sshd_config
echo "MaxSessions 256" >> /etc/ssh/sshd_config
