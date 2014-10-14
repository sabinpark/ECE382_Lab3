ECE382_Lab3
===========

## Mega Prelab
#### Nokia1202  LCD BoosterPack v4-5
*Referenced the Nokia 1202 LCD Boosterpack:* http://ece382.com/datasheets/Nokia_1202_LCD_BoosterPack_v4-5.pdf

*For PxDIR, PxREN, and PxOUT; from the MSP430x2xx Family Users Guide:* http://ece382.com/datasheets/msp430_msp430x2xx_family_users_guide.pdf (pgs 328-329)

| Name | Pin # | Type | PxDIR| PxREN | PxOUT |
|:-: | :-: | :-: | :-: | :-: | :-: |
| GND | 20 | Power | X | X | X  |
| RST | 8 | Output | 1 | 0 | 0 |
| P1.4 | 6 | Output | 1 | 0 | 0 |   
| MOSI| 15 | Output | 1 | 0 | 0 |   
| SCLK | 7 | Output | 1 | 0 | 0 |   
| VCC | 1 | Power | X | X | X |  
| S1 | 9 | Input | 0 | 0 | X | 
| S2 | 10 | Input | 0 | 0 | X | 
| S3 | 11 | Input | 0 | 0 | X | 
| S4 | 12 | Input | 0 | 0 | X | 

#### Configure the MSP430
```
	mov.b	#LCD1202_CS_PIN|LCD1202_BACKLIGHT_PIN|LCD1202_SCLK_PIN|LCD1202_MOSI_PIN, & A
	mov.b	#LCD1202_CS_PIN|LCD1202_BACKLIGHT_PIN|LCD1202_SCLK_PIN|LCD1202_MOSI_PIN, & B
	mov.b	#LCD1202_RESET_PIN, & C
	mov.b	#LCD1202_RESET_PIN, & D
```
| Mystery Label | Register|
|:-: |:-: |
| A| P1DIR |
| B | P1OUT |
| C | P2DIR |
| D | P2OUT |

#### SPI subsystem of the MSP430

*Referenced the MSP430x2xx Family Users Guide:* http://ece382.com/datasheets/msp430_msp430x2xx_family_users_guide.pdf (pg 445)

```
	bis.b	#UCCKPH|UCMSB|UCMST|UCSYNC, &UCB0CTL0
	bis.b	#UCSSEL_2, &UCB0CTL1
	bic.b	#UCSWRST, &UCB0CTL1
```

| ID | Bit  | Function as set in the code |
|:-:|:-:|:-:|
| UCCKPH | 7 | Data is captured on the first UCLK edge and changed on the following edge |
| UCMSB | 5 | MSB set first |
| UCMST | 3 | Master mode |
| UCSYNCH | 0 | Synchronous mode enabled |
| UCSSEL_2 | 7-6 | Using the SMCLK |
| UCSWRST| 0 | Software reset disabled; USCI reset released for operation |

#### Communicate to the Nokia1202 display
Use the code from the mega prelab to draw a timing diagram of the expected behavior of LCD1202_CS_PIN, LCD1202_SCLK_PIN, LCD1202_MOSI_PINs from the begining of this subroutine to the end.

![alt test](https://github.com/sabinpark/ECE382_Lab3/blob/master/images/timing_diagram.jpg "Mega Pre Lab Timing Diagram")

#### Configure the Nokia1202 display
*Referenced the STE2007 datasheet:* http://ece382.com/datasheets/ste2007.pdf (pgs 41-51)

| Symbolic Constant | Hex | Function |
| :-: | :-: | :-: | :-: |
|#STE2007_RESET| E2 | internal reset; command identifier |
|#STE2007_DISPLAYALLPOINTSOFF| A4 | normal display mode; LCD display |
|#STE2007_POWERCONTROL| 28 | sets the on–chip power supply circuit operating mode |
|#STE2007_POWERCTRL_ALL_ON | 07 | booster: on, voltage regulation: on, voltage follower: on |
|#STE2007_DISPLAYNORMAL | A6 | LCD display; normal:DDRAM data "H"=LCD ON voltage |
|#STE2007_DISPLAYON | AF | LCD display on |


## Lab
### Physical Communication
#### Four Calls to *writeNokiaByte*
| Line | R12 | R13 | Purpose |
|:-:|:-:|:-:|:-:|
| 66 | NOKIA_DATA | 0xE7 (1110 0111) | sets the 8 pixel high pattern |
| 276 | NOKIA_CMD | 0xB0 (1011 0000) | sets the rows |
| 288 | NOKIA_CMD | 0x10 (0001 0000) | sets the column address ("upper 3 bits") |
| 294 | NOKIA_CMD | mask upper bits (0000 1111) | sets the column address ("lower 4 bits") |

#### SW3 Waveform Analysis

| Line | Command/Data | 8-bit Packet |
|:-:|:-:|:-:|
| 66 | data | E7 |
| 276 | command | B5 |
| 288 | command | 10 |
| 294 | command | 05 |

##### Waveforms
*Line 66*
![alt test](https://github.com/sabinpark/ECE382_Lab3/blob/master/images/Waveform_1.jpg "Waveform 1")

*Line 276*
![alt test](https://github.com/sabinpark/ECE382_Lab3/blob/master/images/Waveform_2.jpg "Waveform 2")

*Line 288*
![alt test](https://github.com/sabinpark/ECE382_Lab3/blob/master/images/Waveform_3.jpg "Waveform 3")

*Line 294*
![alt test](https://github.com/sabinpark/ECE382_Lab3/blob/master/images/Waveform_4.jpg "Waveform 4")



##### Reset

Using the built-in cursors, I found the RESET line to last 6.954 microseconds. 

![alt test](https://github.com/sabinpark/ECE382_Lab3/blob/master/images/Waveform_reset.jpg "Reset Waveform")

From lines 93-98 of the original lab3.asm file, I found that the counter starts at 0xFFFF, which is equivalent to 65,535 (decimal) iterations.

```
; This loop creates a nice delay for the reset low pulse
	bic.b	#LCD1202_RESET_PIN, &P2OUT
	mov		#0FFFFh, R12
delayNokiaResetLow:
	dec		R12
	jne		delayNokiaResetLow
```

By dividing the number of iterations from the length of the signal, I found that each iteration lasts *10.611 ns*.

### Writing Modes

These pixel map operations are self-explanatory. Reminder: white = 0, black = 1.

![alt test](https://github.com/sabinpark/ECE382_Lab3/blob/master/images/pixel_operations.png "Pixel Operations")

### Functionality
#### Required Functionality
This was pretty simple. All I did in the beginning was create a counter register (R8) and made the bar 8 times, with each consecutive bar shifted to the right by 1 pixel.

```
draw:
	mov		#NOKIA_DATA, R12	; stores data into R12
	mov		#0xFF, R13			; draw an 8 pixel high solid bar (1x8 pixels)

	call	#writeNokiaByte		; draws the pixels

	dec		R8					; decrement the counter
	jnz		draw				; keep drawing until we finish all 8 bars
```

#### A Functionality
To get A functionality, I had to revise the code to make sure the program knew which bit of P2IN was being set. I made R9 the temporary holder for the P2IN bit. From there, I used a switch-case structure to check each switch. Depending on which switch was pressed (and released), the program moved up, down, left, or right. 

Here's a simple table that shows which bit corresponds with which switch:

| Switch | bit of P2IN | direction |
|:-:|:-:|:-:|
| SW1 | bit 2 | right |
| SW2 | bit 4 | left |
| SW3 | bit 8 | - |
| SW4 | bit 16 | down |
| SW5 | bit 32 | up |

I also added a bit of code to ensure that the box does not go off of the edge of the screen. 

Here's an example of what I did to make sure the box did not go too high off the screen:
```
	dec		R10					; move the box up
	cmp		#Y_MIN, R10
	; if R10 >= 0, then leave it be and jump to pressed
	jge		pressed
	; else if R10 < 0, then set Y MIN
setYMIN:
	mov		#Y_MIN, R10			; keep the box at the top of the screen
	jmp		pressed				; go to pressed
```

After moving the box up (decrementing), if the new Y value was greater than or equal to 0, then the box would remain where it is at. Otherwise, it would mean the box is below the value of 0 (meaning that the box is above the screen), and set the box's Y value to 0. The same idea was used for DOWN, LEFT, and RIGHT. 

## Documentation

#### Mega Prelab
I referenced the following manuals to answer the mega prelab questions:
* General - MSP430x2xx Family Users Guide
* Nokia 1202 LCD Boosterpack
* STE2007

I worked with the following cadets by discussing the lab 3 mega prelab questions. We worked through each problem by helping each other find the necessary information to answer the questions (ie, pointing out which manual to look at, etc). 

List of cadets I worked with:
* C2C Ruprecht
* C2C Thompson
* C2C Bolinger
* C2C Jonas
* C2C Cabusora
* C2C Bodin
* C2C Wooden
* C2C Bapty
* C2C Lewandowsky
* C2C Kiernan
* C2C Terragnoli
* C2C Her
* C2C Borusas

Dr. Coulston referred me to the lab3.asm file and showed me that I should separate the bits for the power control set (the last three bits for POWERCTRL_ALL_ON)

#### Lab
C2C Bolinger verified that my connections were correct and explained how to use the logic analyzer.
