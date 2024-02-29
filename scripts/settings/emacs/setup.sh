#!/bin/bash -eu

yes="Yes"
no="No"
response=""
handle_question "response" "Do you want to setup Emacs?" "$yes" "$no"

echo "> Your selection: $response"
case "$response" in
"$yes")
  if ! brew list --formula | grep -q "emacs"; then
    brew install emacs
    brew install emacs-dracula

    git clone --depth 1 https://github.com/doomemacs/doomemacs $HOME/.config/emacs
    $HOME/.config/emacs/bin/doom install
  fi
  ;;
"$no") ;;
esac

exit 0
