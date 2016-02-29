
-- Custom notifications for the screen
-- hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
--   hs.alert.show("Hello World!")
-- end)

-- OSX notifications
-- hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
--   hs.notify.new({title="Hammerspoon", informativeText="Hello World"}):send()
-- end)



-- switchToApp will switch to a window for the given app name.
-- It prefers windows on the current screen, that are not the current window.
-- This allows you to switch between 2 windows for the same app by using the
-- shortcut repeatedly.
function switchToApp(app)
  local curWindow = hs.window.focusedWindow()
  local curScreen = curWindow:screen()
  local wf = hs.window.filter.new(app)

  local appWindows = {}
  for _, w in ipairs(wf:getWindows()) do
    table.insert(appWindows, w)

    if (w ~= curWindow) and w:screen() == curScreen then
      w:focus()
      return
    end
  end
end

function inRange(a, b, c)
  if a <= b and b <= c then
    return true
  end
end

function withinSnap(a, b)
  if a == b then
    return false
  end
  local snapThreshold = 20
  return inRange(a - snapThreshold, b, a + snapThreshold)
end

function resizeAndSnap(f)
  local win = hs.window.focusedWindow()
  local frame = win:frame()
  local screen = win:screen():frame()

  oldW = frame.w
  oldH = frame.h

  f(frame)

  win:setFrame(frame)
end

function moveAndSnap(f)
  local win = hs.window.focusedWindow()
  local frame = win:frame()
  local screen = win:screen():frame()

  oldX = frame.x
  oldY = frame.y


  f(frame)

  -- Snap to left
  if (oldX > 0 and frame.x < 0) or withinSnap(0, frame.x) then
    hs.alert.show("snapped to left")
    frame.x = 0
  end


  -- Snap to right
  if (oldX + frame.w < screen.w and frame.x + frame.w > screen.w) or
     withinSnap(screen.w, frame.x + frame.w) then
    hs.alert.show("snapped to right")
    frame.x = screen.w - frame.w
  end

  -- Snap to top
  if oldY > 0 and frame.y < 0 or withinSnap(0, frame.y) then
    hs.alert.show("snapped to top")
    frame.y = 0
  end

  -- Snap to bottom
  screenH = screen.h + 27 -- dock
  if (oldY + frame.h < screenH and frame.y + frame.h > screenH) or
     withinSnap(screenH, frame.y + frame.h) then
    hs.alert.show("snapped to bottom")
    frame.y = screenH - frame.h
  end


  -- Debugging
  -- hs.alert.show("frame x,y,w,h" .. frame.x .. "," .. frame.y .. "," ..frame.w .."," ..frame.h)
  -- hs.alert.show("screen x,y,w,h" .. screen.x .. "," .. screen.y .. "," ..screen.w .."," ..screen.h)

  win:setFrame(frame)
end

function bindResizer(key, f)
  hs.hotkey.bind({"cmd", "ctrl"}, key, function()
    modifyFrame(f)
  end)
end

function bindSnap(key, f1, f2)
  hs.hotkey.bind({"cmd", "ctrl"}, key, function()
    local win = hs.window.focusedWindow()
    local frame = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    oldFrame = hs.geometry.copy(frame)


    frame.x = max.x
    frame.y = max.y
    frame.w = max.w
    frame.h = max.h
    f1(frame, max)
    if frame == oldFrame and f2 then
      f2(frame, max)
    end

    win:setFrame(frame)
  end)
end

-- Snap to left/right/top/bottom shortcuts.
bindSnap("left", function(f, max)
  f.w = max.w / 2
end, function(f, max)
  f.w = max.w / 3
end)
bindSnap("right", function(f, max)
  f.w = max.w / 2
  f.x = max.w - f.w
end, function(f, max)
  f.w = max.w / 3
  f.x = max.w - f.w
end)
bindSnap("up", function(f, max)
end, function(f, max)
  f.h = max.h / 2
end)
bindSnap("down", function(f, max)
  f.h = max.h / 2
  f.y = max.y + f.h
end)





hs.hints.style = "vimperator"

local expose = hs.expose.new()
-- hs.hotkey.bind({"alt"}, "tab", function()
--   --hs.hints.windowHints()
--   expose:show()
-- end)


function createWindowChooser()
  choseWindow = function(w)
    local window = hs.window.get(w["id"])
    window:focus()
  end

  local chooser = hs.chooser.new(choseWindow)
  hs.hotkey.bind({"alt"}, "tab", function()
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


function lock()
  hs.applescript.applescript('tell application "Finder" to sleep')
end

function wifiToggle()
  hs.applescript.applescript([[
    set makiaeawirelessstatus to do shell script "networksetup -getairportpower en0"

    if makiaeawirelessstatus is "Wi-Fi Power (en0): On" then
        do shell script "networksetup -setairportpower en0 off"
    else if makiaeawirelessstatus is "Wi-Fi Power (en0): Off" then
        do shell script "networksetup -setairportpower en0 on"
    end if
  ]])
end

function createActionChooser()
  local actionIds = {
    [1] = lock,
    [2] = wifiToggle,
  }
  choseAction = function(a)
    actionIds[a["id"]]()
  end

  local chooser = hs.chooser.new(choseAction)

  local actions = {
    {
      ["text"] = "Lock Screen",
      ["subText"] = "Locks the screen",
      ["id"] = 1,
    },
    {
      ["text"] = "Wifi Toggle",
      ["subText"] = "Toggle wireless adapter",
      ["id"] = 2,
    },
    -- TODO: change brightness on external mac display.
  }
  chooser:choices(actions)

  hs.hotkey.bind({"cmd", "shift", "ctrl"}, "tab", function()
    chooser:show()
  end)
end
createActionChooser()

function isFullScreen(f)
  local screen = win:screen():frame()
  return f.x <= screen.x and f.y <= screen.y and
     f.h >= screen.h and f.w >= screen.w
end

-- Draw a orange border on current focused window, unless it's full screen.
function redrawBorder()
  if global_border ~= nil then
      global_border:delete()
  end

  win = hs.window.focusedWindow()
  if win == nil then
    return
  end

  if isFullScreen(win:frame()) then
    return
  end

  top_left = win:topLeft()
  size = win:size()
  if global_border ~= nil then
      global_border:delete()
  end
  global_border = hs.drawing.rectangle(hs.geometry.rect(top_left['x'], top_left['y'], size['w'], size['h']))
  global_border:setStrokeColor({["red"]=1,["blue"]=0.25,["green"]=0.75,["alpha"]=0.8})
  global_border:setFill(false)
  global_border:setStrokeWidth(4)
  global_border:show()
end

allwindows = hs.window.filter.new(nil)
allwindows:subscribe(hs.window.filter.windowCreated, redrawBorder)
allwindows:subscribe(hs.window.filter.windowDestroyed, redrawBorder)
allwindows:subscribe(hs.window.filter.windowFocused, redrawBorder)
allwindows:subscribe(hs.window.filter.windowMoved, redrawBorder)
allwindows:subscribe(hs.window.filter.windowUnfocused, redrawBorder)

redrawBorder()


-- Switcher shortcuts
-- Print all app names:
-- for _, w in ipairs(hs.window.allWindows()) do print(w:application():name()) end

function bindApp(key, app)
  hs.hotkey.bind({"cmd", "ctrl"}, key, function()
    switchToApp(app)
  end)
end

bindApp("1", "Google Chrome")
bindApp("2", "iTerm")
bindApp("3", "Atom")
bindApp("4", "HipChat")

-- Move shortcuts

function bindMover(key, xDiff, yDiff)
  hs.hotkey.bind({"cmd", "shift", "ctrl"}, key, function()
    moveAndSnap(function(f)
      f.x = f.x + xDiff
      f.y = f.y + yDiff
    end)
  end)
end

local moveDiff = 100
bindMover("h", -moveDiff, 0)
bindMover("l", moveDiff, 0)
bindMover("j", 0, moveDiff)
bindMover("k", 0, -moveDiff)
bindMover("y", -moveDiff, -moveDiff)
bindMover("u", moveDiff, -moveDiff)
bindMover("b", -moveDiff, moveDiff)
bindMover("n", moveDiff, moveDiff)

-- Resize shortcuts

function bindResize(key, wDiff, hDiff)
  hs.hotkey.bind({"cmd", "ctrl"}, key, function()
    resizeAndSnap(function(f)
      f.w = f.w + wDiff
      f.h = f.h + hDiff
    end)
  end)
end

bindResize("h", -moveDiff, 0)
bindResize("l", moveDiff, 0)
bindResize("j", 0, moveDiff)
bindResize("k", 0, -moveDiff)
bindResize("y", -moveDiff, -moveDiff)
bindResize("u", moveDiff, -moveDiff)
bindResize("b", -moveDiff, moveDiff)
bindResize("n", moveDiff, moveDiff)

-- Notify that load was successful
hs.alert.show("Hammerspoon config loaded")



-- Reload config on save.
function reloadConfig()
  if configFileWatcher ~= nil then
    configFileWatcher:stop()
    configFileWatcher = nil
  end

  hs.reload()
end

configFileWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/init.lua", reloadConfig)
configFileWatcher:start()