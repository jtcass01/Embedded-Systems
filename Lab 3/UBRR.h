/*
 * UBRR.h
 *
 * Created: 3/24/2018 8:25:11 PM
 *  Author: Jacob Cassady
 */ 


#ifndef UBRR_H_
#define UBRR_H_

#include "Assembler.h"

unsigned int UBRRH;				// USART Baud Rate Register High
unsigned int UBRRL;				// USART Baud Rate Register Low

/*-- Baud Rate Function Prototypes --*/
/* C Functions */
void get_UBRR(void);			//Ask user for new baud rate.
void modify_baud_rate(void);	//Wrapper function. Calls get_UBRR and update_baudrate
/* Assembly Functions */
void update_baudrate(void);		//update USART Baud Rate 0 Register with global variables UBRRH & UBRRL.

/* BEGIN BAUD RATE FUNCTIONS. */
void get_UBRR(void){
	/* Menu */
	UART_Puts("\r\n=== Please select a USART Baud Rate from the valid values listed below. ===");
	UART_Puts("\r\n\tValid Baud Rates: (a)2400, (b)4800, (c)9600, (d)14.4k, (e)19.2k, (f)28.8k");

	/* Ask user for response. */
	unsigned char response = get_response();

	/* Update USART Baud Rate High and Low hexadecimal values. */
	switch(response) {
		case 'a' | 'A': // 2400, UBRRn = 416
		UBRRH = 0x01;
		UBRRL = 0xA0;
		break;
		case 'b' | 'B': // 4800, UBRRn = 206
		UBRRH = 0x00;
		UBRRL = 0xCE;
		break;
		case 'c' | 'C': // 9600, UBRRn = 103
		UBRRH = 0x00;
		UBRRL = 0x67;
		break;
		case 'd' | 'D': // 14.4k, UBRRn = 68
		UBRRH = 0x00;
		UBRRL = 0x67;
		break;
		case 'e' | 'E': // 19.2k, UBRRn = 51
		UBRRH = 0x00;
		UBRRL = 0x43;
		break;
		case 'f' | 'F': // 28.8k, UBRRn = 34
		UBRRH = 0x00;
		UBRRL = 0x22;
		break;
		default:
		UART_Puts("Invalid baud rate response.  Setting to default value of 9600.");
		UBRRH = 0x00;
		UBRRL = 0x67;
	}
}


void modify_baud_rate(void) {
	get_UBRR();			//Ask user to select a new baud rate.
	update_baudrate();	//Assembly Function to update USART Baud Rate 0 Register.
}
/* END BAUD RATE FUNCTIONS. */



#endif /* UBRR_H_ */
