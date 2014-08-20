# Prompt
[[ -f "$HOME/.bash_prompt" ]] && source "$HOME/.bash_prompt"

# Boxen
[[ -f "/opt/boxen/env.sh" ]] && source "/opt/boxen/env.sh"

# Larger bash history (default is 500)
export HISTFILESIZE=10000
export HISTSIZE=10000
export HISTCONTROL=ignoreboth

# Common junk
[[ -s "$HOME/.commonrc" ]] && source "$HOME/.commonrc"

# Prompt
[[ -f "$HOME/.bash_functions" ]] && source "$HOME/.bash_functions"

[[ -f "/opt/boxen/homebrew/etc/bash_completion.d/git-completion.bash" ]] && source /opt/boxen/homebrew/etc/bash_completion.d/git-completion.bash

export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_21.jdk/Contents/Home
export M2_HOME=/opt/boxen/homebrew/Cellar/maven/3.2.1/libexec/

# Set bash to vi mode
set -o vi
