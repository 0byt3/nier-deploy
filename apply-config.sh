#!/usr/bin/env bash
# Deploy the bundled Neovim configuration for the current user.
set -euo pipefail
usage() {
  echo 'Usage: apply-config.sh [--help]'
  # shellcheck disable=SC2016
  echo 'Deploys nvim/ to ${XDG_CONFIG_HOME:-$HOME/.config}/nvim.'
  echo 'Omarchy integration is backed up as nvim.omarchy; other configs get dated backups.'
}
die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
if [[ ${1:-} == --help || ${1:-} == -h ]]; then usage; exit 0; fi
(( $# == 0 )) || { usage >&2; exit 1; }
[[ -z ${SUDO_USER-} ]] || die 'Run as the intended desktop user without sudo.'
source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/nvim" && pwd -P)
config_root=${XDG_CONFIG_HOME:-$HOME/.config}
[[ $config_root == /* ]] || die 'The configuration directory must be an absolute path.'
mkdir -p -- "$config_root"
config_root=$(cd -- "$config_root" && pwd -P)
target=$config_root/nvim
[[ -f $source_dir/init.lua ]] || die 'Bundled nvim/init.lua is missing.'
# Do not replace the checkout itself if it lives at the deployment destination.
if [[ -e $target && $target -ef $source_dir ]]; then
  echo 'Neovim configuration already uses the bundled directory.'
  exit 0
fi
if [[ -d $target ]] && diff -qr -- "$source_dir" "$target" >/dev/null; then
  echo 'Neovim configuration is already current.'
  exit 0
fi
backup=''
if [[ -e $target || -L $target ]]; then
  [[ -d $target ]] || die "Not a Neovim configuration directory: $target"
  if [[ -f $target/lua/plugins/omarchy-theme-hotreload.lua ]] ||
     grep -rEq 'omarchy/current/theme|omarchy.*neovim\.lua' "$target/init.lua" "$target/lua" 2>/dev/null; then
    backup=$config_root/nvim.omarchy
    [[ ! -e $backup && ! -L $backup ]] || die "Backup already exists: $backup; move it before replacing another Omarchy configuration."
  else
    backup=$config_root/nvim.nier-backup.$(date -u +%Y%m%dT%H%M%SZ).$$
    [[ ! -e $backup && ! -L $backup ]] || die "Backup already exists: $backup"
  fi
fi
# Stage a complete copy on the same filesystem before moving the old config.
stage=$(mktemp -d "$config_root/.nier-nvim.XXXXXX")
trap 'rm -rf -- "$stage"' EXIT
cp -a -- "$source_dir" "$stage/nvim"
if [[ -n $backup ]]; then mv -T -- "$target" "$backup"; fi
if ! mv -T -- "$stage/nvim" "$target"; then
  if [[ -n $backup ]]; then
    mv -T -- "$backup" "$target" || die "Deployment and rollback failed; restore $backup manually."
  fi
  die 'Deployment failed; previous configuration restored.'
fi
if [[ -n $backup ]]; then printf 'Previous configuration: %s\n' "$backup"; fi
printf 'Installed Neovim configuration in %s\n' "$target"
