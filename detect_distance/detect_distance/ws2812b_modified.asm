; file	ws2812b_4MHz_demo01_S.asm   target ATmega128L-4MHz-STK300
; purpose send data to ws2812b using 4 MHz MCU and standard I/O port
;         display and paralllel process (blinking LED0)
; usage: buttons on PORTC, ws2812 on PORTD (bit 1)      
;        press button 0
;       a pattern is stored into memory and displayed on the array
;       LED0 blinks fast; when button0 is pressed and released, LED1
;       akcnowledges and the pattern displayed on the array moves by
;       one memory location
; warnings: 1/2 timings of pulses in the macros are sensitive
;			2/2 intensity of LEDs is high, thus keep intensities
;				within the range 0x00-0x0f, and do not look into
;				LEDs
; 20220315 AxS

; WS2812b4_WR0	; macro ; arg: void; used: void
; purpose: write an active-high zero-pulse to PD1   //matrice utilise PORTC mtnt
.macro	WS2812b4_WR0
	clr u
	sbi PORTB, 1
	out PORTB, u
	nop
	nop
	;nop	;deactivated on purpose of respecting timings
	;nop
.endm

; WS2812b4_WR1	; macro ; arg: void; used: void
; purpose: write an active-high one-pulse to PD1
.macro	WS2812b4_WR1
	sbi PORTB, 1
	nop
	nop
	cbi PORTB, 1
	;nop	;deactivated on purpose of respecting timings
	;nop

.endm

//////// NB !!!! jai changé tous les a0 par des b1 !!!

display_matrice:  //changé le nom du main
	; ------ part 1: store image that will be displayed into SRAM
	mov w, a0  //le nombre contenu dans w sera le nombre de fois quon fait la loop, donc le nb de pixel quon affiche
	clc
	lsl w	//multiplication par 8 pour avoir des lignes de 8 led
	lsl w
	lsl w
	ldi _w, 64 //
	sub _w, w  //nb de led eteintes

	ldi zl,low(0x0400)
	ldi zh,high(0x0400)

white_pixel_loop:
	ldi a0,0x05  //on met les 3 octets à la même intensité pour avoir du blanc
	st	z+,a0
	ldi a0,0x05
	st	z+,a0
	ldi	a0, 0x05
	st z+,a0
	dec w
	brne white_pixel_loop  //on fait autant de loop (donc de piexels) que le nb dans w

eteint_loop:
	ldi a0,0x00  //on met les 3 octets à la même intensité pour avoir du blanc
	st	z+,a0
	ldi a0,0x00
	st	z+,a0
	ldi	a0, 0x00
	st z+,a0
	dec _w
	brne eteint_loop

	; ------ part 2, display: read image from SRAM and send to display
restart:

	ldi zl,low(0x0400)  //on remet le pointeur au début des valeurs quon a stockées dans la pile
	ldi zh,high(0x0400)
						//nb jai enlevé l'increment de b1 (code original) psk  je crois qu'il nous sert à rien (truc avec les boutons dont on sen fout)

	_LDI	r0,64
loop:

	ld a0, z+
	
	ld a1, z+		
	
	ld a2,z+
	

	cli
	rcall ws2812b4_byte3wr
	sei

	dec r0
	brne loop
	rcall ws2812b4_reset


; ws2812b4_init		; arg: void; used: r16 (w)
; purpose: initialize AVR to support ws2812
ws2812b4_init:
	OUTI	DDRB,0xff
ret

; ws2812b4_byte3wr	; arg: a0,a1,a2 ; used: r16 (w)
; purpose: write contents of a0,a1,a2 (24 bit) into ws2812, 1 LED configuring
;     GBR color coding, LSB first
ws2812b4_byte3wr:

	ldi w,8
ws2b3_starta0:
	sbrc a0,7
	rjmp	ws2b3w1
	WS2812b4_WR0			; write a zero
	rjmp	ws2b3_nexta0
ws2b3w1:
	WS2812b4_WR1
ws2b3_nexta0:
	lsl a0
	dec	w
	brne ws2b3_starta0

	ldi w,8
ws2b3_starta1:
	sbrc a1,7
	rjmp	ws2b3w1a1
	WS2812b4_WR0			; write a zero
	rjmp	ws2b3_nexta1
ws2b3w1a1:
	WS2812b4_WR1
ws2b3_nexta1:
	lsl a1
	dec	w
	brne ws2b3_starta1

	ldi w,8
ws2b3_starta2:
	sbrc a2,7
	rjmp	ws2b3w1a2
	WS2812b4_WR0			; write a zero
	rjmp	ws2b3_nexta2
ws2b3w1a2:
	WS2812b4_WR1
ws2b3_nexta2:
	lsl a2
	dec	w
	brne ws2b3_starta2
	
ret

; ws2812b4_reset	; arg: void; used: r16 (w)
; purpose: reset pulse, configuration becomes effective
ws2812b4_reset:
	cbi PORTB, 1
	WAIT_US	50 	; 50 us are required, NO smaller works
ret