.globl write_matrix
.text
# ==============================================================================
# FUNCTION: Write a matrix of integers to a binary file
# FILE FORMAT:
#   - The first 8 bytes store two 4-byte integers representing the number of 
#     rows and columns, respectively.
#   - Each subsequent 4-byte segment represents a matrix element, stored in 
#     row-major order.
#
# Arguments:
#   a0 (char *) - Pointer to a string representing the filename.
#   a1 (int *)  - Pointer to the matrix's starting location in memory.
#   a2 (int)    - Number of rows in the matrix.
#   a3 (int)    - Number of columns in the matrix.
#
# Returns:
#   None
#
# Exceptions:
#   - Terminates with error code 27 on `fopen` error or end-of-file (EOF).
#   - Terminates with error code 28 on `fclose` error or EOF.
#   - Terminates with error code 30 on `fwrite` error or EOF.
# ==============================================================================
write_matrix:
    # Prologue
    addi sp, sp, -44
    sw ra, 0(sp)
    sw s0, 4(sp)     # File descriptor
    sw s1, 8(sp)     # Matrix pointer
    sw s2, 12(sp)    # Number of rows
    sw s3, 16(sp)    # Number of columns
    sw s4, 20(sp)    # Total elements
    
    # Save arguments
    mv s1, a1        # Save matrix pointer
    mv s2, a2        # Save number of rows
    mv s3, a3        # Save number of columns
    
    # Open file for writing
    li a1, 1         # Write mode
    jal fopen
    li t0, -1
    beq a0, t0, fopen_error
    mv s0, a0        # Save file descriptor
    
    # Write dimensions to file
    sw s2, 24(sp)    # Store rows
    sw s3, 28(sp)    # Store columns
    mv a0, s0        # File descriptor
    addi a1, sp, 24  # Buffer with dimensions
    li a2, 2         # Two integers
    li a3, 4         # Size of int
    jal fwrite
    li t0, 2
    bne a0, t0, fwrite_error
    
    # Calculate total elements (rows * cols) using bit operations
    mv t0, s2        # Copy rows
    mv t1, s3        # Copy cols
    li s4, 0         # Initialize result
    
multiply:
    beq t1, x0, multiply_done  # If multiplier is zero, done
    andi t2, t1, 1            # Get LSB of multiplier
    beqz t2, multiply_skip    # If LSB is 0, skip addition
    add s4, s4, t0           # Add multiplicand to result
multiply_skip:
    slli t0, t0, 1          # Left shift multiplicand
    srli t1, t1, 1          # Right shift multiplier
    j multiply
multiply_done:    
    
    # Write matrix data
    mv a0, s0        # File descriptor
    mv a1, s1        # Matrix data pointer
    mv a2, s4        # Number of elements
    li a3, 4         # Size of int
    jal fwrite
    bne a0, s4, fwrite_error
    
    # Close file
    mv a0, s0
    jal fclose
    li t0, -1
    beq a0, t0, fclose_error
    
    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 44
    jr ra

fopen_error:
    li a0, 27
    j error_exit

fwrite_error:
    li a0, 30
    j error_exit

fclose_error:
    li a0, 28
    j error_exit

error_exit:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 44
    j exit
