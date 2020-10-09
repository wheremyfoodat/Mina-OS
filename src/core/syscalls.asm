include "common/hardware.inc"

; Supervisor calls are laid in the ROM starting at 0x2000.
; Each supervisor call is 512 (0x200) bytes long
; So SVCALL #0 would be at 0x2000
; SVCALL #1 would be at 0x2200, etc
equ SVCALL_TABLE_START, 0x2000

section "supervisor call handler" [300h]

supervisor_call_handler:
    push r14 ; Push r14, which contains the current FAULT event

    mfrc r14
    andi r14, r14, FFh ; Fetch the supervisor call comment from the control register
    lsr r14, r14, 9 ; Multiply the comment by 0x200 to find the address of the fired SVCALL
    addi r14, r14, SVCALL_TABLE_START
    rcall r14, 0

    pop r14 ; Restore r14
    ret

; prints a null-terminated string
; params: 
; r0: start address of the string to print 
section "SVCall #0: print_string" [2000h]
SVCALL_print_string:
    push r0
    push r1
    push r2

    mov r1, MMIO_START

.print_loop:
    ldb r2, [r0]
    cmpi/eq r2, #0 // If the char is a null terminator, stop printing
    bt .SVCALL_print_string_exit

    stb r2, [r1, rCHAR] // Print a character
    addi r0, r0, #1
    bra .print_loop

.SVCALL_print_string_exit:
    pop r2
    pop r1
    pop r0
    ret

; returns the amount of slotted RAM in KiB in r0
; params: -
section "SVCALL #5: get_RAM_amount_KB" [2A00h]
    mov r0, rRAM_AMOUNT
    addi r0, MMIO_START
    ld r0, [r0]
    lsr r0, r0, #10
    ret


; prints a null-terminated error string, aborts execution
; params:
; r0: start address of the error string to print
section "SVCall #FF: fatal_error" [21E00h]
SVCALL_fatal_error:
    svcall print_string
    mov r0, .fataL_error_message
    svcall print_string
    stop

.fatal_error_message:
    db "Fatal error encountered :(\nAborting...", 0