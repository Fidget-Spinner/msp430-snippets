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
            mov.w   #0d,R5		    ; Counts how many periods have elapsed.
            mov.w   #0, R6		    ; Check whether counting down or not 0 =no (counting up), 1 =yes (counting down)
            mov.w   #961d,R11		    ; R11 stores counts to keep light on for

            bis.b   #001h, &P1DIR	    ; Set P1.0 as output
Start		    mov.w   #2,R9	    ; Counter for on/off state. on = 1, off = 2. Can increase this number to repeat states.
            inc.w   R5			    ; +1 period elapsed
            cmp.w   #120d,R5		    ; Checks if 120 periods (roughly 2 seconds) has passed
            jge	    Toggle		    ; If yes, toggle
RetToggle   cmp.w   #0, R6		    ; If counting up,
	    jnz     Down		    ; If not counting up, jmp to Down
	    add.w   #16, R11		    ; Else add 4 minus 2 (add 2 in total)
Down	    sub.w   #8, R11		    ; If counting down, minus 2
	    mov.w   #4600d,R10		    ; 4600 counts is 1 cycle
	    sub.w   R11, R10		    ; Counter for Delay loop; 4600 counts is 1 cycle.

Mainloop    xor.b   #001h, &P1OUT           ; Toggle value of P1.0 (ie toggle the LED)
	    mov.w   R10, R15		    ; Resets counter for Delay loop
            cmp.w   #2,R9		    ; Test if state is on or off, off = 2 will set neg flag
            jeq     Delay		    ; If eq(off), jmp to Delay
            mov.w   R11, R15		    ; Else, (on), will mov R11 (counter for on) into the R15 counter

Delay	    dec.w   R15			    ; The Delay loop
            jnz     Delay		    ; While R15 is not zero, keep looping back to label Delay
            dec.w   R9
            jz      Start		    ; Marks the end of 1 clock cycle
            jmp     Mainloop

Toggle      xor.w   #001h,R6		    ; Toggle up or down
            mov.w   #0h, R5		    ; Reset the period counter
            jmp     RetToggle
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
            
