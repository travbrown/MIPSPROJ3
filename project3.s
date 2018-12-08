.data
	input_too_long: .asciiz "Input is too long."
	user_input: .space 1000
	input_empty: .asciiz "Input is empty."
	wrong_base: .asciiz "Invalid base-31 number."	
.text
main:
	# getting user input
	
	li $v0, 8
	la $a0, user_input
	li $a1, 1000
	syscall
		
	add $t7, $0, 0 			# Initializing registers
	add $t3, $0, 0 

	                                # empty input check
        la $t1, user_input              # set pointer
        lb $t7, 0($t1)                  # load first element of string into register
        beq $t7, 10, empty_error        # Check for new line
        beq $t7, 0, empty_error
	
	addi $s2, $0, 31                # Set Base number
        addi $t5, $0, 0
        addi $t4, $0, 1
        addi $t6, $0, 0

space_processing:
	lb $t7,0($t1)
	addi $t1, $t1, 1
        addi $t3, $t3, 1
        beq $t7, 32, space_processing   # loop and move forward if space detected
        beq $t7, 10, empty_error        # branches to Empty_error label if new line found
        beq $t7, $0, empty_error
                                        # if a character is next, it will move on to next label automatically
char_processing:
         lb $t7,0($t1)
        addi $t1, $t1, 1
        addi $t3, $t3, 1
        beq $t7, 10, return_to_start    # If string is finished branch to return to start
        beq $t7, 0, return_to_start
        bne $t7, 32, char_processing    # If it is NOT a space is found, then it  loops

char_space_processing:
        lb $t7,0($t1)
        addi $t1, $t1, 1
         addi $t3, $t3, 1
         beq $t7, 10, return_to_start    # If string is finished branch to return to start
         beq $t7, 0, return_to_start
         bne $t7, 32, incorrect_base_error
         j char_space_processing         # loops until it branches to one of the above mentionedlabels

return_to_start:
        sub $t1, $t1, $t3               # restart the pointer in character array
        la $t3, 0                       # restart the counter

move_forward:
        lb $t7, 0($t1)
        addi $t1, $t1, 1
        beq $t7, 32, move_forward

addi $t1, $t1, -1

find_length:                            # determine if the length of the string is valid
        lb $t7, ($t1)
        addi $t1, $t1, 1
        addi $t3, $t3, 1
	beq $t7, 10, reset_ptr
        beq $t7, 0, reset_ptr
        beq $t7, 32, reset_ptr
        beq $t3, 5, too_long_error
        j find_length

reset_ptr:                              # resetting the  pointer to the start of the string
        sub $t1, $t1, $t3
        sub $t3, $t3, $t4
        lb $t7, ($t1)
        sub $s4, $t3, $t4	

find_highest_power:
	beq $s4, 0, conversion          # Determing the highest power
        mult $t4, $s2
        mflo $t4
        sub $s4, $s4, 1
        j find_highest_power

multiply:
        mult $t7, $t4
        mflo $t5                        # sub_sum
        add $t6, $t6, $t5               # final sum

	beq $t4, 1, exit
        div $t4, $s2                    # dividing t4 to the next power of base
        mflo $t4
        add $t1, $t1, 1
        lb $t7, 0($t1)
	j conversion

exit:
	move $a0, $t6                   # moves sum to a0
        li $v0, 1                       # prints contents of a0
        syscall
        li $v0,10                       # Successfully ends program
        syscall

conversion:
        blt $t7, 48, incorrect_base_error       # checks if character is before 0 in ASCII chart
        blt $t7, 58, Number                     # checks if character is between 48 and 57
        blt $t7, 65, incorrect_base_error       # checks if character is between 58 and 64
	blt $t7, 86, Upper_Case                 # checks if character is between 65 and 85
        blt $t7, 97, incorrect_base_error       # checks if character is between 76 and 96
        blt $t7, 118, Lower_Case                # checks if character is between 97 and 117
        blt $t7, 128, incorrect_base_error      # checks if character is between 118 and 127

Upper_Case:
        addi $t7, $t7, -55
        j multiply

Lower_Case:
        addi $t7, $t7, -87
        j multiply
Number:
        addi $t7, $t7, -48
        j multiply

# Error Branches

too_long_error:
	la $a0, input_too_long
        li $v0, 4
        syscall

        li $v0, 10
        syscall

incorrect_base_error:
	la $a0, wrong_base      # loads string
        li $v0, 4               # Specifies print string system call
        syscall

        li $v0,10               # ends program
        syscall

empty_error:
        la $a0, input_empty     # loads string
        li $v0, 4               # Specifies print string system call
        syscall

	li $v0,10               # ends program
        syscall
        
	jr $ra



