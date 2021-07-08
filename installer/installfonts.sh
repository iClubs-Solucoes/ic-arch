# Dirs
# DIR=`pwd`
# PDIR="$HOME/.config/polybar"
FDIR="/usr/share/fonts"

# Install Fonts

echo -e "\n[*] Installing fonts..."
if [[ -d "$FDIR" ]]; then
	sudo -S cp -rf ~/.installtemp/fonts/* "$FDIR"
else
	mkdir -p "$FDIR"
	sudo -S cp -rf ~/.installtemp/fonts/* "$FDIR"
fi
echo -e "\n[*] Done."
