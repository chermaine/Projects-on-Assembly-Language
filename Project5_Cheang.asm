TITLE Sorting Random Integers     (Project5_Cheang.asm)

; Author: Chermaine Cheang
; Course / Project ID: CS271 Program #5                 Date: 11/16/16
; Description: This program will ask user for n numbers in the range of 10-200, validate
;		user's input and generate n random integers between 100-999. All the random integers 
;		will be stored as array. The program will display the unsorted array, then sort
;		the array, display the sorted array and finally determine the median value of these
;		integers. 
;
; Implementation notes: This program is implemented using procedures.
;		Parameters are either passed by value or by reference on the system stack.
;		Strings are used as global variables

INCLUDE Irvine32.inc

; (insert constant definitions here)
MIN = 10	; minimum value user can enter
MAX = 200	; maximum value user can enter
LO = 100	; minimum value of random numbers generated
HI = 999	; maximum value of random numbers generated
COUNT = 10	; number of random numbers per line


.data

; (insert variable definitions here)
intro_1			BYTE	"Sorting Random Integers by Chermaine Cheang", 0
intro_2			BYTE	"Enter a number between 10 and 200, and I will generate that many random numbers in the range ",0
intro_3			BYTE	"of [100...999], display them, sort them in descending order, and display the sorted version of ", 0
intro_4			BYTE	"these numbers. I will also determine and display the median value of these numbers.", 0

prompt_1		BYTE	"How many numbers should I generate?", 0
prompt_2		BYTE	"Enter an integer between 10 and 200: ", 0

invalid_min		BYTE	"Invalid input. Number must be greater than or equal 10. Please try again!", 0
invalid_max		BYTE	"Invalid input. Number must be smaller than or equal 200. Please try again!", 0

request			DWORD	?			; user specified n numbers
list			DWORD	MAX	DUP(?)	; array to hold a max of 200 integers
valid			DWORD	?			; flag for validity of user's input

result_unsorted	BYTE	"Here are the unsorted random numbers:", 0
result_sorted	BYTE	"Here are the sorted random numbers:", 0
result_median	BYTE	"The median is ", 0

space_3			BYTE	"   ", 0

bye_1			BYTE	"Thanks for using my program.", 0
bye_2			BYTE	"Goodbye!", 0

.code
main PROC
	call	Randomize			; provide a seed value to have unique random numbers 
	call	introduction

	push	OFFSET request		; set up reference parameter for getUserData
	call	getUserData

	; set up parameters for fillArray proc
	push	OFFSET list			; array passed by reference
	push	request				; request passed by value
	call	fillArray

	; set up parameters for displaying unsorted array
	push	OFFSET list			; passed array by reference
	push	request				; passed request by value
	push	OFFSET result_unsorted	; passed title by reference
	call	displayArray

	; set up parameters for sortArray
	push	OFFSET list			; passed array by reference
	push	request				; passed request by value
	call	sortArray

	; set up parameters for getMedian
	push	OFFSET list			; passed array by reference
	push	request				; passed request by value
	call	getMedian

	; set up parameters for displaying sorted array
	push	OFFSET list			; passed array by reference
	push	request				; passed request by value
	push	OFFSET result_sorted; passed title by reference
	call	displayArray

	call	goodbye

	exit	; exit to operating system
main ENDP

; description: procedure to display introductions
; receives:	none
; returns: none
; preconditions: global variables intro_1, intro_2, intro_3, intro_4 are defined
; registers changed: edx
introduction	PROC
	mov		edx, OFFSET intro_1
	call	WriteString
	call	Crlf
	call	Crlf

	mov		edx, OFFSET intro_2
	call	WriteString
	call	Crlf

	mov		edx, OFFSET intro_3
	call	WriteString
	call	Crlf

	mov		edx, OFFSET intro_4
	call	WriteString
	call	Crlf
	call	Crlf
	ret
introduction	ENDP


; description: procedure to prompt user for number of elements wanted, and set variable request 
;		according to user input
; implementation notes: This procedure accesses its parameters by setting up a stack frame and 
;		referencing parameters relative to the top of the system stack
; receives: value of request from stack
; returns: user input for request
; preconditions: none
; registers changed: eax, edx, ebp
getUserData		PROC
	push	ebp
	mov		ebp, esp

getData:
	; display prompt
	mov		edx, OFFSET prompt_1
	call	WriteString
	call	Crlf
	mov		edx, OFFSET prompt_2
	call	WriteString

	; get user's input
	call	ReadDec

	; set up parameters for validate and call validate
	push	eax				; passed by value on stack
	push	OFFSET valid	; passed by reference on stack
	call	validate

	; check if validate return true or false
	cmp		valid, 0
	je		invalidInput
	; input is valid. Store input in request
	mov		ebx, [ebp + 8]		; get @request in ebx
	mov		[ebx], eax			; set request = eax (input)
	call	Crlf
	jmp		endProc

invalidInput: ; validate return false, prompt user for a new integer
	jmp		getData

endProc:
	pop		ebp
	ret		4
getUserData		ENDP


; description: procedure to validate user input
; implementation notes: This procedure accesses its parameters by setting up a stack frame and 
;		referencing parameters relative to the top of the system stack
; receives: from stack: user's input - value to be validated
;						@valid - set to 0 for false, 1 for true, and return
; returns:	valid flag (1 = true, 0 = false)
; preconditions: user entered an input
; registers changed: eax, ebx, ecx, edx, ebp
validate		PROC
	push	ebp
	mov		ebp, esp

	mov		eax, [ebp+12]		; get user's input from stack 
	mov		ebx, [ebp+8]		; get address of valid from stack
	mov		ecx, 0				; set ecx = false
	mov		edx, 1				; set edx = true

	; validate user's input
	cmp		eax, MIN
	jb		tooSmall			; input not valid
	cmp		eax, MAX
	ja		tooBig				; input not invalid
	mov		[ebx], edx			; input is valid, set valid to true
	jmp		endValidate

tooSmall:
	; display error message for invalid input (input < 10)
	mov		edx, OFFSET invalid_min
	call	WriteString
	call	Crlf
	call	Crlf
	mov		[ebx], ecx			; set valid to false
	jmp		endValidate

tooBig:
	; display error message for invalid input (input > 200)
	mov		edx, OFFSET invalid_max
	call	WriteString
	call	Crlf
	call	Crlf
	mov		[ebx], ecx			; set valid to false
	jmp		endValidate

endValidate:
	pop		ebp
	ret		8
validate		ENDP


; description: procedure to fill array with random numbers in the range of 100 to 999
; implementation notes: This procedure accesses its parameters by setting up a stack frame and 
;		referencing parameters relative to the top of the system stack
; receives: from stack: @array - to access array
;						request - as loop counter
; returns: an array of random numbers
; preconditions: request is defined and valid
; registers changed: eax, ecx, edi
fillArray		PROC	
	LOCAL	range:DWORD		; local variable to store range of random numbers

	; calculate and set local variable range
	; range = HI - LO + 1
	mov		eax, HI
	sub		eax, LO
	inc		eax
	mov		range, eax

	; set up edi and ecx registers
	mov		edi, [ebp+12]		; edi points to first element of array
	mov		ecx, [ebp+8]		; ecx = request

getNum:
	; generate random numbers and store in array
	call	RandomRange
	add		eax, LO		
	mov		[edi], eax		; store random number generated in array
	add		edi, 4			; add 4 to edi to point to next element of the array
	loop	getNum		

	ret		8
fillArray		ENDP


; description: procedure to display contents of an array
; implementation notes: 1. This procedure accesses its parameters by setting up a stack frame and 
;				referencing parameters relative to the top of the system stack
;				2. This procedure uses a local variable to keep track of number of random numbers
;				printed per line
; receives: from stack: @array - to access array 
;						request - as loop counter
;						@title - to be printed
; returns: none
; preconditions: array is filled 
; registers changed: eax, ebx, ecx, edx, esi
displayArray	PROC
	LOCAL	numCount:DWORD		; variable to hold number of random numbers printed per line
	mov		numCount, 0

	; display title
	mov		edx, [ebp+8]
	call	WriteString
	call	Crlf
	call	Crlf

	; display array
	mov		ebx, 0				; act as element pointer
	mov		esi, [ebp+16]		; get array from stack
	mov		ecx, [ebp+12]		; get request from stack

printElement:
	mov		eax, [esi+ebx]		; get current element
	inc		numCount
	cmp		numCount, COUNT		; check if need to move to new line
	ja		newLine
	jmp		sameLine

newLine:
	call	Crlf
	mov		numCount, 1			; reset numCount 

sameLine:
	call	WriteDec
	mov		edx, OFFSET space_3
	call	WriteString
	add		ebx, 4				; point to next element
	loop	printElement

	call	Crlf
	call	Crlf
	ret		12
displayArray	ENDP


; description: procedure to sort array. The algorithm used:
;		for (int i = 0; i < request - 1; i++) {
;			for (int j = i + 1; j < request; j++) {
;				if (array[i] < array[j]) {
;					exchange(array[i], array[j]);
;				}
;			}
;		}
; implementation notes: This procedure accesses its parameters by setting up a stack frame and 
;		referencing parameters relative to the top of the system stack
; receives: from stack: @array - for array accessing
;						request - total elements in array, for ecx counter
; returns: a sorted array
; preconditions: array has been filled with random numbers
; registers changed: eax, ebx, ecx, edx, ebp, edi, esi
sortArray		PROC
	push	ebp
	mov		ebp, esp

	; set up outer for loop - for (int i = 0; i < request - 1; i++)
	mov		eax, 0		; i = 0		
	mov		ecx, [ebp+8]; i < request - 1
	dec		ecx

startLoop:
	; for (int j = i + 1; j < request ; j++)
	mov		ebx, eax	; j = i
	inc		ebx			; j = i + 1
	push	ecx			; save current ecx
	mov		ecx, [ebp+8]; get request
	sub		ecx, ebx	; set ecx = request - j, so that the condition j < request holds

innerLoop:
	; if (array[i] < array[j]) {
	;		exchange(array[i], array[j]);
	;}
	mov		edx, [esi+eax*4]	; edx = array[i]
	cmp		edx, [esi+ebx*4]	; compare edx with array[j]
	jb		switch
	jmp		loopingInner

switch:
	; set up parameters for exchange
	lea		edi, [esi+eax*4]	; passed array[i] by reference
	push	edi		
	lea		edi, [esi+ebx*4]	; passed array[j] by reference
	push	edi
	call	exchange

loopingInner:
	inc		ebx			; j++
	loop	innerLoop		

endInner:
	inc		eax			; i++
	pop		ecx			; get previous ecx value
	loop	startLoop

	pop		ebp
	ret		8
sortArray		ENDP


; description: procedure to exchange the element of array[i] with array[j]
; implementation notes: This procedure accesses its parameters by setting up a stack frame and 
;		referencing parameters relative to the top of the system stack
; receives: @array[i] and @array[j]
; returns: exchange array[i] with array[j]
; preconditions: array[i] is smaller than array[j]
; registers changed: eax, ebx, ecx, edx, ebp
exchange		PROC
	pushad
	mov		ebp, esp

	; get arguments from stacks
	mov		eax, [ebp+40]	
	mov		ebx, [ebp+36]	

	; get value from pointers
	mov		ecx, [eax]
	mov		edx, [ebx]

	; exchange value of pointers
	mov		[eax], edx
	mov		[ebx], ecx

	popad
	ret		8
exchange		ENDP


; description: procedure to determine the median of the array of random numbers.
;		For even number of elements: median = (array[n/2] + array[(n/2) -1]) / 2
;		For odd number of elements: median = array[n/2]
; implementation notes: This procedure accesses its parameters by setting up a stack frame and 
;		referencing parameters relative to the top of the system stack
; receives: from stack: @array - to access array
;						request - number of elements, to determine "middle" position
; returns: none
; preconditions: array must be sorted
; registers changed: eax, ebx, edx, ebp, esi
getMedian		PROC
	push	ebp
	mov		ebp, esp
	
	; get arguments 
	mov		esi, [ebp+12]	; get array from stack
	mov		eax, [ebp+8]	; get request from stack

	; determine "middle" position
	mov		ebx, 2
	cdq
	div		ebx			

	; check if number of elements is even
	cmp		edx, 0
	je		evenElements

	; number of elements is odd
	mov		eax, [esi+eax*4]	; get the "middle" element
	jmp		displayMedian

evenElements:
	; calculate the average of the two middle elements to determine median
	; due to array indexing: 
	;		first middle element = (request / 2) - 1 
	;		second middle element = (request / 2)
	mov		ebx, [esi+eax*4]	; ebx = array[request/2]
	dec		eax					 
	add		ebx, [esi+eax*4]	; ebx += array[(request/2) - 1]
	mov		eax, ebx
	cdq
	mov		ebx, 2
	div		ebx					; ebx /= 2

	; determine whether rounding is needed (round to nearest integer)
	push	eax					; save current eax on stack
	mov		eax, edx			; eax = remainder
	mul		ebx					; eax *= 2
	
	; if (eax >= 2) rounding required
	cmp		eax, 2				
	jae		rounding
	; else print median
	pop		eax					
	jmp		displayMedian

rounding: ; round to nearest integer 
	pop		eax
	inc		eax

displayMedian:
	; print result
	mov		edx, OFFSET result_median
	call	WriteString
	call	WriteDec
	call	Crlf
	call	Crlf

	pop		ebp
	ret		8
getMedian		ENDP

; description: procedure to display terminating message
; receives: none
; returns: none
; preconditions: global variables bye_1 and bye_2 are defined
; registers changed: edx
goodbye			PROC
	mov		edx, OFFSET bye_1
	call	WriteString
	call	Crlf

	mov		edx, OFFSET bye_2
	call	WriteString
	call	Crlf
	call	Crlf
	ret
goodbye			ENDP

END main
