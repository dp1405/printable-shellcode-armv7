.global _start

.section .text
_start:
    adr r1, message     @ r1 = pointer to "hello\n"
    mov r2, #message_len          @ r2 = length of message
    mov r0, #1          @ r0 = stdout (fd = 1)
    mov r7, #4          @ r7 = sys_write
    svc #0              @ invoke syscall

    mov r7, #1          @ sys_exit
    mov r0, #0          @ exit code 0
    svc #0              @ invoke syscall

message:
    .ascii "Hello, ARMv7 Shellcode!\n"
message_len = . - message

