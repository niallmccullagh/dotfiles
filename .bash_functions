function title {
    echo -ne "\033]0;"$*"\007"
}

function alphanumpassword {
  local length=${1:-53} 
  cat /dev/random | LC_ALL=C tr -dc "[:alnum:]" | tr '[:upper:]' '[:lower:]' | head -c $length;
}

function git-recur {
    echo "Running git $@ recursively"
    local directories=$(find . -type d -depth 2 -name .git | xargs -n 1 dirname)
    for directory in $directories; do
      echo "###################################################################";
      echo "Running git $@ in $directory"
      echo "###################################################################";
      pushd $directory > /dev/null 2>&1;
      git $@;
      popd > /dev/null 2>&1;
    done
}

