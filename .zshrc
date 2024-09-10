autoload -Uz promptinit
autoload -Uz compinit
compinit
promptinit


export EDITOR=/usr/bin/helix
export ZSH="$HOME/.oh-my-zsh"

alias hx="helix"

ZSH_THEME="robbyrussell"

source $ZSH/oh-my-zsh.sh
plugins=(git)


function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

eval "$(zoxide init zsh)"
