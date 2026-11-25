#!/usr/bin/env bash
# Enable the signed Nier repository, install tools, and apply desktop/shell setup.
set -euo pipefail

# Maintain installation targets here. Use unqualified names for omarchy pkg add.
# onedrive-abraunegg is installed as a dependency of onedrive-quickshell.
readonly -a pacman_packages=(
    blesh
    bind
    herdr-app
    neovim-nightly
    nier-desktop
    nier-airplay-plugin
    nier-monitor-arrangement
    nier-workspaces-dropdown
    onedrive-quickshell
    podman
    podman-compose
    podman-desktop
    powershell
    remote-desktop-manager
    shellcheck
    shfmt
    teams-for-linux
    nufmt
    nushell
)

readonly default_url='http://nier-pacman-updater.netbird.cloud:8080'
readonly fingerprint='D08DCD6B97C9885E62968C927DEEC45C73A8FB34'
usage() {
    cat <<EOF
Usage: ${0##*/} [REPOSITORY_URL]

Without a URL, prompts in an interactive terminal (Enter accepts the default).
With noninteractive input, uses $default_url.
Downloads and verifies the public key and database, trusts the pinned key,
and enables [nier] with package and database signatures required.
Performs a full system upgrade and installs the packages in pacman_packages
using omarchy pkg add (pacman on plain Arch), including nier-desktop itself.
OneDrive's client is installed
as a dependency of onedrive-quickshell. The list also includes Nushell.
Removes cliamp and the Basecamp, Google Contacts/Maps/Messages/Photos, HEY,
WhatsApp, and X web-app shortcuts. Other applications are retained.
Then runs nier shell apply --prompt.
Run as the intended desktop user without sudo.
EOF
}
die() {
    printf 'Error: %s\n' "$*" >&2
    exit 1
}
if [[ ${1:-} == --help || ${1:-} == -h ]]; then
    usage
    exit 0
fi
(($# <= 1)) || {
    usage >&2
    exit 1
}
[[ -z ${SUDO_USER-} && $EUID != 0 ]] || die 'Run as the intended desktop user without sudo; repository changes request sudo separately.'
repo_url=${1:-}
if [[ -z $repo_url && -t 0 ]]; then
    read -r -p "Repository URL [$default_url]: " repo_url || true
fi
repo_url=${repo_url:-$default_url}
while [[ $repo_url == */ ]]; do repo_url=${repo_url%/}; done
[[ $repo_url =~ ^https?://[^/[:space:]?#]+(/[^[:space:]?#]*)?$ ]] || die 'Provide an HTTP(S) base URL without whitespace, a query, or a fragment.'
[[ $repo_url != *\$* && $repo_url != *\\* ]] || die 'Repository URLs cannot contain dollar signs or backslashes.'

for tool in curl gpg pacman pacman-key pacman-conf awk grep mktemp readlink cmp install cp mv; do
    command -v "$tool" >/dev/null || die "Required command is missing: $tool"
done
if ((EUID != 0)); then command -v sudo >/dev/null || die 'Run as root or install sudo.'; fi
as_root() {
    if ((EUID == 0)); then "$@"; else sudo -- "$@"; fi
}

temp_dir=$(mktemp -d)
root_stage=''
cleanup() {
    rm -rf -- "$temp_dir"
    if [[ -n $root_stage ]]; then as_root rm -f -- "$root_stage"; fi
}
trap cleanup EXIT
mkdir -m 700 "$temp_dir/gnupg"
download() {
    curl --fail --silent --show-error --location --proto '=http,https' \
        --proto-redir '=http,https' --connect-timeout 10 --max-time 90 \
        --max-filesize 10485760 "$repo_url/$1" --output "$temp_dir/$1"
}

printf 'Checking repository at %s\n' "$repo_url"
download nier-repo.asc
key_info=$(gpg --homedir "$temp_dir/gnupg" --batch --with-colons --show-keys "$temp_dir/nier-repo.asc")
primary_count=$(awk -F: '$1 == "pub" {n++} END {print n+0}' <<<"$key_info")
actual=$(awk -F: '$1 == "fpr" {print $10; exit}' <<<"$key_info")
[[ $primary_count == 1 && $actual == "$fingerprint" ]] || die "Repository signing key does not match pinned fingerprint $fingerprint."
gpg --homedir "$temp_dir/gnupg" --batch --import "$temp_dir/nier-repo.asc"
download nier.db
download nier.db.sig
gpg --homedir "$temp_dir/gnupg" --batch --verify "$temp_dir/nier.db.sig" "$temp_dir/nier.db"

# Preserve unrelated configuration, replacing any existing [nier] section.
# Resolve symlinks so an existing pacman.conf symlink is preserved.
config=$(readlink -f /etc/pacman.conf)
[[ -f $config ]] || die '/etc/pacman.conf is missing.'
awk '
  /^[[:space:]]*\[[^]]+\][[:space:]]*(#.*)?$/ {
    skip = ($0 ~ /^[[:space:]]*\[nier\][[:space:]]*(#.*)?$/)
  }
  !skip {lines[++n] = $0}
  END {
    while (n > 0 && lines[n] ~ /^[[:space:]]*$/) n--
    for (i=1; i<=n; i++) print lines[i]
  }
' "$config" >"$temp_dir/pacman.conf"
printf '\n[nier]\nSigLevel = Required DatabaseRequired\nServer = %s\n' "$repo_url" >>"$temp_dir/pacman.conf"
repos=$(pacman-conf --config "$temp_dir/pacman.conf" --repo-list)
[[ $(awk '$0 == "nier" {n++} END {print n+0}' <<<"$repos") == 1 ]] || die 'Another included configuration defines [nier]; consolidate it before running setup.'
configured_url=$(pacman-conf --config "$temp_dir/pacman.conf" --repo nier Server)
[[ $configured_url == "$repo_url" ]] || die 'Generated pacman configuration did not resolve to the requested URL.'

# All downloads and validation succeed before requesting sudo or changing trust.
as_root pacman-key --init
as_root pacman-key --add "$temp_dir/nier-repo.asc"
as_root pacman-key --lsign-key "$fingerprint"
if cmp -s "$temp_dir/pacman.conf" "$config"; then
    printf 'Repository configuration is already current.\n'
else
    backup="$config.nier-backup.$(date +%Y%m%d%H%M%S).$$"
    as_root cp -a -- "$config" "$backup"
    root_stage=$(as_root mktemp "$config.nier.XXXXXX")
    as_root install -o root -g root -m 0644 "$temp_dir/pacman.conf" "$root_stage"
    as_root mv -f -- "$root_stage" "$config"
    root_stage=''
    printf 'Updated %s; backup: %s\n' "$config" "$backup"
fi
# Install before applying user configuration. The nightly package provides and
# conflicts with neovim, so pacman removes stable in this same transaction.
# Never remove stable separately: a failed nightly install must not leave it absent.
if command -v omarchy >/dev/null; then
    # SSH commands may not read Bash startup files. Initialize Omarchy's own
    # runtime root/PATH before its protected helpers validate the environment.
    if [[ -r /usr/share/omarchy/default/bash/env-bootstrap ]]; then
        # shellcheck source=/dev/null
        source /usr/share/omarchy/default/bash/env-bootstrap
    fi
    # Omarchy 4.5 guards direct full upgrades: use its snapshots, migrations,
    # update lock and restart handling before installing additional packages.
    omarchy update -y
    omarchy pkg add "${pacman_packages[@]}"
else
    as_root pacman -Syu --needed "${pacman_packages[@]}"
fi
# Query first so a broken package database cannot be mistaken for an absent app.
installed_packages=$(pacman -Qq)
if grep -Fxq cliamp <<<"$installed_packages"; then
    command -v omarchy-pkg-drop >/dev/null || die 'Missing omarchy-pkg-drop; cannot remove cliamp.'
    omarchy-pkg-drop cliamp
fi
for webapp in Basecamp 'Google Contacts' 'Google Maps' 'Google Messages' 'Google Photos' HEY WhatsApp X; do
    launcher="$HOME/.local/share/applications/$webapp.desktop"
    # Only remove Omarchy web-app entries, not unrelated launchers with this name.
    if [[ -f $launcher ]] && grep -qE '^Exec=(omarchy-launch-webapp|omarchy-webapp-handler)' "$launcher"; then
        command -v omarchy-webapp-remove >/dev/null || die 'Missing omarchy-webapp-remove; cannot remove selected web apps.'
        OMARCHY_REMOVE_NOTIFY=false omarchy-webapp-remove "$webapp"
    fi
done
nier shell apply --prompt
printf '\nEnabled [nier] at %s and installed the %s selected packages and their dependencies.\n' "$repo_url" "${#pacman_packages[@]}"
