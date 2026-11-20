# Interactive Bash setup, shared by login and non-login shells.
[[ $- == *i* ]] || return 0

if [[ -r "$HOME/.exports" ]]; then
  source "$HOME/.exports"
fi

# Load local overrides after the default aliases and functions.
for file in ~/.{aliases,bash_functions,extra,bash_completion.sh}; do
  [[ -r "$file" && -f "$file" ]] && source "$file"
done
unset file

if declare -F _dotfiles_dedupe_path >/dev/null; then
  _dotfiles_dedupe_path
  unset -f _dotfiles_dedupe_path
fi

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
if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
  source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
fi

# Alias completion requires helpers from bash-completion. Older shells
# keep Bash's default completion for the alias when those are unavailable.
if declare -F _complete_alias _command_offset _completion_loader >/dev/null &&
   ! complete -p k >/dev/null 2>&1; then
  complete -F _complete_alias k
fi

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Set bash to vi mode
set -o vi

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)"
fi
