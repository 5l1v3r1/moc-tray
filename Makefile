# Make file for moc-tray

PREFIX=/usr
BINDIR=$(PREFIX)/bin
ICONDIR=$(PREFIX)/share/pixmaps
APPDIR=$(PREFIX)/share/applications

DESTDIR=

all : 	install

install:
	install -d $(DESTDIR)$(BINDIR) $(DESTDIR)$(ICONDIR) $(DESTDIR)$(APPDIR)
	install -m 0755 moc-tray.pl $(DESTDIR)$(BINDIR)/moc-tray
	install -m 0644 moc-tray.png $(DESTDIR)$(ICONDIR)/
	install -m 0644 moc-tray.desktop $(DESTDIR)$(APPDIR)/
