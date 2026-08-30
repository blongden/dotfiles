#!/bin/sh
# tinty global hook — fan the applied scheme out to apps with no upstream
# template. tinty exports the palette as env vars:
#   $TINTY_SCHEME_PALETTE_BASE00_HEX_R / _G / _B   (2-char hex components)
#   $TINTY_SCHEME_ID  $TINTY_SCHEME_SLUG  $TINTY_SCHEME_VARIANT  $TINTY_THEME_OPERATION
#
# STUB: kitty is wired via its own [[items]] hook. waybar / wofi / dunst /
# sway borders / herdr / swaylock get added here next.

log=${XDG_CACHE_HOME:-$HOME/.cache}/tinty-fanout.log
b() { eval "printf '#%s%s%s' \"\$TINTY_SCHEME_PALETTE_BASE${1}_HEX_R\" \"\$TINTY_SCHEME_PALETTE_BASE${1}_HEX_G\" \"\$TINTY_SCHEME_PALETTE_BASE${1}_HEX_B\""; }

{
    echo "--- $(date '+%F %T')  op=$TINTY_THEME_OPERATION  scheme=$TINTY_SCHEME_ID"
    echo "base00=$(b 00)  base05=$(b 05)  base08=$(b 08)  base0D=$(b 0D)"
} >> "$log"
