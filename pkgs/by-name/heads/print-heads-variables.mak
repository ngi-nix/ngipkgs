.DEFAULT_GOAL := all

BOARD ?= qemu-coreboot-fbwhiptail-tpm1
CONFIG := $(src)/boards/$(BOARD)/$(BOARD).config

VARS_OLD := $(.VARIABLES)

CONFIG_TARGET_ARCH := x86

-include $(CONFIG)

-include $(src)/modules/musl-cross-make
-include $(src)/modules/*

.PHONY:
check_source:
	@if [ "$(src)" = "" ]; then \
		echo "src not set!" >&1; \
		exit 1; \
	fi

.PHONY:
all: check_source
	$(foreach v, \
		$(filter-out $(VARS_OLD) VARS_OLD,$(.VARIABLES)), \
		$(info $(v) = $($(v))))
