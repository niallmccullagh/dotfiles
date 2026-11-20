# Interactive login shells use the same setup as other interactive shells.
if [[ $- == *i* ]]; then
  [[ -r "$HOME/.bashrc" ]] && source "$HOME/.bashrc"
  return 0
fi

if [[ -r "$HOME/.exports" ]]; then
  source "$HOME/.exports"
fi
if [[ -r "$HOME/.extra" && -f "$HOME/.extra" ]]; then
  source "$HOME/.extra"
fi

# Put shims ahead of inherited runtime paths so each command can select
# versions for its working directory without installing interactive hooks.
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash --shims)"
fi

if declare -F _dotfiles_dedupe_path >/dev/null; then
  _dotfiles_dedupe_path
  unset -f _dotfiles_dedupe_path
fi
