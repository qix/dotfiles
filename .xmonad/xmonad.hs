import XMonad                          -- (0) core xmonad libraries
import System.Exit
 
import qualified XMonad.StackSet as W  -- (0a) window stack manipulation
import qualified Data.Map as M         -- (0b) map creation

import Data.Ratio ((%))

-- Hooks -----------------------------------------------------
 
import XMonad.Hooks.DynamicLog     -- (1)  for dzen status bar
import XMonad.Hooks.UrgencyHook    -- (2)  alert me when people use my nick
                                   --      on IRC
import XMonad.Hooks.ManageDocks    -- (3)  automatically avoid covering my
                                   --      status bar with windows
import XMonad.Hooks.ManageHelpers  -- (4)  for doCenterFloat, put floating
                                   --      windows in the middle of the
                                   --      screen
 
-- Layout ----------------------------------------------------
 
import XMonad.Layout.ResizableTile -- (5)  resize non-master windows too
import XMonad.Layout.Grid          -- (6)  grid layout
import XMonad.Layout.TwoPane
import XMonad.Layout.NoBorders     -- (7)  get rid of borders sometimes
                                   -- (8)  navigate between windows
import XMonad.Layout.WindowNavigation  --  directionally
import XMonad.Layout.Named         -- (9)  rename some layouts
import XMonad.Layout.PerWorkspace  -- (10) use different layouts on different WSs
import XMonad.Layout.WorkspaceDir  -- (11) set working directory
                                   --      per-workspace
import XMonad.Layout.Reflect       -- (13) ability to reflect layouts
import XMonad.Layout.MultiToggle   -- (14) apply layout modifiers dynamically
import XMonad.Layout.MultiToggle.Instances

import XMonad.Layout.IM

                                   -- (15) ability to magnify the focused
                                   --      window
import qualified XMonad.Layout.Magnifier as Mag
 
import XMonad.Layout.Gaps
 
-- Actions ---------------------------------------------------
 
import XMonad.Actions.CycleWS      -- (16) general workspace-switching
                                   --      goodness
import XMonad.Actions.CycleRecentWS
                                   -- (17) more flexible window resizing
import qualified XMonad.Actions.FlexibleManipulate as Flex
import XMonad.Actions.Warp         -- (18) warp the mouse pointer
import XMonad.Actions.Submap       -- (19) create keybinding submaps
import XMonad.Actions.Search       -- (20) some predefined web searches
import XMonad.Actions.WindowGo     -- (21) runOrRaise
import XMonad.Actions.UpdatePointer -- (22) auto-warp the pointer to the LR
                                    --      corner of the focused window
 
-- Prompts ---------------------------------------------------
 
import XMonad.Prompt                -- (23) general prompt stuff.
import XMonad.Prompt.Man            -- (24) man page prompt
import XMonad.Prompt.AppendFile     -- (25) append stuff to my NOTES file
import XMonad.Prompt.Shell          -- (26) shell prompt
import XMonad.Prompt.Input          -- (27) generic input prompt, used for
                                    --      making more generic search
                                    --      prompts than those in
                                    --      XMonad.Prompt.Search
 
-- Utilities -------------------------------------------------
 
import XMonad.Util.Loggers          -- (28) some extra loggers for my
                                    --      status bar
import XMonad.Util.EZConfig         -- (29) "M-C-x" style keybindings
import XMonad.Util.Scratchpad       -- (30) 'scratchpad' terminal
import XMonad.Util.Run              -- (31) for 'spawnPipe', 'hPutStrLn'
 
                                                                -- (31)
main = do h <- spawnPipe "dzen2 -x 580 -w 1340 -ta r -fg '#66fd66' -bg '#000' -e 'onstart=lower'"
          xmonad $ byorgeyConfig h                              -- (0)
 
byorgeyConfig h = myUrgencyHook $                               -- (2)
     defaultConfig
       {
         borderWidth        = 2
       , terminal           = "gnome-terminal --profile=XMonad"
       , workspaces         = myWorkspaces
       --, modMask            = mod4Mask  -- use Windoze key for mod
       , normalBorderColor  = "#003300"
       , focusedBorderColor = "#00ff00"
                                                                -- (22)
       , logHook            = myDynamicLog h -- >> updatePointer (Relative 1 1)
       , manageHook         = manageHook defaultConfig <+> myManageHook
       , layoutHook         = myLayoutHook
       , focusFollowsMouse  = True
 
         -- XXX fixme: comment!                                 -- (29)
       , startupHook        = return () >> checkKeymap (byorgeyConfig h) (myKeys h)
       }
       `additionalKeysP` (myKeys h)                             -- (29)
 
-- have urgent events flash a yellow dzen bar with black text
myUrgencyHook = withUrgencyHook dzenUrgencyHook                 -- (2)
    { args = ["-bg", "yellow", "-fg", "black"] }
 
-- define some custom workspace tags
myWorkspaces :: [String]
myWorkspaces = ["=", "1", "2", "3", "4", "5" ]
               ++ ["6", "7", "8", "9", "0", "-"]
               ++ ["\\", "Y", "U", "I","M"]
 
workspaceKeys = "=1234567890-\\yuim"

myDynamicLog h = dynamicLogWithPP $ byorgeyPP                   -- (1)
  { ppExtras = [ date "%a %b %d  %I:%M %p"                      -- (1,28)
               , loadAvg                                        -- (28)
               ]
  , ppOrder  = \(ws:l:t:exs) -> [t,l,ws]++exs                    -- (1)
  , ppOutput = hPutStrLn h                                      -- (1,31)
  , ppTitle  = shorten 180
  }
 

-- my custom keybindings.
myKeys h = myKeymap (byorgeyConfig h)
 
	-- q, w, e: screens
	-- r: reset (quit)
	-- t:
	-- y,u,i: workspaces
	-- o:
	-- p: run
	-- []\: workspaces
	-- a:
	-- s: screenshot
	-- dfg:
	-- hjkl: smaller / switch / larger
	-- ;': workspaces
myKeymap conf =
 
    -- mod-[1..9] %! Switch to workspace N
    -- mod-shift-[1..9] %! Move client to workspace N
    [ (m ++ "M-" ++ [k], windows $ f i)                         -- (0)
        | (i, k) <- zip (XMonad.workspaces conf) workspaceKeys -- (0)
        , (f, m) <- [(W.greedyView, ""), (W.shift, "S-")]       -- (0a)
    ]
		 ++

     [ (m ++ "M-" ++ [k], screenWorkspace i >>= flip whenJust (windows . f))
         | (i, k) <- zip [0..] ",." -- (0)
         , (f, m) <- [(W.view, ""), (W.shift, "S-")]       -- (0a)
     ]
 
    ++
    [ ("M-S-x", spawn $ terminal conf)                          -- (0)
    , ("M-S-b", spawn "urxvt-big")

    , ("S-M-r", io (exitWith ExitSuccess))
    , ("M-r", restart "xmonad" True)
 
		-- Volume controls
		, ("<XF86AudioLowerVolume>", spawn "amixer -c 0 set Master 1-") -- lower
		, ("<XF86AudioRaiseVolume>", spawn "amixer -c 0 set Master 1+") -- raise
		, ("<XF86AudioMute>", spawn "amixer -c 0 set Master toggle") -- mute

--		, ("M-r", screenWorkspace 2 >>= flip whenJust(windows . (W.view)) )
 
      -- in conjunction with manageHook, open a small temporary
      -- floating terminal
      -- fa
    , ("M-S-a", kill)                                           -- (0)
 
    -- some gap-toggling
    , ("M-g b", sendMessage $ ToggleStrut D)                    -- (3)
    , ("M-g <Down>", sendMessage $ ToggleStrut D)                    -- (3)
    , ("M-g t", sendMessage $ ToggleStrut U)                    --  "
    , ("M-g <Up>", sendMessage $ ToggleStrut U)                    -- (3)
    , ("M-g a", sendMessage $ ToggleStruts)                     --  "
 
    , ("M-g g", sendMessage $ ToggleGaps)
    ]
 
    ++
    [ ("M-g " ++ f ++ " <" ++ dk ++ ">", sendMessage $ m d)
        | (dk, d) <- [("L",L), ("D",D), ("U",U), ("R",R)]
        , (f, m)  <- [("v", ToggleGap), ("h", IncGap 10), ("f", DecGap 10)]
    ]
 
    ++
    -- rotate workspaces.
    [ ("M-C-<R>",   nextWS )                                    -- (16)
    , ("M-C-<L>",   prevWS )                                    --  "
    , ("M-S-<R>",   shiftToNext )                               --  "
    , ("M-S-<L>",   shiftToPrev )                               --  "
    , ("M-S-C-<R>", shiftToNext >> nextWS )                     --  "
    , ("M-S-C-<L>", shiftToPrev >> prevWS )                     --  "
    , ("M-<R>",     moveTo Next NonEmptyWS)                     --  "
    , ("M-<L>",     moveTo Prev NonEmptyWS)                     --  "
 
    -- expand/shrink windows
--    , ("M-r k", sendMessage MirrorExpand)                       -- (5)
--    , ("M-r j", sendMessage MirrorShrink)                       -- (5)
--    , ("M-r h", sendMessage Shrink)                             -- (0)
--    , ("M-r l", sendMessage Expand)                             -- (0)
 
    -- switch to previous workspace
    , ("M-z", toggleWS)                                         -- (16)
 
    -- lock the screen with xscreensaver
    , ("M-S-l", spawn "xscreensaver-command -lock")             -- (0)
 
    -- bainsh the pointer
    , ("M-b", warpToWindow 1 1)                                 -- (18)
 
    -- some programs to start with keybindings.
    , ("M-p f", runOrRaise "firefox-3.0" (className =? "Firefox-bin")) -- (21)
    , ("M-p g", spawn "gimp")                                   -- (0)
    , ("M-p b", spawn "banshee")                              -- (0)
    , ("M-p l", spawn "linuxdcpp")                                   -- (0)
    , ("M-p v", spawn "gvim")                       -- (0)
	  , ("M-s", spawn "shutter --selection")
 
    -- byorgeyConfig.
    , ("M-c x", spawn "em ~/.xmonad/xmonad.hs")                 -- (0)
    , ("M-c n", spawn "network-admin" >> spawn (terminal conf ++ " -e 'watch -n 0.5 ifconfig'"))
    , ("M-c v", spawn "gnome-volume-control --class=Volume")    -- (0)
    , ("M-c k", spawn "xkill")
 
    -- window navigation keybindings.
    , ("C-<R>", sendMessage $ Go R)                             -- (8)
    , ("C-<L>", sendMessage $ Go L)                             --  "
    , ("C-<U>", sendMessage $ Go U)                             --  "
    , ("C-<D>", sendMessage $ Go D)                             --  "
    , ("S-C-<R>", sendMessage $ Swap R)                         --  "
    , ("S-C-<L>", sendMessage $ Swap L)                         --  "
    , ("S-C-<U>", sendMessage $ Swap U)                         --  "
    , ("S-C-<D>", sendMessage $ Swap D)                         --  "
 
    -- switch to urgent window
    -- , ("M-s", focusUrgent)
 
    -- toggles: fullscreen, flip x, flip y, mirror, no borders
    , ("M-C-<Space>", sendMessage $ Toggle NBFULL)              -- (14)
    , ("M-C-x",       sendMessage $ Toggle REFLECTX)            -- (14,13)
    , ("M-C-y",       sendMessage $ Toggle REFLECTY)            -- (14,13)
    , ("M-C-m",       sendMessage $ Toggle MIRROR)              --  "
    , ("M-C-b",       sendMessage $ Toggle NOBORDERS)           --  "
 
    -- some prompts.
      -- ability to change the working dir for a workspace.
    , ("M-p d", changeDir myXPConfig)                           -- (11)
      -- man page prompt
    , ("M-p m", manPrompt myXPConfig)                           -- (24)
      -- add single lines to my NOTES file from a prompt.       -- (25)
    , ("M-p n", appendFilePrompt myXPConfig "/www/documents/NOTES")
    , ("M-p t", appendFilePrompt myXPConfig "/www/documents/TODO")
      -- shell prompt.
    , ("M-p s", shellPrompt myXPConfig)                         -- (26)
    , ("M-p p", spawn "exe=`dmenu_path | dmenu` && eval \"exec $exe\"") -- (0)
 
		-- firefox handies
    , ("M-f v", spawn "firefox https://vula.uct.ac.za/portal" >> viewWeb)
    , ("M-f u", spawn "firefox http://uct.ac.za" >> viewWeb)
    , ("M-f l", spawn "firefox http://www.lusion.co.za" >> viewWeb)
    , ("M-f a", spawn "firefox https://www.lusion.co.za/ahs/" >> viewWeb)
    , ("M-f g", spawn "firefox http://www.gmail.com" >> viewWeb)
    , ("M-f c", spawn "firefox http://www.google.com/calendar" >> viewWeb)
    , ("M-f n", spawn "firefox http://www.netvibes.com" >> viewWeb)
    , ("M-f f", spawn "firefox http://www.facebook.com" >> viewWeb)
    , ("M-/", mySearchMap $ myPromptSearch)            -- (19,20)
    , ("M-C-/", mySelectSearch)          -- (19,20)
 
 
    -- todos.                                                   -- (25)
    , ("M-C-t l", spawn "dzen-show-todos")                      -- (0)
    , ("M-C-t u", spawn "cp ~/misc/TODO.backup ~/misc/TODO ; dzen-show-todos")    ]
    ++                                                          -- (0)
    [ ("M-C-t " ++ [key], spawn ("del-todo " ++ show n ++ " ; dzen-show-todos"))
      | (key, n) <- zip "1234567890" [1..10]
    ]
 
-- Perform a search, using the given method, based on a keypress
mySearchMap method = method google 



siteQuickMap method = M.fromList $
       [ ((0, xK_v), method "https://vula.uct.ac.za")
       , ((0, xK_l), method "http://uct.ac.za")
       , ((0, xK_u), method "http://www.lusion.co.za")
       , ((0, xK_a), method "http://www.lusion.co.za/ahs")
       ]

openLink2 _ site = safeSpawn "firefox" site


-- Prompt search: get input from the user via a prompt, then
--   run the search in firefox and automatically switch to the "wb"
--   workspace
--myPromptSearch (SearchEngine _ site)
-- = inputPrompt myXPConfig "Search" ?+ \s ->                    -- (27)
--      (search "firefox" site s >> viewWeb)                      -- (0,20)
myPromptSearch (SearchEngine _ site)
  = inputPrompt myXPConfig "Search" ?+ \s ->                    -- (27)
      (search "firefox" site s >> viewWeb)                      -- (0,20)
 
-- Select search: do a search based on the X selection
mySelectSearch = selectSearch google >> viewWeb                -- (20)
 
-- Switch to the "web" workspace
viewWeb = windows (W.greedyView "1")                           -- (0,0a)
 
-- some nice colors for the prompt windows to match the dzen status bar.
myXPConfig = defaultXPConfig                                    -- (23)
    { fgColor = "#a8a3f7"
    , bgColor = "#3f3c6d"
    }
 
-- Set up a customized manageHook (rules for handling windows on
--   creation)
myManageHook :: ManageHook                                      -- (0)
myManageHook = composeAll $
                   -- auto-float certain windows
                 [ className =? c --> doCenterFloat | c <- myFloats ] -- (4)
                 ++
                 [ title =? t     --> doFloat | t <- myFloatTitles ]
                 ++
								 [ className =? w --> doF (W.shift "=") | w <- classChatShifts ]
                 ++
								 [ title =? w --> doF (W.shift "\\") | w <- videoShiftTitles ]
                 ++
								 [ className =? w --> doF (W.shift "\\") | w <- videoShifts ]
                 ++
								 [ className =? w --> doF (W.shift "M") | w <- musicShifts ]

								++
                   -- send certain windows to certain workspaces
                 [ 
                   -- unmanage docks such as gnome-panel and dzen
                   manageDocks                                     -- (3)
                   -- manage the scratchpad terminal window
                 , scratchpadManageHookDefault                     -- (30)
                 ]
    -- windows to auto-float
    where myFloats = [ "Volume", "Gnome-volume-control"
                     , "XClock"
                     , "Network-admin"
                     , "Xmessage"
                     , "gnome-search-tool"
                     ]
          myFloatTitles = ["Volume Control: HDA Intel (Alsa mixer)"]
          classChatShifts = ["Pidgin", "Skype"]
          musicShifts = ["Banshee","banshee-1"]
          videoShifts = ["Totem"]
          videoShiftTitles = ["VLC (XVideo output)"]
 
-- specify a custom layout hook.
myLayoutHook =
 
    -- automatically avoid overlapping my dzen status bar.
    avoidStrutsOn [U] $                                        -- (3)
 
    -- make manual gap adjustment possible.
    gaps (zip [U,D,L,R] (repeat 0)) $
 
    -- start all workspaces in my home directory, with the ability
    -- to switch to a new working dir.                          -- (10,11)
    workspaceDir "~" $
 
    modWorkspace "3" (workspaceDir "/www/snapbill") $
 
    -- navigate directionally rather than with mod-j/k
    -- what does this do? configurableNavigation (navigateColor "#ff00ff") $          -- (8)
 
    -- ability to toggle between fullscreen, reflect x/y, no borders,
    -- and mirrored.
    mkToggle1 NBFULL $                                  -- (14)
    mkToggle1 REFLECTX $                                -- (14,13)
    mkToggle1 REFLECTY $                                -- (14,13)
--    mkToggle1 NOBORDERS $                               --  "
    mkToggle1 MIRROR $                                  --  "
 
    -- borders automatically disappear for fullscreen windows.
    smartBorders $                                              -- (7)
 
    -- Only "Full" on movie workspace
    onWorkspaces ["\\"] (noBorders Full) $               -- (10,0)
		onWorkspaces ["="]  (imTiled) $

		onWorkspaces ["Y"] (gimp) $
 
    -- ...whereas all other workspaces start tall and can switch
    -- to a grid layout with the focused window magnified.
    myTiled ||| Full           -- resizable tall layout
 
-- use ResizableTall instead of Tall, but still call it "Tall".
myTiled = named "Tall" $ ResizableTall 1 0.03 0.5 []            -- (9,5)

imTiled = withIM (1%7) (Role "buddy_list") $ withIM (1%6) (Role "MainWindow") myTiled

gimp = withIM (0.11) (Role "gimp-toolbox") $ reflectHoriz $ withIM (0.15) (Role "gimp-dock") Full
