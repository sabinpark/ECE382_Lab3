;-------------------------------------------------------------------------------
;	Sabin Park
;	Fall 2014
;	MSP430G2553
;	Draw an 8x8 pixel box in the center of the screen. The box moves with user input:
;		UP (SW1), DOWN (SW4), LEFT (SW2), RIGHT (SW1)
;-------------------------------------------------------------------------------
	.cdecls C,LIST,"msp430.h"		; BOILERPLATE	Include device header file

LCD1202_SCLK_PIN:				.equ	20h		; P1.5
LCD1202_MOSI_PIN: 				.equ	80h		; P1.7
LCD1202_CS_PIN:					.equ	01h		; P1.0
LCD1202_BACKLIGHT_PIN:			.equ	10h
LCD1202_RESET_PIN:				.equ	01h
NOKIA_CMD:						.equ	00h
NOKIA_DATA:						.equ	01h

STE2007_RESET:					.equ	0xE2
STE2007_DISPLAYALLPOINTSOFF:	.equ	0xA4
STE2007_POWERCONTROL:			.equ	0x28
STE2007_POWERCTRL_ALL_ON:		.equ	0x07
STE2007_DISPLAYNORMAL:			.equ	0xA6
STE2007_DISPLAYON:				.equ	0xAF

BOX_WIDTH:	.equ	0x08	; the width of the box

; center positions of the LCD (for an 8x8 pixel box)
X_CENTER:	.equ	0x2c	; decimal of 44
Y_CENTER:	.equ	0x04

; boundaries of the LCD
X_MIN:		.equ	0x00	; left-most edge
X_MAX:		.equ	0x58	; right-most edge, 96 (screen edge) - 8 (box width)
Y_MIN:		.equ	0x00	; top of screen
Y_MAX:		.equ	0x08	; bottom of screen, 9th page minus 1

; the bits of P2IN corresponding to the switches
UP_BIT:		.equ	0x20
DOWN_BIT:	.equ	0x10
LEFT_BIT:	.equ	0x04
RIGHT_BIT:	.equ	0x02

 	.text								; BOILERPLATE	Assemble into program memory
	.retain								; BOILERPLATE	Override ELF conditional linking and retain current section
	.retainrefs							; BOILERPLATE	Retain any sections that have references to current section
	.global main						; BOILERPLATE

;-------------------------------------------------------------------------------
;           						main
;	R8		stores the box width (used as a counter)
;	R9		stores the pit used (corresponds to the switches)
;	R10		row value of cursor
;	R11		value of @R12
;
;	When calling writeNokiaByte:
;	R12		1-bit	Parameter to writeNokiaByte specifying command or data
;	R13		8-bit	data or command
;
;	when calling setAddress:
;	R12		row address
;	R13		column address
;-------------------------------------------------------------------------------
main:
	mov.w   #__STACK_END,SP				; Initialize stackpointer
	mov.w   #WDTPW|WDTHOLD, &WDTCTL  	; Stop watchdog timer
	dint								; disable interrupts

	call	#init						; initialize the MSP430
	call	#initNokia					; initialize the Nokia 1206
	call	#clearDisplay				; clear the display and get ready....

	mov	#Y_CENTER, R10					; centers the Y position
	mov	#X_CENTER, R11					; centers the X position

	mov	R10, R12						; copies the Y position into R12
	mov	R11, R13						; copies the X position into R13

	call	#setAddress					; set the address of the box position

	mov 	#BOX_WIDTH, R8				; set the width of the box

	call	#drawBox					; draw the initial box at the center of the screen

;-------------------------------------------------------------------------------
;	UP
;-------------------------------------------------------------------------------
checkUP:
	bit.b	#UP_BIT, &P2IN		; is bit 5 of P2IN set?
	jnz		checkDOWN			; no? then check bit 4
	mov		#UP_BIT, R9			; yes? store bit 5 of P2IN
	dec		R10					; move the box up
	cmp		#Y_MIN, R10
	; if R10 >= 0, then leave it be and jump to pressed
	jge		pressed
	; else if R10 < 0, then set Y MIN
setYMIN:
	mov		#Y_MIN, R10			; keep the box at the top of the screen
	jmp		pressed				; go to pressed
;-------------------------------------------------------------------------------
;	DOWN
;-------------------------------------------------------------------------------
checkDOWN:
	bit.b	#DOWN_BIT, &P2IN	; is bit 4 of P2IN set?
	jnz		checkLEFT			; no? then check bit 2 of P2IN
	mov		#DOWN_BIT, R9		; yes? store bit 4 of P2IN
	inc		R10					; move the box down
	cmp		#Y_MAX, R10
	; if R10 >= 9 rows, then set Y MAX
	jge		setYMAX
	; else, jump to pressed
	jmp		pressed
setYMAX:
	mov		#Y_MAX, R10			; keep the box at the bottom of the screen
	jmp		pressed				; go to pressed
;-------------------------------------------------------------------------------
;	LEFT
;-------------------------------------------------------------------------------
checkLEFT:
	bit.b	#LEFT_BIT, &P2IN	; is bit 2 of P2IN set?
	jnz		checkRIGHT			; no? then check bit 1 of P2IN
	mov		#LEFT_BIT, R9		; yes? store bit 2 of P2IN
	sub		#8, R11				; move the box to the left
	cmp		#X_MIN, R11
	; if R11 >= 0, jump to pressed
	jge		pressed
	; else, set X MIN
setXMIN:
	mov		#X_MIN, R11			; keep the box at the left edge of the screen
	jmp		pressed				; go to pressed
;-------------------------------------------------------------------------------
;	RIGHT
;-------------------------------------------------------------------------------
checkRIGHT:
	bit.b	#RIGHT_BIT, &P2IN	; is bit 1 of P2IN set?
	jnz		checkUP				; no? then check bit 5 of P2IN
	mov		#RIGHT_BIT, R9		; yes? store bit 1 of P2IN
	add		#8, R11				; move the box to the right
	cmp		#X_MAX, R11
	; if R11 >= X MAX, set X MAX
	jge		setXMAX
	; else, jump to pressed
	jmp		pressed
setXMAX:
	mov		#X_MAX, R11			; keep the box at the right edge of the screen
	jmp		pressed

;-------------------------------------------------------------------------------
;	PRESSED
;	at this point, the button is being held down; once released, the box will be drawn
;-------------------------------------------------------------------------------
pressed:
	bit.b	R9, &P2IN			; bit X of P2IN clear? (bit X depends on which button was pressed)
	jz		pressed				; Yes, branch back and wait
; otherwise, the button is released
released:
	mov 	#BOX_WIDTH, R8		; set the width of the box (the counter)
	mov		R10, R12			; copy over the rows and columns to R12 and R13
	mov		R11, R13
	call	#clearDisplay		; clear the display
	call	#setAddress			; set the address of the rows and columns
	call	#drawBox			; actually draw the box
	jmp		checkUP				; go back to checking for user input

;-------------------------------------------------------------------------------
;	Name:		drawBox
;	Inputs:		none
;	Outputs:	none
;	Purpose:	Draws an 8x8 pixel box
;
;	Registers:	R12 - row address
;				R13 - column address
;-------------------------------------------------------------------------------
drawBox:
	mov		#NOKIA_DATA, R12	; stores data into R12
	mov		#0xFF, R13			; draw an 8 pixel high solid bar (1x8 pixels)

	call	#writeNokiaByte		; draws the pixels

	dec	R8						; decrement the counter
	jnz	drawBox					; keep drawing until we finish all 8 bars

	mov 	#BOX_WIDTH, R8		; reset the width of the box (reset counter)
	ret

;-------------------------------------------------------------------------------
;	Name:		initNokia		68(rows)x92(columns)
;	Inputs:		none
;	Outputs:	none
;	Purpose:	Reset and initialize the Nokia Display
;
;	Registers:	R12 mainly used as the command specification for writeNokiaByte
;				R13 mainly used as the 8-bit command for writeNokiaByte
;-------------------------------------------------------------------------------
initNokia:
	push	R12
	push	R13

	bis.b	#LCD1202_CS_PIN, &P1OUT

	; This loop creates a nice delay for the reset low pulse
	bic.b	#LCD1202_RESET_PIN, &P2OUT
	mov		#0FFFFh, R12
delayNokiaResetLow:
	dec		R12
	jne		delayNokiaResetLow

	; This loop creates a nice delay for the reset high pulse
	bis.b	#LCD1202_RESET_PIN, &P2OUT
	mov		#0FFFFh, R12
delayNokiaResetHigh:
	dec		R12
	jne		delayNokiaResetHigh
	bic.b	#LCD1202_CS_PIN, &P1OUT

	; First write seems to come out a bit garbled - not sure cause
	; but it can't hurt to write a reset command twice
	mov		#NOKIA_CMD, R12
	mov		#STE2007_RESET, R13
	call	#writeNokiaByte

	mov		#NOKIA_CMD, R12
	mov		#STE2007_RESET, R13
	call	#writeNokiaByte

	mov		#NOKIA_CMD, R12
	mov		#STE2007_DISPLAYALLPOINTSOFF, R13
	call	#writeNokiaByte

	mov		#NOKIA_CMD, R12
	mov		#STE2007_POWERCONTROL | STE2007_POWERCTRL_ALL_ON, R13
	call	#writeNokiaByte

	mov		#NOKIA_CMD, R12
	mov		#STE2007_DISPLAYNORMAL, R13
	call	#writeNokiaByte

	mov		#NOKIA_CMD, R12
	mov		#STE2007_DISPLAYON, R13
	call	#writeNokiaByte

	pop		R13
	pop		R12

	ret

;-------------------------------------------------------------------------------
;	Name:		init
;	Inputs:		none
;	Outputs:	none
;	Purpose:	Setup the MSP430 to operate the Nokia 1202 Display
;-------------------------------------------------------------------------------
init:
	mov.b	#CALBC1_8MHZ, &BCSCTL1				; Setup fast clock
	mov.b	#CALDCO_8MHZ, &DCOCTL

	bis.w	#TASSEL_1 | MC_2, &TACTL
	bic.w	#TAIFG, &TACTL

	mov.b	#LCD1202_CS_PIN|LCD1202_BACKLIGHT_PIN|LCD1202_SCLK_PIN|LCD1202_MOSI_PIN, &P1OUT
	mov.b	#LCD1202_CS_PIN|LCD1202_BACKLIGHT_PIN|LCD1202_SCLK_PIN|LCD1202_MOSI_PIN, &P1DIR
	mov.b	#LCD1202_RESET_PIN, &P2OUT
	mov.b	#LCD1202_RESET_PIN, &P2DIR
	bis.b	#LCD1202_SCLK_PIN|LCD1202_MOSI_PIN, &P1SEL			; Select Secondary peripheral module function
	bis.b	#LCD1202_SCLK_PIN|LCD1202_MOSI_PIN, &P1SEL2			; by setting P1SEL and P1SEL2 = 1

	bis.b	#UCCKPH|UCMSB|UCMST|UCSYNC, &UCB0CTL0				; 3-pin, 8-bit SPI master
	bis.b	#UCSSEL_2, &UCB0CTL1								; SMCLK
	mov.b	#0x01, &UCB0BR0 									; 1:1
	mov.b	#0x00, &UCB0BR1
	bic.b	#UCSWRST, &UCB0CTL1

	; Buttons on the Nokia 1202
	;	S1		P2.1		Right
	;	S2		P2.2		Left
	;	S3		P2.3		Aux
	;	S4		P2.4		Bottom
	;	S5		P2.5		Up
	;
	;	7 6 5 4 3 2 1 0
	;	0 0 1 1 1 1 1 0		0x3E
	bis.b	#0x3E, &P2REN					; Pullup/Pulldown Resistor Enabled on P2.1 - P2.5
	bis.b	#0x3E, &P2OUT					; Assert output to pull-ups pin P2.1 - P2.5
	bic.b	#0x3E, &P2DIR

	ret

;-------------------------------------------------------------------------------
;	Name:		writeNokiaByte
;	Inputs:		R12 selects between (1) Data or (0) Command string
;				R13 the data or command byte
;	Outputs:	none
;	Purpose:	Write a command or data byte to the display using 9-bit format
;-------------------------------------------------------------------------------
writeNokiaByte:

	push	R12
	push	R13

	bic.b	#LCD1202_CS_PIN, &P1OUT							; LCD1202_SELECT
	bic.b	#LCD1202_SCLK_PIN | LCD1202_MOSI_PIN, &P1SEL	; Enable I/O function by clearing
	bic.b	#LCD1202_SCLK_PIN | LCD1202_MOSI_PIN, &P1SEL2	; LCD1202_DISABLE_HARDWARE_SPI;

	bit.b	#01h, R12
	jeq		cmd

	bis.b	#LCD1202_MOSI_PIN, &P1OUT						; LCD1202_MOSI_LO
	jmp		clock

cmd:
	bic.b	#LCD1202_MOSI_PIN, &P1OUT						; LCD1202_MOSI_HIGH

clock:
	bis.b	#LCD1202_SCLK_PIN, &P1OUT						; LCD1202_CLOCK		positive edge
	nop
	bic.b	#LCD1202_SCLK_PIN, &P1OUT						;					negative edge

	bis.b	#LCD1202_SCLK_PIN | LCD1202_MOSI_PIN, &P1SEL	; LCD1202_ENABLE_HARDWARE_SPI;
	bis.b	#LCD1202_SCLK_PIN | LCD1202_MOSI_PIN, &P1SEL2	;

	mov.b	R13, UCB0TXBUF

pollSPI:
	bit.b	#UCBUSY, &UCB0STAT
	jz		pollSPI											; while (UCB0STAT & UCBUSY);

	bis.b	#LCD1202_CS_PIN, &P1OUT							; LCD1202_DESELECT

	pop		R13
	pop		R12

	ret

;-------------------------------------------------------------------------------
;	Name:		clearDisplay
;	Inputs:		none
;	Outputs:	none
;	Purpose:	Writes 0x360 blank 8-bit columns to the Nokia display
;-------------------------------------------------------------------------------
clearDisplay:
	push	R11
	push	R12
	push	R13

	mov.w	#0x00, R12			; set display address to 0,0
	mov.w	#0x00, R13

	call	#setAddress

	mov.w	#0x01, R12			; write a "clear" set of pixels
	mov.w	#0x00, R13			; to every byt on the display

	mov.w	#0x360, R11			; loop counter
clearLoop:
	call	#writeNokiaByte
	dec.w	R11
	jnz		clearLoop

	;mov.w	#0x00, R12			; set display address to 0,0
	;mov.w	#0x00, R13

		;mov.w	#Y_CENTER, R12
		;mov.w	#X_CENTER, R13

	call	#setAddress

	pop		R13
	pop		R12
	pop		R11

	ret

;-------------------------------------------------------------------------------
;	Name:		setAddress
;	Inputs:		R12		row
;				R13		col
;	Outputs:	none
;	Purpose:	Sets the cursor address on the 9 row x 96 column display
;-------------------------------------------------------------------------------
setAddress:
	push	R12
	push	R13

	; Since there are only 9 rows on the 1202, we can select the row in 4-bits
	mov.w	R12, R13			; Write a command, setup call to
	mov.w	#NOKIA_CMD, R12
	and.w	#0x0F, R13			; mask out any weird upper nibble bits and
	bis.w	#0xB0, R13			; mask in "B0" as the prefix for a page address....sets the row (goes down)
	call	#writeNokiaByte

	; Since there are only 96 columns on the 1202, we need 2 sets of 4-bits
	mov.w	#NOKIA_CMD, R12
	pop		R13					; make a copy of the column address in R13 from the stack
	push	R13
	rra.w	R13					; shift right 4 bits
	rra.w	R13
	rra.w	R13
	rra.w	R13
	and.w	#0x0F, R13			; mask out upper nibble
	bis.w	#0x10, R13			; 10 is the prefix for a upper column address
	call	#writeNokiaByte

	mov.w	#0x00, R2			; Write a command, setup call to
	pop		R13					; make a copy of the top of the stack
	push	R13
	and.w	#0x0F, R13
	call	#writeNokiaByte

	pop		R13
	pop		R12

	ret

;-------------------------------------------------------------------------------
;           System Initialization
;-------------------------------------------------------------------------------
	.global __STACK_END					; BOILERPLATE
	.sect 	.stack						; BOILERPLATE
	.sect   ".reset"                	; BOILERPLATE		MSP430 RESET Vector
	.short  main						; BOILERPLATE

