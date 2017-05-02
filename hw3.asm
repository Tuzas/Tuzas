##############################################################
# Homework #3
# name: 
# sbuid: Still not valid
##############################################################
.data
inputBuffer: .space 1
coordinateBuffer: .space 200
.text

##############################
# PART 1 FUNCTIONS
##############################

smiley:
    	li $t0, 0xFFFF0000
	la $t1, ($t0)
	li $t4, 0xFFFF00C8
smileyLoop:				# fills in everything with black boxes
	beq $t0, $t4, endSmiley
	la $t1, ($t0)
	li $t2, 0x08
	sb $t2, ($t1)
	addi $t0, $t0, 1
	j smileyLoop
endSmiley:				# displays the actual smiley 
    	li $t0, 0xFFFF002E
	la $t1, ($t0)
	li $t2, 0x42 	#grey bomb
	sb $t2, ($t1)
	addi $t1, $t1, 1
	li $t2, 0xB8	#Yellow Background
	sb $t2, ($t1)
	addi $t1, $t1, 5
	li $t2, 0x42 	#grey bomb
	sb $t2, ($t1)
	addi $t1, $t1, 1
	li $t2, 0xB8	#Yellow Background
	sb $t2, ($t1)
    	li $t0, 0xFFFF0042
	la $t1, ($t0)
	li $t2, 0x42 	#grey bomb
	sb $t2, ($t1)
	addi $t1, $t1, 1
	li $t2, 0xB8	#Yellow Background
	sb $t2, ($t1)
	addi $t1, $t1, 5
	li $t2, 0x42 	#grey bomb
	sb $t2, ($t1)
	addi $t1, $t1, 1
	li $t2, 0xB8	#Yellow Background
	sb $t2, ($t1)
    	li $t0, 0xFFFF007C
	la $t1, ($t0)
	li $t2, 0x45	#red background
	sb $t2, ($t1)
	addi $t1, $t1, 1
	li $t2, 0x1F	#white star
	sb $t2, ($t1)
	addi $t1, $t1, 9
	li $t2, 0x45	#red background
	sb $t2, ($t1)
	addi $t1, $t1, 1
	li $t2, 0x1F	#white star
	sb $t2, ($t1)
    	li $t0, 0xFFFF0092
	la $t1, ($t0)
	li $t2, 0x45	#red background
	sb $t2, ($t1)
	addi $t1, $t1, 1
	li $t2, 0x1F	#white star
	sb $t2, ($t1)
	addi $t1, $t1, 5
	li $t2, 0x45	#red background
	sb $t2, ($t1)
	addi $t1, $t1, 1
	li $t2, 0x1F	#white star
	sb $t2, ($t1)
    	li $t0, 0xFFFF00A8
	la $t1, ($t0)
	li $t2, 0x45	#red background
	sb $t2, ($t1)
	addi $t1, $t1, 1
	li $t2, 0x1F	#white star
	sb $t2, ($t1)
	addi $t1, $t1, 1
	li $t2, 0x45	#red background
	sb $t2, ($t1)
	addi $t1, $t1, 1
	li $t2, 0x1F	#white star
	sb $t2, ($t1)
	j exit
	jr $ra

##############################
# PART 2 FUNCTIONS
##############################

open_file:
	li $v0, 13
	li $a1, 0
	syscall
    	jr $ra
################################################################################################################################################################
close_file:
	addi $sp, $sp, 4
	sw $v0, ($sp)
	li $v0, 16
	syscall
	lw $v0, ($sp)
	addi $sp, $sp, -4
        jr $ra
################################################################################################################################################################
load_map:
	la $t0, ($a1)
	la $s5, ($a1)
	la $t5, coordinateBuffer
	li $v0, 14
	la $a1, inputBuffer
	li $a2, 1
	li $t3, 0
	syscall
loadMapLoop:
	lb $t1, inputBuffer
	beq $v0, 0x00, endMapLoopSuccess
	beq $t1, 0x20, loadMapAddCharSkip #space
	beq $t1, 0x0D, loadMapAddCharSkip #carriage return
	beq $t1, 0x09, loadMapAddCharSkip #tab
	beq $t1, 0x0A, loadMapAddCharSkip #line feed (new line)
	bgt $t1, 0x2F, loadMapContinue # 0-9
	j endMapLoopFailure
loadMapContinue:
	blt $t1, 0x3A, loadMapAddChar # 0-9
	j endMapLoopFailure
loadMapAddCharSkip:
	li $v0, 14
	la $a1, inputBuffer
	li $a2, 1
	syscall
	j loadMapLoop
loadMapAddChar:
	sb $t1, ($t5)
	addi $t5, $t5, 1
	addi $t3, $t3, 1
	li $v0, 14
	la $a1, inputBuffer
	li $a2, 1
	syscall
	j loadMapLoop
endMapLoopSuccess:
	li $t4, 2
	div $t3, $t4
	mfhi $t0
	bgt $t0, 0, endMapLoopFailure
	li $v0, 0
	j loadMapSetValues
loadMapSetValues:
	la $t0, coordinateBuffer
loadMapSetValuesLoop:
	li $t4, 0x30
	lb $t1, ($t0)
	beq $t1, 0x00, setBombNeighbors
	addi $t0, $t0, 1
	lb $t2, ($t0)
	sub $t1, $t1, $t4
	sub $t2, $t2, $t4
	li $t4, 10
	mul $t1, $t1, $t4
	add $t1, $t1, $t2
	la $t5, cells_array
	add $t5, $t1, $t5
	li $t1, 0x00
	sb $t1, ($t5)
	li $t1, 0x20
	sb $t1, ($t5)
	addi $t0, $t0, 1
	j loadMapSetValuesLoop
setBombNeighbors:
	la $t0, ($s5)
	li $t2, 0x20
checkLeftCorners:
	addi $t4, $t0, 1
	lb $t3, ($t4)
	and $t3, $t3, $t2
	bne $t3, 0x20, LC2
	lb $t3, ($t0)
	addi $t3, $t3, 1
	sb $t3, ($t0)
LC2:
	addi $t4, $t0, 10
	lb $t3, ($t4)
	and $t3, $t3, $t2
	bne $t3, 0x20, LC3
	lb $t3, ($t0)
	addi $t3, $t3, 1
	sb $t3, ($t0)
LC3:
	addi $t4, $t0, 11
	lb $t3, ($t4)
	and $t3, $t3, $t2
	bne $t3, 0x20, LC4
	lb $t3, ($t0)
	addi $t3, $t3, 1
	sb $t3, ($t0)
LC4:
	addi $t0, $t0, 90
	addi $t4, $t0, -10
	lb $t3, ($t4)
	and $t3, $t3, $t2
	bne $t3, 0x20, LC5
	lb $t3, ($t0)
	addi $t3, $t3, 1
	sb $t3, ($t0)
LC5:
	addi $t4, $t0, -9
	lb $t3, ($t4)
	and $t3, $t3, $t2
	bne $t3, 0x20, LC6
	lb $t3, ($t0)
	addi $t3, $t3, 1
	sb $t3, ($t0)
LC6:
	addi $t4, $t0, 1
	lb $t3, ($t4)
	and $t3, $t3, $t2
	bne $t3, 0x20, checkRightCorners
	lb $t3, ($t0)
	addi $t3, $t3, 1
	sb $t3, ($t0)
checkRightCorners:
	la $t0, ($s5) #address of first cell from cell array holding info
	addi $t0, $t0, 9
	addi $t4, $t0, -1
	lb $t3, ($t4)
	and $t3, $t3, $t2
	bne $t3, 0x20, RC2
	lb $t3, ($t0)
	addi $t3, $t3, 1
	sb $t3, ($t0)
RC2:
	addi $t4, $t0, 9
	lb $t3, ($t4)
	and $t3, $t3, $t2
	bne $t3, 0x20, RC3
	lb $t3, ($t0)
	addi $t3, $t3, 1
	sb $t3, ($t0)
RC3:
	addi $t4, $t0, 10
	lb $t3, ($t4)
	and $t3, $t3, $t2
	bne $t3, 0x20, RC4
	lb $t3, ($t0)
	addi $t3, $t3, 1
	sb $t3, ($t0)
RC4:
	la $t0, ($s5)
	addi $t0, $t0, 99
	addi $t4, $t0, -10
	lb $t3, ($t4)
	and $t3, $t3, $t2
	bne $t3, 0x20, RC5
	lb $t3, ($t0)
	addi $t3, $t3, 1
	sb $t3, ($t0)
RC5:
	addi $t4, $t0, -1
	lb $t3, ($t4)
	and $t3, $t3, $t2
	bne $t3, 0x20, RC6
	lb $t3, ($t0)
	addi $t3, $t3, 1
	sb $t3, ($t0)
RC6:
	addi $t4, $t0, -11
	lb $t3, ($t4)
	and $t3, $t3, $t2
	bne $t3, 0x20, startBorderChecks
	lb $t3, ($t0)
	addi $t3, $t3, 1
	sb $t3, ($t0)
startBorderChecks:        #############################################
	la $t0, ($s5)
	addi $t0, $t0, 1
	la $t1, ($s5)
	addi $t1, $t1, 9
	li $t8, 0x20
	j northBorderCheck
northBorderCheck:
	beq $t0, $t1, southBorderCheckPreload
	la $t2, ($t0)
	addi $t2, $t2, -1
	lb $t3, ($t2)
	and $t3, $t3, $t8
	beq $t3, 0x20, northCont0
	j northCont1
northCont0:
	lb $t4, ($t0)
	addi $t4, $t4, 1
	sb $t4, ($t0)
northCont1:
	la $t2, ($t0)
	addi $t2, $t2, 1
	lb $t3, ($t2)
	and $t3, $t3, $t8
	beq $t3, 0x20, northCont2
	j northCont3
northCont2:
	lb $t4, ($t0)
	addi $t4, $t4, 1
	sb $t4, ($t0)
northCont3:
	la $t2, ($t0)
	addi $t2, $t2, 9
	lb $t3, ($t2)
	and $t3, $t3, $t8
	beq $t3, 0x20, northCont4
	j northCont5
northCont4:
	lb $t4, ($t0)
	addi $t4, $t4, 1
	sb $t4, ($t0)
northCont5:
	la $t2, ($t0)
	addi $t2, $t2, 10
	lb $t3, ($t2)
	and $t3, $t3, $t8
	beq $t3, 0x20, northCont6
	j northCont7
northCont6:
	lb $t4, ($t0)
	addi $t4, $t4, 1
	sb $t4, ($t0)
northCont7:
	la $t2, ($t0)
	addi $t2, $t2, 11
	lb $t3, ($t2)
	and $t3, $t3, $t8
	beq $t3, 0x20, northCont8
	j northCont9
northCont8:
	lb $t4, ($t0)
	addi $t4, $t4, 1
	sb $t4, ($t0)
northCont9:
	addi $t0, $t0, 1
	j northBorderCheck
	##############################################################
southBorderCheckPreload:
	la $t0, ($s5)
	addi $t0, $t0, 91
	la $t1, ($s5)
	addi $t1, $t1, 99
	li $t8, 0x20
	j southBorderCheck
southBorderCheck:
	beq $t0, $t1, westBorderCheckPreload
	la $t2, ($t0)
	addi $t2, $t2, -1
	lb $t3, ($t2)
	and $t3, $t3, $t8
	beq $t3, 0x20, southCont0
	j southCont1
southCont0:
	lb $t4, ($t0)
	addi $t4, $t4, 1
	sb $t4, ($t0)
southCont1:
	la $t2, ($t0)
	addi $t2, $t2, 1
	lb $t3, ($t2)
	and $t3, $t3, $t8
	beq $t3, 0x20, southCont2
	j southCont3
southCont2:
	lb $t4, ($t0)
	addi $t4, $t4, 1
	sb $t4, ($t0)
southCont3:
	la $t2, ($t0)
	addi $t2, $t2, -9
	lb $t3, ($t2)
	and $t3, $t3, $t8
	beq $t3, 0x20, southCont4
	j southCont5
southCont4:
	lb $t4, ($t0)
	addi $t4, $t4, 1
	sb $t4, ($t0)
southCont5:
	la $t2, ($t0)
	addi $t2, $t2, -10
	lb $t3, ($t2)
	and $t3, $t3, $t8
	beq $t3, 0x20, southCont6
	j southCont7
southCont6:
	lb $t4, ($t0)
	addi $t4, $t4, 1
	sb $t4, ($t0)
southCont7:
	la $t2, ($t0)
	addi $t2, $t2, -11
	lb $t3, ($t2)
	and $t3, $t3, $t8
	beq $t3, 0x20, southCont8
	j southCont9
southCont8:
	lb $t4, ($t0)
	addi $t4, $t4, 1
	sb $t4, ($t0)
southCont9:
	addi $t0, $t0, 1
	j southBorderCheck
westBorderCheckPreload:
	la $t0, ($s5)
	addi $t0, $t0, 10
	la $t1, ($s5)
	addi $t1, $t1, 90
	li $t8, 0x20
	j westBorderCheck
westBorderCheck:
	beq $t0, $t1, eastBorderCheckPreload
	la $t2, ($t0)
	addi $t2, $t2, -10
	lb $t3, ($t2)
	and $t3, $t3, $t8
	beq $t3, 0x20, westCont0
	j westCont1
westCont0:
	lb $t4, ($t0)
	addi $t4, $t4, 1
	sb $t4, ($t0)
westCont1:
	la $t2, ($t0)
	addi $t2, $t2, -9
	lb $t3, ($t2)
	and $t3, $t3, $t8
	beq $t3, 0x20, westCont2
	j westCont3
westCont2:
	lb $t4, ($t0)
	addi $t4, $t4, 1
	sb $t4, ($t0)
westCont3:
	la $t2, ($t0)
	addi $t2, $t2, 1
	lb $t3, ($t2)
	and $t3, $t3, $t8
	beq $t3, 0x20, westCont4
	j westCont5
westCont4:
	lb $t4, ($t0)
	addi $t4, $t4, 1
	sb $t4, ($t0)
westCont5:
	la $t2, ($t0)
	addi $t2, $t2, 10
	lb $t3, ($t2)
	and $t3, $t3, $t8
	beq $t3, 0x20, westCont6
	j westCont7
westCont6:
	lb $t4, ($t0)
	addi $t4, $t4, 1
	sb $t4, ($t0)
westCont7:
	la $t2, ($t0)
	addi $t2, $t2, 11
	lb $t3, ($t2)
	and $t3, $t3, $t8
	beq $t3, 0x20, westCont8
	j westCont9
westCont8:
	lb $t4, ($t0)
	addi $t4, $t4, 1
	sb $t4, ($t0)
westCont9:
	addi $t0, $t0, 10
	j westBorderCheck
eastBorderCheckPreload:
	la $t0, ($s5)
	addi $t0, $t0, 19
	la $t1, ($s5)
	addi $t1, $t1, 99
	li $t8, 0x20
	j eastBorderCheck
eastBorderCheck:
	beq $t0, $t1, middleBombCheck
	la $t2, ($t0)
	addi $t2, $t2, -11
	lb $t3, ($t2)
	and $t3, $t3, $t8
	beq $t3, 0x20, eastCont0
	j eastCont1
eastCont0:
	lb $t4, ($t0)
	addi $t4, $t4, 1
	sb $t4, ($t0)
eastCont1:
	la $t2, ($t0)
	addi $t2, $t2, -10
	lb $t3, ($t2)
	and $t3, $t3, $t8
	beq $t3, 0x20, eastCont2
	j eastCont3
eastCont2:
	lb $t4, ($t0)
	addi $t4, $t4, 1
	sb $t4, ($t0)
eastCont3:
	la $t2, ($t0)
	addi $t2, $t2, -1
	lb $t3, ($t2)
	and $t3, $t3, $t8
	beq $t3, 0x20, eastCont4
	j eastCont5
eastCont4:
	lb $t4, ($t0)
	addi $t4, $t4, 1
	sb $t4, ($t0)
eastCont5:
	la $t2, ($t0)
	addi $t2, $t2, 9
	lb $t3, ($t2)
	and $t3, $t3, $t8
	beq $t3, 0x20, eastCont6
	j eastCont7
eastCont6:
	lb $t4, ($t0)
	addi $t4, $t4, 1
	sb $t4, ($t0)
eastCont7:
	la $t2, ($t0)
	addi $t2, $t2, 10
	lb $t3, ($t2)
	and $t3, $t3, $t8
	beq $t3, 0x20, eastCont8
	j eastCont9
eastCont8:
	lb $t4, ($t0)
	addi $t4, $t4, 1
	sb $t4, ($t0)
eastCont9:
	addi $t0, $t0, 10
	j eastBorderCheck
################################################################################################################################################################
middleBombCheck:
	la $t0, ($s5) #address of first cell from cell array holding info
	addi $t0, $t0, 11
	la $t4, ($s5)
	addi $t4, $t4, 11
	la $t7, ($s5)
	addi $t7, $t7, 19
	la $t8, ($s5)
	addi $t8, $t8, 99
	li $t2, 0x20 # AND against this to discover bombs
	j setBombLoop
setBombNeighborsCont:
	addi $t7, $t7, 10
	addi $t4, $t4, 2
	la $t0, ($t4)
setBombLoop:
	beq $t7, $t8, endBombCheck
	beq $t4, $t7, setBombNeighborsCont
	addi $t0, $t0, -11
	j setBombCurrentCell 
setBombLoop1:
	addi $t0, $t0, 1
	j setBombCurrentCell1
setBombLoop2:
	addi $t0, $t0, 1
	j setBombCurrentCell2
setBombLoop3:	
	addi $t0, $t0, 8
	j setBombCurrentCell3
setBombLoop4:
	addi $t0, $t0, 2
	j setBombCurrentCell4
setBombLoop5:
	addi $t0, $t0, 8
	j setBombCurrentCell5
setBombLoop6:
	addi $t0, $t0, 1
	j setBombCurrentCell6
setBombLoop7:
	addi $t0, $t0, 1
	j setBombCurrentCell7
setBombLoop8:
	addi $t4, $t4, 1
	la $t0, ($t4)
	j setBombLoop
setBombCurrentCell:
	lb $t3, ($t0)
	and $t3, $t3, $t2
	bne $t3, 0x20, setBombLoop1
	lb $t3, ($t4)
	addi $t3, $t3, 1
	sb $t3, ($t4)
	j setBombLoop1
setBombCurrentCell1:
	lb $t3, ($t0)
	and $t3, $t3, $t2
	bne $t3, 0x20, setBombLoop2
	lb $t3, ($t4)
	addi $t3, $t3, 1
	sb $t3, ($t4)
	j setBombLoop2
setBombCurrentCell2:
	lb $t3, ($t0)
	and $t3, $t3, $t2
	bne $t3, 0x20, setBombLoop3
	lb $t3, ($t4)
	addi $t3, $t3, 1
	sb $t3, ($t4)
	j setBombLoop3
setBombCurrentCell3:
	lb $t3, ($t0)
	and $t3, $t3, $t2
	bne $t3, 0x20, setBombLoop4
	lb $t3, ($t4)
	addi $t3, $t3, 1
	sb $t3, ($t4)
	j setBombLoop4
setBombCurrentCell4:
	lb $t3, ($t0)
	and $t3, $t3, $t2
	bne $t3, 0x20, setBombLoop5
	lb $t3, ($t4)
	addi $t3, $t3, 1
	sb $t3, ($t4)
	j setBombLoop5
setBombCurrentCell5:
	lb $t3, ($t0)
	and $t3, $t3, $t2
	bne $t3, 0x20, setBombLoop6
	lb $t3, ($t4)
	addi $t3, $t3, 1
	sb $t3, ($t4)
	j setBombLoop6
setBombCurrentCell6:
	lb $t3, ($t0)
	and $t3, $t3, $t2
	bne $t3, 0x20, setBombLoop7
	lb $t3, ($t4)
	addi $t3, $t3, 1
	sb $t3, ($t4)
	j setBombLoop7
setBombCurrentCell7:
	lb $t3, ($t0)
	and $t3, $t3, $t2
	bne $t3, 0x20, setBombLoop8
	lb $t3, ($t4)
	addi $t3, $t3, 1
	sb $t3, ($t4)
	j setBombLoop8
endBombCheck:
	li $v0, 0
	j endMapLoop
endMapLoopFailure:
	li $v0, -1
endMapLoop:
    	jr $ra
################################################################################################################################################################
##############################
# PART 3 FUNCTIONS
##############################

init_display:
	li $t0, 0
	sw $t0, cursor_row
	sw $t0, cursor_col
	li $t0, 0xFFFF0000
	li $t1, 0xFFFF00C8
	li $t2, 0x00 # char
	li $t3, 0x78 # 7 is yellow background, 8 is grey foreground
	la $t4, ($t0)
initLoop:
	beq $t4, $t1, initCursor
	sb $t2, ($t4)
	addi $t4, $t4, 1
	sb $t3, ($t4)
	addi $t4, $t4, 1
	j initLoop
initCursor:
	la $t4, ($t0)
	addi $t4, $t4, 1
	li $t1, 0xB8
	sb $t1, ($t4)
	jr $ra

set_cell:
	move $t0, $a0 #row
	bge $t0, 0x00, set_cell0
	j invalidInput
set_cell0:
	blt $t0, 0x0a, set_cell1
	j invalidInput
set_cell1:
	move $t1, $a1 #col
	bge $t1, 0x00, set_cell2
	j invalidInput
set_cell2:
	blt $t1, 0x0a, set_cell3
	j invalidInput
set_cell3:
	move $t2, $a2 #char
	move $t3, $a3 #foreground color
	lw $t4, ($sp) #background color
	beq $t4, 0xFF, set_cellSuccessful3
	beq $t3, 0xFF, set_cellSuccessful2
	bge $t3, 0x00, set_cell4
	j invalidInput
set_cell4:
	ble $t3, 0x0F, set_cell5
	j invalidInput
set_cell5:
	bge $t4, 0x00, set_cell6
	j invalidInput
set_cell6:
	ble $t3, 0x0F, set_cellSuccessful
	j invalidInput
set_cellSuccessful:
	beq $t3, 0xFF, set_cellSuccessful2
	li $t5, 0xFFFF0000
	la $t7, ($t5)
	li $t6, 0x0a
	li $t8, 2
	mul $t6, $t6, $t0
	mul $t6, $t6, $t8
	mul $t1, $t1, $t8
	add $t6, $t6, $t1
	add $t7, $t7, $t6
	beq $t2, 0xFF, skipChar
	sb $t2, ($t7)
	addi $t7, $t7, 1
	j unSkippedChar
skipChar:
	addi $t7, $t7, 1
unSkippedChar:
	sll $t4, $t4, 4
	or $t4, $t4, $t3
	sb $t4, ($t7)
	li $v0, 0
	j set_cellExit
set_cellSuccessful2:
	li $t5, 0xFFFF0000
	la $t7, ($t5)
	li $t6, 0x0a
	li $t8, 2
	mul $t6, $t6, $t0
	mul $t6, $t6, $t8
	mul $t1, $t1, $t8
	add $t6, $t6, $t1
	add $t7, $t7, $t6
	beq $t2, 0xFF, skipChar2
	sb $t2, ($t7)
	addi $t7, $t7, 1
	j unSkippedChar2
skipChar2:
	addi $t7, $t7, 1
unSkippedChar2:
	li $t3, 0x0F
	lb $t0, ($t7)
	and $t3, $t3, $t0
	sll $t4, $t4, 4
	or $t4, $t4, $t3
	sb $t4, ($t7)
	li $v0, 0
	j set_cellExit
set_cellSuccessful3:
	li $t5, 0xFFFF0000
	la $t7, ($t5)
	li $t6, 0x0a
	li $t8, 2
	mul $t6, $t6, $t0
	mul $t6, $t6, $t8
	mul $t1, $t1, $t8
	add $t6, $t6, $t1
	add $t7, $t7, $t6
	beq $t2, 0xFF, skipChar3
	sb $t2, ($t7)
	addi $t7, $t7, 1
	j unSkippedChar3
skipChar3:
	addi $t7, $t7, 1
unSkippedChar3:
	la $t0, cells_array		#
	lw $t1, cursor_row		#
	lw $t2, cursor_col		#
	li $t3, 0x0a			#
	mul $t3, $t3, $t1		# Finds current cell's info
	add $t3, $t3, $t2		#
	add $t0, $t0, $t3		#
	lb $t1, ($t0)			#
	andi $t1, $t1, 0x40
	beq $t1, 0x40, setBackgroundBlack
	j setBackgroundGrey
setBackgroundBlack:
	li $t4, 0x00
	j continueChar3
setBackgroundGrey:
	li $t4, 0x07
	j continueChar3
continueChar3:
	li $t3, 0x0F
	lb $t0, ($t7)
	and $t3, $t3, $t0
	sll $t4, $t4, 4
	or $t4, $t4, $t3
	sb $t4, ($t7)
	li $v0, 0
	j set_cellExit
invalidInput:
	li $v0, -1
set_cellExit:
    jr $ra

reveal_map:
	sw $ra, ($sp)
	addi $sp, $sp, 4
	beq $a0, 1, smiley
reveal_mapCont:
	la $s1, ($s5)
	li $t8, 0
reveal_mapLoop:
	beq $t8, 0x64, revealEnd
	lb $t1, ($s1)
	li $t2, 0x40
	and $t2, $t2, $t1
	beq $t2, 0x40, mapRevealed #checks if revealed already by player
	li $t2, 0x10
	and $t2, $t2, $t1
	beq $t2, 0x10, mapBombCheck #checks for flag 
	li $t2, 0x20
	and $t2, $t2, $t1
	beq $t2, 0x20, mapBombFound
	li $t2, 0x0F
	and $t2, $t2, $t1
	bgt $t2, 0x00, mapNumberFound
	j blankFound
mapRevealed:
	addi $s1, $s1, 1
	addi $t8, $t8, 1
	j reveal_mapLoop
mapBombCheck:
	li $t2, 0x20
	and $t2, $t2, $t1
	beq $t2, 0x20, correctFlag
	j incorrectFlag
correctFlag:
	li $t4, 0xF
	sub $t9, $s1, $s5
	li $t7, 10
	div $t9, $t7
	mfhi $t5
	move $a1, $t5 #col
	mflo $t5
	move $a0, $t5 #row
	li $a2, 0x66 #char
	li $a3, 0x0C #foreground
	li $t2, 0x0A #background
	sw $t2, ($sp)
	jal set_cell
	addi $s1, $s1, 1
	addi $t8, $t8, 1
	j reveal_mapLoop
incorrectFlag:
	li $t4, 0xF
	sub $t9, $s1, $s5
	li $t7, 10
	div $t9, $t7
	mfhi $t5
	move $a1, $t5 #col
	mflo $t5
	move $a0, $t5 #row
	li $a2, 0x66 #char
	li $a3, 0x0C #foreground
	li $t2, 0x09 #background
	sw $t2, ($sp)
	jal set_cell
	addi $s1, $s1, 1
	addi $t8, $t8, 1
	j reveal_mapLoop
mapBombFound:
	li $t4, 0xF
	sub $t9, $s1, $s5
	li $t7, 10
	div $t9, $t7
	mfhi $t5
	move $a1, $t5 #col
	mflo $t5
	move $a0, $t5 #row
	li $a2, 0x42 #char
	li $a3, 0x07 #foreground
	li $t2, 0x00 #background
	sw $t2, ($sp)
	jal set_cell
	addi $s1, $s1, 1
	addi $t8, $t8, 1
	j reveal_mapLoop
mapNumberFound:
	addi $t2, $t2, 0x30
	li $t4, 0xF
	sub $t9, $s1, $s5
	li $t7, 10
	div $t9, $t7
	mfhi $t5
	move $a1, $t5 #col
	mflo $t5
	move $a0, $t5 #row
	la $a2, ($t2) #char
	li $a3, 0x0D #foreground
	li $t2, 0x00 #background
	sw $t2, ($sp)
	jal set_cell
	addi $s1, $s1, 1
	addi $t8, $t8, 1
	j reveal_mapLoop
blankFound:
	sub $t9, $s1, $s5
	li $t7, 10
	div $t9, $t7
	mfhi $t5
	move $a1, $t5 #col
	mflo $t5
	move $a0, $t5 #row
	li $a2, 0x00 #char
	li $a3, 0x0F #foreground
	li $t2, 0x00 #background
	sw $t2, ($sp)
	jal set_cell
	addi $s1, $s1, 1
	addi $t8, $t8, 1
	j reveal_mapLoop
revealEnd:
	lw $a0, cursor_row	#row
	lw $a1, cursor_col      #col
	li $a2, 0x45 #char
	li $a3, 0x0F #foreground
	li $t2, 0x09 #background
	sw $t2, ($sp)
	jal set_cell
	addi $sp, $sp, -4
	lw $ra, ($sp)
    jr $ra


##############################
# PART 4 FUNCTIONS
##############################

perform_action:
	sw $ra, ($sp)
	addi $sp, $sp, 4
	move $t0, $a1
	beq $t0, 0x77, action_up
	beq $t0, 0x57, action_up
	beq $t0, 0x64, action_right
	beq $t0, 0x44, action_right
	beq $t0, 0x61, action_left
	beq $t0, 0x41, action_left
	beq $t0, 0x73, action_down
	beq $t0, 0x53, action_down
	beq $t0, 0x66, action_toggle
	beq $t0, 0x46, action_toggle
	beq $t0, 0x72, action_reveal
	beq $t0, 0x52, action_reveal
	j invalidAction
action_up:
	lw $t0, cursor_row
	lw $t1, cursor_col
	bgt $t0, 0x00, actionUpSuccessful
	j invalidAction
actionUpSuccessful:
	move $a0, $t0	#row
	move $a1, $t1   #col
	li $a2, 0xFF #char
	li $a3, 0xFF #foreground
	li $t2, 0xFF #background
	sw $t2, ($sp)
	jal set_cell
	lw $t0, cursor_row
	addi $t0, $t0, -1
	sw $t0, cursor_row
	move $a0, $t0
	lw $t1, cursor_col
	move $a1, $t1
	li $a2, 0xFF #char
	li $a3, 0xFF #foreground
	li $t2, 0x0B #background
	sw $t2, ($sp)
	jal set_cell
	j actionSuccessful
action_right:
	lw $t0, cursor_row
	lw $t1, cursor_col
	blt $t1, 0x09, actionRightSuccessful
	j invalidAction
actionRightSuccessful:
	move $a0, $t0	#row
	move $a1, $t1   #col
	li $a2, 0xFF #char
	li $a3, 0xFF #foreground
	li $t2, 0xFF #background
	sw $t2, ($sp)
	jal set_cell
	lw $t0, cursor_row
	move $a0, $t0
	lw $t1, cursor_col
	addi $t1, $t1, 1
	sw $t1, cursor_col
	move $a1, $t1
	li $a2, 0xFF #char
	li $a3, 0xFF #foreground
	li $t2, 0x0B #background
	sw $t2, ($sp)
	jal set_cell
	j actionSuccessful
action_left:
	lw $t0, cursor_row
	lw $t1, cursor_col
	bgt $t1, 0x00, actionLeftSuccessful
	j invalidAction
actionLeftSuccessful:
	move $a0, $t0	#row
	move $a1, $t1   #col
	li $a2, 0xFF #char
	li $a3, 0xFF #foreground
	li $t2, 0xFF #background
	sw $t2, ($sp)
	jal set_cell
	lw $t0, cursor_row
	move $a0, $t0
	lw $t1, cursor_col
	addi $t1, $t1, -1
	sw $t1, cursor_col
	move $a1, $t1
	li $a2, 0xFF #char
	li $a3, 0xFF #foreground
	li $t2, 0x0B #background
	sw $t2, ($sp)
	jal set_cell
	j actionSuccessful
action_down:
	lw $t0, cursor_row
	lw $t1, cursor_col
	blt $t0, 0x09, actionDownSuccessful
	j invalidAction
actionDownSuccessful:
	move $a0, $t0	#row
	move $a1, $t1   #col
	li $a2, 0xFF #char
	li $a3, 0xFF #foreground
	li $t2, 0xFF #background
	sw $t2, ($sp)
	jal set_cell
	lw $t0, cursor_row
	addi $t0, $t0, 1
	sw $t0, cursor_row
	move $a0, $t0
	lw $t1, cursor_col
	move $a1, $t1
	li $a2, 0xFF #char
	li $a3, 0xFF #foreground
	li $t2, 0x0B #background
	sw $t2, ($sp)
	jal set_cell
	j actionSuccessful
action_toggle:
	la $t0, ($a0)			#
	lw $t1, cursor_row		#
	lw $t2, cursor_col		#
	li $t3, 0x0a			#
	mul $t3, $t3, $t1		# Finds current cell's info
	add $t3, $t3, $t2		#
	add $t0, $t0, $t3		#
	lb $t1, ($t0)			#
	li $t2, 0x40
	and $t2, $t2, $t1
	beq $t2, 0x40, invalidAction
	li $t2, 0x10
	and $t2, $t2, $t1
	beq $t2, 0x10, removeFlag
	beq $t2, 0x00, addFlag
	j invalidAction
removeFlag:
	lw $a0, cursor_row	#row
	lw $a1, cursor_col   #col
	li $a2, 0x00 #char
	li $a3, 0x08 #foreground
	li $t2, 0x0B #background
	sw $t2, ($sp)
	jal set_cell
	la $t0, cells_array		#
	lw $t1, cursor_row		#
	lw $t2, cursor_col		#
	li $t3, 0x0a			#
	mul $t3, $t3, $t1		# Finds current cell's info
	add $t3, $t3, $t2		#
	add $t0, $t0, $t3		#
	lb $t1, ($t0)			#
	li $t3, 0xEF
	and $t2, $t1, $t3
	sb $t2, ($t0)
	j actionSuccessful
addFlag:
	lw $a0, cursor_row	#row
	lw $a1, cursor_col   #col
	li $a2, 0x66 #char
	li $a3, 0x0C #foreground
	li $t2, 0x0B #background
	sw $t2, ($sp)
	jal set_cell
	la $t0, cells_array			#
	lw $t1, cursor_row		#
	lw $t2, cursor_col		#
	li $t3, 0x0a			#
	mul $t3, $t3, $t1		# Finds current cell's info
	add $t3, $t3, $t2		#
	add $t0, $t0, $t3		#
	lb $t1, ($t0)			#
	li $t3, 0xBF
	and $t2, $t1, $t3
	li $t3, 0x10
	or $t2, $t2, $t3
	sb $t2, ($t0)
	j actionSuccessful
action_reveal:
	la $t0, ($a0)
	lw $t1, cursor_row		#
	lw $t2, cursor_col		#
	li $t3, 0x0a			#
	mul $t3, $t3, $t1		# Finds current cell's info
	add $t3, $t3, $t2		#
	add $t0, $t0, $t3		#
	lb $t1, ($t0)			#
	li $t2, 0x40
	and $t2, $t2, $t1
	beq $t2, 0x40, invalidAction
	li $t2, 0x10
	and $t2, $t2, $t1
	beq $t2, 0x10, actionFlag
	li $t2, 0x20
	and $t2, $t2, $t1
	beq $t2, 0x20, actionBomb
	li $t2, 0x0F
	and $t2, $t2, $t1
	bgt $t2, 0x00, actionNumber
	j actionSpace
actionBomb:
	li $a0, -1
	jal reveal_map
	j exit
actionNumber:
	lb $t1, ($t0)
	addi $t1, $t1, 0x30				
	li $t3, 0x40
	or $t2, $t2, $t3
	sb $t2, ($t0)
	lw $a0, cursor_row   #row
	lw $a1, cursor_col   #col
	la $a2, ($t1) #char
	li $a3, 0x0D #foreground
	li $t2, 0x00 #background
	sw $t2, ($sp)
	jal set_cell
	j actionSuccessful
actionFlag:
	j actionSuccessful
actionSpace:
	jal search_cells
	j actionSuccessful
invalidAction:
	li $v0, -1
	addi $sp, $sp, -4
	lw $ra, ($sp)
	jr $ra
actionSuccessful:
	li $v0, 0
	addi $sp, $sp, -4
	lw $ra, ($sp)
	jr $ra
	
game_status:
	
	lb $t0, ($a1)
	
    jr $ra

##############################
# PART 5 FUNCTIONS
##############################

search_cells:
	sw $ra, ($sp)
	addi $sp, $sp, 4
    	la $fp, ($sp)
    	addi $sp, $sp, 4
    	lw $t0, cursor_row
    	sw $t0, ($sp)
    	addi $sp, $sp, 4
    	lw $t0, cursor_col
    	sw $t0, ($sp)
    	la $t4, cells_array
searchCellsWhile:
	beq $fp, $sp, endSearchCells
	lw $s3, ($sp)	#col
	addi $sp, $sp, -4
	lw $s2, ($sp)	#row
	addi $sp, $sp, -4
	li $t3, 0x0a			#
	la $t4, cells_array
	mul $t3, $t3, $s2		# Finds current cell's info
	add $t3, $t3, $s3		#
	add $t4, $t4, $t3		#
	lb $t1, ($t4)			#
	li $t5, 0x10
	and $t5, $t5, $t1
	bne $t5, 0x10, searchReveal
searchCellsWhileCont:
	li $t3, 0x0a			#
	la $t4, cells_array
	mul $t3, $t3, $s2		# Finds current cell's info
	add $t3, $t3, $s3		#
	add $t4, $t4, $t3		#
	lb $t1, ($t4)			#           #possible error $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	andi $t0, $t1, 0x0F
	beq $t0, 0x00, searchCellsWhileInner
	j searchCellsWhile
searchCellsWhileInner:
	addi $t0, $s2, 1
	blt $t0, 10, sCWITerm1  #if (row + 1 < 10 && cell[row + 1][col].isHidden() && !cell[row + 1][col].isFlag())
	j sCWITerm2
sCWITerm1: 
	li $t3, 0x0a			#
	la $t4, cells_array
	mul $t3, $t3, $t0		# Finds current cell's info
	add $t3, $t3, $s3		#
	add $t4, $t4, $t3		#
	lb $t1, ($t4)			#
	andi $t2, $t1, 0x40
	beq $t2, 0x00, sCWI1
	j sCWITerm2
sCWI1:
	andi $t2, $t1, 0x10
	bne $t2, 0x10, sCWI2
	j sCWITerm2
sCWI2:
	addi $sp, $sp, 4
	sw $t0, ($sp)
	addi $sp, $sp, 4
	sw $s3, ($sp)
################################################################################################################
sCWITerm2: #if (row + 1 < 10 && cell[row][col + 1].isHidden() && !cell[row][col + 1].isFlag())
	addi $t0, $s3, 1
	blt $t0, 10, sCWI3  
	j sCWITerm3
sCWI3: 
	#addi $t0, $s3, 1
	li $t3, 0x0a			#
	la $t4, cells_array
	mul $t3, $t3, $s2		# Finds current cell's info
	add $t3, $t3, $t0		#
	add $t4, $t4, $t3		#
	lb $t1, ($t4)			#
	andi $t2, $t1, 0x40
	beq $t2, 0x00, sCWI4
	j sCWITerm3
sCWI4: 
	andi $t2, $t1, 0x10
	bne $t2, 0x10, sCWI5
	j sCWITerm3
sCWI5:
	addi $sp, $sp, 4
	sw $s2, ($sp)
	addi $sp, $sp, 4
	sw $t0, ($sp)
################################################################################################################
sCWITerm3: #if (row - 1 >= 0 && cell[row - 1][col].isHidden() && !cell[row - 1][col].isFlag())
	addi $t0, $s2, -1
	bge $t0, 0, sCWI6  
	j sCWITerm4
sCWI6: 
	li $t3, 0x0a			#
	la $t4, cells_array
	mul $t3, $t3, $t0		# Finds current cell's info
	add $t3, $t3, $s3		#
	add $t4, $t4, $t3		#
	lb $t1, ($t4)			#
	andi $t2, $t1, 0x40
	beq $t2, 0x00, sCWI7
	j sCWITerm4
sCWI7: 
	andi $t2, $t1, 0x10
	bne $t2, 0x10, sCWI8
	j sCWITerm4
sCWI8:
	addi $sp, $sp, 4
	sw $t0, ($sp)
	addi $sp, $sp, 4
	sw $s3, ($sp)
################################################################################################################
sCWITerm4: #if (row - 1 >= 0 && cell[row][col - 1].isHidden() && !cell[row][col - 1].isFlag()
	addi $t0, $s3, -1
	bge $t0, 0, sCWI9  
	j sCWITerm5
sCWI9: 
	#addi $t0, $s3, -1
	li $t3, 0x0a			#
	la $t4, cells_array
	mul $t3, $t3, $s2		# Finds current cell's info
	add $t3, $t3, $t0		#
	add $t4, $t4, $t3		#
	lb $t1, ($t4)			#
	andi $t2, $t1, 0x40
	beq $t2, 0x00, sCWI10
	j sCWITerm5
sCWI10: 
	andi $t2, $t1, 0x10
	bne $t2, 0x10, sCWI11
	j sCWITerm5
sCWI11:
	addi $sp, $sp, 4
	sw $s2, ($sp)
	addi $sp, $sp, 4
	sw $t0, ($sp)
################################################################################################################
sCWITerm5: #if (row - 1 >= 0 && col - 1 >= 0) && cell[row - 1][col - 1].isHidden()
	addi $t0, $s2, -1
	bge $t0, 0, sCWI12
	j sCWITerm6
sCWI12:
	addi $t5, $s3, -1
	bge $t5, 0, sCWI13
	j sCWITerm6
sCWI13: 
	li $t3, 0x0a			#
	la $t4, cells_array
	mul $t3, $t3, $t0		# Finds current cell's info
	add $t3, $t3, $t5		#
	add $t4, $t4, $t3		#
	lb $t1, ($t4)			#
	andi $t2, $t1, 0x40
	beq $t2, 0x00, sCWI14
	j sCWITerm6
sCWI14: 
	andi $t2, $t1, 0x10
	bne $t2, 0x10, sCWI15
	j sCWITerm6
sCWI15:
	addi $sp, $sp, 4
	sw $t0, ($sp)
	addi $sp, $sp, 4
	sw $t5, ($sp)
################################################################################################################
sCWITerm6: #if (row - 1 >= 0 && col + 1 < 10 and cell[row - 1][col + 1].isHidden()
	addi $t0, $s2, -1
	bge $t0, 0, sCWI16
	j sCWITerm7
sCWI16:
	addi $t5, $s3, 1
	blt $t5, 10, sCWI17
	j sCWITerm7
sCWI17: 
	li $t3, 0x0a			#
	la $t4, cells_array
	mul $t3, $t3, $t0		# Finds current cell's info
	add $t3, $t3, $t5		#
	add $t4, $t4, $t3		#
	lb $t1, ($t4)			#
	andi $t2, $t1, 0x40
	beq $t2, 0x00, sCWI18
	j sCWITerm7
sCWI18: 
	andi $t2, $t1, 0x10
	bne $t2, 0x10, sCWI19
	j sCWITerm7
sCWI19:
	addi $sp, $sp, 4
	sw $t0, ($sp)
	addi $sp, $sp, 4
	sw $t5, ($sp)
################################################################################################################
sCWITerm7: #if (row + 1 < 10 && col - 1 >= 0 && cell[row + 1][col - 1].isHidden()
	addi $t0, $s2, 1
	blt $t0, 10, sCWI20
	j sCWITerm8
sCWI20:
	addi $t5, $s3, -1
	bge $t5, 0, sCWI21
	j sCWITerm8
sCWI21: 
	li $t3, 0x0a			#
	la $t4, cells_array
	mul $t3, $t3, $t0		# Finds current cell's info
	add $t3, $t3, $t5		#
	add $t4, $t4, $t3		#
	lb $t1, ($t4)			#
	andi $t2, $t1, 0x40
	beq $t2, 0x00, sCWI22
	j sCWITerm8
sCWI22: 
	andi $t2, $t1, 0x10
	bne $t2, 0x10, sCWI23
	j sCWITerm8
sCWI23:
	addi $sp, $sp, 4
	sw $t0, ($sp)
	addi $sp, $sp, 4
	sw $t5, ($sp)
################################################################################################################
sCWITerm8: #if (row + 1 < 10 && col + 1 < 10 && cell[row + 1][col + 1].isHidden()
	addi $t0, $s2, 1
	blt $t0, 10, sCWI24
	j searchCellsWhile
sCWI24:
	addi $t5, $s3, 1
	blt $t5, 10, sCWI25
	j searchCellsWhile
sCWI25: 
	li $t3, 0x0a			#
	la $t4, cells_array
	mul $t3, $t3, $t0		# Finds current cell's info
	add $t3, $t3, $t5		#
	add $t4, $t4, $t3		#
	lb $t1, ($t4)			#
	andi $t2, $t1, 0x40
	beq $t2, 0x00, sCWI26
	j searchCellsWhile
sCWI26: 
	andi $t2, $t1, 0x10
	bne $t2, 0x10, sCWI27
	j searchCellsWhile
sCWI27:
	addi $sp, $sp, 4
	sw $t0, ($sp)
	addi $sp, $sp, 4
	sw $t5, ($sp)
	j searchCellsWhile
searchReveal:
	andi $t6, $t1, 0x0F
	bgt $t6, 0x00, searchRevealNum
	j searchRevealSpace
searchRevealNum:	
	addi $t6, $t6, 0x30
searchRevealSpace:
	la $a0, ($s2)
	la $a1, ($s3)
	la $a2, ($t6) #char
	li $a3, 0x0D #foreground
	li $t2, 0x00 #background
	addi $sp, $sp, 4
	sw $t2, ($sp)
	jal set_cell
	addi $sp, $sp, -4
	li $t3, 0x0a			#
	la $t4, cells_array
	mul $t3, $t3, $s2		# Finds current cell's info
	add $t3, $t3, $s3		#
	add $t4, $t4, $t3		#
	lb $t1, ($t4)			#
	ori $t1, $t1 ,0x40
	sb $t1, ($t4)
	j searchCellsWhileCont
endSearchCells:
	addi $sp, $sp, -4
	lw $ra, ($sp)
	jr $ra


#################################################################
# Student defined data section
#################################################################
.data
.align 2  # Align next items to word boundary
cursor_row: .word -1
cursor_col: .word -1

#place any additional data declarations here

