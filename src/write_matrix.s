.import ./multiply.s

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
    addi sp, sp, -48               # Adjust stack pointer, allocate 48 bytes
    sw ra, 0(sp)                   # Store ra at sp+0
    sw s0, 4(sp)                   # Store s0 at sp+4
    sw s1, 8(sp)                   # Store s1 at sp+8
    sw s2, 12(sp)                  # Store s2 at sp+12
    sw s3, 16(sp)                  # Store s3 at sp+16
    sw s4, 20(sp)                  # Store s4 at sp+20

    # Save arguments
    mv s1, a1                      # s1 = matrix pointer
    mv s2, a2                      # s2 = number of rows
    mv s3, a3                      # s3 = number of columns

    li a1, 1                       # Mode 1 for writing
    jal fopen                      # Open the file

    li t0, -1
    beq a0, t0, fopen_error        # Check for fopen error

    mv s0, a0                      # s0 = file descriptor

    # Write number of rows and columns to file
    sw s2, 24(sp)                  # Store number of rows at sp+24
    sw s3, 28(sp)                  # Store number of columns at sp+28

    mv a0, s0                      # File descriptor
    addi a1, sp, 24                # Buffer with rows and columns at sp+24
    li a2, 2                       # Number of elements to write
    li a3, 4                       # Size of each element (4 bytes)
    jal fwrite                     # Write header to file

    li t0, 2
    bne a0, t0, fwrite_error       # Check if 2 elements were written

    # Multiply s2 and s3 to get total elements in s4
    mv a0, s2                      # Set multiplicand (number of rows)
    mv a1, s3                      # Set multiplier (number of columns)
    jal multiply                   # Call external multiply function
    mv s4, a0                      # s4 = total number of elements

    # Write matrix data to file
    mv a0, s0                      # File descriptor
    mv a1, s1                      # Matrix data pointer
    mv a2, s4                      # Number of elements to write
    li a3, 4                       # Size of each element (4 bytes)
    jal fwrite                     # Write matrix data to file

    bne a0, s4, fwrite_error       # Check if all elements were written

    mv a0, s0                      # File descriptor
    jal fclose                     # Close the file

    li t0, -1
    beq a0, t0, fclose_error       # Check for fclose error

    # Epilogue
    lw ra, 0(sp)                   # Restore ra
    lw s0, 4(sp)                   # Restore s0
    lw s1, 8(sp)                   # Restore s1
    lw s2, 12(sp)                  # Restore s2
    lw s3, 16(sp)                  # Restore s3
    lw s4, 20(sp)                  # Restore s4
    addi sp, sp, 48                # Deallocate stack space

    jr ra                          # Return

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
    addi sp, sp, 48
    jal exit                       # Properly call exit
