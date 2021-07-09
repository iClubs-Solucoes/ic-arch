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
  "lxdm-gtk3"
  "ttf-dejavu"
  "noto-fonts"
  "pcmanfm"
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
  ;;
esac

echo ''
echo 'Você gostaria de instalar o assistente yay para pacotes AUR?'
read -p '(N,y): ' installYay
echo ''

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
echo i | parted -a opt $installDisk mkpart primary linux-swap 1024 $installDiskSwapSize
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
  echo 'instalando '$p
  read -t 10 -p 'esperando interação ... ' STOPPER
  systemd-nspawn pacman -S $p --noconfirm
done

# Instalando GRUB
arch-chroot /mnt grub-install --target=i386-pc $installDisk
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# Define senha padrão para root e cria usuarios
systemd-nspawn useradd -m -g users -G wheel -p '' $installNewUser

# Copiando folder de instalação para o sistema novo
cp /root/archdev /mnt/home/$installNewUser -r

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
# mkdir /mnt/home/.installtemp

# Copiando arquivos usados na instalação
# cp /mnt/home/$installNewUser/archdevinstaller ~/.installtemp -r
# cp /mnt/home/$installNewUser/archdevConfig ~/.installtemp -r
# cp /mnt/home/$installNewUser/archdevLoginManager ~/.installtemp -r
# cp /mnt/home/$installNewUser/archdevfonts ~/.installtemp -r
# cp /mnt/home/$installNewUser/archdev/LookAndFeel ~/.installtemp -r

# Instalando yay
case $installYay in
  y)
    systemd-nspawn pacman -U /home/$installNewUser/archdev/Packages/yay.pkg.tar.gz
  ;;
  *)

  ;;
esac

# Instalando aplicações complementares para open box
case $installUi in
  2)

  ;;
  *)
    systemd-nspawn pacman -U /home/$installNewUser/archdev/Packages/polybar.pkg.tar.gz
  ;;
esac
# systemd-nspawn pacman -U /home/$installNewUser/archdev/Packages/yay.pkg.tar.gz

# Habilitando interface gráfica
systemd-nspawn systemctl enable NetworkManager.service
systemd-nspawn systemctl enable lxdm.service

# Configurando interface gráfica
cp /mnt/home/$installNewUser/archdev/LookAndFeel/Theme/ /mnt/usr/share/themes/ArchDark -r
cp /mnt/home/$installNewUser/archdev/LookAndFeel/Icons/ /mnt/usr/share/icons/ArchDark -r
cp /mnt/home/$installNewUser/archdev/LookAndFeel/Config/Themes/GTK2/gtkrc /mnt/usr/share/gtk-2.0/gtkrc -r
cp /mnt/home/$installNewUser/archdev/LookAndFeel/Config/Themes/GTK3/settings.ini /mnt/usr/share/gtk-3.0/settings.ini -r
cp /mnt/home/$installNewUser/archdev/LookAndFeel/Config/Themes/Icons/index.theme /mnt/usr/share/icons/default/index.theme -r
cp /mnt/home/$installNewUser/archdev/LookAndFeel/Config/Openbox/* /mnt/etc/xdg/openbox/ -r
cp /mnt/home/$installNewUser/archdev/LookAndFeel/Plank/Theme/* /mnt/usr/share/plank/themes/Default/ -r
cp /mnt/home/$installNewUser/archdev/LookAndFeel/Polybar/Theme/ /mnt/usr/share/doc/polybar/ArchDark/ -r
cp /mnt/home/$installNewUser/archdev/LoginManager/Config/lxdm.conf /mnt/etc/lxdm/
cp /mnt/home/$installNewUser/archdev/LoginManager/Themes/* /mnt/usr/share/lxdm/themes/ArchDark -r

# Instalando fontes
# ~/.installtemp/installer/installfonts.sh

# Removendo pasta temporaria
# rm -rf ~/.installtemp

# Mostrando neofetch para mostrar o fim do processo
# clear
arch-chroot /mnt neofetch
# read -p 'press any key to continue.....' stoper

# Rebootando
# reboot

## Infos Extras
# Para compilar pacotes AUR é necessario usar o comando extra-x86_64-build, esse comando ira gerar um instalaverl .pkg.tar.gz
# use the systemd-nspawn --user=user to run commands as a specific user