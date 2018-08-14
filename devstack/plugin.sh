#!/bin/bash

# devstack/plugin.sh
# Triggers stx-metal specific functions to install and configure stx-metal

echo_summary "Metal devstack plugin.sh called: $1/$2"

# check for service enabled
if is_service_enabled stx-metal; then
    if [[ "$1" == "stack" && "$2" == "pre-install" ]]; then
        # Pre-install requirties
        echo_summary "Pre-requires of stx-metal"
        preinstall_metal
    elif [[ "$1" == "stack" && "$2" == "install" ]]; then
        # Perform installation of source
        echo_summary "Install metal"
        install_metal
    elif [[ "$1" == "stack" && "$2" == "post-config" ]]; then
        # Configure after the other layer 1 and 2 services have been configured
        echo_summary "Configure metal"
    elif [[ "$1" == "stack" && "$2" == "extra" ]]; then
        # Initialize and start the metal services
        echo_summary "Initialize and start metal "
        start_mtce
    elif [[ "$1" == "stack" && "$2" == "test" ]]; then
        # do sanity test for metal
        echo_summary "do test"
    fi

    if [[ "$1" == "unstack" ]]; then
        # Shut down metal services
        echo_summary "Stop metal services"
        stop_mtce
    fi

    if [[ "$1" == "clean" ]]; then
        cleanup_metal
    fi
fi
