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
    
    addi sp, sp, -8           #store s0 and s1 in stack  
    sw s0, 0(sp)                 
    sw s1, 4(sp)  
    li s0, 0
    li s1, 0

loop_start:
    bge t1, a2, loop_end

#get arr0[i * stride0] = arr0[t1 * a3]
    slli t2, s0, 2                 # t2 = (i * stride0) * 4
    add t2, a0, t2                  
    lw t3, 0(t2)                   # t3 = arr0[i * stride0]
    
# get arr1[i * stride1] = arr1[t1 * a4]
    slli t2, s1, 2                  
    add t2, a1, t2                  
    lw t4, 0(t2)                    

#do (arr0[i * stride0] * arr1[i * stride1])
# see if  t3 negative
    srai t2, t3, 31           # get the sign
    xor t3, t3, t2            # get the absolute value
    sub t3, t3, t2            

# see if  t4 negative
    srai t5, t4, 31           # get the sign
    xor t4, t4, t5            # get the absolute value
    sub t4, t4, t5            

    xor t6, t2, t5            # see if multiplier and multiplicand have different sign
    li t2, 0                   
    li t5, 0
multiply_loop:
    bge t5, t3, multiply_done  
    add t2, t2, t4            # t2 += t4
    addi t5, t5, 1            # t5++
    j multiply_loop            

multiply_done:
    bnez t6, negate_result    # jump if not different 
    j end_multiply

negate_result:
    sub t2, x0, t2            # t2 = 0 - t2

end_multiply: 
    add t0, t0, t2                 
    addi t1, t1, 1            # i++
    add s0, s0, a3
    add s1, s1, a4
    j loop_start
    
loop_end:
    lw s0, 0(sp)                #load s0 and s1 from stack
    lw s1, 4(sp)                
    addi sp, sp, 8              
    
    addi a0, t0, 0
    jr ra

error_terminate:
    blt a2, t0, set_error_36
    li a0, 37
    j exit

set_error_36:
    li a0, 36
    j exit
    
