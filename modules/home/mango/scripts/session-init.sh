#!/usr/bin/env bash
set -euo pipefail

dbus-update-activation-environment --systemd \
    DISPLAY \
    WAYLAND_DISPLAY \
    XDG_CURRENT_DESKTOP \
    XDG_SESSION_DESKTOP \
    XDG_SESSION_TYPE \
    NIXOS_OZONE_WL

systemctl --user reset-failed
systemctl --user start mango-session.target
