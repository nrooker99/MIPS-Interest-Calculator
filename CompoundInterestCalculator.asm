# Author: Nicholas Rooker
# ID: 800622566

.data

INPUT_MSG_1: .asciiz "Enter the principle:  "
INPUT_MSG_2: .asciiz "Enter the interest rate (0.001 < interest < 0.40, 0.01 for 1%): "
INPUT_MSG_3: .asciiz "Enter the target balance: "
INPUT_MSG_4: .asciiz "Number of the last years for display: "

YEAR: .asciiz "year "
COLON: .asciiz ": "
EXIT_STATEMENT: .asciiz "It takes "
YEARS: .asciiz " years. "

INVALID_INPUT: .asciiz "Your input is invalid. Please try again."

MIN_PRINCIPLE_VAL: .float 100.00
MAX_PRINCIPLE_VAL: .float 100000.99

MIN_INTEREST_VAL: .float 0.001
MAX_INTEREST_VAL: .float 0.40

ZERO: .float 0.00

NEW_LINE: .asciiz "\n"

.text
.globl main

main:

	la $a0, MIN_PRINCIPLE_VAL			
        lwc1 $f1, ($a0)				

	la $a0, MIN_INTEREST_VAL	
        lwc1 $f2, ($a0)			

	la $a0, MAX_INTEREST_VAL
	lwc1 $f3, ($a0)
	
input_1:

	li $v0, 4
	la $a0, INPUT_MSG_1
	syscall				# Prompt user for first input

	li $v0, 6			# Take input from keyboard
	syscall

	mov.s $f4, $f0

	c.lt.s $f4, $f1			# If principal is less than minimum, branch to invalid_input_1
	bc1t invalid_input_1

	li.s $f5, 100000.99

	c.lt.s $f5, $f4			# If principal is greater than maximum, branch to invalid_input_1
	bc1t invalid_input_1

	j input_2

invalid_input_1:

	li $v0, 4
	la $a0, INVALID_INPUT
	syscall

	li $v0, 4
	la $a0, NEW_LINE
	syscall

	j input_1
					

input_2:

	li $v0, 4
	la $a0, INPUT_MSG_2
	syscall				# Prompt user for second input

	li $v0, 6			# Take input from keyboard
	syscall

	mov.s $f5, $f0

	c.lt.s $f5, $f2			# If interest is less than zero, branch to invalid_input_2
	bc1t invalid_input_2

	c.lt.s $f3, $f5
	bc1t invalid_input_2 

	j input_3

invalid_input_2:

	li $v0, 4
	la $a0, INVALID_INPUT
	syscall

	li $v0, 4
	la $a0, NEW_LINE
	syscall

	j input_2

input_3:

	li $v0, 4
	la $a0, INPUT_MSG_3
	syscall				# Prompt user for third input

	li $v0, 6			# Take input from keyboard
	syscall

	mov.s $f6, $f0			# Copy input to $f4 register

	c.lt.s $f6, $f4			# If target balance is less than zero, branch to invalid_input_3
	bc1t invalid_input_3

	j input_4

invalid_input_3:

	li $v0, 4
	la $a0, INVALID_INPUT
	syscall

	li $v0, 4
	la $a0, NEW_LINE
	syscall

	j input_3

input_4:

	li $v0, 4
	la $a0, INPUT_MSG_4
	syscall

	li $v0, 5
	syscall

	move $s0, $v0
	
	j main_2		

invalid_input_4:

	li $v0, 4
	la $a0, INVALID_INPUT
	syscall

	li $v0, 4
	la $a0, NEW_LINE
	syscall

	j main_2

main_2:
	
	li $s1, 0		# recursive 'loop' counter

	jal recursion

recursion:
	
	subu $sp, $sp, 20	# creating stack frame

	sw $ra, 0($sp)		# saving $ra register

	swc1 $f4, 4($sp)	# saving other GPR's
	swc1 $f5, 8($sp)
	swc1 $f6, 12($sp)
	sw $s0, 16($sp)
	sw $s1, 20($sp)
	
	c.lt.s $f6, $f4		# base case: if principle is greater than target balance, stop recursing
	bc1t recursion_done

	add $s1, $s1, 1		# i think this is like a recursive function call?
	
	mul.s $f7, $f4, $f5	# multiplying interest rate * principal
	add.s $f4, $f4, $f7	# compound to principle

	blt $s0, $zero, print_all	# if numYears input is -1, then skip the stop_printing conditional branch

	blt $s0, $s1, stop_printing	# making sure program only prints years you want it to

	print_all:

	li $v0, 4
	la $a0, YEAR
	syscall

	li $v0, 1
	move $a0, $s1
	syscall

	li $v0, 4
	la $a0, COLON
	syscall			

	li $v0, 2
	mov.s $f12, $f4
	syscall

	li $v0, 4
	la $a0, NEW_LINE
	syscall
	
	stop_printing:

		jal recursion
		j exit_program

	recursion_done:	
		
		lwc1 $f4, 4($sp)		# restoring registers
		lwc1 $f5, 8($sp)
		lwc1 $f6, 12($sp)
		lw $s0, 16($sp)
		lw $s1, 20($sp)
		
		lw $ra, 0($sp)	

		addu $sp, $sp, 20		# restore stack frame
		
		jr $ra
		
exit_program:

	li $v0, 4
	la $a0, EXIT_STATEMENT
	syscall

	li $v0, 1
	move $a0, $s1
	syscall

	li $v0, 4
	la $a0, YEARS
	syscall

	li $v0, 10				# program would cycle infinitely through exit_program so I just put this there and now it works fine
	syscall

	jr $31







