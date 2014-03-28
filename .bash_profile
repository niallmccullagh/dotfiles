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

export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_21.jdk/Contents/Home
