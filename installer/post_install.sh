# Conseguindo privilegios sudo
sudo -S echo 'Initializing Installation'

# Criando pasta temporaria
mkdir ~/.installtemp

# Copiando arquivos usados na instalação
# cd ..
cp ./installer ~/.installtemp -r
cp ./Config ~/.installtemp -r
cp ./LoginManager ~/.installtemp -r
cp ./fonts ~/.installtemp -r
cp ./LookAndFeel ~/.installtemp -r

# Instalando pacotes basicos
sudo -S pacman -S base-devel go xorg xorg-drivers atom pulseaudio alacritty unzip unrar zip xarchiver mesa firefox neofetch base-devel --noconfirm

# Instalando pacotes para openbox envoiroment
sudo -S pacman -S openbox lxappearance-obconf lxinput	lxrandr menumaker nitrogen rofi lxdm-gtk3 plank ttf-dejavu noto-fonts pcmanfm --noconfirm

# Instalando git
sudo -S pacman -S git --noconfirm

# Instalando yay
cd ~/.installtemp
git clone https://aur.archlinux.org/yay
cd yay
makepkg -S
makepkg --install --noconfirm

# Instalando aplicações complementares para open box
yay -S polybar google-chrome nerd-fonts-complete i3lock-color betterlockscreen --noconfirm
sudo -S pacman -S nodejs npm --noconfirm
sudo -S npm i -g yarn
# yay -S polybar i3lock-color betterlockscreen --noconfirm

# Instalando aplicações para ambiente de desenvolvimento
yay -S visual-studio-code-bin insomnia beekeeper-studio-bin --noconfirm

# Habilitando interface gráfica
sudo -S systemctl enable lxdm.service

# Configurando interface gráfica
cd ~/.installtemp
sudo -S cp ./LookAndFeel/Theme/ /usr/share/themes/ArchDark -r
sudo -S cp ./LookAndFeel/Icons/ /usr/share/icons/ArchDark -r
sudo -S cp ./LookAndFeel/Config/Themes/GTK2/gtkrc /usr/share/gtk-2.0/gtkrc -r
sudo -S cp ./LookAndFeel/Config/Themes/GTK3/settings.ini /usr/share/gtk-3.0/settings.ini -r
sudo -S cp ./LookAndFeel/Config/Themes/Icons/index.theme /usr/share/icons/default/index.theme -r
sudo -S cp ./LookAndFeel/Config/Openbox/* /etc/xdg/openbox/ -r
sudo -S cp ./LookAndFeel/Plank/Theme/* /usr/share/plank/themes/Default/ -r
sudo -S cp ./LookAndFeel/Polybar/Theme/ /usr/share/doc/polybar/ArchDark/ -r
sudo -S cp ./LoginManager/Config/lxdm.conf /etc/lxdm/
sudo -S cp ./LoginManager/Themes/* /usr/share/lxdm/themes/ArchDark -r

# Instalando fontes
~/.installtemp/installer/installfonts.sh

# Criando menu openbox
mmaker openbox -f -t alacritty 

# Removendo pasta temporaria
sudo -S rm -rf ~/.installtemp

# Mostrando neofetch para mostrar o fim do processo
clear
neofetch
read -p 'press any key to continue.....' stoper

# Rebootando
sudo -S reboot


## OLD INSTALLATION SCRIPT
# # sudo pacman -S xorg-server openbox obconf pcmanfm nitrogen atom lxdm-gtk3 rofi pulseaudio alacritty menumaker fakeroot htop xf86-video-intel mesa binutils make gcc pkg-config lxappearance plank nodejs npm ttf-font-awesome automake autoconf xarchiver unzip unrar zip

# echo '1 to BareBaseInstall or 2 to BaseInstall'
# read -p '(default=1)' installType
# echo ' '
# echo '1 to FWM or 2 to TWM'
# read -p '(default=1)' guiType

# # Installs the base packages to start using the sistem
# function installBareMinimun(){
#   yes | pacman -S pcmanfm nitrogen atom pulseaudio alacritty xarchiver unzip unrar zip
# }

# # Installs the base packages to start using the sistem
# function installBase(){
#   yes | pacman -S pcmanfm nitrogen atom pulseaudio alacritty unzip unrar zip xarchiver xorg base-devel
#   mkdir .install
#   cd .install
#   git clone https://aur.archlinux.org/yay
#   cd yay
#   makepkg -S
#   makepkg --install
# }

# # Installs the Openbox, my choice of floating window manager
# function installFloatingWindowManager(){
#   yes | pacman -S openbox lxappearance-obconf lxinput	lxrandr menumaker
#   menumaker openbox -f -t alacritty 

#   # If you have installed the base it will install some AUR packages
#   yes | yay -S polybar i3lock-color betterlockscreen
# }

# # Installs XXXXXX, my choice of tiling window manager
# function installTillingWindowManager(){
#   echo 'not yeat available'
# }

# function copyConfigFiles(){
#   cp ./dotfolders/.config/ ~/ -r
#   cp ./dotfolders/.themes/ ~/ -r
#   cp ./dotfolders/.icons/ ~/ -r
#   sudo cp ./lxdm/lxdm/lxdm.conf /etc/lxdm/
#   sudo cp ./lxdm/themes/ /usr/share/lxdm/ -r
# }

# function enableServices(){
#   systemctl enable lxdm.service
# }

# function installDevTools(){
#   # Install the basic dev tools
#   yes | pacman -S node npm 
#   yes | yay -S visual-studio-code-bin insomnia beekeeper-studio-bin
#   sudo npm i -g yarn
# }

# function installFonts(){
#   ./installfonts.sh
# }

# echo 'Iniciating Installation ...'
# echo ' '
# case $installType in
#   2)
#     echo 'Installing the Base Packages  ...'
#     installBase
#   ;;
#   *)
#     echo 'Installing Bare Minimum ...'
#     installBareMinimun
#   ;;
# esac
# echo ' '
# echo 'Initiating envoiroment installation ...'
# case $guiType in
#   2)
#     echo 'Installing the TWM installation  ...'
#     installTillingWindowManager
#   ;;
#   *)
#     echo 'Installing the FWM installation  ...'
#     installFloatingWindowManager
#   ;;
# esac

# echo ' '
# echo 'Installing Configs ...'
# copyConfigFiles

# echo ' '
# echo 'Enabling Services'
# enableServices

# echo ' '
# echo 'Installing Fonts'
# installFonts

# echo ' '
# echo 'Installing Dev Tools'
# installDevTools

# # echo 'install the AUR packages by hand: polybar, vscode, i3lock-color e betterlockscreen'



# # read -p 'name: ' myname
# # echo 'hello '$myname

# # function hfulvio() {
# #   echo 'nice'
# # }

# # case $myname in
# #   fulvio)
# #     hfulvio
# #   ;;
# #   *)
# #     echo 'nop'
# #   ;;
# # esac
