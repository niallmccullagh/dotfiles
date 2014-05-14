cd() {
  if [ $# -eq 0 ]; then
    DIR="${HOME}"
  else
    DIR="$1"
  fi
  pushd $DIR > /dev/null;
  dirs
}

function title {
    echo -ne "\033]0;"$*"\007"
}
