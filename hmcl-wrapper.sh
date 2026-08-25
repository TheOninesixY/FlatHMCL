#!/bin/bash
export GDK_BACKEND=wayland,x11
exec /app/bin/hmcl-bin "$@"