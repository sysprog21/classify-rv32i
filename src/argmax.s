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
    li  t6,  1
    blt a1, t6, handle_error

    lw  t0, 0(a0)     # Max value

    li  t1, 0         # Position
    li  t2, 0         # move
loop_start:
    # TODO: Add your own implementation
    addi a1, a1, -1
    blt  a1, t6, return
    addi a0, a0, 4
    lw   t3, 0(a0)
    addi t2, t2, 1
    ble  t3, t0, loop_start
    addi t1, t2, 0
    addi t0, t3, 0
    j    loop_start

return:
    add a0, t1, zero
    jr ra

handle_error:
    li a0, 36
    j exit
