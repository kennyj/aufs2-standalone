
KDIR = /lib/modules/$(shell uname -r)/build
Conf1=${KDIR}/include/config/auto.conf
Conf2=${KDIR}/.config
ifeq "t" "$(shell test -e ${Conf1} && echo t)"
include ${Conf1}
else ifeq "t" "$(shell test -e ${Conf2} && echo t)"
include ${Conf2}
else
$(warning could not find kernel config file. internal auto-config may fail)
endif

CONFIG_AUFS_FS = m
AUFS_DEF_CONFIG = -DCONFIG_AUFS_MODULE -UCONFIG_AUFS
include config.mk
export CONFIG_AUFS_FS

EXTRA_CFLAGS := -I${CURDIR}/include
EXTRA_CFLAGS += ${AUFS_DEF_CONFIG}

all: aufs.ko usr/include/linux/aufs_type.h

clean:
	${MAKE} -C ${KDIR} M=${CURDIR}/fs/aufs EXTRA_CFLAGS="${EXTRA_CFLAGS}" $@
	find . -type f -name '*~' | xargs -r ${RM}
	${RM} -r aufs.ko usr

aufs.ko: fs/aufs/aufs.ko
	ln -f $< $@
fs/aufs/aufs.ko:
	@echo ${EXTRA_CFLAGS}
	${MAKE} -C ${KDIR} M=${CURDIR}/fs/aufs EXTRA_CFLAGS="${EXTRA_CFLAGS}" modules

usr/include/linux/aufs_type.h: d = $(shell echo ${CURDIR} | cut -c2-)
usr/include/linux/aufs_type.h:
	echo '$$(install-file):srctree= $$(install-file):objtree=' |\
	tr ' ' '\n' |\
	${MAKE} -rR -C ${KDIR} \
		-f scripts/Makefile.headersinst \
		-f - \
		-f Makefile \
		obj=${d}/include/linux dst=${d}/usr/include/linux
