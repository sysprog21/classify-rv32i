.globl read_matrix
.text
# ==============================================================================
# FUNCTION: Binary Matrix File Reader
#
# Loads matrix data from a binary file into dynamically allocated memory.
# Matrix dimensions are read from file header and stored at provided addresses.
#
# Binary File Format:
#   Header (8 bytes):
#     - Bytes 0-3: Number of rows (int32)
#     - Bytes 4-7: Number of columns (int32)
#   Data:
#     - Subsequent 4-byte blocks: Matrix elements
#     - Stored in row-major order: [row0|row1|row2|...]
#
# Arguments:
#   Input:
#     a0: Pointer to filename string
#     a1: Address to write row count
#     a2: Address to write column count
#
#   Output:
#     a0: Base address of loaded matrix
#
# Error Handling:
#   Program terminates with:
#   - Code 26: Dynamic memory allocation failed
#   - Code 27: File access error (open/EOF)
#   - Code 28: File closure error
#   - Code 29: Data read error
# ==============================================================================
read_matrix:
    # Prologue
    addi sp, sp, -40
    sw ra, 0(sp)
    sw s0, 4(sp)     # File descriptor
    sw s1, 8(sp)     # Total elements
    sw s2, 12(sp)    # Matrix pointer
    sw s3, 16(sp)    # Row pointer
    sw s4, 20(sp)    # Col pointer
    
    # Save row and column pointers
    mv s3, a1        # Save row pointer
    mv s4, a2        # Save col pointer
    
    # Open file
    li a1, 0         # Read-only mode
    jal fopen
    li t0, -1
    beq a0, t0, fopen_error
    mv s0, a0        # Save file descriptor
    
    # Read dimensions
    mv a0, s0        # File descriptor
    addi a1, sp, 28  # Buffer for dimensions
    li a2, 8         # Read 8 bytes (2 integers)
    jal fread
    li t0, 8
    bne a0, t0, fread_error
    
    # Store dimensions
    lw t1, 28(sp)    # Load rows
    lw t2, 32(sp)    # Load cols
    sw t1, 0(s3)     # Store rows
    sw t2, 0(s4)     # Store cols
    
    # Calculate total size (rows * cols)
    mv t3, t1        # Copy rows to t3
    mv t4, t2        # Copy cols to t4
    li s1, 0         # Initialize result
    
multiply:
    beq t4, x0, multiply_done  # If multiplier is zero, done
    andi t5, t4, 1            # Get LSB of multiplier
    beqz t5, multiply_skip    # If LSB is 0, skip addition
    add s1, s1, t3           # Add multiplicand to result
multiply_skip:
    slli t3, t3, 1          # Left shift multiplicand
    srli t4, t4, 1          # Right shift multiplier
    j multiply
multiply_done:
    
    # Calculate bytes needed (elements * 4)
    slli t6, s1, 2          # Multiply by 4 for bytes
    sw t6, 24(sp)           # Save size in bytes
    
    # Allocate memory
    mv a0, t6               # Size in bytes
    jal malloc
    beq a0, x0, malloc_error
    mv s2, a0               # Save matrix pointer
    
    # Read matrix data
    mv a0, s0              # File descriptor
    mv a1, s2              # Buffer (matrix pointer)
    lw a2, 24(sp)         # Number of bytes to read
    jal fread
    lw t0, 24(sp)
    bne a0, t0, fread_error
    
    # Close file
    mv a0, s0
    jal fclose
    li t0, -1
    beq a0, t0, fclose_error
    
    # Return matrix pointer
    mv a0, s2
    
    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 40
    jr ra

malloc_error:
    li a0, 26
    j error_exit

fopen_error:
    li a0, 27
    j error_exit

fread_error:
    li a0, 29
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
    addi sp, sp, 40
    j exit
