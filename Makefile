all: common wayland

common:
	stow bat
	stow delta
	stow eww
	stow fontconfig
	stow gitconfig
	stow helix
	stow kitty
	stow nvim
	stow qutebrowser
	stow rofi
	stow scripts
	stow tmux
	stow zathura
	stow zsh
others:
	stow alacritty
xorg:
	stow dunst
	stow polybar
	stow qtile
	stow sxhkd
	stow sxiv
	stow autorandr
	stow misc
wayland:
	stow hyprland
	stow waybar
	stow swaylock
	stow swaync
