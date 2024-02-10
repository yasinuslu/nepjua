#!/usr/bin/env bash
export DISPLAY=:14502
export GNOME_SHELL_SESSION_MODE=gnome
export XDG_CURRENT_DESKTOP=ubuntu:GNOME
export XDG_DATA_DIRS=/usr/share/ubuntu:/usr/local/share:/usr/share:/var/lib/snapd/desktop
export WAYLAND_DISPLAY=
export XDG_CONFIG_DIRS=/etc/xdg/xdg-ubuntu:/etc/xdg
export MESA_D3D12_DEFAULT_ADAPTER_NAME=NVIDIA
# export LIBGL_ALWAYS_INDIRECT=0

gnome-session --session=gnome
