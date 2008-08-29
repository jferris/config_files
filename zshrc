# get the name of the branch we are on
git_prompt_info() {
  ref=$(git-symbolic-ref HEAD 2> /dev/null) || return
  echo " ${ref#refs/heads/}"
}

# returns a color to indicate the state of the working copy
git_color() {
  echo "$fg_bold[green]"
}

# paths
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
export PATH=$PATH:/usr/local/mysql/bin
export PATH=$PATH:/usr/local/git/bin
export MANPATH=$MANPATH:/usr/local/git/man
export MAGICK_HOME=/usr/local/ImageMagick-6.3.7
export DYLD_LIBRARY_PATH="$MAGICK_HOME/lib"

# makes color constants available
autoload -U colors
colors

# expand functions in the prompt
setopt prompt_subst

# prompt
export PS1='%{$fg_bold[blue]%}%~$(git_color)$(git_prompt_info)% %{$reset_color%} $ '

# vi mode
bindkey -v
