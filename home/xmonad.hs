
import Data.Function ((&))
import XMonad
import XMonad.Config.Kde
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.ManageDocks
import XMonad.Layout.Spacing
import XMonad.Layout.ThreeColumns
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig (additionalKeys)
import XMonad.Util.SpawnOnce
main =
  xmonad . ewmh . docks $
    kde4Config
      { modMask = mod4Mask,
        focusFollowsMouse = False,
        manageHook = manageHook kde4Config <+> myManageHook <+> manageDocks,
        layoutHook = myLayoutHook,
        handleEventHook = fullscreenEventHook,
        workspaces = myWorkspaces,
        startupHook = startupHook kde4Config >> spawn "picom --experimental-backends &",
        borderWidth = 0,
        terminal = "alacritty"
      }
      `additionalKeys` myKeys
myWorkspaces = let n = ["Web", "IM", "Code", "Proc", "Music"] in n ++ map show [(1 & (length n +)) .. 8]
spac = spacingRaw False (Border 0 15 10 10) True (Border 5 5 5 5) True . avoidStruts
spac' = spacingRaw False (Border 200 200 200 200) True (Border 5 5 5 5) True . avoidStruts
myLayoutHook = spac ((ThreeCol 1 (3 / 100) (1 / 2) ||| ThreeColMid 1 (3 / 100) (1 / 2) ||| Mirror (Tall 1 (3 / 100) (1 / 2)) ||| Full) |||  spac' (Tall 1 (3 / 100) (1 / 2)))
myKeys =
  [ ((mod4Mask, xK_r), spawn "rofi -no-lazy-grab -show drun -modi drun -theme ~/.config/rofi/colorful/style.rasi"),
    ((mod4Mask .|. controlMask, xK_r), spawn "xmonad --recompile && xmonad --restart" 
        >> spawn "killall picom && picom --experimental-backends &"),
    ((mod4Mask .|. controlMask, xK_l), spawn "killall latte-dock && kstart5 latte-dock"),
    ((mod4Mask .|. controlMask, xK_p), mySpawnOn "Web" firefox),
    ((mod4Mask .|. controlMask, xK_t), mySpawnOn "IM" tg),
    ((mod4Mask .|. controlMask, xK_d), spawn "dolphin"),
    ((mod4Mask .|. controlMask, xK_s), spawn "systemsettings5")
  ]
myManageHook =
  composeAll . concat $
    [ [className =? c --> doFloat | c <- floatByClass],
      [className =? c --> doShift "IM" | c <- imApps],
      [className =? c --> doShift "Web" | c <- webApps],
      [className =? c --> doIgnore | c <- ignoreByClass],
      [name =? c --> doFloat | c <- floatByName]
    ]
  where
    name = stringProperty "WM_NAME"
    floatByClass = ["peek"]
    floatByName = ["Media viewer"]
    ignoreByClass = ["plasmashell"]
    webApps = [firefox]
    imApps = [tg]
firefox = "firefox"
tg = "telegram-desktop"
mySpawnOn workspace program = spawn program >> (windows $ W.greedyView workspace)