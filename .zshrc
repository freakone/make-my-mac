# Zsh options - see http://linux.die.net/man/1/zshoptions for detailed description
setopt auto_pushd           # Make cd push the old directory onto the directory stack.
setopt pushd_ignore_dups    # Don't push multiple copies of the same directory onto the directory stack.
setopt pushd_silent         # Do not print the directory stack after pushd or popd.
setopt auto_menu            # Automatically use menu completion after the second consecutive request for completion
setopt append_history       # If this is set, zsh sessions will append their history list to the history file, rather than replace it.
setopt hist_ignore_dups     # Do not enter command lines into the history list if they are duplicates of the previous event.
setopt hist_ignore_space    # Remove command lines from the history list when the first character on the line is a space
setopt share_history
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=8192
export SAVEHIST=8192
setopt auto_resume          # Treat single word simple commands without redirection as candidates for resumption of an existing job.
setopt complete_in_word     # If unset, the cursor is set to the end of the word if completion is started.
setopt extended_glob        # Treat the '#', '~' and '^' characters as part of patterns for filename generation, etc.
setopt list_types           # When listing files that are possible completions, show the type of each file with a trailing identifying mark.
setopt no_flowcontrol
setopt no_hup
# completion settings
autoload -U compinit && compinit -i
zstyle ':completion:*' menu select
# ENV Variables
# export PATH="$HOME/bin:/usr/local/bin:$PATH"
export EDITOR="vim"
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
# aliases
alias ls="ls -GF"
alias l="ls -GFalh"
alias less="less -r"
alias dc="docker-compose"
# Zsh prompt configuration
setopt prompt_subst
autoload -U colors promptinit
colors
promptinit
_prompt_git_branch() {
  (test -d .git || test -d ../.git) && (git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2> /dev/null
}
_prompt_git_state() {
  if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
    echo "%{$fg[yellow]%}"
  elif ! git diff --quiet 2> /dev/null; then
    echo "%{$fg[red]%}"
  elif ! git diff --cached --quiet 2> /dev/null; then
    echo "%{$fg[blue]%}"
  else
    echo "%{$fg[green]%}"
  fi
}
_prompt_git(){
  local where="$(_prompt_git_branch)"
  [ -n "$where" ] && echo " %{$reset_color%}($(_prompt_git_state)${where#(refs/heads/|tags/)}%{$reset_color%})"
}
_prompt_k8s(){
  local ctx=$(kubectl config current-context)
  case $ctx in
    gke*)
      ctx=${ctx/gke_*_/}
      echo " %{$fg[red]%}[${ctx}]%{$reset_color%}"
      ;;
    arn:aws*)
      ctx=${ctx/*cluster\//}
      echo " %{$fg[yellow]%}[${ctx}]%{$reset_color%}"
      ;;
    *)
      echo " %{$fg[green]%}[${ctx}]%{$reset_color%}"
      ;;
  esac
}
function check_last_exit_code() {
  local LAST_EXIT_CODE=$?
  if [[ $LAST_EXIT_CODE -ne 0 ]]; then
    echo "%{$fg_bold[red]%}$LAST_EXIT_CODE%{$reset_color%} "
  fi
}
PROMPT='%{$fg[cyan]%}%~$(_prompt_git)$(_prompt_k8s) %{$fg_no_bold[cyan]%}λ %{$reset_color%}'
RPROMPT='$(check_last_exit_code)'
# Plugins
source /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# keybindings
autoload -U zsh/terminfo
bindkey '[D'  backward-word
bindkey '[C'  forward-word
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey "^[[3~" delete-char
bindkey "^[3;5~" delete-char
# asdf
source /opt/homebrew/opt/asdf/asdf.sh
# gcloud
source '/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'
source '/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'
export KUBECTL_EXTERNAL_DIFF="colordiff"
# GNU findutils
export PATH="/opt/homebrew/opt/findutils/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
source <(kubectl completion zsh)

export PATH="${PATH}:${HOME}/.krew/bin"

alias k='kubectl'
alias failingpods=kubectl get po -o json --all-namespaces | jq -r '.items[] | select(.status.phase != "Running") | .metadata | "\(.name) -n \(.namespace)"'
