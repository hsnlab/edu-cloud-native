#!/usr/bin/env bash

set -eou pipefail

export SCRIPT_DIR=$(readlink -f "$(dirname "$0")")
export PROJECT_ROOT=$(readlink -f "${SCRIPT_DIR}/..")

# Config ---------------------------------------------------------------------------------------------------------------

# Practice
PRACTICE="k8s-intro"
# Cluster
CLUSTER_NAME="practice-06"
SETUP_TIMEOUT=60
# Pods
HELLO_SERVER_IMG='practice/06'

# Setup ----------------------------------------------------------------------------------------------------------------

function prepare_practice() {
    ### Build
    printf "\n>>> Build docker image(s)...\n"
    docker build -t "${HELLO_SERVER_IMG}" "${PROJECT_ROOT}/${PRACTICE}"
    docker image ls -f "reference=${HELLO_SERVER_IMG}*"
}

function create_k3d_cluster() {
    printf "\n>>> Setup cluster with id: %s...\n" "${CLUSTER_NAME}"
    k3d cluster create "${CLUSTER_NAME}" --wait --timeout="${SETUP_TIMEOUT}s" \
                        --servers=1 --port=80:80@loadbalancer --port=88:88@loadbalancer
    echo
    k3d cluster list
    printf "\n>>> K3d cluster info:\n"
    kubectl cluster-info --context "k3d-${CLUSTER_NAME}"
    ### Import
    printf "\n>>> Import image(s) into cluster[%s]...\n" "${CLUSTER_NAME}"
    k3d image import -c "${CLUSTER_NAME}" "${HELLO_SERVER_IMG}"
}

function delete_k3d_cluster() {
	printf "\n>>> Delete cluster: %s...\n" "${CLUSTER_NAME}"
	k3d cluster delete "${CLUSTER_NAME}"
}

function cleanup() {
    docker rmi -f "${HELLO_SERVER_IMG}"
}

# Register cleanup
trap cleanup_test_cluster ERR INT TERM

# Parameters --------------------------------------------------------------------------------

function display_help() {
    cat <<EOF
Usage: ${0} [OPTIONS]

Options:
    -c  Perform cleanup.
    -d  Delete cluster.
    -h  Display help.

For further information, see https://github.com/hsnlab/edu-cloud-native/tree/main/k3d-setup
EOF
}

while getopts ":hcd" flag; do
	case "${flag}" in
        c)
            cleanup || true
            exit;;
        d)
            delete_k3d_cluster || true
            exit;;
        h)
            display_help
            exit;;
        ?)
            echo "${0##*/}: invalid option -- '${OPTARG}'"
            echo "Try '${0} -h' for more information."
    esac
done

# Main -----------------------------------------------------------------------------------------------------------------

prepare_practice
create_k3d_cluster

echo -e "\nSetup is finished."
