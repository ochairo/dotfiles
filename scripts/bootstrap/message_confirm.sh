#!/bin/bash -eu

if [ $(uname) != "Darwin" ]; then
  handle_error 1 "This is only for macOS"
fi

yes="Yes"
no="No"
handle_question "Do you want to continue?" "$yes" "$no"

echo "> Your selection: $selected_option"
case "$selected_option" in
"$yes") ;;
"$no")
  echo ""
  echo "${BLUE}"
  echo "________________________________________________________________________________"
  echo "                              PROCESS CANCELED!"
  echo "${NC}"
  exit 1
  ;;
esac

exit 0
