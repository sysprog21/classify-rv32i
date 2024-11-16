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
    blt a2, t0, error_terminate    # 检查 element_count >= 1
    blt a3, t0, error_terminate    # 检查 stride0 >= 1
    blt a4, t0, error_terminate    # 检查 stride1 >= 1

    addi sp, sp, -40
    sw ra, 36(sp)
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw a2, 32(sp)                # 保存 a2

    li s0, 0          # s0: 结果累加器
    li s1, 0          # s1: 循环索引

    slli s2, a3, 2    # s2 = stride0 * 4（字节偏移）
    slli s3, a4, 2    # s3 = stride1 * 4

    mv s4, zero       # s4: arr0 的偏移量
    mv s5, zero       # s5: arr1 的偏移量

    mv s6, a0         # s6: 保存数组指针 a0
    mv s7, a1         # s7: 保存数组指针 a1

loop_start:
    blt s1, a2, loop_body
    j loop_end

loop_body:
    add t0, s6, s4       # t0 = arr0 的当前地址
    add t1, s7, s5       # t1 = arr1 的当前地址

    lw t2, 0(t0)         # t2 = arr0[i * stride0]
    lw t3, 0(t1)         # t3 = arr1[i * stride1]

    # 乘法（使用自定义的 multiply 函数）
    mv a0, t2
    mv a1, t3
    jal multiply         # 结果在 a0 中

    # 累加结果
    add s0, s0, a0       # s0 += 乘积

    # 更新偏移量
    add s4, s4, s2       # s4 += stride0 * 4
    add s5, s5, s3       # s5 += stride1 * 4

    addi s1, s1, 1       # s1 += 1
    j loop_start

loop_end:
    mv a0, s0            # 返回结果到 a0

    lw a2, 32(sp)        # 恢复 a2
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw ra, 36(sp)
    addi sp, sp, 40
    jr ra

error_terminate:
    blt a2, t0, set_error_36
    li a0, 37            # 错误代码 37
    j exit

set_error_36:
    li a0, 36            # 错误代码 36
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
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)

    mv s0, zero          # s0: 乘积累加器
    mv s1, a1            # s1: 乘数的副本

    slt t0, a0, zero     # t0 = (a0 < 0)
    slt t1, a1, zero     # t1 = (a1 < 0)
    xor t2, t0, t1       # t2 = 结果符号（0: 正，1: 负）

    blt a0, zero, neg_a0
    j abs_a0_done
neg_a0:
    sub a0, zero, a0
abs_a0_done:
    blt a1, zero, neg_a1
    j abs_a1_done
neg_a1:
    sub a1, zero, a1
abs_a1_done:

multiply_loop:
    beq a1, zero, multiply_end

    andi t3, a1, 1
    beq t3, zero, skip_add
    add s0, s0, a0
skip_add:
    slli a0, a0, 1
    srli a1, a1, 1
    j multiply_loop

multiply_end:
    # 应用符号
    bne t2, zero, neg_result
    j result_ready
neg_result:
    sub s0, zero, s0
result_ready:
    mv a0, s0           # 将乘积返回到 a0

    # 恢复寄存器
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    jr ra
