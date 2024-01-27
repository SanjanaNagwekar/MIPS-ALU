# Add you macro definition here - do not touch cs47_common_macro.asm"
#<------------------ MACRO DEFINITIONS ---------------------->#

.macro insert($destReg, $srcReg, $shiftReg, $maskReg)
	# Load the immediate value 1 into `maskReg`
	li $maskReg, 1
	# Shift left logical `maskReg` by `srcReg` bits to create a mask with a 1 in the `srcReg`th position
	sllv $maskReg, $maskReg, $srcReg
	# Negate the mask to create a mask with a 0 in the `srcReg`th position
	nor $maskReg, $maskReg, $maskReg
	# Clear the `shiftReg`th bit of `destReg` using the mask
	and $destReg, $destReg, $maskReg
	# Shift `shiftReg` left logical by `srcReg` bits
	sllv $shiftReg, $shiftReg, $srcReg
	# Set the `shiftReg`th bit of `destReg` using the shifted value of `shiftReg`
	or $destReg, $destReg, $shiftReg
	.end_macro
	
.macro extract($destReg, $srcReg, $shiftReg)
	# Shift right logical `srcReg` by `shiftReg` bits
	srlv $destReg, $srcReg, $shiftReg
	# Mask the least significant bit (bit 0) of the result
	andi $destReg, $destReg, 1
	.end_macro
	