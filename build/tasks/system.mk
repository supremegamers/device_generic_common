ifneq ($(MKSQUASHFS),)
$(PRODUCT_OUT)/system.sfs: $(BUILT_SYSTEMIMAGE) | $(SIMG2IMG)
	$(hide) $(SIMG2IMG) $< $@
endif
