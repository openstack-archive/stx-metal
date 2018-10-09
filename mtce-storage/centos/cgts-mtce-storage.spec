%define local_etc_pmond      /%{_sysconfdir}/pmond.d
%define local_etc_goenabledd /%{_sysconfdir}/goenabled.d
%define local_etc_servicesd  /%{_sysconfdir}/services.d

%global debug_package %{nil}

Name: cgts-mtce-storage
Version: 1.0
Release: %{tis_patch_ver}%{?_tis_dist}
Summary: Titanium Cloud Platform Storage Node Maintenance Package

Group: base
License: Apache-2.0
Packager: Wind River <info@windriver.com>
URL: unknown

Source0: %{name}-%{version}.tar.gz

BuildRequires: systemd
BuildRequires: systemd-devel
Requires: bash
Requires: /bin/systemctl

%description
Maintenance support files for storage-only node type

%prep
%setup

%build

%install
make install_non_bb buildroot=%{buildroot} _sysconfdir=/etc _unitdir=%{_unitdir}

%post
/bin/systemctl enable goenabled-storage.service

%files
%defattr(-,root,root,-)
/etc/init.d/goenabledStorage
%{_unitdir}/goenabled-storage.service
/usr/share/licenses/cgts-mtce-storage-1.0/LICENSE

%clean
rm -rf $RPM_BUILD_ROOT
