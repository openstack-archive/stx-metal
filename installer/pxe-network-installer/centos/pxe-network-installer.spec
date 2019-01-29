Summary: TIS Network Installation
Name: pxe-network-installer
Version: 1.0
Release: %{tis_patch_ver}%{?_tis_dist}
License: Apache-2.0
Group: base
Packager: Wind River <info@windriver.com>
URL: unknown

Source0: LICENSE

Source1: vmlinuz
Source2: initrd.img
Source3: squashfs.img

Source10: pxeboot-update.sh
Source11: grub.cfg
Source12: efiboot.img
Source13: post_clone_iso_ks.cfg

Source30: default
Source31: default.static
Source32: centos-pxe-controller-install
Source33: centos-pxe-worker-install
Source34: centos-pxe-smallsystem-install
Source35: centos-pxe-storage-install
Source36: centos-pxe-worker_lowlatency-install
Source37: centos-pxe-smallsystem_lowlatency-install

Source50: pxe-grub.cfg
Source51: pxe-grub.cfg.static
Source52: efi-centos-pxe-controller-install
Source53: efi-centos-pxe-worker-install
Source54: efi-centos-pxe-smallsystem-install
Source55: efi-centos-pxe-storage-install
Source56: efi-centos-pxe-worker_lowlatency-install
Source57: efi-centos-pxe-smallsystem_lowlatency-install


BuildRequires: syslinux
BuildRequires: grub2
BuildRequires: grub2-efi-x64-pxeboot

Requires: grub2-efi-x64-pxeboot

%description
TIS Network Installation

%files
%defattr(-,root,root,-)

%install
install -v -d -m 755 %{buildroot}/pxeboot
install -v -d -m 755 %{buildroot}/pxeboot/pxelinux.cfg.files
install -v -d -m 755 %{buildroot}/pxeboot/rel-%{platform_release}
install -v -d -m 755 %{buildroot}/pxeboot/EFI
install -v -d -m 755 %{buildroot}/pxeboot/EFI/centos
ln -s %{_prefix}/lib/grub/x86_64-efi %{buildroot}/pxeboot/EFI/centos/x86_64-efi

install -v -m 644 %{SOURCE1} \
    %{buildroot}/pxeboot/rel-%{platform_release}/installer-bzImage_1.0
install -v -m 644 %{SOURCE2} \
    %{buildroot}/pxeboot/rel-%{platform_release}/installer-intel-x86-64-initrd_1.0
ln -s installer-bzImage_1.0 %{buildroot}/pxeboot/rel-%{platform_release}/installer-bzImage
ln -s installer-intel-x86-64-initrd_1.0 %{buildroot}/pxeboot/rel-%{platform_release}/installer-initrd

install -v -D -m 644 %{SOURCE3} \
    %{buildroot}/www/pages/feed/rel-%{platform_release}/LiveOS/squashfs.img

install -v -d -m 755 %{buildroot}%{_sbindir}

install -v -m 755 %{SOURCE10} %{buildroot}%{_sbindir}/pxeboot-update-%{platform_release}.sh

install -v -m 644 %{SOURCE13} \
    %{buildroot}/pxeboot/post_clone_iso_ks.cfg

install -v -m 644 %{SOURCE30} \
    %{buildroot}/pxeboot/pxelinux.cfg.files/default
install -v -m 644 %{SOURCE31} \
    %{buildroot}/pxeboot/pxelinux.cfg.files/default.static
install -v -m 644 %{SOURCE32} \
    %{buildroot}/pxeboot/pxelinux.cfg.files/pxe-controller-install-%{platform_release}
install -v -m 644 %{SOURCE33} \
    %{buildroot}/pxeboot/pxelinux.cfg.files/pxe-worker-install-%{platform_release}
install -v -m 644 %{SOURCE34} \
    %{buildroot}/pxeboot/pxelinux.cfg.files/pxe-smallsystem-install-%{platform_release}
install -v -m 644 %{SOURCE35} \
    %{buildroot}/pxeboot/pxelinux.cfg.files/pxe-storage-install-%{platform_release}
install -v -m 644 %{SOURCE36} \
    %{buildroot}/pxeboot/pxelinux.cfg.files/pxe-worker_lowlatency-install-%{platform_release}
install -v -m 644 %{SOURCE37} \
    %{buildroot}/pxeboot/pxelinux.cfg.files/pxe-smallsystem_lowlatency-install-%{platform_release}


# UEFI support
install -v -m 644 %{SOURCE50} \
    %{buildroot}/pxeboot/pxelinux.cfg.files/grub.cfg
install -v -m 644 %{SOURCE51} \
    %{buildroot}/pxeboot/pxelinux.cfg.files/grub.cfg.static
# Copy EFI boot image. It will be used to create ISO on the Controller.
install -v -m 644 %{SOURCE12} \
    %{buildroot}/pxeboot/rel-%{platform_release}/
install -v -m 644 %{SOURCE52} \
    %{buildroot}/pxeboot/pxelinux.cfg.files/efi-pxe-controller-install-%{platform_release}
install -v -m 644 %{SOURCE53} \
    %{buildroot}/pxeboot/pxelinux.cfg.files/efi-pxe-worker-install-%{platform_release}
install -v -m 644 %{SOURCE54} \
    %{buildroot}/pxeboot/pxelinux.cfg.files/efi-pxe-smallsystem-install-%{platform_release}
install -v -m 644 %{SOURCE55} \
    %{buildroot}/pxeboot/pxelinux.cfg.files/efi-pxe-storage-install-%{platform_release}
install -v -m 644 %{SOURCE56} \
    %{buildroot}/pxeboot/pxelinux.cfg.files/efi-pxe-worker_lowlatency-install-%{platform_release}
install -v -m 644 %{SOURCE57} \
    %{buildroot}/pxeboot/pxelinux.cfg.files/efi-pxe-smallsystem_lowlatency-install-%{platform_release}


sed -i "s/xxxSW_VERSIONxxx/%{platform_release}/g" \
    %{buildroot}/pxeboot/pxelinux.cfg.files/pxe-* \
    %{buildroot}/pxeboot/pxelinux.cfg.files/efi-pxe-*

# Copy files from the syslinux pkg
install -v -m 0644 \
    %{_datadir}/syslinux/menu.c32 \
    %{_datadir}/syslinux/vesamenu.c32 \
    %{_datadir}/syslinux/chain.c32 \
    %{_datadir}/syslinux/linux.c32 \
    %{_datadir}/syslinux/reboot.c32 \
    %{_datadir}/syslinux/pxechain.com \
    %{_datadir}/syslinux/pxelinux.0 \
    %{_datadir}/syslinux/gpxelinux.0 \
    %{buildroot}/pxeboot

# Copy Titanium grub.cfg. It will be used to create ISO on the Controller.
install -v -m 0644 %{SOURCE11} \
    %{buildroot}/pxeboot/EFI/

# UEFI bootloader expect the grub.cfg file to be in /pxeboot/ so create a symlink for it
ln -s pxelinux.cfg/grub.cfg %{buildroot}/pxeboot/grub.cfg

%files
%license ../SOURCES/LICENSE
%defattr(-,root,root,-)
%dir /pxeboot
/pxeboot/*
%{_sbindir}/pxeboot-update-%{platform_release}.sh
/www/pages/feed/rel-%{platform_release}/LiveOS/squashfs.img

