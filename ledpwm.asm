;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------


			mov.w	#4600d,R10				; 4600 counts is 1 cycle
			mov.w	#2d,R11					; R11 stores counts to keep light on for, change this value to change duty cycle

			sub.w	R11, R10				; Counter for Delay loop; 4600 counts is 1 cycle.
			bis.b	#001h, &P1DIR				; Set P1.0 as output
Start		mov.w	#2,R9						; Counter for on/off state. on = 1, off = 2


Mainloop	xor.b	#001h, &P1OUT          				; Toggle value of P1.0 (ie toggle the LED)
			mov.w	R10, R15				; Resets counter for Delay loop

			cmp.w	#2,R9					; Test if state is on or off, off = 2 will set neg flag
			jeq		Delay				; If eq (off), jmp to Delay
			mov.w	R11, R15				; Else, (on), will mov R11 (counter for on) into the R15 counter

Delay		dec.w	R15						; The Delay loop
			jnz		Delay				; While R15 is not zero, keep looping back to label Delay
			dec.w	R9
			jz		Start				; Marks the end of 1 clock cycle
			jmp 	Mainloop
			nop


;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            
