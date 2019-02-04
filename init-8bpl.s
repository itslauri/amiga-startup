
; startup code stuff for 320x176 8 bit chunky to 320x176 8 bitplane AGA lores


	include "c2p/c2p1x1_8_c5_gen.s"

	section code,code

sync: 	dc.l 0
exitflag: dc.w 0
vblflag: dc.w 0
updateBitplanesFlag: dc.w 0
newBitplanes: dc.l 0
updatePaletteFlag: dc.w 0
newPalette: dc.l 0

Lvl3irq:
	movem.l	d0-a6,-(sp)

	add.l	#1,sync

	move.w	#1,vblflag

	btst	#6,$bfe001	;left mouse button pressed?
	bne		.noclick
	move.w #1,exitflag
.noclick

	tst.w updateBitplanesFlag
	beq .nonewbpls
	move.w #0,updateBitplanesFlag
	move.l newBitplanes,a0
	bsr setBitplanes
.nonewbpls

	tst.w updatePaletteFlag
	beq .nonewpal
	move.w #0,updatePaletteFlag
	move.l newPalette,a0
	bsr setPalette
.nonewpal


	lea		$dff000,a6
	move.w	#$0020,Intreq(a6)
	move.w	#$0020,Intreq(a6)
	movem.l	(sp)+,d0-a6
	rte



waitVBlank

	clr.w	vblflag
.wait
	tst.w	vblflag
	beq	.wait

	rts


setBitplanes
	;lea bitplane1,a0

	movem.l	d0-a6,-(a7)

	move.l a0,d0
	move.w d0,bplptr1+6
	swap d0
	move.w d0,bplptr1+2

	swap d0
	add.l #BPLSIZE,d0
	move.w d0,bplptr2+6
	swap d0
	move.w d0,bplptr2+2

	swap d0
	add.l #BPLSIZE,d0
	move.w d0,bplptr3+6
	swap d0
	move.w d0,bplptr3+2

	swap d0
	add.l #BPLSIZE,d0
	move.w d0,bplptr4+6
	swap d0
	move.w d0,bplptr4+2

	swap d0
	add.l #BPLSIZE,d0
	move.w d0,bplptr5+6
	swap d0
	move.w d0,bplptr5+2
	
	swap d0
	add.l #BPLSIZE,d0
	move.w d0,bplptr6+6
	swap d0
	move.w d0,bplptr6+2

	swap d0
	add.l #BPLSIZE,d0
	move.w d0,bplptr7+6
	swap d0
	move.w d0,bplptr7+2

	swap d0
	add.l #BPLSIZE,d0
	move.w d0,bplptr8+6
	swap d0
	move.w d0,bplptr8+2

	movem.l	(a7)+,d0-a6
	rts



;	Set AGA 256 colour palette
;
;	a0 = source
;	(a1 = destination) (copperlist)

setPalette

	movem.l	d0-a6,-(a7)
	lea paletteCopperlist,a1

	move.l	#255,d0
	move.l	#$f0f0f0f0,d3
	move.l	#$0f0f0f00,d4
.putcol	
	move.l	(a0)+,d1
	lsl.l #8,d1
	move.l	d1,d2

	and.l	d3,d1
	and.l	d4,d2

	lsr.l	#8,d1
	lsr.l	#4,d1
	move.l	d1,d5
	and.l	#$000f,d5
	lsr.l	#4,d1
	or.l	d1,d5
	lsr.l	#4,d1
	and.l	#$0f00,d1
	or.l	d1,d5
	and.l	#$0fff,d5

	lsr.l	#8,d2
	move.l	d2,d6
	and.l	#$000f,d6
	lsr.l	#4,d2
	or.l	d2,d6
	lsr.l	#4,d2
	and.l	#$0f00,d2
	or.l	d2,d6
	and.l	#$0fff,d6

	move.w	d5,6(a1)
	and.l	#$0fff,d6
	move.w	d6,14(a1)
	add.l	#16,a1
	dbra	d0,.putcol

	movem.l	(a7)+,d0-a6
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
	move.l a1,newBitplanes
	bsr c2p1x1_8_c5_gen

	move.l sync,d0
	move.l .prevFlipTime,d1
	cmp.l d0,d1
	bne .cont2
	bsr waitVBlank
.cont2
	move.l sync,.prevFlipTime

	move.w #1,updateBitplanesFlag ; vblank interrupt should pick this up
	rts

.currentScreen dc.w 0
.prevFlipTime dc.l -1



initC2P
	; init c2p

	; d0.w	chunkyx [chunky-pixels]
	; d1.w	chunkyy [chunky-pixels]
	; d3.w	scroffsy [screen-pixels]
	move.l #320,d0
	move.l #176,d1
	move.l #0,d3
	bsr c2p1x1_8_c5_gen_init

	rts

	
	section chipmem, bss_c

	cnop 0,6
bitplanes1
	blk.b 320*176,0
bitplanes2
	blk.b 320*176,0
bitplanes3
	blk.b 320*176,0
	

********************** copperlist *************

	section chipmem, data_c

copperlist
	dc.w	$0106,$0000,$01fc,$0000		; AGA compatible
	dc.w	$008e
	dc.w	$5281		; 320x176 screen       ;for 320x256 use $2881 here
	dc.w	$0090		; 
	dc.w	$02c1		;			;and $28c1 here
	
	dc.w	$0092,$0038,$0094,$00a0	;dma fetch start AGA FETCH MODE

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
bplcon dc.w	$0011				; 8bpl
	
	dc.w	$01fc, $0003		; AGA fetch mode

	dc.w	$0180,$0000			; Color00 = black

	dc.w $10cf, $fffe ; wait a bit in case vblank interrupt needs time to update palette and bitplanes below

paletteCopperlist
	; generate AGA palette copperlist
BPLCON3VAL set $0020
	rept 8
COLORREGVAL set $180
		rept 32
			dc.w	BPLCON3,BPLCON3VAL,COLORREGVAL,$0000,BPLCON3,BPLCON3VAL|$0200,COLORREGVAL,$0000
COLORREGVAL set COLORREGVAL+$2
		endr
BPLCON3VAL set BPLCON3VAL+$2000
	endr

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
