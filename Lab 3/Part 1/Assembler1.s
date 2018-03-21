 // Assembler1.s
 //
 // Created: 1/30/2018 4:15:16 AM
 // Author : Jacob Taylor Cassady
 // Copyright 2018, All Rights Reserved


.section ".data"					//Creates a name 'data' for the following code
/*
*	The .equ directive assins a value to a label.  The following lables describe
*	important offsets for registers.  The register's full name is commented next
*	to each equate directive.  Registers with an * have their offset reduced by
*	0x20 since OUT command is used
*/
/* Port Labels */
.equ	DDRB,0x04					//Port B Data Direction Register*
.equ	PORTB,0x05					//Port B Data Register*
.equ	DDRD,0x0A					//Port D Data Direction Register*
.equ	PORTD,0x0B					//Port D Data Register*

/* USART Labels */
.equ	U2X0,1						//Bit 1 of USART Control and Status Register A
									//"Double the USART Transmission Speed"
.equ	UBRR0L,0xC4					//USART Baud Rate 0 Register Low
.equ	UBRR0H,0xC5					//USART Baud Rate 0 Register High
.equ	UCSR0A,0xC0					//USART Control and Status Register 0 A
.equ	UCSR0B,0xC1					//USART Control and Status Register 0 B
.equ	UCSR0C,0xC2					//USART Control and Status Register 0 C
.equ	UDR0,0xC6					//USART I/O Data Register 0
.equ	RXC0,0x07					//Bit 7 of USART Control and Status Register 0 A
									//'USART Recieve Complete'
.equ	UDRE0,0x05					//Bit 5 of USART Control and Status Register 0 A
									//'USART Data Register Empty'

/* ADC Labels */
.equ	ADCSRA,0x7A					//ADC Control & Status Register A
.equ	ADMUX,0x7C					//ADC Multiplexer Selection Register
.equ	ADCSRB,0x7B					//ADC Control & Status Register B
.equ	DIDR0,0x7E					//Digital Input Disable Register 0
.equ	DIDR1,0x7F					//Digital Input Disable Register 1
.equ	ADSC,6						//Bit 6 of ADC Control and Status Register A
									//'ADC Start Conversion'
.equ	ADIF,4						//Bit 4 of ADC Control and Status Register A
									//'ADC Interrut Flag'
.equ	ADCL,0x78					//ADC Digital Register Low
.equ	ADCH,0x79					//ADC Digital Register High

/* EEPROM Labels */
.equ	EECR,0x1F					//EEPROM Control Register*
.equ	EEDR,0x20					//EEPROM Data Register*
.equ	EEARL,0x21					//EEPROM Address Register Low*
									//EEAR0-7
.equ	EEARH,0x22					//EEPROM Address Register High*
									//EEAR8-9
.equ	EERE,0						//Bit 0 of EEPROM Control Register
									//'EEPROM Read Enable'
.equ	EEPE,1						//Bit 1 of EEPROM Control Register
									//'EEPROM Write Enable'
.equ	EEMPE,2						//'EEPROM Master Write Enable' - Determines whether writing EEE to '1' causes EEPROM to be written.
.equ	EERIE,3						//Bit 3 of EEPROM Control Register
									//'EEPROM Ready Interrupt Enable'

/* Global variables are shared between C and Assembler */
.global HADC				//High value for ADC
.global LADC				//Low value for ADC
.global ASCII				//variable for UART communication
.global DATA				//variable for LCD string
.global EEPROM_AddressH
.global EEPROM_AddressL
.global EEPROM_Data

.set	temp,0				//Sets a dyanmic value of 0 to the label temp

.section ".text"			//Creates a name 'text' for the following code

/* Initializes ATmega328P microprocessor
GLOBAL FUNCTION -- shared between C and assembler */
.global Mega328P_Init
Mega328P_Init:
		/* * * * * * * * * * * * * * * * * * * * * * * * * * * *
		* initialize PORTB
		* * * * * * * * * * * * * * * * * * * * * * * * * * * */
		ldi	r16,0x07		;PB0(R*W),PB1(RS),PB2(E) as fixed outputs
		out	DDRB,r16		//Writes the value of register 16 (7) to Port B Direction register
							//This sets Ports 0, 1, & 2 as fixed outputs.
		ldi	r16,0			//Loads a value of 0 into data register 16
		out	PORTB,r16		//Writes the value of register 16 (0) to Port B for initialization.

		/* * * * * * * * * * * * * * * * * * * * * * * * * * * *
		* initialize UART, 8bits, no parity, 1 stop, 9600
		* * * * * * * * * * * * * * * * * * * * * * * * * * * */
		/* initialize USART Control and Status Register 0 A */
		; U2X0 - Bit 1 - Double the USART Transmission speed
		; Set to 0 to ensure the baud rate divider is 16
		out	U2X0,r16		//Writing 0 to bit 1 of USART Control and Status Register 0 A b to set baud rate.
							
		/* initialize USART Baud Rate 0 Register */
		; UBRR0H - four most significant bits
		; UBRR0L - eight least significant bits
		; Set baud rate to 9600
		ldi	r17,0x0			//Loads a value of 0 into data register 17
		ldi	r16,0x67		//Loads a value of 103 into data register 16
		sts	UBRR0H,r17		//Stores the value of register 17 (0) into data space USART Baud Rate 0 Register High
							//These are the four most significant bits of UBRR0
		sts	UBRR0L,r16		//Stores the value of register 17 (103) into data space USART Baud Rate 0 Register Low

		/* initialize USART Control and Status Register 0 B */
		; Set bits 3 (Transmitter Enable 0) and 4 (Receiver Enable 0) to 1.
		ldi	r16,24			//Loads decimal value 24 into register 16
		sts	UCSR0B,r16		//Stores the value of register 16 (24) into data space USART Control and Status Register 0 B

		/* initialize USART Control and Status Register 0 C */
		; Set bits 1 and 2 to put USART mode to 8-bit and set clock phase.
		; Set bit 3 to 0 for a 1-bit stop
		; Set bits 4 and 5 to 0 to disable USART parity mode.
		ldi	r16,6			//Loads decimal value 6 into register 6
		sts	UCSR0C,r16		//Stores the value of register 16 (6) into data space USART Control and Status Register 0 C

		/* * * * * * * * * * * * * * * * * * * * * * * * * * * *
		* initialize ADC
		* * * * * * * * * * * * * * * * * * * * * * * * * * * */
		/* initialize ADC Control and Status Register A */
		; Sets bits 0, 1, 2, and 7 to 1.
		; Setting bits 0:2 to 0 set the division factor between the system clock fequency and the input clock to 128
		; Setting bit 7 to 0 enables the Analog to Digital Converter.
		ldi r16,0x87		
		sts	ADCSRA,r16		//student comment here

		/* initialize ADC Multilexer Selection Register */
		; Sets bit 7 to 1
		ldi r16,0x40		//student comment here
		sts ADMUX,r16		//student comment here

		/* initialize ADC Control and Status Register B */
		; Setting ADCSRB to 0 puts the trigger source in free running mode.
		ldi r16,0			//student comment here
		sts ADCSRB,r16		//student comment here

		/* initialize Digital Input Disable Register 0 */
		; This disables all of the digital input buffers on ADC pins. Discounting pin ADC0D
		ldi r16,0xFE		//Loads a binary value of 1111110 into register 16.
		sts DIDR0,r16		//Stores the value from register 16 (254) into data space DIDR0.

		/* initialize Digital Input Disable Register 1 */
		; Setting bit to 1 reduces power consumption of the digital input buffer.
		ldi r16,0xFF		//Loads a binary value of 1111111 into register 16.
		sts DIDR1,r16		//Stores the value from register 16 (255) into data space DIDR1.
		
		ret					//Done initializing. Return.
	
.global LCD_Write_Command
LCD_Write_Command:
	call	UART_Off		//student comment here
	ldi		r16,0xFF		;PD0 - PD7 as outputs
	out		DDRD,r16		//student comment here
	lds		r16,DATA		//student comment here
	out		PORTD,r16		//student comment here
	ldi		r16,4			//student comment here
	out		PORTB,r16		//student comment here
	call	LCD_Delay		//student comment here
	ldi		r16,0			//student comment here
	out		PORTB,r16		//student comment here
	call	LCD_Delay		//student comment here
	call	UART_On			//student comment here
	ret						//student comment here

LCD_Delay:
	ldi		r16,0xFA		//student comment here
D0:	ldi		r17,0xFF		//student comment here
D1:	dec		r17				//student comment here
	brne	D1				//student comment here
	dec		r16				//student comment here
	brne	D0				//student comment here
	ret						//student comment here

.global LCD_Write_Data
LCD_Write_Data:
	call	UART_Off		//student comment here
	ldi		r16,0xFF		//student comment here
	out		DDRD,r16		//student comment here
	lds		r16,DATA		//student comment here
	out		PORTD,r16		//student comment here
	ldi		r16,6			//student comment here
	out		PORTB,r16		//student comment here
	call	LCD_Delay		//student comment here
	ldi		r16,0			//student comment here
	out		PORTB,r16		//student comment here
	call	LCD_Delay		//student comment here
	call	UART_On			//student comment here
	ret						//student comment here

.global LCD_Read_Data
LCD_Read_Data:
	call	UART_Off		//student comment here
	ldi		r16,0x00		//student comment here
	out		DDRD,r16		//student comment here
	out		PORTB,4			//student comment here
	in		r16,PORTD		//student comment here
	sts		DATA,r16		//student comment here
	out		PORTB,0			//student comment here
	call	UART_On			//student comment here
	ret						//student comment here

.global UART_On
UART_On:
	ldi		r16,2				//Loads value of 2 into register 16
	out		DDRD,r16			//Sets Port D Data Direction Register bit 1
	ldi		r16,24				//Loads binary value of 11000 into register 16
	sts		UCSR0B,r16			//Sets UART Control Status Register 0 B to on with the following bits
								// Bit 3 - Transmitter Enable
								// Bit 4 - Reciver Enable 
	ret							//Return 

.global UART_Off
UART_Off:
	ldi	r16,0					//Loads value of 0 into register 16
	sts UCSR0B,r16				//Sets UART Control Status Register 0 B to off
	ret							//Returns

.global UART_Clear
UART_Clear:
	lds		r16,UCSR0A			//Loads value from data space location UART Control and Status Register 0 A
	sbrs	r16,RXC0			//Skips next line if USART Recieve Complete bit is set
	ret							//returns
	lds		r16,UDR0			//Loads register 16 with the contents of USART Data Register (RXB)
	rjmp	UART_Clear			//Returns to UART_Clear label

.global UART_Get
UART_Get:
	lds		r16,UCSR0A			//Loads register 16 with the contents of USART Control and Status Register 0 A.
	sbrs	r16,RXC0			//Skips if USART Receive Complete flag (bit 7) is set (1).
	rjmp	UART_Get			//Executed if RXC0 is not set.  Jumps back to check for more data.
	lds		r16,UDR0			//Loads register 16 with the contents of USART Data Register (RXB)
	sts		ASCII,r16			//Stores contents of register 16 into ASCII global variable (shared between C and Assembly)
	ret							//Returns

.global UART_Put
UART_Put:
	lds		r17,UCSR0A			//Loads register 17 with the contents of USART Control and Status Register 0 A.
	sbrs	r17,UDRE0			//Skips if USART Data Register Empty flag (bit 5) is set (1).
	rjmp	UART_Put			//Executed if UDRE0 is not set.  Jumps back to check for more data.
	lds		r16,ASCII			//Loads register 16 with the contents of ASCII global variable (shared between C and Assembly)
	sts		UDR0,r16			//Stores contents of register 16 into USART Data Register (TXB)
	ret							//Returns

.global ADC_Get
ADC_Get:
		ldi		r16,0xC7			//student comment here
		sts		ADCSRA,r16			//student comment here
A2V1:	lds		r16,ADCSRA			//student comment here
		sbrc	r16,ADSC			//student comment here
		rjmp 	A2V1				//student comment here
		lds		r16,ADCL			//student comment here
		sts		LADC,r16			//student comment here
		lds		r16,ADCH			//student comment here
		sts		HADC,r16			//student comment here
		ret							//student comment here

.global EEPROM_Write
EEPROM_Write:      
		sbic    EECR,EEPE			; Skip next line if EEPROM Write Enable is 0
		rjmp    EEPROM_Write		; Wait for completion of previous write
		; Set up address (r18:r17) in address register
		lds		r18,EEPROM_AddressH	; Load 0 into data register 18
		lds		r17,EEPROM_AddressL	; Load 5 into data register 17
		lds		r16,EEPROM_Data		; Load 'F' into data register 16
		out     EEARH, r18			; Loads register 18's value (0) into EEPROM Address Register High
		out     EEARL, r17			; Loads register 17's value (5) into EEPROM Address Register Low
		out     EEDR,r16			; Write data (r16) to Data Register  
		sbi     EECR,EEMPE			; Write logical one to EEMPE
		sbi     EECR,EEPE			; Start eeprom write by setting EEPE
		ret 

.global EEPROM_Read
EEPROM_Read:					    
		sbic    EECR,EEPE    
		rjmp    EEPROM_Read			; Wait for completion of previous write
		lds		r18,EEPROM_AddressH	; Set up address (r18:r17) in EEPROM address register
		lds		r17,EEPROM_AddressL
		ldi		r16,0x00   
		out     EEARH, r18   
		out     EEARL, r17		   
		sbi     EECR,EERE			; Start eeprom read by writing EERE
		in      r16,EEDR			; Read data from Data Register
		sts		ASCII,r16  
		ret


		.end
