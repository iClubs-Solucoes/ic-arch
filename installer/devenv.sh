packagesDevEnvAUR=(
  "visual-studio-code-bin"
  "insomnia"
  "beekeeper-studio-bin"
)

packagesDevEnvAURDependenciesAUR=(
  "nvm"
)

packagesDevEnvAURDependencies=(
  "lsof"
  "libxss"
  "libnotify"
  "xdg-utils"
  "libxslt"
  "libappindicator-gtk3"
)

packagesDevEnv=(
  "nodejs"
  "npm"
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

yayNotInstalled(){
  sudo pacman -Sy
  installPakages
  for dep in ${packagesDevEnvAURDependencies[@]}; do
    sudo pacman -S $dep --noconfirm
  done
  cd ~/
  for depaur in ${packagesDevEnvAURDependenciesAUR[@]}; do
    git clone https://aur.archlinux.org/$depaur
    cd $depaur
    makepkg -S
    makepkg -i --noconfirm
    cd ~/
  done
  for aur in ${packagesDevEnvAUR[@]}; do
    git clone https://aur.archlinux.org/$aur
    cd $aur
    makepkg -S
    makepkg -i --noconfirm
    cd ~/
  done
}

read -p 'YAY esta instalado?(N,y): ' isYayInstalled
case $isYayInstalled in
  y)
    yayInstalled
  ;;
  *)
    yayNotInstalled
  ;;
esac