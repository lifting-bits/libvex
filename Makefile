
.PHONY: all clean install

PWD = $(shell pwd)
UNAME = $(shell uname)
CC ?= cc
LDFLAGS ?= 
CFLAGS ?=

VEX_BUILD_DIR ?= $(PWD)/build
VEX_SRC_DIR ?= $(PWD)/VEX
VEX_INC_DIR ?= $(PWD)/VEX/pub
VEX_INSTALL_DIR ?= /usr/local

VEX_SRC_FILES := $(wildcard $(VEX_SRC_DIR)/priv/*.c)
VEX_OBJ_FILES := $(addsuffix .o, $(subst $(VEX_SRC_DIR),$(VEX_BUILD_DIR),$(VEX_SRC_FILES)))

ifeq ($(UNAME),Darwin) # Mac OS X
	VEX_LIB_EXT = so
	LDFLAGS += -dynamiclib
else
	VEX_LIB_EXT = so
	LDFLAGS += -shared
endif

CFLAGS += -I$(VEX_SRC_DIR)/pub
CFLAGS += -I$(VEX_SRC_DIR)/priv
CFLAGS += -fPIC
LDFLAGS += -fPIC

$(VEX_BUILD_DIR)/%.c.o :: $(VEX_SRC_DIR)/%.c
	@mkdir -p $(@D)
	@$(CC) $(CFLAGS) -c $< -o $@

$(VEX_BUILD_DIR)/libvex.$(VEX_LIB_EXT): $(VEX_OBJ_FILES)
	@mkdir -p $(@D)
	@$(CC) $(LDFLAGS) -o $@ $^

$(VEX_INC_DIR)/libvex_guest_offsets.h:
	@$(CC) $(VEX_SRC_DIR)/auxprogs/genoffsets.c
	@$(PWD)/a.out > $@
	@rm $(PWD)/a.out

clean:
	@rm -rf $(VEX_BUILD_DIR)
	@echo Cleaned

all: $(VEX_BUILD_DIR)/libvex.$(VEX_LIB_EXT) $(VEX_INC_DIR)/libvex_guest_offsets.h
	@echo Compiled

install: all 
	@mkdir -p $(VEX_INSTALL_DIR)/lib
	@mkdir -p $(VEX_INSTALL_DIR)/include
	@cp $(VEX_BUILD_DIR)/libvex.$(VEX_LIB_EXT) $(VEX_INSTALL_DIR)/lib
	@rm -rf $(VEX_INSTALL_DIR)/include/vex
	@cp -r $(VEX_INC_DIR) $(VEX_INSTALL_DIR)/include/vex
	@echo Installed
