
; startup code to kill system, set up a screen
; and handle triple buffered c2p screen flipping
; for 220x176 15 bit chunky (1.5x1 pixel aspect) to 640x176 hires HAM8


	include "c2p/c2p_2rgb555_3rgb555h8_040.s"

	section code

	include	include/libraries.i
	include	include/hardware.i

Execbase = 4

init
	movem.l	d0-d7/a0-a6,-(a7)
	move.l	(Execbase).w,a6
	lea	System(pc),a5
	move.l	sp,Userstack(a5)
	jsr	SuperState(a6)
	move.w	$128(a6),d1
	btst	#0,d1
	beq.b	.noexcpu
	movec	vbr,d1
	move.l	d1,Vecbase(a5)
.noexcpu
	move.l	d0,d1
	moveq	#14,d2
	sub.l	d2,d1
	move.l	d1,Superstack(a5)
	jsr	UserState(a6)


	lea	.gfxname(pc),a1
	moveq	#33,d0
	jsr	Openlib(a6)
	move.l	d0,Gfxbase(a5)
	beq.w	exit
	move.l	d0,a6
	move.l	34(a6),Viewscr(a5)
	move.l	38(a6),Oldcopper(a5)
	suba.l	a1,a1
	jsr	LoadView(a6)
	jsr	WaitTOF(a6)
	jsr	WaitTOF(a6)
	jsr	OwnBlitter(a6)
	jsr	WaitBlit(a6)
	move.l	(Execbase).w,a6
	jsr	Forbid(a6)
	cmpi.b	#50,530(a6)
	seq.b	Frequency(a5)

 ********************************

	movem.l	Setup(pc),d0/d1/a4/a6
	lea	Hardware(a5),a1
	move.w	Dmaconr(a6),(a1)
	or.w	d1,(a1)+
	move.w	Intenar(a6),(a1)
	or.w	d1,(a1)+
	move.w	Intreqr(a6),(a1)
	or.w	d1,(a1)+
	move.w	Adkconr(a6),(a1)
	or.w	d1,(a1)

 ********************************

	move.w	d0,Dmacon(a6)
	move.l	d0,Intena(a6)
	move.w	d0,Adkcon(a6)

 ********************************

	move.w	#$0020,BEAMCON0(a6)
	lea	SPR0POS(a6),a0
	moveq	#0,d1
	move.w	d1,COLOR00(a6)
	moveq	#14-1,d0
.loop
	move.l	d1,(a0)+
	dbf	d0,.loop
	bsr.w	killdrives

 ********************************

	move.w	LisaID(a6),d0
	cmpi.b	#$f8,d0
	sne.b	Agaflag(a5)

 ********************************

	move.l	Vecbase(a5),a1
	move.l	$6c(a1),Lvl3vec(a5)
	lea	Lvl3irq(pc),a0
	move.l	a0,$6c(a1)
	move.w	#$c020,Intena(a6)

 ********************************
 	move.l a5,a5store
 	move.l a6,a6store

	move.l #cop,$dff080	; Set our copperlist

	move.w	#$83c0,Dmacon(a6)	; Turn on needed DMA


	movem.l	(a7)+,d0-d7/a0-a6

		rts


.gfxname		dc.b	"graphics.library",0
		even


deinit
	movem.l	d0-d7/a0-a6,-(a7)
	movea.l a5store,a5
	movea.l a6store,a6

	move.l	#$7fff7fff,d0
	move.w	d0,Dmacon(a6)
	move.l	d0,Intena(a6)
	move.w	d0,Adkcon(a6)
	move.l	Vecbase(a5),a1
	move.l	Lvl3vec(a5),$6c(a1)
	move.l	Oldcopper(a5),Cop1lch(a6)
	move.w	d0,Copjmp1(a6)
	lea	Hardware(a5),a1
	move.w	(a1)+,Dmacon(a6)
	move.w	(a1)+,Intena(a6)
	move.w	(a1)+,Intreq(a6)
	move.w	(a1),Adkcon(a6)

 ********************************

	move.l	Gfxbase(a5),a6
	move.l	Viewscr(a5),a1
	jsr	LoadView(a6)
	jsr	DisownBlitter(a6)
	move.l	a6,a1
	move.l	(Execbase).w,a6
	jsr	Closelib(a6)
	jsr	Permit(a6)
exit
	moveq	#0,d0
	movem.l	(a7)+,d0-d7/a0-a6
	rts


killdrives
		moveq	#3,d0
.mop1
		bclr	d0,$100(a4)
		bsr.b	.pause
		bset	#7,$100(a4)
		bsr.b	.pause
		bset	d0,$100(a4)
		bsr.b	.pause
		addq.b	#1,d0
		cmpi.b	#7,d0
		bne.b	.mop1
		rts
.pause
		moveq	#2-1,d1
.mop2
		move.b	Vhposr(a6),d2
.mop3
		cmp.b	Vhposr(a6),d2
		beq.b	.mop3
		dbf	d1,.mop2
		rts

	 ********************************

Setup:
	dc.l	$7fff7fff
	dc.l	$80008000
	dc.l	$bfd000
	dc.l	$dff000

a5store	dc.l 0
a6store dc.l 0

		rsreset

Agaflag:	rs.b	1
Frequency:	rs.b	1
Hardware:	rs.w	4
Gfxbase:	rs.l	1
Viewscr:	rs.l	1
Oldcopper:	rs.l	1
Lvl3vec:	rs.l	1
Vecbase:	rs.l	1
Userstack:	rs.l	1
Superstack:	rs.l	1
Sys_sizeof:	rs.b	0
System:
		ds.b	Sys_sizeof


		even

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

		; draw control patterns to ham8 bitplanes for this particular c2p
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

cop:		dc.w	$0106,$0000,$01fc,$0000		; AGA compatible
		dc.w	$008e
		dc.w	$5281		; 320x200 screen       ;usually $2881 here
		dc.w	$0090		; instead of the standard
		dc.w	$02c1		; 320x256 one			;and $28c1 here
		
		dc.w	$0092,$0038,$0094
dmafetchend		dc.w $00c0		; dma fetch start AGA FETCH MODE
;		dc.w	$0092,$0038,$0094,$00d0		; dma fetch start OCS FETCH MODE (or aga super hires)

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
bplcon:		dc.w	$8811				; ham8 hires
	
	dc.w	$01fc, $0003		; AGA fetch mode

		dc.w	$0180,$0000			; Color00 = black
;		dc.w	$0182,$0f11

	dc.w $25cf, $fffe ; wait a bit in case vblank needs time

bplptr1:	dc.w $00e0,$0000		; bitplane locations
			dc.w $00e2,$0000
bplptr2:	dc.w $00e4,$0000
			dc.w $00e6,$0000
bplptr3:	dc.w $00e8,$0000
			dc.w $00ea,$0000
bplptr4:	dc.w $00ec,$0000
			dc.w $00ee,$0000
bplptr5:	dc.w $00f0,$0000
			dc.w $00f2,$0000
bplptr6:	dc.w $00f4,$0000
			dc.w $00f6,$0000
bplptr7:	dc.w $00f8,$0000
			dc.w $00fa,$0000
bplptr8:	dc.w $00fc,$0000
			dc.w $00fe,$0000

		dc.w $ffff, $fffe
