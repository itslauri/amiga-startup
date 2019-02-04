
; startup code stuff for 220x176 15 bit chunky
; (1.5x1 pixel aspect) to 640x176 hires HAM8


	include "c2p/c2p_2rgb555_3rgb555h8_040.s"

	section code

sync: 	dc.l 0
exitflag: dc.w 0
vblflag: dc.w 0
updatebitplanesflag: dc.w 0
newbitplanes: dc.l 0

Lvl3irq:
	movem.l	d0-d7/a0-a6,-(sp)

	add.l	#1,sync

	move.w	#1,vblflag

	btst	#6,$bfe001	;left mouse button pressed?
	bne		.noclick
	move.w #1,exitflag
.noclick

	tst.w updatebitplanesflag
	beq .nonewbpls
	move.w #0,updatebitplanesflag
	move.l newbitplanes,a0
	bsr setBitplanes
.nonewbpls

	lea		$dff000,a6
	move.w	#$0020,Intreq(a6)
	move.w	#$0020,Intreq(a6)
	movem.l	(sp)+,d0-d7/a0-a6
	rte



waitVBlank

	clr.w	vblflag
.wait
	tst.w	vblflag
	beq	.wait

	rts


setBitplanes
	;lea bitplane1,a0

	movem.l	d0-d7/a0-a6,-(a7)

	move.l a0,d0
	move.w d0,bplptr1+6
	swap d0
	move.w d0,bplptr1+2

	swap d0
	add.l #14080, d0
	move.w d0,bplptr2+6
	swap d0
	move.w d0,bplptr2+2

	swap d0
	add.l #14080, d0
	move.w d0,bplptr3+6
	swap d0
	move.w d0,bplptr3+2

	swap d0
	add.l #14080, d0
	move.w d0,bplptr4+6
	swap d0
	move.w d0,bplptr4+2

	swap d0
	add.l #14080, d0
	move.w d0,bplptr5+6
	swap d0
	move.w d0,bplptr5+2
	
	swap d0
	add.l #14080, d0
	move.w d0,bplptr6+6
	swap d0
	move.w d0,bplptr6+2

	swap d0
	add.l #14080, d0
	move.w d0,bplptr7+6
	swap d0
	move.w d0,bplptr7+2

	swap d0
	add.l #14080, d0
	move.w d0,bplptr8+6
	swap d0
	move.w d0,bplptr8+2

	movem.l	(a7)+,d0-d7/a0-a6
	rts



flipScreen
	; a0 = chunky screen
	; handles triple buffering for bitplanes
	; sets flag for bitplanes to be set in vblank interrupt


	cmp.w #0,.currentScreen
	beq .bpls1
	cmp.w #1,.currentScreen
	beq .bpls2
	cmp.w #2,.currentScreen
	beq .bpls3

.bpls1
	lea bitplanes1,a1
	move.w #1,.currentScreen
	bra .cont

.bpls2
	lea bitplanes2,a1
	move.w #2,.currentScreen
	bra .cont

.bpls3
	lea bitplanes3,a1
	move.w #0,.currentScreen

.cont
	move.l a1,newbitplanes
	adda.l #14080*3,a1 ;skip control and lowest bitplane
	bsr c2p_2rgb555_3rgb555h8_040

	move.l sync,d0
	move.l .prevFlipTime,d1
	cmp.l d0,d1
	bne .cont2
	bsr waitVBlank
.cont2
	move.l sync,.prevFlipTime

	move.w #1,updatebitplanesflag ; vblank interrupt should pick this up
	rts

.currentScreen dc.w 0
.prevFlipTime dc.l -1



initC2P
; init c2p
; params for init:
; d0.w	chunkyx [chunky-pixels]
; d1.w	chunkyy [chunky-pixels]
; d2.w	scroffsx [screen-pixels]
; d3.w	scroffsy [screen-pixels]
; d4.l	rowlen [bytes] -- offset between one row and the next in a bpl
; d5.l	bplsize [bytes] -- offset between one row in one bpl and the next bpl
; d6.l	chunkylen [bytes] -- offset between one row and the next in chunkybuf
	move.l #220,d0
	move.l #176,d1
	clr d2
	clr d3
	moveq.l #80,d4
	move.l #14080,d5
	move.l #440,d6
	bsr c2p_2rgb555_3rgb555h8_040_init

		; write control bitplane patterns for this particular c2p
	lea bitplanes1,a0 
	bsr drawControlPattern
	lea bitplanes2,a0
	bsr drawControlPattern
	lea bitplanes3,a0
	bsr drawControlPattern

	rts



drawControlPattern
	;a0 target bitplanes

	move.l #(20*176-1), d0
.loop
	move.l #$6db6db6d, (a0)+
	dbra d0, .loop


	move.l #(20*176-1), d0
.loop2
	move.l #$db6db6db, (a0)+
	dbra d0, .loop2

	rts

	
	section chipmem, bss_c

	cnop 0,6
bitplanes1
	blk.b 640*176,0
bitplanes2
	blk.b 640*176,0
bitplanes3
	blk.b 640*176,0
	

********************** copperlist *************

	section chipmem, data_c

copperlist
	dc.w	$0106,$0000,$01fc,$0000		; AGA compatible
	dc.w	$008e
	dc.w	$5281		; 320x200 screen       ;usually $2881 here
	dc.w	$0090		; instead of the standard
	dc.w	$02c1		; 320x256 one			;and $28c1 here
	
	dc.w	$0092,$0038,$0094
dmafetchend		dc.w $00c0		; dma fetch start AGA FETCH MODE

	dc.w	$0102,$0000
	dc.w	$0104,$0000
	dc.w    $0108,0
	dc.w 	$010A,0
	
	dc.w	$0120,$0000,$0122,$0000		; Clear spriteptrs
	dc.w	$0124,$0000,$0126,$0000
	dc.w	$0128,$0000,$012a,$0000
	dc.w	$012c,$0000,$012e,$0000
	dc.w	$0130,$0000,$0132,$0000
	dc.w	$0134,$0000,$0136,$0000
	dc.w	$0138,$0000,$013a,$0000
	dc.w	$013c,$0000,$013e,$0000
	
	dc.w	$0100
bplcon dc.w	$8811				; ham8 hires
	
	dc.w	$01fc, $0003		; AGA fetch mode

	dc.w	$0180,$0000			; Color00 = black

	dc.w $25cf, $fffe ; wait a bit in case vblank needs time

bplptr1	dc.w $00e0,$0000		; bitplane locations
		dc.w $00e2,$0000
bplptr2	dc.w $00e4,$0000
		dc.w $00e6,$0000
bplptr3	dc.w $00e8,$0000
		dc.w $00ea,$0000
bplptr4	dc.w $00ec,$0000
		dc.w $00ee,$0000
bplptr5	dc.w $00f0,$0000
		dc.w $00f2,$0000
bplptr6	dc.w $00f4,$0000
		dc.w $00f6,$0000
bplptr7	dc.w $00f8,$0000
		dc.w $00fa,$0000
bplptr8	dc.w $00fc,$0000
		dc.w $00fe,$0000

		dc.w $ffff, $fffe
