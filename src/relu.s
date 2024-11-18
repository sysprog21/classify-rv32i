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
    # Input validation
    li t0, 1             
    blt a1, t0, error     

    # Initialize counter
    li t1, 0             

loop_start:
    # Check if we've reached the end of array
    bge t1, a1, done        

    # Calculate current element address
    slli t2, t1, 2          # t2 = t1 * 4 (offset)
    add t3, a0, t2          # t3 = base address + offset
    
    # Load and check current element
    lw t4, 0(t3)           # Load value
    bge t4, zero, skip_relu # If value >= 0, skip to next element
    
    # Replace negative value with 0
    sw zero, 0(t3)         

skip_relu:
    # Increment counter and continue
    addi t1, t1, 1
    j loop_start

done:
    jr ra

error:
    li a0, 36          
    j exit
