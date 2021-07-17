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

packagesNode=(
  "yarn"
)

packagesNodeFrontEnd=(
  "@vue/cli"
  "create-react-app"
)

installNodePackages(){
  for n in ${packagesNode[@]}; do
    sudo npm i -g $n
  done
}

installPakages(){
  for p in ${packagesDevEnv[@]}; do
    sudo pacman -S $p --noconfirm
  done
}

setUpPackages(){
  read -p 'Gostaria de instalar as ferramentas de Front-end?(N,y): ' frontendPackages
  # read -p 'Gostaria de instalar as ferramentas de Front-end?(N,y): ' frontendPackages
  if [ $frontendPackages == 'y' ]
  then
    packagesNode+="${packagesNodeFrontEnd[@]}"
  fi
}

envInstall(){
  setUpPackages
  sudo pacman -Sy
  installPakages
  for dep in ${packagesDevEnvAURDependencies[@]}; do
    sudo pacman -S $dep --noconfirm
  done
  cd ~/
  mkdir .aurPostInstall
  cd ~/.aurPostInstall
  for depaur in ${packagesDevEnvAURDependenciesAUR[@]}; do
    git clone https://aur.archlinux.org/$depaur
    cd $depaur
    makepkg -S
    makepkg -i --noconfirm
    cd ~/.aurPostInstall
  done
  for aur in ${packagesDevEnvAUR[@]}; do
    git clone https://aur.archlinux.org/$aur
    cd $aur
    makepkg -S
    makepkg -i --noconfirm
    cd ~/.aurPostInstall
  done
  installNodePackages
  cd ~/
  sudo rm -rf ~/.aurPostInstall
}

clear
echo '----------------------------------------------'
echo '|            ARCH DEV POST-INSTALL           |'
echo '----------------------------------------------'
read -p 'Gostaria de preparar o ambiente de desenvolvimento?(N,y): ' willSetUpDevEnv
case $willSetUpDevEnv in
  y)
    envInstall
  ;;
  *)
    
  ;;
esac

echo 'Redefina sua senha: '
passwd

clear
echo '----------------------------------------------'
echo '|            ARCH DEV POST-INSTALL           |'
echo '----------------------------------------------'
echo 'Pos instalacao realizada com sucesso!!'
read -p '' STOPPER


