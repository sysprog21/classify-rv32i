.globl dot
.text
# =======================================================
# FUNCTION: Strided Dot Product Calculator
#
# Calculates sum(arr0[i * stride0] * arr1[i * stride1])
# where i ranges from 0 to (element_count - 1)
#
# Args:
#   a0 (int *): Pointer to first input array
#   a1 (int *): Pointer to second input array
#   a2 (int):   Number of elements to process
#   a3 (int):   Skip distance in first array
#   a4 (int):   Skip distance in second array
#
# Returns:
#   a0 (int):   Resulting dot product value
#
# Preconditions:
#   - Element count must be positive (>= 1)
#   - Both strides must be positive (>= 1)
#
# Error Handling:
#   - Exits with code 36 if element count < 1
#   - Exits with code 37 if any stride < 1
# =======================================================
dot:
    # Input validation
    li t0, 1
    blt a2, t0, error_36       # Check if element count < 1
    blt a3, t0, error_37       # Check if stride1 < 1
    blt a4, t0, error_37       # Check if stride2 < 1

    # Initialize result and counter
    li t0, 0                   # t0 = result accumulator
    li t1, 0                   # t1 = loop counter
    
    # Convert strides from elements to bytes
    slli a3, a3, 2            # Multiply stride1 by 4 (bytes per int)
    slli a4, a4, 2            # Multiply stride2 by 4 (bytes per int)

loop_start:
    beq t1, a2, loop_end      # If counter == element_count, exit loop
    
    # Load elements from arrays
    lw t2, 0(a0)              # t2 = arr0[i * stride0]
    lw t3, 0(a1)              # t3 = arr1[i * stride1]
    
    # Multiply elements using repeated addition
    li t4, 0                  # t4 = multiplication result
    mv t5, t2                 # t5 = temporary copy of t2
    mv t6, t3                 # t6 = temporary copy of t3
    
multiply:
    beqz t6, multiply_end     # If t6 (multiplier) == 0, end multiply
    andi t3, t6, 1           # Check least significant bit
    beqz t3, multiply_skip    # If LSB is 0, skip addition
    add t4, t4, t5           # Add multiplicand if LSB is 1
multiply_skip:
    slli t5, t5, 1          # Left shift multiplicand
    srli t6, t6, 1          # Right shift multiplier
    j multiply              # Continue multiplication loop
    
multiply_end:
    add t0, t0, t4          # Add product to result accumulator
    
    # Update pointers and counter
    add a0, a0, a3          # Advance first array pointer
    add a1, a1, a4          # Advance second array pointer
    addi t1, t1, 1         # Increment counter
    j loop_start           # Continue main loop

loop_end:
    mv a0, t0              # Move result to return register
    jr ra                  # Return

error_36:
    li a0, 36
    j exit

error_37:
    li a0, 37
    j exit
