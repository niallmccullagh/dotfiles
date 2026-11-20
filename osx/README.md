# macOS setup

## Install Homebrew packages

Install [Homebrew](https://docs.brew.sh/Installation) and follow its instructions
to put `brew` on your `PATH`. From the repository root, review the Brewfile and run:

```bash
brew bundle install --file osx/Brewfile --no-upgrade
```

Check an existing setup and apply upgrades when you have time to review them.

```bash
brew bundle check --verbose --file osx/Brewfile --no-upgrade
brew bundle upgrade --file osx/Brewfile
```

Keep automatic updates enabled in apps that update themselves, including iTerm2.
Docker Desktop supplies the Docker CLI and Compose. If `docker` is missing,
check Docker Desktop's CLI tools installation setting, then verify with
`command -v docker` and `docker compose version`. A copy of Docker Desktop
installed outside Homebrew may appear as missing in the bundle check.

macOS supplies `ssh-copy-id`. Use `7zz` for 7-Zip archives and `./gradlew`
in projects with a Gradle wrapper. The Brewfile installs Temurin 21, and
projects that need a different JDK can pin it through mise.

### AWS profiles

Use [named role profiles](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-role.html)
or [IAM Identity Center profiles](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html)
in place of the old `aws-assume-role` helper. Check which account and role a
profile selects with `aws --profile PROFILE sts get-caller-identity`. For tools
that use the AWS SDK, set `AWS_PROFILE=PROFILE` in a fresh shell so previously
exported AWS credentials do not take precedence.

For Amazon EKS, `aws eks update-kubeconfig` creates entries that use
`aws eks get-token`. Update any entries that still call
`aws-iam-authenticator` before removing the old binary.

## Apply macOS preferences

Review and run `./osx/macos.sh` as your usual macOS user. It sets Finder, Dock,
keyboard, screenshot, Terminal, and TextEdit preferences. It also removes
the old download quarantine and disk-image verification overrides for that
user. Reopen affected apps or sign out and back in to pick up the changes.

Use System Settings for machine and security settings.

- In **Lock Screen**, set the idle display timeout and require a password immediately.
- Under **General → Software Update → Automatic Updates**, enable system data and security updates. On macOS 26 and later, also check **Privacy & Security → Background Security Improvements**.
- In **Privacy & Security**, review FileVault and keep Gatekeeper enabled. In **Network → Firewall**, review incoming access alongside any third-party firewall rules and services enabled in **General → Sharing**.
- Use **Sound** for the startup chime, **Trackpad** for tap to click, and **Spotlight → Search Privacy** for indexing exclusions. Use Safari’s own settings for fraudulent website warnings and cross-site tracking.

If you ran the old script, review `pmset -g custom` and check your power, region,
and time zone settings. The preferences script retains your current choices
for those settings.

## Install the iTerm2 profile

In iTerm2, use **Check for Updates** to get the current stable release. If you
used the old setup, turn off **Load settings from a custom folder or URL** under
**Settings → General → Settings**. From the repository root, link the
[Dynamic Profile](https://iterm2.com/documentation-dynamic-profiles.html).

```bash
profiles="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
mkdir -p "$profiles"
ln -s "$PWD/osx/iterm-settings/Dotfiles.plist" "$profiles/Dotfiles.plist"
```

In **Settings → Profiles**, select **Dotfiles** and use **Other Actions → Set as
Default** if you want new sessions to use it. The profile uses your login shell.

Set **Secure Keyboard Entry** in the iTerm2 menu if you want it. In
**Settings → General → Selection**, keep clipboard reads by terminal
applications subject to confirmation.
