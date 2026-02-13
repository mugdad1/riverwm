sudo xbps-install -Syu --needed base-devel git
sudo xbps-install -S --noconfirm river wlroots alacritty swaybg Waybar wofi foot mako grim slurp light yad Thunar geany viewnior ImageMagick polkit-gnome xorg-server-xwayland xdg-desktop-portal-wlr rofi pulsemixer
git base-devel elogind mesa-dri mesa-vulkan-intel seatd dunst xdg-user-dirs-gtk nerd-fonts pulseaudio wl-clipboard cliphist thunar swaylock



git clone https://github.com/mugdad1/River.git ~/Downloads/River

mkdir -p ~/.config/{alacritty,dunst,moc,neofetch,pcmanfm,river,rofi,waybar}

cp -r ~/Downloads/River/* ~/.config/river/


chmod +x ~/.config/river/init
RED='\033[0;31m'

# refind-install
# git clone https://github.com/josephsurin/refind-theme-circle.git && sudo rm -r ./refind-theme-circle/{screenshots,.git}
# sudo cp -r refind-theme-circle /boot/efi/EFI/refind/ && sudo echo "include refind-theme-circle/theme.conf" >> /boot/efi/EFI/refind/refind.conf

sleep 5
echo -e "${RED}Please Reboot Now."


