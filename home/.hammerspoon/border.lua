-- border adds a border to the currently focused terminal if it's small.
-- this is used to help identify the current window when there's many small
-- terminals open.

local function isLargeWindow(f)
  local screen = win:screen():frame()
  return f.area > 0.4 * screen.area
end



-- Draw a orange border on current focused iTerm window
-- Only applies for non-fullscreen iTerm windows.
local function redrawBorder()
  if global_border ~= nil then
      global_border:delete()
  end

  win = hs.window.focusedWindow()
  if win == nil then
    return
  end

  if win:application():name() ~= "iTerm" and win:application():name() ~= "Terminal" and win:application():name() ~= "iTerm2" then
    return
  end

  if isLargeWindow(win:frame()) then
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
allwindows:subscribe(hs.window.filter.windowFullscreened, redrawBorder)
allwindows:subscribe(hs.window.filter.windowHidden, redrawBorder)
allwindows:subscribe(hs.window.filter.windowMinimized, redrawBorder)
allwindows:subscribe(hs.window.filter.windowMoved, redrawBorder)
allwindows:subscribe(hs.window.filter.windowUnfocused, redrawBorder)
allwindows:subscribe(hs.window.filter.windowUnfullscreened, redrawBorder)
allwindows:subscribe(hs.window.filter.windowUnhidden, redrawBorder)
allwindows:subscribe(hs.window.filter.windowUnminimized, redrawBorder)
redrawBorder()
