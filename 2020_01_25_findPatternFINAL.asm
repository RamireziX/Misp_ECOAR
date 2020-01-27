#ALEXANDER WRZOSEK

#ecoar misp project
#search for a pattern 
#black  & white image

#[most sig bit][][][][][][][][][][][least sig bit]
#pass pointer to structure imgInfo(width, height, pointer to where the buffer of image is located, X & Y coordinates)
#possible to store pattern in registers
#compare masked bytes 

#open file->read whole content at once(will also get info about length of file when reading)

# 62 - bmp file header size


  
  .data
fname:  .asciiz "src_001.bmp"
#fnameout:  .asciiz "src_002.bmp"
number:  .asciiz "Number of occurences:\n"
coor1:  .asciiz "Coordinates:\n"
coor2:  .asciiz "x  y\n"

imgInfo:
w:	.word 32
h:	.word 32
pImg:	.word 0
wbytes:	.word 32
fsize:	.word -1

analyze_data:					.word 	0,0,0,0,0,0,0,0
pattern:							.word 	0,0,0,0,0,0,0,0
		

ptrn:
	#.byte 0x00, 0x1B, 0x1B, 0x1B, 0x1B, 0x03, 0, 0	#letter i	x5 y6 	
	.byte 0x43, 0x7d, 0x7d, 0x41, 0x3d, 0x3d, 0x3d, 0x40	#letter g x7 y8														#pattern from bottom
pResult:
  .align 2
	.space 1024	
fbuf: 
	.space 44000

  .text

  
main:

 	la 	$a0, fname
 	li 	$a1, 0
 	li 	$a2, 0
 	li	$v0, 13 		#open file read only
 	syscall
  
  	move 	$a0, $v0
  	la 	$a1, fbuf
  	li 	$a2, 44000
  	li 	$v0, 14   		#read file
  	syscall
  
  	li	 $v0, 16		#close the file
  	syscall
  
  	la	 $s0, fbuf

  	
 
 #s0 - start of data
 
#Point* FindPattern(imgInfo* pImg, int pSize, int* ptrn, Point* pResult);
 
 	li	$t1, 7			#sx
 	li	$t2, 8 			#sy
 	sll	$t1, $t1, 8
 	or	$t1, $t1, $t2
 
 	la	$a0, fbuf
 	move	$a1, $t1
 	la	$a2, ptrn
 	la	$a3, pResult
 	
 	jal	FindPattern


 	move		$s0, $v0
	move		$s1, $v1
	
	
	la		$a0, number
	li		$v0, 4
	syscall
	
	move		$a0, $s1
	li		$v0, 1
	syscall
	
	li		$a0, '\n'
	li		$v0, 11
	syscall
	
	la		$a0, coor1
	li		$v0, 4
	syscall
	
	la		$a0, coor2
	li		$v0, 4
	syscall
	
 	
#s1 - number of occurences
#s0 - coordinates

print:
 	 beqz		$s1, end
 	 
 	 lw		$a0, ($s0)
 	 li		$v0, 1
 	 syscall
 	 
 	 li		$a0, ' '
 	 li		$v0, 11
 	 syscall
 	 
 	 lw		$a0, 4($s0)
 	 li		$v0, 1
 	 syscall
 	 
 	 li		$a0, 10
 	 li		$v0, 11
 	 syscall
 	 
 	 addiu		$s0, $s0, 8
	
	 subi		$s1, $s1, 1
	 j		print							

end:
  	li $v0, 10		#end program
  	syscall
  
#a0 - imgInfo* pImg
#a1 - pSize
#a2 - pattern
#a3 - table where coordinates will be stored

FindPattern:
	sub 	$sp, $sp, 4		#push $ra to the stack
	sw 	$ra, 4($sp)
	
	#addiu 	$sp, $sp, -32		#room on stack for workspace
	
	#addiu	$sp, $sp, -32		#room for addrresses
	
	
	move	$s0, $a0
	#get filesize
  
  	lbu	$t0, 2($s0)
  	lbu 	$t1, 3($s0)
  	lbu 	$t2, 4($s0)
  	lbu	$t3, 5($s0)
 
  	sll 	$t1, $t1, 8
  	sll 	$t2, $t2, 16
  	sll 	$t3, $t3, 24
 
  	or 	$t3, $t3, $t2
  	or 	$t3, $t3, $t1
  	or 	$t3, $t3, $t0
 
  	sw	$t3, fsize

  	#get width

  	lbu 	$t0, 18($s0)
  	lbu 	$t1, 19($s0)
  	lbu 	$t2, 20($s0)
  	lbu 	$t3, 21($s0)

 
  	sll	$t1, $t1, 8
  	sll 	$t2, $t2, 16
  	sll 	$t3, $t3, 24
 
  	or 	$t3, $t3, $t2
  	or 	$t3, $t3, $t1
  	or 	$t3, $t3, $t0

  	sw	$t3, w
  
 	#get height 
 
  	lbu 	$t0, 22($s0)
  	lbu 	$t1, 23($s0)
  	lbu 	$t2, 24($s0)
  	lbu 	$t3, 25($s0)
 
  	sll 	$t1, $t1, 8
  	sll 	$t2, $t2, 16
  	sll 	$t3, $t3, 24
 
  	or 	$t3, $t3, $t2
  	or 	$t3, $t3, $t1
  	or 	$t3, $t3, $t0
 
  	sw	$t3, h
  
  
 shift:
  	lbu 	$t0, 10($s0)
  	lbu 	$t1, 11($s0)
  	lbu 	$t2, 12($s0)
  	lbu 	$t3, 13($s0)

  	sll 	$t1, $t1, 8
 	sll 	$t2, $t2, 16
  	sll 	$t3, $t3, 24
 
  	or 	$t3, $t3, $t2
  	or 	$t3, $t3, $t1
  	or 	$t3, $t3, $t0
 
  	addu 	$s0, $s0, $t3			#move to the start of bitmap
#s0 - start of bitmap
 
 widthBytes:
  	lw	$t0, w
  	addiu 	$t0, $t0, 7
  	srl 	$t0, $t0, 3
  	addiu 	$t0, $t0, 3
  	srl 	$t0, $t0, 2
  	sll	$t0, $t0, 2
 
  	sw 	$t0, wbytes
	
	move	$t1, $s0

#t1 - start kine address
#t2 - pattern height
#t3 - writing data
	

	move	$t2, $a1
	andi	$t2, 0x000000FF
	move	$s7, $t2																					 
	
	move	$t1, $a1
	srl	$t1, $t1, 8
	andi	$t1, 0x000000FF
	move	$s6, $t1
	
	
	## s6 - pattern width
	## s7 - pattern height

	
	move	$t9, $zero
	li	$t8, 1
	sll	$t8, $t8, 15
	move	$t7, $s6
	
	
build_mask:	
	or	$t9, $t9, $t8
	srl	$t8, $t8, 1
	subiu	$t7, $t7, 1
	bgtz	$t7, build_mask
	
	move	$s5, $t9														

#a0 - free
#a1 - point counter
#a2 - pattern
#a3 - address of point

#t0 - image width in bytes
#t1 - temp
#t2 - 
#t3 - 
#t4 - tmp
#t5 - 
#t6 - 
#t7 - 
#t8 - vertical search
#t9 - 

#s0 - 
#s1 - max x for analyse window
#s2 - 
#s3 - tmp
#s4 - 
#s5 - mask, const
#s6 - pattern width
#s7 - pattern height


## s5 - mask
	

#analyze_data - registry dump
	
	
#search width
	lw		$t4, w
	sub		$t4, $t4, $s6							#image width - pattern width (pixels)
	addi		$s1, $t4, 1								#correction
	
	
	move		$t2, $s7								#height of pattern
#search height
	lw		$t8, h									#height in pixels
	subu		$t8, $t8, $s7							#sub pattern height
	addiu		$t8, $t8, 1								#correction
	
#t9 - vertical counter
	move		$t9, $zero
	
	move		$v1, $zero



#mask correction 


	move		$s4, $a2												#start of pattern
	la		$t5, pattern	
	
	li		$t4, 16
	sub		$t4, $t4, $s6											#t1 - how much to shift left to move pattern to left of 2nd byte[ 4 | 3 | 2 | 1]
	move		$t7, $s7
shift_mask:
	move		$t1, $zero
	lbu		$t1, ($s4)
	sllv		$t1, $t1, $t4
	sw		$t1, ($t5)

	addiu		$s4, $s4, 1
	addiu		$t5, $t5, 4
	subi		$t7, $t7, 1
	bgtz		$t7, shift_mask
	


	la		$a2, pattern



#################MAIN LOOP#####################################

#$s0 - adress of analyze data


	la		$t3, analyze_data

next_line:

	move		$t5, $t3					
	move		$a0, $s7
	move		$s2, $s0
	

store_data:	

	move		$t4, $zero
	lbu		$t4, ($s2)
	addu		$s2, $s2, $t0
	
	
	sll		$t4, $t4, 8
	
	sw		$t4, ($t5)
	addiu		$t5, $t5, 4
	
	subiu		$a0, $a0, 1
	bgtz		$a0, store_data
				
	
	
	
	
#a1 - x start of pattern

	move		$a1, $zero					#a1 - count pixels right, from 0	
	move		$t7, $zero
	
	
horizontal:		#move analyse window by 1 pixel
	
	move		$t5, $t3
	move		$s4, $a2												#start of pattern
	la		$s4, pattern

	addu		$s2, $s0, $t7
	addu		$s2, $s2, 1
	
	move		$t2, $s7												#height of pattern
	
	
	
	
horizontal_with_loading:

	
#t6 - result of masking											
	lw			$t6, ($t5)												#loading for i-th line


	move		$t4, $zero
	lbu		$t4, 0($s2)

	or		$t6, $t6, $t4
	
	addu		$s2, $s2, $t0
	
	sll		$t6, $t6, 1
	sw		$t6, ($t5)
	srl		$t6, $t6, 1
	addiu		$t5, $t5, 4												#move to next line
	and		$t6, $t6, $s5											#t6 - result of masking
	lw		$t1, ($s4)
	addi		$s4, $s4, 4
	
	subi		$t2, $t2, 1
	
	bne		$t6, $t1, test_nomask2
	bgtz		$t2, horizontal_with_loading
	
	
	
	
	
	sw		$a1, ($a3)
	addiu		$a3, $a3, 4
	
	sw		$t9, ($a3)
	addiu		$a3, $a3, 4
	
	addiu		$v1, $v1, 1
	
	
	addiu		$a1, $a1, 1												#x++

	beq		$a1, $s1, test_end
	
	srl		$t7, $a1, 3												#t7 - number of current byte
	sll		$s3, $t7, 3
	sub		$a0, $a1, $s3
	
	beqz		$a0, horizontal	
	j		horizontal2

	
	
nomask2:
	lw		$t6, ($t5)												#load for i-th line


	move		$t4, $zero
	lbu		$t4, 0($s2)
	
	or		$t6, $t6, $t4
	
	addu		$s2, $s2, $t0


	sll		$t6, $t6, 1
	sw		$t6, ($t5)
	addiu		$t5, $t5, 4	
	
	subi		$t2, $t2, 1
	
test_nomask2:	
	
	bgtz		$t2, nomask2
	
	addiu		$a1, $a1, 1

	beq		$a1, $s1, test_end
	
	srl		$t7, $a1, 3												#t7 - number of current byte
	sll		$s3, $t7, 3
	sub		$a0, $a1, $s3
	
	beqz		$a0, horizontal	
	


############################################################################################################################
horizontal2:

	move		$t5, $t3
	move		$s4, $a2												#start of pattern
	move		$t2, $s7												#height of pattern


vertical_no_load:
	lw		$t6, ($t5)												#load for i-th line

	sll		$t6, $t6, 1
	sw		$t6, ($t5)
	srl		$t6, $t6, 1
	addiu		$t5, $t5, 4												#next line address
	
	and		$t6, $t6, $s5											#t6 -result of masking
	lw		$t1, ($s4)
	
	addi		$s4, $s4, 4
	subi		$t2, $t2, 1
	
	
	
	bne		$t6, $t1, test_nomask
	bgtz		$t2, vertical_no_load
	
	sw		$a1, ($a3)
	addiu		$a3, $a3, 4
	
	sw		$t9, ($a3)
	addiu		$a3, $a3, 4
	
	addiu		$v1, $v1, 1
	
	
	addiu		$a1, $a1, 1

	beq		$a1, $s1, test_end
	
	srl		$t7, $a1, 3												#t7 - number of current byte
	sll		$s3, $t7, 3
	sub		$a0, $a1, $s3
	
	beqz		$a0, horizontal	
	j		horizontal2
	
	
	
nomask:
	lw		$t6, ($t5)												#load for i-th line

	sll		$t6, $t6, 1
	sw		$t6, ($t5)
	addiu		$t5, $t5, 4												#move to next line
	
	
	addi		$s4, $s4, 4
	
	subi		$t2, $t2, 1
	
test_nomask:	
	
	bgtz		$t2, nomask
	
	addiu		$a1, $a1, 1

	beq		$a1, $s1, test_end
	
	srl		$t7, $a1, 3												#t7 - number of current byte
	sll		$s3, $t7, 3
	sub		$a0, $a1, $s3
	
	beqz		$a0, horizontal	
	j		horizontal2
	
	

test_end:


	add		$s0, $s0, $t0

	addiu		$t9, $t9, 1
	
	blt		$t9, $t8, next_line
	
	la		$v0, pResult
	
	
	lw 		$ra, 4($sp)		#restore (pop) $ra
	add 		$sp, $sp, 4
	jr 		$ra







	
