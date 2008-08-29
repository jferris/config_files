# get the name of the branch we are on
git_prompt_info() {
  ref=$(git-symbolic-ref HEAD 2> /dev/null) || return
  echo " ${ref#refs/heads/}"
}

# returns a color to indicate the state of the working copy
git_color() {
  echo "$fg_bold[green]"
}

# automatically enter directories without cd
setopt auto_cd

# use vim as an editor
export EDITOR=vim

# paths
if [ -e "$HOME/.pathrc" ]; then
  source "$HOME/.pathrc"
fi

# makes color constants available
autoload -U colors
colors

# enable colored output from ls, etc
export CLICOLOR=1

# expand functions in the prompt
setopt prompt_subst

# prompt
export PS1='%{$fg_bold[blue]%}${SSH_CONNECTION+%n@%m:}%~$(git_color)$(git_prompt_info)% %{$reset_color%} $ '

# vi mode
bindkey -v
