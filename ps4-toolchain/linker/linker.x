OUTPUT_FORMAT("elf64-x86-64-freebsd", "elf64-x86-64-freebsd",
              "elf64-x86-64-freebsd")
OUTPUT_ARCH(i386:x86-64)
ENTRY(_start)

PHDRS
{
	text-segment   PT_LOAD FLAGS(5) /* Read | Execute */;
	relro PT_LOAD FLAGS(4) /* Read */;
	data   PT_LOAD FLAGS(6) /* Read | Write */;
	sce_process_param PT_NULL FLAGS(4);
	dyn    PT_DYNAMIC FLAGS(6);
	interp  PT_INTERP;
	tls PT_TLS FLAGS (4);
	eh_frame_hdr  PT_GNU_EH_FRAME FLAGS (4);
	sce_dynlibdata   PT_LOAD FLAGS(4);
}

SECTIONS
{
  PROVIDE (__executable_start = SEGMENT_START("text-segment", 0x400000)); . = SEGMENT_START("text-segment", 0x400000);
  .interp         : { *(.interp) } : text-segment : interp
  .init           : ALIGN(0x10)
  {
    KEEP (*(SORT_NONE(.init)))
  }  : text-segment
  .text           : ALIGN(0x10)
  {
    *(.text.unlikely .text.*_unlikely .text.unlikely.*)
    *(.text.exit .text.exit.*)
    *(.text.startup .text.startup.*)
    *(.text.hot .text.hot.*)
    *(SORT(.text.sorted.*))
    *(.text .stub .text.* .gnu.linkonce.t.*)
    /* .gnu.warning sections are handled specially by elf.em.  */
    *(.gnu.warning)
  }
  .fini           : ALIGN(0x10)
  {
    KEEP (*(SORT_NONE(.fini)))
  }
  .plt            : { *(.plt) *(.iplt) }
  .rodata         : { *(.rodata .rodata.* .gnu.linkonce.r.*) }
  .eh_frame       : { *(.eh_frame.*) }
  .eh_frame_hdr   : { *(.eh_frame_hdr) *(.eh_frame_entry .eh_frame_entry.*) } : text-segment : eh_frame_hdr
 
	/* =========== SCE RELRO segment =========== */
  . = ALIGN(0x4000);
  .data.rel.ro : { *(.data.rel.ro.local* .gnu.linkonce.d.rel.ro.local.*) *(.data.rel.ro .data.rel.ro.* .gnu.linkonce.d.rel.ro.*) } : relro
  .got            : { *(.got) *(.igot) }
  .got.plt        : { *(.got.plt) *(.igot.plt) }

	/* =========== DATA segment =========== */

  . = ALIGN(0x4000);

  .sce_process_param  : { 
    KEEP(*(.data.sce_process_param))
   } : data 

  .sce_module_param  : { 
    KEEP(*(.data.sce_module_param))
  } : data 

  . = ALIGN(0x20);

    /* Thread Local Storage sections  */
  .tdata          :
   {
     PROVIDE_HIDDEN (__tdata_start = .);
     *(.tdata .tdata.* .gnu.linkonce.td.*)
   } : data : tls
  .tbss           : { *(.tbss .tbss.* .gnu.linkonce.tb.*) *(.tcommon) }
  .data           :
  {
    *(.data .data.* .gnu.linkonce.d.*)
    SORT(CONSTRUCTORS)
  } : data
  
  .jcr            : { KEEP (*(.jcr)) }

  .preinit_array    :
  {
    PROVIDE_HIDDEN (__preinit_array_start = .);
    KEEP (*(.preinit_array))
    PROVIDE_HIDDEN (__preinit_array_end = .);
  }
  .init_array    :
  {
    PROVIDE_HIDDEN (__init_array_start = .);
    KEEP (*(SORT_BY_INIT_PRIORITY(.init_array.*) SORT_BY_INIT_PRIORITY(.ctors.*)))
    KEEP (*(.init_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .ctors))
    PROVIDE_HIDDEN (__init_array_end = .);
  }
  .fini_array    :
  {
    PROVIDE_HIDDEN (__fini_array_start = .);
    KEEP (*(SORT_BY_INIT_PRIORITY(.fini_array.*) SORT_BY_INIT_PRIORITY(.dtors.*)))
    KEEP (*(.fini_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .dtors))
    PROVIDE_HIDDEN (__fini_array_end = .);
  }
  .bss            :
  {
   *(.dynbss)
   *(.bss .bss.* .gnu.linkonce.b.*)
   *(COMMON)
   /* Align here to ensure that the .bss section occupies space up to
      _end.  Align after .bss to ensure correct alignment even if the
      .bss section disappears because there are no input sections.
      FIXME: Why do we need it? When there is no .bss section, we do not
      pad the .data section.  */
   . = ALIGN(. != 0 ? 64 / 8 : 1);
  }
  . = ALIGN (0x10);
	/* =========== PT_SCE_DYNAMIC segment =========== */

  .dynstr         : { *(.dynstr) } : sce_dynlibdata 
  . = ALIGN (0x8);
  .dynsym         : { *(.dynsym) }
  .rela.dyn       :
  {
    *(.rela.init)
    *(.rela.text .rela.text.* .rela.gnu.linkonce.t.*)
    *(.rela.fini)
    *(.rela.rodata .rela.rodata.* .rela.gnu.linkonce.r.*)
    *(.rela.data .rela.data.* .rela.gnu.linkonce.d.*)
    *(.rela.tdata .rela.tdata.* .rela.gnu.linkonce.td.*)
    *(.rela.tbss .rela.tbss.* .rela.gnu.linkonce.tb.*)
    *(.rela.ctors)
    *(.rela.dtors)
    *(.rela.got)
    *(.rela.bss .rela.bss.* .rela.gnu.linkonce.b.*)
    *(.rela.ldata .rela.ldata.* .rela.gnu.linkonce.l.*)
    *(.rela.lbss .rela.lbss.* .rela.gnu.linkonce.lb.*)
    *(.rela.lrodata .rela.lrodata.* .rela.gnu.linkonce.lr.*)
    *(.rela.ifunc)
  }
  . = ALIGN (0x8);

  .rela.plt       :
  {
    *(.rela.plt)
    PROVIDE_HIDDEN (__rela_iplt_start = .);
    *(.rela.iplt)
    PROVIDE_HIDDEN (__rela_iplt_end = .);
  }
  . = ALIGN (0x8);
  .hash           : { *(.hash) }
  . = ALIGN (0x8);
  .gnu.hash       : { *(.gnu.hash) }
  . = ALIGN (0x8);
  .dynamic        : { *(.dynamic) } : dyn : sce_dynlibdata

}
