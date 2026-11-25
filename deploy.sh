#!/usr/bin/env bash
# Deploy repository configurations for the invoking desktop user.
set -euo pipefail

usage() {
  echo 'Usage: deploy.sh [--help]'
  # shellcheck disable=SC2016
  echo 'Deploys hypr/bindings.lua to ${XDG_CONFIG_HOME:-$HOME/.config}/hypr/bindings.lua.'
  # shellcheck disable=SC2016
  echo 'Deploys Nushell support to ${XDG_CONFIG_HOME:-$HOME/.config}/nvim/lua/plugins/nushell.lua.'
  # shellcheck disable=SC2016
  echo 'Deploys shfmt configuration to ${XDG_CONFIG_HOME:-$HOME/.config}/nvim/lua/plugins/formatting.lua.'
  echo 'Adds four-space Neovim indentation defaults while preserving existing options.lua settings.'
  echo 'Deploys PowerShell comment settings so % is not continued as a comment.'
  # shellcheck disable=SC2016
  echo 'Deploys herdr-app/themes/nier.json to ${HERDR_APP_HOME:-$HOME/.config/herdr-app}/themes/nier.json.'
  echo 'Overwrites the existing file after saving a dated backup; run without sudo.'
}
die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

if [[ ${1:-} == --help || ${1:-} == -h ]]; then
  usage
  exit 0
fi
(($# == 0)) || {
  usage >&2
  exit 1
}
[[ $EUID != 0 && -z ${SUDO_USER-} ]] || die 'Run as the intended desktop user without sudo.'

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
config_root=${XDG_CONFIG_HOME:-$HOME/.config}
[[ $config_root == /* ]] || die 'The configuration directory must be an absolute path.'
herdr_home=${HERDR_APP_HOME:-$HOME/.config/herdr-app}
[[ $herdr_home == /* ]] || die 'The Herdr configuration directory must be an absolute path.'

for source_file in "$repo_dir/hypr/bindings.lua" "$repo_dir/herdr-app/themes/nier.json" \
  "$repo_dir/omarchy-nvim/lua/plugins/nushell.lua" \
  "$repo_dir/omarchy-nvim/lua/plugins/formatting.lua" \
  "$repo_dir/omarchy-nvim/after/ftplugin/ps1.lua" \
  "$repo_dir/omarchy-nvim/lua/config/nier-indentation.lua"; do
  [[ -f $source_file ]] || die "Missing configuration: $source_file"
done
command -v luac >/dev/null || die 'Lua syntax validation requires luac (the lua package).'
command -v jq >/dev/null || die 'Theme JSON validation requires jq.'
luac -p "$repo_dir/hypr/bindings.lua"
luac -p "$repo_dir/omarchy-nvim/lua/plugins/nushell.lua"
luac -p "$repo_dir/omarchy-nvim/lua/plugins/formatting.lua"
luac -p "$repo_dir/omarchy-nvim/after/ftplugin/ps1.lua"
luac -p "$repo_dir/omarchy-nvim/lua/config/nier-indentation.lua"
jq -e 'type == "object" and (.ansi | length == 16) and
  ([.background, .foreground, .selection, .cursor, .ansi[], .colors[]] |
    all(type == "string" and test("^#[0-9a-fA-F]{6}$")))' \
  "$repo_dir/herdr-app/themes/nier.json" >/dev/null

stage=''
options_stage=''
trap '[[ -z $stage ]] || rm -f -- "$stage"; [[ -z $options_stage ]] || rm -f -- "$options_stage"' EXIT
deploy_file() {
  local source_file=$1 target=$2 label=$3 target_dir backup
  target_dir=$(dirname -- "$target")
  if [[ -e $target || -L $target ]]; then
    [[ -f $target ]] || die "Not a regular configuration file: $target"
    if cmp -s -- "$source_file" "$target"; then
      printf '%s is already current.\n' "$label"
      return
    fi
  fi

  mkdir -p -- "$target_dir"
  stage=$(mktemp "$target_dir/.nier-deploy.XXXXXX")
  install -m644 -- "$source_file" "$stage"
  if [[ -e $target ]]; then
    backup=$target.nier-backup.$(date -u +%Y%m%dT%H%M%S%NZ).$$
    cp -pL -- "$target" "$backup"
    printf 'Previous %s: %s\n' "$label" "$backup"
  fi
  mv -fT -- "$stage" "$target"
  stage=''
  printf 'Installed %s in %s\n' "$label" "$target"
}

deploy_file "$repo_dir/hypr/bindings.lua" "$config_root/hypr/bindings.lua" 'Hyprland bindings'
deploy_file "$repo_dir/herdr-app/themes/nier.json" "$herdr_home/themes/nier.json" 'Herdr nier theme'
deploy_file "$repo_dir/omarchy-nvim/lua/plugins/nushell.lua" "$config_root/nvim/lua/plugins/nushell.lua" 'Neovim Nushell support'
deploy_file "$repo_dir/omarchy-nvim/lua/plugins/formatting.lua" "$config_root/nvim/lua/plugins/formatting.lua" 'Neovim formatting configuration'
deploy_file "$repo_dir/omarchy-nvim/after/ftplugin/ps1.lua" "$config_root/nvim/after/ftplugin/ps1.lua" 'PowerShell comment settings'
deploy_file "$repo_dir/omarchy-nvim/lua/config/nier-indentation.lua" "$config_root/nvim/lua/config/nier-indentation.lua" 'Neovim indentation defaults'

# LazyVim loads options.lua automatically. Keep its contents and add our module
# once, rather than replacing the user's unrelated editor settings.
options_file=$config_root/nvim/lua/config/options.lua
options_require='require("config.nier-indentation")'
if [[ -e $options_file || -L $options_file ]]; then
  [[ -f $options_file ]] || die "Not a regular configuration file: $options_file"
  luac -p "$options_file"
fi
if [[ -f $options_file ]] && grep -Fxq "$options_require" "$options_file"; then
  printf 'Neovim indentation loader is already current.\n'
else
  options_stage=$(mktemp "$config_root/nvim/lua/config/.nier-options.XXXXXX")
  if [[ -f $options_file ]]; then cat -- "$options_file" > "$options_stage"; fi
  printf '\n-- Nier default indentation.\n%s\n' "$options_require" >> "$options_stage"
  luac -p "$options_stage"
  deploy_file "$options_stage" "$options_file" 'Neovim options'
fi
