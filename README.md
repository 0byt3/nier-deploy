# nier-deploy

Deployment scripts for configuring the Nier pacman repository and installing
Nier packages on Arch Linux and Omarchy clients. Shared desktop tooling for
Nier widgets, themes, and tools belongs in the sibling `nier-desktop/` project.

The current `setup.sh` configures repository access, installs Neovim nightly,
PowerShell, and Nushell, and runs `nier shell apply --prompt` for the current
user. Install `nier-desktop` first (3.0.0-20 or newer automatically adds the Nier
Hyprland loader to the current user's config and `/etc/skel` during installation),
then run setup as the intended desktop user without sudo. The script requests
sudo separately for repository changes and package installation.

## Install Bash completion

The `nier-desktop` package installs completion for Nier commands automatically. See
[its README](../nier-desktop/README.md#bash-completion) for activation and
completion for checkout-relative deployment scripts.

System-wide completion definitions live in `/usr/share/nier/completions/`,
with links from Bash's standard completion directory.

## Enable the Nier pacman repository

```sh
# Prompts for a URL; Enter accepts the NetBird address
./setup.sh

# Explicit URL (usable on the current LAN before NetBird is installed)
./setup.sh http://10.0.2.36:8080

# Explicit future NetBird URL
./setup.sh http://nier-pacman-updated.netbird.cloud:8080
```

The default is `http://nier-pacman-updated.netbird.cloud:8080`. Noninteractive runs without
an argument use it automatically. NetBird installation, connectivity, and DNS
must be configured separately; the script does not install or configure NetBird.
Until then, supply the server's LAN URL explicitly.

`setup.sh` requires Bash, curl, GnuPG, pacman, and sudo when not run as root.
It downloads `nier-repo.asc`, requires the pinned signing fingerprint
`D08DCD6B97C9885E62968C927DEEC45C73A8FB34`, and verifies the downloaded repository
database signature before changing the system. It then imports and locally
signs that public key and creates or updates a single `[nier]` section in
`/etc/pacman.conf` with `SigLevel = Required DatabaseRequired`.

Unrelated configuration is retained; changed configuration is backed up before
atomic replacement. Repeated runs with the same URL leave the configuration
unchanged. A key mismatch, unreachable server, or invalid database signature
fails before trust or configuration changes. Key rotation requires updating the
pinned fingerprint after verifying the replacement key through the administrator.

After enabling the repository, Omarchy systems run `omarchy update -y` through
the canonical update flow (snapshots, keyrings, migrations and boot checks), then
`sudo pacman -S --needed nier/neovim-nightly nier/powershell extra/nushell`.
Setup initializes Omarchy's packaged environment bootstrap for SSH/noninteractive
invocations. It never bypasses Omarchy 4.5's direct-full-upgrade guard.
Plain Arch systems use `sudo pacman -Syu --needed` with the same package targets.
This performs a full system upgrade while explicitly installing nightly from
the Nier repository, PowerShell from Nier, and Nushell from Arch's `extra`
repository. PowerShell exposes `pwsh`; Nushell exposes `nu`. This does not
change the user's login shell or install PowerShell Editor Services.
The nightly package provides and conflicts with `neovim`;
confirm pacman's prompt to remove the stable package in the same transaction.
Nightly recipe revision 7 or newer provides its actual Neovim API version,
satisfying Omarchy 4.5's `omarchy-nvim` versioned dependency.
Stable Neovim is never uninstalled in a separate step. If nightly is unavailable
or the transaction fails, setup stops before applying shell configuration.
Repeated runs skip reinstalling an up-to-date nightly package (`--needed`),
while still checking for system upgrades. Pacman's confirmation prompts remain
enabled. Publish `neovim-nightly` and `powershell` in the selected repository
before running setup. `--needed` also skips up-to-date PowerShell and Nushell
packages.
Hyprland loader setup is handled by `nier-desktop`'s package install/upgrade
scriptlet rather than this script. See the
[desktop tooling guide](../nier-desktop/README.md#hyprland-configuration).

After the package transaction, setup removes `cliamp` if installed, using
Omarchy's built-in `omarchy-pkg-drop cliamp`. This helper handles sudo and uses
`pacman -Rns --noconfirm`, which can also remove cliamp's unused dependencies.
No other application package is explicitly targeted. Removal failures stop setup.
It also removes exactly these Omarchy web-app shortcuts and their icons:
Basecamp, Google Contacts, Google Maps, Google Messages, Google Photos, HEY,
WhatsApp, and X. This uses `omarchy-webapp-remove` individually, suppressing
notifications. Missing launchers are skipped, and same-named launchers that do
not use Omarchy's web-app commands are retained. These launchers use Omarchy's
standard `~/.local/share/applications` location.

Other web apps (including Discord, YouTube, Zoom and custom apps), TUI launchers,
mise tools, and preinstalled-app keyboard bindings are retained. Setup does not
invoke Omarchy's bulk preinstall removal command. Browser profiles and website
data are untouched. Repeated runs skip already-removed applications.

Setup then applies Nier Bash integration and the two-line Starship prompt using
`nier shell apply --prompt`. Changed user files are backed up. Repeated runs
leave the generated Bash and Starship files unchanged, without duplicate lines
or additional backups. Shell setup failures return an error; repository changes
already completed remain in place, and setup can be rerun after fixing the error.
The Neovim configuration itself is deployed separately with `apply-config.sh`.

## Validation

`bash -n setup.sh` and `shellcheck setup.sh` pass. The setup was also tested in
a disposable Arch container on VM 107 for key trust, required signatures,
replacement of stale repository configuration, backups, repeated runs, URL
changes, wrong-key rejection, database tampering, and unreachable-default behavior.
No client host or Omarchy VM configuration was changed during these tests.
`tests/setup-packages.sh` verifies package installation, selected removals,
preservation of unrelated apps, repeat runs, and failure propagation before shell
application with mocked commands. Hyprland package integration has separate
real pacman tests in the desktop project's disposable Arch container; the full
setup script was not rerun on VM106 for this change.

### Full Omarchy 4.5 deployment validation (2026-11-06)

Tested on VM106 after the user's fresh Omarchy 4.5.0-3 restore. Installed
signed `nier-desktop 3.0.0-20` and `blesh 0.4.0_devel3-2` as setup prerequisites,
then ran the actual setup and Neovim configuration deployment. Live testing
found and fixed the direct full-upgrade guard, the missing Omarchy environment
in SSH commands, and nightly's unversioned Neovim provide.

The signed test repository is
`http://10.0.2.36:8080/images/omarchy45-deployment/client` and remains VM106's
configured `[nier]` URL. It contains the desktop, ble.sh, PowerShell and corrected
nightly packages. This separate repository uses the existing pinned key and
required package/database signatures; the production database and enabled
updater package list were not changed. Production still needs nightly revision
7 or newer enabled/published before using the normal URL for this deployment.

Installed nightly `20261106213034.718630294-7` reports Neovim
`0.13.0-dev-2040+g67854d5c5b` and provides `neovim=0.13.0`, retaining
`omarchy-nvim`. PowerShell 7.6.9 and Nushell 0.116.1 passed executable smoke tests.
The only original packages removed were stable `neovim` and `cliamp`.
All eight requested web apps were removed; Discord, YouTube and Zoom remained.
No bulk-removal marker or default-tool opt-out was created.

Validated the package hook's user/skeleton Hyprland loader, live compositor
configuration, interactive ble.sh/Starship/completion, Neovim theme/plugins,
Nushell LSP attachment and Treesitter. Original editor configuration is retained
as `~/.config/nvim.omarchy`. A full setup/config repeat left configuration
checksums and user backup counts unchanged. Reboot changed the boot ID and
returned to a healthy desktop/SSH session with no failed system/user units;
the shell/editor checks passed again. Package integrity reports 91 desktop,
91 ble.sh, 2333 nightly and 627 PowerShell files with none altered.

PowerShell Editor Services and other external language/formatting tools are not
automatically installed. Its missing-server discovery path passed; a live
PowerShell LSP session was not tested. Windows `--check` correctly reports the
missing optional FreeRDP prerequisite; no Windows installation, Podman migration,
OneDrive account authentication/sync, or optional widget/theme deployment was
performed. Both outer VMs remain running to keep the test repository available.

Guest evidence and pre-deployment configuration/package backups are under
`~/nier-deployment-test/`. Nonsecret logs are mirrored in the ignored local
`../nier-desktop/dist/omarchy45-deployment/`. Initial failed attempts are retained
alongside the successful setup, repeat and post-reboot logs.

## Deploy Neovim configuration

Run `./apply-config.sh` as the intended desktop user. It copies the bundled
`nvim/` snapshot to `${XDG_CONFIG_HOME:-$HOME/.config}/nvim`. This is separate
from `setup.sh`; it does not install Neovim or language tooling.

An existing configuration with Omarchy's theme hot-reload plugin or theme-path
integration is renamed to `nvim.omarchy` beside `nvim`. If that backup already
exists, deployment stops rather than overwriting it. Other existing configs
receive `nvim.nier-backup.<timestamp>.<pid>` backups. Symlinked configurations
are backed up as links without changing their original directory. Identical
configurations are left untouched on subsequent runs. Updates stage the new
copy before backing up the old directory and restore the backup if installation
fails. Close Neovim before deployment.

### Snapshot review

The snapshot includes the user's Lua configuration, custom Tokyo colors and
Lualine theme, Nushell queries, plugin manifest, and installed native package
sources (with their licenses). Git metadata, generated help tags, and Blink's
compiled `target/` directory are excluded. Blink uses its Lua fallback; plugin
updates are manual, and `plugins.nuon` describes their upstream repositories.

The source workstation uses Neovim `0.13.0-dev-1840+ga054b698c0`. Configuration
uses the experimental `vim._core.ui2` module and modern LSP APIs; older Neovim
builds may fail at startup. Treesitter installs missing parsers on startup and
needs network access and a working compiler/toolchain. No parsers or editor
state from the workstation's data/cache directories are included.

Language support expects separately installed Lua, Nushell, PowerShell, Pyright,
Ansible, Marksman, Odin, and Rust servers. PowerShell is discovered on `PATH`.
Editor Services is searched for in `/opt/powershell-editor-services/current`,
`/opt/powershell-editor-services`, `/usr/share/powershell-editor-services`,
`/usr/lib/powershell-editor-services`, then Neovim's data directory under
`mason/packages/powershell-editor-services`. Set
`POWERSHELL_EDITOR_SERVICES_PATH` to override discovery with a bundle root or
its `PowerShellEditorServices` directory. An invalid override disables the
PowerShell LSP rather than falling back to another installation. Missing
dependencies disable only that server and produce one warning when opening
a PowerShell file. Restart Neovim after installing dependencies or changing
the environment. Formatting
and linting use Topiary (including its language configuration), jq, mdformat,
odinfmt, rustfmt, ShellCheck, and yamllint. Telescope grep uses ripgrep; Wayland
clipboard support uses wl-clipboard. These dependencies are not installed by
`apply-config.sh`. The custom theme replaces Omarchy's theme integration.

### Live repository deployment and broad tooling validation (2026-11-06)

VM106 now uses `http://10.0.2.36:8080` as its sole `[nier]` server, replacing
its earlier limited test-repository URL. All nine production packages are
installed and pass integrity checks with no altered files. Go and ShellCheck
were added for source regression/static checks. No EAG theme package is installed.

The packaged workspace and OneDrive plugins are linked into the user's Omarchy
plugin directory and enabled in the bar. Only the stock workspace entry was
replaced, and OneDrive was appended once. The original bar configuration is
`~/nier-live-deployment-test/shell.before.json`. Widget QML tests passed on the
actual Wayland session, including sorting, pagination, dispatch quoting, account
discovery and transfer rendering. The installed workspace Lua dispatch worked
for numbered and temporary named workspaces; workspace 1 was restored. OneDrive's
actual empty-state status/open/close IPC passed, and no account is configured.
Its monitor wrapper produced the expected synthetic transfer/completion events.

Remote Desktop Manager and Teams opened actual GUI windows using isolated test
profiles, then were stopped. No authentication or remote connection was attempted.
Shell, completion, Hyprland, Neovim, Nushell LSP, Treesitter, OneDrive Go tests,
control-helper Go tests, application-picker Qt tests and cross-platform PowerShell
regressions passed. Potentially destructive defaults/PAM/Podman/removal tests ran
in disposable containers on VM107, with no host VM/container runtime migration.

Full setup/config repeat checks left active configuration checksums and Nier
backup counts unchanged. After reboot, the live repository, widgets, editor and
shell remained healthy; package integrity and system/user unit checks passed.
PowerShell Editor Services and other optional external language/formatting tools
remain separate dependencies. Windows provisioning was excluded. Windows control,
menu, removal and credential paths were tested through isolated fixtures, not an
actual Windows VM; the prerequisite check reports missing optional FreeRDP.

Guest logs: `~/nier-live-deployment-test/`. Nonsecret evidence is mirrored under
ignored `../nier-desktop/dist/live-verification/`. Both outer VMs remain running.
