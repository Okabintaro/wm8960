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

clean:
	make -C /usr/src/linux-headers-$(KERNELRELEASE) M=$(shell pwd) clean

install: snd-soc-wm8960.ko wm8960.dtbo
	cp snd-soc-wm8960.ko /lib/modules/$(KERNELRELEASE)/kernel/sound/soc/codecs/
	depmod -a $(KERNELRELEASE)
	cp wm8960.dtbo /boot/overlays/
	sed /boot/config.txt -i -e "s/^#dtparam=i2c_arm=on/dtparam=i2c_arm=on/"
	grep -q -E "^dtparam=i2c_arm=on" /boot/config.txt || printf "dtparam=i2c_arm=on\n" >> /boot/config.txt
	sed /boot/config.txt -i -e "s/^#dtoverlay=i2s-mmap/dtoverlay=i2s-mmap/"
	grep -q -E "^dtoverlay=i2s-mmap" /boot/config.txt || printf "dtoverlay=i2s-mmap\n" >> /boot/config.txt
	sed /boot/config.txt -i -e "s/^#dtparam=i2s=on/dtparam=i2s=on/"
	grep -q -E "^dtparam=i2s=on" /boot/config.txt || printf "dtparam=i2s=on\n" >> /boot/config.txt
	sed /boot/config.txt -i -e "s/^#dtoverlay=wm8960/dtoverlay=wm8960/"
	grep -q -E "^dtoverlay=wm8960" /boot/config.txt || printf "dtoverlay=wm8960\n" >> /boot/config.txt

test:
	echo "No test defined yet"

.PHONY: all clean install
