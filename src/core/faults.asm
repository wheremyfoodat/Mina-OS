include "syscalls.asm"
include "common/hardware.inc"
equ FAULT_UNDEFINED, 8

section "SIGILL handler" [200h]
SIGNAL_ILLEGAL:
    mov r0, #0
    mov r1, MMIO_START
    st r0, [r1, rMONITOR_CNT] ; Switch to CLI mode
    
    mov r0, SIGILL_ERROR_MESSAGE
    svcall fatal_error

SIGILL_ERROR_MESSAGE:
    "SIGILL signal received. An illegal instruction has been called from a running process"