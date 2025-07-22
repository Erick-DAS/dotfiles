 if [[ -z $DISPLAY && -z $WAYLAND_DISPLAY && "$XDG_SESSION_DESKTOP" != "Hyprland" ]]; then
 	export __GLX_VENDOR_LIBRARY_NAME=nvidia
 	export WLR_NO_HARDWARE_CURSORS=1
 	export QT_QPA_PLATFORM=wayland
 	export XDG_SESSION_TYPE=wayland
 	export XDG_CURRENT_DESKTOP=sway
 	exec sway --unsupported-gpu
 fi

# Created by `pipx` on 2025-07-16 19:51:55
export PATH="$PATH:/home/das/.local/bin"
