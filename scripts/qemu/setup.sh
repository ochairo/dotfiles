#!/bin/bash -eu

yes="Yes"
no="No"
handle_question response "Do you want to setup QEMU?" "$yes" "$no"

echo "> Your selection: $response"
case "$response" in
"$yes")
  mkdir -p $PATH_ROOT/qemu/ubuntu && wget -P $PATH_ROOT/qemu/ubuntu https://releases.ubuntu.com/22.04.4/ubuntu-22.04.4-desktop-amd64.iso
  ;;
"$no") ;;
esac

exit 0
