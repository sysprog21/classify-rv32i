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
    li t1, 0             

loop_start:
    bge t1, a1, loop_end      # Check if the loop index has reached the number of elements

    slli t2, t1, 2            # Calculate byte offset (t1 * 4)
    add t3, a0, t2            # Calculate the address of the current array element

    lw t4, 0(t3)              # Load the current element into t4
    blez t4, set_zero         # If t4 <= 0, set it to 0
    j skip_set_zero           # Otherwise, skip to the next iteration

set_zero:
    li t4, 0                  # Set the current element to 0
    sw t4, 0(t3)              # Store the modified value back to the array

skip_set_zero:
    addi t1, t1, 1            # Increment loop index
    j loop_start              # Repeat loop

loop_end:
    jr ra                     # Return from the function

error:
    li a0, 36                 # Load error code 36
    j exit                    # Terminate program with error code
