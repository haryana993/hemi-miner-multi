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
    printf "${BLUE}Send tbtc to your pubkey_hash address from DC #faucet and press y/Y after txn Sucess : ${NC}"
    read -r funded
    if [[ ! "$funded" =~ [yY] ]]; then
        printf "${BLUE}Operation cancelled by user.${NC}\n"
        return 1
    fi

    # Set variables: request private key from user
    printf "${BLUE}Please enter your  private_key (that you saved before): ${NC}"
    read -r private_key
    if [[ -z "$private_key" ]]; then
        printf "${BLUE}Private key is required. Exiting...${NC}\n" >&2
        return 1
    fi
    export POPM_BTC_PRIVKEY="$private_key"

    # Set variables: request fee per vB from user
    printf "${BLUE}Please enter gas fee in sats/vb like 50 or 60 : ${NC}"
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
