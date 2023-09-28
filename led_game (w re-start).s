/* 	The LEDs will light up in a pattern
	Turn on the switches under the LEDs that light up  
	Press KEY3 to submit
	Press KEY2 to re-start
*/	
		  	.text                   // executable code follows
          	.global _start
		  	.equ  	HEX_BASE, 0xFF200020
		  	.equ 	LED_BASE, 0xFF200000
		  	.equ 	SW_BASE,  0xFF200040
			.equ 	KEY_BASE, 0xFF200050
		  
_start:  	MOV		R0, #0 		// initialize score
			LDR		R13, =20000
			LDR		R4, =0xFF200030	// initialize hex display
			STR		R0, [R4]
			LDR		R4, =HEX_BASE
			STR		R0, [R4]
			
			LDR		R2, =0xFF200030
			LDR		R1, =0b01001111
			LDR		R3, =0b01001111
			BL		disp_loop
			
			LDR		R1, =0b01011011
			LDR		R3, =0b01011011
			BL		disp_loop
			
			LDR		R1, =0b00000110
			LDR		R3, =0b00000110
			BL		disp_loop
			
			LDR		R1, =0b00111111
			LDR		R3, =0b00111111
			BL		disp_loop
			
			B		start_game
			
disp_loop:	PUSH 	{LR}
			PUSH	{R1}
			PUSH	{R3}
			STR		R1, [R4]
			BL		delay_disp
			LSL		R1, #8
			STR		R1, [R4]
			BL		delay_disp
			LSL		R1, #8
			STR		R1, [R4]
			BL		delay_disp
			LSL		R1, #8
			STR		R1, [R4]
			BL		delay_disp
			
			STR		R0,	[R4]
			
			
			STR		R3, [R2]
			BL		delay_disp
			LSL		R3, #8
			STR		R3, [R2]
			BL		delay_disp
			
			STR		R0,	[R2]
			
			POP 	{R3}
			POP		{R1}
			POP		{LR}
			MOV		PC, LR
			
delay_disp:	PUSH	{R4}
			LDR		R4, =400000		//-- delay variable
loop_dd:	SUB		R4, #1
			CMP		R4, #0
			BEQ		DONE2	
			B		loop_dd
			
DONE2:		POP		{R4}
			MOV		PC, LR			
			
start_game:	MOV		R1, #6		// holds number of patterns
			MOV		R2, #RAND	// R2 points to first pattern
			LDR		R3, [R2]	// R3 holds first pattern
			
game_loop:	BL		disp_pattern
			BL		read_input
			B		get_pattern
					
read_input:	PUSH	{LR}
			PUSH	{R4}
read_loop:	LDR 	R4, =KEY_BASE
			LDR		R4, [R4]
			CMP		R4, #8
			BNE		read_loop
read_loop_1:LDR 	R4, =KEY_BASE
			LDR		R4, [R4]
			CMP		R4, #0
			BNE		read_loop_1
			B		read_done
			
read_done:	LDR		R4, =SW_BASE
			LDR		R4, [R4]
			CMP		R4, R3
			BEQ		correct
			B		wrong
			
read_return:POP		{R4}
			POP		{LR}
			MOV		PC, LR

correct:	ADD		R0, #1		// increase the point
			BL		disp_score
			BL		delay_next
			BL		delay_next
			B		read_return
			
wrong:		BL		disp_wrong
			B		try_again

disp_score:	PUSH	{LR}
			PUSH	{R4}
			PUSH	{R3}
			PUSH	{R2}
			LDR		R4, =HEX_BASE
			LDR		R3, =BIT_CODES
			ADD		R3, R0		// index into bit code array based on score
			LDRB	R2, [R3]
			STR		R2, [R4]	// display score on hex
			POP		{R2}
			POP		{R3}
			POP		{R4}
			POP		{LR}
			MOV		PC, LR


disp_wrong:	PUSH	{LR}
			PUSH	{R4}
			PUSH	{R3}
			PUSH	{R2}
			LDR		R4, =HEX_BASE
			LDR		R3, =WRONG_CODE
			LDR		R2, [R3]
			STR		R2, [R4]
	
			LDR		R4, =0xFF200030
			LDR		R3, =WRONGCODE
			LDR		R2, [R3]
			STR		R2, [R4]
			
			POP		{R2}
			POP		{R3}
			POP		{R4}
			POP		{LR}
			MOV		PC, LR

delay_next:	PUSH	{R4}
			LDR		R4, =160000		//-- delay variable
loop_dn:	SUB		R4, #1
			CMP		R4, #0
			BEQ		DONE1	
			B		loop_dn
			
DONE1:		POP		{R4}
			MOV		PC, LR

disp_pattern:
			PUSH	{LR}
			PUSH	{R4}
			PUSH	{R3}
			LDR		R4, =LED_BASE
			STR		R3, [R4]
			BL 		delay_pat
			MOV		R3, #0
			STR		R3, [R4]
			BL		delay_pat
			POP		{R3}
			POP		{R4}
			POP		{LR}
			MOV		PC, LR
			
delay_pat:	PUSH	{R4}
			LDR		R4, =800000		//-- delay variable
loop:		SUB		R4, #1
			CMP		R4, #0
			BEQ		DONE	
			B		loop
			
DONE:		POP		{R4}
			MOV		PC, LR			
			
get_pattern:
			SUB		R1, #1		// decrement no.of patterns in list
			CMP		R1, #0		// if all patterns are displayed, return
			BEQ		WINNER
			ADD 	R2, #4		// point to next pattern
			LDR		R3, [R2]	// hold next pattern
			B		game_loop

WINNER: 	LDR		R4, =HEX_BASE
			LDR		R3, =GOOD_CODE
			LDR		R2, [R3]
			STR		R2, [R4]
			
			B		try_again		

try_again:	LDR 	R4, =KEY_BASE
			LDR		R4, [R4]
			CMP		R4, #4
			BNE		try_again
again_loop:	LDR 	R4, =KEY_BASE
			LDR		R4, [R4]
			CMP		R4, #0
			BNE		again_loop
			B		_start	

RAND:		.word 0b0000010101		// patterns
			.word 0b0000011111
			.word 0b0000000001
			.word 0b0001010001
			.word 0b0110011111
			.word 0b0111110110

//arm processor is byte addresable
BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
			.skip   2
			
WRONG_CODE: .word 	0b01010000010100000101110001010000
WRONGCODE:	.word	0b00000000000000000000000001111001	

GOOD_CODE: 	.word 	0b01101111010111000101110001011110

// enhance processor is word addresable so use this hexcode
//HEX_CODE:	.word   0b0000000000111111    // 0
//            .word   0b0000000000000110    // 1
//            .word   0b0000000001011011    // 2
//            .word   0b0000000001001111    // 3
//            .word   0b0000000001100110    // 4
//            .word   0b0000000001101101    // 5
//			.word   0b0000000001111101    // 6
//			.word   0b0000000000000111    // 7
//			.word   0b0000000001111111    // 8
//			.word   0b0000000001100111    // 9
			
