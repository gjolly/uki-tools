DESTDIR ?=
INSTALL ?= install

INSTALL_PROGRAM ?= $(INSTALL)
INSTALL_DATA ?= ${INSTALL} -m 644

bindir :=  usr/bin
kernelhooksdir := etc/kernel

install:
	mkdir -p $(DESTDIR)/$(bindir)
	mkdir -p $(DESTDIR)/$(kernelhooksdir)/postinst.d
	mkdir -p $(DESTDIR)/$(kernelhooksdir)/postrm.d
	$(INSTALL_PROGRAM) generate-uki.sh $(DESTDIR)/$(bindir)/generate-uki
	$(INSTALL_PROGRAM) kernel-postinst.sh $(DESTDIR)/$(kernelhooksdir)/postinst.d/zz-unified-kernel-image
	$(INSTALL_PROGRAM) kernel-postrm.sh $(DESTDIR)/$(kernelhooksdir)/postrm.d/zz-unified-kernel-image

uninstall:
	rm $(DESTDIR)/$(bindir)/generate-uki
	rm $(DESTDIR)/$(kernelhooksdir)/postinst.d/zz-unified-kernel-image
	rm $(DESTDIR)/$(kernelhooksdir)/postrm.d/zz-unified-kernel-image
