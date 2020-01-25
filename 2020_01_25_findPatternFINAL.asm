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
fnameout:  .asciiz "src_002.bmp"

imgInfo:
w:	.word 32
h:	.word 32
pImg:	.word 0
wbytes:	.word 32
fsize:	.word -1

analyze_data:					.word 	0,0,0,0,0,0,0,0
wzorce:							.word 	0,0,0,0,0,0,0,0
		

ptrn:
	.byte 0x00, 0x1B, 0x1B, 0x1B, 0x1B, 0x03, 0, 0																	#wzorzec od dolu
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

  	
 
 #s0 - poczatek danych 
 
#Point* FindPattern(imgInfo* pImg, int pSize, int* ptrn, Point* pResult);
 
 	li	$t1, 5			#sx
 	li	$t2, 6 			#sy
 	sll	$t1, $t1, 8
 	or	$t1, $t1, $t2
 
 	la	$a0, fbuf
 	move	$a1, $t1
 	la	$a2, ptrn
 	la	$a3, pResult
 	
 	jal	FindPattern
	
	
	move		$s0, $v0
	move		$s1, $v1
	
	
	move		$a0, $s1
	li			$v0, 1
	syscall
	
	li			$a0, 10
	li			$v0, 11
	syscall
	
#	lw			$a0, ($s0)
#	li			$v0, 1
#	syscall
	
	li			$a0, 10
	li			$v0, 11
	syscall
	
	add			$s0, $s0, 4
	
	
#	lw			$a0, ($s0)
#	li			$v0, 1
#	syscall
	
	li			$a0, 10
	li			$v0, 11
	syscall
	
	la 	$a0, fnameout
 	li 	$a1, 1		#open file read only
 	li 	$a2, 0
 	li	$v0, 13 		
 	syscall
	
	
	
	move 	$a0, $v0
  	la 	$a1, fbuf
  	li 	$a2, 44000
  	li 	$v0, 15   		#save file
  	syscall
  	
  	
  	
 # 	li	$a3, 2345
 # 	mtc1	$a3, $f0
  	
 # 	mfc1	$a0, $f0
 # 	li	$v0, 1
 #	syscall
  	
  	
	
	
	
	
	

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
#s0 - poczatek bitmapy
 
 widthBytes:
  	lw		$t0, w
  	addiu 	$t0, $t0, 7
  	srl 	$t0, $t0, 3
  	addiu 	$t0, $t0, 3
  	srl 	$t0, $t0, 2
  	sll		$t0, $t0, 2
 
  	sw 		$t0, wbytes
	
	move	$t1, $s0

#t1 - adres poczatku wiersza
#t2 - wysokosc wzorca
#t3 - gdzie zapisujemy dane
	

	move	$t2, $a1
	andi	$t2, 0x000000FF
	move	$s7, $t2																					##$s7 - 
	
	move	$t1, $a1
	srl		$t1, $t1, 8
	andi	$t1, 0x000000FF
	move	$s6, $t1
	
	
	## s6 - szerokoc wzorca

	
	move	$t9, $zero
	li		$t8, 1
	sll		$t8, $t8, 15
	move	$t7, $s6
	
	
build_mask:	
	or		$t9, $t9, $t8
	srl		$t8, $t8, 1
	subiu	$t7, $t7, 1
	bgtz	$t7, build_mask
	
	move	$s5, $t9														

#a0 - wolne
#a1 - licznik punktow
#a2 - pattern
#a3 - adres potencjalnego punktu

#t0 - szerokosc obrazu w bajtach
#t1 - temp
#t2 - 
#t3 - 
#t4 - tmp
#t5 - 
#t6 - 
#t7 - 
#t8 - pole szukania pionowo
#t9 - 

#s0 - 
#s1 - maksymalne x, dla okna analizy
#s2 - 
#s3 - tmp
#s4 - 
#s5 - maska, stala
#s6 - szerokosc wzorca, nie ruszac
#s7 - wysokosc wzorca, nie ruszac


## s5 - maska
	

#analyze_data - zrzut rejestru
	
	
#ustalenie szerokosci przeszukiwania
	lw			$t4, w
	sub			$t4, $t4, $s6							#odjecie od szerokosci obrazka w pixelach, szerokosci wzorca w pikselach
	addi		$s1, $t4, 1								#korekcja
	
	
	move		$t2, $s7												#zliczanie wysokosci, wzorca
#ustalenie wysokosci przeszukiwania	
	lw			$t8, h									#wysokosc pikselowo
	subu		$t8, $t8, $s7							#odjac wysokosc wzorca
	addiu		$t8, $t8, 1								#plus jeden, korekcja
	
#t9 - licznik w pionie	
	move		$t9, $zero
	
	move		$v1, $zero



#korekcja masek


	move		$s4, $a2												#ustawienie na poczatek paterna
	la			$t5, wzorce	
	
	li			$t4, 16
	sub			$t4, $t4, $s6											#t1 - o ile przesunac w lewo aby wzorzec dosunac do lewej strony drugiego bajtu [ 4 | 3 | 2 | 1]
	move		$t7, $s7
shift_mask:
	move		$t1, $zero
	lbu			$t1, ($s4)
	sllv		$t1, $t1, $t4
	sw			$t1, ($t5)

	addiu		$s4, $s4, 1
	addiu		$t5, $t5, 4
	subi		$t7, $t7, 1
	bgtz		$t7, shift_mask
	


	la			$a2, wzorce



###GLOWNA PETLA

#$s0 - adres analyze data


	la			$t3, analyze_data

kolejna_linia:

	move		$t5, $t3					
	move		$a0, $s7
	move		$s2, $s0
	

store_data:	

	move		$t4, $zero
	lbu			$t4, ($s2)
	addu		$s2, $s2, $t0
	
	
	sll			$t4, $t4, 8
	
	sw			$t4, ($t5)
	addiu		$t5, $t5, 4
	
	subiu		$a0, $a0, 1
	bgtz		$a0, store_data
				
	
	
	
	
#a1 - aktualne x - poczatku wzorca

	move		$a1, $zero					#a1 - licznik pikseli w prawo, od 0	
	move		$t7, $zero
	
	
poziomo:		#przesuniecie okna porownania w prawo o 1 piksel
	
	move		$t5, $t3
	move		$s4, $a2												#ustawienie na poczatek paterna
	la			$s4, wzorce

	addu		$s2, $s0, $t7
	addu		$s2, $s2, 1
	
	move		$t2, $s7												#zliczanie wysokosci, wzorca
	
	
	
	
pionowo_z_wczytywaniem:

	
#t6 - tu bedzie wynik maskowania												
	lw			$t6, ($t5)												#wczytanie dla i-tego wiersza


	move		$t4, $zero
	lbu			$t4, 0($s2)
	
	or			$t6, $t6, $t4
	
	addu		$s2, $s2, $t0
	
	sll			$t6, $t6, 1
	sw			$t6, ($t5)
	srl			$t6, $t6, 1
	addiu		$t5, $t5, 4												#przesuniecie adresu dla kolejnego wiersza
	and			$t6, $t6, $s5											#t6 - wynik maskowania
	lw			$t1, ($s4)
	addi		$s4, $s4, 4
	
	subi		$t2, $t2, 1
	
	bne			$t6, $t1, test_niemaskowanie2
	bgtz		$t2, pionowo_z_wczytywaniem
	
	
	
	
	
	sw			$a1, ($a3)
	addiu		$a3, $a3, 4
	
	sw			$t9, ($a3)
	addiu		$a3, $a3, 4
	
	addiu		$v1, $v1, 1
	
	
	addiu		$a1, $a1, 1

	beq			$a1, $s1, test_koniec
	
	srl			$t7, $a1, 3												#t7 - numer aktualnego bajtu
	sll			$s3, $t7, 3
	sub			$a0, $a1, $s3
	
	beqz		$a0, poziomo	
	j			poziomo2
	
	
	
niemaskowanie2:
	lw			$t6, ($t5)												#wczytanie dla i-tego wiersza


	move		$t4, $zero
	lbu			$t4, 0($s2)
	
	or			$t6, $t6, $t4
	
	addu		$s2, $s2, $t0
	
	sll			$t6, $t6, 1
	sw			$t6, ($t5)
	addiu		$t5, $t5, 4	
	
	subi		$t2, $t2, 1
	
test_niemaskowanie2:	
	
	bgtz		$t2, niemaskowanie2
	
	addiu		$a1, $a1, 1

	beq			$a1, $s1, test_koniec
	
	srl			$t7, $a1, 3												#t7 - numer aktualnego bajtu
	sll			$s3, $t7, 3
	sub			$a0, $a1, $s3
	
	beqz		$a0, poziomo	
	


############################################################################################################################
poziomo2:

	move		$t5, $t3
	move		$s4, $a2												#ustawienie na poczatek paterna
	move		$t2, $s7												#zliczanie wysokosci, wzorca


pionowo_bez_wczytywania:
	lw			$t6, ($t5)												#wczytanie dla i-tego wiersza

	sll			$t6, $t6, 1
	sw			$t6, ($t5)
	srl			$t6, $t6, 1
	addiu		$t5, $t5, 4												#przesuniecie adresu dla kolejnego wiersza
	
	and			$t6, $t6, $s5											#t6 - wynik maskowania
	lw			$t1, ($s4)
	
	addi		$s4, $s4, 4
	subi		$t2, $t2, 1
	
	
	
	bne			$t6, $t1, test_niemaskowanie
	bgtz		$t2, pionowo_bez_wczytywania
	
	sw			$a1, ($a3)
	addiu		$a3, $a3, 4
	
	sw			$t9, ($a3)
	addiu		$a3, $a3, 4
	
	addiu		$v1, $v1, 1
	
	
	addiu		$a1, $a1, 1

	beq			$a1, $s1, test_koniec
	
	srl			$t7, $a1, 3												#t7 - numer aktualnego bajtu
	sll			$s3, $t7, 3
	sub			$a0, $a1, $s3
	
	beqz		$a0, poziomo	
	j			poziomo2
	
	
	
niemaskowanie:
	lw			$t6, ($t5)												#wczytanie dla i-tego wiersza

	sll			$t6, $t6, 1
	sw			$t6, ($t5)
	addiu		$t5, $t5, 4												#przesuniecie adresu dla kolejnego wiersza
	
	
	addi		$s4, $s4, 4
	
	subi		$t2, $t2, 1
	
test_niemaskowanie:	
	
	bgtz		$t2, niemaskowanie
	
	addiu		$a1, $a1, 1

	beq			$a1, $s1, test_koniec
	
	srl			$t7, $a1, 3												#t7 - numer aktualnego bajtu
	sll			$s3, $t7, 3
	sub			$a0, $a1, $s3
	
	beqz		$a0, poziomo	
	j			poziomo2
	
	

test_koniec:



	add			$s0, $s0, $t0

	addiu		$t9, $t9, 1
	
	blt			$t9, $t8, kolejna_linia
	
	la			$v0, pResult
	
	
	lw 		$ra, 4($sp)		#restore (pop) $ra
	add 	$sp, $sp, 4
	jr 		$ra







	
