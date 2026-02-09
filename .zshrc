# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=100000
# unsetopt beep

export ZSH="$HOME/.oh-my-zsh"

alias cls='printf "\033c"'

ZSH_THEME="alanpeabody"

plugins=(
	zsh-autosuggestions
	git
	virtualenv
	colored-man-pages
)

source $ZSH/oh-my-zsh.sh

# End of lines configured by zsh-newuser-install
