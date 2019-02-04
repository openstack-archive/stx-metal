# This file defines functions that can be used in %pre and %post kickstart sections, by including:
# . /tmp/ks-functions.sh
#

cat <<END_FUNCTIONS >/tmp/ks-functions.sh
#
# Copyright (c) xxxYEARxxx Wind River Systems, Inc.
#
# SPDX-License-Identifier: Apache-2.0
#

function get_by_path()
{
    local disk=\$(cd /dev ; readlink -f \$1)
    for p in /dev/disk/by-path/*; do
        if [ "\$disk" = "\$(readlink -f \$p)" ]; then
            echo \$p
            return
        fi
    done
}

function get_disk()
{
    echo \$(cd /dev ; readlink -f \$1)
}

function report_pre_failure_with_msg()
{
    local msg=\$1
    echo -e '\n\nInstallation failed.\n'
    echo "\$msg"

    exit 1
}

function report_post_failure_with_msg()
{
    local msg=\$1
    cat <<EOF >> /etc/motd

Installation failed.
\$msg

EOF
    echo "\$msg" >/etc/platform/installation_failed

    echo -e '\n\nInstallation failed.\n'
    echo "\$msg"

    exit 1
}

function report_post_failure_with_logfile()
{
    local logfile=\$1
    cat <<EOF >> /etc/motd

Installation failed.
Please see \$logfile for details of failure

EOF
    echo \$logfile >/etc/platform/installation_failed

    echo -e '\n\nInstallation failed.\n'
    cat \$logfile

    exit 1
}

function get_http_port()
{
    echo \$(cat /proc/cmdline |xargs -n1 echo |grep '^inst.repo=' | sed -r 's#^[^/]*://[^/]*:([0-9]*)/.*#\1#')
}

END_FUNCTIONS

