import XMonad
import XMonad.Actions.CycleWS
import XMonad.Actions.SwapWorkspaces
import XMonad.Actions.WorkspaceNames
import XMonad.Config.Gnome
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.SetWMName
import XMonad.Prompt
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig
import XMonad.Util.Run
import XMonad.Actions.GridSelect
import XMonad.Layout.Gaps
import Data.List

-- IntelliJ popup fix from http://youtrack.jetbrains.com/issue/IDEA-74679#comment=27-417315
(~=?) :: Eq a => Query [a] -> [a] -> Query Bool
q ~=? x = fmap (isInfixOf x) q

manageIdeaCompletionWindow = (className =? "jetbrains-idea") <&&> (title ~=? "win") --> doIgnore

myManageHook = composeAll
  [ className =? "Xmessage" --> doFloat
  , className =? "Unity-2d-panel" --> doIgnore
  , className =? "Unity-2d-launcher" --> doIgnore
  , className =? "sun-awt-X11-XWindowPeer" --> doIgnore
  , manageDocks
  ]
myLayouts = avoidStruts $ layoutHook gnomeConfig
myWorkspaces    = ["1-mail", "2-tee", "3-tee", "4-idea", "5-tmux", "6-term", "7-term",
                   "8-term", "9-chrome"]
numPadKeys = [ xK_KP_1 .. xK_KP_9 ]

main = do
  xmproc <- spawnPipe "/usr/local/google/home/prashantv/.cabal/bin/xmobar /usr/local/google/home/prashantv/.xmobarrc"
  xmonad $ defaultConfig
    { manageHook  = manageHook defaultConfig <+> myManageHook <+> manageIdeaCompletionWindow
    , layoutHook  = myLayouts
    , workspaces  = myWorkspaces
    , terminal    = "gnome-terminal"
    , modMask     = mod1Mask
    , borderWidth = 3
    --, logHook = dynamicLogWithPP xmobarPP
    --  { ppOutput = hPutStrLn xmproc
    --  , ppTitle = xmobarColor "blue" "" . shorten 50
    --  , ppLayout = const "" -- to disable layout info on xmobar
    --  }
    , logHook = dynamicLogWithPP xmobarPP
      { ppOutput = hPutStrLn xmproc
      , ppTitle = xmobarColor "blue" "" . shorten 50
      , ppLayout = const "" -- to disable layout info on xmobar
      }
    , startupHook = setWMName "LG3D"
    }
      `additionalKeys`
    [
       ((mod1Mask, xK_g), goToSelected defaultGSConfig)
     , ((mod4Mask, xK_l), spawn "gnome-screensaver-command -l")
     , ((mod4Mask, xK_e), renameWorkspace defaultXPConfig)
     , ((mod1Mask, xK_z), toggleWS)
     , ((mod4Mask, xK_a), toggleWS)
     , ((mod4Mask, xK_r), spawnSelected defaultGSConfig
       [ "chrome"
       , "gnome-terminal"
       , "gvim"
       , "eclipse38"
       , "idea.sh"
       , "sound"
       , "~/bin/panel"
       , "pinta"
       , "firefox"
       ]
   )]

