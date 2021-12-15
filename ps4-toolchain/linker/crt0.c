#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

extern int main(int argc, char *argv[]);
extern void _init_env();
extern int __cxa_finalize(void *);

extern void (*__preinit_array_start[])(void) __attribute__((weak));
extern void (*__preinit_array_end[])(void) __attribute__((weak));
extern void (*__init_array_start[])(void) __attribute__((weak));
extern void (*__init_array_end[])(void) __attribute__((weak));
extern void (*__fini_array_start[])(void) __attribute__((weak));
extern void (*__fini_array_end[])(void) __attribute__((weak));

static void __libc_init_array() {
  int64_t count, i;

  count = __preinit_array_end - __preinit_array_start;
  for (i = 0; i < count; i++)
    __preinit_array_start[i]();

  count = __init_array_end - __init_array_start;
  for (i = 0; i < count; i++)
    __init_array_start[i]();
}

static void __libc_fini_array() {
  int64_t count, i;

  count = __fini_array_end - __fini_array_start;
  for (i = count - 1; i >= 0; i--) {
    __fini_array_start[i]();
  }
}

__attribute__((weak)) void catchReturnFromMain() { kill(getpid(), SIGTERM); }

void _start(void **args, void (*func)()) {
  int __status;
  _init_env();
  atexit(func);
  atexit(__libc_fini_array);
  __libc_init_array();
  __status = main((int)((int*)args)[0], (char **)(&args[1]));
  __cxa_finalize(NULL);
  fflush(NULL);
  catchReturnFromMain();
}

__asm__(".align 0x8 \n"
        ".section \".data.rel.ro._sceLibcParam\" \n"
        ".weak _sceLibcParam \n"
        "_sceLibcParam:  \n"
        "	.quad   0x90 		# Size  \n"
        "	.quad 	0x10000000C	# Unknown? \n"
        "	.quad	sceLibcHeapSize \n"
        "	.quad	0 \n"
        "	.quad	sceLibcHeapExtendedAlloc \n"
        "	.quad	0 \n"
        "	.quad	sceLibcMallocReplace \n"
        "	.quad 	sceLibcNewReplace \n"
        "	.quad	0 \n"
        "	.quad	0 			# Need_sceLibc \n"
        "	.quad	0 \n"
        "	.quad	0 \n"
        "	.quad	sceLibcMallocReplaceForTls \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        "	.quad	0 \n"
        "	.quad 	0 \n"
        " \n"
        "# sceKernelMemParam \n"
        ".align 0x8 \n"
        ".section \".data.rel.ro._sceKernelMemParam\" \n"
        ".weak _sceKernelMemParam \n"
        "_sceKernelMemParam:  \n"
        "	.quad   0x30		# Size \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        " \n"
        "# sceKernelFsParam \n"
        ".align 0x8 \n"
        ".section \".data.rel.ro._sceKernelFsParam\" \n"
        ".weak _sceKernelFsParam \n"
        "_sceKernelFsParam: \n"
        "	.quad 	0x10 		# Size \n"
        "	.quad 	0 \n"
        " \n"
        "# sceLibcMallocReplace \n"
        ".align 0x8 \n"
        ".section \".data.rel.ro._sceLibcMallocReplace\" \n"
        ".weak sceLibcMallocReplace \n"
        "sceLibcMallocReplace: \n"
        "	.quad 	0x70 		# Size \n"
        "	.quad 	1 \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        " \n"
        "# sceLibcNewReplace \n"
        ".align 0x8 \n"
        ".section \".data.rel.ro._sceLibcNewReplace\" \n"
        ".weak sceLibcNewReplace \n"
        "sceLibcNewReplace: \n"
        "	.quad 	0x70 		# Size \n"
        "	.quad 	2 \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        " \n"
        "# sceLibcMallocReplaceForTls \n"
        ".align 0x8 \n"
        ".section \".data.rel.ro._sceLibcMallocReplaceForTls\" \n"
        ".weak sceLibcMallocReplaceForTls \n"
        "sceLibcMallocReplaceForTls: \n"
        "	.quad 	0x38		# Size \n"
        "	.quad 	1 \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        " \n"
        "# sce_process_param \n"
        ".align 0x8 \n"
        ".section \".data.sce_process_param\" \n"
        ".weak _sceProcessParam \n"
        "_sceProcessParam: \n"
        "	.quad 	0x50		# Size \n"
        "	.long   0x4942524F	# Magic \"ORBI\" \n"
        "	.long 	0x3 		# Entry count \n"
        "	.quad 	0x4508101 	# SDK version \n"
        "	.quad 	0 \n"
        "	.quad 	0 \n"
        "	.quad	sceUserMainThreadPriority \n"
        "	.quad 	sceUserMainThreadStackSize \n"
        "	.quad 	_sceLibcParam \n"
        "	.quad 	_sceKernelMemParam \n"
        "	.quad 	_sceKernelFsParam \n"
        " \n"
        "# data globals \n"
        ".align 0x8 \n"
        ".section \".data\" \n"
        ".weak sceUserMainThreadPriority \n"
        "sceUserMainThreadPriority: \n"
        "	.quad	0 \n"
        ".weak sceLibcHeapSize \n"
        "sceLibcHeapSize: \n"
        "	.quad	0xffffffffffffffff \n"
        ".weak sceLibcHeapExtendedAlloc \n"
        "sceLibcHeapExtendedAlloc: \n"
        "	.quad	1 \n"
        ".weak sceUserMainThreadStackSize \n"
        "sceUserMainThreadStackSize: \n"
        "	.quad	0xffffffffffffffff \n"
        ".weak __dso_handle \n"
        "__dso_handle: \n"
        "	.quad 	0 \n"
        ".weak _sceLibc \n"
        "_sceLibc: \n"
        "	.quad	0 \n");
