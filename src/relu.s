.globl relu

.text
# ==============================================================================
# FUNCTION: Array ReLU Activation
#
# Applies ReLU (Rectified Linear Unit) operation in-place:
# For each element x in array: x = max(0, x)
#
# Arguments:
#   a0: Pointer to integer array to be modified
#   a1: Number of elements in array
#
# Returns:
#   None - Original array is modified directly
#
# Validation:
#   Requires non-empty array (length ≥ 1)
#   Terminates (code 36) if validation fails
#
# Example:
#   Input:  [-2, 0, 3, -1, 5]
#   Result: [ 0, 0, 3,  0, 5]
# ==============================================================================
relu:
    li t0, 1             
    blt a1, t0, error     
    li t1, 0     # index            

loop_start:
    # TODO: Add your own implementation
    # Assume t2 = tmp
    beqz a1, loop_end         # if a1 == 0 ,exit loop
    lw   t2, 0(a0)
    addi a0, a0,  4           # a[i+1] = a[i] + offset
    addi a1, a1, -1           # n--
    bge  t2, zero, loop_start # a[i] > 0,next element
    sw   zero, -4(a0)         # store 0
    j    loop_start
    
loop_end:
    jr ra
    
error:
    li a0, 36          
    j exit          
