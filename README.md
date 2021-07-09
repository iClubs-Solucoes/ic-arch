# ARCHDEV

Este projeto **não é um OS**, se trata de um instalador automatico para facilitar sua vida e lhe dar mais controle sobre os pacotes instalados em seu archlinux. Este script foi desenvolvido para funcionar em archlinux, altere o codigo o quanto quiser para sanar suas necessidades.

**não nos responsabilizamos por nenhum dano ou problema causado pelo script, seja ele modificado ou não**

## INSTALAÇÃO

Para instalar o sistema com o script clone este repositório com o comando a baixo em seu ambiente live:

`git clone https://github.com/fulviocoelho/archdev`

Quando o repositorio for clonado totalmente execute o script de instalação com:

`./archdev/installer/install.sh`

## ALTERANDO O SCRIPT

Para alterar o codigo clone o repositorio com seguinte comando:

`git clone https://github.com/fulviocoelho/archdev`

O projeto esta organizado da seguinte maneira
* installer (onde ficam os scripts usados na instalação automatica)
* Fonts (onde ficam as fonts a serem instaladas)
* Packages (guarda os pacotes AUR pre compilados usados na instalação)
* Config (mantem arquivos de configurações do sistema)
* LoginManager (mantem os arquivos do gerenciador de login - lxdm-gtk3)
  * Config (onde ficam os arquivos de configuração do lxdm-gtk3)
  * Themes (onde ficam os arquivos responsaveis pelo visual do lxdm-gtk3)
* LookAndFeel (onde ficam os arquivos responsaveis pelo visual do sistema)
  * Icons (guarda o pacote de icones do sistema)
  * Plank (guarda os arquivos de configuração do Plank)
    * Theme (guara os arquivos de tema do plank)
  * Polybar (guarda os arquivos de configuração do Polybar)
    * Theme (guarda os arquivos de tema do polybar)
  * Theme (onde ficam os arquivos de configurações gerais de thema do sistema)
  * Config (guarda os arquivos de configuração de tema do sistema)
    * Openbox (guarda os arquivos de configuração customizados do Openbox)
    * Themes (guarda os arquivos de configuração de temas padrões do sistema)