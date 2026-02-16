-- action adds choosers with common actions (lock screen, change brightness, etc).
-- cmd+ctrl+shfit+tab:
--   chooser that lets you choose between other actions.

local function lock()
  hs.application.open('/System/Library/Frameworks/ScreenSaver.framework/Versions/A/Resources/ScreenSaverEngine.app')
  return true
end

local function wifiToggle()
  hs.applescript.applescript([[
    set makiaeawirelessstatus to do shell script "networksetup -getairportpower en0"

    if makiaeawirelessstatus is "Wi-Fi Power (en0): On" then
        do shell script "networksetup -setairportpower en0 off"
    else if makiaeawirelessstatus is "Wi-Fi Power (en0): Off" then
        do shell script "networksetup -setairportpower en0 on"
    end if
  ]])
end

local function createBrightnessChooser()
  changeBrightness = function(val)
    local curScreen = hs.screen.primaryScreen()
    local brightness = curScreen:getBrightness()
    if brightness == nil then
      return
    end
    brightness = brightness + val
    brightness = math.min(brightness, 1.0)
    brightness = math.max(brightness, 0)
    curScreen:setBrightness(brightness)
  end

  local chooser
  chooser = hs.chooser.new(function(a)
    changeBrightness(a["val"])
    chooser:show()
  end)

  local actions = {
    {
      ["text"] = "Dimmer",
      ["subText"] = "Decreases brightness by 10%",
      ["val"] = -0.1,
    },
    {
      ["text"] = "Brighter",
      ["subText"] = "Increases brightness by 10%",
      ["val"] = 0.1,
    },
    {
      ["text"] = "Slightly dimmer",
      ["subText"] = "Decreases brightness by 1%",
      ["val"] = -0.01,
    },
    {
      ["text"] = "Slightly brighter",
      ["subText"] = "Increases brightness by 1%",
      ["val"] = 0.01,
    },
  }
  chooser:choices(actions)
  return function()
    chooser:show()
  end
end

local function createActionChooser()
  showBrightness = createBrightnessChooser()
  local actionIds = {
    [1] = lock,
    [2] = wifiToggle,
    [3] = showBrightness,
  }

  local chooser
  choseAction = function(a)
    if actionIds[a["id"]]() then
      chooser:show()
    end
  end

  chooser = hs.chooser.new(choseAction)

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
    {
      ["text"] = "Brightness",
      ["subText"] = "Control brightness of current screen",
      ["id"] = 3,
    },
  }
  chooser:choices(actions)

  hs.hotkey.bind({"cmd", "shift", "ctrl"}, "tab", function()
    chooser:show()
  end)
end
createActionChooser()
