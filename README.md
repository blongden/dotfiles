# dotfiles

Personal dotfiles for a Debian **testing** laptop running **sway / Wayland**
(migrated from i3/X11). Deployed with [GNU Stow](https://www.gnu.org/software/stow/).

## Layout

Each top-level directory is a stow *package* whose contents mirror `$HOME`:

| package | deploys | notes |
|---|---|---|
| `zsh` `git` `tmux` `nvim` | `~/.zshrc`, `~/.gitconfig`, `~/.config/git/ignore`, `~/.tmux.conf`, `~/.config/nvim/init.vim` | |
| `kitty` | `~/.config/kitty/kitty.conf` | Tomorrow Night theme appended |
| `sway` | `~/.config/sway/` | config + `*.sh` helpers + `screensaver-art/` |
| `waybar` `wofi` | `~/.config/{waybar,wofi}/` | Tomorrow Night, Iosevka Nerd Font |
| `kanshi` | `~/.config/kanshi/` | output profiles (docked = DP-2 4K@30) |
| `swaylock` `gammastep` | `~/.config/{swaylock,gammastep}/` | gammastep off by default |
| `herdr` | `~/.config/herdr/config.toml` | multiplexer for coding agents; `--no-folding` (dir holds runtime state) |
| `desktop` | `~/.config/mimeapps.list`, `~/.local/share/applications/{screenshot,sway-keybindings}.desktop` | chromium as default browser; `--no-folding` |

## Rebuild on a new machine

```sh
# 1. packages
sudo apt update
sudo apt install --no-install-recommends $(grep -vE '^\s*#|^\s*$' packages.txt)

# 2. dotfiles
git clone git@github.com:blongden/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow zsh git tmux nvim kitty sway waybar wofi kanshi swaylock gammastep
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

# 4. LightDM greeter (optional cosmetic; system files, not stow-managed)
#   /etc/lightdm/lightdm-gtk-greeter.conf  +  /usr/share/backgrounds/lightdm-nerd.png
```

Pick the sway or i3 session at the LightDM greeter. Don't hot-switch i3 ⇄ sway
without a reboot (the systemd user manager caches `XDG_CURRENT_DESKTOP`).

## Editing

Files under `~/.config/...` are symlinks into this repo — edit in place, then
`git -C ~/dotfiles commit`. After config changes: `swaymsg reload`,
`pkill -SIGUSR1 kitty`, `herdr server reload-config`.
