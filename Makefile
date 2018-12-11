LIB_NAME ?= libgui

PROJ_FILES = ../../
LIB_FULL_NAME = $(LIB_NAME).a

VERSION = 1
#############################

-include $(PROJ_FILES)/Makefile.conf
-include $(PROJ_FILES)/Makefile.gen

# use an app-specific build dir
APP_BUILD_DIR = $(BUILD_DIR)/libs/$(LIB_NAME)

CFLAGS += -ffreestanding
CFLAGS += $(DRIVERS_CFLAGS)
CFLAGS += -I$(PROJ_FILES)/include/generated -I$(PROJ_FILES) -I$(PROJ_FILES)/libs/std -I$(PROJ_FILES)/kernel/shared -I.
# libgui depends on libtft and libtouch
# TODO: these two lines hardcode the touchscreen and tft drivers dependencies. This
# should support various drivers while the API is respected - mostly the following calls:
# touch_is_touched()
# touch_refresh_pos()
# tft_set_cursor_pos()
# tft_setbg()
# tft_setfg()
# tft_puts()
# tft_putc()
CFLAGS += -I$(PROJ_FILES)/drivers/boards/$(BOARD)/ad7843/api
CFLAGS += -I$(PROJ_FILES)/drivers/boards/$(BOARD)/ili9341/api
CFLAGS += -MMD -MP

LDFLAGS += -fno-builtin -nostdlib -nostartfiles
LD_LIBS += -lg

BUILD_DIR ?= $(PROJ_FILE)build

SRC_DIR = .
SRC = $(wildcard $(SRC_DIR)/*.c)
OBJ = $(patsubst %.c,$(APP_BUILD_DIR)/%.o,$(SRC))
DEP = $(OBJ:.o=.d)

OUT_DIRS = $(dir $(OBJ))

# file to (dist)clean
# objects and compilation related
TODEL_CLEAN += $(OBJ)
# targets
TODEL_DISTCLEAN += $(APP_BUILD_DIR)

.PHONY: app

default: all

all: $(APP_BUILD_DIR) lib

show:
	@echo
	@echo "\tAPP_BUILD_DIR\t=> " $(APP_BUILD_DIR)
	@echo
	@echo "C sources files:"
	@echo "\tSRC_DIR\t\t=> " $(SRC_DIR)
	@echo "\tSRC\t\t=> " $(SRC)
	@echo "\tOBJ\t\t=> " $(OBJ)
	@echo

lib: $(APP_BUILD_DIR)/$(LIB_FULL_NAME)

#############################################################
# build targets (driver, core, SoC, Board... and local)
# App C sources files
$(APP_BUILD_DIR)/%.o: %.c
	$(call if_changed,cc_o_c)

# lib
$(APP_BUILD_DIR)/$(LIB_FULL_NAME): $(OBJ)
	$(call if_changed,mklib)
	$(call if_changed,ranlib)

$(APP_BUILD_DIR):
	$(call cmd,mkdir)

-include $(DEP)
-include $(TESTSDEP)
