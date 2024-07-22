
initSoundDriver:
	lea	Z80_busRequest, a4	; 0x4c44
	lea	Z80_reset, a6	; 0x4c4a
	move.w	#0, d6	; 0x4c50
	move.w	#$0100, d7	; 0x4c54
	move.w	d7, (a4)	; 0x4c58
	move.w	d7, (a6)	; 0x4c5a
@wait_z80:
	btst	d6, (a4)	; 0x4c5c
	bne.b	@wait_z80	; 0x4c5e
	move.l	#$00a00000, a1	; 0x4c60
	move.w	#$1fff, d0	; 0x4c66
@next1:
	move.b	d6, (a1)+	; 0x4c6a
	dbf	d0, @next1	; 0x4c6c
	move.l	#$00a00000, a1	; 0x4c70
@z80_code_:
	move.l	#$00030b1e, a0	; 0x4c76
	move.w	#$0160, d0	; 0x4c7c
@next2:
	move.b	(a0)+, (a1)+	; 0x4c80
	dbf	d0, @next2	; 0x4c82
	move.l	#$00a01000, a1	; 0x4c86
	move.l	#$002cf000, a0	; 0x4c8c
	move.w	#$0527, d0	; 0x4c92
@next3:
	move.b	(a0)+, (a1)+	; 0x4c96
	dbf	d0, @next3	; 0x4c98
	move.w	d6, (a6)	; 0x4c9c
	nop		; 0x4c9e
	nop		; 0x4ca0
	nop		; 0x4ca2
	nop		; 0x4ca4
	nop		; 0x4ca6
	nop		; 0x4ca8
	nop		; 0x4caa
	nop		; 0x4cac
	nop		; 0x4cae
	nop		; 0x4cb0
	nop		; 0x4cb2
	nop		; 0x4cb4
	nop		; 0x4cb6
	nop		; 0x4cb8
	move.w	d7, (a6)	; 0x4cba
	move.l	#$00a04000, a3	; 0x4cbc
	lea	($4d56, pc), a0	; 0x4cc2
	moveq	#9, d0	; 0x4cc6
@next4:
	btst	#7, (a3)	; 0x4cc8
	bne.b	@next4	; 0x4ccc
	move.b	(a0)+, (a3)	; 0x4cce
	nop		; 0x4cd0
@wait_sound_driver:
	btst	#7, (a3)	; 0x4cd2
	bne.b	@wait_sound_driver	; 0x4cd6
	move.b	(a0)+, (1, a3)	; 0x4cd8
	dbf	d0, @next4	; 0x4cdc
	moveq	#6, d0	; 0x4ce0
@next6:
	move.b	(a0)+, d3	; 0x4ce2
	move.b	(a0)+, d4	; 0x4ce4
	moveq	#3, d1	; 0x4ce6
@next5:
	moveq	#2, d2	; 0x4ce8
@wait_sound_driver_2:
	btst	#7, (a3)	; 0x4cea
	bne.b	@wait_sound_driver_2	; 0x4cee
	move.b	d3, (a3)	; 0x4cf0
	nop		; 0x4cf2
@wait_sound_driver_3:
	btst	#7, (a3)	; 0x4cf4
	bne.b	@wait_sound_driver_3	; 0x4cf8
	move.b	d4, (1, a3)	; 0x4cfa
	nop		; 0x4cfe
@wait_sound_driver_4:
	btst	#7, (a3)	; 0x4d00
	bne.b	@wait_sound_driver_4	; 0x4d04
	move.b	d3, (2, a3)	; 0x4d06
	nop		; 0x4d0a
@wait_sound_driver_5:
	btst	#7, (a3)	; 0x4d0c
	bne.b	@wait_sound_driver_5	; 0x4d10
	move.b	d4, (3, a3)	; 0x4d12
	addq.b	#1, d3	; 0x4d16
	dbf	d2, @wait_sound_driver_2	; 0x4d18
	addq.b	#1, d3	; 0x4d1c
	dbf	d1, @next5	; 0x4d1e
	dbf	d0, @next6	; 0x4d22
@wait_sound_driver_6:
	btst	#7, (a3)	; 0x4d26
	bne.b	@wait_sound_driver_6	; 0x4d2a
	move.b	#$b6, (2, a3)	; 0x4d2c
	nop		; 0x4d32
@wait_sound_driver_7:
	btst	#7, (a3)	; 0x4d34
	bne.b	@wait_sound_driver_7	; 0x4d38
	move.b	#$c0, (3, a3)	; 0x4d3a
	move.w	d6, (a4)	; 0x4d40
	move.l	#$00c00011, a3	; 0x4d42
	lea	($4d78, pc), a0	; 0x4d48
	moveq	#4, d0	; 0x4d4c
@next7:
	move.b	(a0)+, (a3)	; 0x4d4e
	dbf	d0, @next7	; 0x4d50
	rts		; 0x4d54

ym2612InitData:
	dc.b	$22, $00, $27, $00, $28, $00, $28, $01, $28, $02, $28, $04, $28, $05, $28, $06, $2b, $80, $2a, $80, $30, $00, $40, $7f, $50, $1f, $60, $00, $70, $00, $80, $ff, $90, $00	; 0x4d56

PsgInitData:
	dc.b	$9f, $bf, $df, $e3, $ff, $a1	; 0x4d78

updateBgm:
	lea	Z80_busRequest, a4	; 0x4d7e
	lea	LBL_a04000, a5	; 0x4d84
	move.w	#0, d6	; 0x4d8a
	move.w	#$0100, d7	; 0x4d8e
	move.w	(LBL_ffffc8c8).w, d0	; 0x4d92
	add.w	(LBL_ffffc8ca).w, d0	; 0x4d96
	move.w	d0, (LBL_ffffc8cc).w	; 0x4d9a
	lea	(YmChannel1).w, a3	; 0x4d9e
	moveq	#8, d5	; 0x4da2
@next_channel:
	clr.b	(LBL_ffffc8c2).w	; 0x4da4
	clr.b	(LBL_ffffc8c6).w	; 0x4da8
	tst.l	(a3)	; 0x4dac
	beq.b	@continue1	; 0x4dae
	move.w	(36, a3), (duration_frame).w	; 0x4db0
	bsr.w	FUN_000056aa	; 0x4db6
	tst.l	(a3)	; 0x4dba
	beq.b	@continue1	; 0x4dbc
	st	(LBL_ffffc8c6).w	; 0x4dbe
@continue1:
	st	(LBL_ffffc8c2).w	; 0x4dc2
	lea	(40, a3), a3	; 0x4dc6
	tst.b	(LBL_ffffc8c7).w	; 0x4dca
	bne.b	@continue2	; 0x4dce
	tst.l	(a3)	; 0x4dd0
	beq.b	@continue2	; 0x4dd2
	move.w	(LBL_ffffc8cc).w, (duration_frame).w	; 0x4dd4
	bsr.w	FUN_000056aa	; 0x4dda
@continue2:
	lea	(40, a3), a3	; 0x4dde
	dbf	d5, @next_channel	; 0x4de2
	tst.b	(LBL_ffffc8d4).w	; 0x4de6
	beq.b	@return	; 0x4dea
	move.w	(LBL_ffffc8d0).w, d0	; 0x4dec
	sub.w	d0, (LBL_ffffc8d2).w	; 0x4df0
	bcc.b	@return	; 0x4df4
	clr.w	(LBL_ffffc8d2).w	; 0x4df6
@return:
	rts		; 0x4dfa

setBgm:
	lea	Z80_busRequest, a4	; 0x4dfc
	lea	LBL_a04000, a5	; 0x4e02
	move.w	#0, d6	; 0x4e08
	move.w	#$0100, d7	; 0x4e0c
	cmpi.b	#$f0, d0	; 0x4e10
	bcc.w	@special_code	; 0x4e14
@loop1:
	cmp.b	nb_of_bgms, d0	; 0x4e18
	bcs.b	@exit	; 0x4e1e
	sub.b	nb_of_bgms, d0	; 0x4e20
	bra.b	@loop1	; 0x4e26
@exit:
	andi.w	#$00ff, d0	; 0x4e28
	add.w	d0, d0	; 0x4e2c
	add.w	d0, d0	; 0x4e2e
	lea	ptrs_to_bgms, a0	; 0x4e30
	move.l	(0, a0, d0), a0	; 0x4e36
	move.l	a0, d0	; 0x4e3a
	bne.b	@not_null	; 0x4e3c
	rts		; 0x4e3e
@not_null:
	move.l	a0, a1	; 0x4e40
	move.b	(a0)+, d4	; 0x4e42
	beq.b	@loc_00004E92	; 0x4e44
	lea	(YmChannel1).w, a3	; 0x4e46
	moveq	#8, d5	; 0x4e4a
@next_channel:
	moveq	#0, d3	; 0x4e4c
	move.b	(a0)+, d3	; 0x4e4e
	lsl.w	#8, d3	; 0x4e50
	move.b	(a0)+, d3	; 0x4e52
	tst.w	d3	; 0x4e54
	beq.b	@continue	; 0x4e56
	cmp.b	(38, a3), d4	; 0x4e58
	bcs.b	@continue	; 0x4e5c
	move.l	a3, a2	; 0x4e5e
	moveq	#$0027, d0	; 0x4e60
	moveq	#0, d1	; 0x4e62
@next1:
	move.b	d1, (a2)+	; 0x4e64
	dbf	d0, @next1	; 0x4e66
	move.b	d4, (38, a3)	; 0x4e6a
	add.l	a1, d3	; 0x4e6e
	move.l	d3, (a3)	; 0x4e70
	bset	#0, (32, a3)	; 0x4e72
	cmpi.b	#3, d5	; 0x4e78
	bcc.b	@mute	; 0x4e7c
	move.b	#7, (27, a3)	; 0x4e7e
@mute:
	bsr.w	muteFmChannel	; 0x4e84
@continue:
	lea	(80, a3), a3	; 0x4e88
	dbf	d5, @next_channel	; 0x4e8c
	rts		; 0x4e90
@loc_00004E92:
	lea	(LBL_ffffc61a).w, a3	; 0x4e92
	moveq	#8, d5	; 0x4e96
@next_channel_2:
	move.l	(a3), d4	; 0x4e98
	move.l	a3, a2	; 0x4e9a
	moveq	#$0027, d0	; 0x4e9c
	moveq	#0, d1	; 0x4e9e
@next2:
	move.b	d1, (a2)+	; 0x4ea0
	dbf	d0, @next2	; 0x4ea2
	moveq	#0, d3	; 0x4ea6
	move.b	(a0)+, d3	; 0x4ea8
	lsl.w	#8, d3	; 0x4eaa
	move.b	(a0)+, d3	; 0x4eac
	tst.w	d3	; 0x4eae
	beq.b	@continue3	; 0x4eb0
	add.l	a1, d3	; 0x4eb2
	move.l	d3, (a3)	; 0x4eb4
	bset	#0, (32, a3)	; 0x4eb6
	move.b	#$c0, (39, a3)	; 0x4ebc
	cmpi.b	#3, d5	; 0x4ec2
	bcc.b	@continue3	; 0x4ec6
	move.b	#7, (27, a3)	; 0x4ec8
@continue3:
	tst.l	d4	; 0x4ece
	beq.b	@dont_mute	; 0x4ed0
	lea	(-40, a3), a2	; 0x4ed2
	tst.l	(a2)	; 0x4ed6
	bne.b	@dont_mute	; 0x4ed8
	bsr.w	muteFmChannel	; 0x4eda
@dont_mute:
	lea	(80, a3), a3	; 0x4ede
	dbf	d5, @next_channel_2	; 0x4ee2
	moveq	#0, d0	; 0x4ee6
	move.b	#$ff, d0	; 0x4ee8
	moveq	#0, d1	; 0x4eec
	move.b	LBL_090001, d1	; 0x4eee
	mulu.w	d0, d1	; 0x4ef4
	lsr.w	#8, d1	; 0x4ef6
	move.b	d1, (LBL_ffffc8d6).w	; 0x4ef8
	move.b	LBL_090001, d0	; 0x4efc
	eori.b	#$7f, d0	; 0x4f02
	move.b	d0, (LBL_ffffc8d7).w	; 0x4f06
	clr.b	(LBL_ffffc8d5).w	; 0x4f0a
	clr.w	(LBL_ffffc8ca).w	; 0x4f0e
	clr.b	(LBL_ffffc8d4).w	; 0x4f12
	rts		; 0x4f16
@special_code:
	andi.w	#7, d0	; 0x4f18
	add.w	d0, d0	; 0x4f1c
	move.w	(specialCodesFunctions, pc, d0.w), d0	; 0x4f1e
	jmp	(specialCodesFunctions, pc, d0.w)	; 0x4f22

specialCodesFunctions:
	dc.w	specialCode00-specialCodesFunctions	; 0x4f26
	dc.w	specialCode01-specialCodesFunctions	; 0x4f28
	dc.w	specialCode02-specialCodesFunctions	; 0x4f2a
	dc.w	specialCode03-specialCodesFunctions	; 0x4f2c
	dc.w	specialCode04-specialCodesFunctions	; 0x4f2e
	dc.w	specialCode05-specialCodesFunctions	; 0x4f30
	dc.w	specialCode06-specialCodesFunctions	; 0x4f32
	dc.w	specialCode07-specialCodesFunctions	; 0x4f34

specialCode00:
	lea	(YmChannel1).w, a3	; 0x4f36
	moveq	#0, d4	; 0x4f3a
	moveq	#8, d5	; 0x4f3c
@next4:
	move.l	d4, (a3)	; 0x4f3e
	lea	(40, a3), a3	; 0x4f40
	move.l	d4, (a3)	; 0x4f44
	lea	(40, a3), a3	; 0x4f46
	bsr.w	muteFmChannel	; 0x4f4a
	dbf	d5, @next4	; 0x4f4e
	rts		; 0x4f52

specialCode01:
	lea	(YmChannel1).w, a3	; 0x4f54
	moveq	#8, d5	; 0x4f58
@next5:
	move.l	(a3), d0	; 0x4f5a
	move.l	#0, (a3)	; 0x4f5c
	clr.b	(38, a3)	; 0x4f62
	lea	(40, a3), a3	; 0x4f66
	tst.l	d0	; 0x4f6a
	beq.b	@continue5	; 0x4f6c
	bsr.w	muteFmChannel	; 0x4f6e
	tst.l	(a3)	; 0x4f72
	beq.b	@continue5	; 0x4f74
	st	(37, a3)	; 0x4f76
	cmpi.b	#3, d5	; 0x4f7a
	bcs.b	@continue5	; 0x4f7e
	moveq	#8, d0	; 0x4f80
	sub.b	d5, d0	; 0x4f82
	move.b	d0, d1	; 0x4f84
	add.b	d1, d1	; 0x4f86
	andi.b	#2, d1	; 0x4f88
	move.b	d1, (LBL_ffffc8c3).w	; 0x4f8c
	move.b	d0, d1	; 0x4f90
	lsr.b	#1, d1	; 0x4f92
	andi.b	#3, d1	; 0x4f94
	move.b	d1, (LBL_ffffc8c4).w	; 0x4f98
	moveq	#0, d0	; 0x4f9c
	move.b	(38, a3), d0	; 0x4f9e
	moveq	#$0020, d4	; 0x4fa2
	mulu.w	d0, d4	; 0x4fa4
	lea	LBL_09f000, a1	; 0x4fa6
	adda.w	d4, a1	; 0x4fac
	bsr.w	loadFmInstrument	; 0x4fae
	move.b	(39, a3), d0	; 0x4fb2
	bsr.w	setFmFrequency	; 0x4fb6
@continue5:
	lea	(40, a3), a3	; 0x4fba
	dbf	d5, @next5	; 0x4fbe
	rts		; 0x4fc2

specialCode02:
	andi.w	#$000f, d1	; 0x4fc4
	moveq	#$0050, d0	; 0x4fc8
	mulu.w	d1, d0	; 0x4fca
	lea	(YmChannel1).w, a3	; 0x4fcc
	adda.w	d0, a3	; 0x4fd0
	move.w	d1, d5	; 0x4fd2
	move.l	(a3), d0	; 0x4fd4
	move.l	#0, (a3)	; 0x4fd6
	clr.b	(38, a3)	; 0x4fdc
	lea	(40, a3), a3	; 0x4fe0
	tst.l	d0	; 0x4fe4
	beq.b	@return	; 0x4fe6
	bsr.w	muteFmChannel	; 0x4fe8
	tst.l	(a3)	; 0x4fec
	beq.b	@return	; 0x4fee
	st	(37, a3)	; 0x4ff0
	cmpi.b	#3, d5	; 0x4ff4
	bcs.b	@return	; 0x4ff8
	moveq	#8, d0	; 0x4ffa
	sub.b	d5, d0	; 0x4ffc
	move.b	d0, d1	; 0x4ffe
	add.b	d1, d1	; 0x5000
	andi.b	#2, d1	; 0x5002
	move.b	d1, (LBL_ffffc8c3).w	; 0x5006
	move.b	d0, d1	; 0x500a
	lsr.b	#1, d1	; 0x500c
	andi.b	#3, d1	; 0x500e
	move.b	d1, (LBL_ffffc8c4).w	; 0x5012
	moveq	#0, d0	; 0x5016
	move.b	(38, a3), d0	; 0x5018
	moveq	#$0020, d4	; 0x501c
	mulu.w	d0, d4	; 0x501e
	lea	LBL_09f000, a1	; 0x5020
	adda.w	d4, a1	; 0x5026
	bsr.w	loadFmInstrument	; 0x5028
	move.b	(39, a3), d0	; 0x502c
	bsr.w	setFmFrequency	; 0x5030
@return:
	rts		; 0x5034

specialCode03:
	lea	(YmChannel1).w, a3	; 0x5036
	moveq	#0, d4	; 0x503a
	moveq	#8, d5	; 0x503c
@next6:
	move.l	(a3), d0	; 0x503e
	lea	(40, a3), a3	; 0x5040
	move.l	d4, (a3)	; 0x5044
	lea	(40, a3), a3	; 0x5046
	tst.l	d0	; 0x504a
	bne.b	@dont_mute_2	; 0x504c
	bsr.w	muteFmChannel	; 0x504e
@dont_mute_2:
	dbf	d5, @next6	; 0x5052
	rts		; 0x5056

specialCode04:
	st	(LBL_ffffc8c7).w	; 0x5058
	bsr.w	waitPcmProcessed	; 0x505c
	lea	(YmChannel1).w, a3	; 0x5060
	moveq	#5, d5	; 0x5064
@next7:
	tst.l	(a3)	; 0x5066
	lea	(40, a3), a3	; 0x5068
	bne.b	@continue7	; 0x506c
	tst.l	(a3)	; 0x506e
	beq.b	@continue7	; 0x5070
	moveq	#5, d0	; 0x5072
	sub.b	d5, d0	; 0x5074
	move.b	d0, d2	; 0x5076
	add.b	d2, d2	; 0x5078
	andi.w	#2, d2	; 0x507a
	move.b	d0, d3	; 0x507e
	lsr.b	#1, d3	; 0x5080
	andi.b	#3, d3	; 0x5082
	addi.b	#$40, d3	; 0x5086
	moveq	#3, d1	; 0x508a
@next6:
	nop		; 0x508c
@wait_sound_driver_1:
	btst	#7, (a5)	; 0x508e
	bne.b	@wait_sound_driver_1	; 0x5092
	move.b	d3, (0, a5, d2)	; 0x5094
	nop		; 0x5098
@wait_sound_driver_2:
	btst	#7, (a5)	; 0x509a
	bne.b	@wait_sound_driver_2	; 0x509e
	move.b	#$7f, (1, a5, d2)	; 0x50a0
	addq.b	#4, d3	; 0x50a6
	dbf	d1, @next6	; 0x50a8
@continue7:
	lea	(40, a3), a3	; 0x50ac
	dbf	d5, @next7	; 0x50b0
	move.w	d6, (a4)	; 0x50b4
	moveq	#2, d5	; 0x50b6
@next8:
	tst.l	(a3)	; 0x50b8
	lea	(40, a3), a3	; 0x50ba
	bne.b	@continue8	; 0x50be
	tst.l	(a3)	; 0x50c0
	beq.b	@continue8	; 0x50c2
	moveq	#2, d0	; 0x50c4
	sub.b	d5, d0	; 0x50c6
	lsl.b	#5, d0	; 0x50c8
	ori.b	#$9f, d0	; 0x50ca
	move.b	d0, LBL_c00011	; 0x50ce
	tst.b	d5	; 0x50d4
	bne.b	@continue8	; 0x50d6
	move.b	#$e3, LBL_c00011	; 0x50d8
	move.b	#$ff, LBL_c00011	; 0x50e0
@continue8:
	lea	(40, a3), a3	; 0x50e8
	dbf	d5, @next8	; 0x50ec
	rts		; 0x50f0

specialCode05:
	clr.b	(LBL_ffffc8c7).w	; 0x50f2
	lea	(LBL_ffffc61a).w, a3	; 0x50f6
	moveq	#5, d5	; 0x50fa
@next9:
	tst.l	(a3)	; 0x50fc
	beq.b	@continue9	; 0x50fe
	st	(37, a3)	; 0x5100
@continue9:
	lea	(80, a3), a3	; 0x5104
	dbf	d5, @next9	; 0x5108
	rts		; 0x510c

specialCode06:
	andi.w	#$00ff, d1	; 0x510e
	move.w	d1, (LBL_ffffc8d0).w	; 0x5112
	move.w	#$ffff, (LBL_ffffc8d2).w	; 0x5116
	st	(LBL_ffffc8d4).w	; 0x511c
	rts		; 0x5120

specialCode07:
	move.w	#$0369, d0	; 0x5122
	andi.w	#$00ff, d1	; 0x5126
	mulu.w	d0, d1	; 0x512a
	lsr.l	#8, d1	; 0x512c
	move.w	d1, (LBL_ffffc8ca).w	; 0x512e
	rts		; 0x5132

muteFmChannel:
	cmpi.b	#3, d5	; 0x5134
	bcs.w	@psg	; 0x5138
	moveq	#8, d0	; 0x513c
	sub.b	d5, d0	; 0x513e
	move.b	d0, d2	; 0x5140
	add.b	d2, d2	; 0x5142
	andi.w	#2, d2	; 0x5144
	move.b	d0, d3	; 0x5148
	lsr.b	#1, d3	; 0x514a
	andi.b	#3, d3	; 0x514c
	bsr.w	waitPcmProcessed	; 0x5150
	move.b	d3, d1	; 0x5154
	addi.b	#$40, d1	; 0x5156
	moveq	#3, d0	; 0x515a
@next:
	nop		; 0x515c
@wait_sound_driver:
	btst	#7, (a5)	; 0x515e
	bne.b	@wait_sound_driver	; 0x5162
	move.b	d1, (0, a5, d2)	; 0x5164
	nop		; 0x5168
@wait_sound_driver_2:
	btst	#7, (a5)	; 0x516a
	bne.b	@wait_sound_driver_2	; 0x516e
	move.b	#$7f, (1, a5, d2)	; 0x5170
	addq.b	#4, d1	; 0x5176
	dbf	d0, @next	; 0x5178
	move.b	d3, d1	; 0x517c
	addi.b	#$b4, d1	; 0x517e
	moveq	#3, d0	; 0x5182
@next2:
	nop		; 0x5184
@wait_sound_driver_3:
	btst	#7, (a5)	; 0x5186
	bne.b	@wait_sound_driver_3	; 0x518a
	move.b	d1, (0, a5, d2)	; 0x518c
	nop		; 0x5190
@wait_sound_driver_4:
	btst	#7, (a5)	; 0x5192
	bne.b	@wait_sound_driver_4	; 0x5196
	move.b	#$c0, (1, a5, d2)	; 0x5198
	addq.b	#4, d1	; 0x519e
	dbf	d0, @next2	; 0x51a0
	move.b	d3, d1	; 0x51a4
	addi.b	#$80, d1	; 0x51a6
	moveq	#3, d0	; 0x51aa
@next3:
	nop		; 0x51ac
@wait_sound_driver_5:
	btst	#7, (a5)	; 0x51ae
	bne.b	@wait_sound_driver_5	; 0x51b2
	move.b	d1, (0, a5, d2)	; 0x51b4
	nop		; 0x51b8
@wait_sound_driver_6:
	btst	#7, (a5)	; 0x51ba
	bne.b	@wait_sound_driver_6	; 0x51be
	move.b	#$0f, (1, a5, d2)	; 0x51c0
	addq.b	#4, d1	; 0x51c6
	dbf	d0, @next3	; 0x51c8
	add.b	d2, d2	; 0x51cc
	or.b	d3, d2	; 0x51ce
	nop		; 0x51d0
@wait_sound_driver_7:
	btst	#7, (a5)	; 0x51d2
	bne.b	@wait_sound_driver_7	; 0x51d6
	move.b	#$28, d1	; 0x51d8
	move.b	d1, (a5)	; 0x51dc
	nop		; 0x51de
@wait_sound_driver_8:
	btst	#7, (a5)	; 0x51e0
	bne.b	@wait_sound_driver_8	; 0x51e4
	move.b	d2, (1, a5)	; 0x51e6
	move.w	d6, (a4)	; 0x51ea
	rts		; 0x51ec
@psg:
	moveq	#8, d0	; 0x51ee
	sub.b	d5, d0	; 0x51f0
	subq.b	#2, d0	; 0x51f2
	lsl.b	#5, d0	; 0x51f4
	ori.b	#$1f, d0	; 0x51f6
	move.b	d0, LBL_c00011	; 0x51fa
	tst.b	d5	; 0x5200
	bne.b	@return	; 0x5202
	move.b	#$e3, LBL_c00011	; 0x5204
	move.b	#$ff, LBL_c00011	; 0x520c
@return:
	rts		; 0x5214

waitPcmProcessed:
	move.w	d7, (a4)	; 0x5216
@wait_z80:
	btst	d6, (a4)	; 0x5218
	bne.b	@wait_z80	; 0x521a
	tst.b	LBL_a01ffd	; 0x521c
	beq.b	@return	; 0x5222
	move.w	d6, (a4)	; 0x5224
	nop		; 0x5226
	nop		; 0x5228
	nop		; 0x522a
	nop		; 0x522c
	nop		; 0x522e
	bra.b	waitPcmProcessed	; 0x5230
@return:
	rts		; 0x5232

readFromBgmData:
	moveq	#0, d0	; 0x5234
	move.l	(a3), a0	; 0x5236
	move.b	(a0)+, d0	; 0x5238
	cmpi.b	#$20, d0	; 0x523a
	bcc.b	@ignore	; 0x523e
	bsr.b	processBgmCommand	; 0x5240
@ignore:
	move.l	a0, (a3)	; 0x5242
	rts		; 0x5244

processBgmCommand:
	andi.w	#$001f, d0	; 0x5246
	add.w	d0, d0	; 0x524a
	move.w	(BgmCommands, pc, d0.w), d0	; 0x524c
	jmp	(BgmCommands, pc, d0.w)	; 0x5250

BgmCommands:
	dc.w	bgmCommand00-BgmCommands	; 0x5254
	dc.w	bgmCommand01-BgmCommands	; 0x5256
	dc.w	bgmCommand02-BgmCommands	; 0x5258
	dc.w	bgmCommand03-BgmCommands	; 0x525a
	dc.w	bgmCommand04-BgmCommands	; 0x525c
	dc.w	bgmCommand05-BgmCommands	; 0x525e
	dc.w	bgmCommand06-BgmCommands	; 0x5260
	dc.w	bgmCommand07-BgmCommands	; 0x5262
	dc.w	bgmCommand08-BgmCommands	; 0x5264
	dc.w	bgmCommand09-BgmCommands	; 0x5266
	dc.w	bgmCommand0a-BgmCommands	; 0x5268
	dc.w	bgmCommand0b-BgmCommands	; 0x526a
	dc.w	bgmCommand0c-BgmCommands	; 0x526c
	dc.w	bgmCommand0d-BgmCommands	; 0x526e
	dc.w	bgmCommand0e-BgmCommands	; 0x5270
	dc.w	bgmCommand0f-BgmCommands	; 0x5272
	dc.w	bgmCommand10-BgmCommands	; 0x5274
	dc.w	bgmCommand11-BgmCommands	; 0x5276
	dc.w	bgmCommand12-BgmCommands	; 0x5278
	dc.w	bgmCommand13-BgmCommands	; 0x527a
	dc.w	bgmCommand14-BgmCommands	; 0x527c
	dc.w	bgmCommand15-BgmCommands	; 0x527e
	dc.w	bgmCommand16-BgmCommands	; 0x5280
	dc.w	bgmCommand17-BgmCommands	; 0x5282
	dc.w	bgmCommand18-BgmCommands	; 0x5284
	dc.w	bgmCommands19_1c_1f-BgmCommands	; 0x5286
	dc.w	bgmCommand1a-BgmCommands	; 0x5288
	dc.w	bgmCommand1b-BgmCommands	; 0x528a
	dc.w	bgmCommands19_1c_1f-BgmCommands	; 0x528c
	dc.w	bgmCommand1d-BgmCommands	; 0x528e
	dc.w	bgmCommand1e-BgmCommands	; 0x5290
	dc.w	bgmCommands19_1c_1f-BgmCommands	; 0x5292

bgmCommands19_1c_1f:
	rts		; 0x5294

bgmCommand00:
	eori.b	#$20, (6, a3)	; 0x5296
	bra.b	next_command_100	; 0x529c

bgmCommand01:
	eori.b	#$40, (6, a3)	; 0x529e
	bra.b	next_command_100	; 0x52a4

bgmCommand02:
	ori.b	#$10, (6, a3)	; 0x52a6
	bra.b	next_command_100	; 0x52ac

bgmCommand03:
	eori.b	#8, (6, a3)	; 0x52ae
	bra.b	next_command_100	; 0x52b4

bgmCommand04:
	move.b	(a0)+, d3	; 0x52b6
	andi.b	#$97, (6, a3)	; 0x52b8
	or.b	d3, (6, a3)	; 0x52be

next_command_100:
	move.b	(a0)+, d0	; 0x52c2
	cmpi.b	#$20, d0	; 0x52c4
	bcs.w	processBgmCommand	; 0x52c8
	rts		; 0x52cc

bgmCommand05:
	move.b	(a0)+, d4	; 0x52ce
	lsl.w	#8, d4	; 0x52d0
	move.b	(a0)+, d4	; 0x52d2
	tst.b	(LBL_ffffc8c2).w	; 0x52d4
	bne.b	@ignore	; 0x52d8
	move.w	d4, (36, a3)	; 0x52da
	bra.b	next_command_101	; 0x52de
@ignore:
	move.w	d4, (LBL_ffffc8c8).w	; 0x52e0

next_command_101:
	move.b	(a0)+, d0	; 0x52e4
	cmpi.b	#$20, d0	; 0x52e6
	bcs.w	processBgmCommand	; 0x52ea
	rts		; 0x52ee

bgmCommand06:
	move.b	(a0)+, (7, a3)	; 0x52f0
	move.b	(a0)+, d0	; 0x52f4
	cmpi.b	#$20, d0	; 0x52f6
	bcs.w	processBgmCommand	; 0x52fa
	rts		; 0x52fe

bgmCommand07:
	move.b	(a0)+, d0	; 0x5300
	cmpi.b	#3, d5	; 0x5302
	bcc.b	@pcm	; 0x5306
	move.b	d0, (24, a3)	; 0x5308
	bra.b	@next_command_3	; 0x530c
@pcm:
	eori.b	#$7f, d0	; 0x530e
	move.b	d0, (24, a3)	; 0x5312
	tst.b	(LBL_ffffc8c2).w	; 0x5316
	beq.b	@set_volume	; 0x531a
	move.b	(LBL_ffffc8d7).w, d1	; 0x531c
	move.b	LBL_090001, d2	; 0x5320
	eori.b	#$7f, d2	; 0x5326
	add.b	d1, d0	; 0x532a
	bcs.b	@mute_pcm	; 0x532c
	bmi.b	@mute_pcm	; 0x532e
	add.b	d2, d0	; 0x5330
	bcs.b	@mute_pcm	; 0x5332
	bpl.b	@set_volume	; 0x5334
@mute_pcm:
	moveq	#$007f, d0	; 0x5336
@set_volume:
	move.b	d0, (25, a3)	; 0x5338
@next_command_3:
	move.b	(a0)+, d0	; 0x533c
	cmpi.b	#$20, d0	; 0x533e
	bcs.w	processBgmCommand	; 0x5342
	rts		; 0x5346

bgmCommand08:
	move.b	(a0)+, d0	; 0x5348
	tst.b	(LBL_ffffc8c2).w	; 0x534a
	beq.b	@ignore2	; 0x534e
	move.b	d0, (38, a3)	; 0x5350
@ignore2:
	bsr.b	loadInstrument	; 0x5354
	move.b	(a0)+, d0	; 0x5356
	cmpi.b	#$20, d0	; 0x5358
	bcs.w	processBgmCommand	; 0x535c
	rts		; 0x5360

loadInstrument:
	moveq	#$0020, d4	; 0x5362
	mulu.w	d0, d4	; 0x5364
	lea	LBL_09f000, a1	; 0x5366
	adda.w	d4, a1	; 0x536c
	cmpi.b	#3, d5	; 0x536e
	bcs.b	@pcm_instrument	; 0x5372
	tst.b	(LBL_ffffc8c6).w	; 0x5374
	beq.b	loadFmInstrument	; 0x5378
	rts		; 0x537a
@pcm_instrument:
	adda.w	#$001c, a1	; 0x537c
	moveq	#0, d0	; 0x5380
	move.b	(a1)+, d0	; 0x5382
	add.w	d0, d0	; 0x5384
	move.w	(21420, pc, d0.w), d1	; 0x5386
	move.b	d1, (20, a3)	; 0x538a
	move.b	(a1)+, d0	; 0x538e
	add.w	d0, d0	; 0x5390
	move.w	(21420, pc, d0.w), d1	; 0x5392
	move.b	d1, (21, a3)	; 0x5396
	move.b	(a1)+, (22, a3)	; 0x539a
	move.b	(a1), d0	; 0x539e
	add.w	d0, d0	; 0x53a0
	move.w	(21420, pc, d0.w), d1	; 0x53a2
	move.b	d1, (23, a3)	; 0x53a6
	rts		; 0x53aa
	dc.w	$0000, $0001, $0002, $0003, $0004, $0005, $0006, $0007, $0008, $0009, $000a, $000b, $000c, $000e, $000f, $0010, $0012, $0013, $0014, $0016, $0018, $001b, $001e, $0023, $0028, $0030, $003c, $0050, $007e, $007f, $00fe, $00ff	; 0x53ac

loadFmInstrument:
	moveq	#0, d1	; 0x53ec
	move.b	(LBL_ffffc8c3).w, d1	; 0x53ee
	moveq	#$0030, d2	; 0x53f2
	add.b	(LBL_ffffc8c4).w, d2	; 0x53f4
	bsr.w	waitPcmProcessed	; 0x53f8
	moveq	#$0013, d0	; 0x53fc
@next1:
	cmpi.b	#$0f, d0	; 0x53fe
	bne.b	@not_channel_f	; 0x5402
	adda.w	#4, a1	; 0x5404
	moveq	#3, d3	; 0x5408
@next2:
	nop		; 0x540a
@wait_sound_driver_3:
	btst	#7, (a5)	; 0x540c
	bne.b	@wait_sound_driver_3	; 0x5410
	move.b	d2, (0, a5, d1)	; 0x5412
	nop		; 0x5416
@wait_sound_driver_4:
	btst	#7, (a5)	; 0x5418
	bne.b	@wait_sound_driver_4	; 0x541c
	move.b	#$7f, (1, a5, d1)	; 0x541e
	addq.b	#4, d2	; 0x5424
	dbf	d3, @next2	; 0x5426
@not_channel_f:
	nop		; 0x542a
@wait_sound_driver:
	btst	#7, (a5)	; 0x542c
	bne.b	@wait_sound_driver	; 0x5430
	move.b	d2, (0, a5, d1)	; 0x5432
	nop		; 0x5436
@wait_sound_driver_2:
	btst	#7, (a5)	; 0x5438
	bne.b	@wait_sound_driver_2	; 0x543c
	move.b	(a1)+, (1, a5, d1)	; 0x543e
	addq.b	#4, d2	; 0x5442
	dbf	d0, @next1	; 0x5444
	nop		; 0x5448
@wait_sound_driver_5:
	btst	#7, (a5)	; 0x544a
	bne.b	@wait_sound_driver_5	; 0x544e
	addi.b	#$20, d2	; 0x5450
	move.b	d2, (0, a5, d1)	; 0x5454
	nop		; 0x5458
@wait_sound_driver_6:
	btst	#7, (a5)	; 0x545a
	bne.b	@wait_sound_driver_6	; 0x545e
	move.b	(a1), (1, a5, d1)	; 0x5460
	move.w	d6, (a4)	; 0x5464
	move.b	(a1), d0	; 0x5466
	andi.w	#7, d0	; 0x5468
	suba.w	#$0014, a1	; 0x546c
	move.b	(a1)+, d3	; 0x5470
	lsl.w	#8, d3	; 0x5472
	move.b	(a1)+, d3	; 0x5474
	swap	d3	; 0x5476
	move.b	(a1)+, d3	; 0x5478
	lsl.w	#8, d3	; 0x547a
	move.b	(a1), d3	; 0x547c
	lea	($5492, pc), a1	; 0x547e
	nop		; 0x5482
	add.b	d0, d0	; 0x5484
	add.b	d0, d0	; 0x5486
	or.l	(0, a1, d0), d3	; 0x5488
	move.l	d3, (20, a3)	; 0x548c
	rts		; 0x5490

ym_masks:
	dc.l	$80808000, $80808000, $80808000, $80808000, $80800000, $80000000, $80000000, $00000000	; 0x5492

bgmCommand09:
	move.b	(a0)+, d3	; 0x54b2
	andi.b	#$f8, (6, a3)	; 0x54b4
	or.b	d3, (6, a3)	; 0x54ba
	move.b	(a0)+, d0	; 0x54be
	cmpi.b	#$20, d0	; 0x54c0
	bcs.w	processBgmCommand	; 0x54c4
	rts		; 0x54c8

bgmCommand0a:
	move.b	(a0)+, (LBL_ffffc8d5).w	; 0x54ca
	move.b	(a0)+, d0	; 0x54ce
	cmpi.b	#$20, d0	; 0x54d0
	bcs.w	processBgmCommand	; 0x54d4
	rts		; 0x54d8

bgmCommand0b:
	move.b	(a0)+, (10, a3)	; 0x54da
	move.b	(a0)+, d0	; 0x54de
	cmpi.b	#$20, d0	; 0x54e0
	bcs.w	processBgmCommand	; 0x54e4
	rts		; 0x54e8

bgmCommand0c:
	move.b	(a0)+, (11, a3)	; 0x54ea
	move.b	(a0)+, d0	; 0x54ee
	cmpi.b	#$20, d0	; 0x54f0
	bcs.w	processBgmCommand	; 0x54f4
	rts		; 0x54f8

bgmCommand0d:
	move.b	(a0)+, d3	; 0x54fa
	add.b	d3, d3	; 0x54fc
	move.b	d3, (17, a3)	; 0x54fe
	move.b	(a0)+, d0	; 0x5502
	cmpi.b	#$20, d0	; 0x5504
	bcs.w	processBgmCommand	; 0x5508
	rts		; 0x550c

bgmCommand0e:
	moveq	#$001c, d2	; 0x550e
	bra.b	continue_102	; 0x5510

bgmCommand0f:
	moveq	#$001d, d2	; 0x5512
	bra.b	continue_102	; 0x5514

bgmCommand10:
	moveq	#$001e, d2	; 0x5516
	bra.b	continue_102	; 0x5518

bgmCommand11:
	moveq	#$001f, d2	; 0x551a

continue_102:
	move.b	(a0)+, d3	; 0x551c
	tst.b	(0, a3, d2)	; 0x551e
	bne.b	@ignore	; 0x5522
	move.b	d3, (0, a3, d2)	; 0x5524
	bra.b	bgmCommand16	; 0x5528
@ignore:
	subq.b	#1, (0, a3, d2)	; 0x552a
	bne.b	bgmCommand16	; 0x552e
	addq.w	#2, a0	; 0x5530
	bra.b	next_command_104	; 0x5532

bgmCommand12:
	moveq	#$001c, d2	; 0x5534
	bra.b	continue_103	; 0x5536

bgmCommand13:
	moveq	#$001d, d2	; 0x5538
	bra.b	continue_103	; 0x553a

bgmCommand14:
	moveq	#$001e, d2	; 0x553c
	bra.b	continue_103	; 0x553e

bgmCommand15:
	moveq	#$001f, d2	; 0x5540

continue_103:
	cmpi.b	#1, (0, a3, d2)	; 0x5542
	beq.b	@ignore2	; 0x5548
	addq.w	#3, a0	; 0x554a
	bra.b	next_command_104	; 0x554c
@ignore2:
	clr.b	(0, a3, d2)	; 0x554e
	move.b	(a0)+, d3	; 0x5552
	andi.b	#$97, (6, a3)	; 0x5554
	or.b	d3, (6, a3)	; 0x555a

bgmCommand16:
	move.b	(a0)+, d4	; 0x555e
	lsl.w	#8, d4	; 0x5560
	move.b	(a0)+, d4	; 0x5562
	adda.w	d4, a0	; 0x5564

next_command_104:
	move.b	(a0)+, d0	; 0x5566
	cmpi.b	#$20, d0	; 0x5568
	bcs.w	processBgmCommand	; 0x556c
	rts		; 0x5570

bgmCommand17:
	tst.b	(LBL_ffffc8c2).w	; 0x5572
	bne.b	@loc_000055B6	; 0x5576
	clr.b	(38, a3)	; 0x5578
	bsr.w	muteFmChannel	; 0x557c
	lea	(40, a3), a3	; 0x5580
	tst.l	(a3)	; 0x5584
	beq.b	@continue	; 0x5586
	st	(37, a3)	; 0x5588
	cmpi.b	#3, d5	; 0x558c
	bcs.b	@continue	; 0x5590
	moveq	#0, d0	; 0x5592
	move.b	(38, a3), d0	; 0x5594
	moveq	#$0020, d4	; 0x5598
	mulu.w	d0, d4	; 0x559a
	lea	LBL_09f000, a1	; 0x559c
	adda.w	d4, a1	; 0x55a2
	bsr.w	loadFmInstrument	; 0x55a4
	move.b	(39, a3), d0	; 0x55a8
	bsr.w	setFmFrequency	; 0x55ac
@continue:
	lea	(-40, a3), a3	; 0x55b0
	bra.b	@return	; 0x55b4
@loc_000055B6:
	tst.b	(LBL_ffffc8c6).w	; 0x55b6
	bne.b	@return	; 0x55ba
	bsr.w	muteFmChannel	; 0x55bc
@return:
	lea	(ROM_start).w, a0	; 0x55c0
	rts		; 0x55c4

bgmCommand18:
	move.b	(a0)+, d0	; 0x55c6
	cmpi.b	#3, d5	; 0x55c8
	bcs.b	@next_channel_8	; 0x55cc
	tst.b	(LBL_ffffc8c2).w	; 0x55ce
	beq.b	@ignore8	; 0x55d2
	move.b	d0, (39, a3)	; 0x55d4
	tst.b	(LBL_ffffc8c6).w	; 0x55d8
	bne.b	@next_channel_8	; 0x55dc
@ignore8:
	bsr.b	setFmFrequency	; 0x55de
@next_channel_8:
	move.b	(a0)+, d0	; 0x55e0
	cmpi.b	#$20, d0	; 0x55e2
	bcs.w	processBgmCommand	; 0x55e6
	rts		; 0x55ea

setFmFrequency:
	moveq	#0, d1	; 0x55ec
	move.b	(LBL_ffffc8c3).w, d1	; 0x55ee
	move.b	#$b4, d2	; 0x55f2
	add.b	(LBL_ffffc8c4).w, d2	; 0x55f6
	bsr.w	waitPcmProcessed	; 0x55fa
	nop		; 0x55fe
@wait_sound_driver_1:
	btst	#7, (a5)	; 0x5600
	bne.b	@wait_sound_driver_1	; 0x5604
	move.b	d2, (0, a5, d1)	; 0x5606
	nop		; 0x560a
@wait_sound_driver_2:
	btst	#7, (a5)	; 0x560c
	bne.b	@wait_sound_driver_2	; 0x5610
	move.b	d0, (1, a5, d1)	; 0x5612
	move.w	d6, (a4)	; 0x5616
	rts		; 0x5618

bgmCommand1a:
	move.b	(a0)+, d0	; 0x561a
	tst.b	(LBL_ffffc8c2).w	; 0x561c
	beq.b	@next_channel_9	; 0x5620
	cmpi.b	#3, d5	; 0x5622
	bcc.b	@pcm	; 0x5626
	add.b	d0, d0	; 0x5628
	addq.b	#1, d0	; 0x562a
	moveq	#0, d1	; 0x562c
	move.b	LBL_090001, d1	; 0x562e
	mulu.w	d0, d1	; 0x5634
	lsr.w	#8, d1	; 0x5636
	move.b	d1, (LBL_ffffc8d6).w	; 0x5638
	bra.b	@next_channel_9	; 0x563c
@pcm:
	eori.b	#$7f, d0	; 0x563e
	move.b	d0, (LBL_ffffc8d7).w	; 0x5642
	move.b	(24, a3), d1	; 0x5646
	move.b	LBL_090001, d2	; 0x564a
	eori.b	#$7f, d2	; 0x5650
	add.b	d1, d0	; 0x5654
	bcs.b	@mute	; 0x5656
	bmi.b	@mute	; 0x5658
	add.b	d2, d0	; 0x565a
	bcs.b	@mute	; 0x565c
	bpl.b	@set_volume	; 0x565e
@mute:
	moveq	#$007f, d0	; 0x5660
@set_volume:
	move.b	d0, (25, a3)	; 0x5662
@next_channel_9:
	move.b	(a0)+, d0	; 0x5666
	cmpi.b	#$20, d0	; 0x5668
	bcs.w	processBgmCommand	; 0x566c
	rts		; 0x5670

bgmCommand1b:
	move.b	(a0)+, (35, a3)	; 0x5672
	move.b	(a0)+, d0	; 0x5676
	cmpi.b	#$20, d0	; 0x5678
	bcs.w	processBgmCommand	; 0x567c
	rts		; 0x5680

bgmCommand1d:
	move.b	(a0)+, (33, a3)	; 0x5682
	move.b	(a0)+, d0	; 0x5686
	cmpi.b	#$20, d0	; 0x5688
	bcs.w	processBgmCommand	; 0x568c
	rts		; 0x5690

bgmCommand1e:
	move.b	(a0)+, d0	; 0x5692
	bclr	#0, (32, a3)	; 0x5694
	or.b	d0, (32, a3)	; 0x569a
	move.b	(a0)+, d0	; 0x569e
	cmpi.b	#$20, d0	; 0x56a0
	bcs.w	processBgmCommand	; 0x56a4
	rts		; 0x56a8

FUN_000056aa:
	moveq	#8, d0	; 0x56aa
	sub.b	d5, d0	; 0x56ac
	cmpi.b	#3, d5	; 0x56ae
	bcc.b	@pcm	; 0x56b2
	subq.b	#2, d0	; 0x56b4
	lsl.b	#5, d0	; 0x56b6
	move.b	d0, (LBL_ffffc8c5).w	; 0x56b8
	bra.b	@continue	; 0x56bc
@pcm:
	move.b	d0, d1	; 0x56be
	add.b	d1, d1	; 0x56c0
	andi.b	#2, d1	; 0x56c2
	move.b	d1, (LBL_ffffc8c3).w	; 0x56c6
	move.b	d0, d1	; 0x56ca
	lsr.b	#1, d1	; 0x56cc
	andi.b	#3, d1	; 0x56ce
	move.b	d1, (LBL_ffffc8c4).w	; 0x56d2
@continue:
	tst.w	(4, a3)	; 0x56d6
	beq.w	@next_bgm_data	; 0x56da
	tst.w	(8, a3)	; 0x56de
	beq.b	@update_timer	; 0x56e2
	move.w	(duration_frame).w, d0	; 0x56e4
	sub.w	d0, (8, a3)	; 0x56e8
	bhi.b	@update_timer	; 0x56ec
	clr.w	(8, a3)	; 0x56ee
	cmpi.b	#3, d5	; 0x56f2
	bcc.b	@pcm2	; 0x56f6
	move.b	#3, (27, a3)	; 0x56f8
	bra.b	@update_timer	; 0x56fe
@pcm2:
	tst.b	(LBL_ffffc8c6).w	; 0x5700
	bne.b	@update_timer	; 0x5704
	bsr.w	waitPcmProcessed	; 0x5706
	move.b	(LBL_ffffc8c3).w, d0	; 0x570a
	add.b	d0, d0	; 0x570e
	or.b	(LBL_ffffc8c4).w, d0	; 0x5710
	nop		; 0x5714
@wait_sound_driver:
	btst	#7, (a5)	; 0x5716
	bne.b	@wait_sound_driver	; 0x571a
	move.b	#$28, d1	; 0x571c
	move.b	d1, (a5)	; 0x5720
	nop		; 0x5722
@wait_sound_driver_2:
	btst	#7, (a5)	; 0x5724
	bne.b	@wait_sound_driver_2	; 0x5728
	move.b	d0, (1, a5)	; 0x572a
	move.w	d6, (a4)	; 0x572e
@update_timer:
	move.w	(duration_frame).w, d0	; 0x5730
	sub.w	d0, (4, a3)	; 0x5734
	bls.w	@next_bgm_data	; 0x5738
	cmpi.w	#$c001, (4, a3)	; 0x573c
	bcc.w	@next_bgm_data	; 0x5742
	bra.w	finalize_105	; 0x5746
@next_bgm_data:
	bsr.w	readFromBgmData	; 0x574a
	tst.l	(a3)	; 0x574e
	bne.b	@process_bgm_data	; 0x5750
	rts		; 0x5752
@process_bgm_data:
	move.b	d0, d1	; 0x5754
	lsr.b	#4, d1	; 0x5756
	andi.w	#$000e, d1	; 0x5758
	move.b	(6, a3), d2	; 0x575c
	andi.w	#$0030, d2	; 0x5760
	bclr	#4, (6, a3)	; 0x5764
	or.w	d1, d2	; 0x576a
	move.w	(22396, pc, d2.w), d1	; 0x576c
	add.w	d1, (4, a3)	; 0x5770
	andi.w	#$001f, d0	; 0x5774
	bne.b	@command	; 0x5778
	rts		; 0x577a
	dc.w	$0000, $0300, $0600, $0c00, $1800, $3000, $6000, $c000, $0000, $0000, $0900, $1200, $2400, $4800, $9000, $0000, $0000, $0200, $0400, $0800, $1000, $2000, $4000, $8000	; 0x577c
	dc.w	$0000, $000c, $0018, $0024, $0030, $003c, $0048, $0054, $0018, $0024, $0030, $003c, $0048, $0054, $0060, $006c	; 0x57ac
@command:
	subq.b	#1, d0	; 0x57cc
	move.b	(6, a3), d1	; 0x57ce
	andi.w	#$000f, d1	; 0x57d2
	add.w	d1, d1	; 0x57d6
	add.w	(22444, pc, d1.w), d0	; 0x57d8
	tst.b	(LBL_ffffc8c2).w	; 0x57dc
	beq.b	@not_ffc8d5	; 0x57e0
	add.b	(LBL_ffffc8d5).w, d0	; 0x57e2
@not_ffc8d5:
	add.b	(10, a3), d0	; 0x57e6
	lsl.w	#8, d0	; 0x57ea
	cmpi.w	#$6000, d0	; 0x57ec
	bcs.b	@lt_6000	; 0x57f0
	andi.w	#$00ff, d0	; 0x57f2
	ori.w	#$5f00, d0	; 0x57f6
@lt_6000:
	move.w	d0, d1	; 0x57fa
	andi.w	#$00ff, (16, a3)	; 0x57fc
	move.w	(16, a3), d2	; 0x5802
	beq.b	@skip	; 0x5806
	move.w	(14, a3), d3	; 0x5808
	beq.b	@skip	; 0x580c
	cmp.w	d3, d0	; 0x580e
	beq.b	@skip	; 0x5810
	bcc.b	@positive	; 0x5812
	neg.w	d2	; 0x5814
@positive:
	move.w	d2, (18, a3)	; 0x5816
	move.w	(14, a3), d0	; 0x581a
	st	(16, a3)	; 0x581e
@skip:
	move.w	d1, (14, a3)	; 0x5822
	move.w	d0, (12, a3)	; 0x5826
	btst	#0, (32, a3)	; 0x582a
	beq.b	@cleared	; 0x5830
	andi.b	#$3f, (32, a3)	; 0x5832
	clr.b	(34, a3)	; 0x5838
@cleared:
	cmpi.b	#3, d5	; 0x583c
	bcc.b	@loc_000058BA	; 0x5840
	btst	#7, (6, a3)	; 0x5842
	bne.b	@dont_clear	; 0x5848
	clr.b	(27, a3)	; 0x584a
	clr.b	(26, a3)	; 0x584e
	tst.b	(LBL_ffffc8c6).w	; 0x5852
	bne.w	@skip3	; 0x5856
	move.b	(LBL_ffffc8c5).w, d0	; 0x585a
	ori.b	#$1f, d0	; 0x585e
	move.b	d0, LBL_c00011	; 0x5862
	tst.b	d5	; 0x5868
	bne.b	@dont_clear	; 0x586a
	move.b	#$e3, LBL_c00011	; 0x586c
	move.b	#$ff, LBL_c00011	; 0x5874
@dont_clear:
	tst.b	(LBL_ffffc8c6).w	; 0x587c
	bne.w	@skip3	; 0x5880
	lea	($5ab0, pc), a0	; 0x5884
	nop		; 0x5888
	moveq	#0, d0	; 0x588a
	move.b	(12, a3), d0	; 0x588c
	add.b	d0, d0	; 0x5890
	move.w	(0, a0, d0), d1	; 0x5892
	move.b	(11, a3), d0	; 0x5896
	ext.w	d0	; 0x589a
	add.w	d0, d1	; 0x589c
	move.w	d1, d0	; 0x589e
	andi.w	#$000f, d0	; 0x58a0
	or.b	(LBL_ffffc8c5).w, d0	; 0x58a4
	lsr.w	#4, d1	; 0x58a8
	move.b	d0, LBL_c00011	; 0x58aa
	move.b	d1, LBL_c00011	; 0x58b0
	bra.w	@skip3	; 0x58b6
@loc_000058BA:
	tst.b	(LBL_ffffc8c6).w	; 0x58ba
	bne.w	@skip3	; 0x58be
	bsr.w	waitPcmProcessed	; 0x58c2
	moveq	#0, d2	; 0x58c6
	move.b	(LBL_ffffc8c3).w, d2	; 0x58c8
	move.b	#$40, d3	; 0x58cc
	add.b	(LBL_ffffc8c4).w, d3	; 0x58d0
	moveq	#0, d4	; 0x58d4
	move.b	(LBL_ffffc8d2).w, d4	; 0x58d6
	moveq	#3, d0	; 0x58da
	lea	(20, a3), a1	; 0x58dc
@next:
	moveq	#0, d1	; 0x58e0
	move.b	(a1)+, d1	; 0x58e2
	bpl.b	@positive2	; 0x58e4
	andi.b	#$7f, d1	; 0x58e6
	bra.b	@wait	; 0x58ea
@positive2:
	add.b	(25, a3), d1	; 0x58ec
	bcs.b	@overflow	; 0x58f0
	bpl.b	@positive3	; 0x58f2
@overflow:
	move.b	#$7f, d1	; 0x58f4
@positive3:
	tst.b	(LBL_ffffc8c2).w	; 0x58f8
	beq.b	@wait	; 0x58fc
	tst.b	(LBL_ffffc8d4).w	; 0x58fe
	beq.b	@wait	; 0x5902
	eori.b	#$7f, d1	; 0x5904
	mulu.w	d4, d1	; 0x5908
	lsr.w	#8, d1	; 0x590a
	eori.b	#$7f, d1	; 0x590c
@wait:
	nop		; 0x5910
@wait_for_sound_driver:
	btst	#7, (a5)	; 0x5912
	bne.b	@wait_for_sound_driver	; 0x5916
	move.b	d3, (0, a5, d2)	; 0x5918
	nop		; 0x591c
@wait_for_sound_driver_2:
	btst	#7, (a5)	; 0x591e
	bne.b	@wait_for_sound_driver_2	; 0x5922
	move.b	d1, (1, a5, d2)	; 0x5924
	addq.b	#4, d3	; 0x5928
	dbf	d0, @next	; 0x592a
	lea	($59f0, pc), a0	; 0x592e
	nop		; 0x5932
	moveq	#0, d0	; 0x5934
	move.b	(12, a3), d0	; 0x5936
	add.b	d0, d0	; 0x593a
	move.w	(0, a0, d0), d1	; 0x593c
	move.b	(11, a3), d0	; 0x5940
	ext.w	d0	; 0x5944
	add.w	d0, d1	; 0x5946
	move.w	d1, d0	; 0x5948
	lsr.w	#8, d0	; 0x594a
	andi.w	#$00ff, d1	; 0x594c
	moveq	#0, d2	; 0x5950
	move.b	(LBL_ffffc8c3).w, d2	; 0x5952
	move.b	#$a4, d3	; 0x5956
	add.b	(LBL_ffffc8c4).w, d3	; 0x595a
	nop		; 0x595e
@wait_for_sound_driver_3:
	btst	#7, (a5)	; 0x5960
	bne.b	@wait_for_sound_driver_3	; 0x5964
	move.b	d3, (0, a5, d2)	; 0x5966
	nop		; 0x596a
@wait_for_sound_driver_4:
	btst	#7, (a5)	; 0x596c
	bne.b	@wait_for_sound_driver_4	; 0x5970
	move.b	d0, (1, a5, d2)	; 0x5972
	nop		; 0x5976
@wait_for_sound_driver_5:
	btst	#7, (a5)	; 0x5978
	bne.b	@wait_for_sound_driver_5	; 0x597c
	subq.b	#4, d3	; 0x597e
	move.b	d3, (0, a5, d2)	; 0x5980
	nop		; 0x5984
@wait_for_sound_driver_6:
	btst	#7, (a5)	; 0x5986
	bne.b	@wait_for_sound_driver_6	; 0x598a
	move.b	d1, (1, a5, d2)	; 0x598c
	btst	#7, (6, a3)	; 0x5990
	bne.b	@skip2	; 0x5996
	move.b	(LBL_ffffc8c3).w, d0	; 0x5998
	add.b	d0, d0	; 0x599c
	or.b	(LBL_ffffc8c4).w, d0	; 0x599e
	ori.b	#$f0, d0	; 0x59a2
	nop		; 0x59a6
@wait_for_sound_driver_7:
	btst	#7, (a5)	; 0x59a8
	bne.b	@wait_for_sound_driver_7	; 0x59ac
	move.b	#$28, d1	; 0x59ae
	move.b	d1, (a5)	; 0x59b2
	nop		; 0x59b4
@wait_for_sound_driver_8:
	btst	#7, (a5)	; 0x59b6
	bne.b	@wait_for_sound_driver_8	; 0x59ba
	move.b	d0, (1, a5)	; 0x59bc
@skip2:
	move.w	d6, (a4)	; 0x59c0
@skip3:
	bclr	#7, (6, a3)	; 0x59c2
	move.b	(6, a3), d0	; 0x59c8
	add.b	d0, d0	; 0x59cc
	andi.b	#$80, d0	; 0x59ce
	or.b	d0, (6, a3)	; 0x59d2
	bpl.b	@positive6	; 0x59d6
	moveq	#0, d1	; 0x59d8
	bra.b	@zero	; 0x59da
@positive6:
	move.w	(4, a3), d0	; 0x59dc
	move.b	(7, a3), d1	; 0x59e0
	lsl.w	#8, d1	; 0x59e4
	mulu.w	d0, d1	; 0x59e6
	swap	d1	; 0x59e8
@zero:
	move.w	d1, (8, a3)	; 0x59ea
	rts		; 0x59ee

LBL_0059f0:
	dc.w	$0283, $02aa, $02d2, $02fd, $032b, $035b, $038e, $03c4, $03fd, $043a, $047b, $04bf, $0a83, $0aaa, $0ad2, $0afd, $0b2b, $0b5b, $0b8e, $0bc4, $0bfd, $0c3a, $0c7b, $0cbf, $1283, $12aa, $12d2, $12fd, $132b, $135b, $138e, $13c4, $13fd, $143a, $147b, $14bf, $1a83, $1aaa, $1ad2, $1afd, $1b2b, $1b5b, $1b8e, $1bc4, $1bfd, $1c3a, $1c7b, $1cbf, $2283, $22aa, $22d2, $22fd, $232b, $235b, $238e, $23c4, $23fd, $243a, $247b, $24bf, $2a83, $2aaa, $2ad2, $2afd, $2b2b, $2b5b, $2b8e, $2bc4, $2bfd, $2c3a, $2c7b, $2cbf, $3283, $32aa, $32d2, $32fd, $332b, $335b, $338e, $33c4, $33fd, $343a, $347b, $34bf, $3a83, $3aaa, $3ad2, $3afd, $3b2b, $3b5b, $3b8e, $3bc4, $3bfd, $3c3a, $3c7b, $3cbf	; 0x59f0

psgRelated:
	dc.w	$01ac, $0194, $017d, $0168, $0153, $0140, $012e, $011d, $010d, $00fe, $00f0, $00e2, $00d6, $00ca, $00be, $00b4, $00aa, $00a0, $0097, $008f, $0087, $007f, $0078, $0071, $006b, $0065, $005f, $005a, $0055, $0050, $004c, $0047, $0043, $0040, $003c, $0039, $0357, $0327, $02fa, $02cf, $02a7, $0281, $025d, $023b, $021b, $01fc, $01e0, $01c5, $01ac, $0194, $017d, $0168, $0153, $0140, $012e, $011d, $010d, $00fe, $00f0, $00e2, $00d6, $00ca, $00be, $00b4, $00aa, $00a0, $0097, $008f, $0087, $007f, $0078, $0071, $006b, $0065, $005f, $005a, $0055, $0050, $004c, $0047, $0043, $0040, $003c, $0039, $0036, $0033, $0030, $002d, $002b, $0028, $0026, $0024, $0022, $0020, $001e, $001d	; 0x5ab0

finalize_105:
	cmpi.b	#3, d5	; 0x5b70
	bcc.b	someCallback02	; 0x5b74
	moveq	#0, d0	; 0x5b76
	move.b	(27, a3), d0	; 0x5b78
	andi.b	#7, d0	; 0x5b7c
	add.w	d0, d0	; 0x5b80
	move.w	(someCallbacks, pc, d0.w), d1	; 0x5b82
	jmp	(someCallbacks, pc, d1.w)	; 0x5b86

someCallbacks:
	dc.w	someCallback00-someCallbacks	; 0x5b8a
	dc.w	someCallback01-someCallbacks	; 0x5b8c
	dc.w	someCallback02-someCallbacks	; 0x5b8e
	dc.w	someCallback03-someCallbacks	; 0x5b90
	dc.w	someCallback04To07-someCallbacks	; 0x5b92
	dc.w	someCallback04To07-someCallbacks	; 0x5b94
	dc.w	someCallback04To07-someCallbacks	; 0x5b96
	dc.w	someCallback04To07-someCallbacks	; 0x5b98

someCallback04To07:
	rts		; 0x5b9a

someCallback00:
	move.b	(20, a3), d0	; 0x5b9c
	add.b	d0, (26, a3)	; 0x5ba0
	bcc.b	someCallback02	; 0x5ba4
	st	(26, a3)	; 0x5ba6
	bra.b	increment	; 0x5baa

someCallback01:
	move.b	(21, a3), d0	; 0x5bac
	beq.b	skip4	; 0x5bb0
	sub.b	d0, (26, a3)	; 0x5bb2
	bcs.b	skip4	; 0x5bb6
	move.b	(26, a3), d0	; 0x5bb8
	cmp.b	(22, a3), d0	; 0x5bbc
	bcc.b	someCallback02	; 0x5bc0

skip4:
	move.b	(22, a3), (26, a3)	; 0x5bc2
	bra.b	increment	; 0x5bc8

someCallback03:
	move.b	(23, a3), d0	; 0x5bca
	beq.b	someCallback02	; 0x5bce
	sub.b	d0, (26, a3)	; 0x5bd0
	bcc.b	someCallback02	; 0x5bd4
	clr.b	(26, a3)	; 0x5bd6

increment:
	addq.b	#1, (27, a3)	; 0x5bda

someCallback02:
	move.b	(33, a3), d0	; 0x5bde
	add.b	d0, (34, a3)	; 0x5be2
	bcc.b	@dont_add	; 0x5be6
	addi.b	#$40, (32, a3)	; 0x5be8
@dont_add:
	moveq	#0, d3	; 0x5bee
	move.b	(16, a3), d3	; 0x5bf0
	beq.b	@finalize2	; 0x5bf4
	move.w	(18, a3), d0	; 0x5bf6
	add.w	d0, (12, a3)	; 0x5bfa
	move.w	(12, a3), d0	; 0x5bfe
	move.w	(14, a3), d1	; 0x5c02
	move.b	(18, a3), d2	; 0x5c06
	bpl.b	@dont_swap	; 0x5c0a
	exg	d0, d1	; 0x5c0c
@dont_swap:
	cmp.w	d0, d1	; 0x5c0e
	bcc.b	@finalize2	; 0x5c10
	clr.b	(16, a3)	; 0x5c12
	move.w	(14, a3), (12, a3)	; 0x5c16
@finalize2:
	tst.b	(LBL_ffffc8c6).w	; 0x5c1c
	beq.b	@ffc8c6_zero	; 0x5c20
	rts		; 0x5c22
@ffc8c6_zero:
	cmpi.b	#3, d5	; 0x5c24
	bcc.w	@fm	; 0x5c28
	move.w	#$0030, d0	; 0x5c2c
	moveq	#0, d1	; 0x5c30
	moveq	#0, d4	; 0x5c32
	move.b	(34, a3), d1	; 0x5c34
	beq.b	@positive4	; 0x5c38
	move.b	(35, a3), d4	; 0x5c3a
	beq.b	@positive4	; 0x5c3e
	btst	#6, (32, a3)	; 0x5c40
	beq.b	@positive3	; 0x5c46
	not.b	d1	; 0x5c48
@positive3:
	mulu.w	d1, d4	; 0x5c4a
	mulu.w	d0, d4	; 0x5c4c
	swap	d4	; 0x5c4e
	btst	#7, (32, a3)	; 0x5c50
	beq.b	@positive4	; 0x5c56
	neg.w	d4	; 0x5c58
@positive4:
	moveq	#0, d0	; 0x5c5a
	tst.b	(LBL_ffffc8c2).w	; 0x5c5c
	beq.b	@dont_clear	; 0x5c60
	move.b	(37, a3), d0	; 0x5c62
	clr.b	(37, a3)	; 0x5c66
@dont_clear:
	add.w	d3, d0	; 0x5c6a
	add.w	d4, d0	; 0x5c6c
	beq.b	@skip	; 0x5c6e
	lea	psgRelated, a0	; 0x5c70
	moveq	#0, d0	; 0x5c76
	move.b	(12, a3), d0	; 0x5c78
	add.b	d0, d0	; 0x5c7c
	move.w	(0, a0, d0), d1	; 0x5c7e
	move.b	(11, a3), d0	; 0x5c82
	ext.w	d0	; 0x5c86
	add.w	d0, d1	; 0x5c88
	add.w	d4, d1	; 0x5c8a
	move.w	d1, d0	; 0x5c8c
	andi.w	#$000f, d0	; 0x5c8e
	or.b	(LBL_ffffc8c5).w, d0	; 0x5c92
	lsr.w	#4, d1	; 0x5c96
	move.b	d0, LBL_c00011	; 0x5c98
	move.b	d1, LBL_c00011	; 0x5c9e
@skip:
	moveq	#0, d0	; 0x5ca4
	moveq	#0, d1	; 0x5ca6
	move.b	(LBL_ffffc8d6).w, d0	; 0x5ca8
	move.b	(26, a3), d1	; 0x5cac
	mulu.w	d1, d0	; 0x5cb0
	lsr.w	#8, d0	; 0x5cb2
	move.b	(24, a3), d1	; 0x5cb4
	mulu.w	d1, d0	; 0x5cb8
	lsr.w	#8, d0	; 0x5cba
	tst.b	(LBL_ffffc8c2).w	; 0x5cbc
	beq.b	@skip10	; 0x5cc0
	tst.b	(LBL_ffffc8d4).w	; 0x5cc2
	beq.b	@skip10	; 0x5cc6
	move.b	(LBL_ffffc8d2).w, d1	; 0x5cc8
	mulu.w	d1, d0	; 0x5ccc
	lsr.w	#8, d0	; 0x5cce
@skip10:
	eori.b	#$0f, d0	; 0x5cd0
	or.b	(LBL_ffffc8c5).w, d0	; 0x5cd4
	ori.b	#$10, d0	; 0x5cd8
	tst.b	d5	; 0x5cdc
	bne.b	@send	; 0x5cde
	move.b	(12, a3), d1	; 0x5ce0
	cmpi.b	#$24, d1	; 0x5ce4
	bcc.b	@send	; 0x5ce8
	ori.b	#$20, d0	; 0x5cea
@send:
	move.b	d0, LBL_c00011	; 0x5cee
	rts		; 0x5cf4
@fm:
	move.w	#$00c0, d0	; 0x5cf6
	moveq	#0, d1	; 0x5cfa
	moveq	#0, d4	; 0x5cfc
	move.b	(34, a3), d1	; 0x5cfe
	beq.b	@zero11	; 0x5d02
	move.b	(35, a3), d4	; 0x5d04
	beq.b	@zero11	; 0x5d08
	btst	#6, (32, a3)	; 0x5d0a
	beq.b	@zero10	; 0x5d10
	not.b	d1	; 0x5d12
@zero10:
	mulu.w	d1, d4	; 0x5d14
	mulu.w	d0, d4	; 0x5d16
	swap	d4	; 0x5d18
	btst	#7, (32, a3)	; 0x5d1a
	beq.b	@zero11	; 0x5d20
	neg.w	d4	; 0x5d22
@zero11:
	tst.b	(LBL_ffffc8c2).w	; 0x5d24
	beq.b	@zero12	; 0x5d28
	tst.b	(37, a3)	; 0x5d2a
	bne.b	@process10	; 0x5d2e
@zero12:
	move.w	d3, d0	; 0x5d30
	add.w	d4, d0	; 0x5d32
	beq.b	@zero14	; 0x5d34
@process10:
	lea	LBL_0059f0, a0	; 0x5d36
	moveq	#0, d0	; 0x5d3c
	move.b	(12, a3), d0	; 0x5d3e
	add.b	d0, d0	; 0x5d42
	move.w	(0, a0, d0), d1	; 0x5d44
	move.w	(0, a0, d0), d1	; 0x5d48
	move.b	(11, a3), d0	; 0x5d4c
	ext.w	d0	; 0x5d50
	add.w	d0, d1	; 0x5d52
	add.w	d4, d1	; 0x5d54
	move.w	d1, d0	; 0x5d56
	lsr.w	#8, d0	; 0x5d58
	andi.w	#$00ff, d1	; 0x5d5a
	moveq	#0, d2	; 0x5d5e
	move.b	(LBL_ffffc8c3).w, d2	; 0x5d60
	move.b	#$a4, d3	; 0x5d64
	add.b	(LBL_ffffc8c4).w, d3	; 0x5d68
	bsr.w	waitPcmProcessed	; 0x5d6c
	nop		; 0x5d70
@wait_sound_driver_20:
	btst	#7, (a5)	; 0x5d72
	bne.b	@wait_sound_driver_20	; 0x5d76
	move.b	d3, (0, a5, d2)	; 0x5d78
	nop		; 0x5d7c
@wait_sound_driver_21:
	btst	#7, (a5)	; 0x5d7e
	bne.b	@wait_sound_driver_21	; 0x5d82
	move.b	d0, (1, a5, d2)	; 0x5d84
	nop		; 0x5d88
@wait_sound_driver_22:
	btst	#7, (a5)	; 0x5d8a
	bne.b	@wait_sound_driver_22	; 0x5d8e
	subq.b	#4, d3	; 0x5d90
	move.b	d3, (0, a5, d2)	; 0x5d92
	nop		; 0x5d96
@wait_sound_driver_23:
	btst	#7, (a5)	; 0x5d98
	bne.b	@wait_sound_driver_23	; 0x5d9c
	move.b	d1, (1, a5, d2)	; 0x5d9e
	move.w	d6, (a4)	; 0x5da2
@zero14:
	tst.b	(LBL_ffffc8c2).w	; 0x5da4
	beq.b	@return	; 0x5da8
	tst.b	(37, a3)	; 0x5daa
	beq.b	@dont_clear_20	; 0x5dae
	clr.b	(37, a3)	; 0x5db0
	bra.b	@process20	; 0x5db4
@dont_clear_20:
	tst.b	(LBL_ffffc8d4).w	; 0x5db6
	beq.b	@return	; 0x5dba
@process20:
	moveq	#0, d4	; 0x5dbc
	move.b	(LBL_ffffc8d2).w, d4	; 0x5dbe
	moveq	#0, d2	; 0x5dc2
	move.b	(LBL_ffffc8c3).w, d2	; 0x5dc4
	move.b	#$40, d3	; 0x5dc8
	add.b	(LBL_ffffc8c4).w, d3	; 0x5dcc
	bsr.w	waitPcmProcessed	; 0x5dd0
	moveq	#3, d0	; 0x5dd4
	lea	(20, a3), a1	; 0x5dd6
@next:
	moveq	#0, d1	; 0x5dda
	move.b	(a1)+, d1	; 0x5ddc
	bpl.b	@positive20	; 0x5dde
	andi.b	#$7f, d1	; 0x5de0
	bra.b	@process21	; 0x5de4
@positive20:
	add.b	(25, a3), d1	; 0x5de6
	bcs.b	@negative	; 0x5dea
	bpl.b	@loc_00005DF2	; 0x5dec
@negative:
	move.b	#$7f, d1	; 0x5dee
@loc_00005DF2:
	tst.b	(LBL_ffffc8d4).w	; 0x5df2
	beq.b	@process21	; 0x5df6
	eori.b	#$7f, d1	; 0x5df8
	mulu.w	d4, d1	; 0x5dfc
	lsr.w	#8, d1	; 0x5dfe
	eori.b	#$7f, d1	; 0x5e00
@process21:
	nop		; 0x5e04
@wait_sound_driver_24:
	btst	#7, (a5)	; 0x5e06
	bne.b	@wait_sound_driver_24	; 0x5e0a
	move.b	d3, (0, a5, d2)	; 0x5e0c
	nop		; 0x5e10
@wait_sound_driver_25:
	btst	#7, (a5)	; 0x5e12
	bne.b	@wait_sound_driver_25	; 0x5e16
	move.b	d1, (1, a5, d2)	; 0x5e18
	addq.b	#4, d3	; 0x5e1c
	dbf	d0, @next	; 0x5e1e
	move.w	d6, (a4)	; 0x5e22
@return:
	rts		; 0x5e24