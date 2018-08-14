export BIN_DIR=${BIN_DIR:-"/usr/local/bin"}
export SBIN_DIR=${SBIN_DIR:-"/usr/local/sbin"}
export LIB_DIR=${LIB_DIR:-"/usr/local/lib"}
export INC_DIR=${INC_DIR:-"/usr/local/include"}
export UNIT_DIR=${UNIT_DIR:-"/etc/systemd/system"}

export MAJOR=${MAJOR:-1}
export MINOR=${MINOR:-0}

MTCE_COMPUTE_VERSION="1.0"

MTCE_COMPUTE_DIR=$DEST/stx-metal/mtce-compute/cgts-mtce-compute-"${MTCE_COMPUTE_VERSION}"

function install_mtce_compute(){
    cd $MTCE_COMPUTE_DIR
    # Compute-Only Init Scripts (source group x)
    sudo -E install -m 755 -p -D scripts/goenabled /etc/init.d/goenabledCompute
    sudo -E install -m 755 -p -D scripts/e_nova-init /etc/init.d/e_nova-init
    sudo -E install -m 755 -p -D scripts/nova-cleanup /etc/init.d/nova-cleanup
    sudo -E install -m 755 -p -D scripts/nova-startup /etc/init.d/nova-startup

    # Compute-Only Process Monitor Config files (source group 1x)
    sudo -E install -m 755 -d                /etc/pmon.d
    sudo -E install -m 755 -d                /etc/nova
    sudo -E install -m 644 -p -D scripts/nova-cleanup.conf /etc/nova/nova-cleanup.conf
    sudo -E install -m 644 -p -D scripts/nova-compute.conf /etc/nova/nova-compute.conf
    sudo -E install -m 644 -p -D scripts/libvirtd.conf /etc/pmon.d/libvirtd.conf

    # Compute-Only Go Enabled Test (source group 2x)
    sudo -E install -m 755 -d                /etc/goenabled.d
    sudo -E install -m 755 -p -D scripts/nova-goenabled.sh /etc/goenabled.d/nova-goenabled.sh
    sudo -E install -m 755 -p -D scripts/virt-support-goenabled.sh /etc/goenabled.d/virt-support-goenabled.sh

    # Sudo -E Install to systemd (source group 3x)
    sudo -E install -m 644 -p -D scripts/goenabled-compute.service $UNIT_DIR/goenabled-compute.service
    sudo -E install -m 644 -p -D scripts/e_nova-init.service $UNIT_DIR/e_nova-init.service
}

function enable_mtce_compute_services(){
    sudo systemctl enable goenabled-compute.service
    sudo systemctl enable e_nova-init.service
    sudo systemctl enable qemu_clean.service
}

function unstack_mtce_compute(){
    cd $MTCE_COMPUTE_DIR
    files=(/etc/nova/nova-cleanup.conf \
		     /etc/nova/nova-compute.conf \
		     /etc/pmon.d/libvirt.d \
		     /etc/goenabled.d/nova-goenabled.sh \
		     /etc/goenabled.d/virt-support-goenabled.sh \
		     $UNIT_DIR/goenabled-compute/service \
		     $UNIT_DIR/e_nova-init.service)
    for file in ${files[@]}; do
	sudo -E rm -rf $file
    done
}
