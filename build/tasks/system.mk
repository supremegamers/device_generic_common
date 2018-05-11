$(PRODUCT_OUT)/build.prop: $(INSTALLED_BUILD_PROP_TARGET)
	sed -E '/ro.product.manufacturer|ro.product.model/d' $< > $@ && cat $@ > $<

$(BUILT_SYSTEMIMAGE): $(PRODUCT_OUT)/build.prop

ifneq ($(MKSQUASHFS),)
$(systemimg): $(BUILT_SYSTEMIMAGE) | $(MKSQUASHFS)
	$(call build-squashfs-target,$^,$@)
endif
