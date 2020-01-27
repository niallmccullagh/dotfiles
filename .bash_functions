function title {
    echo -ne "\033]0;"$*"\007"
}

function alphanumpassword {
  local length=${1:-53} 
  cat /dev/random | LC_ALL=C tr -dc "[:alnum:]" | tr "[:upper:]" "[:lower:]:" | head -c $length;
}

function recur-in-git {
    echo "Running git $@ recursively"
    local directories=$(find . -type d -depth 2 -name .git | xargs -n 1 dirname)
    for directory in $directories; do
      echo "###################################################################";
      echo "Running git $@ in $directory"
      echo "###################################################################";
      pushd $directory > /dev/null 2>&1;
      $@;
      popd > /dev/null 2>&1;
    done
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

function npm-recur {
    echo "Running npm $@ recursively"
    local directories=$(find . -type f -depth 2 -name package.json | xargs -n 1 dirname)
    for directory in $directories; do
      echo "###################################################################";
      echo "Running npm $@ in $directory"
      echo "###################################################################";
      pushd $directory > /dev/null 2>&1;
      npm $@;
      popd > /dev/null 2>&1;
    done
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
