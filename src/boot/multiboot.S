MBALIGN		equ 1<<0
MEMINFO		equ 1<<1
MBFLAGS		equ MBALIGN | MEMINFO
MBMAGIC		equ 0x1BADB002
MBCHECKSUM	equ -(MBMAGIC + MBFLAGS)

section .multiboot
align 4
	dd MBMAGIC
	dd MBFLAGS
	dd MBCHECKSUM

section .bootstrap_stack nobits
align 4
	stack_bottom: times 16384 db 0
	stack_top:

section .text
global _multiboot_start
_multiboot_start:
	mov esp, stack_top
	
; rust needs this:
	mov [gs:0x30], dword 0
	
	; clear screen
	mov edi, 0xb8000
	mov ecx, 80*25*2
	mov al, 1
	rep stosb
	
	extern kmain
	call kmain
	cli
	hlt
.infinite_loop: jmp .infinite_loop
