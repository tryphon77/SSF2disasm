
selectBgmF0:
	move.b	#$f0, d0	; 0x4cc
	bra.b	selectBgm	; 0x4d0

bgmStop:
	move.b	#$f1, d0	; 0x4d2
	bra.b	selectBgm	; 0x4d6

selectBgmF3:
	move.b	#$f3, d0	; 0x4d8
	bra.b	selectBgm	; 0x4dc

selectBgmF4:
	move.b	#$f4, d0	; 0x4de
	bra.b	selectBgm	; 0x4e2

selectBgmF5:
	move.b	#$f5, d0	; 0x4e4
	bra.b	selectBgm	; 0x4e8

bgmFadeOff:
	move.b	#$f6, d0	; 0x4ea
	move.b	#$c0, d1	; 0x4ee
	bra.b	selectBgm	; 0x4f2

fastenBgm:
	move.b	#$f7, d0	; 0x4f4
	move.b	#$18, d1	; 0x4f8

selectBgm:
	move.w	(posInBgmQueue).w, d2	; 0x4fc
	addq.w	#2, d2	; 0x500
	andi.w	#$000e, d2	; 0x502
	move.w	d2, (posInBgmQueue).w	; 0x506
	lea	(LBL_ffffa5d0).w, a0	; 0x50a
	adda.w	d2, a0	; 0x50e
	move.b	d0, (a0)	; 0x510
	move.b	d1, (1, a0)	; 0x512
	rts		; 0x516

put0000And0100InSfxQueue:
	moveq	#0, d0	; 0x518
	bsr.b	putWordInSfxQueue	; 0x51a
	move.w	#$0100, d0	; 0x51c

putWordInSfxQueue:
	move.w	(posInSfxQueue).w, d1	; 0x520
	addq.w	#2, d1	; 0x524
	andi.w	#$000e, d1	; 0x526
	move.w	d1, (posInSfxQueue).w	; 0x52a
	lea	(sfxQueue).w, a0	; 0x52e
	adda.w	d1, a0	; 0x532
	move.w	d0, (a0)	; 0x534
	rts		; 0x536

putSfxInSfxQueue:
	movem.l	d1/a0, -(a7)	; 0x538
	move.w	(posInSfxQueue).w, d1	; 0x53c
	addq.w	#2, d1	; 0x540
	andi.w	#$000e, d1	; 0x542
	move.w	d1, (posInSfxQueue).w	; 0x546
	lea	(sfxQueue).w, a0	; 0x54a
	adda.w	d1, a0	; 0x54e
	move.b	(23, a6), (a0)+	; 0x550
	move.b	d0, (a0)	; 0x554
	movem.l	(a7)+, a0/d1	; 0x556
	rts		; 0x55a

FUN_0000055c:
	movem.l	d1/a0, -(a7)	; 0x55c
	move.w	(posInSfxQueue).w, d1	; 0x560
	addq.w	#2, d1	; 0x564
	andi.w	#$000e, d1	; 0x566
	move.w	d1, (posInSfxQueue).w	; 0x56a
	lea	(sfxQueue).w, a0	; 0x56e
	adda.w	d1, a0	; 0x572
	move.b	(23, a6), d1	; 0x574
	eori.b	#1, d1	; 0x578
	move.b	d1, (a0)+	; 0x57c
	move.b	d0, (a0)	; 0x57e
@end:
	movem.l	(a7)+, a0/d1	; 0x580
	rts		; 0x584

putInSfxQueue:
	movem.l	d1/a0, -(a7)	; 0x586
	move.w	(posInSfxQueue).w, d1	; 0x58a
	addq.w	#2, d1	; 0x58e
	andi.w	#$000e, d1	; 0x590
	move.w	d1, (posInSfxQueue).w	; 0x594
	lea	(sfxQueue).w, a0	; 0x598
	adda.w	d1, a0	; 0x59c
	move.b	(24, a6), (a0)+	; 0x59e
	move.b	d0, (a0)	; 0x5a2
	movem.l	(a7)+, a0/d1	; 0x5a4
	rts		; 0x5a8