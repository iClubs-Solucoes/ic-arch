packagesDevEnvAUR=(
  "visual-studio-code-bin"
  "insomnia"
  "beekeeper-studio-bin"
)

packagesDevEnv=(
  "nodejs"
  "python"
)

installPakages(){
  for p in ${packagesDevEnv[@]}; do
    sudo pacman -S $p --noconfirm
  done
}

yayInstalled(){
  sudo pacman -Sy
  installPakages
  for aur in ${packagesDevEnvAUR[@]}; do
    yay -S $aur --noconfirm
  done
}

# yayNotInstalled(){

# }

read -p 'YAY esta instalado?(N,y): ' isYayInstalled
case $isYayInstalled in
  y)
    yayInstalled
  ;;
  *)

  ;;
esac