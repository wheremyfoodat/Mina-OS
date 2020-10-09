include "common/hardware.inc"
include "syscalls.asm"

; Addresses of important vectors:
; exception vector (Every fault event, including SVCalls, reset, etc, goes through this vector)
; depending on the event type, the exception vector jumps to one of these vectors:

; supervisorCallHandler: 300h
; bootSequence: 1000h

section "exception vector" [0h]

.handleException:

    // Load FAULT into r14
    mfrc r14
    andi r14, r14, #F00h
    lsr r14, r14, #8

    cmpi/eq r14, FAULT_SVCALL // If FAULT == 14, call the SVCALL handler
    ct supervisorCallHandler

    cmpi/eq r14, FAULT_RESET
    bt bootSequence // If FAULT == 15 (state of FAULT on boot), jump to the reset sequence

    stop // If FAULT is none of these values, this means we've stumbled upon an exception I haven't implemented. If so, STOP.


// POST code
section "boot sequence" [1000h]

bootSequence:
    mov r1, #0
    mov r2, #0
    mov r15, RAM_START ; init the SP

.greetUser:
    mov r0, .helloMessage    
    svcall printString

// TODO
.POST:
    stop

.helloMessage:
    db "This is sir Michel Rodrique, speaking to you from the white house.\n", 0