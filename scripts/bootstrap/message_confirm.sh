#!/bin/bash -eu

if [ $(uname) != "Darwin" ]; then
  handle_error 1 "This is only for macOS"
fi

yes="Yes"
no="No"
handle_question response "Do you want to continue?" "$yes" "$no"

echo "> Your selection: $response"
case "$response" in
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
