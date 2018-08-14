export BIN_DIR=${BIN_DIR:-"/usr/local/bin"}
export SBIN_DIR=${SBIN_DIR:-"/usr/local/sbin"}
export LIB_DIR=${LIB_DIR:-"/usr/local/lib"}
export INC_DIR=${INC_DIR:-"/usr/local/include"}
export UNIT_DIR=${UNIT_DIR:-"/etc/systemd/system"}

export MAJOR=${MAJOR:-1}
export MINOR=${MINOR:-0}

MTCE_STORAGE_VERSION="1.0"

MTCE_STORAGE_DIR=$DEST/stx-metal/mtce-storage/cgts-mtce-storage-"${MTCE_STORAGE_VERSION}"

function install_mtce_storage(){
    cd $MTCE_STORAGE_DIR
    # Storage-Only Init Scripts
    sudo install -m 755 -p -D scripts/goenabled /etc/init.d/goenabledStorage

    # Storage-Only Process Monitor Config files
    sudo install -m 755 -d /etc/pmond.d

    # Storage-Only Go Enabled Tests
    sudo install -m 755 -d /etc/goenabled.d

    # Storage-Only Services
    sudo install -m 755 -d /etc/services.d/storage

    # Install systemd dir
    sudo -E install -m 644 -p -D scripts/goenabled-storage.service $UNIT_DIR/goenabled-storage.service
}

function enable_mtce_storage_services(){
    sudo systemctl enable goenabled-storage.service
}
function unstack_mtce_storage(){
    cd $MTCE_STORAGE_DIR
}
