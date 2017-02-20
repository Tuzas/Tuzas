.data
	message: .asciiz "Choose a number to count up to using the Fibonacci Sequence"
	newline: .asciiz "\n"
.text

main:
	la $a0, message
	li $v0, 51	#     prints message
	syscall
	move $s0, $a0   #     count up to
	li $s1, 0 	#     counter
	li $s2, 1       #     currentNumber
	li $s3, 0       #     previousNumber
	
loop:
	move $a0, $s2   #     load current number into argument 1
	li $v0, 1 
	syscall         #     print current number
	add $s2, $s2, $s3 #   add current and previous
	sub $s3, $s2, $s3 #   subtract previous from current, get previous number
	
	la $a0, newline
	li $v0, 4	  #   print new line 
        syscall
	
	add $s1, $s1, 1   #   counter incrementation
	ble $s0, $s1, exit #  compares counter to user input 
	j loop

exit:
li $v0, 10
syscall