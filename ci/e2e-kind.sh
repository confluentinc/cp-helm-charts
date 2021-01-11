#!/usr/bin/env bash
# https://github.com/helm/chart-testing/blob/master/examples/kind/test/e2e-kind.sh

set -o errexit
set -o nounset
set -o pipefail

readonly KIND_VERSION=v0.9.0
readonly CLUSTER_NAME=chart-testing
readonly K8S_VERSION=v1.18.0
readonly CT_VERSION=v3.1.1

output(){
    echo ""
    echo "*******************************************************"
    echo "$1"
    echo "*******************************************************"
    echo ""
}

run_ct_container() {
    echo 'Running ct container...'
    docker run --rm --interactive --detach --network host --name ct \
        --volume "$(pwd)/ci/ct.yaml:/etc/ct/ct.yaml" \
        --volume "$(pwd):/workdir" \
        --workdir /workdir \
        "quay.io/helmpack/chart-testing:$CT_VERSION" \
        cat
    echo
}

cleanup() {
    echo 'Removing ct container...'
    docker kill ct > /dev/null 2>&1
    kind delete cluster --name "$CLUSTER_NAME" || /bin/true
    echo 'Done!'
}

docker_exec() {
    docker exec -i ct "$@"
}

create_kind_cluster() {
    echo 'Installing kind...'

    curl -sSLo kind "https://github.com/kubernetes-sigs/kind/releases/download/$KIND_VERSION/kind-linux-amd64"
    chmod +x kind
    sudo mv kind /usr/local/bin/kind

    kind create cluster --name "$CLUSTER_NAME" --config ci/kind-config.yaml --image "kindest/node:$K8S_VERSION" --wait 60s

    # TODO: Remove debugging steps
    docker_exec whoami

    docker_exec mkdir -p /root/.kube

    echo 'Copying kubeconfig to container...'
    docker cp "${HOME}"/.kube/config ct:/root/.kube/config

    docker_exec kubectl cluster-info
    echo

    docker_exec kubectl get nodes
    echo

    echo 'Cluster ready!'
    echo
}

install_charts() {
    docker_exec ct lint-and-install
    echo 'Charts applied'
}

main() {
    run_ct_container
    trap cleanup EXIT
    create_kind_cluster
    install_charts
}

main
