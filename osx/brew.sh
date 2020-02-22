#!/bin/bash

########################################################################
# update any submodules
########################################################################
git submodule update --init --recursive

# Make homebew is installed
if ! [ -x "$(command -v brew)" ]; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Install Mac App Store command-line interface
brew install mas

########################################################################
# Set bash v4 up
########################################################################
# Switch to using brew-installed bash as default shell
if ! fgrep -q "$(brew --prefix)/bin/bash" /etc/shells; then
    echo "$(brew --prefix)/bin/bash" | sudo tee -a /etc/shells;
    chsh -s $(brew --prefix)/bin/bash;
fi;


########################################################################
# Finish up
########################################################################
brew cleanup
