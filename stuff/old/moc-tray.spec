Name:           moc-tray
Version:        0.3
Release:        1%{?dist}
Summary:        Control your music on console player via tray icon

Group:          Applications/Multimedia
License:        GPLv3
URL:            http://moc-tray.googlecode.com/
Source0:        http://moc-tray.googlecode.com/files/moc-tray-%{version}.tar.bz2
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch

Requires:       perl

%description
moc-tray allows quick and easy access to mocp basic functions 
and console interface via tray pop-up menu. Written in gtk2-perl.

%prep
%setup -q


%build


%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc CREDITS ChangeLog
%{_bindir}/moc-tray


%changelog
* Thu Mar 19 2009 Bartłomiej "Rotwang" Palmowski <rotwang@crux.org.pl> - 0.3-1
* Wed Mar 18 2009 Marcin "czaks" Łabanowski <chax@i-rpg.net> - 0.2.1-1
- initial release
