function title {
    echo -ne "\033]0;"$*"\007"
}

function alphanumpassword {
  local length=${1:-53} 
  cat /dev/random | LC_ALL=C tr -dc "[:alnum:]" | tr "[:upper:]" "[:lower:]:" | head -c $length;
}

_recur_in_project_directories() (
    local marker_type=$1 marker_name=$2
    shift 2
    set -o pipefail

    printf 'Running %s recursively\n' "$*"
    find . -mindepth 2 -maxdepth 2 -type "$marker_type" -name "$marker_name" -print0 | (
        local marker directory status=0
        while IFS= read -r -d '' marker; do
            directory=${marker%/*}
            printf '###################################################################\n'
            printf 'Running %s in %s\n' "$*" "$directory"
            printf '###################################################################\n'
            (builtin cd -- "$directory" && "$@" <&3) || status=$?
        done
        exit "$status"
    )
# Keep the caller's input available while the loop reads paths from find.
) 3<&0

function recur-in-git {
    _recur_in_project_directories d .git "$@"
}

function git-recur {
    _recur_in_project_directories d .git git "$@"
}

function npm-recur {
    _recur_in_project_directories f package.json npm "$@"
}

function aws_ip_from_private_dns_name() {
    echo $(aws ec2 describe-instances --filters "{\"Name\":\"private-dns-name\", \"Values\":[\"$1*\"]}" --query='Reservations[0].Instances[0].PublicIpAddress' ) | tr -d '"'
}

function k_describe_node_for_pod() {
     kubectl describe node $(kubectl get pods $1 -owide --no-headers | awk '{ print $7 }')
}

function k_kibana() {
    kubectl port-forward $(kubectl get pods -lapp=aws-es-proxy -o jsonpath="{.items[0].metadata.name}") 9200 &
    sleep 3
    open "http://localhost:9200/_plugin/kibana/"
    fg
}

# Used by bash-git-prompt
function prompt_callback {
    echo " $(kube_ps1)"
}

function ecr-docker-login() {
  eval $(aws ecr get-login --no-include-email)
}

function aws-start-session() { eval $( mfa-start-session $@); }
