-- ~/.config/hypr/hyprland.lua
-- STOCK-LEANING TRIAL CONFIG. Stripped back to Hyprland 0.56.2 defaults to feel
-- the out-of-the-box look & feel and keybinds. The look/feel + animation +
-- keybind + window-rule blocks below are copied VERBATIM from the shipped
-- example at /usr/share/hypr/hyprland.lua.
--
-- Only kept from the sway port (hardware / infra, not "feel"):
--   * this laptop's monitors (eDP-1 + Dell-dock catch-all)
--   * GB keyboard + caps:escape + touchpad tweaks
--   * autostart of waybar / dunst / cliphist / wallpaper
--
-- Substitutions where a stock program isn't installed here:
--   * fileManager: dolphin -> kitty
--   * menu:        hyprlauncher -> wofi --show drun
--
-- Full customised config preserved at hyprland.lua.customized.bak
-- Wiki: https://wiki.hypr.land/

-------------------
----- MONITORS ----
-------------------
-- Ported from ~/.config/kanshi/config (kanshi no longer runs under hypr).
-- eDP-1 is pinned at the origin so undocking is seamless; DP-2 sits to its
-- LEFT and shifted up so the bottom edges line up (eDP-1 bottom = 1080,
-- DP-2 bottom = -1080 + 2160 = 1080), matching the old kanshi "docked" profile.
-- The dock's USB-C link is 2-lane, so 4K tops out at 30Hz (see kanshi notes);
-- `preferred` would pick the same mode if the explicit one ever fails to match.
hl.monitor({ output = "eDP-1", mode = "1920x1080",    position = "0x0",         scale = 1 })
hl.monitor({ output = "DP-2",  mode = "3840x2160@30", position = "-3840x-1080", scale = 1 })
hl.monitor({ output = "",      mode = "preferred",    position = "auto",        scale = "auto" }) -- any other output

---------------------
----- MY PROGRAMS ----
---------------------
local terminal    = "kitty"
local browser     = "chromium"
local fileManager = "kitty --class yazi -e yazi"  -- yazi TUI (stock: dolphin, not installed)
local menu        = "wofi --show drun"            -- stock: hyprlauncher (not installed)

-------------------
----- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP GNOME_KEYRING_CONTROL SSH_AUTH_SOCK")  -- keyring vars: pam_gnome_keyring (greetd) starts+unlocks the daemon; propagate its socket to dbus/systemd activation
    hl.exec_cmd("hyprpaper")                                             -- wallpaper (~/.config/hypr/hyprpaper.conf); replaced swaybg + Azote
    hl.exec_cmd("waybar -c ~/.config/waybar/config-hyprland")
    hl.exec_cmd("~/.config/waybar/scripts/wattson-refresh.sh")   -- nudge custom/wattson ~30s past each :00/:30 Agile boundary
    hl.exec_cmd("command -v eww >/dev/null && eww daemon")   -- widget daemon (wattson popover; opened from the waybar module)
    hl.exec_cmd("dunst")
    hl.exec_cmd("wl-paste --type text  --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("hypridle")   -- idle: screensaver @5min, dpms off @30min (~/.config/hypr/hypridle.conf)

    -- tray / daemons  (ported from ~/.config/sway/autostart.sh)
    hl.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ 20%")   -- one-time level
    hl.exec_cmd("/usr/libexec/polkit-mate-authentication-agent-1")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("kdeconnect-indicator")
    hl.exec_cmd("~/.config/kdeconnect-autoopen.sh")   -- auto-open files received via KDE Connect (HEIC->JPG)
    hl.exec_cmd("udiskie --smart-tray --file-manager 'kitty --class yazi -e yazi'")
    hl.exec_cmd("protonmail-bridge --noninteractive")   -- local IMAP :1143 / SMTP :1025 for Proton Mail (reuses stored session)

    -- workspace apps
    hl.exec_cmd("kitty --class scratchpad")         -- -> special:magic (window rule)
    hl.exec_cmd("~/.config/hypr/herdr-claude.sh")   -- kitty+herdr+Claude -> ws1 (window rule)
    hl.exec_cmd("~/.config/hypr/startup-apps.sh")   -- browser on ws2, Discord/Proton/WhatsApp tabbed on ws3, then back to ws1
end)

--------------------------------
----- ENVIRONMENT VARIABLES ----
--------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
-- plain-Qt apps (VLC) get an explicit qt5ct palette; Dolphin/KF6 read kdeglobals too
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")

---------------
----- INPUT ----
---------------
hl.config({
    input = {
        kb_layout    = "gb",
        kb_model     = "pc105",
        kb_options   = "caps:escape",
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad = {
            natural_scroll       = true,
            tap_to_click         = true,
            disable_while_typing = true,
            clickfinger_behavior = true,
        },
    },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-----------------------
----- LOOK AND FEEL ----  (stock /usr/share/hypr/hyprland.lua; gaps + border tightened)
-----------------------
hl.config({
    general = {
        gaps_in  = 2,   -- stock 5
        gaps_out = 6,   -- stock 20

        border_size = 1,   -- stock 2

        -- border colours: see the THEME block below (base16, fanned out by tinty)

        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24.21279333 })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  spring = "easy",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick" })

hl.config({
    dwindle = {
        preserve_split = true,
    },
})

hl.config({
    master = {
        new_status = "master",
    },
})

-------------------
-----  GROUPS  ----  (tabbed window groups — used by startup-apps.sh on ws3)
-------------------
-- Stock groupbar is ~40%-alpha yellow on transparent with 8px text = invisible.
-- NOTE: Hyprland 0.56.2 does NOT paint the segment fill opaque even with
-- gradients=false + a full-alpha col — it only draws the title text + the
-- indicator line, so the wallpaper (and waybar, on the right) show through.
-- gradients=true at least gives the active/left segments a visible tint.
hl.config({
    group = {
        groupbar = {
            col = {
                active   = "rgba(2a9fd6ff)",
                inactive = "rgba(3c3c3cff)",
            },
            text_color          = "rgb(ffffff)",
            text_color_inactive = "rgb(cccccc)",
            font_size           = 11,
            height              = 24,
            indicator_height    = 2,
            gradients           = true,
        },
    },
})

----------------
-----  MISC  ----
----------------
hl.config({
    misc = {
        force_default_wallpaper = -1,    -- stock anime mascot (only visible if hyprpaper isn't running)
        disable_hyprland_logo   = false,
        -- Safety net for the hypridle DPMS-off stage: any input force-wakes the
        -- panel even if hypridle's `on-resume` fails to fire. See hypridle.conf.
        key_press_enables_dpms  = true,
        mouse_move_enables_dpms = true,
    },
})

-----------------
-----  THEME  ----  base16 palette, fanned out by tinty
-----------------
-- Body rewritten by ~/.config/tinted-theming/tinty/fanout.sh on every
-- `tinty apply`. Comes after LOOK AND FEEL + GROUPS so it overrides their
-- col values. `hyprctl reload` re-reads this file and applies it live.
-- tinty:start — rewritten by ~/.config/tinted-theming/tinty/fanout.sh
hl.config({
    general = {
        col = {
            active_border   = { colors = { "rgba(81a2beee)", "rgba(8abeb7ee)" }, angle = 45 },
            inactive_border = "rgba(373b41aa)",
        },
    },
    group = {
        groupbar = {
            col = { active = "rgba(81a2beff)", inactive = "rgba(282a2eff)" },
            text_color          = "rgb(c5c8c6)",
            text_color_inactive = "rgb(969896)",
        },
    },
})
-- tinty:end

---------------------
----- KEYBINDINGS ----  (verbatim from /usr/share/hypr/hyprland.lua)
---------------------
local mainMod = "SUPER"

hl.bind(mainMod .. " + Return",         hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd(browser .. " --new-window"))
local closeWindowBind = hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))  -- graceful; falls back to hard exit (Lua-config dispatch syntax)
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))  -- yazi (stock: dolphin)
hl.bind(mainMod .. " + period",         hl.dsp.exec_cmd("rofimoji --selector wofi --action type"))
hl.bind(mainMod .. " + SHIFT + period", hl.dsp.exec_cmd("rofimoji --selector wofi --action copy"))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))  -- not bound in stock hyprland.lua
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("cliphist list | wofi --dmenu | cliphist decode | wl-copy"))  -- clipboard history (was: pseudo)
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + slash", hl.dsp.exec_cmd("~/.config/hypr/keybinds.sh"))  -- keybinding cheatsheet

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- move window in-layout (not bound in stock hyprland.lua)
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

--------------------------------
----- WINDOWS AND WORKSPACES ----  (verbatim from /usr/share/hypr/hyprland.lua)
--------------------------------
local suppressMaximizeRule = hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

------------------------------------------------------------------------
-- Per-app workspace placement  (ported from sway assign / autostart.sh)
--   herdr -> ws1,  scratchpad -> special:magic  (persistent rules, safe because
--   each is only ever spawned once, by autostart).
--   The startup browser (ws2) and the ws3 comms trio are placed by
--   startup-apps.sh instead of a rule, so SUPER+SHIFT+Return still opens a
--   browser on whatever workspace is focused (matches the old sway behaviour).
------------------------------------------------------------------------
hl.window_rule({ name = "ws1-herdr",  match = { class = "^(herdr)$" },      workspace = "1 silent" })
hl.window_rule({ name = "scratchpad", match = { class = "^(scratchpad)$" }, workspace = "special:magic silent" })

-- Fullscreen the terminal screensaver (launched by hypridle -> screensaver.sh)
hl.window_rule({ name = "screensaver", match = { class = "^(screensaver)$" }, fullscreen = true })

-- Float rules  (ported from sway `for_window … floating enable`; Hyprland has no
-- window_role matcher, so the sway pop-up/dialog role rules are dropped — it
-- floats most transients on its own).
local floatClasses = {
    "^(1Password)$",
    "^(pavucontrol|org[.]pulseaudio[.]pavucontrol|Pavucontrol)$",
    "^(nm-connection-editor)$",
    "^(blueman-manager)$",
    "^([Gg]alculator)$",
    "^(GParted)$",
    "^(Lxappearance)$",
    "^([Ss]imple-scan)$",
    "^(.*[Ss]ystem-config-printer.*)$",
    "^(.*[Vv]irtual[Bb]ox.*)$",
}
for _, c in ipairs(floatClasses) do
    hl.window_rule({ match = { class = c }, float = true })
end
hl.window_rule({ match = { title = "^(alsamixer)$" },     float = true })
hl.window_rule({ match = { title = "^(File Transfer.*)$" }, float = true })

hl.bind("SUPER + minus", hl.dsp.workspace.toggle_special("magic"))

-- Tabbed-group navigation (the ws3 comms group)
hl.bind("SUPER + Tab",         hl.dsp.group.next())
hl.bind("SUPER + SHIFT + Tab", hl.dsp.group.prev())
hl.bind("SUPER + G",           hl.dsp.group.toggle())   -- group/ungroup the focused window

-- Screenshots  (ported from sway config; scripts live in ~/.config/sway/,
-- screenshot.sh now branches swaymsg/hyprctl on HYPRLAND_INSTANCE_SIGNATURE)
local shot = "~/.config/sway/screenshot.sh"
hl.bind("Print",                       hl.dsp.exec_cmd("~/.config/sway/screenshot-menu.sh"))
hl.bind("SUPER + Print",               hl.dsp.exec_cmd(shot .. " window"))
hl.bind("SHIFT + Print",               hl.dsp.exec_cmd(shot .. " region"))
hl.bind("CTRL + Print",                hl.dsp.exec_cmd(shot .. " full-clip"))
hl.bind("CTRL + SUPER + Print",        hl.dsp.exec_cmd(shot .. " window-clip"))
hl.bind("CTRL + SHIFT + Print",        hl.dsp.exec_cmd(shot .. " region-clip"))
hl.bind("SUPER + SHIFT + Print",       hl.dsp.exec_cmd(shot .. " region-edit"))
hl.bind("CTRL + SUPER + SHIFT + Print", hl.dsp.exec_cmd(shot .. " full-edit"))

-- Push-to-talk dictation (pw-record + whisper.cpp + wtype; no sway deps).
-- Press to start recording, press again to transcribe + type into focused window.
hl.bind("SUPER + grave", hl.dsp.exec_cmd("~/.config/hypr/dictate-groq.sh"))  -- Groq whisper-large-v3-turbo (cleanup off; DICTATE_CLEANUP=1 to enable)
