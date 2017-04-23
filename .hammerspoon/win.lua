
-- win adds window management shortcuts.
-- ctrl+cmd+[arrow]:
--   take up half of the screen in the specified direction.
--   up will maximize on first binding, then take up top half on second.
-- ctrl+cmd+[hjkl]:
--   resize window in specified direction, only the bottom and right edge moves.
-- ctrl+cmd+shift+[hjkl]:
--   move window in the given direction
--
-- all resize/move operations will try and snap to edges.


local function inRange(a, b, c)
  if a <= b and b <= c then
    return true
  end
end


local function withinSnap(a, b)
  if a == b then
    return false
  end
  local snapThreshold = 20
  return inRange(a - snapThreshold, b, a + snapThreshold)
end

local function resizeAndSnap(f)
  local win = hs.window.focusedWindow()
  local frame = win:frame()
  local screen = win:screen():frame()

  oldW = frame.w
  oldH = frame.h

  f(frame)

  win:setFrame(frame)
end

local function moveAndSnap(f)
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

local function bindResizer(key, f)
  hs.hotkey.bind({"cmd", "ctrl"}, key, function()
    modifyFrame(f)
  end)
end

local function bindSnap(key, f1, f2)
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


hs.hotkey.bind({"alt"}, "`", function()
  hs.hints.windowHints(hs.window.focusedWindow():application():allWindows())
end)
hs.hotkey.bind({"alt"}, "tab", function()
  hs.hints.windowHints()
end)


local function bindMover(key, xDiff, yDiff)
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

local function bindResize(key, wDiff, hDiff)
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
