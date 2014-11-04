%define ptrsize 4
%define ptrword dword
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
	mov eax, %1		;eax is standard argument holder
%endmacro

%macro SYSEXIT 0
	mov	eax, 1		;Sys call for exit
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
	heldplace resb (16 * ptrsize)
	heldptr resb ptrsize
	;; end required
	mycell resb sizeof(cell)
	myatom resb sizeof(atom)
	t1 resb ptrsize
	mycell2 resb sizeof(cell)
	myatom2 resb sizeof(atom)
	myatom3 resb sizeof(atom)

section	.text
    global _start 

_start:
	mov ptrword [heldptr], heldplace
	
	movatom myatom, print
	movcell mycell, myatom
	movtype myatom, t1
	movnxt mycell, mycell2
	movcell mycell2, myatom2
	movatom myatom2, msg
	
	movatom myatom3, mycell

	setargs myatom3
	call eval
	SYSEXIT


eval:					;takes atom containing list and evaluates it
	;; NOTE ECX ESI EDI ARE SAFE FROM EVAL, DO NOT USE EAX EBX EDX AND EXPECT THEM NOT TO CHANGE AFTER CALLING EVAL
	add ptrword [heldptr], ptrsize 	;go to next avaliable pointer so as to hold arg making it uneffected by called functions
	mov ptrword [heldptr], eax	;arg is always preserved, it is the thing to replace its value with

	atomhere eax		;set args to first cell of list ([a] b c d) where eax goes from (a b c d) to [a]
	;; function must manually go from [a] to [b] in list, thus eax must remain as a cell. It points to affter eval to the function being called
	mov ebx, eax		;move value of eax into ebx
	cellhere ebx		;set ebx to its 'here' value meaning it only is a type and a value (no position, atom) ebx should be function
	macval ebx 		;use macro to call function held by atom held in ebx
	;; change expression so value is changed
	mov edx, [heldptr]
	movatom edx, eax	;sets value of edx to whatever function returned
	;; so for the expression ( (func a b c) d e f) goes to (returnedValue, d e f)
	sub ptrword [heldptr], ptrsize ;important so next eval gets its proper argpointer to replace with returned value
	ret
	
print:

	cellnext eax		;move from function to first arg from function
	cellhere eax		;gets atom held by eax
	atomhere eax	        ;put value (string) of first arg in eax
	mov ecx, eax		;move value of first arg into ecx
	call setlen		;find length of ecx and put size in ebx
	mov edx, ebx 		;puts size in edx	
	mov ebx, 1
	mov eax, 4
	int 0x80		;call kernel

	ret

setlen:				;puts str from eax in ecx and size in in ebx
	mov ebx, 0
	mov eax, ecx		;preserves string so ptr is put into ecx
	call lenth		;start counting
	ret
lenth:				;its not misspelled, it is program shortspeak
	cmp byte [eax], 0	;checks if char is 0
	je l1			;if so jump to l1 (return)
	jmp l2			;else jump to l2 and inc counter (ebx)
l1:
	ret

l2:
	inc ebx
	add eax, 1		;go to next char
	jmp lenth		;repeat until 0

section	.data

msg	db	'hi!', 10, 0

 
