# Herdr customizations

Run `./deploy.sh` from the `nier-deploy` directory as your desktop user to
install `themes/nier.json` alongside the Hyprland bindings. Deployment backs
up changed destination files and skips identical files.

Herdr uses `~/.config/herdr-app` by default, or `HERDR_APP_HOME` when set.
The deploy script uses that same location for the theme, independently of
`XDG_CONFIG_HOME`.

Herdr discovers JSON files in its `themes/` directory automatically. No
settings or layout changes are needed for discovery. Select **nier** in the
theme picker to apply its dark charcoal panel backgrounds and darker gray
terminal backgrounds. Deployment does
not change the selected theme. If the running app does not show the new
entry immediately, reopen it.
