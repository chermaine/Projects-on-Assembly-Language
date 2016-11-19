TITLE Fibonacci Numbers     (Project2_Cheang.asm)

; Author: Chermaine Cheang
; Course / Project ID: CS 271 Program 02                Date: 10/7/16
; Description: This program will prompt user for their name and also an integer in the range of 
; 1 to 46. Then, this program will calculate the number of Fibonacci terms requested by the user, 
; and finally display them in rows of 5 before terminating.
;
; **EC Description: Display Fibonacci terms in aligned columns


INCLUDE Irvine32.inc

; constant variables
LOWER_LIMIT = 1
UPPER_LIMIT = 46

.data
username	BYTE	30 DUP(0)	; store user's name
fib_terms	DWORD	?			; store number of fib number
first		DWORD	0			; store previous value
second		DWORD	1			; store previous value
columnCount	DWORD	0			; counter for number of terms in each column
intro_1		BYTE	"Fibonacci Numbers by Chermaine Cheang", 0
intro_2		BYTE	"Hello, ", 0
prompt_1	BYTE	"What's your name? ", 0
prompt_2	BYTE	"Enter the number of Fibonacci terms to be displayed. ", 0
prompt_3	BYTE	"Give the number as an integer in the range of 1 to 46.", 0
prompt_4	BYTE	"How many Fibonacci terms do you want? ", 0
invalid_1	BYTE	"Out of range! Enter a number between 1 and 46.", 0
result_1	BYTE	"Here are the Fibonacci terms you requested:", 0
result_2	BYTE	"Results certified by Chermaine Cheang.", 0
spaces13	BYTE	"             ", 0
spaces12	BYTE	"            ", 0
spaces11	BYTE	"           ", 0
spaces10	BYTE	"          ", 0
spaces9		BYTE	"         ", 0
spaces8		BYTE	"        ", 0
spaces7		BYTE	"       ", 0
spaces6		BYTE	"      ", 0
spaces5		BYTE	"     ", 0
goodbye		BYTE	"Goodbye, ",0
ec_1		BYTE	"***EC Description: Display the numbers in aligned columns***", 0

.code
main PROC
; display program title and programmer's name
	mov		edx, OFFSET intro_1
	call	WriteString
	call	Crlf

; display extra credit description
	mov		edx, OFFSET ec_1
	call	WriteString
	call	Crlf

; display prompt to get user's name
	call	Crlf
	mov		edx, OFFSET prompt_1
	call	WriteString
	
; get user's name
	mov		edx, OFFSET username
	mov		ecx, 29
	call	ReadString
	call	Crlf

; greet user
	call	Crlf
	mov		edx, OFFSET intro_2
	call	WriteString
	mov		edx, OFFSET username
	call	WriteString
	call	Crlf

; display instruction
	call	Crlf
	mov		edx, OFFSET prompt_2
	call	WriteString
	call	Crlf
	mov		edx, OFFSET prompt_3
	call	WriteString
	call	Crlf

; get user's data
getData:
	call	Crlf
	mov		edx, OFFSET prompt_4
	call	WriteString
	call	ReadDec	; read in an unsigned integer

; validate user's data
	cmp		eax, UPPER_LIMIT
	jg		inputNotOk
	cmp		eax, LOWER_LIMIT
	jl		inputNotOk

; store user's input to fib_terms
	mov		fib_terms, eax
	call	Crlf
	jmp		inputOk

; invalid input
inputNotOk: 
	; display out of range message and re-prompt user for integer
	call	Crlf
	mov		edx, OFFSET invalid_1
	call	WriteString
	call	Crlf
	jmp		getData		; loop back to getData to prompt user for new value

; valid input. calculate and display fibonacci numbers
inputOk:
	call	Crlf
	mov		edx, OFFSET result_1
	call	WriteString
	call	Crlf

; print out first fibonacci number
	mov		eax, second
	mov		edx, eax
	call	WriteDec
	mov		edx, OFFSET spaces13
	call	WriteString
	inc		columnCount
	dec		fib_terms	; decrement total terms requested by 1 since first term has been printed
	mov		ecx, fib_terms

; beginning of for loop
top:
	mov		eax, first
	mov		ebx, second
	add		eax, ebx
	mov		edx, eax
	cmp		columnCount, 5	; check each line has 5 terms already
	je		newLine

; compare digit to allocate appropriate number of spaces so that output will be aligned
digitCompare:
	call	WriteDec
	cmp		edx, 10			; if (edx < 10)
	jl		dig_1
	cmp		edx, 100		; else if (edx < 100)
	jl		dig_2
	cmp		edx, 1000		; else if (edx < 1000)
	jl		dig_3
	cmp		edx, 10000		; else if (edx < 10000)
	jl		dig_4
	cmp		edx, 100000		; else if (edx < 100000)
	jl		dig_5
	cmp		edx, 1000000	; else if (edx < 1000000)
	jl		dig_6
	cmp		edx, 10000000	; else if (edx < 10000000)
	jl		dig_7
	cmp		edx, 100000000	; else if (edx < 100000000)
	jl		dig_8
	mov		edx, OFFSET spaces5	; else

; display appropriate spaces, stored previous values in first and second, repeat loop until ecx is 0
continue:
	call	WriteString
	inc		columnCount
	mov		first, ebx
	mov		second, eax
	loop	top

; proceed to terminate the program
	call	Crlf
	jmp		terminate

; value is less than 10
dig_1:
	mov		edx, OFFSET spaces13
	jmp		continue

; value is less than 100
dig_2:
	mov		edx, OFFSET spaces12
	jmp		continue

; value is less than 1000
dig_3:
	mov		edx, OFFSET spaces11
	jmp		continue

; value is less than 10000
dig_4:
	mov		edx, OFFSET spaces10
	jmp		continue

; value is less than 100000
dig_5:
	mov		edx, OFFSET spaces9
	jmp		continue

; value is less than 1000000
dig_6:
	mov		edx, OFFSET spaces8
	jmp		continue

; value is less than 10000000
dig_7:
	mov		edx, OFFSET spaces7
	jmp		continue

; value is less than 100000000
dig_8:
	mov		edx, OFFSET spaces6
	jmp		continue

; move cursor to new line to make sure there are only 5 terms per line
newLine:
	call	Crlf
	mov		columnCount, 0
	jmp		digitCompare

; say goodbye
terminate:
	call	Crlf
	mov		edx, OFFSET result_2
	call	WriteString
	call	Crlf
	call	Crlf
	mov		edx, OFFSET goodbye
	call	WriteString
	mov		edx, OFFSET username
	call	WriteString
	call	Crlf

	exit	; exit to operating system
main ENDP


END main
