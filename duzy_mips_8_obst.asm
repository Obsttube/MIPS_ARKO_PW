#---------------------------------------------------------------------------------------
# author: Zbigniew Szymanski (file reading and checking pixels), modified by Piotr Obst
# data : 2018.05.07, 2020.11.22
# description : "Big" MIPS project - finding 8th-type marker in a BMP file 
#---------------------------------------------------------------------------------------

# only 24-bits 320x240 pixels BMP files are supported
.eqv IMAGE_W 320
.eqv IMAGE_H 240
.eqv BMP_FILE_SIZE 230454
.eqv BYTES_PER_ROW 960

	.data
# space for the 320x240px 24-bits bmp image
.align 4
pix_arr_adr:	.space 2
image:		.space BMP_FILE_SIZE
markers:	.space 200	# x0, y0, x1, y1, ..., x49, y49 - half words, so 2x number of bytes. 50 markers.
num_of_markers:	.half 0
msg_file_error:	.asciiz "Couldn't open the file or file not found."
msg_found:	.asciiz "Found markers at:"
msg_not_found:	.asciiz "No markers found."
msg_x:		.asciiz "\nx = "
msg_y:		.asciiz ", y = "
msg_y2:		.asciiz " (y from the bottom = "
msg_y3:		.asciiz ")"
msg_separator:	.asciiz ", "
msg_end_line:	.asciiz "\n"

fname:	.asciiz "input.bmp"	# example_markers.bmp
	.text
main:
	jal	read_bmp
	beq	$v0, -1, main_file_error
        
        li	$s0, 3		# current x (we can ommit first 3)
        li	$s1, 0		# current y
        li	$s2, IMAGE_H	# variable used for the loop
        sub	$s2, $s2, 1	# we can ommit last 1 pixel
        
main_markers_loop:
        move	$a0, $s0	# x
	move	$a1, $s1	# y
	jal     check_marker
	add	$s0, $s0, 1	# increment current x
	blt	$s0, IMAGE_W, main_markers_loop	# move right if image border nor reached
	add	$s1, $s1, 1	# increment current y
	li	$s0, 3		# move current x to begining
	blt	$s1, $s2, main_markers_loop	# move up if image border nor reached (we can ommit last 1 pixel)
	
	jal     print_markers	# print marker coordinates as stated in the excercise
	#jal     print_markers_human	# print it in a more human-readable style

exit:	li 	$v0,10		# Terminate the program
	syscall

main_file_error:
	la	$a0, msg_file_error	# address of the string
	li	$v0, 4		# system call for print_string
        syscall
        j	exit

# ============================================================================
print_markers_human:
# description: 
#	prints all markers from the markers array with pretty description
# arguments: none
# returns: nothing

	sub	$sp, $sp, 4
	sw	$ra,4($sp)		# push $ra to the stack
        
        lh	$t1, num_of_markers	# $t1 = num_of markers
        beq	$t1, 0, print_h_no_markers	# jump if there are no markers to print
        li	$t4, IMAGE_H		# load image height to $t4
        sub	$t4, $t4, 1		# $t4 is used for calculating y from the top. We have to subtract 1
        la	$t0, markers		# $t0 = address of the markers array
        li	$t2, 0			# current index
        
        la	$a0, msg_found		# address of the string
	li	$v0, 4			# system call for print_string
        syscall
        
print_h_loop:
        lh	$t3, ($t0)		# load x from the array
        
        la	$a0, msg_x		# address of the string "\nx = "
	li	$v0, 4			# system call for print_string
        syscall
        move	$a0, $t3		# int to print (x)
	li	$v0, 1			# system call for print_int
        syscall
        
        lh	$t3, 2($t0)		# load y from the array
        
        la	$a0, msg_y		# address of the string ", y = "
	li	$v0, 4			# system call for print_string
        syscall
        sub	$t5, $t4, $t3		# calculate y from the top
        move	$a0, $t5		# int to print (y from the top)
	li	$v0, 1			# system call for print_int
        syscall
        
        la	$a0, msg_y2		# address of the string " (y from the bottom = "
	li	$v0, 4			# system call for print_string
        syscall
        
        move	$a0, $t3		# int to print (y from the bottom)
	li	$v0, 1			# system call for print_int
        syscall
        la	$a0, msg_y3		# address of the string ")"
	li	$v0, 4			# system call for print_string
        syscall
        
        add	$t0, $t0, 4		# move to the next x
        add	$t2, $t2, 1		# increment current index
        blt	$t2, $t1, print_h_loop	# jump if there are still more markers left to print
        
print_h_exit:
	lw	$ra, 4($sp)		# restore (pop) $ra
	add	$sp, $sp, 4
	jr	$ra

print_h_no_markers:
	la	$a0, msg_not_found	# address of the string "No markers found."
	li	$v0, 4			# system call for print_string
        syscall
        j	print_exit		# exit

# ============================================================================
print_markers:
# description: 
#	prints all markers from the markers array with pretty description
# arguments: none
# returns: nothing

	sub	$sp, $sp, 4
	sw	$ra,4($sp)		# push $ra to the stack
        
        lh	$t1, num_of_markers	# $t1 = num_of markers
        beq	$t1, 0, print_no_markers	# jump if there are no markers to print
        li	$t4, IMAGE_H		# load image height to $t4
        sub	$t4, $t4, 1		# $t4 is used for calculating y from the top. We have to subtract 1
        la	$t0, markers		# $t0 = address of the markers array
        li	$t2, 0			# current index
  
print_loop:
        lh	$t3, ($t0)		# load x from the array
        
        move	$a0, $t3		# int to print (x)
	li	$v0, 1			# system call for print_int
        syscall
        
        lh	$t3, 2($t0)		# load y from the array
        
        la	$a0, msg_separator	# address of the string ", "
	li	$v0, 4			# system call for print_string
        syscall
        sub	$t5, $t4, $t3		# calculate y from the top
        move	$a0, $t5		# int to print (y from the top)
	li	$v0, 1			# system call for print_int
        syscall
        
        la	$a0, msg_end_line	# address of the string "\n"
	li	$v0, 4			# system call for print_string
        syscall
        
        add	$t0, $t0, 4		# move to the next x
        add	$t2, $t2, 1		# increment current index
        blt	$t2, $t1, print_loop	# jump if there are still more markers left to print
        
print_exit:
	lw	$ra, 4($sp)		# restore (pop) $ra
	add	$sp, $sp, 4
	jr	$ra

print_no_markers:
	la	$a0, msg_not_found	# address of the string "No markers found."
	li	$v0, 4			# system call for print_string
        syscall
        j	print_exit		# exit

# ============================================================================
check_marker:
# description: 
#	adds marker coordinates to 'markers' when marker exists at x, y
# arguments:
#	$a0 - x coordinate
#	$a1 - y coordinate - (0,0) - bottom left corner
# variables:
#	$s0 - marker index x
#	$s1 - marker index y
#	$s2 - horizontal arm length (x axis)
#	$s3 - vertical arm width (x axis)
#	$s4 - vertical arm length (y axis)
# returns:
#	$v0 - 1 if a marker exists at (x, y), 0 otherwise

	sub	$sp, $sp, 4
	sw	$ra,4($sp)		# push $ra to the stack
	sub	$sp, $sp, 4
	sw	$s0, 4($sp)		# push $s0 to the stack
	sub	$sp, $sp, 4
	sw	$s1, 4($sp)		# push $s1 to the stack
	sub	$sp, $sp, 4
	sw	$s2, 4($sp)		# push $s2 to the stack
	sub	$sp, $sp, 4
	sw	$s3, 4($sp)		# push $s3 to the stack
	sub	$sp, $sp, 4
	sw	$s4, 4($sp)		# push $s4 to the stack
	
	move	$s0, $a0		# marker index x
	move	$s1, $a1		# marker index y
	li	$s4, 0			# set vertical arm length to 0
	
	# bottom line
	move	$a0, $s0		# x
	move	$a1, $s1		# y
	li	$a2, -1			# max length = -1 -> don't check
	jal     check_line
	beq	$v0, 0, return_0
	move	$s2, $v0		# bottom line length (x axis)
	
	# space under bottom line
	ble	$s1, 0, check_marker_loop	# skip if we reached the bottom edge
	sub	$s1, $s1, 1		# move down
	move	$a0, $s0		# x
	move	$a1, $s1		# y
	move	$a2, $s2		# max length
	jal     check_x_edge		# check bottom edge
	blt	$v0, $s2, return_0
	add	$s1, $s1, 1		# move up
	
	# next lines (moving up) - horizontal arm
check_marker_loop:
	add	$s4, $s4, 1		# increment vertical arm length (y-axis)
	add	$s1, $s1, 1		# move up
	move	$a0, $s0		# x
	move	$a1, $s1		# y
	move	$a2, $s2		# max length = last line length
	jal     check_line
	beq	$v0, $s2, check_marker_loop	# length equal to last line length
	beq	$v0, 0, return_0	# length equal to 0
	bgt	$v0, $s2, return_0	# length greater than last line length
	move	$s3, $v0		# veritical arm width (x axis)
	
	# check space over the horizontal line
	move	$a0, $s0		# x
	sub	$a0, $a0, $s3		# move to the left of the vertical arm
	move	$a1, $s1		# y
	move	$a2, $s2		# max length = horizontal arm length
	sub	$a2, $a2, $s3 		# max length -= vertical arm width
	jal     check_x_edge		# check vertical arm top edge
	move	$t0, $s2		# max length = horizontal arm length
	sub	$t0, $t0, $s3 		# max length -= vertical arm width
	blt	$v0, $t0, return_0
	
	# next lines (moving up) - vertical arm
check_marker_loop2:
	add	$s4, $s4, 1		# increment vertical arm length (y-axis)
	add	$s1, $s1, 1		# move up
	bge	$s1, IMAGE_H, check_skip	# skip if we reached the top edge
	move	$a0, $s0		# x
	move	$a1, $s1		# y
	move	$a2, $s3		# max length = last line length
	jal     check_line
	beq	$v0, $s3, check_marker_loop2	# length equal to last line length
	beq	$v0, 0, check_space_over	# length equal to 0 - we found the end
	j	return_0		# wrong length (longer than last or shorter but non-zero)
	
	# check space over the vertical line
check_space_over:
	bge	$s1, IMAGE_H, check_skip	# skip if we reached the top edge
	move	$a0, $s0		# x
	move	$a1, $s1		# y
	move	$a2, $s3		# max length = vertical arm length
	jal     check_x_edge		# check vertical arm top edge
	blt	$v0, $s3, return_0	# space less than the vertical arm length
check_skip:
	sub	$s1, $s1, $s4		# subtract marker height from current y to get the marker index y
	
	sll	$s4, $s4, 1
	bne	$s2, $s4, return_0	# return 0 if horizontal arm isn't exactly 2 time longer than the vertical arm
	
	# we found a marker! - let's save it
        
        la	$t0, markers		# $t0 = address of the markers array
        lh	$t1, num_of_markers	# $t1 = num_of markers
        sll	$t2, $t1, 2		# $t2 = $t1 * 4 (two pairs or half words)
        add	$t0, $t0, $t2		# address of next empty cell
        sh	$s0, 0($t0)		# store x
        sh	$s1, 2($t0)		# store y
        add	$t1, $t1, 1		# increment $t1 (num_of_markers)
        sh	$t1, num_of_markers	# store it
	
return_1:
	li	$v0, 1
	
check_marker_exit:
	lw	$s4, 4($sp)		# restore (pop) $s4
	add	$sp, $sp, 4
	lw	$s3, 4($sp)		# restore (pop) $s3
	add	$sp, $sp, 4
	lw	$s2, 4($sp)		# restore (pop) $s2
	add	$sp, $sp, 4
	lw	$s1, 4($sp)		# restore (pop) $s1
	add	$sp, $sp, 4
	lw	$s0, 4($sp)		# restore (pop) $s0
	add	$sp, $sp, 4
	lw	$ra, 4($sp)		# restore (pop) $ra
	add	$sp, $sp, 4
	jr	$ra
	
return_0:
	li	$v0, 0
	j	check_marker_exit

# ============================================================================
check_line:
# description: 
#	check the whole line from right to left (starting from a pixel to the right of the marker)
# arguments:
#	$a0 - x coordinate of the marker index
#	$a1 - y coordinate or the current line
#	$a2 - max length ($a2 = -1 -> don't check)
# variables:
#	$s0 - x coordinate
#	$s1 - y coordinate
#	$s2 - current length
#	$s3 - max length
# returns:
#	$v0 - length of the line (or width) - x axis

	sub	$sp, $sp, 4
	sw	$ra, 4($sp)		# push $ra to the stack
	sub	$sp, $sp, 4
	sw	$s0, 4($sp)		# push $s0 to the stack
	sub	$sp, $sp, 4
	sw	$s1, 4($sp)		# push $s1 to the stack
	sub	$sp, $sp, 4
	sw	$s2, 4($sp)		# push $s2 to the stack
	sub	$sp, $sp, 4
	sw	$s3, 4($sp)		# push $s3 to the stack
	
	move	$s0, $a0		# x
	move	$s1, $a1		# y
	move	$s3, $a2		# max length
	
	li	$s2, 0			# length
	add	$s3, $s3, 1		# increment max length
	
	add	$s0, $s0, 1		# check a pixel to the right of the starting point
	bge	$s0, IMAGE_W, check_line_loop	# if we reached the right edge, don't check
	move	$a0, $s0
	jal	get_pixel
	beq	$v0, 0, check_line_exit	# if color of a pixel to the right of the starting point is black, return 0
	
check_line_loop:
	sub	$s0, $s0, 1		# move left
	blt	$s0, 0, check_line_exit	# if we reached the left edge, exit
	move	$a0, $s0
	jal	get_pixel
	bne	$v0, 0, check_line_exit	# if color of the current pixel is not black, exit
	add	$s2, $s2, 1		# increment length
	beq	$s2, $s3, check_line_exit	# if length is equal to max length, exit
	j	check_line_loop
	
check_line_exit:
	move	$v0, $s2
	lw	$s3, 4($sp)		# restore (pop) $s3
	add	$sp, $sp, 4
	lw	$s2, 4($sp)		# restore (pop) $s2
	add	$sp, $sp, 4
	lw	$s1, 4($sp)		# restore (pop) $s1
	add	$sp, $sp, 4
	lw	$s0, 4($sp)		# restore (pop) $s0
	add	$sp, $sp, 4
	lw	$ra, 4($sp)		# restore (pop) $ra
	add	$sp, $sp, 4
	jr	$ra

# ============================================================================
check_x_edge:
# description: 
#	check the whole line from right to left (starting from a pixel to the right of the marker)
# arguments:
#	$a0 - x coordinate of the marker index
#	$a1 - y coordinate or the current line
#	$a2 - max length
# variables:
#	$s0 - x coordinate
#	$s1 - y coordinate
#	$s2 - current length
#	$s3 - max length
# returns:
#	$v0 - length of the line (or width) - x axis

	sub	$sp, $sp, 4
	sw	$ra, 4($sp)		# push $ra to the stack
	sub	$sp, $sp, 4
	sw	$s0, 4($sp)		# push $s0 to the stack
	sub	$sp, $sp, 4
	sw	$s1, 4($sp)		# push $s1 to the stack
	sub	$sp, $sp, 4
	sw	$s2, 4($sp)		# push $s2 to the stack
	sub	$sp, $sp, 4
	sw	$s3, 4($sp)		# push $s3 to the stack
	
	move	$s0, $a0		# x
	move	$s1, $a1		# y
	move	$s3, $a2		# max length
	
	li	$s2, 0			# length
	
check_x_edge_loop:
	move	$a0, $s0
	jal	get_pixel
	beq	$v0, 0, check_x_edge_exit	# if color of the current pixel is black, exit
	add	$s2, $s2, 1		# increment length
	beq	$s2, $s3, check_x_edge_exit	# if length is equal to max length, exit
	sub	$s0, $s0, 1		# move left
	j	check_x_edge_loop
	
check_x_edge_exit:
	move	$v0, $s2
	lw	$s3, 4($sp)		# restore (pop) $s3
	add	$sp, $sp, 4
	lw	$s2, 4($sp)		# restore (pop) $s2
	add	$sp, $sp, 4
	lw	$s1, 4($sp)		# restore (pop) $s1
	add	$sp, $sp, 4
	lw	$s0, 4($sp)		# restore (pop) $s0
	add	$sp, $sp, 4
	lw	$ra, 4($sp)		# restore (pop) $ra
	add	$sp, $sp, 4
	jr	$ra

# ============================================================================
read_bmp:
# description: 
#	reads the contents of a bmp file into memory
# arguments:
#	none
# return value:
#	$v0 - has the file been opened correctly? 0 = opened correctly, -1 = couldn't open the file or file not found
	sub	$sp, $sp, 4		# push $ra to the stack
	sw	$ra,4($sp)
	sub	$sp, $sp, 4		# push $s1
	sw	$s1, 4($sp)
# open file
	li	$v0, 13
        la	$a0, fname		# file name 
        li	$a1, 0			# flags: 0-read file
        li	$a2, 0			# mode: ignored
        syscall
	move	$s1, $v0      		# save the file descriptor

# check if file has been opened correctly
	blt	$s1, 0,	file_error

# read file
	li	$v0, 14
	move	$a0, $s1
	la	$a1, image
	li	$a2, BMP_FILE_SIZE
	syscall

# save pixel array address
	la	$t1, image + 10		# adress of file offset to pixel array
	lw	$t2, ($t1)		# file offset to pixel array in $t2
	la	$t1, image		# adress of bitmap
	add	$t2, $t1, $t2		# adress of pixel array in $t2
	sw	$t2, pix_arr_adr

# close file
	li	$v0, 16
	move	$a0, $s1
        syscall

# return 0
	li	$v0, 0

read_file_exit:
	lw	$s1, 4($sp)		# restore (pop) $s1
	add	$sp, $sp, 4
	lw	$ra, 4($sp)		# restore (pop) $ra
	add	$sp, $sp, 4
	jr	$ra

file_error:
	li	$v0, -1		# return -1 (can't open the file/file not found)
	j	read_file_exit

# ============================================================================
get_pixel:
# description: 
#	returns 0x00000000 if pixel is black, other values if it is not black
#		It does not return the pixel color! (for optimisation)
# arguments:
#	$a0 - x coordinate
#	$a1 - y coordinate - (0,0) - bottom left corner
# return value:
#	$v0 - 0x00000000 if pixel is black, other values if it is not black

	sub	$sp, $sp, 4		# push $ra to the stack
	sw	$ra,4($sp)
	
	# pixel address calculation
	mul	$t1, $a1, BYTES_PER_ROW # t1= y*BYTES_PER_ROW
	move	$t3, $a0		
	sll	$a0, $a0, 1
	add	$t3, $t3, $a0		# $t3= 3*x
	add	$t1, $t1, $t3		# $t1 = 3x + y*BYTES_PER_ROW
	lw	$t2, pix_arr_adr	# adress of pixel array in $t2
	add	$t2, $t2, $t1		# pixel address 
	
	# get color
	lbu	$v0,($t2)		# load B
	lbu	$t1,1($t2)		# load G
	or	$v0, $v0, $t1
	lbu	$t1,2($t2)		# load R
	or	$v0, $v0, $t1
					
	lw	$ra, 4($sp)		# restore (pop) $ra
	add	$sp, $sp, 4
	jr	$ra

# ============================================================================
