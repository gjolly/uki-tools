BINDIR			= $(DESTDIR)/usr/bin
KERNEL_HOOKS_DIR 	= $(DESTDIR)/etc/kernel

install:
	$(INSTALL) -m 755 -d $(BINDIR)
	$(INSTALL) -m 755 generate-uki.sh $(BINDIR)/generate-uki
	$(INSTALL) -m 755 -d $(KERNEL_HOOKS_DIR)
	$(INSTALL) -m 755 -d $(KERNEL_HOOKS_DIR)/postinst.d
	$(INSTALL) -m 755 -d $(KERNEL_HOOKS_DIR)/postrm.d
	$(INSTALL) -m 755 kernel-postinst.sh $(KERNEL_HOOKS_DIR)/postinst.d/zz-unified-kernel-image
	$(INSTALL) -m 755 kernel-postrm.sh $(KERNEL_HOOKS_DIR)/postrm.d/zz-unified-kernel-image

uninstall:
	rm $(DESTDIR)/$(bindir)/generate-uki
	rm $(DESTDIR)/$(kernelhooksdir)/postinst.d/zz-unified-kernel-image
	rm $(DESTDIR)/$(kernelhooksdir)/postrm.d/zz-unified-kernel-image
