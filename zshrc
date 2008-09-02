# print the name of the current branch and working copy status
git_prompt_info() {
  ref=$(git-symbolic-ref HEAD 2> /dev/null)
  if [[ -n `git-status 2> /dev/null | grep 'Changes to be committed:'` ]]; then
    gitstatus=" %{$fg[green]%}modified%{$reset_color%}"
  elif [[ -n `git-status 2> /dev/null | grep 'use "git add'` ]]; then
    gitstatus=" %{$fg[red]%}modified%{$reset_color%}"
  elif [[ -n `git-diff --shortstat ORIGIN..HEAD 2> /dev/null` ]]; then
    gitstatus=" %{$fg[green]%}unpushed%{$reset_color%}"
  else
    gitstatus=''
  fi
  if [[ -n $ref ]]; then
    echo "%{$fg_bold[green]%}/${ref#refs/heads/}%{$reset_color%}$gitstatus"
  fi
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
export PS1='${SSH_CONNECTION+"%{$fg_bold[green]%}%n@%m:"}%{$fg_bold[blue]%}%~%{$reset_color%}$(git_prompt_info) $ '

# vi mode
bindkey -v
