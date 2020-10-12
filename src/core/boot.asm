include "common/hardware.inc"
include "syscalls.asm"
include "faults.asm"

; Addresses of important vectors:
; exception vector (Every fault event, including SVCalls, reset, etc, goes through this vector)
; depending on the event type, the exception vector jumps to one of these vectors:

; SIGNAL_ILLEGAL: 200h
; supervisor_call_handler: 300h
; boot_sequence: 1000h

section "exception vector" [0h]

.handleException:

    ; Load FAULT into r14
    mfrc r14
    andi r14, r14, #F00h
    lsr r14, r14, #8

    cmpi/eq r14, FAULT_SVCALL ; If FAULT == 14, call the SVCALL handler
    ct supervisor_call_handler
    bt .exceptionVectorExit

    cmpi/eq r14, FAULT_RESET
    bt boot_sequence ; If FAULT == 15 (state of FAULT on boot), jump to the reset sequence

    cmpi/eq r14, FAULT_INVALID_STATE ; If FAULT == 4, throw a SIGILL
    bt SIGNAL_ILLEGAL

    cmpi/eq r14, FAULT_UNDEFINED ; If FAULT == 8, throw a SIGILL
    bt SIGNAL_ILLEGAL


    stop ; If FAULT is none of these values, this means we've stumbled upon an exception I haven't implemented. If so, STOP.

.exceptionVectorExit:
    switch ; move OMCR into MCR
    ret


; POST code
section "boot sequence" [1000h]

boot_sequence:
    mov r0, #0
    mov r2, #0
    mov r15, #10008000h ; init the SP. TODO: Make this depend on the amount of RAM slotted
    svcall set_screen_mode ; Set screen mode to the CLI-based mode for POST

; greet user, sleep for 2 seconds
.greet_user: 
    mov r0, .hello_message    
    svcall print_string
    mov r0, #2000 
    svcall sleep_ms

.POST:
    svcall get_RAM_amount_KB
    cmp/lo r0, #64 ; Check if system has less than 64 KiB of RAM. If so, crash
    bt not_enough_ram

    ; If the system has enough RAM, sleep for 2 seconds and continue POST
    mov r0, .ram_good_message
    svcall print_string
    mov r0, #2000
    svcall sleep_ms
    stop ; TODO: Add more tests


.jumpToProgram:
    ; add handling for if there's no program diskette inserted
    clrt               ; Clear the T bit, in case it screws up the user program
    mfrc r0            ; \
    nandi r0, #30000h  ;   switch from supervisor to user mode
    mtoc r0            ; /

    mov r0, PROGRAM_MEM_START
    rbra r0, #0


.not_enough_ram:
    mov r0, .not_enough_ram_message
    svcall fatal_error

.hello_message:
    db "This is sir Michel Rodrique, speaking to you from the white house.\nI'll shit in your face\nStarting POST...\n", 0

.not_enough_ram_message:
    db "Bruh you don't even have 64KB of RAM installed", 0

.ram_good_message:
    db "RAM: OK\nChecking monitor state...\n"