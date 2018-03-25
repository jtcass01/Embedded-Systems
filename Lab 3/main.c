
 // main.c
 //
 // Created: 3/17/2018 4:04:52 AM
 // Author : Jacob Cassady
 // Copyright 2018, All Rights Reserved

#include "UCSR0C.h"
#include "UBRR.h"
#include "Assembler.h"
  
 const char MS1[] = "\r\nECE-412 ATMega328P Tiny OS";
 const char MS2[] = "\r\nby Jacob Cassady Copyright 2018, All Rights Reserved";
 const char MS3[] = "\r\nMenu: (L)CD, (A)CD, (E)EEPROM, (U)Update Config\r\n";
 const char MS5[] = "\r\nInvalid Command Try Again...";
 const char MS6[] = "Volts\r";
  
/* Menu Functions */
void update_config(void);		// Update Configuration Menu
void Command(void);				// Main menu

/* External Assembly Functions */
void EEPROM_Read(void);
void EEPROM_Write(void);

unsigned char DATA;				//shared internal variable with Assembly
char HADC;						//shared ADC variable with Assembly
char LADC;						//shared ADC variable with Assembly

int EEPROM_Address;				//shared variable for sharing EEPROM address with assembler
unsigned int EEPROM_AddressH;
unsigned int EEPROM_AddressL;
unsigned char EEPROM_Data;

char volts[5];					//string buffer for ADC output
int Acc;						//Accumulator for ADC use

unsigned int hex_char_to_int(unsigned char hex_char){
	unsigned int result;
	
	switch(hex_char){
		case '0':
			result = 0;
			break;
		case '1':
			result = 1;
			break;
		case '2':
			result = 2;
			break;
		case '3':
			result = 3;
			break;
		case '4':
			result = 4;
			break;
		case '5':
			result = 5;
			break;
		case '6':
			result = 6;
			break;
		case '7':
			result = 7;
			break;
		case '8':
			result = 8;
			break;
		case '9':
			result = 9;
			break;
		case ('A' | 'a'):
			result = 10;
			break;
		case ('B' | 'b'):
			result = 11;
			break;
		case ('C' | 'c'):
			result = 12;
			break;
		case ('D' | 'd'):
			result = 13;
			break;
		case ('E' | 'e'):
			result = 14;
			break;
		case ('F' | 'f'):
			result = 15;
			break;
		default:
			UART_Puts("Invalid hex_char. Result set to 0.");
			result = 0;
	}
	
	return result;
}

/* Used for debug only */
void quick_check(unsigned int val, unsigned int comparator){
	if(val == comparator) {
		UART_Puts("\r\nQuick_Check Success.");
		} else {
		UART_Puts("\r\nQuick_Check Failure.");
	}
}

//void quick_check(unsigned char val, unsigned char comparator){
//	if(val == comparator) {
//		UART_Puts("\r\nQuick_Check Success.");
//		} else {
//		UART_Puts("\r\nQuick_Check Failure.");
//	}
//}

unsigned char get_EEPROM_data(void) {
	UART_Puts("\r\nPlease enter an 8-bit data value (char): ");
	return get_response();
}


unsigned int get_hex_address(void){
	unsigned int hex_high, hex_low, address;
	UART_Puts("\r\n\tEnter hex address in the form of 0xAB");
	UART_Puts("\r\n\tEnter A: ");
	hex_high = hex_char_to_int(get_response());
	address = hex_high*16;

	UART_Puts("\r\n\tEnter B: ");
	hex_low = hex_char_to_int(get_response());
	address = address + hex_low;
	
	return address;
}

void get_EEPROM_addresses(void){
	UART_Puts("\r\n=== Please enter a valid EEPROM Address by entering a high and low hex address value. ===");

	UART_Puts("\r\n\t= HIGH ADDRESS =");
	EEPROM_AddressH = get_hex_address();

	UART_Puts("\r\n\n\tLOW ADDRESS");
	EEPROM_AddressL = get_hex_address();
}

void LCD_Puts(const char *str) {
	/* Display a string on the LCD Module
	*/
	while (*str) {
		DATA = *str++;
		LCD_Write_Data();
	}
}


void Banner(void) {
	/* Display Tiny OS Banner on Terminal
	*/
	UART_Puts(MS1);
	UART_Puts(MS2);
}

void HELP(void)	{
	/* Display available Tiny OS Commands on Terminal
	*/
	UART_Puts(MS3);
}

void LCD(void) {
	/* Lite LCD demo
	*/
	DATA = 0x34;					//Student Comment Here
	LCD_Write_Command();
	DATA = 0x08;					//Student Comment Here
	LCD_Write_Command();
	DATA = 0x02;					//Student Comment Here
	LCD_Write_Command();
	DATA = 0x06;					//Student Comment Here
	LCD_Write_Command();
	DATA = 0x0f;					//Student Comment Here
	LCD_Write_Command();
	LCD_Puts("Hello ECE412!");
	/*
	Re-engineer this subroutine to have the LCD endlessly scroll a marquee sign of 
	your Team's name either vertically or horizontally. Any key press should stop
	the scrolling and return execution to the command line in Terminal. User must
	always be able to return to command line.
	*/
}

void EEPROM(void) {
	/*
	Re-engineer this subroutine so that a byte of data can be written to any address in EEPROM
	during run-time via the command line and the same byte of data can be read back and verified after the power to
	the Xplained Mini board has been cycled. Ask the user to enter a valid EEPROM address and an
	8-bit data value. Utilize the following two given Assembly based drivers to communicate with the EEPROM. You
	may modify the EEPROM drivers as needed. User must be able to always return to command line.
	*/
	UART_Puts("\r\n===== EEPROM Write and Read =====");
	UART_Puts("\r\n");	
	get_EEPROM_addresses();
	EEPROM_Data = get_EEPROM_data();
	EEPROM_Write();
	UART_Puts("\r\n");
	EEPROM_Read();
	UART_Put();
	UART_Puts("\r\n");
	
}

void ADC(void) {
	/* Lite Demo of the Analog to Digital Converter
	*/
	volts[0x1]='.';
	volts[0x3]=' ';
	volts[0x4]= 0;
	ADC_Get();
	Acc = (((int)HADC) * 0x100 + (int)(LADC))*0xA;
	volts[0x0] = 48 + (Acc / 0x7FE);
	Acc = Acc % 0x7FE;
	volts[0x2] = ((Acc *0xA) / 0x7FE) + 48;
	Acc = (Acc * 0xA) % 0x7FE;
	if (Acc >= 0x3FF) volts[0x2]++;
	if (volts[0x2] == 58)
	{
		volts[0x2] = 48;
		volts[0x0]++;
	}
	UART_Puts(volts);
	UART_Puts(MS6);
	/*
		Re-engineer this subroutine to display temperature in degrees Fahrenheit on the Terminal.
		The potentiometer simulates a thermistor, its varying resistance simulates the
		varying resistance of a thermistor as it is heated and cooled. See the thermistor
		equations in the lab 3 folder. User must always be able to return to command line.
	*/
}


/*=== Update Configuration Menu === */
void update_config(void) {
	//Add a 'USART' command and subroutine to allow the user to reconfigure the
	//serial port parameters during runtime. Modify baud rate, # of data bits, parity,
	//# of stop bits.
	unsigned char command;
	UART_Puts("\r\n=== Update Menu ===");
	UART_Puts("\r\n(b) Baud Rate, (n) # of data bits, (p) parity, (s) # of stop bits");
	command = get_response();

	switch(command){
		// Modify Baud Rate
		case 'B' | 'b':
		UART_Puts("\r\nModifying baud rate...");
		modify_baud_rate();
		UART_Puts("\r\nBaud rate updated.");
		break;
		// Modify # of data bits
		case 'N' | 'n':
		UART_Puts("\r\nModifying # of data bits...");
		modify_n_db();
		UART_Puts("\r\n# of data bits updated.");
		break;
		// Modify parity
		case 'P' | 'p':
		UART_Puts("\r\nModifying parity...");
		modify_parity();
		UART_Puts("\r\nParity updated.");
		break;
		// Modify # of stop bits
		case 'S' | 's':
		UART_Puts("\r\nModifying # of stop bits...");
		modify_n_sb();
		UART_Puts("\r\n# of stop bits updated.");
		break;
		default:
		UART_Puts("\r\nInvalid command.  Returning to main menu...");
	}
}


/*=== Standard Menu ===*/
void Command(void) {
	/* command interpreter
	*/
	unsigned char command;
	
	UART_Puts(MS3);
	command = get_response();

	switch (command) {
		case ('L' | 'l'):
			LCD();
			break;
		case ('A' | 'a'):
			ADC();
			break;
		case 'E' | 'e':
			EEPROM();
			break;
		case 'U' | 'u':
			update_config();
			break;
		default:
			UART_Puts(MS5);
			HELP();
			break;
	}
}


int main(void) {
	Mega328P_Init();
	Banner();
	while (1) {
		Command();				//infinite command loop
	}
}
