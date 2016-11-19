TITLE Elementary Arithmetic     (Program1_Cheang.asm)

; Author: Chermaine Cheang
; Course / Project ID: CS271 Program 1                Date:9/30/16
; Description: This program will
;				1. display programmer's name and program's title
;				2. display instruction for user
;				3. get two numbers from user
;				4. calculate and display the sum, difference, product, quotient and remainder of the two numbers
;				5. display terminating message
; **EC Description: 1. Program repeats until user wishes to quit
;					2. Program verifies second number is less than first number

INCLUDE Irvine32.inc

.data

intro_1		BYTE	"Elementary Arithmetic by Chermaine Cheang", 0
intro_2		BYTE	"Enter two numbers and I will show you their sum, difference, product, quotient and remainder.", 0
prompt_1	BYTE	"First number: ", 0
prompt_2	BYTE	"Second number: ", 0
num_1		DWORD	?
num_2		DWORD	?
sum			DWORD	?
diff		DWORD	?
product		DWORD	?
quotient	DWORD	?
remainder	DWORD	?
result_sum	BYTE	" + ", 0
result_diff	BYTE	" - ", 0
result_pro	BYTE	" * ", 0
result_div	BYTE	" / ", 0
result_eq	BYTE	" = ", 0
result_rem	BYTE	" remainder ", 0
goodbye		BYTE	"Bye! See you soon!", 0
ec_1		BYTE	"**EC Description: Program repeats until user wishes to quit.", 0
ec_2		BYTE	"**EC Description: Program verifies second number is less than first number.", 0
error_stop	BYTE	"ERROR!!! The second number must be less than the first number!", 0
prompt_3	BYTE	"Do you wish to quit? (Y/N)", 0
quit		BYTE	?
error_carry	BYTE	"ERROR!!! Carry Flag is set!", 0
result_none	BYTE	" cannot be determined", 0

.code
main PROC
; display introduction
	mov		edx, OFFSET intro_1
	call	WriteString
	call	Crlf

; display first extra credit description
	mov		edx, OFFSET ec_1
	call	WriteString
	call	Crlf

;display second extra credit description
	mov		edx, OFFSET ec_2
	call	WriteString
	call	Crlf

start: 
; display instruction
	call	Crlf
	mov		edx, OFFSET intro_2
	call	WriteString
	call	Crlf

; get first number
	call	Crlf
	mov		edx, OFFSET prompt_1
	call	WriteString
	call	ReadInt
	mov		num_1, eax

; get second number
	mov		edx, OFFSET prompt_2
	call	WriteString
	call	ReadInt
	mov		num_2, eax

; validate num_2 to be less than num_1
	mov		eax, num_1
	mov		ebx, num_2
	cmp		eax, ebx
	jng		inputNotOk

inputOk: ; proceed with calculations when second integer is less than first integer

summation:	; calculate sum
	mov		eax, num_1
	add		eax, num_2
	mov		sum, eax

displayAdd:	;display the result of summation of two numbers
	call	Crlf
	mov		eax, num_1
	call	WriteDec
	mov		edx, OFFSET result_sum
	call	WriteString
	mov		eax, num_2
	call	WriteDec
	mov		edx, OFFSET result_eq
	call	WriteString
	mov		eax, sum
	call	WriteDec
	call	Crlf

subtraction:	; calculate difference
	mov		eax, num_1
	sub		eax, num_2
	mov		diff, eax

displaySub:	;display the difference of two numbers
	mov		eax, num_1
	call	WriteDec
	mov		edx, OFFSET result_diff
	call	WriteString
	mov		eax, num_2
	call	WriteDec
	mov		edx, OFFSET result_eq
	call	WriteString
	mov		eax, diff
	call	WriteDec
	call	Crlf

multiplication:	; calculate product
	mov		eax, num_1
	mov		ebx, num_2
	mul		ebx		
	jc		mulError	;check if Carry Flag is set
	mov		product, eax

displayMul:	;display the result of multiplication of two numbers
	mov		eax, num_1
	call	WriteDec
	mov		edx, OFFSET result_pro
	call	WriteString
	mov		eax, num_2
	call	WriteDec
	mov		edx, OFFSET result_eq
	call	WriteString
	mov		eax, product
	call	WriteDec
	call	Crlf
	jmp		division	;continue the program with division

mulError:	;display error message for multiplication because CF = 1
	mov		edx, OFFSET error_carry
	call	WriteString
	call	Crlf
	mov		eax, num_1
	call	WriteDec
	mov		edx, OFFSET result_pro
	call	WriteString
	mov		eax, num_2
	call	WriteDec
	mov		edx, OFFSET result_eq
	call	WriteString
	mov		edx, OFFSET result_none
	call	WriteString
	call	Crlf

division:	; calculate quotient and remainder
	mov		eax, num_1
	cdq
	mov		ebx, num_2
	div		ebx
	mov		quotient, eax
	mov		remainder, edx

displayQuo:	;display the division of two numbers
	mov		eax, num_1
	call	WriteDec
	mov		edx, OFFSET result_div
	call	WriteString
	mov		eax, num_2
	call	WriteDec
	mov		edx, OFFSET result_eq
	call	WriteString
	mov		eax, quotient
	call	WriteDec
	mov		edx, OFFSET result_rem
	call	WriteString
	mov		eax, remainder
	call	WriteDec
	call	Crlf

askToQuit: ; ask if user wants to quit
	call	Crlf
	mov		edx, OFFSET prompt_3
	call	WriteString
	call	Crlf
	call	ReadChar
	mov		quit, al

	; user wants to quit - proceed to bye
	cmp		quit, 'Y'
	je		endProgram
	cmp		quit, 'y'
	je		endProgram

	; user does not want to quit - restart the program 
	cmp		quit, 'N'
	je		start
	cmp		quit, 'n'
	je		start

endProgram:	; say goodbye
	call	Crlf
	mov		edx, OFFSET goodbye
	call	WriteString
	call	Crlf

	exit	; exit to operating system

inputNotOk:	; second integer is less than first integer, display error message
	call	Crlf
	mov		edx, OFFSET error_stop
	call	WriteString
	call	Crlf
	jmp		askToQuit	;check if user wants to continue or quit

main ENDP

END main
