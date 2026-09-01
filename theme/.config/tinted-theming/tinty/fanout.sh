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

# ---- hyprland : general.col.* + groupbar (Lua config) ------------------
hypr_block() {
    cat <<EOF
hl.config({
    general = {
        col = {
            active_border   = { colors = { "rgba(${BLUE}ee)", "rgba(${AQUA}ee)" }, angle = 45 },
            inactive_border = "rgba(${LINE}aa)",
        },
    },
    group = {
        groupbar = {
            col = { active = "rgba(${BLUE}ff)", inactive = "rgba(${BG2}ff)" },
            text_color          = "rgb($FG)",
            text_color_inactive = "rgb($DIM)",
        },
    },
})
EOF
}
[ -f "$CFG/hypr/hyprland.lua" ] && hypr_block | repl "$CFG/hypr/hyprland.lua" '-- tinty:start' '-- tinty:end'

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

# ---- GTK3 + GTK4/libadwaita : @define-color in ~/.config/gtk-{3,4}.0/gtk.css
gtk3_block() {
    cat <<EOF
@define-color theme_bg_color          #$BG;
@define-color theme_fg_color          #$FG;
@define-color theme_base_color        #$BG;
@define-color theme_text_color        #$FG;
@define-color theme_selected_bg_color #$BLUE;
@define-color theme_selected_fg_color #$BG;
@define-color insensitive_bg_color    #$BG2;
@define-color insensitive_fg_color    #$DIM;
@define-color insensitive_base_color  #$BG;
@define-color borders                 #$LINE;
@define-color unfocused_borders       #$LINE;
@define-color warning_color           #$YELLOW;
@define-color error_color             #$RED;
@define-color success_color           #$GREEN;
@define-color wm_bg                   #$BG;
@define-color menu_color              #$BG2;
@define-color popover_bg_color        #$BG2;
@define-color content_view_bg         #$BG;
@define-color tooltip_text            #$FG;
@define-color tooltip_border          #$LINE;
EOF
}
gtk4_block() {
    cat <<EOF
@define-color window_bg_color     #$BG;
@define-color window_fg_color     #$FG;
@define-color view_bg_color       #$BG;
@define-color view_fg_color       #$FG;
@define-color headerbar_bg_color  #$BG2;
@define-color headerbar_fg_color  #$FG;
@define-color headerbar_border_color #$LINE;
@define-color headerbar_backdrop_color #$BG;
@define-color headerbar_shade_color rgba(0,0,0,0.36);
@define-color sidebar_bg_color    #$BG2;
@define-color sidebar_fg_color    #$FG;
@define-color sidebar_backdrop_color #$BG;
@define-color sidebar_shade_color rgba(0,0,0,0.36);
@define-color card_bg_color       #$BG2;
@define-color card_fg_color       #$FG;
@define-color card_shade_color    rgba(0,0,0,0.36);
@define-color dialog_bg_color     #$BG2;
@define-color dialog_fg_color     #$FG;
@define-color popover_bg_color    #$BG2;
@define-color popover_fg_color    #$FG;
@define-color thumbnail_bg_color  #$BG2;
@define-color thumbnail_fg_color  #$FG;
@define-color borders             #$LINE;
@define-color accent_bg_color     #$BLUE;
@define-color accent_fg_color     #$BG;
@define-color accent_color        #$BLUE;
@define-color destructive_bg_color #$RED;
@define-color destructive_fg_color #$BG;
@define-color destructive_color   #$RED;
@define-color success_bg_color    #$GREEN;
@define-color success_fg_color    #$BG;
@define-color success_color       #$GREEN;
@define-color warning_bg_color    #$YELLOW;
@define-color warning_fg_color    #$BG;
@define-color warning_color       #$YELLOW;
@define-color error_bg_color      #$RED;
@define-color error_fg_color      #$BG;
@define-color error_color         #$RED;
EOF
}
[ -f "$CFG/gtk-3.0/gtk.css" ] && gtk3_block | repl "$CFG/gtk-3.0/gtk.css" '/\* tinty:start \*/' '/\* tinty:end \*/'
[ -f "$CFG/gtk-4.0/gtk.css" ] && gtk4_block | repl "$CFG/gtk-4.0/gtk.css" '/\* tinty:start \*/' '/\* tinty:end \*/'

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
button.suggested-action,
button.suggested-action:hover {
  background-color: #$BG2;
  border-color: #$YELLOW;
}
button.suggested-action label {
  color: #$YELLOW;
  font-weight: bold;
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
hyprctl reload               >/dev/null 2>&1 || true
dunstctl reload              2>/dev/null || true
herdr server reload-config   >/dev/null 2>&1 || true
# kitty / tmux / nvim each have their own [[items]] hook.
# GTK: a settings poke makes GTK3 apps re-read gtk.css live; GTK4/libadwaita
# apps only pick up the new colours on restart.
gsettings set org.gnome.desktop.interface color-scheme prefer-dark 2>/dev/null || true
if command -v dbus-send >/dev/null 2>&1; then
    dbus-send --session --type=signal /org/gtk/Settings \
        org.gtk.Settings.SettingsChanged string:"gtk-theme-name" 2>/dev/null || true
fi

echo "    ok  bg=#$BG fg=#$FG accent=#$YELLOW"
