efiBootInstall() {
  # Instalando GRUB
  arch-chroot /mnt grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
  arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
}

efiBootInstall