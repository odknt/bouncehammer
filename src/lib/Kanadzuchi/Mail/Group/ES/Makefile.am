# $Id: Makefile.am,v 1.1.2.2 2011/03/24 05:40:58 ak Exp $
# Copyright (C) 2011 Cubicroot Co. Ltd.
# This is the auto-Makefile for bounceHammer/src/lib/Kanadzuchi/Mail/Group/ES,
# is processed by automake to create Makefile.in.

distdir = $(BUILDROOT)/dist/lib/Kanadzuchi/Mail/Group/ES
pkgdatadir = @libdir@/Kanadzuchi/Mail/Group/ES
pkgdata_DATA = Cellphone.pm Smartphone.pm WebMail.pm

all-am:
	test -d $(distdir) || mkdir -p $(distdir)
	cp -Rp $(pkgdata_DATA) $(distdir)/

.PHONY: clean
clean:
	rm -f $(distdir)/*.pm

