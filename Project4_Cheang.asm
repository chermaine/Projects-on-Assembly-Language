TITLE Composite Numbers     (Project4_Cheang.asm)

; Author: Chermaine Cheang
; Course / Project ID: CS271 Assignment 4                 Date: Nov 1,2016
; Description: This program will display user specified number of composite numbers.
;		The program will validate user entered a number between 1 and 400 (inclusive), 
;		and the result will be displayed 10 per line with 3 spaces between each composite number. 
;
; Implementation notes: This program is implemented using procedures. 
;		All variables are global. No parameter passing

INCLUDE Irvine32.inc

LOWER_LIMIT = 1		; constant variable
UPPER_LIMIT = 400	; constant variable

.data

intro_1		BYTE	"Composite Numbers by Chermaine Cheang", 0
intro_2		BYTE	"This program will display the number of composite numbers you wish to see.", 0
intro_3		BYTE	"However, I can only accept orders for up to 400 composites.", 0
prompt_1	BYTE	"Enter a number between 1 and 400 to see the composites: ", 0
outRange_1	BYTE	"Out of range! Number must be greater than 0.", 0
outRange_2	BYTE	"Out of range! Number must be less than or equal to 400.", 0
tryAgain	BYTE	"Please try again.", 0
result_1	BYTE	"Here are the composite numbers:", 0
result_2	BYTE	"Results certified by Chermaine.", 0
bye_1		BYTE	"Goodbye!", 0
space_1		BYTE	" ", 0
space_2		BYTE	"  ", 0
space_3		BYTE	"   ", 0
numCom		DWORD	?	; store user entered number of composite numbers
count		DWORD	0	; variable to keep track of number of composite numbers printed in a line
ec_1		BYTE	"***EC: Align the output columns", 0

.code
main PROC
	call introduction
	call getUserData
	call showComposites
	call goodbye

	exit	; exit to operating system
main ENDP


; description: Procedure to display program's introductions
; receives: none
; returns: none
; preconditions: global variables intro_1, intro_2, intro_3 must be defined
; registers changed: edx
introduction PROC
	; display program's name and programmer's name
	mov		edx, OFFSET intro_1
	call	WriteString
	call	Crlf
	call	Crlf

	; display extra-credit option
	mov		edx, OFFSET ec_1
	call	WriteString
	call	Crlf
	call	Crlf

	; display program's instructions
	mov		edx, OFFSET intro_2
	call	WriteString
	call	Crlf
	mov		edx, OFFSET intro_3
	call	WriteString
	call	Crlf
	call	Crlf

	ret
introduction ENDP


; description: Procedure to get number of composite numbers (numCom) from user.
;		Call validate to validate user's input
; receives: none
; return: numCom
; preconditions: none
; registers changed: eax, edx
getUserData PROC
	; display prompt for user input
	mov		edx, OFFSET prompt_1
	call	WriteString
	
	; get user's input
	call	ReadDec
	
	; save user's input to numCom
	mov		numCom, eax

	; call validate to validate user's numCom
	call	validate

	ret
getUserData ENDP

; Description: procedure to validate user's input. Display out of range messages if input is 
;		 not valid, and call getUserData to reprompt user for another input
; receives: none
; return: none
; precondition: global variable numCom is defined
; registers changed: edx, eax
validate	PROC
	; set up eax for comparison
	mov		eax, numCom

	; compare eax to upper limit. If greater than 400, jump to greaterThan400
	cmp		eax, UPPER_LIMIT
	ja		greaterThan400

	; compare eax to lower limit. If less than 1, jump to lessThan1
	cmp		eax, LOWER_LIMIT
	jb		lessThan1

	; jump to endValidate if input is valid
	jmp		endValidate

	lessThan1: ; display out of range message for input less than 1
		call	Crlf
		mov		edx, OFFSET outRange_1
		call	WriteString
		call	Crlf
		jmp		notValid

	greaterThan400: ; display out of range message for input greater than 400
		call	Crlf
		mov		edx, OFFSET outRange_2
		call	WriteString
		call	Crlf
		jmp		notValid

	notValid: 
		; display try again message
		mov		edx, OFFSET tryAgain
		call	WriteString
		call	Crlf
		call	Crlf

		; call getUserData procedure to prompt user for a new input
		call	getUserData

	endValidate:
		ret
validate	ENDP


; description: Procedure to display composite numbers. Call isComposite to 
;	to determine whether a number is a composite.
; receives: none
; returns: none
; preconditions: numCom is defined and valid
; registers changed: edx
showComposites PROC
	; display result intro
	call	Crlf
	mov		edx, OFFSET result_1
	call	WriteString
	call	Crlf

	; call isComposite to determine composite numbers
	call	isComposite
	call	Crlf

	; display end of result
	call	Crlf
	mov		edx, OFFSET result_2
	call	WriteString
	call	Crlf
	ret
showComposites ENDP

; description: determine whether a number is composite and display the composite number
; receives: none
; returns: none
; preconditions: numCom is defined and valid
; registers changed: eax, ebx, ecx, edx
isComposite	PROC
	; set up eax and ecx
	mov		eax, 0
	mov		ecx, numCom

	startLoop:
		inc		eax		; start from 0 up to nth composite numbers
		push	ecx		; save a copy of ecx counter on stack

		; base cases (eax = 1 or eax = 2 or eax = 3) - 1, 2, 3 are not composites
		cmp		eax, 3
		jbe		notComposite

		; for all other cases 
		mov		ebx, eax
		mov		ecx, eax	; set ecx counter to current eax value
		sub		ecx, 2		; sub ecx by 2 to skip div by 1 and 0

		determineComposite:
		; determine whether value (n) in eax is composite by dividing it with n - 1
		; if n % (n - 1) == 0, n is composite
		; else repeat for n % (n - 2), n % (n - 3), ..., (n % 3), (n % 2)
			push	eax		; save a copy of eax in stack
			dec		ebx		; decrement ebx to set up (n - 1)
			cdq
			div		ebx

			; if remainder == 0, n is a composite number
			cmp		edx, 0	
			je		printComposite

			; else - reset eax and proceed with next iteration
			pop		eax
			loop	determineComposite

		endNestedLoop: ; end of determineComposite loop. n is not a composite 
			jmp		notComposite

		printComposite: ; n is composite, set up eax and call print procedure
			pop		eax
			call	print

		yesComposite:	; n is composite, reset ecx counter to previous value
			pop		ecx
			jmp		continueLoop
			
		notComposite: 
		; n is not a composite, reset ecx counter to value before nested loop
		; increment ecx by 1 to prevent ecx from decreasing due to loop operator
			pop		ecx
			inc		ecx

		continueLoop:
			loop	startLoop

	endStartLoop:
		ret
isComposite ENDP

; description: procedure to print composite numbers. Each line has 10 numbers.
; receives: eax
; return: none
; preconditions: eax is determined to be a valid composite number
; registers changed: eax, edx
print	PROC
	; check if each line has 10 numbers
	cmp		count, 10
	jb		sameLine

	; point cursor to a new line when count is 10, and reset count to 0
	call	Crlf
	mov		count, 0

	sameLine: ; print the composite number on the same line as previous numbers, increment count
		inc		count
		
		; align output according to number of digits in eax
		cmp		eax, 10		; values with only one digit (1 - 9)
		jb		digitOnes
		cmp		eax, 100	; values with two digits (10 - 99)
		jb		digitTens

		; for all other values (>= 100)
		call	WriteDec
		jmp		printSpaces

	digitOnes: ; for values with only one digit (1 - 9)
	; print 2 spaces before printing the value to align them
		mov		edx, OFFSET space_2
		call	WriteString
		call	WriteDec
		jmp		printSpaces

	digitTens: ; for values with two digits (10 - 99)
	; print 1 space before printing the value to align them
		mov		edx, OFFSET space_1
		call	WriteString
		call	WriteDec
		
	printSpaces: ; print 3 spaces to separate each composite number
		mov		edx, OFFSET space_3
		call	WriteString

		ret
print	ENDP

; description: Procedure to display goodbye message
; receives: none
; return: none
; precondition: global variable bye_1 is defined
; registers changed: edx
goodbye PROC
	; display goodbye message
	mov		edx, OFFSET bye_1
	call	WriteString
	call	Crlf
	ret
goodbye ENDP

END main
