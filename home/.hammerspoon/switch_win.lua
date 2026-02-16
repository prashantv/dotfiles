-- switch_win adds shortcuts for switching between windows.
-- alt+`:
--   show window hints for all windows of the current application
-- alt+tab:
--   show window hints for all windows
-- alt+shfit+tab:
--   chooser for switching between all open windows.

hs.hotkey.bind({"alt"}, "`", function()
  hs.hints.windowHints(hs.window.focusedWindow():application():allWindows())
end)
hs.hotkey.bind({"alt"}, "tab", function()
  hs.hints.windowHints()
end)

local function createWindowChooser()
  choseWindow = function(w)
    local window = hs.window.get(w["id"])
    hs.alert.show("Switch to" .. window:title())
    window:becomeMain()
    window:raise()
    window:focus()
  end

  local chooser = hs.chooser.new(choseWindow)
  hs.hotkey.bind({"alt", "shift"}, "tab", function()
    local windows = {}
    local wf = hs.window.filter.new()

    for _, w in pairs(wf:getWindows()) do
      table.insert(windows, {
        ["text"] = w:title(),
        ["subText"] = w:application():name(),
        ["id"] = w:id(),
      })
    end
    chooser:choices(windows)
    chooser:show()
    -- expose:show()
  end)


end
createWindowChooser()

