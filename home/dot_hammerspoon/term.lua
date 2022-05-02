-- term adds shortcuts for creating new terminals.
-- cmd+shift+enter:
--   create a new full terminal

local function newTerminal()
    if hs.application.find('iTerm') == nil then
        hs.application.launchOrFocus('iTerm')
    else
        hs.applescript.applescript([[
            tell application "iTerm"
                create window with default profile
            end tell
        ]])
    end
end

hs.hotkey.bind({'cmd', 'shift'}, 'return', newTerminal)