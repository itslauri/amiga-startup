
; ADPCM replayer by BriteLite / Dekadence
; Plays IMA 4:1 ADPCM .wav files with Paula in 14 bit mono or stereo
; No error checks.

; initMusic:
; starts playback. pass adpcm wav location in a0
; stopMusic:
; stops playback

		section	code,code

fixbyte macro
		lsr.b	#2,d6
		endm


diffiL	macro
		move.l	d2,d4
		add.l	(a3,d2.l*4),d3
		and.l	#7,d4
		cmp.l	#0,d3
		bge.s	.ok1\@
		moveq.l	#0,d3
.ok1\@	cmp.l	#88,d3
		ble.s	.ok2\@
		moveq.l	#88,d3
.ok2\@	
		and.l	#8,d2
		mulu.l	d0,d4
		asr.l	#2,d4
		asr.l	#3,d0
		add.l	d0,d4

		move.l	(a4,d3.l*4),d0

		cmp.l	#8,d2
		bne.s	.pos\@
		neg.l	d4

.pos\@	add.l	a5,d4
		cmp.l	#-$8000,d4
		bge.s	.ok3\@
		move.l	#-$8000,d4
.ok3\@	cmp.l	#$7fff,d4
		ble.s	.ok4\@
		move.l	#$7fff,d4
.ok4\@	move.l	d4,a5
		endm

diffiR	macro
		move.l	d2,d4
		add.l	(a3,d2.l*4),d3
		and.l	#7,d4
		cmp.l	#0,d3
		bge.s	.ok1\@
		moveq.l	#0,d3
.ok1\@	cmp.l	#88,d3
		ble.s	.ok2\@
		moveq.l	#88,d3
.ok2\@	
		and.l	#8,d2
		mulu.l	d0,d4
		asr.l	#2,d4
		asr.l	#3,d0
		add.l	d0,d4

		move.l	(a4,d3.l*4),d0

		cmp.l	#8,d2
		bne.s	.pos\@
		neg.l	d4

.pos\@	add.l	a5,d4
		cmp.l	#-$8000,d4
		bge.s	.ok3\@
		move.l	#-$8000,d4
.ok3\@	cmp.l	#$7fff,d4
		ble.s	.ok4\@
		move.l	#$7fff,d4
.ok4\@	move.l	d4,a5
		endm


diffi	macro
		move.l	d2,d4
		add.l	(a3,d2.l*4),d3
		and.l	#7,d4
		cmp.l	#0,d3
		bge.s	.ok1\@
		moveq.l	#0,d3
.ok1\@	cmp.l	#88,d3
		ble.s	.ok2\@
		moveq.l	#88,d3
.ok2\@	

		and.l	#8,d2
		mulu.l	d0,d4
		asr.l	#2,d4
		asr.l	#3,d0
		add.l	d0,d4

		move.l	(a4,d3.l*4),d0

		cmp.l	#8,d2
		bne.s	.pos\@
		neg.l	d4

.pos\@	add.l	a5,d4
		cmp.l	#-$8000,d4
		bge.s	.ok3\@
		move.l	#-$8000,d4
.ok3\@	cmp.l	#$7fff,d4
		ble.s	.ok4\@
		move.l	#$7fff,d4
.ok4\@	move.l	d4,a5
		endm

*-------------------------------------------------------------------------

decodeAdpcm_stereo
		
		move.w	(a0),d4
		lea		index_table,a3
		lea		step_table,a4
	
		move.w	d4,d5
		rol.w	#8,d4
		ror.w	#8,d5
		move.b	d5,d4

		ext.l	d4
		move.l	d4,predictorL

		move.b	2(a0),d2
		and.l	#$7f,d2
		move.l	d2,step_indexL

		move.l	(a4,d2.l*4),stepL

		move.w	4(a0),d4
		move.w	d4,d5
		rol.w	#8,d4
		ror.w	#8,d5
		move.b	d5,d4
		ext.l	d4
		move.l	d4,predictorR

		move.b	6(a0),d2
		and.l	#$7f,d2
		move.l	d2,step_indexR

		move.l	(a4,d2.l*4),stepR

		addq.l	#8,a0
	
		move.w	cdata,d1
		lsr.w	#2,d1
.putsnd	move.l	(a0)+,d7
		rol.l	#8,d7
		move.l	step_indexL,d3
		move.b	d7,d2
		move.l	stepL,d0
		and.l	#$f,d2
		move.l	predictorL,a5

		diffiL

		move.b	d4,d6
		fixbyte
		move.w	d4,d5
		rol.w	#8,d6
		rol.l	#8,d5

		move.b	d7,d2
		ror.b	#4,d2
		rol.l	#8,d7
		and.l	#$f,d2

		diffiL

		move.b	d4,d6
		fixbyte
		move.w	d4,d5
		swap	d6
		rol.l	#8,d5

		move.b	d7,d2
		and.l	#$f,d2

		diffiL

		move.b	d4,d6
		fixbyte
		move.w	d4,d5
		rol.w	#8,d6

		move.b	d7,d2
		ror.b	#4,d2
		rol.l	#8,d7
		and.l	#$f,d2

		diffiL

		move.b	d4,d6
		fixbyte
		move.l	d6,20000(a1)
		ror.w	#8,d4
		move.b	d4,d5
		move.l	d5,(a1)

		move.b	d7,d2
		and.l	#$f,d2

		diffiL

		move.b	d4,d6
		fixbyte
		move.w	d4,d5
		rol.w	#8,d6
		rol.l	#8,d5

		move.b	d7,d2
		ror.b	#4,d2
		rol.l	#8,d7
		and.l	#$f,d2

		diffiL

		move.b	d4,d6
		fixbyte
		move.w	d4,d5
		swap	d6
		rol.l	#8,d5

		move.b	d7,d2
		and.l	#$f,d2

		diffiL

		move.b	d4,d6
		fixbyte
		move.w	d4,d5
		rol.w	#8,d6

		move.b	d7,d2
		ror.b	#4,d2
		and.l	#$f,d2

		diffiL

		move.l	a5,predictorL
		move.b	d4,d6
		move.l	d0,stepL
		lsr.b	#2,d6
		move.l	d3,step_indexL
		move.l	d6,20004(a1)
		ror.w	#8,d4
		move.b	d4,d5
		move.l	d5,4(a1)


		move.l	(a0)+,d7
		rol.l	#8,d7
		move.l	step_indexR,d3
		move.b	d7,d2
		move.l	stepR,d0
		and.l	#$f,d2
		move.l	predictorR,a5

		diffiR

		move.b	d4,d6
		fixbyte
		move.w	d4,d5
		rol.w	#8,d6
		rol.l	#8,d5

		move.b	d7,d2
		ror.b	#4,d2
		rol.l	#8,d7
		and.l	#$f,d2

		diffiR

		move.b	d4,d6
		fixbyte
		move.w	d4,d5
		swap	d6
		rol.l	#8,d5

		move.b	d7,d2
		and.l	#$f,d2

		diffiR

		move.b	d4,d6
		fixbyte
		move.w	d4,d5
		rol.w	#8,d6

		move.b	d7,d2
		lsr.b	#4,d2
		rol.l	#8,d7
		and.l	#$f,d2

		diffiR

		move.b	d4,d6
		fixbyte
		move.l	d6,30000(a1)
		ror.w	#8,d4
		move.b	d4,d5
		move.l	d5,10000(a1)

		move.b	d7,d2
		and.l	#$f,d2

		diffiR

		move.b	d4,d6
		fixbyte
		move.w	d4,d5
		rol.w	#8,d6
		rol.l	#8,d5

		move.b	d7,d2
		ror.b	#4,d2
		rol.l	#8,d7
		and.l	#$f,d2

		diffiR

		move.b	d4,d6
		fixbyte
		move.w	d4,d5
		swap	d6
		rol.l	#8,d5

		move.b	d7,d2
		and.l	#$f,d2

		diffiR

		move.b	d4,d6
		fixbyte
		move.w	d4,d5
		rol.w	#8,d6

		move.b	d7,d2
		ror.b	#4,d2
		and.l	#$f,d2

		diffiR

		move.l	a5,predictorR
		move.b	d4,d6
		move.l	d0,stepR
		lsr.b	#2,d6
		move.l	d3,step_indexR
		move.l	d6,30004(a1)
		ror.w	#8,d4
		move.b	d4,d5
		move.l	d5,10004(a1)

		addq.l	#8,a1
	
		subq.w	#1,d1
		bne		.putsnd
		rts

*-------------------------------------------------------------------------

decodeAdpcm_mono

		move.w	(a0),d4
		lea		index_table,a3
		lea		step_table,a4

		move.w	d4,d5
		rol.w	#8,d4
		ror.w	#8,d5
		move.b	d5,d4

		ext.l	d4
		move.l	d4,a5               ; predictor

		move.b	2(a0),d3
		and.l	#$7f,d3             ; step_index
		
		move.l	(a4,d3.l*4),d0      ; step

		addq.l	#4,a0
	
		move.w	cdata,d1
		lsr.w	#2,d1
.putsnd	move.l	(a0)+,d7
		rol.l	#8,d7
		move.b	d7,d2
		and.l	#$f,d2

		diffi

		move.b	d4,d6
		fixbyte
		move.w	d4,d5
		rol.w	#8,d6
		rol.l	#8,d5

		move.b	d7,d2
		ror.b	#4,d2
		rol.l	#8,d7
		and.l	#$f,d2

		diffi

		move.b	d4,d6
		fixbyte
		move.w	d4,d5
		swap	d6
		rol.l	#8,d5

		move.b	d7,d2
		and.l	#$f,d2

		diffi

		move.b	d4,d6
		fixbyte
		move.w	d4,d5
		rol.w	#8,d6

		move.b	d7,d2
		ror.b	#4,d2
		rol.l	#8,d7
		and.l	#$f,d2

		diffi

		move.b	d4,d6
		fixbyte
		move.l	d6,10000(a1)
		ror.w	#8,d4	
		move.b	d4,d5
		move.l	d5,(a1)+


		move.b	d7,d2
		and.l	#$f,d2

		diffi

		move.b	d4,d6
		fixbyte
		move.w	d4,d5
		rol.w	#8,d6
		rol.l	#8,d5

		move.b	d7,d2
		ror.b	#4,d2
		rol.l	#8,d7
		and.l	#$f,d2

		diffi

		move.b	d4,d6
		fixbyte
		move.w	d4,d5
		swap	d6
		rol.l	#8,d5

		move.b	d7,d2
		and.l	#$f,d2

		diffi

		move.b	d4,d6
		fixbyte
		move.w	d4,d5
		rol.w	#8,d6

		move.b	d7,d2
		ror.b	#4,d2
		and.l	#$f,d2

		diffi

		move.b	d4,d6
		fixbyte
		move.l	d6,10000(a1)
		ror.w	#8,d4
		move.b	d4,d5
		move.l	d5,(a1)+
		
		subq.w	#1,d1
		bne		.putsnd
		rts

*-------------------------------------------------------------------------


predictorL
		dc.l	0
step_indexL
		dc.l	0
stepL
		dc.l	0

predictorR
		dc.l	0
step_indexR
		dc.l	0
stepR
		dc.l	0

predictor
		dc.l	0
step_index
		dc.l	0
step
		dc.l	0



; for adpcm-decoding

index_table
		dc.l	-1, -1, -1, -1, 2, 4, 6, 8
		dc.l	-1, -1, -1, -1, 2, 4, 6, 8


step_table
		dc.l	7, 8, 9, 10, 11, 12, 13, 14, 16, 17
		dc.l	19, 21, 23, 25, 28, 31, 34, 37, 41, 45
		dc.l	50, 55, 60, 66, 73, 80, 88, 97, 107, 118
		dc.l	130, 143, 157, 173, 190, 209, 230, 253, 279, 307
		dc.l	337, 371, 408, 449, 494, 544, 598, 658, 724, 796
		dc.l	876, 963, 1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066
		dc.l	2272, 2499, 2749, 3024, 3327, 3660, 4026, 4428, 4871, 5358
		dc.l	5894, 6484, 7132, 7845, 8630, 9493, 10442, 11487, 12635, 13899
		dc.l	15289, 16818, 18500, 20350, 22385, 24623, 27086, 29794, 32767

*-------------------------------------------------------------------------

Play_Stream_stereo:
        movem.l d0-a6,-(sp)				; save all registers
        lea     ActChipBuffer(pc),a1	; address of chip buffer ID (0 or –1)
        move.w  (a1),d0					; read buffer ID
        not.w   (a1)					; swap buffers (0 -> -1 or –1 -> 0)
        move.l  -28(a1,d0.w*4),a1		; reads the address of the chip buffer
                                        ; the –4 points us to the middle of the
                                        ; chip buffer addresses and d0 gives us
                                        ; now buffer 2 (offset d0=0*4=0) or
                                        ; buffer 1 (offset d0=–1*4=-4)

        move.l  a1,a2                   ; make copy of target buffer

        lea     StreamPosition(pc),a3   ; address of stream position
		move.l	chunk,d0
        move.l  (a3),a0                 ; get position in the stream
        add.l	d0,(a3)                 ; step further in stream by increasing pos
		cmp.l	StreamEnd,a0
		blt.s	.streamok
		move.l	StreamBegin,(a3)
.streamok
		bsr		decodeAdpcm_stereo


        lea     $dff0a0,a0              ; gets address of channelA data

		lea		10000(a2),a3
		lea		10000(a3),a4
		lea		10000(a4),a5

		move.w	cdata,d0
		swap	d0
		move.w	freq,d0				; length of soundbuffer
		move.w	#$40,d2					; volume
		move.w	#$1,d3

		move.l	a2,(a0)			; chan 1
		move.l	d0,4(a0)
		move.w	d2,8(a0)

		move.l	a4,48(a0)		; chan 4
		move.l	d0,52(a0)
		move.w	d3,56(a0)


		move.l	a3,16(a0)		; chan 2
		move.l	d0,20(a0)
		move.w	d2,24(a0)

		move.l	a5,32(a0)		; chan 3
		move.l	d0,36(a0)
		move.w	d3,40(a0)

        lea     $dff09c,a0
        move.w  #%11110000000,(a0)      ; accept all audio interrupts
        move.w  #%11110000000,(a0)      ; accept them again (A4000 bug)

        movem.l (sp)+,d0-a6             ; restore all register values
        rts     ; rte if you have changed the interrupt vectors directly
                ; rts if you choosed the system calls to set up audio interrupt

*-------------------------------------------------------------------------

Play_Stream_mono:
        movem.l d0-a6,-(sp)				; save all registers
        lea     ActChipBuffer(pc),a1	; address of chip buffer ID (0 or –1)
        move.w  (a1),d0					; read buffer ID
        not.w   (a1)					; swap buffers (0 -> -1 or –1 -> 0)
        move.l  -12(a1,d0.w*4),a1		; reads the address of the chip buffer
                                        ; the –4 points us to the middle of the
                                        ; chip buffer addresses and d0 gives us
                                        ; now buffer 2 (offset d0=0*4=0) or
                                        ; buffer 1 (offset d0=–1*4=-4)

        move.l  a1,a2                   ; make copy of target buffer

        lea     StreamPosition(pc),a3   ; address of stream position
		move.l	chunk,d0
        move.l  (a3),a0                 ; get position in the stream
        add.l	d0,(a3)                 ; step further in stream by increasing pos
		cmp.l	StreamEnd,a0
		blt.s	.streamok
		move.l	StreamBegin,(a3)
.streamok
		bsr		decodeAdpcm_mono


        lea     $dff0a0,a0              ; gets address of channelA data

		lea		10000(a2),a3

		move.w	cdata,d0				; length of soundbuffer
		swap	d0
		move.w	freq,d0
		move.w	#$40,d2					; volume
		move.w	#$1,d3

		move.l	a2,(a0)			; chan 1
		move.l	d0,4(a0)
		move.w	d2,8(a0)

		move.l	a3,48(a0)		; chan 4
		move.l	d0,52(a0)
		move.w	d3,56(a0)


		move.l	a2,16(a0)		; chan 2
		move.l	d0,20(a0)
		move.w	d2,24(a0)

		move.l	a3,32(a0)		; chan 3
		move.l	d0,36(a0)
		move.w	d3,40(a0)

        lea     $dff09c,a0
        move.w  #%11110000000,(a0)      ; accept all audio interrupts
        move.w  #%11110000000,(a0)      ; accept them again (A4000 bug)

        movem.l (sp)+,d0-a6             ; restore all register values
        rts     ; rte if you have changed the interrupt vectors directly
                ; rts if you choosed the system calls to set up audio interrupt

*-------------------------------------------------------------------------

_initMusic
initMusic
        movem.l d0-a6,-(sp)             ; save all registers

		move.w	#9999,d0
		move.l	#0,d1
		lea		Buffer1_in_ChipMem,a1
.cliir	move.l	d1,(a1)+
		dbra	d0,.cliir

		move.b	$16(a0),d7

		move.l	4(a0),d0
		move.b	d0,d1
		ror.l	#8,d0
		rol.l	#8,d1
		move.b	d0,d1
		ror.l	#8,d0
		rol.l	#8,d1
		move.b	d0,d1
		ror.l	#8,d0
		rol.l	#8,d1
		move.b	d0,d1
		sub.l	#$3c,d1

		move.l	#3546895*16,d2
		moveq.l	#0,d0
		move.b	$19(a0),d0
		lsl.w	#8,d0
		move.b	$18(a0),d0
		divu.l	d0,d2
		add.l	#8,d2
		lsr.l	#4,d2
		move.w	d2,freq
				
		move.l	#3546895*16,d6
		divu.l	d2,d6
		add.l	#8,d6
		lsr.l	#4,d6
		swap	d6
		
		move.b	$21(a0),d0
		lsl.w	#8,d0
		move.b	$20(a0),d0
		ext.l	d0
		move.l	d0,chunk
		
		cmp.b	#2,d7
		beq		.stereo

.mono	move.w	#1,d6
		swap	d6
		move.l	d6,stuffi

		sub.l	#4,d0
		move.w	d0,cdata

		add.l	#$3c,a0
		move.l	a0,StreamPosition
		move.l	a0,StreamBegin
		add.l	d1,a0
		move.l	a0,StreamEnd

		or.b	#$02,$bfe001			; disable filter

        lea     AudIntStruct(pc),a1     ; load the structures address
        lea     Play_Stream_mono(pc),a0      ; address of the interrupt routine
        addq.b  #2,8(a1)                ; set interrupt type (assumed that the
                                        ; AudIntStruct memory is zeroed)
        move.l  a0,18(a1)               ; set routines address into the structure
        bsr     SetAudInt               ; enables the new interrupt

        bsr.w   Play_Stream_mono		; plays the first stream data

        lea     $dff096,a6
        move.w  #$820f,(a6)             ; enable audio DMA for all four channels
        move.w  #%1100000010000000,$9a-$96(a6) ; enable interrupt for AUD0
        movem.l (sp)+,d0-a6             ; restore all register values
        move.l	stuffi,d0
        rts
		
		
.stereo	move.w	#2,d6
		swap	d6
		move.l	d6,stuffi

		sub.l	#8,d0
		lsr.l	#1,d0
		move.w	d0,cdata

		add.l	#$3c,a0
		move.l	a0,StreamPosition
		move.l	a0,StreamBegin
		add.l	d1,a0
		move.l	a0,StreamEnd

		or.b	#$02,$bfe001			; disable filter

        lea     AudIntStruct(pc),a1     ; load the structures address
        lea     Play_Stream_stereo(pc),a0      ; address of the interrupt routine
        addq.b  #2,8(a1)                ; set interrupt type (assumed that the
                                        ; AudIntStruct memory is zeroed)
        move.l  a0,18(a1)               ; set routines address into the structure
        bsr     SetAudInt               ; enables the new interrupt

        bsr.w   Play_Stream_stereo		; plays the first stream data

        lea     $dff096,a6
        move.w  #$820f,(a6)             ; enable audio DMA for all four channels
        move.w  #%1100000010000000,$9a-$96(a6) ; enable interrupt for AUD0
        movem.l (sp)+,d0-a6             ; restore all register values
        move.l	stuffi,d0
        rts

*-------------------------------------------------------------------------

_stopMusic
stopMusic
        movem.l d0-a6,-(sp)             ; save all registers
        lea     $dff096,a6              ; DMA control registers
        move.w  #%1111,(a6)             ; disable all audio channels
        move.w  #%11110000000,$9a-$96(a6) ; disable all audio interrupts
        sub.l   a1,a1                   ; set 0 as new AudIntStruct,
                                        ; this removes all audio interrupts,
                                        ; also if there has been one before
        bsr.b   SetAudInt              ; the bsr.b and the rts has been removed
        movem.l (sp)+,d0-a6             ; restore all register values
        rts                            ; as the SetAudInt routine follows directly

SetAudInt:
        moveq   #7,d0                   ; flag to set interrupt for AUD0
        move.l  $4.w,a6                 ; read exec base
        jsr     -162(a6)                ; set interrupt, use jmp to spare a rts
        rts

*-------------------------------------------------------------------------

AudIntStruct:
        dcb.b   30,0                    ; space for the AudIntStruct

ChipBuffers:
        dc.l    Buffer1_in_ChipMem      ; pointer to chipbuffer 1
        dc.l    Buffer2_in_ChipMem      ; pointer to chipbuffer 2
        dc.l    Buffer3_in_ChipMem      ; pointer to chipbuffer 3
        dc.l    Buffer4_in_ChipMem      ; pointer to chipbuffer 4
        dc.l    Buffer5_in_ChipMem      ; pointer to chipbuffer 5
        dc.l    Buffer6_in_ChipMem      ; pointer to chipbuffer 6
        dc.l    Buffer7_in_ChipMem      ; pointer to chipbuffer 7
        dc.l    Buffer8_in_ChipMem      ; pointer to chipbuffer 8
ActChipBuffer:                          ; keep this directly after the ChipBuffers
        dc.w    0                       ; number of act buffer (can be 0 or -1)

StreamPosition:
        dc.l    0                       ; position in the stream

StreamBegin:
		dc.l	0
StreamEnd:
		dc.l	0        

chunk	dc.l	0
stuffi	dc.l	0
cdata	dc.w	0
freq	dc.w	0

*-------------------------------------------------------------------------

        section audio,bss_c

Buffer1_in_ChipMem:
        ds.b    5000                    ; chip buffer 1
Buffer2_in_ChipMem:
        ds.b    5000                    ; chip buffer 2 (double buffering!)

Buffer3_in_ChipMem:
        ds.b    5000                    ; chip buffer 3
Buffer4_in_ChipMem:
        ds.b    5000                    ; chip buffer 4 (double buffering!)

Buffer5_in_ChipMem:
        ds.b    5000                    ; chip buffer 3
Buffer6_in_ChipMem:
        ds.b    5000                    ; chip buffer 4 (double buffering!)

Buffer7_in_ChipMem:
        ds.b    5000                    ; chip buffer 3
Buffer8_in_ChipMem:
        ds.b    5000                    ; chip buffer 4 (double buffering!)

*--------------------------------------------------------------------------