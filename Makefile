# SPDX-License-Identifier: GPL-2.0
KERNELRELEASE ?= $(shell uname -r)

snd-soc-wm8960-objs := wm8960.o
obj-m += snd-soc-wm8960.o
dtbo-y += wm8960.dtbo

targets += $(dtbo-y)

# Gracefully supporting the new always-y without cutting off older target with kernel 4.x
ifeq ($(firstword $(subst ., ,$(KERNELRELEASE))),4)
	always := $(dtbo-y)
else
	always-y := $(dtbo-y)
endif

all:
	make -C /usr/src/linux-headers-$(KERNELRELEASE) M=$(shell pwd) modules

ifeq ($(wildcard /boot/firmware/config.txt),)
    BOOT_CONFIG := /boot/config.txt
else
    BOOT_CONFIG := /boot/firmware/config.txt
endif

# dtbo rule is no longer available
ifeq ($(firstword $(subst ., ,$(KERNELRELEASE))),6)
all: wm8960.dtbo

wm8960.dtbo: wm8960-overlay.dts
	dtc -I dts -O dtb -o $@ $<
endif

clean:
	make -C /usr/src/linux-headers-$(KERNELRELEASE) M=$(shell pwd) clean

install: snd-soc-wm8960.ko wm8960.dtbo
	cp snd-soc-wm8960.ko /lib/modules/$(KERNELRELEASE)/kernel/sound/soc/codecs/
	depmod -a $(KERNELRELEASE)
	cp wm8960.dtbo /boot/overlays/
	sed $(BOOT_CONFIG) -i -e "s/^#dtparam=i2c_arm=on/dtparam=i2c_arm=on/"
	grep -q -E "^dtparam=i2c_arm=on" $(BOOT_CONFIG) || printf "dtparam=i2c_arm=on\n" >> $(BOOT_CONFIG)
	sed $(BOOT_CONFIG) -i -e "s/^#dtoverlay=i2s-mmap/dtoverlay=i2s-mmap/"
	grep -q -E "^dtoverlay=i2s-mmap" $(BOOT_CONFIG) || printf "dtoverlay=i2s-mmap\n" >> $(BOOT_CONFIG)
	sed $(BOOT_CONFIG) -i -e "s/^#dtparam=i2s=on/dtparam=i2s=on/"
	grep -q -E "^dtparam=i2s=on" $(BOOT_CONFIG) || printf "dtparam=i2s=on\n" >> $(BOOT_CONFIG)
	sed $(BOOT_CONFIG) -i -e "s/^#dtoverlay=wm8960/dtoverlay=wm8960/"
	grep -q -E "^dtoverlay=wm8960" $(BOOT_CONFIG) || printf "dtoverlay=wm8960\n" >> $(BOOT_CONFIG)

test:
	echo "No test defined yet"

.PHONY: all clean install
