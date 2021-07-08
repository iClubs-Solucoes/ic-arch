# Inicio de variaveis
# Pacotes basicos que serão instalados
packages=(
  "atom"
  "nano"
  "sudo"
  "networkmanager"
  "rofi"
  "htop"
  "alacritty"
  "pulseaudio"
  "git"
  "firefox"
  "xarchiver"
  "unrar"
  "zip"
  "unzip"
  "neofetch"
  "grub"
)

# Pacotes para instalação completa
packagesComplete=(
  "xorg"
  "base-devel"
)

# Pacotes para instalação minima
packagesMinimum=(
  "xorg-server"
  "binutils"
  "make"
  "gcc"
  "pkg-config"
  "go"
  "fakeroot"
  # Video drivers
  "mesa"
  "xf86-video-intel"
)

# Pacotes para FWM (Openbox)
packagesFWM=(
  "openbox"
  "plank"
  "lxappearance-obconf"
  "lxinput"
  "lxrandr"
  "nitrogen"
  "lxdm-gtk3"
  "ttf-dejavu"
  "noto-fonts"
  "pcmanfm"
)

packagesDevTools=(
  "nodejs"
  "docker"
  "npm"
)

packagesAUR=(
  
)

packagesAURFWM=(
  "i3lock-color"
  "polybar"
  "betterlockscreen"
  "nerd-fonts-complete"
)

packagesAURTWM=(
  
)

packagesAURDevTools=(
  "visual-studio-code-bin"
  "beekeeper-studio-bin"
  "google-chrome"
  "insomnia"
  "docker-compose"
)

# Inicio do script de instalação
echo '----------------------------------------------'
echo '|           ARCH DARK INSTALLER              |'
echo '----------------------------------------------'

echo ''
echo 'Iniciando instalação ...'
echo ''

# Seta o teclado para ABNT2
loadkeys br-abnt2

# Inicio de formulario para prosseguir com isntalação
echo ''
echo 'Você gostaria de realizar a instalação :'
echo '1) Completa'
echo '2) Minima'
echo ''
read -p '(padrão = 1): ' installType
echo ''

case $installType in
  2)
    packages+=("${packagesMinimum[@]}")
  ;;
  *)
    packages+=("${packagesComplete[@]}")
  ;;
esac

echo ''
echo 'Sua interface grafica deve ser:'
echo '1) Float Window Manager'
echo '2) Tilling Window Manager'
echo ''
read -p '(padrão = 1): ' installUi
echo ''

case $installUi in
  2)
    # packages+=("${packagesMinimum[@]}")
  ;;
  *)
    packages+=("${packagesFWM[@]}")
    packagesAUR+=("${packagesAURFWM[@]}")
  ;;
esac

echo ''
read -p 'Você gostaria de instalar softwares de desenvolvimento? (N,y): ' installDevTools
echo ''

if [ $installDevTools == 'y' ]
then
  packagesAUR+=("${packagesAURDevTools[@]}")
fi

echo ''
read -p 'Digite o nome de sua maquina: ' installHostName
echo ''

echo ''
read -p 'Digite o nome do seu usuário: ' installNewUser
echo ''

# while [ $installNewUserPass1 !== $installNewUserPass2 ]
# do
#   echo ''
#   read -s -p 'Digite sua senha: ' installNewUserPass1
#   read -s -p 'Repita sua senha: ' installNewUserPass2
#   echo ''
# done

fdisk -l

echo ''
read -p 'Disco para formatar: ' installDisk
echo ''

installDiskSwapSize='5G'

echo ''
read -p 'Tamanho da unidade de swap (coloque G ou MB após o numero): ' installDiskSwapSize
echo ''

# Particiona o disco
parted $installDisk mklabel msdos 
## Para tornar um disco com label msdos bootable com o grub é necessário deixar libre 2047 sectores antes da primeira partição.
echo i | parted -a opt $installDisk mkpart primary linux-swap 2048 $installDiskSwapSize
echo i | parted -a opt $installDisk mkpart primary ext4 $installDiskSwapSize 100%
parted -a opt $installDisk set 2 boot on

# Script de instalação de AUR
# installAUR(){

# }

# Formata o disco
mkfs.ext4 $installDisk'2'
mkswap $installDisk'1'

# Monta o disco
mount $installDisk'2' /mnt
swapon $installDisk'1'

# Instalando sistema base
pacstrap /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab

# Entrando na tree do sistema novo
cd /mnt

# Instalando pacotes
for p in ${packages[@]}; do
  systemd-nspawn pacman -S $p --noconfirm
done

# Instalando GRUB
arch-chroot /mnt grub-install --target=i386-pc $installDisk
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# Define senha padrão para root e cria usuarios
systemd-nspawn useradd -m -g users -G wheel -p '' $installNewUser

cd /home/$installNewUser
systemd-nspawn git clone https://aur.archlinux.org/yay
cd yay
systemd-nspawn sudo $installNewUser 
systemd-nspawn makepkg -S
systemd-nspawn makepkg --install 

# if [ $installDevTools == 'y' ]
# then
#   packagesAUR+=("${packagesAURDevTools[@]}")
# fi

# Copiando folder de instalação para o sistema novo
cp /root/arch /mnt/home/$installNewUser -r

# Removendo password pra comandos sudo para instalação
cp /mnt/home/$installNewUser/arch/Config/Install\ sudo/* /mnt/etc/ -r

# Configuração basica de systema
systemd-nspawn ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
systemd-nspawn echo 'pt_BR.UTF-8 UTF-8' >> /etc/locale.gen
systemd-nspawn locale-gen
systemd-nspawn echo 'KEYMAP=br-abnt2' >> /etc/vconsole.conf
systemd-nspawn echo $installHostName >> /etc/hostname
systemd-nspawn echo '127.0.0.1  localhost' >> /etc/hosts
systemd-nspawn echo '::1  localhost' >> /etc/hosts
systemd-nspawn echo '127.0.0.1  '$installHostName'.localdomain  localhost' >> /etc/hosts

# Conseguindo privilegios sudo
echo 'Initializing Installation'

# Criando pasta temporaria
mkdir ~/.installtemp

# Copiando arquivos usados na instalação
cp ./installer ~/.installtemp -r
cp ./Config ~/.installtemp -r
cp ./LoginManager ~/.installtemp -r
cp ./fonts ~/.installtemp -r
cp ./LookAndFeel ~/.installtemp -r

# Instalando yay
# cd ~/.installtemp
# git clone https://aur.archlinux.org/yay
# cd yay
# makepkg -S
# makepkg --install --noconfirm

# Instalando aplicações complementares para open box
# yay -S polybar google-chrome nerd-fonts-complete i3lock-color betterlockscreen --noconfirm
# sudo -S pacman -S nodejs npm --noconfirm
# sudo -S npm i -g yarn
# yay -S polybar i3lock-color betterlockscreen --noconfirm

# Instalando aplicações para ambiente de desenvolvimento
# yay -S visual-studio-code-bin insomnia beekeeper-studio-bin --noconfirm

# Habilitando interface gráfica
systemd-nspawn systemctl enable NetworkManager.service
systemd-nspawn systemctl enable lxdm.service

# Configurando interface gráfica
cd ~/.installtemp
cp ./LookAndFeel/Theme/ /usr/share/themes/ArchDark -r
cp ./LookAndFeel/Icons/ /usr/share/icons/ArchDark -r
cp ./LookAndFeel/Config/Themes/GTK2/gtkrc /usr/share/gtk-2.0/gtkrc -r
cp ./LookAndFeel/Config/Themes/GTK3/settings.ini /usr/share/gtk-3.0/settings.ini -r
cp ./LookAndFeel/Config/Themes/Icons/index.theme /usr/share/icons/default/index.theme -r
cp ./LookAndFeel/Config/Openbox/* /etc/xdg/openbox/ -r
cp ./LookAndFeel/Plank/Theme/* /usr/share/plank/themes/Default/ -r
cp ./LookAndFeel/Polybar/Theme/ /usr/share/doc/polybar/ArchDark/ -r
cp ./LoginManager/Config/lxdm.conf /etc/lxdm/
cp ./LoginManager/Themes/* /usr/share/lxdm/themes/ArchDark -r

# Instalando fontes
~/.installtemp/installer/installfonts.sh

# Removendo pasta temporaria
rm -rf ~/.installtemp

# Mostrando neofetch para mostrar o fim do processo
# clear
arch-chroot /mnt neofetch
# read -p 'press any key to continue.....' stoper

# Rebootando
# reboot
