-- Keep only your personal keybinding overrides here. Add new bindings with
-- o.bind or replace defaults with o.rebind.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding. o.rebind takes the same arguments as o.bind.
-- This example replaces the default file manager with Flea.
-- o.rebind("SUPER + SHIFT + F", "File manager", { launch = "flea" })

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, { panel = "omarchy.emojis" })

-- Nier: disable stock Omarchy 4.5 bindings.
-- Copied from the current user's ~/.config/hypr/bindings.lua on 2026-11-07.
-- Inventory source: Omarchy 4.5.0-3, /usr/share/omarchy/default/hypr/bindings/*.lua.
-- Every hl.unbind below is ACTIVE. Delete or comment out an unbind to keep
-- that stock shortcut. Add personal o.bind/o.rebind calls AFTER this list.
-- One unbind removes all actions on a chord, including press/release pairs.
-- Optional app/backend and JIS bindings are included even when unavailable.
-- Workspace, group-window and bar-panel loops are expanded for individual edits.
-- This repository copy takes effect only when installed as ~/.config/hypr/bindings.lua.

-- dictation (stock dictation.lua)
-- Right Alt hold: remove both push-to-talk start and stop actions.
hl.unbind("ALT + Alt_R") -- Start dictation (push-to-talk); Stop dictation (push-to-talk)

-- applications (stock applications.lua)
hl.unbind("SUPER + ALT + RETURN") -- Tmux
hl.unbind("SUPER + CTRL + RETURN") -- Herdr
hl.unbind("SUPER + SHIFT + Q") -- Calculator
hl.unbind("XF86Calculator") -- Calculator
hl.unbind("SUPER + SHIFT + M") -- Music
hl.unbind("SUPER + SHIFT + ALT + M") -- Music TUI
hl.unbind("SUPER + SHIFT + D") -- Docker
hl.unbind("SUPER + SHIFT + G") -- Signal
hl.unbind("SUPER + SHIFT + ALT + A") -- Grok
hl.unbind("SUPER + SHIFT + C") -- Calendar
hl.unbind("SUPER + SHIFT + ALT + E") -- New email
hl.unbind("SUPER + SHIFT + Y") -- YouTube
hl.unbind("SUPER + SHIFT + ALT + G") -- WhatsApp
hl.unbind("SUPER + SHIFT + CTRL + G") -- Google Messages
hl.unbind("SUPER + SHIFT + P") -- Google Photos
hl.unbind("SUPER + SHIFT + S") -- Google Maps
hl.unbind("SUPER + SHIFT + X") -- X
hl.unbind("SUPER + SHIFT + ALT + X") -- X Post


-- input-method (stock input-method.lua)
hl.unbind("SUPER + I") -- Switch input language
hl.unbind("SUPER + SHIFT + I") -- Switch input language back
hl.unbind("CTRL + SPACE") -- Direct input for the terminal prefix

-- jis (stock jis.lua)
-- Stock only enables this shortcut for a Japanese keyboard layout.
hl.unbind("CTRL + SHIFT + semicolon") -- Zoom in (JIS + key)

-- tiling (stock tiling.lua)
hl.unbind("CTRL + ALT + DELETE") -- Close all windows
hl.unbind("SUPER + P") -- Pseudo window
hl.unbind("SUPER + CTRL + F") -- Tiled full screen
hl.unbind("SUPER + ALT + F") -- Full width
hl.unbind("SUPER + ALT + L") -- Cycle workspace layout back

-- utilities (stock utilities.lua)
hl.unbind("SUPER + SHIFT + SPACE") -- Toggle top bar
hl.unbind("SUPER + CTRL + SPACE") -- Background switcher
hl.unbind("SUPER + CTRL + W") -- Background switcher
hl.unbind("SUPER + SHIFT + CTRL + SPACE") -- Theme menu
hl.unbind("SUPER + CTRL + T") -- Theme menu
hl.unbind("SUPER + BACKSPACE") -- Toggle transparency on a window
hl.unbind("SUPER + SHIFT + BACKSPACE") -- Toggle window gaps
hl.unbind("SUPER + CTRL + BACKSPACE") -- Toggle single-window square aspect

hl.unbind("SUPER + CTRL + I") -- Toggle locking on idle
hl.unbind("SUPER + CTRL + Delete") -- Toggle laptop display
hl.unbind("SUPER + CTRL + ALT + Delete") -- Toggle laptop display mirroring
hl.unbind("SUPER + ALT + code:34") -- Make webcam overlay smaller
hl.unbind("SUPER + ALT + code:35") -- Make webcam overlay larger
hl.unbind("SUPER + CTRL + S") -- Share
hl.unbind("SUPER + CTRL + PERIOD") -- Transcode
hl.unbind("SUPER + CTRL + R") -- Set reminder
hl.unbind("SUPER + CTRL + ALT + R") -- Show reminders
hl.unbind("SUPER + SHIFT + CTRL + R") -- Clear reminders
hl.unbind("SUPER + CTRL + ALT + T") -- Show time
hl.unbind("SUPER + CTRL + ALT + B") -- Show battery remaining
hl.unbind("SUPER + CTRL + ALT + W") -- Toggle weather
hl.unbind("SUPER + CTRL + ALT + E") -- World clock

-- Temporary screenshot-region navigation is registered by utilities.lua only
-- while a selection layer is open: RETURN (take window), CTRL + RETURN (take
-- fullscreen), TAB / CTRL + TAB (next / previous window), and arrow keys
-- (select window in that direction). These are not persistent desktop bindings;
-- unbinding them here cannot prevent their later creation by the selection hook.

-- Extra named workspaces on the primary monitor selected by Nier's monitor manager.
-- Read the Lua global on each keypress: the manager sets it asynchronously and
-- clears it during monitor changes. Named workspaces avoid Omarchy's ten-slot
-- numeric blocks; their bar labels are primary-11, primary-12 and primary-13.
local function primary_workspace(slot, move_window)
  return function()
    local primary = NIER_PRIMARY_MONITOR
    local monitor = type(primary) == "string" and primary ~= "" and hl.get_monitor(primary) or nil
    if not monitor or monitor.is_mirror then
      hl.dispatch(hl.dsp.exec_cmd(
        'omarchy notification send "Primary monitor is not set or unavailable" '
          .. '"Select a connected primary monitor in the Nier monitor manager."'
      ))
      return
    end

    -- Capture the source window before focusing the destination monitor/workspace.
    local window = move_window and hl.get_active_window() or nil
    if move_window and not window then
      return
    end

    local selector = "name:primary-" .. slot
    local workspace = hl.get_workspace(selector)
    -- Reclaim an existing workspace if it moved while its monitor was unplugged,
    -- or if the user selected a different primary. Never move its windows alone.
    if workspace and (not workspace.monitor or workspace.monitor.name ~= monitor.name) then
      hl.dispatch(hl.dsp.workspace.move({ workspace = selector, monitor = monitor.name }))
    end
    hl.dispatch(hl.dsp.focus({ monitor = monitor.name }))
    hl.dispatch(hl.dsp.focus({ workspace = selector }))
    if window then
      hl.dispatch(hl.dsp.window.move({
        workspace = selector,
        window = "address:" .. window.address,
        follow = true,
      }))
    end
  end
end

-- Replace SUPER+Q's stock close-window action as well as any existing E/R binds.
o.rebind("SUPER + Q", "Primary workspace 11", primary_workspace(11))
o.rebind("SUPER + E", "Primary workspace 12", primary_workspace(12))
o.rebind("SUPER + R", "Primary workspace 13", primary_workspace(13))

-- Move the current window to the primary workspace and follow it there.
-- These replace the stock Calculator/Email bindings on SUPER+SHIFT+Q/E.
o.rebind("SUPER + SHIFT + Q", "Move window to primary workspace 11", primary_workspace(11, true))
o.rebind("SUPER + SHIFT + E", "Move window to primary workspace 12", primary_workspace(12, true))
o.rebind("SUPER + SHIFT + R", "Move window to primary workspace 13", primary_workspace(13, true))
