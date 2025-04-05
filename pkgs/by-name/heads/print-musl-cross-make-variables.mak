.DEFAULT_GOAL := all

VARS_OLD := $(.VARIABLES)

-include $(src)/Makefile

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
