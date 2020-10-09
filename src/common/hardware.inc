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
; Terminal output register
; Characters written to rCHAR are outputted to the terminal
equ rCHAR, 0h

;; SVCALL names

; print null-terminated string starting from address specified at r0
equ printString, 0h

