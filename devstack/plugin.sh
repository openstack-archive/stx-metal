LIBDIR=$DEST/stx-metal/devstack/lib

source $LIBDIR/mtce_common.sh
source $LIBDIR/mtce_control.sh
source $LIBDIR/mtce_compute.sh
source $LIBDIR/mtce_storage.sh

# check for service enabled
if is_service_enabled stx-metal; then

    if [[ "$1" == "stack" && "$2" == "install" ]]; then
	echo_summary "Installing stx-fault"
	install_mtce_common
	install_mtce_control
	install_mtce_compute
	install_mtce_storage

    elif [[ "$1" == "stack" && "$2" == "post-config" ]]; then
	echo_summary "Configuring stx-fault"
    fi

    if [[ "$1" == "unstack" ]]; then
	unstack_mtce_common
	unstack_mtce_control
	unstack_mtce_compute
	unstack_mtce_storage
    fi
fi
