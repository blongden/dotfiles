#!/bin/sh
# tinty global hook — fan the applied base16 scheme out to the apps that have
# no upstream tinty template. tinty exports the palette as env vars:
#   $TINTY_SCHEME_PALETTE_BASE00_HEX_R / _G / _B   (2-char hex components)
#   $TINTY_SCHEME_ID  $TINTY_SCHEME_SLUG  $TINTY_THEME_OPERATION
#
# Each target config carries a  tinty:start / tinty:end  marker pair (dunst is
# section-keyed instead). We rewrite only what's between the markers, then
# reload the app. kitty is handled by its own [[items]] hook, not here.
set -u

log=${XDG_CACHE_HOME:-$HOME/.cache}/tinty-fanout.log
exec 2>>"$log"
echo "--- $(date '+%F %T')  op=${TINTY_THEME_OPERATION:-?}  scheme=${TINTY_SCHEME_ID:-?}"

# ---- palette -----------------------------------------------------------------
hx() { eval "printf '%s%s%s' \"\$TINTY_SCHEME_PALETTE_BASE${1}_HEX_R\" \"\$TINTY_SCHEME_PALETTE_BASE${1}_HEX_G\" \"\$TINTY_SCHEME_PALETTE_BASE${1}_HEX_B\""; }
BG=$(hx 00); BG2=$(hx 01); LINE=$(hx 02); DIM=$(hx 03); FG=$(hx 05)
RED=$(hx 08); ORANGE=$(hx 09); YELLOW=$(hx 0A); GREEN=$(hx 0B); AQUA=$(hx 0C); BLUE=$(hx 0D); PURPLE=$(hx 0E)

CFG=${XDG_CONFIG_HOME:-$HOME/.config}

# ---- replace text between two marker lines (markers kept) -------------------
# usage:  printf '%s\n' "...new body..." | repl <file> <start-regex> <end-regex>
repl() {
    _f=$1; _s=$2; _e=$3; _new=$(cat); _tmp=$(mktemp)
    awk -v s="$_s" -v e="$_e" -v new="$_new" '
        $0 ~ s { print; print new; skip=1; next }
        $0 ~ e { skip=0; print; next }
        !skip  { print }
    ' "$_f" > "$_tmp" && cat "$_tmp" > "$_f" && rm -f "$_tmp"
}   # cat >, not mv — mv would replace a stow symlink with a plain file

# ---- waybar + wofi : GTK CSS @define-color block ---------------------------
css_block() {
    cat <<EOF
@define-color bg     #$BG;
@define-color bg2    #$BG2;
@define-color line   #$LINE;
@define-color dim    #$DIM;
@define-color fg     #$FG;
@define-color red    #$RED;
@define-color orange #$ORANGE;
@define-color yellow #$YELLOW;
@define-color green  #$GREEN;
@define-color aqua   #$AQUA;
@define-color blue   #$BLUE;
@define-color purple #$PURPLE;
EOF
}
for f in "$CFG/waybar/style.css" "$CFG/wofi/style.css"; do
    [ -f "$f" ] && css_block | repl "$f" 'tinty:start' 'tinty:end'
done

# ---- sway : client.* window colours --------------------------------------
sway_block() {
    cat <<EOF
# window border colours — managed by tinty
#                       border   bg       text     indicator child_border
client.focused          #$BLUE  #$BG  #$FG  #$AQUA   #$BLUE
client.focused_inactive #$BLUE  #$BG  #$FG  #$BLUE   #$LINE
client.unfocused        #$LINE  #$BG  #$DIM  #$LINE   #$LINE
client.urgent           #$RED  #$BG  #$FG  #$RED   #$RED
client.placeholder      #000000  #$BG  #$FG  #000000   #$BG
client.background       #$BG
EOF
}
[ -f "$CFG/sway/config" ] && sway_block | repl "$CFG/sway/config" '### tinty:start' '### tinty:end'

# ---- herdr : [theme.custom] tokens --------------------------------------
herdr_block() {
    cat <<EOF
sidebar_bg    = "#$BG"
active_row_bg = "#$BG2"
selection_bg  = "#$LINE"
accent        = "#$YELLOW"
red           = "#$RED"
green         = "#$GREEN"
EOF
}
[ -f "$CFG/herdr/config.toml" ] && herdr_block | repl "$CFG/herdr/config.toml" '# tinty:start' '# tinty:end'

# ---- swaylock : key=color (no #, alpha suffixes kept) -------------------
swaylock_block() {
    cat <<EOF
ring-color=$BG
key-hl-color=$BLUE
line-color=00000000
inside-color=${BG}cc
separator-color=00000000
text-color=$FG
EOF
}
[ -f "$CFG/swaylock/config" ] && swaylock_block | repl "$CFG/swaylock/config" '# tinty:start' '# tinty:end'

# ---- dunst : section-keyed (no markers) --------------------------------
dunst_rc="$CFG/dunst/dunstrc"
if [ -f "$dunst_rc" ]; then
    _tmp=$(mktemp)
    awk -v bg="#$BG" -v fg="#$FG" -v dim="#$DIM" -v line="#$LINE" \
        -v blue="#$BLUE" -v yellow="#$YELLOW" -v red="#$RED" '
        /^\[/ { sec=$0 }
        {
            key=$1
            if (sec=="[global]" && key=="frame_color")        { print "    frame_color = \"" line "\""; next }
            if (sec=="[urgency_low]") {
                if (key=="background")  { print "    background = \"" bg  "\""; next }
                if (key=="foreground")  { print "    foreground = \"" dim "\""; next }
                if (key=="frame_color") { print "    frame_color = \"" line "\""; next }
                if (key=="highlight")   { print "    highlight = \"" dim "\""; next }
            }
            if (sec=="[urgency_normal]") {
                if (key=="background")  { print "    background = \"" bg  "\""; next }
                if (key=="foreground")  { print "    foreground = \"" fg  "\""; next }
                if (key=="frame_color") { print "    frame_color = \"" blue "\""; next }
                if (key=="highlight")   { print "    highlight = \"" yellow "\""; next }
            }
            if (sec=="[urgency_critical]") {
                if (key=="background")  { print "    background = \"" bg "\""; next }
                if (key=="foreground")  { print "    foreground = \"" yellow "\""; next }
                if (key=="frame_color") { print "    frame_color = \"" red "\""; next }
                if (key=="highlight")   { print "    highlight = \"" red "\""; next }
            }
            print
        }
    ' "$dunst_rc" > "$_tmp" && cat "$_tmp" > "$dunst_rc" && rm -f "$_tmp"
fi

# ---- ReGreet greeter : dotfiles copy is user-owned; /etc needs root ----
# Rewrites ~/dotfiles/greetd/etc/greetd/regreet.css between markers, then
# tries a passwordless push to /etc. Add this to sudoers for the push to
# work unattended (visudo -f /etc/sudoers.d/greetd-css):
#   ben ALL=(root) NOPASSWD: /usr/bin/install -m644 /home/ben/dotfiles/greetd/etc/greetd/regreet.css /etc/greetd/regreet.css
greeter_css="$HOME/dotfiles/greetd/etc/greetd/regreet.css"
greeter_block() {
    cat <<EOF
window {
  background-color: #$BG;
  color: #$FG;
  font-family: "Iosevka Nerd Font", "Iosevka", monospace;
}
entry {
  background-color: #$BG2;
  color: #$FG;
  border: 1px solid #$LINE;
  border-radius: 4px;
  padding: 8px 10px;
  caret-color: #$YELLOW;
}
entry:focus-within { border-color: #$YELLOW; }
button {
  background-image: none;
  background-color: #$BG2;
  color: #$FG;
  border: 1px solid #$LINE;
  border-radius: 4px;
}
button:hover { background-color: #$LINE; }
button.suggested-action {
  background-color: #$YELLOW;
  color: #$BG;
  border-color: #$YELLOW;
}
dropdown > button { background-color: #$BG2; color: #$FG; }
label { color: #$FG; }
EOF
}
if [ -f "$greeter_css" ]; then
    greeter_block | repl "$greeter_css" '/\* tinty:start \*/' '/\* tinty:end \*/'
    sudo -n install -m644 "$greeter_css" /etc/greetd/regreet.css 2>/dev/null || true
fi

# ---- reloads -----------------------------------------------------------
pkill -SIGUSR2 waybar        2>/dev/null || true
swaymsg reload               >/dev/null 2>&1 || true
dunstctl reload              2>/dev/null || true
herdr server reload-config   >/dev/null 2>&1 || true
# kitty / tmux / nvim each have their own [[items]] hook

echo "    ok  bg=#$BG fg=#$FG accent=#$YELLOW"
