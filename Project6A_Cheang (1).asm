TITLE Designing Low-Level I/O Procedure     (Project6_Cheang.asm)

; Author: Chermaine Cheang
; Course / Project ID: CS 271 Programming Assignment 6A                 Date: 
; Description: This program will prompt user for a total of 10 integers, validate
; user inputs to make sure that user enters valid digits and the number is not too large
; for 32-bit registers. This program will get user inputs as string, convert these inputs 
; to numeric, store them in an array and calculate the average of these numeric values. The 
; program will then display the average rounded down to nearest integer and display those 
; numeric inputs as string.
;
; Implementation notes: This program is implemented using MACRO and Procedures.
;			All procedure parameters are passed on the system stack either by value or reference.
;			All macro parameters are passed by address
;			Only global variables are strings

INCLUDE Irvine32.inc

; (insert constant definitions here)
ZERO = 48		; character codes for digit 0
NINE = 57		; character codes for digit 9
MAX_SIZE = 200	; max size of an input string
TEST_SIZE = 10		; number of input

getString	MACRO	stringToPrint, inBuffer, inCount
	push	edx
	push	ecx
	push	ebx

	mov		ebx, inCount
	displayString	stringToPrint
	mov		edx, inBuffer
	mov		ecx, MAX_SIZE
	call	ReadString
	mov		[ebx], eax

	pop		ebx
	pop		ecx
	pop		edx
ENDM

displayString MACRO buffer
	push	edx
	mov		edx, buffer
	call	WriteString
	pop		edx
ENDM

.data
intro_1		BYTE	"Programming Assignment 6A: Designing Low-Level I/O Procedures", 0
intro_2		BYTE	"Programmed by: Chermaine Cheang", 0
intro_3		BYTE	"Enter 10 positive numbers and I will display a list of the integers, ",0
intro_4		BYTE	"their sums and their average (rounded down to nearest integer).", 0
intro_5		BYTE	"Please make sure to enter numbers that are small enough to fit in a 32-bit register.", 0

prompt_1	BYTE	"Enter an unsigned number: ", 0

err_notDig	BYTE	"Invalid input! Input must be numeric. Please try again.", 0
err_tooBig	BYTE	"Invalid input! Input is too large. Please try again.", 0

spaces		BYTE	"   ", 0
result_1	BYTE	"Here are the numbers you entered:", 0
result_2	BYTE	"The sum of these numbers is ", 0
result_3	BYTE	"The average of these numbers is ", 0

numList		DWORD	10 DUP(?)		; array to store numeric values
sum			DWORD	?			
average		DWORD	?
inputString	BYTE	MAX_SIZE DUP(?)	; store string of digits from input
outString	BYTE	MAX_SIZE DUP(?)	; store string of digits to output
byteCount	DWORD	?				; holds number of bytes input
validConv	DWORD	?				; flag to indicate whether conversion was successful or failed

bye_1		BYTE	"Thank you for using this program.", 0
bye_2		BYTE	"Goodbye!", 0

ec_1		BYTE	"**EC: Number each line of user input and display a running subtotal of the usr's numbers", 0
cur_sum		BYTE	"current sum: ", 0


.code
main PROC

; (insert executable instructions here)
	call	introduction

	push	OFFSET sum
	push	OFFSET validConv
	push	OFFSET inputString
	push	OFFSET byteCount
	push	OFFSET numList
	call	ReadVal

	push	OFFSET inputString
	push	OFFSET outString
	push	OFFSET numList
	push	LENGTHOF numList
	call	WriteVal

	push	sum
	push	LENGTHOF numList
	push	OFFSET average
	call	getAverage
	
	call	goodbye
	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

;-------------------------------------------------------------------------------------------------------
; description: Procedure to display introduction by calling displayString macro
; receives: global string variables
; returns: none
; preconditions: strings are declared and initialized
; registers changed: edx
;-------------------------------------------------------------------------------------------------------
introduction	PROC
	displayString	OFFSET intro_1
	call	Crlf
	displayString	OFFSET intro_2
	call	Crlf
	call	Crlf
	displayString	OFFSET ec_1
	call	Crlf
	call	Crlf
	displayString	OFFSET intro_3
	call	Crlf
	displayString	OFFSET intro_4
	call	Crlf
	displayString	OFFSET intro_5
	call	Crlf
	call	Crlf
	ret
introduction	ENDP

;-------------------------------------------------------------------------------------------------------
; description: Procedure to get user inputs by calling getString macro, call convertToNum proc to convert
;			user input to numeric value and store the value in an array
;
; implementation notes: Procedure accessess its parameters by setting up a stack frame and referencing
;			parameters relative to the top of the system stack.
;			Procedure uses local variables:	tempNum - to hold numeric value returned from convertToNum
;											lineCount - to hold current line count of user input
;											tempSum - accumulator for current sum
;
; receives: @validConv - flag to indicate whether convertToNum was successful
;			@inputString - string to store user input
;			@byteCount - to hold number of bytes user inputed
;			@numList - array to store numeric value
;
; returns: none
; precondition: all parameters are on system stack
; registers changed: eax, ebx, ecx, edx, edi, esi
;-------------------------------------------------------------------------------------------------------
ReadVal	PROC
	LOCAL	tempNum:DWORD, lineCount:DWORD, tempSum:DWORD	; local variables 
	mov		lineCount, 0
	mov		tempSum, 0

	; get arguments from system stack
	mov		esi, [ebp+16]		; @inputString buffer
	mov		ebx, [ebp+12]		; @byteCount
	mov		edi, [ebp+8]		; @numList
	mov		ecx, TEST_SIZE		; loop counter

	getUserInput:
		; display current line count for extra credit
		inc		lineCount
		mov		eax, lineCount
		call	WriteDec
		displayString OFFSET spaces

		getString	OFFSET prompt_1, esi, ebx		;invoke getString to get user input

		; push parameters needed for convertToNum and call convertToNum
		push	[ebp+20]		; @validConv
		push	esi				; @inputString
		push	[ebx]			; byteCount
		call	convertToNum

		mov		tempNum, eax	; store value returned from convertToNum in tempNum
		mov		eax, [ebp+20]	; @validConv
		mov		edx, 0			
		cmp		[eax], edx		; check if conversion was success/input is valid
		je		notValid
		jmp		valid

	notValid:					; input is not valid, get user input again without using loop 
		dec		lineCount
		jmp		getUserInput

	valid:						; input is valid, store tempNum into numList
		mov		eax, tempNum
		mov		[edi], eax

		; add numeric value to tempSum and display current running subtotal
		add		tempSum, eax
		displayString OFFSET cur_sum
		mov		eax, tempSum
		call	WriteDec
		call	Crlf

		add		edi, 4			; increment edi to next element
		loop	getUserInput	; dec ecx and get user input again

		; store tempSum to sum
		mov		eax, [ebp+24]
		mov		ebx, tempSum
		mov		[eax], ebx

	call	Crlf
	ret		20
ReadVal	ENDP

;-------------------------------------------------------------------------------------------------------
; description: Procedure to convert a string of digit to numeric values. This procedure also validate
;			that string is digit and numeric value is not too large for a 32-bit register. 
;			Uses the following algorithm from lecture 23 to convert from string to numeric:
;				x = 0
;				for (k = 0 to len(str)-1)
;					if (48 <= str[k] <= 57)
;						x = 10 * x + (str[k] - 48)
;					else
;						break
;
; implementation notes: Procedure accessess its parameters by setting up a stack frame and referencing
;			parameters relative to the top of the system stack
;
; receives:	@inputString - user's input string
;			@validConv	- set to 1 if converted successfully, set to 0 if input is not digit/too big
;			byteCount	- LENGTHOF inputString for loop counter
;
; returns: numeric value in eax register
; preconditions: inputString is not empty, all parameters are on system stack
; registers changed: eax, ebx, ecx, edx, esi, ebp
;-------------------------------------------------------------------------------------------------------
convertToNum		PROC
	LOCAL	x:DWORD, TEN:DWORD
	mov		x, 0
	mov		TEN, 10

	push	ecx					; store current ecx value	
	mov		esi, [ebp+12]		; source = inputString
	mov		ecx, [ebp+8]		; LENGTHOF inputString
	cld							; forward direction

	digitToNum:
		mov		eax, 0			; clear eax
		lodsb					; load string onto AL register
		cmp		al, ZERO		; anything below 48 is not a digit
		jb		notDigit
		cmp		al, NINE		; anything above 57 is not a digit
		ja		notDigit
		push	eax				; save current eax value
		mov		eax, x			; eax = x
		mov		ebx, TEN		; ebx = 10
		mul		ebx				; eax = 10 * x
		pop		ebx				; get previous eax value from stack
		jc		tooBig			; check if multiplication set CF due to result being too large for eax
		add		eax, ebx		; eax = 10 * x + str[k]
		jc		tooBig			; check if addition set CF due to result being too large for eax
		sub		eax, ZERO		; eax = 10 * x + str[k] - 48
		mov		x, eax			; x = 10 * x + str[k] - 48
		loop	digitToNum		
		jmp		validDig

	notDigit:					; display error message
		displayString	OFFSET err_notDig
		call	Crlf
		call	Crlf
		jmp		invalidString

	tooBig:						; display error message
		displayString	OFFSET err_tooBig
		call	Crlf
		call	Crlf

	invalidString:				; set validConv to 0
		mov		ebx, [ebp+16]
		mov		ecx, 0
		mov		[ebx], ecx
		jmp		endConvert

	validDig:					; set validConv to 1
		mov		ebx, [ebp+16]
		mov		ecx, 1
		mov		[ebx], ecx

	endConvert:
		pop		ecx
		ret		12
convertToNum		ENDP

;-------------------------------------------------------------------------------------------------------
; description: Procedure to convert numeric value to digit strings.
;
; implementation notes: Procedure accessess its parameters by setting up a stack frame and referencing
;			parameters relative to the top of the system stack

; receives:	@numList - array of numeric values
;			@inputString - string to store reverse digit string
;			@outString	- string to store digit string
;			LENGTHOF numList - number of elements in array
; returns: none
; preconditions: all parameters passed on system stack. numList is not empty
; registers changed: eax, ebx, ecx, edi, esi
;-------------------------------------------------------------------------------------------------------
WriteVal	PROC
	LOCAL	tempByte:DWORD	; local variable to hold number of bytes converted from numeric value
	mov		tempByte, 0

	displayString	OFFSET result_1	
	call	Crlf

	mov		esi, [ebp+12]	; @numList
	mov		ecx, [ebp+8]	; size of array numList

convertToDig:				; convert numeric values to digit
	mov		eax, [esi]		; get elements from numList
	mov		edi, [ebp+20]	; @inputString 
	cld						; forward direction

getDigit:	
	mov		ebx, 10			
	cdq
	div		ebx				; eax = eax / 10
	push	eax				; store result in stack
	mov		eax, edx		; eax = remainder of division
	add		eax, ZERO		; add character code for digit '0' to eax
	stosb					; store digit in inputString
	inc		tempByte		
	pop		eax				; restore eax to quotient from division
	cmp		eax, 0			; check if eax = 0
	jz		finish			; eax = 0 --> done with conversion
	jmp		getDigit		; else repeat conversion until eax = 0

finish:
	push	[ebp+16]		; @outString
	push	[ebp+20]		; @inputString
	push	tempByte		; size of inputString
	call	reverseString	
	mov		edi, [ebp+16]	; @outString
					
	displayString	edi		; display outString
	displayString OFFSET spaces

	; call clearString to clear contents of outString to prevent printing of unneccesary bytes
	push	[ebp+16]
	push	tempByte
	call	clearString

	add		esi, 4			; move esi to next element
	mov		tempByte, 0		; reset tempByte to 0
	loop	convertToDig	

	call	Crlf
	ret		16
WriteVal	ENDP


;-------------------------------------------------------------------------------------------------------
; description: Procedure to clear content of a string 
;
; implementation notes: Procedure accessess its parameters by setting up a stack frame and referencing
;			parameters relative to the top of the system stack
; 
; receives:	@outString - string to be cleared
;			number of bytes in outString
;
; returns: none
; preconditions: all parameters passed on stack
; registers changed: eax, ecx, edi
;-------------------------------------------------------------------------------------------------------
clearString	PROC
	push	ebp
	mov		ebp, esp
	push	ecx				; save current ecx value
	mov		edi, [ebp+12]	; @outString
	mov		ecx, [ebp+8]	; number of bytes to clear

	; repetitively set edi to 0
	cld
	mov		eax, 0
	rep		stosb			

	pop		ecx				; restore ecx
	pop		ebp
	ret		8
clearString ENDP


;-------------------------------------------------------------------------------------------------------
; description: Procedure to reverse a string
;
; implementation notes: Procedure accessess its parameters by setting up a stack frame and referencing
;			parameters relative to the top of the system stack
;
; receives:	@inputString - string to be reversed
;			@outString	- location to store the reversed string
;			number of bytes of inputString
;
; returns: none
; precondition: inputString contains the digit string to be reversed. All parameters passed on system stack
; registers changed: ecx,edi, esi
;-------------------------------------------------------------------------------------------------------
reverseString PROC
	pushad					; save all registers value
	mov		ebp, esp

	mov		ecx, [ebp+36]	; number of valid bytes in inputString
	mov		esi, [ebp+40]	; @inputString

	; add ecx to esi and dec esi to point esi to last element of inputString
	add		esi, ecx		
	dec		esi		
			
	mov		edi, [ebp+44]	; @outString

reverse:					; reverse inputString and store in outString
	std						; set direction flag - move backward on inputString
	lodsb					; load esi to AL, dec esi
	cld						; clear direction flag - move forward on outString
	stosb					; store AL to edi, inc edi
	loop	reverse			; continue until inputString[0]

	popad					; restore all registers
	ret		12
reverseString ENDP


;-------------------------------------------------------------------------------------------------------
; description: Procedure to calculate the average of user's input and display sum and average using 
;			displayString macro. Formula for average = sum/num of input
;
; implementation notes: Procedure accessess its parameters by setting up a stack frame and referencing
;			parameters relative to the top of the system stack
;
; receives:	sum - sum of numbers in numList
;			LENGTHOF numList - num of input
;			@average - store result 
;
; returns: none
; preconditions: sum has been determined, all parameters are on system stack
; registers changed: eax, ebx, ecx, ebp
;-------------------------------------------------------------------------------------------------------
getAverage		PROC
	push	ebp
	mov		ebp, esp

	mov		eax, [ebp+16]	; sum

displaySum:
	call	Crlf
	displayString	OFFSET result_2
	call	WriteDec
	call	Crlf

	mov		ecx, [ebp+8]	; @average
	mov		ebx, [ebp+12]	; LENGTHOF numList
	cdq
	div		ebx				; average = sum / LENGTHOF
	mov		[ecx], eax		; store result in average 

displayAverage:
	displayString	OFFSET result_3
	call	WriteDec
	call	Crlf

	pop		ebp
	ret		12
getAverage		ENDP


;-------------------------------------------------------------------------------------------------------
; description: Procedure display farewell message using displayString macro
;
; receives: global string variables
; returns: none
; preconditions: strings are declared and initialized
; registers changed: edx
;-------------------------------------------------------------------------------------------------------
goodbye	PROC
	call	Crlf
	displayString	OFFSET bye_1
	call	Crlf
	displayString	OFFSET bye_2
	call	Crlf
	ret
goodbye	ENDP

END main
