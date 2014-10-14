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

| Line | R12 | R13 | Purpose |
|:-:|:-:|:-:|:-:|
| 66 | NOKIA_DATA | 0xE7 (1110 0111) | stores the 8 pixel bar into R12; stores the 2 pixel hole in R13 |
| 276 | NOKIA_CMD | 0xB0 (1011 0000) | sets the rows to 8 pixels down |
| 288 | NOKIA_CMD | 0x10 (0001 0000) | ---- |
| 294 | NOKIA_CMD | mask upper bits (0000 1111) | resets the row |

| Line | Command/Data | 8-bit Packet |
|:-:|:-:|:-:|
| 66 | data | E7 |
| 276 | command | B6 |
| 288 | command | 10 |
| 294 | command | 06 |

RESET
-6.964281 us - (-7.766734 us)

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
None
