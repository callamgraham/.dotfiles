autoload -Uz promptinit
autoload -Uz compinit
compinit
promptinit

export EDITOR=/usr/bin/helix
export ZSH="$HOME/.oh-my-zsh"
export GPG_TTY=$(tty)
export PATH=$PATH:/home/callam/.bin:/home/callam/.cargo/.bin
alias hx="helix"
alias timeshift="sudo -E timeshift-launcher"
alias g="gitui"

ZSH_THEME="robbyrussell"

source $ZSH/oh-my-zsh.sh
plugins=(git)

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

eval "$(zoxide init zsh)"
