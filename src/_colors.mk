RETURN    := $(shell printf "\015")
ESCAPE    := $(shell printf "\033")

RESET      = $(ESCAPE)[0m

# Define HTML colors names.
BLACK      = $(ESCAPE)[0;30m
MAROON     = $(ESCAPE)[0;31m
GREEN      = $(ESCAPE)[0;32m
OLIVE      = $(ESCAPE)[0;33m
NAVY       = $(ESCAPE)[0;34m
PURPLE     = $(ESCAPE)[0;35m
TEAL       = $(ESCAPE)[0;36m
SILVER     = $(ESCAPE)[0;37m
GRAY       = $(ESCAPE)[1;30m
RED        = $(ESCAPE)[1;31m
LIME       = $(ESCAPE)[1;32m
YELLOW     = $(ESCAPE)[1;33m
BLUE       = $(ESCAPE)[1;34m
FUCHSIA    = $(ESCAPE)[1;35m
MAGENTA    = $(ESCAPE)[1;35m
AQUA       = $(ESCAPE)[1;36m
CYAN       = $(ESCAPE)[1;36m
WHITE      = $(ESCAPE)[1;37m

# Define background colors with black foreground using HTML color names.
BG_BLACK   = ${ESCAPE}[0;7;30;40m
BG_MAROON  = ${ESCAPE}[0;7;31;40m
BG_GREEN   = ${ESCAPE}[0;7;32;40m
BG_OLIVE   = ${ESCAPE}[0;7;33;40m
BG_NAVY    = ${ESCAPE}[0;7;34;40m
BG_PURPLE  = ${ESCAPE}[0;7;35;40m
BG_TEAL    = ${ESCAPE}[0;7;36;40m
BG_SILVER  = ${ESCAPE}[0;7;37;40m
BG_GRAY    = ${ESCAPE}[0;5;30;40m
BG_RED     = ${ESCAPE}[0;5;30;41m
BG_LIME    = ${ESCAPE}[0;5;30;42m
BG_YELLOW  = ${ESCAPE}[0;5;30;43m
BG_BLUE    = ${ESCAPE}[0;5;30;44m
BG_FUCHSIA = ${ESCAPE}[0;5;30;45m
BG_MAGENTA = ${ESCAPE}[0;5;30;45m
BG_AQUA    = ${ESCAPE}[0;5;30;46m
BG_CYAN    = ${ESCAPE}[0;5;30;46m
BG_WHITE   = ${ESCAPE}[0;5;30;47m

