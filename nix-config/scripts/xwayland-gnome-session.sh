#!/usr/bin/env bash

nohup Xwayland \
  -host-grab \
  -br \
  -ac \
  -geometry 1920x1080 \
  -fullscreen \
  +iglx \
  :1 > /dev/null 2>&1 & # -dpi 117 \
env DISPLAY=:1 WAYLAND_DISPLAY= XDG_SESSION_TYPE=x11 gnome-session
pkill -9 Xwayland > /dev/null 2>&1
