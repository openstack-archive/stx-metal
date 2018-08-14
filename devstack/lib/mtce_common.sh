export BIN_DIR=${BIN_DIR:-"/usr/local/bin"}
export SBIN_DIR=${SBIN_DIR:-"/usr/local/sbin"}
export LIB_DIR=${LIB_DIR:-"/usr/local/lib"}
export INC_DIR=${INC_DIR:-"/usr/local/include"}
export UNIT_DIR=${UNIT_DIR:-"/etc/systemd/system"}

export MAJOR=${MAJOR:-1}
export MINOR=${MINOR:-0}

MTCE_COMMON_VERSION="1.0"

MTCE_COMMON_DIR=$DEST/stx-metal/mtce-common/cgts-mtce-common-"${MTCE_COMMON_VERSION}"

function install_mtce_common(){
    cd $MTCE_COMMON_DIR

    make CCFLAGS=' -g -O2 -Wall -Wextra -std=c++11 -DBUILDINFO="\"$$(date)\""' build
    # Resource Agent
    sudo -E install -m 755 -p -D scripts/mtcAgent $LIB_DIR/ocf/resource.d/platform/mtcAgent
    sudo -E install -m 755 -p -D scripts/hbsAgent $LIB_DIR/ocf/resource.d/platform/hbsAgent
    sudo -E install -m 755 -p -D hwmon/scripts/ocf/hwmon $LIB_DIR/ocf/resource.d/platform/hwmon
    sudo -E install -m 755 -p -D guest/scripts/guestAgent.ocf $LIB_DIR/ocf/resource.d/platform/guestAgent

    # Config files
    sudo -E install -m 644 -p -D scripts/mtc.ini /etc/mtc.ini
    sudo -E install -m 644 -p -D scripts/mtc.conf /etc/mtc.conf
    sudo -E install -m 644 -p -D fsmon/scripts/fsmond.conf /etc/mtc/fsmond.conf
    sudo -E install -m 644 -p -D hwmon/scripts/hwmond.conf /etc/mtc/hwmond.conf
    sudo -E install -m 644 -p -D pmon/scripts/pmond.conf /etc/mtc/pmond.conf
    sudo -E install -m 644 -p -D rmon/scripts/rmond.conf /etc/mtc/rmond.conf
    sudo -E install -m 644 -p -D guest/scripts/guest.ini /etc/mtc/guestAgent.ini
    sudo -E install -m 644 -p -D guest/scripts/guest.ini /etc/mtc/guestServer.ini
    sudo -E install -m 644 -p -D hostw/scripts/hostwd.conf /etc/mtc/hostwd.conf

    sudo -E install -m 755 -d /etc/etc/bmc/server_profiles.d
    sudo -E install -m 644 -p -D scripts/sensor_hp360_v1_ilo_v4.profile /etc/bmc/server_profiles.d/sensor_hp360_v1_ilo_v4.profile
    sudo -E install -m 644 -p -D scripts/sensor_hp380_v1_ilo_v4.profile /etc/bmc/server_profiles.d/sensor_hp380_v1_ilo_v4.profile
    sudo -E install -m 644 -p -D scripts/sensor_quanta_v1_ilo_v4.profile /etc/bmc/server_profiles.d/sensor_quanta_v1_ilo_v4.profile

    # binaries
    sudo -E install -m 755 -p -D maintenance/mtcAgent $BIN_DIR/mtcAgent
    sudo -E install -m 755 -p -D maintenance/mtcClient $BIN_DIR/mtcClient
    sudo -E install -m 755 -p -D heartbeat/hbsAgent $BIN_DIR/hbsAgent
    sudo -E install -m 755 -p -D heartbeat/hbsClient $BIN_DIR/hbsClient
    sudo -E install -m 755 -p -D guest/guestServer $BIN_DIR/guestServer
    sudo -E install -m 755 -p -D guest/guestAgent $BIN_DIR/guestAgent
    sudo -E install -m 755 -p -D pmon/pmond $BIN_DIR/pmond
    sudo -E install -m 755 -p -D hostw/hostwd $BIN_DIR/hostwd
    sudo -E install -m 755 -p -D rmon/rmond $BIN_DIR/rmond
    sudo -E install -m 755 -p -D fsmon/fsmond $BIN_DIR/fsmond
    sudo -E install -m 755 -p -D hwmon/hwmond $BIN_DIR/hwmond
    sudo -E install -m 755 -p -D mtclog/mtclogd $BIN_DIR/mtclogd
    sudo -E install -m 755 -p -D alarm/mtcalarmd $BIN_DIR/mtcalarmd
    sudo -E install -m 755 -p -D rmon/rmon_resource_notify/rmon_resource_notify $BIN_DIR/rmon_resource_notify
    sudo -E install -m 755 -p -D scripts/wipedisk $BIN_DIR/wipedisk
    sudo -E install -m 755 -p -D common/fsync $SBIN_DIR/fsync
    sudo -E install -m 700 -p -D pmon/scripts/pmon-restart $SBIN_DIR/pmon-restart
    sudo -E install -m 700 -p -D pmon/scripts/pmon-start $SBIN_DIR/pmon-start
    sudo -E install -m 700 -p -D pmon/scripts/pmon-stop $SBIN_DIR/pmon-stop

    # test tools
    sudo -E install -m 755 hwmon/scripts/show_hp360 $SBIN_DIR/show_hp360
    sudo -E install -m 755 hwmon/scripts/show_hp380 $SBIN_DIR/show_hp380
    sudo -E install -m 755 hwmon/scripts/show_quanta $SBIN_DIR/show_quanta

    # init script files
    sudo -E install -m 755 -p -D scripts/mtcClient /etc/init.d/mtcClient
    sudo -E install -m 755 -p -D scripts/hbsClient /etc/init.d/hbsClient
    sudo -E install -m 755 -p -D guest/scripts/guestServer /etc/init.d/guestServer
    sudo -E install -m 755 -p -D guest/scripts/guestAgent /etc/init.d/guestAgent
    sudo -E install -m 755 -p -D hwmon/scripts/lsb/hwmon /etc/init.d/hwmon
    sudo -E install -m 755 -p -D fsmon/scripts/fsmon /etc/init.d/fsmon
    sudo -E install -m 755 -p -D scripts/mtclog /etc/init.d/mtclog
    sudo -E install -m 755 -p -D pmon/scripts/pmon /etc/init.d/pmon
    sudo -E install -m 755 -p -D rmon/scripts/rmon /etc/init.d/rmon
    sudo -E install -m 755 -p -D hostw/scripts/hostw /etc/init.d/hostw
    sudo -E install -m 755 -p -D alarm/scripts/mtcalarm.init /etc/init.d/mtcalarm

    # sudo -E install -m 755 -p -D scripts/config /etc/init.d/config

    # TODO: Init hack. Should move to proper module
    sudo -E install -m 755 -p -D scripts/hwclock.sh /etc/init.d/hwclock.sh
    sudo -E install -m 644 -p -D scripts/hwclock.service %{_unitdir}/hwclock.service

    # systemd service files
    sudo -E install -m 644 -p -D fsmon/scripts/fsmon.service $UNIT_DIR/fsmon.service
    sudo -E install -m 644 -p -D hwmon/scripts/hwmon.service $UNIT_DIR/hwmon.service
    sudo -E install -m 644 -p -D rmon/scripts/rmon.service $UNIT_DIR/rmon.service
    sudo -E install -m 644 -p -D pmon/scripts/pmon.service $UNIT_DIR/pmon.service
    sudo -E install -m 644 -p -D hostw/scripts/hostw.service $UNIT_DIR/hostw.service
    sudo -E install -m 644 -p -D guest/scripts/guestServer.service $UNIT_DIR/guestServer.service
    sudo -E install -m 644 -p -D guest/scripts/guestAgent.service $UNIT_DIR/guestAgent.service
    sudo -E install -m 644 -p -D scripts/mtcClient.service $UNIT_DIR/mtcClient.service
    sudo -E install -m 644 -p -D scripts/hbsClient.service $UNIT_DIR/hbsClient.service
    sudo -E install -m 644 -p -D scripts/mtclog.service $UNIT_DIR/mtclog.service
    sudo -E install -m 644 -p -D scripts/goenabled.service $UNIT_DIR/goenabled.service
    sudo -E install -m 644 -p -D scripts/runservices.service $UNIT_DIR/runservices.service
    sudo -E install -m 644 -p -D alarm/scripts/mtcalarm.service $UNIT_DIR/mtcalarm.service

    # go enabled stuff
    sudo -E install -m 755 -p -D scripts/goenabled /etc/init.d/goenabled

    # start or stop services test script
    sudo -E install -m 755 -d /etc/services.d
    sudo -E install -m 755 -d /etc/services.d/controller
    sudo -E install -m 755 -d /etc/services.d/compute
    sudo -E install -m 755 -d /etc/services.d/storage
    sudo -E install -m 755 -p -D scripts/mtcTest /etc/services.d/compute
    sudo -E install -m 755 -p -D scripts/mtcTest /etc/services.d/controller
    sudo -E install -m 755 -p -D scripts/mtcTest /etc/services.d/storage
    sudo -E install -m 755 -p -D scripts/runservices /etc/init.d/runservices

    # test tools
    sudo -E install -m 755 -p -D scripts/dmemchk.sh $SBIN_DIR

    # process monitor config files
    sudo -E install -m 755 -d /etc/pmon.d
    sudo -E install -m 644 -p -D scripts/mtcClient.conf /etc/pmon.d/mtcClient.conf
    sudo -E install -m 644 -p -D scripts/hbsClient.conf /etc/pmon.d/hbsClient.conf
    sudo -E install -m 644 -p -D pmon/scripts/acpid.conf /etc/pmon.d/acpid.conf
    sudo -E install -m 644 -p -D pmon/scripts/sshd.conf /etc/pmon.d/sshd.conf
    sudo -E install -m 644 -p -D pmon/scripts/ntpd.conf /etc/pmon.d/ntpd.conf
    sudo -E install -m 644 -p -D pmon/scripts/syslog-ng.conf /etc/pmon.d/syslog-ng.conf
    sudo -E install -m 644 -p -D rmon/scripts/rmon.conf /etc/pmon.d/rmon.conf
    sudo -E install -m 644 -p -D fsmon/scripts/fsmon.conf /etc/pmon.d/fsmon.conf
    sudo -E install -m 644 -p -D scripts/mtclogd.conf /etc/pmon.d/mtclogd.conf
    sudo -E install -m 644 -p -D guest/scripts/guestServer.pmon /etc/pmon.d/guestServer.conf
    sudo -E install -m 644 -p -D alarm/scripts/mtcalarm.pmon.conf /etc/pmon.d/mtcalarm.conf

    # resource monitor config files
    sudo -E install -m 755 -d /etc/rmon.d
    sudo -E install -m 755 -d /etc/rmonapi.d
    sudo -E install -m 755 -d /etc/rmonfiles.d
    sudo -E install -m 755 -d /etc/rmon_interfaces.d
    sudo -E install -m 644 -p -D rmon/scripts/remotelogging_resource.conf /etc/rmon.d/remotelogging_resource.conf
    #sudo -E install -m 644 -p -D rmon/scripts/cpu_resource.conf /etc/rmon.d/cpu_resource.conf
    sudo -E install -m 644 -p -D rmon/scripts/memory_resource.conf /etc/rmon.d/memory_resource.conf
    sudo -E install -m 644 -p -D rmon/scripts/filesystem_resource.conf /etc/rmon.d/filesystem_resource.conf
    sudo -E install -m 644 -p -D rmon/scripts/cinder_virtual_resource.conf /etc/rmon.d/cinder_virtual_resource.conf
    sudo -E install -m 644 -p -D rmon/scripts/nova_virtual_resource.conf /etc/rmon.d/nova_virtual_resource.conf
    sudo -E install -m 644 -p -D rmon/scripts/oam_resource.conf /etc/rmon_interfaces.d/oam_resource.conf
    sudo -E install -m 644 -p -D rmon/scripts/management_resource.conf /etc/rmon_interfaces.d/management_resource.conf
    sudo -E install -m 644 -p -D rmon/scripts/infrastructure_resource.conf /etc/rmon_interfaces.d/infrastructure_resource.conf
    sudo -E install -m 755 -p -D rmon/scripts/query_ntp_servers.sh /etc/rmonfiles.d/query_ntp_servers.sh
    sudo -E install -m 755 -p -D rmon/scripts/rmon_reload_on_cpe.sh /etc/goenabled.d/rmon_reload_on_cpe.sh

    # log rotation
    sudo -E install -m 755 -d /etc/logrotate.d
    sudo -E install -m 644 -p -D scripts/mtce.logrotate /etc/logrotate.d/mtce.logrotate
    sudo -E install -m 644 -p -D hostw/scripts/hostw.logrotate /etc/logrotate.d/hostw.logrotate
    sudo -E install -m 644 -p -D pmon/scripts/pmon.logrotate /etc/logrotate.d/pmon.logrotate
    sudo -E install -m 644 -p -D rmon/scripts/rmon.logrotate /etc/logrotate.d/rmon.logrotate
    sudo -E install -m 644 -p -D fsmon/scripts/fsmon.logrotate /etc/logrotate.d/fsmon.logrotate
    sudo -E install -m 644 -p -D hwmon/scripts/hwmon.logrotate /etc/logrotate.d/hwmon.logrotate
    sudo -E install -m 644 -p -D guest/scripts/guestAgent.logrotate /etc/logrotate.d/guestAgent.logrotate
    sudo -E install -m 644 -p -D guest/scripts/guestServer.logrotate /etc/logrotate.d/guestServer.logrotate
    sudo -E install -m 644 -p -D alarm/scripts/mtcalarm.logrotate /etc/logrotate.d/mtcalarm.logrotate

    sudo -E install -m 755 -p -D public/libamon.so.$MAJOR $LIBDIR/libamon.so.$MAJOR
    cd $LIB_DIR ; ln -s libamon.so.$MAJOR libamon.so.$MAJOR.$MINOR
    cd $LIB_DIR ; ln -s libamon.so.$MAJOR libamon.so

    sudo -E install -m 755 -p -D rmon/rmonApi/librmonapi.so.$MAJOR $LIB_DIR/librmonapi.so.$MAJOR
    cd $LIB_DIR ; ln -s librmonapi.so.$MAJOR librmonapi.so.$MAJOR.$MINOR
    cd $LIB_DIR ; ln -s librmonapi.so.$MAJOR librmonapi.so

}

function unstack_mtce_common(){
    cd $MTCE_COMMON_DIR
    sudo make clean

    # Resource Agent
    sudo -E rm -rf $LIB_DIR/ocf/resource.d/platform/mtcAgent
    sudo -E rm -rf $LIB_DIR/ocf/resource.d/platform/hbsAgent
    sudo -E rm -rf $LIB_DIR/ocf/resource.d/platform/hwmon
    sudo -E rm -rf $LIB_DIR/ocf/resource.d/platform/guestAgent

    # Config files
    sudo -E rm -rf /etc/mtc.ini
    sudo -E rm -rf /etc/mtc.conf
    sudo -E rm -rf /etc/mtc/fsmond.conf
    sudo -E rm -rf /etc/mtc/hwmond.conf
    sudo -E rm -rf /etc/mtc/pmond.conf
    sudo -E rm -rf /etc/mtc/rmond.conf
    sudo -E rm -rf /etc/mtc/guestAgent.ini
    sudo -E rm -rf /etc/mtc/guestServer.ini
    sudo -E rm -rf /etc/mtc/hostwd.conf

    sudo -E rm -rf  /etc/etc/bmc/server_profiles.d

    # binaries
    sudo -E rm -rf $BIN_DIR/mtcAgent
    sudo -E rm -rf $BIN_DIR/mtcClient
    sudo -E rm -rf $BIN_DIR/hbsAgent
    sudo -E rm -rf $BIN_DIR/hbsClient
    sudo -E rm -rf $BIN_DIR/guestServer
    sudo -E rm -rf $BIN_DIR/guestAgent
    sudo -E rm -rf $BIN_DIR/pmond
    sudo -E rm -rf $BIN_DIR/hostwd
    sudo -E rm -rf $BIN_DIR/rmond
    sudo -E rm -rf $BIN_DIR/fsmond
    sudo -E rm -rf $BIN_DIR/hwmond
    sudo -E rm -rf $BIN_DIR/mtclogd
    sudo -E rm -rf $BIN_DIR/mtcalarmd
    sudo -E rm -rf $BIN_DIR/rmon_resource_notify
    sudo -E rm -rf $BIN_DIR/wipedisk
    sudo -E rm -rf $SBIN_DIR/fsync
    sudo -E rm -rf $SBIN_DIR/pmon-restart
    sudo -E rm -rf $SBIN_DIR/pmon-start
    sudo -E rm -rf $SBIN_DIR/pmon-stop

    # test tools
    sudo -E rm -rf $SBIN_DIR/show_hp360
    sudo -E rm -rf $SBIN_DIR/show_hp380
    sudo -E rm -rf $SBIN_DIR/show_quanta

    # init script files
    sudo -E rm -rf /etc/init.d/mtcClient
    sudo -E rm -rf /etc/init.d/hbsClient
    sudo -E rm -rf /etc/init.d/guestServer
    sudo -E rm -rf /etc/init.d/guestAgent
    sudo -E rm -rf /etc/init.d/hwmon
    sudo -E rm -rf /etc/init.d/fsmon
    sudo -E rm -rf /etc/init.d/mtclog
    sudo -E rm -rf /etc/init.d/pmon
    sudo -E rm -rf /etc/init.d/rmon
    sudo -E rm -rf /etc/init.d/hostw
    sudo -E rm -rf /etc/init.d/mtcalarm

    # sudo -E rm -rf -m 755 -p -D scripts/config /etc/init.d/config

    # TODO: Init hack. Should move to proper module
    sudo -E rm -rf /etc/init.d/hwclock.sh
    sudo -E rm -rf $UNIT_DIR/hwclock.service

    # systemd service files
    sudo -E rm -rf $UNIT_DIR/fsmon.service
    sudo -E rm -rf $UNIT_DIR/hwmon.service
    sudo -E rm -rf $UNIT_DIR/rmon.service
    sudo -E rm -rf $UNIT_DIR/pmon.service
    sudo -E rm -rf $UNIT_DIR/hostw.service
    sudo -E rm -rf $UNIT_DIR/guestServer.service
    sudo -E rm -rf 644 -p -D guest/scripts/guestAgent.service $UNIT_DIR/guestAgent.service
    sudo -E rm -rf 644 -p -D scripts/mtcClient.service $UNIT_DIR/mtcClient.service
    sudo -E rm -rf 644 -p -D scripts/hbsClient.service $UNIT_DIR/hbsClient.service
    sudo -E rm -rf 644 -p -D scripts/mtclog.service $UNIT_DIR/mtclog.service
    sudo -E rm -rf 644 -p -D scripts/goenabled.service $UNIT_DIR/goenabled.service
    sudo -E rm -rf 644 -p -D scripts/runservices.service $UNIT_DIR/runservices.service
    sudo -E rm -rf 644 -p -D alarm/scripts/mtcalarm.service $UNIT_DIR/mtcalarm.service

    # go enabled stuff
    sudo -E rm -rf 755 -p -D scripts/goenabled /etc/init.d/goenabled

    # start or stop services test script
    sudo -E rm -rf 755 -d /etc/services.d
    sudo -E rm -rf 755 -d /etc/services.d/controller
    sudo -E rm -rf 755 -d /etc/services.d/compute
    sudo -E rm -rf 755 -d /etc/services.d/storage
    sudo -E rm -rf 755 -p -D scripts/mtcTest /etc/services.d/compute
    sudo -E rm -rf 755 -p -D scripts/mtcTest /etc/services.d/controller
    sudo -E rm -rf 755 -p -D scripts/mtcTest /etc/services.d/storage
    sudo -E rm -rf 755 -p -D scripts/runservices /etc/init.d/runservices

    # test tools
    sudo -E rm -rf 755 -p -D scripts/dmemchk.sh $SBIN_DIR

    # process monitor config files
    sudo -E rm -rf 755 -d /etc/pmon.d
    sudo -E rm -rf 644 -p -D scripts/mtcClient.conf /etc/pmon.d/mtcClient.conf
    sudo -E rm -rf 644 -p -D scripts/hbsClient.conf /etc/pmon.d/hbsClient.conf
    sudo -E rm -rf 644 -p -D pmon/scripts/acpid.conf /etc/pmon.d/acpid.conf
    sudo -E rm -rf 644 -p -D pmon/scripts/sshd.conf /etc/pmon.d/sshd.conf
    sudo -E rm -rf 644 -p -D pmon/scripts/ntpd.conf /etc/pmon.d/ntpd.conf
    sudo -E rm -rf 644 -p -D pmon/scripts/syslog-ng.conf /etc/pmon.d/syslog-ng.conf
    sudo -E rm -rf 644 -p -D rmon/scripts/rmon.conf /etc/pmon.d/rmon.conf
    sudo -E rm -rf 644 -p -D fsmon/scripts/fsmon.conf /etc/pmon.d/fsmon.conf
    sudo -E rm -rf 644 -p -D scripts/mtclogd.conf /etc/pmon.d/mtclogd.conf
    sudo -E rm -rf 644 -p -D guest/scripts/guestServer.pmon /etc/pmon.d/guestServer.conf
    sudo -E rm -rf 644 -p -D alarm/scripts/mtcalarm.pmon.conf /etc/pmon.d/mtcalarm.conf

    # resource monitor config files
    sudo -E rm -rf 755 -d /etc/rmon.d
    sudo -E rm -rf 755 -d /etc/rmonapi.d
    sudo -E rm -rf 755 -d /etc/rmonfiles.d
    sudo -E rm -rf 755 -d /etc/rmon_interfaces.d
    sudo -E rm -rf 644 -p -D rmon/scripts/remotelogging_resource.conf /etc/rmon.d/remotelogging_resource.conf
    sudo -E rm -rf 644 -p -D rmon/scripts/cpu_resource.conf /etc/rmon.d/cpu_resource.conf
    sudo -E rm -rf 644 -p -D rmon/scripts/memory_resource.conf /etc/rmon.d/memory_resource.conf
    sudo -E rm -rf 644 -p -D rmon/scripts/filesystem_resource.conf /etc/rmon.d/filesystem_resource.conf
    sudo -E rm -rf 644 -p -D rmon/scripts/cinder_virtual_resource.conf /etc/rmon.d/cinder_virtual_resource.conf
    sudo -E rm -rf 644 -p -D rmon/scripts/nova_virtual_resource.conf /etc/rmon.d/nova_virtual_resource.conf
    sudo -E rm -rf 644 -p -D rmon/scripts/oam_resource.conf /etc/rmon_interfaces.d/oam_resource.conf
    sudo -E rm -rf 644 -p -D rmon/scripts/management_resource.conf /etc/rmon_interfaces.d/management_resource.conf
    sudo -E rm -rf 644 -p -D rmon/scripts/infrastructure_resource.conf /etc/rmon_interfaces.d/infrastructure_resource.conf
    sudo -E rm -rf 755 -p -D rmon/scripts/query_ntp_servers.sh /etc/rmonfiles.d/query_ntp_servers.sh
    sudo -E rm -rf 755 -p -D rmon/scripts/rmon_reload_on_cpe.sh /etc/goenabled.d/rmon_reload_on_cpe.sh

    # log rotation
    sudo -E rm -rf 755 -d /etc/logrotate.d
    sudo -E rm -rf 644 -p -D scripts/mtce.logrotate /etc/logrotate.d/mtce.logrotate
    sudo -E rm -rf 644 -p -D hostw/scripts/hostw.logrotate /etc/logrotate.d/hostw.logrotate
    sudo -E rm -rf 644 -p -D pmon/scripts/pmon.logrotate /etc/logrotate.d/pmon.logrotate
    sudo -E rm -rf 644 -p -D rmon/scripts/rmon.logrotate /etc/logrotate.d/rmon.logrotate
    sudo -E rm -rf 644 -p -D fsmon/scripts/fsmon.logrotate /etc/logrotate.d/fsmon.logrotate
    sudo -E rm -rf 644 -p -D hwmon/scripts/hwmon.logrotate /etc/logrotate.d/hwmon.logrotate
    sudo -E rm -rf 644 -p -D guest/scripts/guestAgent.logrotate /etc/logrotate.d/guestAgent.logrotate
    sudo -E rm -rf 644 -p -D guest/scripts/guestServer.logrotate /etc/logrotate.d/guestServer.logrotate
    sudo -E rm -rf 644 -p -D alarm/scripts/mtcalarm.logrotate /etc/logrotate.d/mtcalarm.logrotate

    sudo -E rm -rf 755 -p -D public/libamon.so.$MAJOR $LIBDIR/libamon.so.$MAJOR
    cd $LIB_DIR ; ln -s libamon.so.$MAJOR libamon.so.$MAJOR.$MINOR
    cd $LIB_DIR ; ln -s libamon.so.$MAJOR libamon.so

    sudo -E rm -rf 755 -p -D rmon/rmonApi/librmonapi.so.$MAJOR $LIB_DIR/librmonapi.so.$MAJOR

}
