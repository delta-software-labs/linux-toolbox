#!/usr/bin/make -f

include src/_colors.mk

check:
	@echo ":: Checking $(WHITE)FOO$(RESET) directory."
	@echo ":: Checking $(BG_YELLOW)FOO$(RESET) directory."
	@echo ":: Checking $(BG_YELLOW)$(CYAN)FOO$(RESET) directory."

