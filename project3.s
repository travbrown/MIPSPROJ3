.data 
	input_too_long: .asciiz "Input is too long."
	user_input: .space 1000
	input_empty: .asciiz "Input is empty."
	wrong_base: .asciiz "Invalid base-31 number."	
.text
main:
        # the above sectionis he Data declaration section
        # where we declare the  pre-defined string that we know we are going to use

	# getting user input
	li $v0, 8			# initiates the read string system  call 
	la $a0, user_input		# load the address for the space set aside for the user input
	li $a1, 1000			# space expected
	syscall                         # calls the OS to execute                        
		
	addi $s5, $0, 0 	        # Initializing registers
	addi $t3, $0, 0                 # Initializing registers
	addi $s1, $0, 0                 # Initializing registers

	                                # empty input check
        la $t1, user_input              # set pointer
        lb $s5, 0($t1)                  # load first element of string into register
        beq $s5, 10, empty_error        # Check for new line
        beq $s5, 0, empty_error
	
	addi $s2, $0, 31                # Set Base number
        addi $t5, $0, 0                 # Initializing registers
        addi $s7, $0, 1			# Initialize register as 1 for exponent
        addi $t6, $0, 0                 # Initializing registers
        addi $t8, $0, 0                 # Initializing registers

space_processing:			# this label skips the spaces in the string until we find the irst character
	lb $s5, 0($t1)			# load character pointer is at into the register t7
	addi $t1, $t1, 1		# incrementing pointer
        addi $t3, $t3, 1		# incrementing pointer_tracker
        beq $s5, 32, space_processing   # loop and move forward if space detected
        beq $s5, 10, empty_error        # branches to Empty_error label if new line found
        beq $s5, $0, empty_error	# If a character is next, it will move on to next label automatically


char_processing:			# This label will skips over the char until a space, new line or nothing is detected 
        lb $s5, 0($t1)			# load byte where the pointer is
        addi $t1, $t1, 1		# incrementing pointer
        addi $t3, $t3, 1		# incrementing pointer-tracker
        addi $t8, $t8, 1		# increment counter
        beq $s5, 10, return_to_start    # If we find a new line or nothing branch to return to start
        beq $s5, 0, return_to_start	# branch if the byte is equal to nothing
        bne $s5, 32, char_processing    # If it is NOT a space is found, then it  loops


char_space_processing:			# At this point, we are checking if we are going to find only space
        lb $s5, 0($t1)			# or another set of characters.
        addi $t1, $t1, 1		# incrementing pointer		
        addi $t3, $t3, 1		# incrementing pointer-tracker
        addi $t8, $t8, 1		# increment counter
        beq $s5, 10, return_to_start    # If string is finished branch to return to start
        beq $s5, 0, return_to_start     # branch if the byte is equal to nothing
        bne $s5, 32, invalid_base_or_len # will check for invalid length or default to invalid base.
        j char_space_processing         # loops until it branches to one of the above mentioned labels


return_to_start:                        # the label name return_to_start
        sub $t1, $t1, $t3               # restart the pointer in character array
        la $t3, 0                       # restart the counter

move_forward:                           # the label name move_forward
        lb $s5, 0($t1)			# Skipping the spaces at the begin of the input (if any)
        addi $t1, $t1, 1		# to get to the first char in the string
        beq $s5, 32, move_forward	# this line stops iteratinng the string when it detects a letter

addi $t1, $t1, -1 			# re-aligning the pointer with the first letter we loaded and then detected

find_length:                            # loops until the incrementing counter hits 5
        lb $s5, ($t1)			# and then it would give error message
        addi $t1, $t1, 1		# otherwise the input's length is valid
        addi $t3, $t3, 1                # this line increments the pointer-tracker
	beq $s5, 10, reset_ptr		# Checking for the end of the sequence of letters
        beq $s5, 0, reset_ptr           # branch if the byte is equal to nothing
        beq $s5, 32, reset_ptr          # branch if the byte is equal to a space
        beq $t3, 5, too_long_error	# branch if the pointer trackerhas moved more times than the input  is  allowed to be in length
        j find_length                   # jump to the label find_length

reset_ptr:                              # resetting the  pointer to the start of the string
        sub $t1, $t1, $t3               # subtracting the pointer-tra ker from the pointer
        sub $t3, $t3, $s7		# this line brings the counter for the length to its correct place
        lb $s5, 0($t1)			# load first byte
        sub $s4, $t3, $s7		# decremented and set the highest power for this paarticular length of valid string

	move $s6, $t3			# place length of input in an s register so it doesn't get changed after calling a subprogram

find_highest_power:                     # the label name find_highest_power
	beq $s4, 0, finishing_up          # Determing the highest power
        mult $s7, $s2			# Multiplying to the highest power
        mflo $s7			# until the counter = 0
        sub $s4, $s4, 1			# decrement the length register
        j find_highest_power            # Jump to the find_highest_power label

finishing_up:                           # the label name finishing_up
	addi $sp, $sp, -16	        # allocate memory
	sw $s5, 0($sp)	                # store the character
	sw $t1, 4($sp)                  # storing string address
	sw $s1, 8($sp)                  # memory allocated for the power
	sw $s6, 12($sp)                 # for the length string
        
        jal conversion                  # jump and link to the conversion label
	
        lw $a0, 0($sp)                  # unload the value $a0 to use
	addi $sp, $sp, 4                # memory deallocation of the stack
        
        li $v0, 1                       # prints contents of a0
        syscall                         # calls the OS to execute
        
        li $v0, 10                       # Successfully ends program
        syscall                         # calls the OS to execute

.globl conversion
conversion:                             # unloading the following below
        lw $s5, 0($sp)                  # current char
	lw $t1, 4($sp)                  # string address
	lw $s1, 8($sp)                  # current power
	lw $s6, 12($sp)                 # string length
	addi $sp, $sp, 16               # deallocating the memory

        addi $sp, $sp, -8		# allocate memory
        sw $ra, 0($sp)			# store the return address
        sw $s5, 4($sp)			# store the new

        beq $s1, $s6, finisha		# base case for recursion
        lb $s5, 0($t1)                  # loading the byte

        addi $t1, $t1, 1	# incremental loading of pointer, iterating across input
	addi $s1, $s1, 1	# increment counter

        blt $s5, 48, incorrect_base_error       # checks if character is before 0 in ASCII chart
        blt $s5, 58, Number                     # checks if character is between 48 and 57
        blt $s5, 65, incorrect_base_error       # checks if character is between 58 and 64
	blt $s5, 86, Upper_Case                 # checks if character is between 65 and 85
        blt $s5, 97, incorrect_base_error       # checks if character is between 76 and 96
        blt $s5, 118, Lower_Case                # checks if character is between 97 and 117
        blt $s5, 128, incorrect_base_error      # checks if character is between 118 and 127

        Upper_Case:                     # the label name Upper_Case
                addi $s5, $s5, -55	# subtraction is done like this to the ASCII to get the value of the char
                j next_step		# like ASCII 'A' = 65 & 'A' in base 31 = 10
                                                # so 65 - 55 = 10
        Lower_Case:                     # the label name Lower_Case
                addi $s5, $s5, -87	# same is done for lower case but not for numbers
                j next_step              # jump to next_step
        Number:                         # the label name Number
                addi $s5, $s5, -48       # subtract the exact value to get the exact number    
                j next_step             # jump to next_step

        next_step:
		mul $s5, $s5, $s7	# value of letter times corresponding base^y
        	div $s7, $s7, 31	# decreasingthe exponent of the register holding the highest power
        	
		addi $sp, $sp, -16             # allocating memory
		sw $s5, 0($sp)          # curr char
		sw $t1, 4($sp)          # string address
		sw $s1, 8($sp)          # current power (initialized to 1)
		sw $s6, 12($sp)         # length string                

                jal conversion          # Jump & link to the conversion lable

                lw $v0, 0($sp)          # return the value from the stack into the register
                addi $sp, $sp, 4               # deallocating the memory
                add $v0, $s5, $v0			# adding up the rest of the calculation for the input
                
                lw $ra, 0($sp)				# reload so we can return them
                lw, $s5, 4($sp)			     # return the value from the stack into the register
                addi $sp, $sp, 8			# freeing up $sp, deallocating memory
                
                addi $sp, $sp, -4                       #allocating the memory
                sw $v0, 0($sp)                  # storing the value of $v0 into the stack

                jr $ra					# jump return

                finisha:                        # the label name
                        li $v0, 0	                               
                        lw $ra, 0($sp)				# reload so we can return them
                        lw $s5, 4($sp)				# return the value from the stack into the register
                        addi $sp, $sp, 8			# freeing up $sp, deallocating memory
                        addi $sp, $sp, -4                       # memory allocation
                        sw $v0, 0($sp)                  # storing the value of $v0 into the stack 
                        jr $ra                          # jump and return to the return address currently in the register

# Error Branches

too_long_error:                 # the label name too_long_error
	la $a0, input_too_long  # loads string
        li $v0, 4               # Specifies print string system call
        syscall                 # calls the OS to execute

        li $v0, 10              # ends program
        syscall                 # calls the OS to execute

incorrect_base_error:           # the label name incorrect_base_error
	la $a0, wrong_base      # loads string
        li $v0, 4               # Specifies print string system call
        syscall                 # calls the OS to execute

        li $v0,10               # ends program
        syscall                 # calls the OS to execute

empty_error:                     # the label name empty_error
        la $a0, input_empty     # loads string
        li $v0, 4               # Specifies print string system call
        syscall                 # calls the OS to execute

	li $v0,10               # ends program
        syscall                 # calls the OS to execute

invalid_base_or_len:	                # the label name invalid_base_or_len
	bge $t8, 4, too_long_error	# checks if too long	
	j incorrect_base_error	        # defaults to Invalid base if not too long
        
	jr $ra                         #  jump and return to the return address currently in the register
