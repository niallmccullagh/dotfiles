# Prompt
[[ -f "$HOME/.bash_prompt" ]] && source "$HOME/.bash_prompt"

# Boxen
[[ -f "/opt/boxen/env.sh" ]] && source "/opt/boxen/env.sh"

# Jenv
if which jenv > /dev/null; then eval "$(jenv init -)"; fi

# Larger bash history (default is 500)
export HISTFILESIZE=10000
export HISTSIZE=10000
export HISTCONTROL=ignoreboth

# Common junk
[[ -s "$HOME/.commonrc" ]] && source "$HOME/.commonrc"

# Prompt
[[ -f "$HOME/.bash_functions" ]] && source "$HOME/.bash_functions"

[[ -f "/opt/boxen/homebrew/etc/bash_completion.d/git-completion.bash" ]] && source /opt/boxen/homebrew/etc/bash_completion.d/git-completion.bash

export M2_HOME=/opt/boxen/homebrew/Cellar/maven/3.2.5/libexec/

# Set bash to vi mode
set -o vi
