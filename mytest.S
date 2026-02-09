    .text
    .globl _start

_start:
    # I-type ALU setup
    
    addi x1, x0, 5
    addi x2, x0, 12
    addi x3, x0, -7
    addi x4, x0, 1

    # R-type
    
    add  x5, x1, x2
    sub  x6, x2, x1
    and  x7, x1, x2
    or   x8, x1, x2
    xor  x9, x1, x2
    sll  x10, x1, x4
    srl  x11, x2, x4
    sra  x12, x3, x4
    slt  x13, x3, x1
    sltu x14, x3, x1

    # I-type ALU
    
    addi x15, x1, 100
    andi x16, x2, 15
    ori  x17, x2, 16
    xori x18, x1, 3
    slti x19, x3, 0
    sltiu x20, x3, 1
    slli x21, x1, 3
    srli x22, x2, 2
    srai x23, x3, 2

    # U-type
    
    lui   x24, 0xABCDE
    auipc x25, 0

    # Memory (store/load)
    
    auipc x26, 0          # base address (PC)
    addi  x27, x0, 0x123
    sw    x27, 0(x26)
    lw    x28, 0(x26)

    addi  x29, x0, -1
    sb    x29, 4(x26)
    lb    x30, 4(x26)
    lbu   x31, 4(x26)

    sh    x29, 6(x26)
    lh    x5,  6(x26)
    lhu   x6,  6(x26)

    # Branches
    
    addi x7, x0, 10
    addi x8, x0, 10
    beq  x7, x8, beq_taken
    addi x9, x9, 1        # should be skipped

beq_taken:
    bne  x7, x8, bne_taken
    addi x9, x9, 2        # should execute

bne_taken:
    blt  x3, x1, blt_taken
    addi x9, x9, 4        # skipped

blt_taken:
    bge  x1, x3, bge_taken
    addi x9, x9, 8        # skipped

bge_taken:
    bltu x3, x1, bltu_taken
    addi x9, x9, 16       # should execute

bltu_taken:
    bgeu x3, x1, bgeu_taken
    addi x9, x9, 32       # skipped

bgeu_taken:
    # Jumps
    
    jal  x1, after_jal
    addi x9, x9, 64       # skipped

after_jal:
    auipc x2, 0
    addi  x2, x2, 8       # points a couple instructions ahead (simple immediate)
    jalr  x3, x2, 0
    addi  x9, x9, 128     # skipped

    ecall

done:
    jal x0, done
