#!/bin/bash -eu

if [ $(uname) != "Darwin" ]; then
  handle_error 1 "This is only for macOS"
fi

yes="Yes"
no="No"
handle_question response "Do you want to continue?" "$yes" "$no"

echo "> Your selection: $response"
case "$response" in
"$yes")
  if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  ;;
"$no")
  echo ""
  echo "${COLOR_BLUE}"
  echo "________________________________________________________________________________"
  echo "                              PROCESS CANCELED!"
  echo "${COLOR_DEFAULT}"
  exit 1
  ;;
esac
