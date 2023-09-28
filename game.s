DEPTH 4096
.define LED_BASE 	0x1000
.define HEX0_BASE	0x2000
.define HEX1_BASE	0x2001
.define HEX2_BASE	0x2002
.define HEX3_BASE	0x2003
.define HEX4_BASE	0x2004
.define HEX5_BASE	0x2005
.define SW_BASE 	0x3000

		  
start:  	mv		r0, #0 			// initialize score
			mv      sp, =0x1000       // initialize sp to bottom of memory
			mv		r4, =HEX0_BASE	 // point to hex0
			st		r0, [r4]		// clear hex0
			
			add		r4, #1			// point to hex0
			st		r0, [r4]		// clear hex1
			
			add		r4, #1			// point to hex0
			st		r0, [r4]		// clear hex2
			
			add		r4, #1			// point to hex0
			st		r0, [r4]		// clear hex3
			
			add		r4, #1			// point to hex0
			st		r0, [r4]		// clear hex4
			
			add		r4, #1			// point to hex0
			st		r0, [r4]		// clear hex5
			
// ------------- start game hex screen ---------------------------
			mv		r1, #0b01001111	// r1 <- hex code for '3'
			mvt		r3, #0
			bl		disp_loop
			
			mv		r1, #0b01011011	// r1 <- hex code for '2'
			bl		disp_loop
			
			mv		r1, #0b00000110 // r1 <- hex code for '1'
			bl		disp_loop
			
			mv		r1, #0b00111111 // r1 <- hex code for '0'
			bl		disp_loop
			
			b		start_game
			
disp_loop:	push 	r6			// push lr
			push	r0
			push	r4
			
			mv		r4, =HEX0_BASE	// point to hex0
			mv		r0, #6			// hex counter
disp_loop_1:st		r1, [r4]		
			bl		delay_disp
			st		r3, [r4]
			bl		delay_disp
			add		r4, #1			// move to the next hex display 
			sub		r0, #1			// decrement hex counter
			cmp		r0, #0			// check if all hex is displayed
			bne		disp_loop_1		
			
			pop 	r4
			pop		r0
			pop		r6				// pop lr
			mv		r7, r6			// mov pc, lr
			

// ----------------------- display delay loops --------------------------------
delay_disp:	push	r6
			push	r4
			mv		r4, #6
delay_disp1:bl		delay_loop
			sub		r4, #1
			cmp		r4, #0
			bne		delay_disp1
			pop		r4
			pop		r6				// pop lr
			mv		r7, r6			// mov pc, lr
			
delay_loop:	push	r6
			push	r4		
			mvt		r4, #0xFF
loop_dd:	sub		r4, #1
			cmp		r4, #0
			bne		loop_dd
			pop		r4
			pop		r6				// pop lr
			mv		r7, r6			// mov pc, lr
			
			
// -------- start of game ----------------------------------			
start_game:	mv		r1, #6		// holds number of patterns
			mv		r2, #RAND	// R2 points to first pattern
			ld		r3, [r2]	// R3 holds first pattern
			
game_loop:	bl		disp_pattern
			bl		read_input
next:		b		get_pattern			
			

// -------------- display pattern on LED --------------------------
disp_pattern:push	r6				// push lr
			push	r4
			push	r3
			mv		r4, =LED_BASE
			st		r3, [r4]		// display pattern
			bl 		delay_pat
			mv		r3, #0		
			st		r3, [r4]		// display nothing
			bl		delay_pat
			pop		r3
			pop		r4
			pop		r6				// pop lr
			mv		r7, r6			// mov pc, lr			
			
// ----------------- pattern delay loops ----------------------------
delay_pat:	push	r6				// push lr
			push	r4
			mv		r4, #13
			bl		delay_loop
			sub		r4, #1
			cmp		r4, #0
			bne		delay_disp1
			pop		r4
			pop		r6				// pop lr
			mv		r7, r6			// mov pc, lr		
				
			

// ------------ read user input from switches ----------------					
read_input:	push	r6			// push lr
			push	r4	

read_loop:	mv	 	r4, =SW_BASE
			ld		r4, [r4]		// checking for button press
			mv		r5, =0b0100000000
			and		r4, r5
			cmp		r4, #0
			beq		read_loop

read_loop_1: mv		r4, =SW_BASE
			 ld		r4, [r4]
			 mv		r5, =0b0100000000
			 and	r4, r5
			 cmp	r4, #0			
			 bne	read_loop_1
			 b		read_done
			
read_done:	mv		r4, =SW_BASE
			ld		r4, [r4]		// read switches
			mv		r5, =0b0011111111
			and		r4, r5
			cmp		r4, r3			// compare if switch state matches LED
			beq		correct
			b		wrong
			
read_return: pop	r4
			 mv		r7, r6			// mov pc, lr			
				

// --------------- correct/ wrong ------------------------------------
correct:	add		r0, #1			// increase the point
			bl		disp_score
			bl		delay_next
			bl		delay_next
			b		next			
			
wrong:		bl		disp_wrong
end2:		b		end2
			
			
// ----------------- display error on hex4 - hex0 -------------------
disp_wrong:	push	r6			// push lr
			push	r4
			push	r3
			push	r2
			mv		r4, =HEX0_BASE
			mv		r3, =WRONG_CODE
			ld		r2, [r3]		// load letter to be displayed on hex0
			st		r2, [r4]		// display letter on hex0
			
			add		r4, #1			// go to next letter
			add		r3, #1			// go to hex1
			
			ld		r2, [r3]		// load letter to be displayed on hex1
			st		r2, [r4]		// display letter on hex1
			
			add		r4, #1			// go to next letter
			add		r3, #1			// go to hex2
			
			ld		r2, [r3]		// load letter to be displayed on hex2
			st		r2, [r4]		// display letter on hex2
			
			add		r4, #1			// go to next letter
			add		r3, #1			// go to hex3
			
			ld		r2, [r3]		// load letter to be displayed on hex1
			st		r2, [r4]		// display letter on hex3
			
			add		r4, #1			// go to next letter
			add		r3, #1			// go to hex4
			
			ld		r2, [r3]		// load letter to be displayed on hex1
			st		r2, [r4]		// display letter on hex4
			
			pop		r2
			pop		r3
			pop		r4
			pop		r6			// pop lr
			mv		r7, r6			// mov pc, lr			
			
// ----------------- next delay loops ----------------------------
delay_next:	push	r6			// push lr
			push	r4
			mv		r4, #3
			bl		delay_loop
			sub		r4, #1
			cmp		r4, #0
			bne		delay_disp1
			pop		r4
			pop		r6			// pop lr
			mv		r7, r6			// mov pc, lr		
			
// ----------------- display score on hex0 --------------------
disp_score:	push	r6			// push lr
			push	r4
			push	r3
			push	r2
			mv		r4, =HEX0_BASE
			mv		r3, =BIT_CODES
			add		r3, r0			// index into bit code array based on score
			ld		r2, [r3]
			st		r2, [r4]		// display score on hex
			pop		r2
			pop		r3
			pop		r4
			pop		r6				// pop lr
			mv		r7, r6			// mov pc, lr


// --------------- get next pattern to display --------------------			
get_pattern:
			sub		r1, #1		// decrement no.of patterns in list
			cmp		r1, #0		// if all patterns are displayed, return
			beq		winner
			add 	r2, #1		// point to next pattern
			ld		r3, [r2]	// hold next pattern
			b		game_loop			
	
	
// --------------- display good on hex3 - hex0
winner: 	mv		r4, =HEX0_BASE
			mv		r3, =GOOD_CODE
			ld		r2, [r3]	// load first letter
			st		r2, [r4]	// display on hex0
			
			add 	r4, #1		// point to next letter
			add 	r3, #1		// point to hex1
			ld		r2, [r3]
			st		r2, [r4]	// display next letter on hex1
			
			
			add 	r4, #1		// point to next letter
			add 	r3, #1		// point to hex2
			ld		r2, [r3]
			st		r2, [r4]	// display next letter on hex2
			
			add 	r4, #1		// point to next letter
			add 	r3, #1		// point to hex3
			ld		r2, [r3]
			st		r2, [r4]	// display next letter on hex3
			
try:		b		try	
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
// ------------------ LED Patterns ---------------------
RAND:		.word 0b0000010101		// patterns
			.word 0b0000011111
			.word 0b0000000001
			.word 0b0001010001
			.word 0b0110011111
			.word 0b0111110110			
			
// ------------------ hex display bit codes ---------------------
// error bit code
WRONG_CODE: .word 	0b01010000	  // r
			.word 	0b01011100	  // o
			.word 	0b01010000	  // r
			.word 	0b01010000	  // r
			.word 	0b01111001	  // e

// good bit code
GOOD_CODE: 	.word 	0b01011110	  // d
			.word 	0b01011100	  // o
			.word 	0b01011100	  // d
			.word 	0b01101111	  // g

// enhanced processor is word addresable so use this hexcode
BIT_CODES:	.word   0b00111111    // 0
            .word   0b00000110    // 1
            .word   0b01011011    // 2
            .word   0b01001111    // 3
            .word   0b01100110    // 4
            .word   0b01101101    // 5
			.word   0b01111101    // 6
			.word   0b00000111    // 7
			.word   0b01111111    // 8
			.word   0b01100111    // 9			
			
			