ECE382_Lab3
===========

## Purpose

## Mega Prelab
#### Nokia1202  LCD BoosterPack v4-5

| Name | Pin # | Type | PxDIR| PxREN | PxOUT |
|:-: | :-: | :-: | :-: | :-: | :-: |
|GND | | | | |  |
| RST |   |   |   |   |   |
| P1.4 |   |   |   |   |   |   
| MOSI|  |   |   |   |   |   
| SCLK |   |   |   |   |   |   
| VCC |   |   |   |   |   |  
| S1 |   |   |   |   |   | 
| S2 |   |   |   |   |   | 
| S3 |   |   |   |   |   | 
| S4 || | | | | 

#### Configure the MSP430
```
mov.b	#LCD1202_CS_PIN|LCD1202_BACKLIGHT_PIN|LCD1202_SCLK_PIN|LCD1202_MOSI_PIN, & A
mov.b	#LCD1202_CS_PIN|LCD1202_BACKLIGHT_PIN|LCD1202_SCLK_PIN|LCD1202_MOSI_PIN, & B
mov.b	#LCD1202_RESET_PIN, & C
mov.b	#LCD1202_RESET_PIN, & D
```
| Mystery Label | Register|
|:-: |:-: |
| A|  |
| B |  |
| C |  |
| D |  |

#### SPI subsystem of the MSP430

```
	bis.b	#UCCKPH|UCMSB|UCMST|UCSYNC, &UCB0CTL0
	bis.b	#UCSSEL_2, &UCB0CTL1
	bic.b	#UCSWRST, &UCB0CTL1
```

| ID | Bit | Function as set in the code |
|:-:|:-:|:-:|
| UCCKPH | | |
| UCMSB | | |
| UCMST | | |
| UCSYNCH| | |
| UCSSEL_2|  | |
| UCSWRST| | |

#### Communicate to the Nokia1202 display
Use the code from the mega prelab to draw a timing diagram of the expected behavior of LCD1202_CS_PIN, LCD1202_SCLK_PIN, LCD1202_MOSI_PINs from the begining of this subroutine to the end.

[INSERT TIMING DIAGRAM)

#### Configure the Nokia1202 display

| Symbolic Constant | Hex | Function |
| :-: | :-: | :-: |
|#STE2007_RESET| | |
|#STE2007_DISPLAYALLPOINTSOFF| | |
|#STE2007_POWERCONTROL| | | 
|#STE2007_POWERCTRL_ALL_ON | | |
|#STE2007_DISPLAYNORMAL | | |
|#STE2007_DISPLAYON | | |


