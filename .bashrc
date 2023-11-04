#
# ~/.bashrc
#
export PATH=$PATH:/home/callam/.bin
export MOZ_ENABLE_WAYLAND=1

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
