sudo xbps-install -Syu river wlroots alacritty Waybar wofi mako grim slurp fish-shell micro light yad yazi viewnior ImageMagick polkit-gnome xorg-server-xwayland xdg-desktop-portal-wlr  pulsemixer elogind mesa-dri mesa-vulkan-intel seatd dunst xdg-user-dirs-gtk nerd-fonts pulseaudio wl-clipboard cliphist swaylock swayidle 



mkdir -p ~/.config/river/
mkdir -p ~/Pictures/screenshots
cp -r ~/riverwm/* ~/.config/river/


chmod +x ~/.config/river/init

