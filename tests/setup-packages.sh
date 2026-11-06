#!/usr/bin/env bash
# Exercise setup's post-repository actions without changing the host.
set -euo pipefail
project=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT
sed -n '/^# Install before applying user configuration/,$p' "$project/setup.sh" > "$stage/actions.sh"
[[ -s $stage/actions.sh ]]
cat > "$stage/runner.sh" <<'RUNNER'
#!/usr/bin/env bash
set -euo pipefail
repo_url=http://fixture.invalid
die() { echo "$*" >&2; exit 1; }
command() {
  if [[ $* == '-v omarchy' && $OMARCHY_TEST_PRESENT == 0 ]]; then return 1; fi
  builtin command "$@"
}
as_root() {
  case "$*" in
    'pacman -S --needed nier/neovim-nightly nier/powershell extra/nushell'|'pacman -Syu --needed nier/neovim-nightly nier/powershell extra/nushell')
      if [[ $OMARCHY_TEST_PRESENT == 1 ]]; then [[ $2 == -S ]]; else [[ $2 == -Syu ]]; fi
      printf '%s\n' "$*" >> "$ACTION_LOG"
      return "$PACKAGE_RESULT" ;;
    *) echo "Unexpected privileged command: $*" >&2; exit 1 ;;
  esac
}
omarchy() {
  [[ $* == 'update -y' ]] || exit 1
  echo 'omarchy update -y' >> "$ACTION_LOG"
  return "$UPDATE_RESULT"
}
omarchy-pkg-drop() {
  [[ $# == 1 && $1 == cliamp ]] || exit 1
  printf 'omarchy-pkg-drop %s\n' "$1" >> "$ACTION_LOG"
  if [[ $REMOVE_RESULT == 0 ]]; then rm "$HOME/cliamp-installed"; fi
  return "$REMOVE_RESULT"
}
pacman() {
  [[ $* == -Qq ]] || exit 1
  [[ $QUERY_RESULT == 0 ]] || return "$QUERY_RESULT"
  echo cliamp-extra
  if [[ -f $HOME/cliamp-installed ]]; then echo cliamp; fi
}
omarchy-webapp-remove() {
  [[ $# == 1 && $OMARCHY_REMOVE_NOTIFY == false ]] || exit 1
  printf 'webapp %s\n' "$1" >> "$ACTION_LOG"
  rm "$HOME/.local/share/applications/$1.desktop"
}
nier() {
  [[ $* == 'shell apply --prompt' ]] || exit 1
  printf 'nier %s\n' "$*" >> "$ACTION_LOG"
}
source "$1"
RUNNER
export HOME="$stage/home" ACTION_LOG="$stage/actions.log"
export OMARCHY_TEST_PRESENT=1 UPDATE_RESULT=0 PACKAGE_RESULT=0 REMOVE_RESULT=0 QUERY_RESULT=0
apps="$HOME/.local/share/applications"
mkdir -p "$apps"
touch "$HOME/cliamp-installed"
selected=(Basecamp 'Google Contacts' 'Google Maps' 'Google Messages' 'Google Photos' HEY WhatsApp X)
for name in "${selected[@]}" Discord YouTube Zoom 'My Custom Web App'; do
  printf 'Name=%s\nExec=omarchy-launch-webapp https://example.invalid\n' "$name" > "$apps/$name.desktop"
done
printf 'Name=HEY\nExec=omarchy-webapp-handler-hey %%u\n' > "$apps/HEY.desktop"
printf 'Name=Terminal\nExec=xdg-terminal-exec --app-id=TUI.Terminal\n' > "$apps/Terminal.desktop"
bash "$stage/runner.sh" "$stage/actions.sh" >/dev/null
{
  echo 'omarchy update -y'
  echo 'pacman -S --needed nier/neovim-nightly nier/powershell extra/nushell'
  echo 'omarchy-pkg-drop cliamp'
  printf 'webapp %s\n' "${selected[@]}"
  echo 'nier shell apply --prompt'
} > "$stage/expected"
cmp "$ACTION_LOG" "$stage/expected"
for name in "${selected[@]}"; do [[ ! -e $apps/$name.desktop ]]; done
for name in Discord YouTube Zoom 'My Custom Web App' Terminal; do [[ -f $apps/$name.desktop ]]; done
[[ ! -e $HOME/cliamp-installed ]]
# Reruns preserve unrelated launchers even when they share a selected name.
printf 'Name=X\nExec=custom-command\n' > "$apps/X.desktop"
: > "$ACTION_LOG"
bash "$stage/runner.sh" "$stage/actions.sh" >/dev/null
printf '%s\n' 'omarchy update -y' 'pacman -S --needed nier/neovim-nightly nier/powershell extra/nushell' 'nier shell apply --prompt' > "$stage/repeat-expected"
cmp "$ACTION_LOG" "$stage/repeat-expected"
[[ -f $apps/X.desktop ]]
# Plain Arch retains the full pacman upgrade path.
: > "$ACTION_LOG"
OMARCHY_TEST_PRESENT=0 bash "$stage/runner.sh" "$stage/actions.sh" >/dev/null
printf '%s\n' 'pacman -Syu --needed nier/neovim-nightly nier/powershell extra/nushell' 'nier shell apply --prompt' > "$stage/arch-expected"
cmp "$ACTION_LOG" "$stage/arch-expected"
# Installation, package-query and removal errors must stop subsequent actions.
for failure in UPDATE_RESULT PACKAGE_RESULT QUERY_RESULT REMOVE_RESULT; do
  export UPDATE_RESULT=0 PACKAGE_RESULT=0 QUERY_RESULT=0 REMOVE_RESULT=0
  export "$failure=1"
  touch "$HOME/cliamp-installed"
  printf 'Exec=omarchy-launch-webapp https://example.invalid\n' > "$apps/Basecamp.desktop"
  : > "$ACTION_LOG"
  if bash "$stage/runner.sh" "$stage/actions.sh" >/dev/null 2>&1; then
    echo "Ignored failure: $failure" >&2; exit 1
  fi
  [[ -e $HOME/cliamp-installed && -e $apps/Basecamp.desktop ]]
  if grep -qE '^(webapp|nier) ' "$ACTION_LOG"; then exit 1; fi
done
echo 'PASS: package selection, exact removals, unrelated apps retained, repeat runs, name collisions and failure propagation (mocked commands)'
