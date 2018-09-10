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

###############################################################################
# Init Setup

set -e

( set -x
  [ -d "${dest_root}" ] || mkdir "${dest_root}"
  [ -d "${dest_mount}" ] || mkdir "${dest_mount}"
  [ -f "${disk}" ] || mkfs.ext4 "${disk}" 100G
)

###############################################################################
# Mount

if ! mount | grep -q ${disk}; then
  ( set -x
    #udisksctl loop-setup -r -f ${disk}
    #udisksctl mount -b /dev/loop0
    sudo mount -o loop ${disk} "${dest_mount}"
    sudo chown $(id -u):$(id -g) "${dest_mount}"
  )
fi

###############################################################################
# Utils

_log() {
  echo "# $*"
}

_warn() {
  _log "Warning! $*" >&2
}

###############################################################################
# Links

ln -vsf "${script_dir}/unmount.sh" "${dest_mount}/unmount.sh"

_lnk() {
  local dir="$1" # Relative to "dest_root"

  local from="${dest_virtual}/${dir}"
  local to="${dest_root}/${dir}"

  _log "Linking '${dir}'..."

  if [ ! -d "${from}" ] || [ ! -f "${from}" ]; then
    _warn "'${from}' not exists!"
    return 1
  elif [ -d "${to}" ]; then
    _warn "'${to}' is a directory!"
  else
    ln -vs "${from}" "${to}"
  fi
}

_lnk .local/share/android/sdk

echo Finish
sleep 5
