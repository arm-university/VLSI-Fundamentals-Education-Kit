// memfile.s
// david_harris@hmc.edu and sarah.harris@unlv.edu 20 Jan 2014
// Test ARM processor
// ADD, SUB, AND, ORR, LDR, STR, B
// TST, LSL, CMN, ADC
// If successful, it should write the value 7 to address 100
// Modified 24 November 2019
//  to support 8 registers for CMOS VLSI Design 8-bit ARM subset
//  Thus R7 becomes R6 and R8 becomes R1
//  Also change branch conditions to only use Z and C flags


MAIN	SUB R0, R15, R15 	; R0 = 0						1110 000 0010 0 1111 0000 0000 0000 1111 E04F000F 0x00
		ADD R2, R0, #5      ; R2 = 5             			1110 001 0100 0 0000 0010 0000 0000 0101 E2802005 0x04
		ADD R3, R0, #12    	; R3 = 12            			1110 001 0100 0 0000 0011 0000 0000 1100 E280300C 0x08
		SUB R6, R3, #9    	; R6 = 3             			1110 001 0010 0 0011 0110 0000 0000 1001 E2436009 0x0c
		ORR R4, R6, R2    	; R4 = 3 OR 5 = 7           	1110 000 1100 0 0110 0100 0000 0000 0010 E1864002 0x10	
        AND R5, R3, R4    	; R5 = 12 AND 7 = 4            	1110 000 0000 0 0011 0101 0000 0000 0100 E0035004 0x14
		ADD R5, R5, R4    	; R5 = 4 + 7 = 11              	1110 000 0100 0 0101 0101 0000 0000 0100 E0855004 0x18		
        SUBS R1, R5, R6    	; R1 <= 11 - 3 = 8, set Flags   1110 000 0010 1 0101 1000 0000 0000 0110 E0558006 0x1c	  		
        BEQ END        		; shouldn't be taken            0000 1010 0000  0000 0000 0000 0000 1100 0A00000C 0x20  		
        SUBS R1, R3, R4    	; R1 = 12 - 7  = 5             	1110 000 0010 1 0011 0001 0000 0000 0100 E0531004 0x24		
        BHI AROUND       	; should be taken               1010 1010 0000  0000 0000 0000 0000 0000 8A000000 0x28
		ADD R5, R0, #0     	; should be skipped             1110 001 0100 0 0000 0101 0000 0000 0000 E2805000 0x2c	
AROUND	SUBS R1, R6, R2   	; R1 = 3 - 5 = -2, set Flags  	1110 000 0010 1 0110 0001 0000 0000 0010 E0561002 0x30        	
        ADDLS R6, R5, #1  	; R6 = 11 + 1 = 12				1011 001 0100 0 0101 0110 0000 0000 0001 92856001 0x34	          	
        SUB R6, R6, R2    	; R6 = 12 - 5 = 7				1110 000 0010 0 0110 0110 0000 0000 0010 E0466002 0x38	
    	STR R6, [R3, #84]  	; mem[12+84] = 7		     	1110 010 1100 0 0011 0110 0000 0101 0100 E5836054 0x3c
		LDR R2, [R0, #96]  	; R2 = mem[96] = 7				1110 010 1100 1 0000 0010 0000 0110 0000 E5902060 0x40
		ADD R15, R15, R0	; PC <- PC + 8 (skips next)  	1110 000 0100 0 1111 1111 0000 0000 0000 E08FF000 0x44
		ADD R2, R0, #14    	; shouldn't happen           	1110 001 0100 0 0000 0010 0000 0000 0001 E280200E 0x48
		B END             	; always taken					1110 1010 0000 0000 0000 0000 0000 0001  EA000001 0x4c
		ADD R2, R0, #13   	; shouldn't happen				1110 001 0100 0 0000 0010 0000 0000 0001 E280200D 0x50
  		ADD R2, R0, #10		; shouldn't happen			 	1110 001 0100 0 0000 0010 0000 0000 0001 E280200A 0x54
END		STR R2, [R0, #100] 	; mem[100] = 7                  1110 010 1100 0 0000 0010 0000 0101 0100 E5802064 0x58



