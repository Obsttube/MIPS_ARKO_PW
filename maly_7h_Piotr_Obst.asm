#===============================================================================#
#	autor:		Piotr Obst						#
#	data:		29.10.2020						#
#	opis:		Zadanie 7h						#
#===============================================================================#

	.data
tekst:			.space	64
dane_testowe:		.asciiz	"nh:wind on the hill"	# domyœlnie "nh:wind on the hill"
komunikat_blad:	.asciiz	"\nCiag wejsciowy powinien skladac sie co najmniej z dwoch znakow oraz dwukropka (np. 'nh:')"	# komunikat o b³êdnym ci¹gu wejœciowym
komunikat_wejscie:	.asciiz	"\nInput string      > "
komunikat_wyjscie:	.asciiz	"\nConversion results> "
# zmienna czy_debug s³u¿y do ³atwiejszego testowania programu
# 0 - normalne uruchomienie programu (z wczytywaniem danych z klawiatury)
# 1 - uruchomienie programu w trybie testowym (dane podane w zmiennej dane_testowe)
czy_debug:	.byte 0

	.text
main:
	la	$a0, komunikat_wejscie		# za³aduj adres ci¹gu znaków do wyœwietlenia
        li	$v0, 4				# rozkaz nr 4 - wyœwietlanie
        syscall

	lb	$t0, czy_debug			# za³aduj wartoœæ zmiennej
	beqz	$t0, wczytywanie		# jeœli zmienna czy_debug ma wartoœæ zero, to skocz do wczytywania danych

ladowanie_testowych:
	la	$a0, dane_testowe		# za³aduj adres ci¹gu znaków do wyœwietlenia
        li	$v0, 4				# rozkaz nr 4 - wyœwietlanie
        syscall
	la	$t0, dane_testowe		# adres danych testowych
	la	$t1, tekst			# adres zmiennej tekst
kopiuj_testowe:
	lb	$t3, ($t0)			# za³aduj znak z dane_tekstowe
	sb	$t3, ($t1)			# zapisz ten znak na odpowiadaj¹cej pozycji w zmiennej tekst
	add	$t0, $t0, 1			# przejdŸ do nastêpnego elementu
	add	$t1, $t1, 1			# przejdŸ do nastêpnego elementu
	beqz	$t3, program			# jeœli za³adowano koniec ci¹gu znaków, to przejdŸ do wykonywania programu
	j	kopiuj_testowe			# kopiuj kolejny znak

wczytywanie:
	la	$a0, tekst			# adres rejestru docelowego
	li	$v0, 8				# rozkaz nr 8 - wczytywanie
	li	$a1, 64				# maksymalna d³ugoœæ ci¹gu znaków
	syscall
	
	la	$a0, tekst			# $a0 - argument do funkcji; za³aduj adres pocz¹tku zmiennej tekst do $a0
	jal	szukaj_konca			# wywo³aj funkcjê szukaj_konca
	move	$t1, $v0			# przypisz do rejestru $t1 wartoœæ zwrócon¹ przez funkcjê
	sub	$t1, $t1, 1			# przesuñ w lewo
	lb	$t2, ($t1)			# za³aduj znak
	bne	$t2, '\n', program		# jeœli ten znak, to nie znak nowej linii, to skocz do program
	li	$t0, '\0'			# za³aduj znak koñca linii
	sb	$t0, ($t1)			# zamieñ znak nowej linii na znak koñca linii

program:

sprawdz_dane:
	lb	$t0, tekst			# za³aduj pierwszy znak
	beqz	$t0, bledne_dane		# skocz, jeœli jest to znak koñca ci¹gu znaków
	lb	$t0, tekst + 1			# za³aduj drugi znak
	beqz	$t0, bledne_dane		# skocz, jeœli jest to znak koñca ci¹gu znaków
	lb	$t0, tekst + 2			# za³aduj trzeci znak
	bne	$t0, ':', bledne_dane		# skocz, jeœli jest to znak inny, ni¿ dwukropek

	li	$t0, '*'			# za³aduj znak, na który zamieniamy

	la	$t2, tekst + 2			# adres elementu drugiego - do szukania elementu drugiego (teraz wskazuje na element ':')
	lb	$t3, tekst + 1			# znak szukany (drugi)
szukaj_znaku_2:
	add	$t2, $t2, 1			# przejdŸ do nastêpnego znaku (w prawo)
	lb	$t4, ($t2)			# za³aduj znak
	beqz	$t4, koniec_ciagu_2		# skocz, jeœli dotarliœmy do koñca ci¹gu znaków
	bne	$t4, $t3, szukaj_znaku_2	# jeœli za³adowany znak nie równa siê szukanemu, to szukaj dalej
	add	$t2, $t2, 1			# pomiñ szukany znak
koniec_ciagu_2:					# s³u¿y jedynie do opuszczenia szukaj_znaku_2

	la	$a0, ($t2)			# $a0 - argument do funkcji; $t2 - adres elementu pierwszego (teraz wskazuje na element "drugi" - bo bez sensu zaczynaæ od pocz¹tku)
	jal	szukaj_konca			# wywo³aj funkcjê szukaj_konca
	move	$t1, $v0			# przypisz do rejestru $t1 wartoœæ zwrócon¹ przez funkcjê

	lb	$t3, tekst			# znak szukany (pierwszy)
szukaj_znaku_1: 
	sub	$t1, $t1, 1			# przejdŸ do nastêpnego znaku (w lewo)
	lb	$t4, ($t1)			# za³aduj znak
	beq	$t4, ':', koniec_ciagu_1	# skocz, jeœli dotarliœmy do dwukropka (jeœli nie znaleziono szukanego znaku)
	bne	$t4, $t3, szukaj_znaku_1	# jeœli za³adowany znak nie równa siê szukanemu, to szukaj dalej
	sub	$t1, $t1, 1			# pomiñ szukany znak
koniec_ciagu_1:					# s³u¿y jedynie do opuszczenia szukaj_znaku_1

zamieniaj_w_prawo:				# zamienianie na prawo od znaku drugiego
	lb	$t3, ($t2)			# za³aduj znak
	beqz	$t3, zamieniaj_w_lewo		# jeœli za³adowany znak jest koñcem ci¹gu znaków, to przestañ zamieniaæ i skocz do zamieniaj_w_lewo
	sb	$t0, ($t2)			# zamieñ znak na gwiazdkê
	add	$t2, $t2, 1			# przejdŸ do nastêpnego znaku (w prawo)
	j	zamieniaj_w_prawo 		# kontynuuj zamianê

zamieniaj_w_lewo:				# zamienianie na lewo od znaku pierwszego
	lb	$t3, ($t1)			# za³aduj znak
	beq	$t3, ':', zamien_na_spacje	# jeœli za³adowany znak jest dwukropkiem, to przestañ zamieniaæ i skocz do zamien_na_spacje
	sb	$t0, ($t1)			# zamieñ znak na gwiazdkê
	sub	$t1, $t1, 1			# przejdŸ do nastêpnego znaku (w lewo)
	j	zamieniaj_w_lewo		# kontynuuj zamianê

zamien_na_spacje:
	la	$t1, tekst			# adres zmiennej tekst
	li	$t0, ' '			# za³aduj znak, na który zamieniamy
	sb	$t0, ($t1)			# zamieñ pierwszy znak na spacjê
	sb	$t0, 1($t1)			# zamieñ drugi znak na spacjê
	sb	$t0, 2($t1)			# zamieñ trzeci znak na spacjê

wyswietl:
	la	$a0, komunikat_wyjscie		# za³aduj adres ci¹gu znaków do wyœwietlenia
        li	$v0, 4				# rozkaz nr 4 - wyœwietlanie
        syscall
	la	$a0, tekst			# za³aduj adres ci¹gu znaków do wyœwietlenia
	li	$v0, 4				# rozkaz nr 4 - wyœwietlanie
	syscall

exit:
	li	$v0, 10				# zakoñcz dzia³anie programu
	syscall

# a0 - adres pocz¹tku ci¹gu znaków (lub dowolnego elementu z tego ci¹gu). Nie mo¿e to byæ adres koñca!
# v0 - zwraca adres koñca ci¹gu znaków
szukaj_konca:					# szukanie koñca ci¹gu znaków
	move	$v0, $a0
szukaj_konca_petla:
	add	$v0, $v0, 1			# przejdŸ do nastêpnego znaku (w prawo)
	lb	$t4, ($v0)			# za³aduj znak
	bnez	$t4, szukaj_konca_petla		# jeœli za³adowany znak nie jest koñcem ci¹gu znaków, to szukaj dalej
	jr	$ra				# powróæ do miejsca wywo³ania funkcji

bledne_dane:
	la	$a0, komunikat_blad		# za³aduj adres ci¹gu znaków do wyœwietlenia
        li	$v0, 4				# rozkaz nr 4 - wyœwietlanie
        syscall
	j	exit