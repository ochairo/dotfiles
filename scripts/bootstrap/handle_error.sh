#!/bin/bash -eu

handle_error() {
  local exit_code=$1
  local error_message=$2

  echo "${RED}"
  echo "────────────────────────────────── ERROR ───────────────────────────────────────"

  if [[ "$exit_code" =~ ^[0-9]+$ ]]; then
    echo "Number: ${exit_code}"
  fi

  if [ -n "$error_message" ]; then
    echo "Message: ${error_message}"
  elif [ -n "$exit_code" ]; then
    echo "Message: ${exit_code}"
  fi

  echo "________________________________________________________________________________"
  echo "                                PROCESS END"
  echo "${NC}"

  exit "${exit_code:-1}"
}
