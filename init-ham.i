
; startup code stuff for 220x176 15 bit chunky
; (1.5x1 pixel aspect) to 640x176 hires HAM8


	include "c2p/c2p_2rgb555_3rgb555h8_040.s"

	section code,code

sync: 	dc.l 0
exitflag: dc.w 0
vblflag: dc.w 0
updatebitplanesflag: dc.w 0
newbitplanes: dc.l 0

Lvl3irq:
	movem.l	d0-a6,-(sp)

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
	add.l #14080,d0
	move.w d0,bplptr2+6
	swap d0
	move.w d0,bplptr2+2

	swap d0
	add.l #14080,d0
	move.w d0,bplptr3+6
	swap d0
	move.w d0,bplptr3+2

	swap d0
	add.l #14080,d0
	move.w d0,bplptr4+6
	swap d0
	move.w d0,bplptr4+2

	swap d0
	add.l #14080,d0
	move.w d0,bplptr5+6
	swap d0
	move.w d0,bplptr5+2
	
	swap d0
	add.l #14080,d0
	move.w d0,bplptr6+6
	swap d0
	move.w d0,bplptr6+2

	swap d0
	add.l #14080,d0
	move.w d0,bplptr7+6
	swap d0
	move.w d0,bplptr7+2

	swap d0
	add.l #14080,d0
	move.w d0,bplptr8+6
	swap d0
	move.w d0,bplptr8+2

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

	move.l #(20*176-1),d0
.loop
	move.l #$6db6db6d,(a0)+
	dbra d0,.loop


	move.l #(20*176-1),d0
.loop2
	move.l #$db6db6db,(a0)+
	dbra d0,.loop2

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

copperlistHam8
	dc.w	BPLCON3,$0000
	dc.w	BPLCON0,$8811	; 8 bitplanes, HAM, hires, ECS enabled
	dc.w	FMODE,$0003		; AGA fetch mode
	dc.w	DDFSTRT,$0038,DDFSTOP,$00c0	; dma fetch start AGA FETCH MODE in HIRES

						; You need to change these values to modify the screen height
	dc.w	DIWSTRT
	dc.w	$5281		; 320x176 screen   ; for 320x256 use $2881 here...
	dc.w	DIWSTOP		; 
	dc.w	$02c1		;			       ; ...and $28c1 here
	
	dc.w	BPLCON1,$0000
	dc.w	BPLCON2,$0000
	dc.w	BPL1MOD,$0000
	dc.w 	BPL2MOD,$0000
	
	dc.w	SPR0PTH,$0000,SPR0PTL,$0000		; Clear sprite pointers
	dc.w	SPR1PTH,$0000,SPR1PTL,$0000
	dc.w	SPR2PTH,$0000,SPR2PTL,$0000
	dc.w	SPR3PTH,$0000,SPR3PTL,$0000
	dc.w	SPR4PTH,$0000,SPR4PTL,$0000
	dc.w	SPR5PTH,$0000,SPR5PTL,$0000
	dc.w	SPR6PTH,$0000,SPR6PTL,$0000
	dc.w	SPR7PTH,$0000,SPR7PTL,$0000
	
	dc.w	COLOR00,$0000			; Color00 = black

	dc.w $10cf, $fffe ; wait a bit in case vblank needs time

bplptr1	dc.w BPL1PTH,$0000		; bitplane pointers
		dc.w BPL1PTL,$0000
bplptr2	dc.w BPL2PTH,$0000
		dc.w BPL2PTL,$0000
bplptr3	dc.w BPL3PTH,$0000
		dc.w BPL3PTL,$0000
bplptr4	dc.w BPL4PTH,$0000
		dc.w BPL4PTL,$0000
bplptr5	dc.w BPL5PTH,$0000
		dc.w BPL5PTL,$0000
bplptr6	dc.w BPL6PTH,$0000
		dc.w BPL6PTL,$0000
bplptr7	dc.w BPL7PTH,$0000
		dc.w BPL7PTL,$0000
bplptr8	dc.w BPL8PTH,$0000
		dc.w BPL8PTL,$0000

		dc.w $ffff, $fffe
