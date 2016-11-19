TITLE Integer Accumulator     (Project3_Cheang.asm)

; Author: Chermaine Cheang
; Course / Project ID : CS271 Programming Assignment 3       Date: Oct 20, 2016
; Description: This program will repeatedly ask user to enter an integer between -100
; and -1 until a non-negative number is entered. Then, the program will calculate the
; average of those numbers entered by user rounded to nearest integer. The program will
; also display the total number of valid input entered by user and the sum of those
; negative numbers.  

INCLUDE Irvine32.inc

; (insert constant definitions here)
LOWER_LIMIT = -100
UPPER_LIMIT = -1

.data
intro_1		BYTE	"Integer Accumulator by Chermaine Cheang", 0
intro_2		BYTE	"Enter numbers between -100 and -1 (inclusive), and I will display the sum and average of the numbers you entered!", 0
intro_3		BYTE	"Enter a non-negative number when you are finised to see the results.", 0
ec_1		BYTE	"**EC: Number the lines during user input",0
ec_2		BYTE	"**EC: Calculate and display average as a floating-point number, rounded to nearest 0.001", 0
prompt_1	BYTE	"What is your name? ", 0
prompt_2	BYTE	"Enter number: ", 0
greet_1		BYTE	"Hello, ", 0
bye_1		BYTE	"Thank you for using Integer Accumulator!", 0
bye_2		BYTE	"Goodbye, ", 0

; variables for calculation
username	BYTE	30	DUP(0)
count		DWORD	0
sum			SDWORD	0
average		SDWORD	?
remainder	SDWORD	?

result_1	BYTE	"You entered ", 0
result_2	BYTE	" negative numbers.", 0
result_3	BYTE	"The sum of your valid numbers is ", 0
result_4	BYTE	"The rounded average is ", 0
result_5	BYTE	"The average as floating-point number is ", 0
error_1		BYTE	"You did not enter any negative numbers.", 0
error_2		BYTE	"Invalid input! Numbers must be between -100 and -1!", 0

; variables for extra credit
thousand	DWORD	1000
lineCount	DWORD	0
printLine	BYTE	"Ln ", 0
printSpace	BYTE	"     ", 0

.code
main PROC

; display program title and programmer's name
	mov		edx, OFFSET intro_1
	call	WriteString
	call	Crlf
	call	Crlf

; display extra credit option
	mov		edx, OFFSET ec_1
	call	WriteString
	call	Crlf
	mov		edx, OFFSET ec_2
	call	WriteString
	call	Crlf
	call	Crlf

; prompt for user's name
	mov		edx, OFFSET prompt_1
	call	WriteString

; get user's name
	mov		edx, OFFSET username
	mov		ecx, SIZEOF username
	call	ReadString
	call	Crlf

; greet user
	mov		edx, OFFSET greet_1
	call	WriteString
	mov		edx, OFFSET username
	call	WriteString
	call	Crlf
	call	Crlf

; display instructions
	mov		edx, OFFSET intro_2
	call	WriteString
	call	Crlf
	mov		edx, OFFSET intro_3
	call	WriteString
	call	Crlf
	call	Crlf

; set up accumulator
	mov		ebx, sum

getNum:
	; display line number
	mov		edx, OFFSET printLine
	call	WriteString
	inc		lineCount
	mov		eax, lineCount
	call	WriteDec
	mov		edx, OFFSET printSpace
	call	WriteString

	; prompt user for number
	mov		edx, OFFSET prompt_2
	call	WriteString

	; get number using ReadInt(signed integers)
	call	ReadInt

	; validate input by user
	; jump to inputNotOk when input is smaller than -100
	cmp		eax, LOWER_LIMIT	
	jl		inputNotOk

	; proceed to calculation when input is non-negative
	cmp		eax, UPPER_LIMIT
	jg		endGetNum

inputOk:
	; input is valid
	add		ebx, eax	; add input to ebx (accumulator)
	inc		count		; increment count
	jmp		getNum		; jump to getNum to prompt user for another number

inputNotOk:
	; input not valid 
	call	Crlf
	mov		edx, OFFSET error_2
	call	WriteString		; display error message
	call	Crlf
	dec		lineCount
	jmp		getNum			; jump to getNum to prompt user for another number

endGetNum:
	; user entered a non-negative number
	call	Crlf

	; check if user entered any negative numbers. Jump to noNum if no number entered
	mov		eax, count
	cmp		eax, 0
	je		noNum

	; display number of negative numbers entered. Jump to continue
	mov		edx, OFFSET result_1
	call	WriteString
	call	WriteDec
	mov		edx, OFFSET result_2
	call	WriteString
	call	Crlf
	jmp		continue

noNum:
	; no negative numbers entered, jump to goodbye
	mov		edx, OFFSET error_1
	call	WriteString
	call	Crlf
	jmp		goodbye

continue:
	; get sum from ebx
	mov		sum, ebx

display_sum:
	; display sum of negative numbers
	mov		edx, OFFSET result_3
	call	WriteString
	mov		eax, sum
	call	WriteInt
	call	Crlf

calculate_average:
	; calculate average of negative numbers
	mov		eax, sum
	cdq
	mov		ebx, count
	idiv	ebx
	mov		average, eax
	mov		remainder, edx

	; check if rounding is required. If remainder*2 <= count, then no rounding needed
	mov		eax, remainder
	neg		eax
	mov		ebx, 2
	mul		ebx
	cmp		eax, count
	jle		noRounding

	; round average to nearest integer by substracting 1 
	sub		average, 1

noRounding:
	; display average
	mov		edx, OFFSET result_4
	call	WriteString
	mov		eax, average
	call	WriteInt
	call	Crlf

fp_average:
	; calculate average as floating-point number
	fild	sum
	fidiv	count

	; rounding to nearest .001
	fimul	thousand
	frndint
	fidiv	thousand

	; display average as floating-point number
	mov		edx, OFFSET result_5
	call	WriteString
	call	WriteFloat
	call	Crlf

goodbye:
	; display parting message
	call	Crlf
	mov		edx, OFFSET bye_1
	call	WriteString
	call	Crlf
	mov		edx, OFFSET bye_2
	call	WriteString
	mov		edx, OFFSET username
	call	WriteString
	call	Crlf

	exit	; exit to operating system
main ENDP

END main
