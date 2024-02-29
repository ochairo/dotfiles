#!/bin/bash -eu

# Clear the terminal ----------------------------------------------------------
clear

# VARIABLES -------------------------------------------------------------------
export BLUE=$(tput setaf 4)
export GRAY=$(tput setaf 8)
export GREEN=$(tput setaf 2)
export RED=$(tput setaf 1)
export NC=$(tput sgr0)
export REPO_DIR=$(pwd)

# Load handlers ---------------------------------------------------------------
source $REPO_DIR/scripts/handlers/error.sh
source $REPO_DIR/scripts/handlers/question.sh

# Welcome message -----------------------------------------------------
source $REPO_DIR/scripts/messages/welcome.sh

# Prepare ---------------------------------------------------------------------
source $REPO_DIR/scripts/prepare.sh

# Setup -----------------------------------------------------------------------
source $REPO_DIR/scripts/setup.sh

# Cleanup ---------------------------------------------------------------------
source $REPO_DIR/scripts/cleanup.sh

# Complete message -----------------------------------------------------------
source $REPO_DIR/scripts/messages/complete.sh

exit 0
