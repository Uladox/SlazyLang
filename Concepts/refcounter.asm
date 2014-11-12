%define pax rax
%define pbx rbx
%define pcx rcx
%define pdx rdx
%define psi rsi
%define psp rsp
%define pbp rbp

%define ptrsize 8
%define ptrword qword

%define sizeof(x) x %+ _size
	
%macro SYSEXIT 0
	mov	pax, 1		;Sys call for exit
	int	0x80		;Call kernel
%endmacro

%define atomType 0
%define listType 1

struc mem
	.length resb 4
	.refs resb 1
endstruc


struc cell
	.next resb ptrsize
	.here resb ptrsize
	.is_alloc resb 1
endstruc

struc value
	.here resb ptrsize
	.type resb 1
	.is_alloc resb 1
endstruc


section .bss
	struff resb sizeof(value) + sizeof(mem)
	
	stuff2 resb sizeof(cell) + sizeof(mem)
	stuff3 resb sizeof(cell) + sizeof(mem)
	stuff4 resb sizeof(value)
section .data
	msg db "hello world!", 10
	len equ $ - msg
section .text
	global _start
_start:
	
%if 0
	mov pax, struff
	add pax, sizeof(mem)
	add pax, value.is_alloc
	mov byte [pax], 1

	mov pax, struff
	add pax, mem.refs
	mov byte [pax], 2
	
	mov pax, struff
	add pax, sizeof(mem)
	push struff + sizeof(mem)


	call voidval

	cmp byte [struff + mem.refs], 1
	call woot
%endif
	;; 
	mov byte [stuff4 + value.is_alloc], 0
	mov byte [stuff2 + sizeof(mem) + cell.is_alloc], 1
	mov byte [stuff2 + mem.refs], 4
	
	mov byte [stuff3 + sizeof(mem) + cell.is_alloc], 1
	mov byte [stuff3 + mem.refs], 1

	mov ptrword [stuff3 + sizeof(mem) + cell.here], stuff4
	mov ptrword [stuff3 + sizeof(mem) + cell.next], stuff2 + sizeof(mem)

	mov pax, stuff3
	add pax, sizeof(mem)
	
	push pax

	call voidcell

	cmp byte [stuff2 + mem.refs], 3
	je l5
	call woot

l5:	
	SYSEXIT


condValVoidCall:
	push pax
	call voidval
	jmp endvoid

condCellVoidCall:
	push ptrword [pax + value.here]
	call voidcell
	jmp endvoid

valtreevoid:
	add pax, sizeof(mem)	;go to the value pointed at
	mov pax, [pax + value.here]
	;;we assume there are no more references so we need to decrease the value
	;;pointed to by one
	cmp byte [pax + value.type], atomType
	je condValVoidCall

	cmp byte [pax + value.type], listType
	je condCellVoidCall

	jmp endvoid
voidval:	
	push pbp             ; create stack frame
        mov ptrword pbp, psp
	
	mov ptrword pax, [pbp + ptrsize + ptrsize] ;puts first arg into pax
	cmp byte [pax + value.is_alloc], 0	 ;checks if it is allocated, if not jump
	je endvoid			 ;ends function

	sub pax, sizeof(mem)	;goes to the value's info if it is allocated
	dec byte [pax + mem.refs]	;being voided, it loses one reference

;;; To do, tree based reference loss
	cmp byte [pax + mem.refs], 0
	je valtreevoid


	jmp endvoid

celltreevoid:
	add pax, sizeof(mem)	;go to the value pointed at
	;;we assume there are no more references so we need to decrease the value
	;;pointed to by one, along with the next in list
	cmp byte [pax + cell.next], 0 ;Last element in list, freeing zero is a bad idea
	je lastInList
	mov pax, [pax + cell.next]
	push pax
	call voidcell	
	mov ptrword pax, [pbp + ptrsize + ptrsize] ;puts first arg into pax
	add psp, ptrsize
	;;gotta reset after a function call
lastInList:
	cmp byte [pax + value.type], atomType
	je condValVoidCall

	cmp byte [pax + value.type], listType
	je condCellVoidCall

	jmp endvoid
voidcell:
	push pbp             ; create stack frame
        mov ptrword pbp, psp
	
	mov ptrword pax, [pbp + ptrsize + ptrsize] ;puts first arg into pax
	cmp byte [pax + cell.is_alloc], 0	 ;checks if it is allocated, if not jump
	je endvoid			 ;ends function

	sub pax, sizeof(mem)	;goes to the value's info if it is allocated
	dec byte [pax + mem.refs]	;being voided, it loses one reference

;;; To do, tree based reference loss
	cmp byte [pax + mem.refs], 0
	je celltreevoid


	jmp endvoid
	
endvoid:
	mov psp, pbp
	pop pbp             ; restore the base pointer
	ret

woot:
	mov	pdx,len     ;message length
	mov	pcx,msg     ;message to write
	mov	pbx,1       ;file descriptor (stdout)
	mov	pax,4       ;system call number (sys_write)
	int	0x80        ;call kernel
	ret
