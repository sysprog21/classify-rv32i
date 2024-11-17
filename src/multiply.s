.globl multiply
.text
# =======================================================
# FUNCTION: Multiply two integers without using 'mul'
# Args:
#   a0: Multiplicand
#   a1: Multiplier
# Returns:
#   a0: Product
# =======================================================
multiply:
    addi sp, sp, -16                 # Save callee-saved registers
    sw   ra, 12(sp)
    sw   s0, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)

    mv   s0, zero                    # s0: Product accumulator
    mv   s1, a1                      # s1: Copy of multiplier

                                     # Handle signs
    slt  t0, a0, zero                # t0 = (a0 < 0)
    slt  t1, a1, zero                # t1 = (a1 < 0)
    xor  t2, t0, t1                  # t2 = Sign of result (0: positive, 1: negative)

                                     # Take absolute values
    blt  a0, zero, neg_a0
    j    abs_a0_done
neg_a0:
    sub  a0, zero, a0
abs_a0_done:
    blt  a1, zero, neg_a1
    j    abs_a1_done
neg_a1:
    sub  a1, zero, a1
abs_a1_done:

multiply_loop:
    beq  a1, zero, multiply_end

    andi t3, a1, 1
    beq  t3, zero, skip_add
    add  s0, s0, a0
skip_add:
    slli a0, a0, 1
    srli a1, a1, 1
    j    multiply_loop

multiply_end:
                                     # Apply sign
    bne  t2, zero, neg_result
    j    result_ready
neg_result:
    sub  s0, zero, s0
result_ready:
    mv   a0, s0                      # Return product in a0

    lw   s0, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    jr   ra
