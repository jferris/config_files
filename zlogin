git_prompt_info() {
  ref=$(git symbolic-ref HEAD 2> /dev/null)
  if [[ -n $ref ]]; then
    echo "[%{$fg_bold[green]%}${ref#refs/heads/}%{$reset_color%}]"
  fi
}

# makes color constants available
autoload -U colors
colors

# enable colored output from ls, etc
export CLICOLOR=1

# expand functions in the prompt
setopt prompt_subst

# prompt
export PS1='$(git_prompt_info)[${SSH_CONNECTION+"%{$fg_bold[green]%}%n@%m:"}%{$fg_bold[blue]%}%~%{$reset_color%}] '

# autocompletion for ruby_test
# works with tu/tf aliases
_ruby_tests() {
  if [[ -n $words[2] ]]; then
    compadd `ruby_test -l ${words[2]}`
  fi
}
compdef _ruby_tests ruby_test

# autocompletion for ruby_spec
# works with sm/sc aliases
_ruby_specs() {
  if [[ -n $words[2] ]]; then
    compadd `ruby_spec -l ${words[2]}`
  fi
}
compdef _ruby_specs ruby_spec

# autocompletion for ruby_tu_rs
# works with su/sf aliases
_ruby_mixed_tests() {
  if [[ -n $words[2] ]]; then
    compadd `ruby_tu_rs -l ${words[2]}`
  fi
}
compdef _ruby_mixed_tests ruby_tu_rs

_git_remote_branch() {
  ref=$(git symbolic-ref HEAD 2> /dev/null)
  if [[ -n $ref ]]; then
    if (( CURRENT == 2 )); then
      # first arg: operation
      compadd create publish rename delete track
    elif (( CURRENT == 3 )); then
      # second arg: remote branch name
      compadd `git branch -r | grep -v HEAD | sed "s/.*\///" | sed "s/ //g"`
    elif (( CURRENT == 4 )); then
      # third arg: remote name
      compadd `git remote`
    fi
  else;
    _files
  fi
}
compdef _git_remote_branch grb

# autocompletion for schema
_rails_tables() {
  if [[ -n $words[2] ]]; then
    compadd `schema -l ${words[2]}`
  fi
}
compdef _rails_tables schema

# autocompletion for cuc
_cucumber_features() {
  compadd `ls features/**/*.feature | sed "s/features\/\(.*\).feature/\1/"`
}
compdef _cucumber_features cuc

