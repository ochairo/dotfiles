#!/bin/bash -eu

#!/bin/bash -eu

question="Do you want to setup QEMU?"
responseRef="selectedValue"
option1="Yes"
option2="No"
handle_question "$question" "$responseRef" "$option1" "$option2"

echo "> Your selection: $selectedValue"
case "$selectedValue" in
"$option1")
  mkdir -p $PATH_ROOT/qemu/ubuntu && wget -P $PATH_ROOT/qemu/ubuntu https://releases.ubuntu.com/22.04.4/ubuntu-22.04.4-desktop-amd64.iso
  ;;
"$option2") ;;
esac
