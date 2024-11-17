.import ./multiply.s

.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Binary Matrix File Reader
#
# Loads matrix data from a binary file into dynamically allocated memory.
# Matrix dimensions are read from file header and stored at provided addresses.
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
    addi sp, sp, -56              # Allocate stack space (24 bytes for saved registers + 32 bytes for variables)
    sw ra, 0(sp)                  # Store ra at sp+0
    sw s0, 4(sp)                  # Store s0 at sp+4
    sw s1, 8(sp)                  # Store s1 at sp+8
    sw s2, 12(sp)                 # Store s2 at sp+12
    sw s3, 16(sp)                 # Store s3 at sp+16
    sw s4, 20(sp)                 # Store s4 at sp+20

    # Store the addresses for row and column counts on the stack
    sw a1, 24(sp)                 # Save address to write row count at sp+24
    sw a2, 28(sp)                 # Save address to write column count at sp+28

    li a1, 0                      # Mode 0 for reading
    jal fopen                     # Open the file

    li t0, -1
    beq a0, t0, fopen_error       # Check for fopen error

    sw a0, 32(sp)                 # Save file descriptor at sp+32

    # Read rows and columns
    lw a0, 32(sp)                 # Load file descriptor
    addi a1, sp, 44               # Buffer at sp+44 (Avoiding overlap with saved registers)
    li a2, 8                      # Read 8 bytes (2 integers)
    jal fread                     # Read the header

    li t0, 8
    bne a0, t0, fread_error       # Check if 8 bytes were read

    lw t1, 44(sp)                 # Load number of rows from buffer
    lw t2, 48(sp)                 # Load number of columns from buffer

    lw t3, 24(sp)                 # Load address to write row count
    lw t4, 28(sp)                 # Load address to write column count

    sw t1, 0(t3)                  # Store number of rows
    sw t2, 0(t4)                  # Store number of columns

    # Multiply t1 and t2 to get total elements
    mv a0, t1                     # Set multiplicand (rows)
    mv a1, t2                     # Set multiplier (columns)
    jal multiply                  # Call external multiply function
    mv t5, a0                     # Store result (number of elements) in t5

    slli t6, t5, 2                # Multiply by 4 to get size in bytes
    sw t6, 40(sp)                 # Store size in bytes at sp+40

    lw a0, 40(sp)                 # Load size in bytes into a0
    jal malloc                    # Allocate memory for the matrix

    beq a0, x0, malloc_error      # Check for malloc error

    sw a0, 36(sp)                 # Save matrix base address at sp+36

    # Read matrix data
    lw a0, 32(sp)                 # Load file descriptor
    lw a1, 36(sp)                 # Load buffer address (matrix base address)
    lw a2, 40(sp)                 # Load number of bytes to read
    jal fread                     # Read the matrix data

    lw t6, 40(sp)                 # Load expected number of bytes
    bne a0, t6, fread_error       # Check if all data was read

    # Close the file
    lw a0, 32(sp)                 # Load file descriptor
    jal fclose                    # Close the file

    li t0, -1
    beq a0, t0, fclose_error      # Check for fclose error

    lw a0, 36(sp)                 # Load matrix base address to return

    # Epilogue
    lw ra, 0(sp)                  # Restore ra
    lw s0, 4(sp)                  # Restore s0
    lw s1, 8(sp)                  # Restore s1
    lw s2, 12(sp)                 # Restore s2
    lw s3, 16(sp)                 # Restore s3
    lw s4, 20(sp)                 # Restore s4
    addi sp, sp, 56               # Deallocate stack space

    jr ra                         # Return

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
    # Restore registers and stack pointer
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 56
    jal exit                      # Properly call exit
