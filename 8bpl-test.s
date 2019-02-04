
; test program for 8 bitplane startup code
; compiles with PhxAss at least

	MACHINE 68020

	include "init.s"
	include "init-8bpl.s"

	section	code,code

main
	bsr init ; switch off system and set custom copperlist etc
	bsr initC2P ; set parameters for chunky to planar routine

	lea texture,a0
	adda.l #6,a0 ; skip header in texture
	move.l a0,newpalette
	move.w #1,updatepaletteflag ; set flag to update palette in next vblank int

.mainloop
	
		bsr drawTestScreen

		lea screen,a0
		bsr flipScreen

		tst.w exitflag

	beq .mainloop

	bsr deinit

	rts



drawTestScreen
	; draws a scrolling texture to chunky screen

	lea screen,a0
	lea texture,a1

	move.l sync,d2 ; sync is our global timer incremented in vblank interrupt 50 times a second

	move.l #176-1,d0
.yloop

	movea.l a1,a2
	adda.l #6+256*4,a2 ; skip header and palette
	adda.l d2,a2

	move.l #(320/4/8)-1,d1
.xloop
		rept 8
			move.l (a2)+,(a0)+
		endr
	dbra d1,.xloop

	adda.l #256,a1

	dbra d0,.yloop

	rts


	section data,bss

screen
	blk.b 320*176,0

	section data,data

texture
	incbin "data/texture.uc"
