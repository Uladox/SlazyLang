;;|
;;[]-[]-[] 
;; |     |
;; car   []
;; 
%define ptrsize 8
%define ptrword qword
%define pax rax
%define pbx rbx
%define pcx rcx
%define pdx rdx

%define atomType 0
%define listType 1
%define functionType 2

%macro movcell 2
	mov ptrword [%1 + cell.here], %2 ;puts a pointer in 1's here
%endmacro

%macro movatom 2
	mov ptrword [%1 + atom.here], %2 ;puts a pointer in 1's here
%endmacro

%macro movtype 2
	mov ptrword [%1 + atom.type], %2 ;puts a pointer in 1's type
%endmacro

%macro movnxt 2
	mov ptrword [%1 + cell.next], %2 ;puts a pointer in 1's next
%endmacro

%macro macval 1
	call [%1 + atom.here]	;calls a function held in 1's here
%endmacro

%macro setargs 1
	mov pax, %1		;pax is standard argument holder
%endmacro

%macro SYSEXIT 0
	mov	pax, 1		;Sys call for exit
	int	0x80		;Call kernel
%endmacro

%macro cellnext 1		;makes 1 hold its next value
	add %1, cell.next
	mov %1, [%1]
%endmacro

%macro cellhere 1
	add %1, cell.here	;makes 1 hold its here value
	mov %1, [%1]
%endmacro

%macro atomhere 1
	add %1, atom.here	;makes 1 hold its here value
	mov %1, [%1]
%endmacro

struc cell
	.next: resb ptrsize	;reserve ptrsize for next value in linked list
	.here: resb ptrsize	;reserve space for pointer value for cell
	;; important, make sure ptrsize is correct or risk overwriting data
endstruc

struc atom
	.type: resb ptrsize	;reserve for type pointer
	.here: resb ptrsize	;reserve for function pointer/cell pointer (for list)/ string
endstruc
%define sizeof(x) x %+ _size	;size of stuff cuz i'm lazy

section .bss
	;; stuff needed for counting pointers in eval
	heldplace resb (64 * ptrsize)
	heldptr resb ptrsize
	;; end required
	mycell resb sizeof(cell)
	myatom resb sizeof(atom)
	mycell2 resb sizeof(cell)
	myatom2 resb sizeof(atom)
	mycell3 resb sizeof(cell)
	myatom3 resb sizeof(atom)
	mycell4 resb sizeof(cell)
	myatom4 resb sizeof(atom)
	
	mycell5 resb sizeof(cell)
	myatom5 resb sizeof(atom)
	mycell6 resb sizeof(cell)
	myatom6 resb sizeof(atom)
	mycell7 resb sizeof(cell)
	myatom7 resb sizeof(atom)
	mycell8 resb sizeof(cell)
	myatom8 resb sizeof(atom)
	mycell9 resb sizeof(cell)
	myatom9 resb sizeof(atom)
	mycell10 resb sizeof(cell)
	myatom10 resb sizeof(atom)
	mycell11 resb sizeof(cell)
	myatom11 resb sizeof(atom)

section	.text
    global _start 

_start:
	mov ptrword [heldptr], heldplace

	movatom myatom, mycell
	movcell mycell, myatom2
	movatom myatom2, print

	movnxt mycell, mycell2

	movcell mycell2, myatom3
	movatom myatom3, mycell3
	movcell mycell3, myatom4
	movatom myatom4, car

	movnxt mycell3, mycell4
%if 1
	movcell mycell4, myatom5
	movatom myatom5, mycell5
	movcell mycell5, myatom6
	movatom myatom6, car

	movnxt mycell5, mycell6
%endif
	movcell mycell6, myatom7
	movatom myatom7, mycell7
	movcell mycell7, myatom8
	movatom myatom8, quote

	movnxt mycell7, mycell8
	
	movcell mycell8, myatom9
	movatom myatom9, mycell9
	movcell mycell9, myatom10
	
	movatom myatom10, mycell10
	movcell mycell10, myatom11
	movatom myatom11, msg
	
	setargs myatom
	call eval
	;; call eval
	SYSEXIT

eval:					;takes atom containing cell and evaluates it
	atomhere pax		;set args to first cell of list ([a] b c d) where pax goes from (a b c d) to [a]
	mov pbx, pax		;move value of pax into pbx
	cellhere pbx		;gets the atom in list that the function is in
	;; function must manually go from [a] to [b] in list, thus pax must remain as a cell.
	macval pbx 		;use macro to call function held by atom held in ebx
	;; Always sets pax to returned value
	ret
formlist:
	cmp 
	ret
quote:
	cellnext pax
	atomhere pax
	ret
car:
	cellnext pax		;get arg2 which is a list
	cellhere pax		;get the list (atom) from its cell
	setargs pax		;evaluate the list
	call eval
	;; should return an atom pointing to a cell, so return an atom pointing to thing in cell
	atomhere pax
	cellhere pax

	ret
print:

	cellnext pax		;move from function to first arg from function
	cellhere pax		;gets atom held by pax
	setargs pax
	call eval
	atomhere pax
	mov pcx, pax		;move value of first arg into pcx
	call setlen		;find length of pcx and put size in ebx
	mov pdx, pbx 		;puts size in pdx	
	mov pbx, 1
	mov pax, 4
	int 0x80		;call kernel

	ret

setlen:				;puts str from pax in pcx and size in in ebx
	mov pbx, 0
	mov pax, pcx		;preserves string so ptr is put into pcx
	call lenth		;start counting
	ret
lenth:				;its not misspelled, it is program shortspeak
	cmp byte [pax], 0	;checks if char is 0
	je l1			;if so jump to l1 (return)
	jmp l2			;else jump to l2 and inc counter (pbx)
l1:
	ret

l2:
	inc pbx
	add pax, 1		;go to next char
	jmp lenth		;repeat until 0

section	.data

msg	db	'hi!', 10, 0

 
 
