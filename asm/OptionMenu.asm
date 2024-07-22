
CMD_optionMenu:
	clr.b	(LBL_ffffbb78).w	; 0x6726
	bra.w	@run_option_menu	; 0x672a
	st	(LBL_ffffbb78).w	; 0x672e
@run_option_menu:
	jsr	(selectBgmF3).w	; 0x6732
	jsr	(initDisplay).w	; 0x6736
	jsr	(clearSatCache).w	; 0x673a
	lea	($7562, pc), a0	; 0x673e
	jsr	(transferDataFromPageToRam).w	; 0x6742
	lea	($756a, pc), a0	; 0x6746
	jsr	(transferDataFromPageToRam).w	; 0x674a
	lea	($7572, pc), a0	; 0x674e
	jsr	(transferDataFromPageToRam).w	; 0x6752
	lea	($757a, pc), a0	; 0x6756
	jsr	(transferDataFromPageToRam).w	; 0x675a
	lea	PALETTE_3a37a0, a1	; 0x675e
	move.w	#$0020, d0	; 0x6764
	jsr	(getFarAddress).w	; 0x6768
	move.b	d2, (currentPageInBank7).w	; 0x676c
	move.b	d2, mapperBank7	; 0x6770
	lea	(rawPalettes).w, a2	; 0x6776
@next_1:
	move.l	(a1)+, (a2)+	; 0x677a
	dbf	d0, @next_1	; 0x677c
	move.l	#$00382420, a1	; 0x6780
	move.w	#$0060, d0	; 0x6786
	jsr	(getFarAddress).w	; 0x678a
	move.b	d2, (currentPageInBank7).w	; 0x678e
	move.b	d2, mapperBank7	; 0x6792
	lea	(rawPalettes).w, a2	; 0x6798
@next_2:
	move.l	(a1)+, (a2)+	; 0x679c
	dbf	d0, @next_2	; 0x679e
	move.w	#0, (rawPalettes).w	; 0x67a2
	move.b	#7, (currentPageInBank7).w	; 0x67a8
	move.b	#7, mapperBank7	; 0x67ae
	clr.b	LBL_ff0859	; 0x67b6
	move.b	#1, LBL_ff0801	; 0x67bc
	move.b	#2, LBL_ff0821	; 0x67c4
	tst.b	(LBL_ffffbb78).w	; 0x67cc
	beq.w	@process_1	; 0x67d0
	move.b	#2, LBL_ff0859	; 0x67d4
	move.b	#2, (LBL_ffffbb78).w	; 0x67dc
	tst.b	(LBL_ffff9938).w	; 0x67e2
	beq.w	@ff9938_cleared	; 0x67e6
	move.b	#1, (LBL_ffffbb78).w	; 0x67ea
	bra.w	@process_1	; 0x67f0
@ff9938_cleared:
	tst.b	(LBL_ffff996e).w	; 0x67f4
	beq.w	@process_1	; 0x67f8
	move.b	#$ff, LBL_ff0801	; 0x67fc
	move.b	#$ff, LBL_ff0821	; 0x6804
	moveq	#0, d0	; 0x680c
	move.b	(LBL_ffff9971).w, d0	; 0x680e
	add.w	d0, d0	; 0x6812
	lea	(LBL_ffff997a).w, a0	; 0x6814
	lea	(0, a0, d0), a0	; 0x6818
	move.b	(a0)+, d0	; 0x681c
	bmi.w	@skip_1	; 0x681e
	andi.b	#7, d0	; 0x6822
	addq.b	#1, d0	; 0x6826
	move.b	d0, LBL_ff0801	; 0x6828
@skip_1:
	move.b	(a0)+, d0	; 0x682e
	bmi.w	@process_1	; 0x6830
	andi.b	#7, d0	; 0x6834
	addq.l	#1, d0	; 0x6838
	move.b	d0, LBL_ff0821	; 0x683a
@process_1:
	clr.b	LBL_ff085b	; 0x6840
	clr.b	LBL_ff085a	; 0x6846
	clr.w	LBL_ff0856	; 0x684c
	st	(LBL_ffff986b).w	; 0x6852
	bsr.w	optionMenuDrawBackground	; 0x6856
	move.l	#$5c020003, (4, a5)	; 0x685a
	move.w	#$0100, (a5)	; 0x6862
	move.w	#0, (LBL_ffff9b8c).w	; 0x6866
	move.l	#$00ff0800, a0	; 0x686c
	move.b	#0, (a0)	; 0x6872
	move.b	(joy1State).w, (2, a0)	; 0x6876
	st	(3, a0)	; 0x687c
	move.b	(LBL_fffffd04).w, (4, a0)	; 0x6880
	moveq	#0, d0	; 0x6886
	move.b	(LBL_ffffbb78).w, d0	; 0x6888
	add.w	d0, d0	; 0x688c
	move.w	(@DATA_68d2, pc, d0.w), (6, a0)	; 0x688e
	move.l	#$00ffa46b, (8, a0)	; 0x6894
	move.l	#$00fffd06, (12, a0)	; 0x689c
	move.l	#$a000a000, d0	; 0x68a4
	move.l	d0, (16, a0)	; 0x68aa
	move.l	d0, (20, a0)	; 0x68ae
	move.l	d0, (24, a0)	; 0x68b2
	tst.b	(1, a0)	; 0x68b6
	bmi.w	@process_4	; 0x68ba
	move.l	#$c000c000, d0	; 0x68be
	move.l	d0, (16, a0)	; 0x68c4
	move.l	d0, (20, a0)	; 0x68c8
	move.l	d0, (24, a0)	; 0x68cc
	bra.b	@process_4	; 0x68d0

@DATA_68d2:
	dc.w	$0384, $0304, $0304	; 0x68d2
@process_4:
	move.l	#$00ff0820, a0	; 0x68d8
	move.b	#0, (a0)	; 0x68de
	move.b	(joy2State).w, (2, a0)	; 0x68e2
	st	(3, a0)	; 0x68e8
	move.b	(LBL_fffffd05).w, (4, a0)	; 0x68ec
	moveq	#0, d0	; 0x68f2
	move.b	(LBL_ffffbb78).w, d0	; 0x68f4
	add.w	d0, d0	; 0x68f8
	move.w	(@DATA_693e, pc, d0.w), (6, a0)	; 0x68fa
	move.l	#$00ffa471, (8, a0)	; 0x6900
	move.l	#$00fffd10, (12, a0)	; 0x6908
	move.l	#$a000a000, d0	; 0x6910
	move.l	d0, (16, a0)	; 0x6916
	move.l	d0, (20, a0)	; 0x691a
	move.l	d0, (24, a0)	; 0x691e
	tst.b	(1, a0)	; 0x6922
	bmi.w	@process_2	; 0x6926
	move.l	#$c000c000, d0	; 0x692a
	move.l	d0, (16, a0)	; 0x6930
	move.l	d0, (20, a0)	; 0x6934
	move.l	d0, (24, a0)	; 0x6938
	bra.b	@process_2	; 0x693c

@DATA_693e:
	dc.w	$03a0, $0320, $0320	; 0x693e
@process_2:
	lea	dataBuffer, a0	; 0x6944
	move.l	#$a000a000, d0	; 0x694a
	move.w	#$01ff, d7	; 0x6950
@next_7:
	move.l	d0, (a0)+	; 0x6954
	dbf	d7, @next_7	; 0x6956
	lea	LBL_ff0848, a0	; 0x695a
	move.l	#$c000c000, (a0)+	; 0x6960
	move.l	#$c000c000, (a0)+	; 0x6966
	move.l	#$c000c000, (a0)	; 0x696c
	moveq	#0, d0	; 0x6972
	move.b	(LBL_ffffbb78).w, d0	; 0x6974
	add.w	d0, d0	; 0x6978
	lea	($7584, pc), a3	; 0x697a
	move.w	(0, a3, d0), d0	; 0x697e
	lea	(0, a3, d0), a3	; 0x6982
@loop_1:
	move.w	(a3)+, d0	; 0x6986
	bmi.w	@exit_1	; 0x6988
	move.w	d0, a0	; 0x698c
	move.w	(a3)+, d0	; 0x698e
	move.w	(a3)+, d1	; 0x6990
	bsr.w	drawString	; 0x6992
	bra.b	@loop_1	; 0x6996
@exit_1:
	moveq	#0, d1	; 0x6998
	move.b	(LBL_ffffbb78).w, d1	; 0x699a
	add.w	d1, d1	; 0x699e
	move.w	(@DATA_6a1a, pc, d1.w), d1	; 0x69a0
	ori.l	#$ffff0000, d1	; 0x69a4
	move.l	d1, a0	; 0x69aa
	moveq	#0, d0	; 0x69ac
	move.b	LBL_ff0801, d0	; 0x69ae
	bmi.w	@skip_2	; 0x69b4
	addi.w	#$a030, d0	; 0x69b8
	move.w	d0, (a0)	; 0x69bc
	bra.w	@skip_3	; 0x69be
@skip_2:
	move.w	LBL_ff0806, a0	; 0x69c2
	lea	(-192, a0), a0	; 0x69c8
	move.w	#$a000, d0	; 0x69cc
	move.w	#$0017, d1	; 0x69d0
	bsr.w	drawString	; 0x69d4
@skip_3:
	moveq	#0, d1	; 0x69d8
	move.b	(LBL_ffffbb78).w, d1	; 0x69da
	add.w	d1, d1	; 0x69de
	move.w	(@DATA_6a20, pc, d1.w), d1	; 0x69e0
	ori.l	#$ffff0000, d1	; 0x69e4
	move.l	d1, a0	; 0x69ea
	moveq	#0, d0	; 0x69ec
	move.b	LBL_ff0821, d0	; 0x69ee
	bmi.w	@skip_4	; 0x69f4
	addi.w	#$a030, d0	; 0x69f8
	move.w	d0, (a0)	; 0x69fc
	bra.b	@process_3	; 0x69fe
@skip_4:
	move.w	LBL_ff0826, a0	; 0x6a00
	lea	(-192, a0), a0	; 0x6a06
	move.w	#$a000, d0	; 0x6a0a
	move.w	#$0017, d1	; 0x6a0e
	bsr.w	drawString	; 0x6a12
	bra.w	@process_3	; 0x6a16

@DATA_6a1a:
	dc.w	$0308, $0288, $0288	; 0x6a1a

@DATA_6a20:
	dc.w	$0324, $02a4, $02a4	; 0x6a20
@process_3:
	move.l	#$00ff0800, a6	; 0x6a26
	bsr.w	FUN_00006f88	; 0x6a2c
	move.l	#$00ff0820, a6	; 0x6a30
	bsr.w	FUN_00006f88	; 0x6a36
	move.l	#$00ff0800, a6	; 0x6a3a
	bsr.w	updateKeyConfigItems	; 0x6a40
	bsr.w	optionMenuRefreshOptions	; 0x6a44
	move.l	#$00ff0820, a6	; 0x6a48
	bsr.w	updateKeyConfigItems	; 0x6a4e
	bsr.w	optionMenuRefreshOptions	; 0x6a52
	bsr.w	updateOptionMenuItems	; 0x6a56
	bsr.w	updateOptionMenu	; 0x6a5a
	bsr.w	updateOptionTilemap	; 0x6a5e
	move.w	#$0035, d0	; 0x6a62
	jsr	(selectBgm).w	; 0x6a66
	move.w	#$0780, (LBL_ffffbb7a).w	; 0x6a6a
	ori.b	#$40, (VdpRegistersCache).w	; 0x6a70
	move.w	(VdpRegistersCache).w, (4, a5)	; 0x6a76
	bsr.w	optionMenuFadeIn	; 0x6a7c
@loop_2:
	move.b	#1, d0	; 0x6a80
	trap	#3	; 0x6a84
	subq.w	#1, (LBL_ffffbb7a).w	; 0x6a86
	bne.b	@skip_bgm	; 0x6a8a
	move.w	#$0780, (LBL_ffffbb7a).w	; 0x6a8c
	move.w	#$0035, d0	; 0x6a92
	jsr	(selectBgm).w	; 0x6a96
@skip_bgm:
	addq.b	#1, LBL_ff0858	; 0x6a9a
	addq.b	#1, LBL_ff0800	; 0x6aa0
	addq.b	#1, LBL_ff0820	; 0x6aa6
	move.l	#$00ff0800, a6	; 0x6aac
	bsr.w	FUN_00006f98	; 0x6ab2
	move.l	#$00ff0820, a6	; 0x6ab6
	bsr.w	FUN_00006f98	; 0x6abc
	tst.b	LBL_ff085a	; 0x6ac0
	bne.w	@skip_5	; 0x6ac6
	move.w	(joy1State).w, d1	; 0x6aca
	move.l	#$00ff0800, a6	; 0x6ace
	bsr.w	runOptionMenu	; 0x6ad4
	move.w	(joy2State).w, d1	; 0x6ad8
	move.l	#$00ff0820, a6	; 0x6adc
	bsr.w	runOptionMenu	; 0x6ae2
	bra.w	@continue_2	; 0x6ae6
@skip_5:
	move.w	(joy1State).w, d1	; 0x6aea
	move.l	#$00ff0800, a6	; 0x6aee
	bsr.w	runKeyConfig	; 0x6af4
	move.w	(joy2State).w, d1	; 0x6af8
	move.l	#$00ff0820, a6	; 0x6afc
	bsr.w	runKeyConfig	; 0x6b02
@continue_2:
	move.w	(joy1State).w, d1	; 0x6b06
	move.l	#$00ff0800, a6	; 0x6b0a
	bsr.w	runOptionMenuCheckABCXYZ	; 0x6b10
	move.w	(joy2State).w, d1	; 0x6b14
	move.l	#$00ff0820, a6	; 0x6b18
	bsr.w	runOptionMenuCheckABCXYZ	; 0x6b1e
	bsr.w	updateOptionMenu	; 0x6b22
	bsr.w	updateOptionMenuItems	; 0x6b26
	move.l	#$00ff0800, a6	; 0x6b2a
	bsr.w	updateKeyConfigItems	; 0x6b30
	bsr.w	optionMenuRefreshOptions	; 0x6b34
	move.l	#$00ff0820, a6	; 0x6b38
	bsr.w	updateKeyConfigItems	; 0x6b3e
	bsr.w	optionMenuRefreshOptions	; 0x6b42
	bsr.w	FUN_00007398	; 0x6b46
	bsr.w	updateOptionTilemap	; 0x6b4a
	bsr.w	updateOptionScrolling	; 0x6b4e
	bra.w	@loop_2	; 0x6b52

runOptionMenu:
	tst.b	(1, a6)	; 0x6b56
	bmi.w	@return	; 0x6b5a
	moveq	#0, d0	; 0x6b5e
@loop:
	andi.w	#$000f, d1	; 0x6b60
	beq.w	@return	; 0x6b64
	lsr.w	#1, d1	; 0x6b68
	bcc.w	@continue	; 0x6b6a
	move.w	d0, d2	; 0x6b6e
	movem.w	d0/d1/d2, -(a7)	; 0x6b70
	move.w	(menuOptionsJoyCallbacks, pc, d2.w), d2	; 0x6b74
	jsr	(menuOptionsJoyCallbacks, pc, d2.w)	; 0x6b78
	movem.w	(a7)+, d2/d1/d0	; 0x6b7c
@continue:
	addq.b	#2, d0	; 0x6b80
	bra.b	@loop	; 0x6b82
@return:
	rts		; 0x6b84

menuOptionsJoyCallbacks:
	dc.w	runOptionMenuUp-menuOptionsJoyCallbacks	; 0x6b86
	dc.w	runOptionMenuDown-menuOptionsJoyCallbacks	; 0x6b88
	dc.w	runOptionMenuLeft-menuOptionsJoyCallbacks	; 0x6b8a
	dc.w	runOptionRight-menuOptionsJoyCallbacks	; 0x6b8c

runOptionMenuUp:
	clr.w	LBL_ff0858	; 0x6b8e
	moveq	#0, d0	; 0x6b94
	move.b	(LBL_ffffbb78).w, d0	; 0x6b96
	add.w	d0, d0	; 0x6b9a
	move.w	(menuOptionsUpFunctions, pc, d0.w), d0	; 0x6b9c
	jmp	(menuOptionsUpFunctions, pc, d0.w)	; 0x6ba0

menuOptionsUpFunctions:
	dc.w	menuOptionsUp00-menuOptionsUpFunctions	; 0x6ba4
	dc.w	menuOptionsUp01-menuOptionsUpFunctions	; 0x6ba6
	dc.w	menuOptionsUp02-menuOptionsUpFunctions	; 0x6ba8

menuOptionsUp00:
	moveq	#0, d0	; 0x6baa
	move.b	LBL_ff085b, d0	; 0x6bac
	subq.b	#1, d0	; 0x6bb2
	bcc.w	@not_on_top	; 0x6bb4
	moveq	#3, d0	; 0x6bb8

@not_on_top:
	move.b	(DATA_6bca, pc, d0.w), LBL_ff0859	; 0x6bba
	move.b	d0, LBL_ff085b	; 0x6bc2
	rts		; 0x6bc8

DATA_6bca:
	dc.b	$00, $01, $02, $03	; 0x6bca

menuOptionsUp01:
	moveq	#0, d0	; 0x6bce
	move.b	LBL_ff085b, d0	; 0x6bd0
	subq.b	#1, d0	; 0x6bd6
	bcc.w	@not_on_top	; 0x6bd8
	moveq	#3, d0	; 0x6bdc

@not_on_top:
	move.b	(DATA_6bee, pc, d0.w), LBL_ff0859	; 0x6bde
	move.b	d0, LBL_ff085b	; 0x6be6
	rts		; 0x6bec

DATA_6bee:
	dc.b	$02, $04, $05, $06	; 0x6bee

menuOptionsUp02:
	moveq	#0, d0	; 0x6bf2
	move.b	LBL_ff085b, d0	; 0x6bf4
	eori.b	#1, d0	; 0x6bfa
	move.b	(DATA_6c0e, pc, d0.w), LBL_ff0859	; 0x6bfe
	move.b	d0, LBL_ff085b	; 0x6c06
	rts		; 0x6c0c

DATA_6c0e:
	dc.b	$02, $06	; 0x6c0e

runOptionMenuDown:
	clr.b	LBL_ff0858	; 0x6c10
	moveq	#0, d0	; 0x6c16
	move.b	(LBL_ffffbb78).w, d0	; 0x6c18
	add.w	d0, d0	; 0x6c1c
	move.w	(menuOptionsDownFunctions, pc, d0.w), d0	; 0x6c1e
	jmp	(menuOptionsDownFunctions, pc, d0.w)	; 0x6c22

menuOptionsDownFunctions:
	dc.w	menuOptionsDown00-menuOptionsDownFunctions	; 0x6c26
	dc.w	menuOptionsDown01-menuOptionsDownFunctions	; 0x6c28
	dc.w	menuOptionsDown02-menuOptionsDownFunctions	; 0x6c2a

menuOptionsDown00:
	moveq	#0, d0	; 0x6c2c
	move.b	LBL_ff085b, d0	; 0x6c2e
	addq.b	#1, d0	; 0x6c34
	cmpi.b	#4, d0	; 0x6c36
	bne.w	@not_on_bottom	; 0x6c3a
	moveq	#0, d0	; 0x6c3e

@not_on_bottom:
	move.b	(DATA_6bca, pc, d0.w), LBL_ff0859	; 0x6c40
	move.b	d0, LBL_ff085b	; 0x6c48
	rts		; 0x6c4e

menuOptionsDown01:
	moveq	#0, d0	; 0x6c50
	move.b	LBL_ff085b, d0	; 0x6c52
	addq.b	#1, d0	; 0x6c58
	cmpi.b	#4, d0	; 0x6c5a
	bne.w	@not_on_bottom	; 0x6c5e
	moveq	#0, d0	; 0x6c62

@not_on_bottom:
	move.b	(DATA_6bee, pc, d0.w), LBL_ff0859	; 0x6c64
	move.b	d0, LBL_ff085b	; 0x6c6c
	rts		; 0x6c72

menuOptionsDown02:
	moveq	#0, d0	; 0x6c74
	move.b	LBL_ff085b, d0	; 0x6c76
	eori.b	#1, d0	; 0x6c7c
	move.b	(DATA_6c0e, pc, d0.w), LBL_ff0859	; 0x6c80
	move.b	d0, LBL_ff085b	; 0x6c88
	rts		; 0x6c8e

runOptionMenuLeft:
	moveq	#0, d0	; 0x6c90
	move.b	LBL_ff0859, d0	; 0x6c92
	add.w	d0, d0	; 0x6c98
	move.w	(menuOptionsLeftFunctions, pc, d0.w), d0	; 0x6c9a
	jmp	(menuOptionsLeftFunctions, pc, d0.w)	; 0x6c9e

menuOptionsLeftFunctions:
	dc.w	runOptionMenuDifficultyLeft-menuOptionsLeftFunctions	; 0x6ca2
	dc.w	runOptionMenuTimeLimitLeft-menuOptionsLeftFunctions	; 0x6ca4
	dc.w	runOptionKeyConfigLimitLeft-menuOptionsLeftFunctions	; 0x6ca6
	dc.w	runOptionSuperModeLimitLeft-menuOptionsLeftFunctions	; 0x6ca8
	dc.w	runOptionUnknown1LimitLeft-menuOptionsLeftFunctions	; 0x6caa
	dc.w	runOptionUnknown2LimitLeft-menuOptionsLeftFunctions	; 0x6cac
	dc.w	runOptionUnknown3LimitLeft-menuOptionsLeftFunctions	; 0x6cae

runOptionMenuDifficultyLeft:
	move.b	(difficulty).w, d0	; 0x6cb0
	beq.w	@return	; 0x6cb4
	subq.b	#1, d0	; 0x6cb8
	move.b	d0, (difficulty).w	; 0x6cba
	clr.b	LBL_ff0858	; 0x6cbe

@return:
	rts		; 0x6cc4

runOptionMenuTimeLimitLeft:
	tst.b	(freeTime).w	; 0x6cc6
	beq.w	@return	; 0x6cca
	clr.b	(freeTime).w	; 0x6cce
	clr.b	LBL_ff0858	; 0x6cd2

@return:
	rts		; 0x6cd8

runOptionKeyConfigLimitLeft:
	rts		; 0x6cda

runOptionSuperModeLimitLeft:
	tst.b	(superMode).w	; 0x6cdc
	beq.w	@return	; 0x6ce0
	clr.b	(superMode).w	; 0x6ce4
	clr.b	LBL_ff0858	; 0x6ce8

@return:
	rts		; 0x6cee

runOptionUnknown1LimitLeft:
	tst.b	LBL_ff0804	; 0x6cf0
	bne.w	@return	; 0x6cf6
	clr.b	LBL_ff0858	; 0x6cfa
	st	LBL_ff0804	; 0x6d00

@return:
	rts		; 0x6d06

runOptionUnknown2LimitLeft:
	tst.b	LBL_ff0824	; 0x6d08
	bne.w	runOptionUnknown3LimitLeft	; 0x6d0e
	clr.b	LBL_ff0858	; 0x6d12
	st	LBL_ff0824	; 0x6d18

runOptionUnknown3LimitLeft:
	rts		; 0x6d1e

runOptionRight:
	moveq	#0, d0	; 0x6d20
	move.b	LBL_ff0859, d0	; 0x6d22
	add.w	d0, d0	; 0x6d28
	move.w	(menuOptionsRightFunctions, pc, d0.w), d0	; 0x6d2a
	jmp	(menuOptionsRightFunctions, pc, d0.w)	; 0x6d2e

menuOptionsRightFunctions:
	dc.w	runOptionMenuDifficultyRight-menuOptionsRightFunctions	; 0x6d32
	dc.w	runOptionMenuTimeLimitRight-menuOptionsRightFunctions	; 0x6d34
	dc.w	runOptionMenuKeyConfigRight-menuOptionsRightFunctions	; 0x6d36
	dc.w	runOptionMenuSuperModeRight-menuOptionsRightFunctions	; 0x6d38
	dc.w	runOptionMenuUnknown1Right-menuOptionsRightFunctions	; 0x6d3a
	dc.w	runOptionMenuUnknown2Right-menuOptionsRightFunctions	; 0x6d3c
	dc.w	runOptionMenuUnknown3Right-menuOptionsRightFunctions	; 0x6d3e

runOptionMenuDifficultyRight:
	move.b	(difficulty).w, d0	; 0x6d40
	addq.b	#1, d0	; 0x6d44
	cmpi.b	#8, d0	; 0x6d46
	bne.w	not_maxed	; 0x6d4a
	moveq	#7, d0	; 0x6d4e
	bra.b	return10	; 0x6d50

not_maxed:
	move.b	d0, (difficulty).w	; 0x6d52
	clr.b	LBL_ff0858	; 0x6d56

return10:
	rts		; 0x6d5c

runOptionMenuTimeLimitRight:
	tst.b	(freeTime).w	; 0x6d5e
	bne.w	@return	; 0x6d62
	st	(freeTime).w	; 0x6d66
	clr.b	LBL_ff0858	; 0x6d6a

@return:
	rts		; 0x6d70

runOptionMenuKeyConfigRight:
	st	LBL_ff085a	; 0x6d72
	move.l	#$00ff0800, a6	; 0x6d78
	clr.b	(3, a6)	; 0x6d7e
	clr.b	(a6)	; 0x6d82
	move.l	#$00ff0820, a6	; 0x6d84
	clr.b	(3, a6)	; 0x6d8a
	clr.b	(a6)	; 0x6d8e
	rts		; 0x6d90

runOptionMenuSuperModeRight:
	tst.b	(superMode).w	; 0x6d92
	bne.w	@return	; 0x6d96
	st	(superMode).w	; 0x6d9a
	clr.b	LBL_ff0858	; 0x6d9e

@return:
	rts		; 0x6da4

runOptionMenuUnknown1Right:
	tst.b	LBL_ff0804	; 0x6da6
	beq.w	@return	; 0x6dac
	clr.b	LBL_ff0804	; 0x6db0
	clr.b	LBL_ff0858	; 0x6db6

@return:
	rts		; 0x6dbc

runOptionMenuUnknown2Right:
	tst.b	LBL_ff0824	; 0x6dbe
	beq.w	runOptionMenuUnknown3Right	; 0x6dc4
	clr.b	LBL_ff0824	; 0x6dc8
	clr.b	LBL_ff0858	; 0x6dce

runOptionMenuUnknown3Right:
	rts		; 0x6dd4

runKeyConfig:
	tst.b	(1, a6)	; 0x6dd6
	bmi.w	@return	; 0x6dda
	moveq	#0, d0	; 0x6dde
@loop:
	andi.w	#$000f, d1	; 0x6de0
	beq.w	@return	; 0x6de4
	lsr.w	#1, d1	; 0x6de8
	bcc.w	@continue	; 0x6dea
	move.w	d0, d2	; 0x6dee
	movem.w	d0/d1/d2, -(a7)	; 0x6df0
	move.w	(keyConfigJoyCallbacks, pc, d2.w), d2	; 0x6df4
	jsr	(keyConfigJoyCallbacks, pc, d2.w)	; 0x6df8
	movem.w	(a7)+, d2/d1/d0	; 0x6dfc
@continue:
	addq.w	#2, d0	; 0x6e00
	bra.b	@loop	; 0x6e02
@return:
	rts		; 0x6e04

keyConfigJoyCallbacks:
	dc.w	runKeyConfigUp-keyConfigJoyCallbacks	; 0x6e06
	dc.w	runKeyConfigDown-keyConfigJoyCallbacks	; 0x6e08
	dc.w	runKeyConfigLeft-keyConfigJoyCallbacks	; 0x6e0a
	dc.w	runKeyConfigRight-keyConfigJoyCallbacks	; 0x6e0c

runKeyConfigUp:
	clr.b	(a6)	; 0x6e0e
	move.b	(3, a6), d0	; 0x6e10
	subq.b	#1, d0	; 0x6e14
	bcc.w	@return	; 0x6e16
	moveq	#5, d0	; 0x6e1a
	cmpi.b	#1, (2, a6)	; 0x6e1c
	beq.w	@return	; 0x6e22
	moveq	#3, d0	; 0x6e26
@return:
	move.b	d0, (3, a6)	; 0x6e28
	rts		; 0x6e2c

runKeyConfigDown:
	clr.b	(a6)	; 0x6e2e
	move.b	(3, a6), d0	; 0x6e30
	addq.b	#1, d0	; 0x6e34
	moveq	#6, d1	; 0x6e36
	cmpi.b	#1, (2, a6)	; 0x6e38
	beq.w	@skip	; 0x6e3e
	moveq	#4, d1	; 0x6e42

@skip:
	cmp.b	d1, d0	; 0x6e44
	bne.w	@return	; 0x6e46
	moveq	#0, d0	; 0x6e4a

@return:
	move.b	d0, (3, a6)	; 0x6e4c

runKeyConfigRight:
	rts		; 0x6e50

runKeyConfigLeft:
	clr.b	LBL_ff085a	; 0x6e52
	move.b	#$ff, LBL_ff0803	; 0x6e58
	move.b	#$ff, LBL_ff0823	; 0x6e60
	rts		; 0x6e68

runOptionMenuCheckABCXYZ:
	tst.b	(1, a6)	; 0x6e6a
	bmi.w	@return	; 0x6e6e
	moveq	#0, d0	; 0x6e72
	lsr.w	#4, d1	; 0x6e74
	beq.w	@return	; 0x6e76
	cmpi.b	#6, LBL_ff0859	; 0x6e7a
	beq.w	quitOptionMenu	; 0x6e82
@wait:
	tst.w	d1	; 0x6e86
	beq.w	@return	; 0x6e88
	lsr.w	#1, d1	; 0x6e8c
	bcc.w	@continue	; 0x6e8e
	move.w	d0, d2	; 0x6e92
	movem.w	d0/d1/d2, -(a7)	; 0x6e94
	move.w	(optionMenuButtonsCallbacks, pc, d2.w), d2	; 0x6e98
	jsr	(optionMenuButtonsCallbacks, pc, d2.w)	; 0x6e9c
	movem.w	(a7)+, d2/d1/d0	; 0x6ea0
@continue:
	addq.b	#2, d0	; 0x6ea4
	bra.b	@wait	; 0x6ea6
@return:
	rts		; 0x6ea8

optionMenuButtonsCallbacks:
	dc.w	optionMenuButtonB-optionMenuButtonsCallbacks	; 0x6eaa
	dc.w	optionMenuButtonC-optionMenuButtonsCallbacks	; 0x6eac
	dc.w	optionMenuButtonA-optionMenuButtonsCallbacks	; 0x6eae
	dc.w	optionMenuButtonStart-optionMenuButtonsCallbacks	; 0x6eb0
	dc.w	optionMenuButtonZ-optionMenuButtonsCallbacks	; 0x6eb2
	dc.w	optionMenuButtonY-optionMenuButtonsCallbacks	; 0x6eb4
	dc.w	optionMenuButtonX-optionMenuButtonsCallbacks	; 0x6eb6
	dc.w	optionMenuButtonMode-optionMenuButtonsCallbacks	; 0x6eb8

optionMenuButtonA:
	move.b	#6, d0	; 0x6eba
	bra.w	optionMenuHandleABCXYZ	; 0x6ebe

optionMenuButtonB:
	move.b	#4, d0	; 0x6ec2
	bra.w	optionMenuHandleABCXYZ	; 0x6ec6

optionMenuButtonC:
	move.b	#5, d0	; 0x6eca
	bra.w	optionMenuHandleABCXYZ	; 0x6ece

optionMenuButtonX:
	move.b	#$0a, d0	; 0x6ed2
	bra.w	optionMenuHandleABCXYZ	; 0x6ed6

optionMenuButtonY:
	move.b	#9, d0	; 0x6eda
	bra.w	optionMenuHandleABCXYZ	; 0x6ede

optionMenuButtonZ:
	move.b	#8, d0	; 0x6ee2
	bra.w	optionMenuHandleABCXYZ	; 0x6ee6

optionMenuButtonStart:
	cmpi.b	#0, (2, a6)	; 0x6eea
	bne.w	quitOptionMenu	; 0x6ef0
	tst.b	LBL_ff085a	; 0x6ef4
	beq.w	quitOptionMenu	; 0x6efa
	move.b	#7, d0	; 0x6efe
	bra.w	optionMenuHandleABCXYZ	; 0x6f02

optionMenuButtonMode:
	rts		; 0x6f06

quitOptionMenu:
	jsr	(bgmFadeOff).w	; 0x6f08
	move.b	LBL_ff0804, (LBL_fffffd04).w	; 0x6f0c
	move.b	LBL_ff0824, (LBL_fffffd05).w	; 0x6f14
	bsr.w	optionMenuFadeOut	; 0x6f1c
	tst.b	(LBL_ffffbb78).w	; 0x6f20
	bne.w	@dont_change_cmd	; 0x6f24
	move.l	#$00009e80, a0	; 0x6f28
	move.w	#$0010, d0	; 0x6f2e
	trap	#0	; 0x6f32
@dont_change_cmd:
	clr.b	(LBL_ffff986b).w	; 0x6f34
	trap	#1	; 0x6f38

optionMenuRefreshOptions:
	tst.b	(1, a6)	; 0x6f3a
	bmi.w	@return	; 0x6f3e
	moveq	#0, d7	; 0x6f42
	move.b	(3, a6), d6	; 0x6f44
	move.w	(6, a6), a2	; 0x6f48
	lea	(16, a6), a3	; 0x6f4c
@next:
	cmp.b	d6, d7	; 0x6f50
	bne.w	@skip	; 0x6f52
	move.l	a2, a0	; 0x6f56
	move.w	#$c000, d0	; 0x6f58
	moveq	#8, d1	; 0x6f5c
	moveq	#0, d2	; 0x6f5e
	bsr.w	setTileRectFromRam	; 0x6f60
	bra.b	@continue	; 0x6f64
@skip:
	move.l	a2, a0	; 0x6f66
	move.w	#$a000, d0	; 0x6f68
	moveq	#8, d1	; 0x6f6c
	moveq	#0, d2	; 0x6f6e
	bsr.w	setTileRectFromRam	; 0x6f70
	move.w	#$c000, (a3)	; 0x6f74
@continue:
	addq.b	#1, d7	; 0x6f78
	lea	(64, a2), a2	; 0x6f7a
	addq.l	#2, a3	; 0x6f7e
	cmpi.b	#6, d7	; 0x6f80
	bcs.b	@next	; 0x6f84
@return:
	rts		; 0x6f86

FUN_00006f88:
	tst.b	(1, a6)	; 0x6f88
	bmi.w	return_200	; 0x6f8c
	move.l	(8, a6), a1	; 0x6f90
	move.b	(a1), d0	; 0x6f94
	bra.b	process	; 0x6f96

FUN_00006f98:
	tst.b	(1, a6)	; 0x6f98
	bmi.w	return_200	; 0x6f9c
	move.b	(2, a6), d1	; 0x6fa0
	move.l	(8, a6), a1	; 0x6fa4
	move.b	(a1), d0	; 0x6fa8
	cmp.b	d0, d1	; 0x6faa
	beq.w	return_200	; 0x6fac

process:
	clr.b	(3, a6)	; 0x6fb0
	tst.b	LBL_ff085a	; 0x6fb4
	bne.w	@skip1	; 0x6fba
	st	(3, a6)	; 0x6fbe
@skip1:
	move.w	#$0013, d1	; 0x6fc2
	move.b	d0, (2, a6)	; 0x6fc6
	cmpi.b	#0, d0	; 0x6fca
	bne.w	@dont_max	; 0x6fce
	move.w	#$0012, d1	; 0x6fd2
	bra.b	@continue1	; 0x6fd6
@dont_max:
	cmpi.b	#1, d0	; 0x6fd8
	bne.w	@dont_min	; 0x6fdc
	move.w	#$0011, d1	; 0x6fe0
	bra.b	@continue1	; 0x6fe4
@dont_min:
	cmpi.b	#$ff, d0	; 0x6fe6
	bne.w	@continue1	; 0x6fea
	move.w	#$0014, d1	; 0x6fee
@continue1:
	move.w	(6, a6), a0	; 0x6ff2
	move.w	#$a000, d0	; 0x6ff6
	bsr.w	drawString	; 0x6ffa
	cmpi.b	#1, (2, a6)	; 0x6ffe
	beq.w	case1_200	; 0x7004
	cmpi.b	#0, (2, a6)	; 0x7008
	beq.w	case2_200	; 0x700e

return_200:
	rts		; 0x7012

case2_200:
	tst.b	(1, a6)	; 0x7014
	bmi.w	return_201	; 0x7018
	move.l	(12, a6), a2	; 0x701c
	addq.l	#6, a2	; 0x7020
	moveq	#4, d1	; 0x7022
	bra.b	process_200	; 0x7024

case1_200:
	tst.b	(1, a6)	; 0x7026
	bmi.w	return_201	; 0x702a
	move.l	(12, a6), a2	; 0x702e
	moveq	#6, d1	; 0x7032

process_200:
	move.w	(6, a6), d0	; 0x7034
	ori.l	#$ffff0000, d0	; 0x7038
	move.l	d0, a0	; 0x703e
	lea	(18, a0), a0	; 0x7040
	moveq	#0, d2	; 0x7044
@loop:
	moveq	#0, d3	; 0x7046
	move.b	(a2)+, d3	; 0x7048
	subq.b	#4, d3	; 0x704a
	move.b	d3, d4	; 0x704c
	add.b	d3, d3	; 0x704e
	add.b	d4, d3	; 0x7050
	lea	($7074, pc), a1	; 0x7052
	adda.l	d3, a1	; 0x7056
	move.w	#$a000, d0	; 0x7058
	move.b	(a1)+, d0	; 0x705c
	move.w	d0, (a0)+	; 0x705e
	move.b	(a1)+, d0	; 0x7060
	move.w	d0, (a0)+	; 0x7062
	move.b	(a1)+, d0	; 0x7064
	move.w	d0, (a0)	; 0x7066
	lea	(60, a0), a0	; 0x7068
	addq.b	#1, d2	; 0x706c
	cmp.b	d1, d2	; 0x706e
	bne.b	@loop	; 0x7070

return_201:
	rts		; 0x7072

DATA_7074:
	dc.b	$20, $42, $20, $20, $43, $20, $20, $41, $20, $fc, $fd, $fe, $20, $5a, $20, $20, $59, $20, $20, $58, $20, $20, $4d, $20	; 0x7074

optionMenuHandleABCXYZ:
	tst.b	LBL_ff085a	; 0x708c
	beq.w	@return	; 0x7092
	tst.b	(1, a6)	; 0x7096
	bmi.w	@return	; 0x709a
	cmpi.b	#$0f, (2, a6)	; 0x709e
	beq.w	@return	; 0x70a4
	cmpi.b	#$ff, (2, a6)	; 0x70a8
	beq.w	@return	; 0x70ae
	moveq	#0, d1	; 0x70b2
	move.b	(3, a6), d1	; 0x70b4
	move.l	(12, a6), a0	; 0x70b8
	cmpi.b	#0, (2, a6)	; 0x70bc
	bne.w	@not_zero	; 0x70c2
	addq.l	#6, a0	; 0x70c6
	move.b	(0, a0, d1), d2	; 0x70c8
	move.w	#3, d7	; 0x70cc
	move.l	a0, a1	; 0x70d0
@next2:
	move.b	(a1), d3	; 0x70d2
	cmp.b	d0, d3	; 0x70d4
	beq.w	@exit2	; 0x70d6
	addq.l	#1, a1	; 0x70da
	dbf	d7, @next2	; 0x70dc
	bra.b	@case0	; 0x70e0
@exit2:
	move.b	d2, (a1)	; 0x70e2
	move.b	d0, (0, a0, d1)	; 0x70e4
	bra.w	case2_200	; 0x70e8
@not_zero:
	move.b	(0, a0, d1), d2	; 0x70ec
	move.w	#5, d7	; 0x70f0
	move.l	a0, a1	; 0x70f4
@next1:
	move.b	(a1), d3	; 0x70f6
	cmp.b	d0, d3	; 0x70f8
	beq.w	@exit1	; 0x70fa
	addq.l	#1, a1	; 0x70fe
	dbf	d7, @next1	; 0x7100
	bra.b	@case0	; 0x7104
@exit1:
	move.b	d2, (a1)	; 0x7106
	move.b	d0, (0, a0, d1)	; 0x7108
	bra.w	case1_200	; 0x710c
@return:
	rts		; 0x7110
@case0:
	move.l	(12, a6), a0	; 0x7112
	move.l	($7126, pc), a1	; 0x7116
	nop		; 0x711a
	moveq	#9, d7	; 0x711c
@next3:
	move.b	(a1)+, (a0)+	; 0x711e
	dbf	d7, @next3	; 0x7120
	rts		; 0x7124
	dc.b	$0a, $09, $08, $06, $04, $05, $06, $04, $05, $07	; 0x7126

updateOptionMenu:
	move.l	#$00ff0840, a0	; 0x7130
	moveq	#3, d7	; 0x7136
@next:
	move.w	#$a000, (a0)+	; 0x7138
	dbf	d7, @next	; 0x713c
	move.l	#$00ff0840, a0	; 0x7140
	moveq	#0, d0	; 0x7146
	move.b	LBL_ff085b, d0	; 0x7148
	add.w	d0, d0	; 0x714e
	move.w	#$e000, (0, a0, d0)	; 0x7150
	moveq	#0, d0	; 0x7156
	move.b	(LBL_ffffbb78).w, d0	; 0x7158
	add.w	d0, d0	; 0x715c
	move.w	(29058, pc, d0.w), d0	; 0x715e
	lea	(29058, pc, d0.w), a2	; 0x7162
	lea	LBL_ff0840, a3	; 0x7166
@loop:
	move.w	(a2)+, d0	; 0x716c
	bmi.w	@exit	; 0x716e
	move.w	d0, a0	; 0x7172
	move.w	(a3)+, d0	; 0x7174
	move.w	(a2)+, d1	; 0x7176
	move.w	(a2)+, d2	; 0x7178
	bsr.w	setTileRectFromRam	; 0x717a
	bra.b	@loop	; 0x717e
@exit:
	rts		; 0x7180
	dc.w	$0006, $0020, $003a, $0186, $0009, $0000, $0206, $0009, $0000, $0286, $000a, $0000, $0546, $0009, $0000, $ffff, $0206, $000a, $0000, $04c6, $0006, $0000, $0546, $0006, $0000, $05c6, $0003, $0000, $ffff, $0206, $000a, $0000, $04c6, $0003, $0000, $ffff	; 0x7182

updateOptionMenuItems:
	moveq	#0, d0	; 0x71ca
	move.b	LBL_ff0859, d0	; 0x71cc
	lea	LBL_ff0848, a0	; 0x71d2
	add.w	d0, d0	; 0x71d8
	move.l	a0, a1	; 0x71da
	move.w	(0, a0, d0), d3	; 0x71dc
	moveq	#6, d7	; 0x71e0
@next1:
	move.w	#$c000, (a0)+	; 0x71e2
	dbf	d7, @next1	; 0x71e6
	move.w	d3, (0, a1, d0)	; 0x71ea
	moveq	#0, d0	; 0x71ee
	move.b	(LBL_ffffbb78).w, d0	; 0x71f0
	add.w	d0, d0	; 0x71f4
	move.w	(ffbb78Functions, pc, d0.w), d0	; 0x71f6
	jmp	(ffbb78Functions, pc, d0.w)	; 0x71fa

ffbb78Functions:
	dc.w	ffbb78Func00-ffbb78Functions	; 0x71fe
	dc.w	ffbb78Func02-ffbb78Functions	; 0x7200
	dc.w	ffbb78Func04-ffbb78Functions	; 0x7202

ffbb78Func00:
	bsr.w	updateOptionDifficultyItems	; 0x7204
	bsr.w	updateTimeLimitItems	; 0x7208
	bra.w	updateOptionSuperModeItems	; 0x720c

ffbb78Func02:
	move.l	#$00ff0800, a6	; 0x7210
	bsr.w	FUN_00007338	; 0x7216
	move.l	#$00ff0820, a6	; 0x721a
	bra.w	FUN_7338	; 0x7220

ffbb78Func04:
	rts		; 0x7224

updateOptionDifficultyItems:
	lea	LBL_ff0848, a4	; 0x7226
	move.l	#$000001a2, a0	; 0x722c
	move.w	a0, a2	; 0x7232
	move.w	#$a000, d0	; 0x7234
	moveq	#7, d1	; 0x7238
	moveq	#0, d2	; 0x723a
	bsr.w	setTileRectFromRam	; 0x723c
	move.w	a2, a0	; 0x7240
	move.w	(a4), d0	; 0x7242
	moveq	#0, d1	; 0x7244
	move.b	(difficulty).w, d1	; 0x7246
	moveq	#0, d2	; 0x724a
	bra.w	setTileRectFromRam	; 0x724c

updateTimeLimitItems:
	lea	LBL_ff0848, a4	; 0x7250
	move.w	(2, a4), d0	; 0x7256
	tst.b	(freeTime).w	; 0x725a
	bne.w	@loc_00007282	; 0x725e
	move.l	#$0000021e, a0	; 0x7262
	moveq	#2, d1	; 0x7268
	moveq	#0, d2	; 0x726a
	bsr.w	setTileRectFromRam	; 0x726c
	move.l	#$0000022e, a0	; 0x7270
	move.w	#$a000, d0	; 0x7276
	moveq	#2, d1	; 0x727a
	moveq	#0, d2	; 0x727c
	bra.w	setTileRectFromRam	; 0x727e
@loc_00007282:
	move.l	#$0000022e, a0	; 0x7282
	moveq	#2, d1	; 0x7288
	moveq	#0, d2	; 0x728a
	bsr.w	setTileRectFromRam	; 0x728c
	move.w	#$a000, d0	; 0x7290
	moveq	#2, d1	; 0x7294
	moveq	#0, d2	; 0x7296
	move.l	#$0000021e, a0	; 0x7298
	bra.w	setTileRectFromRam	; 0x729e

updateKeyConfigItems:
	cmpi.b	#$0f, (2, a6)	; 0x72a2
	beq.w	@return	; 0x72a8
	cmpi.b	#$ff, (2, a6)	; 0x72ac
	beq.w	@return	; 0x72b2
	tst.b	(1, a6)	; 0x72b6
	bmi.w	@return	; 0x72ba
	move.w	(6, a6), a0	; 0x72be
	lea	(18, a0), a0	; 0x72c2
	move.l	a0, a2	; 0x72c6
	lea	(16, a6), a3	; 0x72c8
	moveq	#5, d7	; 0x72cc
@next1:
	move.w	(a3)+, d0	; 0x72ce
	moveq	#2, d1	; 0x72d0
	moveq	#0, d2	; 0x72d2
	bsr.w	setTileRectFromRam	; 0x72d4
	lea	(64, a2), a2	; 0x72d8
	move.l	a2, a0	; 0x72dc
	dbf	d7, @next1	; 0x72de
@return:
	rts		; 0x72e2

updateOptionSuperModeItems:
	lea	LBL_ff0848, a4	; 0x72e4
	move.w	(6, a4), d0	; 0x72ea
	tst.b	(superMode).w	; 0x72ee
	bne.w	super_mode	; 0x72f2
	moveq	#5, d1	; 0x72f6
	moveq	#0, d2	; 0x72f8
	move.l	#$0000055e, a0	; 0x72fa
	bsr.w	setTileRectFromRam	; 0x7300
	move.w	#$a000, d0	; 0x7304
	moveq	#5, d1	; 0x7308
	moveq	#1, d2	; 0x730a
	move.l	#$0000052c, a0	; 0x730c
	bra.w	setTileRectFromRam	; 0x7312

super_mode:
	moveq	#5, d1	; 0x7316
	move.w	#1, d2	; 0x7318
	move.l	#$0000052c, a0	; 0x731c
	bsr.w	setTileRectFromRam	; 0x7322
	move.w	#$a000, d0	; 0x7326
	moveq	#5, d1	; 0x732a
	moveq	#0, d2	; 0x732c
	move.l	#$0000055e, a0	; 0x732e
	bra.w	setTileRectFromRam	; 0x7334

FUN_00007338:
	move.w	LBL_ff0850, d0	; 0x7338
	move.l	#$000004de, a3	; 0x733e
	move.l	#$000004ee, a4	; 0x7344
	bra.w	skip_278	; 0x734a

FUN_7338:
	move.w	LBL_ff0852, d0	; 0x734e
	move.l	#$0000055e, a3	; 0x7354
	move.l	#$0000056e, a4	; 0x735a

skip_278:
	tst.b	(4, a6)	; 0x7360
	beq.w	@loc_00007380	; 0x7364
	move.w	a3, a0	; 0x7368
	moveq	#4, d1	; 0x736a
	moveq	#0, d2	; 0x736c
	bsr.w	setTileRectFromRam	; 0x736e
	move.w	a4, a0	; 0x7372
	move.w	#$a000, d0	; 0x7374
	moveq	#2, d1	; 0x7378
	moveq	#0, d2	; 0x737a
	bra.w	setTileRectFromRam	; 0x737c
@loc_00007380:
	move.w	a4, a0	; 0x7380
	moveq	#2, d1	; 0x7382
	moveq	#0, d2	; 0x7384
	bsr.w	setTileRectFromRam	; 0x7386
	move.w	a3, a0	; 0x738a
	move.w	#$a000, d0	; 0x738c
	moveq	#4, d1	; 0x7390
	moveq	#0, d2	; 0x7392
	bra.w	setTileRectFromRam	; 0x7394

FUN_00007398:
	lea	LBL_ff0848, a4	; 0x7398
	moveq	#0, d0	; 0x739e
	move.b	LBL_ff0859, d0	; 0x73a0
	add.w	d0, d0	; 0x73a6
	move.w	(updateMenuItems, pc, d0.w), d0	; 0x73a8
	jmp	(updateMenuItems, pc, d0.w)	; 0x73ac

updateMenuItems:
	dc.w	updateMenuItemDifficulty-updateMenuItems	; 0x73b0
	dc.w	updateMenuItemTimeLimite-updateMenuItems	; 0x73b2
	dc.w	updateMenuItemTimeKeyConfig-updateMenuItems	; 0x73b4
	dc.w	updateMenuItemSuperMode-updateMenuItems	; 0x73b6
	dc.w	updateMenuItem04-updateMenuItems	; 0x73b8
	dc.w	updateMenuItem05-updateMenuItems	; 0x73ba
	dc.w	updateMenuItem06-updateMenuItems	; 0x73bc

updateMenuItemDifficulty:
	lea	(a4), a0	; 0x73be
	bra.b	continue	; 0x73c0

updateMenuItemTimeLimite:
	lea	(2, a4), a0	; 0x73c2
	bra.b	continue	; 0x73c6

updateMenuItemTimeKeyConfig:
	move.l	#$00ff0800, a6	; 0x73c8
	bsr.w	FUN_000073dc	; 0x73ce
	move.l	#$00ff0820, a6	; 0x73d2
	bra.w	FUN_000073dc	; 0x73d8

FUN_000073dc:
	moveq	#0, d0	; 0x73dc
	move.b	(3, a6), d0	; 0x73de
	add.w	d0, d0	; 0x73e2
	btst	#5, (a6)	; 0x73e4
	beq.w	@plane_b	; 0x73e8
	move.w	#$c000, (16, a6, d0)	; 0x73ec
	rts		; 0x73f2
@plane_b:
	move.w	#$e000, (16, a6, d0)	; 0x73f4

updateMenuItem06:
	rts		; 0x73fa

updateMenuItemSuperMode:
	lea	(6, a4), a0	; 0x73fc
	bra.w	continue	; 0x7400

updateMenuItem04:
	lea	(8, a4), a0	; 0x7404
	bra.w	continue	; 0x7408

updateMenuItem05:
	lea	(10, a4), a0	; 0x740c
	bra.w	continue	; 0x7410

continue:
	btst	#5, LBL_ff0858	; 0x7414
	beq.w	plane_b_2	; 0x741c
	move.w	#$c000, (a0)	; 0x7420
	rts		; 0x7424

plane_b_2:
	move.w	#$e000, (a0)	; 0x7426
	rts		; 0x742a

updateOptionScrolling:
	move.w	(LBL_ffff9b8c).w, d0	; 0x742c
	move.w	LBL_ff0856, d1	; 0x7430
	eori.w	#1, d1	; 0x7436
	sub.w	d1, d0	; 0x743a
	andi.w	#$01ff, d0	; 0x743c
	move.w	d1, LBL_ff0856	; 0x7440
	move.w	d0, (LBL_ffff9b8c).w	; 0x7446
	st	(flagProcessVSRAM).w	; 0x744a
	rts		; 0x744e

drawString:
	move.w	a0, d2	; 0x7450
	ori.l	#$ffff0000, d2	; 0x7452
	move.l	d2, a0	; 0x7458
	lea	($764a, pc), a1	; 0x745a
	add.w	d1, d1	; 0x745e
	moveq	#0, d2	; 0x7460
	move.w	(0, a1, d1), d2	; 0x7462
	lea	(0, a1, d2.l), a1	; 0x7466
	move.l	a0, a2	; 0x746a
@loop:
	move.b	(a1)+, d0	; 0x746c
	beq.w	@return	; 0x746e
	cmpi.b	#$ff, d0	; 0x7472
	bne.w	@exit	; 0x7476
	lea	(64, a2), a0	; 0x747a
	move.l	a0, a2	; 0x747e
	bra.b	@loop	; 0x7480
@exit:
	move.w	d0, (a0)+	; 0x7482
	bra.b	@loop	; 0x7484
@return:
	rts		; 0x7486

updateOptionTilemap:
	move.w	(ptrLastUpdatableBgArea).w, a0	; 0x7488
	move.w	#$6000, (a0)+	; 0x748c
	move.b	#$1f, (a0)+	; 0x7490
	move.b	#$1f, (a0)+	; 0x7494
	move.l	#$00ff0000, (a0)+	; 0x7498
	move.w	a0, (ptrLastUpdatableBgArea).w	; 0x749e
	rts		; 0x74a2

setTileRectFromRam:
	move.w	a0, d4	; 0x74a4
	ori.l	#$ffff0000, d4	; 0x74a6
	move.l	d4, a0	; 0x74ac
	move.w	d1, d3	; 0x74ae
	move.l	a0, a1	; 0x74b0
@next:
	move.w	(a0), d4	; 0x74b2
	andi.w	#$9fff, d4	; 0x74b4
	or.w	d0, d4	; 0x74b8
	move.w	d4, (a0)+	; 0x74ba
	dbf	d1, @next	; 0x74bc
	lea	(64, a1), a1	; 0x74c0
	move.l	a1, a0	; 0x74c4
	move.w	d3, d1	; 0x74c6
	dbf	d2, @next	; 0x74c8
	rts		; 0x74cc

optionMenuDrawBackground:
	move.l	#$60400003, d0	; 0x74ce
	moveq	#7, d5	; 0x74d4
	bsr.w	drawBgHalf1	; 0x74d6
	move.l	#$60600003, d0	; 0x74da
	moveq	#7, d5	; 0x74e0
	bsr.w	drawBgHalf1	; 0x74e2
	move.l	#$60500003, d0	; 0x74e6
	moveq	#7, d5	; 0x74ec
	bsr.w	drawBgHalf2	; 0x74ee
	move.l	#$60700003, d0	; 0x74f2
	moveq	#7, d5	; 0x74f8
	bra.b	drawBgHalf2	; 0x74fa

drawBgHalf1:
	lea	($78b6, pc), a0	; 0x74fc
	bsr.w	draw64by64PixelsBlock	; 0x7500
	addi.l	#$04000000, d2	; 0x7504
	subq.b	#1, d5	; 0x750a
	bmi.w	return_274	; 0x750c

drawBgHalf2:
	lea	($7936, pc), a0	; 0x7510
	bsr.w	draw64by64PixelsBlock	; 0x7514
	addi.l	#$04000000, d2	; 0x7518
	subq.b	#1, d5	; 0x751e
	bmi.w	return_274	; 0x7520
	bra.b	drawBgHalf1	; 0x7524

return_274:
	rts		; 0x7526

draw64by64PixelsBlock:
	moveq	#7, d6	; 0x7528
@next2:
	move.l	d0, (4, a5)	; 0x752a
	moveq	#7, d7	; 0x752e
@next1:
	move.w	(a0)+, (a5)	; 0x7530
	dbf	d7, @next1	; 0x7532
	addi.l	#$00800000, d0	; 0x7536
	dbf	d6, @next2	; 0x753c
	rts		; 0x7540

optionMenuFadeIn:
	jsr	(fadeInStart).w	; 0x7542
	bra.b	optionMenuSkipFadeOut	; 0x7546

optionMenuFadeOut:
	jsr	(fadeOutStart).w	; 0x7548

optionMenuSkipFadeOut:
	move.b	#1, d0	; 0x754c
	trap	#3	; 0x7550
	bsr.w	updateOptionScrolling	; 0x7552
	bsr.w	FUN_00007398	; 0x7556
	tst.b	(fadingDelta).w	; 0x755a
	bne.b	optionMenuSkipFadeOut	; 0x755e
	rts		; 0x7560
	dc.w	$1000	; nb of bytes	; 0x7562
	dc.l	PATTERNS_381400/2	; source	; 0x7564
	dc.w	$1000	; destination in VRAM	; 0x7568
	; 0x-1
	dc.w	$E40	; nb of bytes	; 0x756a
	dc.l	PATTERNS_382880/2	; source	; 0x756c
	dc.w	$7000	; destination in VRAM	; 0x7570
	; 0x-1
	dc.w	$60	; nb of bytes	; 0x7572
	dc.l	PATTERNS_388e8c/2	; source	; 0x7574
	dc.w	$1F80	; destination in VRAM	; 0x7578
	; 0x-1
	dc.w	$B40	; nb of bytes	; 0x757a
	dc.l	PATTERNS_3b0fc0/2	; source	; 0x757c
	dc.w	$2200	; destination in VRAM	; 0x7580
	; 0x-1
	dc.w	$0000	; 0x7582

DATAS_7584:
	dc.w	DATA_758a-DATAS_7584	; 0x7584
	dc.w	DATA_75da-DATAS_7584	; 0x7586
	dc.w	DATA_7624-DATAS_7584	; 0x7588

DATA_758a:
	dc.w	$0094, $8300, $000d, $00a2, $8300, $000e, $0186, $a000, $0000, $019e, $a000, $0001, $0206, $a000, $0002, $021e, $a000, $0003, $022e, $a000, $0004, $0286, $a000, $0005, $030a, $a000, $0006, $0326, $a000, $0006, $0546, $a000, $0007, $055e, $a000, $0008, $056c, $a000, $0009, $ffff	; 0x758a

DATA_75da:
	dc.w	$010e, $8300, $000f, $0116, $8300, $0010, $0206, $a000, $0005, $028a, $a000, $0006, $02a6, $a000, $0006, $04c6, $a000, $0015, $0546, $a000, $0016, $04de, $a000, $000a, $055e, $a000, $000a, $04ec, $a000, $000b, $056c, $a000, $000b, $05c6, $a000, $000c, $ffff	; 0x75da

DATA_7624:
	dc.w	$010e, $8300, $000f, $0116, $8300, $0010, $028a, $a000, $0006, $02a6, $a000, $0006, $0206, $a000, $0005, $04c6, $a000, $000c, $ffff	; 0x7624

offsetsToStrings:
	dc.w	strDifficulty-offsetsToStrings	; 0x764a
	dc.w	strDifficultyStars-offsetsToStrings	; 0x764c
	dc.w	strTileLimit-offsetsToStrings	; 0x764e
	dc.w	strYes-offsetsToStrings	; 0x7650
	dc.w	strNo-offsetsToStrings	; 0x7652
	dc.w	strKeyConfig-offsetsToStrings	; 0x7654
	dc.w	strPlayer-offsetsToStrings	; 0x7656
	dc.w	strSuperMode-offsetsToStrings	; 0x7658
	dc.w	strNormal-offsetsToStrings	; 0x765a
	dc.w	strExpert-offsetsToStrings	; 0x765c
	dc.w	strHuman-offsetsToStrings	; 0x765e
	dc.w	strCom-offsetsToStrings	; 0x7660
	dc.w	strExit-offsetsToStrings	; 0x7662
	dc.w	strJapaneseText1-offsetsToStrings	; 0x7664
	dc.w	strJapaneseText2-offsetsToStrings	; 0x7666
	dc.w	strJapaneseText3-offsetsToStrings	; 0x7668
	dc.w	strJapaneseText4-offsetsToStrings	; 0x766a
	dc.w	strLPunch_MPunch_HPunch_LKick_MKick_HKick-offsetsToStrings	; 0x766c
	dc.w	strLAttack_MAttack_HAttack_Switch-offsetsToStrings	; 0x766e
	dc.w	strNoSupport-offsetsToStrings	; 0x7670
	dc.w	strNoConnect-offsetsToStrings	; 0x7672
	dc.w	str1Player-offsetsToStrings	; 0x7674
	dc.w	str2Player-offsetsToStrings	; 0x7676
	dc.w	strComputer-offsetsToStrings	; 0x7678

strDifficulty:
	dc.b	"DIFFICULTY", $00	; 0x767a

strDifficultyStars:
	dc.b	"L $$$$$$$$ H", $00	; 0x7685

strTileLimit:
	dc.b	"TIME LIMIT", $00	; 0x7692

strYes:
	dc.b	"YES", $00	; 0x769d

strNo:
	dc.b	"NO", $00	; 0x76a1

strKeyConfig:
	dc.b	"KEY CONFIG.", $00	; 0x76a4

strPlayer:
	dc.b	"PLAYER", $00	; 0x76b0

strSuperMode:
	dc.b	"SUPER MODE", $00	; 0x76b7

strNormal:
	dc.b	"NORMAL", $00	; 0x76c2

strExpert:
	dc.b	"EXPERT", $00	; 0x76c9

strHuman:
	dc.b	"HUMAN", $00	; 0x76d0

strCom:
	dc.b	" COM ", $00	; 0x76d6

strExit:
	dc.b	"EXIT", $00	; 0x76dc

str1Player:
	dc.b	"1PLAYER", $00	; 0x76e1

str2Player:
	dc.b	"2PLAYER", $00	; 0x76e9

strJapaneseText1:
	dc.b	$9e, $a0, $a8, $92, $9e, $9c, $ff, $9f, $a1, $a9, $93, $9f, $9d, $00	; 0x76f1

strJapaneseText2:
	dc.b	$9a, $9e, $88, $8a, $ff, $9b, $9f, $89, $8b, $00	; 0x76ff

strJapaneseText3:
	dc.b	$96, $8a, $b2, $ff, $97, $8b, $b3, $00	; 0x7709

strJapaneseText4:
	dc.b	$86, $9e, $9c, $8c, $92, $8e, $aa, $a4, $82, $a8, $92, $9e, $9c, $ff, $87, $9f, $9d, $8d, $93, $8f, $ab, $a5, $83, $a9, $93, $9f, $9d, $00	; 0x7711

strLPunch_MPunch_HPunch_LKick_MKick_HKick:
	dc.b	" L.PUNCH ", $ff, " M.PUNCH ", $ff, " H.PUNCH ", $ff, " L.KICK  ", $ff, " M.KICK  ", $ff, " H.KICK  ", $00	; 0x772d

strLAttack_MAttack_HAttack_Switch:
	dc.b	" L.ATTACK", $ff, " M.ATTACK", $ff, " H.ATTACK", $ff, " SWITCH  ", $ff, "         ", $ff, "         ", $00	; 0x7769

strNoSupport:
	dc.b	"            ", $ff, "            ", $ff, " NO SUPPORT ", $ff, "            ", $ff, "            ", $ff, "            ", $00	; 0x77a5

strNoConnect:
	dc.b	"            ", $ff, "            ", $ff, " NO CONNECT ", $ff, "            ", $ff, "            ", $ff, "            ", $00	; 0x77f3

strComputer:
	dc.b	"            ", $ff, "            ", $ff, "            ", $ff, "            ", $ff, "            ", $ff, "  COMPUTER  ", $ff, "            ", $ff, "            ", $ff, "            ", $00	; 0x7841

tilemapBgHalf1:
	dc.w	$000a, $000a, $000a, $000a, $000a, $000a, $011e, $011f, $0114, $0115, $0116, $0112, $0128, $0129, $012a, $012b, $0124, $0125, $0126, $0122, $0138, $0139, $013a, $013b, $0134, $0135, $0136, $0132, $0148, $0149, $014a, $014b, $0144, $0125, $0126, $0145, $0153, $0154, $0155, $0156, $011b, $011c, $011d, $0146, $015b, $015c, $015d, $015e, $000a, $000a, $000a, $000a, $000a, $000a, $0147, $0150, $000a, $000a, $000a, $000a, $000a, $000a, $000a, $000a	; 0x78b6

tilemapBgHalf2:
	dc.w	$0127, $0137, $000a, $000a, $000a, $000a, $000a, $000a, $012c, $012d, $012e, $0128, $0110, $0111, $0142, $0113, $013c, $013d, $013e, $013f, $0120, $0121, $0142, $0123, $014c, $014d, $014e, $014f, $0130, $0131, $0142, $0133, $0157, $0158, $0159, $015a, $0140, $0141, $0142, $0143, $015f, $0160, $0161, $012f, $0117, $0118, $0119, $011a, $0151, $0152, $000a, $000a, $000a, $000a, $000a, $000a, $000a, $000a, $000a, $000a, $000a, $000a, $000a, $000a	; 0x7936