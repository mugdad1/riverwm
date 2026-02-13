sudo xbps-install -Syu river chafa wlroots alacritty Waybar wofi mako grim slurp fish-shell micro light  yazi viewnior ImageMagick polkit-gnome xorg-server-xwayland xdg-desktop-portal-wlr  pulsemixer elogind mesa-dri mesa-vulkan-intel seatd dunst xdg-user-dirs-gtk nerd-fonts pulseaudio wl-clipboard cliphist swaylock swayidle 
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
fisher install jomik/fish-gruvbox


mkdir -p ~/.config/river/
mkdir -p ~/Pictures/screenshots
cp -r ~/riverwm/* ~/.config/river/


chmod +x ~/.config/river/init

