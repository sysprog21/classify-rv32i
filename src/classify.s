.globl classify

.text
# =====================================
# NEURAL NETWORK CLASSIFIER
# =====================================
# Description:
#   Command line program for matrix-based classification
#
# Command Line Arguments:
#   1. M0_PATH      - First matrix file location
#   2. M1_PATH      - Second matrix file location
#   3. INPUT_PATH   - Input matrix file location
#   4. OUTPUT_PATH  - Output file destination
#
# Register Usage:
#   a0 (int)        - Input: Argument count
#                   - Output: Classification result
#   a1 (char **)    - Input: Argument vector
#   a2 (int)        - Input: Silent mode flag
#                     (0 = verbose, 1 = silent)
#
# Error Codes:
#   31 - Invalid argument count
#   26 - Memory allocation failure
# =====================================
classify:
    # Error handling
    li t0, 5
    blt a0, t0, error_args
    
    # Prologue
    addi sp, sp, -48
    sw ra, 0(sp)
    sw s0, 4(sp)  # m0 matrix
    sw s1, 8(sp)  # m1 matrix
    sw s2, 12(sp) # input matrix
    sw s3, 16(sp) # m0 matrix rows
    sw s4, 20(sp) # m0 matrix cols
    sw s5, 24(sp) # m1 matrix rows
    sw s6, 28(sp) # m1 matrix cols
    sw s7, 32(sp) # input matrix rows
    sw s8, 36(sp) # input matrix cols
    sw s9, 40(sp) # h
    sw s10, 44(sp) # o

    # ==== Read m0 matrix ====
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    # Allocate memory for dimensions
    li a0, 4
    jal malloc
    beq a0, x0, error_malloc
    mv s3, a0
    
    li a0, 4
    jal malloc
    beq a0, x0, error_malloc
    mv s4, a0
    
    # Read matrix
    lw a1, 4(sp)
    lw a0, 4(a1)
    mv a1, s3
    mv a2, s4
    jal read_matrix
    mv s0, a0
    
    # Restore registers
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12

    # ==== Read m1 matrix ====
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    li a0, 4
    jal malloc
    beq a0, x0, error_malloc
    mv s5, a0
    
    li a0, 4
    jal malloc
    beq a0, x0, error_malloc
    mv s6, a0
    
    lw a1, 4(sp)
    lw a0, 8(a1)
    mv a1, s5
    mv a2, s6
    jal read_matrix
    mv s1, a0
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12

    # ==== Read input matrix ====
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    li a0, 4
    jal malloc
    beq a0, x0, error_malloc
    mv s7, a0
    
    li a0, 4
    jal malloc
    beq a0, x0, error_malloc
    mv s8, a0
    
    lw a1, 4(sp)
    lw a0, 12(a1)
    mv a1, s7
    mv a2, s8
    jal read_matrix
    mv s2, a0
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12

    # ==== Compute h = matmul(m0, input) ====
    addi sp, sp, -28
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    
    # Allocate memory for h
    lw t0, 0(s3)
    lw t1, 0(s8)
    
    # Multiply dimensions
    li a0, 0
multiply_h:
    beq t1, x0, multiply_h_done
    andi t2, t1, 1
    beq t2, x0, skip_add_h
    add a0, a0, t0
skip_add_h:
    slli t0, t0, 1
    srli t1, t1, 1
    j multiply_h
multiply_h_done:
    
    slli a0, a0, 2
    jal malloc
    beq a0, x0, error_malloc
    mv s9, a0
    mv a6, a0
    
    # Perform matrix multiplication
    mv a0, s0
    lw a1, 0(s3)
    lw a2, 0(s4)
    mv a3, s2
    lw a4, 0(s7)
    lw a5, 0(s8)
    jal matmul
    
    # Restore registers
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw a6, 24(sp)
    addi sp, sp, 28

    # ==== Apply ReLU to h ====
    addi sp, sp, -8
    sw a0, 0(sp)
    sw a1, 4(sp)
    
    mv a0, s9
    lw t0, 0(s3)
    lw t1, 0(s8)
    
    # Multiply for length
    li a1, 0
multiply_relu:
    beq t1, x0, multiply_relu_done
    andi t2, t1, 1
    beq t2, x0, skip_add_relu
    add a1, a1, t0
skip_add_relu:
    slli t0, t0, 1
    srli t1, t1, 1
    j multiply_relu
multiply_relu_done:
    
    jal relu
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    addi sp, sp, 8

    # ==== Compute o = matmul(m1, h) ====
    addi sp, sp, -28
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    
    # Allocate memory for o
    lw t0, 0(s5)
    lw t1, 0(s8)
    
    # Multiply dimensions
    li a0, 0
multiply_o:
    beq t1, x0, multiply_o_done
    andi t2, t1, 1
    beq t2, x0, skip_add_o
    add a0, a0, t0
skip_add_o:
    slli t0, t0, 1
    srli t1, t1, 1
    j multiply_o
multiply_o_done:
    
    slli a0, a0, 2
    jal malloc
    beq a0, x0, error_malloc
    mv s10, a0
    mv a6, a0
    
    # Perform matrix multiplication
    mv a0, s1
    lw a1, 0(s5)
    lw a2, 0(s6)
    mv a3, s9
    lw a4, 0(s3)
    lw a5, 0(s8)
    jal matmul
    
    # Restore registers
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw a6, 24(sp)
    addi sp, sp, 28

    # ==== Write output matrix o ====
    addi sp, sp, -16
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    
    lw a1, 4(sp)
    lw a0, 16(a1)
    mv a1, s10
    lw a2, 0(s5)
    lw a3, 0(s8)
    jal write_matrix
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    addi sp, sp, 16

    # ==== Compute argmax(o) ====
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    mv a0, s10
    lw t0, 0(s5)
    lw t1, 0(s8)
    
    # Multiply for length
    li a1, 0
multiply_argmax:
    beq t1, x0, multiply_argmax_done
    andi t2, t1, 1
    beq t2, x0, skip_add_argmax
    add a1, a1, t0
skip_add_argmax:
    slli t0, t0, 1
    srli t1, t1, 1
    j multiply_argmax
multiply_argmax_done:
    
    jal argmax
    mv t0, a0
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12
    
    mv a0, t0

    # Print if not in silent mode
    bne a2, x0, cleanup
    
    addi sp, sp, -4
    sw a0, 0(sp)
    
    jal print_int
    li a0, '\n'
    jal print_char
    
    lw a0, 0(sp)
    addi sp, sp, 4

cleanup:
    # Save return value
    addi sp, sp, -4
    sw a0, 0(sp)
    
    # Free all allocated memory
    mv a0, s0
    jal free
    mv a0, s1
    jal free
    mv a0, s2
    jal free
    mv a0, s3
    jal free
    mv a0, s4
    jal free
    mv a0, s5
    jal free
    mv a0, s6
    jal free
    mv a0, s7
    jal free
    mv a0, s8
    jal free
    mv a0, s9
    jal free
    mv a0, s10
    jal free
    
    # Restore return value
    lw a0, 0(sp)
    addi sp, sp, 4

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    lw s8, 36(sp)
    lw s9, 40(sp)
    lw s10, 44(sp)
    addi sp, sp, 48
    
    jr ra

error_args:
    li a0, 31
    j exit

error_malloc:
    li a0, 26
    j exit
