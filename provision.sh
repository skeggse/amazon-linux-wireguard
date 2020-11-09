#!/bin/bash -e

sudo amazon-linux-extras install kernel-ng
sudo yum update -y
sudo yum groupinstall -y "Development Tools"
sudo yum install -y elfutils-libelf-devel kernel-devel pkg-config

# Since we haven't restarted, we have to override the kernel version used.
export KERNELRELEASE="$(ls /lib/modules | grep -vFx "$(uname -r)")"
if [[ "$KERNELRELEASE" == *$'\n'* ]]; then
  echo 'unable to identify appropriate kernel release' >&2
  exit 1
fi

(
  git clone https://git.zx2c4.com/wireguard-linux-compat &&
  make -C wireguard-linux-compat/src "-j$(nproc)" &&
  sudo --preserve-env=KERNELRELEASE make -C wireguard-linux-compat/src install
) &
(
  git clone https://git.zx2c4.com/wireguard-tools &&
  make -C wireguard-tools/src "-j$(nproc)" &&
  sudo --preserve-env=KERNELRELEASE make -C wireguard-tools/src install
) &
wait %1; wait %2

sudo tee /etc/modules-load.d/wireguard.conf <<< wireguard
