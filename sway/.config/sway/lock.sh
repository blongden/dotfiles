#!/bin/sh
# swaylock — replaces the old `convert ... | i3lock --raw` pipe.
# swaylock reads the image directly, no imagemagick needed.
exec swaylock \
    --image "$HOME/Pictures/Backdrops/11131168.jpg" \
    --scaling fill \
    --indicator-caps-lock \
    --show-failed-attempts \
    --ring-color 1d1f21 \
    --key-hl-color 81a2be \
    --line-color 00000000 \
    --inside-color 1d1f21cc \
    --separator-color 00000000 \
    --text-color c5c8c6
