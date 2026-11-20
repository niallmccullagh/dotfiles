# Add `~/bin` to the `$PATH`
[[ -d "/usr/local/sbin" ]] && export PATH="/usr/local/sbin:$PATH";
[[ -d "$HOME/bin" ]] && export PATH="$HOME/bin:$PATH";

if command -v brew >/dev/null 2>&1; then
  eval "$(brew shellenv)"
elif [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,exports,aliases,bash_functions,extra,bash_completion.sh}; do
        [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# Kubernetes PS1 Prompt (Printed by Git Prompt below)
if [[ -r "${HOMEBREW_PREFIX}/opt/kube-ps1/share/kube-ps1.sh" ]]; then
  source "${HOMEBREW_PREFIX}/opt/kube-ps1/share/kube-ps1.sh"
fi

# Git Prompt
# Sets PS1 inside and outside of git repos
# Theme is configured in the ~/.git-prompt-colors.sh file
if [ -f "${HOMEBREW_PREFIX}/opt/bash-git-prompt/share/gitprompt.sh" ]; then
  __GIT_PROMPT_DIR="${HOMEBREW_PREFIX}/opt/bash-git-prompt/share"
  GIT_PROMPT_IGNORE_SUBMODULES=1 # Disable as checking the status of submodules can be very slow
  source "${HOMEBREW_PREFIX}/opt/bash-git-prompt/share/gitprompt.sh"
fi

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;
# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
        shopt -s "$option" 2> /dev/null;
done;

# Add tab completion for many Bash commands
if type brew &>/dev/null; then
  for COMPLETION in $(brew --prefix)/etc/bash_completion.d/*
  do
    [[ -f $COMPLETION ]] && source "$COMPLETION"
  done
  if [[ -f $(brew --prefix)/etc/profile.d/bash_completion.sh ]];
  then
    source "$(brew --prefix)/etc/profile.d/bash_completion.sh"
  fi
fi


# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Set bash to vi mode
set -o vi

# Initialise jenv
#if which jenv > /dev/null; then eval "$(jenv init -)"; fi

if [[ $- == *i* ]] && command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)"
fi
