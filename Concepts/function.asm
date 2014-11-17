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
	atom1 resb sizeof(value)
	atom2 resb sizeof(value)
	atom3 resb sizeof(value)
	atom4 resb sizeof(value)
	atom5 resb sizeof(value)
	atom6 resb sizeof(value)

	cell1 resb sizeof(cell)
	cell2 resb sizeof(cell)
	cell3 resb sizeof(cell)
	cell4 resb sizeof(cell)
	
section .data
	msg db "hello world!", 10, 0
	len equ $ - msg

	argerrormsg db "Too many args in function", 10
	argerrorlen equ $ - argerrormsg
section .text
	global _start
_start:
	mov ptrword [atom1 + value.here], cell1
	mov ptrword [cell1 + cell.here], atom2
	mov ptrword [atom2 + value.here], cell2
	mov ptrword [cell2 + cell.here], atom3
	mov ptrword [atom3 + value.here], msg
	mov ptrword [cell2 + cell.next], cell3
	mov ptrword [cell3 + cell.here], atom4
	mov ptrword [atom4 + value.here], quote
	mov ptrword [cell3 + cell.next], 0

	mov ptrword [cell1 + cell.next], cell4
	mov ptrword [cell4 + cell.here], atom5
	mov ptrword [atom5 + value.here], print
	mov ptrword [cell4 + cell.next], 0

	push atom1

	call eval
	
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

print:
	push pbp             ; create stack frame
	mov ptrword pbp, psp

	cmp ptrword [pbp + ptrsize + ptrsize], 1
	je printNoError
	jmp argerror
printNoError:
	push ptrword [pbp + ptrsize + ptrsize + ptrsize]
	call eval
	mov pcx, pax
	mov pcx, [pax + value.here]


	call setlen

	mov pdx, pbx 		;puts size in pdx

	mov pbx, 1
	mov pax, 4
	int 0x80		;call kernel

			
	mov psp, pbp
	pop pbp             ; restore the base pointer
	ret
;;;
functeval:
	push pbp             ; create stack frame
        mov ptrword pbp, psp

	cmp byte [pbp + ptrsize + ptrsize], 1
	je functevalNoError
	jmp argerror
functevalNoError:
	push ptrword [pbp + ptrsize + ptrsize + ptrsize]
	call eval
	mov psp, pbp
	pop pbp             ; restore the base pointer
	ret
;;;
eval:
	push pbp             ; create stack frame


        mov ptrword pbp, psp

	mov pax, 0

	mov ptrword pbx, [pbp + ptrsize + ptrsize]
	
	mov pbx, [pbx + value.here]

evalLoopBegin:
	cmp ptrword [pbx + cell.next], 0
	je evalLoopEnd
	push ptrword [pbx + cell.here]
	mov ptrword pbx, [pbx + cell.next]
	inc pax
	jmp evalLoopBegin
evalLoopEnd:

	push pax
	mov pax, [pbx + cell.here]
	mov pax, [pax + value.here]

	call pax

	mov psp, pbp
	pop pbp             ; restore the base pointer

	ret
;;;
quote:	
	push pbp             ; create stack frame
        mov ptrword pbp, psp

	cmp byte [pbp + ptrsize + ptrsize], 1
	je quoteNoError
	jmp argerror
quoteNoError:
	mov pax, [pbp + ptrsize + ptrsize + ptrsize]
	mov psp, pbp
	pop pbp             ; restore the base pointer
	ret
;;;
argerror:
	mov	pdx,argerrorlen     ;message length
	mov	pcx,argerrormsg     ;message to write
	mov	pbx,1       ;file descriptor (stdout)
	mov	pax,4       ;system call number (sys_write)
	int	0x80        ;call kernel
	SYSEXIT
;;;
setlen:				;puts str from pax in pcx and size in in ebx
	
	mov pbx, 0
	mov pax, pcx		;preserves string so ptr is put into pcx
	call lenth		;start counting
	ret
lenth:				;its not misspelled, it is program shortspeak
	cmp byte [pax], 0	;checks if char is 0
	je lengthEnd		;if so jump to l1 (return)
	jmp lengthLoop		;else jump to l2 and inc counter (pbx)
lengthEnd:
	ret

lengthLoop:
	inc pbx
	add pax, 1		;go to next char
	jmp lenth		;repeat until 0
 
