# ---- Kubernetes-friendly .bashrc snippet ----

# vi ~/.bashrc
# source ~/.bashrc
# Safe defaults
set -o vi 2>/dev/null || true
set -o noclobber

# ----- kubectl completion -----
# Enable kubectl bash completion if available
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion bash) 2>/dev/null || true
fi

# Short alias and wire completion to it
alias k=kubectl
if command -v kubectl >/dev/null 2>&1; then
  complete -F __start_kubectl k
fi

# ----- Common aliases -----
# Get
alias kg='k get'
alias kgp='k get pods'
alias kgs='k get svc'
alias kgi='k get ingress'
alias kgn='k get nodes'
alias kgns='k get namespaces'
alias kgrs='k get rs'
alias kgd='k get deploy'
# Describe
alias kdp='k describe pod'
alias kds='k describe svc'
alias kdd='k describe deploy'
# Logs & exec
alias kl='k logs'
alias klf='k logs -f'
alias kx='k exec -it'
# Apply/Delete
alias kaf='k apply -f'
alias kdf='k delete -f'
alias kdel='k delete'
# Other helpers
alias ktop='k top pods --all-namespaces'
alias kctx='kubectl config use-context'
alias kns='kubectl config set-context --current --namespace'

# Port-forward helper: kpf <pod> <localPort>:<remotePort> [-n ns]
function kpf() {
  if [ $# -lt 2 ]; then
    echo "Usage: kpf <pod> <localPort>:<remotePort> [--namespace ns]"; return 1; fi
  k port-forward "$@"
}

# knsf: switch namespace quickly (creates it if missing)
function knsf() {
  if [ -z "$1" ]; then echo "Usage: knsf <namespace>"; return 1; fi
  if ! k get ns "$1" >/dev/null 2>&1; then k create ns "$1"; fi
  kubectl config set-context --current --namespace="$1"
}

# kc: short for "kubectl config current-context"
alias kc='kubectl config current-context'

# kgaw: get all common workload resources in current ns
function kgaw() {
  k get deploy,sts,ds,job,cronjob,po,svc,ing -o wide "$@"
}

# ----- Prompt (shows kube context/namespace) -----
# Toggle with KUBE_PS1=0 to disable
if [ -z "$KUBE_PS1" ] || [ "$KUBE_PS1" = "1" ]; then
  __kube_ps1() {
    command -v kubectl >/dev/null 2>&1 || return
    local ctx ns
    ctx=$(kubectl config current-context 2>/dev/null) || return
    ns=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
    [ -z "$ns" ] && ns=default
    echo -n "(k8s:${ctx}/${ns})"
  }
  export PS1='\u@\h \W $(__kube_ps1)\n$ '
fi

# Colorized kubectl output (if yq present for custom formatting)
export KUBECTL_EXTERNAL_DIFF=diff

# History tuning
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=5000
export HISTFILESIZE=10000

# ---- end of Kubernetes .bashrc snippet ----