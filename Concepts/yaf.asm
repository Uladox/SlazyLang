%define pax rax
%define pbx rbx
%define pcx rcx
%define pdx rdx
%define psi rsi
%define psp rsp
%define pbp rbp

%define ptrsize 8
%define ptrword qword
%define ptrsize3 ptrsize * 3
%define ptrsize5 ptrsize * 5

%define sizeof(x) x %+ _size
	
%macro SYSEXIT 0
	mov	pax, 1		;Sys call for exit
	int	0x80		;Call kernel
%endmacro

%define listType 0
%define symbolType 1
%define functionType 2
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
	atom7 resb sizeof(value)
	atom8 resb sizeof(value)
	atom9 resb sizeof(value)
	atom10 resb sizeof(value)
	atom11 resb sizeof(value)
	atom12 resb sizeof(value)

	cell1 resb sizeof(cell)
	cell2 resb sizeof(cell)
	cell3 resb sizeof(cell)
	cell4 resb sizeof(cell)
	cell5 resb sizeof(cell)
	cell6 resb sizeof(cell)
	cell7 resb sizeof(cell)
	cell8 resb sizeof(cell)
	
section .data
	msg db "hello world!lolololololol", 10, 0
	len equ $ - msg

	argerrormsg db "Too many args in function", 10
	argerrorlen equ $ - argerrormsg

	msg2 db "msg", 10, 0
section .text
	global _start
_start:
	mov ptrword [atom1 + value.here], cell1
	mov byte [atom1 + value.type], listType

	mov ptrword [cell1 + cell.here], atom2
	mov ptrword [atom2 + value.here], msg
	mov byte [atom2 + value.type], symbolType

	mov ptrword [cell1 + cell.next], cell2

	mov ptrword [cell2 + cell.next], 0

	mov ptrword [cell2 + cell.here], atom3
	mov byte [atom3 + value.type], listType
	mov ptrword [atom3 + value.here], cell3

	mov ptrword [cell3 + cell.here], atom4
	mov byte [atom4 + value.type], listType
	mov ptrword [atom4 + value.here], cell4

	mov ptrword [cell4 + cell.here], atom5
	mov byte [atom5 + value.type], symbolType
	mov ptrword [atom5 + value.here], msg2

	mov ptrword [cell4 + cell.next], cell5
	mov ptrword [cell5 + cell.here], atom6
	mov ptrword [cell5 + cell.next], 0
	mov byte [atom6 + value.type], functionType
	mov ptrword [atom6 + value.here], print

	mov ptrword [cell3 + cell.next], cell6
	mov ptrword [cell6 + cell.here], atom7
	mov byte [atom7 + value.type], listType
	mov ptrword [atom7 + value.here], cell7

	mov ptrword [cell7 + cell.next], 0
	mov ptrword [cell7 + cell.here], atom8
	mov ptrword [atom8 + value.here], msg2
	mov byte [atom8 + value.type], symbolType

	mov ptrword [cell6 + cell.next], cell8

	mov ptrword [cell8 + cell.here], atom9
	mov byte [atom9 + value.type], functionType
	mov ptrword [atom9 + value.here], lambda
	
	push atom1
	call eval
%if 0
	mov pcx, [cell1 + cell.here]
	mov pcx, [pcx + value.here]
	mov pdx, len 		;puts size in pdx
	mov pbx, 1
	mov pax, 4
	int 0x80		;call kernel
%endif
	
	SYSEXIT

	


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
	;; call eval
	mov pax, [pbp + ptrsize + ptrsize + ptrsize]
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
evalListFunct:
	cmp byte [pax + value.type], functionType
	je Evalprim

	push pax
	call eval
	jmp Endeval
Evalprim:
	mov pax, [pax + value.here]
	call pax
Endeval:
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


replace:			;cell, expr, sym, pbp
	push pbp             ; create stack frame
	mov ptrword pbp, psp
	%define replaceCell pbp + ptrsize3 + ptrsize
	%define replaceExpr pbp + ptrsize3
	%define replaceSymbol pbp + ptrsize + ptrsize
	push ptrword [replaceCell]
replaceLoop:
	mov pax, [pbp - ptrsize]
	mov pax, [pax + cell.here]
	cmp byte [pax + value.type], symbolType
	je replaceLoopSymbol
	
	cmp byte [pax + value.type], listType
	je replaceLoopList

replaceLoopProc:
	mov pax, [pbp - ptrsize]
	cmp ptrword [pax + cell.next], 0
	je endReplace
	mov pdx, [pax + cell.next]
	mov ptrword [pbp - ptrsize], pdx
	jmp replaceLoop
replaceLoopSymbol:
	
	mov pbx, [replaceSymbol]
	mov pbx, [pbx + value.here]
	cmp pbx, [pax + value.here]
	je replaceSymbolSuccess
	
	jmp replaceLoopProc
replaceSymbolSuccess:
	mov pax, [pbp - ptrsize]
	mov pdx, [replaceExpr]
	mov ptrword [pax + cell.here], pdx
	jmp replaceLoopProc
replaceLoopList:
	push ptrword [pbp - ptrsize]
	push ptrword [replaceExpr]
	push ptrword [replaceSymbol]
	call replace
	pop pbx
	pop pdx
	pop pdx
endReplace:
	mov psp, pbp
	pop pbp             ; restore the base pointer
	ret

lambda:
	%define firstOuterArg pbp + ptrsize5 + ptrsize3 + ptrsize
	%define argList pbp + ptrsize3
	%define replacementList pbp + ptrsize3 + ptrsize

	push pbp             ; create stack frame
	mov ptrword pbp, psp
	
	mov pax, ptrword [replacementList]
	push ptrword [pax + value.here]

	push ptrword [firstOuterArg]
	
	mov pax, [argList]
	mov pax, [pax + value.here]
	mov pax, [pax + cell.here]
	push pax
	
	call replace
	
	push ptrword [replacementList]
	call eval
	
	mov psp, pbp
	pop pbp             ; restore the base pointer
	
	ret
