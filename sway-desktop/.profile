. "$HOME/.atuin/bin/env"

if [ -z "${XDG_SESSION_TYPE}" ] && ["$XDG_SESSION_TYPE" == "wayland" ]; then
	export MOZ_ENABLE_WAYLAND=1
fi

if uwsm check may-start && uwsm select; then
  exec uwsm start default
fi

export QT_QPA_PLATFORMTHEME=qt6ct

