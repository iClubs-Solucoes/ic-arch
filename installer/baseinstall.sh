# Inicio de instalação basica

# Carrega layout de teclado abnt2
loadkeys br-abnt2
clear

# Lista os discos presentes no sistema
echo 'Instruções para particionar o disco:'
echo '  1. O disco deve ter somente duas partições.'
echo '  2. A primeira partição deve ser a partição bootavel de arquivos.'
echo '  3. A segunda o partição deve ser destinada ao swap.'
echo ''
read -p 'pressione qualquer tecla para entrar na etapa de formatação ....' STOPER

clear
fdisk -l
read -p 'qual disco deseja formatar? ' DISK
cfdisk $DISK

# Formata o disco
mkfs.ext4 $DISK'1'
mkswap $DISK'2'

# Monta o disco
mount $DISK'1' /mnt
swapon $DISK'2'

# Instalando sistema base
pacstrap /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab

# Preconfiguração
arch-chroot /mnt pacman -S grub networkmanager sudo --noconfirm

# Instalando GRUB
arch-chroot /mnt grub-install --target=i386-pc $DISK
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# Define senha padrão para root e cria usuarios
clear
echo 'Digite a senha do Root'
arch-chroot /mnt passwd
echo ''
echo 'Qual o nome do novo usuário'
read -p ' ' USER
arch-chroot /mnt useradd -m -g users -G wheel $USER
echo 'Escolha a senha para o usuario'
arch-chroot /mnt passwd arch

# Copiando folder de instalação para o sistema novo
cp /root/arch /mnt/home/$USER -r

# Removendo password pra comandos sudo para instalação
cp /mnt/home/$USER/arch/Config/Install\ sudo/* /mnt/etc/ -r

# Configuração basica de systema
arch-chroot /mnt ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
arch-chroot /mnt echo pt_BR.UTF-8 UTF-8 >> /etc/locale.gen
arch-chroot /mnt locale-gen
arch-chroot /mnt echo KEYMAP=br-abnt2 >> /etc/vconsole.conf
echo ''
read -p 'Nome da maquina: ' HOSTNAME
arch-chroot /mnt echo $HOSTNAME >> /etc/hostname


# Finaliza preinstall
read -p 'pressione qualquer tecla para reiniciar....' STOPER
reboot
