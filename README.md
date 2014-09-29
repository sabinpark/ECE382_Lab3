ECE382_Lab3
===========

## Purpose

## Mega Prelab
#### Nokia1202  LCD BoosterPack v4-5
*Referenced the Nokia 1202 LCD Boosterpack:* http://ece382.com/datasheets/Nokia_1202_LCD_BoosterPack_v4-5.pdf
*For PxDIR, PxREN, and PxOUT; from the MSP430x2xx Family Users Guide:* http://ece382.com/datasheets/msp430_msp430x2xx_family_users_guide.pdf (pgs 328-329)

| Name | Pin # | Type | PxDIR| PxREN | PxOUT |
|:-: | :-: | :-: | :-: | :-: | :-: |
|GND | 20 | Power | - | - | -  |
| RST | 8 | Output | 1 | 0 | 1 |
| P1.4 | 6 | Output | 1 | 0 | 1 |   
| MOSI| 15 | Output | 1 | 0 | 1 |   
| SCLK | 7 | Output | 1 | 0 | 1 |   
| VCC | 1 | Power | - | - | - |  
| S1 | 9 | Input | 0 | 1 | 1 | 
| S2 | 10 | Input | 0 | 1 | 1 | 
| S3 | 11 | Input | 0 | 1 | 1 | 
| S4 | 12 | Input | 0 | 1 | 1 | 

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

| ID | Bit | Function as set in the code |
|:-:|:-:|:-:|
| UCCKPH | 7 | clock phase select; 0: data is changed on the first UCLK edge and captured on the following edge, 1: opposite of 0 |
| UCMSB | 5 | MSB first selesct; controls the direction of the receive and transmit shift register; 0 (LSB first), 1 (MSB first) |
| UCMST | 3 | master mode select: 0 (slave), 1 (master) |
| UCSYNCH| 0 | synchronous mode enable; 0 (asynchronous), 1 (synchronous) |
| UCSSEL_2| 7-6 | USCI clock source select; these bits select the BRCLK source clock in master mode; UCxCLK is always used in slave mode; 00 (NA), 01 (ACLK), 10 (SMCLK), 11 (SMCLK) |
| UCSWRST| 0 | software reset enable; 0 (disabled, USCI reset released for operation), 1 (enabled, USCI logic held in reset state) |

#### Communicate to the Nokia1202 display
Use the code from the mega prelab to draw a timing diagram of the expected behavior of LCD1202_CS_PIN, LCD1202_SCLK_PIN, LCD1202_MOSI_PINs from the begining of this subroutine to the end.

[INSERT TIMING DIAGRAM)

#### Configure the Nokia1202 display
*Referenced the STE2007 datasheet:* http://ece382.com/datasheets/ste2007.pdf (pgs 41-51)

| Symbolic Constant | Hex | Function |
| :-: | :-: | :-: | :-: |
|#STE2007_RESET| E2 | internal reset; command identifier |
|#STE2007_DISPLAYALLPOINTSOFF| A4 | normal display mode; LCD display |
|#STE2007_POWERCONTROL| - | sets the on–chip power supply circuit operating mode |
|#STE2007_POWERCTRL_ALL_ON | 2F | booster: on, voltage regulation: on, voltage follower: on |
|#STE2007_DISPLAYNORMAL | A6 | LCD display; normal:DDRAM data "H"=LCD ON voltage |
|#STE2007_DISPLAYON | AF | LCD display on |


## Documentation

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
