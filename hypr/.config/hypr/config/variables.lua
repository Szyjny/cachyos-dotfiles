-- Hyprland default apps

TERMINAL = "ghostty -e zsh -i -l -c 'env -u TMUX tmux new-session -As Main'"
FILE_MANAGER = "dolphin"
BROWSER = "zen-browser"
EDITOR = "gnome-text-editor --new-window"
CALCULATOR = "gnome-calculator"

-- Monitors
MONITOR1 = "eDP-1"
MONITOR2 = "HDMI-A-1"
MONITOR3 = ""
PRIMARY_MONITOR = MONITOR1

-- Workspaces
NUM_WPM = 3 -- Number of workspaces per monitor (Max 10)
