
; startup code to kill system and set up copperlist and vblank interrupt

	section code

	include	include/libraries.i
	include	include/hardware.i

	bra main

Execbase = 4

init
	movem.l	d0-a6,-(a7)
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

	move.w	#$83c0,Dmacon(a6)	; Turn on needed DMA


	movem.l	(a7)+,d0-a6

		rts


.gfxname		dc.b	"graphics.library",0
		even


deinit
	movem.l	d0-a6,-(a7)
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
	movem.l	(a7)+,d0-a6
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
