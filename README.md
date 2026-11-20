# Nialls dotfiles

Collection of dotfiles as I'm tired of recreating these.

## Installation

**Warning:** If you want to give these dotfiles a try, you should first fork this repository, review the code, and remove things you don’t want or need. Don’t blindly use my settings unless you know what that entails. Use at your own risk!

### Apply the dotfiles

Install [mise](https://mise.jdx.dev/installing-mise.html) and put it on your
`PATH`. Clone this repo where you want to keep it. The links in your home
directory point back to that checkout. If you already have a checkout, run the
commands there.

```bash
git clone https://github.com/niallmccullagh/dotfiles.git
cd dotfiles
git submodule update --init --recursive
mise trust ./mise.toml
mise bootstrap --only dotfiles --dry-run
mise bootstrap --only dotfiles
```

Review any conflicts reported by the preview and move existing files you want
to keep aside before applying. To update, pull in the checkout, update the Vim
submodules, and preview and apply again if the link manifest changed.

### Install Node and Ruby

The linked mise config sets Node 24.22.3 and Ruby 3.4.13 as defaults and reads
project pins from `.node-version`, `.nvmrc`, and `.ruby-version`. On a new Mac,
set up [Homebrew packages](osx/README.md) first, then run `mise install`.

On a machine with existing nodenv or rbenv installs, you can register them in
mise before installing anything. This also preserves packages and gems stored
with those runtimes. Run these commands for the versions you already have:

```bash
mise link node@24.22.3 "$HOME/.nodenv/versions/24.22.3"
mise link ruby@3.4.13 "$HOME/.rbenv/versions/3.4.13"
```

Open a new Bash session (for example, `bash -l`) and check `node --version`
and `ruby --version`. Repeat the checks inside projects that use their own
version pins. Run `mise install` from the project directory when its pinned
version is missing. Non-interactive Bash login shells use mise shims so
commands resolve the configured runtime from their working directory.

### Bash prompt

Install Starship from the Brewfile and apply the dotfiles manifest. The bundled
prompt shows the working directory, Git branch, and active Kubernetes context
and namespace. Set `STARSHIP_CONFIG` or use Starship's usual user config file to
load your own prompt settings.

### Specify the `$PATH`

Bash sources `~/.path` before loading the shared exports in login shells and
interactive shells.

Here’s an example `~/.path` file that adds `/usr/local/bin` to the `$PATH`:

```bash
export PATH="/usr/local/bin:$PATH"
```

### Add custom commands without creating a new fork

Bash sources `~/.extra` in login shells and interactive shells. You can use
this file for machine-local settings and environment variables. In interactive
shells, Bash loads it after the default aliases and functions so you can
override them. Guard interactive-only commands with a check for `$- == *i*`
when the same file is used by non-interactive login shells. Keep credentials
outside this repository.

My `~/.extra` looks something like this:

```bash
# Git credentials
# Not in the repository, to prevent people from accidentally committing under my name
GIT_AUTHOR_NAME="Niall McCullagh"
GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
git config --global user.name "$GIT_AUTHOR_NAME"
GIT_AUTHOR_EMAIL="blah@gmail.com"
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
git config --global user.email "$GIT_AUTHOR_EMAIL"
```

You could also use `~/.extra` to override settings, functions and aliases from my dotfiles repository. It’s probably better to [fork this repository](https://github.com/niallmccullagh/dotfiles/fork) instead, though.

### Clone GitHub organization or team repositories

Install the GitHub CLI (`gh`) and run `gh auth login`. From the directory where
you want the checkouts, run one of these commands.

```bash
clone-github -o ORGANIZATION
clone-github -o ORGANIZATION -t TEAM_SLUG
```

New checkouts use SSH, so your SSH key also needs access to the repositories.
Existing checkouts with a matching origin are updated with a fast-forward-only
pull.

### Log Docker in to Amazon ECR

Pass the registry hostname and the AWS region it belongs to. You can also pass
`--profile` to select an AWS CLI profile.

```bash
ecr-docker-login ACCOUNT.dkr.ecr.REGION.amazonaws.com --region REGION
```

### OSX

Have a look in the [OSX](osx/README.md) folder where there are scripts to set some sensible osx defaults and a list of useful homebrew installable applications.

## Feedback

Suggestions/improvements
[welcome](https://github.com/niallmccullagh/dotfiles/issues)!

## Thanks to…

* [Mathias Bynens](http://mathiasbynens.be/) and his [dotfiles repository](https://github.com/mathiasbynens/dotfiles)
