;; Memory addr constants
; 32KB of RAM reserved for use exclusively by the OS, in supervisor mode
; Accessing it in user mode should raise a Privilege Mismatch exception
equ OS_RAM_START, 10000000h
equ OS_RAM_END, 10007FFFh

; RAM for user mode processes
; Minimum size: 32KB
; Maximum size: 256MB
; Accessing unslotted RAM should raise a (tfw there's no memory access fault events) Privilege Mismatch fault event
; Programs should make sure the machine has enough RAM before running, and if they try to use too much extra RAM, boo-hoo
; This will change when we finally get an MMU
equ USER_RAM_START, 20000000h


; Program memory
equ PROGRAM_MEM_START, 80000000h
equ PROGRAM_MEM_END, EFFFFFFFh

; Range of memory that the OS uses to communicate with hardware (also  called high page)
; Accessing these outside of supervisor mode WILL raise a Fault Event.
; ALL MMIO accesses in user mode should be done via syscalls
equ MMIO_START, FFFFFF00h
equ MMIO_END, FFFFFFFFh

;; MMIO constants

; Monitor control register (32-bit) (R/W)
; bits 0-3: Display mode 
    ; Display modes: 
    ; DISP_MODE_0: CLI-based mode. All visual output is done by outputting characters to rCHAR, and clearing the screen is done by rCLS
    ; DISP_MODE_1: Bitmap-based mode. Pixels are stored in VRAM as RGBA8888 values in VRAM (32bpp). rCHAR/rCLS writes are ignored
    ; DISP_MODE_2: Bitmap-based mode. Pixels are stored in VRAM as palette indices (8bpp). Palettes are stored in PRAM as RGBA8888 values. rCHAR/rCLS writes are ignored
    ; Other modes: RFU
; bits 4-31: RFU
equ rMONITOR_CNT, 0h

; Terminal output register (8-bit) (W)
; Characters written to rCHAR are outputted to the terminal when the machine is in a CLI-based mode
equ rCHAR, 4h

; Clear Screen register (8-bit) (W)
; Reads from this register return 0
; Writes clear the screen if bit 0 of the written value is 1 and the machine is in a CLI-based mode, else they do nothing
equ rCLS, 5h

; RAM amount register (in bytes) (32-bit) (R) (MUST BE A POWER OF 2 (For example, 0x10000 is a valid value, but 0x300 isn't))
; Minimum amount: 64KB
; maximum amount: 256MB
equ rRAM_AMOUNT, 10h

; Slow, non-configurable timer (32-bit) (R)
; Reads: Return the current timer value
; Writes: Set the timer to the written value (Note: Writing to ANY byte of TIM0 resets the internal clock)
; Frequency: Incremented by 1 every ms
equ rTIM0, 40h
equ rTIMER_SLOW, 40h

; DMA Channel 0 control register (32-bit) (W)
; Reads: return 0
; Writes: If bit 0 of the written value is 1, fires a DMA from channel 0. Else, does nothing
; TODO: Add more DMA channels and config options
equ rDMA0_CONTROL, 60h

; DMA Channel 0 source, destination and byte count registers (32-bit) (W)
; Reads: return 0
; DMA0_SRC: Source address for DMA0 transfers
; DMA0_DEST: Destination address for DMA0 transfers
; DMA0_BYTE_CNT: Amount of bytes to be transferred by DMA0 transfer

equ rDMA0_SRC, 64h
equ rDMA0_DEST, 68h
equ rDMA0_BYTE_CNT, 6Ch

;; SVCALL names

; print null-terminated string starting from address specified at r0
equ print_string, 0h

; print the character stored in the lowest byte of r0
equ putchar, 1h

; clears the screen
equ clear_screen, 2h

; sets the screen mode to the mode specified by r0 (bottom 4 bits)
equ set_screen_mode 3h

; return the RAM size in KiB in r0
equ get_RAM_amount_KB, 5h

; copies a block of memory using DMA0
equ memcpy, 6h

; sleep for x ms (duration is stored in r0)
equ sleep_ms, FEh

; prints a null-terminated error string starting from address specified at r0, then aborts execution
equ fatal_error, FFh

