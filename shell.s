.global _start
.text

_start:
    /* Push "/bin//sh" onto the stack */
    eor r0, r0, r0          @ Clear r0
    adr r0, binsh           @ r0 points to "/bin/sh"
    eor r1, r1, r1          @ argv = NULL
    eor r2, r2, r2          @ envp = NULL
    mov r7, #11             @ syscall number for execve
    svc #0                  @ make syscall

binsh:
    .ascii "/bin/sh\0"
