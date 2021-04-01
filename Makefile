HOSTARCH := $(shell uname -m | \
	sed -e s/i.86/i386/ \
	    -e s/arm.*/arm/)

HOSTOS := $(shell uname -s | tr '[:upper:]' '[:lower:]' | \
	    sed -e 's/\(cygwin\).*/cygwin/')

export	HOSTARCH HOSTOS

ifneq ($(BUILD_DIR),)
saved-output := $(BUILD_DIR)

# Attempt to create a output directory.
$(shell [ -d ${BUILD_DIR} ] || mkdir -p ${BUILD_DIR})

# Verify if it was successful.
BUILD_DIR := $(shell cd $(BUILD_DIR) && /bin/pwd)
$(if $(BUILD_DIR),,$(error output directory "$(saved-output)" does not exist))
endif # ifneq ($(BUILD_DIR),)

OBJTREE		:= $(if $(BUILD_DIR),$(BUILD_DIR),$(CURDIR))
SRCTREE		:= $(CURDIR)
TOPDIR		:= $(SRCTREE)
LNDIR		:= $(OBJTREE)
export	TOPDIR SRCTREE OBJTREE

ifneq ($(OBJTREE),$(SRCTREE))
REMOTE_BUILD	:= 1
export REMOTE_BUILD
endif

ifneq ($(OBJTREE),$(SRCTREE))
obj := $(OBJTREE)/
src := $(SRCTREE)/
else
obj :=
src :=
endif
export obj src

ifeq ($(OBJTREE)/include/config.mk,$(wildcard $(OBJTREE)/include/config.mk))

# load ARCH, BOARD, and CPU configuration
include $(OBJTREE)/include/config.mk
export	ARCH CPU BOARD

# CROSS_COMPILE = /usr/local/arm/4.3.2/bin/arm-linux-
CROSS_COMPILE = arm-none-eabi-
export	CROSS_COMPILE

# load other configuration
include $(TOPDIR)/config.mk

# SMDK6410 objects....order is important (i.e. start must be first)

OBJS := $(addprefix $(obj),$(OBJS))

LIBS  = lib_generic/libgeneric.a
LIBS += board/$(BOARDDIR)/lib$(BOARD).a
LIBS += cpu/$(CPU)/lib$(CPU).a
LIBS += lib_$(ARCH)/lib$(ARCH).a
LIBS += ucos3/libucos3.a
LIBS += application/libapplication.a
# add to support onenand. by scsuh
LIBS += $(BOARDLIBS)

LIBS := $(addprefix $(obj),$(LIBS))
.PHONY : $(LIBS)

# Add GCC lib
PLATFORM_LIBS += -L $(shell dirname `$(CC) $(CFLAGS) -print-libgcc-file-name`) -lgcc

# The "tools" are needed early, so put this first
# Don't include stuff already done in $(LIBS)
SUBDIRS	= 
.PHONY : $(SUBDIRS)

__OBJS := $(subst $(obj),,$(OBJS))
__LIBS := $(subst $(obj),,$(LIBS))

# =======================================================================
# all 目标文件
# =======================================================================
ALL = $(obj)SMDK6410.srec $(obj)SMDK6410.hex $(obj)SMDK6410.bin $(obj)System.map $(obj)SMDK6410.dis

all:		$(ALL)

$(obj)SMDK6410.hex:	$(obj)SMDK6410.axf
		$(OBJCOPY) ${OBJCFLAGS} -O ihex $< $@

$(obj)SMDK6410.srec:	$(obj)SMDK6410.axf
		$(OBJCOPY) ${OBJCFLAGS} -O srec $< $@

$(obj)SMDK6410.bin:	$(obj)SMDK6410.axf
		$(OBJCOPY) ${OBJCFLAGS} -O binary $< $@

$(obj)SMDK6410.dis:	$(obj)SMDK6410.axf
		$(OBJDUMP) -S -D $< > $@

# =======================================================================
# SMDK6410编译
# =======================================================================
$(obj)SMDK6410.axf:		depend $(SUBDIRS) $(OBJS) $(LIBS) $(LDSCRIPT)
		UNDEF_SYM=`$(OBJDUMP) -x $(LIBS) |sed  -n -e 's/.*\(__u_boot_cmd_.*\)/-u\1/p'|sort|uniq`;\
		cd $(LNDIR) && $(LD) $(LDFLAGS) $$UNDEF_SYM $(__OBJS) \
			--start-group $(__LIBS) --end-group $(PLATFORM_LIBS) \
			-Map SMDK6410.map -o SMDK6410.axf

# =======================================================================
# SMDK6410编译obj文件
# =======================================================================
$(OBJS):
		$(MAKE) -C cpu/$(CPU) $(if $(REMOTE_BUILD),$@,$(notdir $@))

# =======================================================================
# SMDK6410编译lib文件
# $(dir $(subst $(obj),,$@)): 取文件名的目录部分
# $(subst $(obj),,$@): 将$@中的$(obj)字符串替换为空
# =======================================================================
$(LIBS):
		$(MAKE) -C $(dir $(subst $(obj),,$@))

# =======================================================================
# SMDK6410编译子目录
# =======================================================================
$(SUBDIRS):
		$(MAKE) -C $@ all

# =======================================================================
# SMDK6410创建.depend文件(目标依赖)
# =======================================================================
depend dep:
		for dir in $(SUBDIRS) ; do $(MAKE) -C $$dir _depend ; done

# =======================================================================
# SMDK6410生成System.map文件
# =======================================================================
$(obj)System.map:	$(obj)SMDK6410.axf
		@$(NM) $< | \
		grep -v '\(compiled\)\|\(\.o$$\)\|\( [aUw] \)\|\(\.\.ng$$\)\|\(LASH[RL]DI\)' | \
		sort > $(obj)System.map

endif

clean:
	find $(OBJTREE) -type f \
		\( -name 'core' -o -name '*.bak' -o -name '*~' \
		-o -name '*~' -o -name '.depend*' \
		-o -name '*.o'  -o -name '*.a'  \) -print \
		| xargs rm -f
	rm -f SMDK6410.axf SMDK6410.dis SMDK6410.hex SMDK6410.map SMDK6410.srec

clobber:	clean
	find $(OBJTREE) -type f \( -name .depend \
		-o -name '*.srec' -o -name '*.bin' \) \
		-print0 \
		| xargs -0 rm -f
	rm -f $(OBJS) $(obj)*.bak
	rm -fr $(obj)*.*~
	rm -f $(obj)SMDK6410.axf $(obj)SMDK6410.map $(obj)SMDK6410.hex $(ALL)

ifeq ($(OBJTREE),$(SRCTREE))
mrproper \
distclean:	clobber
else
mrproper \
distclean:	clobber
	rm -rf $(OBJTREE)/*
endif

backup:
	F=`basename $(TOPDIR)` ; cd .. ; \
	gtar --force-local -zcvf `date "+$$F-%Y-%m-%d-%T.tar.gz"` $$F

