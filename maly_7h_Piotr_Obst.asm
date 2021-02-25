#===============================================================================#
#	autor:		Piotr Obst						#
#	data:		29.10.2020						#
#	opis:		Zadanie 7h						#
#===============================================================================#

	.data
tekst:			.space	64
dane_testowe:		.asciiz	"nh:wind on the hill"	# domy�lnie "nh:wind on the hill"
komunikat_blad:	.asciiz	"\nCiag wejsciowy powinien skladac sie co najmniej z dwoch znakow oraz dwukropka (np. 'nh:')"	# komunikat o b��dnym ci�gu wej�ciowym
komunikat_wejscie:	.asciiz	"\nInput string      > "
komunikat_wyjscie:	.asciiz	"\nConversion results> "
# zmienna czy_debug s�u�y do �atwiejszego testowania programu
# 0 - normalne uruchomienie programu (z wczytywaniem danych z klawiatury)
# 1 - uruchomienie programu w trybie testowym (dane podane w zmiennej dane_testowe)
czy_debug:	.byte 0

	.text
main:
	la	$a0, komunikat_wejscie		# za�aduj adres ci�gu znak�w do wy�wietlenia
        li	$v0, 4				# rozkaz nr 4 - wy�wietlanie
        syscall

	lb	$t0, czy_debug			# za�aduj warto�� zmiennej
	beqz	$t0, wczytywanie		# je�li zmienna czy_debug ma warto�� zero, to skocz do wczytywania danych

ladowanie_testowych:
	la	$a0, dane_testowe		# za�aduj adres ci�gu znak�w do wy�wietlenia
        li	$v0, 4				# rozkaz nr 4 - wy�wietlanie
        syscall
	la	$t0, dane_testowe		# adres danych testowych
	la	$t1, tekst			# adres zmiennej tekst
kopiuj_testowe:
	lb	$t3, ($t0)			# za�aduj znak z dane_tekstowe
	sb	$t3, ($t1)			# zapisz ten znak na odpowiadaj�cej pozycji w zmiennej tekst
	add	$t0, $t0, 1			# przejd� do nast�pnego elementu
	add	$t1, $t1, 1			# przejd� do nast�pnego elementu
	beqz	$t3, program			# je�li za�adowano koniec ci�gu znak�w, to przejd� do wykonywania programu
	j	kopiuj_testowe			# kopiuj kolejny znak

wczytywanie:
	la	$a0, tekst			# adres rejestru docelowego
	li	$v0, 8				# rozkaz nr 8 - wczytywanie
	li	$a1, 64				# maksymalna d�ugo�� ci�gu znak�w
	syscall
	
	la	$a0, tekst			# $a0 - argument do funkcji; za�aduj adres pocz�tku zmiennej tekst do $a0
	jal	szukaj_konca			# wywo�aj funkcj� szukaj_konca
	move	$t1, $v0			# przypisz do rejestru $t1 warto�� zwr�con� przez funkcj�
	sub	$t1, $t1, 1			# przesu� w lewo
	lb	$t2, ($t1)			# za�aduj znak
	bne	$t2, '\n', program		# je�li ten znak, to nie znak nowej linii, to skocz do program
	li	$t0, '\0'			# za�aduj znak ko�ca linii
	sb	$t0, ($t1)			# zamie� znak nowej linii na znak ko�ca linii

program:

sprawdz_dane:
	lb	$t0, tekst			# za�aduj pierwszy znak
	beqz	$t0, bledne_dane		# skocz, je�li jest to znak ko�ca ci�gu znak�w
	lb	$t0, tekst + 1			# za�aduj drugi znak
	beqz	$t0, bledne_dane		# skocz, je�li jest to znak ko�ca ci�gu znak�w
	lb	$t0, tekst + 2			# za�aduj trzeci znak
	bne	$t0, ':', bledne_dane		# skocz, je�li jest to znak inny, ni� dwukropek

	li	$t0, '*'			# za�aduj znak, na kt�ry zamieniamy

	la	$t2, tekst + 2			# adres elementu drugiego - do szukania elementu drugiego (teraz wskazuje na element ':')
	lb	$t3, tekst + 1			# znak szukany (drugi)
szukaj_znaku_2:
	add	$t2, $t2, 1			# przejd� do nast�pnego znaku (w prawo)
	lb	$t4, ($t2)			# za�aduj znak
	beqz	$t4, koniec_ciagu_2		# skocz, je�li dotarli�my do ko�ca ci�gu znak�w
	bne	$t4, $t3, szukaj_znaku_2	# je�li za�adowany znak nie r�wna si� szukanemu, to szukaj dalej
	add	$t2, $t2, 1			# pomi� szukany znak
koniec_ciagu_2:					# s�u�y jedynie do opuszczenia szukaj_znaku_2

	la	$a0, ($t2)			# $a0 - argument do funkcji; $t2 - adres elementu pierwszego (teraz wskazuje na element "drugi" - bo bez sensu zaczyna� od pocz�tku)
	jal	szukaj_konca			# wywo�aj funkcj� szukaj_konca
	move	$t1, $v0			# przypisz do rejestru $t1 warto�� zwr�con� przez funkcj�

	lb	$t3, tekst			# znak szukany (pierwszy)
szukaj_znaku_1: 
	sub	$t1, $t1, 1			# przejd� do nast�pnego znaku (w lewo)
	lb	$t4, ($t1)			# za�aduj znak
	beq	$t4, ':', koniec_ciagu_1	# skocz, je�li dotarli�my do dwukropka (je�li nie znaleziono szukanego znaku)
	bne	$t4, $t3, szukaj_znaku_1	# je�li za�adowany znak nie r�wna si� szukanemu, to szukaj dalej
	sub	$t1, $t1, 1			# pomi� szukany znak
koniec_ciagu_1:					# s�u�y jedynie do opuszczenia szukaj_znaku_1

zamieniaj_w_prawo:				# zamienianie na prawo od znaku drugiego
	lb	$t3, ($t2)			# za�aduj znak
	beqz	$t3, zamieniaj_w_lewo		# je�li za�adowany znak jest ko�cem ci�gu znak�w, to przesta� zamienia� i skocz do zamieniaj_w_lewo
	sb	$t0, ($t2)			# zamie� znak na gwiazdk�
	add	$t2, $t2, 1			# przejd� do nast�pnego znaku (w prawo)
	j	zamieniaj_w_prawo 		# kontynuuj zamian�

zamieniaj_w_lewo:				# zamienianie na lewo od znaku pierwszego
	lb	$t3, ($t1)			# za�aduj znak
	beq	$t3, ':', zamien_na_spacje	# je�li za�adowany znak jest dwukropkiem, to przesta� zamienia� i skocz do zamien_na_spacje
	sb	$t0, ($t1)			# zamie� znak na gwiazdk�
	sub	$t1, $t1, 1			# przejd� do nast�pnego znaku (w lewo)
	j	zamieniaj_w_lewo		# kontynuuj zamian�

zamien_na_spacje:
	la	$t1, tekst			# adres zmiennej tekst
	li	$t0, ' '			# za�aduj znak, na kt�ry zamieniamy
	sb	$t0, ($t1)			# zamie� pierwszy znak na spacj�
	sb	$t0, 1($t1)			# zamie� drugi znak na spacj�
	sb	$t0, 2($t1)			# zamie� trzeci znak na spacj�

wyswietl:
	la	$a0, komunikat_wyjscie		# za�aduj adres ci�gu znak�w do wy�wietlenia
        li	$v0, 4				# rozkaz nr 4 - wy�wietlanie
        syscall
	la	$a0, tekst			# za�aduj adres ci�gu znak�w do wy�wietlenia
	li	$v0, 4				# rozkaz nr 4 - wy�wietlanie
	syscall

exit:
	li	$v0, 10				# zako�cz dzia�anie programu
	syscall

# a0 - adres pocz�tku ci�gu znak�w (lub dowolnego elementu z tego ci�gu). Nie mo�e to by� adres ko�ca!
# v0 - zwraca adres ko�ca ci�gu znak�w
szukaj_konca:					# szukanie ko�ca ci�gu znak�w
	move	$v0, $a0
szukaj_konca_petla:
	add	$v0, $v0, 1			# przejd� do nast�pnego znaku (w prawo)
	lb	$t4, ($v0)			# za�aduj znak
	bnez	$t4, szukaj_konca_petla		# je�li za�adowany znak nie jest ko�cem ci�gu znak�w, to szukaj dalej
	jr	$ra				# powr�� do miejsca wywo�ania funkcji

bledne_dane:
	la	$a0, komunikat_blad		# za�aduj adres ci�gu znak�w do wy�wietlenia
        li	$v0, 4				# rozkaz nr 4 - wy�wietlanie
        syscall
	j	exit