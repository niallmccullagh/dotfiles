# Add `~/bin` to the `$PATH`
[[ -d "$HOME/bin" ]] && export PATH="$HOME/bin:$PATH";

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,bash_prompt,exports,aliases,bash_functions,extra}; do
        [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# Boxen
[[ -f "/opt/boxen/env.sh" ]] && source "/opt/boxen/env.sh"

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
if which brew > /dev/null && [ -f "$(brew --prefix)/share/bash-completion/bash_completion" ]; then
	source "$(brew --prefix)/share/bash-completion/bash_completion";
elif [ -f /etc/bash_completion ]; then
	source /etc/bash_completion;
fi;

# Enable tab completion for git
which brew > /dev/null && [[ -f "$(brew --prefix)/etc/bash_completion.d/git-completion.bash" ]] && source "$(brew --prefix)/etc/bash_completion.d/git-completion.bash"

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Set bash to vi mode
set -o vi

# Initialise jenv
if which jenv > /dev/null; then eval "$(jenv init -)"; fi

# Initialise rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# Initialise nodenv
if which nodenv > /dev/null; then eval "$(nodenv init -)"; fi

# Set default docker-machine environment
if which docker-machine > /dev/null && [[ $DISABLE_DOCKER_ENV_SETUP != true ]]; then eval "$(docker-machine env dev)"; fi
