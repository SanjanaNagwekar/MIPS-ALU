.include "./cs47_proj_macro.asm"
.text
.globl au_logical

#####################################################################
au_logical:
	addi	$sp, $sp, -60
	sw	$fp, 60($sp)
	sw	$ra, 56($sp)
	sw	$a0, 52($sp)
	sw	$a1, 48($sp)
	sw      $a2, 44($sp)
	sw      $a3, 40($sp)
	sw      $s0, 36($sp)
	sw      $s1, 32($sp)
	sw      $s2, 28($sp)
	sw      $s3, 24($sp)
	sw      $s4, 20($sp)
	sw      $s5, 16($sp)
	sw      $s6, 12($sp)
	sw      $s7,  8($sp)
	addi	$fp, $sp, 60

beq     $a2, 43, add_logical
beq     $a2, 45, sub_logical	
beq     $a2, 42, mul_signed
beq     $a2, 47, div_signed

##############################################################

#PROCEDURE 1
add_sub_logical: # calculate the sum of its first two arguments $a0 and $a1 
    addi    $sp, $sp, -24
    sw    $fp, 24($sp)
    sw    $ra, 20($sp)
    sw    $a0, 16($sp)
    sw    $a1, 12($sp)
    sw    $a2,  8($sp)
    addi    $fp, $sp, 24

   li $t0, 0 #this one is i
   li $v0, 0 #This one is S
   extract($v1, $a2, $zero)

addition_loop:
   	beq $t0, 32, exit
   	extract($t2, $a0, $t0) #Get ith bit of A and place it in t2
   	extract($t3, $a1, $t0) #Get ith bit of B and place it in t3
   	xor $t4, $t2, $t3 #Let t4 carry the result of Xor A and B
   	xor $t5, $t4, $v1 #Let t5 carry the result of Ci xor t4, which is Y
   	and $t8, $t2, $t3 #Let t8 carry the result of A and B
 	and $t7, $t4, $v1 #Let t7 carry the result of Cin and t4
   	or  $t9, $t8, $t7 #Let t9 carry the result of t5 or t8, which is the CO
   	move $v1, $t9 #Change the content of Cin to CO
   	insert($v0, $t0, $t5, $t4)
   	addi $t0, $t0, 1
   	j addition_loop
exit:

    lw    $fp, 24($sp)
    lw    $ra, 20($sp)
    lw    $a0, 16($sp)
    lw    $a1, 12($sp)
    lw    $a2,  8($sp)
    addi    $sp, $sp, 24
    jr $ra

 ####################################################################
    
#PROCEDURE 2   
add_logical:  # calls add_sub_logical procedure to perform addition.
	# Allocate space on the stack for saved registers and function arguments
	addi    $sp, $sp, -24
	sw    $fp, 24($sp) # Save frame pointer
	sw    $ra, 20($sp) # Save return address
	sw    $a0, 16($sp) # Save function argument 1
	sw    $a1, 12($sp) # Save function argument 2
	sw    $a2,  8($sp) # Save function argument 3
	addi    $fp, $sp, 24  # Set up a new stack frame by setting the frame pointer to the current stack pointer plus 24
 
     	# Load the value 0x00000000 into register $a2, which is used as a temporary variable to store the result of the addition
	li $a2, 0x00000000 
	# Call the add_sub_logical subroutine to perform the actual addition operation
	jal add_sub_logical
	
	# Restore saved registers and function arguments from the stack
	lw    $fp, 24($sp) # Restore frame pointer
	lw    $ra, 20($sp) # Restore return address
	lw    $a0, 16($sp) # Restore function argument 1
	lw    $a1, 12($sp) # Restore function argument 2
	lw    $a2,  8($sp) # Restore function argument 3
	
	# Deallocate stack space by adding 24 to the stack pointer
	addi    $sp, $sp, 24
	jr $ra     # Jump back to the return address
    
 #################################################################### 
   
 #PROCEDRURE 3 
sub_logical: # Performs subtraction by calling add_sub_logical procedure
	addi    $sp, $sp, -24
	sw    $fp, 24($sp)
	sw    $ra, 20($sp)
	sw    $a0, 16($sp)
	sw    $a1, 12($sp)
	sw    $a2,  8($sp)
	addi    $fp, $sp, 24

	# Negate the second argument by performing a bitwise NOT operation on it and store the result in $a1
	not $a1, $a1 
	# Load the value 0xFFFFFFFF into register $a2, which is used as a temporary variable to store the result of the subtraction
	li $a2, 0xFFFFFFFF
	# Call the add_sub_logical subroutine to perform the actual subtraction operation
	jal add_sub_logical 
	# Restore the values of $fp, $ra, $a0, and $a1 from the stack
	lw    $fp, 24($sp)
	lw    $ra, 20($sp)
	lw    $a0, 16($sp)
	lw    $a1, 12($sp)
	lw    $a2,  8($sp)
	addi    $sp, $sp, 24 	# Deallocate the space on the stack for local variables
	jr $ra
 

#####################################################################

# PROCEDURE 4
twos_complement: # Converts any operand to its corresponding two’s complement form.
	addi	$sp, $sp, -20
	sw	$fp, 20($sp)
	sw	$ra, 16($sp)
	sw      $a0, 12($sp)
	sw      $a1,  8($sp)
	addi	$fp, $sp, 20	
	# Compute the one's complement of the operand by negating it
	not $a0, $a0
	# Set $a1 to 1 to add 1 to the one's complement to get the two's complement
	li $a1, 1
	# Call the add_logical subroutine to add 1 to the one's complement
	jal add_logical	
	lw $fp, 20($sp)
	lw $ra, 16($sp)
	lw $a0, 12($sp)
	lw $a1,  8($sp)
	addi $sp, $sp, 20
	jr $ra	
twos_complement_if_neg:
	addi    $sp, $sp, -16
	sw      $fp, 0($sp)
	sw      $ra, 4($sp)
	sw      $a0, 8($sp)
	# Check if the operand is negative (i.e., less than zero)
	blt     $a0, $zero, skip_call
	# If the operand is non-negative, simply return it
	move    $v0, $a0
	j       end_now
skip_call:
	# If the operand is negative, call the twos_complement subroutine to convert it to two's complement
	jal     twos_complement
end_now:
	# Restore the values of $a0, $ra, and $fp from the stack
	lw      $a0, 8($sp)
	lw      $ra, 4($sp)
	lw      $fp, 0($sp)
	addi    $sp, $sp, 16
	jr      $ra
    
#####################################################################

#PROCEDURE 5
twos_complement_64bit: # Convert the contents of two 32-bit registers into a 64-bit result.
	addi	$sp, $sp, -24     
	sw	$fp, 20($sp)      
	sw	$ra, 16($sp)      
	sw      $a0, 12($sp)     
	sw      $a1, 8($sp)    
	addi	$fp, $sp, 20    

	not $a0, $a0          # apply bitwise NOT to Lo of the number
	not $a1, $a1          # apply bitwise NOT to Hi of the number
	move $s3, $a1         # save original Hi of the number to register s3
	li $a1, 1             # set the Hi argument to 1

	jal add_logical       # call add_logical to add 1 to the 2's complement of the number

	move $s4, $v0         # save the Lo part of the result to register s4
	move $a1, $v1         # set the Hi argument to the Hi result of add_logical
	move $a0, $s3         # set the Lo argument to the original Hi of the number

	jal add_logical       # call add_logical to add the original Hi of the number to the result

	move $v1, $v0         # move the Hi part of the result to v1
	move $v0, $s4         # move the Lo part of the result to v0

	lw $fp, 20($sp)       
	lw $ra, 16($sp)      
	lw $a0, 12($sp)       
	lw $a1, 8($sp)       
	addi $sp, $sp, 24     
	jr $ra               


#####################################################################

# PROCEDURE 6
bit_replicator: #Replicates a certain individual bit 32 times to become 32 bits
	addi $sp, $sp, -16
	sw $fp, 12($sp)
	sw $ra, 8($sp)
	sw $a0, 4($sp)
	addi $fp, $sp, 12
	
	# check if bit to replicate is 0
	beq $a0, 0, case_zero
	li $v0, 0xFFFFFFFF # set all bits to 1
	
	# jump to end of replication
	j case_end

case_zero:
	li $v0, 0 # set all bits to 0

case_end:
	lw $fp, 12($sp)
	lw $ra, 8($sp)
	lw $a0, 4($sp)
	addi $sp, $sp, 16
	jr $ra

#####################################################################

#PROCEDURE 7
mul_unsigned: # Performs unsigned multiplication of two arguments
	addi	$sp, $sp, -60
	sw	$fp, 60($sp)
	sw	$ra, 56($sp)
	sw	$a0, 52($sp)
	sw	$a1, 48($sp)
	sw      $a2, 44($sp)
	sw      $a3, 40($sp)
	sw      $s0, 36($sp)
	sw      $s1, 32($sp)
	sw      $s2, 28($sp)
	sw      $s3, 24($sp)
	sw      $s4, 20($sp)
	sw      $s5, 16($sp)
	sw      $s6, 12($sp)
	sw      $s7,  8($sp)
	addi	$fp, $sp, 60
	li $s0, 0 # Counter i
	li $s1, 0 # Hi part of the result
	move $s2, $a1 # L, the multiplier
	move $s3, $a0 # M, the multiplicand

loop:
  	 # Check if all 32 bits of the multiplier have been processed
	beq $s0, 32, Exit
  	 # Extract the least significant bit of the multiplier
	extract($a0, $s2, $zero)
	jal bit_replicator # Call the bit_replicator subroutine to replicate the bit and store the result in $v0

	move $s4, $v0 # $s4 now has the replicated bit
 	 # Calculate the product of the multiplicand and the replicated bit
	and $s5, $s3, $s4 # X = M & R
	move $a1, $s5 # H + X
	la $a0, ($s1) # Store the sum in $a1

	jal add_logical # Call the add_logical subroutine to add $a0 and $a1 and store the result in $v0

	move $s1, $v0 # Assign the value of the result to H
 	 # Shift the multiplier right logical by 1
	srl $s2, $s2, 1 
 	 # Extract the least significant bit of H and store it in $s7
	extract($s7, $s1, $zero) 
  	 # Assign the least significant bit of L to the value of $s7
	li $t1, 31
	insert($s2, $t1  $s7, $t9) 
	srl $s1, $s1, 1 #Shift the value of H right logical by 1
	addi $s0, $s0, 1 #Increment the counter
	j loop

Exit:
	move $v0, $s2 #Assign the value of $v0 by L, which is the Lo part
	move $v1, $s1 #Assign the value of $v1 by H, which is the hi part

	lw     $fp, 60($sp)
	lw     $ra, 56($sp)
	lw     $a0, 52($sp)
	lw     $a1, 48($sp)
	lw     $a2, 44($sp)
	lw     $a3, 40($sp)
	lw     $s0, 36($sp)
	lw     $s1, 32($sp)
	lw     $s2, 28($sp)
	lw     $s3, 24($sp) 
	lw     $s4, 20($sp)
	lw     $s5, 16($sp)
	lw     $s6, 12($sp)
	lw     $s7,  8($sp)
	addi   $sp, $sp, 60
	jr 	$ra

########################################################################
#PROCEDURE 8

mul_signed: # Performs multiplication of either signed or unsigned arguments
	addi	$sp, $sp, -60
	sw	$fp, 60($sp)
	sw	$ra, 56($sp)
	sw	$a0, 52($sp)
	sw	$a1, 48($sp)
	sw      $a2, 44($sp)
	sw      $a3, 40($sp)
	sw      $s0, 36($sp)
	sw      $s1, 32($sp)
	sw      $s2, 28($sp)
	sw      $s3, 24($sp)
	sw      $s4, 20($sp)
	sw      $s5, 16($sp)
	sw      $s6, 12($sp)
	sw      $s7,  8($sp)
	addi	$fp, $sp, 60
	
move $s6, $a0 # let N1, which will be $s6, be $a0. That is, N1 = $a0
move $s5, $a1 # let N2, which will be $s5, be $a1. That is, N2 = $a1


jal twos_complement_if_neg #v0 contains the two complement of $a0 if $a0 is negative
move $a3, $v0 #a3 will hold the twos complement if $a0 was negative
move $t6, $s5 #let N2, which will be $t6, be $a1. That is, N2 = $a1
move $a0, $t6 #Move N2 into a0. This way, when twos_complement_if_neg is called, a0 will contain the twos_complement of N2, which ia the original a1
jal twos_complement_if_neg
move $a1, $v0 
move $a0, $a3
jal mul_unsigned

li $t0, 31
extract($t1, $s6, $t0) #extract $a0[31] and place it in $t1
extract($t2, $t6, $t0) #extract $a1[31] and place it in $t2
xor $t3, $t1, $t2 #Xor between t2 and t1, place it in t3, and this is the sign of the result. 
bne $t3, 1, cont1
move $a0, $v0
move $a1, $v1
jal twos_complement_64bit
cont1:

	lw     $fp, 60($sp)
	lw     $ra, 56($sp)
	lw     $a0, 52($sp)
	lw     $a1, 48($sp)
	lw     $a2, 44($sp)
	lw     $a3, 40($sp)
	lw     $s0, 36($sp)
	lw     $s1, 32($sp)
	lw     $s2, 28($sp)
	lw     $s3, 24($sp) 
	lw     $s4, 20($sp)
	lw     $s5, 16($sp)
	lw     $s6, 12($sp)
	lw     $s7,  8($sp)
	addi   $sp, $sp, 60
	jr 	$ra

#####################################################################

#PROCEDURE 9 
div_unsigned: # Performs unsigned division
	addi	$sp, $sp, -60
	sw	$fp, 60($sp)
	sw	$ra, 56($sp)
	sw	$a0, 52($sp)
	sw	$a1, 48($sp)
	sw      $a2, 44($sp)
	sw      $a3, 40($sp)
	sw      $s0, 36($sp)
	sw      $s1, 32($sp)
	sw      $s2, 28($sp)
	sw      $s3, 24($sp)
	sw      $s4, 20($sp)
	sw      $s5, 16($sp)
	sw      $s6, 12($sp)
	sw      $s7,  8($sp)
	addi	$fp, $sp, 60

li $s0, 0 # i
li $s1, 0 # Remainder
move $s2, $a0 # Dividend
move $s3, $a1 # Divisor

div_loop:
   # Check if i >= 32
	beq $s0, 32, Exit_Div
	# Shift remainder left logical by 1
	sll $s1, $s1, 1
	li $t1, 31
	extract($t2, $s2, $t1) # Extract the 31st bit of divident and place it in $t2
	insert($s1, $zero, $t2, $t9)  # Insert the 31st bit of dividend into the zeroth bit of remainder
	# Shift dividend left logical by 1
	sll $s2, $s2, 1 
	# Call sub_logical to subtract dividend from remainder
	move $a0, $s1 # Move remainder into $a0
	move $a1, $s3 # Move divisor into $a1

	jal sub_logical
	blt $v0, $zero, increment
	move $s1, $v0 # Move the difference into remainder
	
	li $t1, 1 
	insert($s2, $zero, $t1, $t9)
increment:
	addi $s0, $s0, 1
	j div_loop	

Exit_Div:
move $v0, $s2 # Move quotient to $v0
move $v1, $s1 # Move remainder to $v1


	lw     $fp, 60($sp)
	lw     $ra, 56($sp)
	lw     $a0, 52($sp)
	lw     $a1, 48($sp)
	lw     $a2, 44($sp)
	lw     $a3, 40($sp)
	lw     $s0, 36($sp)
	lw     $s1, 32($sp)
	lw     $s2, 28($sp)
	lw     $s3, 24($sp) 
	lw     $s4, 20($sp)
	lw     $s5, 16($sp)
	lw     $s6, 12($sp)
	lw     $s7,  8($sp)
	addi   $sp, $sp, 60
	jr 	$ra

#####################################################################

#PROCEDURE 10
div_signed: # Performs division of signed and unsigned arguments
	addi	$sp, $sp, -60
	sw	$fp, 60($sp)
	sw	$ra, 56($sp)
	sw	$a0, 52($sp)
	sw	$a1, 48($sp)
	sw      $a2, 44($sp)
	sw      $a3, 40($sp)
	sw      $s0, 36($sp)
	sw      $s1, 32($sp)
	sw      $s2, 28($sp)
	sw      $s3, 24($sp)
	sw      $s4, 20($sp)
	sw      $s5, 16($sp)
	sw      $s6, 12($sp)
	sw      $s7,  8($sp)
	addi	$fp, $sp, 60
	
 # Save N1 and N2 in $s6 and $s5 respectively
move $s6, $a0 
move $s5, $a1 

 # Convert N1 to two's complement if it's negative
jal twos_complement_if_neg
move $a3, $v0  

# Convert N2 to two's complement if it's negative
move $t6, $s5
move $a0, $t6 
jal twos_complement_if_neg

# Call div_unsigned with the absolute values of N1 and N2
move $a1, $v0 
move $a0, $a3
jal div_unsigned

# Determine the sign of the result
li $t0, 31
extract($t1, $s6, $t0) # extract the sign bit of N1 and place it in $t1
extract($t2, $t6, $t0) # extract the sign bit of N2 and place it in $t2
xor $t3, $t1, $t2  # the sign of the result is the XOR of the sign bits of N1 and N2

# Convert the result to two's complement if it's negative
move $a0, $v0
move $s1, $v1
bne $t3, 1, cont2
jal twos_complement
move $s4, $v0
j cont4
cont2:
move $s4, $v0
cont4:
li $t0, 31

# Convert the quotient to two's complement if N1 or N2 was negative
extract($t1, $s6, $t0) 
move $a0, $s1
bne $t1, 1, cont3
jal twos_complement
move $v1, $v0
move $v0, $s4
j End
cont3:
move $v0, $s4
move $v1, $s1
j End

End:
	lw     $fp, 60($sp)
	lw     $ra, 56($sp)
	lw     $a0, 52($sp)
	lw     $a1, 48($sp)
	lw     $a2, 44($sp)
	lw     $a3, 40($sp)
	lw     $s0, 36($sp)
	lw     $s1, 32($sp)
	lw     $s2, 28($sp)
	lw     $s3, 24($sp) 
	lw     $s4, 20($sp)
	lw     $s5, 16($sp)
	lw     $s6, 12($sp)
	lw     $s7,  8($sp)
	addi   $sp, $sp, 60
	jr 	$ra

	