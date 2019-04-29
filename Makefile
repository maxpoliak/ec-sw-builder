#
# Makefile
#
# Copyright (C) 2019 Maxim Polyakov <max.senia.poliak@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#

#  name of linux kernel module
MODULE_NAME ?= ec
MODULE_DIR  ?= fabric-ec

# absolute path sdk
THIS_FILE := $(lastword $(MAKEFILE_LIST))
THIS_DIR  := $(abspath $(dir $(THIS_FILE)))

# objects
ALL_DIRS  := $(subst /, , $(subst $(THIS_DIR)/, , $(shell ls -d $(THIS_DIR)/*/ ) ))
MOD_DIR   := $(MODULE_DIR)
GLB_DIRS  := $(addprefix $(THIS_DIR)/, $(sort $(MOD_DIR)))
SOURCES   := $(filter %.c , $(wildcard $(addsuffix /*.*, $(GLB_DIRS))))
OBJECTS   := $(addsuffix .o , $(subst $(THIS_DIR)/, , $(basename $(SOURCES))))

# applications
APP_DIRS  := $(subst $(PATCH_DIR), ,$(subst $(MOD_DIR), ,$(ALL_DIRS)))
APP_MAKE  = $(foreach dir,$(APP_DIRS),$(shell make -f $(THIS_DIR)/$(dir)/Makefile))
APP_CLEAN = $(foreach dir,$(APP_DIRS),$(shell make -f $(THIS_DIR)/$(dir)/Makefile clean))

obj-m += $(MODULE_NAME).o
ccflags-y := -Wall -O -Wmaybe-uninitialized -Werror -I$(THIS_DIR)/ecdrv -DEC_MOD_NAME="$(MODULE_NAME)"
$(MODULE_NAME)-y := $(OBJECTS)

ifneq ($(KERNELRELEASE),)
# call from kernel build system
else

KERNELVER ?= $(shell uname -r)
KERNELDIR := /lib/modules/$(KERNELVER)/build
PWD       := $(THIS_DIR)

default:
	@echo ' '
	@echo '  [ MOD ]  Build:'
	$(MAKE) -C $(KERNELDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) clean
endif

all: info default application

install:
	sudo insmod $(MODULE_NAME).ko
	@echo '  [ INS ]  Install module in linux kernel!'

remove:
	sudo rmmod $(MODULE_NAME)
	@echo '  [ REM ]  Remove module from kernel!'
	@echo ' '

reinstall: remove install

init:
	git submodule init && git submodule update

application:
	@echo ' '
	@echo '  [ APP ]  Build user space applications:'
	@echo $(APP_MAKE)

cleanapp:
	@echo ' '
	@echo '  [ APP ]  Remove examples:'
	@echo ' '
	@echo $(APP_CLEAN)

cleanall: clean cleanapp

info:
	@echo ' '
	@echo 'Patches:      '$(addprefix "\n" ' [ MOD ]  ' , $(PATCHES) )
	@echo ' '
	@echo 'Directories:  '$(addprefix "\n" ' [ MOD ]  ' , $(MOD_DIR) )
	@echo ' '
	@echo 'Directories:  '$(addprefix "\n" ' [ APP ]  ' , $(APP_DIRS) )
	@echo ' '
	@echo 'Source files: '$(addprefix "\n" ' [ SRC ]  ' , $(SOURCES) )
	@echo ' '
	@echo 'Object files: '$(addprefix "\n" ' [ OBJ ]  ' , $(OBJECTS) )

help:
	@echo ' '
	@echo '  MODULE_NAME - name of module;'
	@echo '  MODULE_DIR - name of the directory that contains the kernel;'
	@echo ' '
	@echo '    Build or clear all SDK:'
	@echo ' '
	@echo '  (shell)$ cd /path/to/sdk'
	@echo '  (shell)$ make init'
	@echo '  (shell)$ make all'
	@echo '  (shell)$ make cleanall'
	@echo ' '
	@echo '    Building or cleaning only the kernel module:'
	@echo '  (shell)$ make'
	@echo '  (shell)$ make clean'
	@echo ' '
	@echo '    User application example build ( clear ) only:'
	@echo '  (shell)$ make app'
	@echo '  (shell)$ make cleanapp'
	@echo ' '
	@echo '    Print information about SDK:'
	@echo '  (shell)$ make info'
	@echo '  (shell)$ make help'
	@echo ' '
	@echo '    Load or unload module:'
	@echo '  (shell)$ make install'
	@echo '  (shell)$ make remove'
	@echo '  (shell)$ make reinstall'

ifeq (.depend,$(wildcard .depend))
include .depend
endif
