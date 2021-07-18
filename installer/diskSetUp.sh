read -p 'disk: ' installDisk
read -p 'swap: ' installDiskSwapSize

efiDiskSetUP() {
  # Particiona o disco
  parted '/dev/'$installDisk mklabel gpt 
  ## Para tornar um disco com label msdos bootable com o grub é necessário deixar libre 2047 sectores antes da primeira partição.
  ## echo i | parted -a opt $installDisk mkpart primary linux-swap 1024 $installDiskSwapSize
  echo i | parted -a opt '/dev/'$installDisk mkpart primary fat32 256 806
  echo i | parted -a opt '/dev/'$installDisk mkpart primary linux-swap 806 $((806+$installDiskSwapSize))
  echo i | parted -a opt '/dev/'$installDisk mkpart primary ext4 $((806+$installDiskSwapSize)) 100%
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
}

efiDiskSetUP