#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

export EDITOR=helix
alias hx='helix'
alias r='ranger'
# source /usr/share/fzf/key-bindings.bash
# source /usr/share/fzf/completion.bash

# add personal bin to the PARH
export PATH=$PATH:/home/callam/.bin

# fix a bug with dolphin emulator
export QT_XCB_NO_XI2=1
