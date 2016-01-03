# Add `~/bin` to the `$PATH`
[[ -d "$HOME/bin" ]] && export PATH="$HOME/bin:$PATH";

# Prompt
[[ -f "$HOME/.bash_prompt" ]] && source "$HOME/.bash_prompt"

# Boxen
[[ -f "/opt/boxen/env.sh" ]] && source "/opt/boxen/env.sh"

# Jenv
if which jenv > /dev/null; then eval "$(jenv init -)"; fi

# Common junk
[[ -s "$HOME/.commonrc" ]] && source "$HOME/.commonrc"

# Prompt
[[ -f "$HOME/.bash_functions" ]] && source "$HOME/.bash_functions"

# Add tab completion for many Bash commands
if which brew > /dev/null && [ -f "$(brew --prefix)/share/bash-completion/bash_completion" ]; then
	source "$(brew --prefix)/share/bash-completion/bash_completion";
elif [ -f /etc/bash_completion ]; then
	source /etc/bash_completion;
fi;

# Enable tab completion for git
[[ -f "/opt/boxen/homebrew/etc/bash_completion.d/git-completion.bash" ]] && source /opt/boxen/homebrew/etc/bash_completion.d/git-completion.bash

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

export M2_HOME=/opt/boxen/homebrew/Cellar/maven/3.2.5/libexec/

# Set bash to vi mode
set -o vi
