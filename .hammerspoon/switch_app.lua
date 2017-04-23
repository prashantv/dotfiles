-- switch_app adds application switching shortcuts.
-- ctrl+cmd+[num]:
--   switches to the last used window of application [num].
--   if the same binding is used again, we toggle with the second
--   most recent window for that application.
--
-- Application numbers are:
-- 1: Chrome/Safari
-- 2: iTerm/Terminal
-- 3: VS Code/Atom
-- 4: HipChat/uChat

-- switchToApp will switch to a window for the given app name.
-- It prefers windows on the current screen, that are not the current window.
-- This allows you to switch between 2 windows for the same app by using the
-- shortcut repeatedly.
local function switchToApp(app)
  local curWindow = hs.window.focusedWindow()
  local curScreen = hs.screen.primaryScreen()
  local wf = hs.window.filter.new(app)

  local appWindows = {}
  for _, w in ipairs(wf:getWindows()) do
    table.insert(appWindows, w)

    if (w ~= curWindow) and w:screen() == curScreen then
      w:focus()
      return true
    end
  end

  for _, w in ipairs(appWindows) do
    if w ~= curWindow then
      w:focus()
      return true
    end
  end

  return false
end

-- Switcher shortcuts

-- Debugging to show all the application names for binding.
-- Print all app names:
-- for _, w in ipairs(hs.window.allWindows()) do print(w:application():name()) end

local function bindApp(key, apps)
  if type(apps) ~= "table" then
    apps = {apps}
  end

  hs.hotkey.bind({"cmd", "ctrl"}, key, function()
    for i, app in ipairs(apps) do
      if switchToApp(app) then
        return
      end
    end
  end)
end

bindApp("1", {"Google Chrome", "Safari"})
bindApp("2", {"iTerm2", "Terminal", "iTerm"})
bindApp("3", {"Code", "Atom", "Code - Insiders"})
bindApp("4", {"HipChat", "uChat"})
