 ; Lab4
 ;
 ; Created: 3/24/2018 4:15:16 AM
 ; Author : Eugene Rockey

		 .org 0				;student discuss interrupts and vector table in report
		 jmp RESET			;student discuss reset in report
		 jmp INT0_H			;student discuss reset in report
		 jmp INT1_H			;student discuss reset in report
		 jmp PCINT0_H			;student discuss reset in report
		 jmp PCINT1_H			;student discuss reset in report
		 jmp PCINT2_H			;student discuss reset in report
		 jmp WDT			;student discuss reset in report
		 jmp TIM2_COMPA			;student discuss reset in report
		 jmp TIM2_COMPB			;student discuss reset in report
		 jmp TIM2_OVF			;student discuss reset in report
		 jmp TIM1_CAPT			;student discuss reset in report
		 jmp TIM1_COMPA			;student discuss reset in report
		 jmp TIM1_COMPB			;student discuss reset in report
		 jmp TIM1_OVF			;student discuss reset in report
		 jmp TIM0_COMPA			;student discuss reset in report
		 jmp TIM0_COMPB			;student discuss reset in report
		 jmp TIM0_OVF			;student discuss reset in report
		 jmp SPI_TC			;student discuss reset in report
		 jmp USART_RXC			;student discuss reset in report
		 jmp USART_UDRE			;student discuss reset in report
		 jmp USART_TXC			;student discuss reset in report
		 jmp ADCC			;student discuss reset in report
		 jmp EE_READY			;student discuss reset in report
		 jmp ANA_COMP			;student discuss reset in report
		 jmp TWI			;student discuss reset in report
		 jmp SPM_READY			;student discuss reset in report



RESET:	;Initialize the ATMega328P chip for the THIS embedded application.
		;initialize PORTB for Output
		cli
		ldi	r16,0xFF		;PB1 or OC1A Output
		out	DDRB,r16		;PORTB pins set to output

;initialize and start Timer A, compare match, interrupt enabled

		;TCCR1A : Page 170 ATmega328P Sheet
		;TC1 Control Register 1 A
		;Bits 4:5,6:7 - COM1B/COM1A respectively : Compare output mode for channel
		;COM1A & COM1B control output compare pins
		;Can be set to non-PWM or fast PWM mode
		ldi	r16,0xC0		;set OC to compare match set output to high level
		sts 	TCCR1A,r16		;Stores a binary value of 1100 0000
						; This sets OC1A on Compare Match (non-PWM) (Set output to high level)

		;TCCR1B : Page 173 ATmega328P Sheet
		;TC1 Control Register 1 B
		;Bit 7 - ICNC1  : Input Capture Noise Canceller
		;Bit 6 - ICES1  : Input Capture Edge Select
		;Set to 0 for falling edge trigger, 1 for positive edge.
		;Bit 5 - N/A
		;Bit 3,4 - WGM1 : Waveform generation mode, connects with TCCR1A
			/* These bits control the counting sequence of the counter, the source for maximum (TOP)
			*	counter value, and what type of waveform generation to be used.
			*	They are combined witht he first 2 bits of TCCR1A which were set to 0 above.
			*	This is the key to changing PWM modes.  Please see page 171 Atmega328P sheet
			*/
		;Bit 2:0 - CS1  : Three clock select bits, select clock source to be used.
		;set clock prescaler
		ldi 	r16,0x04		; Load register 16 with a binary value of 0000 0100
		sts 	TCCR1B,r16		; This sets the clock source to clkI/O/256


		;TCCR1C : Page 175 ATmega328P Sheet
		;TC1 Control Register 1 C
		;Bits 6,7 - FOC1 : Force output compare for channel B & A
		;Only active when WGM1 bits specificies non-PWM mode
		;force output compare, set PB1 high
		ldi 	r16,0x80		; Loads a binary value of 1000 0000 into register 16
		sts 	TCCR1C,r16		; forces compare on Waveform Generation unit
						; varies depending on COM1x[1:0] bit settings

		ldi 	r16,0x40		; Loads a binary value of 0100 0000 into register 16
		sts 	TCCR1A,r16		; This sets Compare Output Mode to "Toggle OC1A on Compare Match"

		ldi	r18,0x0B		; Loads a binary value of 0000 1011 (decimal 11) into register 18
		ldi 	r17,0xB8		; Loads a binary value of 1011 1000 (decimal 184) into register 17

		; Timer/Counter Value : Page 176-177 ATmega328P
		/* Note: The Time/Counter I/O locations give direct access, both for read and write operations, to the Timer/Counter unit
		*	16 bit counter. Modifying the counter while the counter is running introduces a risk of missing a compare match between
		*	TCNT1 and one of the OCR1x Registers. Writing to the TCNT1 register blocks the compare match on the following timer clock
		*	for all compare units. (page 176 Atmega328P sheet)
		*/
		lds 	r16,TCNT1L		; Loads register 16 with the current value in TCNT1L (Timer/Counter 1 Counter Value Low Byte)
		add 	r17,r16			; Register 17 = register 17 (decimal 184) + register 16 (TCNT1L)
		lds 	r16,TCNT1H		; Loads register 16 with the current value in TCNT1H (Timer/Counter 1 Counter Value High Byte)
		adc 	r18,r16			; Register 18 = register 18 (decimal 11) + register 16 (TCNT1H)

		; OCR1A : Page 180-181 ATmega328P sheet
		/* Note: The counter reaches the TOP when it becomes equal to the highest value in the count sequence.
		*	The TOP value can be assigned to be the fixed MAX value or the value stored in the OCR1A Register.
		*	The assignment is dependant on the mode of operation. 
		*/
		;continuously compared w/ counter value
		;Match can either generate an interrupt or waveform output on OC1A pin
		;In this setup, it is acting as an interrupt
		sts 	OCR1AH,r18		; Stores the value in register 18 (11 + TCNT1H) in Output Compare Register 1 A High
		sts 	OCR1AL,r17		; Stores the value in register 17 (184 + TCNT1L) in Output Compare Register 1 A Low

		ldi 	r19,0			; Loads register 19 with a binary value of 0000 0000
						; This forces the programs control flow to skip the ONE label on the first pass.
		ldi 	r16,0x02		; Loads regitser 16 with a binary value of 0000 0010
		sts 	TIMSK1,r16		; Stores the value of register 16 (0000 0010) into the Timer Interrupt Mask Register
						; This globally enables interrupts and the Timer/Counter Output Control A Match
						; The corresponding Interrupt Vector is executed when the OCFA Flag, located in TIFR1, is set.
		out 	TIFR1,r16		; Stores the value of register 16 (0000 0010) into the Timer/Counter Interrupt Flag Register.
		sei				; Sets global interrupt flag
here:	rjmp here
		
INT0_H:
		nop			;external interrupt 0 handler
		reti
INT1_H:
		nop			;external interrupt 1 handler
		reti
PCINT0_H:
		nop			;pin change interrupt 0 handler
		reti
PCINT1_H:
		nop			;pin change interrupt 1 handler
		reti
PCINT2_H:
		nop			;pin change interrupt 2 handler
		reti
WDT:
		nop			;watch dog time out handler
		reti
TIM2_COMPA:
		nop			;TC 2 compare match A handler
		reti
TIM2_COMPB:
		nop			;TC 2 compare match B handler
		reti
TIM2_OVF:
		nop			;TC 2 overflow handler
		reti
TIM1_CAPT:
		nop			;TC 1 capture event handler
		reti
TIM1_COMPA:				;Timer/Counter 1 compare match A handler
		sbrc	r19,0			;Skip if bit 0 in register 19 is cleared.
		rjmp	ONE			/* ONE - LABEL DESCRIPTION
							* This label loads the following values:
							* register 17 <- 1110 1000
							* register 18 <- 0000 1011
							* register 19 <- 0000 0000
						*/
		ldi	r17,0xE8		;
		ldi	r18,0x0B		; else -- same values are loaded in besides:
		ldi	r19,1			; register 19 <- 0000 0001
		rjmp	BEGIN			/* BEGIN - LABEL DESCRIPTION
						*	* Note: The counter reaches the TOP when it becomes equal to the highest value in the count sequence.
						*	* The TOP value can be assigned to be the fixed MAX value or the value stored in the OCR1A Register.
						*	* The assignment is dependant on the mode of operation.
						* This label loads the registers with OCR1A H and Low values
						* OCR1A - Output Compare 1 A Register (16 bits)
						* OCR1AL - Low 8 bits
						*	OC1AL receives a value of 1110 1000 (232)
						* OCR1AH - High 8 bits
						*	OC1AH receives a value of 0000 1011 (11)
						* This gives us a 16-bit value of 
						*/
ONE:		ldi	r17,0xE8		; REFER TO RJMP FOR INFO
		ldi	r18,0x0B		; 
		ldi	r19,0			;
BEGIN:		lds	r16,OCR1AL		; Loads data stored in Output Compare Register 1 A L (Least significant 8-bits)
		add	r17,r16			; register 17 += register 16 (OCR1AL)
		lds	r16,OCR1AH		; Loads data stored in Output Compare Register 1 A H (Most significant 8-bits)
		adc	r18,r16			; register 18 += register 16 (OCR1AH)
		sts	OCR1AH,r18		; Store register 18's data back into Output Compare Register 1 A H
		sts	OCR1AL,r17		; Store register 17's data back into Output Compare Register 1 A L
		reti				; Return from interrupt

TIM1_COMPB:
		nop			;TC 1 compare match B handler
		reti
TIM1_OVF:
		nop			;TC 1 overflow handler
		reti
TIM0_COMPA:
		nop			;TC 0 compare match A handler
		reti
TIM0_COMPB:			
		nop			;TC 1 compare match B handler
		reti
TIM0_OVF:
		nop			;TC 0 overflow handler
		reti
SPI_TC:
		nop			;SPI Transfer Complete
		reti
USART_RXC:
		nop			;USART receive complete
		reti
USART_UDRE:
		nop			;USART data register empty
		reti
USART_TXC:
		nop			;USART transmit complete
		reti
ADCC:
		nop			;ADC conversion complete
		reti
EE_READY:
		nop			;EEPROM ready
		reti
ANA_COMP:
		nop			;Analog Comparison complete 
		reti
TWI:
		nop			;I2C interrupt handler
		reti
SPM_READY:
		nop			;store program memory ready handler
		reti		

