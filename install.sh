# Install packages
sudo xbps-install -Syu river chafa wlroots alacritty Waybar wofi mako grim \
slurp fish-shell micro light yazi viewnior ImageMagick polkit-gnome \
xorg-server-xwayland xdg-desktop-portal-wlr pulsemixer elogind \
mesa-dri mesa-vulkan-intel seatd dunst xdg-user-dirs-gtk nerd-fonts \
pulseaudio wl-clipboard cliphist swaylock swayidle wlsunset 

# Using Fish shell to run Fisher commands
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
fish -c "fisher install jomik/fish-gruvbox"

# Create necessary directories
mkdir -p ~/.config/river/
mkdir -p ~/Pictures/screenshots
mkdir -p ~/.config/micro/
cp ~/riverwm/micro/*  ~/.config/micro/
# Copy river configuration files
cp -r ~/riverwm/*	 ~/.config/river/

# Set executable permissions for init
chmod +x ~/.config/river/init
