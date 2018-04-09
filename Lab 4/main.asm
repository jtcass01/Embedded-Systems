;
; BreathingLCD.asm
;
; Created: 4/5/2018 10:27:34 PM
; Author : JakeT
;

		.org 0					;student discuss interrupts and vector table in report
		jmp RESET				;student discuss reset in report
		jmp TIM1_COMPA

RESET:	;Initialize the ATMega328P chip for the THIS embedded application.
		;initialize PORTB for Output
		cli
		ldi	r16,0xFF				;PB1 or OC1A Output
		out	DDRB,r16				;PORTB pins set to output

;initialize and start Timer A, compare match, interrupt enabled

		;TCCR1A : Page 170 ATmega328P Sheet
		;TC1 Control Register 1 A
		;Bits 4:5,6:7 - COM1B/COM1A respectively : Compare output mode for channel
		;COM1A & COM1B control output compare pins
		;Can be set to non-PWM or fast PWM mode
		ldi	r16,0x81			;set OC to compare match set output to high level
		sts TCCR1A,r16			;Stores a binary value of 1100 0000
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
		ldi r16,0x0A			; Load register 16 with a binary value of 0000 0100
		sts TCCR1B,r16			; This sets the clock source to clkI/O/256


		;TCCR1C : Page 175 ATmega328P Sheet
		;TC1 Control Register 1 C
		;Bits 6,7 - FOC1 : Force output compare for channel B & A
		;Only active when WGM1 bits specificies non-PWM mode
		;force output compare, set PB1 high
		ldi r16,0x00			; Loads a binary value of 1000 0000 into register 16
		sts TCCR1C,r16			; forces compare on Waveform Generation unit
								; varies depending on COM1x[1:0] bit settings

		ldi	r17,0
		ldi r18,0
		ldi r16,1

		; OCR1A : Page 180-181 ATmega328P sheet
		/* Note: The counter reaches the TOP when it becomes equal to the highest value in the count sequence.
		*	The TOP value can be assigned to be the fixed MAX value or the value stored in the OCR1A Register.
		*	The assignment is dependant on the mode of operation. 
		*/
		;continuously compared w/ counter value
		;Match can either generate an interrupt or waveform output on OC1A pin
		;In this setup, it is acting as an interrupt
		sts OCR1AH, r18
		sts	OCR1AL, r17

; Increment OCR1AL to increase intensity.
IncrementLow:
		inc	r17
		sts	OCR1AL, r17
		call TimeDelay				; Add a time delay to slow change in intensity.
		ldi	r18,255
		cp	r17,r18
		brne IncrementLow

; Decrement OCR1AL to decrease intensity.
DecrementLow:
		dec	r17
		sts	OCR1AL, r17
		call TimeDelay				; Add a time delay to slow change in intensity.
		ldi	r18,0
		cp	r17,r18
		brne DecrementLow
		jmp IncrementLow			; Loop back to incrementing when done decrementing

TIM1_COMPA:							;TC 1 compare match A handler
		sbrc	r19,0				;Skip if bit 0 in register 19 is cleared.
		rjmp	ONE					
		ldi		r17,0x05			; register 17 <- 0000 0101
		ldi		r18,0x01			; register 18 <- 0000 0001
		ldi		r19,1				; register 19 <- 0000 0001
		rjmp	BEGIN				/* BEGIN - LABEL DESCRIPTION
									*	* Note: The counter reaches the TOP when it becomes equal to the highest value in the count sequence.
									*	* The TOP value can be assigned to be the fixed MAX value or the value stored in the OCR1A Register.
									*	* The assignment is dependant on the mode of operation.
									* This label loads the registers with OCR1A H and Low values
									* OCR1A - Output Compare 1 A Register (16 bits)
										* OCR1AL - Low 8 bits
										* OCR1AH - High 8 bits
									*/
ONE:	ldi		r17,0x05			; register 17 <- 0000 0101
		ldi		r18,0x01			; register 18 <- 0000 0001
		ldi		r19,0				; register 19 <- 0000 0000
BEGIN:	lds		r16,OCR1AL			; Loads data stored in Output Compare Register 1 A L (Least significant 8-bits)
		add		r17,r16				; register 17 += register 16 (OCR1AL)
		lds		r16,OCR1AH			; Loads data stored in Output Compare Register 1 A H (Most significant 8-bits)
		adc		r18,r16				; register 18 += register 16 (OCR1AH)
		sts		OCR1AH,r18			; Store register 18's data back into Output Compare Register 1 A H
		sts		OCR1AL,r17			; Store register 17's data back into Output Compare Register 1 A L
		reti						; Return from interrupt

TimeDelay:						// Total time delay = r22*r23
		ldi		r22,255
		ldi		r23,200
innerloop:
		dec		r22				; Decrements r22
		brne	innerloop		; Returns to inner loop until zero
		ldi		r22,255			; Reloads r22
		dec		r23				; Decrements r23
		brne	innerloop		; Returns to inner loop when r23 = 0
		ret
