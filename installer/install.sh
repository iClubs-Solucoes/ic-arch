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

# Pacotes para instalacoes em sistemas EFI
efiPackages=(
  "os-prober"
  "efibootmgr"
  "dosfstools"
  "mtools"
)

# Layout de teclados disponiveis
layoutKeyboards=(
  "us"
  "br-abnt2"
)

# Valor padrao para validacao de informacoes de instalacao
installInfoCheck='n' 

screenHeader() {
  clear
  echo '----------------------------------------------'
  echo '|            ARCH DEV INSTALLER              |'
  echo '----------------------------------------------'
}

installKeyboardLayout() {
  # loadkeys br-abnt2
  read -p 'Deseja alterar o layout do teclado? (Padrao='${layoutKeyboards[0]}' | N,y)' setNewLayout
  if [ "$setNewLayout" == 'y' ]
  then
    echo 'Layout disponiveis: '
    n=0
    for l in "${layoutKeyboards[@]}"; do
      echo $n') '$l
      n=$(($n+1))
    done
    read -p 'Digite o numero do layout que deseja: ' chosenLayout
    loadkeys ${layoutKeyboards[$chosenLayout]}
  fi
}

installInfoForm() {
  screenHeader

  echo ''
  echo 'Iniciando instalação ...'
  echo ''

  # Seta o padrao do teclado
  installKeyboardLayout

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

  # Tipo de boot para a maquina
  echo ''
  echo 'Qual tipo de boot deseja instalar :'
  echo '1) EFI'
  echo '2) Legacy BIOS'
  echo ''
  read -p '(padrão = 1): ' installBootType

  # fdisk -l
  echo 'Discos disponiveis no sistem: '
  lsblk -d | grep disk

  read -p 'Disco para formatar: ' installDisk

  read -p 'Tamanho da unidade de swap (em MBs): ' installDiskSwapSize
  echo ''
}

infoCheckScreen() {
  if [ -z "$installDiskSwapSize" ]
  then
    installDiskSwapSize='5000'
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

  if [ $installBootType == '2' ]
  then
    installBootTypeLabel='Legacy BIOS'
  else
    installBootTypeLabel='EFI'
  fi

  if [ $installWindowManager == '2' ]
  then
    installWindowManagerLabel='Tiling Window Manager'
  else
    installWindowManagerLabel='Floating Window Manager'
  fi

  if [ -z "$chosenLayout" ]
  then
    installKeyboardLayoutLabel="us"
  else
    installKeyboardLayoutLabel=${layoutKeyboards[$chosenLayout]}
  fi

  screenHeader
  echo 'Resumo de Instalação'
  echo ''
  echo 'Tipo de Instalação: '$installTypeLabel
  echo 'Window Manager: '$installWindowManagerLabel
  echo 'Nome de Maquina: '$installHostName
  echo 'Usuario: '$installNewUser
  echo 'Layout de Teclado: '$installKeyboardLayoutLabel
  echo 'Tipo de Boot: '$installBootTypeLabel
  echo 'Instalar YAY: '$installYay
  echo 'Formatar Disco: '$installDisk
  echo 'Tamanho de Swap: '$installDiskSwapSize'M'
  echo ''
  echo 'Estas informações estão corretas?'
  read -p '(N,y): ' installInfoCheck
}

packagesPreparation() {
  case $installWindowManager in
    2)
      twmPackages
    ;;
    *)
      fwmPackages
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
}

fwmPackages() {
  packages+=("${installPackagesFWM[@]}")
  installAURPackages+=("${installAURFWM[@]}")
}

twmPackages() {
  packages+=("${installPackagesTWM[@]}")
  installAURPackages+=("${installAURTWM[@]}")
}

legacyDiskSetUP() {
  # Particiona o disco
  parted '/dev/'$installDisk mklabel msdos 
  ## Para tornar um disco com label msdos bootable com o grub é necessário deixar libre 2047 sectores antes da primeira partição.
  ## echo i | parted -a opt $installDisk mkpart primary linux-swap 1024 $installDiskSwapSize
  echo i | parted -a opt '/dev/'$installDisk mkpart primary linux-swap 256 $((256+$installDiskSwapSize))
  echo i | parted -a opt '/dev/'$installDisk mkpart primary ext4 $((256+$installDiskSwapSize)) 100%
  parted -a opt '/dev/'$installDisk set 2 boot on

  # Formata o disco
  mkfs.ext4 '/dev/'$installDisk'2'
  mkswap '/dev/'$installDisk'1'

  # Monta o disco
  mount '/dev/'$installDisk'2' /mnt
  swapon '/dev/'$installDisk'1'
}

legacyBootInstall() {
  # Instalando GRUB
  arch-chroot /mnt grub-install --target=i386-pc '/dev/'$installDisk
  arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
}

efiDiskSetUP() {
  # Particiona o disco
  parted '/dev/'$installDisk mklabel gpt 
  ## Para tornar um disco com label msdos bootable com o grub é necessário deixar libre 2047 sectores antes da primeira partição.
  ## echo i | parted -a opt $installDisk mkpart primary linux-swap 1024 $installDiskSwapSize
  parted -a opt '/dev/'$installDisk mkpart primary fat32 256 806
  parted -a opt '/dev/'$installDisk mkpart primary linux-swap 806 $installDiskSwapSize
  # parted -a opt '/dev/'$installDisk mkpart primary linux-swap 806 $((806+$installDiskSwapSize))
  parted -a opt '/dev/'$installDisk mkpart primary ext4 $installDiskSwapSize 100%
  # parted -a opt '/dev/'$installDisk mkpart primary ext4 $((806+$installDiskSwapSize)) 100%
  # parted -a opt /dev/$installDisk set 2 boot on

  # Formata o disco
  mkfs.ext4 '/dev/'$installDisk'3'
  mkswap '/dev/'$installDisk'2'
  mkfs.fat -F32 '/dev/'$installDisk'1'

  # Monta o disco
  mount '/dev/'$installDisk'3' /mnt
  swapon '/dev/'$installDisk'2'
  mkdir /mnt/boot
  mkdir /mnt/boot/EFI
  mount '/dev/'$installDisk'1' /mnt/boot/EFI

  # Adiciona os pacotes necessarios para instalar grub
  packages+=("${efiPackages[@]}")
}

efiBootInstall() {
  # Instalando GRUB
  arch-chroot /mnt grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
  arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
}

aurHelperAndPackagesInstall() {
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
}

archBaseConfig() {
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

  # Auto inicializacao do pacote starship no bash shell
  echo 'eval "$(starship init bash)"' >> /mnt/etc/bash.bashrc
}

servicesEnable() {
  # Habilitando interface gráfica
  systemd-nspawn systemctl enable NetworkManager.service
  systemd-nspawn systemctl enable lxdm.service
  systemd-nspawn systemctl enable --now systemd-timesyncd.service
  systemd-nspawn systemctl enable --now systemd-time-await-sync.service
}

basicThemesConfig() {
  # Configurando interface gráfica
  cp /mnt/home/$installNewUser/archdev/LookAndFeel/Icons/ /mnt/usr/share/icons/ArchDark -r
  cp /mnt/home/$installNewUser/archdev/LookAndFeel/Config/Themes/GTK2/gtkrc /mnt/usr/share/gtk-2.0/gtkrc -r
  cp /mnt/home/$installNewUser/archdev/LookAndFeel/Config/Themes/GTK3/settings.ini /mnt/usr/share/gtk-3.0/settings.ini -r
  cp /mnt/home/$installNewUser/archdev/LookAndFeel/Config/Themes/Icons/index.theme /mnt/usr/share/icons/default/index.theme -r
  cp /mnt/home/$installNewUser/archdev/LookAndFeel/Plank/Theme/* /mnt/usr/share/plank/themes/Default/ -r
  cp /mnt/home/$installNewUser/archdev/LookAndFeel/Polybar/Theme/ /mnt/usr/share/doc/polybar/ArchDark/ -r
  cp /mnt/home/$installNewUser/archdev/LoginManager/Themes/* /mnt/usr/share/lxdm/themes/ArchDark -r
}

twmThemeConfig() {
  cp /mnt/home/$installNewUser/archdev/LookAndFeel/Theme/Awesome/ /mnt/usr/share/themes/ArchDark -r
  cp /mnt/home/$installNewUser/archdev/LookAndFeel/Config/Awesome/* /mnt/etc/xdg/awesome/ -r
  cp /mnt/home/$installNewUser/archdev/LoginManager/Config/Awesome/lxdm.conf /mnt/etc/lxdm/
  echo 'sudo sed -i "820d" /etc/xdg/awesome/rc.lua' >> /mnt/home/$installNewUser/archdev/installer/postInstall.sh
}

fwmThemeConfig() {
  cp /mnt/home/$installNewUser/archdev/LookAndFeel/Theme/Openbox/ /mnt/usr/share/themes/ArchDark -r
  cp /mnt/home/$installNewUser/archdev/LookAndFeel/Config/Openbox/* /mnt/etc/xdg/openbox/ -r
  cp /mnt/home/$installNewUser/archdev/LoginManager/Config/Openbox/lxdm.conf /mnt/etc/lxdm/
  echo 'sudo sed -i "7d" /etc/xdg/openbox/autostart' >> /mnt/home/$installNewUser/archdev/installer/postInstall.sh
}

themeConfig() {
  basicThemesConfig
  case $installWindowManager in
  2)
    twmThemeConfig
  ;;
  *)
    fwmThemeConfig
  ;;
  esac
}

archInstall() {

  if [ "$installBootType" == '2' ]
  then
    legacyDiskSetUP
  else
    efiDiskSetUP
  fi

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

  if [ "$installBootType" == '2' ]
  then
    legacyBootInstall
  else
    efiBootInstall
  fi

  archBaseConfig
  aurHelperAndPackagesInstall
  servicesEnable
  themeConfig

  # Instalando fontes
  cp -rf /mnt/home/$installNewUser/archdev/Fonts/* /mnt/usr/share/fonts
}

finishInstallScreen() {
  # Mostrando neofetch para mostrar o fim do processo
  screenHeader
  echo 'Instalação finalizada'
  arch-chroot /mnt neofetch
  read -p 'press any key to continue.....' STOPPER
}

main() {
  # Inicio do script de instalação
  while [ "$installInfoCheck" != 'y' ]
  do
    installInfoForm
    infoCheckScreen  

    case $installInfoCheck in
      y)

      ;;
      *)
        installInfoCheck='n'
      ;;
    esac

  done

  packagesPreparation
  archInstall
  finishInstallScreen

  # Rebootando
  reboot
}

main

## Infos Extras
# Para compilar pacotes AUR é necessario usar o comando extra-x86_64-build, esse comando ira gerar um instalaverl .pkg.tar.gz
# use the systemd-nspawn --user=user to run commands as a specific user