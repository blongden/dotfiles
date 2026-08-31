# dotfiles

Personal dotfiles for a Debian **testing** laptop running **sway / Wayland**
(migrated from i3/X11). Deployed with [GNU Stow](https://www.gnu.org/software/stow/).

## Layout

Each top-level directory is a stow *package* whose contents mirror `$HOME`:

| package | deploys | notes |
|---|---|---|
| `zsh` `git` `tmux` `nvim` | `~/.zshrc`, `~/.zshenv`, `~/.gitconfig`, `~/.config/git/ignore`, `~/.tmux.conf`, `~/.config/nvim/init.vim` | `.zshenv` keeps tool history/state out of `$HOME` (XDG) |
| `kitty` | `~/.config/kitty/kitty.conf` | Tomorrow Night theme appended |
| `sway` | `~/.config/sway/` | config + `*.sh` helpers |
| `screensaver` | `~/.config/screensaver/` | compositor-agnostic tte terminal screensaver (`screensaver.sh` + `art/*.txt`); called by `sway/idle.sh` and `hypr/hypridle.conf` at 5 min idle |
| `hypr` | `~/.config/hypr/{hyprland.lua,hypridle.conf}`, `~/.config/kdeconnect-autoopen.sh` | Hyprland trial, side-by-side with sway. **Partial** — the Lua config also sources `keybinds.sh` / `startup-apps.sh` / `hyprpaper.conf` / `dictate*.sh`, not tracked yet. `hypridle`: tte screensaver @5min, DPMS off @30min. `kdeconnect-autoopen.sh` (launched from both hypr + sway autostart) opens files received via KDE Connect, converting HEIC→JPG with `heic2img` |
| `waybar` `wofi` | `~/.config/{waybar,wofi}/` | Tomorrow Night, Iosevka Nerd Font; `rofimoji` (apt) drives wofi for the `$mod+.` emoji picker. waybar has a `custom/claude` module (session/weekly Claude Code quota from `api.anthropic.com/api/oauth/usage`) |
| `dunst` | `~/.config/dunst/dunstrc` | Tomorrow Night; self-contained (dunst reads one config, no merge) |
| `theme` | `~/.config/tinted-theming/tinty/` | tinty config + `fanout.sh`; one base16 palette → kitty, tmux, nvim, waybar, wofi, sway borders, herdr, dunst. `tinty apply <scheme>` to switch. kitty/tmux/nvim via upstream templates + an `include`/`source`; the rest written by `fanout.sh` from tinty's `$TINTY_SCHEME_PALETTE_*` env vars |
| `kanshi` | `~/.config/kanshi/` | output profiles (docked = DP-2 4K@30) |
| `gammastep` | `~/.config/gammastep/` | off by default |
| `greetd` | `/etc/greetd/{config.toml,sway-config,regreet.toml,regreet.css}` + tmpfiles | **not stowed** (root-owned), install by hand (step 4). ReGreet (GTK4) hosted by a throwaway sway for GB keyboard + wallpaper; tuigreet command kept in config.toml's header as fallback |
| `herdr` | `~/.config/herdr/config.toml` | multiplexer for coding agents; `--no-folding` (dir holds runtime state) |
| `desktop` | `~/.config/mimeapps.list`, `~/.local/share/applications/*.desktop` | chromium as default browser; custom launchers (screenshot, sway-keybindings, yazi, mc, downloads); `code`/`discord`/`Claude` overrides add `--ozone-platform-hint=auto` for native Wayland; `--no-folding` |

## Rebuild on a new machine

```sh
# 1. packages
sudo apt update
sudo apt install --no-install-recommends $(grep -vE '^\s*#|^\s*$' packages.txt)

# 2. dotfiles
git clone git@github.com:blongden/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow zsh git tmux nvim kitty sway screensaver hypr waybar wofi dunst theme kanshi gammastep bin
stow --no-folding herdr desktop

# 3. by-hand pieces (not in apt)
pipx install terminaltexteffects                                   # `tte` screensaver engine
mkdir -p ~/.local/bin && curl -fsSL -o ~/.local/bin/herdr \
  https://github.com/herdrdev/herdr/releases/latest/download/herdr-linux-x86_64 \
  && chmod +x ~/.local/bin/herdr
mkdir -p ~/.local/share/fonts                                      # Iosevka Nerd Font ->
#   copy iosevka_nerd_font.ttf into ~/.local/share/fonts/ then: fc-cache -f
curl -fsSL -o ~/.config/nvim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# tinty — one-palette theming (prebuilt binary, not in Debian). After stow:
curl -fsSL https://github.com/tinted-theming/tinty/releases/latest/download/tinty-x86_64-unknown-linux-musl.tar.gz \
  | tar xz -C /tmp && install -m755 /tmp/tinty ~/.local/bin/tinty
tinty install && tinty apply base16-tomorrow-night      # clones templates, themes everything

# ReGreet — greetd greeter (GTK4). Not in Debian; build from source.
#   build deps: cargo cage libgtk-4-dev libadwaita-1-dev  (in packages.txt)
git clone --depth 1 https://github.com/rharish101/ReGreet /tmp/ReGreet \
  && ( cd /tmp/ReGreet && cargo build --release ) \
  && sudo install -m755 /tmp/ReGreet/target/release/regreet /usr/local/bin/regreet

# Tailscale (Tailscale's own apt repo, not Debian; drives the waybar module)
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale set --operator=$USER                 # non-root `tailscale` CLI
sudo tailscale up --accept-routes                   # opens a browser to log in
#   subnet routes / exit node live on the homeassistant node (HA OS add-on
#   a0d7b954_tailscale), approved in the login.tailscale.com admin console.

# 4. greetd + ReGreet greeter (system files, not stow-managed)
sudo install -m600 -o root -g root greetd/etc/greetd/config.toml    /etc/greetd/config.toml
sudo install -m644 -o root -g root greetd/etc/greetd/sway-config    /etc/greetd/sway-config
sudo install -m644 -o root -g root greetd/etc/greetd/regreet.toml   /etc/greetd/regreet.toml
sudo install -m644 -o root -g root greetd/etc/greetd/regreet.css    /etc/greetd/regreet.css
sudo install -m644 -o root -g root greetd/usr/lib/tmpfiles.d/regreet.conf /usr/lib/tmpfiles.d/regreet.conf
sudo cp ~/Pictures/Backdrops/11131112.jpg /etc/greetd/backdrop.jpg && sudo chmod 644 /etc/greetd/backdrop.jpg
sudo systemd-tmpfiles --create /usr/lib/tmpfiles.d/regreet.conf   # /var/{lib,log}/regreet, owned by _greetd
sudo systemctl disable lightdm.service 2>/dev/null || true
sudo rm -f /etc/systemd/system/display-manager.service
sudo systemctl enable greetd.service            # claims display-manager.service
#   Fallback: config.toml's header has the tuigreet command — from a TTY,
#   swap it back into default_session and `systemctl restart greetd`.
#   If sway/ReGreet can't draw: sudo usermod -aG video,input _greetd
```

Pick the session (sway is the default) at the tuigreet greeter on VT 7. Don't
hot-switch i3 ⇄ sway without a reboot (the systemd user manager caches
`XDG_CURRENT_DESKTOP`).

## Editing

Files under `~/.config/...` are symlinks into this repo — edit in place, then
`git -C ~/dotfiles commit`. After config changes: `swaymsg reload`,
`pkill -SIGUSR1 kitty`, `herdr server reload-config`.
