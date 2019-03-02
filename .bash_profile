# Add `~/bin` to the `$PATH`
[[ -d "/usr/local/sbin" ]] && export PATH="/usr/local/sbin:$PATH";
[[ -d "$HOME/bin" ]] && export PATH="$HOME/bin:$PATH";

source "/usr/local/opt/kube-ps1/share/kube-ps1.sh"

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,exports,aliases,bash_functions,extra,bash_completion.sh}; do
        [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

if [ -f "/usr/local/opt/bash-git-prompt/share/gitprompt.sh" ]; then
  __GIT_PROMPT_DIR="/usr/local/opt/bash-git-prompt/share"
  source "/usr/local/opt/bash-git-prompt/share/gitprompt.sh"
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

# Initialise rbenv
#if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# Initialise nodenv
if which nodenv > /dev/null; then eval "$(nodenv init -)"; fi

