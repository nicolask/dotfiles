-- default desktop configuration for Fedora

import System.Posix.Env (getEnv)
-- import Data.Maybe (maybe)

import XMonad

import System.Exit
import XMonad.Util.Run (spawnPipe)
import XMonad.Layout.Accordion
import XMonad.Layout.Grid
import XMonad.Layout.NoBorders
import XMonad.Layout.Gaps
import XMonad.Prompt
import XMonad.Prompt.Man
import XMonad.Hooks.SetWMName

import XMonad.Hooks.DynamicLog
import XMonad.Util.Loggers

import System.IO
import qualified XMonad.StackSet as W 
import qualified Data.Map	 as M

myTerm		= "urxvt"

myModMask	= mod4Mask
myWorkspaces	= map show [1 .. 9 :: Int]

myBorderWidth	= 4
myNormalBorderColor	= "#000070"
myFocusedBorderColor	= "#cccccc"

myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $

	[
	-- start personal session

	-- launch a terminal
 	((modMask .|. shiftMask, 	xK_Return), spawn $ XMonad.terminal conf)

	-- launch dmenu
	, ((modMask .|. shiftMask, 	xK_p), spawn "dmenu_run -nb black -nf grey -sb darkcyan -sf white")

	-- prompt for input and launch man
	, ((modMask,		   	xK_F1), manPrompt defaultXPConfig)

	-- close focused window
	, ((modMask .|. shiftMask,	xK_c), kill)

	-- Quit xmonad
	, ((modMask .|. shiftMask, xK_q), io (exitWith ExitSuccess))

	-- Restart xmonad
	, ((modMask,			xK_q), broadcastMessage ReleaseResources >> restart "xmonad" True)

	-- rotate through layouts
	, ((modMask, 			xK_space ), sendMessage NextLayout)

	-- reset layouts to default
	, ((modMask .|. shiftMask,	xK_space), setLayout $ XMonad.layoutHook conf)

	-- Move focus to next window
	, ((modMask, 			xK_Tab), windows W.focusDown)
	, ((modMask, 			xK_j), windows W.focusDown)

	-- Move focus to previous window
	, ((modMask,			xK_k), windows W.focusUp)

	-- Move focus to master window
	, ((modMask,			xK_m), windows W.focusMaster)
	
	-- Swap the focused window and the master window
	, ((modMask,			xK_Return), windows W.swapMaster)

	-- Swap the focused window with the next window
	, ((modMask .|. shiftMask,	xK_j), windows W.swapDown)

	-- Swap the focused window with the previous window
	, ((modMask .|. shiftMask, 	xK_k), windows W.swapUp)

	-- Shrink the master area
	, ((modMask,			xK_h), sendMessage Shrink)

	-- Expand the master area
	, ((modMask,			xK_l), sendMessage Expand)
	
	-- Push window back into tiling
	, ((modMask, 			xK_t), withFocused $ windows . W.sink)
	
	-- Increment the number of windows in the master area
	, ((modMask,			xK_comma), sendMessage (IncMasterN 1))	

	-- Deincrement the number of windows in the master area
	, ((modMask, 			xK_period), sendMessage (IncMasterN (-1)))
 
	]
	++

	-- mod-[1..9] Switch to workspace N
	-- mod-shift-[1..9], Move client to workspace N
	[((m .|. modMask, k), windows $ f i)
	    | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
	    , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
	++

	-- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2 or 3
	-- mod-shift-{w,e,r}, Move client to screen 1, 2, 3
	[((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
	    | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
	    , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

myLayout = gaps [(U,18)] $ tiled ||| Mirror tiled ||| Accordion ||| noBorders (Full) ||| Grid
    where
	-- default tiling algorithm partitions the screen into two panes
	tiled	= Tall nmaster delta ratio
	
	-- The default number of windows in master pane
	nmaster	= 1

	-- Default proportion of screen occupied by master pane
	ratio 	= 1/2

	-- Percent of screen to increment by when resiszing panes
	delta 	= 3/100

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

main = do
	session <- getEnv "DESKTOP_SESSION"
	-- xmonad $ maybe desktopConfig desktop session
	xmonad $ defaultConfig
	 {
	 -- simple stuff
	    terminal		= myTerm,
	    modMask 		= myModMask,
	    workspaces		= myWorkspaces,
	    focusFollowsMouse 	= myFocusFollowsMouse,
	    normalBorderColor 	= myNormalBorderColor,
	    focusedBorderColor 	= myFocusedBorderColor,	

	-- key bindings
	    keys	= myKeys,

	    layoutHook	= myLayout,
	    startupHook = setWMName "LG3D"
	 }


