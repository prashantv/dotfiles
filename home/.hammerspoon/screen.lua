-- screen adds screen management shortcuts.
-- cmd+ctrl+shift+[arrow]:
--   move focused window to the screen in the specified direction.

local function bindMoveToScreen(key, f)
  hs.hotkey.bind({"cmd", "ctrl", "shift"}, key, function()
    local win = hs.window.focusedWindow()
    f(win)
  end)
end

-- Move window to screen on left/right/top/bottom.
bindMoveToScreen("left", function(w)
  w:moveOneScreenWest()
end)
bindMoveToScreen("right", function(w)
  w:moveOneScreenEast()
end)
bindMoveToScreen("up", function(w)
  w:moveOneScreenNorth()
end)
bindMoveToScreen("down", function(w)
  w:moveOneScreenSouth()
end)

