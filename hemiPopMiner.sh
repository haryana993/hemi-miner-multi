#!/bin/bash

# Define colors
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Function to check for successful command execution
check_success() {
    if [[ $? -ne 0 ]]; then
        printf "${BLUE}An error occurred during the execution of the script. Exiting...${NC}\n" >&2
        return 1
    fi
}

# Main script
main() {
    # Clone the GitHub repository and navigate to the directory
    git clone https://github.com/arun993/hemi-miner.git && cd hemi-miner || return 1

    # Update and upgrade system packages
    sudo apt update && sudo apt upgrade -y
    check_success

    # Install 'screen' package if not already installed
    sudo apt install -y screen
    check_success

    # Start a new screen session named "hemi"
    screen -S hemi || return 1

    # Extract the miner files and change to the extracted directory
    tar xvf heminetwork_v0.4.3_linux_amd64.tar.gz && cd heminetwork_v0.4.3_linux_amd64 || return 1

    # Generate keys and store them in JSON format
    ./keygen -secp256k1 -json -net="testnet" > ~/popm-address.json
    check_success

    # Display the generated keys and ask user to save credentials
    cat ~/popm-address.json
    printf "${BLUE}Save your credentials and press y/Y to continue: ${NC}"
    read -r continue
    if [[ ! "$continue" =~ [yY] ]]; then
        printf "${BLUE}Operation cancelled by user.${NC}\n"
        return 1
    fi

    # Ask user to fund the miner and continue after confirmation
    printf "${BLUE}Fund your miner and press y/Y if you have funded it: ${NC}"
    read -r funded
    if [[ ! "$funded" =~ [yY] ]]; then
        printf "${BLUE}Operation cancelled by user.${NC}\n"
        return 1
    fi

    # Set variables: request private key from user
    printf "${BLUE}Please enter your POPM BTC private key: ${NC}"
    read -r private_key
    if [[ -z "$private_key" ]]; then
        printf "${BLUE}Private key is required. Exiting...${NC}\n" >&2
        return 1
    fi
    export POPM_BTC_PRIVKEY="$private_key"

    # Set variables: request fee per vB from user
    printf "${BLUE}Please enter fee per vB (as an integer): ${NC}"
    read -r fee_per_vB
    if [[ -z "$fee_per_vB" ]]; then
        printf "${BLUE}Fee per vB is required. Exiting...${NC}\n" >&2
        return 1
    fi
    export POPM_STATIC_FEE="$fee_per_vB"

    # Set the URL variable for the miner
    export POPM_BFG_URL="wss://testnet.rpc.hemi.network/v1/ws/public"

    # Run the miner
    ./popmd
    check_success
}

# Execute main function
main
