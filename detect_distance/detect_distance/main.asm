.include "macros.asm"
.include "definitions.asm"

; === interrupt table ===
.org	0
		jmp		reset
		jmp		ext_int0
		jmp		ext_int1
		jmp		ext_int2
		jmp		ext_int3

.org	ADCCaddr
		jmp		ADCCaddr_sra

.org	0x30

; === interrupt service routines ===

ext_int0:
		ldi a2,0
		reti

ext_int1:
		ldi a2,1
		reti

ext_int2:
		ldi a2,2
		reti

ext_int3:
		ldi a2,3
		reti

ADCCaddr_sra:
		ldi		r23,0x01
		reti

; === initialization (reset) ===
reset:
		LDSP	RAMEND
		OUTI	DDRE,0xff

		OUTI EIMSK, 0b00001111
		OUTEI EICRA, 0b10101010
		//ldi w, 1
		//out EICRA, w
		sei
		rcall	LCD_init
		rcall	ws2812b4_init	; initialize matrice

		OUTI	ADCSR,(1<<ADEN)+(1<<ADIE)+6
		

		OUTI	ADMUX,3
		clr b2
		clr b3
		clr a2
		clr a3
		jmp		main


.include "lcd.asm"
.include "printf.asm"
.include "sound1.asm"
.include "ws2812b_modified.asm"

; === main program ===
main:
		WAIT_MS 1
		
		clr		r23
		/*
		in		w, PIND
		sbrc	w,0
		jmp		PC-2
		*/
		
		sbi		ADCSR,ADSC
		WB0		r23,0	// attends que l'info soit prête

		in		a0,ADCL
		in		a1,ADCH

		DIV16	a0, a1

//switch numero 1 : tuning de la plage de distance
case1:
		cpi a0,4  
		brsh case2
		//code case1
		ldi w, 1
		rjmp end_switch
case2:
		cpi a0,5   //r16 = 2 ?
		brsh case3
		//code case2
		ldi w, 2
		rjmp end_switch
case3:
		cpi a0,6   //r16 = 2 ?
		brsh case4
		ldi w, 3
		rjmp end_switch
case4:
		cpi a0,7   //r16 = 2 ?
		brsh case5
		ldi w, 4
		rjmp end_switch
case5:
		cpi a0,9   //r16 = 2 ?
		brsh case6
		ldi w, 5
		rjmp end_switch
case6:
		cpi a0,12   //r16 = 2 ?
		brsh case7
		ldi w, 6
		rjmp end_switch
case7:
		cpi a0,15   //r16 = 2 ?
		brsh case8
		ldi w, 7
		rjmp end_switch
case8:
		ldi w, 8

end_switch:
	mov a0, w


//switch 2 : le retour ; affichage du rythme sur l'écran LCD
//case000:
		tst a2
		brne case001
		PRINTF	LCD
.db		CR,CR,"noires         ",0
		rjmp end_switch00
case001:
		cpi a2,1  
		brne case002
		PRINTF	LCD
.db		CR,CR,"croches        ",0
		rjmp end_switch00
case002:
		cpi a2,2   
		brne case003
		PRINTF	LCD
.db		CR,CR,"triolet          ",0
		rjmp end_switch00
case003:
		cpi a2,3  
		PRINTF	LCD
.db		CR,CR,"doubles croches",0
end_switch00:


		push a0
		push a2
		rcall display_matrice
		pop a2
		pop a0


		rcall play_note	

		rjmp	main
	