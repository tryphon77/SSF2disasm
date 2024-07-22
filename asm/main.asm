	include	"MoreSymbols.asm"	; 0x-1
	include	"VectorTable.asm"	; 0x-1
	include	"RomHeader.asm"	; 0x-1

bankChecksums:
	dc.l	$b372a6cf	; 0x200
	dc.l	$23d20856	; 0x204
	dc.l	$91b98e66	; 0x208
	dc.l	$92f02c7f	; 0x20c
	dc.l	$52ca8889	; 0x210
	dc.l	$a2393c3b	; 0x214
	dc.l	$85c18d66	; 0x218
	dc.l	$3ce23943	; 0x21c
	dc.l	$96011ca1	; 0x220
	dc.l	$ce89fa11	; 0x224
	dc.l	$e7def3d6	; 0x228
	include	"FadeFunctions.asm"	; 0x-1

initDisplay:
	clr.w	(hintFun).w	; 0x27a
	clr.b	(flagProcessPalettes).w	; 0x27e
	clr.b	(flagProcessVSRAM).w	; 0x282
	clr.b	(flagProcessHScroll).w	; 0x286
	clr.w	(LBL_ffff989e).w	; 0x28a
	clr.w	(LBL_ffff98a0).w	; 0x28e
	move.w	#$9faa, (ptrCurrentSpriteInSatBuffer).w	; 0x292
	move.w	#$a1aa, (ptrDmaQueueCurrentEntry).w	; 0x298
	move.w	#$a2aa, (ptrLastUpdatableBgArea).w	; 0x29e
	bsr.b	setVdpRegs	; 0x2a4
	move.l	#$40000010, (4, a5)	; VSRAM write to 0000	; 0x2a6
	moveq	#0, d0	; 0x2ae
	move.l	d0, (a5)	; 0x2b0
	move.l	#$50000083, d1	; DMA VRAM write    :
			; 	src=0xFFF800
			; 	dest=D000
			; 	length=280	; 0x2b2
	move.l	#$942f93ff, d0	; 0x2b8
	bra.w	doDmaAndWaitCompletion	; 0x2be

setVdpRegs:
	lea	($2e2, pc), a0	; 0x2c2
	lea	(VdpRegistersCache).w, a1	; 0x2c6
	move.w	#$8000, d0	; 0x2ca
	moveq	#$0012, d7	; 0x2ce
@loop:
	move.b	(a0)+, d0	; 0x2d0
	move.w	d0, (a1)+	; 0x2d2
	move.w	d0, (4, a5)	; 0x2d4
	addi.w	#$0100, d0	; 0x2d8
	dbf	d7, @loop	; 0x2dc
	rts		; 0x2e0

VdpRegs2e2:
	dc.b	$04, $24, $38, $34, $07, $6d, $00, $00, $00, $00, $ff, $00, $00, $37, $00, $02, $11, $00, $00, $00	; 0x2e2

updateWindow:
	move.l	#$50000083, d1	; DMA VRAM write    :
			; 	src=0xFF0000
			; 	dest=D000
			; 	length=16	; 0x2f6
	move.l	#$940793ff, d0	; 0x2fc
	bra.b	doDmaAndWaitCompletion	; 0x302
	move.l	#$5c000083, d1	; DMA VRAM write    :
			; 	src=0xFF0000
			; 	dest=DC00
			; 	length=16	; 0x304
	move.l	#$940393ff, d0	; 0x30a
	bra.b	doDmaAndWaitCompletion	; 0x310

sendSat:
	move.l	#$5a000083, d1	; DMA VRAM write    :
			; 	src=0xFF0000
			; 	dest=DA00
			; 	length=16	; 0x312
	move.l	#$940193ff, d0	; 0x318
	bra.b	doDmaAndWaitCompletion	; 0x31e

sendPlaneA:
	move.l	#$60000083, d1	; DMA VRAM write    :
			; 	src=0xFF0000
			; 	dest=E000
			; 	length=16	; 0x320
	move.l	#$940f93ff, d0	; 0x326
	bra.b	doDmaAndWaitCompletion	; 0x32c

sendPlaneB:
	move.l	#$70000083, d1	; DMA VRAM write    :
			; 	src=0xFF0000
			; 	dest=F000
			; 	length=16	; 0x32e
	move.l	#$940f93ff, d0	; 0x334

doDmaAndWaitCompletion:
	moveq	#0, d2	; 0x33a

doDmaAndWaitCompletionAlt:
	lea	(4, a5), a6	; 0x33c
	ori.b	#$10, (VdpRegistersCache).w	; 0x340
	move.w	(VdpRegistersCache).w, (a6)	; 0x346
	move.w	#$8f01, (a6)	; 0x34a
	move.l	d0, (a6)	; 0x34e
	move.w	#$9780, (a6)	; 0x350
	move.l	d1, (a6)	; 0x354
	move.b	d2, (a5)	; 0x356
@wait:
	move.w	(a6), d5	; 0x358
	andi.w	#2, d5	; 0x35a
	bne.b	@wait	; 0x35e
	andi.b	#$ef, (VdpRegistersCache).w	; 0x360
	move.w	(VdpRegistersCache).w, (a6)	; 0x366
	move.w	#$8f02, (a6)	; 0x36a
	rts		; 0x36e

transferDataToVramDMA:
	move.b	#7, (currentPageInBank7).w	; 0x370
	move.b	#7, mapperBank7	; 0x376
	move.l	#$93009400, d0	; 0x37e
	move.b	(a0)+, d0	; 0x384
	swap	d0	; 0x386
	move.b	(a0)+, d0	; 0x388
	move.l	(a0), a1	; 0x38a
	adda.l	a1, a1	; 0x38c
	move.b	(a0)+, d2	; 0x38e
	move.w	#$9700, d2	; 0x390
	move.b	(a0)+, d2	; 0x394
	move.l	#$95009600, d1	; 0x396
	move.b	(a0)+, d1	; 0x39c
	swap	d1	; 0x39e
	move.b	(a0)+, d1	; 0x3a0
	moveq	#0, d3	; 0x3a2
	move.w	(a0)+, d3	; 0x3a4
	lsl.l	#2, d3	; 0x3a6
	lsr.w	#2, d3	; 0x3a8
	swap	d3	; 0x3aa
	ori.l	#$40000080, d3	; 0x3ac
	move.l	d3, -(a7)	; 0x3b2
	move.l	#$00a11100, a4	; 0x3b4
	move.w	#0, d6	; 0x3ba
	move.w	#$0100, d7	; 0x3be
	lea	(4, a5), a6	; 0x3c2
	andi.b	#$df, (VdpRegistersCache).w	; 0x3c6
	move.w	(VdpRegistersCache).w, (a6)	; 0x3cc
	ori.b	#$10, (VdpRegistersCache).w	; 0x3d0
	move.w	(VdpRegistersCache).w, (a6)	; 0x3d6
	move.w	d7, (a4)	; 0x3da
	move.l	d0, (a6)	; 0x3dc
	move.l	d1, (a6)	; 0x3de
	move.w	d2, (a6)	; 0x3e0
	move.w	(a7)+, (a6)	; 0x3e2
@wait:
	btst	d6, (a4)	; 0x3e4
	bne.b	@wait	; 0x3e6
	move.w	(a7)+, (a6)	; 0x3e8
	move.w	d6, (a4)	; 0x3ea
	andi.b	#$ef, (VdpRegistersCache).w	; 0x3ec
	move.w	(VdpRegistersCache).w, (a6)	; 0x3f2
	eori.w	#$0080, d3	; 0x3f6
	move.l	d3, (a6)	; 0x3fa
	move.w	(a1), (a5)	; 0x3fc
	ori.b	#$20, (VdpRegistersCache).w	; 0x3fe
	move.w	(VdpRegistersCache).w, (a6)	; 0x404
	rts		; 0x408
	move.w	(a0)+, d0	; 0x40a
	moveq	#0, d1	; 0x40c
	move.b	(a0)+, d1	; 0x40e
	moveq	#0, d2	; 0x410
	move.b	(a0)+, d2	; 0x412

next2:
	move.w	d0, (4, a5)	; 0x414
	move.w	#3, (4, a5)	; 0x418
	move.w	d2, d4	; 0x41e

next1:
	move.w	(a0)+, (a5)	; 0x420
	dbf	d4, next1	; 0x422
	addi.w	#$0080, d0	; 0x426
	dbf	d1, next2	; 0x42a
	rts		; 0x42e

writeTileRect:
	move.w	(a0)+, d0	; 0x430
	moveq	#0, d1	; 0x432
	move.b	(a0)+, d1	; 0x434
	moveq	#0, d2	; 0x436
	move.b	(a0)+, d2	; 0x438
	move.b	(a0)+, d3	; 0x43a
	lsl.w	#8, d3	; 0x43c
@next2:
	move.w	d0, (4, a5)	; 0x43e
	move.w	#3, (4, a5)	; 0x442
	move.w	d2, d4	; 0x448
@next1:
	move.b	(a0)+, d3	; 0x44a
	move.w	d3, (a5)	; 0x44c
	dbf	d4, @next1	; 0x44e
	addi.w	#$0080, d0	; 0x452
	dbf	d1, @next2	; 0x456
	rts		; 0x45a

FUN_0000045c:
	move.w	(a0)+, d0	; 0x45c
	moveq	#0, d1	; 0x45e
	move.b	(a0)+, d1	; 0x460
	moveq	#0, d2	; 0x462
	move.b	(a0)+, d2	; 0x464
	move.l	(a0)+, a1	; 0x466
@next2:
	move.w	d0, (4, a5)	; 0x468
	move.w	#3, (4, a5)	; 0x46c
	move.w	d2, d4	; 0x472
@next1:
	move.w	(a1)+, (a5)	; 0x474
	dbf	d4, @next1	; 0x476
	addi.w	#$0080, d0	; 0x47a
	dbf	d1, @next2	; 0x47e
	rts		; 0x482

writeText:
	move.w	(a0)+, d0	; 0x484
	move.b	(a0)+, d1	; 0x486
	lsl.w	#8, d1	; 0x488
@newline:
	move.w	d0, (4, a5)	; 0x48a
	move.w	#3, (4, a5)	; 0x48e
@nextchar:
	move.b	(a0)+, d1	; 0x494
	beq.b	@end	; 0x496
	cmpi.b	#$ff, d1	; 0x498
	beq.b	@nextline	; 0x49c
	move.w	d1, (a5)	; 0x49e
	bra.b	@nextchar	; 0x4a0
@nextline:
	addi.w	#$0080, d0	; 0x4a2
	bra.b	@newline	; 0x4a6
@end:
	rts		; 0x4a8

clearSatCache:
	lea	(SAT_cache).w, a0	; 0x4aa
	moveq	#$007f, d7	; 0x4ae
	moveq	#0, d0	; 0x4b0
@next:
	move.l	d0, (a0)+	; 0x4b2
	dbf	d7, @next	; 0x4b4
	rts		; 0x4b8

clearHscrollCache:
	lea	(hScrollCacheA).w, a0	; 0x4ba
	move.w	#$00ff, d7	; 0x4be
	moveq	#0, d0	; 0x4c2
@next:
	move.l	d0, (a0)+	; 0x4c4
	dbf	d7, @next	; 0x4c6
	rts		; 0x4ca
	include	"Sound.asm"	; 0x-1

random:
	move.w	(random_value).w, d0	; 0x5aa
	move.w	d0, d1	; 0x5ae
	add.w	d0, d0	; 0x5b0
	add.w	d1, d0	; 0x5b2
	lsr.w	#8, d0	; 0x5b4
	add.b	d0, (random_value).w	; 0x5b6
	move.b	d0, (random_value).w	; 0x5ba
	move.b	(random_value).w, d0	; 0x5be
	rts		; 0x5c2

setABCStart:
	moveq	#0, d0	; 0x5c4
	tst.b	(areWeOnTitleScreenOrDemoMode).w	; 0x5c6
	bne.b	@end	; 0x5ca
	btst	#0, (flagActivePlayers).w	; 0x5cc
	beq.b	@noplayer1	; 0x5d2
	or.w	(joy1State).w, d0	; 0x5d4
@noplayer1:
	btst	#1, (flagActivePlayers).w	; 0x5d8
	beq.b	@noplayer2	; 0x5de
	or.w	(joy2State).w, d0	; 0x5e0
@noplayer2:
	andi.w	#$0ff0, d0	; 0x5e4
	lsr.w	#4, d0	; 0x5e8
@end:
	move.b	d0, (joy1And2ABCStart).w	; 0x5ea
	rts		; 0x5ee

updateVsScreenTimer:
	move.w	(shakingMainTimer).w, d0	; 0x5f0
	subq.w	#1, d0	; 0x5f4
	beq.b	@return0	; 0x5f6
	tst.b	(joy1And2ABCStart).w	; 0x5f8
	beq.b	@end	; 0x5fc
	subq.w	#3, d0	; 0x5fe
	bge.b	@end	; 0x600
@return0:
	moveq	#0, d0	; 0x602
@end:
	move.w	d0, (shakingMainTimer).w	; 0x604
	rts		; 0x608

loadFlatPtrnsAtVpos5000And4000:
	move.w	#$5000, d0	; 0x60a
	bsr.b	loadFlatPtrns	; 0x60e
	bra.b	loadFlatPtrnsAtVpos4000	; 0x610

loadFlatPtrnsAtVpos6000And4000:
	move.w	#$6000, d0	; 0x612
	bsr.b	loadFlatPtrns	; 0x616

loadFlatPtrnsAtVpos4000:
	move.w	#$4000, d0	; 0x618

loadFlatPtrns:
	move.w	(ptrDmaQueueCurrentEntry).w, a0	; 0x61c
	move.w	#$0100, (a0)+	; 0x620
	move.l	#$001c0280, (a0)+	; 0x624
	move.w	d0, (a0)+	; 0x62a
	move.w	a0, (ptrDmaQueueCurrentEntry).w	; 0x62c
	rts		; 0x630

loadFromDataLoader:
	move.w	(a0)+, d0	; 0x632
	move.l	(a0)+, d1	; 0x634
	move.b	(a0)+, d2	; 0x636
	move.b	(a0)+, d3	; 0x638

loadInDataBuffer:
	lea	dataBuffer, a1	; 0x63a
	adda.w	d0, a1	; 0x640
	ext.w	d2	; 0x642
	ext.w	d3	; 0x644
	move.w	(ptrToTilesets, pc, d2.w), a2	; 0x646
	move.w	(tileSizes, pc, d2.w), d2	; 0x64a
@next1:
	moveq	#0, d0	; 0x64e
	move.b	(a0)+, d0	; 0x650
	move.b	(0, a2, d0), d0	; 0x652
	lsl.w	#5, d0	; 0x656
	move.l	d1, a3	; 0x658
	adda.l	d0, a3	; 0x65a
	move.w	d2, d4	; 0x65c
@next2:
	move.l	(a3)+, (a1)+	; 0x65e
	dbf	d4, @next2	; 0x660
	dbf	d3, @next1	; 0x664
	rts		; 0x668

ptrToTilesets:
	dc.w	$0676, $06d4, $0750	; 0x66a

tileSizes:
	dc.w	$0007, $000f, $000f	; 0x670

tileset01Data:
	dc.b	$00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $1d, $1e, $1f, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2a, $2b, $2c, $2d, $2e, $2f, $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3a, $3b, $3c, $3d, $3e, $3f, $40, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4a, $4b, $4c, $4d, $4e, $4f, $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5a, $18, $18, $00	; 0x676

tileset02Data:
	dc.b	$00, $02, $04, $06, $08, $0a, $0c, $0e, $10, $12, $22, $24, $26, $28, $2a, $2c, $00, $02, $04, $06, $08, $0a, $0c, $0e, $10, $12, $56, $58, $5a, $5c, $5e, $60, $18, $14, $8c, $8a, $18, $18, $18, $1d, $18, $18, $18, $18, $1e, $20, $1b, $18, $00, $02, $04, $06, $08, $0a, $0c, $0e, $10, $12, $8e, $90, $18, $18, $18, $16, $18, $22, $24, $26, $28, $2a, $2c, $2e, $30, $32, $34, $36, $38, $3a, $3c, $3e, $40, $42, $44, $46, $48, $4a, $4c, $4e, $50, $52, $54, $18, $18, $18, $18, $18, $18, $56, $58, $5a, $5c, $5e, $60, $62, $64, $66, $68, $6a, $6c, $6e, $70, $72, $74, $76, $78, $7a, $7c, $7e, $80, $82, $84, $86, $88, $8a	; 0x6d4

tileset03Data:
	dc.b	$00, $02, $04, $06, $08, $0a, $0c, $0e, $10, $12, $22, $24, $26, $28, $2a, $2c, $00, $02, $04, $06, $08, $0a, $0c, $0e, $10, $12, $00, $00, $00, $00, $00, $00, $54, $14, $1e, $16, $54, $54, $54, $1b, $54, $54, $54, $54, $1a, $56, $1c, $54, $00, $02, $04, $06, $08, $0a, $0c, $0e, $10, $12, $54, $54, $54, $54, $54, $18, $54, $20, $22, $24, $26, $28, $2a, $2c, $2e, $30, $32, $34, $36, $38, $3a, $3c, $3e, $40, $42, $44, $46, $48, $4a, $4c, $4e, $50, $52, $00	; 0x750

loadBicolorPtrns:
	moveq	#0, d3	; 0x7ac
	moveq	#0, d4	; 0x7ae
	move.b	(a2)+, d5	; 0x7b0
	beq.b	@blankptrn	; 0x7b2
	move.b	d5, d2	; 0x7b4
	andi.b	#$0f, d2	; 0x7b6
	beq.b	@blankhalfptrn1	; 0x7ba
	addq.b	#5, d2	; 0x7bc
	move.b	d2, d3	; 0x7be
	addq.b	#5, d2	; 0x7c0
	move.b	d2, d4	; 0x7c2
@blankhalfptrn1:
	move.b	d5, d2	; 0x7c4
	andi.b	#$f0, d2	; 0x7c6
	beq.b	@blankhalfptrn2	; 0x7ca
	addi.b	#$50, d2	; 0x7cc
	add.b	d2, d3	; 0x7d0
	addi.b	#$50, d2	; 0x7d2
	add.b	d2, d4	; 0x7d6
@blankhalfptrn2:
	move.b	d3, (a0)+	; 0x7d8
	move.b	d4, (a1)+	; 0x7da
	bra.b	@nextptrn	; 0x7dc
@blankptrn:
	clr.b	(a0)+	; 0x7de
	clr.b	(a1)+	; 0x7e0
@nextptrn:
	dbf	d0, loadBicolorPtrns	; 0x7e2
	rts		; 0x7e6

loadBgAreas:
	lea	(tempTilemapData).w, a1	; 0x7e8
	move.w	(ptrLastUpdatableBgArea).w, a2	; 0x7ec

loadBgAreas_nextarea:
	moveq	#0, d0	; 0x7f0
	move.b	(a0)+, d0	; 0x7f2
	beq.b	loadBgAreas_end	; 0x7f4
	move.b	(a0)+, d1	; 0x7f6
	move.b	(a0)+, (a2)+	; 0x7f8
	move.b	(a0)+, (a2)+	; 0x7fa
	move.b	#0, (a2)+	; 0x7fc

loadBgAreasAlt:
	move.b	d0, (a2)+	; 0x800
	move.l	a1, (a2)+	; 0x802
@next:
	move.b	d1, (a1)+	; 0x804
	move.b	(a0)+, (a1)+	; 0x806
	dbf	d0, @next	; 0x808
	bra.b	loadBgAreas_nextarea	; 0x80c

loadBgAreas_end:
	move.w	a2, (ptrLastUpdatableBgArea).w	; 0x80e
	rts		; 0x812

loadPalette:
	lea	(rawPalettes).w, a2	; 0x814
	moveq	#0, d0	; 0x818
	move.l	d0, d1	; 0x81a
	move.b	(a0)+, d0	; 0x81c
	beq.b	@end	; 0x81e
	addq.w	#1, d0	; 0x820
	lsl.w	#2, d0	; 0x822
	move.b	(a0)+, d1	; 0x824
	adda.l	d1, a2	; 0x826
	move.l	(a0)+, a1	; 0x828
	bsr.w	getFarAddress	; 0x82a
	move.b	d2, (currentPageInBank7).w	; 0x82e
	move.b	d2, mapperBank7	; 0x832
	lsr.w	#2, d0	; 0x838
	subq.w	#1, d0	; 0x83a
@next1:
	move.l	(a1)+, (a2)+	; 0x83c
	dbf	d0, @next1	; 0x83e
	tst.b	d3	; 0x842
	beq.b	loadPalette	; 0x844
	move.b	d3, (currentPageInBank7).w	; 0x846
	move.b	d3, mapperBank7	; 0x84a
	lsr.w	#2, d1	; 0x850
	subq.w	#1, d1	; 0x852
@next2:
	move.l	(a3)+, (a2)+	; 0x854
	dbf	d1, @next2	; 0x856
	bra.b	loadPalette	; 0x85a
@end:
	move.b	#7, (currentPageInBank7).w	; 0x85c
	move.b	#7, mapperBank7	; 0x862
	st	(flagProcessPalettes).w	; 0x86a
	rts		; 0x86e

transferDataFromPageToRam:
	moveq	#0, d0	; 0x870
	move.w	(a0)+, d0	; 0x872
	beq.b	@end	; 0x874
	move.l	(a0)+, a1	; 0x876
	move.w	(a0)+, a2	; 0x878
	move.w	d0, (transfer_queue_).w	; 0x87a
	lsr	(transfer_queue_).w	; 0x87e
	move.l	#$007f8000, (LBL_ffffba52).w	; 0x882
	move.w	a2, (LBL_ffffba56).w	; 0x88a
	bsr.w	getFarAddress	; 0x88e
	move.b	d2, (currentPageInBank7).w	; 0x892
	move.b	d2, mapperBank7	; 0x896
	lea	dataBuffer, a2	; 0x89c
	lsr.w	#2, d0	; 0x8a2
	subq.w	#1, d0	; 0x8a4
@next1:
	move.l	(a1)+, (a2)+	; 0x8a6
	dbf	d0, @next1	; 0x8a8
	tst.b	d3	; 0x8ac
	beq.b	@skip	; 0x8ae
	move.b	d3, (currentPageInBank7).w	; 0x8b0
	move.b	d3, mapperBank7	; 0x8b4
	lsr.w	#2, d1	; 0x8ba
	subq.w	#1, d1	; 0x8bc
@next2:
	move.l	(a3)+, (a2)+	; 0x8be
	dbf	d1, @next2	; 0x8c0
@skip:
	move.l	a0, -(a7)	; 0x8c4
	lea	(transfer_queue_).w, a0	; 0x8c6
	jsr	(transferDataToVramDMA).w	; 0x8ca
	move.l	(a7)+, a0	; 0x8ce
	move.b	#7, (currentPageInBank7).w	; 0x8d0
	move.b	#7, mapperBank7	; 0x8d6
	bra.b	transferDataFromPageToRam	; 0x8de
@end:
	rts		; 0x8e0
	lea	dataBuffer, a2	; 0x8e2
	lsr.w	#2, d0	; 0x8e8
	subq.w	#1, d0	; 0x8ea

next:
	move.l	(a1)+, (a2)+	; 0x8ec
	dbf	d0, next	; 0x8ee
	rts		; 0x8f2

getFarAddress:
	move.b	#7, d2	; 0x8f4
	move.l	a1, d1	; 0x8f8
	swap	d1	; 0x8fa
	subi.b	#$38, d1	; 0x8fc
	bmi.b	@return0	; 0x900
	lsr.w	#3, d1	; 0x902
	move.b	d1, d2	; 0x904
	addi.b	#7, d2	; 0x906
	move.l	a1, d6	; 0x90a
	ori.l	#$00080000, d6	; 0x90c
	andi.l	#$000fffff, d6	; 0x912
	add.l	d0, d6	; 0x918
	subi.l	#$00100000, d6	; 0x91a
	bmi.b	@end	; 0x920
	beq.b	@end	; 0x922
	move.w	d6, d1	; 0x924
	neg.w	d6	; 0x926
	add.w	d6, d0	; 0x928
	move.w	d0, d6	; 0x92a
	move.l	a1, d6	; 0x92c
	andi.l	#$003fffff, d6	; 0x92e
	ori.l	#$00380000, d6	; 0x934
	move.l	d6, a1	; 0x93a
	move.b	d2, d3	; 0x93c
	move.l	#$00380000, a3	; 0x93e
	addq.b	#1, d3	; 0x944
	rts		; 0x946
@return0:
	moveq	#0, d3	; 0x948
	rts		; 0x94a
@end:
	move.l	a1, d6	; 0x94c
	andi.l	#$003fffff, d6	; 0x94e
	ori.l	#$00380000, d6	; 0x954
	move.l	d6, a1	; 0x95a
	moveq	#0, d3	; 0x95c
	rts		; 0x95e

FUN_00000960:
	clr.b	(1, a6)	; 0x960
	move.w	(6, a6), d0	; 0x964
	addi.w	#$0010, d0	; 0x968
	sub.w	(cameraX).w, d0	; 0x96c
	cmpi.w	#$0120, d0	; 0x970
	bcc.b	@end	; 0x974
	addq.b	#1, (1, a6)	; 0x976
@end:
	rts		; 0x97a

checkObjectVisibility:
	move.w	(6, a6), d0	; 0x97c
	sub.w	(cameraX).w, d0	; 0x980
	addi.w	#$0020, d0	; 0x984
	cmpi.w	#$0140, d0	; 0x988
	bcc.b	@notvisible	; 0x98c
	move.w	(10, a6), d0	; 0x98e
	sub.w	(cameraY).w, d0	; 0x992
	addi.w	#$0010, d0	; 0x996
	cmpi.w	#$0100, d0	; 0x99a
	bcs.b	@visible	; 0x99e
@notvisible:
	clr.b	(1, a6)	; 0x9a0
	rts		; 0x9a4
@visible:
	move.b	#1, (1, a6)	; 0x9a6

checkObjectVisibilityAlt:
	lea	(objectTimers).w, a0	; 0x9ac
	moveq	#0, d0	; 0x9b0
	move.b	(23, a6), d0	; 0x9b2
	addq.w	#1, (0, a0, d0)	; 0x9b6
	cmpi.w	#$0020, (0, a0, d0)	; 0x9ba
	bcs.b	@process	; 0x9c0
	rts		; 0x9c2
@process:
	move.w	(@objectDepthFunctions, pc, d0.w), d0	; 0x9c4
	jmp	(@objectDepthFunctions, pc, d0.w)	; 0x9c8
@objectDepthFunctions:
	dc.w	@objectDepth00-@objectDepthFunctions	; 0x9cc
	dc.w	@objectDepth01-@objectDepthFunctions	; 0x9ce
	dc.w	@objectDepth02-@objectDepthFunctions	; 0x9d0
	dc.w	@objectDepth03-@objectDepthFunctions	; 0x9d2
	dc.w	@objectDepth04-@objectDepthFunctions	; 0x9d4
@objectDepth00:
	move.w	(ptrToListOfPtrsToObjects1).w, a0	; 0x9d6
	move.w	a6, (a0)+	; 0x9da
	move.w	a0, (ptrToListOfPtrsToObjects1).w	; 0x9dc
	rts		; 0x9e0
@objectDepth01:
	move.w	(ptrToListOfPtrsToObjects2).w, a0	; 0x9e2
	move.w	a6, (a0)+	; 0x9e6
	move.w	a0, (ptrToListOfPtrsToObjects2).w	; 0x9e8
	rts		; 0x9ec
@objectDepth02:
	move.w	(ptrToListOfPtrsToObjects3).w, a0	; 0x9ee
	move.w	a6, (a0)+	; 0x9f2
	move.w	a0, (ptrToListOfPtrsToObjects3).w	; 0x9f4
	rts		; 0x9f8
@objectDepth03:
	move.w	(ptrToListOfPtrsToObjects4).w, a0	; 0x9fa
	move.w	a6, (a0)+	; 0x9fe
	move.w	a0, (ptrToListOfPtrsToObjects4).w	; 0xa00
	rts		; 0xa04
@objectDepth04:
	move.w	(ptrToListOfPtrsToObjects5).w, a0	; 0xa06
	move.w	a6, (a0)+	; 0xa0a
	move.w	a0, (ptrToListOfPtrsToObjects5).w	; 0xa0c
	rts		; 0xa10

setObjectAnimation:
	andi.w	#$00ff, d0	; 0xa12
	add.w	d0, d0	; 0xa16
	move.l	LBL_032bc8, a0	; 0xa18
	adda.w	(0, a0, d0), a0	; 0xa1e
	move.l	a0, (28, a6)	; 0xa22
	lea	LBL_2ca344, a0	; 0xa26
	adda.w	(0, a0, d0), a0	; 0xa2c
	move.l	a0, (36, a6)	; 0xa30
	rts		; 0xa34

setObjectFrame:
	andi.w	#$00ff, d0	; 0xa36
	add.w	d0, d0	; 0xa3a
	move.l	(28, a6), a0	; 0xa3c
	adda.w	(0, a0, d0), a0	; 0xa40
	move.l	a0, (32, a6)	; 0xa44
	bra.b	setFrameCommon	; 0xa48

setProjectileFrame:
	move.b	(27, a6), d0	; 0xa4a
	beq.b	setFrameCommon	; 0xa4e
	subq.b	#1, (27, a6)	; 0xa50
	beq.b	setFrameCommon	; 0xa54
	rts		; 0xa56

setFrameCommon:
	move.l	(32, a6), a0	; 0xa58
	move.b	(a0)+, d0	; 0xa5c
	bne.b	@noanimationtable	; 0xa5e
	move.b	(a0), d0	; 0xa60
	ext.w	d0	; 0xa62
	adda.w	d0, a0	; 0xa64
	move.b	(a0)+, d0	; 0xa66
@noanimationtable:
	move.b	d0, (27, a6)	; 0xa68
	moveq	#0, d0	; 0xa6c
	move.b	(a0)+, d0	; 0xa6e
	move.l	a0, (32, a6)	; 0xa70
	add.w	d0, d0	; 0xa74
	move.l	(36, a6), a0	; 0xa76
	adda.w	(0, a0, d0), a0	; 0xa7a
	move.l	a0, (40, a6)	; 0xa7e
	rts		; 0xa82

updateAirSpeedAndPos:
	move.w	(68, a6), d0	; 0xa84
	sub.w	(64, a6), d0	; 0xa88
	move.w	d0, (68, a6)	; 0xa8c
	move.w	(66, a6), d0	; 0xa90
	sub.w	(62, a6), d0	; 0xa94
	move.w	d0, (66, a6)	; 0xa98

updateAirYpos:
	bsr.b	updateAirXpos	; 0xa9c
	move.w	(68, a6), d0	; 0xa9e
	ext.l	d0	; 0xaa2
	asl.l	#8, d0	; 0xaa4
	sub.l	d0, (10, a6)	; 0xaa6
	rts		; 0xaaa

updateAirXpos:
	move.w	(66, a6), d0	; 0xaac
	ext.l	d0	; 0xab0
	asl.l	#8, d0	; 0xab2
	add.l	d0, (6, a6)	; 0xab4
	rts		; 0xab8
	move.w	(68, a6), d0	; 0xaba
	ext.l	d0	; 0xabe
	asl.l	#8, d0	; 0xac0
	add.l	d0, (10, a6)	; 0xac2
	rts		; 0xac6

appendToDamageList:
	moveq	#0, d1	; 0xac8
	move.b	(damageListIndex).w, d1	; 0xaca
	lea	(damageList).w, a0	; 0xace
	move.b	d0, (0, a0, d1)	; 0xad2
	addq.b	#1, d1	; 0xad6
	andi.b	#$1f, d1	; 0xad8
	move.b	d1, (damageListIndex).w	; 0xadc
	rts		; 0xae0

appendToDamageListAlt:
	moveq	#0, d1	; 0xae2
	move.b	(damageListAltIndex).w, d1	; 0xae4
	lea	(damageListAlt).w, a0	; 0xae8
	move.b	d0, (0, a0, d1)	; 0xaec
	addq.b	#1, d1	; 0xaf0
	andi.b	#$1f, d1	; 0xaf2
	move.b	d1, (damageListAltIndex).w	; 0xaf6
	rts		; 0xafa

clear992eData:
	lea	(LBL_ffff992e).w, a0	; 0xafc
	move.w	#$00db, d7	; 0xb00
	bra.b	clearRamBlock	; 0xb04

clearPlayersDataAndMore:
	lea	(fighter1Data).w, a0	; 0xb06
	move.w	#$192d, d7	; 0xb0a
	bra.b	clearRamBlock	; 0xb0e

clearPlayersData:
	lea	(fighter1Data).w, a0	; 0xb10
	lea	(player_1_).w, a1	; 0xb14
	move.w	#$027f, d7	; 0xb18
	moveq	#0, d0	; 0xb1c
@next:
	move.b	d0, (a0)+	; 0xb1e
	move.b	d0, (a1)+	; 0xb20
	dbf	d7, @next	; 0xb22
	rts		; 0xb26

clearPlayersAnd97caData:
	jsr	($b10, pc)	; 0xb28
	lea	(LBL_ffff97ca).w, a0	; 0xb2c
	move.w	#$0015, d7	; 0xb30
	bsr.b	clearRamBlock	; 0xb34

clear9790DataAnd9740Data:
	lea	(LBL_ffff9790).w, a0	; 0xb36
	move.w	#$001f, d7	; 0xb3a
	bsr.b	clearRamBlock	; 0xb3e
	lea	(stageStructData).w, a0	; 0xb40
	move.w	#$004f, d7	; 0xb44
	bsr.b	clearRamBlock	; 0xb48

clearProjectileData:
	lea	(projectile1Data).w, a0	; 0xb4a
	move.w	#$113f, d7	; 0xb4e

clearRamBlock:
	moveq	#0, d0	; 0xb52
@next:
	move.b	d0, (a0)+	; 0xb54
	dbf	d7, @next	; 0xb56
	rts		; 0xb5a

getObjectSlot:
	lea	(objectsData).w, a0	; 0xb5c
	moveq	#$002f, d7	; 0xb60
@next:
	tst.b	(a0)	; 0xb62
	beq.b	@end	; 0xb64
	lea	(80, a0), a0	; 0xb66
	dbf	d7, @next	; 0xb6a
	moveq	#1, d0	; 0xb6e
@end:
	rts		; 0xb70

releaseObject:
	clr.w	(a6)	; 0xb72
	clr.l	(2, a6)	; 0xb74
	rts		; 0xb78

initProjectile:
	lea	(projectile1Data).w, a0	; 0xb7a
	move.b	(641, a6), d1	; 0xb7e
	beq.b	@isplayer1	; 0xb82
	lea	(projectile2Data).w, a0	; 0xb84
@isplayer1:
	move.b	d1, (17, a0)	; 0xb88
	move.b	d1, (23, a0)	; 0xb8c
	move.b	d0, (15, a0)	; 0xb90
	move.b	(188, a6), (16, a0)	; 0xb94
	move.b	(25, a6), (25, a0)	; 0xb9a
	move.b	#$50, (22, a0)	; 0xba0
	move.w	(18, a6), (18, a0)	; 0xba6
	move.l	(90, a6), (90, a0)	; 0xbac
	move.l	(28, a6), (28, a0)	; 0xbb2
	move.l	(36, a6), (36, a0)	; 0xbb8
	move.l	(44, a6), (44, a0)	; 0xbbe
	move.l	(48, a6), (48, a0)	; 0xbc4
	move.w	(6, a6), (6, a0)	; 0xbca
	move.w	(10, a6), (10, a0)	; 0xbd0
	move.l	a6, (56, a0)	; 0xbd6
	move.w	a0, (202, a6)	; 0xbda
	moveq	#1, d0	; 0xbde
	move.b	d0, (a0)	; 0xbe0
	move.b	d0, (14, a0)	; 0xbe2
	rts		; 0xbe6

doSelectChar:
	lea	(fighter1Data).w, a1	; 0xbe8
	lea	(player_1_).w, a2	; 0xbec
	moveq	#0, d0	; 0xbf0
	tst.b	(LBL_ffff980e).w	; 0xbf2
	bne.b	@LAB_00000c00	; 0xbf6
	move.b	d0, (685, a1)	; 0xbf8
	move.b	d0, (685, a2)	; 0xbfc
@LAB_00000c00:
	move.b	d0, (650, a1)	; 0xc00
	move.b	d0, (650, a2)	; 0xc04
	tst.b	(areWeOnTitleScreenOrDemoMode).w	; 0xc08
	bne.b	@end	; 0xc0c
	move.b	(648, a2), d0	; 0xc0e
	add.b	d0, d0	; 0xc12
	or.b	(648, a1), d0	; 0xc14
	move.b	d0, (flagActivePlayers).w	; 0xc18
	move.b	(LBL_ffff996e).w, d0	; 0xc1c
	or.b	(LBL_ffff99dc).w, d0	; 0xc20
	bne.b	@end	; 0xc24
	tst.b	(areWeOnBonusStage).w	; 0xc26
	bne.b	@end	; 0xc2a
	cmpi.b	#3, (flagActivePlayers).w	; 0xc2c
	beq.b	@end	; 0xc32
	move.w	(stageId).w, d2	; 0xc34
	tst.b	(648, a2)	; 0xc38
	beq.b	@cpu	; 0xc3c
	move.b	d2, (651, a1)	; 0xc3e
	bra.b	@nocpu	; 0xc42
@cpu:
	move.b	d2, (651, a2)	; 0xc44
@nocpu:
	move.b	(651, a2), d0	; 0xc48
	cmp.b	(651, a1), d0	; 0xc4c
	bne.b	@end	; 0xc50
	tst.b	(648, a1)	; 0xc52
	bne.b	@human	; 0xc56
	clr.b	(653, a1)	; 0xc58
	move.b	(653, a2), d0	; 0xc5c
	cmp.b	(653, a1), d0	; 0xc60
	bne.b	@end	; 0xc64
	addi.b	#$20, d0	; 0xc66
	move.b	d0, (653, a1)	; 0xc6a
	bra.b	@end	; 0xc6e
@human:
	clr.b	(653, a2)	; 0xc70
	move.b	(653, a1), d0	; 0xc74
	cmp.b	(653, a2), d0	; 0xc78
	bne.b	@end	; 0xc7c
	addi.b	#$20, d0	; 0xc7e
	move.b	d0, (653, a2)	; 0xc82
@end:
	lea	(LBL_ffff985a).w, a6	; 0xc86
	move.w	#$0013, d7	; 0xc8a

clearRamArea:
	moveq	#0, d0	; 0xc8e
@next:
	move.b	d0, (a6)+	; 0xc90
	dbf	d7, @next	; 0xc92
	rts		; 0xc96

initTimeAndHp:
	lea	(time).w, a6	; 0xc98
	move.w	#$0073, d7	; 0xc9c
	bsr.b	clearRamArea	; 0xca0
	lea	(fighter1Data).w, a1	; 0xca2
	lea	(player_1_).w, a2	; 0xca6
	move.w	#$00b0, d0	; 0xcaa
	move.w	d0, (60, a1)	; 0xcae
	move.w	d0, (70, a1)	; 0xcb2
	move.w	d0, (232, a1)	; 0xcb6
	move.w	d0, (60, a2)	; 0xcba
	move.w	d0, (70, a2)	; 0xcbe
	move.w	d0, (232, a2)	; 0xcc2
	bsr.b	setAttackLevelModifier	; 0xcc6
	jsr	(fixFF97F8).w	; 0xcc8
	move.w	#$0080, (cameraX).w	; 0xccc
	rts		; 0xcd2

setAttackLevelModifier:
	tst.b	(areWeOnTitleScreenOrDemoMode).w	; 0xcd4
	beq.b	@not_on_title_screen_or_demo_mode	; 0xcd8
	moveq	#$000f, d0	; 0xcda
	move.w	d0, (142, a1)	; 0xcdc
	tst.b	(LBL_ffff9933).w	; 0xce0
	bne.b	@end1	; 0xce4
	moveq	#8, d0	; 0xce6
@end1:
	move.w	d0, (142, a2)	; 0xce8
	rts		; 0xcec
@not_on_title_screen_or_demo_mode:
	tst.b	(LBL_ffff996e).w	; 0xcee
	bne.w	@special4	; 0xcf2
	cmpi.b	#3, (flagActivePlayers).w	; 0xcf6
	bne.b	@special1	; 0xcfc
	tst.b	(LBL_ffff9938).w	; 0xcfe
	bne.b	@special2	; 0xd02
	tst.b	(LBL_ffff9943).w	; 0xd04
	bne.w	@special3	; 0xd08
	moveq	#4, d0	; 0xd0c
	move.w	d0, (142, a1)	; 0xd0e
	move.w	d0, (142, a2)	; 0xd12
	move.b	(650, a1), d2	; 0xd16
	cmp.b	(650, a2), d2	; 0xd1a
	beq.b	@end2	; 0xd1e
	move.l	a1, a0	; 0xd20
	tst.b	d2	; 0xd22
	beq.b	@f1_28a_eq_f2_28a	; 0xd24
	move.l	a2, a0	; 0xd26
@f1_28a_eq_f2_28a:
	jsr	(random).w	; 0xd28
	andi.w	#$001f, d0	; 0xd2c
	move.b	(@attackLevelModifiers, pc, d0.w), d1	; 0xd30
	ext.w	d1	; 0xd34
	move.w	d1, (142, a0)	; 0xd36
@end2:
	rts		; 0xd3a
@attackLevelModifiers:
	dc.b	$04, $04, $04, $05, $05, $05, $05, $05, $05, $05, $05, $05, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $07, $07, $07, $07, $07, $07, $08	; 0xd3c
@special1:
	move.l	a1, a0	; 0xd5c
	tst.b	(LBL_ffff8288).w	; 0xd5e
	bne.b	@is_fighter1_human	; 0xd62
	move.l	a2, a0	; 0xd64
@is_fighter1_human:
	move.w	#4, (142, a0)	; 0xd66
	rts		; 0xd6c
@special2:
	lea	($e04, pc), a0	; 0xd6e
	moveq	#0, d0	; 0xd72
	move.b	(fighter1AttackLevel).w, d0	; 0xd74
	add.w	d0, d0	; 0xd78
	move.w	(0, a0, d0), (142, a1)	; 0xd7a
	move.b	(fighter2AttackLevel).w, d0	; 0xd80
	add.w	d0, d0	; 0xd84
	move.w	(0, a0, d0), (142, a2)	; 0xd86
	rts		; 0xd8c
@special3:
	lea	($e04, pc), a0	; 0xd8e
	moveq	#0, d0	; 0xd92
	move.b	(LBL_fffffcec).w, d0	; 0xd94
	add.w	d0, d0	; 0xd98
	move.w	(0, a0, d0), (142, a1)	; 0xd9a
	move.b	(LBL_fffffced).w, d0	; 0xda0
	add.w	d0, d0	; 0xda4
	move.w	(0, a0, d0), (142, a2)	; 0xda6
	rts		; 0xdac
@special4:
	move.b	(648, a1), d0	; 0xdae
	or.b	(648, a2), d0	; 0xdb2
	beq.b	@both_humans	; 0xdb6
	lea	($e04, pc), a0	; 0xdb8
	lea	(LBL_ffff997a).w, a3	; 0xdbc
	lea	(LBL_ffff9982).w, a4	; 0xdc0
	moveq	#0, d0	; 0xdc4
	move.b	(LBL_ffff9971).w, d0	; 0xdc6
	add.w	d0, d0	; 0xdca
	bsr.b	FUN_00000df0	; 0xdcc
	move.w	d1, (142, a1)	; 0xdce
	addq.w	#1, d0	; 0xdd2
	bsr.b	FUN_00000df0	; 0xdd4
	move.w	d1, (142, a2)	; 0xdd6
	rts		; 0xdda
@both_humans:
	moveq	#$000f, d0	; 0xddc
	move.w	d0, (LBL_ffff97f0).w	; 0xdde
	move.w	d0, (142, a1)	; 0xde2
	move.w	d0, (142, a2)	; 0xde6
	st	(LBL_ffff996f).w	; 0xdea
	rts		; 0xdee

FUN_00000df0:
	move.b	(0, a3, d0), d1	; 0xdf0
	andi.w	#7, d1	; 0xdf4
	move.b	(0, a4, d1), d1	; 0xdf8
	add.w	d1, d1	; 0xdfc
	move.w	(0, a0, d1), d1	; 0xdfe
	rts		; 0xe02
	dc.w	$0000, $0002, $0004, $0006, $0008, $000a, $000d, $000f	; 0xe04

next_fight:
	move.w	(currentFightId).w, d0	; 0xe14
	lea	(listOfFights).w, a0	; 0xe18
	move.w	(0, a0, d0), (stageId).w	; 0xe1c
	addq.w	#2, (currentFightId).w	; 0xe22
	rts		; 0xe26

getNextFight:
	tst.b	(areWeOnTitleScreenOrDemoMode).w	; 0xe28
	bne.b	@end1	; 0xe2c
	tst.b	(LBL_ffff996e).w	; 0xe2e
	bne.b	next_fight	; 0xe32
	tst.b	(areWeOnBonusStage).w	; 0xe34
	bne.b	@loc_00000E40	; 0xe38
	move.w	(stageId).w, (lastStageId).w	; 0xe3a
@loc_00000E40:
	clr.b	(areWeOnBonusStage).w	; 0xe40
	tst.b	(superMode).w	; 0xe44
	bne.b	@next	; 0xe48
	moveq	#0, d0	; 0xe4a
	moveq	#0, d1	; 0xe4c
	move.b	(storyModePart).w, d0	; 0xe4e
	move.b	(bonusStagesList, pc, d0.w), d1	; 0xe52
	bmi.b	@next	; 0xe56
	move.b	(bonusStagesList, pc, d0.w), d0	; 0xe58
	cmp.b	(LBL_ffff9815).w, d1	; 0xe5c
	beq.b	@end2	; 0xe60
@next:
	lea	(listOfFights).w, a1	; 0xe62
	move.w	(currentFightId).w, d0	; 0xe66
	move.w	(0, a1, d0), (stageId).w	; 0xe6a
	bpl.b	@stage_not_done	; 0xe70
	addq.w	#2, (currentFightId).w	; 0xe72
	bra.b	@next	; 0xe76
@stage_not_done:
	cmpi.w	#8, (stageId).w	; 0xe78
	bne.b	@not_dictator_stage	; 0xe7e
	st	(LBL_ffff97ee).w	; 0xe80
	st	(LBL_ffff9821).w	; 0xe84
@not_dictator_stage:
	tst.b	(LBL_ffff981f).w	; 0xe88
	beq.b	@end1	; 0xe8c
	moveq	#0, d0	; 0xe8e
	clr.b	(LBL_ffff981f).w	; 0xe90
	move.b	(player_1_).w, d0	; 0xe94
	tst.b	(LBL_ffff9820).w	; 0xe98
	beq.b	@player2	; 0xe9c
	move.b	(player_1_char_id).w, d0	; 0xe9e
@player2:
	move.w	d0, (stageId).w	; 0xea2
@end1:
	rts		; 0xea6
@end2:
	st	(areWeOnBonusStage).w	; 0xea8
	move.w	d0, (stageId).w	; 0xeac
	rts		; 0xeb0

bonusStagesList:
	dc.b	$03, $10, $06, $11, $09, $12, $ff, $ff	; 0xeb2

computeListOfFights:
	clr.w	(currentFightId).w	; 0xeba
	clr.w	(stageId).w	; 0xebe
	lea	charactersPermutations, a0	; 0xec2
	moveq	#0, d0	; 0xec8
	move.b	(LBL_ffff9810).w, d0	; 0xeca
	move.w	d0, d1	; 0xece
	add.w	d0, d0	; 0xed0
	add.w	d1, d0	; 0xed2
	asl.w	#4, d0	; 0xed4
	lea	(0, a0, d0), a0	; 0xed6
	jsr	(random).w	; 0xeda
	andi.w	#7, d0	; 0xede
	move.w	d0, d1	; 0xee2
	add.w	d0, d0	; 0xee4
	add.w	d1, d0	; 0xee6
	add.w	d0, d0	; 0xee8
	lea	(listOfFights).w, a1	; 0xeea
	moveq	#3, d1	; 0xeee
	tst.b	(superMode).w	; 0xef0
	beq.b	@next	; 0xef4
	moveq	#5, d1	; 0xef6
@next:
	moveq	#0, d2	; 0xef8
	move.b	(0, a0, d0), d2	; 0xefa
	lsr.w	#4, d2	; 0xefe
	andi.w	#$000f, d2	; 0xf00
	move.w	d2, (a1)+	; 0xf04
	move.b	(0, a0, d0), d2	; 0xf06
	andi.w	#$000f, d2	; 0xf0a
	move.w	d2, (a1)+	; 0xf0e
	addq.w	#1, d0	; 0xf10
	dbf	d1, @next	; 0xf12
	move.w	#$000a, (a1)+	; 0xf16
	move.w	#$000b, (a1)+	; 0xf1a
	move.w	#9, (a1)+	; 0xf1e
	move.w	#8, (a1)+	; 0xf22
	tst.b	(superMode).w	; 0xf26
	bne.b	@end	; 0xf2a
	move.w	#$0020, (a1)+	; 0xf2c
@end:
	rts		; 0xf30

FUN_00000f32:
	clr.w	(currentFightId).w	; 0xf32
	clr.w	(stageId).w	; 0xf36
	moveq	#0, d2	; 0xf3a
	moveq	#$000b, d4	; 0xf3c
	lea	(listOfFights).w, a0	; 0xf3e
@next2:
	jsr	(random).w	; 0xf42
	andi.w	#$000f, d0	; 0xf46
	move.w	d2, d3	; 0xf4a
	beq.b	@ignore	; 0xf4c
	subq.w	#1, d3	; 0xf4e
	lea	(listOfFights).w, a1	; 0xf50
@next:
	cmp.w	(a1)+, d0	; 0xf54
	beq.b	@next2	; 0xf56
	dbf	d3, @next	; 0xf58
@ignore:
	move.w	d0, (a0)+	; 0xf5c
	addq.w	#1, d2	; 0xf5e
	dbf	d4, @next2	; 0xf60
	bra.w	getNextFight	; 0xf64

initFighters:
	move.w	(cameraX).w, d0	; 0xf68
	addi.w	#$004d, d0	; 0xf6c
	move.w	d0, (LBL_ffff8006).w	; 0xf70
	move.w	d0, (LBL_ffff80d8).w	; 0xf74
	addi.w	#$0066, d0	; 0xf78
	move.w	d0, (player_1_).w	; 0xf7c
	move.w	d0, (player_1_).w	; 0xf80
	move.w	#$00c0, d0	; 0xf84
	move.w	d0, (LBL_ffff800a).w	; 0xf88
	move.w	d0, (LBL_ffff80dc).w	; 0xf8c
	move.w	d0, (player_1_).w	; 0xf90
	move.w	d0, (player_1_).w	; 0xf94
	moveq	#8, d0	; 0xf98
	move.b	d0, (LBL_ffff8019).w	; 0xf9a
	move.b	d0, (LBL_ffff80c4).w	; 0xf9e
	move.w	#$4580, (LBL_ffff8012).w	; 0xfa2
	move.w	#$6600, (player_1_).w	; 0xfa8
	moveq	#$0050, d0	; 0xfae
	move.b	d0, (LBL_ffff8016).w	; 0xfb0
	move.b	d0, (player_1_).w	; 0xfb4
	moveq	#0, d1	; 0xfb8
	move.b	(player_1_char_id).w, d0	; 0xfba
	add.b	d0, d0	; 0xfbe
	move.b	(player_1_).w, d1	; 0xfc0
	add.b	d1, d1	; 0xfc4
	cmpi.w	#$0010, (stageId).w	; 0xfc6
	beq.b	@stages_10_12	; 0xfcc
	cmpi.w	#$0012, (stageId).w	; 0xfce
	bne.b	@ignore	; 0xfd4
@stages_10_12:
	addq.b	#1, d0	; 0xfd6
	addq.b	#1, d1	; 0xfd8
@ignore:
	move.b	(playerWidths, pc, d0.w), d0	; 0xfda
	ext.w	d0	; 0xfde
	move.w	d0, (LBL_ffff80c8).w	; 0xfe0
	move.b	(playerWidths, pc, d1.w), d1	; 0xfe4
	ext.w	d1	; 0xfe8
	move.w	d1, (player_1_).w	; 0xfea
	moveq	#1, d0	; 0xfee
	move.b	d0, (player_1_).w	; 0xff0
	move.b	d0, (LBL_ffff87a0).w	; 0xff4
	move.b	d0, (LBL_ffff87f0).w	; 0xff8
	move.b	d0, (LBL_ffff8800).w	; 0xffc
	move.b	#4, (LBL_ffff87af).w	; 0x1000
	move.b	#4, (LBL_ffff87ff).w	; 0x1006
	rts		; 0x100c

playerWidths:
	dc.b	$17, $0e, $20, $19, $1f, $14, $17, $11, $17, $0e, $15, $13, $1b, $13, $17, $11, $17, $13, $1a, $13, $17, $12, $17, $15, $15, $12, $1b, $12, $17, $0f, $18, $1a	; 0x100e

fixFighterPosition:
	tst.b	(408, a6)	; 0x102e
	bne.b	@end	; 0x1032
	clr.b	(103, a6)	; 0x1034
	tst.b	(410, a6)	; 0x1038
	bne.b	@end	; 0x103c
	moveq	#1, d0	; 0x103e
	move.w	(cameraX).w, d1	; 0x1040
	add.w	(200, a6), d1	; 0x1044
	cmp.w	(6, a6), d1	; 0x1048
	bge.b	@ignore	; 0x104c
	move.w	#$0100, d1	; 0x104e
	add.w	(cameraX).w, d1	; 0x1052
	sub.w	(200, a6), d1	; 0x1056
	cmp.w	(6, a6), d1	; 0x105a
	bgt.b	@end	; 0x105e
	moveq	#2, d0	; 0x1060
@ignore:
	move.b	d0, (103, a6)	; 0x1062
	move.w	d1, d0	; 0x1066
	sub.w	(6, a6), d1	; 0x1068
	move.w	d0, (6, a6)	; 0x106c
	tst.b	(117, a6)	; 0x1070
	beq.b	@end	; 0x1074
	move.w	(662, a6), a4	; 0x1076
	add.w	d1, (6, a4)	; 0x107a
@end:
	rts		; 0x107e

activePlayers:
	moveq	#0, d0	; 0x1080
	moveq	#1, d1	; 0x1082
	move.b	d1, (a6)	; 0x1084
	move.b	d1, (1, a6)	; 0x1086
	move.b	d0, (251, a6)	; 0x108a
	cmpi.b	#$0b, (651, a6)	; 0x108e
	bne.b	@not_claw	; 0x1094
	move.b	d1, (251, a6)	; 0x1096
@not_claw:
	moveq	#0, d0	; 0x109a
	move.b	(651, a6), d0	; 0x109c
	add.w	d0, d0	; 0x10a0
	add.w	d0, d0	; 0x10a2
	lea	animationsDataTable, a0	; 0x10a4
	move.l	(0, a0, d0), (28, a6)	; 0x10aa
	lea	patternsTable, a0	; 0x10b0
	move.l	(0, a0, d0), (90, a6)	; 0x10b6
	lea	framesDataTable, a0	; 0x10bc
	move.l	(0, a0, d0), (36, a6)	; 0x10c2
	lea	attributesTables, a0	; 0x10c8
	move.l	(0, a0, d0), (44, a6)	; 0x10ce
	lea	rectsTable, a0	; 0x10d4
	move.l	(0, a0, d0), (48, a6)	; 0x10da
	moveq	#0, d0	; 0x10e0
	move.b	(651, a6), d0	; 0x10e2
	lea	($116a, pc), a0	; 0x10e6
	nop		; 0x10ea
	move.b	(0, a0, d0), d0	; 0x10ec
	move.w	d0, (128, a6)	; 0x10f0
	move.w	#$002e, (130, a6)	; 0x10f4
	moveq	#0, d0	; 0x10fa
	moveq	#0, d1	; 0x10fc
	move.b	(651, a6), d0	; 0x10fe
	lea	($11ba, pc), a0	; 0x1102
	nop		; 0x1106
	move.b	(0, a0, d0), d0	; 0x1108
	beq.b	@loc_00001132	; 0x110c
	subq.w	#1, d0	; 0x110e
	lsl.w	#4, d0	; 0x1110
	move.b	(641, a6), d1	; 0x1112
	lsl.w	#3, d1	; 0x1116
	add.w	d1, d0	; 0x1118
	lea	($117a, pc), a0	; 0x111a
	nop		; 0x111e
	lea	(0, a0, d0), a0	; 0x1120
	move.w	(ptrDmaQueueCurrentEntry).w, a1	; 0x1124
	move.w	(a0)+, (a1)+	; 0x1128
	move.l	(a0)+, (a1)+	; 0x112a
	move.w	(a0), (a1)+	; 0x112c
	move.w	a1, (ptrDmaQueueCurrentEntry).w	; 0x112e
@loc_00001132:
	lea	(paletteBuffers).w, a1	; 0x1132
	move.b	(641, a6), (23, a6)	; 0x1136
	beq.b	@loc_00001142	; 0x113c
	lea	(paletteBuffers).w, a1	; 0x113e
@loc_00001142:
	moveq	#0, d0	; 0x1142
	move.b	(651, a6), d0	; 0x1144
	lsl.b	#2, d0	; 0x1148
	lea	charPalettes, a0	; 0x114a
	move.l	(0, a0, d0), a0	; 0x1150
	move.b	(653, a6), d0	; 0x1154
	adda.w	d0, a0	; 0x1158
	move.w	#7, d7	; 0x115a
@next_color:
	move.l	(a0)+, (a1)+	; 0x115e
	dbf	d7, @next_color	; 0x1160
	st	(flagProcessPalettes).w	; 0x1164
	rts		; 0x1168

field80Values:
	dc.b	$10, $10, $11, $11, $10, $0e, $1a, $14, $10, $12, $10, $10, $0e, $14, $11, $10	; 0x116a

structTileDataDMA_ARRAY_117a:
	dc.w	$0100	; length in words	; 0x117a
	dc.l	ryu_ptrns_1/2	; source	; 0x117c
	dc.w	$bc00	; dest	; 0x1180
	; 0x-1
	dc.w	$0100	; length in words	; 0x1182
	dc.l	ryu_ptrns_1/2	; source	; 0x1184
	dc.w	$cc00	; dest	; 0x1188
	; 0x-1
	dc.w	$0100	; length in words	; 0x118a
	dc.l	ryu_ptrns_1/2	; source	; 0x118c
	dc.w	$bc00	; dest	; 0x1190
	; 0x-1
	dc.w	$0100	; length in words	; 0x1192
	dc.l	ryu_ptrns_1/2	; source	; 0x1194
	dc.w	$cc00	; dest	; 0x1198
	; 0x-1
	dc.w	$0100	; length in words	; 0x119a
	dc.l	ryu_ptrns_1/2	; source	; 0x119c
	dc.w	$bc00	; dest	; 0x11a0
	; 0x-1
	dc.w	$0100	; length in words	; 0x11a2
	dc.l	ryu_ptrns_1/2	; source	; 0x11a4
	dc.w	$cc00	; dest	; 0x11a8
	; 0x-1
	dc.w	$0100	; length in words	; 0x11aa
	dc.l	ryu_ptrns_1/2	; source	; 0x11ac
	dc.w	$bc00	; dest	; 0x11b0
	; 0x-1
	dc.w	$0100	; length in words	; 0x11b2
	dc.l	ryu_ptrns_1/2	; source	; 0x11b4
	dc.w	$cc00	; dest	; 0x11b8
	; 0x-1

BYTE_ARRAY_11ba:
	dc.b	$00, $00, $00, $01, $02, $00, $00, $03, $00, $04, $00, $00, $00, $00, $00, $00	; 0x11ba

setCharacterAnimation:
	andi.w	#$00ff, d0	; 0x11ca
	add.w	d0, d0	; 0x11ce
	move.l	(28, a6), a0	; 0x11d0
	adda.w	(0, a0, d0), a0	; 0x11d4
	move.l	a0, (32, a6)	; 0x11d8
	move.w	#$00c6, d6	; 0x11dc
	move.w	#$00c7, d7	; 0x11e0
	bra.b	next_animation	; 0x11e4

setProjectileAnimation:
	andi.w	#$00ff, d0	; 0x11e6
	add.w	d0, d0	; 0x11ea
	move.l	(28, a6), a0	; 0x11ec
	adda.w	(0, a0, d0), a0	; 0x11f0
	move.l	a0, (32, a6)	; 0x11f4
	move.w	#$005e, d6	; 0x11f8
	move.w	#$005f, d7	; 0x11fc
	bra.b	next_animation	; 0x1200

updateCharAnimation:
	move.w	#$00c6, d6	; 0x1202
	move.w	#$00c7, d7	; 0x1206
	bra.b	update_animation	; 0x120a

updateProjectileAnimation:
	move.w	#$005e, d6	; 0x120c
	move.w	#$005f, d7	; 0x1210

update_animation:
	move.b	(27, a6), d0	; 0x1214
	beq.b	next_animation	; 0x1218
	subq.b	#1, (27, a6)	; 0x121a
	bne.b	next_animation_end	; 0x121e

next_animation:
	move.l	(32, a6), a0	; 0x1220
	move.b	(a0)+, (27, a6)	; 0x1224
	move.b	(a0)+, (26, a6)	; 0x1228
	moveq	#0, d0	; 0x122c
	moveq	#0, d1	; 0x122e
	move.b	(a0)+, d0	; 0x1230
	move.b	(a0)+, d1	; 0x1232
	move.l	a0, (32, a6)	; 0x1234
	move.b	d0, (0, a6, d6)	; 0x1238
	st	(0, a6, d7)	; 0x123c
	add.w	d0, d0	; 0x1240
	move.l	(36, a6), a1	; 0x1242
	adda.w	(0, a1, d0), a1	; 0x1246
	move.l	a1, (40, a6)	; 0x124a
	lsl.w	#4, d1	; 0x124e
	move.l	(44, a6), a1	; 0x1250
	adda.w	d1, a1	; 0x1254
	move.l	(a1), (74, a6)	; 0x1256
	move.l	(4, a1), (78, a6)	; 0x125a
	move.l	(8, a1), (82, a6)	; 0x1260
	move.l	(12, a1), (86, a6)	; 0x1266
	tst.b	(-3, a0)	; 0x126c
	bpl.b	next_animation_end	; 0x1270
	move.w	(a0), d0	; 0x1272
	adda.w	d0, a0	; 0x1274
	move.l	a0, (32, a6)	; 0x1276

next_animation_end:
	rts		; 0x127a

updateProjected:
	move.w	(662, a6), a4	; 0x127c
	moveq	#0, d0	; 0x1280
	moveq	#0, d1	; 0x1282
	move.b	(651, a4), d0	; 0x1284
	lsl.w	#5, d0	; 0x1288
	move.b	(651, a6), d1	; 0x128a
	add.b	d1, d1	; 0x128e
	add.w	d1, d0	; 0x1290
	lea	WORD_ARRAY_0003c6a2_ryu, a0	; 0x1292
	adda.w	(0, a0, d0), a0	; 0x1298
	moveq	#0, d0	; 0x129c
	move.b	(82, a4), d0	; 0x129e
	add.w	d0, d0	; 0x12a2
	add.w	d0, d0	; 0x12a4
	adda.l	d0, a0	; 0x12a6
	move.b	(a0)+, d0	; 0x12a8
	ext.w	d0	; 0x12aa
	btst	#3, (25, a4)	; 0x12ac
	beq.b	@not_flipped	; 0x12b2
	neg.w	d0	; 0x12b4
@not_flipped:
	add.w	(6, a4), d0	; 0x12b6
	move.w	d0, (6, a6)	; 0x12ba
	move.b	(a0)+, d0	; 0x12be
	ext.w	d0	; 0x12c0
	add.w	(10, a4), d0	; 0x12c2
	move.w	d0, (10, a6)	; 0x12c6
	move.b	(a0), d0	; 0x12ca
	move.b	(25, a4), d1	; 0x12cc
	eor.b	d0, d1	; 0x12d0
	andi.b	#8, d1	; 0x12d2
	move.b	d1, (25, a6)	; 0x12d6
	move.b	(a0)+, d0	; 0x12da
	andi.b	#1, d0	; 0x12dc
	move.b	(641, a4), d1	; 0x12e0
	eor.b	d1, d0	; 0x12e4
	eori.b	#1, d0	; 0x12e6
	move.b	d0, (fightersPriority).w	; 0x12ea
	moveq	#0, d0	; 0x12ee
	move.b	#$8c, d0	; 0x12f0
	move.l	(28, a6), a1	; 0x12f4
	adda.w	(0, a1, d0), a1	; 0x12f8
	moveq	#0, d0	; 0x12fc
	move.b	(a0), d0	; 0x12fe
	lsl.w	#2, d0	; 0x1300
	adda.w	d0, a1	; 0x1302
	move.l	a1, (32, a6)	; 0x1304
	move.w	#$00c6, d6	; 0x1308
	move.w	#$00c7, d7	; 0x130c
	bra.w	next_animation	; 0x1310

clampVerticalPosition:
	tst.b	(94, a6)	; 0x1314
	bne.b	@return1	; 0x1318
	move.w	(10, a6), d0	; 0x131a
	cmpi.w	#$00c0, d0	; 0x131e
	ble.b	@return0	; 0x1322
	move.w	#$00c0, (10, a6)	; 0x1324
	moveq	#1, d0	; 0x132a
	rts		; 0x132c
@return0:
	moveq	#0, d0	; 0x132e
	rts		; 0x1330
@return1:
	moveq	#1, d0	; 0x1332
	move.b	d0, (95, a6)	; 0x1334
	rts		; 0x1338

checkOrientation:
	moveq	#0, d0	; 0x133a
	move.w	(654, a6), d0	; 0x133c
	btst	#3, d0	; 0x1340
	beq.b	@return0_2	; 0x1344
	move.b	#1, (24, a6)	; 0x1346
	rts		; 0x134c
@return0_2:
	btst	#2, d0	; 0x134e
	beq.b	@return2	; 0x1352
	clr.b	(24, a6)	; 0x1354
	rts		; 0x1358
@return2:
	ori.b	#2, (24, a6)	; 0x135a
	rts		; 0x1360

FUN_00001362:
	tst.b	(26, a6)	; 0x1362
	beq.b	@end	; 0x1366
	moveq	#0, d1	; 0x1368
	move.b	(188, a6), d1	; 0x136a
	tst.b	(189, a6)	; 0x136e
	beq.b	@punch	; 0x1372
	addq.w	#6, d1	; 0x1374
@punch:
	move.w	(WORD_ARRAY_138a, pc, d1.w), d1	; 0x1376
	move.w	(656, a6), d0	; 0x137a
	not.w	d0	; 0x137e
	and.w	(654, a6), d0	; 0x1380
	and.w	d1, d0	; 0x1384
	rts		; 0x1386
@end:
	rts		; 0x1388

WORD_ARRAY_138a:
	dc.w	$0100, $0200, $0400, $1000, $2000, $4000	; 0x138a

ifSomething_1396:
	tst.b	(648, a6)	; 0x1396
	beq.w	return_1	; 0x139a
	bra.b	ifSomethingHuman_1396	; 0x139e

ifSomething_13a0:
	tst.b	(648, a6)	; 0x13a0
	beq.w	return_1	; 0x13a4
	tst.b	(193, a6)	; 0x13a8
	bne.w	return_1	; 0x13ac

ifSomethingHuman_1396:
	tst.b	(areWeBeforeFight).w	; 0x13b0
	bne.w	return_1	; 0x13b4
	tst.b	(isFightOver).w	; 0x13b8
	bne.w	return_1	; 0x13bc
	tst.b	(projectionFlags).w	; 0x13c0
	bne.w	return_1	; 0x13c4
	move.b	(3, a6), d1	; 0x13c8
	cmpi.b	#$0c, d1	; 0x13cc
	beq.b	return_1	; 0x13d0
	cmpi.b	#$0e, d1	; 0x13d2
	beq.b	@set_AF_return_1	; 0x13d6
	cmpi.b	#$14, d1	; 0x13d8
	beq.b	@set_AF_return_1	; 0x13dc
	tst.b	(648, a6)	; 0x13de
	beq.b	@check_hp_and_parry	; 0x13e2
	cmpi.b	#$0a, d1	; 0x13e4
	beq.b	@state_06_0a	; 0x13e8
	cmpi.b	#4, d1	; 0x13ea
	bne.b	@check_hp_and_parry	; 0x13ee
	cmpi.b	#6, (4, a6)	; 0x13f0
	bne.b	@check_hp_and_parry	; 0x13f6
@state_06_0a:
	tst.b	(179, a6)	; 0x13f8
	beq.b	return_1	; 0x13fc
@check_hp_and_parry:
	move.w	(60, a6), d1	; 0x13fe
	cmp.w	(70, a6), d1	; 0x1402
	bne.b	return_1	; 0x1406
	tst.b	(116, a6)	; 0x1408
	bne.b	return_1	; 0x140c
	moveq	#0, d1	; 0x140e
	rts		; 0x1410
@set_AF_return_1:
	move.b	#1, (175, a6)	; 0x1412

return_1:
	moveq	#1, d1	; 0x1418
	rts		; 0x141a

computePunchOrKickPower:
	move.w	(656, a6), d0	; 0x141c
	not.w	d0	; 0x1420
	and.w	(654, a6), d0	; 0x1422
	andi.w	#$7700, d0	; 0x1426
	clr.b	(189, a6)	; 0x142a
	clr.b	(188, a6)	; 0x142e
	btst	#8, d0	; 0x1432
	bne.b	@light	; 0x1436
	btst	#9, d0	; 0x1438
	bne.b	@medium	; 0x143c
	btst	#$000a, d0	; 0x143e
	bne.b	@heavy	; 0x1442
	move.b	#2, (189, a6)	; 0x1444
	btst	#$000c, d0	; 0x144a
	bne.b	@light	; 0x144e
	btst	#$000d, d0	; 0x1450
	beq.b	@heavy	; 0x1454
@medium:
	move.b	#2, (188, a6)	; 0x1456
	rts		; 0x145c
@heavy:
	move.b	#4, (188, a6)	; 0x145e
	rts		; 0x1464
@light:
	rts		; 0x1466

updateWalk:
	move.b	(25, a6), d1	; 0x1468
	ext.w	d1	; 0x146c
	lsr.w	#3, d1	; 0x146e
	move.b	(24, a6), d0	; 0x1470
	ext.w	d0	; 0x1474
	eor.w	d1, d0	; 0x1476
	add.w	d0, d0	; 0x1478
	move.w	d0, d3	; 0x147a
	move.b	(651, a6), d1	; 0x147c
	ext.w	d1	; 0x1480
	lsl.w	#3, d1	; 0x1482
	add.w	d1, d0	; 0x1484
	lea	walkSpeedTable, a0	; 0x1486
	move.w	(0, a0, d0), d0	; 0x148c
	tst.b	(25, a6)	; 0x1490
	beq.b	@noflip	; 0x1494
	neg.w	d0	; 0x1496
@noflip:
	ext.l	d0	; 0x1498
	asl.l	#8, d0	; 0x149a
	add.l	d0, (6, a6)	; 0x149c
	rts		; 0x14a0

updateXPosition:
	move.w	(66, a6), d0	; 0x14a2
	spl	d1	; 0x14a6
	sub.w	(62, a6), d0	; 0x14a8
	smi	d2	; 0x14ac
	eor.b	d1, d2	; 0x14ae
	bne.b	@set_x_velocity	; 0x14b0
	clr.w	d0	; 0x14b2
@set_x_velocity:
	move.w	d0, (66, a6)	; 0x14b4
	ext.l	d0	; 0x14b8
	asl.l	#8, d0	; 0x14ba
	add.l	d0, (6, a6)	; 0x14bc
	tst.w	(66, a6)	; 0x14c0
	rts		; 0x14c4

FUN_000014c6:
	move.b	(189, a6), d1	; 0x14c6

FUN_000014ca:
	moveq	#0, d0	; 0x14ca
	move.b	(651, a6), d0	; 0x14cc
	add.w	d0, d0	; 0x14d0
	move.w	(jumpTable_14da, pc, d0.w), d0	; 0x14d2
	jmp	(jumpTable_14da, pc, d0.w)	; 0x14d6

jumpTable_14da:
	dc.w	WORD_000014da_ryu_guile_ken_deejay-jumpTable_14da	; 0x14da
	dc.w	return_0-jumpTable_14da	; 0x14dc
	dc.w	return_0-jumpTable_14da	; 0x14de
	dc.w	WORD_000014da_ryu_guile_ken_deejay-jumpTable_14da	; 0x14e0
	dc.w	WORD_000014da_ryu_guile_ken_deejay-jumpTable_14da	; 0x14e2
	dc.w	WORD_000014da_chun_li-jumpTable_14da	; 0x14e4
	dc.w	return_0-jumpTable_14da	; 0x14e6
	dc.w	WORD_000014da_dhalsim_sagat-jumpTable_14da	; 0x14e8
	dc.w	return_0-jumpTable_14da	; 0x14ea
	dc.w	WORD_000014da_dhalsim_sagat-jumpTable_14da	; 0x14ec
	dc.w	return_0-jumpTable_14da	; 0x14ee
	dc.w	return_0-jumpTable_14da	; 0x14f0
	dc.w	return_0-jumpTable_14da	; 0x14f2
	dc.w	return_0-jumpTable_14da	; 0x14f4
	dc.w	return_0-jumpTable_14da	; 0x14f6
	dc.w	WORD_000014da_ryu_guile_ken_deejay-jumpTable_14da	; 0x14f8

WORD_000014da_ryu_guile_ken_deejay:
	tst.b	d1	; 0x14fa
	bne.b	return_0	; 0x14fc

return_with_projectile:
	move.w	(202, a6), d0	; 0x14fe
	rts		; 0x1502

WORD_000014da_chun_li:
	cmpi.b	#4, d1	; 0x1504
	bne.b	return_0	; 0x1508
	bra.b	return_with_projectile	; 0x150a

WORD_000014da_dhalsim_sagat:
	cmpi.b	#4, d1	; 0x150c
	bcs.b	return_with_projectile	; 0x1510

return_0:
	moveq	#0, d0	; 0x1512
	rts		; 0x1514

ifSomething_FUN_00001516:
	move.w	(6, a6), d0	; 0x1516
	sub.w	(6, a0), d0	; 0x151a
	bpl.b	@positive1	; 0x151e
	neg.w	d0	; 0x1520
@positive1:
	move.w	(200, a6), d1	; 0x1522
	addi.w	#$000b, d1	; 0x1526
	cmp.w	d1, d0	; 0x152a
	bcs.b	@return_1	; 0x152c
	moveq	#0, d0	; 0x152e
	move.b	(651, a6), d0	; 0x1530
	lsl.w	#2, d0	; 0x1534
	lea	DAT_00032b88, a1	; 0x1536
	move.l	(0, a1, d0), a1	; 0x153c
	andi.w	#$00ff, d6	; 0x1540
	moveq	#0, d5	; 0x1544
	move.b	(0, a1, d6), d5	; 0x1546
	moveq	#0, d4	; 0x154a
	tst.b	(14, a0)	; 0x154c
	bne.b	@not_f0e	; 0x1550
	move.w	(200, a0), d4	; 0x1552
@not_f0e:
	tst.b	(25, a0)	; 0x1556
	bne.b	@not_flip	; 0x155a
	neg.w	d4	; 0x155c
@not_flip:
	add.w	(6, a0), d4	; 0x155e
	moveq	#8, d1	; 0x1562
	move.w	(6, a6), d0	; 0x1564
	sub.w	d4, d0	; 0x1568
	bpl.b	@positive2	; 0x156a
	moveq	#0, d1	; 0x156c
	neg.w	d0	; 0x156e
@positive2:
	cmp.w	d0, d5	; 0x1570
	bcs.b	@return_0	; 0x1572
	cmp.b	(25, a0), d1	; 0x1574
	bne.b	@return_0	; 0x1578
@return_1:
	moveq	#1, d0	; 0x157a
	rts		; 0x157c
@return_0:
	moveq	#0, d0	; 0x157e
	rts		; 0x1580

checkPlayerOrder:
	tst.b	(areWeOnBonusStage).w	; 0x1582
	bne.b	@return	; 0x1586
	moveq	#0, d2	; 0x1588
	move.w	(player_1_).w, d0	; 0x158a
	sub.w	(LBL_ffff8006).w, d0	; 0x158e
	bpl.b	@p2_right_to_p1_a	; 0x1592
	moveq	#1, d2	; 0x1594
@p2_right_to_p1_a:
	addi.w	#$000e, d0	; 0x1596
	cmpi.w	#$001c, d0	; 0x159a
	bcs.b	@return	; 0x159e
	moveq	#8, d0	; 0x15a0
	moveq	#0, d1	; 0x15a2
	tst.b	d2	; 0x15a4
	beq.b	@p2_right_to_p1_b	; 0x15a6
	exg	d0, d1	; 0x15a8
@p2_right_to_p1_b:
	move.b	d0, (LBL_ffff80c4).w	; 0x15aa
	move.b	d1, (player_1_).w	; 0x15ae
@return:
	rts		; 0x15b2

populateCpuFields16f:
	bsr.b	computeF128	; 0x15b4
	lea	LBL_025a5e, a0	; 0x15b6
	lea	LBL_025ade, a1	; 0x15bc
	lea	(367, a6), a2	; 0x15c2
	move.w	(142, a6), d2	; 0x15c6
	moveq	#7, d7	; 0x15ca
@next:
	jsr	(random).w	; 0x15cc
	andi.w	#$000f, d0	; 0x15d0
	move.b	(0, a0, d2), d1	; 0x15d4
	move.b	(0, a1, d0), d0	; 0x15d8
	add.b	d0, d1	; 0x15dc
	beq.b	@clamp	; 0x15de
	bpl.b	@store	; 0x15e0
@clamp:
	moveq	#1, d1	; 0x15e2
@store:
	move.b	d1, (a2)+	; 0x15e4
	lea	(16, a0), a0	; 0x15e6
	lea	(16, a1), a1	; 0x15ea
	dbf	d7, @next	; 0x15ee
	rts		; 0x15f2

return_3:
	move.w	#3, (296, a6)	; 0x15f4
	rts		; 0x15fa

computeF128:
	tst.b	(LBL_ffff9939).w	; 0x15fc
	bne.b	return_3	; 0x1600
	moveq	#0, d1	; 0x1602
	move.b	(time).w, d3	; 0x1604
	lea	LBL_025a52, a0	; 0x1608
	move.w	(60, a6), d0	; 0x160e
	bmi.b	@process	; 0x1612
	cmpi.w	#$00b1, d0	; 0x1614
	bcs.b	@get_ref_value	; 0x1618
	move.w	#$00b0, d0	; 0x161a
@get_ref_value:
	lsr.w	#4, d0	; 0x161e
	move.b	(0, a0, d0), d1	; 0x1620
@process:
	moveq	#0, d2	; 0x1624
	cmpi.b	#$20, d3	; 0x1626
	bcs.b	@done	; 0x162a
	moveq	#1, d2	; 0x162c
	cmpi.b	#$40, d3	; 0x162e
	bcs.b	@done	; 0x1632
	moveq	#2, d2	; 0x1634
	cmpi.b	#$60, d3	; 0x1636
	bcs.b	@done	; 0x163a
	moveq	#3, d2	; 0x163c
@done:
	cmp.w	d2, d1	; 0x163e
	bcs.b	@return	; 0x1640
	move.w	d2, d1	; 0x1642
@return:
	move.w	d1, (296, a6)	; 0x1644
	rts		; 0x1648
	include	"projection.asm"	; 0x-1

vs_mode:
	lea	($1fb8, pc), a0	; 0x1e9c
	moveq	#0, d0	; 0x1ea0
	move.b	(fighter1AttackLevel).w, d0	; 0x1ea2
	lsl.w	#4, d0	; 0x1ea6
	move.b	(0, a0, d0), d0	; 0x1ea8
	lsr.b	#4, d0	; 0x1eac
	andi.w	#$000f, d0	; 0x1eae
	move.w	d0, (LBL_ffff97f0).w	; 0x1eb2
	moveq	#0, d0	; 0x1eb6
	move.b	(fighter2AttackLevel).w, d0	; 0x1eb8
	lsl.w	#4, d0	; 0x1ebc
	move.b	(0, a0, d0), d0	; 0x1ebe
	lsr.w	#4, d0	; 0x1ec2
	andi.w	#$000f, d0	; 0x1ec4
	move.w	d0, (LBL_ffff97f2).w	; 0x1ec8
	rts		; 0x1ecc

ff996e_set:
	moveq	#0, d0	; 0x1ece
	move.b	(LBL_ffff9971).w, d0	; 0x1ed0
	add.w	d0, d0	; 0x1ed4
	tst.b	(LBL_ffff8288).w	; 0x1ed6
	beq.b	@loc_00001EDE	; 0x1eda
	addq.w	#1, d0	; 0x1edc
@loc_00001EDE:
	lea	(LBL_ffff997a).w, a0	; 0x1ede
	move.b	(0, a0, d0), d0	; 0x1ee2
	andi.w	#7, d0	; 0x1ee6
	lea	(LBL_ffff9982).w, a0	; 0x1eea
	move.b	(0, a0, d0), d0	; 0x1eee
	andi.w	#7, d0	; 0x1ef2
	lsl.w	#4, d0	; 0x1ef6
	lea	($1fb8, pc), a0	; 0x1ef8
	move.b	(0, a0, d0), d0	; 0x1efc
	andi.w	#$00ff, d0	; 0x1f00
	move.w	d0, (LBL_ffff97f4).w	; 0x1f04
	move.w	d0, (LBL_ffff97f6).w	; 0x1f08
	lsr.w	#4, d0	; 0x1f0c
	move.w	d0, (LBL_ffff97f0).w	; 0x1f0e
	rts		; 0x1f12

ff99dc_or_ff996f:
	move.w	#$00ff, d0	; 0x1f14
	move.w	d0, (LBL_ffff97f4).w	; 0x1f18
	move.w	d0, (LBL_ffff97f6).w	; 0x1f1c
	lsr.w	#4, d0	; 0x1f20
	move.w	d0, (LBL_ffff97f0).w	; 0x1f22
	rts		; 0x1f26

fixFF97F8:
	move.b	(LBL_ffff99dc).w, d0	; 0x1f28
	or.b	(LBL_ffff996f).w, d0	; 0x1f2c
	bne.b	ff99dc_or_ff996f	; 0x1f30
	tst.b	(LBL_ffff9938).w	; 0x1f32
	bne.w	vs_mode	; 0x1f36
	tst.b	(LBL_ffff996e).w	; 0x1f3a
	bne.b	ff996e_set	; 0x1f3e
	tst.b	(areWeOnTitleScreenOrDemoMode).w	; 0x1f40
	beq.b	@normal_mode	; 0x1f44
	moveq	#$000f, d0	; 0x1f46
	move.w	d0, (LBL_ffff808e).w	; 0x1f48
	tst.b	(LBL_ffff9933).w	; 0x1f4c
	bne.b	@loc_00001F54	; 0x1f50
	moveq	#8, d0	; 0x1f52
@loc_00001F54:
	move.w	d0, (player_1_).w	; 0x1f54
	rts		; 0x1f58
@normal_mode:
	moveq	#0, d1	; 0x1f5a
	move.w	(copyOfDifficulty).w, d0	; 0x1f5c
	move.b	(something_min_values, pc, d0.w), d1	; 0x1f60
	move.w	d1, (LBL_ffff97f4).w	; 0x1f64
	lsl.w	#4, d0	; 0x1f68
	add.w	(LBL_ffff9800).w, d0	; 0x1f6a
	move.b	(something_max_values, pc, d0.w), d1	; 0x1f6e
	move.w	d1, (LBL_ffff97f6).w	; 0x1f72
	move.w	(LBL_ffff97f8).w, d0	; 0x1f76
	cmpi.w	#$0100, d0	; 0x1f7a
	bcs.b	@no_overflow	; 0x1f7e
	move.w	#$00ff, d0	; 0x1f80
	move.w	d0, (LBL_ffff97f8).w	; 0x1f84
@no_overflow:
	move.w	(LBL_ffff97f4).w, d1	; 0x1f88
	cmp.w	d1, d0	; 0x1f8c
	bcc.b	@clamp_min	; 0x1f8e
	move.w	d1, d0	; 0x1f90
@clamp_min:
	move.w	(LBL_ffff97f6).w, d1	; 0x1f92
	cmp.w	d1, d0	; 0x1f96
	bcs.b	@clamp_max	; 0x1f98
	move.w	d1, d0	; 0x1f9a
@clamp_max:
	move.w	d0, (LBL_ffff97f8).w	; 0x1f9c
	lsr.w	#4, d0	; 0x1fa0
	move.w	d0, (LBL_ffff97f0).w	; 0x1fa2
	rts		; 0x1fa6

something_min_values:
	dc.b	$18, $28, $38, $48, $78, $88, $a8, $ff	; 0x1fa8

something_max_values:
	dc.b	$18, $18, $18, $20, $20, $20, $20, $28	; 0x1fb0

something_vs_values:
	dc.b	$28, $28, $28, $38, $38, $38, $38, $38, $28, $28, $38, $38, $38, $38, $40, $40, $48, $48, $58, $58, $58, $68, $68, $68, $38, $38, $38, $48, $48, $48, $58, $58, $58, $68, $68, $68, $78, $78, $78, $88, $48, $48, $58, $5c, $67, $74, $88, $88, $98, $98, $98, $98, $98, $98, $98, $98, $78, $7f, $84, $88, $8f, $9f, $af, $b6, $b6, $b6, $b6, $b6, $b6, $b6, $b6, $b6, $88, $88, $8c, $98, $ac, $bf, $cc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $a8, $b8, $c0, $c8, $d0, $d8, $e8, $f0, $f0, $f0, $f0, $f0, $f0, $f0, $f0, $f0, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	; 0x1fb8

FUN_00002030:
	cmpi.b	#3, (flagActivePlayers).w	; 0x2030
	beq.b	return207C	; 0x2036
	tst.b	(areWeOnBonusStage).w	; 0x2038
	bne.b	return207C	; 0x203c
	addq.w	#1, (TIMER_ffff97fa).w	; 0x203e
	cmpi.w	#$00f0, (TIMER_ffff97fa).w	; 0x2042
	bcs.b	@timer_over	; 0x2048
	clr.w	(TIMER_ffff97fa).w	; 0x204a
	addq.w	#3, (LBL_ffff97f8).w	; 0x204e
	bsr.w	fixFF97F8	; 0x2052
@timer_over:
	lea	(fighter1Data).w, a0	; 0x2056
	tst.b	(LBL_ffff8288).w	; 0x205a
	bne.b	@human	; 0x205e
	lea	(player_1_).w, a0	; 0x2060
@human:
	moveq	#0, d0	; 0x2064
	move.b	(657, a0), d0	; 0x2066
	not.b	d0	; 0x206a
	and.b	(655, a0), d0	; 0x206c
	andi.b	#$77, d0	; 0x2070
	beq.b	return207C	; 0x2074
	addq.w	#1, (LBL_ffff987e).w	; 0x2076
	bcc.b	return207C	; 0x207a
	move.w	#$ffff, (LBL_ffff987e).w	; 0x207c

return207C:
	rts		; 0x2082

FUN_00002084:
	cmpi.b	#3, (flagActivePlayers).w	; 0x2084
	beq.b	return207C	; 0x208a
	tst.b	(areWeOnBonusStage).w	; 0x208c
	bne.b	return207C	; 0x2090
	moveq	#0, d0	; 0x2092
	move.w	(LBL_ffff987e).w, d1	; 0x2094
	cmpi.w	#$001f, d1	; 0x2098
	bcs.b	@loc_000020B8	; 0x209c
	moveq	#1, d0	; 0x209e
	cmpi.w	#$0029, d1	; 0x20a0
	bcs.b	@loc_000020B8	; 0x20a4
	moveq	#2, d0	; 0x20a6
	cmpi.w	#$0033, d1	; 0x20a8
	bcs.b	@loc_000020B8	; 0x20ac
	moveq	#3, d0	; 0x20ae
	cmpi.w	#$003c, d1	; 0x20b0
	bcs.b	@loc_000020B8	; 0x20b4
	moveq	#4, d0	; 0x20b6
@loc_000020B8:
	add.w	d0, (LBL_ffff97f8).w	; 0x20b8
	bra.w	fixFF97F8	; 0x20bc

FUN_000020c0:
	bchg	#1, (LBL_ffff97fe).w	; 0x20c0
	bne.b	return207C	; 0x20c6

FUN_000020c8:
	move.w	(LBL_ffff97fc).w, d0	; 0x20c8
	cmpi.w	#$0010, d0	; 0x20cc
	bcs.b	@loc_000020D4	; 0x20d0
	moveq	#$0010, d0	; 0x20d2
@loc_000020D4:
	move.b	(8426, pc, d0.w), d0	; 0x20d4
	sub.w	d0, (LBL_ffff97f8).w	; 0x20d8
	bpl.b	@loc_000020E2	; 0x20dc
	clr.w	(LBL_ffff97f8).w	; 0x20de
@loc_000020E2:
	addq.w	#1, (LBL_ffff97fc).w	; 0x20e2
	bra.w	fixFF97F8	; 0x20e6
	dc.b	$18, $20, $28, $30, $38, $3c, $40, $44, $48, $4c, $50, $54, $58, $5c, $60, $63	; 0x20ea

FUN_000020fa:
	cmpi.b	#3, (flagActivePlayers).w	; 0x20fa
	beq.b	@loc_00002130	; 0x2100
	tst.b	(areWeOnBonusStage).w	; 0x2102
	bne.b	@loc_00002130	; 0x2106
	moveq	#0, d1	; 0x2108
	move.b	(time).w, d1	; 0x210a
	lsr.w	#4, d1	; 0x210e
	moveq	#0, d0	; 0x2110
	tst.b	(LBL_ffff985e).w	; 0x2112
	bne.b	@loc_00002124	; 0x2116
	move.b	(8498, pc, d1.w), d0	; 0x2118
	add.w	d0, (LBL_ffff97f8).w	; 0x211c
	bra.w	fixFF97F8	; 0x2120
@loc_00002124:
	move.b	(8508, pc, d1.w), d0	; 0x2124
	sub.w	d0, (LBL_ffff97f8).w	; 0x2128
	bra.w	fixFF97F8	; 0x212c
@loc_00002130:
	rts		; 0x2130
	dc.b	$03, $03, $01, $01, $00, $00, $01, $01, $03, $03	; 0x2132
	dc.b	$00, $00, $04, $04, $06, $06, $09, $09, $0f, $0f	; 0x213c

fight_over_1:
	moveq	#0, d0	; 0x2146
	move.b	(LBL_ffff9865).w, d0	; 0x2148
	cmpi.b	#9, d0	; 0x214c
	bcc.b	@loc_00002158	; 0x2150
	addq.b	#1, (LBL_ffff9865).w	; 0x2152
	bra.b	@loc_0000215A	; 0x2156
@loc_00002158:
	moveq	#9, d0	; 0x2158
@loc_0000215A:
	move.b	(8550, pc, d0.w), d0	; 0x215a
	add.w	d0, (LBL_ffff97f8).w	; 0x215e
	bra.w	fixFF97F8	; 0x2162
	dc.b	$00, $02, $08, $10, $14, $18, $20, $28, $30, $3b	; 0x2166

fixFF97F8Alt:
	addq.w	#2, (LBL_ffff97f8).w	; 0x2170
	bra.w	fixFF97F8	; 0x2174

FUN_00002178:
	cmpi.b	#3, (flagActivePlayers).w	; 0x2178
	beq.b	return101	; 0x217e
	tst.b	(areWeOnBonusStage).w	; 0x2180
	bne.b	return101	; 0x2184
	tst.b	(isFightOver).w	; 0x2186
	bmi.b	fight_over_1	; 0x218a
	move.w	(LBL_ffff803c).w, d0	; 0x218c
	move.b	(isFightOver).w, d1	; 0x2190
	subq.b	#1, d1	; 0x2194
	beq.b	@fight_over_2	; 0x2196
	move.w	(player_1_).w, d0	; 0x2198
@fight_over_2:
	moveq	#0, d2	; 0x219c
	cmpi.w	#$0071, d0	; 0x219e
	bcc.b	@proceed	; 0x21a2
	moveq	#1, d2	; 0x21a4
	cmpi.w	#$0051, d0	; 0x21a6
	bcc.b	@proceed	; 0x21aa
	moveq	#2, d2	; 0x21ac
	cmpi.w	#$0031, d0	; 0x21ae
	bcc.b	@proceed	; 0x21b2
	moveq	#3, d2	; 0x21b4
	cmpi.w	#$0011, d0	; 0x21b6
	bcc.b	@proceed	; 0x21ba
	moveq	#4, d2	; 0x21bc
@proceed:
	cmp.b	(LBL_ffff981b).w, d1	; 0x21be
	bne.b	@ff981b_set	; 0x21c2
	move.b	(positive_modifier, pc, d2.w), d2	; 0x21c4
	add.w	d2, (LBL_ffff97f8).w	; 0x21c8
	bra.w	fixFF97F8	; 0x21cc
@ff981b_set:
	move.b	(negative_modifier, pc, d2.w), d2	; 0x21d0
	sub.w	d2, (LBL_ffff97f8).w	; 0x21d4
	bra.w	fixFF97F8	; 0x21d8

return101:
	rts		; 0x21dc

positive_modifier:
	dc.b	$04, $03, $01, $01, $03, $38	; 0x21de

negative_modifier:
	dc.b	$0c, $09, $03, $03, $06, $7a	; 0x21e4

FUN_000021ea:
	cmpi.b	#3, (flagActivePlayers).w	; 0x21ea
	beq.b	return101	; 0x21f0
	tst.b	(areWeOnBonusStage).w	; 0x21f2
	bne.b	return101	; 0x21f6
	addq.w	#1, (LBL_ffff97f8).w	; 0x21f8
	bra.w	fixFF97F8	; 0x21fc

FUN_00002200:
	cmpi.b	#3, (flagActivePlayers).w	; 0x2200
	beq.b	FUN_00002230	; 0x2206
	tst.b	(areWeOnBonusStage).w	; 0x2208
	bne.b	FUN_00002230	; 0x220c
	move.w	(LBL_ffff9880).w, d0	; 0x220e
	cmpi.w	#9, d0	; 0x2212
	bcs.b	@loc_0000221A	; 0x2216
	moveq	#9, d0	; 0x2218
@loc_0000221A:
	move.b	(8742, pc, d0.w), d0	; 0x221a
	add.w	d0, (LBL_ffff97f8).w	; 0x221e
	bra.w	fixFF97F8	; 0x2222
	dc.b	$00, $02, $04, $08, $0c, $10, $14, $18, $1c, $20	; 0x2226

FUN_00002230:
	rts		; 0x2230

FUN_00002232:
	cmpi.b	#3, (flagActivePlayers).w	; 0x2232
	beq.b	FUN_00002230	; 0x2238
	tst.b	(areWeOnBonusStage).w	; 0x223a
	bne.b	FUN_00002230	; 0x223e
	jsr	(random).w	; 0x2240
	andi.w	#$001f, d0	; 0x2244
	move.b	(8788, pc, d0.w), d0	; 0x2248
	sub.w	d0, (LBL_ffff97f8).w	; 0x224c
	bra.w	fixFF97F8	; 0x2250
	dc.b	$0a, $20, $02, $00, $0a, $08, $10, $08, $14, $08, $10, $0a, $10, $0a, $14, $10, $02, $10, $0a, $08, $0a, $20, $0a, $02, $00, $0a, $08, $14, $08, $0a, $10, $0a	; 0x2254
	cmpi.b	#3, (flagActivePlayers).w	; 0x2274
	beq.b	FUN_00002230	; 0x227a
	addq.w	#8, (LBL_ffff97f8).w	; 0x227c
	bra.w	fixFF97F8	; 0x2280

doWeDisplayFrame:
	moveq	#0, d0	; 0x2284
	move.l	d0, d1	; 0x2286
	tst.b	(displayCurrentFrameFlag).w	; 0x2288
	bne.b	@display	; 0x228c
	move.b	(copyOfGameSpeed).w, d0	; 0x228e
	move.w	(displayedFramesFlags, pc, d0.w), d0	; 0x2292
	move.b	(frameCounter).w, d1	; 0x2296
	btst	d1, d0	; 0x229a
	beq.b	@dont_set_display_flag	; 0x229c
	addq.b	#1, (displayCurrentFrameFlag).w	; 0x229e
@dont_set_display_flag:
	addq.b	#1, d1	; 0x22a2
	cmpi.w	#$000a, d1	; 0x22a4
	bcs.b	@dont_reset_counter	; 0x22a8
	moveq	#0, d1	; 0x22aa
@dont_reset_counter:
	move.b	d1, (frameCounter).w	; 0x22ac
	rts		; 0x22b0
@display:
	move.b	d0, (displayCurrentFrameFlag).w	; 0x22b2
	addq.b	#1, (displayedFramesCounter).w	; 0x22b6
	rts		; 0x22ba

displayedFramesFlags:
	dc.w	$0000, $0001, $0021, $0091, $00a5, $01a5, $02b5, $01dd, $01ef, $03ef, $03ff	; 0x22bc

updateFightersKeys:
	lea	(fighter1Data).w, a1	; 0x22d2
	lea	(player_1_).w, a2	; 0x22d6
	lea	(joy1State).w, a3	; 0x22da
	lea	(LBL_fffffd0c).w, a0	; 0x22de
	bsr.b	updateFighterKeys	; 0x22e2
	exg	a2, a1	; 0x22e4
	lea	(joy2State).w, a3	; 0x22e6
	lea	(LBL_fffffd16).w, a0	; 0x22ea

updateFighterKeys:
	move.w	(654, a1), (656, a1)	; 0x22ee
	move.w	(658, a1), (660, a1)	; 0x22f4
	move.b	(3, a3), d0	; 0x22fa
	move.b	d0, d1	; 0x22fe
	andi.b	#$0f, d0	; 0x2300
	move.b	d0, (655, a1)	; 0x2304
	andi.b	#3, d0	; 0x2308
	move.b	d0, (659, a1)	; 0x230c
	andi.b	#$0c, d1	; 0x2310
	tst.b	(areWeOnBonusStage).w	; 0x2314
	bne.b	@on_bonus_stage	; 0x2318
	move.w	(6, a2), d2	; 0x231a
	cmp.w	(6, a1), d2	; 0x231e
	beq.b	@not_flipped	; 0x2322
	bcs.b	@not_flipped	; 0x2324
	bra.b	@fighter_1_left	; 0x2326
@on_bonus_stage:
	tst.b	(25, a1)	; 0x2328
	beq.b	@not_flipped	; 0x232c
@fighter_1_left:
	lsr.b	#3, d1	; 0x232e
	bcs.b	@flipped	; 0x2330
	lsl.b	#2, d1	; 0x2332
	bra.b	@not_flipped	; 0x2334
@flipped:
	ori.b	#8, d1	; 0x2336
@not_flipped:
	or.b	d1, (659, a1)	; 0x233a
	move.w	(2, a3), d0	; 0x233e
	moveq	#0, d1	; 0x2342
	moveq	#0, d2	; 0x2344
	cmpi.b	#1, (1, a3)	; 0x2346
	beq.b	@pad_6_buttons	; 0x234c
	lea	(4, a0), a0	; 0x234e
	move.b	-(a0), d2	; 0x2352
	move.w	(4, a3), d3	; 0x2354
	btst	d2, d3	; 0x2358
	beq.b	@not_start	; 0x235a
	eori.b	#$ff, (392, a1)	; 0x235c
@not_start:
	bsr.b	reassignPowerKeys	; 0x2362
	tst.b	(392, a1)	; 0x2364
	beq.b	@kicks	; 0x2368
	lsl.b	#4, d1	; 0x236a
@kicks:
	move.b	d1, (654, a1)	; 0x236c
	move.b	d1, (658, a1)	; 0x2370
	rts		; 0x2374
@pad_6_buttons:
	bsr.b	reassignPowerKeys	; 0x2376
	add.b	d1, d1	; 0x2378
	bsr.b	reassignPowerKeys	; 0x237a
	move.b	d1, (654, a1)	; 0x237c
	move.b	d1, (658, a1)	; 0x2380
	rts		; 0x2384

reassignPowerKeys:
	moveq	#2, d3	; 0x2386
@next:
	add.w	d1, d1	; 0x2388
	move.b	-(a0), d2	; 0x238a
	btst	d2, d0	; 0x238c
	beq.b	@continue	; 0x238e
	ori.b	#1, d1	; 0x2390
@continue:
	dbf	d3, @next	; 0x2394
	rts		; 0x2398

computeHScrollOffsets:
	lea	dataBuffer, a0	; 0x239a
	move.l	#$ffb48600, d0	; 0x23a0
	move.l	#$00011820, d1	; 0x23a6
	move.w	#$00c0, d7	; 0x23ac
@next2:
	move.l	d0, d2	; 0x23b0
	move.w	#$003f, d6	; 0x23b2
@next1:
	swap	d2	; 0x23b6
	move.w	d2, (a0)+	; 0x23b8
	swap	d2	; 0x23ba
	add.l	d1, d2	; 0x23bc
	dbf	d6, @next1	; 0x23be
	subi.l	#$00008c10, d0	; 0x23c2
	subi.l	#$000002eb, d1	; 0x23c8
	dbf	d7, @next2	; 0x23ce
	rts		; 0x23d2

initStageSpecific:
	move.w	(stageId).w, d0	; 0x23d4
	add.w	d0, d0	; 0x23d8
	move.w	(initStageFunsOffsets, pc, d0.w), d0	; 0x23da
	jmp	(initStageFunsOffsets, pc, d0.w)	; 0x23de

initStageFunsOffsets:
	dc.w	initRyuGuileKenSagatBoxerClawCammyTHawkDeejayFeilongStage-initStageFunsOffsets	; 0x23e2
	dc.w	initEHondaBlankaChunLiZangiefDhalsimStage-initStageFunsOffsets	; 0x23e4
	dc.w	initEHondaBlankaChunLiZangiefDhalsimStage-initStageFunsOffsets	; 0x23e6
	dc.w	initRyuGuileKenSagatBoxerClawCammyTHawkDeejayFeilongStage-initStageFunsOffsets	; 0x23e8
	dc.w	initRyuGuileKenSagatBoxerClawCammyTHawkDeejayFeilongStage-initStageFunsOffsets	; 0x23ea
	dc.w	initEHondaBlankaChunLiZangiefDhalsimStage-initStageFunsOffsets	; 0x23ec
	dc.w	initEHondaBlankaChunLiZangiefDhalsimStage-initStageFunsOffsets	; 0x23ee
	dc.w	initEHondaBlankaChunLiZangiefDhalsimStage-initStageFunsOffsets	; 0x23f0
	dc.w	initDictatorStage-initStageFunsOffsets	; 0x23f2
	dc.w	initRyuGuileKenSagatBoxerClawCammyTHawkDeejayFeilongStage-initStageFunsOffsets	; 0x23f4
	dc.w	initRyuGuileKenSagatBoxerClawCammyTHawkDeejayFeilongStage-initStageFunsOffsets	; 0x23f6
	dc.w	initRyuGuileKenSagatBoxerClawCammyTHawkDeejayFeilongStage-initStageFunsOffsets	; 0x23f8
	dc.w	initRyuGuileKenSagatBoxerClawCammyTHawkDeejayFeilongStage-initStageFunsOffsets	; 0x23fa
	dc.w	initRyuGuileKenSagatBoxerClawCammyTHawkDeejayFeilongStage-initStageFunsOffsets	; 0x23fc
	dc.w	initRyuGuileKenSagatBoxerClawCammyTHawkDeejayFeilongStage-initStageFunsOffsets	; 0x23fe
	dc.w	initRyuGuileKenSagatBoxerClawCammyTHawkDeejayFeilongStage-initStageFunsOffsets	; 0x2400
	dc.w	initBonus1Bonus3Stage-initStageFunsOffsets	; 0x2402
	dc.w	initBonus2Stage-initStageFunsOffsets	; 0x2404
	dc.w	initBonus1Bonus3Stage-initStageFunsOffsets	; 0x2406

initEHondaBlankaChunLiZangiefDhalsimStage:
	move.w	#2, (hintInitFun).w	; 0x2408
	move.w	#$9205, (windowVPosSetter2).w	; 0x240e
	move.w	#$929b, (windowVPosSetter3).w	; 0x2414
	move.w	#$8ad7, d5	; 0x241a
	move.w	d5, (VdpRegistersCache).w	; 0x241e
	move.w	d5, (4, a5)	; 0x2422
	ori.b	#3, (VdpRegistersCache).w	; 0x2426
	move.w	(VdpRegistersCache).w, (4, a5)	; 0x242c
	rts		; 0x2432

initDictatorStage:
	move.w	#2, (hintInitFun).w	; 0x2434
	move.w	#$9205, (windowVPosSetter2).w	; 0x243a
	move.w	#$929b, (windowVPosSetter3).w	; 0x2440
	move.w	#$8a9f, d5	; 0x2446
	move.w	d5, (VdpRegistersCache).w	; 0x244a
	move.w	d5, (4, a5)	; 0x244e
	ori.b	#3, (VdpRegistersCache).w	; 0x2452
	move.w	(VdpRegistersCache).w, (4, a5)	; 0x2458
	rts		; 0x245e

initRyuGuileKenSagatBoxerClawCammyTHawkDeejayFeilongStage:
	move.w	#4, (hintInitFun).w	; 0x2460
	move.w	#$8aff, d0	; 0x2466
	move.w	d0, (hintCounterSetter3).w	; 0x246a
	move.w	d0, (hintCounterSetter4).w	; 0x246e
	move.w	d0, (hintCounterSetter5).w	; 0x2472
	move.w	d0, (hintCounterSetter6).w	; 0x2476
	move.w	#$9205, (windowVPosSetter2).w	; 0x247a
	move.w	#$929b, (windowVPosSetter3).w	; 0x2480
	ori.b	#3, (VdpRegistersCache).w	; 0x2486
	move.w	(VdpRegistersCache).w, (4, a5)	; 0x248c
	rts		; 0x2492

initBonus1Bonus3Stage:
	move.w	#6, (hintInitFun).w	; 0x2494
	clr.l	(hScrollCacheA).w	; 0x249a
	move.w	#$9205, (windowVPosSetter2).w	; 0x249e
	move.w	#$929b, (windowVPosSetter3).w	; 0x24a4
	move.w	#$8ad7, d5	; 0x24aa
	move.w	d5, (VdpRegistersCache).w	; 0x24ae
	move.w	d5, (4, a5)	; 0x24b2
	rts		; 0x24b6

initBonus2Stage:
	move.w	#6, (hintInitFun).w	; 0x24b8
	move.l	#$00000100, (hScrollCacheA).w	; 0x24be
	move.w	#$9205, (windowVPosSetter2).w	; 0x24c6
	move.w	#$929b, (windowVPosSetter3).w	; 0x24cc
	move.w	#$8ad7, d5	; 0x24d2
	move.w	d5, (VdpRegistersCache).w	; 0x24d6
	move.w	d5, (4, a5)	; 0x24da
	rts		; 0x24de

updateStageScroll:
	move.l	(ptrToHScrollOffsets).w, a0	; 0x24e0
	lea	(hScrollCache).w, a2	; 0x24e4
	move.w	(stageId).w, d0	; 0x24e8
	add.w	d0, d0	; 0x24ec
	move.w	(updateStageScrollsFunsOffsets, pc, d0.w), d0	; 0x24ee
	jmp	(updateStageScrollsFunsOffsets, pc, d0.w)	; 0x24f2

updateStageScrollsFunsOffsets:
	dc.w	updateRyuStageScroll-updateStageScrollsFunsOffsets	; 0x24f6
	dc.w	updateEHondaStageScroll-updateStageScrollsFunsOffsets	; 0x24f8
	dc.w	updateBlankaStageScroll-updateStageScrollsFunsOffsets	; 0x24fa
	dc.w	updateGuileStageScroll-updateStageScrollsFunsOffsets	; 0x24fc
	dc.w	updateKenStageScroll-updateStageScrollsFunsOffsets	; 0x24fe
	dc.w	updateChunLiStageScroll-updateStageScrollsFunsOffsets	; 0x2500
	dc.w	updateZangiefStageScroll-updateStageScrollsFunsOffsets	; 0x2502
	dc.w	updateDhalsimStageScroll-updateStageScrollsFunsOffsets	; 0x2504
	dc.w	updateDictatorStageScroll-updateStageScrollsFunsOffsets	; 0x2506
	dc.w	updateSagatStageScroll-updateStageScrollsFunsOffsets	; 0x2508
	dc.w	updateBoxerStageScroll-updateStageScrollsFunsOffsets	; 0x250a
	dc.w	updateClawStageScroll-updateStageScrollsFunsOffsets	; 0x250c
	dc.w	updateCammyStageScroll-updateStageScrollsFunsOffsets	; 0x250e
	dc.w	updateTHawkStageScroll-updateStageScrollsFunsOffsets	; 0x2510
	dc.w	updateFeilongScroll-updateStageScrollsFunsOffsets	; 0x2512
	dc.w	updateDeejayStageScroll-updateStageScrollsFunsOffsets	; 0x2514
	dc.w	updateBonusStage1Scroll-updateStageScrollsFunsOffsets	; 0x2516
	dc.w	updateBonusStage2Scroll-updateStageScrollsFunsOffsets	; 0x2518
	dc.w	updateBonusStage3Scroll-updateStageScrollsFunsOffsets	; 0x251a

updateRyuStageScroll:
	move.w	(48, a0), d0	; 0x251c
	move.w	(a0), d1	; 0x2520
	move.w	(cameraY).w, d7	; 0x2522
	addi.w	#$009f, d7	; 0x2526

next10:
	move.w	d0, (a2)+	; 0x252a
	move.w	d1, (a2)+	; 0x252c
	dbf	d7, next10	; 0x252e
	lea	(48, a0), a1	; 0x2532
	move.w	#$001e, d7	; 0x2536

next11:
	move.w	(a1)+, (a2)+	; 0x253a
	move.w	d0, (a2)+	; 0x253c
	dbf	d7, next11	; 0x253e
	move.w	(110, a0), d1	; 0x2542
	move.w	#8, d7	; 0x2546

next12:
	move.w	d1, (a2)+	; 0x254a
	move.w	d0, (a2)+	; 0x254c
	dbf	d7, next12	; 0x254e
	move.w	(cameraY).w, d0	; 0x2552
	neg.w	d0	; 0x2556
	move.w	d0, (planeAVScroll).w	; 0x2558
	move.w	d0, (planeAVScrollAlt).w	; 0x255c
	addi.w	#$0100, d0	; 0x2560
	move.w	d0, (planeBVScrollAlt).w	; 0x2564
	move.l	(cameraY).w, d0	; 0x2568
	asr.l	#1, d0	; 0x256c
	move.l	d0, d1	; 0x256e
	asr.l	#1, d0	; 0x2570
	add.l	d1, d0	; 0x2572
	swap	d0	; 0x2574
	neg.w	d0	; 0x2576
	addi.w	#$0100, d0	; 0x2578
	move.w	d0, (planeBVScroll).w	; 0x257c
	move.w	(cameraY).w, d0	; 0x2580
	addi.w	#$00af, d0	; 0x2584
	move.b	d0, (someYStagePos).w	; 0x2588
	rts		; 0x258c

updateEHondaStageScroll:
	move.w	(32, a0), d0	; 0x258e
	move.w	(cameraY).w, d1	; 0x2592
	add.w	d1, d1	; 0x2596
	lea	(48, a0, d1), a1	; 0x2598
	move.w	(cameraY).w, d7	; 0x259c
	addi.w	#$000f, d7	; 0x25a0

next20:
	move.w	d0, (a2)+	; 0x25a4
	move.w	-(a1), (a2)+	; 0x25a6
	dbf	d7, next20	; 0x25a8
	move.w	(16, a0), d1	; 0x25ac
	move.w	#$005f, d7	; 0x25b0

next21:
	move.w	d0, (a2)+	; 0x25b4
	move.w	d1, (a2)+	; 0x25b6
	dbf	d7, next21	; 0x25b8
	move.w	#7, d7	; 0x25bc

next22:
	move.w	(a1)+, (a2)+	; 0x25c0
	lea	(2, a1), a1	; 0x25c2
	move.w	d1, (a2)+	; 0x25c6
	dbf	d7, next22	; 0x25c8
	move.w	(48, a0), d0	; 0x25cc
	move.w	#$0027, d7	; 0x25d0

next23:
	move.w	d0, (a2)+	; 0x25d4
	move.w	d1, (a2)+	; 0x25d6
	dbf	d7, next23	; 0x25d8
	lea	(48, a0), a1	; 0x25dc
	move.w	#$0027, d7	; 0x25e0

next24:
	move.w	d1, (a2)+	; 0x25e4
	move.w	(a1)+, (a2)+	; 0x25e6
	dbf	d7, next24	; 0x25e8
	move.w	(cameraY).w, d0	; 0x25ec
	neg.w	d0	; 0x25f0
	move.w	d0, (vsRamCache1).w	; 0x25f2
	addi.w	#$0100, d0	; 0x25f6
	move.w	d0, (LBL_ffff9b8c).w	; 0x25fa
	rts		; 0x25fe

updateBlankaStageScroll:
	move.w	(48, a0), d0	; 0x2600
	move.w	(16, a0), d1	; 0x2604
	move.w	(cameraY).w, d7	; 0x2608
	addi.w	#$009f, d7	; 0x260c

next30:
	move.w	d0, (a2)+	; 0x2610
	move.w	d1, (a2)+	; 0x2612
	dbf	d7, next30	; 0x2614
	lea	(48, a0), a1	; 0x2618
	move.w	#$000f, d7	; 0x261c

next31:
	move.w	d0, (a2)+	; 0x2620
	move.w	(a1)+, (a2)+	; 0x2622
	dbf	d7, next31	; 0x2624
	move.w	(126, a0), d0	; 0x2628
	move.w	#$0017, d7	; 0x262c

next32:
	move.w	d0, (a2)+	; 0x2630
	move.w	(a1)+, (a2)+	; 0x2632
	dbf	d7, next32	; 0x2634
	move.w	(cameraY).w, d0	; 0x2638
	neg.w	d0	; 0x263c
	move.w	d0, (vsRamCache1).w	; 0x263e
	addi.w	#$0100, d0	; 0x2642
	move.w	d0, (LBL_ffff9b8c).w	; 0x2646
	rts		; 0x264a

updateGuileStageScroll:
	move.w	(32, a0), d0	; 0x264c
	move.w	(a0), d1	; 0x2650
	move.w	(cameraY).w, d7	; 0x2652
	addi.w	#$0037, d7	; 0x2656

next40:
	move.w	d0, (a2)+	; 0x265a
	move.w	d1, (a2)+	; 0x265c
	dbf	d7, next40	; 0x265e
	move.w	(76, a0), d1	; 0x2662
	move.w	#$0067, d7	; 0x2666

next41:
	move.w	d1, (a2)+	; 0x266a
	move.w	d0, (a2)+	; 0x266c
	dbf	d7, next41	; 0x266e
	lea	(48, a0), a1	; 0x2672
	move.w	#$0027, d7	; 0x2676

next42:
	move.w	d1, (a2)+	; 0x267a
	move.w	(a1)+, (a2)+	; 0x267c
	dbf	d7, next42	; 0x267e
	move.w	(cameraY).w, d0	; 0x2682
	neg.w	d0	; 0x2686
	move.w	d0, (planeAVScroll).w	; 0x2688
	addi.w	#$0100, d0	; 0x268c
	move.w	d0, (planeBVScroll).w	; 0x2690
	move.w	d0, (planeBVScrollAlt).w	; 0x2694
	addi.w	#$00fc, d0	; 0x2698
	move.w	d0, (planeAVScrollAlt).w	; 0x269c
	move.w	(cameraY).w, d0	; 0x26a0
	addi.w	#$004f, d0	; 0x26a4
	move.b	d0, (someYStagePos).w	; 0x26a8
	rts		; 0x26ac

updateKenStageScroll:
	move.w	(16, a0), d0	; 0x26ae
	move.w	(a0), d1	; 0x26b2
	move.w	(cameraY).w, d7	; 0x26b4
	addi.w	#$008f, d7	; 0x26b8

next50:
	move.w	d0, (a2)+	; 0x26bc
	move.w	d1, (a2)+	; 0x26be
	dbf	d7, next50	; 0x26c0
	move.w	(104, a0), d0	; 0x26c4
	lea	(16, a0), a1	; 0x26c8
	move.w	#$0037, d7	; 0x26cc

next51:
	move.w	d0, (a2)+	; 0x26d0
	move.w	(a1)+, (a2)+	; 0x26d2
	dbf	d7, next51	; 0x26d4
	move.w	(cameraY).w, d0	; 0x26d8
	neg.w	d0	; 0x26dc
	addi.w	#$0100, d0	; 0x26de
	move.w	d0, (planeBVScroll).w	; 0x26e2
	move.w	d0, (planeBVScrollAlt).w	; 0x26e6
	addi.w	#$ff04, d0	; 0x26ea
	move.w	d0, (planeAVScrollAlt).w	; 0x26ee
	sub.w	(stagePosY).w, d0	; 0x26f2
	move.w	d0, (planeAVScroll).w	; 0x26f6
	move.w	(cameraY).w, d0	; 0x26fa
	addi.w	#$009f, d0	; 0x26fe
	move.b	d0, (someYStagePos).w	; 0x2702
	rts		; 0x2706

updateChunLiStageScroll:
	move.w	(16, a0), d0	; 0x2708
	swap	d0	; 0x270c
	move.w	(16, a0), d0	; 0x270e
	move.w	(cameraY).w, d7	; 0x2712
	addi.w	#$008f, d7	; 0x2716

next60:
	move.l	d0, (a2)+	; 0x271a
	dbf	d7, next60	; 0x271c
	lea	(16, a0), a1	; 0x2720
	move.w	(112, a0), d1	; 0x2724
	move.w	#$0037, d7	; 0x2728

next61:
	move.w	(a1)+, (a2)+	; 0x272c
	move.w	d1, (a2)+	; 0x272e
	dbf	d7, next61	; 0x2730
	move.w	(cameraY).w, d0	; 0x2734
	neg.w	d0	; 0x2738
	move.w	d0, (vsRamCache1).w	; 0x273a
	addi.w	#$0100, d0	; 0x273e
	move.w	d0, (LBL_ffff9b8c).w	; 0x2742
	rts		; 0x2746

updateZangiefStageScroll:
	move.w	(32, a0), d0	; 0x2748
	move.w	(a0), d1	; 0x274c
	move.w	(cameraY).w, d7	; 0x274e
	addi.w	#$008f, d7	; 0x2752

next70:
	move.w	d0, (a2)+	; 0x2756
	move.w	d1, (a2)+	; 0x2758
	dbf	d7, next70	; 0x275a
	move.w	(126, a0), d1	; 0x275e
	move.w	#7, d7	; 0x2762

next71:
	move.w	d0, (a2)+	; 0x2766
	move.w	d1, (a2)+	; 0x2768
	dbf	d7, next71	; 0x276a
	lea	(32, a0), a1	; 0x276e
	move.w	#$002f, d7	; 0x2772

next72:
	move.w	(a1)+, (a2)+	; 0x2776
	move.w	d1, (a2)+	; 0x2778
	dbf	d7, next72	; 0x277a
	move.w	(cameraY).w, d0	; 0x277e
	neg.w	d0	; 0x2782
	move.w	d0, (vsRamCache1).w	; 0x2784
	addi.w	#$0100, d0	; 0x2788
	move.w	d0, (LBL_ffff9b8c).w	; 0x278c
	rts		; 0x2790

updateDhalsimStageScroll:
	move.w	(80, a0), d0	; 0x2792
	move.w	(20, a0), d1	; 0x2796
	move.w	(cameraY).w, d7	; 0x279a
	addi.w	#$0091, d7	; 0x279e

next81:
	move.w	d0, (a2)+	; 0x27a2
	move.w	d1, (a2)+	; 0x27a4
	dbf	d7, next81	; 0x27a6
	lea	(20, a0), a1	; 0x27aa
	move.w	#$0035, d7	; 0x27ae

next82:
	move.w	d0, (a2)+	; 0x27b2
	move.w	(a1)+, (a2)+	; 0x27b4
	dbf	d7, next82	; 0x27b6
	move.w	(cameraY).w, d0	; 0x27ba
	neg.w	d0	; 0x27be
	move.w	d0, (vsRamCache1).w	; 0x27c0
	addi.w	#$0100, d0	; 0x27c4
	move.w	d0, (LBL_ffff9b8c).w	; 0x27c8
	rts		; 0x27cc

updateDictatorStageScroll:
	move.w	(48, a0), d0	; 0x27ce
	move.w	(cameraY).w, d1	; 0x27d2
	add.w	d1, d1	; 0x27d6
	lea	(56, a0, d1), a1	; 0x27d8
	move.w	(cameraY).w, d7	; 0x27dc
	addi.w	#$000f, d7	; 0x27e0

next90:
	move.w	d0, (a2)+	; 0x27e4
	move.w	-(a1), (a2)+	; 0x27e6
	dbf	d7, next90	; 0x27e8
	move.w	(a0), d1	; 0x27ec
	move.w	#$0077, d7	; 0x27ee

next91:
	move.w	d0, (a2)+	; 0x27f2
	move.w	d1, (a2)+	; 0x27f4
	dbf	d7, next91	; 0x27f6
	lea	(a0), a1	; 0x27fa
	move.w	#$0027, d7	; 0x27fc

next92:
	move.w	d0, (a2)+	; 0x2800
	move.w	(a1)+, (a2)+	; 0x2802
	dbf	d7, next92	; 0x2804
	move.w	(68, a0), d0	; 0x2808
	move.w	#$0017, d7	; 0x280c

next93:
	move.w	d0, (a2)+	; 0x2810
	move.w	(a1)+, (a2)+	; 0x2812
	dbf	d7, next93	; 0x2814
	move.w	(cameraY).w, d0	; 0x2818
	neg.w	d0	; 0x281c
	move.w	d0, (vsRamCache1).w	; 0x281e
	addi.w	#$0100, d0	; 0x2822
	move.w	d0, (LBL_ffff9b8c).w	; 0x2826
	rts		; 0x282a

updateSagatStageScroll:
	move.w	(32, a0), d0	; 0x282c
	move.w	#$ff60, d1	; 0x2830
	move.w	(cameraY).w, d7	; 0x2834
	addi.w	#$007f, d7	; 0x2838

next100:
	move.w	d0, (a2)+	; 0x283c
	move.w	d1, (a2)+	; 0x283e
	dbf	d7, next100	; 0x2840
	move.w	(44, a0), d1	; 0x2844
	move.w	#$0017, d7	; 0x2848

next101:
	move.w	d1, (a2)+	; 0x284c
	move.w	d0, (a2)+	; 0x284e
	dbf	d7, next101	; 0x2850
	lea	(32, a0), a1	; 0x2854
	move.w	#$000f, d7	; 0x2858

next102:
	move.w	d1, (a2)+	; 0x285c
	move.w	(a1)+, (a2)+	; 0x285e
	dbf	d7, next102	; 0x2860
	move.w	(96, a0), d1	; 0x2864
	move.w	#$001f, d7	; 0x2868

next103:
	move.w	d1, (a2)+	; 0x286c
	move.w	(a1)+, (a2)+	; 0x286e
	dbf	d7, next103	; 0x2870
	move.w	(cameraY).w, d0	; 0x2874
	neg.w	d0	; 0x2878
	move.w	d0, (planeAVScroll).w	; 0x287a
	move.w	d0, (planeAVScrollAlt).w	; 0x287e
	addi.w	#$0110, d0	; 0x2882
	move.w	d0, (planeBVScrollAlt).w	; 0x2886
	move.w	(cameraY).w, d0	; 0x288a
	asr.w	#2, d0	; 0x288e
	neg.w	d0	; 0x2890
	addi.w	#$0100, d0	; 0x2892
	move.w	d0, (planeBVScroll).w	; 0x2896
	move.w	(cameraY).w, d0	; 0x289a
	addi.w	#$008f, d0	; 0x289e
	move.b	d0, (someYStagePos).w	; 0x28a2
	rts		; 0x28a6

updateBoxerStageScroll:
	move.w	(24, a0), d0	; 0x28a8
	move.w	(a0), d1	; 0x28ac
	move.w	(cameraY).w, d7	; 0x28ae
	addi.w	#$0047, d7	; 0x28b2

next110:
	move.w	d0, (a2)+	; 0x28b6
	move.w	d1, (a2)+	; 0x28b8
	dbf	d7, next110	; 0x28ba
	move.w	(48, a0), d1	; 0x28be
	move.w	#$0057, d7	; 0x28c2

next111:
	move.w	d1, (a2)+	; 0x28c6
	move.w	d0, (a2)+	; 0x28c8
	dbf	d7, next111	; 0x28ca
	lea	(48, a0), a1	; 0x28ce
	move.w	#$0027, d7	; 0x28d2

next112:
	move.w	d1, (a2)+	; 0x28d6
	move.w	(a1)+, (a2)+	; 0x28d8
	dbf	d7, next112	; 0x28da
	move.w	(cameraY).w, d0	; 0x28de
	neg.w	d0	; 0x28e2
	move.w	d0, (planeAVScroll).w	; 0x28e4
	move.w	d0, (planeAVScrollAlt).w	; 0x28e8
	addi.w	#$0100, d0	; 0x28ec
	move.w	d0, (planeBVScrollAlt).w	; 0x28f0
	move.l	(cameraY).w, d0	; 0x28f4
	asr.l	#1, d0	; 0x28f8
	move.l	d0, d1	; 0x28fa
	asr.l	#1, d0	; 0x28fc
	add.l	d1, d0	; 0x28fe
	swap	d0	; 0x2900
	neg.w	d0	; 0x2902
	addi.w	#$00f8, d0	; 0x2904
	move.w	d0, (planeBVScroll).w	; 0x2908
	move.w	(cameraY).w, d0	; 0x290c
	addi.w	#$0057, d0	; 0x2910
	move.b	d0, (someYStagePos).w	; 0x2914
	rts		; 0x2918

updateClawStageScroll:
	move.w	(72, a0), d0	; 0x291a
	move.w	(32, a0), d1	; 0x291e
	move.w	(cameraY).w, d7	; 0x2922
	addi.w	#$006f, d7	; 0x2926

next120:
	move.w	d0, (a2)+	; 0x292a
	move.w	d1, (a2)+	; 0x292c
	dbf	d7, next120	; 0x292e
	move.w	(64, a0), d1	; 0x2932
	move.w	#$0037, d7	; 0x2936

next121:
	move.w	d0, (a2)+	; 0x293a
	move.w	d1, (a2)+	; 0x293c
	dbf	d7, next121	; 0x293e
	lea	(64, a0), a1	; 0x2942
	move.w	#$001f, d7	; 0x2946

next122:
	move.w	d0, (a2)+	; 0x294a
	move.w	(a1)+, (a2)+	; 0x294c
	dbf	d7, next122	; 0x294e
	move.w	(cameraY).w, d0	; 0x2952
	neg.w	d0	; 0x2956
	move.w	d0, (vsRamCache1).w	; 0x2958
	addi.w	#$0100, d0	; 0x295c
	move.w	d0, (LBL_ffff9b8c).w	; 0x2960
	rts		; 0x2964

updateCammyStageScroll:
	move.w	(16, a0), d0	; 0x2966
	move.w	#$ff80, d1	; 0x296a
	move.w	#7, d7	; 0x296e

next130:
	move.w	d0, (a2)+	; 0x2972
	move.w	d1, (a2)+	; 0x2974
	dbf	d7, next130	; 0x2976
	lea	($2a60, pc), a3	; 0x297a
	adda.w	(posInBorealAuroraOffsetsList).w, a3	; 0x297e
	move.l	a3, a1	; 0x2982
	move.w	#$0017, d7	; 0x2984

next131:
	move.w	d0, (a2)+	; 0x2988
	move.w	(a1)+, (a2)+	; 0x298a
	dbf	d7, next131	; 0x298c
	move.l	a3, a1	; 0x2990
	move.w	#$0017, d7	; 0x2992

next132:
	move.w	d0, (a2)+	; 0x2996
	move.w	(a1)+, (a2)+	; 0x2998
	dbf	d7, next132	; 0x299a
	move.l	a3, a1	; 0x299e
	move.w	#$000f, d7	; 0x29a0

next133:
	move.w	d0, (a2)+	; 0x29a4
	move.w	(a1)+, (a2)+	; 0x29a6
	dbf	d7, next133	; 0x29a8
	move.w	#$0080, d1	; 0x29ac
	sub.w	(cameraX).w, d1	; 0x29b0
	muls.w	#$549f, d1	; 0x29b4
	swap	d1	; 0x29b8
	subi.w	#$0080, d1	; 0x29ba
	move.w	(cameraY).w, d7	; 0x29be
	addi.w	#$005f, d7	; 0x29c2

next134:
	move.w	d0, (a2)+	; 0x29c6
	move.w	d1, (a2)+	; 0x29c8
	dbf	d7, next134	; 0x29ca
	lea	(64, a0), a1	; 0x29ce
	move.w	#$000f, d7	; 0x29d2

next135:
	move.w	(a1)+, (a2)+	; 0x29d6
	move.w	d1, (a2)+	; 0x29d8
	dbf	d7, next135	; 0x29da
	move.w	(96, a0), d0	; 0x29de
	move.w	#7, d7	; 0x29e2

next136:
	move.w	d0, (a2)+	; 0x29e6
	move.w	d1, (a2)+	; 0x29e8
	dbf	d7, next136	; 0x29ea
	move.w	(16, a0), d0	; 0x29ee
	move.w	#7, d7	; 0x29f2

next137:
	move.w	d0, (a2)+	; 0x29f6
	move.w	d1, (a2)+	; 0x29f8
	dbf	d7, next137	; 0x29fa
	move.w	(cameraY).w, d0	; 0x29fe
	neg.w	d0	; 0x2a02
	addi.w	#$0028, d0	; 0x2a04
	move.w	d0, (someYPosRelatedToNewCharStages).w	; 0x2a08
	move.w	(cameraY).w, d0	; 0x2a0c
	asr.w	#2, d0	; 0x2a10
	neg.w	d0	; 0x2a12
	addi.w	#$0100, d0	; 0x2a14
	move.w	d0, (planeBVScrollAlt).w	; 0x2a18
	move.w	d0, (someYPosRelatedToNewCharStages2).w	; 0x2a1c
	move.w	d0, (someYPosRelatedToCammyStage3).w	; 0x2a20
	move.l	(cameraY).w, d0	; 0x2a24
	asr.l	#1, d0	; 0x2a28
	move.l	d0, d1	; 0x2a2a
	asr.l	#2, d0	; 0x2a2c
	add.l	d1, d0	; 0x2a2e
	swap	d0	; 0x2a30
	neg.w	d0	; 0x2a32
	move.w	d0, (planeAVScroll).w	; 0x2a34
	move.w	d0, (planeAVScrollAlt).w	; 0x2a38
	move.w	d0, (someYPosRelatedToCammyStage4).w	; 0x2a3c
	move.w	#$00f8, (planeBVScroll).w	; 0x2a40
	move.b	#$57, (someYStagePos).w	; 0x2a46
	move.w	(cameraY).w, d0	; 0x2a4c
	addi.w	#$005f, d0	; 0x2a50
	move.b	d0, (someYPosRelatedToFeilongStage).w	; 0x2a54
	move.b	#$17, (LBL_ffffa61b).w	; 0x2a58
	rts		; 0x2a5e

borealAuroraRelated:
	dc.w	$0182, $0181, $0181, $0180, $0180, $0180, $0180, $0180, $0180, $0180, $0181, $0181, $0182, $0182, $0182, $0183, $0183, $0183, $0183, $0183, $0183, $0183, $0182, $0182, $0182, $0181, $0181, $0180, $0180, $0180, $0180, $0180, $0180, $0180, $0181, $0181, $0182, $0182, $0182, $0183, $0183, $0183, $0183, $0183, $0183, $0183, $0182, $0182	; 0x2a60

updateTHawkStageScroll:
	move.w	(40, a0), d0	; 0x2ac0
	subi.w	#4, d0	; 0x2ac4
	move.w	#$0080, d1	; 0x2ac8
	sub.w	(cameraX).w, d1	; 0x2acc
	muls.w	#$549f, d1	; 0x2ad0
	swap	d1	; 0x2ad4
	subi.l	#$00000080, d1	; 0x2ad6
	move.w	(cameraY).w, d7	; 0x2adc
	addi.w	#$005f, d7	; 0x2ae0

next140:
	move.w	d0, (a2)+	; 0x2ae4
	move.w	d1, (a2)+	; 0x2ae6
	dbf	d7, next140	; 0x2ae8
	move.w	(40, a0), d1	; 0x2aec
	move.w	#$003b, d7	; 0x2af0

next141:
	move.w	d0, (a2)+	; 0x2af4
	move.w	d1, (a2)+	; 0x2af6
	dbf	d7, next141	; 0x2af8
	lea	(40, a0), a1	; 0x2afc
	move.w	#$002b, d7	; 0x2b00

next142:
	move.w	d0, (a2)+	; 0x2b04
	move.w	(a1)+, (a2)+	; 0x2b06
	dbf	d7, next142	; 0x2b08
	move.w	(cameraY).w, d0	; 0x2b0c
	neg.w	d0	; 0x2b10
	move.w	d0, (planeAVScroll).w	; 0x2b12
	move.w	d0, (planeAVScrollAlt).w	; 0x2b16
	addi.w	#$0100, d0	; 0x2b1a
	move.w	d0, (planeBVScrollAlt).w	; 0x2b1e
	move.w	(cameraY).w, d0	; 0x2b22
	asr.w	#1, d0	; 0x2b26
	neg.w	d0	; 0x2b28
	addi.w	#$0100, d0	; 0x2b2a
	move.w	d0, (planeBVScroll).w	; 0x2b2e
	move.w	(cameraY).w, d0	; 0x2b32
	addi.w	#$006f, d0	; 0x2b36
	move.b	d0, (someYStagePos).w	; 0x2b3a
	rts		; 0x2b3e

updateFeilongScroll:
	move.w	#$0080, d0	; 0x2b40
	sub.w	(cameraX).w, d0	; 0x2b44
	muls.w	#$549f, d0	; 0x2b48
	subi.l	#$00800000, d0	; 0x2b4c
	move.l	d0, d1	; 0x2b52
	swap	d0	; 0x2b54
	move.w	d0, d1	; 0x2b56
	move.w	(cameraY).w, d7	; 0x2b58
	addi.w	#$006f, d7	; 0x2b5c

next150:
	move.l	d1, (a2)+	; 0x2b60
	dbf	d7, next150	; 0x2b62
	move.w	(32, a0), d0	; 0x2b66
	move.w	#$001f, d7	; 0x2b6a

next151:
	move.w	d0, (a2)+	; 0x2b6e
	move.w	d1, (a2)+	; 0x2b70
	dbf	d7, next151	; 0x2b72
	lea	(16, a0), a1	; 0x2b76
	move.w	#$0037, d7	; 0x2b7a

next152:
	move.w	d0, (a2)+	; 0x2b7e
	move.w	(a1)+, (a2)+	; 0x2b80
	dbf	d7, next152	; 0x2b82
	move.w	(cameraY).w, d0	; 0x2b86
	neg.w	d0	; 0x2b8a
	move.w	d0, (planeAVScrollAlt).w	; 0x2b8c
	move.w	d0, (someYPosRelatedToNewCharStages).w	; 0x2b90
	addi.w	#$0100, d0	; 0x2b94
	move.w	d0, (someYPosRelatedToNewCharStages2).w	; 0x2b98
	move.w	(cameraY).w, d0	; 0x2b9c
	asr.w	#2, d0	; 0x2ba0
	neg.w	d0	; 0x2ba2
	subi.w	#$0010, d0	; 0x2ba4
	move.w	d0, (planeAVScroll).w	; 0x2ba8
	addi.w	#$0100, d0	; 0x2bac
	move.w	d0, (planeBVScroll).w	; 0x2bb0
	move.w	d0, (planeBVScrollAlt).w	; 0x2bb4
	move.w	(cameraY).w, d0	; 0x2bb8
	addi.w	#$007f, d0	; 0x2bbc
	move.b	d0, (someYStagePos).w	; 0x2bc0
	move.b	#$1f, (someYPosRelatedToFeilongStage).w	; 0x2bc4
	rts		; 0x2bca

updateDeejayStageScroll:
	move.w	(48, a0), d0	; 0x2bcc
	swap	d0	; 0x2bd0
	move.w	(48, a0), d0	; 0x2bd2
	move.w	#$0027, d7	; 0x2bd6

next160:
	move.l	d0, (a2)+	; 0x2bda
	dbf	d7, next160	; 0x2bdc
	move.w	#$ff80, d1	; 0x2be0
	move.w	(cameraY).w, d7	; 0x2be4
	addi.w	#$005f, d7	; 0x2be8

next161:
	move.w	d0, (a2)+	; 0x2bec
	move.w	d1, (a2)+	; 0x2bee
	dbf	d7, next161	; 0x2bf0
	move.w	#$0017, d7	; 0x2bf4

next162:
	move.l	d0, (a2)+	; 0x2bf8
	dbf	d7, next162	; 0x2bfa
	lea	(48, a0), a1	; 0x2bfe
	move.w	#$0027, d7	; 0x2c02

next163:
	move.w	(a1)+, d0	; 0x2c06
	move.w	d0, (a2)+	; 0x2c08
	move.w	d0, (a2)+	; 0x2c0a
	dbf	d7, next163	; 0x2c0c
	move.w	(cameraY).w, d0	; 0x2c10
	neg.w	d0	; 0x2c14
	move.w	d0, (planeAVScroll).w	; 0x2c16
	move.w	d0, (planeAVScrollAlt).w	; 0x2c1a
	move.w	d0, (someYPosRelatedToNewCharStages).w	; 0x2c1e
	addi.w	#$0100, d0	; 0x2c22
	move.w	d0, (planeBVScroll).w	; 0x2c26
	move.w	d0, (someYPosRelatedToNewCharStages2).w	; 0x2c2a
	move.w	#$0100, (planeBVScrollAlt).w	; 0x2c2e
	move.b	#$37, (someYStagePos).w	; 0x2c34
	move.w	(cameraY).w, d0	; 0x2c3a
	addi.w	#$005f, d0	; 0x2c3e
	move.b	d0, (someYPosRelatedToFeilongStage).w	; 0x2c42
	rts		; 0x2c46

updateBonusStage1Scroll:
	move.w	(posInBorealAuroraOffsetsList).w, d0	; 0x2c48
	neg.w	d0	; 0x2c4c
	move.w	d0, (hScrollCacheA).w	; 0x2c4e
	move.w	(cameraY).w, d0	; 0x2c52
	add.w	(stagePosY).w, d0	; 0x2c56
	neg.w	d0	; 0x2c5a
	move.w	d0, (vsRamCache1).w	; 0x2c5c
	move.w	(cameraY).w, d0	; 0x2c60
	neg.w	d0	; 0x2c64
	addi.w	#$0100, d0	; 0x2c66
	move.w	d0, (LBL_ffff9b8c).w	; 0x2c6a
	rts		; 0x2c6e

updateBonusStage2Scroll:
	move.w	(cameraY).w, d0	; 0x2c70
	add.w	(stagePosY).w, d0	; 0x2c74
	neg.w	d0	; 0x2c78
	move.w	d0, (vsRamCache1).w	; 0x2c7a
	move.w	(cameraY).w, d0	; 0x2c7e
	neg.w	d0	; 0x2c82
	move.w	d0, (LBL_ffff9b8c).w	; 0x2c84
	rts		; 0x2c88

updateBonusStage3Scroll:
	move.w	(cameraY).w, d0	; 0x2c8a
	neg.w	d0	; 0x2c8e
	move.w	d0, (vsRamCache1).w	; 0x2c90
	move.w	d0, (LBL_ffff9b8c).w	; 0x2c94
	rts		; 0x2c98

selectHScrollOffset:
	subi.w	#$0020, d0	; 0x2c9a
	lsl.w	#7, d0	; 0x2c9e
	lea	dataBuffer, a0	; 0x2ca0
	adda.w	d0, a0	; 0x2ca6
	move.l	a0, (ptrToHScrollOffsets).w	; 0x2ca8
	rts		; 0x2cac

updateStage:
	move.w	(cameraX).w, d0	; 0x2cae
	bsr.b	selectHScrollOffset	; 0x2cb2
	lea	(stageStructData).w, a6	; 0x2cb4
	move.w	(stageId).w, d0	; 0x2cb8
	add.w	d0, d0	; 0x2cbc
	move.w	(updateStageFunctions, pc, d0.w), d0	; 0x2cbe
	jmp	(updateStageFunctions, pc, d0.w)	; 0x2cc2

updateStageFunctions:
	dc.w	updateOtherStages-updateStageFunctions	; 0x2cc6
	dc.w	updateOtherStages-updateStageFunctions	; 0x2cc8
	dc.w	updateOtherStages-updateStageFunctions	; 0x2cca
	dc.w	updateOtherStages-updateStageFunctions	; 0x2ccc
	dc.w	updateKenStage-updateStageFunctions	; 0x2cce
	dc.w	updateOtherStages-updateStageFunctions	; 0x2cd0
	dc.w	updateOtherStages-updateStageFunctions	; 0x2cd2
	dc.w	updateOtherStages-updateStageFunctions	; 0x2cd4
	dc.w	updateOtherStages-updateStageFunctions	; 0x2cd6
	dc.w	updateOtherStages-updateStageFunctions	; 0x2cd8
	dc.w	updateOtherStages-updateStageFunctions	; 0x2cda
	dc.w	updateClawStage-updateStageFunctions	; 0x2cdc
	dc.w	updateCammyStage-updateStageFunctions	; 0x2cde
	dc.w	updateOtherStages-updateStageFunctions	; 0x2ce0
	dc.w	updateOtherStages-updateStageFunctions	; 0x2ce2
	dc.w	updateOtherStages-updateStageFunctions	; 0x2ce4
	dc.w	updateBonusStage1-updateStageFunctions	; 0x2ce6
	dc.w	updateOtherStages-updateStageFunctions	; 0x2ce8
	dc.w	updateOtherStages-updateStageFunctions	; 0x2cea

updateOtherStages:
	rts		; 0x2cec

updateKenStage:
	addq.w	#1, (16, a6)	; 0x2cee
	move.w	(16, a6), d0	; 0x2cf2
	lsr.w	#4, d0	; 0x2cf6
	andi.w	#$000e, d0	; 0x2cf8
	move.w	(boatDyPositions, pc, d0.w), (10, a6)	; 0x2cfc
	rts		; 0x2d02

boatDyPositions:
	dc.w	$0008, $0009, $000a, $000b, $000b, $000a, $0009, $0008	; 0x2d04

updateClawStage:
	move.b	(3, a6), d0	; 0x2d14
	move.w	(updateClawStageFunctions, pc, d0.w), d1	; 0x2d18
	jmp	(updateClawStageFunctions, pc, d1.w)	; 0x2d1c

updateClawStageFunctions:
	dc.w	updateClawStage00-updateClawStageFunctions	; 0x2d20
	dc.w	updateClawStage02-updateClawStageFunctions	; 0x2d22
	dc.w	updateClawStage04-updateClawStageFunctions	; 0x2d24
	dc.w	updateClawStage06-updateClawStageFunctions	; 0x2d26

updateClawStage00:
	tst.b	(LBL_ffff9862).w	; 0x2d28
	bne.b	init6	; 0x2d2c
	tst.b	(LBL_ffff9826).w	; 0x2d2e
	bne.b	init6	; 0x2d32
	addq.b	#2, (3, a6)	; 0x2d34
	move.b	#$1e, (52, a6)	; 0x2d38
	move.w	#$0200, (10, a6)	; 0x2d3e
	move.b	#1, (24, a6)	; 0x2d44
	bra.b	updateGridPos	; 0x2d4a

updateClawStage02:
	subq.b	#1, (52, a6)	; 0x2d4c
	bne.b	claw_stage_02_update_end	; 0x2d50
	addq.b	#2, (3, a6)	; 0x2d52
	move.w	#$0030, (64, a6)	; 0x2d56

claw_stage_02_update_end:
	bra.b	updateGridPos	; 0x2d5c

updateClawStage04:
	move.w	(64, a6), d0	; 0x2d5e
	add.w	d0, (68, a6)	; 0x2d62
	move.w	(68, a6), d0	; 0x2d66
	ext.l	d0	; 0x2d6a
	asl.l	#8, d0	; 0x2d6c
	sub.l	d0, (10, a6)	; 0x2d6e
	bcs.b	grid_clash	; 0x2d72
	cmpi.w	#$0080, (10, a6)	; 0x2d74
	bcc.b	updateGridPos	; 0x2d7a
	st	(LBL_ffff9826).w	; 0x2d7c
	bra.b	updateGridPos	; 0x2d80

grid_clash:
	moveq	#$0010, d0	; 0x2d82
	jsr	(putInSfxQueue).w	; 0x2d84
	jsr	updateSmallShaking	; 0x2d88

init6:
	move.b	#6, (3, a6)	; 0x2d8e
	clr.l	(10, a6)	; 0x2d94
	move.w	#$ffff, (hintInitFun).w	; 0x2d98

updateClawStage06:
	rts		; 0x2d9e

updateGridPos:
	move.w	(cameraY).w, d0	; 0x2da0
	neg.w	d0	; 0x2da4
	move.w	d0, d1	; 0x2da6
	add.w	(10, a6), d0	; 0x2da8
	move.w	d0, (planeAVScroll).w	; 0x2dac
	addi.w	#$0100, d1	; 0x2db0
	move.w	d1, (planeBVScroll).w	; 0x2db4
	move.w	d1, (planeAVScrollAlt).w	; 0x2db8
	move.w	d1, (planeBVScrollAlt).w	; 0x2dbc
	cmpi.w	#$0098, d0	; 0x2dc0
	bcc.b	dont_move_grid	; 0x2dc4
	neg.w	d0	; 0x2dc6
	addi.b	#$bf, d0	; 0x2dc8
	move.b	d0, (someYStagePos).w	; 0x2dcc
	rts		; 0x2dd0

dont_move_grid:
	move.b	#$27, (someYStagePos).w	; 0x2dd2
	rts		; 0x2dd8

updateCammyStage:
	move.w	(52, a6), d0	; 0x2dda
	subi.w	#$0022, d0	; 0x2dde
	bpl.b	skip10	; 0x2de2
	addi.w	#$3000, d0	; 0x2de4

skip10:
	move.w	d0, (52, a6)	; 0x2de8
	lsr.w	#8, d0	; 0x2dec
	andi.w	#$003e, d0	; 0x2dee
	move.w	d0, (6, a6)	; 0x2df2
	rts		; 0x2df6

updateBonusStage1:
	move.w	(2, a6), d0	; 0x2df8
	move.w	(updateBonusStage1Functions, pc, d0.w), d0	; 0x2dfc
	jmp	(updateBonusStage1Functions, pc, d0.w)	; 0x2e00

updateBonusStage1Functions:
	dc.w	updateBonusStage1_00-updateBonusStage1Functions	; 0x2e04
	dc.w	updateBonusStage1_02-updateBonusStage1Functions	; 0x2e06
	dc.w	updateBonusStage1_04-updateBonusStage1Functions	; 0x2e08
	dc.w	updateBonusStage1_06-updateBonusStage1Functions	; 0x2e0a

updateBonusStage1_00:
	rts		; 0x2e0c

updateBonusStage1_02:
	clr.w	(10, a6)	; 0x2e0e
	move.w	#$0200, (28, a6)	; 0x2e12
	move.w	#$0040, (30, a6)	; 0x2e18
	move.w	#4, (2, a6)	; 0x2e1e
	rts		; 0x2e24

updateBonusStage1_04:
	move.w	(30, a6), d0	; 0x2e26
	sub.w	d0, (28, a6)	; 0x2e2a
	move.w	(28, a6), d0	; 0x2e2e
	ext.l	d0	; 0x2e32
	asl.l	#8, d0	; 0x2e34
	sub.l	d0, (10, a6)	; 0x2e36
	cmpi.w	#$0038, (10, a6)	; 0x2e3a
	bpl.b	no_more_bumper	; 0x2e40
	eori.b	#1, (6, a6)	; 0x2e42
	rts		; 0x2e48

no_more_bumper:
	move.w	#$0038, (10, a6)	; 0x2e4a
	ori.b	#1, (6, a6)	; 0x2e50
	move.w	#6, (2, a6)	; 0x2e56
	moveq	#8, d0	; 0x2e5c
	jmp	FUN_000309fc	; 0x2e5e

updateBonusStage1_06:
	rts		; 0x2e64

initStageUpdate:
	moveq	#0, d0	; 0x2e66
	move.l	d0, (objectTimers).w	; 0x2e68
	move.l	d0, (LBL_ffffa486).w	; 0x2e6c
	move.w	d0, (LBL_ffffa48a).w	; 0x2e70
	move.w	#$a48c, (ptrToListOfPtrsToObjects1).w	; 0x2e74
	move.w	#$a4cc, (ptrToListOfPtrsToObjects2).w	; 0x2e7a
	move.w	#$a50c, (ptrToListOfPtrsToObjects3).w	; 0x2e80
	move.w	#$a54c, (ptrToListOfPtrsToObjects4).w	; 0x2e86
	move.w	#$a58c, (ptrToListOfPtrsToObjects5).w	; 0x2e8c
	rts		; 0x2e92

updateAllSprites:
	tst.b	(areWeFighting).w	; 0x2e94
	beq.b	@pass_gui_update	; 0x2e98
	jsr	updateGuiSprites	; 0x2e9a
@pass_gui_update:
	move.w	(ptrDmaQueueCurrentEntry).w, a3	; 0x2ea0
	move.w	(ptrCurrentSpriteInSatBuffer).w, a4	; 0x2ea4
	bsr.w	updateAllObjectsSprites	; 0x2ea8
	tst.b	(fightersPriority).w	; 0x2eac
	bne.b	@priority_to_fighter_2	; 0x2eb0
	lea	(projectile1Data).w, a6	; 0x2eb2
	bsr.w	updateProjectilePatterns	; 0x2eb6
	bsr.w	updateProjectileSprite	; 0x2eba
	lea	(projectile2Data).w, a6	; 0x2ebe
	bsr.w	updateProjectilePatterns	; 0x2ec2
	bsr.w	updateProjectileSprite	; 0x2ec6
	bsr.b	updateFighter1	; 0x2eca
	bsr.b	updateFighter2	; 0x2ecc
	bra.b	@continue	; 0x2ece
@priority_to_fighter_2:
	lea	(projectile2Data).w, a6	; 0x2ed0
	bsr.w	updateProjectilePatterns	; 0x2ed4
	bsr.w	updateProjectileSprite	; 0x2ed8
	lea	(projectile1Data).w, a6	; 0x2edc
	bsr.w	updateProjectilePatterns	; 0x2ee0
	bsr.w	updateProjectileSprite	; 0x2ee4
	bsr.b	updateFighter2	; 0x2ee8
	bsr.b	updateFighter1	; 0x2eea
@continue:
	bsr.w	updateAllObjects	; 0x2eec
	move.w	a3, (ptrDmaQueueCurrentEntry).w	; 0x2ef0
	move.w	a4, (ptrCurrentSpriteInSatBuffer).w	; 0x2ef4
	clr.b	(needFightersUpdating).w	; 0x2ef8
	rts		; 0x2efc

updateFighter1:
	lea	(LBL_ffff8700).w, a6	; 0x2efe
	bsr.w	updateObject	; 0x2f02
	lea	(fighter1Data).w, a6	; 0x2f06
	tst.b	(a6)	; 0x2f0a
	beq.b	@return	; 0x2f0c
	tst.b	(251, a6)	; 0x2f0e
	beq.b	@pass_sprite_update	; 0x2f12
	bsr.w	notUpdateFighterSprite	; 0x2f14
@pass_sprite_update:
	bsr.w	updateFighterPatterns	; 0x2f18
	bra.w	updateSprite	; 0x2f1c
@return:
	rts		; 0x2f20

updateFighter2:
	lea	(LBL_ffff8750).w, a6	; 0x2f22
	bsr.w	updateObject	; 0x2f26
	lea	(player_1_).w, a6	; 0x2f2a
	tst.b	(a6)	; 0x2f2e
	beq.b	@loc_00002F44	; 0x2f30
	tst.b	(251, a6)	; 0x2f32
	beq.b	@pass_sprite_update	; 0x2f36
	bsr.w	notUpdateFighterSprite	; 0x2f38
@pass_sprite_update:
	bsr.w	updateFighterPatterns	; 0x2f3c
	bra.w	updateSprite	; 0x2f40
@loc_00002F44:
	rts		; 0x2f44

updateAllObjectsSprites:
	lea	(LBL_ffffa48c).w, a1	; 0x2f46
	move.w	(ptrToListOfPtrsToObjects1).w, a2	; 0x2f4a
@next1:
	cmpa.w	a2, a1	; 0x2f4e
	beq.b	@exit1	; 0x2f50
	move.w	(a1)+, a6	; 0x2f52
	bsr.w	updateObjectSprite	; 0x2f54
	bra.b	@next1	; 0x2f58
@exit1:
	lea	(LBL_ffffa4cc).w, a1	; 0x2f5a
	move.w	(ptrToListOfPtrsToObjects2).w, a2	; 0x2f5e
@next2:
	cmpa.w	a2, a1	; 0x2f62
	beq.b	@exit2	; 0x2f64
	move.w	(a1)+, a6	; 0x2f66
	bsr.w	updateObjectSprite	; 0x2f68
	bra.b	@next2	; 0x2f6c
@exit2:
	lea	(LBL_ffffa50c).w, a1	; 0x2f6e
	move.w	(ptrToListOfPtrsToObjects3).w, a2	; 0x2f72
@next3:
	cmpa.w	a2, a1	; 0x2f76
	beq.b	@exit3	; 0x2f78
	move.w	(a1)+, a6	; 0x2f7a
	bsr.w	updateObjectSprite	; 0x2f7c
	bra.b	@next3	; 0x2f80
@exit3:
	rts		; 0x2f82

updateAllObjects:
	lea	(LBL_ffffa54c).w, a1	; 0x2f84
	move.w	(ptrToListOfPtrsToObjects4).w, a2	; 0x2f88
@next1:
	cmpa.w	a2, a1	; 0x2f8c
	beq.b	updateObjects5	; 0x2f8e
	move.w	(a1)+, a6	; 0x2f90
	bsr.w	updateObjectSprite	; 0x2f92
	bra.b	@next1	; 0x2f96

updateObjects5:
	btst	#0, (object2And3Priority).w	; 0x2f98
	bne.b	@object3_has_priority	; 0x2f9e
	lea	(LBL_ffff87a0).w, a6	; 0x2fa0
	bsr.w	updateObject	; 0x2fa4
	lea	(LBL_ffff87f0).w, a6	; 0x2fa8
	bsr.w	updateObject	; 0x2fac
	bra.b	@continue	; 0x2fb0
@object3_has_priority:
	lea	(LBL_ffff87f0).w, a6	; 0x2fb2
	bsr.w	updateObject	; 0x2fb6
	lea	(LBL_ffff87a0).w, a6	; 0x2fba
	bsr.w	updateObject	; 0x2fbe
@continue:
	lea	(lengthOfListOfPtrsToObjects5).w, a1	; 0x2fc2
	move.w	(ptrToListOfPtrsToObjects5).w, a2	; 0x2fc6
@next2:
	cmpa.w	a2, a1	; 0x2fca
	beq.b	@exit2	; 0x2fcc
	move.w	(a1)+, a6	; 0x2fce
	bsr.w	updateObjectSprite	; 0x2fd0
	bra.b	@next2	; 0x2fd4
@exit2:
	rts		; 0x2fd6

updateFighterPatterns:
	tst.b	(199, a6)	; 0x2fd8
	beq.b	@exit	; 0x2fdc
	clr.b	(199, a6)	; 0x2fde
	moveq	#0, d0	; 0x2fe2
	move.b	(198, a6), d0	; 0x2fe4
	add.w	d0, d0	; 0x2fe8
	move.l	(90, a6), a0	; 0x2fea
	adda.w	(0, a0, d0), a0	; 0x2fee
	move.w	#$b000, d7	; 0x2ff2
	tst.b	(641, a6)	; 0x2ff6
	beq.b	@next	; 0x2ffa
	move.w	#$c000, d7	; 0x2ffc
@next:
	move.w	(a0)+, d0	; 0x3000
	beq.b	@exit	; 0x3002
	move.l	(a0)+, d1	; 0x3004
	move.w	(a0)+, d2	; 0x3006
	add.w	d7, d2	; 0x3008
	add.l	d0, (LBL_ffffa606).w	; 0x300a
	move.w	d0, (a3)+	; 0x300e
	move.l	d1, (a3)+	; 0x3010
	move.w	d2, (a3)+	; 0x3012
	bra.b	@next	; 0x3014
@exit:
	rts		; 0x3016

updateProjectilePatterns:
	tst.b	(95, a6)	; 0x3018
	beq.b	@exit	; 0x301c
	clr.b	(95, a6)	; 0x301e
	moveq	#0, d0	; 0x3022
	move.b	(94, a6), d0	; 0x3024
	add.w	d0, d0	; 0x3028
	move.l	(90, a6), a0	; 0x302a
	adda.w	(0, a0, d0), a0	; 0x302e
	move.w	#$b000, d7	; 0x3032
	tst.b	(17, a6)	; 0x3036
	beq.b	@next	; 0x303a
	move.w	#$c000, d7	; 0x303c
@next:
	move.w	(a0)+, d0	; 0x3040
	beq.b	@exit	; 0x3042
	move.l	(a0)+, d1	; 0x3044
	move.w	(a0)+, d2	; 0x3046
	add.w	d7, d2	; 0x3048
	add.l	d0, (LBL_ffffa606).w	; 0x304a
	move.w	d0, (a3)+	; 0x304e
	move.l	d1, (a3)+	; 0x3050
	move.w	d2, (a3)+	; 0x3052
	bra.b	@next	; 0x3054
@exit:
	rts		; 0x3056

updateObject:
	tst.b	(1, a6)	; 0x3058
	bne.b	updateObjectSprite	; 0x305c
	rts		; 0x305e

updateObjectSprite:
	move.b	(25, a6), (LBL_ffffbcb6).w	; 0x3060
	move.w	(18, a6), d6	; 0x3066
	move.w	(6, a6), d4	; 0x306a
	move.w	(10, a6), d5	; 0x306e
	tst.b	(1, a6)	; 0x3072
	bmi.b	@dont_fix_pos	; 0x3076
	moveq	#0, d0	; 0x3078
	move.b	(22, a6), d0	; 0x307a
	move.l	(ptrToHScrollOffsets).w, a0	; 0x307e
	add.w	(0, a0, d0), d4	; 0x3082
	add.w	(cameraY).w, d5	; 0x3086
@dont_fix_pos:
	tst.b	(a6)	; 0x308a
	bmi.b	@read_sprite_defs_alt	; 0x308c
	move.l	(40, a6), a0	; 0x308e
	move.w	(a0)+, d7	; 0x3092
@next1:
	move.w	(a0)+, d0	; 0x3094
	move.w	(a0)+, d1	; 0x3096
	move.b	(a0)+, d2	; 0x3098
	move.b	(a0)+, d3	; 0x309a
	bsr.w	sendSprite	; 0x309c
	bsr.w	checkLastSpriteVisibility	; 0x30a0
	dbf	d7, @next1	; 0x30a4
	rts		; 0x30a8
@read_sprite_defs_alt:
	move.l	(40, a6), a0	; 0x30aa
	move.w	(a0)+, d7	; 0x30ae
@next2:
	move.w	(a0)+, d0	; 0x30b0
	move.w	(a0)+, d1	; 0x30b2
	move.w	(a0)+, d2	; 0x30b4
	move.w	(a0)+, d3	; 0x30b6
	move.w	d2, d6	; 0x30b8
	andi.w	#$ff00, d6	; 0x30ba
	bsr.w	sendSprite	; 0x30be
	bsr.w	checkLastSpriteVisibility	; 0x30c2
	dbf	d7, @next2	; 0x30c6
	rts		; 0x30ca

notUpdateFighterSprite:
	moveq	#0, d0	; 0x30cc
	move.b	(198, a6), d0	; 0x30ce
	add.w	d0, d0	; 0x30d2
	add.w	d0, d0	; 0x30d4
	lea	LBL_083dea, a1	; 0x30d6
	adda.w	d0, a1	; 0x30dc
	move.b	(a1)+, d5	; 0x30de
	ext.w	d5	; 0x30e0
	move.b	(a1)+, d4	; 0x30e2
	ext.w	d4	; 0x30e4
	move.b	(a1)+, d0	; 0x30e6
	bne.b	@load_frames	; 0x30e8
	rts		; 0x30ea
@load_frames:
	ext.w	d0	; 0x30ec
	add.w	d0, d0	; 0x30ee
	move.l	(36, a6), a0	; 0x30f0
	adda.w	(0, a0, d0), a0	; 0x30f4
	move.b	(a1)+, d2	; 0x30f8
	move.b	(25, a6), d0	; 0x30fa
	move.b	(85, a6), d1	; 0x30fe
	eor.b	d1, d0	; 0x3102
	btst	#4, d0	; 0x3104
	beq.b	@not_vflipped	; 0x3108
	neg.w	d5	; 0x310a
	addi.w	#$ff80, d5	; 0x310c
@not_vflipped:
	btst	#3, d0	; 0x3110
	beq.b	@not_hflipped	; 0x3114
	neg.w	d4	; 0x3116
@not_hflipped:
	eor.b	d2, d0	; 0x3118
	move.b	d0, (LBL_ffffbcb6).w	; 0x311a
	move.w	(18, a6), d6	; 0x311e
	add.w	(6, a6), d4	; 0x3122
	add.w	(144, a6), d4	; 0x3126
	add.w	(10, a6), d5	; 0x312a
	move.b	(86, a6), d0	; 0x312e
	ext.w	d0	; 0x3132
	add.w	d0, d5	; 0x3134
	bra.b	update_sprite100	; 0x3136

updateProjectileSprite:
	tst.b	(a6)	; 0x3138
	beq.b	@return	; 0x313a
	tst.b	(1, a6)	; 0x313c
	beq.b	@return	; 0x3140
	tst.b	(74, a6)	; 0x3142
	bne.b	@return	; 0x3146
	move.b	(25, a6), d0	; 0x3148
	move.b	(85, a6), d1	; 0x314c
	eor.b	d1, d0	; 0x3150
	move.b	d0, (LBL_ffffbcb6).w	; 0x3152
	move.w	(18, a6), d6	; 0x3156
	move.w	(6, a6), d4	; 0x315a
	move.w	(10, a6), d5	; 0x315e
	bra.b	not_vflipped100	; 0x3162
@return:
	rts		; 0x3164

updateSprite:
	move.b	(25, a6), d0	; 0x3166
	move.b	(85, a6), d1	; 0x316a
	eor.b	d1, d0	; 0x316e
	move.b	d0, (LBL_ffffbcb6).w	; 0x3170
	move.w	(18, a6), d6	; 0x3174
	move.w	(6, a6), d4	; 0x3178
	add.w	(144, a6), d4	; 0x317c
	move.w	(10, a6), d5	; 0x3180
	move.b	(86, a6), d0	; 0x3184
	ext.w	d0	; 0x3188
	add.w	d0, d5	; 0x318a
	btst	#4, (LBL_ffffbcb6).w	; 0x318c
	beq.b	not_vflipped100	; 0x3192
	addi.w	#$ff80, d5	; 0x3194

not_vflipped100:
	move.l	(40, a6), a0	; 0x3198

update_sprite100:
	tst.b	(1, a6)	; 0x319c
	bmi.b	@dont_fix_pos	; 0x31a0
	moveq	#0, d0	; 0x31a2
	move.b	(22, a6), d0	; 0x31a4
	move.l	(ptrToHScrollOffsets).w, a1	; 0x31a8
	add.w	(0, a1, d0), d4	; 0x31ac
	add.w	(cameraY).w, d5	; 0x31b0
@dont_fix_pos:
	move.w	(a0)+, d7	; 0x31b4
@next:
	move.w	(a0)+, d0	; 0x31b6
	move.w	(a0)+, d1	; 0x31b8
	move.b	(a0)+, d2	; 0x31ba
	move.b	(a0)+, d3	; 0x31bc
	bsr.b	sendSprite	; 0x31be
	dbf	d7, @next	; 0x31c0
	rts		; 0x31c4

sendSprite:
	cmpi.b	#$40, (currentSpriteLink).w	; 0x31c6
	bcc.w	@return	; 0x31cc
	addq.b	#1, (currentSpriteLink).w	; 0x31d0
	btst	#4, (LBL_ffffbcb6).w	; 0x31d4
	beq.b	@not_hflipped	; 0x31da
	andi.w	#3, d3	; 0x31dc
	addq.w	#1, d3	; 0x31e0
	lsl.w	#3, d3	; 0x31e2
	add.w	d3, d1	; 0x31e4
	neg.w	d1	; 0x31e6
	move.b	(-1, a0), d3	; 0x31e8
@not_hflipped:
	addi.w	#$0080, d1	; 0x31ec
	add.w	d5, d1	; 0x31f0
	move.w	d1, (a4)+	; 0x31f2
	move.b	d3, d1	; 0x31f4
	andi.b	#$0f, d1	; 0x31f6
	move.b	d1, (a4)+	; 0x31fa
	move.b	(currentSpriteLink).w, (a4)+	; 0x31fc
	move.b	d3, d1	; 0x3200
	lsl.w	#7, d1	; 0x3202
	andi.w	#$1800, d1	; 0x3204
	move.b	d2, d1	; 0x3208
	add.w	d6, d1	; 0x320a
	move.b	d3, d3	; 0x320c
	bpl.b	@dont_change_priority_palette	; 0x320e
	andi.w	#$1fff, d1	; 0x3210
	or.w	(20, a6), d1	; 0x3214
@dont_change_priority_palette:
	move.b	(LBL_ffffbcb6).w, d2	; 0x3218
	lsl.w	#8, d2	; 0x321c
	eor.w	d2, d1	; 0x321e
	move.w	d1, (a4)+	; 0x3220
	btst	#3, (LBL_ffffbcb6).w	; 0x3222
	beq.b	@not_vflipped	; 0x3228
	andi.w	#$000c, d3	; 0x322a
	addq.w	#4, d3	; 0x322e
	add.w	d3, d3	; 0x3230
	add.w	d3, d0	; 0x3232
	neg.w	d0	; 0x3234
	move.b	(-1, a0), d3	; 0x3236
@not_vflipped:
	add.w	d4, d0	; 0x323a
	addi.w	#$0080, d0	; 0x323c
	move.w	d0, (a4)+	; 0x3240
@return:
	rts		; 0x3242

checkLastSpriteVisibility:
	move.w	(-2, a4), d0	; 0x3244
	addi.w	#$ffa0, d0	; 0x3248
	cmpi.w	#$0120, d0	; 0x324c
	bcs.w	@return	; 0x3250
	subq.w	#8, a4	; 0x3254
	subq.b	#1, (currentSpriteLink).w	; 0x3256
@return:
	rts		; 0x325a

FUN_0000325c:
	jsr	(initStageUpdate).w	; 0x325c
	st	(needFightersUpdating).w	; 0x3260
	jsr	(FUN_0000378a).w	; 0x3264
	bsr.w	updateProjectiles	; 0x3268
	jsr	(updateCamera).w	; 0x326c
	jsr	(updateStage).w	; 0x3270
	bsr.w	updateAllObjectsAlt	; 0x3274
	bsr.w	handleSomeObjects	; 0x3278
	rts		; 0x327c

updateBackgroundAndObjects:
	jsr	(initStageUpdate).w	; 0x327e
	st	(needFightersUpdating).w	; 0x3282
	bra.w	updateAllObjectsAlt	; 0x3286

handleSomeObjects:
	lea	(LBL_ffff8700).w, a6	; 0x328a
	moveq	#3, d7	; 0x328e
@next:
	tst.b	(a6)	; 0x3290
	beq.b	@continue	; 0x3292
	moveq	#0, d0	; 0x3294
	move.b	(15, a6), d0	; 0x3296
	lsl.w	#2, d0	; 0x329a
	move.l	(ptrToSomeObjectFunctions, pc, d0.w), a0	; 0x329c
	move.w	d7, -(a7)	; 0x32a0
	jsr	(a0)	; 0x32a2
	move.w	(a7)+, d7	; 0x32a4
@continue:
	lea	(80, a6), a6	; 0x32a6
	dbf	d7, @next	; 0x32aa
	rts		; 0x32ae

ptrToSomeObjectFunctions:
	dc.l	someObjectFunction00	; 0x32b0
	dc.l	someObjectFunction00	; 0x32b4
	dc.l	someObjectFunction01	; 0x32b8
	dc.l	someObjectFunction02	; 0x32bc
	dc.l	someObjectFunction03	; 0x32c0
	dc.l	someObjectFunction04	; 0x32c4
	dc.l	someObjectFunction03	; 0x32c8
	dc.l	someObjectFunction03	; 0x32cc
	dc.l	someObjectFunction03	; 0x32d0
	dc.l	someObjectFunction03	; 0x32d4

updateProjectiles:
	lea	(projectile1Data).w, a6	; 0x32d8
	moveq	#1, d7	; 0x32dc
@next:
	tst.b	(a6)	; 0x32de
	beq.b	@continue	; 0x32e0
	moveq	#0, d0	; 0x32e2
	move.b	(15, a6), d0	; 0x32e4
	lsl.w	#2, d0	; 0x32e8
	move.l	(ptrProjectilesFunctions, pc, d0.w), a0	; 0x32ea
	move.w	d7, -(a7)	; 0x32ee
	jsr	(a0)	; 0x32f0
	move.w	(a7)+, d7	; 0x32f2
@continue:
	lea	(128, a6), a6	; 0x32f4
	dbf	d7, @next	; 0x32f8
	rts		; 0x32fc

ptrProjectilesFunctions:
	dc.l	projectileFunction00	; 0x32fe
	dc.l	projectileFunction01	; 0x3302
	dc.l	projectileFunction02	; 0x3306
	dc.l	projectileFunction03	; 0x330a
	dc.l	projectileFunction04	; 0x330e
	dc.l	projectileFunction05	; 0x3312
	dc.l	projectileFunction05	; 0x3316
	dc.l	projectileFunction06	; 0x331a
	dc.l	projectileFunction07	; 0x331e
	dc.l	projectileFunction08	; 0x3322
	dc.l	projectileFunction09	; 0x3326

updateAllObjectsAlt:
	lea	(objectsData).w, a6	; 0x332a
	moveq	#$002f, d7	; 0x332e
@next:
	tst.b	(a6)	; 0x3330
	beq.b	@continue	; 0x3332
	moveq	#0, d0	; 0x3334
	move.b	(15, a6), d0	; 0x3336
	lsl.w	#2, d0	; 0x333a
	move.l	(update_objects_functions, pc, d0.w), a0	; 0x333c
	move.w	d7, -(a7)	; 0x3340
	moveq	#0, d0	; 0x3342
	jsr	(a0)	; 0x3344
	move.w	(a7)+, d7	; 0x3346
@continue:
	lea	(80, a6), a6	; 0x3348
	dbf	d7, @next	; 0x334c
	rts		; 0x3350

update_objects_functions:
	dc.l	update_object_00	; 0x3352
	dc.l	update_object_01	; 0x3356
	dc.l	update_object_02	; 0x335a
	dc.l	update_object_03	; 0x335e
	dc.l	update_object04_0f	; 0x3362
	dc.l	update_object_05	; 0x3366
	dc.l	update_object_06	; 0x336a
	dc.l	update_object_07	; 0x336e
	dc.l	update_object_08	; 0x3372
	dc.l	update_object_09	; 0x3376
	dc.l	update_object_0a	; 0x337a
	dc.l	update_object_0b	; 0x337e
	dc.l	update_object_0c	; 0x3382
	dc.l	update_object_0d	; 0x3386
	dc.l	update_object_0e	; 0x338a
	dc.l	update_object04_0f	; 0x338e
	dc.l	update_object_10	; 0x3392
	dc.l	update_object_11	; 0x3396
	dc.l	update_object_12	; 0x339a
	dc.l	update_object_13	; 0x339e
	dc.l	update_object_14	; 0x33a2
	dc.l	update_object_15	; 0x33a6
	dc.l	update_object_16	; 0x33aa
	dc.l	update_object_17	; 0x33ae
	dc.l	update_object_18	; 0x33b2
	dc.l	update_object_19	; 0x33b6
	dc.l	update_object_1a	; 0x33ba
	dc.l	update_object_1b	; 0x33be
	dc.l	update_object_1c	; 0x33c2
	dc.l	update_object_1d	; 0x33c6
	dc.l	update_object_1e	; 0x33ca
	dc.l	update_object_1f	; 0x33ce
	dc.l	update_object_20	; 0x33d2
	dc.l	update_object_21	; 0x33d6
	dc.l	update_object_22	; 0x33da
	dc.l	update_object_23	; 0x33de
	dc.l	update_object_24	; 0x33e2
	dc.l	update_object_25	; 0x33e6
	dc.l	update_object_26	; 0x33ea
	dc.l	update_object_27	; 0x33ee
	dc.l	update_object_28	; 0x33f2
	dc.l	update_object_29	; 0x33f6
	dc.l	update_object_2a	; 0x33fa
	dc.l	update_object_2b	; 0x33fe
	dc.l	update_object_2c	; 0x3402
	dc.l	update_object_2d	; 0x3406
	dc.l	update_object_2e	; 0x340a
	dc.l	update_object_2f	; 0x340e
	dc.l	update_object_30	; 0x3412
	dc.l	update_object_31	; 0x3416
	dc.l	update_object_32	; 0x341a
	dc.l	update_object_33	; 0x341e
	dc.l	update_object_34	; 0x3422
	dc.l	update_object_35	; 0x3426
	dc.l	update_object_36	; 0x342a
	dc.l	update_object_37	; 0x342e
	dc.l	update_object_38	; 0x3432
	dc.l	update_object_39	; 0x3436
	dc.l	update_object_3a	; 0x343a
	dc.l	update_object_3b	; 0x343e
	dc.l	update_object_3c	; 0x3442
	dc.l	update_object_3d	; 0x3446
	dc.l	update_object_3e	; 0x344a
	dc.l	update_object_3f	; 0x344e
	dc.l	update_object_40	; 0x3452
	dc.l	update_object_41	; 0x3456
	dc.l	update_object_42	; 0x345a
	dc.l	update_object_43	; 0x345e
	dc.l	update_object_44	; 0x3462
	dc.l	update_object_45	; 0x3466
	dc.l	update_object_46	; 0x346a
	dc.l	update_object_47	; 0x346e
	dc.l	update_object_48	; 0x3472
	dc.l	update_object_49	; 0x3476
	dc.l	update_object_4a	; 0x347a
	dc.l	update_object_do_nothing	; 0x347e
	dc.l	update_object_4c	; 0x3482
	dc.l	update_object_4d	; 0x3486
	dc.l	update_object_4e	; 0x348a
	dc.l	update_object_4f	; 0x348e
	dc.l	update_object_50	; 0x3492
	dc.l	update_object_51	; 0x3496
	dc.l	update_object_52	; 0x349a
	dc.l	update_object_53	; 0x349e
	dc.l	update_object_do_nothing	; 0x34a2
	dc.l	update_object_55	; 0x34a6
	dc.l	update_object_56	; 0x34aa
	dc.l	update_object_do_nothing	; 0x34ae
	dc.l	update_object_58	; 0x34b2
	dc.l	update_object_59	; 0x34b6
	dc.l	update_object_5a	; 0x34ba
	dc.l	update_object_5b	; 0x34be
	dc.l	update_object_5c	; 0x34c2
	dc.l	update_object_5d	; 0x34c6
	dc.l	update_object_5e	; 0x34ca
	dc.l	update_object_5f	; 0x34ce
	dc.l	update_object_60	; 0x34d2
	dc.l	update_object_61	; 0x34d6
	dc.l	update_object_62	; 0x34da
	dc.l	update_object_63	; 0x34de
	dc.l	update_object_64	; 0x34e2
	dc.l	update_object_65	; 0x34e6
	dc.l	update_object_66	; 0x34ea
	dc.l	update_object_67	; 0x34ee
	dc.l	update_object_68	; 0x34f2
	dc.l	update_object_69	; 0x34f6
	dc.l	update_object_6a	; 0x34fa
	dc.l	update_object_6b	; 0x34fe
	dc.l	update_object_6c	; 0x3502
	dc.l	update_object_do_nothing	; 0x3506
	dc.l	update_object_do_nothing	; 0x350a
	dc.l	update_object_do_nothing	; 0x350e
	dc.l	update_object_70	; 0x3512
	dc.l	update_object_71	; 0x3516

update_object_do_nothing:
	rts		; 0x351a

updateBigShaking:
	tst.b	(LBL_ffff9939).w	; 0x351c
	bne.b	return110	; 0x3520
	tst.b	(LBL_ffff988e).w	; 0x3522
	bne.b	return110	; 0x3526
	move.b	#8, (LBL_ffff988e).w	; 0x3528

return110:
	rts		; 0x352e

updateSmallShaking:
	tst.b	(LBL_ffff9939).w	; 0x3530
	bne.b	return110	; 0x3534
	tst.b	(LBL_ffff988e).w	; 0x3536
	bne.b	return110	; 0x353a
	move.b	#5, (LBL_ffff988e).w	; 0x353c
	rts		; 0x3542

updateCameraFunctions:
	dc.w	updateCamera00-updateCameraFunctions	; 0x3544
	dc.w	updateCamera02-updateCameraFunctions	; 0x3546

updateCamera:
	moveq	#0, d0	; 0x3548
	move.b	(LBL_ffff9792).w, d0	; 0x354a
	move.w	(updateCameraFunctions, pc, d0.w), d1	; 0x354e
	jmp	(updateCameraFunctions, pc, d1.w)	; 0x3552

updateCamera00:
	addq.b	#2, (LBL_ffff9792).w	; 0x3556
	moveq	#0, d0	; 0x355a
	move.w	d0, (LBL_ffff97d2).w	; 0x355c
	move.l	d0, (cameraY).w	; 0x3560
	rts		; 0x3564

updateCamera02:
	tst.b	(LBL_ffff9933).w	; 0x3566
	bne.b	return110	; 0x356a
	tst.b	(areWeOnBonusStage).w	; 0x356c
	bne.b	on_bonus_stage	; 0x3570
	bsr.b	computeCamera	; 0x3572

on_bonus_stage:
	tst.b	(LBL_ffff988e).w	; 0x3574
	beq.b	end	; 0x3578
	bsr.w	updateShaking	; 0x357a

end:
	bra.w	compute_camera_y	; 0x357e

computeCamera:
	move.w	(LBL_ffff8006).w, d2	; 0x3582
	tst.b	(LBL_ffff819a).w	; 0x3586
	beq.b	@fighter_1_not_19a	; 0x358a
	move.w	(player_1_).w, d2	; 0x358c
@fighter_1_not_19a:
	move.w	(player_1_).w, d3	; 0x3590
	tst.b	(player_1_).w	; 0x3594
	beq.b	@fighter_2_not_19a	; 0x3598
	move.w	(LBL_ffff8006).w, d3	; 0x359a
@fighter_2_not_19a:
	lea	(fighter1Data).w, a1	; 0x359e
	lea	(player_1_).w, a2	; 0x35a2
	cmp.w	d2, d3	; 0x35a6
	bgt.b	@fighter_1_left_to_2	; 0x35a8
	exg	d2, d3	; 0x35aa
	exg	a2, a1	; 0x35ac
@fighter_1_left_to_2:
	sub.w	(200, a1), d2	; 0x35ae
	add.w	(200, a2), d3	; 0x35b2
	move.w	d2, d0	; 0x35b6
	move.w	d3, d1	; 0x35b8
	sub.w	d0, d1	; 0x35ba
	cmpi.w	#$00b6, d1	; 0x35bc
	bcc.b	@fighters_too_far	; 0x35c0
	move.w	d2, d0	; 0x35c2
	move.w	d3, d1	; 0x35c4
	sub.w	(cameraX).w, d1	; 0x35c6
	subi.w	#$00db, d1	; 0x35ca
	bpl.b	@camera_on_left_fighter	; 0x35ce
	sub.w	(cameraX).w, d0	; 0x35d0
	subi.w	#$0025, d0	; 0x35d4
	bmi.b	@camera_overflow_on_left	; 0x35d8
@return:
	rts		; 0x35da
@fighters_too_far:
	cmpi.w	#$0100, d1	; 0x35dc
	bcc.b	@return	; 0x35e0
	add.w	d2, d3	; 0x35e2
	move.w	d3, d0	; 0x35e4
	lsr.w	#1, d0	; 0x35e6
	sub.w	(cameraX).w, d0	; 0x35e8
	subi.w	#$0080, d0	; 0x35ec
	bmi.b	@camera_overflow_on_left	; 0x35f0
	move.w	d0, d1	; 0x35f2
@camera_on_left_fighter:
	cmpi.w	#3, d1	; 0x35f4
	bcs.b	@clamp_3	; 0x35f8
	move.w	#3, d1	; 0x35fa
@clamp_3:
	move.w	d1, d0	; 0x35fe
	bra.b	@clamp_m3	; 0x3600
@camera_overflow_on_left:
	cmpi.w	#$fffd, d0	; 0x3602
	bcc.b	@clamp_m3	; 0x3606
	move.w	#$fffd, d0	; 0x3608
@clamp_m3:
	add.w	(cameraX).w, d0	; 0x360c
	cmpi.w	#$0020, d0	; 0x3610
	bcc.b	@clamp_20	; 0x3614
	move.w	#$0020, d0	; 0x3616
	bra.b	@clamp_e0	; 0x361a
@clamp_20:
	cmpi.w	#$00e0, d0	; 0x361c
	bcs.b	@clamp_e0	; 0x3620
	move.w	#$00e0, d0	; 0x3622
@clamp_e0:
	move.w	d0, (cameraX).w	; 0x3626
	rts		; 0x362a

compute_camera_y:
	tst.b	(projectionFlags).w	; 0x362c
	bne.w	return2	; 0x3630
	tst.b	(shakingDy).w	; 0x3634
	bne.w	return2	; 0x3638
	tst.b	(LBL_ffff9879).w	; 0x363c
	bne.w	return2	; 0x3640
	move.w	(LBL_ffff800a).w, d1	; 0x3644
	move.w	(player_1_).w, d0	; 0x3648
	cmp.w	d1, d0	; 0x364c
	bpl.b	fighter_1_above_fighter_2	; 0x364e
	move.w	d0, d1	; 0x3650

fighter_1_above_fighter_2:
	move.w	#$00c0, d0	; 0x3652
	sub.w	d1, d0	; 0x3656
	cmpi.w	#$0070, d0	; 0x3658
	bcs.b	clamp_70	; 0x365c
	move.w	#$0070, d0	; 0x365e

clamp_70:
	lsr.w	#3, d0	; 0x3662
	sub.w	(cameraY).w, d0	; 0x3664
	bmi.w	camera_y_overflow	; 0x3668
	cmpi.w	#3, d0	; 0x366c
	blt.b	clamp_2	; 0x3670
	moveq	#2, d0	; 0x3672

clamp_2:
	add.w	d0, (cameraY).w	; 0x3674
	rts		; 0x3678

camera_y_overflow:
	cmpi.w	#$fffd, d0	; 0x367a
	bgt.b	clamp_m2	; 0x367e
	moveq	#-2, d0	; 0x3680

clamp_m2:
	add.w	d0, (cameraY).w	; 0x3682

return2:
	rts		; 0x3686

updateShaking:
	moveq	#0, d0	; 0x3688
	move.b	(LBL_ffff9794).w, d0	; 0x368a
	move.w	(update_shaking_funcs, pc, d0.w), d1	; 0x368e
	jmp	(update_shaking_funcs, pc, d1.w)	; 0x3692

update_shaking_funcs:
	dc.w	update_shaking_00-update_shaking_funcs	; 0x3696
	dc.w	update_shaking_02-update_shaking_funcs	; 0x3698

update_shaking_00:
	addq.b	#2, (LBL_ffff9794).w	; 0x369a
	move.b	(LBL_ffff988e).w, (shakingMainTimer).w	; 0x369e
	move.b	#7, (shakingFrameTimer).w	; 0x36a4
	move.w	(cameraY).w, d0	; 0x36aa
	move.w	d0, (tempCameraY).w	; 0x36ae
	rts		; 0x36b2

update_shaking_02:
	subq.b	#1, (shakingFrameTimer).w	; 0x36b4
	bpl.b	dont_reset_timer	; 0x36b8
	subq.b	#1, (shakingMainTimer).w	; 0x36ba
	beq.b	end_shaking	; 0x36be
	move.b	#7, (shakingFrameTimer).w	; 0x36c0

dont_reset_timer:
	btst	#0, (shakingFrameTimer).w	; 0x36c6
	beq.b	even_frame	; 0x36cc
	move.w	(cameraY).w, d0	; 0x36ce
	move.w	d0, (tempCameraY).w	; 0x36d2
	move.b	#3, (shakingDy).w	; 0x36d6
	addq.w	#3, d0	; 0x36dc
	cmpi.w	#$0010, d0	; 0x36de
	bcs.b	@loc_000036E6	; 0x36e2
	moveq	#$000f, d0	; 0x36e4
@loc_000036E6:
	move.w	d0, (cameraY).w	; 0x36e6
	rts		; 0x36ea

end_shaking:
	clr.b	(LBL_ffff988e).w	; 0x36ec
	clr.b	(LBL_ffff9794).w	; 0x36f0

even_frame:
	clr.b	(shakingDy).w	; 0x36f4
	move.w	(tempCameraY).w, (cameraY).w	; 0x36f8
	rts		; 0x36fe

updateCounters:
	tst.b	(648, a6)	; 0x3700
	bne.b	@human	; 0x3704
	tst.b	(402, a6)	; 0x3706
	beq.b	@f192_zero	; 0x370a
	subq.b	#1, (402, a6)	; 0x370c
@f192_zero:
	move.b	(LBL_ffff9933).w, d0	; 0x3710
	or.b	(LBL_ffff9939).w, d0	; 0x3714
	or.b	(areWeOnBonusStage).w, d0	; 0x3718
	bne.b	@fB6_zero	; 0x371c
	bra.b	@no_bonus	; 0x371e
@human:
	tst.b	(235, a6)	; 0x3720
	beq.b	@fEB_zero	; 0x3724
	subq.b	#1, (235, a6)	; 0x3726
@fEB_zero:
	tst.b	(areWeOnBonusStage).w	; 0x372a
	beq.b	@no_bonus	; 0x372e
	tst.b	(182, a6)	; 0x3730
	beq.b	@fB6_zero	; 0x3734
	subq.b	#1, (182, a6)	; 0x3736
@fB6_zero:
	move.w	(70, a6), d0	; 0x373a
	cmp.w	(60, a6), d0	; 0x373e
	beq.b	@no_bonus	; 0x3742
	move.w	#$00b0, (70, a6)	; 0x3744
	move.w	#$00af, (60, a6)	; 0x374a
@no_bonus:
	tst.b	(413, a6)	; 0x3750
	beq.b	@f19D_zero	; 0x3754
	subq.b	#1, (413, a6)	; 0x3756
@f19D_zero:
	tst.b	(158, a6)	; 0x375a
	beq.b	@f9e_zero	; 0x375e
	subq.b	#1, (158, a6)	; 0x3760
@f9e_zero:
	tst.b	(186, a6)	; 0x3764
	beq.b	@fBA_zero	; 0x3768
	subq.b	#1, (186, a6)	; 0x376a
@fBA_zero:
	tst.w	(108, a6)	; 0x376e
	beq.b	@f6C_zero	; 0x3772
	subq.w	#1, (108, a6)	; 0x3774
	bne.b	@dont_reset_f6A	; 0x3778
@f6C_zero:
	clr.w	(106, a6)	; 0x377a
@dont_reset_f6A:
	tst.w	(110, a6)	; 0x377e
	beq.b	@end	; 0x3782
	subq.w	#1, (110, a6)	; 0x3784
@end:
	rts		; 0x3788

FUN_0000378a:
	move.l	(LBL_ffff80dc).w, (LBL_ffff80e0).w	; 0x378a
	move.l	(player_1_).w, (player_1_).w	; 0x3790
	move.l	(LBL_ffff8006).w, (LBL_ffff80d8).w	; 0x3796
	move.l	(LBL_ffff800a).w, (LBL_ffff80dc).w	; 0x379c
	move.l	(player_1_).w, (player_1_).w	; 0x37a2
	move.l	(player_1_).w, (player_1_).w	; 0x37a8
	clr.b	(player_1_).w	; 0x37ae
	move.l	(LBL_ffff80dc).w, d0	; 0x37b2
	moveq	#1, d1	; 0x37b6
	cmp.l	(LBL_ffff80e0).w, d0	; 0x37b8
	beq.b	@fighter1_vdirection_zero	; 0x37bc
	blt.b	@fighter1_vdirection_1	; 0x37be
	moveq	#-1, d1	; 0x37c0
@fighter1_vdirection_1:
	move.b	d1, (player_1_).w	; 0x37c2
@fighter1_vdirection_zero:
	clr.b	(LBL_ffff8145).w	; 0x37c6
	move.l	(player_1_).w, d0	; 0x37ca
	moveq	#1, d1	; 0x37ce
	cmp.l	(player_1_).w, d0	; 0x37d0
	beq.b	@fighter2_vdirection_zero	; 0x37d4
	blt.b	@fighter2_vdirection_1	; 0x37d6
	moveq	#-1, d1	; 0x37d8
@fighter2_vdirection_1:
	move.b	d1, (LBL_ffff8145).w	; 0x37da
@fighter2_vdirection_zero:
	bsr.w	updateFightersF06AndF07	; 0x37de
	tst.b	(LBL_ffff80f0).w	; 0x37e2
	beq.b	@fighter1_f80_zero	; 0x37e6
	subq.b	#1, (LBL_ffff80f0).w	; 0x37e8
@fighter1_f80_zero:
	tst.b	(player_1_).w	; 0x37ec
	beq.b	@fighter2_f80_zero	; 0x37f0
	subq.b	#1, (player_1_).w	; 0x37f2
@fighter2_f80_zero:
	tst.b	(projectionFlags).w	; 0x37f6
	bne.w	@projection_ongoing	; 0x37fa
	lea	(fighter1Data).w, a6	; 0x37fe
	lea	(player_1_).w, a0	; 0x3802
	jsr	(random).w	; 0x3806
	move.l	#$55555555, d1	; 0x380a
	andi.w	#$001f, d0	; 0x3810
	btst	d0, d1	; 0x3814
	beq.b	@dont_swap	; 0x3816
	exg	a0, a6	; 0x3818
@dont_swap:
	move.w	a6, (ptrToFighterPriority1).w	; 0x381a
	move.w	a0, (ptrToFighterPriority2).w	; 0x381e
	bsr.w	updateFighter	; 0x3822
	tst.b	(117, a6)	; 0x3826
	bne.b	@projection_priority1	; 0x382a
	move.w	(ptrToFighterPriority2).w, a6	; 0x382c
	bsr.b	updateFighter	; 0x3830
	tst.b	(117, a6)	; 0x3832
	bne.b	@projection_priority2	; 0x3836
	clr.b	(areFighterClose).w	; 0x3838
	tst.b	(projectionCounter).w	; 0x383c
	beq.b	@end_projection	; 0x3840
	subq.b	#1, (projectionCounter).w	; 0x3842
	rts		; 0x3846
@end_projection:
	bsr.w	computeFightersPriority	; 0x3848
	bsr.w	computeOldFacesRight	; 0x384c
	bsr.w	computeFightersDeltas	; 0x3850
	jsr	FUN_00015b0e	; 0x3854
	bra.w	computeVDistAndHDistToOpponent	; 0x385a
@projection_priority1:
	move.w	(ptrToFighterPriority1).w, a6	; 0x385e
	move.w	a6, (copyOfPtrToFighterPriority2).w	; 0x3862
	bsr.b	updateFighter	; 0x3866
	move.w	(ptrToFighterPriority2).w, a6	; 0x3868
	move.w	a6, (copyOfPtrToFighterPriority1).w	; 0x386c
	bra.b	updateFighter	; 0x3870
@projection_priority2:
	move.w	(ptrToFighterPriority2).w, a6	; 0x3872
	move.w	a6, (copyOfPtrToFighterPriority2).w	; 0x3876
	bsr.w	updateFighter	; 0x387a
	move.w	(ptrToFighterPriority1).w, a6	; 0x387e
	move.w	a6, (copyOfPtrToFighterPriority1).w	; 0x3882
	bra.w	updateFighter	; 0x3886
@projection_ongoing:
	move.w	(copyOfPtrToFighterPriority2).w, a6	; 0x388a
	bsr.w	updateFighter	; 0x388e
	move.w	(copyOfPtrToFighterPriority1).w, a6	; 0x3892

updateFighter:
	tst.b	(648, a6)	; 0x3896
	beq.b	@cpu	; 0x389a
	moveq	#0, d0	; 0x389c
	jsr	updatePlayerState02	; 0x389e
	jmp	(fixFighterPosition).w	; 0x38a4
@cpu:
	tst.b	(areWeOnBonusStage).w	; 0x38a8
	beq.b	@normal_play	; 0x38ac
	move.b	#1, (195, a6)	; 0x38ae
	jmp	(fixFighterPosition).w	; 0x38b4
@normal_play:
	bsr.w	someCpuFighterFunction	; 0x38b8
	moveq	#0, d0	; 0x38bc
	jsr	updateComputerState02	; 0x38be
	jmp	(fixFighterPosition).w	; 0x38c4

computeFightersPriority:
	clr.b	(fightersPriority).w	; 0x38c8
	tst.b	(fighter1Data).w	; 0x38cc
	beq.b	@end	; 0x38d0
	move.b	(LBL_ffff8051).w, d0	; 0x38d2
	tst.b	(player_1_).w	; 0x38d6
	beq.b	@end	; 0x38da
	move.b	(player_1_).w, d1	; 0x38dc
	cmp.b	d1, d0	; 0x38e0
	beq.b	@swap_priorities	; 0x38e2
	bcc.b	@end	; 0x38e4
	move.b	#1, (fightersPriority).w	; 0x38e6
@end:
	move.b	(fightersPriority).w, (otherFightersPriority).w	; 0x38ec
	rts		; 0x38f2
@swap_priorities:
	move.b	(otherFightersPriority).w, (fightersPriority).w	; 0x38f4
	rts		; 0x38fa

computeOldFacesRight:
	tst.b	(areWeOnBonusStage).w	; 0x38fc
	bne.w	@bonus_stage	; 0x3900
	moveq	#0, d2	; 0x3904
	move.w	(player_1_).w, d0	; 0x3906
	sub.w	(LBL_ffff8006).w, d0	; 0x390a
	bpl.b	@fighter_2_is_left	; 0x390e
	moveq	#1, d2	; 0x3910
@fighter_2_is_left:
	addi.w	#$000e, d0	; 0x3912
	cmpi.w	#$001c, d0	; 0x3916
	bls.b	@return1	; 0x391a
	moveq	#8, d0	; 0x391c
	moveq	#0, d1	; 0x391e
	tst.b	d2	; 0x3920
	beq.b	@dont_swap	; 0x3922
	exg	d0, d1	; 0x3924
@dont_swap:
	move.b	d0, (LBL_ffff80c4).w	; 0x3926
	move.b	d1, (player_1_).w	; 0x392a
@return1:
	rts		; 0x392e
@bonus_stage:
	tst.b	(areWeBeforeFight).w	; 0x3930
	bne.b	return120	; 0x3934
	lea	(fighter1Data).w, a6	; 0x3936
	bsr.b	computeOldFacesRightInBonusStages	; 0x393a
	lea	(player_1_).w, a6	; 0x393c

computeOldFacesRightInBonusStages:
	tst.b	(193, a6)	; 0x3940
	bne.b	return120	; 0x3944
	move.w	(654, a6), d0	; 0x3946
	btst	#2, d0	; 0x394a
	beq.b	@not_left	; 0x394e
	clr.b	(196, a6)	; 0x3950
	rts		; 0x3954
@not_left:
	btst	#3, d0	; 0x3956
	beq.b	return120	; 0x395a
	move.b	#8, (196, a6)	; 0x395c

return120:
	rts		; 0x3962

computeFightersDeltas:
	lea	(fighter1Data).w, a6	; 0x3964
	bsr.b	computeFighterDelta	; 0x3968
	lea	(player_1_).w, a6	; 0x396a

computeFighterDelta:
	move.l	(6, a6), d0	; 0x396e
	sub.l	(216, a6), d0	; 0x3972
	move.l	d0, (208, a6)	; 0x3976
	move.l	(10, a6), d0	; 0x397a
	sub.l	(220, a6), d0	; 0x397e
	move.l	d0, (212, a6)	; 0x3982
	rts		; 0x3986

computeVDistAndHDistToOpponent:
	move.w	(player_1_).w, d1	; 0x3988
	sub.w	(LBL_ffff800a).w, d1	; 0x398c
	bpl.b	@positive	; 0x3990
	neg.w	d1	; 0x3992
@positive:
	move.w	d1, (LBL_ffff80ce).w	; 0x3994
	move.w	d1, (player_1_).w	; 0x3998
	move.w	(stageId).w, d0	; 0x399c
	cmpi.w	#$0010, d0	; 0x39a0
	beq.b	bonus_stage_1	; 0x39a4
	cmpi.w	#$0011, d0	; 0x39a6
	beq.b	bonus_stage_2	; 0x39aa
	cmpi.w	#$0012, d0	; 0x39ac
	bne.b	@not_bonus_stage	; 0x39b0
	jmp	FUN_0002e7b2	; 0x39b2
@not_bonus_stage:
	lea	(fighter1Data).w, a0	; 0x39b8
	lea	(player_1_).w, a1	; 0x39bc
	bsr.b	computeHDistToOpponent	; 0x39c0
	exg	a1, a0	; 0x39c2

computeHDistToOpponent:
	move.w	(6, a1), d0	; 0x39c4
	move.w	(200, a1), d1	; 0x39c8
	sub.w	(6, a0), d0	; 0x39cc
	bpl.b	@positive	; 0x39d0
	neg.w	d0	; 0x39d2
@positive:
	sub.w	d1, d0	; 0x39d4
	bpl.b	@return	; 0x39d6
	moveq	#0, d0	; 0x39d8
@return:
	move.w	d0, (204, a0)	; 0x39da
	rts		; 0x39de

bonus_stage_1:
	lea	(fighter1Data).w, a0	; 0x39e0
	bsr.b	computeHDistToOpponentBonusStage01	; 0x39e4
	lea	(player_1_).w, a0	; 0x39e6

computeHDistToOpponentBonusStage01:
	move.w	#$00ec, d0	; 0x39ea
	move.w	(6, a0), d1	; 0x39ee
	move.w	(200, a0), d2	; 0x39f2
	cmpi.w	#$0100, d1	; 0x39f6
	bcs.b	@x_lt_100	; 0x39fa
	move.w	#$0128, d0	; 0x39fc
@x_lt_100:
	sub.w	d1, d0	; 0x3a00
	bpl.b	@positive	; 0x3a02
	neg.w	d0	; 0x3a04
@positive:
	sub.w	d2, d0	; 0x3a06
	bpl.b	@return	; 0x3a08
	moveq	#0, d0	; 0x3a0a
@return:
	move.w	d0, (204, a0)	; 0x3a0c
	rts		; 0x3a10

bonus_stage_2:
	rts		; 0x3a12

someCpuFighterFunction:
	tst.b	(areWeOnTitleScreenOrDemoMode).w	; 0x3a14
	bne.b	@populate_cpu_fields_16f	; 0x3a18
	moveq	#0, d0	; 0x3a1a
	tst.b	(LBL_ffff9938).w	; 0x3a1c
	beq.b	@loc_00003A28	; 0x3a20
	move.b	(641, a6), d0	; 0x3a22
	add.w	d0, d0	; 0x3a26
@loc_00003A28:
	move.w	#$97f0, a0	; 0x3a28
	move.w	(0, a0, d0), (142, a6)	; 0x3a2c
@populate_cpu_fields_16f:
	jmp	(populateCpuFields16f).w	; 0x3a32

updateFightersF06AndF07:
	lea	(fighter1Data).w, a0	; 0x3a36
	bsr.b	updateFighterFE6AndFE7	; 0x3a3a
	lea	(player_1_).w, a0	; 0x3a3c

updateFighterFE6AndFE7:
	cmpi.w	#$00c0, (10, a0)	; 0x3a40
	bne.b	@not_on_ground	; 0x3a46
	move.w	(654, a0), d0	; 0x3a48
	andi.w	#$000f, d0	; 0x3a4c
	beq.b	@no_keys	; 0x3a50
	btst	#1, d0	; 0x3a52
	bne.b	@no_keys	; 0x3a56
	btst	#0, d0	; 0x3a58
	bne.b	@not_on_ground	; 0x3a5c
	andi.w	#$000c, d0	; 0x3a5e
	beq.b	@no_keys	; 0x3a62
	move.b	(102, a0), d0	; 0x3a64
	or.b	(103, a0), d0	; 0x3a68
	beq.b	@not_on_ground	; 0x3a6c
@no_keys:
	tst.b	(230, a0)	; 0x3a6e
	beq.b	@counter_over	; 0x3a72
	subq.b	#1, (230, a0)	; 0x3a74
	bne.b	@exit	; 0x3a78
	move.b	#1, (231, a0)	; 0x3a7a
@counter_over:
	jsr	(random).w	; 0x3a80
	andi.w	#$000f, d0	; 0x3a84
	move.b	(14992, pc, d0.w), (230, a0)	; 0x3a88
@exit:
	rts		; 0x3a8e
	dc.b	$3c, $3c, $3c, $50, $50, $50, $64, $64, $78, $78, $8c, $8c, $a0, $a0, $b4, $b4	; 0x3a90
@not_on_ground:
	clr.b	(231, a0)	; 0x3aa0
	clr.b	(230, a0)	; 0x3aa4
	rts		; 0x3aa8

EntryPoint:
	tst.l	ctrl1Control	; 0x3aaa
	bne.b	@skip_expansion_port	; 0x3ab0
	tst.w	expansionPortControl	; 0x3ab2
@skip_expansion_port:
	bne.b	@skip_init	; 0x3ab8
	lea	($3b38, pc), a5	; 0x3aba
	movem.w	(a5)+, d7/d6/d5	; 0x3abe
	movem.l	(a5)+, a4/a3/a2/a1/a0	; 0x3ac2
	move.b	(-4351, a1), d0	; 0x3ac6
	andi.b	#$0f, d0	; 0x3aca
	beq.b	@no_TMSS	; 0x3ace
	move.l	#$53454741, (12032, a1)	; 0x3ad0
@no_TMSS:
	move.w	(a4), d0	; 0x3ad8
	moveq	#0, d0	; 0x3ada
	move.l	d0, a6	; 0x3adc
	move.l	a6, usp	; 0x3ade
	moveq	#$0017, d1	; 0x3ae0
@next1:
	move.b	(a5)+, d5	; 0x3ae2
	move.w	d5, (a4)	; 0x3ae4
	add.w	d7, d5	; 0x3ae6
	dbf	d1, @next1	; 0x3ae8
	move.l	(a5)+, (a4)	; 0x3aec
	move.w	d0, (a3)	; 0x3aee
	move.w	d7, (a1)	; 0x3af0
	move.w	d7, (a2)	; 0x3af2
@next2:
	btst	d0, (a1)	; 0x3af4
	bne.b	@next2	; 0x3af6
	moveq	#$0025, d2	; 0x3af8
@next3:
	move.b	(a5)+, (a0)+	; 0x3afa
	dbf	d2, @next3	; 0x3afc
	move.w	d0, (a2)	; 0x3b00
	move.w	d0, (a1)	; 0x3b02
	move.w	d7, (a2)	; 0x3b04
@next4:
	move.l	d0, -(a6)	; 0x3b06
	dbf	d6, @next4	; 0x3b08
	move.l	(a5)+, (a4)	; 0x3b0c
	move.l	(a5)+, (a4)	; 0x3b0e
	moveq	#$001f, d3	; 0x3b10
@next5:
	move.l	d0, (a3)	; 0x3b12
	dbf	d3, @next5	; 0x3b14
	move.l	(a5)+, (a4)	; 0x3b18
	moveq	#$0013, d4	; 0x3b1a
@next6:
	move.l	d0, (a3)	; 0x3b1c
	dbf	d4, @next6	; 0x3b1e
	moveq	#3, d5	; 0x3b22
@next7:
	move.b	(a5)+, (17, a3)	; 0x3b24
	dbf	d5, @next7	; 0x3b28
	move.w	d0, (a2)	; 0x3b2c
	movem.l	(a6), a6/a5/a4/a3/a2/a1/a0/d7/d6/d5/d4/d3/d2/d1/d0	; 0x3b2e
	move.w	#$2700, sr	; 0x3b32
@skip_init:
	bra.b	startupCode	; 0x3b36

initRegistersValues:
	dc.w	$8000	; 0x3b38
	dc.w	$3fff	; 0x3b3a
	dc.w	$0100	; 0x3b3c
	dc.l	Z80_ramStart	; 0x3b3e
	dc.l	Z80_busRequest	; 0x3b42
	dc.l	Z80_reset	; 0x3b46
	dc.l	VdpDataPort	; 0x3b4a
	dc.l	VdpCtrlPort	; 0x3b4e
	dc.b	$04	; 0x3b52
	dc.b	$14	; 0x3b53
	dc.b	$30	; 0x3b54
	dc.b	$3c	; 0x3b55
	dc.b	$07	; 0x3b56
	dc.b	$6c	; 0x3b57
	dc.b	$00	; 0x3b58
	dc.b	$00	; 0x3b59
	dc.b	$00	; 0x3b5a
	dc.b	$00	; 0x3b5b
	dc.b	$ff	; 0x3b5c
	dc.b	$00	; 0x3b5d
	dc.b	$81	; 0x3b5e
	dc.b	$37	; 0x3b5f
	dc.b	$00	; 0x3b60
	dc.b	$01	; 0x3b61
	dc.b	$01	; 0x3b62
	dc.b	$00	; 0x3b63
	dc.b	$00	; 0x3b64
	dc.b	$ff	; 0x3b65
	dc.b	$ff	; 0x3b66
	dc.b	$00	; 0x3b67
	dc.b	$00	; 0x3b68
	dc.b	$80	; 0x3b69
	dc.l	$40000080	; 0x3b6a

z80InitCode:
	dc.b	$af, $01, $d9, $1f, $11, $27, $00, $21, $26, $00, $f9, $77, $ed, $b0, $dd, $e1, $fd, $e1, $ed, $47, $ed, $4f, $d1, $e1, $f1, $08, $d9, $c1, $d1, $e1, $f1, $f9, $f3, $ed, $56, $36, $e9, $e9	; 0x3b6e

DAT_3b9a:
	dc.l	$81048f02	; 0x3b94
	dc.l	$c0000000	; 0x3b98
	dc.l	$40000010	; 0x3b9c
	dc.b	$9f	; 0x3ba0
	dc.b	$bf	; 0x3ba1
	dc.b	$df	; 0x3ba2
	dc.b	$ff	; 0x3ba3

startupCode:
	tst.w	VdpCtrlPort	; 0x3ba4
@wait:
	move.w	VdpCtrlPort, d1	; 0x3baa
	btst	#1, d1	; 0x3bb0
	bne.b	@wait	; 0x3bb4
	btst	#6, IoCtrlExt	; 0x3bb6
	beq.b	@verify_checksums	; 0x3bbe
	cmpi.l	#$696e6974, initCheck	; 0x3bc0
	beq.w	@already_initialized	; 0x3bca
@verify_checksums:
	lea	(ROM_start).w, a0	; 0x3bce
	lea	(bankChecksums).w, a1	; 0x3bd2
	moveq	#7, d2	; 0x3bd6
	moveq	#-1, d1	; 0x3bd8
@next9:
	moveq	#0, d0	; 0x3bda
@next8:
	add.l	(a0)+, d0	; 0x3bdc
	add.l	(a0)+, d0	; 0x3bde
	nop		; 0x3be0
	nop		; 0x3be2
	nop		; 0x3be4
	nop		; 0x3be6
	nop		; 0x3be8
	nop		; 0x3bea
	nop		; 0x3bec
	nop		; 0x3bee
	nop		; 0x3bf0
	nop		; 0x3bf2
	nop		; 0x3bf4
	nop		; 0x3bf6
	nop		; 0x3bf8
	nop		; 0x3bfa
	nop		; 0x3bfc
	nop		; 0x3bfe
	nop		; 0x3c00
	nop		; 0x3c02
@next11:
	nop		; 0x3c04
@next10:
	nop		; 0x3c06
	nop		; 0x3c08
	nop		; 0x3c0a
	nop		; 0x3c0c
	nop		; 0x3c0e
	nop		; 0x3c10
	nop		; 0x3c12
	nop		; 0x3c14
	bra.b	@checksum_passed	; 0x3c16
@red_screen_of_death:
	move.l	#$c0000000, VdpCtrlPort	; 0x3c18
	move.w	#$003f, d7	; 0x3c22
@next12:
	move.w	#$000e, VdpDataPort	; 0x3c26
	dbf	d7, @next12	; 0x3c2e
	move.w	#$8140, VdpCtrlPort	; 0x3c32
@wait_eternally:
	bra.b	@wait_eternally	; 0x3c3a
@checksum_passed:
	lea	(VdpRegistersCache).w, a0	; 0x3c3c
	move.w	#$00ff, d1	; 0x3c40
	moveq	#0, d0	; 0x3c44
@next13:
	move.l	d0, (a0)+	; 0x3c46
	dbf	d1, @next13	; 0x3c48
	lea	highScoreNames, a0	; 0x3c4c
	lea	(highScoreNamesBuffer).w, a1	; 0x3c52
	move.w	#$0066, d1	; 0x3c56
@next14:
	move.b	(a0)+, (a1)+	; 0x3c5a
	dbf	d1, @next14	; 0x3c5c
	move.b	versionRegister, (copyOfVersionRegister).w	; 0x3c60
	move.b	#2, LBL_a130f1	; 0x3c68
	move.b	#1, (currentPageInBank1).w	; 0x3c70
	move.b	#1, MapperBank1	; 0x3c76
	move.b	#2, (currentPageInBank2).w	; 0x3c7e
	move.b	#2, MapperBank2	; 0x3c84
	move.b	#3, (currentPageInBank3).w	; 0x3c8c
	move.b	#3, MapperBank3	; 0x3c92
	move.b	#4, (currentPageInBank4).w	; 0x3c9a
	move.b	#4, MapperBank4	; 0x3ca0
	move.b	#5, (currentPageInBank5).w	; 0x3ca8
	move.b	#5, MapperBank5	; 0x3cae
	move.b	#6, (currentPageInBank6).w	; 0x3cb6
	move.b	#6, MapperBank6	; 0x3cbc
	move.b	#7, (currentPageInBank7).w	; 0x3cc4
	move.b	#7, mapperBank7	; 0x3cca
	move.l	#$696e6974, initCheck	; 0x3cd2
@already_initialized:
	lea	VdpDataPort, a5	; 0x3cdc
	lea	dataBuffer, a0	; 0x3ce2
	move.w	#$3eff, d1	; 0x3ce8
	moveq	#0, d0	; 0x3cec
@next15:
	move.l	d0, (a0)+	; 0x3cee
	dbf	d1, @next15	; 0x3cf0
	jsr	($49ac, pc)	; 0x3cf4
	jsr	($4874, pc)	; 0x3cf8
	jsr	($4c44, pc)	; 0x3cfc
	lea	(LBL_ffffbd7c).w, a0	; 0x3d00
	lea	(LBL_ffffbef0).w, a1	; 0x3d04
	move.w	#7, d1	; 0x3d08
@next16:
	move.l	a1, (a0)	; 0x3d0c
	lea	(16, a0), a0	; 0x3d0e
	lea	(256, a1), a1	; 0x3d12
	dbf	d1, @next16	; 0x3d16
	move.w	#$9faa, (ptrCurrentSpriteInSatBuffer).w	; 0x3d1a
	move.w	#$a1aa, (ptrDmaQueueCurrentEntry).w	; 0x3d20
	move.w	#$a2aa, (ptrLastUpdatableBgArea).w	; 0x3d26
	move.b	#$0e, (fadingAttenuation).w	; 0x3d2c
	move.l	#$000063b2, a0	; 0x3d32
	move.w	#0, d0	; 0x3d38
	trap	#0	; 0x3d3c
	andi	#$f8ff, sr	; 0x3d3e

main_loop_170:
	clr.b	(isVIntProcessed).w	; 0x3d42

wait_vint_170:
	tst.b	(isVIntProcessed).w	; 0x3d46
	beq.b	wait_vint_170	; 0x3d4a
	move.l	a5, -(a7)	; 0x3d4c
	lea	Z80_busRequest, a4	; 0x3d4e
	move.w	#0, d6	; 0x3d54
	move.w	#$0100, d7	; 0x3d58
	move.w	(currentSfx).w, d0	; 0x3d5c
	cmp.w	(posInSfxQueue).w, d0	; 0x3d60
	beq.b	pos_is_zero_170	; 0x3d64
	addq.w	#2, d0	; 0x3d66
	andi.w	#$000e, d0	; 0x3d68
	move.w	d0, (currentSfx).w	; 0x3d6c

process_sfx_queue:
	lea	(sfxQueue).w, a0	; 0x3d70
	adda.w	d0, a0	; 0x3d74
	move.b	(a0), d1	; 0x3d76
	move.b	(1, a0), d0	; 0x3d78
	lea	LBL_a01ffe, a1	; 0x3d7c
	andi.w	#1, d1	; 0x3d82
	adda.w	d1, a1	; 0x3d86
	move.w	d7, (a4)	; 0x3d88

wait_sound_driver_170:
	btst	d6, (a4)	; 0x3d8a
	bne.b	wait_sound_driver_170	; 0x3d8c
	move.b	d0, (a1)	; 0x3d8e
	move.w	d6, (a4)	; 0x3d90

pos_is_zero_170:
	move.w	(currentBgm).w, d0	; 0x3d92
	cmp.w	(posInBgmQueue).w, d0	; 0x3d96
	beq.b	dont_change_bgm	; 0x3d9a
	addq.w	#2, d0	; 0x3d9c
	andi.w	#$000e, d0	; 0x3d9e
	move.w	d0, (currentBgm).w	; 0x3da2
	lea	(LBL_ffffa5d0).w, a0	; 0x3da6
	adda.w	d0, a0	; 0x3daa
	move.b	(a0), d0	; 0x3dac
	move.b	(1, a0), d1	; 0x3dae
	jsr	($4dfc, pc)	; 0x3db2

dont_change_bgm:
	jsr	($4d7e, pc)	; 0x3db6
	move.l	(a7)+, a5	; 0x3dba
	addq.b	#1, (object2And3Priority).w	; 0x3dbc

process_command_queue:
	lea	(commandsQueue).w, a0	; 0x3dc0
	moveq	#7, d0	; 0x3dc4

next170:
	move.b	(a0), d1	; 0x3dc6
	cmpi.b	#4, d1	; 0x3dc8
	beq.b	command_type_4_140	; 0x3dcc
	cmpi.b	#8, d1	; 0x3dce
	beq.w	command_type_8_141	; 0x3dd2

command_type_1_or_2:
	cmpi.b	#1, d1	; 0x3dd6
	bne.b	command_type_2	; 0x3dda
	subq.b	#1, (1, a0)	; 0x3ddc
	bne.b	command_type_2	; 0x3de0
	move.b	#4, (a0)	; 0x3de2

command_type_2:
	lea	(16, a0), a0	; 0x3de6
	dbf	d0, next170	; 0x3dea
	tst.b	(currentSpriteLink).w	; 0x3dee
	beq.b	skip_130	; 0x3df2
	move.w	(ptrCurrentSpriteInSatBuffer).w, a0	; 0x3df4
	clr.b	(-5, a0)	; 0x3df8
	bra.b	skip_130	; 0x3dfc
	tst.b	(currentSpriteLink).w	; 0x3dfe
	beq.b	skip_finalize_sat_100	; 0x3e02
	move.w	(ptrCurrentSpriteInSatBuffer).w, a0	; 0x3e04
	move.b	#$3f, (-5, a0)	; 0x3e08

skip_finalize_sat_100:
	lea	(LBL_ffffa1a2).w, a0	; 0x3e0e
	move.w	(8, a5), d0	; 0x3e12
	lsr.w	#8, d0	; 0x3e16
	addi.w	#$0080, d0	; 0x3e18
	move.w	d0, (a0)+	; 0x3e1c
	move.w	#0, (a0)+	; 0x3e1e
	move.w	#$8002, (a0)+	; 0x3e22
	move.w	#$0080, (a0)	; 0x3e26

skip_130:
	jsr	FUN_00030a46	; 0x3e2a
	jsr	fadeInUpdate	; 0x3e30
	bra.w	main_loop_170	; 0x3e36

command_type_4_140:
	move.w	d0, -(a7)	; 0x3e3a
	move.w	a7, (savingSP).w	; 0x3e3c
	move.w	a0, (savingCurrentCommandSlot).w	; 0x3e40
	move.b	#$10, (a0)	; 0x3e44
	move.l	(4, a0), -(a7)	; 0x3e48
	move.w	(2, a0), -(a7)	; 0x3e4c
	move.l	(8, a0), a1	; 0x3e50
	move.l	a1, usp	; 0x3e54
	rte		; 0x3e56

command_type_8_141:
	move.w	d0, -(a7)	; 0x3e58
	move.w	a7, (savingSP).w	; 0x3e5a
	move.w	a0, (savingCurrentCommandSlot).w	; 0x3e5e
	move.b	#$10, (a0)	; 0x3e62
	move.l	(4, a0), a1	; 0x3e66
	move.l	(12, a0), a4	; 0x3e6a
	move.l	a4, usp	; 0x3e6e
	andi	#$dfff, sr	; 0x3e70
	jmp	(a1)	; 0x3e74

Trap00:
	lea	(commandsQueue).w, a1	; 0x3e76
	move.b	#8, (0, a1, d0)	; 0x3e7a
	move.l	a0, (4, a1, d0)	; 0x3e80
	rte		; 0x3e84

Trap01:
	move.w	(savingCurrentCommandSlot).w, a0	; 0x3e86
	move.b	#0, d1	; 0x3e8a
	move.b	d1, (a0)	; 0x3e8e
	move.w	(savingSP).w, a7	; 0x3e90
	move.w	(a7)+, d0	; 0x3e94
	jmp	($3dd6, pc)	; 0x3e96

Trap02:
	lea	(commandsQueue).w, a1	; 0x3e9a
	move.b	#0, (0, a1, d0)	; 0x3e9e
	rte		; 0x3ea4

Trap03:
	move.w	(savingCurrentCommandSlot).w, a0	; 0x3ea6
	move.b	#1, d1	; 0x3eaa
	move.b	d1, (a0)	; 0x3eae
	move.b	d0, (1, a0)	; 0x3eb0
	move.l	usp, a1	; 0x3eb4
	move.l	a1, (8, a0)	; 0x3eb6
	move.w	(a7)+, (2, a0)	; 0x3eba
	move.l	(a7)+, (4, a0)	; 0x3ebe
	move.w	(savingSP).w, a7	; 0x3ec2
	move.w	(a7)+, d0	; 0x3ec6
	jmp	($3dd6, pc)	; 0x3ec8

Trap04:
	lea	(commandsQueue).w, a1	; 0x3ecc
	tst.b	(0, a1, d0)	; 0x3ed0
	beq.b	no_command	; 0x3ed4
	bset	#1, (0, a1, d0)	; 0x3ed6

no_command:
	rte		; 0x3edc

Trap05:
	lea	(commandsQueue).w, a1	; 0x3ede
	bclr	#1, (0, a1, d0)	; 0x3ee2
	rte		; 0x3ee8

VInt:
	movem.l	d0/d1/d2/d3/d4/d5/d6/d7/a0/a1/a2/a3/a4/a5/a6, -(a7)	; 0x3eea
	lea	Z80_busRequest, a4	; 0x3eee
	lea	VdpDataPort, a5	; 0x3ef4
	lea	(4, a5), a6	; 0x3efa
	move.w	#0, d6	; 0x3efe
	move.w	#$0100, d7	; 0x3f02
	tst.b	(isVIntProcessed).w	; 0x3f06
	bne.w	skip_hinit_funcs	; 0x3f0a
	jsr	($488a, pc)	; 0x3f0e
	move.w	(hintInitFun).w, d0	; 0x3f12
	beq.b	no_hinit_func	; 0x3f16
	bpl.b	skip1	; 0x3f18
	move.w	#$8ad7, d5	; 0x3f1a
	move.w	d5, (VdpRegistersCache).w	; 0x3f1e
	move.w	d5, (4, a5)	; 0x3f22
	move.w	#2, d0	; 0x3f26

skip1:
	move.w	d0, (hintFun).w	; 0x3f2a
	clr.w	(hintInitFun).w	; 0x3f2e
	ori.b	#$10, (VdpRegistersCache).w	; 0x3f32
	move.w	(VdpRegistersCache).w, (a6)	; 0x3f38

no_hinit_func:
	move.w	(hintFun).w, d0	; 0x3f3c
	move.w	(hIntFunctions, pc, d0.w), d0	; 0x3f40
	jmp	(hIntFunctions, pc, d0.w)	; 0x3f44

hIntFunctions:
	dc.w	hInt00-hIntFunctions	; 0x3f48
	dc.w	hInt02-hIntFunctions	; 0x3f4a
	dc.w	hInt04-hIntFunctions	; 0x3f4c
	dc.w	hInt06-hIntFunctions	; 0x3f4e
	dc.w	hInt08-hIntFunctions	; 0x3f50

hInt08:
	clr.b	(hintCounterToSetFlag).w	; 0x3f52
	move.w	#$8a3f, (a6)	; 0x3f56
	move.l	(planeAVScrollAlt).w, (vsRamCache2).w	; 0x3f5a
	st	(flagProcessVSRAM).w	; 0x3f60

hInt00:
	jsr	($4a90, pc)	; 0x3f64
	jsr	($4aa6, pc)	; 0x3f68
	jsr	($4b42, pc)	; 0x3f6c
	jsr	($49ec, pc)	; 0x3f70
	jsr	($4b8e, pc)	; 0x3f74
	jsr	($4c0a, pc)	; 0x3f78
	bra.w	hIntOther00	; 0x3f7c

hInt04:
	clr.b	(hintCounterToSetFlag).w	; 0x3f80
	lea	(hintCounterSetter3).w, a0	; 0x3f84
	lea	(hintCounterSetter2).w, a1	; 0x3f88
	move.l	(a0)+, (a1)+	; 0x3f8c
	move.l	(a0)+, (a1)+	; 0x3f8e
	move.l	(a0), (a1)	; 0x3f90
	move.w	(hintCounterSetter2).w, (a6)	; 0x3f92
	lea	(planeAVScroll).w, a0	; 0x3f96
	lea	(vsRamCache1).w, a1	; 0x3f9a
	move.l	(a0)+, (a1)+	; 0x3f9e
	move.l	(a0)+, (a1)+	; 0x3fa0
	move.l	(a0)+, (a1)+	; 0x3fa2
	move.l	(a0), (a1)	; 0x3fa4

hInt02:
	move.l	(windowVPosSetter2).w, (windowVPosSetter).w	; 0x3fa6
	move.w	(windowVPosSetter).w, (a6)	; 0x3fac
	andi.b	#$bf, (VdpRegistersCache).w	; 0x3fb0
	move.w	(VdpRegistersCache).w, (a6)	; 0x3fb6
	jsr	($4a9a, pc)	; 0x3fba
	jsr	($4afe, pc)	; 0x3fbe
	jsr	($4b42, pc)	; 0x3fc2
	jsr	($49ec, pc)	; 0x3fc6
	jsr	($4b8e, pc)	; 0x3fca
	jsr	($4c0a, pc)	; 0x3fce
	ori.b	#$40, (VdpRegistersCache).w	; 0x3fd2
	move.w	(VdpRegistersCache).w, (a6)	; 0x3fd8
	bra.b	hIntOther00	; 0x3fdc

hInt06:
	move.l	(windowVPosSetter2).w, (windowVPosSetter).w	; 0x3fde
	move.w	(windowVPosSetter).w, (a6)	; 0x3fe4
	andi.b	#$bf, (VdpRegistersCache).w	; 0x3fe8
	move.w	(VdpRegistersCache).w, (a6)	; 0x3fee
	jsr	($4a9a, pc)	; 0x3ff2
	jsr	($4af2, pc)	; 0x3ff6
	jsr	($4b42, pc)	; 0x3ffa
	jsr	($49ec, pc)	; 0x3ffe
	jsr	($4b8e, pc)	; 0x4002
	jsr	($4c0a, pc)	; 0x4006
	ori.b	#$40, (VdpRegistersCache).w	; 0x400a
	move.w	(VdpRegistersCache).w, (a6)	; 0x4010
	bra.b	hIntOther00	; 0x4014

skip_hinit_funcs:
	move.w	(hintFun).w, d0	; 0x4016
	move.w	(hIntOtherFunctions, pc, d0.w), d0	; 0x401a
	jmp	(hIntOtherFunctions, pc, d0.w)	; 0x401e

hIntOtherFunctions:
	dc.w	hIntOther00-hIntOtherFunctions	; 0x4022
	dc.w	hIntOther02-hIntOtherFunctions	; 0x4024
	dc.w	hIntOther04-hIntOtherFunctions	; 0x4026
	dc.w	hIntOther02-hIntOtherFunctions	; 0x4028
	dc.w	hIntOther08-hIntOtherFunctions	; 0x402a

hIntOther04:
	clr.b	(hintCounterToSetFlag).w	; 0x402c
	move.w	(hintCounterSetter2).w, (a6)	; 0x4030
	jsr	($4a9a, pc)	; 0x4034

hIntOther02:
	move.w	(windowVPosSetter).w, (a6)	; 0x4038
	bra.b	hIntOther00	; 0x403c

hIntOther08:
	clr.b	(hintCounterToSetFlag).w	; 0x403e
	move.w	#$8a3f, (a6)	; 0x4042

hIntOther00:
	cmpi.w	#4, (hintFun).w	; 0x4046
	bne.b	end_vint	; 0x404c
	move.w	(VdpRegistersCache).w, d0	; 0x404e
	andi.w	#$0040, d0	; 0x4052
	beq.b	end_vint	; 0x4056

wait_end_vblank:
	move.w	(a6), d0	; 0x4058
	andi.w	#8, d0	; 0x405a
	bne.b	wait_end_vblank	; 0x405e
	move.w	(hintCounter1).w, (a6)	; 0x4060

end_vint:
	addq.b	#1, (frameCounterAlt).w	; 0x4064
	st	(isVIntProcessed).w	; 0x4068
	movem.l	(a7)+, a6/a5/a4/a3/a2/a1/a0/d7/d6/d5/d4/d3/d2/d1/d0	; 0x406c
	rte		; 0x4070

HInt:
	movem.l	d0/a5/a6, -(a7)	; 0x4072
	lea	VdpDataPort, a5	; 0x4076
	lea	(4, a5), a6	; 0x407c
	move.w	(hintFun).w, d0	; 0x4080
	move.w	(hIntAlsoOtherFunction, pc, d0.w), d0	; 0x4084
	jsr	(hIntAlsoOtherFunction, pc, d0.w)	; 0x4088
	movem.l	(a7)+, a6/a5/d0	; 0x408c
	rte		; 0x4090

hIntAlsoOtherFunction:
	dc.w	hIntAlsoOther00-hIntAlsoOtherFunction	; 0x4092
	dc.w	hIntAlsoOther02-hIntAlsoOtherFunction	; 0x4094
	dc.w	hIntAlsoOther04-hIntAlsoOtherFunction	; 0x4096
	dc.w	hIntAlsoOther02-hIntAlsoOtherFunction	; 0x4098
	dc.w	hIntAlsoOther08-hIntAlsoOtherFunction	; 0x409a

hIntAlsoOther04:
	tst.b	(hintCounterToSetFlag).w	; 0x409c
	bmi.b	send_vsram_cache_4	; 0x40a0
	bne.b	send_vsram_cache_3	; 0x40a2
	addq.b	#1, (hintCounterToSetFlag).w	; 0x40a4
	move.l	#$40000010, (a6)	; VSRAM write to 0000	; 0x40a8
	move.l	(vsRamCache2).w, (a5)	; 0x40ae
	move.w	(LBL_ffffa628).w, (a6)	; 0x40b2

hIntAlsoOther02:
	move.w	(LBL_ffffa62e).w, (a6)	; 0x40b6
	rts		; 0x40ba

send_vsram_cache_3:
	st	(hintCounterToSetFlag).w	; 0x40bc
	move.l	#$40000010, (a6)	; VSRAM write to 0000	; 0x40c0
	move.l	(vsRamCache3).w, (a5)	; 0x40c6
	move.w	#$8aff, (a6)	; 0x40ca
	rts		; 0x40ce

send_vsram_cache_4:
	move.l	#$40000010, (a6)	; VSRAM write to 0000	; 0x40d0
	move.l	(vsRamCache4).w, (a5)	; 0x40d6

hIntAlsoOther00:
	rts		; 0x40da

hIntAlsoOther08:
	tst.b	(hintCounterToSetFlag).w	; 0x40dc
	bmi.b	hint_counter_negative	; 0x40e0
	bne.b	hint_counter_set	; 0x40e2
	addq.b	#1, (hintCounterToSetFlag).w	; 0x40e4
	move.l	#$40000010, (a6)	; VSRAM write to 0000	; 0x40e8
	move.l	(vsRamCache2).w, (a5)	; 0x40ee
	move.w	#$8a1f, (a6)	; 0x40f2
	rts		; 0x40f6

hint_counter_set:
	st	(hintCounterToSetFlag).w	; 0x40f8
	move.w	#$8aff, (a6)	; 0x40fc
	rts		; 0x4100

hint_counter_negative:
	move.l	#$40000010, (a6)	; VSRAM write to 0000	; 0x4102
	move.l	#$01800180, (a5)	; 0x4108
	rts		; 0x410e

ExtInt:
	nop		; 0x4110
	rte		; 0x4112

Error:
	nop		; 0x4114
	rte		; 0x4116
	include	"debug.asm"	; 0x-1

fadeInUpdate:
	move.b	(fadingDelta).w, d0	; 0x477c
	beq.b	@return	; 0x4780
	subq.b	#1, (fadingTimer).w	; 0x4782
	bne.b	@done	; 0x4786
	move.b	#4, (fadingTimer).w	; 0x4788
	add.b	d0, (fadingAttenuation).w	; 0x478e
	beq.b	@level_0	; 0x4792
	cmpi.b	#$0e, (fadingAttenuation).w	; 0x4794
	bne.b	@not_level_e	; 0x479a
@level_0:
	clr.b	(fadingDelta).w	; 0x479c
	bra.b	@not_level_e	; 0x47a0
@done:
	tst.b	(flagProcessPalettes).w	; 0x47a2
	beq.b	@return	; 0x47a6
@not_level_e:
	bsr.b	subtractComponentsToAllColors	; 0x47a8
	st	(flagProcessPalettes).w	; 0x47aa
@return:
	rts		; 0x47ae

subtractComponentsToAllColors:
	lea	(rawPalettes).w, a0	; 0x47b0
	lea	(currentPalettes).w, a1	; 0x47b4
	moveq	#0, d0	; 0x47b8
	move.b	(fadingAttenuation).w, d0	; 0x47ba
	move.w	d0, d2	; 0x47be
	lsl.w	#4, d0	; 0x47c0
	move.w	d0, d1	; 0x47c2
	lsl.w	#4, d0	; 0x47c4
	moveq	#$003f, d7	; 0x47c6

subtractComponents:
	move.w	(a0)+, d3	; 0x47c8
	beq.b	@nothing_to_do	; 0x47ca
	move.w	d3, d4	; 0x47cc
	move.w	d3, d5	; 0x47ce
	andi.w	#$0e00, d3	; 0x47d0
	sub.w	d0, d3	; 0x47d4
	bcc.b	@green	; 0x47d6
	moveq	#0, d3	; 0x47d8
@green:
	andi.w	#$00e0, d4	; 0x47da
	sub.w	d1, d4	; 0x47de
	bcc.b	@red	; 0x47e0
	moveq	#0, d4	; 0x47e2
@red:
	andi.w	#$000e, d5	; 0x47e4
	sub.w	d2, d5	; 0x47e8
	bcc.b	@set_color	; 0x47ea
	moveq	#0, d5	; 0x47ec
@set_color:
	or.w	d4, d3	; 0x47ee
	or.w	d5, d3	; 0x47f0
@nothing_to_do:
	move.w	d3, (a1)+	; 0x47f2
	dbf	d7, subtractComponents	; 0x47f4
	rts		; 0x47f8

getRGBComponents:
	move.l	a0, a1	; 0x47fa
	move.w	d0, d1	; 0x47fc
	move.w	d0, d2	; 0x47fe
	andi.w	#$0e00, d0	; 0x4800
	andi.w	#$00e0, d1	; 0x4804
	andi.w	#$000e, d2	; 0x4808
	bsr.b	subtractComponents	; 0x480c
	st	(flagProcessPalettes).w	; 0x480e
	rts		; 0x4812

somethingToDoWithPalettes:
	moveq	#0, d4	; 0x4814
	moveq	#0, d5	; 0x4816
	move.b	(a0), d1	; 0x4818
	move.b	(1, a0), d2	; 0x481a
	move.b	d2, d3	; 0x481e
	andi.b	#$0f, d2	; 0x4820
	lsr.b	#4, d3	; 0x4824
	add.b	d1, d5	; 0x4826
	add.b	d2, d5	; 0x4828
	add.b	d3, d5	; 0x482a
	moveq	#0, d4	; 0x482c
@loop:
	subq.b	#3, d5	; 0x482e
	bcs.b	@exit	; 0x4830
	addq.b	#1, d4	; 0x4832
	bra.b	@loop	; 0x4834
@exit:
	andi.w	#$001e, d4	; 0x4836
	cmp.b	d1, d4	; 0x483a
	beq.b	@equals	; 0x483c
	bcc.b	@adjust	; 0x483e
	subq.b	#2, d1	; 0x4840
	bra.b	@equals	; 0x4842
@adjust:
	addq.b	#2, d1	; 0x4844
@equals:
	cmp.b	d2, d4	; 0x4846
	beq.b	@equals2	; 0x4848
	bcc.b	@adjust2	; 0x484a
	subq.b	#2, d2	; 0x484c
	bra.b	@equals2	; 0x484e
@adjust2:
	addq.b	#2, d2	; 0x4850
@equals2:
	cmp.b	d3, d4	; 0x4852
	beq.b	@equals3	; 0x4854
	bcc.b	@adjust3	; 0x4856
	subq.b	#2, d3	; 0x4858
	bra.b	@equals3	; 0x485a
@adjust3:
	addq.b	#2, d3	; 0x485c
@equals3:
	lsl.b	#4, d3	; 0x485e
	add.b	d3, d2	; 0x4860
	move.b	d1, (a0)+	; 0x4862
	move.b	d2, (a0)+	; 0x4864
	dbf	d0, somethingToDoWithPalettes	; 0x4866
	st	(flagProcessPalettes).w	; 0x486a
	subq.b	#1, (LBL_ffffa610).w	; 0x486e
	rts		; 0x4872
	include	"inputs.asm"	; 0x-1

resetVdp:
	jsr	(setVdpRegs).w	; 0x49ac
	bsr.b	clearVsRam	; 0x49b0
	bsr.b	clearCRam	; 0x49b2
	move.l	#$40000080, d1	; DMA VRAM write    :
			; 	src=0xFF0000
			; 	dest=0000
			; 	length=16	; 0x49b4
	move.l	#$94ff93ff, d0	; 0x49ba
	jmp	(doDmaAndWaitCompletion).w	; 0x49c0

clearCRam:
	move.l	#$c0000000, (4, a5)	; 0x49c4
	moveq	#$001f, d7	; 0x49cc
	moveq	#0, d0	; 0x49ce
@next:
	move.l	d0, (a5)	; 0x49d0
	dbf	d7, @next	; 0x49d2
	rts		; 0x49d6

clearVsRam:
	move.l	#$40000010, (4, a5)	; VSRAM write to 0000	; 0x49d8
	moveq	#$0013, d7	; 0x49e0
	moveq	#0, d0	; 0x49e2
@next:
	move.l	d0, (a5)	; 0x49e4
	dbf	d7, @next	; 0x49e6
	rts		; 0x49ea

processPalettes:
	tst.b	(flagProcessPalettes).w	; 0x49ec
	beq.b	@return	; 0x49f0
	clr.b	(flagProcessPalettes).w	; 0x49f2
	btst	#6, (copyOfVersionRegister).w	; 0x49f6
	beq.b	@nowait	; 0x49fc
	move.w	#$0628, d7	; 0x49fe
@wait:
	dbf	d7, @wait	; 0x4a02
@nowait:
	tst.b	(fadingAttenuation).w	; 0x4a06
	bne.b	@copy_current_palettes	; 0x4a0a
	ori.b	#$10, (VdpRegistersCache).w	; 0x4a0c
	move.w	(VdpRegistersCache).w, (a6)	; 0x4a12
	move.w	d7, (a4)	; 0x4a16
	move.l	#$94009340, (a6)	; 0x4a18
	move.l	#$96cd9505, (a6)	; 0x4a1e
	move.w	#$977f, (a6)	; 0x4a24
	move.w	#$c000, (a6)	; 0x4a28
	move.w	#$0080, -(a7)	; 0x4a2c
@wait_z80:
	btst	d6, (a4)	; 0x4a30
	bne.b	@wait_z80	; 0x4a32
	move.w	(a7)+, (a6)	; 0x4a34
	move.w	d6, (a4)	; 0x4a36
	andi.b	#$ef, (VdpRegistersCache).w	; 0x4a38
	move.w	(VdpRegistersCache).w, (a6)	; 0x4a3e
	move.l	#$c0000000, (a6)	; 0x4a42
	move.w	(rawPalettes).w, (a5)	; 0x4a48
@return:
	rts		; 0x4a4c
@copy_current_palettes:
	ori.b	#$10, (VdpRegistersCache).w	; 0x4a4e
	move.w	(VdpRegistersCache).w, (a6)	; 0x4a54
	move.w	d7, (a4)	; 0x4a58
	move.l	#$94009340, (a6)	; 0x4a5a
	move.l	#$96cd9565, (a6)	; 0x4a60
	move.w	#$977f, (a6)	; 0x4a66
	move.w	#$c000, (a6)	; 0x4a6a
	move.w	#$0080, -(a7)	; 0x4a6e
@wait_z80_2:
	btst	d6, (a4)	; 0x4a72
	bne.b	@wait_z80_2	; 0x4a74
	move.w	(a7)+, (a6)	; 0x4a76
	move.w	d6, (a4)	; 0x4a78
	andi.b	#$ef, (VdpRegistersCache).w	; 0x4a7a
	move.w	(VdpRegistersCache).w, (a6)	; 0x4a80
	move.l	#$c0000000, (a6)	; 0x4a84
	move.w	(currentPalettes).w, (a5)	; 0x4a8a
	rts		; 0x4a8e

setVScroll:
	tst.b	(flagProcessVSRAM).w	; 0x4a90
	beq.b	vscroll_return	; 0x4a94
	clr.b	(flagProcessVSRAM).w	; 0x4a96

setVscrollAlt:
	move.l	#$40000010, (a6)	; VSRAM write to 0000	; 0x4a9a
	move.l	(vsRamCache1).w, (a5)	; 0x4aa0

vscroll_return:
	rts		; 0x4aa4

updateHScroll:
	tst.b	(flagProcessHScroll).w	; 0x4aa6
	beq.b	@return	; 0x4aaa
	clr.b	(flagProcessHScroll).w	; 0x4aac
	ori.b	#$10, (VdpRegistersCache).w	; 0x4ab0
	move.w	(VdpRegistersCache).w, (a6)	; 0x4ab6
	move.w	d7, (a4)	; 0x4aba
	move.l	#$94029300, (a6)	; 0x4abc
	move.l	#$96cd95d5, (a6)	; 0x4ac2
	move.w	#$977f, (a6)	; 0x4ac8
	move.w	#$5c00, (a6)	; 0x4acc
	move.w	#$0083, -(a7)	; 0x4ad0
@wait_z80:
	btst	d6, (a4)	; 0x4ad4
	bne.b	@wait_z80	; 0x4ad6
	move.w	(a7)+, (a6)	; 0x4ad8
	move.w	d6, (a4)	; 0x4ada
	andi.b	#$ef, (VdpRegistersCache).w	; 0x4adc
	move.w	(VdpRegistersCache).w, (a6)	; 0x4ae2
	move.l	#$5c000003, (a6)	; 0x4ae6
	move.w	(hScrollCacheA).w, (a5)	; 0x4aec
@return:
	rts		; 0x4af0

updateHScrollAlt:
	move.l	#$5c000003, (a6)	; 0x4af2
	move.l	(hScrollCacheA).w, (a5)	; 0x4af8
	rts		; 0x4afc

updateHScrollCache40:
	ori.b	#$10, (VdpRegistersCache).w	; 0x4afe
	move.w	(VdpRegistersCache).w, (a6)	; 0x4b04
	move.w	d7, (a4)	; 0x4b08
	move.l	#$94019390, (a6)	; 0x4b0a
	move.l	#$96cd95f5, (a6)	; 0x4b10
	move.w	#$977f, (a6)	; 0x4b16
	move.w	#$5c40, (a6)	; 0x4b1a
	move.w	#$0083, -(a7)	; 0x4b1e
@wait_z80:
	btst	d6, (a4)	; 0x4b22
	bne.b	@wait_z80	; 0x4b24
	move.w	(a7)+, (a6)	; 0x4b26
	move.w	d6, (a4)	; 0x4b28
	andi.b	#$ef, (VdpRegistersCache).w	; 0x4b2a
	move.w	(VdpRegistersCache).w, (a6)	; 0x4b30
	move.l	#$5c400003, (a6)	; 0x4b34
	move.w	hScrollCache, (a5)	; 0x4b3a
	rts		; 0x4b40

updateSat:
	move.w	#$9faa, (ptrCurrentSpriteInSatBuffer).w	; 0x4b42
	clr.b	(currentSpriteLink).w	; 0x4b48
	ori.b	#$10, (VdpRegistersCache).w	; 0x4b4c
	move.w	(VdpRegistersCache).w, (a6)	; 0x4b52
	move.w	d7, (a4)	; 0x4b56
	move.l	#$94019300, (a6)	; 0x4b58
	move.l	#$96cf95d5, (a6)	; 0x4b5e
	move.w	#$977f, (a6)	; 0x4b64
	move.w	#$5a00, (a6)	; 0x4b68
	move.w	#$0083, -(a7)	; 0x4b6c
@wait_z80:
	btst	d6, (a4)	; 0x4b70
	bne.b	@wait_z80	; 0x4b72
	move.w	(a7)+, (a6)	; 0x4b74
	move.w	d6, (a4)	; 0x4b76
	andi.b	#$ef, (VdpRegistersCache).w	; 0x4b78
	move.w	(VdpRegistersCache).w, (a6)	; 0x4b7e
	move.l	#$5a000003, (a6)	; 0x4b82
	move.w	(SAT_cache).w, (a5)	; 0x4b88
	rts		; 0x4b8c

loadAllTileDatasDma:
	lea	(LBL_ffffa1aa).w, a0	; 0x4b8e
	move.w	(ptrDmaQueueCurrentEntry).w, a2	; 0x4b92
	move.w	a0, (ptrDmaQueueCurrentEntry).w	; 0x4b96
@loop:
	cmpa.w	a2, a0	; 0x4b9a
	beq.b	@exit	; 0x4b9c
	bsr.b	loadTileDataDma	; 0x4b9e
	bra.b	@loop	; 0x4ba0
@exit:
	rts		; 0x4ba2

loadTileDataDma:
	move.l	#$93009400, d0	; 0x4ba4
	move.b	(a0)+, d0	; 0x4baa
	swap	d0	; 0x4bac
	move.b	(a0)+, d0	; 0x4bae
	move.l	(a0), a1	; 0x4bb0
	adda.l	a1, a1	; 0x4bb2
	move.b	(a0)+, d2	; 0x4bb4
	move.w	#$9700, d2	; 0x4bb6
	move.b	(a0)+, d2	; 0x4bba
	move.l	#$95009600, d1	; 0x4bbc
	move.b	(a0)+, d1	; 0x4bc2
	swap	d1	; 0x4bc4
	move.b	(a0)+, d1	; 0x4bc6
	moveq	#0, d3	; 0x4bc8
	move.w	(a0)+, d3	; 0x4bca
	lsl.l	#2, d3	; 0x4bcc
	lsr.w	#2, d3	; 0x4bce
	swap	d3	; 0x4bd0
	ori.l	#$40000080, d3	; 0x4bd2
	move.l	d3, -(a7)	; 0x4bd8
	ori.b	#$10, (VdpRegistersCache).w	; 0x4bda
	move.w	(VdpRegistersCache).w, (a6)	; 0x4be0
	move.w	d7, (a4)	; 0x4be4
	move.l	d0, (a6)	; 0x4be6
	move.l	d1, (a6)	; 0x4be8
	move.w	d2, (a6)	; 0x4bea
	move.w	(a7)+, (a6)	; 0x4bec
@wait_z80:
	btst	d6, (a4)	; 0x4bee
	bne.b	@wait_z80	; 0x4bf0
	move.w	(a7)+, (a6)	; 0x4bf2
	move.w	d6, (a4)	; 0x4bf4
	andi.b	#$ef, (VdpRegistersCache).w	; 0x4bf6
	move.w	(VdpRegistersCache).w, (a6)	; 0x4bfc
	eori.w	#$0080, d3	; 0x4c00
	move.l	d3, (a6)	; 0x4c04
	move.w	(a1), (a5)	; 0x4c06
	rts		; 0x4c08

updateAllTilemaps:
	lea	(updatable_bg_areas_list).w, a0	; 0x4c0a
	move.w	(ptrLastUpdatableBgArea).w, a2	; 0x4c0e
	move.w	a0, (ptrLastUpdatableBgArea).w	; 0x4c12
@loop:
	cmpa.w	a2, a0	; 0x4c16
	beq.b	@exit	; 0x4c18
	bsr.b	updateTilemapRect	; 0x4c1a
	bra.b	@loop	; 0x4c1c
@exit:
	rts		; 0x4c1e

updateTilemapRect:
	move.w	(a0)+, d0	; 0x4c20
	moveq	#0, d1	; 0x4c22
	move.b	(a0)+, d1	; 0x4c24
	moveq	#0, d2	; 0x4c26
	move.b	(a0)+, d2	; 0x4c28
	move.l	(a0)+, a1	; 0x4c2a
@loop:
	move.w	d0, (a6)	; 0x4c2c
	move.w	#3, (a6)	; 0x4c2e
	move.w	d2, d4	; 0x4c32
@wait_z80:
	move.w	(a1)+, (a5)	; 0x4c34
	dbf	d4, @wait_z80	; 0x4c36
	addi.w	#$0080, d0	; 0x4c3a
	dbf	d1, @loop	; 0x4c3e
	rts		; 0x4c42
	include	"MoreSound.asm"	; 0x-1

FUN_00005e26:
	move.b	d0, (LBL_ffffbb68).w	; 0x5e26
	move.l	#$00005e38, a0	; 0x5e2a
	move.w	#$0040, d0	; 0x5e30
	trap	#0	; 0x5e34
	rts		; 0x5e36

CMD_5e38:
	move.w	#$9202, (windowVPosSetter2).w	; 0x5e38
	move.w	#$929b, (windowVPosSetter3).w	; 0x5e3e
	move.b	#1, d0	; 0x5e44
	trap	#3	; 0x5e48
	move.l	#$80018001, d0	; 0x5e4a
	move.w	#$01ff, d5	; 0x5e50
	lea	LBL_ff7800, a0	; 0x5e54

next500:
	move.l	d0, (a0)+	; 0x5e5a
	dbf	d5, next500	; 0x5e5c
	move.w	(ptrDmaQueueCurrentEntry).w, a0	; 0x5e60
	lea	($5f02, pc), a1	; 0x5e64
	move.l	(a1)+, (a0)+	; 0x5e68
	move.l	(a1)+, (a0)+	; 0x5e6a
	move.w	a0, (ptrDmaQueueCurrentEntry).w	; 0x5e6c
	move.b	#1, d0	; 0x5e70
	trap	#3	; 0x5e74
	move.w	(ptrDmaQueueCurrentEntry).w, a0	; 0x5e76
	lea	($5f0a, pc), a1	; 0x5e7a
	move.l	(a1)+, (a0)+	; 0x5e7e
	move.l	(a1)+, (a0)+	; 0x5e80
	move.w	a0, (ptrDmaQueueCurrentEntry).w	; 0x5e82
	move.b	#1, d0	; 0x5e86
	trap	#3	; 0x5e8a
	moveq	#0, d0	; 0x5e8c
	move.b	(LBL_ffffbb68).w, d0	; 0x5e8e
	add.b	d0, d0	; 0x5e92
	move.w	(ffbb68Callbacks, pc, d0.w), d0	; 0x5e94
	jsr	(ffbb68Callbacks, pc, d0.w)	; 0x5e98
	clr.b	(LBL_ffffbb68).w	; 0x5e9c
	trap	#1	; 0x5ea0

ffbb68Callbacks:
	dc.w	ffbb68Callback00_02-ffbb68Callbacks	; 0x5ea2
	dc.w	ffbb68Callback01-ffbb68Callbacks	; 0x5ea4
	dc.w	ffbb68Callback00_02-ffbb68Callbacks	; 0x5ea6

ffbb68Callback00_02:
	move.w	#6, d5	; 0x5ea8

next701:
	move.w	d5, -(a7)	; 0x5eac
	move.b	#2, d0	; 0x5eae
	trap	#3	; 0x5eb2
	move.w	(a7)+, d5	; 0x5eb4
	cmpi.w	#4, d5	; 0x5eb6
	bhi.b	not_max	; 0x5eba
	addq.b	#1, (LBL_ffffa61f).w	; 0x5ebc

not_max:
	subq.b	#1, (LBL_ffffa621).w	; 0x5ec0
	dbf	d5, next701	; 0x5ec4
	move.w	(ptrDmaQueueCurrentEntry).w, a0	; 0x5ec8
	lea	($5f12, pc), a1	; 0x5ecc
	move.l	(a1)+, (a0)+	; 0x5ed0
	move.l	(a1)+, (a0)+	; 0x5ed2
	move.w	a0, (ptrDmaQueueCurrentEntry).w	; 0x5ed4

ffbb68Callback01:
	moveq	#3, d0	; 0x5ed8
	bsr.w	FUN_0000633c	; 0x5eda
	move.b	#1, d0	; 0x5ede
	trap	#3	; 0x5ee2
	moveq	#4, d0	; 0x5ee4
	bsr.w	FUN_0000633c	; 0x5ee6
	move.b	#1, d0	; 0x5eea
	trap	#3	; 0x5eee
	moveq	#5, d0	; 0x5ef0
	bsr.w	FUN_0000633c	; 0x5ef2
	move.b	#1, d0	; 0x5ef6
	trap	#3	; 0x5efa
	moveq	#6, d0	; 0x5efc
	bra.w	FUN_0000633c	; 0x5efe
	dc.l	$0200007f	; 0x5f02
	dc.l	$be00d000	; 0x5f06
	dc.l	$0200007f	; 0x5f0a
	dc.l	$be00d400	; 0x5f0e
	dc.l	$01c0007f	; 0x5f12
	dc.l	$bc00fa00	; 0x5f16

FUN_00005f1a:
	jsr	(initDisplay).w	; 0x5f1a
	jsr	(clearSatCache).w	; 0x5f1e
	bsr.b	FUN_00005f4c	; 0x5f22
	st	(FLAG_ff97b1).w	; 0x5f24
	move.w	#$6000, d0	; 0x5f28
	cmpi.b	#2, (LBL_ffff993c).w	; 0x5f2c
	bne.b	@loc_00005F38	; 0x5f32
	move.w	#$6000, d0	; 0x5f34
@loc_00005F38:
	jsr	FUN_000136da	; 0x5f38
	ori.b	#$40, (VdpRegistersCache).w	; 0x5f3e
	move.w	(VdpRegistersCache).w, (4, a5)	; 0x5f44
	rts		; 0x5f4a

FUN_00005f4c:
	andi.w	#$00ff, d6	; 0x5f4c
	move.w	d6, (LBL_ffffbb6a).w	; 0x5f50
	move.w	d6, d0	; 0x5f54
	bsr.b	loadPaletteById	; 0x5f56
	move.w	(LBL_ffffbb6a).w, d0	; 0x5f58
	bra.w	load_patterns_108	; 0x5f5c
	moveq	#0, d0	; 0x5f60

FUN_00005f62:
	move.w	d0, -(a7)	; 0x5f62
	jsr	(updateBackgroundAndObjects).w	; 0x5f64
	jsr	(updateAllSprites).w	; 0x5f68
	move.b	#1, d0	; 0x5f6c
	trap	#3	; 0x5f70
	move.w	(a7)+, d0	; 0x5f72
	dbf	d0, FUN_00005f62	; 0x5f74
	rts		; 0x5f78

FUN_00005f7a:
	jsr	(updateBackgroundAndObjects).w	; 0x5f7a
	jmp	(updateAllSprites).w	; 0x5f7e
	jsr	(initStageUpdate).w	; 0x5f82
	st	(needFightersUpdating).w	; 0x5f86
	jmp	(updateAllSprites).w	; 0x5f8a

FUN_00005f8e:
	move.w	a6, -(a7)	; 0x5f8e
	move.w	(LBL_ffff9a00).w, a0	; 0x5f90
	move.w	(662, a0), a6	; 0x5f94
	bra.b	set_animation_107	; 0x5f98

FUN_00005f9a:
	move.w	a6, -(a7)	; 0x5f9a
	move.w	(LBL_ffff9a00).w, a6	; 0x5f9c

set_animation_107:
	jsr	(setCharacterAnimation).w	; 0x5fa0
	bra.b	finalize_106	; 0x5fa4
	nop		; 0x5fa6

FUN_00005fa8:
	move.w	a6, -(a7)	; 0x5fa8
	move.w	(LBL_ffff9a00).w, a0	; 0x5faa
	move.w	(662, a0), a6	; 0x5fae
	bra.b	update_char_animation_100	; 0x5fb2

FUN_00005fb4:
	move.w	a6, -(a7)	; 0x5fb4
	move.w	(LBL_ffff9a00).w, a6	; 0x5fb6

update_char_animation_100:
	jsr	(updateCharAnimation).w	; 0x5fba

finalize_106:
	move.w	(a7)+, a6	; 0x5fbe
	rts		; 0x5fc0

loadPaletteById:
	add.w	d0, d0	; 0x5fc2
	move.w	(palettesById, pc, d0.w), d0	; 0x5fc4
	lea	(palettesById, pc, d0.w), a0	; 0x5fc8
	jmp	(loadPalette).w	; 0x5fcc

palettesById:
	dc.w	paletteId00-palettesById	; 0x5fd0
	dc.w	paletteId01-palettesById	; 0x5fd2
	dc.w	paletteId02-palettesById	; 0x5fd4
	dc.w	paletteId03_14-palettesById	; 0x5fd6
	dc.w	paletteId04-palettesById	; 0x5fd8
	dc.w	paletteId05-palettesById	; 0x5fda
	dc.w	paletteId06-palettesById	; 0x5fdc
	dc.w	paletteId07-palettesById	; 0x5fde
	dc.w	paletteId08-palettesById	; 0x5fe0
	dc.w	paletteId09-palettesById	; 0x5fe2
	dc.w	paletteId0a-palettesById	; 0x5fe4
	dc.w	paletteId0b-palettesById	; 0x5fe6
	dc.w	paletteId0c-palettesById	; 0x5fe8
	dc.w	paletteId0d-palettesById	; 0x5fea
	dc.w	paletteId0e-palettesById	; 0x5fec
	dc.w	paletteId0f-palettesById	; 0x5fee
	dc.w	paletteId10-palettesById	; 0x5ff0
	dc.w	paletteId11-palettesById	; 0x5ff2
	dc.w	paletteId12-palettesById	; 0x5ff4
	dc.w	paletteId13-palettesById	; 0x5ff6
	dc.w	paletteId03_14-palettesById	; 0x5ff8
	dc.w	paletteId15-palettesById	; 0x5ffa
	dc.w	paletteId16-palettesById	; 0x5ffc
	dc.w	paletteId17-palettesById	; 0x5ffe
	dc.w	paletteId18-palettesById	; 0x6000
	dc.w	paletteId19-palettesById	; 0x6002
	dc.w	paletteId1a-palettesById	; 0x6004

paletteId00:
	dc.b	$0F	; nb of colors: 31	; 0x6006
	dc.b	$00	; first colors: 0x00	; 0x6007
	dc.l	PALETTE_4bd040/2	; source	; 0x6008
	; 0x-1
	dc.w	$0000	; 0x600c

paletteId01:
	dc.b	$0F	; nb of colors: 31	; 0x600e
	dc.b	$20	; first colors: 0x10	; 0x600f
	dc.l	PALETTE_4bd080/2	; source	; 0x6010
	; 0x-1
	dc.w	$0000	; 0x6014

paletteId02:
	dc.b	$1F	; nb of colors: 63	; 0x6016
	dc.b	$00	; first colors: 0x00	; 0x6017
	dc.l	PALETTE_4bd0c0/2	; source	; 0x6018
	; 0x-1
	dc.w	$0000	; 0x601c

paletteId08:
	dc.b	$17	; nb of colors: 47	; 0x601e
	dc.b	$00	; first colors: 0x00	; 0x601f
	dc.l	PALETTE_4bd140/2	; source	; 0x6020
	; 0x-1
	dc.w	$0000	; 0x6024

paletteId15:
	dc.b	$17	; nb of colors: 47	; 0x6026
	dc.b	$20	; first colors: 0x10	; 0x6027
	dc.l	PALETTE_4bd220/2	; source	; 0x6028
	; 0x-1
	dc.w	$0000	; 0x602c

paletteId03_14:
	dc.b	$1F	; nb of colors: 63	; 0x602e
	dc.b	$00	; first colors: 0x00	; 0x602f
	dc.l	PALETTE_4bd2e0/2	; source	; 0x6030
	; 0x-1
	dc.w	$0000	; 0x6034

paletteId19:
	dc.b	$17	; nb of colors: 47	; 0x6036
	dc.b	$20	; first colors: 0x10	; 0x6037
	dc.l	PALETTE_4bd360/2	; source	; 0x6038
	; 0x-1
	dc.w	$0000	; 0x603c

paletteId0c:
	dc.b	$1F	; nb of colors: 63	; 0x603e
	dc.b	$00	; first colors: 0x00	; 0x603f
	dc.l	PALETTE_4bd4c0/2	; source	; 0x6040
	; 0x-1
	dc.w	$0000	; 0x6044

paletteId0d:
	dc.b	$1F	; nb of colors: 63	; 0x6046
	dc.b	$00	; first colors: 0x00	; 0x6047
	dc.l	PALETTE_4bd540/2	; source	; 0x6048
	; 0x-1
	dc.w	$0000	; 0x604c

paletteId0e:
	dc.b	$1F	; nb of colors: 63	; 0x604e
	dc.b	$00	; first colors: 0x00	; 0x604f
	dc.l	PALETTE_4bd5c0/2	; source	; 0x6050
	; 0x-1
	dc.w	$0000	; 0x6054

paletteId12:
	dc.b	$17	; nb of colors: 47	; 0x6056
	dc.b	$00	; first colors: 0x00	; 0x6057
	dc.l	PALETTE_4bd640/2	; source	; 0x6058
	; 0x-1
	dc.w	$0000	; 0x605c

paletteId13:
	dc.b	$1F	; nb of colors: 63	; 0x605e
	dc.b	$00	; first colors: 0x00	; 0x605f
	dc.l	PALETTE_4bd6a0/2	; source	; 0x6060
	; 0x-1
	dc.b	$07	; nb of colors: 15	; 0x6064
	dc.b	$40	; first colors: 0x20	; 0x6065
	dc.l	PALETTE_3c49e0/2	; source	; 0x6066
	; 0x-1
	dc.w	$0000	; 0x606a

paletteId0f:
	dc.b	$17	; nb of colors: 47	; 0x606c
	dc.b	$20	; first colors: 0x10	; 0x606d
	dc.l	PALETTE_4bd720/2	; source	; 0x606e
	; 0x-1
	dc.w	$0000	; 0x6072

paletteId10:
	dc.b	$0F	; nb of colors: 31	; 0x6074
	dc.b	$20	; first colors: 0x10	; 0x6075
	dc.l	PALETTE_4bd780/2	; source	; 0x6076
	; 0x-1
	dc.w	$0000	; 0x607a

paletteId05:
	dc.b	$17	; nb of colors: 47	; 0x607c
	dc.b	$00	; first colors: 0x00	; 0x607d
	dc.l	PALETTE_4bd7c0/2	; source	; 0x607e
	; 0x-1
	dc.w	$0000	; 0x6082

paletteId06:
	dc.b	$1F	; nb of colors: 63	; 0x6084
	dc.b	$00	; first colors: 0x00	; 0x6085
	dc.l	PALETTE_4bd8a0/2	; source	; 0x6086
	; 0x-1
	dc.w	$0000	; 0x608a

paletteId04:
	dc.b	$17	; nb of colors: 47	; 0x608c
	dc.b	$00	; first colors: 0x00	; 0x608d
	dc.l	PALETTE_4bd9a0/2	; source	; 0x608e
	; 0x-1
	dc.w	$0000	; 0x6092

paletteId07:
	dc.b	$1F	; nb of colors: 63	; 0x6094
	dc.b	$00	; first colors: 0x00	; 0x6095
	dc.l	PALETTE_4bd920/2	; source	; 0x6096
	; 0x-1
	dc.w	$0000	; 0x609a

paletteId09:
	dc.b	$1F	; nb of colors: 63	; 0x609c
	dc.b	$00	; first colors: 0x00	; 0x609d
	dc.l	PALETTE_4bdb60/2	; source	; 0x609e
	; 0x-1
	dc.w	$0000	; 0x60a2

paletteId0a:
	dc.b	$17	; nb of colors: 47	; 0x60a4
	dc.b	$20	; first colors: 0x10	; 0x60a5
	dc.l	PALETTE_4bdbe0/2	; source	; 0x60a6
	; 0x-1
	dc.w	$0000	; 0x60aa

paletteId16:
	dc.b	$1F	; nb of colors: 63	; 0x60ac
	dc.b	$00	; first colors: 0x00	; 0x60ad
	dc.l	PALETTE_4bdc40/2	; source	; 0x60ae
	; 0x-1
	dc.w	$0000	; 0x60b2

paletteId17:
	dc.b	$0F	; nb of colors: 31	; 0x60b4
	dc.b	$00	; first colors: 0x00	; 0x60b5
	dc.l	PALETTE_4bdcc0/2	; source	; 0x60b6
	; 0x-1
	dc.w	$0000	; 0x60ba

paletteId0b:
	dc.b	$1F	; nb of colors: 63	; 0x60bc
	dc.b	$00	; first colors: 0x00	; 0x60bd
	dc.l	PALETTE_4bdd00/2	; source	; 0x60be
	; 0x-1

paletteId18:
	dc.w	$0000	; 0x60c2

paletteId11:
	dc.b	$1F	; nb of colors: 63	; 0x60c4
	dc.b	$00	; first colors: 0x00	; 0x60c5
	dc.l	PALETTE_4be100/2	; source	; 0x60c6
	; 0x-1
	dc.w	$0000	; 0x60ca

paletteId1a:
	dc.b	$0F	; nb of colors: 31	; 0x60cc
	dc.b	$20	; first colors: 0x10	; 0x60cd
	dc.l	PALETTE_4be260/2	; source	; 0x60ce
	; 0x-1
	dc.w	$0000	; 0x60d2

load_patterns_108:
	add.w	d0, d0	; 0x60d4
	move.w	(patternsById, pc, d0.w), d0	; 0x60d6
	lea	(patternsById, pc, d0.w), a0	; 0x60da
	jmp	(transferDataFromPageToRam).w	; 0x60de

patternsById:
	dc.w	otherPalette00-patternsById	; 0x60e2
	dc.w	otherPalette01-patternsById	; 0x60e4
	dc.w	otherPalette02-patternsById	; 0x60e6
	dc.w	otherPalette03-patternsById	; 0x60e8
	dc.w	otherPalette04-patternsById	; 0x60ea
	dc.w	otherPalette05-patternsById	; 0x60ec
	dc.w	otherPalette06-patternsById	; 0x60ee
	dc.w	otherPalette07-patternsById	; 0x60f0
	dc.w	otherPalette08-patternsById	; 0x60f2
	dc.w	otherPalette09-patternsById	; 0x60f4
	dc.w	otherPalette0a-patternsById	; 0x60f6
	dc.w	otherPalette0b-patternsById	; 0x60f8
	dc.w	otherPalette0c-patternsById	; 0x60fa
	dc.w	otherPalette0d-patternsById	; 0x60fc
	dc.w	otherPalette0e-patternsById	; 0x60fe
	dc.w	otherPalette0f_10-patternsById	; 0x6100
	dc.w	otherPalette0f_10-patternsById	; 0x6102
	dc.w	otherPalette11-patternsById	; 0x6104
	dc.w	otherPalette12-patternsById	; 0x6106
	dc.w	otherPalette13-patternsById	; 0x6108
	dc.w	otherPalette14-patternsById	; 0x610a
	dc.w	otherPalette15-patternsById	; 0x610c
	dc.w	otherPalette16-patternsById	; 0x610e
	dc.w	otherPalette17-patternsById	; 0x6110
	dc.w	otherPalette18-patternsById	; 0x6112
	dc.w	otherPalette19-patternsById	; 0x6114
	dc.w	otherPalette1a-patternsById	; 0x6116

otherPalette00:
	dc.w	$2AE0	; nb of bytes	; 0x6118
	dc.l	PATTERNS_477d80/2	; source	; 0x611a
	dc.w	$2000	; destination in VRAM	; 0x611e
	; 0x-1
	dc.w	$1000	; nb of bytes	; 0x6120
	dc.l	PATTERNS_49c040/2	; source	; 0x6122
	dc.w	$E000	; destination in VRAM	; 0x6126
	; 0x-1
	dc.w	$1000	; nb of bytes	; 0x6128
	dc.l	PATTERNS_49c040/2	; source	; 0x612a
	dc.w	$F000	; destination in VRAM	; 0x612e
	; 0x-1
	dc.w	$0000	; 0x6130

otherPalette01:
	dc.w	$1000	; nb of bytes	; 0x6132
	dc.l	PATTERNS_49d040/2	; source	; 0x6134
	dc.w	$E000	; destination in VRAM	; 0x6138
	; 0x-1
	dc.w	$0000	; 0x613a

otherPalette02:
	dc.w	$1000	; nb of bytes	; 0x613c
	dc.l	PATTERNS_49e040/2	; source	; 0x613e
	dc.w	$E000	; destination in VRAM	; 0x6142
	; 0x-1
	dc.w	$1000	; nb of bytes	; 0x6144
	dc.l	PATTERNS_49f040/2	; source	; 0x6146
	dc.w	$F000	; destination in VRAM	; 0x614a
	; 0x-1
	dc.w	$FE0	; nb of bytes	; 0x614c
	dc.l	PATTERNS_4be440/2	; source	; 0x614e
	dc.w	$8000	; destination in VRAM	; 0x6152
	; 0x-1
	dc.w	$0000	; 0x6154

otherPalette08:
	dc.w	$1F00	; nb of bytes	; 0x6156
	dc.l	PATTERNS_47a860/2	; source	; 0x6158
	dc.w	$2000	; destination in VRAM	; 0x615c
	; 0x-1
	dc.w	$2000	; nb of bytes	; 0x615e
	dc.l	PATTERNS_4a0040/2	; source	; 0x6160
	dc.w	$E000	; destination in VRAM	; 0x6164
	; 0x-1
	dc.w	$0000	; 0x6166

otherPalette15:
	dc.w	$1F60	; nb of bytes	; 0x6168
	dc.l	PATTERNS_47c760/2	; source	; 0x616a
	dc.w	$2A00	; destination in VRAM	; 0x616e
	; 0x-1
	dc.w	$400	; nb of bytes	; 0x6170
	dc.l	dictator_stage_tileset_1_data/2	; source	; 0x6172
	dc.w	$2000	; destination in VRAM	; 0x6176
	; 0x-1
	dc.w	$600	; nb of bytes	; 0x6178
	dc.l	PATTERNS_486020/2	; source	; 0x617a
	dc.w	$2400	; destination in VRAM	; 0x617e
	; 0x-1
	dc.w	$2000	; nb of bytes	; 0x6180
	dc.l	PATTERNS_4a2040/2	; source	; 0x6182
	dc.w	$E000	; destination in VRAM	; 0x6186
	; 0x-1
	dc.w	$0000	; 0x6188

otherPalette03:
	dc.w	$2180	; nb of bytes	; 0x618a
	dc.l	PATTERNS_47e6c0/2	; source	; 0x618c
	dc.w	$2000	; destination in VRAM	; 0x6190
	; 0x-1
	dc.w	$1000	; nb of bytes	; 0x6192
	dc.l	PATTERNS_4a4040/2	; source	; 0x6194
	dc.w	$E000	; destination in VRAM	; 0x6198
	; 0x-1
	dc.w	$0000	; 0x619a

otherPalette14:
	dc.w	$2180	; nb of bytes	; 0x619c
	dc.l	PATTERNS_47e6c0/2	; source	; 0x619e
	dc.w	$2000	; destination in VRAM	; 0x61a2
	; 0x-1
	dc.w	$1000	; nb of bytes	; 0x61a4
	dc.l	PATTERNS_4a5040/2	; source	; 0x61a6
	dc.w	$E000	; destination in VRAM	; 0x61aa
	; 0x-1
	dc.w	$0000	; 0x61ac

otherPalette19:
	dc.w	$17E0	; nb of bytes	; 0x61ae
	dc.l	PATTERNS_480840/2	; source	; 0x61b0
	dc.w	$2000	; destination in VRAM	; 0x61b4
	; 0x-1
	dc.w	$1000	; nb of bytes	; 0x61b6
	dc.l	PATTERNS_4a6040/2	; source	; 0x61b8
	dc.w	$E000	; destination in VRAM	; 0x61bc
	; 0x-1
	dc.w	$0000	; 0x61be

otherPalette0c:
	dc.w	$4000	; nb of bytes	; 0x61c0
	dc.l	PATTERNS_482020/2	; source	; 0x61c2
	dc.w	$2000	; destination in VRAM	; 0x61c6
	; 0x-1
	dc.w	$1000	; nb of bytes	; 0x61c8
	dc.l	PATTERNS_4a7040/2	; source	; 0x61ca
	dc.w	$E000	; destination in VRAM	; 0x61ce
	; 0x-1
	dc.w	$100	; nb of bytes	; 0x61d0
	dc.l	PATTERNS_4c3c40/2	; source	; 0x61d2
	dc.w	$8000	; destination in VRAM	; 0x61d6
	; 0x-1
	dc.w	$0000	; 0x61d8

otherPalette0d:
	dc.w	$1000	; nb of bytes	; 0x61da
	dc.l	PATTERNS_4a8040/2	; source	; 0x61dc
	dc.w	$E000	; destination in VRAM	; 0x61e0
	; 0x-1
	dc.w	$0000	; 0x61e2

otherPalette0e:
	dc.w	$1000	; nb of bytes	; 0x61e4
	dc.l	PATTERNS_4a9040/2	; source	; 0x61e6
	dc.w	$E000	; destination in VRAM	; 0x61ea
	; 0x-1
	dc.w	$0000	; 0x61ec

otherPalette12:
	dc.w	$400	; nb of bytes	; 0x61ee
	dc.l	dictator_stage_tileset_1_data/2	; source	; 0x61f0
	dc.w	$2000	; destination in VRAM	; 0x61f4
	; 0x-1
	dc.w	$11A0	; nb of bytes	; 0x61f6
	dc.l	PATTERNS_486020/2	; source	; 0x61f8
	dc.w	$2400	; destination in VRAM	; 0x61fc
	; 0x-1
	dc.w	$1000	; nb of bytes	; 0x61fe
	dc.l	PATTERNS_4aa040/2	; source	; 0x6200
	dc.w	$E000	; destination in VRAM	; 0x6204
	; 0x-1
	dc.w	$0000	; 0x6206

otherPalette13:
	dc.w	$400	; nb of bytes	; 0x6208
	dc.l	dictator_stage_tileset_1_data/2	; source	; 0x620a
	dc.w	$2000	; destination in VRAM	; 0x620e
	; 0x-1
	dc.w	$11A0	; nb of bytes	; 0x6210
	dc.l	PATTERNS_486020/2	; source	; 0x6212
	dc.w	$2400	; destination in VRAM	; 0x6216
	; 0x-1
	dc.w	$1000	; nb of bytes	; 0x6218
	dc.l	PATTERNS_4aa040/2	; source	; 0x621a
	dc.w	$F000	; destination in VRAM	; 0x621e
	; 0x-1
	dc.w	$0000	; 0x6220

otherPalette0f_10:
	dc.w	$23A0	; nb of bytes	; 0x6222
	dc.l	PATTERNS_4871c0/2	; source	; 0x6224
	dc.w	$2000	; destination in VRAM	; 0x6228
	; 0x-1
	dc.w	$2000	; nb of bytes	; 0x622a
	dc.l	PATTERNS_4ab040/2	; source	; 0x622c
	dc.w	$E000	; destination in VRAM	; 0x6230
	; 0x-1
	dc.w	$5A0	; nb of bytes	; 0x6232
	dc.l	PATTERNS_4bf420/2	; source	; 0x6234
	dc.w	$8000	; destination in VRAM	; 0x6238
	; 0x-1
	dc.w	$0000	; 0x623a

otherPalette05:
	dc.w	$D80	; nb of bytes	; 0x623c
	dc.l	PATTERNS_489560/2	; source	; 0x623e
	dc.w	$2000	; destination in VRAM	; 0x6242
	; 0x-1
	dc.w	$180	; nb of bytes	; 0x6244
	dc.l	PATTERNS_48a2e0/2	; source	; 0x6246
	dc.w	$2E00	; destination in VRAM	; 0x624a
	; 0x-1
	dc.w	$2E0	; nb of bytes	; 0x624c
	dc.l	PATTERNS_4bf9c0/2	; source	; 0x624e
	dc.w	$3000	; destination in VRAM	; 0x6252
	; 0x-1
	dc.w	$2000	; nb of bytes	; 0x6254
	dc.l	PATTERNS_4bfca0/2	; source	; 0x6256
	dc.w	$3400	; destination in VRAM	; 0x625a
	; 0x-1
	dc.w	$1000	; nb of bytes	; 0x625c
	dc.l	PATTERNS_4ad040/2	; source	; 0x625e
	dc.w	$E000	; destination in VRAM	; 0x6262
	; 0x-1
	dc.w	$0000	; 0x6264

otherPalette06:
	dc.w	$17C0	; nb of bytes	; 0x6266
	dc.l	PATTERNS_48a460/2	; source	; 0x6268
	dc.w	$2000	; destination in VRAM	; 0x626c
	; 0x-1
	dc.w	$D20	; nb of bytes	; 0x626e
	dc.l	PATTERNS_4c1ca0/2	; source	; 0x6270
	dc.w	$3800	; destination in VRAM	; 0x6274
	; 0x-1
	dc.w	$1000	; nb of bytes	; 0x6276
	dc.l	PATTERNS_4ae040/2	; source	; 0x6278
	dc.w	$E000	; destination in VRAM	; 0x627c
	; 0x-1
	dc.w	$0000	; 0x627e

otherPalette04:
	dc.w	$2A40	; nb of bytes	; 0x6280
	dc.l	PATTERNS_48bc20/2	; source	; 0x6282
	dc.w	$2000	; destination in VRAM	; 0x6286
	; 0x-1
	dc.w	$1000	; nb of bytes	; 0x6288
	dc.l	PATTERNS_4af040/2	; source	; 0x628a
	dc.w	$E000	; destination in VRAM	; 0x628e
	; 0x-1
	dc.w	$0000	; 0x6290

otherPalette07:
	dc.w	$1000	; nb of bytes	; 0x6292
	dc.l	PATTERNS_4b0040/2	; source	; 0x6294
	dc.w	$E000	; destination in VRAM	; 0x6298
	; 0x-1
	dc.w	$0000	; 0x629a

otherPalette09:
	dc.w	$2960	; nb of bytes	; 0x629c
	dc.l	PATTERNS_48e660/2	; source	; 0x629e
	dc.w	$2000	; destination in VRAM	; 0x62a2
	; 0x-1
	dc.w	$1000	; nb of bytes	; 0x62a4
	dc.l	PATTERNS_4b1040/2	; source	; 0x62a6
	dc.w	$E000	; destination in VRAM	; 0x62aa
	; 0x-1
	dc.w	$0000	; 0x62ac

otherPalette0a:
	dc.w	$1000	; nb of bytes	; 0x62ae
	dc.l	PATTERNS_4b2040/2	; source	; 0x62b0
	dc.w	$E000	; destination in VRAM	; 0x62b4
	; 0x-1
	dc.w	$0000	; 0x62b6

otherPalette16:
	dc.w	$5E20	; nb of bytes	; 0x62b8
	dc.l	sagat_stage_tileset_1_data/2	; source	; 0x62ba
	dc.w	$1000	; destination in VRAM	; 0x62be
	; 0x-1
	dc.w	$1000	; nb of bytes	; 0x62c0
	dc.l	PATTERNS_492ac0/2	; source	; 0x62c2
	dc.w	$4000	; destination in VRAM	; 0x62c6
	; 0x-1
	dc.w	$2000	; nb of bytes	; 0x62c8
	dc.l	PATTERNS_4b4040/2	; source	; 0x62ca
	dc.w	$E000	; destination in VRAM	; 0x62ce
	; 0x-1
	dc.w	$1080	; nb of bytes	; 0x62d0
	dc.l	PATTERNS_4c2bc0/2	; source	; 0x62d2
	dc.w	$8000	; destination in VRAM	; 0x62d6
	; 0x-1
	dc.w	$0000	; 0x62d8

otherPalette17:
	dc.w	$1B00	; nb of bytes	; 0x62da
	dc.l	PATTERNS_490fc0/2	; source	; 0x62dc
	dc.w	$2000	; destination in VRAM	; 0x62e0
	; 0x-1
	dc.w	$1000	; nb of bytes	; 0x62e2
	dc.l	PATTERNS_4b3040/2	; source	; 0x62e4
	dc.w	$E000	; destination in VRAM	; 0x62e8
	; 0x-1
	dc.w	$1000	; nb of bytes	; 0x62ea
	dc.l	PATTERNS_4b3040/2	; source	; 0x62ec
	dc.w	$F000	; destination in VRAM	; 0x62f0
	; 0x-1
	dc.w	$0000	; 0x62f2

otherPalette0b:
	dc.w	$1400	; nb of bytes	; 0x62f4
	dc.l	PATTERNS_493ac0/2	; source	; 0x62f6
	dc.w	$2000	; destination in VRAM	; 0x62fa
	; 0x-1
	dc.w	$1000	; nb of bytes	; 0x62fc
	dc.l	PATTERNS_4b6040/2	; source	; 0x62fe
	dc.w	$E000	; destination in VRAM	; 0x6302
	; 0x-1
	dc.w	$0000	; 0x6304

otherPalette18:
	dc.w	$1000	; nb of bytes	; 0x6306
	dc.l	PATTERNS_4b7040/2	; source	; 0x6308
	dc.w	$E000	; destination in VRAM	; 0x630c
	; 0x-1
	dc.w	$0000	; 0x630e

otherPalette11:
	dc.w	$2C00	; nb of bytes	; 0x6310
	dc.l	PATTERNS_494ec0/2	; source	; 0x6312
	dc.w	$2000	; destination in VRAM	; 0x6316
	; 0x-1
	dc.w	$2000	; nb of bytes	; 0x6318
	dc.l	PATTERNS_4b8040/2	; source	; 0x631a
	dc.w	$E000	; destination in VRAM	; 0x631e
	; 0x-1
	dc.w	$0000	; 0x6320

otherPalette1a:
	dc.w	$4580	; nb of bytes	; 0x6322
	dc.l	PATTERNS_497ac0/2	; source	; 0x6324
	dc.w	$2000	; destination in VRAM	; 0x6328
	; 0x-1
	dc.w	$800	; nb of bytes	; 0x632a
	dc.l	PATTERNS_4ba040/2	; source	; 0x632c
	dc.w	$E000	; destination in VRAM	; 0x6330
	; 0x-1
	dc.w	$800	; nb of bytes	; 0x6332
	dc.l	PATTERNS_4ba840/2	; source	; 0x6334
	dc.w	$E800	; destination in VRAM	; 0x6338
	; 0x-1
	dc.w	$0000	; 0x633a

FUN_0000633c:
	add.w	d0, d0	; 0x633c
	move.w	(patternsLoaders_100, pc, d0.w), d0	; 0x633e
	lea	(patternsLoaders_100, pc, d0.w), a0	; 0x6342
	move.w	(ptrDmaQueueCurrentEntry).w, a1	; 0x6346
	move.w	(a0)+, (a1)+	; 0x634a
	move.l	(a0)+, (a1)+	; 0x634c
	move.w	(a0)+, (a1)+	; 0x634e
	move.w	a1, (ptrDmaQueueCurrentEntry).w	; 0x6350
	rts		; 0x6354

patternsLoaders_100:
	dc.w	patternsLoader00_100-patternsLoaders_100	; 0x6356
	dc.w	patternsLoader01_100-patternsLoaders_100	; 0x6358
	dc.w	patternsLoader02_100-patternsLoaders_100	; 0x635a
	dc.w	patternsLoader03_100-patternsLoaders_100	; 0x635c
	dc.w	patternsLoader04_100-patternsLoaders_100	; 0x635e
	dc.w	patternsLoader05And06_100-patternsLoaders_100	; 0x6360
	dc.w	patternsLoader05And06_100-patternsLoaders_100	; 0x6362
	dc.w	patternsLoader07_100-patternsLoaders_100	; 0x6364
	dc.w	patternsLoader08_100-patternsLoaders_100	; 0x6366
	dc.w	patternsLoader09_100-patternsLoaders_100	; 0x6368

patternsLoader00_100:
	dc.w	$0100	; length in words	; 0x636a
	dc.l	PATTERNS_3c0620/2	; source	; 0x636c
	dc.w	$8e00	; dest	; 0x6370
	; 0x-1

patternsLoader01_100:
	dc.w	$0390	; length in words	; 0x6372
	dc.l	PATTERNS_3c0840/2	; source	; 0x6374
	dc.w	$8e00	; dest	; 0x6378
	; 0x-1

patternsLoader02_100:
	dc.w	$01E0	; length in words	; 0x637a
	dc.l	PATTERNS_3c0f80/2	; source	; 0x637c
	dc.w	$8e00	; dest	; 0x6380
	; 0x-1

patternsLoader03_100:
	dc.w	$0C50	; length in words	; 0x6382
	dc.l	PATTERNS_3c1340/2	; source	; 0x6384
	dc.w	$8e00	; dest	; 0x6388
	; 0x-1

patternsLoader04_100:
	dc.w	$0F00	; length in words	; 0x638a
	dc.l	PATTERNS_3c2be0/2	; source	; 0x638c
	dc.w	$8e00	; dest	; 0x6390
	; 0x-1

patternsLoader05And06_100:
	dc.w	$0740	; length in words	; 0x6392
	dc.l	flatPtrnsData/2	; source	; 0x6394
	dc.w	$8e00	; dest	; 0x6398
	; 0x-1

patternsLoader07_100:
	dc.w	$02E0	; length in words	; 0x639a
	dc.l	PATTERNS_3c4a00/2	; source	; 0x639c
	dc.w	$8e00	; dest	; 0x63a0
	; 0x-1

patternsLoader08_100:
	dc.w	$0500	; length in words	; 0x63a2
	dc.l	PATTERNS_383aec/2	; source	; 0x63a4
	dc.w	$5200	; dest	; 0x63a8
	; 0x-1

patternsLoader09_100:
	dc.w	$0100	; length in words	; 0x63aa
	dc.l	PATTERNS_383eec/2	; source	; 0x63ac
	dc.w	$7000	; dest	; 0x63b0
	; 0x-1

CMD_segaLogo1:
	move.b	($1f0).w, d0	; 0x63b2
	move.b	(copyOfVersionRegister).w, d1	; 0x63b6
	andi.b	#$c0, d1	; 0x63ba
	cmpi.b	#$4a, d0	; 0x63be
	bne.b	@not_japanese	; 0x63c2
	tst.b	d1	; 0x63c4
	beq.b	@not_european	; 0x63c6
	move.b	#$7f, (DAT_ffff97b0_flag_random).w	; 0x63c8
	bra.b	@skip	; 0x63ce
@not_japanese:
	cmpi.b	#$55, d0	; 0x63d0
	bne.b	@not_usa	; 0x63d4
	cmpi.b	#$80, d1	; 0x63d6
	beq.b	@not_european	; 0x63da
	move.b	#$7e, (DAT_ffff97b0_flag_random).w	; 0x63dc
	bra.b	@skip	; 0x63e2
@not_usa:
	cmpi.b	#$45, d0	; 0x63e4
	bne.b	@not_european	; 0x63e8
	cmpi.b	#$c0, d1	; 0x63ea
	beq.b	@not_european	; 0x63ee
	move.b	#$7d, (DAT_ffff97b0_flag_random).w	; 0x63f0
@skip:
	st	(FLAG_ff97b1).w	; 0x63f6
	move.w	#$2000, d0	; 0x63fa
	jsr	FUN_000136f2	; 0x63fe
	jsr	FUN_0001371c	; 0x6404
	move.l	#$c0000000, (4, a5)	; 0x640a
	move.w	#8, (a5)	; 0x6412
	move.l	#$00381382, a0	; 0x6416
	moveq	#$000e, d0	; 0x641c
@next:
	move.w	(a0)+, (a5)	; 0x641e
	dbf	d0, @next	; 0x6420
	ori.b	#$40, (VdpRegistersCache).w	; 0x6424
	move.w	(VdpRegistersCache).w, (4, a5)	; 0x642a
	trap	#1	; 0x6430
@not_european:
	lea	($6458, pc), a0	; 0x6432
	jsr	(transferDataToVramDMA).w	; 0x6436
	move.w	(8, a5), d2	; 0x643a
	andi.w	#$00ff, d2	; 0x643e
@next2:
	jsr	(random).w	; 0x6442
	dbf	d2, @next2	; 0x6446
	move.l	#$00006460, a0	; 0x644a
	move.w	#$0010, d0	; 0x6450
	trap	#0	; 0x6454
	trap	#1	; 0x6456

guiStartupTileDataDMA:
	dc.w	$0740	; length in words	; 0x6458
	dc.l	flatPtrnsData/2	; source	; 0x645a
	dc.w	$0	; dest	; 0x645e
	; 0x-1

CMD_segaLogo2:
	clr.l	(logoSceneStateRelated).w	; 0x6460

loop_300:
	move.w	(logoSceneStateRelated).w, d0	; 0x6464
	move.w	(logoSceneStates00, pc, d0.w), d0	; 0x6468
	jsr	(logoSceneStates00, pc, d0.w)	; 0x646c
	move.b	#1, d0	; 0x6470
	trap	#3	; 0x6474

CMD_00006476:
	cmpi.w	#4, (logoSceneStateRelated).w	; 0x6476
	bne.b	loop_300	; 0x647c
	move.w	#$0040, d0	; 0x647e
	trap	#2	; 0x6482
	jmp	($9e80, pc)	; 0x6484

logoSceneStates00:
	dc.w	logoSceneState00-logoSceneStates00	; 0x6488
	dc.w	logoSceneState02-logoSceneStates00	; 0x648a

logoSceneState02_04:
	tst.b	(fadingDelta).w	; 0x648c
	bne.b	return_150	; 0x6490
	addq.w	#2, (logoSceneSubState).w	; 0x6492

return_150:
	rts		; 0x6496

logoSceneState02_08:
	tst.b	(fadingDelta).w	; 0x6498
	bne.b	return_150	; 0x649c
	addq.w	#2, (logoSceneStateRelated).w	; 0x649e
	clr.w	(logoSceneSubState).w	; 0x64a2
	rts		; 0x64a6

logoSceneState00:
	move.w	(logoSceneSubState).w, d0	; 0x64a8
	move.w	(logoSceneState00Substates, pc, d0.w), d0	; 0x64ac
	jmp	(logoSceneState00Substates, pc, d0.w)	; 0x64b0

logoSceneState00Substates:
	dc.w	logoSceneState00_00-logoSceneState00Substates	; 0x64b4
	dc.w	logoSceneState02_04-logoSceneState00Substates	; 0x64b6
	dc.w	logoSceneState00_04-logoSceneState00Substates	; 0x64b8
	dc.w	logoSceneState02_08-logoSceneState00Substates	; 0x64ba

logoSceneState00_00:
	jsr	(initDisplay).w	; 0x64bc
	move.l	#$60000000, (4, a5)	; 0x64c0
	lea	segaLogoPtrns, a0	; 0x64c8
	move.w	#$018f, d7	; 0x64ce

next_151:
	move.l	(a0)+, (a5)	; 0x64d2
	dbf	d7, next_151	; 0x64d4
	jsr	(clearSatCache).w	; 0x64d8
	lea	($65c6, pc), a0	; 0x64dc
	jsr	(writeTileRect).w	; 0x64e0
	btst	#7, (copyOfVersionRegister).w	; 0x64e4
	beq.b	dont_show_tm	; 0x64ea
	move.l	#$66300003, (4, a5)	; 0x64ec
	move.l	#$01300131, (a5)	; 0x64f4

dont_show_tm:
	ori.b	#$81, (VdpRegistersCache).w	; 0x64fa
	move.w	(VdpRegistersCache).w, (4, a5)	; 0x6500
	ori.b	#$40, (VdpRegistersCache).w	; 0x6506
	move.w	(VdpRegistersCache).w, (4, a5)	; 0x650c
	lea	($6584, pc), a0	; 0x6512
	lea	(rawPalettes).w, a1	; 0x6516
	moveq	#$000c, d7	; 0x651a

next_152:
	move.w	(a0)+, (a1)+	; 0x651c
	dbf	d7, next_152	; 0x651e
	addq.w	#2, (logoSceneSubState).w	; 0x6522
	move.w	#$00f0, (logoTimer).w	; 0x6526
	move.w	#$0028, (colorCycleIndex).w	; 0x652c
	move.w	#$000a, (colorCycleTimer).w	; 0x6532
	jmp	(fadeInStart).w	; 0x6538

logoSceneState00_04:
	move.w	(joy1State).w, d0	; 0x653c
	or.w	(joy2State).w, d0	; 0x6540
	btst	#7, d0	; 0x6544
	bne.b	start_pressed_154	; 0x6548
	subq.w	#1, (logoTimer).w	; 0x654a
	bne.b	update_154	; 0x654e

start_pressed_154:
	addq.w	#2, (logoSceneSubState).w	; 0x6550
	jsr	(fadeOutStart).w	; 0x6554

update_154:
	subq.w	#1, (colorCycleTimer).w	; 0x6558
	bpl.b	return_154	; 0x655c
	move.w	#1, (colorCycleTimer).w	; 0x655e
	move.w	(colorCycleIndex).w, d0	; 0x6564
	bmi.b	return_154	; 0x6568
	subq.w	#2, (colorCycleIndex).w	; 0x656a
	lea	(segaLogoPalette, pc, d0.w), a0	; 0x656e
	lea	(rawPalettes).w, a1	; 0x6572
	moveq	#$000a, d0	; 0x6576

next_154:
	move.w	(a0)+, (a1)+	; 0x6578
	dbf	d0, next_154	; 0x657a
	st	(flagProcessPalettes).w	; 0x657e

return_154:
	rts		; 0x6582

segaLogoPalette:
	dc.w	$0000, $0eee, $0ec0, $0ea0, $0e80, $0e60, $0e40, $0e20, $0e00, $0c00, $0a00, $0800, $0600, $0800, $0a00, $0c00, $0e00, $0e20, $0e40, $0e60, $0e80, $0ea0, $0ec0, $0ea0, $0e80, $0e60, $0e40, $0e20, $0e00, $0c00, $0a00, $0800, $0600	; 0x6584

segaLogoTilemap:
	dc.w	$661c	; 0x65c6
	dc.b	$03	; 0x65c8
	dc.b	$0b	; 0x65c9
	dc.b	$01	; 0x65ca
	dc.b	$01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $00, $0c, $0d, $0e, $0f, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $1d, $1e, $1f, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2a, $2b, $2c, $2d, $2e, $2f	; 0x65cb
	dc.b	$78	; 0x65fb

logoSceneState02:
	move.w	(logoSceneSubState).w, d0	; 0x65fc
	move.w	(logoSceneState02Substates, pc, d0.w), d0	; 0x6600
	jmp	(logoSceneState02Substates, pc, d0.w)	; 0x6604

logoSceneState02Substates:
	dc.w	logoSceneState02_00-logoSceneState02Substates	; 0x6608
	dc.w	logoSceneState02_02-logoSceneState02Substates	; 0x660a
	dc.w	logoSceneState02_04-logoSceneState02Substates	; 0x660c
	dc.w	logoSceneState02_06-logoSceneState02Substates	; 0x660e
	dc.w	logoSceneState02_08-logoSceneState02Substates	; 0x6610

logoSceneState02_00:
	jsr	(initDisplay).w	; 0x6612
	lea	($66d4, pc), a0	; 0x6616
	jsr	(transferDataToVramDMA).w	; 0x661a
	lea	($66dc, pc), a0	; 0x661e
	nop		; 0x6622
	jsr	(writeTileRect).w	; 0x6624
	ori.b	#$40, (VdpRegistersCache).w	; 0x6628
	move.w	(VdpRegistersCache).w, (4, a5)	; 0x662e
	clr.w	(colorCycleIndex).w	; 0x6634
	bsr.b	updateCapcomLogoColors	; 0x6638
	addq.w	#2, (logoSceneSubState).w	; 0x663a
	move.w	#$001e, (logoTimer).w	; 0x663e
	moveq	#0, d0	; 0x6644
	jmp	(selectBgm).w	; 0x6646

logoSceneState02_02:
	subq.w	#1, (logoTimer).w	; 0x664a
	bne.b	@return	; 0x664e
	addq.w	#2, (logoSceneSubState).w	; 0x6650
	move.w	#$010e, (logoTimer).w	; 0x6654
	jmp	(fadeInStart).w	; 0x665a

@return:
	rts		; 0x665e

logoSceneState02_06:
	move.w	(joy1State).w, d0	; 0x6660
	or.w	(joy2State).w, d0	; 0x6664
	btst	#7, d0	; 0x6668
	bne.b	@start_pressed	; 0x666c
	subq.w	#1, (logoTimer).w	; 0x666e
	bne.b	@update	; 0x6672

@start_pressed:
	addq.w	#2, (logoSceneSubState).w	; 0x6674
	jsr	(fadeOutStart).w	; 0x6678

@update:
	cmpi.w	#$0018, (colorCycleIndex).w	; 0x667c
	beq.b	@return	; 0x6682
	subq.w	#1, (colorCycleTimer).w	; 0x6684
	bne.b	@return	; 0x6688
	addq.w	#4, (colorCycleIndex).w	; 0x668a
	bra.b	updateCapcomLogoColors	; 0x668e

@return:
	rts		; 0x6690

updateCapcomLogoColors:
	move.w	(colorCycleIndex).w, d0	; 0x6692
	lea	(26296, pc, d0.w), a1	; 0x6696
	move.l	#$00380480, a0	; 0x669a
	adda.w	(a1)+, a0	; 0x66a0
	move.w	(a1), (colorCycleTimer).w	; 0x66a2
	lea	(rawPalettes).w, a1	; 0x66a6
	moveq	#7, d7	; 0x66aa
@next4:
	move.l	(a0)+, (a1)+	; 0x66ac
	dbf	d7, @next4	; 0x66ae
	st	(flagProcessPalettes).w	; 0x66b2
	rts		; 0x66b6
	dc.w	$0000, $003c, $0020, $0005, $0040, $0002, $0060, $0004, $0040, $0002, $0020, $0005, $0000, $0001	; 0x66b8

capcomLogoPtrnLoader:
	dc.w	$0240	; length in words	; 0x66d4
	dc.l	PATTERNS_capcomLogo/2	; source	; 0x66d6
	dc.w	$2000	; dest	; 0x66da
	; 0x-1

capcomLogoTilemap:
	dc.w	$6614	; 0x66dc
	dc.b	$02	; 0x66de
	dc.b	$0b	; 0x66df
	dc.b	$01	; 0x66e0
	dc.b	$00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $1d, $1e, $1f, $20, $21, $22, $23	; 0x66e1
	dc.b	$fc, $00, $02, $00, $20, $00, $01, $00, $40, $00, $40, $00, $10, $00, $10, $00, $20, $00, $02, $01, $00, $00, $01, $04, $00, $00, $40, $02, $00, $00, $10, $00, $20	; 0x6705
	include	"OptionMenu.asm"	; 0x-1

startDebugMode:
	clr.w	(debugMenuState).w	; 0x79b6
	clr.w	(debugMenuSubstate).w	; 0x79ba

loop:
	move.w	(debugMenuState).w, d0	; 0x79be
	move.w	(debugMenuStates, pc, d0.w), d1	; 0x79c2
	jsr	(debugMenuStates, pc, d1.w)	; 0x79c6
	move.b	#1, d0	; 0x79ca
	trap	#3	; 0x79ce
	bra.b	loop	; 0x79d0

debugMenuStates:
	dc.w	debugMenuState00-debugMenuStates	; 0x79d2
	dc.w	debugMenuState02-debugMenuStates	; 0x79d4
	dc.w	debugMenuState04-debugMenuStates	; 0x79d6
	dc.w	debugMenuState06-debugMenuStates	; 0x79d8

debugMenuState00:
	tst.w	(debugMenuSubstate).w	; 0x79da
	bne.b	debugMenuState00_02	; 0x79de
	andi.b	#$bf, (VdpRegistersCache).w	; 0x79e0
	move.w	(VdpRegistersCache).w, (4, a5)	; 0x79e6
	jsr	(initDisplay).w	; 0x79ec
	jsr	(clearSatCache).w	; 0x79f0
	lea	($7b20, pc), a0	; 0x79f4
	jsr	(writeText).w	; 0x79f8
	lea	($7b50, pc), a0	; 0x79fc
	jsr	(writeText).w	; 0x7a00
	ori.b	#$40, (VdpRegistersCache).w	; 0x7a04
	move.w	(VdpRegistersCache).w, (4, a5)	; 0x7a0a
	addq.w	#2, (debugMenuSubstate).w	; 0x7a10
	lea	($7a26, pc), a0	; 0x7a14
	jsr	(loadPalette).w	; 0x7a18
	move.w	#$0440, (rawPalettes).w	; 0x7a1c
	jmp	(fadeInStart).w	; 0x7a22
	dc.b	$07	; nb of colors: 15	; 0x7a26
	dc.b	$00	; first colors: 0x00	; 0x7a27
	dc.l	palette_381380/2	; source	; 0x7a28
	; 0x-1
	dc.w	$0000	; 0x7a2c

debugMenuState00_02:
	tst.b	(fadingDelta).w	; 0x7a2e
	bne.b	return00	; 0x7a32
	addq.w	#2, (debugMenuState).w	; 0x7a34
	clr.w	(debugMenuSubstate).w	; 0x7a38
	clr.w	(debugModeCursorRow).w	; 0x7a3c

return00:
	rts		; 0x7a40

debugMenuState02:
	tst.w	(debugMenuSubstate).w	; 0x7a42
	bne.b	debugMenuState02_02	; 0x7a46
	btst	#7, (joy1State).w	; 0x7a48
	bne.b	start_pressed	; 0x7a4e
	btst	#1, (joy1State).w	; 0x7a50
	beq.b	down_not_pressed	; 0x7a56
	addq.w	#4, (debugModeCursorRow).w	; 0x7a58
	cmpi.w	#$0010, (debugModeCursorRow).w	; 0x7a5c
	bne.b	proceed_271	; 0x7a62
	clr.w	(debugModeCursorRow).w	; 0x7a64
	bra.b	proceed_271	; 0x7a68

down_not_pressed:
	btst	#0, (joy1State).w	; 0x7a6a
	beq.b	proceed_271	; 0x7a70
	subq.w	#4, (debugModeCursorRow).w	; 0x7a72
	bpl.b	proceed_271	; 0x7a76
	move.w	#$000c, (debugModeCursorRow).w	; 0x7a78

proceed_271:
	moveq	#0, d0	; 0x7a7e

loop_271:
	move.w	(dmaHighwordsCommands, pc, d0.w), (4, a5)	; 0x7a80
	move.w	#3, (4, a5)	; 0x7a86
	move.w	#$0020, d1	; 0x7a8c
	move.w	(debugModeCursorRow).w, d2	; 0x7a90
	lsr.w	#1, d2	; 0x7a94
	cmp.w	d2, d0	; 0x7a96
	bne.b	skip02	; 0x7a98
	move.b	#$24, d1	; 0x7a9a

skip02:
	move.w	d1, (a5)	; 0x7a9e
	addq.w	#2, d0	; 0x7aa0
	cmpi.w	#8, d0	; 0x7aa2
	bne.b	loop_271	; 0x7aa6
	rts		; 0x7aa8

start_pressed:
	addq.w	#2, (debugMenuSubstate).w	; 0x7aaa
	jmp	(fadeOutStart).w	; 0x7aae

dmaHighwordsCommands:
	dc.w	$6692, $6792, $6892, $6992	; 0x7ab2

debugMenuState02_02:
	tst.b	(fadingDelta).w	; 0x7aba
	bne.b	return02	; 0x7abe
	addq.w	#2, (debugMenuState).w	; 0x7ac0
	clr.w	(debugMenuSubstate).w	; 0x7ac4

return02:
	rts		; 0x7ac8

debugMenuState04:
	addq.w	#2, (debugMenuState).w	; 0x7aca
	move.w	(debugModeCursorRow).w, d0	; 0x7ace
	cmpi.w	#$000c, d0	; 0x7ad2
	bne.b	@loc_00007AEA	; 0x7ad6
	jsr	(fadeOutStartAndProcess).w	; 0x7ad8
	move.l	#$00009e80, a0	; 0x7adc
	move.w	#$0010, d0	; 0x7ae2
	trap	#0	; 0x7ae6
	trap	#1	; 0x7ae8
@loc_00007AEA:
	move.l	(debugMenuCommands, pc, d0.w), a0	; 0x7aea
	move.w	#$0050, d0	; 0x7aee
	trap	#0	; 0x7af2
	rts		; 0x7af4

debugMenuCommands:
	dc.l	CMD_objectTest	; 0x7af6
	dc.l	CMD_ScrollTest	; 0x7afa
	dc.l	CMD_SoundTest	; 0x7afe

debugMenuState06:
	btst	#7, (joy1State).w	; 0x7b02
	beq.w	start_not_pressed_06	; 0x7b08
	move.w	#$0050, d0	; 0x7b0c
	trap	#2	; 0x7b10
	jsr	(fadeOutStartAndProcess).w	; 0x7b12
	clr.w	(debugMenuState).w	; 0x7b16
	clr.w	(debugMenuSubstate).w	; 0x7b1a

start_not_pressed_06:
	rts		; 0x7b1e

txtDebugSuperStreetFighterII:
	dc.b	$63	; 0x7b20
	dc.b	$0a	; 0x7b21
	dc.b	$00	; 0x7b22
	dc.b	"SUPER STREET FIGHTER #", $ff, $ff, "  - TEST MODE MENU -", $00	; 0x7b23

txtDebugObjectTestScrollTestSoundTest:
	dc.b	$66	; 0x7b50
	dc.b	$96	; 0x7b51
	dc.b	$00	; 0x7b52
	dc.b	"OBJECT TEST", $ff, $ff, "SCROLL TEST", $ff, $ff, "SOUND  TEST", $ff, $ff, "EXIT", $00	; 0x7b53
	dc.b	$04	; 0x7b7f

CMD_objectTest:
	cmpi.w	#$0700, (joy2State).w	; 0x7b80
	beq.w	stageObjectsTest	; 0x7b86
	jsr	(initDisplay).w	; 0x7b8a
	lea	($891e, pc), a0	; 0x7b8e
	jsr	(transferDataFromPageToRam).w	; 0x7b92
	lea	($8928, pc), a0	; 0x7b96
	jsr	(transferDataFromPageToRam).w	; 0x7b9a
	lea	($8932, pc), a0	; 0x7b9e
	jsr	(transferDataFromPageToRam).w	; 0x7ba2
	lea	($893c, pc), a0	; 0x7ba6
	jsr	(transferDataFromPageToRam).w	; 0x7baa
	ori.b	#$40, (VdpRegistersCache).w	; 0x7bae
	move.w	(VdpRegistersCache).w, (4, a5)	; 0x7bb4
	jsr	(clearSatCache).w	; 0x7bba
	lea	dataBuffer, a0	; 0x7bbe
	moveq	#0, d1	; 0x7bc4
	move.w	#$07ff, d7	; 0x7bc6

next_272:
	move.l	d1, (a0)+	; 0x7bca
	dbf	d7, next_272	; 0x7bcc
	clr.l	(cameraX).w	; 0x7bd0
	clr.l	(cameraY).w	; 0x7bd4
	lea	($7bec, pc), a0	; 0x7bd8
	jsr	(loadPalette).w	; 0x7bdc
	move.w	#$0440, (rawPalettes).w	; 0x7be0
	jsr	(fadeInStart).w	; 0x7be6
	bra.b	@loc_00007BF4	; 0x7bea
	dc.b	$07	; nb of colors: 15	; 0x7bec
	dc.b	$20	; first colors: 0x10	; 0x7bed
	dc.l	PALETTE_3b61e0/2	; source	; 0x7bee
	; 0x-1
	dc.w	$0000	; 0x7bf2
@loc_00007BF4:
	clr.w	(fighterTestObjectState).w	; 0x7bf4
	clr.b	(debugObjectDisplayMode).w	; 0x7bf8
	clr.b	(LBL_ffffbb8e).w	; 0x7bfc
	lea	($8956, pc), a0	; 0x7c00
	jsr	(writeText).w	; 0x7c04
	lea	($89a2, pc), a0	; 0x7c08
	jsr	(writeText).w	; 0x7c0c
	lea	($89e4, pc), a0	; 0x7c10
	jsr	(writeText).w	; 0x7c14
	lea	($89f0, pc), a0	; 0x7c18
	jsr	(writeText).w	; 0x7c1c

loop_272:
	move.b	#1, d0	; 0x7c20
	trap	#3	; 0x7c24
	lea	(fighter1Data).w, a6	; 0x7c26
	moveq	#0, d0	; 0x7c2a
	move.b	(fighterTestObjectState).w, d0	; 0x7c2c
	move.w	(fighterTestObjectStates, pc, d0.w), d0	; 0x7c30
	jsr	(fighterTestObjectStates, pc, d0.w)	; 0x7c34
	clr.b	(debugShadowSpriteLink).w	; 0x7c38
	st	(showHotSpot).w	; 0x7c3c
	moveq	#0, d0	; 0x7c40
	move.b	(debugObjectDisplayMode).w, d0	; 0x7c42
	move.w	(debugObjectDisplayFunctions, pc, d0.w), d0	; 0x7c46
	jsr	(debugObjectDisplayFunctions, pc, d0.w)	; 0x7c4a
	bsr.w	FUN_000080c0	; 0x7c4e
	bsr.w	writeFighterInfos	; 0x7c52
	bra.b	loop_272	; 0x7c56

fighterTestObjectStates:
	dc.w	fighterTestObject00-fighterTestObjectStates	; 0x7c58
	dc.w	fighterTestObject02-fighterTestObjectStates	; 0x7c5a
	dc.w	fighterTestObject04-fighterTestObjectStates	; 0x7c5c

debugObjectDisplayFunctions:
	dc.w	debugObjectDisplay00-debugObjectDisplayFunctions	; 0x7c5e
	dc.w	debugObjectDisplay02-debugObjectDisplayFunctions	; 0x7c60
	dc.w	debugObjectDisplay04-debugObjectDisplayFunctions	; 0x7c62
	dc.w	debugObjectDisplay06-debugObjectDisplayFunctions	; 0x7c64
	dc.w	debugObjectDisplay08-debugObjectDisplayFunctions	; 0x7c66
	dc.w	debugObjectDisplay0a-debugObjectDisplayFunctions	; 0x7c68
	dc.w	debugObjectDisplay08-debugObjectDisplayFunctions	; 0x7c6a
	dc.w	debugObjectDisplay0a-debugObjectDisplayFunctions	; 0x7c6c

debugObjectDisplay02:
	lea	(fighter1Data).w, a6	; 0x7c6e
	bsr.w	drawBoxes	; 0x7c72
	lea	(player_1_).w, a6	; 0x7c76
	bsr.w	drawBoxes	; 0x7c7a
	bra.b	debugObjectDisplay04	; 0x7c7e

debugObjectDisplay00:
	clr.b	(showHotSpot).w	; 0x7c80

debugObjectDisplay04:
	lea	(fighter1Data).w, a6	; 0x7c84
	move.w	#$00c0, d1	; 0x7c88
	move.w	(6, a6), d2	; 0x7c8c
	move.w	(10, a6), d3	; 0x7c90
	bsr.w	sendBoxSprite	; 0x7c94
	lea	(player_1_).w, a6	; 0x7c98
	move.w	#$00c0, d1	; 0x7c9c
	move.w	(6, a6), d2	; 0x7ca0
	move.w	(10, a6), d3	; 0x7ca4
	bra.w	sendBoxSprite	; 0x7ca8

debugObjectDisplay06:
	clr.b	(showHotSpot).w	; 0x7cac
	rts		; 0x7cb0

debugObjectDisplay08:
	clr.b	(showHotSpot).w	; 0x7cb2
	move.w	#$2400, (LBL_ffff8012).w	; 0x7cb6
	move.w	#$2400, (player_1_).w	; 0x7cbc
	rts		; 0x7cc2

debugObjectDisplay0a:
	clr.b	(showHotSpot).w	; 0x7cc4
	move.w	#$4580, (LBL_ffff8012).w	; 0x7cc8
	move.w	#$6600, (player_1_).w	; 0x7cce
	rts		; 0x7cd4

fighterTestObject00:
	addq.b	#2, (fighterTestObjectState).w	; 0x7cd6
	clr.b	(LBL_ffff9931).w	; 0x7cda
	move.w	#$0080, (6, a6)	; 0x7cde
	move.w	#$00c0, (10, a6)	; 0x7ce4
	move.b	#0, (651, a6)	; 0x7cea
	jsr	(activePlayers).w	; 0x7cf0
	move.w	#$8300, (662, a6)	; 0x7cf4
	move.b	#$ff, (1, a6)	; 0x7cfa
	move.w	#$4580, (18, a6)	; 0x7d00
	moveq	#0, d0	; 0x7d06
	move.b	d0, (fighter1TestObjectAnimId).w	; 0x7d08
	jsr	(setCharacterAnimation).w	; 0x7d0c
	lea	(768, a6), a6	; 0x7d10
	move.w	#$0080, (6, a6)	; 0x7d14
	move.w	#$00c0, (10, a6)	; 0x7d1a
	move.b	#1, (641, a6)	; 0x7d20
	move.b	#0, (651, a6)	; 0x7d26
	jsr	(activePlayers).w	; 0x7d2c
	move.w	#$8000, (662, a6)	; 0x7d30
	move.b	#$ff, (1, a6)	; 0x7d36
	move.w	#$6600, (18, a6)	; 0x7d3c
	clr.b	(a6)	; 0x7d42
	moveq	#0, d0	; 0x7d44
	move.b	d0, (fighter2TestObjectAnimId).w	; 0x7d46
	jsr	(setCharacterAnimation).w	; 0x7d4a
	moveq	#1, d0	; 0x7d4e
	move.b	d0, (LBL_ffff87a0).w	; 0x7d50
	move.b	d0, (LBL_ffff87f0).w	; 0x7d54
	move.b	d0, (LBL_ffff8800).w	; 0x7d58
	move.b	#4, (LBL_ffff87af).w	; 0x7d5c
	move.b	#4, (LBL_ffff87ff).w	; 0x7d62
	move.l	#0, (LBL_ffff87a2).w	; 0x7d68
	move.l	#0, (LBL_ffff87f2).w	; 0x7d70
	rts		; 0x7d78

fighterTestObject02:
	move.w	(joy2State).w, d1	; 0x7d7a
	andi.w	#$0240, d1	; 0x7d7e
	move.w	(joy2State).w, d0	; 0x7d82
	or.w	d1, d0	; 0x7d86
	swap	d0	; 0x7d88
	move.w	(joy1State).w, d1	; 0x7d8a
	andi.w	#$0240, d1	; 0x7d8e
	move.w	(joy1State).w, d0	; 0x7d92
	or.w	d1, d0	; 0x7d96
	move.l	d0, (fighterTestObjectKeysYC).w	; 0x7d98

loop_273:
	move.l	(fighterTestObjectKeysYC).w, d0	; 0x7d9c
	beq.b	return_272	; 0x7da0
	clr.b	(fighterTestObjectButtonId).w	; 0x7da2
	moveq	#$001f, d7	; 0x7da6

next_273:
	bclr	d7, d0	; 0x7da8
	bne.b	exit	; 0x7daa
	addq.b	#2, (fighterTestObjectButtonId).w	; 0x7dac
	dbf	d7, next_273	; 0x7db0

exit:
	move.l	d0, (fighterTestObjectKeysYC).w	; 0x7db4
	move.b	(fighterTestObjectButtonId).w, d0	; 0x7db8
	lea	(fighter1Data).w, a6	; 0x7dbc
	lea	(fighter1TestObjectAnimId).w, a4	; 0x7dc0
	move.w	(joy1State).w, d1	; 0x7dc4
	move.w	(joy1State).w, d2	; 0x7dc8
	cmpi.b	#$20, d0	; 0x7dcc
	bcc.b	fighter_1	; 0x7dd0
	lea	(player_1_).w, a6	; 0x7dd2
	lea	(fighter2TestObjectAnimId).w, a4	; 0x7dd6
	move.w	(joy2State).w, d1	; 0x7dda
	move.w	(joy2State).w, d2	; 0x7dde

fighter_1:
	ext.w	d0	; 0x7de2
	move.w	(buttonCallbacks, pc, d0.w), d0	; 0x7de4
	jsr	(buttonCallbacks, pc, d0.w)	; 0x7de8
	bra.b	loop_273	; 0x7dec

return_272:
	rts		; 0x7dee

buttonCallbacks:
	dc.w	fighterTestObjectUnavailable-buttonCallbacks	; 0x7df0
	dc.w	fighterTestObjectUnavailable-buttonCallbacks	; 0x7df2
	dc.w	fighterTestObjectUnavailable-buttonCallbacks	; 0x7df4
	dc.w	fighterTestObjectUnavailable-buttonCallbacks	; 0x7df6
	dc.w	fighterTestObjectUnavailable2-buttonCallbacks	; 0x7df8
	dc.w	button_p2_x-buttonCallbacks	; 0x7dfa
	dc.w	button_p2_y-buttonCallbacks	; 0x7dfc
	dc.w	button_p1_p2_z-buttonCallbacks	; 0x7dfe
	dc.w	fighterTestObjectUnavailable3-buttonCallbacks	; 0x7e00
	dc.w	button_p2_a-buttonCallbacks	; 0x7e02
	dc.w	button_p2_c-buttonCallbacks	; 0x7e04
	dc.w	button_p2_b-buttonCallbacks	; 0x7e06
	dc.w	button_p1_p2_right-buttonCallbacks	; 0x7e08
	dc.w	button_p1_p2_left-buttonCallbacks	; 0x7e0a
	dc.w	button_p1_p2_down-buttonCallbacks	; 0x7e0c
	dc.w	button_p1_p2_up-buttonCallbacks	; 0x7e0e
	dc.w	fighterTestObjectUnavailable-buttonCallbacks	; 0x7e10
	dc.w	fighterTestObjectUnavailable-buttonCallbacks	; 0x7e12
	dc.w	fighterTestObjectUnavailable-buttonCallbacks	; 0x7e14
	dc.w	fighterTestObjectUnavailable-buttonCallbacks	; 0x7e16
	dc.w	fighterTestObjectUnavailable2-buttonCallbacks	; 0x7e18
	dc.w	button_p1_x-buttonCallbacks	; 0x7e1a
	dc.w	button_p1_y-buttonCallbacks	; 0x7e1c
	dc.w	button_p1_p2_z-buttonCallbacks	; 0x7e1e
	dc.w	button_p1_unavailable-buttonCallbacks	; 0x7e20
	dc.w	button_p1_a-buttonCallbacks	; 0x7e22
	dc.w	button_p1_c-buttonCallbacks	; 0x7e24
	dc.w	button_p1_b-buttonCallbacks	; 0x7e26
	dc.w	button_p1_p2_right-buttonCallbacks	; 0x7e28
	dc.w	button_p1_p2_left-buttonCallbacks	; 0x7e2a
	dc.w	button_p1_p2_down-buttonCallbacks	; 0x7e2c
	dc.w	button_p1_p2_up-buttonCallbacks	; 0x7e2e

button_p1_p2_up:
	btst	#9, d1	; 0x7e30
	bne.w	fighterTestObjectUnavailable	; 0x7e34
	btst	#4, d1	; 0x7e38
	bne.b	increase_fighter_id	; 0x7e3c
	btst	#5, d1	; 0x7e3e
	bne.b	increase_kage	; 0x7e42
	moveq	#0, d1	; 0x7e44
	move.b	(651, a6), d1	; 0x7e46
	lea	($8946, pc), a0	; 0x7e4a
	move.b	(0, a0, d1), d1	; 0x7e4e
	move.b	(a4), d0	; 0x7e52
	cmp.b	d1, d0	; 0x7e54
	bcc.b	no_overflow	; 0x7e56
	addq.b	#1, d0	; 0x7e58
	move.b	d0, (a4)	; 0x7e5a
	tst.b	(641, a6)	; 0x7e5c
	beq.w	button_p1_b	; 0x7e60
	bra.w	button_p2_b	; 0x7e64

increase_fighter_id:
	move.b	(651, a6), d0	; 0x7e68
	addq.b	#1, d0	; 0x7e6c
	andi.b	#$0f, d0	; 0x7e6e
	move.b	d0, (651, a6)	; 0x7e72
	jsr	(activePlayers).w	; 0x7e76
	move.b	#$ff, (1, a6)	; 0x7e7a

no_overflow:
	move.b	(a4), d0	; 0x7e80
	cmpi.b	#$46, d0	; 0x7e82
	beq.b	eq_46	; 0x7e86
	moveq	#0, d0	; 0x7e88

eq_46:
	move.b	d0, (a4)	; 0x7e8a
	tst.b	(641, a6)	; 0x7e8c
	beq.w	button_p1_b	; 0x7e90
	bra.w	button_p2_b	; 0x7e94

increase_kage:
	addq.b	#1, (80, a6)	; 0x7e98
	andi.b	#$1f, (80, a6)	; 0x7e9c
	bra.w	fighterTestObjectUnavailable	; 0x7ea2

button_p1_p2_down:
	btst	#9, d1	; 0x7ea6
	bne.w	fighterTestObjectUnavailable	; 0x7eaa
	btst	#4, d1	; 0x7eae
	bne.b	decrease_fighter_id	; 0x7eb2
	btst	#5, d1	; 0x7eb4
	bne.b	decrease_kage	; 0x7eb8
	moveq	#0, d1	; 0x7eba
	move.b	(651, a6), d1	; 0x7ebc
	lea	($8946, pc), a0	; 0x7ec0
	move.b	(0, a0, d1), d1	; 0x7ec4
	move.b	(a4), d0	; 0x7ec8
	subq.b	#1, d0	; 0x7eca
	bcc.b	not_negative	; 0x7ecc
	move.b	d1, d0	; 0x7ece

not_negative:
	move.b	d0, (a4)	; 0x7ed0
	tst.b	(641, a6)	; 0x7ed2
	beq.b	button_p1_b	; 0x7ed6
	bra.w	button_p2_b	; 0x7ed8

decrease_fighter_id:
	move.b	(651, a6), d0	; 0x7edc
	subq.b	#1, d0	; 0x7ee0
	andi.b	#$0f, d0	; 0x7ee2
	move.b	d0, (651, a6)	; 0x7ee6
	jsr	(activePlayers).w	; 0x7eea
	move.b	#$ff, (1, a6)	; 0x7eee
	move.b	(a4), d0	; 0x7ef4
	cmpi.b	#$46, d0	; 0x7ef6
	beq.b	eq_46_273	; 0x7efa
	moveq	#0, d0	; 0x7efc

eq_46_273:
	move.b	d0, (a4)	; 0x7efe
	tst.b	(641, a6)	; 0x7f00
	beq.b	button_p1_b	; 0x7f04
	bra.b	button_p2_b	; 0x7f06

decrease_kage:
	subq.b	#1, (80, a6)	; 0x7f08
	andi.b	#$1f, (80, a6)	; 0x7f0c
	bra.w	fighterTestObjectUnavailable	; 0x7f12

button_p1_p2_left:
	btst	#9, d1	; 0x7f16
	bne.w	fighterTestObjectUnavailable	; 0x7f1a
	move.b	#$f7, d0	; 0x7f1e
	btst	#5, d1	; 0x7f22
	beq.b	no_vflip	; 0x7f26
	move.b	#$ef, d0	; 0x7f28

no_vflip:
	and.b	d0, (25, a6)	; 0x7f2c
	rts		; 0x7f30

button_p1_p2_right:
	btst	#9, d1	; 0x7f32
	bne.w	fighterTestObjectUnavailable	; 0x7f36
	move.b	#8, d0	; 0x7f3a
	btst	#5, d1	; 0x7f3e
	beq.b	no_vflip_2	; 0x7f42
	move.b	#$10, d0	; 0x7f44

no_vflip_2:
	or.b	d0, (25, a6)	; 0x7f48
	rts		; 0x7f4c

button_p1_b:
	move.b	(a4), d0	; 0x7f4e
	jsr	(setCharacterAnimation).w	; 0x7f50
	cmpi.b	#$46, (fighter2TestObjectAnimId).w	; 0x7f54
	bne.b	return_273	; 0x7f5a
	lea	(player_1_).w, a6	; 0x7f5c
	tst.b	(a6)	; 0x7f60
	beq.b	return_273	; 0x7f62
	jmp	(updateProjected).w	; 0x7f64

return_273:
	rts		; 0x7f68

button_p2_b:
	move.b	(a4), d0	; 0x7f6a
	jmp	(setCharacterAnimation).w	; 0x7f6c

button_p1_c:
	move.w	(ptrDmaQueueCurrentEntry).w, a0	; 0x7f70
	move.w	#$0800, (a0)+	; 0x7f74
	move.l	#$007f8000, (a0)+	; 0x7f78
	move.w	#$b000, (a0)+	; 0x7f7e
	move.w	a0, (ptrDmaQueueCurrentEntry).w	; 0x7f82
	st	(199, a6)	; 0x7f86
	bra.b	proceed10	; 0x7f8a

button_p2_c:
	move.w	(ptrDmaQueueCurrentEntry).w, a0	; 0x7f8c
	move.w	#$0800, (a0)+	; 0x7f90
	move.l	#$007f8000, (a0)+	; 0x7f94
	move.w	#$c000, (a0)+	; 0x7f9a
	move.w	a0, (ptrDmaQueueCurrentEntry).w	; 0x7f9e
	st	(199, a6)	; 0x7fa2

proceed10:
	addi.b	#$20, (653, a6)	; 0x7fa6
	jsr	(activePlayers).w	; 0x7fac
	move.b	#$ff, (1, a6)	; 0x7fb0
	cmpi.b	#$0b, (651, a6)	; 0x7fb6
	bne.b	not_claw	; 0x7fbc
	move.l	#$0003a3ae, (48, a6)	; 0x7fbe
	eori.b	#1, (LBL_ffffbb8e).w	; 0x7fc6
	move.b	(LBL_ffffbb8e).w, (251, a6)	; 0x7fcc
	bne.b	not_claw	; 0x7fd2
	move.l	#$0003a3b8, (48, a6)	; 0x7fd4

not_claw:
	rts		; 0x7fdc

button_p1_a:
	jsr	(updateCharAnimation).w	; 0x7fde
	cmpi.b	#$46, (fighter2TestObjectAnimId).w	; 0x7fe2
	bne.b	return20	; 0x7fe8
	lea	(player_1_).w, a6	; 0x7fea
	tst.b	(a6)	; 0x7fee
	beq.b	return20	; 0x7ff0
	jmp	(updateProjected).w	; 0x7ff2

return20:
	rts		; 0x7ff6

button_p2_a:
	jmp	(updateCharAnimation).w	; 0x7ff8

button_p1_unavailable:
	rts		; 0x7ffc

button_p1_p2_z:
	moveq	#0, d1	; 0x7ffe
	move.b	(651, a6), d1	; 0x8000
	lea	($8946, pc), a0	; 0x8004
	move.b	(0, a0, d1), d1	; 0x8008
	move.b	(a4), d0	; 0x800c
	addi.b	#$10, d0	; 0x800e
	cmp.b	d1, d0	; 0x8012
	bcc.w	no_overflow	; 0x8014
	move.b	d0, (a4)	; 0x8018
	jmp	(setCharacterAnimation).w	; 0x801a

button_p1_y:
	btst	#9, d2	; 0x801e
	beq.b	change_position_up	; 0x8022
	addq.b	#2, (debugObjectDisplayMode).w	; 0x8024
	andi.b	#$0e, (debugObjectDisplayMode).w	; 0x8028
	bra.b	change_position_up	; 0x802e

button_p2_y:
	btst	#9, d2	; 0x8030
	beq.b	change_position_up	; 0x8034
	eori.b	#1, (fightersPriority).w	; 0x8036

change_position_up:
	btst	#0, d1	; 0x803c
	beq.b	change_position_down	; 0x8040
	subi.l	#$00008000, (10, a6)	; 0x8042
	andi.w	#$01ff, (10, a6)	; 0x804a

change_position_down:
	btst	#1, d1	; 0x8050
	beq.b	change_position_left	; 0x8054
	addi.l	#$00008000, (10, a6)	; 0x8056
	andi.w	#$01ff, (10, a6)	; 0x805e

change_position_left:
	btst	#2, d1	; 0x8064
	beq.b	change_position_right	; 0x8068
	subi.l	#$00008000, (6, a6)	; 0x806a
	andi.w	#$01ff, (6, a6)	; 0x8072

change_position_right:
	btst	#3, d1	; 0x8078
	beq.b	return30	; 0x807c
	addi.l	#$00008000, (6, a6)	; 0x807e
	andi.w	#$01ff, (6, a6)	; 0x8086

return30:
	rts		; 0x808c

button_p1_x:
	clr.b	(27, a6)	; 0x808e
	jsr	(updateCharAnimation).w	; 0x8092
	cmpi.b	#$46, (fighter2TestObjectAnimId).w	; 0x8096
	bne.b	return40	; 0x809c
	lea	(player_1_).w, a6	; 0x809e
	tst.b	(a6)	; 0x80a2
	beq.b	return40	; 0x80a4
	jmp	(updateProjected).w	; 0x80a6

return40:
	rts		; 0x80aa

button_p2_x:
	clr.b	(27, a6)	; 0x80ac
	jmp	(updateCharAnimation).w	; 0x80b0

fighterTestObjectUnavailable2:
	rts		; 0x80b4

fighterTestObjectUnavailable3:
	eori.b	#1, (a6)	; 0x80b6
	rts		; 0x80ba

fighterTestObjectUnavailable:
	rts		; 0x80bc

fighterTestObject04:
	rts		; 0x80be

FUN_000080c0:
	jsr	(initStageUpdate).w	; 0x80c0
	move.w	(ptrDmaQueueCurrentEntry).w, a3	; 0x80c4
	move.w	(ptrCurrentSpriteInSatBuffer).w, a4	; 0x80c8
	tst.b	(fightersPriority).w	; 0x80cc
	bne.b	@fighter2_has_priority	; 0x80d0
	jsr	updateFighter1	; 0x80d2
	jsr	updateFighter2	; 0x80d8
	bra.b	@proceed	; 0x80de
@fighter2_has_priority:
	jsr	updateFighter2	; 0x80e0
	jsr	updateFighter1	; 0x80e6
@proceed:
	tst.b	(showHotSpot).w	; 0x80ec
	beq.b	@dont_show_hotspot	; 0x80f0
	movem.l	a3/a4, -(a7)	; 0x80f2
	lea	(LBL_ffff87a0).w, a6	; 0x80f6
	jsr	someObjectFunction03	; 0x80fa
	tst.b	(1, a6)	; 0x8100
	beq.b	@fighter1_inactive	; 0x8104
	move.b	#$ff, (1, a6)	; 0x8106
	move.b	(fighter1Data).w, d0	; 0x810c
	bne.b	@fighter1_inactive	; 0x8110
	move.b	d0, (1, a6)	; 0x8112
@fighter1_inactive:
	move.w	(LBL_ffff800a).w, (10, a6)	; 0x8116
	move.w	#$04c0, (18, a6)	; 0x811c
	lea	(LBL_ffff87f0).w, a6	; 0x8122
	jsr	someObjectFunction03	; 0x8126
	tst.b	(1, a6)	; 0x812c
	beq.b	@fighter2_inactive	; 0x8130
	move.b	#$ff, (1, a6)	; 0x8132
	move.b	(player_1_).w, d0	; 0x8138
	bne.b	@fighter2_inactive	; 0x813c
	move.b	d0, (1, a6)	; 0x813e

@fighter2_inactive:
	move.w	(player_1_).w, (10, a6)	; 0x8142
	move.w	#$04c0, (18, a6)	; 0x8148
	movem.l	(a7)+, a4/a3	; 0x814e
	jsr	updateObjects5	; 0x8152
@dont_show_hotspot:
	move.w	(ptrDmaQueueCurrentEntry).w, a0	; 0x8158
	move.w	a3, a1	; 0x815c
	cmpa.w	a1, a0	; 0x815e
	beq.w	@no_extra_infos	; 0x8160
	move.l	#$642e0003, d6	; 0x8164
	moveq	#$0011, d7	; 0x816a
@next_data:
	move.l	d6, (4, a5)	; 0x816c
	move.l	#$00200020, d0	; 0x8170
	move.l	d0, (a5)	; 0x8176
	move.l	d0, (a5)	; 0x8178
	move.l	d0, (a5)	; 0x817a
	move.l	d0, (a5)	; 0x817c
	addi.l	#$00800000, d6	; 0x817e
	dbf	d7, @next_data	; 0x8184
	move.l	#$642e0003, d6	; 0x8188
@next_info:
	cmpa.w	a1, a0	; 0x818e
	beq.b	@no_extra_infos	; 0x8190
	move.b	(6, a0), d0	; 0x8192
	andi.b	#$c0, d0	; 0x8196
	cmpi.b	#$80, d0	; 0x819a
	beq.b	@eq_80	; 0x819e
	lea	(8, a0), a0	; 0x81a0
	bra.b	@next_info	; 0x81a4
@eq_80:
	move.l	d6, (4, a5)	; 0x81a6
	move.w	#$0025, (a5)	; 0x81aa
	move.w	(a0)+, d0	; 0x81ae
	lsr.w	#4, d0	; 0x81b0
	bsr.w	writeHex8Number	; 0x81b2
	addi.l	#$00820000, d6	; 0x81b6
	move.l	d6, (4, a5)	; 0x81bc
	move.l	(a0)+, d0	; 0x81c0
	lsl.l	#1, d0	; 0x81c2
	swap	d0	; 0x81c4
	bsr.w	writeHex8Number	; 0x81c6
	swap	d0	; 0x81ca
	bsr.w	writeHex16Number	; 0x81cc
	addi.l	#$00800000, d6	; 0x81d0
	move.l	d6, (4, a5)	; 0x81d6
	move.w	(a0)+, d0	; 0x81da
	lsr.w	#5, d0	; 0x81dc
	bsr.w	writeHex12Number	; 0x81de
	addi.l	#$007e0000, d6	; 0x81e2
	bra.b	@next_info	; 0x81e8
@no_extra_infos:
	move.w	a3, (ptrDmaQueueCurrentEntry).w	; 0x81ea
	move.w	a4, (ptrCurrentSpriteInSatBuffer).w	; 0x81ee
	rts		; 0x81f2

writeFighterInfos:
	lea	(player_1_).w, a4	; 0x81f4
	lea	(fighter1Data).w, a6	; 0x81f8
	move.l	#$60920003, (4, a5)	; 0x81fc
	move.b	(651, a6), d0	; 0x8204
	bsr.w	writeHex8Number	; 0x8208
	move.l	#$61120003, (4, a5)	; 0x820c
	move.b	(fighter1TestObjectAnimId).w, d0	; 0x8214
	bsr.w	writeHex8Number	; 0x8218
	move.l	#$61920003, (4, a5)	; 0x821c
	move.b	(27, a6), d0	; 0x8224
	bsr.w	writeHex8Number	; 0x8228
	move.l	#$62120003, (4, a5)	; 0x822c
	move.b	(26, a6), d0	; 0x8234
	bsr.w	writeHex8Number	; 0x8238
	move.l	#$62920003, (4, a5)	; 0x823c
	move.b	(198, a6), d0	; 0x8244
	bsr.w	writeHex8Number	; 0x8248
	move.l	#$63120003, (4, a5)	; 0x824c
	move.b	(25, a6), d0	; 0x8254
	bsr.w	writeHex8Number	; 0x8258
	move.l	#$63920003, (4, a5)	; 0x825c
	move.b	(653, a6), d0	; 0x8264
	lsr.b	#5, d0	; 0x8268
	bsr.w	writeHex8Number	; 0x826a
	move.l	#$64120003, (4, a5)	; 0x826e
	move.b	(currentSpriteLink).w, d0	; 0x8276
	sub.b	(debugShadowSpriteLink).w, d0	; 0x827a
	bsr.w	writeHex8Number	; 0x827e
	move.l	#$60ba0003, (4, a5)	; 0x8282
	move.b	(651, a4), d0	; 0x828a
	bsr.w	writeHex8Number	; 0x828e
	move.l	#$613a0003, (4, a5)	; 0x8292
	move.b	(fighter2TestObjectAnimId).w, d0	; 0x829a
	bsr.w	writeHex8Number	; 0x829e
	move.l	#$61ba0003, (4, a5)	; 0x82a2
	move.b	(27, a4), d0	; 0x82aa
	bsr.w	writeHex8Number	; 0x82ae
	move.l	#$623a0003, (4, a5)	; 0x82b2
	move.b	(26, a4), d0	; 0x82ba
	bsr.w	writeHex8Number	; 0x82be
	move.l	#$62ba0003, (4, a5)	; 0x82c2
	move.b	(198, a4), d0	; 0x82ca
	bsr.w	writeHex8Number	; 0x82ce
	move.l	#$633a0003, (4, a5)	; 0x82d2
	move.b	(25, a4), d0	; 0x82da
	bsr.w	writeHex8Number	; 0x82de
	move.l	#$63ba0003, (4, a5)	; 0x82e2
	move.b	(653, a4), d0	; 0x82ea
	lsr.b	#5, d0	; 0x82ee
	bsr.w	writeHex8Number	; 0x82f0
	move.l	#$6d2e0003, (4, a5)	; 0x82f4
	move.w	(6, a4), d0	; 0x82fc
	sub.w	(6, a6), d0	; 0x8300
	bsr.w	writeHex8Number	; 0x8304
	move.l	#$6d380003, (4, a5)	; 0x8308
	move.w	(10, a4), d0	; 0x8310
	sub.w	(10, a6), d0	; 0x8314
	bsr.w	writeHex8Number	; 0x8318
	move.l	#$650c0003, (4, a5)	; 0x831c
	move.b	(74, a6), d0	; 0x8324
	bsr.w	writeHex8Number	; 0x8328
	move.l	#$658c0003, (4, a5)	; 0x832c
	move.b	(75, a6), d0	; 0x8334
	bsr.w	writeHex8Number	; 0x8338
	move.l	#$660c0003, (4, a5)	; 0x833c
	move.b	(76, a6), d0	; 0x8344
	bsr.w	writeHex8Number	; 0x8348
	move.l	#$668c0003, (4, a5)	; 0x834c
	move.b	(77, a6), d0	; 0x8354
	bsr.w	writeHex8Number	; 0x8358
	move.l	#$670c0003, (4, a5)	; 0x835c
	move.b	(78, a6), d0	; 0x8364
	bsr.w	writeHex8Number	; 0x8368
	move.l	#$678c0003, (4, a5)	; 0x836c
	move.b	(79, a6), d0	; 0x8374
	bsr.w	writeHex8Number	; 0x8378
	move.l	#$680c0003, (4, a5)	; 0x837c
	move.b	(80, a6), d0	; 0x8384
	bsr.w	writeHex8Number	; 0x8388
	move.l	#$688c0003, (4, a5)	; 0x838c
	move.b	(81, a6), d0	; 0x8394
	bsr.w	writeHex8Number	; 0x8398
	move.l	#$698c0003, (4, a5)	; 0x839c
	move.b	(82, a6), d0	; 0x83a4
	bsr.w	writeHex8Number	; 0x83a8
	move.l	#$6a0c0003, (4, a5)	; 0x83ac
	move.b	(83, a6), d0	; 0x83b4
	bsr.w	writeHex8Number	; 0x83b8
	move.l	#$6a8c0003, (4, a5)	; 0x83bc
	move.b	(84, a6), d0	; 0x83c4
	bsr.w	writeHex8Number	; 0x83c8
	move.l	#$6b0c0003, (4, a5)	; 0x83cc
	move.b	(85, a6), d0	; 0x83d4
	bsr.w	writeHex8Number	; 0x83d8
	move.l	#$6b8c0003, (4, a5)	; 0x83dc
	move.b	(86, a6), d0	; 0x83e4
	bsr.w	writeHex8Number	; 0x83e8
	move.l	#$6c0c0003, (4, a5)	; 0x83ec
	move.b	(87, a6), d0	; 0x83f4
	bsr.w	writeHex8Number	; 0x83f8
	move.l	#$6c8c0003, (4, a5)	; 0x83fc
	move.b	(88, a6), d0	; 0x8404
	bsr.w	writeHex8Number	; 0x8408
	move.l	#$6d0c0003, (4, a5)	; 0x840c
	move.b	(89, a6), d0	; 0x8414
	bra.w	writeHex8Number	; 0x8418

drawBoxes:
	tst.b	(a6)	; 0x841c
	beq.w	return_336	; 0x841e
	moveq	#0, d0	; 0x8422
	moveq	#0, d1	; 0x8424
	move.w	#$00c1, d2	; 0x8426
	move.b	(74, a6), d1	; 0x842a
	bsr.b	debugDrawBoxAlt	; 0x842e
	moveq	#2, d0	; 0x8430
	moveq	#0, d1	; 0x8432
	move.w	#$00c5, d2	; 0x8434
	move.b	(75, a6), d1	; 0x8438
	bsr.b	debugDrawBoxAlt	; 0x843c
	moveq	#4, d0	; 0x843e
	moveq	#0, d1	; 0x8440
	move.w	#$00c2, d2	; 0x8442
	move.b	(76, a6), d1	; 0x8446
	bsr.b	debugDrawBoxAlt	; 0x844a
	moveq	#6, d0	; 0x844c
	moveq	#0, d1	; 0x844e
	move.w	#$00c4, d2	; 0x8450
	move.b	(78, a6), d1	; 0x8454
	beq.b	@no_atck	; 0x8458
	move.l	(48, a6), a0	; 0x845a
	move.w	(0, a0, d0), d0	; 0x845e
	adda.w	d0, a0	; 0x8462
	add.w	d1, d1	; 0x8464
	add.w	d1, d1	; 0x8466
	move.w	d1, d0	; 0x8468
	add.w	d1, d1	; 0x846a
	add.w	d0, d1	; 0x846c
	adda.w	d1, a0	; 0x846e
	bsr.b	debugDrawBox	; 0x8470
@no_atck:
	moveq	#8, d0	; 0x8472
	moveq	#0, d1	; 0x8474
	move.w	#$00c6, d2	; 0x8476
	move.b	(79, a6), d1	; 0x847a

debugDrawBoxAlt:
	beq.w	return_336	; 0x847e
	move.l	(48, a6), a0	; 0x8482
	move.w	(0, a0, d0), d0	; 0x8486
	adda.w	d0, a0	; 0x848a
	add.w	d1, d1	; 0x848c
	add.w	d1, d1	; 0x848e
	adda.w	d1, a0	; 0x8490

debugDrawBox:
	move.w	d2, d1	; 0x8492
	move.b	(a0), d0	; 0x8494
	ext.w	d0	; 0x8496
	btst	#3, (25, a6)	; 0x8498
	beq.b	@not_hflipped	; 0x849e
	neg.w	d0	; 0x84a0
@not_hflipped:
	move.w	(6, a6), d2	; 0x84a2
	add.w	d0, d2	; 0x84a6
	move.b	(1, a0), d0	; 0x84a8
	ext.w	d0	; 0x84ac
	btst	#4, (25, a6)	; 0x84ae
	beq.b	@not_vflipped	; 0x84b4
	neg.w	d0	; 0x84b6
@not_vflipped:
	move.w	(10, a6), d3	; 0x84b8
	sub.w	d0, d3	; 0x84bc
	moveq	#0, d0	; 0x84be
	move.b	(2, a0), d0	; 0x84c0
	sub.w	d0, d2	; 0x84c4
	moveq	#0, d0	; 0x84c6
	move.b	(3, a0), d0	; 0x84c8
	sub.w	d0, d3	; 0x84cc
	bsr.b	sendBoxSprite	; 0x84ce
	ori.w	#$0800, d1	; 0x84d0
	moveq	#0, d0	; 0x84d4
	move.b	(2, a0), d0	; 0x84d6
	add.w	d0, d0	; 0x84da
	add.w	d0, d2	; 0x84dc
	bsr.b	sendBoxSprite	; 0x84de
	ori.w	#$1800, d1	; 0x84e0
	moveq	#0, d0	; 0x84e4
	move.b	(3, a0), d0	; 0x84e6
	add.w	d0, d0	; 0x84ea
	add.w	d0, d3	; 0x84ec
	bsr.b	sendBoxSprite	; 0x84ee
	andi.w	#$f7ff, d1	; 0x84f0
	moveq	#0, d0	; 0x84f4
	move.b	(2, a0), d0	; 0x84f6
	add.w	d0, d0	; 0x84fa
	sub.w	d0, d2	; 0x84fc
	bsr.b	sendBoxSprite	; 0x84fe

return_336:
	rts		; 0x8500

sendBoxSprite:
	addq.b	#1, (currentSpriteLink).w	; 0x8502
	addq.b	#1, (debugShadowSpriteLink).w	; 0x8506
	move.w	(ptrCurrentSpriteInSatBuffer).w, a1	; 0x850a
	move.w	d3, d0	; 0x850e
	addi.w	#$007c, d0	; 0x8510
	move.w	d0, (a1)+	; 0x8514
	move.b	#0, (a1)+	; 0x8516
	move.b	(currentSpriteLink).w, (a1)+	; 0x851a
	move.w	d1, (a1)+	; 0x851e
	move.w	d2, d0	; 0x8520
	addi.w	#$007c, d0	; 0x8522
	move.w	d0, (a1)+	; 0x8526
	move.w	a1, (ptrCurrentSpriteInSatBuffer).w	; 0x8528
	rts		; 0x852c

writeHex16Number:
	move.w	d0, d1	; 0x852e
	andi.w	#$f000, d1	; 0x8530
	rol.w	#4, d1	; 0x8534
	move.b	(strHexDigits, pc, d1.w), d1	; 0x8536
	move.w	d1, (a5)	; 0x853a

writeHex12Number:
	move.w	d0, d1	; 0x853c
	andi.w	#$0f00, d1	; 0x853e
	lsr.w	#8, d1	; 0x8542
	move.b	(strHexDigits, pc, d1.w), d1	; 0x8544
	move.w	d1, (a5)	; 0x8548

writeHex8Number:
	move.w	d0, d1	; 0x854a
	andi.w	#$00f0, d1	; 0x854c
	lsr.w	#4, d1	; 0x8550
	move.b	(strHexDigits, pc, d1.w), d1	; 0x8552
	move.w	d1, (a5)	; 0x8556
	move.w	d0, d1	; 0x8558
	andi.w	#$000f, d1	; 0x855a
	move.b	(strHexDigits, pc, d1.w), d1	; 0x855e
	move.w	d1, (a5)	; 0x8562
	rts		; 0x8564

strHexDigits:
	dc.b	$30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $41, $42, $43, $44, $45, $46	; 0x8566

stageObjectsTest:
	jsr	(initDisplay).w	; 0x8576
	lea	($891e, pc), a0	; 0x857a
	jsr	(transferDataFromPageToRam).w	; 0x857e
	lea	($8928, pc), a0	; 0x8582
	jsr	(transferDataFromPageToRam).w	; 0x8586
	ori.b	#$40, (VdpRegistersCache).w	; 0x858a
	move.w	(VdpRegistersCache).w, (4, a5)	; 0x8590
	jsr	(clearSatCache).w	; 0x8596
	lea	dataBuffer, a0	; 0x859a
	moveq	#0, d1	; 0x85a0
	move.w	#$07ff, d7	; 0x85a2
@next:
	move.l	d1, (a0)+	; 0x85a6
	dbf	d7, @next	; 0x85a8
	clr.l	(cameraX).w	; 0x85ac
	clr.l	(cameraY).w	; 0x85b0
	lea	($7bec, pc), a0	; 0x85b4
	jsr	(loadPalette).w	; 0x85b8
	move.w	#$0440, (rawPalettes).w	; 0x85bc
	jsr	(fadeInStart).w	; 0x85c2
	clr.w	(fighterTestObjectState).w	; 0x85c6
	lea	($8a54, pc), a0	; 0x85ca
	jsr	(writeText).w	; 0x85ce
	lea	($8a98, pc), a0	; 0x85d2
	jsr	(writeText).w	; 0x85d6
@loop:
	move.b	#1, d0	; 0x85da
	trap	#3	; 0x85de
	lea	(objectsData).w, a6	; 0x85e0
	moveq	#0, d0	; 0x85e4
	move.b	(fighterTestObjectState).w, d0	; 0x85e6
	move.w	(debugObjectTestFunctions, pc, d0.w), d0	; 0x85ea
	jsr	(debugObjectTestFunctions, pc, d0.w)	; 0x85ee
	bsr.w	displayObjectSprites	; 0x85f2
	bsr.w	displayObjectInfos	; 0x85f6
	bra.b	@loop	; 0x85fa

debugObjectTestFunctions:
	dc.w	debugObjectTest00-debugObjectTestFunctions	; 0x85fc
	dc.w	debugObjectTest02-debugObjectTestFunctions	; 0x85fe
	dc.w	debugObjectTest04-debugObjectTestFunctions	; 0x8600

debugObjectTest04:
	rts		; 0x8602

debugObjectTest00:
	addq.b	#2, (fighterTestObjectState).w	; 0x8604
	move.w	#$0080, (6, a6)	; 0x8608
	move.w	#$00c0, (10, a6)	; 0x860e
	move.b	#1, (a6)	; 0x8614
	st	(1, a6)	; 0x8618
	moveq	#0, d0	; 0x861c
	move.b	d0, (debugObjectId).w	; 0x861e
	jsr	(setObjectAnimation).w	; 0x8622
	move.w	#$0400, (18, a6)	; 0x8626
	move.w	#$0400, (20, a6)	; 0x862c
	move.w	(ptrDmaQueueCurrentEntry).w, a0	; 0x8632
	moveq	#0, d0	; 0x8636
	move.b	(debugObjectId).w, d0	; 0x8638
	lsl.w	#3, d0	; 0x863c
	lea	($8acc, pc), a1	; 0x863e
	adda.w	d0, a1	; 0x8642
	move.w	(a1)+, (a0)+	; 0x8644
	move.l	(a1)+, (a0)+	; 0x8646
	move.w	(a1)+, (a0)+	; 0x8648
	move.w	a0, (ptrDmaQueueCurrentEntry).w	; 0x864a
	moveq	#0, d0	; 0x864e
	move.b	d0, (fighter1TestObjectAnimId).w	; 0x8650
	jmp	(setObjectFrame).w	; 0x8654

debugObjectTest02:
	bsr.w	FUN_000087b2	; 0x8658
	beq.w	return	; 0x865c
	moveq	#0, d0	; 0x8660
	move.b	d1, (fighterTestObjectButtonId).w	; 0x8662
	move.w	(fighterTestObjectCallbacks, pc, d1.w), d1	; 0x8666
	jmp	(fighterTestObjectCallbacks, pc, d1.w)	; 0x866a

return:
	rts		; 0x866e

fighterTestObjectCallbacks:
	dc.w	objectTest_x-fighterTestObjectCallbacks	; 0x8670
	dc.w	objectTest_c-fighterTestObjectCallbacks	; 0x8672
	dc.w	objectTest_y-fighterTestObjectCallbacks	; 0x8674
	dc.w	objectTest_left_right-fighterTestObjectCallbacks	; 0x8676
	dc.w	objectTest_left_right-fighterTestObjectCallbacks	; 0x8678
	dc.w	objectTest_down-fighterTestObjectCallbacks	; 0x867a
	dc.w	objectTest_up-fighterTestObjectCallbacks	; 0x867c

objectTest_x:
	tst.b	(27, a6)	; 0x867e
	bmi.b	return_337	; 0x8682
	jmp	(setProjectileFrame).w	; 0x8684

return_337:
	rts		; 0x8688

objectTest_c:
	tst.b	(27, a6)	; 0x868a
	bmi.b	return_337	; 0x868e
	clr.b	(27, a6)	; 0x8690
	jmp	(setProjectileFrame).w	; 0x8694

objectTest_y:
	move.b	(fighter1TestObjectAnimId).w, d0	; 0x8698
	jmp	(setObjectFrame).w	; 0x869c

objectTest_left_right:
	eori.b	#8, (25, a6)	; 0x86a0
	rts		; 0x86a6

objectTest_down:
	move.w	(fighterTestObjectKeysYC).w, d1	; 0x86a8
	btst	#8, d1	; 0x86ac
	bne.w	@objectTest_down_z	; 0x86b0
	moveq	#0, d1	; 0x86b4
	move.b	(debugObjectId).w, d1	; 0x86b6
	lea	($8aa4, pc), a0	; 0x86ba
	move.b	(0, a0, d1), d1	; 0x86be
	move.b	(fighter1TestObjectAnimId).w, d0	; 0x86c2
	subq.b	#1, d0	; 0x86c6
	bpl.b	@not_overflow_4	; 0x86c8
	move.b	d1, d0	; 0x86ca
@not_overflow_4:
	move.b	d0, (fighter1TestObjectAnimId).w	; 0x86cc
	bra.b	objectTest_y	; 0x86d0
@objectTest_down_z:
	move.b	(debugObjectId).w, d0	; 0x86d2
	subq.b	#1, d0	; 0x86d6
	bpl.b	@not_overflow	; 0x86d8
	move.b	#$26, d0	; 0x86da
@not_overflow:
	move.b	d0, (debugObjectId).w	; 0x86de
	jsr	(setObjectAnimation).w	; 0x86e2
	move.w	(ptrDmaQueueCurrentEntry).w, a0	; 0x86e6
	moveq	#0, d0	; 0x86ea
	move.b	(debugObjectId).w, d0	; 0x86ec
	lsl.w	#3, d0	; 0x86f0
	lea	($8acc, pc), a1	; 0x86f2
	adda.w	d0, a1	; 0x86f6
	move.w	(a1)+, (a0)+	; 0x86f8
	move.l	(a1)+, (a0)+	; 0x86fa
	move.w	(a1)+, (a0)+	; 0x86fc
	move.w	a0, (ptrDmaQueueCurrentEntry).w	; 0x86fe
	move.w	#$0400, (18, a6)	; 0x8702
	move.w	#$0400, (20, a6)	; 0x8708
	cmpi.b	#$19, (debugObjectId).w	; 0x870e
	bne.b	@not_object_19	; 0x8714
	move.w	#$24c0, (18, a6)	; 0x8716
	move.w	#$24c0, (20, a6)	; 0x871c
@not_object_19:
	clr.b	(fighter1TestObjectAnimId).w	; 0x8722
	bra.w	objectTest_y	; 0x8726

objectTest_up:
	move.w	(fighterTestObjectKeysYC).w, d1	; 0x872a
	btst	#8, d1	; 0x872e
	bne.w	objectTest_up_z	; 0x8732
	moveq	#0, d1	; 0x8736
	move.b	(debugObjectId).w, d1	; 0x8738
	lea	($8aa4, pc), a0	; 0x873c
	move.b	(0, a0, d1), d1	; 0x8740
	move.b	(fighter1TestObjectAnimId).w, d0	; 0x8744
	addq.b	#1, d0	; 0x8748
	cmp.b	d1, d0	; 0x874a
	bcs.b	@not_overflow_2	; 0x874c
	moveq	#0, d0	; 0x874e
@not_overflow_2:
	move.b	d0, (fighter1TestObjectAnimId).w	; 0x8750
	bra.w	objectTest_y	; 0x8754

objectTest_up_z:
	move.b	(debugObjectId).w, d0	; 0x8758
	addq.b	#1, d0	; 0x875c
	cmpi.b	#$26, d0	; 0x875e
	bcs.b	@not_overflow_3	; 0x8762
	moveq	#0, d0	; 0x8764
@not_overflow_3:
	move.b	d0, (debugObjectId).w	; 0x8766
	jsr	(setObjectAnimation).w	; 0x876a
	move.w	(ptrDmaQueueCurrentEntry).w, a0	; 0x876e
	moveq	#0, d0	; 0x8772
	move.b	(debugObjectId).w, d0	; 0x8774
	lsl.w	#3, d0	; 0x8778
	lea	($8acc, pc), a1	; 0x877a
	adda.w	d0, a1	; 0x877e
	move.w	(a1)+, (a0)+	; 0x8780
	move.l	(a1)+, (a0)+	; 0x8782
	move.w	(a1)+, (a0)+	; 0x8784
	move.w	a0, (ptrDmaQueueCurrentEntry).w	; 0x8786
	move.w	#$0400, (18, a6)	; 0x878a
	move.w	#$0400, (20, a6)	; 0x8790
	cmpi.b	#$19, (debugObjectId).w	; 0x8796
	bne.b	@not_object_19_2	; 0x879c
	move.w	#$24c0, (18, a6)	; 0x879e
	move.w	#$24c0, (20, a6)	; 0x87a4
@not_object_19_2:
	clr.b	(fighter1TestObjectAnimId).w	; 0x87aa
	bra.w	objectTest_y	; 0x87ae

FUN_000087b2:
	move.w	(joy1State).w, d0	; 0x87b2
	andi.w	#$0500, d0	; 0x87b6
	move.w	(joy1State).w, d1	; 0x87ba
	andi.w	#$027f, d1	; 0x87be
	or.w	d1, d0	; 0x87c2
	move.w	d0, (fighterTestObjectKeysYC).w	; 0x87c4
	beq.b	@return_with_0	; 0x87c8
	moveq	#0, d1	; 0x87ca
	btst	#$000a, d0	; 0x87cc
	bne.b	@return_with_1	; 0x87d0
	addq.b	#2, d1	; 0x87d2
	btst	#5, d0	; 0x87d4
	bne.b	@return_with_1	; 0x87d8
	addq.b	#2, d1	; 0x87da
	btst	#9, d0	; 0x87dc
	bne.b	@return_with_1	; 0x87e0
	addq.b	#2, d1	; 0x87e2
	andi.w	#$000f, d0	; 0x87e4
	moveq	#3, d7	; 0x87e8
@next:
	btst	d7, d0	; 0x87ea
	bne.b	@return_with_1	; 0x87ec
	addq.b	#2, d1	; 0x87ee
	dbf	d7, @next	; 0x87f0
	bra.b	@return_with_0	; 0x87f4
@return_with_1:
	moveq	#1, d0	; 0x87f6
	rts		; 0x87f8
@return_with_0:
	moveq	#0, d0	; 0x87fa
	rts		; 0x87fc

displayObjectInfos:
	lea	(objectsData).w, a6	; 0x87fe
	move.l	#$60920003, (4, a5)	; 0x8802
	move.b	(debugObjectId).w, d0	; 0x880a
	bsr.w	writeHex8Number	; 0x880e
	move.l	#$61120003, (4, a5)	; 0x8812
	move.b	(fighter1TestObjectAnimId).w, d0	; 0x881a
	bsr.w	writeHex8Number	; 0x881e
	move.l	#$61920003, (4, a5)	; 0x8822
	move.b	(27, a6), d0	; 0x882a
	bsr.w	writeHex8Number	; 0x882e
	move.l	#$62120003, (4, a5)	; 0x8832
	move.b	(26, a6), d0	; 0x883a
	bsr.w	writeHex8Number	; 0x883e
	move.l	#$62920003, (4, a5)	; 0x8842
	move.b	#0, d0	; 0x884a
	bsr.w	writeHex8Number	; 0x884e
	move.l	#$63120003, (4, a5)	; 0x8852
	move.b	(25, a6), d0	; 0x885a
	bsr.w	writeHex8Number	; 0x885e
	move.l	#$64120003, (4, a5)	; 0x8862
	move.b	(currentSpriteLink).w, d0	; 0x886a
	sub.b	(debugShadowSpriteLink).w, d0	; 0x886e
	bra.w	writeHex8Number	; 0x8872

displayObjectSprites:
	move.w	(ptrCurrentSpriteInSatBuffer).w, a4	; 0x8876
	lea	(objectsData).w, a6	; 0x887a
	move.l	(40, a6), a0	; 0x887e
	move.w	(a0)+, d7	; 0x8882
@next:
	move.w	(a0)+, d0	; 0x8884
	move.w	(a0)+, d1	; 0x8886
	move.b	(a0)+, d2	; 0x8888
	move.b	(a0)+, d3	; 0x888a
	bsr.w	sendSpriteToSatBufferAlt	; 0x888c
	dbf	d7, @next	; 0x8890
	move.w	a4, (ptrCurrentSpriteInSatBuffer).w	; 0x8894
	rts		; 0x8898

sendSpriteToSatBufferAlt:
	cmpi.b	#$40, (currentSpriteLink).w	; 0x889a
	bcc.w	@return	; 0x88a0
	addq.b	#1, (currentSpriteLink).w	; 0x88a4
	btst	#4, (25, a6)	; 0x88a8
	beq.b	@not_vflipped	; 0x88ae
	andi.w	#3, d3	; 0x88b0
	addq.w	#1, d3	; 0x88b4
	lsl.w	#3, d3	; 0x88b6
	add.w	d3, d1	; 0x88b8
	neg.w	d1	; 0x88ba
	move.b	(-1, a0), d3	; 0x88bc
@not_vflipped:
	addi.w	#$0080, d1	; 0x88c0
	add.w	(10, a6), d1	; 0x88c4
	move.w	d1, (a4)+	; 0x88c8
	move.b	d3, d1	; 0x88ca
	andi.b	#$0f, d1	; 0x88cc
	move.b	d1, (a4)+	; 0x88d0
	move.b	(currentSpriteLink).w, (a4)+	; 0x88d2
	move.b	d3, d1	; 0x88d6
	lsl.w	#7, d1	; 0x88d8
	andi.w	#$1800, d1	; 0x88da
	move.b	d2, d1	; 0x88de
	add.w	(18, a6), d1	; 0x88e0
	move.b	d3, d3	; 0x88e4
	bpl.b	@not_adjust_palette	; 0x88e6
	andi.w	#$1fff, d1	; 0x88e8
	or.w	(20, a6), d1	; 0x88ec
@not_adjust_palette:
	move.b	(25, a6), d2	; 0x88f0
	lsl.w	#8, d2	; 0x88f4
	eor.w	d2, d1	; 0x88f6
	move.w	d1, (a4)+	; 0x88f8
	btst	#3, (25, a6)	; 0x88fa
	beq.b	@not_hflipped	; 0x8900
	andi.w	#$000c, d3	; 0x8902
	addq.w	#4, d3	; 0x8906
	add.w	d3, d3	; 0x8908
	add.w	d3, d0	; 0x890a
	neg.w	d0	; 0x890c
	move.b	(-1, a0), d3	; 0x890e
@not_hflipped:
	add.w	(6, a6), d0	; 0x8912
	addi.w	#$0080, d0	; 0x8916
	move.w	d0, (a4)+	; 0x891a
@return:
	rts		; 0x891c
	dc.b	$02, $00, $00, $3b, $4f, $e0, $18, $00, $00, $00	; 0x891e
	dc.w	$1000	; nb of bytes	; 0x8928
	dc.l	PATTERNS_3b51e0/2	; source	; 0x892a
	dc.w	$8000	; destination in VRAM	; 0x892e
	; 0x-1
	dc.w	$0000	; 0x8930
	dc.w	$13C0	; nb of bytes	; 0x8932
	dc.l	PATTERNS_3c73e0/2	; source	; 0x8934
	dc.w	$9800	; destination in VRAM	; 0x8938
	; 0x-1
	dc.w	$0000	; 0x893a
	dc.w	$400	; nb of bytes	; 0x893c
	dc.l	PATTERNS_3c87a0/2	; source	; 0x893e
	dc.w	$AC00	; destination in VRAM	; 0x8942
	; 0x-1
	dc.w	$0000	; 0x8944

nbOfAnimsPerFighter:
	dc.b	$b6, $c6, $d1, $b2, $b6, $d8, $b4, $b1, $ff, $b2, $ba, $ff, $ff, $ff, $ff, $ff	; 0x8946

textPlrTyp_SeqNum_:
	dc.b	$60	; 0x8956
	dc.b	$82	; 0x8957
	dc.b	$00	; 0x8958
	dc.b	"PLR TYP=", $ff, "SEQ NUM=", $ff, "INT NUM=", $ff, "CHR TYP=", $ff, "PAT NUM=", $ff, "CHR DIR=", $ff, "COL NUM=", $ff, "OBJ NUM=", $00	; 0x8959
	dc.b	$41	; 0x89a1

textPlrTyp_SeqNum_Alt_:
	dc.b	$60	; 0x89a2
	dc.b	$aa	; 0x89a3
	dc.b	$00	; 0x89a4
	dc.b	"PLR TYP=", $ff, "SEQ NUM=", $ff, "INT NUM=", $ff, "CHR TYP=", $ff, "PAT NUM=", $ff, "CHR DIR=", $ff, "COL NUM=", $00	; 0x89a5

textX_Y:
	dc.b	$6d	; 0x89e4
	dc.b	$2a	; 0x89e5
	dc.b	$00	; 0x89e6
	dc.b	"X=   Y=", $00	; 0x89e7
	dc.b	$43	; 0x89ef

textHead_Body_Foot_Weak_:
	dc.b	$65	; 0x89f0
	dc.b	$02	; 0x89f1
	dc.b	$00	; 0x89f2
	dc.b	"HEAD=", $ff, "BODY=", $ff, "FOOT=", $ff, "WEAK=", $ff, "ATCK=", $ff, "BDY1=", $ff, "KAGE=", $ff, "PRIO=", $ff, $ff, "CACH=", $ff, "BLCK=", $ff, "SITC=", $ff, "CDIR=", $ff, "TRYY=", $ff, "WTYP=", $ff, "YOK2=", $ff, "YOKE=", $00	; 0x89f3

textGroup_SeqNum_IntNum_:
	dc.b	$60	; 0x8a54
	dc.b	$82	; 0x8a55
	dc.b	$00	; 0x8a56
	dc.b	"GROUP  =", $ff, "SEQ NUM=", $ff, "INT NUM=", $ff, "NO  USE=", $ff, "PAT NUM=", $ff, "CHR DIR=", $ff, $ff, "OBJ NUM=", $00	; 0x8a57
	dc.b	$20	; 0x8a97

textX_Y_Alt:
	dc.b	$6d	; 0x8a98
	dc.b	$2a	; 0x8a99
	dc.b	$00	; 0x8a9a
	dc.b	"X=   Y=", $00	; 0x8a9b
	dc.b	$4d	; 0x8aa3

nbOfAnimsPerObject:
	dc.b	$03, $04, $05, $05, $02, $01, $05, $06, $0a, $04, $03, $01, $02, $03, $01, $07, $02, $04, $36, $06, $04, $22, $0b, $09, $07, $17, $05, $01, $01, $01, $03, $03, $05, $01, $04, $07, $04, $08, $05, $01	; 0x8aa4

fightersTileDatas:
	dc.w	$0090	; length in words	; 0x8acc
	dc.l	ryuStageTilesetData2/2	; source	; 0x8ace
	dc.w	$8000	; dest	; 0x8ad2
	; 0x-1
	dc.w	$0220	; length in words	; 0x8ad4
	dc.l	eHondaStageTilesetData_2/2	; source	; 0x8ad6
	dc.w	$8000	; dest	; 0x8ada
	; 0x-1
	dc.w	$0700	; length in words	; 0x8adc
	dc.l	guileStageTilesetData2/2	; source	; 0x8ade
	dc.w	$8000	; dest	; 0x8ae2
	; 0x-1
	dc.w	$0850	; length in words	; 0x8ae4
	dc.l	ken_stage_tileset_2_data/2	; source	; 0x8ae6
	dc.w	$7760	; dest	; 0x8aea
	; 0x-1
	dc.w	$0800	; length in words	; 0x8aec
	dc.l	chun_li_stage_tileset_2_data/2	; source	; 0x8aee
	dc.w	$7400	; dest	; 0x8af2
	; 0x-1
	dc.w	$0350	; length in words	; 0x8af4
	dc.l	zangief_stage_tileset_2_data/2	; source	; 0x8af6
	dc.w	$8000	; dest	; 0x8afa
	; 0x-1
	dc.w	$1000	; length in words	; 0x8afc
	dc.l	dictator_stage_tileset_2_data/2	; source	; 0x8afe
	dc.w	$f400	; dest	; 0x8b02
	; 0x-1
	dc.w	$0860	; length in words	; 0x8b04
	dc.l	boxer_stage_tileset_2_data/2	; source	; 0x8b06
	dc.w	$7400	; dest	; 0x8b0a
	; 0x-1
	dc.w	$0900	; length in words	; 0x8b0c
	dc.l	bonus_stage_1_tileset_2a_data/2	; source	; 0x8b0e
	dc.w	$8000	; dest	; 0x8b12
	; 0x-1
	dc.w	$03A0	; length in words	; 0x8b14
	dc.l	bonus_stage_2_tileset_2_data/2	; source	; 0x8b16
	dc.w	$8000	; dest	; 0x8b1a
	; 0x-1
	dc.w	$0900	; length in words	; 0x8b1c
	dc.l	bonus_stage_3_tileset_2_data/2	; source	; 0x8b1e
	dc.w	$8000	; dest	; 0x8b22
	; 0x-1
	dc.w	$0100	; length in words	; 0x8b24
	dc.l	flatPtrnsData/2	; source	; 0x8b26
	dc.w	$8000	; dest	; 0x8b2a
	; 0x-1
	dc.w	$0100	; length in words	; 0x8b2c
	dc.l	flatPtrnsData/2	; source	; 0x8b2e
	dc.w	$8000	; dest	; 0x8b32
	; 0x-1
	dc.w	$0100	; length in words	; 0x8b34
	dc.l	flatPtrnsData/2	; source	; 0x8b36
	dc.w	$8000	; dest	; 0x8b3a
	; 0x-1
	dc.w	$0100	; length in words	; 0x8b3c
	dc.l	flatPtrnsData/2	; source	; 0x8b3e
	dc.w	$8000	; dest	; 0x8b42
	; 0x-1
	dc.w	$0100	; length in words	; 0x8b44
	dc.l	flatPtrnsData/2	; source	; 0x8b46
	dc.w	$8000	; dest	; 0x8b4a
	; 0x-1
	dc.w	$0100	; length in words	; 0x8b4c
	dc.l	flatPtrnsData/2	; source	; 0x8b4e
	dc.w	$8000	; dest	; 0x8b52
	; 0x-1
	dc.w	$0100	; length in words	; 0x8b54
	dc.l	flatPtrnsData/2	; source	; 0x8b56
	dc.w	$8000	; dest	; 0x8b5a
	; 0x-1
	dc.w	$0DC0	; length in words	; 0x8b5c
	dc.l	PATTERNS_3d1300/2	; source	; 0x8b5e
	dc.w	$8000	; dest	; 0x8b62
	; 0x-1
	dc.w	$02F0	; length in words	; 0x8b64
	dc.l	PATTERNS_3a2380/2	; source	; 0x8b66
	dc.w	$9200	; dest	; 0x8b6a
	; 0x-1
	dc.w	$0140	; length in words	; 0x8b6c
	dc.l	PATTERNS_3a2a20/2	; source	; 0x8b6e
	dc.w	$9200	; dest	; 0x8b72
	; 0x-1
	dc.w	$0100	; length in words	; 0x8b74
	dc.l	flatPtrnsData/2	; source	; 0x8b76
	dc.w	$8000	; dest	; 0x8b7a
	; 0x-1
	dc.w	$0100	; length in words	; 0x8b7c
	dc.l	flatPtrnsData/2	; source	; 0x8b7e
	dc.w	$8000	; dest	; 0x8b82
	; 0x-1
	dc.w	$0100	; length in words	; 0x8b84
	dc.l	flatPtrnsData/2	; source	; 0x8b86
	dc.w	$8000	; dest	; 0x8b8a
	; 0x-1
	dc.w	$0100	; length in words	; 0x8b8c
	dc.l	flatPtrnsData/2	; source	; 0x8b8e
	dc.w	$8000	; dest	; 0x8b92
	; 0x-1
	dc.w	$0200	; length in words	; 0x8b94
	dc.l	PATTERNS_3c87a0/2	; source	; 0x8b96
	dc.w	$ac00	; dest	; 0x8b9a
	; 0x-1
	dc.w	$0100	; length in words	; 0x8b9c
	dc.l	flatPtrnsData/2	; source	; 0x8b9e
	dc.w	$8000	; dest	; 0x8ba2
	; 0x-1
	dc.w	$0200	; length in words	; 0x8ba4
	dc.l	PATTERNS_3a1a80/2	; source	; 0x8ba6
	dc.w	$9800	; dest	; 0x8baa
	; 0x-1
	dc.w	$0100	; length in words	; 0x8bac
	dc.l	flatPtrnsData/2	; source	; 0x8bae
	dc.w	$8000	; dest	; 0x8bb2
	; 0x-1
	dc.w	$0100	; length in words	; 0x8bb4
	dc.l	flatPtrnsData/2	; source	; 0x8bb6
	dc.w	$8000	; dest	; 0x8bba
	; 0x-1
	dc.w	$0100	; length in words	; 0x8bbc
	dc.l	flatPtrnsData/2	; source	; 0x8bbe
	dc.w	$8000	; dest	; 0x8bc2
	; 0x-1
	dc.w	$0100	; length in words	; 0x8bc4
	dc.l	flatPtrnsData/2	; source	; 0x8bc6
	dc.w	$8000	; dest	; 0x8bca
	; 0x-1
	dc.w	$0100	; length in words	; 0x8bcc
	dc.l	flatPtrnsData/2	; source	; 0x8bce
	dc.w	$8000	; dest	; 0x8bd2
	; 0x-1
	dc.w	$0100	; length in words	; 0x8bd4
	dc.l	flatPtrnsData/2	; source	; 0x8bd6
	dc.w	$8000	; dest	; 0x8bda
	; 0x-1
	dc.w	$0100	; length in words	; 0x8bdc
	dc.l	flatPtrnsData/2	; source	; 0x8bde
	dc.w	$8000	; dest	; 0x8be2
	; 0x-1
	dc.w	$0100	; length in words	; 0x8be4
	dc.l	flatPtrnsData/2	; source	; 0x8be6
	dc.w	$8000	; dest	; 0x8bea
	; 0x-1
	dc.w	$0100	; length in words	; 0x8bec
	dc.l	flatPtrnsData/2	; source	; 0x8bee
	dc.w	$8000	; dest	; 0x8bf2
	; 0x-1
	dc.w	$0100	; length in words	; 0x8bf4
	dc.l	flatPtrnsData/2	; source	; 0x8bf6
	dc.w	$8000	; dest	; 0x8bfa
	; 0x-1
	dc.w	$0100	; length in words	; 0x8bfc
	dc.l	flatPtrnsData/2	; source	; 0x8bfe
	dc.w	$8000	; dest	; 0x8c02
	; 0x-1
	dc.w	$0200	; length in words	; 0x8c04
	dc.l	PATTERNS_3c87a0/2	; source	; 0x8c06
	dc.w	$ac00	; dest	; 0x8c0a
	; 0x-1

CMD_ScrollTest:
	clr.w	(stageId).w	; 0x8c0c
	clr.w	(scrollTestState).w	; 0x8c10
	clr.w	(scrollTestSubState).w	; 0x8c14
@loop:
	move.w	(scrollTestState).w, d0	; 0x8c18
	move.w	(scrollTestFunctions, pc, d0.w), d0	; 0x8c1c
	jsr	(scrollTestFunctions, pc, d0.w)	; 0x8c20
	move.b	#1, d0	; 0x8c24
	trap	#3	; 0x8c28
	bra.b	@loop	; 0x8c2a

scrollTestFunctions:
	dc.w	scrollTest00-scrollTestFunctions	; 0x8c2c
	dc.w	scrollTest02-scrollTestFunctions	; 0x8c2e

scrollTest00:
	tst.w	(scrollTestSubState).w	; 0x8c30
	bne.b	@scrollTest00_02	; 0x8c34
	addq.w	#2, (scrollTestSubState).w	; 0x8c36
	jsr	(initDisplay).w	; 0x8c3a
	jsr	(clearSatCache).w	; 0x8c3e
	lea	($8d00, pc), a0	; 0x8c42
	jsr	(writeText).w	; 0x8c46
	bsr.b	displayStageName	; 0x8c4a
	ori.b	#$40, (VdpRegistersCache).w	; 0x8c4c
	move.w	(VdpRegistersCache).w, (4, a5)	; 0x8c52
	move.w	#$0440, (rawPalettes).w	; 0x8c58
	jmp	(fadeInStart).w	; 0x8c5e
@scrollTest00_02:
	btst	#6, (joy1State).w	; 0x8c62
	beq.b	@not_button_a	; 0x8c68
	addq.w	#2, (scrollTestState).w	; 0x8c6a
	clr.w	(scrollTestSubState).w	; 0x8c6e
	jmp	(fadeOutStartAndProcess).w	; 0x8c72
@not_button_a:
	btst	#3, (joy1State).w	; 0x8c76
	beq.b	@not_right	; 0x8c7c
	addq.w	#1, (stageId).w	; 0x8c7e
	cmpi.w	#$0013, (stageId).w	; 0x8c82
	bne.b	displayStageName	; 0x8c88
	clr.w	(stageId).w	; 0x8c8a
	bra.b	displayStageName	; 0x8c8e
@not_right:
	btst	#2, (joy1State).w	; 0x8c90
	beq.b	@not_left	; 0x8c96
	subq.w	#1, (stageId).w	; 0x8c98
	bpl.b	displayStageName	; 0x8c9c
	move.w	#$0012, (stageId).w	; 0x8c9e
	bra.b	displayStageName	; 0x8ca4
@not_left:
	rts		; 0x8ca6

displayStageName:
	move.w	(stageId).w, d0	; 0x8ca8
	add.w	d0, d0	; 0x8cac
	move.w	(offsetsStageNames, pc, d0.w), d0	; 0x8cae
	lea	(offsetsStageNames, pc, d0.w), a0	; 0x8cb2
	move.l	#$659e0003, (4, a5)	; 0x8cb6
	moveq	#0, d1	; 0x8cbe
@loop:
	move.b	(a0)+, d1	; 0x8cc0
	beq.b	@exit	; 0x8cc2
	move.w	d1, (a5)	; 0x8cc4
	bra.b	@loop	; 0x8cc6
@exit:
	rts		; 0x8cc8

offsetsStageNames:
	dc.w	str_0_Ryu-offsetsStageNames	; 0x8cca
	dc.w	str_1_E_Honda-offsetsStageNames	; 0x8ccc
	dc.w	str_2_Blanka-offsetsStageNames	; 0x8cce
	dc.w	str_3_Guile-offsetsStageNames	; 0x8cd0
	dc.w	str_4_Ken-offsetsStageNames	; 0x8cd2
	dc.w	str_5_ChunLi-offsetsStageNames	; 0x8cd4
	dc.w	str_6_Zangief-offsetsStageNames	; 0x8cd6
	dc.w	str_7_Dhalsim-offsetsStageNames	; 0x8cd8
	dc.w	str_8_Vega-offsetsStageNames	; 0x8cda
	dc.w	str_9_Sagat-offsetsStageNames	; 0x8cdc
	dc.w	str_a_M_Bison-offsetsStageNames	; 0x8cde
	dc.w	str_b_Balrog-offsetsStageNames	; 0x8ce0
	dc.w	str_c_Cammy-offsetsStageNames	; 0x8ce2
	dc.w	str_d_T_Hawk-offsetsStageNames	; 0x8ce4
	dc.w	str_e_FeiLong-offsetsStageNames	; 0x8ce6
	dc.w	str_f_DeeJay-offsetsStageNames	; 0x8ce8
	dc.w	str_10_Bonus_0-offsetsStageNames	; 0x8cea
	dc.w	str_11_Bonus_1-offsetsStageNames	; 0x8cec
	dc.w	str_12_Bonus_2-offsetsStageNames	; 0x8cee
	dc.w	str_13_Ken-offsetsStageNames	; 0x8cf0
	dc.w	str_14_ChunLi-offsetsStageNames	; 0x8cf2
	dc.w	str_15_Zangief-offsetsStageNames	; 0x8cf4
	dc.w	str_16_Dhalsim-offsetsStageNames	; 0x8cf6
	dc.w	str_17_Vega-offsetsStageNames	; 0x8cf8
	dc.w	str_18_Sagat-offsetsStageNames	; 0x8cfa
	dc.w	str_19_M_Bison-offsetsStageNames	; 0x8cfc
	dc.w	str_1a_Balrog-offsetsStageNames	; 0x8cfe

txtScrollTestStage:
	dc.b	$63	; 0x8d00
	dc.b	$92	; 0x8d01
	dc.b	$00	; 0x8d02
	dc.b	" SCROLL TEST", $ff, $ff, $ff, $ff, "STAGE ", $00	; 0x8d03

str_0_Ryu:
	dc.b	"0  RYU    ", $00	; 0x8d1a

str_1_E_Honda:
	dc.b	"1  E.HONDA", $00	; 0x8d25

str_2_Blanka:
	dc.b	"2  BLANKA ", $00	; 0x8d30

str_3_Guile:
	dc.b	"3  GUILE  ", $00	; 0x8d3b

str_4_Ken:
	dc.b	"4  KEN    ", $00	; 0x8d46

str_5_ChunLi:
	dc.b	"5  CHUN LI", $00	; 0x8d51

str_6_Zangief:
	dc.b	"6  ZANGIEF", $00	; 0x8d5c

str_7_Dhalsim:
	dc.b	"7  DHALSIM", $00	; 0x8d67

str_8_Vega:
	dc.b	"8  VEGA   ", $00	; 0x8d72

str_9_Sagat:
	dc.b	"9  SAGAT  ", $00	; 0x8d7d

str_a_M_Bison:
	dc.b	"A  M.BISON", $00	; 0x8d88

str_b_Balrog:
	dc.b	"B  BALROG ", $00	; 0x8d93

str_c_Cammy:
	dc.b	"C  CAMMY  ", $00	; 0x8d9e

str_d_T_Hawk:
	dc.b	"D  T.HAWK ", $00	; 0x8da9

str_e_FeiLong:
	dc.b	"E  FEILONG", $00	; 0x8db4

str_f_DeeJay:
	dc.b	"F  DEEJAY ", $00	; 0x8dbf

str_10_Bonus_0:
	dc.b	"10 BONUS 0", $00	; 0x8dca

str_11_Bonus_1:
	dc.b	"11 BONUS 1", $00	; 0x8dd5

str_12_Bonus_2:
	dc.b	"12 BONUS 2", $00	; 0x8de0

str_13_Ken:
	dc.b	"13 KEN    ", $00	; 0x8deb

str_14_ChunLi:
	dc.b	"14 CHUN LI", $00	; 0x8df6

str_15_Zangief:
	dc.b	"15 ZANGIEF", $00	; 0x8e01

str_16_Dhalsim:
	dc.b	"16 DHALSIM", $00	; 0x8e0c

str_17_Vega:
	dc.b	"17 VEGA   ", $00	; 0x8e17

str_18_Sagat:
	dc.b	"18 SAGAT  ", $00	; 0x8e22

str_19_M_Bison:
	dc.b	"19 M.BISON", $00	; 0x8e2d

str_1a_Balrog:
	dc.b	$31, $41, $20, $42, $41, $4c, $52, $4f, $47, $20, $00, $20	; 0x8e38

scrollTest02:
	tst.w	(scrollTestSubState).w	; 0x8e44
	bne.w	scrollTest02_02	; 0x8e48
	addq.w	#2, (scrollTestSubState).w	; 0x8e4c
	clr.b	(LBL_ffff9826).w	; 0x8e50
	jsr	(clearPlayersAnd97caData).w	; 0x8e54
	jsr	(initDisplay).w	; 0x8e58
	move.l	#$50000080, d1	; DMA VRAM write    :
			; 	src=0xFF0000
			; 	dest=1000
			; 	length=16	; 0x8e5c
	move.l	#$94bf93ff, d0	; 0x8e62
	move.b	#$37, d2	; 0x8e68
	jsr	(doDmaAndWaitCompletionAlt).w	; 0x8e6c
	jsr	FUN_00014796	; 0x8e70
	jsr	(clearProjectileData).w	; 0x8e76
	move.w	(stageId).w, d0	; 0x8e7a
	cmpi.w	#$000e, d0	; 0x8e7e
	bhi.b	dont_init_objects	; 0x8e82
	jsr	initStageObjects	; 0x8e84

dont_init_objects:
	jsr	(clearSatCache).w	; 0x8e8a
	move.w	#$0080, (cameraX).w	; 0x8e8e
	move.w	#0, (cameraY).w	; 0x8e94
	ori.b	#$40, (VdpRegistersCache).w	; 0x8e9a
	move.w	(VdpRegistersCache).w, (4, a5)	; 0x8ea0
	jmp	(fadeInStart).w	; 0x8ea6

scrollTest02_02:
	move.w	(joy1State).w, d0	; 0x8eaa
	btst	#6, d0	; 0x8eae
	beq.b	@no_button_a	; 0x8eb2
	clr.w	(scrollTestState).w	; 0x8eb4
	clr.w	(scrollTestSubState).w	; 0x8eb8
	jmp	(fadeOutStartAndProcess).w	; 0x8ebc
@no_button_a:
	btst	#5, d0	; 0x8ec0
	beq.b	@no_button_c	; 0x8ec4
	jmp	($9128, pc)	; 0x8ec6
@no_button_c:
	move.w	(joy1State).w, d0	; 0x8eca
	btst	#3, d0	; 0x8ece
	beq.b	@not_right	; 0x8ed2
	cmpi.w	#$00e0, (cameraX).w	; 0x8ed4
	beq.b	@not_right	; 0x8eda
	addi.w	#1, (cameraX).w	; 0x8edc
@not_right:
	btst	#2, d0	; 0x8ee2
	beq.b	@not_left	; 0x8ee6
	cmpi.w	#$0020, (cameraX).w	; 0x8ee8
	beq.b	@not_left	; 0x8eee
	subi.w	#1, (cameraX).w	; 0x8ef0
@not_left:
	btst	#0, d0	; 0x8ef6
	beq.b	@not_up	; 0x8efa
	cmpi.w	#$0010, (cameraY).w	; 0x8efc
	beq.b	@not_up	; 0x8f02
	addi.w	#1, (cameraY).w	; 0x8f04
@not_up:
	btst	#1, d0	; 0x8f0a
	beq.b	@not_down	; 0x8f0e
	cmpi.w	#0, (cameraY).w	; 0x8f10
	beq.b	@not_down	; 0x8f16
	subi.w	#1, (cameraY).w	; 0x8f18
@not_down:
	btst	#4, d0	; 0x8f1e
	beq.b	@no_button_b	; 0x8f22
	move.w	#$0080, (cameraX).w	; 0x8f24
	move.w	#0, (cameraY).w	; 0x8f2a
@no_button_b:
	cmpi.w	#$0013, (stageId).w	; 0x8f30
	bcc.b	@lt_13	; 0x8f36
	jsr	(updateStage).w	; 0x8f38
@lt_13:
	jsr	(updateBackgroundAndObjects).w	; 0x8f3c
	clr.b	(fighter1Data).w	; 0x8f40
	clr.b	(player_1_).w	; 0x8f44
	st	(areWeFighting).w	; 0x8f48
	jsr	(updateAllSprites).w	; 0x8f4c
	cmpi.w	#$0013, (stageId).w	; 0x8f50
	bcc.b	@return	; 0x8f56
	jmp	(updateStageScroll).w	; 0x8f58
@return:
	rts		; 0x8f5c

CMD_SoundTest:
	clr.w	(sound_test_row).w	; 0x8f5e
	clr.b	(bgmSelected).w	; 0x8f62
	clr.b	(pcmCh1Selected).w	; 0x8f66
	clr.b	(pcmCh2Selected).w	; 0x8f6a
	jsr	(initDisplay).w	; 0x8f6e
	lea	($90ec, pc), a0	; 0x8f72
	jsr	(writeText).w	; 0x8f76
	bsr.w	updateSoundTestCursor	; 0x8f7a
	ori.b	#$40, (VdpRegistersCache).w	; 0x8f7e
	move.w	(VdpRegistersCache).w, (4, a5)	; 0x8f84
	jsr	(fadeInStart).w	; 0x8f8a
@sound_test:
	move.b	#1, d0	; 0x8f8e
	trap	#3	; 0x8f92
	btst	#6, (joy1State).w	; 0x8f94
	beq.b	@not_a	; 0x8f9a
	move.b	(bgmSelected).w, d0	; 0x8f9c
	jsr	(selectBgm).w	; 0x8fa0
@not_a:
	btst	#4, (joy1State).w	; 0x8fa4
	beq.b	@not_b	; 0x8faa
	move.w	#0, d0	; 0x8fac
	move.b	(pcmCh1Selected).w, d0	; 0x8fb0
	jsr	(putWordInSfxQueue).w	; 0x8fb4
@not_b:
	btst	#5, (joy1State).w	; 0x8fb8
	beq.b	@not_c	; 0x8fbe
	move.w	#$0100, d0	; 0x8fc0
	move.b	(pcmCh2Selected).w, d0	; 0x8fc4
	jsr	(putWordInSfxQueue).w	; 0x8fc8
@not_c:
	btst	#$000a, (joy1State).w	; 0x8fcc
	beq.b	@not_x	; 0x8fd2
	jsr	(selectBgmF4).w	; 0x8fd4
	jsr	(bgmStop).w	; 0x8fd8
	move.b	#4, d0	; 0x8fdc
	trap	#3	; 0x8fe0
	moveq	#-$005c, d0	; 0x8fe2
	jsr	(putWordInSfxQueue).w	; 0x8fe4
	move.b	#4, d0	; 0x8fe8
	trap	#3	; 0x8fec
@loop_until_x:
	move.b	#1, d0	; 0x8fee
	trap	#3	; 0x8ff2
	btst	#$000a, (joy1State).w	; 0x8ff4
	beq.b	@loop_until_x	; 0x8ffa
	moveq	#-$006b, d0	; 0x8ffc
	jsr	(putWordInSfxQueue).w	; 0x8ffe
	move.b	#$14, d0	; 0x9002
	trap	#3	; 0x9006
	jsr	(selectBgmF5).w	; 0x9008
@not_x:
	btst	#0, (joy1State).w	; 0x900c
	beq.b	@not_up	; 0x9012
	subq.w	#2, (sound_test_row).w	; 0x9014
	bpl.b	@not_up	; 0x9018
	move.w	#4, (sound_test_row).w	; 0x901a
@not_up:
	btst	#1, (joy1State).w	; 0x9020
	beq.b	@not_down	; 0x9026
	addq.w	#2, (sound_test_row).w	; 0x9028
	cmpi.w	#6, (sound_test_row).w	; 0x902c
	bne.b	@not_down	; 0x9032
	clr.w	(sound_test_row).w	; 0x9034
@not_down:
	btst	#3, (joy1State).w	; 0x9038
	beq.b	@not_right	; 0x903e
	move.b	#1, d0	; 0x9040
	btst	#8, (joy1State).w	; 0x9044
	beq.b	@not_right_z	; 0x904a
	move.b	#$10, d0	; 0x904c
@not_right_z:
	bsr.b	updateSoundtestSelection	; 0x9050
@not_right:
	btst	#2, (joy1State).w	; 0x9052
	beq.b	@not_left	; 0x9058
	move.b	#$ff, d0	; 0x905a
	btst	#8, (joy1State).w	; 0x905e
	beq.b	@not_left_z	; 0x9064
	move.b	#$f0, d0	; 0x9066
@not_left_z:
	bsr.b	updateSoundtestSelection	; 0x906a
@not_left:
	bsr.b	updateSoundTestCursor	; 0x906c
	bra.w	@sound_test	; 0x906e

updateSoundTestCursor:
	move.w	(ptrCurrentSpriteInSatBuffer).w, a0	; 0x9072
	move.w	(sound_test_row).w, d0	; 0x9076
	move.w	(cursor_pos_y, pc, d0.w), d0	; 0x907a
	move.w	d0, (a0)+	; 0x907e
	move.b	#0, (a0)+	; 0x9080
	addq.b	#1, (currentSpriteLink).w	; 0x9084
	move.b	(currentSpriteLink).w, (a0)+	; 0x9088
	move.w	#$0024, (a0)+	; 0x908c
	move.w	#$00c0, (a0)+	; 0x9090
	move.w	a0, (ptrCurrentSpriteInSatBuffer).w	; 0x9094
	rts		; 0x9098

cursor_pos_y:
	dc.w	$00d8	; 0x909a
	dc.w	$00e8	; 0x909c
	dc.w	$00f8	; 0x909e

updateSoundtestSelection:
	move.w	(sound_test_row).w, d1	; 0x90a0
	move.w	(soundTestItemsPtrs, pc, d1.w), a0	; 0x90a4
	add.b	d0, (a0)	; 0x90a8
	move.w	(soundTestItemsPosY, pc, d1.w), (4, a5)	; 0x90aa
	move.w	#3, (4, a5)	; 0x90b0
	move.b	(a0), d1	; 0x90b6
	lsr.b	#4, d1	; 0x90b8
	bsr.w	displayHexDigitAlt	; 0x90ba
	move.b	(a0), d1	; 0x90be
	andi.b	#$0f, d1	; 0x90c0

displayHexDigitAlt:
	ext.w	d1	; 0x90c4
	moveq	#0, d2	; 0x90c6
	move.b	(strHexDigitsAlt1, pc, d1.w), d2	; 0x90c8
	move.w	d2, (a5)	; 0x90cc
	rts		; 0x90ce

soundTestItemsPtrs:
	dc.w	$bb96, $bb97, $bb98	; 0x90d0

soundTestItemsPosY:
	dc.w	$65a8, $66a8, $67a8	; 0x90d6

strHexDigitsAlt1:
	dc.b	"0123456789ABCDEFc", $94, $00	; 0x90dc
	dc.b	" SOUND TEST", $ff, $ff, $ff, $ff, "BGM + SE  00", $ff, $ff, "PCM CH.1  00", $ff, $ff, "PCM CH.2  00", $00	; 0x90ef
	dc.b	$3c	; 0x9127

updateStagePaletteViewer:
	clr.l	(stagePaletteViewerState).w	; 0x9128
	clr.l	(stageScrollColorId).w	; 0x912c
	clr.w	(dontShowPaletteViewer).w	; 0x9130
	jsr	(clearSatCache).w	; 0x9134
@loop:
	move.w	(stagePaletteViewerState).w, d0	; 0x9138
	cmpi.w	#4, d0	; 0x913c
	beq.b	@return	; 0x9140
	move.w	(stagePaletteViewerStates, pc, d0.w), d1	; 0x9142
	jsr	(stagePaletteViewerStates, pc, d1.w)	; 0x9146
	move.b	#1, d0	; 0x914a
	trap	#3	; 0x914e
	bra.b	@loop	; 0x9150
@return:
	rts		; 0x9152

stagePaletteViewerStates:
	dc.w	updateStagePaletteViewer00-stagePaletteViewerStates	; 0x9154
	dc.w	updateStagePaletteViewer02-stagePaletteViewerStates	; 0x9156

updateStagePaletteViewer00:
	bsr.w	FUN_00009280	; 0x9158
	cmpi.b	#1, (dontShowPaletteViewer).w	; 0x915c
	beq.b	@dont_show_palette_viewer	; 0x9162
	cmpi.w	#$0080, (paletteEditorPosX).w	; 0x9164
	bcc.b	@too_on_the_left	; 0x916a
	bra.b	@stop_on_left	; 0x916c
@too_on_the_left:
	tst.b	(dontShowPaletteViewer).w	; 0x916e
	beq.b	@move_palette_viewer	; 0x9172
@stop_on_left:
	addq.w	#4, (paletteEditorPosX).w	; 0x9174
	bra.b	@dont_move	; 0x9178
@move_palette_viewer:
	subq.w	#4, (paletteEditorPosX).w	; 0x917a
@dont_move:
	cmpi.w	#$0080, (paletteEditorPosX).w	; 0x917e
	beq.b	@init_update_palette_viewer_02	; 0x9184
	cmpi.w	#$0100, (paletteEditorPosX).w	; 0x9186
	beq.b	@init_update_palette_viewer_02	; 0x918c
	rts		; 0x918e
@init_update_palette_viewer_02:
	addq.w	#2, (stagePaletteViewerState).w	; 0x9190
	not.b	(dontShowPaletteViewer).w	; 0x9194
	rts		; 0x9198
@dont_show_palette_viewer:
	subq.w	#4, (paletteEditorPosX).w	; 0x919a
	bne.b	@return	; 0x919e
	move.w	#4, (stagePaletteViewerState).w	; 0x91a0
@return:
	rts		; 0x91a6

updateStagePaletteViewer02:
	btst	#8, (joy1State).w	; 0x91a8
	bne.b	@button_z	; 0x91ae
	btst	#5, (joy1State).w	; 0x91b0
	beq.b	@not_c	; 0x91b6
	move.b	#1, (dontShowPaletteViewer).w	; 0x91b8
@button_z:
	clr.w	(stagePaletteViewerState).w	; 0x91be
@not_c:
	btst	#$000a, (joy1State).w	; 0x91c2
	beq.b	@not_x	; 0x91c8
	addq.w	#1, (stageScrollPaletteId).w	; 0x91ca
	andi.w	#3, (stageScrollPaletteId).w	; 0x91ce
@not_x:
	tst.b	(LBL_ffffbba3).w	; 0x91d4
	beq.b	@not_ffbba3	; 0x91d8
	jmp	($9274, pc)	; 0x91da
@not_ffbba3:
	btst	#0, (joy1State).w	; 0x91de
	beq.b	@not_up	; 0x91e4
	subq.b	#2, (stageScrollColorId).w	; 0x91e6
	andi.b	#$1f, (stageScrollColorId).w	; 0x91ea
@not_up:
	btst	#1, (joy1State).w	; 0x91f0
	beq.b	@not_down	; 0x91f6
	addq.b	#2, (stageScrollColorId).w	; 0x91f8
	andi.b	#$1f, (stageScrollColorId).w	; 0x91fc
@not_down:
	btst	#3, (joy1State).w	; 0x9202
	beq.b	@not_right	; 0x9208
	addq.b	#2, (stageScrollColorComponentId).w	; 0x920a
	cmpi.b	#6, (stageScrollColorComponentId).w	; 0x920e
	bne.b	@not_right	; 0x9214
	clr.b	(stageScrollColorComponentId).w	; 0x9216
@not_right:
	btst	#2, (joy1State).w	; 0x921a
	beq.b	@not_left	; 0x9220
	subq.b	#2, (stageScrollColorComponentId).w	; 0x9222
	bpl.b	@not_left	; 0x9226
	move.b	#4, (stageScrollColorComponentId).w	; 0x9228
@not_left:
	moveq	#0, d2	; 0x922e
	btst	#4, (joy1State).w	; 0x9230
	bne.b	@button_b	; 0x9236
	btst	#6, (joy1State).w	; 0x9238
	beq.b	not_a_100	; 0x923e
	move.b	#6, d2	; 0x9240
@button_b:
	lea	(rawPalettes).w, a0	; 0x9244
	moveq	#0, d0	; 0x9248
	move.w	(stageScrollPaletteId).w, d0	; 0x924a
	lsl.w	#5, d0	; 0x924e
	add.b	(stageScrollColorId).w, d0	; 0x9250
	adda.l	d0, a0	; 0x9254
	move.w	(a0), d0	; 0x9256
	move.w	d0, d1	; 0x9258
	add.b	(stageScrollColorComponentId).w, d2	; 0x925a
	move.w	(changeComponentsFunctions, pc, d2.w), d3	; 0x925e
	jsr	(changeComponentsFunctions, pc, d3.w)	; 0x9262
	bra.b	not_a_100	; 0x9266

changeComponentsFunctions:
	dc.w	increment_blue_component-changeComponentsFunctions	; 0x9268
	dc.w	increment_green_component-changeComponentsFunctions	; 0x926a
	dc.w	increment_red_component-changeComponentsFunctions	; 0x926c
	dc.w	decrement_blue_component-changeComponentsFunctions	; 0x926e
	dc.w	decrement_green_component-changeComponentsFunctions	; 0x9270
	dc.w	decrement_red_component-changeComponentsFunctions	; 0x9272

not_a_100:
	btst	#9, (joy1State).w	; 0x9274
	beq.b	FUN_00009280	; 0x927a
	not.b	(LBL_ffffbba3).w	; 0x927c

FUN_00009280:
	lea	(SAT_cache).w, a0	; 0x9280
	move.w	#0, a1	; 0x9284
	move.w	#0, a2	; 0x9288
	move.b	#1, (currentSpriteLink).w	; 0x928c
	move.w	#8, d1	; 0x9292
	move.w	#$8000, d2	; 0x9296
	bsr.w	displayPaletteEditor	; 0x929a
	move.w	#$0024, a1	; 0x929e
	move.w	#$0012, a2	; 0x92a2
	move.w	#3, d1	; 0x92a6
	move.w	(stageScrollPaletteId).w, d2	; 0x92aa
	ror.w	#3, d2	; 0x92ae
	ori.w	#$8000, d2	; 0x92b0
	bsr.w	displayPaletteEditor	; 0x92b4
	move.w	#$00c0, d0	; 0x92b8
	move.w	#$000f, d2	; 0x92bc
	lea	(rawPalettes).w, a1	; 0x92c0
	moveq	#0, d6	; 0x92c4
	move.w	(stageScrollPaletteId).w, d6	; 0x92c6
	lsl.w	#5, d6	; 0x92ca
	adda.l	d6, a1	; 0x92cc
@next1:
	tst.b	(LBL_ffffbba3).w	; 0x92ce
	beq.b	@ffbba3_zero	; 0x92d2
	bsr.w	FUN_00009342	; 0x92d4
	bra.b	@skip1	; 0x92d8
@ffbba3_zero:
	bsr.w	FUN_00009362	; 0x92da
@skip1:
	addq.w	#8, d0	; 0x92de
	dbf	d2, @next1	; 0x92e0
	move.w	#$00a0, (a0)+	; 0x92e4
	move.w	#$003e, (a0)+	; 0x92e8
	move.w	(stageScrollPaletteId).w, d0	; 0x92ec
	ori.w	#$0030, d0	; 0x92f0
	move.w	d0, (a0)+	; 0x92f4
	move.w	(paletteEditorPosX).w, d0	; 0x92f6
	addi.w	#$0028, d0	; 0x92fa
	move.w	d0, (a0)+	; 0x92fe
	tst.b	(LBL_ffffbba3).w	; 0x9300
	beq.b	@ffbba3_zero_2	; 0x9304
	lea	(LBL_ffffa194).w, a1	; 0x9306
	move.w	#0, (a1)	; 0x930a
	bra.b	@proceed_return	; 0x930e
@ffbba3_zero_2:
	moveq	#0, d0	; 0x9310
	move.b	(stageScrollColorId).w, d0	; 0x9312
	asl.b	#2, d0	; 0x9316
	addi.w	#$00c0, d0	; 0x9318
	move.w	d0, (a0)+	; 0x931c
	move.w	#0, (a0)+	; 0x931e
	move.w	#$803e, (a0)+	; 0x9322
	moveq	#0, d0	; 0x9326
	move.b	(stageScrollColorComponentId).w, d0	; 0x9328
	asl.b	#3, d0	; 0x932c
	addi.w	#$0028, d0	; 0x932e
	add.w	(paletteEditorPosX).w, d0	; 0x9332
	move.w	d0, (a0)+	; 0x9336
@proceed_return:
	move.w	a0, (ptrCurrentSpriteInSatBuffer).w	; 0x9338
	clr.b	(currentSpriteLink).w	; 0x933c
	rts		; 0x9340

FUN_00009342:
	move.w	(paletteEditorPosX).w, d1	; 0x9342
	addi.w	#$0038, d1	; 0x9346
	moveq	#8, d6	; 0x934a
	move.b	(a1)+, d5	; 0x934c
	bsr.w	FUN_00009388	; 0x934e
	move.b	(a1), d5	; 0x9352
	lsr.b	#4, d5	; 0x9354
	bsr.w	FUN_00009388	; 0x9356
	move.b	(a1)+, d5	; 0x935a
	andi.b	#$0e, d5	; 0x935c
	bra.b	FUN_00009388	; 0x9360

FUN_00009362:
	move.w	(paletteEditorPosX).w, d1	; 0x9362
	addi.w	#$0030, d1	; 0x9366
	moveq	#$0010, d6	; 0x936a
	move.b	(a1)+, d5	; 0x936c
	lsr.b	#1, d5	; 0x936e
	bsr.w	FUN_00009388	; 0x9370
	move.b	(a1), d5	; 0x9374
	lsr.b	#5, d5	; 0x9376
	bsr.w	FUN_00009388	; 0x9378
	move.b	(a1)+, d5	; 0x937c
	andi.b	#$0e, d5	; 0x937e
	lsr.b	#1, d5	; 0x9382
	jmp	($9388, pc)	; 0x9384

FUN_00009388:
	move.w	d0, (a0)+	; 0x9388
	move.b	(currentSpriteLink).w, d4	; 0x938a
	ext.w	d4	; 0x938e
	move.w	d4, (a0)+	; 0x9390
	ext.w	d5	; 0x9392
	move.b	(strHexDigitsAlt2, pc, d5.w), d5	; 0x9394
	move.w	d5, (a0)+	; 0x9398
	move.w	d1, (a0)+	; 0x939a
	addq.b	#1, (currentSpriteLink).w	; 0x939c
	add.w	d6, d1	; 0x93a0
	rts		; 0x93a2

strHexDigitsAlt2:
	dc.b	"0123456789ABCDEF", $06, "@", $02, $00	; 0x93a4
	andi.w	#$0eee, d0	; 0x93b8
	bra.b	proceed_338	; 0x93bc

increment_green_component:
	andi.w	#$0e0e, d0	; 0x93be
	andi.w	#$00e0, d1	; 0x93c2
	addi.w	#$0020, d1	; 0x93c6
	andi.w	#$00e0, d1	; 0x93ca
	or.w	d1, d0	; 0x93ce
	bra.b	proceed_338	; 0x93d0

increment_red_component:
	andi.w	#$0ee0, d0	; 0x93d2
	andi.w	#$000e, d1	; 0x93d6
	addi.w	#2, d1	; 0x93da
	andi.w	#$000e, d1	; 0x93de
	or.w	d1, d0	; 0x93e2
	bra.b	proceed_338	; 0x93e4

decrement_blue_component:
	subi.w	#$0200, d0	; 0x93e6
	andi.w	#$0eee, d0	; 0x93ea
	bra.b	proceed_338	; 0x93ee

decrement_green_component:
	andi.w	#$0e0e, d0	; 0x93f0
	andi.w	#$00e0, d1	; 0x93f4
	subi.w	#$0020, d1	; 0x93f8
	andi.w	#$00e0, d1	; 0x93fc
	or.w	d1, d0	; 0x9400
	bra.b	proceed_338	; 0x9402

decrement_red_component:
	andi.w	#$0ee0, d0	; 0x9404
	andi.w	#$000e, d1	; 0x9408
	subi.w	#2, d1	; 0x940c
	andi.w	#$000e, d1	; 0x9410
	or.w	d1, d0	; 0x9414

proceed_338:
	move.w	d0, (a0)	; 0x9416
	st	(flagProcessPalettes).w	; 0x9418
	rts		; 0x941c

displayPaletteEditor:
	move.w	(paletteEditorPatternsPosXY, pc, a1.w), (a0)+	; 0x941e
	addq.w	#2, a1	; 0x9422
	move.b	(paletteEditorPatternsId, pc, a2.w), d0	; 0x9424
	lsl.w	#4, d0	; 0x9428
	or.b	(currentSpriteLink).w, d0	; 0x942a
	move.w	d0, (a0)+	; 0x942e
	addq.b	#1, (currentSpriteLink).w	; 0x9430
	addq.w	#1, a2	; 0x9434
	move.b	(paletteEditorPatternsId, pc, a2.w), d2	; 0x9436
	move.w	d2, (a0)+	; 0x943a
	addq.w	#1, a2	; 0x943c
	move.w	(paletteEditorPatternsPosXY, pc, a1.w), d0	; 0x943e
	add.w	(paletteEditorPosX).w, d0	; 0x9442
	move.w	d0, (a0)+	; 0x9446
	addq.w	#2, a1	; 0x9448
	dbf	d1, displayPaletteEditor	; 0x944a
	move.w	a0, (ptrCurrentSpriteInSatBuffer).w	; 0x944e
	rts		; 0x9452

paletteEditorPatternsId:
	dc.b	$00, $50, $30, $30, $30, $34, $10, $38, $10, $41, $30, $43, $00, $42, $00, $47, $00, $52, $30, $00, $30, $04, $30, $08, $30, $0c	; 0x9454

paletteEditorPatternsPosXY:
	dc.w	$00a0, $0018, $00c0, $0018, $00e0, $0018, $0100, $0018, $0110, $0018, $0120, $0018, $00b0, $0030, $00b0, $0040, $00b0, $0050, $00c0, $0068, $00e0, $0068, $0100, $0068, $0120, $0068	; 0x946e

unknownDebugMenu:
	bsr.w	FUN_0000446e	; 0x94a2
	clr.w	(unknownDebugMenuState).w	; 0x94a6
	move.w	(LBL_ffff803c).w, d0	; 0x94aa
	move.w	d0, (LBL_ffffbba8).w	; 0x94ae
	move.w	(player_1_).w, d0	; 0x94b2
	move.w	d0, (LBL_ffffbbaa).w	; 0x94b6
	lea	($97d6, pc), a0	; 0x94ba
	jsr	(writeText).w	; 0x94be
	bsr.w	FUN_000095cc	; 0x94c2
	ori.b	#$40, (VdpRegistersCache).w	; 0x94c6
	move.w	(VdpRegistersCache).w, (4, a5)	; 0x94cc
	bsr.w	FUN_000094ec	; 0x94d2
	move.w	(LBL_ffffbba8).w, d0	; 0x94d6
	move.w	d0, (LBL_ffff803c).w	; 0x94da
	move.w	(LBL_ffffbbaa).w, d0	; 0x94de
	move.w	d0, (player_1_).w	; 0x94e2
	jmp	FUN_0000451a	; 0x94e6

FUN_000094ec:
	clr.b	(isVIntProcessed).w	; 0x94ec
@wait_vint:
	tst.b	(isVIntProcessed).w	; 0x94f0
	beq.b	@wait_vint	; 0x94f4
	btst	#7, (joy1State).w	; 0x94f6
	beq.b	@not_start	; 0x94fc
	rts		; 0x94fe
@not_start:
	bsr.w	FUN_0000950a	; 0x9500
	bsr.w	FUN_0000958e	; 0x9504
	bra.b	FUN_000094ec	; 0x9508

FUN_0000950a:
	cmpi.b	#1, (joy1State).w	; 0x950a
	bne.b	@down	; 0x9510
	move.b	#8, (LBL_ffffbba6).w	; 0x9512
	bra.b	@not_down	; 0x9518
@down:
	cmpi.b	#1, (joy1State).w	; 0x951a
	bne.b	@down2	; 0x9520
	tst.b	(LBL_ffffbba6).w	; 0x9522
	beq.b	@not_down	; 0x9526
	subq.b	#1, (LBL_ffffbba6).w	; 0x9528
	bra.b	@down2	; 0x952c
@not_down:
	subi.w	#1, (unknownDebugMenuState).w	; 0x952e
	andi.w	#7, (unknownDebugMenuState).w	; 0x9534
	bra.b	proceed_222	; 0x953a
@down2:
	cmpi.b	#2, (joy1State).w	; 0x953c
	bne.b	@left	; 0x9542
	move.b	#8, (LBL_ffffbba6).w	; 0x9544
	bra.b	@not_left	; 0x954a
@left:
	cmpi.b	#2, (joy1State).w	; 0x954c
	bne.b	left_222	; 0x9552
	tst.b	(LBL_ffffbba6).w	; 0x9554
	beq.b	@not_left	; 0x9558
	subq.b	#1, (LBL_ffffbba6).w	; 0x955a
	bra.b	left_222	; 0x955e
@not_left:
	addi.w	#1, (unknownDebugMenuState).w	; 0x9560
	andi.w	#7, (unknownDebugMenuState).w	; 0x9566
	bra.b	proceed_222	; 0x956c

left_222:
	rts		; 0x956e

proceed_222:
	lea	(SAT_cache).w, a0	; 0x9570
	move.w	(unknownDebugMenuState).w, d0	; 0x9574
	lsl.w	#4, d0	; 0x9578
	addi.w	#$00b8, d0	; 0x957a
	move.w	d0, (a0)+	; 0x957e
	move.w	#0, (a0)+	; 0x9580
	move.w	#$8024, (a0)+	; 0x9584
	move.w	#$00a8, (a0)	; 0x9588
	rts		; 0x958c

FUN_0000958e:
	move.w	(unknownDebugMenuState).w, d0	; 0x958e
	add.w	d0, d0	; 0x9592
	cmpi.w	#$000c, d0	; 0x9594
	beq.w	unknwonDebugMenuState06	; 0x9598
	cmpi.w	#$000e, d0	; 0x959c
	beq.w	unknwonDebugMenuState07	; 0x95a0
	move.w	(joy1State).w, d2	; 0x95a4
	cmpi.w	#$000c, d2	; 0x95a8
	beq.b	@eq_0c	; 0x95ac
	andi.w	#$077c, d2	; 0x95ae
	beq.b	left_222	; 0x95b2
@eq_0c:
	move.w	(unknownDebugMenuFunctions, pc, d0.w), d1	; 0x95b4
	jmp	(unknownDebugMenuFunctions, pc, d1.w)	; 0x95b8

unknownDebugMenuFunctions:
	dc.w	unknwonDebugMenuState00-unknownDebugMenuFunctions	; 0x95bc
	dc.w	unknwonDebugMenuState01-unknownDebugMenuFunctions	; 0x95be
	dc.w	unknownDebugMenuState02-unknownDebugMenuFunctions	; 0x95c0
	dc.w	unknwonDebugMenuState03-unknownDebugMenuFunctions	; 0x95c2
	dc.w	unknwonDebugMenuState04-unknownDebugMenuFunctions	; 0x95c4
	dc.w	unknwonDebugMenuState05-unknownDebugMenuFunctions	; 0x95c6
	dc.w	unknwonDebugMenuState06-unknownDebugMenuFunctions	; 0x95c8
	dc.w	unknwonDebugMenuState07-unknownDebugMenuFunctions	; 0x95ca

FUN_000095cc:
	bsr.b	unknownDebugMenuWriteItem1	; 0x95cc
	bsr.b	unknownDebugMenuWriteItem2	; 0x95ce
	bsr.b	unknownDebugMenuWriteItem3	; 0x95d0
	bsr.b	unknownDebugMenuWriteItem4	; 0x95d2
	bsr.w	unknownDebugMenuWriteItem5	; 0x95d4
	bsr.w	unknownDebugMenuWriteItem6	; 0x95d8
	move.w	(LBL_ffffbba8).w, d0	; 0x95dc
	move.l	#$69ac0003, (4, a5)	; 0x95e0
	bsr.w	FUN_00009786	; 0x95e8
	move.w	(LBL_ffffbbaa).w, d0	; 0x95ec
	move.l	#$6aac0003, (4, a5)	; 0x95f0
	bsr.w	Fun9786proceed	; 0x95f8
	bra.w	proceed_222	; 0x95fc

unknwonDebugMenuState00:
	eori.b	#$80, (LBL_fffffd1a).w	; 0x9600

unknownDebugMenuWriteItem1:
	lea	($9850, pc), a0	; 0x9606
	tst.b	(LBL_fffffd1a).w	; 0x960a
	bmi.b	@on	; 0x960e
	lea	($9858, pc), a0	; 0x9610
@on:
	jmp	(writeText).w	; 0x9614

unknwonDebugMenuState01:
	eori.b	#$40, (LBL_fffffd1a).w	; 0x9618

unknownDebugMenuWriteItem2:
	lea	($9860, pc), a0	; 0x961e
	btst	#6, (LBL_fffffd1a).w	; 0x9622
	bne.b	on	; 0x9628
	lea	($9868, pc), a0	; 0x962a

on:
	jmp	(writeText).w	; 0x962e

unknownDebugMenuState02:
	eori.b	#8, (LBL_fffffd1a).w	; 0x9632

unknownDebugMenuWriteItem3:
	lea	($9870, pc), a0	; 0x9638
	btst	#3, (LBL_fffffd1a).w	; 0x963c
	bne.b	@on	; 0x9642
	lea	($9878, pc), a0	; 0x9644
@on:
	jmp	(writeText).w	; 0x9648

unknwonDebugMenuState03:
	eori.b	#1, (LBL_fffffd1a).w	; 0x964c

unknownDebugMenuWriteItem4:
	lea	($9880, pc), a0	; 0x9652
	btst	#0, (LBL_fffffd1a).w	; 0x9656
	bne.b	@on	; 0x965c
	lea	($9888, pc), a0	; 0x965e
@on:
	jmp	(writeText).w	; 0x9662

unknwonDebugMenuState04:
	eori.b	#2, (LBL_fffffd1a).w	; 0x9666

unknownDebugMenuWriteItem5:
	lea	($9890, pc), a0	; 0x966c
	btst	#1, (LBL_fffffd1a).w	; 0x9670
	bne.b	@on	; 0x9676
	lea	($9898, pc), a0	; 0x9678
@on:
	jmp	(writeText).w	; 0x967c

unknwonDebugMenuState05:
	eori.b	#4, (LBL_fffffd1a).w	; 0x9680

unknownDebugMenuWriteItem6:
	lea	($98a0, pc), a0	; 0x9686
	btst	#2, (LBL_fffffd1a).w	; 0x968a
	bne.b	@on	; 0x9690
	lea	($98a8, pc), a0	; 0x9692
@on:
	jmp	(writeText).w	; 0x9696

unknwonDebugMenuState06:
	tst.w	(LBL_ffff803c).w	; 0x969a
	bmi.b	@not_something_2	; 0x969e
	move.b	#8, d0	; 0x96a0
	move.b	(joy1State).w, d1	; 0x96a4
	move.b	(joy1State).w, d2	; 0x96a8
	bsr.b	unknownDebugMenuIfSomething	; 0x96ac
	bne.b	@not_something	; 0x96ae
	move.b	#4, d0	; 0x96b0
	move.b	(joy1State).w, d1	; 0x96b4
	move.b	(joy1State).w, d2	; 0x96b8
	bsr.b	unknownDebugMenuIfSomething	; 0x96bc
	beq.b	@not_something_2	; 0x96be
	move.w	(LBL_ffffbba8).w, d0	; 0x96c0
	subq.w	#1, d0	; 0x96c4
	bpl.b	@positive	; 0x96c6
	moveq	#-1, d0	; 0x96c8
@positive:
	move.w	d0, (LBL_ffffbba8).w	; 0x96ca
	move.l	#$69ac0003, (4, a5)	; 0x96ce
	bra.w	FUN_00009786	; 0x96d6
@not_something:
	move.w	(LBL_ffffbba8).w, d0	; 0x96da
	addi.w	#1, d0	; 0x96de
	cmpi.w	#$00b1, d0	; 0x96e2
	bcs.b	@not_too_large	; 0x96e6
	move.w	#$00b0, d0	; 0x96e8
@not_too_large:
	move.w	d0, (LBL_ffffbba8).w	; 0x96ec
	move.l	#$69ac0003, (4, a5)	; 0x96f0
	bra.w	FUN_00009786	; 0x96f8
@not_something_2:
	rts		; 0x96fc

unknownDebugMenuIfSomething:
	cmp.b	d0, d1	; 0x96fe
	bne.b	@different_keys	; 0x9700
	move.b	#8, (LBL_ffffbba6).w	; 0x9702
	bra.b	@return_1	; 0x9708
@different_keys:
	cmp.b	d0, d2	; 0x970a
	bne.b	@return_0	; 0x970c
	tst.b	(LBL_ffffbba6).w	; 0x970e
	beq.b	@return_1	; 0x9712
	subq.b	#1, (LBL_ffffbba6).w	; 0x9714
	bra.b	@return_0	; 0x9718
@return_1:
	moveq	#1, d0	; 0x971a
	rts		; 0x971c
@return_0:
	moveq	#0, d0	; 0x971e
	rts		; 0x9720

unknwonDebugMenuState07:
	tst.w	(player_1_).w	; 0x9722
	bmi.b	@not_something_2	; 0x9726
	move.b	#8, d0	; 0x9728
	move.b	(joy1State).w, d1	; 0x972c
	move.b	(joy1State).w, d2	; 0x9730
	bsr.b	unknownDebugMenuIfSomething	; 0x9734
	bne.b	@not_something_1	; 0x9736
	move.b	#4, d0	; 0x9738
	move.b	(joy1State).w, d1	; 0x973c
	move.b	(joy1State).w, d2	; 0x9740
	bsr.b	unknownDebugMenuIfSomething	; 0x9744
	beq.b	@not_something_2	; 0x9746
	move.w	(LBL_ffffbbaa).w, d0	; 0x9748
	subq.w	#1, d0	; 0x974c
	bpl.b	@not_negative	; 0x974e
	moveq	#-1, d0	; 0x9750
@not_negative:
	move.w	d0, (LBL_ffffbbaa).w	; 0x9752
	move.l	#$6aac0003, (4, a5)	; 0x9756
	bra.w	Fun9786proceed	; 0x975e
@not_something_1:
	move.w	(LBL_ffffbbaa).w, d0	; 0x9762
	addi.w	#1, d0	; 0x9766
	cmpi.w	#$00b1, d0	; 0x976a
	bcs.b	@not_too_large	; 0x976e
	move.w	#$00b0, d0	; 0x9770
@not_too_large:
	move.w	d0, (LBL_ffffbbaa).w	; 0x9774
	move.l	#$6aac0003, (4, a5)	; 0x9778
	bra.w	Fun9786proceed	; 0x9780
@not_something_2:
	rts		; 0x9784

FUN_00009786:
	tst.w	d0	; 0x9786
	bmi.b	fun9786_set	; 0x9788
	bra.b	fun9786_not_set	; 0x978a

Fun9786proceed:
	tst.w	d0	; 0x978c
	bmi.b	fun9786_write_die_2	; 0x978e

fun9786_not_set:
	move.b	#$30, d1	; 0x9790
	andi.w	#$00ff, d1	; 0x9794
	move.w	d1, (a5)	; 0x9798
	move.w	d0, d1	; 0x979a
	lsr.w	#4, d1	; 0x979c
	andi.w	#$000f, d1	; 0x979e
	move.b	(strHexDigitsAlt3, pc, d1.w), d1	; 0x97a2
	move.w	d1, (a5)	; 0x97a6
	move.w	d0, d1	; 0x97a8
	andi.w	#$000f, d1	; 0x97aa
	move.b	(strHexDigitsAlt3, pc, d1.w), d1	; 0x97ae
	move.w	d1, (a5)	; 0x97b2
	rts		; 0x97b4

fun9786_set:
	lea	($98b0, pc), a0	; 0x97b6
	jmp	(writeText).w	; 0x97ba

fun9786_write_die_2:
	lea	($98b8, pc), a0	; 0x97be
	jmp	(writeText).w	; 0x97c2

strHexDigitsAlt3:
	dc.b	$30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $41, $42, $43, $44, $45, $46	; 0x97c6

txtTest_Test_Bit_Edit:
	dc.w	$620e; write to 0xe20e	; 0x97d6
	dc.b	$00; upper byte	; 0x97d8
	dc.b	$54,$45,$53,$54,$20,$54,$45,$53,$54,$20,$42,$49,$54,$20,$45,$44,$49,$54,$ff	; 0x97d9
	dc.b	$ff	; 0x97ec
	dc.b	$ff	; 0x97ed
	dc.b	$54,$49,$4d,$45,$20,$53,$54,$4f,$50,$ff	; 0x97ee
	dc.b	$ff	; 0x97f8
	dc.b	$4e,$4f,$20,$44,$41,$4d,$41,$47,$45,$ff	; 0x97f9
	dc.b	$ff	; 0x9803
	dc.b	$4e,$4f,$20,$43,$48,$45,$43,$4b,$ff	; 0x9804
	dc.b	$ff	; 0x980d
	dc.b	$53,$4f,$46,$54,$20,$52,$41,$50,$49,$44,$ff	; 0x980e
	dc.b	$ff	; 0x9819
	dc.b	$53,$48,$4f,$52,$49,$20,$42,$41,$52,$ff	; 0x981a
	dc.b	$ff	; 0x9824
	dc.b	$4e,$41,$4e,$44,$4f,$20,$44,$49,$53,$50,$ff	; 0x9825
	dc.b	$ff	; 0x9830
	dc.b	$31,$50,$4c,$41,$59,$45,$52,$20,$56,$49,$54,$41,$4c,$ff	; 0x9831
	dc.b	$ff	; 0x983f
	dc.b	$32,$50,$4c,$41,$59,$45,$52,$20,$56,$49,$54,$41,$4c	; 0x9840
	dc.b	$00	; 0x984e
	dc.b	$00	; 0x984e
	dc.b	$01	; 0x984f

txtOn1:
	dc.w	$63ac; write to 0xe3ac	; 0x9850
	dc.b	$00; upper byte	; 0x9852
	dc.b	$4f,$4e,$20	; 0x9853
	dc.b	$00,$3c	; 0x9857

txtOff1:
	dc.w	$63ac; write to 0xe3ac	; 0x9858
	dc.b	$00; upper byte	; 0x985a
	dc.b	$4f,$46,$46	; 0x985b
	dc.b	$00,$7c	; 0x985f

txtOn2:
	dc.w	$64ac; write to 0xe4ac	; 0x9860
	dc.b	$00; upper byte	; 0x9862
	dc.b	$4f,$4e,$20	; 0x9863
	dc.b	$00,$00	; 0x9867

txtOff2:
	dc.w	$64ac; write to 0xe4ac	; 0x9868
	dc.b	$00; upper byte	; 0x986a
	dc.b	$4f,$46,$46	; 0x986b
	dc.b	$00,$2c	; 0x986f

txtOn3:
	dc.w	$65ac; write to 0xe5ac	; 0x9870
	dc.b	$00; upper byte	; 0x9872
	dc.b	$4f,$4e,$20	; 0x9873
	dc.b	$00,$3c	; 0x9877

txtOff3:
	dc.w	$65ac; write to 0xe5ac	; 0x9878
	dc.b	$00; upper byte	; 0x987a
	dc.b	$4f,$46,$46	; 0x987b
	dc.b	$00,$81	; 0x987f

txtOn4:
	dc.w	$66ac; write to 0xe6ac	; 0x9880
	dc.b	$00; upper byte	; 0x9882
	dc.b	$4f,$4e,$20	; 0x9883
	dc.b	$00,$0f	; 0x9887

txtOff4:
	dc.w	$66ac; write to 0xe6ac	; 0x9888
	dc.b	$00; upper byte	; 0x988a
	dc.b	$4f,$46,$46	; 0x988b
	dc.b	$00,$00	; 0x988f

txtOn5:
	dc.w	$67ac; write to 0xe7ac	; 0x9890
	dc.b	$00; upper byte	; 0x9892
	dc.b	$4f,$4e,$20	; 0x9893
	dc.b	$00,$16	; 0x9897

txtOff5:
	dc.w	$67ac; write to 0xe7ac	; 0x9898
	dc.b	$00; upper byte	; 0x989a
	dc.b	$4f,$46,$46	; 0x989b
	dc.b	$00,$f8	; 0x989f

txtOn6:
	dc.w	$68ac; write to 0xe8ac	; 0x98a0
	dc.b	$00; upper byte	; 0x98a2
	dc.b	$4f,$4e,$20	; 0x98a3
	dc.b	$00,$f8	; 0x98a7

txtOff6:
	dc.w	$68ac; write to 0xe8ac	; 0x98a8
	dc.b	$00; upper byte	; 0x98aa
	dc.b	$4f,$46,$46	; 0x98ab
	dc.b	$00,$33	; 0x98af

txtDie1:
	dc.w	$69ac; write to 0xe9ac	; 0x98b0
	dc.b	$00; upper byte	; 0x98b2
	dc.b	$44,$49,$45	; 0x98b3
	dc.b	$00,$42	; 0x98b7

txtDie2:
	dc.w	$6aac; write to 0xeaac	; 0x98b8
	dc.b	$00; upper byte	; 0x98ba
	dc.b	$44,$49,$45	; 0x98bb
	dc.b	$00,$54	; 0x98bf

openingSceneState04:
	move.w	(openingSceneSubState).w, d0	; 0x98c0
	move.w	(openingSceneState04Substates, pc, d0.w), d1	; 0x98c4
	jsr	(openingSceneState04Substates, pc, d1.w)	; 0x98c8
	bsr.w	kataModeUpdateFighter	; 0x98cc
	jsr	(updateBackgroundAndObjects).w	; 0x98d0
	jmp	(updateAllSprites).w	; 0x98d4

openingSceneState04Substates:
	dc.w	initDemoMode-openingSceneState04Substates	; 0x98d8
	dc.w	openingSceneState04_02-openingSceneState04Substates	; 0x98da
	dc.w	openingSceneState04_04-openingSceneState04Substates	; 0x98dc
	dc.w	openingSceneState04_06-openingSceneState04Substates	; 0x98de
	dc.w	openingSceneState04_08-openingSceneState04Substates	; 0x98e0
	dc.w	openingSceneState02Sub05-openingSceneState04Substates	; 0x98e2

initDemoMode:
	jsr	(initDisplay).w	; 0x98e4
	move.l	#$00000100, (hScrollCacheA).w	; 0x98e8
	move.l	#$00000100, (vsRamCache1).w	; 0x98f0
	st	(flagProcessHScroll).w	; 0x98f8
	st	(flagProcessVSRAM).w	; 0x98fc
	jsr	(clearSatCache).w	; 0x9900
	jsr	(loadFlatPtrnsAtVpos4000).w	; 0x9904
	jsr	(clearPlayersDataAndMore).w	; 0x9908
	clr.b	(isFighterInKataMode).w	; 0x990c
	moveq	#0, d0	; 0x9910
	move.b	(counterMod16).w, d0	; 0x9912
	lea	charsIds, a0	; 0x9916
	move.b	(0, a0, d0), (player_1_).w	; 0x991c
	clr.b	(player_1_).w	; 0x9922
	addq.w	#2, (openingSceneSubState).w	; 0x9926
	move.b	(player_1_).w, d0	; 0x992a
	moveq	#1, d1	; 0x992e
	move.w	d1, d2	; 0x9930
	moveq	#$0016, d3	; 0x9932
	jsr	FUN_00013aaa	; 0x9934
	moveq	#2, d1	; 0x993a
	moveq	#0, d2	; 0x993c
	jsr	FUN_00013b5e	; 0x993e
	moveq	#$0010, d3	; 0x9944
	jmp	FUN_00013bd8	; 0x9946

openingSceneState04_02:
	st	(FLAG_ff97b1).w	; 0x994c
	lea	dataBuffer, a0	; 0x9950
	lea	LBL_ff2000, a1	; 0x9956
	lea	font8By16Ptrns, a2	; 0x995c
	move.w	#$123f, d0	; 0x9962
	jsr	loadBicolorPtrns	; 0x9966
	lea	($99ca, pc), a0	; 0x996c
	jsr	(transferDataToVramDMA).w	; 0x9970
	lea	($99d2, pc), a0	; 0x9974
	jsr	(transferDataToVramDMA).w	; 0x9978
	move.b	#1, d0	; 0x997c
	trap	#3	; 0x9980
	lea	($99da, pc), a0	; 0x9982
	jsr	(loadPalette).w	; 0x9986
	move.w	#$0eee, (colorMask).w	; 0x998a
	bsr.w	loadKataPalettes	; 0x9990
	jsr	(computeHScrollOffsets).w	; 0x9994
	move.w	#$0080, d0	; 0x9998
	move.w	d0, (cameraX).w	; 0x999c
	jsr	(selectHScrollOffset).w	; 0x99a0
	move.b	(player_1_).w, d0	; 0x99a4
	addi.b	#$80, d0	; 0x99a8
	move.b	d0, (DAT_ffff97b0_flag_random).w	; 0x99ac
	jsr	FUN_0001371c	; 0x99b0
	addq.w	#2, (openingSceneSubState).w	; 0x99b6
	ori.b	#$40, (VdpRegistersCache).w	; 0x99ba
	move.w	(VdpRegistersCache).w, (4, a5)	; 0x99c0
	jmp	(fadeInStart).w	; 0x99c6
	dc.w	$0920	; length in words	; 0x99ca
	dc.l	dataBuffer/2	; source	; 0x99cc
	dc.w	$6c00	; dest	; 0x99d0
	; 0x-1
	dc.w	$0920	; length in words	; 0x99d2
	dc.l	LBL_ff2000/2	; source	; 0x99d4
	dc.w	$8c00	; dest	; 0x99d8
	; 0x-1
	dc.b	$07	; nb of colors: 15	; 0x99da
	dc.b	$00	; first colors: 0x00	; 0x99db
	dc.l	palette_381380/2	; source	; 0x99dc
	; 0x-1
	dc.w	$0000	; 0x99e0

openingSceneState04_04:
	tst.b	(fadingDelta).w	; 0x99e2
	bne.b	@return_1	; 0x99e6
	move.b	#1, (isFighterInKataMode).w	; 0x99e8
	addq.w	#2, (openingSceneSubState).w	; 0x99ee
@return_1:
	rts		; 0x99f2

openingSceneState04_06:
	tst.b	(DAT_ffff97b0_flag_random).w	; 0x99f4
	bne.b	skip	; 0x99f8
	addq.w	#2, (openingSceneSubState).w	; 0x99fa
	move.b	#$18, (demoTimer01).w	; 0x99fe

skip:
	rts		; 0x9a04

openingSceneState04_08:
	tst.w	(hScrollCacheB).w	; 0x9a06
	beq.b	dont_move_plane_b	; 0x9a0a
	subq.w	#4, (hScrollCacheB).w	; 0x9a0c
	st	(flagProcessHScroll).w	; 0x9a10

dont_move_plane_b:
	tst.b	(demoTimer01).w	; 0x9a14
	beq.b	demo_timer_01_over	; 0x9a18
	subq.b	#1, (demoTimer01).w	; 0x9a1a
	rts		; 0x9a1e

demo_timer_01_over:
	tst.w	(colorMask).w	; 0x9a20
	beq.b	faded_in	; 0x9a24
	move.b	(object2And3Priority).w, d0	; 0x9a26
	andi.b	#7, d0	; 0x9a2a
	bne.b	loadKataPalettes	; 0x9a2e
	subi.w	#$0222, (colorMask).w	; 0x9a30

faded_in:
	move.w	(hScrollCacheB).w, d0	; 0x9a36
	or.w	(colorMask).w, d0	; 0x9a3a
	bne.b	loadKataPalettes	; 0x9a3e
	addq.w	#2, (openingSceneSubState).w	; 0x9a40
	moveq	#0, d0	; 0x9a44
	move.b	(player_1_).w, d0	; 0x9a46
	lea	LBL_0313d0, a0	; 0x9a4a
	move.b	(0, a0, d0), d0	; 0x9a50
	jsr	(putWordInSfxQueue).w	; 0x9a54

loadKataPalettes:
	st	(flagProcessPalettes).w	; 0x9a58
	lea	(rawPalettes).w, a0	; 0x9a5c
	move.l	#$00383ac0, a1	; 0x9a60
	move.l	#$00382402, a2	; 0x9a66
	move.w	(a2), (2, a0)	; 0x9a6c
	move.w	(a2), (12, a0)	; 0x9a70
	move.w	(a2), (22, a0)	; 0x9a74
	move.w	(4, a1), (4, a0)	; 0x9a78
	move.w	(16, a1), (14, a0)	; 0x9a7e
	move.w	(26, a1), (24, a0)	; 0x9a84
	move.w	(colorMask).w, d0	; 0x9a8a
	moveq	#$000f, d1	; 0x9a8e
	jmp	FUN_00013a30	; 0x9a90

openingSceneState02Sub05:
	cmpi.b	#2, (isFighterInKataMode).w	; 0x9a96
	bne.b	@return_1	; 0x9a9c
	addq.w	#2, (openingSceneState).w	; 0x9a9e
	clr.w	(openingSceneSubState).w	; 0x9aa2
@return_1:
	rts		; 0x9aa6

kataModeUpdateFighter:
	lea	(player_1_).w, a6	; 0x9aa8
	moveq	#0, d0	; 0x9aac
	move.b	(2, a6), d0	; 0x9aae
	move.w	(fighter2States, pc, d0.w), d1	; 0x9ab2
	jmp	(fighter2States, pc, d1.w)	; 0x9ab6

fighter2States:
	dc.w	fighter2State00-fighter2States	; 0x9aba
	dc.w	fighter2State02-fighter2States	; 0x9abc
	dc.w	fighter2State04-fighter2States	; 0x9abe
	dc.w	fighter2State06-fighter2States	; 0x9ac0
	dc.w	fighter2State08-fighter2States	; 0x9ac2

fighter2State00:
	move.b	(3, a6), d0	; 0x9ac4
	move.w	(fighter2State00Substates, pc, d0.w), d1	; 0x9ac8
	jmp	(fighter2State00Substates, pc, d1.w)	; 0x9acc

fighter2State00Substates:
	dc.w	fighter2State00_00-fighter2State00Substates	; 0x9ad0
	dc.w	fighter2State00_02-fighter2State00Substates	; 0x9ad2
	dc.w	fighter2State00_04-fighter2State00Substates	; 0x9ad4

fighter2State00_00:
	move.b	#1, (641, a6)	; 0x9ad6
	jsr	(activePlayers).w	; 0x9adc
	moveq	#0, d0	; 0x9ae0
	move.l	d0, (6, a6)	; 0x9ae2
	move.l	d0, (10, a6)	; 0x9ae6
	move.b	#$b0, (7, a6)	; 0x9aea
	move.b	#$c8, (11, a6)	; 0x9af0
	move.w	#$6600, (18, a6)	; 0x9af6
	move.b	#8, d0	; 0x9afc
	move.b	d0, (25, a6)	; 0x9b00
	move.b	d0, (196, a6)	; 0x9b04
	moveq	#0, d0	; 0x9b08
	move.b	(651, a6), d0	; 0x9b0a
	lea	kataAnimationsOffsets, a0	; 0x9b0e
	move.b	(0, a0, d0), d0	; 0x9b14
	move.w	d0, (currentKataId).w	; 0x9b18
	addq.b	#2, (3, a6)	; 0x9b1c
	moveq	#2, d0	; 0x9b20
	jmp	(setCharacterAnimation).w	; 0x9b22

fighter2State00_02:
	cmpi.b	#1, (isFighterInKataMode).w	; 0x9b26
	bne.b	proceed2	; 0x9b2c
	move.b	#$4b, (kataTimer).w	; 0x9b2e
	addq.b	#2, (3, a6)	; 0x9b34

proceed2:
	jmp	(updateCharAnimation).w	; 0x9b38

fighter2State00_04:
	subq.b	#1, (kataTimer).w	; 0x9b3c
	bne.b	proceed1	; 0x9b40
	addq.b	#2, (2, a6)	; 0x9b42
	clr.b	(3, a6)	; 0x9b46

proceed1:
	jmp	(updateCharAnimation).w	; 0x9b4a

fighter2State02:
	addq.b	#2, (2, a6)	; 0x9b4e
	lea	kataAnimationsOffsets, a0	; 0x9b52
	move.w	(currentKataId).w, d1	; 0x9b58
	move.b	(0, a0, d1), d0	; 0x9b5c
	cmpi.b	#$ff, d0	; 0x9b60
	bne.b	proceed3	; 0x9b64
	move.b	#6, (2, a6)	; 0x9b66
	move.b	#$2d, (kataTimer).w	; 0x9b6c
	moveq	#2, d0	; 0x9b72

proceed3:
	jmp	(setCharacterAnimation).w	; 0x9b74

fighter2State04:
	tst.b	(26, a6)	; 0x9b78
	bpl.b	proceed4	; 0x9b7c
	move.b	#2, (2, a6)	; 0x9b7e
	addq.w	#1, (currentKataId).w	; 0x9b84

proceed4:
	jmp	(updateCharAnimation).w	; 0x9b88

fighter2State06:
	tst.b	(3, a6)	; 0x9b8c
	bne.b	fighter2State06_02	; 0x9b90
	subq.b	#1, (kataTimer).w	; 0x9b92
	bne.b	proceed4	; 0x9b96
	move.b	#$b4, (kataTimer).w	; 0x9b98
	addq.b	#2, (3, a6)	; 0x9b9e
	moveq	#0, d0	; 0x9ba2
	move.b	(651, a6), d0	; 0x9ba4
	lea	winPoseAnimations, a0	; 0x9ba8
	move.b	(0, a0, d0), d0	; 0x9bae
	jmp	(setCharacterAnimation).w	; 0x9bb2

fighter2State06_02:
	subq.b	#1, (kataTimer).w	; 0x9bb6
	bne.b	fighter2State08	; 0x9bba
	move.b	#2, (isFighterInKataMode).w	; 0x9bbc
	addq.b	#2, (2, a6)	; 0x9bc2
	clr.b	(3, a6)	; 0x9bc6

fighter2State08:
	jmp	(updateCharAnimation).w	; 0x9bca

openingSceneState0c:
	move.w	(openingSceneSubState).w, d0	; 0x9bce
	move.w	(openingSceneState0cSubstates, pc, d0.w), d1	; 0x9bd2
	jsr	(openingSceneState0cSubstates, pc, d1.w)	; 0x9bd6
	jsr	(initStageUpdate).w	; 0x9bda
	st	(needFightersUpdating).w	; 0x9bde
	jsr	(updateStage).w	; 0x9be2
	jsr	(updateAllObjectsAlt).w	; 0x9be6
	jsr	(handleSomeObjects).w	; 0x9bea
	jsr	(updateAllSprites).w	; 0x9bee
	jmp	(updateStageScroll).w	; 0x9bf2

openingSceneState0cSubstates:
	dc.w	openingSceneState0c_00-openingSceneState0cSubstates	; 0x9bf6
	dc.w	openingSceneState0c_02-openingSceneState0cSubstates	; 0x9bf8
	dc.w	openingSceneState0c_04-openingSceneState0cSubstates	; 0x9bfa
	dc.w	openingSceneState0c_06-openingSceneState0cSubstates	; 0x9bfc
	dc.w	openingSceneState0c_08-openingSceneState0cSubstates	; 0x9bfe

openingSceneState0c_00:
	jsr	(initDisplay).w	; 0x9c00
	jsr	(clearSatCache).w	; 0x9c04
	jsr	(clearPlayersDataAndMore).w	; 0x9c08
	clr.b	(LBL_ffff992e).w	; 0x9c0c
	clr.b	(LBL_ffff9933).w	; 0x9c10
	clr.b	LBL_ffbbb7	; 0x9c14
	st	(LBL_ffff9826).w	; 0x9c1a
	addq.w	#2, (openingSceneSubState).w	; 0x9c1e
	move.w	#$0080, (cameraX).w	; 0x9c22
	clr.w	(cameraY).w	; 0x9c28
	moveq	#0, d0	; 0x9c2c
	move.b	(copyOfCounterMod16).w, d0	; 0x9c2e
	lea	charsIds, a0	; 0x9c32
	move.b	(0, a0, d0), d0	; 0x9c38
	move.w	d0, (stageId).w	; 0x9c3c
	jsr	initStageObjects	; 0x9c40
	jmp	FUN_00014796	; 0x9c46

openingSceneState0c_02:
	move.w	#$9202, (windowVPosSetter2).w	; 0x9c4c
	addq.w	#2, (openingSceneSubState).w	; 0x9c52
	move.b	(copyOfCounterMod16).w, d0	; 0x9c56
	lea	charsIds, a0	; 0x9c5a
	lea	(fighter1Data).w, a6	; 0x9c60
	move.b	(0, a0, d0), (651, a6)	; 0x9c64
	clr.b	(653, a6)	; 0x9c6a
	jsr	(activePlayers).w	; 0x9c6e
	moveq	#0, d0	; 0x9c72
	move.l	d0, (6, a6)	; 0x9c74
	move.l	d0, (10, a6)	; 0x9c78
	move.w	#$0100, (6, a6)	; 0x9c7c
	move.w	#$00c0, (10, a6)	; 0x9c82
	move.w	#$4580, (18, a6)	; 0x9c88
	moveq	#$0050, d0	; 0x9c8e
	move.b	d0, (LBL_ffff8016).w	; 0x9c90
	move.b	#8, d0	; 0x9c94
	move.b	d0, (25, a6)	; 0x9c98
	move.b	d0, (196, a6)	; 0x9c9c
	moveq	#2, d0	; 0x9ca0
	jsr	(setCharacterAnimation).w	; 0x9ca2
	move.b	#1, (LBL_ffff87a0).w	; 0x9ca6
	move.b	#4, (LBL_ffff87af).w	; 0x9cac
	rts		; 0x9cb2

openingSceneState0c_04:
	lea	($9d24, pc), a0	; 0x9cb4
	jsr	(loadFromDataLoader).w	; 0x9cb8
	bsr.w	loadHiScoresInDataBuffer	; 0x9cbc
	lea	($9d42, pc), a0	; 0x9cc0
	jsr	(transferDataToVramDMA).w	; 0x9cc4
	lea	($9d4a, pc), a0	; 0x9cc8
	jsr	(loadPalette).w	; 0x9ccc
	moveq	#$000f, d1	; 0x9cd0
@next1:
	jsr	(getObjectSlot).w	; 0x9cd2
	bne.b	@exit1	; 0x9cd6
	addq.b	#1, (a0)	; 0x9cd8
	move.b	#$60, (15, a0)	; 0x9cda
	move.b	d1, (16, a0)	; 0x9ce0
	dbf	d1, @next1	; 0x9ce4
@exit1:
	clr.b	(LBL_ffffbbb4).w	; 0x9ce8
	move.b	#$40, (hiScoreTimer).w	; 0x9cec
	moveq	#$0018, d0	; 0x9cf2
	jsr	(selectBgm).w	; 0x9cf4
	lea	(rawPalettes).w, a0	; 0x9cf8
	move.w	#$0444, d0	; 0x9cfc
	moveq	#$002f, d7	; 0x9d00
	jsr	getRGBComponents	; 0x9d02
	ori.b	#$40, (VdpRegistersCache).w	; 0x9d08
	move.w	(VdpRegistersCache).w, (4, a5)	; 0x9d0e
	jsr	(fadeInStart).w	; 0x9d14
	addq.w	#2, (openingSceneSubState).w	; 0x9d18

update_fighter_1_100:
	lea	(fighter1Data).w, a6	; 0x9d1c
	jmp	(updateCharAnimation).w	; 0x9d20
	dc.w	$00	; nb of bytes	; 0x9d24
	dc.l	PATTERNS_382480/2	; source	; 0x9d26
	dc.w	$215	; destination in VRAM	; 0x9d2a
	; 0x-1
	dc.b	$52, $41, $4e, $4b, $49, $4e, $47, $31, $53, $54, $32, $4e, $44, $33, $52, $44, $34, $54, $48, $35, $54, $48	; 0x9d2c
	dc.w	$09A0	; length in words	; 0x9d42
	dc.l	dataBuffer/2	; source	; 0x9d44
	dc.w	$8800	; dest	; 0x9d48
	; 0x-1
	dc.b	$07	; nb of colors: 15	; 0x9d4a
	dc.b	$60	; first colors: 0x30	; 0x9d4b
	dc.l	palette_381380/2	; source	; 0x9d4c
	; 0x-1
	dc.w	$0000	; 0x9d50

openingSceneState0c_06:
	tst.b	(fadingDelta).w	; 0x9d52
	bne.b	update_fighter_1_100	; 0x9d56
	subq.b	#1, (hiScoreTimer).w	; 0x9d58
	bne.b	update_fighter_1_100	; 0x9d5c
	moveq	#1, d0	; 0x9d5e
	move.b	d0, (LBL_ffff9879).w	; 0x9d60
	move.b	d0, (isFightOver).w	; 0x9d64
	clr.b	(LBL_ffff9861).w	; 0x9d68
	move.b	#1, (LBL_ffff9863).w	; 0x9d6c
	clr.b	(LBL_ffff9892).w	; 0x9d72
	addq.w	#2, (openingSceneSubState).w	; 0x9d76
	clr.b	(-32763, a6)	; 0x9d7a
	bra.b	proceed5	; 0x9d7e

openingSceneState0c_08:
	subq.b	#1, (LBL_ffffbbb4).w	; 0x9d80
	bne.b	proceed5	; 0x9d84
	clr.b	(LBL_ffff9879).w	; 0x9d86
	clr.b	(isFightOver).w	; 0x9d8a
	clr.b	(LBL_ffff9826).w	; 0x9d8e
	move.b	(counterMod16).w, d0	; 0x9d92
	addq.b	#1, d0	; 0x9d96
	andi.b	#$0f, d0	; 0x9d98
	move.b	d0, (counterMod16).w	; 0x9d9c
	move.b	d0, (copyOfCounterMod16).w	; 0x9da0
	tst.b	hiscoreVictoryAnimPlaying	; 0x9da4
	bne.b	proceed_339	; 0x9daa
	addq.w	#2, (openingSceneState).w	; 0x9dac
	clr.w	(openingSceneSubState).w	; 0x9db0

proceed5:
	lea	(fighter1Data).w, a6	; 0x9db4
	moveq	#0, d0	; 0x9db8
	move.b	(651, a6), d0	; 0x9dba
	lsl.w	#2, d0	; 0x9dbe
	move.l	(40390, pc, d0.w), a0	; 0x9dc0
	jmp	(a0)	; 0x9dc4
	dc.l	WORD_0001c452_ryu_e_honda_blanka_guile_ken_chun_li_zangief_dictator_sagat_claw_feilong_deejay	; 0x9dc6
	dc.l	WORD_0001c452_ryu_e_honda_blanka_guile_ken_chun_li_zangief_dictator_sagat_claw_feilong_deejay	; 0x9dca
	dc.l	WORD_0001c452_ryu_e_honda_blanka_guile_ken_chun_li_zangief_dictator_sagat_claw_feilong_deejay	; 0x9dce
	dc.l	WORD_0001c452_ryu_e_honda_blanka_guile_ken_chun_li_zangief_dictator_sagat_claw_feilong_deejay	; 0x9dd2
	dc.l	WORD_0001c452_ryu_e_honda_blanka_guile_ken_chun_li_zangief_dictator_sagat_claw_feilong_deejay	; 0x9dd6
	dc.l	WORD_0001c452_ryu_e_honda_blanka_guile_ken_chun_li_zangief_dictator_sagat_claw_feilong_deejay	; 0x9dda
	dc.l	WORD_0001c452_ryu_e_honda_blanka_guile_ken_chun_li_zangief_dictator_sagat_claw_feilong_deejay	; 0x9dde
	dc.l	WORD_0001c452_dhalsim	; 0x9de2
	dc.l	WORD_0001c452_ryu_e_honda_blanka_guile_ken_chun_li_zangief_dictator_sagat_claw_feilong_deejay	; 0x9de6
	dc.l	WORD_0001c452_ryu_e_honda_blanka_guile_ken_chun_li_zangief_dictator_sagat_claw_feilong_deejay	; 0x9dea
	dc.l	WORD_0001c452_boxer	; 0x9dee
	dc.l	WORD_0001c452_ryu_e_honda_blanka_guile_ken_chun_li_zangief_dictator_sagat_claw_feilong_deejay	; 0x9df2
	dc.l	WORD_0001c452_cammy	; 0x9df6
	dc.l	WORD_0001c452_ryu_e_honda_blanka_guile_ken_chun_li_zangief_dictator_sagat_claw_feilong_deejay	; 0x9dfa
	dc.l	WORD_0001c452_ryu_e_honda_blanka_guile_ken_chun_li_zangief_dictator_sagat_claw_feilong_deejay	; 0x9dfe
	dc.l	WORD_0001c452_ryu_e_honda_blanka_guile_ken_chun_li_zangief_dictator_sagat_claw_feilong_deejay	; 0x9e02

proceed_339:
	jsr	(fadeOutStartAndProcess).w	; 0x9e06
	clr.b	hiscoreVictoryAnimPlaying	; 0x9e0a
	jmp	($6460, pc)	; 0x9e10

loadHiScoresInDataBuffer:
	lea	LBL_ff2000, a0	; 0x9e14
	move.l	a0, a2	; 0x9e1a
	lea	(highScoreNamesBuffer).w, a1	; 0x9e1c
	moveq	#4, d4	; 0x9e20
@next2:
	moveq	#0, d1	; 0x9e22
	moveq	#3, d3	; 0x9e24
@next1:
	moveq	#0, d0	; 0x9e26
	move.b	(a1)+, d0	; 0x9e28
	move.b	d0, d2	; 0x9e2a
	lsr.b	#4, d0	; 0x9e2c
	bsr.b	hiscorePrintDigit	; 0x9e2e
	move.b	d2, d0	; 0x9e30
	andi.b	#$0f, d0	; 0x9e32
	bsr.b	hiscorePrintDigit	; 0x9e36
	dbf	d3, @next1	; 0x9e38
	move.b	(a1)+, (a2)+	; 0x9e3c
	move.b	(a1)+, (a2)+	; 0x9e3e
	move.b	(a1)+, (a2)+	; 0x9e40
	move.b	(a1)+, d0	; 0x9e42
	dbf	d4, @next2	; 0x9e44
	move.w	#$0580, d0	; 0x9e48
	move.l	#$00382480, d1	; 0x9e4c
	moveq	#2, d2	; 0x9e52
	move.b	#$36, d3	; 0x9e54
	jmp	(loadInDataBuffer).w	; 0x9e58

strDigits:
	dc.b	$30, $31, $32, $33, $34, $35, $36, $37, $38, $39	; 0x9e5c

hiscorePrintDigit:
	move.b	(strDigits, pc, d0.w), d0	; 0x9e66
	tst.b	d1	; 0x9e6a
	bne.b	@put	; 0x9e6c
	cmpi.b	#$30, d0	; 0x9e6e
	beq.b	@space	; 0x9e72
	moveq	#1, d1	; 0x9e74
	bra.b	@put	; 0x9e76
@space:
	move.b	#$20, d0	; 0x9e78
@put:
	move.b	d0, (a2)+	; 0x9e7c
	rts		; 0x9e7e

CMD_openingScene:
	move.b	(LBL_ffff9933).w, (hiscoreVictoryAnimPlaying).w	; 0x9e80
	move.b	(LBL_ffff992e).w, (LBL_ffbbb7).w	; 0x9e86
	jsr	(clear992eData).w	; 0x9e8c
	tst.b	(hiscoreVictoryAnimPlaying).w	; 0x9e90
	bne.b	@skip_opening	; 0x9e94
	tst.b	(LBL_ffbbb7).w	; 0x9e96
	beq.b	@dont_skip_opening	; 0x9e9a
@skip_opening:
	move.w	#$000a, (openingSceneState).w	; 0x9e9c
@dont_skip_opening:
	st	(areWeOnTitleScreenOrDemoMode).w	; 0x9ea2

opening_scene_loop:
	move.w	(openingSceneState).w, d0	; 0x9ea6
	move.w	(openingSceneStates, pc, d0.w), d1	; 0x9eaa
	jsr	(openingSceneStates, pc, d1.w)	; 0x9eae
	move.b	#1, d0	; 0x9eb2
	trap	#3	; 0x9eb6

CMD_00009eb8:
	tst.b	(hiscoreVictoryAnimPlaying).w	; 0x9eb8
	bne.b	opening_scene_loop	; 0x9ebc
	cmpi.w	#$0012, (openingSceneState).w	; 0x9ebe
	beq.b	opening_scene_loop	; 0x9ec4
	move.b	(joy1State).w, d0	; 0x9ec6
	or.b	(joy2State).w, d0	; 0x9eca
	btst	#7, d0	; 0x9ece
	beq.b	opening_scene_loop	; 0x9ed2
	move.w	#$0012, (openingSceneState).w	; 0x9ed4
	clr.w	(openingSceneSubState).w	; 0x9eda
	clr.l	(openingSceneSubSubState).w	; 0x9ede
	bra.b	opening_scene_loop	; 0x9ee2

openingSceneStates:
	dc.w	openingSceneState00-openingSceneStates	; 0x9ee4
	dc.w	openingSceneStates02And06And0aAnd0e-openingSceneStates	; 0x9ee6
	dc.w	openingSceneState04-openingSceneStates	; 0x9ee8
	dc.w	openingSceneStates02And06And0aAnd0e-openingSceneStates	; 0x9eea
	dc.w	openingSceneState08Alt-openingSceneStates	; 0x9eec
	dc.w	openingSceneStates02And06And0aAnd0e-openingSceneStates	; 0x9eee
	dc.w	openingSceneState0c-openingSceneStates	; 0x9ef0
	dc.w	openingSceneStates02And06And0aAnd0e-openingSceneStates	; 0x9ef2
	dc.w	openingSceneState10-openingSceneStates	; 0x9ef4
	dc.w	openingSceneState12-openingSceneStates	; 0x9ef6

openingSceneStates02And06And0aAnd0e:
	tst.w	(openingSceneSubState).w	; 0x9ef8
	bne.b	openingSceneState02_02	; 0x9efc
	addq.w	#2, (openingSceneSubState).w	; 0x9efe
	jmp	(fadeOutStart).w	; 0x9f02

openingSceneState02_02:
	tst.b	(fadingDelta).w	; 0x9f06
	bne.b	return_444	; 0x9f0a
	addq.w	#2, (openingSceneState).w	; 0x9f0c
	clr.w	(openingSceneSubState).w	; 0x9f10
	clr.l	(openingSceneSubSubState).w	; 0x9f14
	move.w	#$0020, d0	; 0x9f18
	trap	#2	; 0x9f1c
	move.w	#$0030, d0	; 0x9f1e
	trap	#2	; 0x9f22
	jsr	(clearPlayersAnd97caData).w	; 0x9f24
	clr.b	(areWeFighting).w	; 0x9f28
	jsr	(initDisplay).w	; 0x9f2c
	jmp	(clearSatCache).w	; 0x9f30

openingSceneState10:
	clr.l	(openingSceneState).w	; 0x9f34
	clr.l	(openingSceneSubSubState).w	; 0x9f38

return_444:
	rts		; 0x9f3c

openingSceneState00:
	tst.w	(openingSceneSubState).w	; 0x9f3e
	bne.b	openingSceneState00_02	; 0x9f42
	move.w	#$0708, (openingTimer1).w	; 0x9f44
	addq.w	#2, (openingSceneSubState).w	; 0x9f4a
	move.l	#$0000a3ee, a0	; 0x9f4e
	move.w	#$0020, d0	; 0x9f54
	trap	#0	; 0x9f58
	rts		; 0x9f5a

openingSceneState00_02:
	subq.w	#1, (openingTimer1).w	; 0x9f5c
	bne.b	return_2	; 0x9f60
	addq.w	#2, (openingSceneState).w	; 0x9f62
	clr.l	(openingSceneSubState).w	; 0x9f66

return_2:
	rts		; 0x9f6a

openingSceneState08Alt:
	move.w	(openingSceneSubState).w, d0	; 0x9f6c
	move.w	(openingSceneState08AltSubstates, pc, d0.w), d0	; 0x9f70
	jmp	(openingSceneState08AltSubstates, pc, d0.w)	; 0x9f74

openingSceneState08AltSubstates:
	dc.w	openingSceneState08_00-openingSceneState08AltSubstates	; 0x9f78
	dc.w	openingSceneState08_02-openingSceneState08AltSubstates	; 0x9f7a
	dc.w	openingSceneState08_04-openingSceneState08AltSubstates	; 0x9f7c

openingSceneState08_00:
	addq.w	#2, (openingSceneSubState).w	; 0x9f7e
	jmp	($a320, pc)	; 0x9f82

openingSceneState08_02:
	tst.b	(areWeFighting).w	; 0x9f86
	beq.b	return_445	; 0x9f8a
	addq.w	#2, (openingSceneSubState).w	; 0x9f8c

return_445:
	rts		; 0x9f90

openingSceneState08_04:
	cmpi.w	#$5501, (time).w	; 0x9f92
	bls.b	@demo_mode_timeout	; 0x9f98
	tst.b	(LBL_ffff9879).w	; 0x9f9a
	beq.b	return_445	; 0x9f9e
@demo_mode_timeout:
	move.w	#$0020, d0	; 0x9fa0
	trap	#2	; 0x9fa4
	move.w	#$0030, d0	; 0x9fa6
	trap	#2	; 0x9faa
	clr.b	(areWeFighting).w	; 0x9fac
	addq.w	#2, (openingSceneState).w	; 0x9fb0
	clr.l	(openingSceneSubState).w	; 0x9fb4
	jsr	(bgmStop).w	; 0x9fb8
	jmp	(bgmFadeOff).w	; 0x9fbc

openingSceneState12:
	move.w	(openingSceneSubState).w, d0	; 0x9fc0
	move.w	(openingSceneState12Substates, pc, d0.w), d1	; 0x9fc4
	jsr	(openingSceneState12Substates, pc, d1.w)	; 0x9fc8
	jsr	(updateBackgroundAndObjects).w	; 0x9fcc
	jsr	(updateAllSprites).w	; 0x9fd0
	subq.w	#1, (openingTimer1).w	; 0x9fd4
	bne.b	@return_4	; 0x9fd8
	move.w	#2, (openingSceneState).w	; 0x9fda
	clr.l	(openingSceneSubState).w	; 0x9fe0
@return_4:
	rts		; 0x9fe4

openingSceneState12Substates:
	dc.w	openingSceneState12_00-openingSceneState12Substates	; 0x9fe6
	dc.w	openingSceneState12_02-openingSceneState12Substates	; 0x9fe8
	dc.w	openingSceneState12_04-openingSceneState12Substates	; 0x9fea
	dc.w	openingSceneState12_06-openingSceneState12Substates	; 0x9fec
	dc.w	openingSceneState12_08-openingSceneState12Substates	; 0x9fee

openingSceneState12_00:
	move.b	#1, d0	; 0x9ff0
	trap	#3	; 0x9ff4
	tst.b	(fadingDelta).w	; 0x9ff6
	bne.b	openingSceneState12_00	; 0x9ffa
	jsr	(fadeOutStartAndProcess).w	; 0x9ffc
	jsr	(bgmStop).w	; 0xa000
	jsr	(selectBgmF3).w	; 0xa004
	jsr	(put0000And0100InSfxQueue).w	; 0xa008
	jsr	(initDisplay).w	; 0xa00c
	jsr	(clearSatCache).w	; 0xa010
	jsr	(clearPlayersAnd97caData).w	; 0xa014
	move.w	#$0020, d0	; 0xa018
	trap	#2	; 0xa01c
	move.w	#$0030, d0	; 0xa01e
	trap	#2	; 0xa022
	move.w	#$0040, d0	; 0xa024
	trap	#2	; 0xa028
	move.w	#$0050, d0	; 0xa02a
	trap	#2	; 0xa02e
	clr.b	(areWeFighting).w	; 0xa030
	move.w	#$04b0, (openingTimer1).w	; 0xa034
	addq.w	#2, (openingSceneSubState).w	; 0xa03a

return_5:
	rts		; 0xa03e

openingSceneState12_02:
	jsr	($aab8, pc)	; 0xa040
	move.b	#6, (gameMenuSelection).w	; 0xa044
	clr.b	(flashingMenuSelection).w	; 0xa04a
	bsr.w	displayGameSpeedSelection	; 0xa04e
	addq.w	#2, (openingSceneSubState).w	; 0xa052
	ori.b	#$40, (VdpRegistersCache).w	; 0xa056
	move.w	(VdpRegistersCache).w, (4, a5)	; 0xa05c
	jmp	(fadeInStart).w	; 0xa062

openingSceneState12_04:
	move.b	(joy1State).w, d0	; 0xa066
	or.b	(joy2State).w, d0	; 0xa06a
	beq.b	return_5	; 0xa06e
	bsr.w	resetOpeningTimer1	; 0xa070
	move.b	(gameSpeed).w, d1	; 0xa074
	btst	#3, d0	; 0xa078
	beq.b	@not_right	; 0xa07c
	addq.b	#2, d1	; 0xa07e
	cmpi.b	#$0a, d1	; 0xa080
	bne.b	@change_speed	; 0xa084
	moveq	#0, d1	; 0xa086
	bra.b	@change_speed	; 0xa088
@not_right:
	btst	#2, d0	; 0xa08a
	beq.b	@not_left	; 0xa08e
	subq.b	#2, d1	; 0xa090
	bpl.b	@change_speed	; 0xa092
	moveq	#8, d1	; 0xa094
@change_speed:
	move.b	d1, (gameSpeed).w	; 0xa096
	bra.w	displayGameSpeedSelection	; 0xa09a
@not_left:
	btst	#7, d0	; 0xa09e
	beq.b	return_5	; 0xa0a2
	tst.b	(fadingDelta).w	; 0xa0a4
	bne.b	return_5	; 0xa0a8
	clr.b	(gameMenuSelection).w	; 0xa0aa
	addq.w	#2, (openingSceneSubState).w	; 0xa0ae
	bra.w	initGameModeMenu	; 0xa0b2

openingSceneState12_06:
	moveq	#0, d0	; 0xa0b6
	move.w	(joy1State).w, d0	; 0xa0b8
	or.w	(joy2State).w, d0	; 0xa0bc
	beq.b	@not_abcxyz	; 0xa0c0
	bsr.w	resetOpeningTimer1	; 0xa0c2
	move.b	(gameMenuSelection).w, d1	; 0xa0c6
	btst	#1, d0	; 0xa0ca
	bne.b	@down	; 0xa0ce
	btst	#0, d0	; 0xa0d0
	bne.b	@up	; 0xa0d4
	btst	#3, d0	; 0xa0d6
	bne.b	@right	; 0xa0da
	btst	#2, d0	; 0xa0dc
	bne.w	@left	; 0xa0e0
	btst	#7, d0	; 0xa0e4
	beq.b	@not_start	; 0xa0e8
	clr.b	(startButtonStates).w	; 0xa0ea
	bsr.w	checkStartButtonStates	; 0xa0ee
	move.b	#$3c, (gameModeScreenClosingTimer).w	; 0xa0f2
	addq.w	#2, (openingSceneSubState).w	; 0xa0f8
	moveq	#$0033, d0	; 0xa0fc
	jsr	(selectBgm).w	; 0xa0fe
	jmp	(fadeOutStart).w	; 0xa102
@not_start:
	andi.w	#$0770, d0	; 0xa106
	beq.b	@not_abcxyz	; 0xa10a
	move.w	#4, (openingSceneSubState).w	; 0xa10c
	move.b	#6, (gameMenuSelection).w	; 0xa112
	bra.w	displayGameSpeedSelection	; 0xa118
@not_abcxyz:
	rts		; 0xa11c
@down:
	addq.b	#2, d1	; 0xa11e
	cmpi.b	#6, d1	; 0xa120
	bne.b	@not_too_low	; 0xa124
	moveq	#1, d1	; 0xa126
	bra.b	@not_too_high	; 0xa128
@not_too_low:
	cmpi.b	#7, d1	; 0xa12a
	bne.b	@not_too_high	; 0xa12e
	moveq	#0, d1	; 0xa130
	bra.b	@not_too_high	; 0xa132
@up:
	subq.b	#2, d1	; 0xa134
	bpl.b	@not_too_high	; 0xa136
	cmpi.b	#$ff, d1	; 0xa138
	bne.b	@not_too_low_2	; 0xa13c
	moveq	#4, d1	; 0xa13e
	bra.b	@not_too_high	; 0xa140
@not_too_low_2:
	moveq	#5, d1	; 0xa142
	bra.b	@not_too_high	; 0xa144
@right:
	addq.b	#1, d1	; 0xa146
	cmpi.b	#6, d1	; 0xa148
	bne.b	@not_too_high	; 0xa14c
	moveq	#0, d1	; 0xa14e
	bra.b	@not_too_high	; 0xa150
@left:
	subq.b	#1, d1	; 0xa152
	bpl.b	@not_too_high	; 0xa154
	moveq	#5, d1	; 0xa156
@not_too_high:
	move.b	d1, (gameMenuSelection).w	; 0xa158
	jsr	($a226, pc)	; 0xa15c
	moveq	#$0030, d0	; 0xa160
	jmp	(selectBgm).w	; 0xa162

openingSceneState12_08:
	bsr.b	checkStartButtonStates	; 0xa166
	move.b	(object2And3Priority).w, d0	; 0xa168
	andi.b	#4, d0	; 0xa16c
	move.b	d0, (flashingMenuSelection).w	; 0xa170
	tst.b	(gameModeScreenClosingTimer).w	; 0xa174
	beq.b	@closeGameModeSelection	; 0xa178
	subq.b	#1, (gameModeScreenClosingTimer).w	; 0xa17a
@init_game_mode_menu:
	bra.w	initGameModeMenu	; 0xa17e
@closeGameModeSelection:
	tst.b	(fadingDelta).w	; 0xa182
	bne.b	@init_game_mode_menu	; 0xa186
	clr.b	(areWeOnTitleScreenOrDemoMode).w	; 0xa188
	clr.b	(LBL_ffff993b).w	; 0xa18c
	clr.b	(LBL_ffff9938).w	; 0xa190
	clr.b	(LBL_ffff9943).w	; 0xa194
	clr.b	(LBL_ffff996e).w	; 0xa198
	clr.b	(LBL_ffff99dc).w	; 0xa19c
	moveq	#0, d0	; 0xa1a0
	move.b	(gameMenuSelection).w, d0	; 0xa1a2
	add.w	d0, d0	; 0xa1a6
	move.w	(gameMenuSelectionStates, pc, d0.w), d1	; 0xa1a8
	jmp	(gameMenuSelectionStates, pc, d1.w)	; 0xa1ac

gameMenuSelectionStates:
	dc.w	selectSuperGameMode-gameMenuSelectionStates	; 0xa1b0
	dc.w	openingSceneState12_08_02-gameMenuSelectionStates	; 0xa1b2
	dc.w	openingSceneState12_08_04-gameMenuSelectionStates	; 0xa1b4
	dc.w	openingSceneState12_08_06-gameMenuSelectionStates	; 0xa1b6
	dc.w	openingSceneState12_08_08-gameMenuSelectionStates	; 0xa1b8
	dc.w	selectOptionMenu-gameMenuSelectionStates	; 0xa1ba

selectOptionMenu:
	move.l	#$000079b6, a0	; 0xa1bc
	move.w	#$0040, d0	; 0xa1c2
	trap	#0	; 0xa1c6
	trap	#1	; 0xa1c8

checkStartButtonStates:
	move.b	(startButtonStates).w, d0	; 0xa1ca
	btst	#7, (joy1State).w	; 0xa1ce
	beq.b	@not_p1_start	; 0xa1d4
	ori.b	#1, d0	; 0xa1d6
@not_p1_start:
	btst	#7, (joy2State).w	; 0xa1da
	beq.b	@not_p2_start	; 0xa1e0
	ori.b	#2, d0	; 0xa1e2
@not_p2_start:
	move.b	d0, (startButtonStates).w	; 0xa1e6
	rts		; 0xa1ea

resetOpeningTimer1:
	move.w	#$0258, d1	; 0xa1ec
	cmp.w	(openingTimer1).w, d1	; 0xa1f0
	bcs.b	@return	; 0xa1f4
	move.w	d1, (openingTimer1).w	; 0xa1f6
@return:
	rts		; 0xa1fa

displayGameSpeedSelection:
	jsr	($a250, pc)	; 0xa1fc
	lea	LBL_ff706e, a0	; 0xa200
	lea	($a2dc, pc), a1	; 0xa206
	nop		; 0xa20a
	moveq	#6, d3	; 0xa20c
	bsr.b	updateItemInGameModeMenu	; 0xa20e
	move.b	(gameSpeed).w, d0	; 0xa210
	move.w	#$609b, d1	; 0xa214
	lea	LBL_ff70a4, a0	; 0xa218
@loop:
	subq.b	#2, d0	; 0xa21e
	bmi.b	return_458	; 0xa220
	move.w	d1, (a0)+	; 0xa222
	bra.b	@loop	; 0xa224

initGameModeMenu:
	bsr.b	clearTitleScreenTextArea	; 0xa226
	lea	LBL_ff7000, a0	; 0xa228
	lea	($a2a0, pc), a1	; 0xa22e
	nop		; 0xa232
	moveq	#0, d3	; 0xa234
	move.w	#4, d2	; 0xa236
@next:
	bsr.b	updateItemInGameModeMenu	; 0xa23a
	adda.l	#8, a0	; 0xa23c
	bsr.b	updateItemInGameModeMenu	; 0xa242
	adda.l	#$00000030, a0	; 0xa244
	dbf	d2, @next	; 0xa24a

return_458:
	rts		; 0xa24e

clearTitleScreenTextArea:
	lea	LBL_ff7000, a0	; 0xa250
	move.w	(ptrLastUpdatableBgArea).w, a2	; 0xa256
	move.w	#$6b08, (a2)+	; 0xa25a
	move.b	#4, (a2)+	; 0xa25e
	move.b	#$17, (a2)+	; 0xa262
	move.l	a0, (a2)+	; 0xa266
	move.w	a2, (ptrLastUpdatableBgArea).w	; 0xa268
	move.w	#$6080, d0	; 0xa26c
	move.w	#$0077, d1	; 0xa270
@next:
	move.w	d0, (a0)+	; 0xa274
	dbf	d1, @next	; 0xa276
	rts		; 0xa27a

updateItemInGameModeMenu:
	move.w	#9, d1	; 0xa27c
@next:
	move.w	#$6020, d0	; 0xa280
	tst.b	(flashingMenuSelection).w	; 0xa284
	bne.b	@flashing	; 0xa288
	cmp.b	(gameMenuSelection).w, d3	; 0xa28a
	bne.b	@flashing	; 0xa28e
	move.w	#$6000, d0	; 0xa290
@flashing:
	add.b	(a1)+, d0	; 0xa294
	move.w	d0, (a0)+	; 0xa296
	dbf	d1, @next	; 0xa298
	addq.b	#1, d3	; 0xa29c
	rts		; 0xa29e

titleScreenGameModesTextsTilemaps:
	dc.b	$80, $80, $93, $95, $90, $85, $92, $80, $80, $80, $80, $80, $96, $85, $92, $93, $95, $93, $80, $80	; 0xa2a0
	dc.b	$94, $8f, $95, $92, $8e, $81, $8d, $85, $8e, $94, $80, $80, $87, $92, $8f, $95, $90, $80, $80, $80	; 0xa2b4
	dc.b	$83, $88, $81, $8c, $8c, $85, $8e, $87, $85, $80, $80, $80, $8f, $90, $94, $89, $8f, $8e, $80, $80	; 0xa2c8

gameSpeedTilemap:
	dc.b	$87, $81, $8d, $85, $80, $93, $94, $81, $92, $94	; 0xa2dc

openingSceneState12_08_02:
	moveq	#3, d0	; 0xa2e6
	move.b	d0, (startButtonStates).w	; 0xa2e8
	move.b	d0, (LBL_ffff9938).w	; 0xa2ec
	bra.b	selectSuperGameMode	; 0xa2f0

openingSceneState12_08_06:
	moveq	#3, d0	; 0xa2f2
	move.b	d0, (startButtonStates).w	; 0xa2f4
	move.b	d0, (LBL_ffff9943).w	; 0xa2f8
	bra.b	selectSuperGameMode	; 0xa2fc

openingSceneState12_08_04:
	moveq	#3, d0	; 0xa2fe
	move.b	d0, (startButtonStates).w	; 0xa300
	move.b	d0, (LBL_ffff996e).w	; 0xa304
	bra.b	selectSuperGameMode	; 0xa308

openingSceneState12_08_08:
	moveq	#1, d0	; 0xa30a
	btst	#0, (startButtonStates).w	; 0xa30c
	bne.b	@p1_start	; 0xa312
	moveq	#2, d0	; 0xa314
@p1_start:
	move.b	d0, (LBL_ffff99dc).w	; 0xa316
	move.b	#3, (startButtonStates).w	; 0xa31a

selectSuperGameMode:
	move.b	(startButtonStates).w, d2	; 0xa320
	jsr	(clearPlayersDataAndMore).w	; 0xa324
	move.b	d2, (startButtonStates).w	; 0xa328
	lea	(fighter1Data).w, a1	; 0xa32c
	lea	(player_1_).w, a2	; 0xa330
	moveq	#1, d1	; 0xa334
	moveq	#2, d2	; 0xa336
	move.b	(difficulty).w, (copyOfDifficulty).w	; 0xa338
	move.b	(freeTime).w, (copyOfFreeTime).w	; 0xa33e
	move.b	(gameSpeed).w, (copyOfGameSpeed).w	; 0xa344
	tst.b	(areWeOnTitleScreenOrDemoMode).w	; 0xa34a
	bne.b	@not_on_title_screen_or_demo_mode	; 0xa34e
	tst.b	(LBL_ffff99dc).w	; 0xa350
	beq.b	@skip	; 0xa354
@not_on_title_screen_or_demo_mode:
	clr.b	(copyOfGameSpeed).w	; 0xa356
@skip:
	tst.b	(areWeOnTitleScreenOrDemoMode).w	; 0xa35a
	beq.b	@on_title_screen_or_demo_mode	; 0xa35e
	move.b	#3, (startButtonStates).w	; 0xa360
	move.b	d0, (copyOfFreeTime).w	; 0xa366
	tst.b	(LBL_ffff9933).w	; 0xa36a
	bne.b	@on_title_screen_or_demo_mode	; 0xa36e
	move.b	d0, (LBL_ffff9931).w	; 0xa370
	move.b	d0, (copyOfGameSpeed).w	; 0xa374
@on_title_screen_or_demo_mode:
	move.w	a2, (662, a1)	; 0xa378
	move.w	a1, (662, a2)	; 0xa37c
	moveq	#4, d4	; 0xa380
	move.b	d4, (651, a2)	; 0xa382
	move.b	d4, (652, a2)	; 0xa386
	move.b	d1, (641, a2)	; 0xa38a
	move.b	(areWeOnTitleScreenOrDemoMode).w, (copyOfAreWeOnTitleScreenOrDemoMode).w	; 0xa38e
	bne.b	@not_p2	; 0xa394
	btst	d0, (startButtonStates).w	; 0xa396
	beq.b	@not_p1	; 0xa39a
	move.b	d2, (640, a1)	; 0xa39c
	move.b	d2, (642, a1)	; 0xa3a0
	move.b	d1, (648, a1)	; 0xa3a4
@not_p1:
	btst	d1, (startButtonStates).w	; 0xa3a8
	beq.b	@not_p2	; 0xa3ac
	move.b	d2, (640, a2)	; 0xa3ae
	move.b	d2, (642, a2)	; 0xa3b2
	move.b	d1, (648, a2)	; 0xa3b6
@not_p2:
	move.l	(highScoreNamesBuffer).w, (copyOfHighScoreNamesBuffer).w	; 0xa3ba
	move.l	(LBL_fffffcb8).w, (LBL_ffff98e6).w	; 0xa3c0
	tst.b	(LBL_ffff9933).w	; 0xa3c6
	bne.b	@ff9933_set	; 0xa3ca
	move.l	#$0000fee6, a0	; 0xa3cc
	move.w	#$0020, d0	; 0xa3d2
	trap	#0	; 0xa3d6
@ff9933_set:
	move.l	#$0000befa, a0	; 0xa3d8
	move.w	#$0030, d0	; 0xa3de
	trap	#0	; 0xa3e2
	tst.b	(areWeOnTitleScreenOrDemoMode).w	; 0xa3e4
	bne.b	@return	; 0xa3e8
	trap	#1	; 0xa3ea
@return:
	rts		; 0xa3ec

CMD_opening:
	clr.w	(openingState).w	; 0xa3ee
	clr.l	(openingSubState).w	; 0xa3f2

loop_456:
	move.w	(openingState).w, d0	; 0xa3f6
	move.w	(openingStates, pc, d0.w), d1	; 0xa3fa
	jsr	(openingStates, pc, d1.w)	; 0xa3fe
	jsr	(updateBackgroundAndObjects).w	; 0xa402
	jsr	(updateAllSprites).w	; 0xa406
	move.b	#1, d0	; 0xa40a
	trap	#3	; 0xa40e

CMD_0000a410:
	bra.b	loop_456	; 0xa410

openingStates:
	dc.w	openingState00-openingStates	; 0xa412
	dc.w	openingState02-openingStates	; 0xa414
	dc.w	openingState04-openingStates	; 0xa416
	dc.w	openingState06-openingStates	; 0xa418
	dc.w	openingState08-openingStates	; 0xa41a
	dc.w	openingState0a-openingStates	; 0xa41c
	dc.w	openingState0c-openingStates	; 0xa41e

openingState00:
	move.w	(openingSubState).w, d0	; 0xa420
	move.w	(openingState00_Substates, pc, d0.w), d0	; 0xa424
	jmp	(openingState00_Substates, pc, d0.w)	; 0xa428

openingState00_Substates:
	dc.w	openingState00_00-openingState00_Substates	; 0xa42c
	dc.w	openingState00_02-openingState00_Substates	; 0xa42e
	dc.w	openingSubState00_04-openingState00_Substates	; 0xa430
	dc.w	openingState00_06-openingState00_Substates	; 0xa432
	dc.w	openingState00_08-openingState00_Substates	; 0xa434
	dc.w	openingState00_0a-openingState00_Substates	; 0xa436
	dc.w	openingState00_0c-openingState00_Substates	; 0xa438
	dc.w	openingState00_0e-openingState00_Substates	; 0xa43a
	dc.w	openingState00_10-openingState00_Substates	; 0xa43c
	dc.w	openingState00_12-openingState00_Substates	; 0xa43e

openingState00_00:
	addq.w	#2, (openingSubState).w	; 0xa440
	clr.b	(usedByOpeningObject6B).w	; 0xa444
	clr.b	(openingSceneTimer).w	; 0xa448
	jsr	(initDisplay).w	; 0xa44c
	jsr	(clearSatCache).w	; 0xa450
	jsr	(clearPlayersAnd97caData).w	; 0xa454
	lea	($a49a, pc), a0	; 0xa458
	jsr	(transferDataFromPageToRam).w	; 0xa45c
	lea	($a4e4, pc), a0	; 0xa460
	jsr	(loadPalette).w	; 0xa464
	moveq	#0, d4	; 0xa468
@next_object:
	jsr	(getObjectSlot).w	; 0xa46a
	bne.b	@object_list_full	; 0xa46e
	addq.b	#1, (a0)	; 0xa470
	move.b	#$6b, (15, a0)	; 0xa472
	move.b	d4, (16, a0)	; 0xa478
@object_list_full:
	addq.b	#2, d4	; 0xa47c
	cmpi.b	#$10, d4	; 0xa47e
	bne.b	@next_object	; 0xa482
	moveq	#$0011, d0	; 0xa484
	jsr	(selectBgm).w	; 0xa486
	ori.b	#$40, (VdpRegistersCache).w	; 0xa48a
	move.w	(VdpRegistersCache).w, (4, a5)	; 0xa490
	jmp	(fadeInStart).w	; 0xa496
	dc.w	$5880	; nb of bytes	; 0xa49a
	dc.l	openingScreenPtrns_1/2	; source	; 0xa49c
	dc.w	$7780	; destination in VRAM	; 0xa4a0
	; 0x-1
	dc.w	$2000	; nb of bytes	; 0xa4a2
	dc.l	openingScreenTilemap/2	; source	; 0xa4a4
	dc.w	$E000	; destination in VRAM	; 0xa4a8
	; 0x-1
	dc.w	$1A00	; nb of bytes	; 0xa4aa
	dc.l	openingScreenPtrns_2/2	; source	; 0xa4ac
	dc.w	$1000	; destination in VRAM	; 0xa4b0
	; 0x-1
	dc.w	$760	; nb of bytes	; 0xa4b2
	dc.l	openingScreenPtrns_3/2	; source	; 0xa4b4
	dc.w	$2A00	; destination in VRAM	; 0xa4b8
	; 0x-1
	dc.w	$720	; nb of bytes	; 0xa4ba
	dc.l	openingScreenPtrns_4/2	; source	; 0xa4bc
	dc.w	$3200	; destination in VRAM	; 0xa4c0
	; 0x-1
	dc.w	$780	; nb of bytes	; 0xa4c2
	dc.l	openingScreenPtrns_5/2	; source	; 0xa4c4
	dc.w	$3A00	; destination in VRAM	; 0xa4c8
	; 0x-1
	dc.w	$1DE0	; nb of bytes	; 0xa4ca
	dc.l	openingScreenPtrns_6/2	; source	; 0xa4cc
	dc.w	$4200	; destination in VRAM	; 0xa4d0
	; 0x-1
	dc.w	$B20	; nb of bytes	; 0xa4d2
	dc.l	openingScreenPtrns_7/2	; source	; 0xa4d4
	dc.w	$6000	; destination in VRAM	; 0xa4d8
	; 0x-1
	dc.w	$C60	; nb of bytes	; 0xa4da
	dc.l	openingScreenPtrns_8/2	; source	; 0xa4dc
	dc.w	$6B20	; destination in VRAM	; 0xa4e0
	; 0x-1
	dc.w	$0000	; 0xa4e2
	dc.b	$1F	; nb of colors: 63	; 0xa4e4
	dc.b	$00	; first colors: 0x00	; 0xa4e5
	dc.l	openingScreenPalettes/2	; source	; 0xa4e6
	; 0x-1
	dc.w	$0000	; 0xa4ea

openingState00_02:
	cmpi.b	#2, (usedByOpeningObject6B).w	; 0xa4ec
	bne.b	@return00_02	; 0xa4f2
	addq.w	#2, (openingSubState).w	; 0xa4f4
	move.w	#5, (openingTimer2).w	; 0xa4f8
	move.w	#$0104, d0	; 0xa4fe
	move.w	d0, (hScrollCacheA).w	; 0xa502
	move.w	d0, (hScrollCacheB).w	; 0xa506
	move.w	#$0100, d0	; 0xa50a
	move.w	d0, (vsRamCache1).w	; 0xa50e
	move.w	d0, (LBL_ffff9b8c).w	; 0xa512
	jsr	(clearSatCache).w	; 0xa516
	jsr	(clearPlayersAnd97caData).w	; 0xa51a
@return00_02:
	st	(flagProcessHScroll).w	; 0xa51e
	st	(flagProcessVSRAM).w	; 0xa522
	rts		; 0xa526

openingSubState00_04:
	bsr.w	loadOpeningGfx	; 0xa528
	subq.w	#1, (openingTimer2).w	; 0xa52c
	bne.b	@return	; 0xa530
	addq.w	#2, (openingSubState).w	; 0xa532
	move.w	#5, (openingTimer2).w	; 0xa536
	clr.w	(hScrollCacheA).w	; 0xa53c
	clr.w	(hScrollCacheB).w	; 0xa540
	clr.w	(vsRamCache1).w	; 0xa544
	clr.w	(LBL_ffff9b8c).w	; 0xa548
	st	(flagProcessHScroll).w	; 0xa54c
	st	(flagProcessVSRAM).w	; 0xa550
@return:
	rts		; 0xa554

openingState00_06:
	bsr.w	loadOpeningGfx	; 0xa556
	subq.w	#1, (openingTimer2).w	; 0xa55a
	bne.b	@return_00_06	; 0xa55e
	addq.w	#2, (openingSubState).w	; 0xa560
	move.w	#5, (openingTimer2).w	; 0xa564
	clr.w	(hScrollCacheA).w	; 0xa56a
	clr.w	(hScrollCacheB).w	; 0xa56e
	move.w	#$0100, d0	; 0xa572
	move.w	d0, (vsRamCache1).w	; 0xa576
	move.w	d0, (LBL_ffff9b8c).w	; 0xa57a
	st	(flagProcessHScroll).w	; 0xa57e
	st	(flagProcessVSRAM).w	; 0xa582
	moveq	#$0071, d0	; 0xa586
	jsr	(putWordInSfxQueue).w	; 0xa588
@return_00_06:
	rts		; 0xa58c

openingState00_08:
	bsr.w	loadOpeningGfx	; 0xa58e
	subq.w	#1, (openingTimer2).w	; 0xa592
	bne.b	@return	; 0xa596
	addq.w	#2, (openingSubState).w	; 0xa598
	move.w	#$005a, (openingTimer2).w	; 0xa59c
	move.w	#4, (openingSceneTimer).w	; 0xa5a2
	move.w	#$002c, (shakingMainTimer).w	; 0xa5a8
	move.w	#$0014, (COUNTER_ff97c6).w	; 0xa5ae
	move.w	#$0104, d0	; 0xa5b4
	move.w	d0, (hScrollCacheA).w	; 0xa5b8
	move.w	d0, (hScrollCacheB).w	; 0xa5bc
	clr.w	(vsRamCache1).w	; 0xa5c0
	clr.w	(LBL_ffff9b8c).w	; 0xa5c4
	st	(flagProcessHScroll).w	; 0xa5c8
	st	(flagProcessVSRAM).w	; 0xa5cc
	moveq	#0, d0	; 0xa5d0
@next_object_1:
	jsr	(getObjectSlot).w	; 0xa5d2
	bne.b	@no_slot	; 0xa5d6
	addq.b	#1, (a0)	; 0xa5d8
	move.b	#$70, (15, a0)	; 0xa5da
	move.b	d0, (16, a0)	; 0xa5e0
@no_slot:
	addq.b	#2, d0	; 0xa5e4
	cmpi.b	#$0a, d0	; 0xa5e6
	bne.b	@next_object_1	; 0xa5ea
@return:
	rts		; 0xa5ec

openingState00_0a:
	bsr.w	loadOpeningGfx	; 0xa5ee
	tst.w	(openingSceneTimer).w	; 0xa5f2
	beq.b	@skip_1	; 0xa5f6
	subq.w	#1, (openingSceneTimer).w	; 0xa5f8
	bne.b	@skip_1	; 0xa5fc
	move.w	(ptrLastUpdatableBgArea).w, a0	; 0xa5fe
	move.w	#$634e, (a0)+	; 0xa602
	move.b	#6, (a0)+	; 0xa606
	move.b	#8, (a0)+	; 0xa60a
	move.l	#$0000ae00, (a0)+	; 0xa60e
	move.w	a0, (ptrLastUpdatableBgArea).w	; 0xa614
@skip_1:
	tst.w	(shakingMainTimer).w	; 0xa618
	beq.b	@skip_2	; 0xa61c
	subq.w	#1, (shakingMainTimer).w	; 0xa61e
	bne.b	@skip_2	; 0xa622
	move.w	(ptrLastUpdatableBgArea).w, a0	; 0xa624
	move.w	#$6654, (a0)+	; 0xa628
	move.b	#4, (a0)+	; 0xa62c
	move.b	#3, (a0)+	; 0xa630
	move.l	#$0000ae7e, (a0)+	; 0xa634
	move.w	a0, (ptrLastUpdatableBgArea).w	; 0xa63a
@skip_2:
	subq.w	#1, (openingTimer2).w	; 0xa63e
	bne.b	@return	; 0xa642
	jsr	(clearSatCache).w	; 0xa644
	jsr	(clearPlayersAnd97caData).w	; 0xa648
	addq.w	#2, (openingSubState).w	; 0xa64c
	move.w	#$0fff, (rawPalettes).w	; 0xa650
	st	(flagProcessPalettes).w	; 0xa656
@return:
	rts		; 0xa65a

openingState00_0c:
	addq.w	#2, (openingSubState).w	; 0xa65c
	move.w	#2, (openingTimer2).w	; 0xa660
	move.l	#$00000fff, d0	; 0xa666
	lea	(rawPalettes).w, a0	; 0xa66c
	move.w	#$003f, d7	; 0xa670
@next_10:
	move.w	d0, (a0)+	; 0xa674
	dbf	d7, @next_10	; 0xa676
	st	(flagProcessPalettes).w	; 0xa67a
	rts		; 0xa67e

openingState00_0e:
	subq.w	#1, (openingTimer2).w	; 0xa680
	bne.b	@return	; 0xa684
	addq.w	#2, (openingSubState).w	; 0xa686
	move.w	#$00f8, d0	; 0xa68a
	move.w	d0, (hScrollCacheA).w	; 0xa68e
	move.w	d0, (hScrollCacheB).w	; 0xa692
	move.w	#$0100, d0	; 0xa696
	move.w	d0, (vsRamCache1).w	; 0xa69a
	move.w	d0, (LBL_ffff9b8c).w	; 0xa69e
	st	(flagProcessHScroll).w	; 0xa6a2
	st	(flagProcessVSRAM).w	; 0xa6a6
	move.w	#$0172, d0	; 0xa6aa
	jsr	(putWordInSfxQueue).w	; 0xa6ae
@return:
	rts		; 0xa6b2

openingState00_10:
	addq.w	#2, (openingSubState).w	; 0xa6b4
	move.w	#1, (openingTimer2).w	; 0xa6b8
	lea	($a6c6, pc), a0	; 0xa6be
	jmp	(loadPalette).w	; 0xa6c2
	dc.b	$07	; nb of colors: 15	; 0xa6c6
	dc.b	$00	; first colors: 0x00	; 0xa6c7
	dc.l	openingHadokenPalette/2	; source	; 0xa6c8
	; 0x-1
	dc.w	$0000	; 0xa6cc

openingState00_12:
	subq.w	#1, (openingTimer2).w	; 0xa6ce
	bne.b	@return	; 0xa6d2
	addq.w	#2, (openingState).w	; 0xa6d4
	clr.w	(openingSubState).w	; 0xa6d8
@return:
	rts		; 0xa6dc

loadOpeningGfx:
	move.w	(openingTimer2).w, d0	; 0xa6de
	subq.w	#1, d0	; 0xa6e2
	cmpi.w	#5, d0	; 0xa6e4
	bge.b	@return	; 0xa6e8
	move.w	(openingSubState).w, d1	; 0xa6ea
	subq.w	#4, d1	; 0xa6ee
	move.w	(openingGfx, pc, d1.w), d1	; 0xa6f0
	lsl.w	#3, d0	; 0xa6f4
	add.w	d1, d0	; 0xa6f6
	lea	(openingGfx, pc, d0.w), a0	; 0xa6f8
	jmp	(transferDataToVramDMA).w	; 0xa6fc
@return:
	rts		; 0xa700

openingGfx:
	dc.w	openingGfx00-openingGfx	; 0xa702
	dc.w	openingGfx01-openingGfx	; 0xa704
	dc.w	openingGfx02-openingGfx	; 0xa706
	dc.w	openingGfx03-openingGfx	; 0xa708

openingGfx00:
	dc.w	$0400	; length in words	; 0xa70a
	dc.l	PATTERNS_3aefc0/2	; source	; 0xa70c
	dc.w	$e000	; dest	; 0xa710
	; 0x-1
	dc.w	$0400	; length in words	; 0xa712
	dc.l	PATTERNS_3af7c0/2	; source	; 0xa714
	dc.w	$e800	; dest	; 0xa718
	; 0x-1
	dc.w	$0400	; length in words	; 0xa71a
	dc.l	PATTERNS_3a5b60/2	; source	; 0xa71c
	dc.w	$2a00	; dest	; 0xa720
	; 0x-1
	dc.w	$0410	; length in words	; 0xa722
	dc.l	PATTERNS_3a6360/2	; source	; 0xa724
	dc.w	$3200	; dest	; 0xa728
	; 0x-1
	dc.w	$0500	; length in words	; 0xa72a
	dc.l	PATTERNS_3a6b80/2	; source	; 0xa72c
	dc.w	$4000	; dest	; 0xa730
	; 0x-1

openingGfx01:
	dc.w	$0400	; length in words	; 0xa732
	dc.l	PATTERNS_3affc0/2	; source	; 0xa734
	dc.w	$f000	; dest	; 0xa738
	; 0x-1
	dc.w	$0400	; length in words	; 0xa73a
	dc.l	PATTERNS_3b07c0/2	; source	; 0xa73c
	dc.w	$f800	; dest	; 0xa740
	; 0x-1
	dc.w	$0500	; length in words	; 0xa742
	dc.l	PATTERNS_3a7580/2	; source	; 0xa744
	dc.w	$4a00	; dest	; 0xa748
	; 0x-1
	dc.w	$0500	; length in words	; 0xa74a
	dc.l	PATTERNS_3a7f80/2	; source	; 0xa74c
	dc.w	$5400	; dest	; 0xa750
	; 0x-1
	dc.w	$03D0	; length in words	; 0xa752
	dc.l	PATTERNS_3a8980/2	; source	; 0xa754
	dc.w	$5e00	; dest	; 0xa758
	; 0x-1

openingGfx02:
	dc.w	$03C0	; length in words	; 0xa75a
	dc.l	PATTERNS_3ab920/2	; source	; 0xa75c
	dc.w	$3800	; dest	; 0xa760
	; 0x-1
	dc.w	$0500	; length in words	; 0xa762
	dc.l	PATTERNS_3a9120/2	; source	; 0xa764
	dc.w	$1000	; dest	; 0xa768
	; 0x-1
	dc.w	$0500	; length in words	; 0xa76a
	dc.l	PATTERNS_3a9b20/2	; source	; 0xa76c
	dc.w	$1a00	; dest	; 0xa770
	; 0x-1
	dc.w	$0500	; length in words	; 0xa772
	dc.l	PATTERNS_3aa520/2	; source	; 0xa774
	dc.w	$2400	; dest	; 0xa778
	; 0x-1
	dc.w	$0500	; length in words	; 0xa77a
	dc.l	PATTERNS_3aaf20/2	; source	; 0xa77c
	dc.w	$2e00	; dest	; 0xa780
	; 0x-1

openingGfx03:
	dc.w	$0390	; length in words	; 0xa782
	dc.l	PATTERNS_3ae8a0/2	; source	; 0xa784
	dc.w	$6800	; dest	; 0xa788
	; 0x-1
	dc.w	$0500	; length in words	; 0xa78a
	dc.l	PATTERNS_3ac0a0/2	; source	; 0xa78c
	dc.w	$4000	; dest	; 0xa790
	; 0x-1
	dc.w	$0500	; length in words	; 0xa792
	dc.l	PATTERNS_3acaa0/2	; source	; 0xa794
	dc.w	$4a00	; dest	; 0xa798
	; 0x-1
	dc.w	$0500	; length in words	; 0xa79a
	dc.l	PATTERNS_3ad4a0/2	; source	; 0xa79c
	dc.w	$5400	; dest	; 0xa7a0
	; 0x-1
	dc.w	$0500	; length in words	; 0xa7a2
	dc.l	PATTERNS_3adea0/2	; source	; 0xa7a4
	dc.w	$5e00	; dest	; 0xa7a8
	; 0x-1

openingState02:
	addq.w	#2, (openingState).w	; 0xa7aa
	clr.l	(openingSubState).w	; 0xa7ae
	move.w	#$0222, (openingFadingValue).w	; 0xa7b2
	move.b	#7, (openingTimer2).w	; 0xa7b8
	move.b	#8, (openingSceneTimer).w	; 0xa7be
	rts		; 0xa7c4

openingState04:
	move.w	(openingSubState).w, d0	; 0xa7c6
	move.w	(openingState04_Substates, pc, d0.w), d1	; 0xa7ca
	jmp	(openingState04_Substates, pc, d1.w)	; 0xa7ce

openingState04_Substates:
	dc.w	openingState04_00-openingState04_Substates	; 0xa7d2
	dc.w	openingState04_02-openingState04_Substates	; 0xa7d4
	dc.w	openingState04_04-openingState04_Substates	; 0xa7d6

openingState04_00:
	subq.b	#1, (openingSceneTimer).w	; 0xa7d8
	bne.b	@return	; 0xa7dc
	move.b	#8, (openingSceneTimer).w	; 0xa7de
	lea	(rawPalettes).w, a0	; 0xa7e4
	move.w	(openingFadingValue).w, d0	; 0xa7e8
	move.w	#$003f, d1	; 0xa7ec
	jsr	fadePalette	; 0xa7f0
	st	(flagProcessPalettes).w	; 0xa7f6
	subq.b	#1, (openingTimer2).w	; 0xa7fa
	bne.b	@return	; 0xa7fe
	andi.b	#$bf, (VdpRegistersCache).w	; 0xa800
	move.w	(VdpRegistersCache).w, (4, a5)	; 0xa806
	addq.w	#2, (openingSubState).w	; 0xa80c
@return:
	rts		; 0xa810

openingState04_02:
	tst.w	(LBL_ffffbbc0).w	; 0xa812
	bne.w	@white	; 0xa816
	jsr	(clearSatCache).w	; 0xa81a
	bsr.w	openingInitScroll	; 0xa81e
	bsr.w	updateTitleScreen	; 0xa822
	lea	($ac3c, pc), a0	; 0xa826
	jsr	(transferDataFromPageToRam).w	; 0xa82a
	jsr	($af4e, pc)	; 0xa82e
	move.b	#$3c, (openingTimer2).w	; 0xa832
	addq.w	#2, (LBL_ffffbbc0).w	; 0xa838
	rts		; 0xa83c
@white:
	subq.b	#1, (openingTimer2).w	; 0xa83e
	bne.b	@return_04_02	; 0xa842
	move.w	#$0eee, (openingFadingValue).w	; 0xa844
	move.b	#8, (openingTimer2).w	; 0xa84a
	addq.w	#2, (openingSubState).w	; 0xa850
	clr.w	(LBL_ffffbbc0).w	; 0xa854
	ori.b	#$40, (VdpRegistersCache).w	; 0xa858
	move.w	(VdpRegistersCache).w, (4, a5)	; 0xa85e
@return_04_02:
	rts		; 0xa864

openingState04_04:
	subq.b	#1, (openingTimer2).w	; 0xa866
	bne.b	@return	; 0xa86a
	move.b	#8, (openingTimer2).w	; 0xa86c
	lea	($ac6c, pc), a0	; 0xa872
	jsr	(loadPalette).w	; 0xa876
	lea	(rawPalettes).w, a0	; 0xa87a
	move.w	(openingFadingValue).w, d0	; 0xa87e
	move.w	#$000f, d1	; 0xa882
	jsr	fadePalette	; 0xa886
	subi.w	#$0222, (openingFadingValue).w	; 0xa88c
	bpl.b	@return	; 0xa892
	move.b	#$3c, (openingTimer2).w	; 0xa894
	move.w	#$0100, (hScrollCacheA).w	; 0xa89a
	st	(flagProcessHScroll).w	; 0xa8a0
	addq.w	#2, (openingState).w	; 0xa8a4
	clr.l	(openingSubState).w	; 0xa8a8
@return:
	rts		; 0xa8ac

openingState06:
	move.w	(openingSubState).w, d0	; 0xa8ae
	move.w	(openingState06_Substates, pc, d0.w), d1	; 0xa8b2
	jmp	(openingState06_Substates, pc, d1.w)	; 0xa8b6

openingState06_Substates:
	dc.w	openingState06_00-openingState06_Substates	; 0xa8ba
	dc.w	openingState06_02-openingState06_Substates	; 0xa8bc
	dc.w	openingState06_04-openingState06_Substates	; 0xa8be
	dc.w	openingState06_06-openingState06_Substates	; 0xa8c0

openingState06_00:
	subq.b	#1, (openingTimer2).w	; 0xa8c2
	bne.b	@return	; 0xa8c6
	move.l	#$0000aea6, a0	; 0xa8c8
	move.w	#$0030, d0	; 0xa8ce
	trap	#0	; 0xa8d2
	move.b	#$3c, (openingTimer2).w	; 0xa8d4
	move.w	#$0eee, (openingFadingValue).w	; 0xa8da
	addq.w	#2, (openingSubState).w	; 0xa8e0
@return:
	rts		; 0xa8e4

openingState06_02:
	subq.b	#1, (openingTimer2).w	; 0xa8e6
	bne.b	@return	; 0xa8ea
	bsr.b	titleScreenloadSuperPalette	; 0xa8ec
	jsr	(getObjectSlot).w	; 0xa8ee
	bne.b	@next_substate	; 0xa8f2
	addq.b	#1, (a0)	; 0xa8f4
	move.b	#$11, (15, a0)	; 0xa8f6
	move.b	(counterMod16).w, d0	; 0xa8fc
	andi.b	#1, d0	; 0xa900
	move.b	d0, (16, a0)	; 0xa904
@next_substate:
	addq.w	#2, (openingSubState).w	; 0xa908
@return:
	rts		; 0xa90c

openingState06_04:
	bsr.b	titleScreenloadSuperPalette	; 0xa90e
	subi.w	#$0222, (openingFadingValue).w	; 0xa910
	bpl.b	return_459	; 0xa916
	move.b	#$69, (openingTimer2).w	; 0xa918
	addq.w	#2, (openingSubState).w	; 0xa91e

return_459:
	rts		; 0xa922

titleScreenloadSuperPalette:
	lea	($ac74, pc), a0	; 0xa924
	btst	#0, (counterMod16).w	; 0xa928
	beq.b	@load_palette	; 0xa92e
	lea	($ac7c, pc), a0	; 0xa930
@load_palette:
	jsr	(loadPalette).w	; 0xa934
	lea	(rawPalettes).w, a0	; 0xa938
	move.w	(openingFadingValue).w, d0	; 0xa93c
	move.w	#$000f, d1	; 0xa940
	jmp	FUN_00013a30	; 0xa944

openingState06_06:
	subq.b	#1, (openingTimer2).w	; 0xa94a
	bne.b	return_459	; 0xa94e
	addq.w	#2, (openingState).w	; 0xa950
	clr.l	(openingSubState).w	; 0xa954
	move.w	#$000c, (sf2LogoSpritesTimer).w	; 0xa958

openingState08:
	bsr.w	displaySf2LogoSprites	; 0xa95e
	subq.w	#1, (sf2LogoSpritesTimer).w	; 0xa962
	bne.b	@return	; 0xa966
	addq.w	#1, (sf2LogoSpritesTimer).w	; 0xa968
	move.w	#$0173, d0	; 0xa96c
	jsr	(putWordInSfxQueue).w	; 0xa970
	addq.w	#2, (openingState).w	; 0xa974
@return:
	rts		; 0xa978

openingState0a:
	bsr.w	displaySf2LogoSprites	; 0xa97a
	tst.w	(openingSubState).w	; 0xa97e
	bne.b	openingState0a_02	; 0xa982
	moveq	#3, d1	; 0xa984
@next_object:
	jsr	(getObjectSlot).w	; 0xa986
	bne.b	@no_more_slot	; 0xa98a
	addq.b	#1, (a0)	; 0xa98c
	move.b	#$18, (15, a0)	; 0xa98e
	move.b	d1, (16, a0)	; 0xa994
	dbf	d1, @next_object	; 0xa998
@no_more_slot:
	clr.w	(posInTheNewChallengersTilemaps).w	; 0xa99c
	move.w	#$691e, (theNewChallengersPosLeft).w	; 0xa9a0
	move.w	#$6920, (theNewChallengersPosRight).w	; 0xa9a6
	move.b	#1, (openingTimer2).w	; 0xa9ac
	addq.w	#2, (openingSubState).w	; 0xa9b2
	lea	dataBuffer, a2	; 0xa9b6
	bsr.b	updateTheNewChallengersTilemaps	; 0xa9bc
	bra.b	updateTheNewChallengersTilemaps	; 0xa9be

openingState0a_02:
	subq.b	#1, (openingTimer2).w	; 0xa9c0
	bne.b	@return	; 0xa9c4
	move.b	#2, (openingTimer2).w	; 0xa9c6
	lea	dataBuffer, a2	; 0xa9cc
	bsr.b	updateTheNewChallengersTilemaps	; 0xa9d2
	cmpi.b	#$2a, d0	; 0xa9d4
	bne.b	@return	; 0xa9d8
	jsr	(getObjectSlot).w	; 0xa9da
	bne.b	@no_more_slot_2	; 0xa9de
	addq.b	#1, (a0)	; 0xa9e0
	move.b	#$15, (15, a0)	; 0xa9e2
@no_more_slot_2:
	addq.w	#2, (openingState).w	; 0xa9e8
	clr.l	(openingSubState).w	; 0xa9ec
@return:
	rts		; 0xa9f0

updateTheNewChallengersTilemaps:
	lea	($adac, pc), a1	; 0xa9f2
	nop		; 0xa9f6
	move.w	(theNewChallengersPosLeft).w, d1	; 0xa9f8
	bsr.b	updateTheNewChallengersTilemap	; 0xa9fc
	lea	($add6, pc), a1	; 0xa9fe
	nop		; 0xaa02
	move.w	(theNewChallengersPosRight).w, d1	; 0xaa04
	bsr.b	updateTheNewChallengersTilemap	; 0xaa08
	subq.w	#2, (theNewChallengersPosLeft).w	; 0xaa0a
	addq.w	#2, (theNewChallengersPosRight).w	; 0xaa0e
	move.w	d0, (posInTheNewChallengersTilemaps).w	; 0xaa12
	rts		; 0xaa16

updateTheNewChallengersTilemap:
	move.w	(ptrLastUpdatableBgArea).w, a0	; 0xaa18
	move.w	d1, (a0)+	; 0xaa1c
	move.b	#2, (a0)+	; 0xaa1e
	move.b	#0, (a0)+	; 0xaa22
	move.l	a2, (a0)+	; 0xaa26
	move.w	a0, (ptrLastUpdatableBgArea).w	; 0xaa28
	moveq	#2, d1	; 0xaa2c
	move.w	(posInTheNewChallengersTilemaps).w, d0	; 0xaa2e
@next:
	move.b	#$42, (a2)+	; 0xaa32
	move.b	(0, a1, d0), (a2)+	; 0xaa36
	addq.w	#1, d0	; 0xaa3a
	dbf	d1, @next	; 0xaa3c
	rts		; 0xaa40

openingState0c:
	bsr.w	displaySf2LogoSprites	; 0xaa42
	tst.w	(openingSubState).w	; 0xaa46
	bne.b	openingState0c_02	; 0xaa4a
	lea	($acdc, pc), a0	; 0xaa4c
	jsr	(loadBgAreas).w	; 0xaa50
	addq.w	#2, (openingSubState).w	; 0xaa54

openingState0c_02:
	rts		; 0xaa58

FUN_0000aa5a:
	lea	($afa6, pc), a0	; 0xaa5a
	jsr	(loadPalette).w	; 0xaa5e
	lea	(paletteBuffers).w, a0	; 0xaa62
	move.w	(openingFadingValue).w, d0	; 0xaa66
	move.w	#$000a, d1	; 0xaa6a
	rts		; 0xaa6e
	bsr.b	FUN_0000aa5a	; 0xaa70
	jmp	fadePalette	; 0xaa72
	bsr.b	FUN_0000aa5a	; 0xaa78
	jmp	FUN_00013a30	; 0xaa7a

openingInitScroll:
	clr.l	(hScrollCacheA).w	; 0xaa80
	move.l	#$000000f0, d0	; 0xaa84
	btst	#0, (counterMod16).w	; 0xaa8a
	beq.b	@skip	; 0xaa90
	move.l	#$00000100, d0	; 0xaa92
@skip:
	move.l	d0, (vsRamCache1).w	; 0xaa98
	st	(flagProcessHScroll).w	; 0xaa9c
	st	(flagProcessVSRAM).w	; 0xaaa0
	rts		; 0xaaa4

clearAllPalettes:
	lea	(rawPalettes).w, a0	; 0xaaa6
	moveq	#0, d0	; 0xaaaa
	move.w	#$001f, d1	; 0xaaac
@next:
	move.l	d0, (a0)+	; 0xaab0
	dbf	d1, @next	; 0xaab2
	rts		; 0xaab6

updateGameStartScreen:
	bsr.b	openingInitScroll	; 0xaab8
	bsr.w	updateTitleScreen	; 0xaaba
	lea	($ac84, pc), a0	; 0xaabe
	jsr	(loadPalette).w	; 0xaac2
	lea	($ac74, pc), a0	; 0xaac6
	btst	#0, (counterMod16).w	; 0xaaca
	beq.b	@normal_palette	; 0xaad0
	lea	($ac7c, pc), a0	; 0xaad2
@normal_palette:
	jsr	(loadPalette).w	; 0xaad6
	lea	LBL_ff5000, a0	; 0xaada
	lea	LBL_ff6000, a1	; 0xaae0
	lea	smallFontPtrns, a2	; 0xaae6
	move.w	#$05ff, d0	; 0xaaec
	jsr	loadBicolorPtrns	; 0xaaf0
	lea	($ac4e, pc), a0	; 0xaaf6
	jsr	(transferDataToVramDMA).w	; 0xaafa
	lea	($ac56, pc), a0	; 0xaafe
	jsr	(transferDataToVramDMA).w	; 0xab02
	jsr	(getObjectSlot).w	; 0xab06
	bne.b	@no_more_slot	; 0xab0a
	addq.b	#1, (a0)	; 0xab0c
	move.b	#$11, (15, a0)	; 0xab0e
	move.b	(counterMod16).w, d0	; 0xab14
	andi.b	#1, d0	; 0xab18
	move.b	d0, (16, a0)	; 0xab1c
	jsr	(getObjectSlot).w	; 0xab20
	bne.b	@no_more_slot	; 0xab24
	addq.b	#1, (a0)	; 0xab26
	move.b	#$15, (15, a0)	; 0xab28
@no_more_slot:
	move.w	#1, (sf2LogoSpritesTimer).w	; 0xab2e
	bsr.b	displaySf2LogoSprites	; 0xab34
	lea	($ad44, pc), a0	; 0xab36
	jmp	(loadBgAreas).w	; 0xab3a

updateTitleScreen:
	lea	($abde, pc), a0	; 0xab3e
	jsr	(transferDataFromPageToRam).w	; 0xab42
	lea	($ac5e, pc), a0	; 0xab46
	jsr	(loadPalette).w	; 0xab4a
	btst	#0, (counterMod16).w	; 0xab4e
	bne.b	@normal_patterns	; 0xab54
	lea	($ac18, pc), a0	; 0xab56
	jmp	(transferDataFromPageToRam).w	; 0xab5a
@normal_patterns:
	lea	($ac2a, pc), a0	; 0xab5e
	jmp	(transferDataFromPageToRam).w	; 0xab62

displaySf2LogoSprites:
	move.w	(ptrCurrentSpriteInSatBuffer).w, a0	; 0xab66
	lea	($ac8c, pc), a1	; 0xab6a
	nop		; 0xab6e
	lea	($acb4, pc), a2	; 0xab70
	nop		; 0xab74
	move.w	#$0a00, d0	; 0xab76
	move.b	(currentSpriteLink).w, d0	; 0xab7a
	move.w	#$00f4, d3	; 0xab7e
	move.w	#$00c8, d4	; 0xab82
	move.w	#$a400, d5	; 0xab86
	move.w	#$0027, d6	; 0xab8a
@next_sprite:
	move.b	(a1)+, d1	; 0xab8e
	ext.w	d1	; 0xab90
	muls.w	(sf2LogoSpritesTimer).w, d1	; 0xab92
	add.w	d3, d1	; 0xab96
	cmpi.w	#$0068, d1	; 0xab98
	bcs.b	@lt_68_or_gt_180	; 0xab9c
	cmpi.w	#$0180, d1	; 0xab9e
	bcc.b	@lt_68_or_gt_180	; 0xaba2
	move.b	(a2)+, d2	; 0xaba4
	ext.w	d2	; 0xaba6
	muls.w	(sf2LogoSpritesTimer).w, d2	; 0xaba8
	add.w	d4, d2	; 0xabac
	cmpi.w	#$0068, d2	; 0xabae
	bcs.b	@lt_68_or_gt_180_2	; 0xabb2
	cmpi.w	#$0180, d2	; 0xabb4
	bcc.b	@lt_68_or_gt_180_2	; 0xabb8
@load_sprite:
	move.w	d2, (a0)+	; 0xabba
	addq.b	#1, d0	; 0xabbc
	move.w	d0, (a0)+	; 0xabbe
	move.w	d5, (a0)+	; 0xabc0
	addi.w	#9, d5	; 0xabc2
	move.w	d1, (a0)+	; 0xabc6
	dbf	d6, @next_sprite	; 0xabc8
	move.b	d0, (currentSpriteLink).w	; 0xabcc
	move.w	a0, (ptrCurrentSpriteInSatBuffer).w	; 0xabd0
	rts		; 0xabd4
@lt_68_or_gt_180:
	move.b	(a2)+, d2	; 0xabd6
@lt_68_or_gt_180_2:
	moveq	#0, d1	; 0xabd8
	move.l	d1, d2	; 0xabda
	bra.b	@load_sprite	; 0xabdc
	dc.w	$F80	; nb of bytes	; 0xabde
	dc.l	titleScreenPatterns01/2	; source	; 0xabe0
	dc.w	$2000	; destination in VRAM	; 0xabe4
	; 0x-1
	dc.w	$1000	; nb of bytes	; 0xabe6
	dc.l	titleScreenMap/2	; source	; 0xabe8
	dc.w	$E000	; destination in VRAM	; 0xabec
	; 0x-1
	dc.w	$7E0	; nb of bytes	; 0xabee
	dc.l	titleScreenPatterns02/2	; source	; 0xabf0
	dc.w	$4000	; destination in VRAM	; 0xabf4
	; 0x-1
	dc.w	$1820	; nb of bytes	; 0xabf6
	dc.l	titleScreenPatterns03/2	; source	; 0xabf8
	dc.w	$47E0	; destination in VRAM	; 0xabfc
	; 0x-1
	dc.w	$2000	; nb of bytes	; 0xabfe
	dc.l	titleScreenPatterns04/2	; source	; 0xac00
	dc.w	$8000	; destination in VRAM	; 0xac04
	; 0x-1
	dc.w	$D00	; nb of bytes	; 0xac06
	dc.l	titleScreenPatterns05/2	; source	; 0xac08
	dc.w	$A000	; destination in VRAM	; 0xac0c
	; 0x-1
	dc.w	$F00	; nb of bytes	; 0xac0e
	dc.l	titleScreenPatterns06/2	; source	; 0xac10
	dc.w	$AE00	; destination in VRAM	; 0xac14
	; 0x-1
	dc.w	$0000	; 0xac16
	dc.w	$1080	; nb of bytes	; 0xac18
	dc.l	titleScreenPatterns07/2	; source	; 0xac1a
	dc.w	$2F80	; destination in VRAM	; 0xac1e
	; 0x-1
	dc.w	$1000	; nb of bytes	; 0xac20
	dc.l	titleScreenPatterns08/2	; source	; 0xac22
	dc.w	$F000	; destination in VRAM	; 0xac26
	; 0x-1
	dc.w	$0000	; 0xac28
	dc.w	$780	; nb of bytes	; 0xac2a
	dc.l	titleScreenPatterns09/2	; source	; 0xac2c
	dc.w	$2F80	; destination in VRAM	; 0xac30
	; 0x-1
	dc.w	$1000	; nb of bytes	; 0xac32
	dc.l	titleScreenPatterns10/2	; source	; 0xac34
	dc.w	$F000	; destination in VRAM	; 0xac38
	; 0x-1
	dc.w	$0000	; 0xac3a
	dc.w	$200	; nb of bytes	; 0xac3c
	dc.l	titleScreenPatterns11/2	; source	; 0xac3e
	dc.w	$1C00	; destination in VRAM	; 0xac42
	; 0x-1
	dc.w	$600	; nb of bytes	; 0xac44
	dc.l	smallFontPtrns/2	; source	; 0xac46
	dc.w	$1000	; destination in VRAM	; 0xac4a
	; 0x-1
	dc.w	$0000	; 0xac4c

lightSmallFontPatternsLoader:
	dc.w	$0200	; length in words	; 0xac4e
	dc.l	LBL_ff5000/2	; source	; 0xac50
	dc.w	$1000	; dest	; 0xac54
	; 0x-1

darkSmallFontPatternsLoader:
	dc.w	$0200	; length in words	; 0xac56
	dc.l	LBL_ff6000/2	; source	; 0xac58
	dc.w	$1400	; dest	; 0xac5c
	; 0x-1
	dc.b	$07	; nb of colors: 15	; 0xac5e
	dc.b	$20	; first colors: 0x10	; 0xac5f
	dc.l	openingTitlePalettes/2	; source	; 0xac60
	; 0x-1
	dc.b	$07	; nb of colors: 15	; 0xac64
	dc.b	$40	; first colors: 0x20	; 0xac65
	dc.l	PALETTE_3a3ae0/2	; source	; 0xac66
	; 0x-1
	dc.w	$0000	; 0xac6a
	dc.b	$07	; nb of colors: 15	; 0xac6c
	dc.b	$00	; first colors: 0x00	; 0xac6d
	dc.l	PALETTE_003a3800/2	; source	; 0xac6e
	; 0x-1
	dc.w	$0000	; 0xac72

titleScreenPalette00Loader:
	dc.b	$07	; nb of colors: 15	; 0xac74
	dc.b	$00	; first colors: 0x00	; 0xac75
	dc.l	titleScreenPalette00/2	; source	; 0xac76
	; 0x-1
	dc.w	$0000	; 0xac7a

titleScreenPalette00AltLoader:
	dc.b	$07	; nb of colors: 15	; 0xac7c
	dc.b	$00	; first colors: 0x00	; 0xac7d
	dc.l	titleScreenPalette00Alt/2	; source	; 0xac7e
	; 0x-1
	dc.w	$0000	; 0xac82

titleScreenPalette03Loader:
	dc.b	$07	; nb of colors: 15	; 0xac84
	dc.b	$60	; first colors: 0x30	; 0xac85
	dc.l	titleScreenPalette03/2	; source	; 0xac86
	; 0x-1
	dc.w	$0000	; 0xac8a

sf2LogoSpritesDx:
	dc.b	$f4, $0c, $24, $3c, $ac, $c4, $dc, $f4, $0c, $24, $3c, $54, $ac, $c4, $dc, $f4, $0c, $24, $3c, $54, $ac, $c4, $dc, $f4, $0c, $24, $3c, $54, $6c, $ac, $c4, $dc, $f4, $0c, $24, $3c, $54, $ac, $c4, $dc	; 0xac8c

sf2LogoSpritesDy:
	dc.b	$c4, $c4, $c4, $c4, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $f4, $f4, $f4, $f4, $f4, $f4, $f4, $f4, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $24, $24, $24, $24, $24, $24, $24, $24, $3c, $3c, $3c	; 0xacb4

copyrightTextsTilemaps:
	dc.b	19	; length - 1	; 0xacdc
	dc.b	$60; upper byte	; 0xacde
	dc.w	$6b0a; write to 0xeb0a	; 0xace0
	dc.b	$80,$ad,$80,$83,$81,$90,$83,$8f,$8d,$80,$a1,$a9,$a9,$a1,$ab,$a9,$a3,$ab,$a9,$a4	; 0xace0
	dc.b	28	; length - 1	; 0xacf4
	dc.b	$60; upper byte	; 0xacf6
	dc.w	$6b82; write to 0xeb82	; 0xacf8
	dc.b	$ad,$80,$83,$81,$90,$83,$8f,$8d,$80,$95,$aa,$93,$aa,$81,$aa,$89,$8e,$83,$aa,$a1,$a9,$a9,$a1,$ab,$a9,$a3,$ab,$a9,$a4	; 0xacf8
	dc.b	$0a	; 0xad15
	dc.b	96	; length - 1	; 0xad16
	dc.b	$6c; upper byte	; 0xad18
	dc.w	$148c; write to 0xd48c	; 0xad1a
	dc.b	$89,$83,$85,$8e,$93,$85,$84,$80,$82,$99,$14,$60,$6c,$8a,$93,$85,$87,$81,$80,$85,$8e,$94,$85,$92,$90,$92,$89,$93,$85,$93,$80,$8c,$94,$84,$9c,$01,$60,$61,$b8,$94,$8d,$00,$1b,$c2,$69,$04,$00,$01,$02,$0a,$0a,$0a,$03,$04,$0a,$0a,$0a,$0a,$0a,$05,$06,$07,$0a,$0a,$08,$09,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$1b,$c2,$69,$84,$0b,$0c,$0d,$0e,$0f,$3e,$10,$11,$12,$13,$14,$15,$3e,$16,$17,$18,$19,$1a,$1b	; 0xad1a
	dc.b	$1c	; 0xad7b
	dc.b	$1d, $1e, $1f, $20, $21, $22, $23, $24, $1b, $c2, $6a, $04, $25, $26, $27, $28, $29, $3e, $2a, $2b, $2c, $2d, $2e, $3e, $3e, $2f, $30, $31	; 0xad7c
	dc.b	$32, $33, $34, $35, $36, $37, $38, $39, $3a, $3b, $3c, $3d, $01, $60, $61, $b8, $94, $8d, $00, $80, $05, $16, $2f, $0a, $3e, $3e, $0a, $15	; 0xad98
	dc.b	$3e, $0a, $14, $2e, $0a, $13, $2d, $0a, $12, $2c, $04, $11, $2b, $03, $10, $2a, $0a, $3e, $3e, $0a, $0f, $29, $0a, $0e, $28, $02, $0d, $27, $01, $0c, $26, $00, $0b, $25, $06, $17, $30, $07, $18, $31, $0a, $19	; 0xadb4
	dc.b	$32, $0a, $1a, $33, $08, $1b, $34, $09, $1c, $35, $0a, $1d, $36, $0a, $1e, $37, $0a, $1f, $38, $0a, $20, $39, $0a, $21, $3a, $0a, $22, $3b, $0a, $23, $3c, $0a, $24, $3d, $00, $00, $00, $00, $00, $00, $00, $00	; 0xadde
	dc.w	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0080, $0081, $0082, $4083, $4084, $2085, $0000, $0000, $0089, $008a, $008b, $008c, $408d, $408e, $208f, $0000, $0094, $0095, $0096, $0097, $0098, $4099, $409a, $409b, $0000, $00a0, $00a1, $00a2, $00a3, $00a4, $00a5, $40a6, $40a7, $0000, $0000, $00ae, $00af, $00b0, $00b1, $00b2, $00b3, $40b4, $0000, $0000, $00ba, $20bb, $20bc, $00bd, $00be, $00bf, $40c0, $01e2, $01e3, $01e4, $01e5	; 0xae08
	dc.w	$01e6, $01e7, $01e8, $01e9, $01ea, $01eb, $01ec, $01ed, $20e8, $01ee, $01ef, $01f0, $20f9, $01f1, $01f2, $01f3, $4278, $bbcc, $4238, $bbd0	; 0xae86
	move.b	#1, (LBL_ffffbbce).w	; 0xaeae
	move.b	#$20, (LBL_ffffbbcf).w	; 0xaeb4
@loop:
	move.w	(titleScreenState).w, d0	; 0xaeba
	move.w	(titleScreenStates, pc, d0.w), d1	; 0xaebe
	jsr	(titleScreenStates, pc, d1.w)	; 0xaec2
	move.b	#1, d0	; 0xaec6
	trap	#3	; 0xaeca
	bra.b	@loop	; 0xaecc

titleScreenStates:
	dc.w	titleScreenState00-titleScreenStates	; 0xaece
	dc.w	titleScreenState02-titleScreenStates	; 0xaed0
	dc.w	titleScreenState04-titleScreenStates	; 0xaed2

titleScreenState00:
	subq.b	#1, (LBL_ffffbbce).w	; 0xaed4
	bne.b	@return	; 0xaed8
	move.b	#3, (LBL_ffffbbce).w	; 0xaeda
	bsr.w	titleScreenClearPalette01	; 0xaee0
	moveq	#0, d0	; 0xaee4
	move.b	(LBL_ffffbbd0).w, d0	; 0xaee6
	lea	(paletteBuffers).w, a0	; 0xaeea
	adda.l	d0, a0	; 0xaeee
	move.l	#$003a3840, a1	; 0xaef0
	move.l	(a1)+, (a0)+	; 0xaef6
	move.l	(a1)+, (a0)+	; 0xaef8
	addq.b	#8, d0	; 0xaefa
	cmpi.b	#$20, d0	; 0xaefc
	bne.b	@not_20	; 0xaf00
	moveq	#0, d0	; 0xaf02
@not_20:
	move.b	d0, (LBL_ffffbbd0).w	; 0xaf04
	addq.w	#2, (titleScreenState).w	; 0xaf08
@return:
	rts		; 0xaf0c

titleScreenState02:
	subq.b	#1, (LBL_ffffbbce).w	; 0xaf0e
	bne.b	@return	; 0xaf12
	moveq	#$0074, d0	; 0xaf14
	jsr	(putWordInSfxQueue).w	; 0xaf16
	move.b	#1, (LBL_ffffbbce).w	; 0xaf1a
	clr.w	(titleScreenState).w	; 0xaf20
	bsr.b	titleScreenClearPalette01	; 0xaf24
	subq.b	#1, (LBL_ffffbbcf).w	; 0xaf26
	bne.b	@return	; 0xaf2a
	lea	($afa6, pc), a0	; 0xaf2c
	jsr	(loadPalette).w	; 0xaf30
	clr.w	(hScrollCacheA).w	; 0xaf34
	st	(flagProcessHScroll).w	; 0xaf38
	move.b	#1, (LBL_ffffbbd1).w	; 0xaf3c
	clr.b	(titlescreenLightningIndex).w	; 0xaf42
	move.w	#4, (titleScreenState).w	; 0xaf46
@return:
	rts		; 0xaf4c

titleScreenClearPalette01:
	moveq	#0, d0	; 0xaf4e
	lea	(paletteBuffers).w, a0	; 0xaf50
	move.w	#7, d1	; 0xaf54
@next_color:
	move.l	d0, (a0)+	; 0xaf58
	dbf	d1, @next_color	; 0xaf5a
	st	(flagProcessPalettes).w	; 0xaf5e
	rts		; 0xaf62

titleScreenState04:
	subq.b	#1, (LBL_ffffbbd1).w	; 0xaf64
	bne.b	@return	; 0xaf68
	jsr	(getObjectSlot).w	; 0xaf6a
	bne.b	@no_more_slot	; 0xaf6e
	addq.b	#1, (a0)	; 0xaf70
	move.b	#$19, (15, a0)	; 0xaf72
	move.b	(titlescreenLightningIndex).w, (16, a0)	; 0xaf78
@no_more_slot:
	moveq	#0, d0	; 0xaf7e
	move.b	(titlescreenLightningIndex).w, d0	; 0xaf80
	addq.b	#1, d0	; 0xaf84
	move.b	(titlescreenLightningTypes, pc, d0.w), d1	; 0xaf86
	bmi.b	@exit	; 0xaf8a
	move.b	d0, (titlescreenLightningIndex).w	; 0xaf8c
	move.b	d1, (LBL_ffffbbd1).w	; 0xaf90
@return:
	rts		; 0xaf94
@exit:
	trap	#1	; 0xaf96

titlescreenLightningTypes:
	dc.b	$01, $09, $0b, $0a, $0a, $0b, $09, $0c, $0e, $0f, $10, $10, $11, $ff	; 0xaf98
	dc.b	$07	; nb of colors: 15	; 0xafa6
	dc.b	$60	; first colors: 0x30	; 0xafa7
	dc.l	PALETTE_003a3860/2	; source	; 0xafa8
	; 0x-1
	dc.w	$0099	; 0xafac