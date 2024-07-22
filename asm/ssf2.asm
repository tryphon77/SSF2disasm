
; Vector Table
	org	$0
ROM_start:
vStack	dc.l	$fffffc00
vReset	dc.l	$3aaa
vBusError	dc.l	$4114
vAddressError	dc.l	$4114
vIllegalInstruction	dc.l	$4114
vDivisionByZero	dc.l	$4114
vChkInstruction	dc.l	$4114
vTrapvInstruction	dc.l	$4114
vPrivilegeViolation	dc.l	$4114
vTrace	dc.l	$4114
vLineA	dc.l	$4114
vLineF	dc.l	$4114
vUnused1	dc.l	$4114
vUnused2	dc.l	$4114
vUnused3	dc.l	$4114
vUninitializedInterrupt	dc.l	$4114
vReserved1	dc.l	$4114
vReserved2	dc.l	$4114
vReserved3	dc.l	$4114
vReserved4	dc.l	$4114
vReserved5	dc.l	$4114
vReserved6	dc.l	$4114
vReserved7	dc.l	$4114
vReserved8	dc.l	$4114
vSpuriousInt	dc.l	$4114
vIrq1Int	dc.l	$4114
vExtInt	dc.l	$4110
vIrq3Int	dc.l	$4114
vHInt	dc.l	$4072
vIrq5Int	dc.l	$4114
vVInt	dc.l	$3eea
vIrq7Int	dc.l	$4114
vTrap00	dc.l	$3e76
vTrap01	dc.l	$3e86
vTrap02	dc.l	$3e9a
vTrap03	dc.l	$3ea6
vTrap04	dc.l	$3ecc
vTrap05	dc.l	$3ede
vTrap06	dc.l	$4114
vTrap07	dc.l	$4114
vTrap08	dc.l	$4114
vTrap09	dc.l	$4114
vTrap10	dc.l	$4114
vTrap11	dc.l	$4114
vTrap12	dc.l	$4114
vTrap13	dc.l	$4114
vTrap14	dc.l	$4114
vTrap15	dc.l	$4114
vFpUnused1	dc.l	$4114
vFpUnused2	dc.l	$4114
vFpUnused3	dc.l	$4114
vFpUnused4	dc.l	$4114
vFpUnused5	dc.l	$4114
vFpUnused6	dc.l	$4114
vFpUnused7	dc.l	$4114
vFpUnused8	dc.l	$4114
vMmuUnused1	dc.l	$4114
vMmuUnused2	dc.l	$4114
vMmuUnused3	dc.l	$4114
vReserved9	dc.l	$4114
vReserved10	dc.l	$4114
vReserved11	dc.l	$4114
vReserved12	dc.l	$4114
vReserved13	dc.l	$4114
	include	"RomHeader.asm" 
	org	$200
bankChecksums:
	dc.l	$b372a6cf
	dc.l	$23d20856
	dc.l	$91b98e66
	dc.l	$92f02c7f
	dc.l	$52ca8889
	dc.l	$a2393c3b
	dc.l	$85c18d66
	dc.l	$3ce23943
	dc.l	$96011ca1
	dc.l	$ce89fa11
	dc.l	$e7def3d6

	org	$22c
	org	$22c
fadeInStart:
	tst.b	(fadingAttenuation).w
	beq.b	@end
	cmpi.b	#$fe, (fadingDelta).w
	beq.b	@end
	move.b	#$fe, (fadingDelta).w
	move.b	#5, (fadingTimer).w
	org	$246
@end:
	rts	
	org	$248
fadeOutStart:
	cmpi.b	#$0e, (fadingAttenuation).w
	beq.b	@end
	cmpi.b	#2, (fadingDelta).w
	beq.b	@end
	move.b	#2, (fadingDelta).w
	move.b	#5, (fadingTimer).w
	org	$264
@end:
	rts	
	org	$266
fadeInStartAndProcess:
	bsr.b	fadeInStart
	bra.b	process
	org	$26a
fadeOutStartAndProcess:
	bsr.b	fadeOutStart
	org	$26c
process:
	move.b	#1, d0
	trap	#3
	tst.b	(fadingDelta).w
	bne.b	process
	rts	
	org	$27a
initDisplay:
	clr.w	(hintFun).w
	clr.b	(flagProcessPalettes).w
	clr.b	(flagProcessVSRAM).w
	clr.b	(flagProcessHScroll).w
	clr.w	(LBL_ffff989e).w
	clr.w	(LBL_ffff98a0).w
	move.w	#$9faa, (ptrCurrentSpriteInSatBuffer).w
	move.w	#$a1aa, (ptrDmaQueueCurrentEntry).w
	move.w	#$a2aa, (ptrLastUpdatableBgArea).w
	bsr.b	setVdpRegs
	move.l	#$40000010, (4, a5)	; VSRAM write to 0000
	moveq	#0, d0
	move.l	d0, (a5)
	move.l	#$50000083, d1	; DMA VRAM write    :
			; 	src=0xFFF800
			; 	dest=D000
			; 	length=280
	move.l	#$942f93ff, d0
	bra.w	doDmaAndWaitCompletion
	org	$2c2
setVdpRegs:
	lea	($2e2, pc), a0
	lea	(VdpRegistersCache).w, a1
	move.w	#$8000, d0
	moveq	#$0012, d7
	org	$2d0
@loop:
	move.b	(a0)+, d0
	move.w	d0, (a1)+
	move.w	d0, (4, a5)
	addi.w	#$0100, d0
	dbf	d7, @loop
	rts	

	org	$2e2
	org	$2e2
VdpRegs2e2:


	org	$2f6
	org	$2f6
updateWindow:
	move.l	#$50000083, d1	; DMA VRAM write    :
			; 	src=0xFF0000
			; 	dest=D000
			; 	length=16
	move.l	#$940793ff, d0
	bra.b	doDmaAndWaitCompletion
	move.l	#$5c000083, d1	; DMA VRAM write    :
			; 	src=0xFF0000
			; 	dest=DC00
			; 	length=16
	move.l	#$940393ff, d0
	bra.b	doDmaAndWaitCompletion
	org	$312
sendSat:
	move.l	#$5a000083, d1	; DMA VRAM write    :
			; 	src=0xFF0000
			; 	dest=DA00
			; 	length=16
	move.l	#$940193ff, d0
	bra.b	doDmaAndWaitCompletion
	org	$320
sendPlaneA:
	move.l	#$60000083, d1	; DMA VRAM write    :
			; 	src=0xFF0000
			; 	dest=E000
			; 	length=16
	move.l	#$940f93ff, d0
	bra.b	doDmaAndWaitCompletion
	org	$32e
sendPlaneB:
	move.l	#$70000083, d1	; DMA VRAM write    :
			; 	src=0xFF0000
			; 	dest=F000
			; 	length=16
	move.l	#$940f93ff, d0
	org	$33a
doDmaAndWaitCompletion:
	moveq	#0, d2
	org	$33c
doDmaAndWaitCompletionAlt:
	lea	(4, a5), a6
	ori.b	#$10, (VdpRegistersCache+3).w
	move.w	(VdpRegistersCache+2).w, (a6)
	move.w	#$8f01, (a6)
	move.l	d0, (a6)
	move.w	#$9780, (a6)
	move.l	d1, (a6)
	move.b	d2, (a5)
	org	$358
@wait:
	move.w	(a6), d5
	andi.w	#2, d5
	bne.b	@wait
	andi.b	#$ef, (VdpRegistersCache+3).w
	move.w	(VdpRegistersCache+2).w, (a6)
	move.w	#$8f02, (a6)
	rts	
	org	$370
transferDataToVramDMA:
	move.b	#7, (currentPageInBank7).w
	move.b	#7, mapperBank7
	move.l	#$93009400, d0
	move.b	(a0)+, d0
	swap	d0
	move.b	(a0)+, d0
	move.l	(a0), a1
	adda.l	a1, a1
	move.b	(a0)+, d2
	move.w	#$9700, d2
	move.b	(a0)+, d2
	move.l	#$95009600, d1
	move.b	(a0)+, d1
	swap	d1
	move.b	(a0)+, d1
	moveq	#0, d3
	move.w	(a0)+, d3
	lsl.l	#2, d3
	lsr.w	#2, d3
	swap	d3
	ori.l	#$40000080, d3
	move.l	d3, -(a7)
	move.l	#$00a11100, a4
	move.w	#0, d6
	move.w	#$0100, d7
	lea	(4, a5), a6
	andi.b	#$df, (VdpRegistersCache+3).w
	move.w	(VdpRegistersCache+2).w, (a6)
	ori.b	#$10, (VdpRegistersCache+3).w
	move.w	(VdpRegistersCache+2).w, (a6)
	move.w	d7, (a4)
	move.l	d0, (a6)
	move.l	d1, (a6)
	move.w	d2, (a6)
	move.w	(a7)+, (a6)
	org	$3e4
@wait:
	btst	d6, (a4)
	bne.b	@wait
	move.w	(a7)+, (a6)
	move.w	d6, (a4)
	andi.b	#$ef, (VdpRegistersCache+3).w
	move.w	(VdpRegistersCache+2).w, (a6)
	eori.w	#$0080, d3
	move.l	d3, (a6)
	move.w	(a1), (a5)
	ori.b	#$20, (VdpRegistersCache+3).w
	move.w	(VdpRegistersCache+2).w, (a6)
	rts	
	move.w	(a0)+, d0
	moveq	#0, d1
	move.b	(a0)+, d1
	moveq	#0, d2
	move.b	(a0)+, d2
	org	$414
next2:
	move.w	d0, (4, a5)
	move.w	#3, (4, a5)
	move.w	d2, d4
	org	$420
next1:
	move.w	(a0)+, (a5)
	dbf	d4, next1
	addi.w	#$0080, d0
	dbf	d1, next2
	rts	
	org	$430
writeTileRect:
	move.w	(a0)+, d0
	moveq	#0, d1
	move.b	(a0)+, d1
	moveq	#0, d2
	move.b	(a0)+, d2
	move.b	(a0)+, d3
	lsl.w	#8, d3
	org	$43e
@next2:
	move.w	d0, (4, a5)
	move.w	#3, (4, a5)
	move.w	d2, d4
	org	$44a
@next1:
	move.b	(a0)+, d3
	move.w	d3, (a5)
	dbf	d4, @next1
	addi.w	#$0080, d0
	dbf	d1, @next2
	rts	
	org	$45c
FUN_0000045c:
	move.w	(a0)+, d0
	moveq	#0, d1
	move.b	(a0)+, d1
	moveq	#0, d2
	move.b	(a0)+, d2
	move.l	(a0)+, a1
	org	$468
@next2:
	move.w	d0, (4, a5)
	move.w	#3, (4, a5)
	move.w	d2, d4
	org	$474
@next1:
	move.w	(a1)+, (a5)
	dbf	d4, @next1
	addi.w	#$0080, d0
	dbf	d1, @next2
	rts	
	org	$484
writeText:
	move.w	(a0)+, d0
	move.b	(a0)+, d1
	lsl.w	#8, d1
	org	$48a
@newline:
	move.w	d0, (4, a5)
	move.w	#3, (4, a5)
	org	$494
@nextchar:
	move.b	(a0)+, d1
	beq.b	@end
	cmpi.b	#$ff, d1
	beq.b	@nextline
	move.w	d1, (a5)
	bra.b	@nextchar
	org	$4a2
@nextline:
	addi.w	#$0080, d0
	bra.b	@newline
	org	$4a8
@end:
	rts	
	org	$4aa
clearSatCache:
	lea	(SAT_cache).w, a0
	moveq	#$007f, d7
	moveq	#0, d0
	org	$4b2
@next:
	move.l	d0, (a0)+
	dbf	d7, @next
	rts	
	org	$4ba
clearHscrollCache:
	lea	(hScrollCacheA).w, a0
	move.w	#$00ff, d7
	moveq	#0, d0
	org	$4c4
@next:
	move.l	d0, (a0)+
	dbf	d7, @next
	rts	
	org	$4cc
selectBgmF0:
	move.b	#$f0, d0
	bra.b	selectBgm
	org	$4d2
bgmStop:
	move.b	#$f1, d0
	bra.b	selectBgm
	org	$4d8
selectBgmF3:
	move.b	#$f3, d0
	bra.b	selectBgm
	org	$4de
selectBgmF4:
	move.b	#$f4, d0
	bra.b	selectBgm
	org	$4e4
selectBgmF5:
	move.b	#$f5, d0
	bra.b	selectBgm
	org	$4ea
bgmFadeOff:
	move.b	#$f6, d0
	move.b	#$c0, d1
	bra.b	selectBgm
	org	$4f4
fastenBgm:
	move.b	#$f7, d0
	move.b	#$18, d1
	org	$4fc
selectBgm:
	move.w	(posInBgmQueue).w, d2
	addq.w	#2, d2
	andi.w	#$000e, d2
	move.w	d2, (posInBgmQueue).w
	lea	(LBL_ffffa5d0).w, a0
	adda.w	d2, a0
	move.b	d0, (a0)
	move.b	d1, (1, a0)
	rts	
	org	$518
put0000And0100InSfxQueue:
	moveq	#0, d0
	bsr.b	putWordInSfxQueue
	move.w	#$0100, d0
	org	$520
putWordInSfxQueue:
	move.w	(posInSfxQueue).w, d1
	addq.w	#2, d1
	andi.w	#$000e, d1
	move.w	d1, (posInSfxQueue).w
	lea	(sfxQueue).w, a0
	adda.w	d1, a0
	move.w	d0, (a0)
	rts	
	org	$538
putSfxInSfxQueue:
	movem.l	d1/a0, -(a7)
	move.w	(posInSfxQueue).w, d1
	addq.w	#2, d1
	andi.w	#$000e, d1
	move.w	d1, (posInSfxQueue).w
	lea	(sfxQueue).w, a0
	adda.w	d1, a0
	move.b	(23, a6), (a0)+
	move.b	d0, (a0)
	movem.l	(a7)+, a0/d1
	rts	
	org	$55c
FUN_0000055c:
	movem.l	d1/a0, -(a7)
	move.w	(posInSfxQueue).w, d1
	addq.w	#2, d1
	andi.w	#$000e, d1
	move.w	d1, (posInSfxQueue).w
	lea	(sfxQueue).w, a0
	adda.w	d1, a0
	move.b	(23, a6), d1
	eori.b	#1, d1
	move.b	d1, (a0)+
	move.b	d0, (a0)
	movem.l	(a7)+, a0/d1
	rts	
	org	$586
putInSfxQueue:
	movem.l	d1/a0, -(a7)
	move.w	(posInSfxQueue).w, d1
	addq.w	#2, d1
	andi.w	#$000e, d1
	move.w	d1, (posInSfxQueue).w
	lea	(sfxQueue).w, a0
	adda.w	d1, a0
	move.b	(24, a6), (a0)+
	move.b	d0, (a0)
	movem.l	(a7)+, a0/d1
	rts	
	org	$5aa
random:
	move.w	(random_value).w, d0
	move.w	d0, d1
	add.w	d0, d0
	add.w	d1, d0
	lsr.w	#8, d0
	add.b	d0, (LBL_fffffce5).w
	move.b	d0, (random_value).w
	move.b	(LBL_fffffce5).w, d0
	rts	
	org	$5c4
setABCStart:
	moveq	#0, d0
	tst.b	(areWeOnTitleScreenOrDemoMode).w
	bne.b	@end
	btst	#0, (flagActivePlayers).w
	beq.b	@noplayer1
	or.w	(joy1Keys).w, d0
	org	$5d8
@noplayer1:
	btst	#1, (flagActivePlayers).w
	beq.b	@noplayer2
	or.w	(joy2Keys).w, d0
	org	$5e4
@noplayer2:
	andi.w	#$0ff0, d0
	lsr.w	#4, d0
	org	$5ea
@end:
	move.b	d0, (joy1And2ABCStart).w
	rts	
	org	$5f0
updateVsScreenTimer:
	move.w	(vsScreenTimer).w, d0
	subq.w	#1, d0
	beq.b	@return0
	tst.b	(joy1And2ABCStart).w
	beq.b	@end
	subq.w	#3, d0
	bge.b	@end
	org	$602
@return0:
	moveq	#0, d0
	org	$604
@end:
	move.w	d0, (vsScreenTimer).w
	rts	
	org	$60a
loadFlatPtrnsAtVpos5000And4000:
	move.w	#$5000, d0
	bsr.b	loadFlatPtrns
	bra.b	loadFlatPtrnsAtVpos4000
	org	$612
loadFlatPtrnsAtVpos6000And4000:
	move.w	#$6000, d0
	bsr.b	loadFlatPtrns
	org	$618
loadFlatPtrnsAtVpos4000:
	move.w	#$4000, d0
	org	$61c
loadFlatPtrns:
	move.w	(ptrDmaQueueCurrentEntry).w, a0
	move.w	#$0100, (a0)+
	move.l	#$001c0280, (a0)+
	move.w	d0, (a0)+
	move.w	a0, (ptrDmaQueueCurrentEntry).w
	rts	
	org	$632
loadFromDataLoader:
	move.w	(a0)+, d0
	move.l	(a0)+, d1
	move.b	(a0)+, d2
	move.b	(a0)+, d3
	org	$63a
loadInDataBuffer:
	lea	dataBuffer, a1
	adda.w	d0, a1
	ext.w	d2
	ext.w	d3
	move.w	(ptrToTilesets, pc, d2.w), a2
	move.w	(tileSizes, pc, d2.w), d2
	org	$64e
@next1:
	moveq	#0, d0
	move.b	(a0)+, d0
	move.b	(0, a2, d0), d0
	lsl.w	#5, d0
	move.l	d1, a3
	adda.l	d0, a3
	move.w	d2, d4
	org	$65e
@next2:
	move.l	(a3)+, (a1)+
	dbf	d4, @next2
	dbf	d3, @next1
	rts	

	org	$66a
	org	$66a
ptrToTilesets:


	org	$7ac
	org	$7ac
loadBicolorPtrns:
	moveq	#0, d3
	moveq	#0, d4
	move.b	(a2)+, d5
	beq.b	@blankptrn
	move.b	d5, d2
	andi.b	#$0f, d2
	beq.b	@blankhalfptrn1
	addq.b	#5, d2
	move.b	d2, d3
	addq.b	#5, d2
	move.b	d2, d4
	org	$7c4
@blankhalfptrn1:
	move.b	d5, d2
	andi.b	#$f0, d2
	beq.b	@blankhalfptrn2
	addi.b	#$50, d2
	add.b	d2, d3
	addi.b	#$50, d2
	add.b	d2, d4
	org	$7d8
@blankhalfptrn2:
	move.b	d3, (a0)+
	move.b	d4, (a1)+
	bra.b	@nextptrn
	org	$7de
@blankptrn:
	clr.b	(a0)+
	clr.b	(a1)+
	org	$7e2
@nextptrn:
	dbf	d0, loadBicolorPtrns
	rts	
	org	$7e8
loadBgAreas:
	lea	(tempTilemapData).w, a1
	move.w	(ptrLastUpdatableBgArea).w, a2
	org	$7f0
loadBGAreas_nextarea:
	moveq	#0, d0
	move.b	(a0)+, d0
	beq.b	loadBgAreas_end
	move.b	(a0)+, d1
	move.b	(a0)+, (a2)+
	move.b	(a0)+, (a2)+
	move.b	#0, (a2)+
	org	$800
loadBgAreasAlt:
	move.b	d0, (a2)+
	move.l	a1, (a2)+
	org	$804
@next:
	move.b	d1, (a1)+
	move.b	(a0)+, (a1)+
	dbf	d0, @next
	bra.b	loadBGAreas_nextarea
	org	$80e
loadBgAreas_end:
	move.w	a2, (ptrLastUpdatableBgArea).w
	rts	
	org	$814
loadPalette:
	lea	(rawPalettes).w, a2
	moveq	#0, d0
	move.l	d0, d1
	move.b	(a0)+, d0
	beq.b	@end
	addq.w	#1, d0
	lsl.w	#2, d0
	move.b	(a0)+, d1
	adda.l	d1, a2
	move.l	(a0)+, a1
	bsr.w	getFarAddress
	move.b	d2, (currentPageInBank7).w
	move.b	d2, mapperBank7
	lsr.w	#2, d0
	subq.w	#1, d0
	org	$83c
@next1:
	move.l	(a1)+, (a2)+
	dbf	d0, @next1
	tst.b	d3
	beq.b	loadPalette
	move.b	d3, (currentPageInBank7).w
	move.b	d3, mapperBank7
	lsr.w	#2, d1
	subq.w	#1, d1
	org	$854
@next2:
	move.l	(a3)+, (a2)+
	dbf	d1, @next2
	bra.b	loadPalette
	org	$85c
@end:
	move.b	#7, (currentPageInBank7).w
	move.b	#7, mapperBank7
	st	(flagProcessPalettes).w
	rts	
	org	$870
transferDataFromPageToRam:
	moveq	#0, d0
	move.w	(a0)+, d0
	beq.b	@end
	move.l	(a0)+, a1
	move.w	(a0)+, a2
	move.w	d0, (transfer_queue_).w
	lsr	(transfer_queue_).w
	move.l	#$007f8000, (LBL_ffffba52).w
	move.w	a2, (LBL_ffffba56).w
	bsr.w	getFarAddress
	move.b	d2, (currentPageInBank7).w
	move.b	d2, mapperBank7
	lea	dataBuffer, a2
	lsr.w	#2, d0
	subq.w	#1, d0
	org	$8a6
@next1:
	move.l	(a1)+, (a2)+
	dbf	d0, @next1
	tst.b	d3
	beq.b	@skip
	move.b	d3, (currentPageInBank7).w
	move.b	d3, mapperBank7
	lsr.w	#2, d1
	subq.w	#1, d1
	org	$8be
@next2:
	move.l	(a3)+, (a2)+
	dbf	d1, @next2
	org	$8c4
@skip:
	move.l	a0, -(a7)
	lea	(transfer_queue_).w, a0
	jsr	(transferDataToVramDMA).w
	move.l	(a7)+, a0
	move.b	#7, (currentPageInBank7).w
	move.b	#7, mapperBank7
	bra.b	transferDataFromPageToRam
	org	$8e0
@end:
	rts	
	lea	dataBuffer, a2
	lsr.w	#2, d0
	subq.w	#1, d0
	org	$8ec
@loc_000008EC:
	move.l	(a1)+, (a2)+
	dbf	d0, @loc_000008EC
	rts	
	org	$8f4
getFarAddress:
	move.b	#7, d2
	move.l	a1, d1
	swap	d1
	subi.b	#$38, d1
	bmi.b	@return0
	lsr.w	#3, d1
	move.b	d1, d2
	addi.b	#7, d2
	move.l	a1, d6
	ori.l	#$00080000, d6
	andi.l	#$000fffff, d6
	add.l	d0, d6
	subi.l	#$00100000, d6
	bmi.b	@end
	beq.b	@end
	move.w	d6, d1
	neg.w	d6
	add.w	d6, d0
	move.w	d0, d6
	move.l	a1, d6
	andi.l	#$003fffff, d6
	ori.l	#$00380000, d6
	move.l	d6, a1
	move.b	d2, d3
	move.l	#$00380000, a3
	addq.b	#1, d3
	rts	
	org	$948
@return0:
	moveq	#0, d3
	rts	
	org	$94c
@end:
	move.l	a1, d6
	andi.l	#$003fffff, d6
	ori.l	#$00380000, d6
	move.l	d6, a1
	moveq	#0, d3
	rts	
	org	$960
FUN_00000960:
	clr.b	(1, a6)
	move.w	(6, a6), d0
	addi.w	#$0010, d0
	sub.w	(cameraX).w, d0
	cmpi.w	#$0120, d0
	bcc.b	@end
	addq.b	#1, (1, a6)
	org	$97a
@end:
	rts	
	org	$97c
checkObjectVisibility:
	move.w	(6, a6), d0
	sub.w	(cameraX).w, d0
	addi.w	#$0020, d0
	cmpi.w	#$0140, d0
	bcc.b	@notvisible
	move.w	(10, a6), d0
	sub.w	(cameraY).w, d0
	addi.w	#$0010, d0
	cmpi.w	#$0100, d0
	bcs.b	@visible
	org	$9a0
@notvisible:
	clr.b	(1, a6)
	rts	
	org	$9a6
@visible:
	move.b	#1, (1, a6)
	org	$9ac
checkObjectVisibilityAlt:
	lea	(objectTimers).w, a0
	moveq	#0, d0
	move.b	(23, a6), d0
	addq.w	#1, (0, a0, d0)
	cmpi.w	#$0020, (0, a0, d0)
	bcs.b	@process
	rts	
	org	$9c4
@process:
	move.w	(@JT_000009cc, pc, d0.w), d0
	jmp	(@JT_000009cc, pc, d0.w)

	org	$9cc
	org	$9cc
@JT_000009cc:


	org	$9d6
	org	$9d6
@WORD_000009cc_fun00:
	move.w	(ptrToListOfPtrsToObjects1).w, a0
	move.w	a6, (a0)+
	move.w	a0, (ptrToListOfPtrsToObjects1).w
	rts	
	org	$9e2
@WORD_000009cc_fun01:
	move.w	(ptrToListOfPtrsToObjects2).w, a0
	move.w	a6, (a0)+
	move.w	a0, (ptrToListOfPtrsToObjects2).w
	rts	
	org	$9ee
@WORD_000009cc_fun02:
	move.w	(ptrToListOfPtrsToObjects3).w, a0
	move.w	a6, (a0)+
	move.w	a0, (ptrToListOfPtrsToObjects3).w
	rts	
	org	$9fa
@WORD_000009cc_fun03:
	move.w	(ptrToListOfPtrsToObjects4).w, a0
	move.w	a6, (a0)+
	move.w	a0, (ptrToListOfPtrsToObjects4).w
	rts	
	org	$a06
@WORD_000009cc_fun04:
	move.w	(ptrToListOfPtrsToObjects5).w, a0
	move.w	a6, (a0)+
	move.w	a0, (ptrToListOfPtrsToObjects5).w

tileSizes	equ	$670	;  used
rawPalettes	equ	$ffff9a0a	;  used
VdpRegistersCache	equ	$fffffc00	;  used
mapperBank7	equ	$a130ff	;  used
dataBuffer	equ	$ff0000	;  used
cameraX	equ	$ffff9796	;  used
cameraY	equ	$ffff979a	;  used
vsScreenTimer	equ	$ffff97c4	;  used
flagActivePlayers	equ	$ffff97e7	;  used
joy1And2ABCStart	equ	$ffff97e8	;  used
areWeOnTitleScreenOrDemoMode	equ	$ffff993a	;  used
hScrollCacheA	equ	$ffff9baa	;  used
SAT_cache	equ	$ffff9faa	;  used
joy1Keys	equ	$ffffa46c	;  used
joy2Keys	equ	$ffffa472	;  used
ptrToListOfPtrsToObjects1	equ	$ffffa476	;  used
ptrToListOfPtrsToObjects2	equ	$ffffa478	;  used
ptrToListOfPtrsToObjects3	equ	$ffffa47a	;  used
ptrToListOfPtrsToObjects4	equ	$ffffa47c	;  used
ptrToListOfPtrsToObjects5	equ	$ffffa47e	;  used
objectTimers	equ	$ffffa482	;  used
posInBgmQueue	equ	$ffffa5e2	;  used
sfxQueue	equ	$ffffa5e4	;  used
posInSfxQueue	equ	$ffffa5f6	;  used
ptrCurrentSpriteInSatBuffer	equ	$ffffa5fe	;  used
ptrDmaQueueCurrentEntry	equ	$ffffa600	;  used
ptrLastUpdatableBgArea	equ	$ffffa602	;  used
fadingDelta	equ	$ffffa60a	;  used
fadingTimer	equ	$ffffa60b	;  used
fadingAttenuation	equ	$ffffa60c	;  used
flagProcessPalettes	equ	$ffffa60d	;  used
flagProcessVSRAM	equ	$ffffa60e	;  used
flagProcessHScroll	equ	$ffffa60f	;  used
hintFun	equ	$ffffa614	;  used
transfer_queue_	equ	$ffffba50	;  used
tempTilemapData	equ	$ffffba58	;  used
currentPageInBank7	equ	$fffffc37	;  used
random_value	equ	$fffffce4	;  used
LBL_ffff989e	equ	$ffff989e	;  used
LBL_ffff98a0	equ	$ffff98a0	;  used
LBL_ffffa5d0	equ	$ffffa5d0	;  used
LBL_fffffce5	equ	$fffffce5	;  used
LBL_ffffba52	equ	$ffffba52	;  used
LBL_ffffba56	equ	$ffffba56	;  used