###################################
PlatformFlags += --target=x86_64-scei-ps4 -D__PS4__ -D__ORBIS__
AssemblerFlags += $(PlatformFlags) -fPIE -dynamic
CompilerFlags +=  $(PlatformFlags) 
CompilerFlagsCpp += $(PlatformFlags) 
LinkerFlags += -T $(ORBISDEV)/usr/lib/linker.x --dynamic-linker=/libexec/ld-elf.so.1 --gc-sections -z max-page-size=0x4000  -pie --eh-frame-hdr
CrtFile ?= $(ORBISDEV)/usr/lib/crt0.o
###################################
###################################
#--gc-sections,
$(OutPath)/$(TargetFile):: $(ObjectFiles)
	$(dirp)
	$(link)

###################################

all:: $(AllTarget)
clean::
	$(CleanTarget)

