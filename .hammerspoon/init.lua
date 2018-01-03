
-- Shortcuts added by this script:
-- Ctrl+Cmd+[NUM]: Switch to app (prefer cur screen).
--  1 = Chrome, 2 = iTerm, 3 = Atom, 4 = HipChat
-- Alt+Tab: Show window switcher list popup
-- Ctrl+Cmd+[Arrow]: Take up some half of the screen. Up maximizes, then takes up top half.
-- Ctrl+Cmd+[hjkl]: Resize window (make smaller or larger in given direction)
-- Ctrl+Cmd+Shift+[hjkl]: Move window in the given direction
-- Ctrl+Cmd+Shift+Tab: Common actions (e.g. lock screen)
-- Ctrl+Cmd+Shift+[Arrow]: Move window to screen in given direction.


-- Custom notifications for the screen
-- hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
--   hs.alert.show("Hello World!")
-- end)

-- OSX notifications
-- hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
--   hs.notify.new({title="Hammerspoon", informativeText="Hello World"}):send()
-- end)

require('action')
require('border')
require('screen')
require('switch_app')
require('switch_win')
require('term')
require('win')


-- Notify that load was successful
hs.alert.show("Hammerspoon config loaded")

-- Reload automatically when anything in the .hammerspoon directory changes.
local function reloadConfig()
  if configFileWatcher ~= nil then
    configFileWatcher:stop()
    configFileWatcher = nil
  end

  hs.reload()
end

configFileWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig)
configFileWatcher:start()
