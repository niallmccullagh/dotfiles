function title {
    echo -ne "\033]0;"$*"\007"
}

function git-status-recur {
    find . -type d -depth 1 -exec sh -c '(cd {} && if [ -d ".git" ]; then if [ -n "$(git status --porcelain)" ]; then  echo "{}"; fi; fi)' ';'
}
