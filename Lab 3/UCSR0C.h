/*
 * UCSR0C.h
 *
 * Created: 3/24/2018 8:22:39 PM
 *  Author: Jacob Cassady
 */ 
#ifndef UCSR0C_H_
#define UCSR0C_H_

#include "Assembler.h"

unsigned int UCSR0CV;			// Value to be loaded into UCSR0C
unsigned int parity = 0;		// parity setting
unsigned int n_db = 3;			// # of data bytes
unsigned int n_sb = 0;			// # of stop bytes

/*-- USART Control Status Register 0 C Function Prototypes --*/
/* C Functions	*/
/* update UCSR0CV with the following bit values [C function]*/
void compile_UCSR0CV(void);
/* Bits 0, 1, 2 - Character Size */
void get_n_db(void);			// Ask user for new character size setting
void modify_n_db(void);			// Wrapper function. Calls modify_n_db and update_UCSR0CV
/* Bit 3 - Stop Bits */
void get_n_sb(void);			// Ask user for new stop-bit setting
void modify_n_sb(void);			// Wrapper function. Calls modify_n_sb and update_UCSR0CV
/* Bits 4 & 5 - Parity mode */
void get_parity(void);			// Ask user for new parity setting
void modify_parity(void);		// Wrapper function. Calls get_parity and update_UCSR0CV
/* Assembly Functions */
void update_UCSR0CV(void);		// Update USART Control and Status Register 0 C with global variable UCSR0CV


/* BEGIN USART CONTROL AND STATUS REGISTER FUNCTIONS. */
	/*
	*	Compile_UCSR0CV is used when updating any bit of the UCSR0C register.
	*	It shifts the bit values and calls an assembly function to load the register.
	*/
void compile_UCSR0CV(void){
	UCSR0CV = n_db * 2;				// Bits 1 & 2	- number of data bytes
	UCSR0CV = UCSR0CV + (n_sb*8);	// Bit 3		- number of stop bits 
	UCSR0CV = UCSR0CV + (parity*16);// Bits 4 & 5	- USART parity mode
	update_UCSR0CV();				// Assembly function to update USART Control and Status Register 0 C with value UCSR0CV.
}
	/* begin character size functions.*/
void get_n_db(void){
	/* Menu */
	UART_Puts("\r\n\tNote: valid char sizes: [5, 6, 7, 8, 9]");

	/* Request Response */
	unsigned char n_response = get_response();

	/* Update number of data bits variable n_sb  */
	switch(n_response) {
		case '5':
			UART_Puts("Setting number of data bits to 5-bits.");
			n_sb = 0;	//000
			break;
		case '6':
			UART_Puts("Setting number of data bits to 6-bits.");
			n_sb = 1;	//001
			break;
		case '7':
			UART_Puts("Setting number of data bits to 7-bits.");
			n_sb = 2;	//010
			break;
		case '8':
			UART_Puts("Setting number of data bits to 8-bits.");
			n_sb = 3;	//011
			break;
		case '9':
			UART_Puts("Setting number of data bits to 9-bits.");
			n_sb = 7;	//111
			break;
		default:
			UART_Puts("\r\nInvalid character size.  Setting to default value of 8.");
			n_sb = 3;	//011
	}
}

void modify_n_db(void){
	get_n_db();				//Ask user for character size setting.
	compile_UCSR0CV();		//Compile UCSR0CV value with other bit settings.
}
	/* end character size functions.*/

	/* begin parity functions.*/
void get_parity(void){
	/* Menu */
	UART_Puts("\r\n\tNote: valid parities: [(d)isabled, (e)ven, (o)dd]");

	/* Request Response. */
	unsigned char p_response = get_response();
	
	/* Update parity value. */
	switch(p_response) {
		case 'D' | 'd':
			UART_Puts("Parity set to disabled.");
			parity = 0;		//00
			break;
		case 'E' | 'e':
			UART_Puts("Parity set to even.");
			parity = 2;		//10
			break;
		case 'O' | 'o':
			UART_Puts("Parity set to odd.");
			parity = 3;		//11
			break;
		default:
			UART_Puts("Invalid parity. Setting to default [disabled]");
			parity = 0;		//00
	}	
}

void modify_parity(void){
	get_parity();			// Ask user for parity setting
	compile_UCSR0CV();		//Compile UCSR0CV value with other bit settings.
}
	/* end parity functions.*/

	/* begin # of stop bits functions.*/
void get_n_sb(void){
	/* Menu */
	UART_Puts("\r\n\tNote: valid stop-bits: 1, 2");

	/* Request Response */
	unsigned char n_response = get_response();
	
	/* Update number of stop-bits variable: n_sb */
	switch(n_response) {
		case '1':
			UART_Puts("\r\nStop-bit setting updated to 1-bit.");
			n_sb = 0;
			break;
		case '2':
			UART_Puts("\r\nStop-bit setting updated to 2-bit.");
			n_sb = 1;
			break;
		default:
			UART_Puts("\r\nInvalid stop-bit entry.  Setting to default: 1-bit.");
			n_sb = 0;
	}
}

void modify_n_sb(void){
	get_n_sb();				//Ask user for stop bit setting 
	compile_UCSR0CV();		//Compile UCSR0CV value with other bit settings.
}
	/* end # of stop bits functions.*/
/* END USART CONTROL AND STATUS REGISTER C FUNCTIONS. */


#endif /* UCSR0C_H_ */
