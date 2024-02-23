#!/bin/bash -eu

echo "brew.sh"

brew install bash

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

exit 0
