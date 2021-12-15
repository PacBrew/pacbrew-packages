###################################
IncludePath += -I$(ORBISDEV)/usr/include/orbis
PlatformFlags += --target=x86_64-scei-ps4 -D__PS4__ -D__ORBIS__
AssemblerFlags += $(PlatformFlags)
CompilerFlags += $(PlatformFlags)
CompilerFlagsCpp += $(PlatformFlags)
LinkerFlags += -Wl,--gc-sections,--gc-keep-exported -L$(PS4SDK)/lib
CrtFile ?= $(ORBISDEV)/usr/lib/crt0.o  
###################################
all:: $(AllTarget)
clean::
	$(CleanTarget)

