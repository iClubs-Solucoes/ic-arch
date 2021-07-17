# Inicio de variaveis
# Pacotes basicos que serão instalados
packages=(
  "sudo"
  "networkmanager"
  "rofi"
  "htop"
  "alacritty"
  "git"
  "firefox"
  "xarchiver"
  "unrar"
  "zip"
  "unzip"
  "neofetch"
  "ttf-dejavu"
  "noto-fonts"
  "lxdm-gtk3"
  "grub"
  "starship"
)

# Pacotes para FWM
installPackagesFWM=(
  "nano"
  "pulseaudio"
  "atom"
  "openbox"
  "plank"
  "lxappearance-obconf"
  "lxinput"
  "lxrandr"
  "nitrogen"
  "pcmanfm"
)

# Pacotes para TWM
installPackagesTWM=(
  "nano"
  "alsa-lib"
  "alsa-utils"
  "awesome"
  "rofi"
  "ranger"
)

# Pacotes compilados que serão instalados
installAURPackages=(
  "i3lock-color"
  "betterlockscreen"
)

# Pacotes compilados que serão instalados com FWM
installAURFWM=(
  "polybar"
)

# Pacotes compilados que serão instalados com TWM
installAURTWM=(
  "lain-git"
  "awesome-freedesktop-git"
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

installInfoCheck='n' 

 # Inicio do script de instalação
while [ $installInfoCheck != 'y' ]
do

  clear
  echo '----------------------------------------------'
  echo '|            ARCH DEV INSTALLER              |'
  echo '----------------------------------------------'

  echo ''
  echo 'Iniciando instalação ...'
  echo ''

  # Seta o teclado para ABNT2
  loadkeys br-abnt2

  # Inicio de formulario para prosseguir com instalação
  echo ''
  echo 'Você gostaria de realizar a instalação :'
  echo '1) Completa'
  echo '2) Minima'
  echo ''
  read -p '(padrão = 1): ' installType

  # Formulario para prosseguir com a instação do window manager
  echo ''
  echo 'Escolha o ambiente:'
  echo '1) Floating Window Manager'
  echo '2) Tiling Window Manager'
  echo ''
  read -p '(padrão = 1): ' installWindowManager

  echo 'Você gostaria de instalar o assistente yay para pacotes AUR?'
  read -p '(N,y): ' installYay
  read -p 'Digite o nome de sua maquina: ' installHostName
  read -p 'Digite o nome do seu usuário: ' installNewUser

  fdisk -l

  read -p 'Disco para formatar: ' installDisk

  read -p 'Tamanho da unidade de swap (coloque G ou MB após o numero): ' installDiskSwapSize
  echo ''

  if [ -z "$installDiskSwapSize" ]
  then
    installDiskSwapSize='5G'
  fi

  if [ "$installYay" != 'y' ]
  then
    installYay='n'
  fi

  if [ $installType == '2' ]
  then
    installTypeLabel='Minima'
  else
    installTypeLabel='Completa'
  fi

  if [ $installWindowManager == '2' ]
  then
    installWindowManagerLabel='Tiling Window Manager'
  else
    installWindowManagerLabel='Floating Window Manager'
  fi

  clear

  echo '----------------------------------------------'
  echo '|            ARCH DEV INSTALLER              |'
  echo '----------------------------------------------'

  echo 'Resumo de Instalação'
  echo ''
  echo 'Tipo de Instalação: '$installTypeLabel
  echo 'Window Manager: '$installWindowManagerLabel
  echo 'Nome de Maquina: '$installHostName
  echo 'Usuario: '$installNewUser
  echo 'Instalar YAY: '$installYay
  echo 'Formatar Disco: '$installDisk
  echo 'Tamanho de Swap: '$installDiskSwapSize
  echo ''
  echo 'Estas informações estão corretas?'
  read -p '(N,y): ' installInfoCheck

  case $installInfoCheck in
    y)

    ;;
    *)
      installInfoCheck='n'
    ;;
  esac

done

case $installWindowManager in
  2)
    packages+=("${installPackagesTWM[@]}")
    installAURPackages+=("${installAURTWM[@]}")
  ;;
  *)
    packages+=("${installPackagesFWM[@]}")
    installAURPackages+=("${installAURFWM[@]}")
  ;;
esac

case $installType in
  2)
    packages+=("${packagesMinimum[@]}")
  ;;
  *)
    packages+=("${packagesComplete[@]}")
  ;;
esac

# Particiona o disco
parted $installDisk mklabel msdos 
## Para tornar um disco com label msdos bootable com o grub é necessário deixar libre 2047 sectores antes da primeira partição.
## echo i | parted -a opt $installDisk mkpart primary linux-swap 1024 $installDiskSwapSize
echo i | parted -a opt $installDisk mkpart primary linux-swap 256M $installDiskSwapSize
echo i | parted -a opt $installDisk mkpart primary ext4 $installDiskSwapSize 100%
parted -a opt $installDisk set 2 boot on

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
  # echo 'instalando '$p
  # read -t 5 -p 'Pressione qualquer tecla para continuar com a instação ... ' STOPPER
  systemd-nspawn pacman -S $p --noconfirm
done

# Instalando GRUB
arch-chroot /mnt grub-install --target=i386-pc $installDisk
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# Define senha padrão para root e cria usuarios
arch-chroot /mnt useradd -m -g users -G wheel -p '' $installNewUser

# Copiando folder de instalação para o sistema novo
cp /root/archdev /mnt/home/$installNewUser -r

# Removendo password pra comandos sudo para instalação
cp /mnt/home/$installNewUser/archdev/Config/Install\ sudo/* /mnt/etc/ -r

# Configuração basica de systema
ln -sf /mnt/usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
echo 'pt_BR.UTF-8 UTF-8' >> /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
echo 'KEYMAP=br-abnt2' >> /mnt/etc/vconsole.conf
echo $installHostName >> /mnt/etc/hostname
echo '127.0.0.1  localhost' >> /mnt/etc/hosts
echo '::1  localhost' >> /mnt/etc/hosts
echo '127.0.0.1  '$installHostName'.localdomain  localhost' >> /mnt/etc/hosts
echo 'eval "$(starship init bash)"' >> /mnt/etc/bash.bashrc

# Conseguindo privilegios sudo
echo 'Initializing Installation'

# Instalando yay
case $installYay in
  y)
    systemd-nspawn pacman -U /home/$installNewUser/archdev/Packages/yay.pkg.tar.zst --noconfirm
  ;;
  *)

  ;;
esac

# Instalando aplicações complementares para open box
for p in ${installAURPackages[@]}; do
  systemd-nspawn pacman -U /home/$installNewUser/archdev/Packages/$p.pkg.tar.zst --noconfirm
done

# Habilitando interface gráfica
systemd-nspawn systemctl enable NetworkManager.service
systemd-nspawn systemctl enable lxdm.service
systemd-nspawn systemctl enable --now systemd-timesyncd.service
systemd-nspawn systemctl enable --now systemd-time-await-sync.service

# Configurando interface gráfica
cp /mnt/home/$installNewUser/archdev/LookAndFeel/Icons/ /mnt/usr/share/icons/ArchDark -r
cp /mnt/home/$installNewUser/archdev/LookAndFeel/Config/Themes/GTK2/gtkrc /mnt/usr/share/gtk-2.0/gtkrc -r
cp /mnt/home/$installNewUser/archdev/LookAndFeel/Config/Themes/GTK3/settings.ini /mnt/usr/share/gtk-3.0/settings.ini -r
cp /mnt/home/$installNewUser/archdev/LookAndFeel/Config/Themes/Icons/index.theme /mnt/usr/share/icons/default/index.theme -r
cp /mnt/home/$installNewUser/archdev/LookAndFeel/Plank/Theme/* /mnt/usr/share/plank/themes/Default/ -r
cp /mnt/home/$installNewUser/archdev/LookAndFeel/Polybar/Theme/ /mnt/usr/share/doc/polybar/ArchDark/ -r
cp /mnt/home/$installNewUser/archdev/LoginManager/Themes/* /mnt/usr/share/lxdm/themes/ArchDark -r

case $installWindowManager in
  2)
    cp /mnt/home/$installNewUser/archdev/LookAndFeel/Theme/Awesome/ /mnt/usr/share/themes/ArchDark -r
    cp /mnt/home/$installNewUser/archdev/LookAndFeel/Config/Awesome/* /mnt/etc/xdg/awesome/ -r
    cp /mnt/home/$installNewUser/archdev/LoginManager/Config/Awesome/lxdm.conf /mnt/etc/lxdm/
    echo 'awful.spawn.with_shell("alacritty -e ~/archdev/installer/postInstall.sh")' >> /mnt/etc/xdg/awesome/rc.lua
    echo 'sudo sed -i "$d" /etc/xdg/awesome/rc.lua' >> /mnt/home/$installNewUser/archdev/installer/postInstall.sh
  ;;
  *)
    cp /mnt/home/$installNewUser/archdev/LookAndFeel/Theme/Openbox/ /mnt/usr/share/themes/ArchDark -r
    cp /mnt/home/$installNewUser/archdev/LookAndFeel/Config/Openbox/* /mnt/etc/xdg/openbox/ -r
    cp /mnt/home/$installNewUser/archdev/LoginManager/Config/Openbox/lxdm.conf /mnt/etc/lxdm/
    echo 'sudo sed -i "7d" /etc/xdg/openbox/autostart' >> /mnt/home/$installNewUser/archdev/installer/postInstall.sh
  ;;
esac

# Instalando fontes
cp -rf /mnt/home/$installNewUser/archdev/Fonts/* /mnt/usr/share/fonts

# Mostrando neofetch para mostrar o fim do processo
clear
echo '----------------------------------------------'
echo '|            ARCH DEV INSTALLER              |'
echo '----------------------------------------------'
echo 'Instalação finalizada'
arch-chroot /mnt neofetch
read -p 'press any key to continue.....' STOPPER

# Rebootando
reboot

## Infos Extras
# Para compilar pacotes AUR é necessario usar o comando extra-x86_64-build, esse comando ira gerar um instalaverl .pkg.tar.gz
# use the systemd-nspawn --user=user to run commands as a specific user