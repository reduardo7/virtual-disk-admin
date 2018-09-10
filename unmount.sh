#!/usr/bin/env bash

###############################################################################
# Pre-Init

export current_dir="$(cd "$(dirname "$0")" ; pwd)"
export script_dir="$(readlink "$0")"
export script_dir="$(cd "$([ -z "${script_dir}" ] && echo "${current_dir}" || dirname "${script_dir}")" ; pwd)"

set -x
cd "${script_dir}"
set +x

###############################################################################
# Config

. ./.env

if mount | grep -q ${disk}; then
  ( set -x
    #udisksctl umount -b /dev/loop0
    sudo umount "${dest_mount}"
  )
fi

echo Finish
sleep 5
