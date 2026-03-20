# ── Context variables ─────────────────────────────────────────────────────────
# $NS   - target namespace
# $POD  - target pod
# $CONT - target container (optional — omit to get all container logs)
# Set these to avoid passing them repeatedly, e.g: export NS=mynamespace

# ── Helpers ───────────────────────────────────────────────────────────────────
_kns() {
    if [ "$1" = "-A" ] || [ "$1" = "--all-namespaces" ]; then
        echo "--all-namespaces"
    else
        local ns="${1:-$NS}"
        [ -n "$ns" ] && echo "-n $ns"
    fi
}
_kcont() { local c="${1:-$CONT}";  [ -n "$c"  ] && echo "-c $c"; }

# ── Context management ────────────────────────────────────────────────────────
kns()    { export NS="$1";   echo "NS=$NS"; }
kpod()   { export POD="$1";  echo "POD=$POD"; }
kcont()  { export CONT="$1"; echo "CONT=$CONT"; }
kctx()   { echo "NS=${NS:-unset}  POD=${POD:-unset}  CONT=${CONT:-unset}"; }
kunset() { unset NS POD CONT; echo "context cleared"; }

# ── Core ──────────────────────────────────────────────────────────────────────
alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kcon='kubectl config current-context'
kcuc() {
    [ -z "$1" ] && { echo "usage: kcuc <context>" >&2; return 1; }
    kubectl config use-context "$1"
}

# ── Get ───────────────────────────────────────────────────────────────────────
kgp()   { kubectl get pods                   $(_kns "${1}"); }
kgs()   { kubectl get services               $(_kns "${1}"); }
kgd()   { kubectl get deployments            $(_kns "${1}"); }
kgi()   { kubectl get ingress                $(_kns "${1}"); }
kgrs()  { kubectl get replicasets            $(_kns "${1}"); }
kgsec() { kubectl get secrets                $(_kns "${1}"); }
kgcm()  { kubectl get configmaps             $(_kns "${1}"); }
kgsa()  { kubectl get serviceaccounts        $(_kns "${1}"); }
kgpvc() { kubectl get persistentvolumeclaims $(_kns "${1}"); }
kgpv()  { kubectl get persistentvolumes; }
kgn()   { kubectl get nodes; }
kgsi() {
    local svc="$1" ns="${2:-$NS}"
    [ -z "$svc" ] && { echo "usage: kgsi <service> [namespace]  (or set \$NS)" >&2; return 1; }
    kubectl get ingress $(_kns "$ns") -o json | jq -r --arg s "$svc" '
        .items[]
        | select([.spec.rules[]?.http.paths[]?.backend.service.name] | any(. == $s))
        | "Ingress: \(.metadata.name)",
          (.spec.rules[]?
            | "  Host: \(.host // "*")",
              (.http.paths[]?
                | "  Path: \(.path // "/")  →  \(.backend.service.name):\(.backend.service.port.number // .backend.service.port.name)"
              )
          )
    '
}
kgowner() {
    local pod="${1:-$POD}" ns="${2:-$NS}"
    [ -z "$pod" ] && { echo "usage: kgowner [pod] [namespace]  (or set \$POD/\$NS)" >&2; return 1; }
    kubectl get pod "$pod" $(_kns "$ns") -o jsonpath='{range .metadata.ownerReferences[*]}{.kind}/{.name}{"\n"}{end}'
}

# ── Describe ──────────────────────────────────────────────────────────────────
kdp() {
    local pod="${1:-$POD}" ns="${2:-$NS}"
    [ -z "$pod" ] && { echo "usage: kdp [pod] [namespace]  (or set \$POD/\$NS)" >&2; return 1; }
    kubectl describe pod "$pod" $(_kns "$ns")
}
kds() {
    local svc="$1" ns="${2:-$NS}"
    [ -z "$svc" ] && { echo "usage: kds <service> [namespace]  (or set \$NS)" >&2; return 1; }
    kubectl describe service "$svc" $(_kns "$ns")
}
kdi() {
    local ing="$1" ns="${2:-$NS}"
    [ -z "$ing" ] && { echo "usage: kdi <ingress> [namespace]  (or set \$NS)" >&2; return 1; }
    kubectl describe ingress "$ing" $(_kns "$ns")
}
kdrs() {
    local rs="$1" ns="${2:-$NS}"
    [ -z "$rs" ] && { echo "usage: kdrs <replicaset> [namespace]  (or set \$NS)" >&2; return 1; }
    kubectl describe replicaset "$rs" $(_kns "$ns")
}
kdsec() {
    local sec="$1" ns="${2:-$NS}"
    [ -z "$sec" ] && { echo "usage: kdsec <secret> [namespace]  (or set \$NS)" >&2; return 1; }
    kubectl describe secret "$sec" $(_kns "$ns")
}
kdcm() {
    local cm="$1" ns="${2:-$NS}"
    [ -z "$cm" ] && { echo "usage: kdcm <configmap> [namespace]  (or set \$NS)" >&2; return 1; }
    kubectl describe configmap "$cm" $(_kns "$ns")
}
kdsa() {
    local sa="$1" ns="${2:-$NS}"
    [ -z "$sa" ] && { echo "usage: kdsa <serviceaccount> [namespace]  (or set \$NS)" >&2; return 1; }
    kubectl describe serviceaccount "$sa" $(_kns "$ns")
}
kdpvc() {
    local pvc="$1" ns="${2:-$NS}"
    [ -z "$pvc" ] && { echo "usage: kdpvc <pvc> [namespace]  (or set \$NS)" >&2; return 1; }
    kubectl describe persistentvolumeclaim "$pvc" $(_kns "$ns")
}
kdpv() {
    local pv="$1"
    [ -z "$pv" ] && { echo "usage: kdpv <pv>" >&2; return 1; }
    kubectl describe persistentvolume "$pv"
}
kdns()   { kubectl describe namespace "${1:-$NS}"; }
kdnode() { kubectl describe node "$1"; }
kdpi() {
    local pod="${1:-$POD}" ns="${2:-$NS}"
    [ -z "$pod" ] && { echo "usage: kdpi [pod] [namespace]  (or set \$POD/\$NS)" >&2; return 1; }
    local svc
    svc=$(kgpsvc "$pod" "$ns") || return 1
    [ -z "$svc" ] && { echo "Pod does not have ingress"; return 0; }
    local ing
    ing=$(kubectl get ingress $(_kns "$ns") -o json | jq -r --arg s "$svc" '
        .items[] | select([.spec.rules[]?.http.paths[]?.backend.service.name] | any(. == $s)) | .metadata.name
    ' | head -1)
    [ -z "$ing" ] && { echo "Pod does not have ingress"; return 0; }
    kubectl describe ingress "$ing" $(_kns "$ns")
}

# ── Pod search ───────────────────────────────────────────────────────────────
kgpsvc() {
    local pod="${1:-$POD}" ns="${2:-$NS}"
    [ -z "$pod" ] && { echo "usage: kgpsvc [pod] [namespace]  (or set \$POD/\$NS)" >&2; return 1; }
    local pod_json
    pod_json=$(kubectl get pod "$pod" $(_kns "$ns") -o json 2>/dev/null) || {
        echo "Pod '$pod' not found" >&2; return 1
    }
    kubectl get services $(_kns "$ns") -o json | jq -r --argjson pod "$pod_json" '
        .items[]
        | select(.spec.selector != null)
        | select(.spec.selector | to_entries | all(. as $e | $pod.metadata.labels[$e.key] == $e.value))
        | .metadata.name
    '
}
kgpwi() {
    local pod="${1:-$POD}" ns="${2:-$NS}"
    [ -z "$pod" ] && { echo "usage: kgpwi [pod] [namespace]  (or set \$POD/\$NS)" >&2; return 1; }
    local svc
    svc=$(kgpsvc "$pod" "$ns") || return 1
    [ -z "$svc" ] && { echo "Pod does not have ingress"; return 0; }
    kgsi "$svc" "$ns"
}
kgpwcon() {
    local cont="$1" ns_arg="${2:-$NS}"
    [ -z "$cont" ] && { echo "usage: kgpwcon <container> [-A|namespace]  (or set \$NS)" >&2; return 1; }
    if [ "$ns_arg" = "-A" ] || [ "$ns_arg" = "--all-namespaces" ]; then
        kubectl get pods --all-namespaces -o json \
            | jq -r --arg c "$cont" '
                .items[]
                | select(
                    any(.spec.containers[]; .name == $c) or
                    any(.spec.initContainers // []; .name == $c)
                  )
                | "\(.metadata.namespace)/\(.metadata.name)"'
    else
        kubectl get pods $(_kns "$ns_arg") -o json \
            | jq -r --arg c "$cont" '
                .items[]
                | select(
                    any(.spec.containers[]; .name == $c) or
                    any(.spec.initContainers // []; .name == $c)
                  )
                | .metadata.name'
    fi
}

# ── Filtered get ─────────────────────────────────────────────────────────────
kgpin() {
    local status="$1" ns="${2:-$NS}"
    [ -z "$status" ] && { echo "usage: kgpin <status> [namespace]  (or set \$NS)" >&2; return 1; }
    kubectl get pods $(_kns "$ns") | grep "$status"
}
kgpvin() {
    local phase="$1"
    [ -z "$phase" ] && { echo "usage: kgpvin <phase>" >&2; return 1; }
    kubectl get persistentvolumes | grep "$phase"
}
kgpvbad() {
    kubectl get persistentvolumes -o json | jq -r '
        ["NAME", "PHASE", "CLAIM"],
        ( .items[]
          | select(.status.phase != "Bound" and .status.phase != "Available")
          | [ .metadata.name,
              .status.phase,
              ((.spec.claimRef.namespace // "-") + "/" + (.spec.claimRef.name // "-")) ]
        ) | @tsv
    '
}
kgpvcpv() {
    local pvc="$1" ns="${2:-$NS}"
    [ -z "$pvc" ] && { echo "usage: kgpvcpv <pvc> [namespace]  (or set \$NS)" >&2; return 1; }
    kubectl get pvc "$pvc" $(_kns "$ns") -o jsonpath='{.spec.volumeName}{"\n"}'
}
kgpvpvc() {
    local pv="$1"
    [ -z "$pv" ] && { echo "usage: kgpvpvc <pv>" >&2; return 1; }
    kubectl get pv "$pv" -o jsonpath='{.spec.claimRef.namespace}/{.spec.claimRef.name}{"\n"}'
}

# ── Logs ──────────────────────────────────────────────────────────────────────
klog() {
    local pod="${1:-$POD}" ns="${2:-$NS}" cont="${3:-$CONT}"
    [ -z "$pod" ] && { echo "usage: klog [pod] [namespace]  (or set \$POD/\$NS)" >&2; return 1; }
    kubectl logs -f "$pod" $(_kns "$ns") $(_kcont "$cont")
}

# ── Exec ──────────────────────────────────────────────────────────────────────
kex() {
    local pod="${1:-$POD}" ns="${2:-$NS}" cont="${3:-$CONT}"
    [ -z "$pod" ] && { echo "usage: kex [pod] [namespace] [container]  (or set \$POD/\$NS/\$CONT)" >&2; return 1; }
    kubectl exec -it "$pod" $(_kns "$ns") $(_kcont "$cont") -- "${4:-sh}"
}
