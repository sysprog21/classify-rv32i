.globl argmax
.text
# =================================================================
# FUNCTION: Maximum Element First Index Finder
#
# Scans an integer array to find its maximum value and returns the
# position of its first occurrence. In cases where multiple elements
# share the maximum value, returns the smallest index.
#
# Arguments:
#   a0 (int *): Pointer to the first element of the array
#   a1 (int):  Number of elements in the array
#
# Returns:
#   a0 (int):  Position of the first maximum element (0-based index)
#
# Preconditions:
#   - Array must contain at least one element
#
# Error Cases:
#   - Terminates program with exit code 36 if array length < 1
# =================================================================
argmax:
    # Input validation
    li t6, 1
    blt a1, t6, handle_error

    # Initialize
    lw t0, 0(a0)        # t0 = current maximum value
    li t1, 0           # t1 = index of maximum value
    li t2, 1           # t2 = current index

loop_start:
    # Check loop termination
    bge t2, a1, loop_end
    
    # Calculate current element address and load value
    slli t3, t2, 2     # t3 = current index * 4 (offset)
    add t4, a0, t3     # t4 = base address + offset
    lw t5, 0(t4)       # t5 = current element
    
    # Compare with current maximum
    ble t5, t0, loop_continue  # If current <= max, skip update
    
    # Update maximum and its index
    mv t0, t5          # Update max value
    mv t1, t2          # Update max index
    
loop_continue:
    addi t2, t2, 1     # Increment counter
    j loop_start       # Continue loop
    
loop_end:
    mv a0, t1          # Return index of maximum
    jr ra

handle_error:
    li a0, 36
    j exit
