#!/usr/bin/env bash

xpra start-desktop \
  :14502 \
  --bind-tcp="0.0.0.0:14502" \
  --pulseaudio=yes \
  --printing=no \
  --use-display=auto \
  --start-child="gnome-session --session=gnome" \
  --systemd-run=no \
  --dbus-launch="--sh-syntax --close-stderr" \
  --exit-with-children \
  --daemon=no \
  --webcam=no \
  --attach=no \
  --start-env=GNOME_SHELL_SESSION_MODE=gnome \
  --start-env=XDG_CURRENT_DESKTOP=ubuntu:GNOME \
  --start-env=XDG_DATA_DIRS=/usr/share/ubuntu:/usr/local/share:/usr/share \
  --start-env=WAYLAND_DISPLAY= \
  --start-env=XDG_CONFIG_DIRS=/etc/xdg/xdg-ubuntu:/etc/xdg \
  --start-env=MESA_D3D12_DEFAULT_ADAPTER_NAME=NVIDIA \
  --av-sync=yes
