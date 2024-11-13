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
    li t2, 0       # sum = 0
    
    slli a3, a3, 2 # a0's skip distamce
    slli a4, a4, 2 # a1's skip distance
    
loop_start:
    ble a2, zero, loop_end        # if a2 <= 0 , exit loop
    # TODO: Add your own implementation
    # Assume a0=[1,2,3]  a1=[1,3,5]  dot(a0,a1)=1*1 + 2*3 + 3*5
    # t1 = a0 , t2 = a1 , t2 = sum, t3 = tmp
    lw t0 , 0(a0)      #First input array
    lw t1 , 0(a1)      #Second input array
    
    #mul t3, t0, t1     #t3=a0[i]*a1[i]
    #=============================================================================
    li   t3, 0           # Initialize t3
mul_loop:
    andi t4, t1, 1     # check the lsb of multiplier
    beqz t4, skip_add  # if lsb is 0 , skip_add
    add  t3, t3, t0    
skip_add:    
    slli t0, t0, 1     # Shift multiplicand left by 1 (multiply by 2 )
    srli t1, t1, 1     # Shift multiplier right by 1 (divide by 2 )
    bnez t1, mul_loop  # if t1 != 0 , mul_loop  

#===============================================================================
    add t2, t2, t3     # sum = sum + t3
    
    add a0, a0, a3     # a0's strides
    add a1, a1, a4     # a1's strides 
    addi a2, a2, -1    # a2 --
    j    loop_start

loop_end:
    mv a0, t2
    jr ra

error_terminate:
    blt a2, t0, set_error_36
    li a0, 37
    j exit

set_error_36:
    li a0, 36
    j exit
