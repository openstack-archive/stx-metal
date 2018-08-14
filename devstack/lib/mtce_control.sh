export BIN_DIR=${BIN_DIR:-"/usr/local/bin"}
export SBIN_DIR=${SBIN_DIR:-"/usr/local/sbin"}
export LIB_DIR=${LIB_DIR:-"/usr/local/lib"}
export INC_DIR=${INC_DIR:-"/usr/local/include"}
export UNIT_DIR=${UNIT_DIR:-"/etc/systemd/system"}

export MAJOR=${MAJOR:-1}
export MINOR=${MINOR:-0}

MTCE_CONTROL_VERSION="1.0"

MTCE_CONTROL_DIR=$DEST/stx-metal/mtce-control/cgts-mtce-control-"${MTCE_CONTROL_VERSION}"

function install_mtce_control(){
    cd $MTCE_CONTROL_DIR
    sudo install -m 755 -d /etc/pmond.d
    sudo install -m 755 -d /etc/goenabled.d
    sudo systemctl enable lighthttpd.service
    sudo systemctl enable qemu_clean.service
}

function unstack_mtce_control(){
    cd $MTCE_CONTROL_DIR
    sudo make clean
}
