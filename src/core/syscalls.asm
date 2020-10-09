include "common/hardware.inc"

; Supervisor calls are laid in the ROM starting at 0x2000.
; Each supervisor call is 512 (0x200) bytes long
; So SVCALL #0 would be at 0x2000
; SVCALL #1 would be at 0x2200, etc
equ SVCALL_TABLE_START, 0x2000

section "supervisor call handler" [300h]

supervisorCallHandler:
    push r14 ; Push r14, which contains the current FAULT event

    mfrc r14
    andi r14, r14, FFh ; Fetch the supervisor call comment from the control register
    lsr r14, r14, 9 ; Multiply the comment by 0x200 to find the address of the fired SVCALL
    addi r14, r14, SVCALL_TABLE_START
    rcall r14, 0

    pop r14 ; Restore r14
    ret

; params:
; r0: start address of the string to print 
SVCALL_printString:
    push r0
    push r1
    push r2

    mov r1, MMIO_START

.printLoop:
    ld r2, [r0]
    cmpi/eq r2, #0 // If the char is a null terminator, stop printing
    bt .SVCALL_printString_exit

    st r2, [r1, rCHAR] // Print a character
    addi r0, r0, #1
    bra .printLoop

.SVCALL_printString_exit:
    pop r2
    pop r1
    pop r0
    ret
