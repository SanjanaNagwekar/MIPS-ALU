.include "./cs47_proj_macro.asm"
.text
.globl au_normal

au_normal:
# TBD: Complete it
    add $t0, $zero, $a0   # Move the first operand to temporary register $t0
    add $t1, $zero, $a1   # Move the second operand to temporary register $t1

    # Perform the arithmetic operation based on its code in $a2
    	 # Addition sign = 43
   	 # Subtraction sign = 45
   	 # Multiplication sign = 42
   	 # Division sign = 47
    beq $a2, 43, ADD_operation   # Addition
    beq $a2, 45, SUB_operation   # Subtraction
    beq $a2, 42, MUL_operation   # Multiplication
    beq $a2, 47, DIV_operation   # Division

ADD_operation:
    add $v0, $t0, $t1     # Store addition result of $t0 and $t1 in $v0
    j end

SUB_operation:
    sub $v0, $t0, $t1     # Store subtraction result of $t0 and $t1 in $v0
    j end

MUL_operation:
    mul $v0, $t0, $t1     # Store multiplication result of $t0 and $t1 in $v0
    mfhi $v1              # Move the HI result to $v1
    j end

DIV_operation:
    div $t0, $t1          
    mflo $v0              # Move the quotient of $t0 and $t1 to $v0
    mfhi $v1              # Move the remainder to $v1

end:
    jr $ra                # Return to the calling function

