include "syscalls.asm"
include "common/hardware.inc"

;; CAUSE values

; Cause value when the CPU attempts to switch to one of the 2 reserved CPU modes
equ FAULT_INVALID_STATE, 4

; Cause value when the CPU attempts to execute an illegal instruction
equ FAULT_UNDEFINED, 8

; Cause value after an SVCALL event
equ FAULT_SVCALL, 14

; Cause value on RESET
equ FAULT_RESET, 15

section "SIGILL handler" [200h]
SIGNAL_ILLEGAL:
    cmpi/eq r14, FAULT_INVALID_STATE ; Throw an invalid state error in case fault == 4
    bt invalid_state_handler

    mov r0, sigill_error_msg ; If not, fall through and throw a regular ol' SIGILL
    svcall fatal_error

invalid_state_handler:
    mov r0, invalid_state_error_msg
    svcall fatal_error

sigill_error_msg:
    "SIGILL signal received because an illegal instruction has been called from a running process\n", 0

invalid_state_error_msg:
    "SIGILL signal received because the processor has switched to an invalid state\n", 0
