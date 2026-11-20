# macOS setup

## Install Homebrew packages

Install [Homebrew](https://docs.brew.sh/Installation) and follow its instructions
to put `brew` on your `PATH`. From the repository root, review the Brewfile and run:

```bash
brew bundle install --file osx/Brewfile --no-upgrade
```

## Set OSX settings

Review `osx/macos.sh` before running it. It includes privileged commands and
quits several apps, including Terminal. Run any settings you still want from
iTerm. This script is separate from the mise bootstrap.
    
## Load iTerm settings

1. Open iTerm2 settings and find the option to load preferences from a custom folder or URL.
2. Select the `osx/iterm-settings` folder in your checkout.
