
; test program for ham8 startup code
; compiles with PhxAss at least

	MACHINE 68020

	bra main

	include "init.i"
	include "init-ham.i"

	section code,code

main
	bsr initC2PHam ; set parameters for chunky to planar routine and setup bitplanes
	bsr init ; switch off system and set custom copperlist etc
	move.l #copperlistHam,$dff080	; Set our copperlist

.mainloop
	
		bsr drawTestScreen

		lea screen,a0
		bsr flipScreenHam

		tst.w exitflag

	beq .mainloop

	bsr deinit

	rts



drawTestScreen
	; draws a scrolling texture to chunky screen

	lea screen,a0
	lea texture,a1

	move.l sync,d2 ; sync is our global timer incremented in vblank interrupt 50 times a second
	lsl.l #1,d2 ; shift up to scroll words

	move.l #176-1,d0
.yloop
	movea.l a1,a2
	adda.l d2,a2

	move.l #(220/10)-1,d1
.xloop
		rept 10
			move.w (a2)+,(a0)+
			addq.l #2,a2 ; skip every other texture pixel
		endr
	dbra d1,.xloop

	adda.l #(256<<1),a1
	dbra d0,.yloop

	rts


	section data, bss

screen
	blk.w 220*176,0

	section data,data

texture
	incbin "data/texture.c15"
