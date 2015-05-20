TITLE JH_ASM_05
; CSCI263
; Programming Excercise 05: MASM Sort Array
; Author: Josh Harmon
; Created: 4/22/13
; Last Modified: 4/23/13
;
; Program functions and outputs correctly
INCLUDE Irvine32.inc

.data
	; Message strings
	sTitle BYTE "This program works with an array of integers", 0dh, 0ah, 0
	sIntPrompt BYTE "Please enter an integer: ", 0
	sListPrompt BYTE "Do you want to see SORTED or UNSORTED list? Reply S or U: ", 0
	sUnsorted BYTE "This is the unsorted list: ", 0dh, 0ah, 0
	sSorted BYTE "This is the sorted list: ", 0dh, 0ah, 0
	sRepeat BYTE "Repeat program? Reply Y or N: ", 0
	sInvalid BYTE "Invalid Response", 0dh, 0ah, 0
	
	; Sort data
	iMin SDWORD ?
	iPos SDWORD 0
	
	; Array
	iIntArr SDWORD 10 DUP(?) ; Doubleword array of size 10
	ARRAYSZ = ($ - iIntArr) / TYPE iIntArr ; Auto size for array
	ARRAYSZDEC = ARRAYSZ - 1; For sort array
	
.code
main PROC
; Outer program loop
PROGRAMLOOP:
	; Display initial message
	lea EDX, sTitle
	call WriteString
	
	; Prep read loop
	mov ECX, ARRAYSZ		; Set loop counter to size of array
	lea EDX, sIntPrompt
	lea ESI, iIntArr
	
; Read Loop
READLOOP:
	; Prompt and receive input into array
	call WriteString		; Prompt
	call ReadInt			; Grab int into EAX
	mov [ESI], EAX			; Store int into proper index in array
	add ESI, TYPE iIntArr	; increment index in array
	loop READLOOP			; Call loop
	
LISTPROMPT:
	; Clear registers
	mov EAX, 0
	mov EBX, 0
	mov ECX, 0
	mov EDX, 0
	; Prompt to sort list
	lea EDX, sListPrompt
	call WriteString
	call ReadChar			; Get input
	call Crlf				; linebreak
	; Compare and jump based on input
	cmp EAX, "u"
	je UNSORTPROMPT
	cmp EAX, "U"
	je UNSORTPROMPT
	cmp EAX, "s"
	je SORTLIST
	cmp EAX, "S"
	je SORTLIST
	; Not valid input prompt and repeat
	lea EDX, sInvalid
	call WriteString
	jmp LISTPROMPT
	
SORTLIST:
	; Loop conditions
	; iPos - outerloop counter
	; ECX = innerloop counter
	mov ECX, iPos			; ECX = iPos + 1
	inc ECX					; ->^
	
	; iMin = iPos
	mov EBX, iPos
	mov iMin, EBX
	INNERSORT:
		; if a[ECX] < a[iMin] then iMin = ECX
		mov EBX, [iIntArr + 4 * ECX]	; EBX = a[ECX]
		mov EAX, iMin
		mov EDX, [iIntArr + 4 * EAX]	; EDX = a[iMin]
		cmp EBX, EDX
		jge INNERCONT		; if a[ECX] < a[iMin]
		mov iMin, ECX		; then iMin = ECX
	INNERCONT:
		inc ECX				; increment loop counter
		cmp ECX, ARRAYSZ	;
		jne INNERSORT		; if ECX = Array length, loop
		;; end INNERSORT
		
	; Load adresses to swap
	mov EBX, iPos
	lea ESI, [iIntArr + 4 * EBX]	; iIntArr[iPos]
	mov EBX, iMin
	lea EDI, [iIntArr + 4 * EBX]	; iIntArr[iMin]
	; Swap iIntArr[iPos] with iIntArr[iMin]
	;  http://answers.yahoo.com/question/index?qid=20110322004050AAb9emZ
	mov EDX, [ESI]				; EDX = iIntArr[iPos]
	xchg EDX, [EDI]				; swap iIntArr[iPos] and iIntArr[iMin]
	xchg EDX, [ESI]				; swap iIntArr[iMin] and iIntArr[iPos]
	; NOTE: Easier to just use stack with push/pop

	; Outer loop conditions
	mov EAX, iPos				; Load loop counter
	inc EAX						; Increment counter
	mov iPos, EAX				; store iPos
	cmp EAX, ARRAYSZ			; iPos == array length
	jne SORTLIST				; Loop until ->^
	;; end SORTLIST

	; Prompt Sorted
	lea EDX, sSorted
	call WriteString
	call CRLF
	jmp PRINT					; Skip over unsorted message

UNSORTPROMPT:
	lea EDX, sUnsorted
	call WriteString
	call Crlf
	
PRINT:
	; Prep print loop
	mov ECX, ARRAYSZ
	lea ESI, iIntArr
	
PRINTLOOP:
	; Print Loop
	mov EAX, [ESI]			; Load value from array
	call WriteInt			; Print value from array
	call Crlf
	add ESI, TYPE iIntArr	; increment index in array
	loop PRINTLOOP
	
REPEATPROMPT:
	; Clear registers
	mov EAX, 0
	mov EBX, 0
	mov ECX, 0
	mov EDX, 0
	; Repeat prompt
	lea EDX, sRepeat
	call WriteString		; Check if user wants to repeat program
	call ReadChar
	call Crlf
	cmp EAX, "y"			; "y"
	je PROGRAMLOOP			; Repeat
	cmp EAX, "Y"			; "Y"
	je PROGRAMLOOP			; Repeat
	cmp EAX, "n"			; "n"
	je EXITPROGRAM			; Exit
	cmp EAX, "N"			; "N"
	je EXITPROGRAM			; Exit
	lea EDX, sInvalid		; Prompt user to enter proper entry
	call WriteString
	jmp REPEATPROMPT		; Repeat Prompt
	
EXITPROGRAM:
	push +00000000h			; return code
	exit
main ENDP
END main
	