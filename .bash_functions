cd() {
  if [ $# -eq 0 ]; then
    DIR="${HOME}"
  else
    DIR="$1"
  fi
  pushd $DIR > /dev/null;
  dirs
}
