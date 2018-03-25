/*
 * Assembler.h
 *
 * Created: 3/24/2018 8:35:20 PM
 *  Author: Jacob Cassady
 */ 


#ifndef ASSEMBLER_H_
#define ASSEMBLER_H_

unsigned char ASCII;			//shared I/O variable with Assembly

void LCD_Init(void);
void UART_Init(void);
void UART_Clear(void);
void UART_Get(void);
void UART_Put(void);
void LCD_Write_Data(void);
void LCD_Write_Command(void);
void LCD_Read_Data(void);
void Mega328P_Init(void);
void ADC_Get(void);

/* Assembler accessors */
void UART_Puts(const char *);
unsigned char get_response(void);

void UART_Puts(const char *str)	{
	/* Display a string in the PC Terminal Program
	*/
	while (*str)
	{
		ASCII = *str++;
		UART_Put();
	}
}

unsigned char get_response(void) {
	ASCII = '\0';

	while (ASCII == '\0') {
		UART_Get();
	}
	
	return ASCII;
}




#endif /* ASSEMBLER_H_ */
