# Install packages
sudo xbps-install -Syu river chafa wlroots alacritty Waybar wofi mako grim \
slurp fish-shell micro light yazi viewnior ImageMagick polkit-gnome \
xorg-server-xwayland xdg-desktop-portal-wlr pulsemixer elogind \
mesa-dri mesa-vulkan-intel seatd dunst xdg-user-dirs-gtk nerd-fonts \
pulseaudio wl-clipboard cliphist swaylock swayidle wlsunset 

# Create necessary directories
mkdir -p ~/.config/{river,micro,fish}
mkdir -p ~/Pictures/screenshots
cp ~/riverwm/micro/*  ~/.config/micro/
cp ~/riverwm/fish/* ~/.config/fish/
# Copy river configuration files
cp -r ~/riverwm/*	 ~/.config/river/

# Set executable permissions for init
chmod +x ~/.config/river/init
