include "common/hardware.inc"
; Supervisor calls are laid in the ROM starting at 0x2000.
; Each supervisor call is 512 (0x200) bytes long
; So SVCALL #0 would be at 0x2000
; SVCALL #1 would be at 0x2200, etc

; NOTE: SVC[r8, r9, r10] are often thrashed when using SVCALLs for speed

equ SVCALL_TABLE_START, 2000h

section "supervisor call handler" [300h]

supervisor_call_handler:
    push r14 ; Push r14, which contains the current FAULT event

    mfrc r14
    andi r14, r14, FFh ; Fetch the supervisor call comment from the control register
    lsr r14, r14, #9 ; Multiply the comment by 0x200 to find the address of the fired SVCALL
    addi r14, r14, SVCALL_TABLE_START
    rcall r14, #0

    pop r14 ; Restore r14
    ret

; prints a null-terminated string if you're in a CLI-based mode
; params: 
; r0: start address of the string to print 
section "SVCall #0: print_string" [2000h]
SVCALL_print_string:
    push r0
    mov r8, MMIO_START

.print_loop:
    ldb r9, [r0]
    cmpi/eq r9, #0 ; If the char is a null terminator, stop printing
    bt .SVCALL_print_string_exit

    stb r9, [r8, rCHAR] ; Print a character
    addi r0, r0, #1
    bra .print_loop

.SVCALL_print_string_exit:
    pop r0
    ret

; prints a character if you're in a CLI-based mode
; params: 
; r0: character to print (only the lowest byte is taken into account)
section "SVCall #1: putchar" [2200h]
SVCALL_putchar:
    mov r8, MMIO_START
    stb r0, [r8, rCHAR]
    ret

; clears the screen if you're in a CLI-based mode
; params: -
section "SVCall #2: clear_screen" [2400h]
SVCALL_clear_screen:
    mov r8, #1
    mov r9, MMIO_START
    st r8, [r9, rCLS]
    ret

; sets the screen mode
; params: 
; r0 - new screen mode (4 lower bits)
section "SVCALL #3: set_screen_mode" [2600h]
    push r0

    andi r0, r0, #Fh
    mov r8, MMIO_START
    ld r9, [r8, rMONITOR_CNT]
    nandi r9, r9, #Fh
    or r9, r9, r0
    st r9, [r8, rMONITOR_CNT]

    pop r0
    ret

; returns the amount of slotted RAM in KiB in r0
; params: -
section "SVCALL #5: get_RAM_amount_KB" [2A00h]
    mov r0, MMIO_START
    ld r0, [r0, rRAM_AMOUNT]
    lsr r0, r0, #10
    ret

; copies n bytes from address x to address y utiling DMA Channel 0
; params:
; r0 - source address
; r1 - dest address
; r2 - number of bytes to transfer
section "SVCALL #6: memcpy" [2C00h]
    ; set up DMA transfer
    mov r8, #1
    mov r9, MMIO_START
    st r0, [r9, rDMA0_SRC]
    st r1, [r9, rDMA0_DEST]
    st r2, [r9, rDMA0_BYTE_CNT]
    st r8, [r9, rDMA0_CONTROL]

    ret

; sleeps for a set amount of milliseconds
; params:
; r0: Amount of milliseconds to sleep for
section "SVCall #FE: sleep_ms" [21C00h]
    mov r8, 0 ; Reset the millisecond timer to 0
    mov r9, MMIO_START
    st r8, [r9, rTIMER_SLOW]

.sleepLoop: ; Wait till millisecond timer == amount of ms to sleep for
    ld r8, [r9, rTIMER_SLOW]
    cmp/eq r0, r8
    bf .sleepLoop

    ret
    

; prints a null-terminated error string, aborts execution
; params:
; r0: start address of the error string to print
section "SVCall #FF: fatal_error" [21E00h]
SVCALL_fatal_error:
    push r0
    mov r0, 0 ; set screen mode to CLI mode
    svcall set_screen_mode
    pop r0

    svcall print_string
    mov r0, .fataL_error_message
    svcall print_string
    stop

.fatal_error_message:
    db "Fatal error encountered :(\nAborting...", 0