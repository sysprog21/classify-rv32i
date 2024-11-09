# Assignment 2: Classify

TODO: Add your own descriptions here.


abs.s: It turns value into Absolute value. Thus, 0-negtive.

argmax.s: It return position of max value. I use sequence access method to search array value.

dot.s: sequence access by a3 and a4 to mul array1 and array2.
Fail, debug: I forgot to shift a3 and  a4 by 2.


matmul.s: inner_loop_end and outter_loop_end
Fail, debug: the pointer must point to the correct address.


read_matrix.s: mul instruction can be converted by the column form of multiplication.
write_matrix.s: mul instruction can be converted by the column form of multiplication.


relu.s: Determine value is positive or negative numbers.if value is zero it's negative number.
No errors were shown during the testing phase.


classify.s: mul instruction can be converted by the column form of multiplication.
Fail: Attempting to access uninitialized memory between the stack and heap. Attempting to access '4' bytes at address '0x10008180'.
trace: In test_classify_slient, the value of a0 is 0x1, result in 'blt a0,5,error_arg' branch.
Using mul instruction to test function.There has same fail, so I know the problem is not in classify.s.
Then, I check other function where are falut.
At the end. I replacing all instruction of relu.s. I found original code have additional loop time.
But in the test function of relu.s, they didn't detect the loop running one extra time.
Thus, I spent a lot of time trying to find the bug.😅😅😅