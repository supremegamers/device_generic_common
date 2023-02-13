$(PRODUCT_OUT)/build.prop: $(INSTALLED_BUILD_PROP_TARGET) $(INSTALLED_VENDOR_BUILD_PROP_TARGET)
	sed -i -E '/ro.product.*manufacturer|ro.product.*model/d' $^ && touch $@

$(BUILT_SYSTEMIMAGE): $(PRODUCT_OUT)/build.prop

ifneq ($(MKSQUASHFS),)
$(systemimg): $(BUILT_SYSTEMIMAGE) | $(MKSQUASHFS)
	$(call build-squashfs-target,$^,$@)
endif

ifneq ($(MKEROFS),)
$(systemimg): $(BUILT_SYSTEMIMAGE) | $(MKEROFS)
	$(call build-erofs-target,$^,$@)
endif
