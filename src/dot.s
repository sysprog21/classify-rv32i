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
    li t0, 1
    blt a2, t0, error_terminate    # Check if element_count >= 1
    blt a3, t0, error_terminate    # Check if stride0 >= 1
    blt a4, t0, error_terminate    # Check if stride1 >= 1

    addi sp, sp, -40               # Allocate space on the stack
    sw ra, 36(sp)                  # Save return address
    sw s0, 0(sp)                   # Save s0
    sw s1, 4(sp)                   # Save s1
    sw s2, 8(sp)                   # Save s2
    sw s3, 12(sp)                  # Save s3
    sw s4, 16(sp)                  # Save s4
    sw s5, 20(sp)                  # Save s5
    sw s6, 24(sp)                  # Save s6
    sw s7, 28(sp)                  # Save s7
    sw a2, 32(sp)                  # Save a2

    li s0, 0                       # s0: Result accumulator
    li s1, 0                       # s1: Loop index

    slli s2, a3, 2                 # s2 = stride0 * 4 (byte offset)
    slli s3, a4, 2                 # s3 = stride1 * 4 (byte offset)

    mv s4, zero                    # s4: Offset for arr0
    mv s5, zero                    # s5: Offset for arr1

    mv s6, a0                      # s6: Base pointer for arr0
    mv s7, a1                      # s7: Base pointer for arr1

loop_start:
    blt s1, a2, loop_body          # If s1 < element_count, continue
    j loop_end

loop_body:
    add t0, s6, s4                 # t0 = Current address for arr0[i * stride0]
    add t1, s7, s5                 # t1 = Current address for arr1[i * stride1]

    lw t2, 0(t0)                   # Load arr0[i * stride0]
    lw t3, 0(t1)                   # Load arr1[i * stride1]

    # Perform multiplication (using the custom 'multiply' function)
    mv a0, t2
    mv a1, t3
    jal multiply                   # Result in a0

    # Accumulate result
    add s0, s0, a0                 # s0 += product

    # Update offsets
    add s4, s4, s2                 # s4 += stride0 * 4
    add s5, s5, s3                 # s5 += stride1 * 4

    addi s1, s1, 1                 # s1 += 1 (increment loop index)
    j loop_start

loop_end:
    mv a0, s0                      # Return the result in a0

    lw a2, 32(sp)                  # Restore a2
    lw s0, 0(sp)                   # Restore s0
    lw s1, 4(sp)                   # Restore s1
    lw s2, 8(sp)                   # Restore s2
    lw s3, 12(sp)                  # Restore s3
    lw s4, 16(sp)                  # Restore s4
    lw s5, 20(sp)                  # Restore s5
    lw s6, 24(sp)                  # Restore s6
    lw s7, 28(sp)                  # Restore s7
    lw ra, 36(sp)                  # Restore ra
    addi sp, sp, 40                # Deallocate stack space
    jr ra                          # Return

error_terminate:
    blt a2, t0, set_error_36       # If a2 < 1, set error 36
    li a0, 37                      # Error code 37 for stride issue
    j exit

set_error_36:
    li a0, 36                      # Error code 36 for element count issue
    j exit

# =======================================================
# FUNCTION: Multiply two integers without using 'mul'
# Args:
#   a0: Multiplicand
#   a1: Multiplier
# Returns:
#   a0: Product
# =======================================================
multiply:
    addi sp, sp, -16               # Allocate stack space
    sw ra, 12(sp)                  # Save return address
    sw s0, 0(sp)                   # Save s0
    sw s1, 4(sp)                   # Save s1
    sw s2, 8(sp)                   # Save s2

    mv s0, zero                    # s0: Product accumulator
    mv s1, a1                      # Copy multiplier to s1

    slt t0, a0, zero               # Check if a0 < 0
    slt t1, a1, zero               # Check if a1 < 0
    xor t2, t0, t1                 # Determine the result sign (0: positive, 1: negative)

    blt a0, zero, neg_a0           # If a0 < 0, make it positive
    j abs_a0_done
neg_a0:
    sub a0, zero, a0
abs_a0_done:
    blt a1, zero, neg_a1           # If a1 < 0, make it positive
    j abs_a1_done
neg_a1:
    sub a1, zero, a1
abs_a1_done:

multiply_loop:
    beq a1, zero, multiply_end     # Exit loop when a1 == 0

    andi t3, a1, 1                 # Check if the least significant bit of a1 is set
    beq t3, zero, skip_add         # If not, skip addition
    add s0, s0, a0                 # Add a0 to product accumulator
skip_add:
    slli a0, a0, 1                 # Shift a0 left by 1 (a0 *= 2)
    srli a1, a1, 1                 # Shift a1 right by 1 (a1 /= 2)
    j multiply_loop

multiply_end:
    # Apply the sign
    bne t2, zero, neg_result       # If t2 != 0, negate the result
    j result_ready
neg_result:
    sub s0, zero, s0               # Negate the product
result_ready:
    mv a0, s0                      # Move product to a0

    # Restore registers
    lw s0, 0(sp)                   # Restore s0
    lw s1, 4(sp)                   # Restore s1
    lw s2, 8(sp)                   # Restore s2
    lw ra, 12(sp)                  # Restore return address
    addi sp, sp, 16                # Deallocate stack space
    jr ra                          # Return
