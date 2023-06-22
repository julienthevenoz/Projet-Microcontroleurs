; file	sound1.asm

.include "sound.asm"		; include sound routine

play_note:
	//mov w,a0  //on recoit les valeurs dans a0 du capteur de distance et on travaille avec


	clr	a1		; clear high byte NORMALEMENT IL EST DEJA CLEAR (APRES DIV 16) 
	ldi	zl, low(2*tbl)	; load table base into z
	ldi	zh,high(2*tbl)	
	add	zl,a0		; add offset to table base
	adc	zh,a1		; add high byte
	lpm			; load program memory, r0 <- (z)
	
	mov	a0,r0  ; load oscillation period
	rcall joue_avec_rythme
	ret

tbl:
.db do,re,mi,fa,so,la,si,do2      //première octave
.db re2,mi2,fa2,so2,la2,si2  //deuxième octave. Total 16 éléments, pas de padding.


/*
.equ	do	= 100000/517	; (517 Hz)
.equ	dom	= do*944/1000	; do major
.equ	re	= do*891/1000
.equ	rem	= do*841/1000	; re major
.equ	mi	= do*794/1000
.equ	fa	= do*749/1000
.equ	fam	= do*707/1000	; fa major
.equ	so	= do*667/1000
.equ	som	= do*630/1000	; so major
.equ	la	= do*595/1000
.equ	lam	= do*561/1000	; la major
.equ	si	= do*530/1000

.equ	do2	= do/2
.equ	dom2	= dom/2
.equ	re2	= re/2
.equ	rem2	= rem/2
.equ	mi2	= mi/2
.equ	fa2	= fa/2
.equ	fam2	= fam/2
.equ	so2	= so/2
.equ	som2	= som/2
.equ	la2	= la/2
.equ	lam2	= lam/2
.equ	si2	= si/2
*/