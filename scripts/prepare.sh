#!/bin/bash -eu

if [ $(uname) != "Darwin" ]; then
  handle_error 1 "This is only for macOS"
fi

question="Do you want to continue?"
responseRef="selectedValue"
option1="Yes"
option2="No"
handle_question "$question" "$responseRef" "$option1" "$option2"

echo "> Your selection: $selectedValue"
case "$selectedValue" in
"$option1")
  if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  ;;
"$option2")
  echo ""
  echo "${COLOR_BLUE}"
  echo "________________________________________________________________________________"
  echo "                              PROCESS CANCELED!"
  echo "${COLOR_DEFAULT}"
  exit 1
  ;;
esac
