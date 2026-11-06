#!/usr/bin/env bash
set -euo pipefail
project=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT
# Use a small fixture to test directory deployment without duplicating plugins.
mkdir -p "$stage/deploy/nvim/lua" "$stage/home" "$stage/config"
cp "$project/apply-config.sh" "$stage/deploy/"
echo '-- bundled config' > "$stage/deploy/nvim/init.lua"
apply() {
  env -u SUDO_USER HOME="$stage/home" XDG_CONFIG_HOME="$stage/config" \
    bash "$stage/deploy/apply-config.sh" "$@"
}
apply
cmp "$stage/deploy/nvim/init.lua" "$stage/config/nvim/init.lua"
apply
[[ $(find "$stage/config" -mindepth 1 -maxdepth 1 | wc -l) == 1 ]]
# Preserve custom changes; repeat application must not create another backup.
echo '-- custom change' >> "$stage/config/nvim/init.lua"
apply
[[ $(find "$stage/config" -name 'nvim.nier-backup.*' | wc -l) == 1 ]]
apply
[[ $(find "$stage/config" -name 'nvim.nier-backup.*' | wc -l) == 1 ]]
# Back up the Omarchy integration under its designated name.
mkdir -p "$stage/config/nvim/lua/plugins"
echo '-- Omarchy fixture' > "$stage/config/nvim/lua/plugins/omarchy-theme-hotreload.lua"
apply
[[ -f $stage/config/nvim.omarchy/lua/plugins/omarchy-theme-hotreload.lua ]]
apply
mkdir -p "$stage/config/nvim/lua/plugins"
echo '-- another Omarchy fixture' > "$stage/config/nvim/lua/plugins/omarchy-theme-hotreload.lua"
if apply >/dev/null 2>&1; then echo 'Overwrote Omarchy backup' >&2; exit 1; fi
grep -q 'another Omarchy' "$stage/config/nvim/lua/plugins/omarchy-theme-hotreload.lua"
grep -q '^-- Omarchy fixture$' "$stage/config/nvim.omarchy/lua/plugins/omarchy-theme-hotreload.lua"
# Replacing a symlink must not alter the directory it points to.
rm -rf "$stage/config/nvim" "$stage/config/nvim.omarchy"
mkdir -p "$stage/original/lua/plugins"
echo '-- original' > "$stage/original/init.lua"
touch "$stage/original/lua/plugins/omarchy-theme-hotreload.lua"
ln -s "$stage/original" "$stage/config/nvim"
apply
[[ -L $stage/config/nvim.omarchy && ! -L $stage/config/nvim ]]
grep -q '^-- original$' "$stage/original/init.lua"
# A failed final rename restores the previous configuration.
mkdir "$stage/bin"
cat > "$stage/bin/mv" <<'MOCK'
#!/usr/bin/env bash
for argument in "$@"; do
  if [[ $argument == */.nier-nvim.*/nvim ]]; then exit 1; fi
done
exec /usr/bin/mv "$@"
MOCK
chmod +x "$stage/bin/mv"
echo '-- keep on failure' >> "$stage/config/nvim/init.lua"
if PATH="$stage/bin:$PATH" apply >/dev/null 2>&1; then
  echo 'Failed rename accepted' >&2; exit 1
fi
grep -q '^-- keep on failure$' "$stage/config/nvim/init.lua"
# No source files or original config changes for help and invalid arguments.
apply --help >/dev/null
if apply --invalid >/dev/null 2>&1; then exit 1; fi
echo 'PASS: fresh install, repeat runs, backups, backup collision, symlinks, rollback and arguments'
