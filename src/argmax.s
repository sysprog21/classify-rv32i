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
    li t6, 1
    blt a1, t6, handle_error

    lw t0, 0(a0)

    li t1, 0
    li t2, 1

loop_start:
    # Check if we have reached the end of the array
    bge t2, a1, end_loop

    # Load the current element into t3
    slli t4, t2, 2      # Calculate byte offset (t2 * 4)
    add t5, a0, t4      # Add offset to base address (a0)
    lw t3, 0(t5)        # Load element at the calculated address

    # Compare current element with max value in t0
    ble t3, t0, skip_update  # If current element <= max, skip

    # Update max value and index if current element is greater
    mv t0, t3
    mv t1, t2

skip_update:
    addi t2, t2, 1      # Increment loop index
    j loop_start        # Jump back to the start of the loop

end_loop:
    # Store the index of the max element in a0 (return value)
    mv a0, t1
    jr ra               # Return to caller

handle_error:
    li a0, 36
    j exit
