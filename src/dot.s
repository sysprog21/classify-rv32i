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
    blt a2, t0, error_terminate  
    blt a3, t0, error_terminate   
    blt a4, t0, error_terminate  

    li t0, 0            
    li t1, 0         

loop_start:
    bge t1, a2, loop_end     # Exit loop if t1 >= element_count

    # Calculate addresses for current elements in arr0 and arr1
    mul t2, t1, a3           # t2 = t1 * stride0
    mul t3, t1, a4           # t3 = t1 * stride1

    add t4, a0, t2           # t4 = address of arr0[t1 * stride0]
    add t5, a1, t3           # t5 = address of arr1[t1 * stride1]

    lw t6, 0(t4)             # Load arr0[t1 * stride0] into t6
    lw t2, 0(t5)             # Load arr1[t1 * stride1] into t2

    mul t3, t6, t2           # t3 = arr0[t1 * stride0] * arr1[t1 * stride1]
    add t0, t0, t3           # Accumulate into result

    addi t1, t1, 1           # Increment loop index
    j loop_start             # Repeat loop

loop_end:
    mv a0, t0
    jr ra

error_terminate:
    blt a2, t0, set_error_36
    li a0, 37
    j exit

set_error_36:
    li a0, 36
    j exit
