;; CAUSE values
; Cause value after an SVCALL event
equ FAULT_SVCALL, 14

; Cause value on RESET
equ FAULT_RESET, 15

;; Memory addr constants
; Start of RAM
equ RAM_START, 10000000h

; Start of the range of memory that the OS uses to communicate with hardware
equ MMIO_START, FFFFFF00h

;; MMIO constants
; Terminal output register (8-bit)
; Characters written to rCHAR are outputted to the terminal
equ rCHAR, 0h

; RAM amount register (in bytes) (32-bit) (MUST BE A POWER OF 2 (For example, 0x10000 is a valid value, but 0x300 isn't))
; Minimum amount: 32KB
; maximum amount: 256MB
equ rRAM_AMOUNT, 10h

;; SVCALL names

; print null-terminated string starting from address specified at r0
equ print_string, 0h

; return the RAM size in KiB in r0
equ get_RAM_amount_KB, 5h

; print null-terminated error string starting from address specified at r0
; abort execution
equ fatal_error, FFh

