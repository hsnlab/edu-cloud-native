#!/usr/bin/env bash

set -eou pipefail

# Config ---------------------------------------------------------------------------------------------------------------

DOCKER_VER=latest
K3D_VER=v5.8.3
KUBECTL_VER=v1.31.5	# used by k3d v5.8.3 / k3s v1.31.5

NO_CHECK=false
SLIM_SETUP=false
UPDATE=false

DOCKER_CHECK_IMG="hello-world:latest"
TEST_CLUSTER_NAME="test"
TEST_TIMEOUT=60

# Install actions ------------------------------------------------------------------------------------------------------

function install_deps() {
	printf "\n>>> Install dependencies...\n"
	sudo apt-get update && sudo apt-get install -y ca-certificates curl bash-completion
}

function install_docker() {
	printf "\n>>> Install Docker[%s]...\n" "${DOCKER_VER}"
	curl -fsSL https://get.docker.com/ | VERSION=${DOCKER_VER} sudo sh
    # Privileged Docker
    sudo usermod -aG docker "${USER}"
	echo
	(set -x; docker --version)
}

function install_k3d() {
	printf "\n>>> Install k3d binary[%s]...\n" "${K3D_VER}"
	curl -fsSL https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | TAG=${K3D_VER} bash
	echo
	(set -x; k3d version)
}

function install_kubectl() {
	printf "\n>>> Install kubectl binary[%s]...\n" "${KUBECTL_VER}"
	curl -fsSLO "https://dl.k8s.io/release/${KUBECTL_VER}/bin/linux/amd64/kubectl"
	sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && rm kubectl
	echo
	(set -x; kubectl version --client)
}

function setup_k3d_bash_completion() {
    printf "\n>>> Install k3d bash completion...\n"
    mkdir -p /etc/bash_completion.d
    k3d completion bash | sudo tee /etc/bash_completion.d/k3d > /dev/null
    sudo chmod a+r /etc/bash_completion.d/k3d
    source ~/.bashrc
    echo "Finished."
}

function setup_kubectl_bash_completion() {
    printf "\n>>> Install Kubectl bash completion...\n"
    mkdir -p /etc/bash_completion.d
    kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
    sudo chmod a+r /etc/bash_completion.d/kubectl
    source ~/.bashrc
    echo "Finished."
}

# Test actions ---------------------------------------------------------------------------------------------------------

function create_test_cluster() {
    printf "\n>>> Prepare test cluster with id: %s...\n" "${TEST_CLUSTER_NAME}"
    k3d cluster create "${TEST_CLUSTER_NAME}" --wait --timeout="${TEST_TIMEOUT}s" --servers=1
    printf "\n>>> K3s setup:\n"
    kubectl version
    echo
    kubectl get all -A
}

function cleanup_test_cluster() {
	printf "\n>>> Cleanup...\n"
	k3d cluster delete "${TEST_CLUSTER_NAME}"
}

# Parameters -----------------------------------------------------------------------------------------------------------

function display_help() {
    cat <<EOF
Usage: ${0} [OPTIONS]

Options:
    -s  Only install minimum required binaries.
    -u  Update/overwrite dependencies.
    -x  Skip deployment validation.
    -h  Display help.

For further information, see https://github.com/hsnlab/edu-cloud-native/tree/main/k3d-setup
EOF
}

while getopts ":xsuh" flag; do
	case "${flag}" in
        x)
            echo "[x] No setup validation is configured."
            NO_CHECK=true;;
        s)
            echo "[x] Slim install is configured."
            SLIM_SETUP=true;;
        u)
            echo "[x] Update dependencies."
            UPDATE=true;;
        h)
            display_help
            exit;;
        ?)
            echo "${0##*/}: invalid option -- '${OPTARG}'"
            echo "Try '${0} -h' for more information."
            exit 1;;
    esac
done

# Main -----------------------------------------------------------------------------------------------------------------

### Basic dependencies
install_deps

### Docker
DOCKER_PRE_INSTALLED=$(command -v docker)
if ! command -v docker >/dev/null 2>&1 || [ "${UPDATE}" = true ]; then
    # Binaries
	install_docker
    if [ ${NO_CHECK} = false ] && [ -z "${DOCKER_PRE_INSTALLED}" ]; then
        printf "\n>>> Jump into new shell for docker group privilege...\n" && sleep 3s
        # New shell with docker group privilege
        exec sg docker "$0" "$@"
    fi
    # Validation
    if [ ${NO_CHECK} = false ]; then
        printf "\n>>> Check Docker install...\n"
        # Docker check with simple container
        docker run --rm "${DOCKER_CHECK_IMG}" && docker rmi -f "${DOCKER_CHECK_IMG}"
    fi
fi

### K3d
if ! command -v k3d >/dev/null 2>&1 || [ "${UPDATE}" = true ]; then
	# Binary
	install_k3d
    if [ ${SLIM_SETUP} = false ]; then
        # Bash completion
        setup_k3d_bash_completion
    fi
fi

### Kubectl
if ! command -v kubectl >/dev/null 2>&1 || [ "${UPDATE}" = true ]; then
	# Binary
	install_kubectl
    if [ ${SLIM_SETUP} = false ]; then
        # Bash completion
        setup_kubectl_bash_completion
    fi
fi

# Register cleanup
trap cleanup_test_cluster ERR INT TERM

if [ ${NO_CHECK} = false ]; then
    # Make test
    create_test_cluster
    cleanup_test_cluster
    # Make warning
    if [ -z "${DOCKER_PRE_INSTALLED}" ]; then
        cat <<EOF

#########################################################################################################
##  Shell session should be reloaded MANUALLY to make the non-root user access to Docker take effect!  ##
#########################################################################################################
EOF
    fi
fi

echo -e "\nSetup is finished."
