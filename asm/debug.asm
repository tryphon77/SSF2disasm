	movem.l	d0/d1/d2/d3/d4/d5/d6/d7/a0/a1/a2/a3/a4/a5/a6/a7, -(a7)	; 0x4118
	move.b	#$ff, (LBL_ffffa63c).w	; 0x411c
	bra.b	handleErrorNoMessage	; 0x4122

Error02:
	movem.l	d0/d1/d2/d3/d4/d5/d6/d7/a0/a1/a2/a3/a4/a5/a6/a7, -(a7)	; 0x4124
	moveq	#2, d0	; 0x4128
	bra.b	handleError	; 0x412a

Error03:
	movem.l	d0/d1/d2/d3/d4/d5/d6/d7/a0/a1/a2/a3/a4/a5/a6/a7, -(a7)	; 0x412c
	moveq	#3, d0	; 0x4130
	bra.b	handleError	; 0x4132

Error04:
	movem.l	d0/d1/d2/d3/d4/d5/d6/d7/a0/a1/a2/a3/a4/a5/a6/a7, -(a7)	; 0x4134
	moveq	#4, d0	; 0x4138
	bra.b	handleError	; 0x413a

Error05:
	movem.l	d0/d1/d2/d3/d4/d5/d6/d7/a0/a1/a2/a3/a4/a5/a6/a7, -(a7)	; 0x413c
	moveq	#5, d0	; 0x4140
	bra.b	handleError	; 0x4142

Error06:
	movem.l	d0/d1/d2/d3/d4/d5/d6/d7/a0/a1/a2/a3/a4/a5/a6/a7, -(a7)	; 0x4144
	moveq	#6, d0	; 0x4148
	bra.b	handleError	; 0x414a

Error07:
	movem.l	d0/d1/d2/d3/d4/d5/d6/d7/a0/a1/a2/a3/a4/a5/a6/a7, -(a7)	; 0x414c
	moveq	#7, d0	; 0x4150
	bra.b	handleError	; 0x4152

Error08:
	movem.l	d0/d1/d2/d3/d4/d5/d6/d7/a0/a1/a2/a3/a4/a5/a6/a7, -(a7)	; 0x4154
	moveq	#8, d0	; 0x4158
	bra.b	handleError	; 0x415a

Error09:
	movem.l	d0/d1/d2/d3/d4/d5/d6/d7/a0/a1/a2/a3/a4/a5/a6/a7, -(a7)	; 0x415c
	moveq	#9, d0	; 0x4160
	bra.b	handleError	; 0x4162

Error0a:
	movem.l	d0/d1/d2/d3/d4/d5/d6/d7/a0/a1/a2/a3/a4/a5/a6/a7, -(a7)	; 0x4164
	moveq	#$000a, d0	; 0x4168
	bra.b	handleError	; 0x416a

Error0b:
	movem.l	d0/d1/d2/d3/d4/d5/d6/d7/a0/a1/a2/a3/a4/a5/a6/a7, -(a7)	; 0x416c
	moveq	#$000b, d0	; 0x4170
	bra.b	handleError	; 0x4172
	dc.w	$020a, $0217, $0228, $0240, $024f, $0262, $0277, $028e, $02a1, $02b2	; 0x4174

handleError:
	move.b	d0, (LBL_ffffa63c).w	; 0x4188
	ext.w	d0	; 0x418c
	add.w	d0, d0	; 0x418e
	move.w	(16752, pc, d0.w), d0	; 0x4190
	lea	(16756, pc, d0.w), a0	; 0x4194

handleErrorNoMessage:
	move.l	a0, (LBL_ffffa630).w	; 0x4198
	move.l	a7, (LBL_ffffa634).w	; 0x419c
	move.l	#$ffff0000, (LBL_ffffa638).w	; 0x41a0
@loop:
	jsr	($446e, pc)	; 0x41a8
	move.l	#$c0000000, (4, a5)	; 0x41ac
	lea	(rawPalettes).w, a0	; 0x41b4
	moveq	#7, d7	; 0x41b8
@next1:
	move.l	(a0)+, (a5)	; 0x41ba
	dbf	d7, @next1	; 0x41bc
	move.l	#$610c0003, (4, a5)	; 0x41c0
	move.l	(LBL_ffffa630).w, a0	; 0x41c8
	move.w	#$8000, d0	; 0x41cc
@next2:
	move.b	(a0)+, d0	; 0x41d0
	beq.b	@exit2	; 0x41d2
	move.w	d0, (a5)	; 0x41d4
	bra.b	@next2	; 0x41d6
@exit2:
	lea	($4437, pc), a0	; 0x41d8
	move.l	(LBL_ffffa634).w, a1	; 0x41dc
	move.w	#$6422, d0	; 0x41e0
	bsr.w	FUN_000042c6	; 0x41e4
	move.w	#$6408, d0	; 0x41e8
	bsr.w	FUN_000042c6	; 0x41ec
	lea	(2, a1), a1	; 0x41f0
	cmpi.b	#4, (LBL_ffffa63c).w	; 0x41f4
	bcc.b	@skip	; 0x41fa
	lea	(8, a1), a1	; 0x41fc
@skip:
	move.w	#$6288, d0	; 0x4200
	bsr.w	FUN_000042d6	; 0x4204
	bsr.w	writeLong	; 0x4208
	lea	(-6, a1), a1	; 0x420c
	move.w	#$6308, d0	; 0x4210
	bsr.w	FUN_000042d6	; 0x4214
	bsr.w	displayCrStatus	; 0x4218
	bsr.w	displayDebugInfo	; 0x421c
	ori.b	#$40, (VdpRegistersCache).w	; 0x4220
	move.w	(VdpRegistersCache).w, (4, a5)	; 0x4226
	bsr.b	FUN_0000423a	; 0x422c
	jsr	($451a, pc)	; 0x422e
	bsr.w	waitButtonC	; 0x4232
	bra.w	@loop	; 0x4236

FUN_0000423a:
	clr.b	(isVIntProcessed).w	; 0x423a
@wait_vint:
	tst.b	(isVIntProcessed).w	; 0x423e
	beq.b	@wait_vint	; 0x4242
	btst	#7, (joy1State).w	; 0x4244
	beq.b	@no_start	; 0x424a
	rts		; 0x424c
@no_start:
	move.w	(joy1State).w, d0	; 0x424e
	btst	#$000a, d0	; 0x4252
	beq.b	@no_button_y	; 0x4256
	move.w	(joy1State).w, d0	; 0x4258
@no_button_y:
	btst	#0, d0	; 0x425c
	beq.b	@no_up	; 0x4260
	addq.w	#8, (LBL_ffffa63a).w	; 0x4262
	btst	#6, (joy1State).w	; 0x4266
	beq.b	@no_button_c	; 0x426c
	addi.w	#$00f8, (LBL_ffffa63a).w	; 0x426e
	bra.b	@no_button_c	; 0x4274
@no_up:
	btst	#1, d0	; 0x4276
	beq.b	@no_down	; 0x427a
	subq.w	#8, (LBL_ffffa63a).w	; 0x427c
	btst	#6, (joy1State).w	; 0x4280
	beq.b	@no_button_c	; 0x4286
	subi.w	#$00f8, (LBL_ffffa63a).w	; 0x4288
	bra.b	@no_button_c	; 0x428e
@no_down:
	btst	#4, (joy1State).w	; 0x4290
	beq.b	@no_button_a	; 0x4296
	move.w	#0, (LBL_ffffa63a).w	; 0x4298
	bra.b	@no_button_c	; 0x429e
@no_button_a:
	btst	#5, (joy1State).w	; 0x42a0
	beq.b	FUN_0000423a	; 0x42a6
	move.w	#$8000, (LBL_ffffa63a).w	; 0x42a8
@no_button_c:
	bsr.b	displayDebugInfo	; 0x42ae
	bra.b	FUN_0000423a	; 0x42b0

waitButtonC:
	clr.b	(isVIntProcessed).w	; 0x42b2
@wait_vint:
	tst.b	(isVIntProcessed).w	; 0x42b6
	beq.b	@wait_vint	; 0x42ba
	btst	#7, (joy1State).w	; 0x42bc
	beq.b	waitButtonC	; 0x42c2
	rts		; 0x42c4

FUN_000042c6:
	moveq	#7, d6	; 0x42c6
@next:
	bsr.b	FUN_000042d6	; 0x42c8
	bsr.b	writeLong	; 0x42ca
	addi.w	#$0080, d0	; 0x42cc
	dbf	d6, @next	; 0x42d0
	rts		; 0x42d4

FUN_000042d6:
	move.w	d0, (4, a5)	; 0x42d6
	move.w	#3, (4, a5)	; 0x42da
	moveq	#0, d1	; 0x42e0
	moveq	#2, d7	; 0x42e2
@next:
	move.b	(a0)+, d1	; 0x42e4
	move.w	d1, (a5)	; 0x42e6
	dbf	d7, @next	; 0x42e8
	rts		; 0x42ec

writeLong:
	move.l	(a1)+, d1	; 0x42ee
	moveq	#7, d7	; 0x42f0

writeHexDigits:
	rol.l	#4, d1	; 0x42f2
	move.w	d1, d2	; 0x42f4
	andi.w	#$000f, d2	; 0x42f6
	move.b	(hexDigits, pc, d2.w), d2	; 0x42fa
	move.w	d2, (a5)	; 0x42fe
	dbf	d7, writeHexDigits	; 0x4300
	rts		; 0x4304

displayCrStatus:
	move.l	(a1)+, d1	; 0x4306
	moveq	#0, d3	; 0x4308
	moveq	#$000f, d7	; 0x430a
@next:
	move.b	#$2e, d2	; 0x430c
	rol.l	#1, d1	; 0x4310
	bcc.b	@loc_00004318	; 0x4312
	move.b	(crStatusStr, pc, d3.w), d2	; 0x4314
@loc_00004318:
	move.w	d2, (a5)	; 0x4318
	addq.w	#1, d3	; 0x431a
	dbf	d7, @next	; 0x431c
	rts		; 0x4320

displayDebugInfo:
	move.l	(LBL_ffffa638).w, a1	; 0x4322
	move.w	#$6888, d0	; 0x4326
	moveq	#7, d6	; 0x432a
@next:
	move.w	d0, (4, a5)	; 0x432c
	move.w	#3, (4, a5)	; 0x4330
	move.l	a1, d1	; 0x4336
	rol.l	#8, d1	; 0x4338
	moveq	#5, d7	; 0x433a
	bsr.b	writeHexDigits	; 0x433c
	move.w	#$0020, (a5)	; 0x433e
	bsr.b	writeLong	; 0x4342
	move.w	#$0020, (a5)	; 0x4344
	bsr.b	writeLong	; 0x4348
	move.l	a1, d1	; 0x434a
	ori.l	#$ffff0000, d1	; 0x434c
	move.l	d1, a1	; 0x4352
	addi.w	#$0080, d0	; 0x4354
	dbf	d6, @next	; 0x4358
	rts		; 0x435c

hexDigits:
	dc.b	'0'	; 0x435e
	dc.b	'1'	; 0x435f
	dc.b	'2'	; 0x4360
	dc.b	'3'	; 0x4361
	dc.b	'4'	; 0x4362
	dc.b	'5'	; 0x4363
	dc.b	'6'	; 0x4364
	dc.b	'7'	; 0x4365
	dc.b	'8'	; 0x4366
	dc.b	'9'	; 0x4367
	dc.b	'A'	; 0x4368
	dc.b	'B'	; 0x4369
	dc.b	'C'	; 0x436a
	dc.b	'D'	; 0x436b
	dc.b	'E'	; 0x436c
	dc.b	'F'	; 0x436d

crStatusStr:
	dc.b	"T?S??III???XNZVC02 BUS ERROR", $00	; 0x436e
	dc.b	"03 ADDRESS ERROR", $00	; 0x438b
	dc.b	"04 ILLEGAL INSTRRUCTION", $00	; 0x439c
	dc.b	"05 ZERO DEVIDE", $00	; 0x43b4
	dc.b	"06 CHK INSTRUCTION", $00	; 0x43c3
	dc.b	"07 TRAPV INSTRUCTION", $00	; 0x43d6
	dc.b	"08 PRIVILEGE VIOLATION", $00	; 0x43eb
	dc.b	"09 TRACE EXCEPTION", $00	; 0x4402
	dc.b	"10 1010 EMULATOR", $00	; 0x4415
	dc.b	"11 1111 EMULATOR", $00	; 0x4426

str_D0_D1_D2_D3_D4_D5_D6_D7_A0_A1_A2:
	dc.b	$44, $30, $20, $44, $31, $20, $44, $32, $20, $44, $33, $20, $44, $34, $20, $44, $35, $20, $44, $36, $20, $44, $37, $20, $41, $30, $20, $41, $31, $20, $41, $32, $20, $41, $33, $20, $41, $34, $20, $41, $35, $20, $41, $36, $20, $41, $37, $20, $50, $43, $20, $53, $52, $20, $b4	; 0x4437

FUN_0000446e:
	andi.b	#$bf, (VdpRegistersCache).w	; 0x446e
	move.w	(VdpRegistersCache).w, (4, a5)	; 0x4474
	move.w	(hintFun).w, (LBL_ffffba46).w	; 0x447a
	clr.w	(hintFun).w	; 0x4480
	move.w	(VdpRegistersCache).w, (LBL_ffffba4c).w	; 0x4484
	move.w	#$8004, d5	; 0x448a
	move.w	d5, (VdpRegistersCache).w	; 0x448e
	move.w	d5, (4, a5)	; 0x4492
	move.w	#$8b00, (4, a5)	; 0x4496
	move.w	#$9200, (4, a5)	; 0x449c
	moveq	#0, d0	; 0x44a2
	move.l	#$00000010, (4, a5)	; 0x44a4
	move.l	(a5), (vsRamCache5).w	; 0x44ac
	move.l	#$40000010, (4, a5)	; VSRAM write to 0000	; 0x44b0
	move.l	d0, (a5)	; 0x44b8
	move.l	#$1c000003, (4, a5)	; 0x44ba
	move.l	(a5), (LBL_ffffba42).w	; 0x44c2
	move.l	#$5c000003, (4, a5)	; 0x44c6
	move.l	d0, (a5)	; 0x44ce
	move.l	#$20000003, (4, a5)	; 0x44d0
	lea	(LBL_ffffa63e).w, a0	; 0x44d8
	move.w	#$03ff, d7	; 0x44dc
@next1:
	move.l	(a5), (a0)+	; 0x44e0
	dbf	d7, @next1	; 0x44e2
	jsr	(sendPlaneA).w	; 0x44e6
	move.l	#$1a000003, (4, a5)	; 0x44ea
	lea	(LBL_ffffb63e).w, a0	; 0x44f2
	move.w	#$007f, d7	; 0x44f6
@next2:
	move.l	(a5), (a0)+	; 0x44fa
	dbf	d7, @next2	; 0x44fc
	jsr	(sendSat).w	; 0x4500
	lea	(SAT_cache).w, a0	; 0x4504
	lea	(SAT_cache_copy_).w, a1	; 0x4508
	moveq	#$007f, d7	; 0x450c
@next3:
	move.l	(a0)+, (a1)+	; 0x450e
	dbf	d7, @next3	; 0x4510
	jsr	(clearSatCache).w	; 0x4514
	rts		; 0x4518

FUN_0000451a:
	andi.b	#$bf, (VdpRegistersCache).w	; 0x451a
	move.w	(VdpRegistersCache).w, (4, a5)	; 0x4520
	move.l	#$40000010, (4, a5)	; VSRAM write to 0000	; 0x4526
	move.l	(vsRamCache5).w, (a5)	; 0x452e
	move.l	#$5c000003, (4, a5)	; 0x4532
	move.l	(LBL_ffffba42).w, (a5)	; 0x453a
	move.l	#$60000003, (4, a5)	; 0x453e
	lea	(LBL_ffffa63e).w, a0	; 0x4546
	move.w	#$03ff, d7	; 0x454a
@next1:
	move.l	(a0)+, (a5)	; 0x454e
	dbf	d7, @next1	; 0x4550
	move.l	#$5a000003, (4, a5)	; 0x4554
	lea	(LBL_ffffb63e).w, a0	; 0x455c
	move.w	#$007f, d7	; 0x4560
@next2:
	move.l	(a0)+, (a5)	; 0x4564
	dbf	d7, @next2	; 0x4566
	lea	(SAT_cache).w, a0	; 0x456a
	lea	(SAT_cache_copy_).w, a1	; 0x456e
	moveq	#$007f, d7	; 0x4572
@next3:
	move.l	(a1)+, (a0)+	; 0x4574
	dbf	d7, @next3	; 0x4576
	move.w	(VdpRegistersCache).w, (4, a5)	; 0x457a
	move.w	(VdpRegistersCache).w, (4, a5)	; 0x4580
	move.w	(LBL_ffffba4c).w, (VdpRegistersCache).w	; 0x4586
	move.w	(VdpRegistersCache).w, (4, a5)	; 0x458c
	move.w	(LBL_ffffba46).w, (hintFun).w	; 0x4592
	ori.b	#$40, (VdpRegistersCache).w	; 0x4598
	move.w	(VdpRegistersCache).w, (4, a5)	; 0x459e
	rts		; 0x45a4

FUN_000045a6:
	bsr.w	FUN_0000446e	; 0x45a6
	lea	($4748, pc), a0	; 0x45aa
	jsr	(writeText).w	; 0x45ae
	bsr.w	proceed	; 0x45b2
	ori.b	#$40, (VdpRegistersCache).w	; 0x45b6
	move.w	(VdpRegistersCache).w, (4, a5)	; 0x45bc
	bsr.w	FUN_000045ca	; 0x45c2
	bra.w	FUN_0000451a	; 0x45c6

FUN_000045ca:
	clr.b	(isVIntProcessed).w	; 0x45ca
@wait_vint:
	tst.b	(isVIntProcessed).w	; 0x45ce
	beq.b	@wait_vint	; 0x45d2
	btst	#7, (joy1State).w	; 0x45d4
	beq.b	@no_start_button	; 0x45da
	rts		; 0x45dc
@no_start_button:
	bsr.b	FUN_000045e4	; 0x45de
	bsr.b	FUN_0000464a	; 0x45e0
	bra.b	FUN_000045ca	; 0x45e2

FUN_000045e4:
	btst	#0, (joy1State).w	; 0x45e4
	beq.b	@no_up_pressed	; 0x45ea
	move.b	#8, (LBL_ffffba4e).w	; 0x45ec
	bra.b	@proceed1	; 0x45f2
@no_up_pressed:
	btst	#0, (joy1State).w	; 0x45f4
	beq.b	@no_up	; 0x45fa
	tst.b	(LBL_ffffba4e).w	; 0x45fc
	beq.b	@proceed1	; 0x4600
	subq.b	#1, (LBL_ffffba4e).w	; 0x4602
	bra.b	@no_up	; 0x4606
@proceed1:
	addi.w	#$0010, (LBL_ffffba48).w	; 0x4608
	andi.w	#$07f0, (LBL_ffffba48).w	; 0x460e
	bra.w	proceed	; 0x4614
@no_up:
	btst	#1, (joy1State).w	; 0x4618
	beq.b	@no_down_pressed	; 0x461e
	move.b	#8, (LBL_ffffba4e).w	; 0x4620
	bra.b	@proceed2	; 0x4626
@no_down_pressed:
	btst	#1, (joy1State).w	; 0x4628
	beq.b	return170	; 0x462e
	tst.b	(LBL_ffffba4e).w	; 0x4630
	beq.b	@proceed2	; 0x4634
	subq.b	#1, (LBL_ffffba4e).w	; 0x4636
	bra.b	return170	; 0x463a
@proceed2:
	subi.w	#$0010, (LBL_ffffba48).w	; 0x463c
	andi.w	#$07f0, (LBL_ffffba48).w	; 0x4642
	bra.b	proceed	; 0x4648

FUN_0000464a:
	btst	#2, (joy1State).w	; 0x464a
	beq.b	@no_left_pressed	; 0x4650
	move.w	(LBL_ffffba4a).w, d0	; 0x4652
	subi.w	#$2000, d0	; 0x4656
	andi.w	#$6000, d0	; 0x465a
	andi.w	#$9fff, (LBL_ffffba4a).w	; 0x465e
	or.w	d0, (LBL_ffffba4a).w	; 0x4664
	bra.b	proceed	; 0x4668
@no_left_pressed:
	btst	#3, (joy1State).w	; 0x466a
	beq.b	@no_right_pressed	; 0x4670
	move.w	(LBL_ffffba4a).w, d0	; 0x4672
	addi.w	#$2000, d0	; 0x4676
	andi.w	#$6000, d0	; 0x467a
	andi.w	#$9fff, (LBL_ffffba4a).w	; 0x467e
	or.w	d0, (LBL_ffffba4a).w	; 0x4684
	bra.b	proceed	; 0x4688
@no_right_pressed:
	btst	#6, (joy1State).w	; 0x468a
	beq.b	@no_button_b	; 0x4690
	eori.w	#$1000, (LBL_ffffba4a).w	; 0x4692
	bra.b	proceed	; 0x4698
@no_button_b:
	btst	#4, (joy1State).w	; 0x469a
	beq.b	return170	; 0x46a0
	eori.w	#$0800, (LBL_ffffba4a).w	; 0x46a2
	bra.b	proceed	; 0x46a8

return170:
	rts		; 0x46aa

proceed:
	move.w	#$650a, d3	; 0x46ac
	move.w	(LBL_ffffba48).w, d0	; 0x46b0
	move.w	(LBL_ffffba4a).w, d2	; 0x46b4
	moveq	#$000f, d6	; 0x46b8
@next2:
	move.w	d3, (4, a5)	; 0x46ba
	move.w	#3, (4, a5)	; 0x46be
	bsr.b	printHexU8	; 0x46c4
	moveq	#$000f, d7	; 0x46c6
@next1:
	move.w	d0, d1	; 0x46c8
	or.w	d2, d1	; 0x46ca
	move.w	d1, (a5)	; 0x46cc
	addq.w	#1, d0	; 0x46ce
	dbf	d7, @next1	; 0x46d0
	andi.w	#$07f0, d0	; 0x46d4
	addi.w	#$0080, d3	; 0x46d8
	dbf	d6, @next2	; 0x46dc
	move.l	#$639c0003, (4, a5)	; 0x46e0
	move.w	(LBL_ffffba4a).w, d0	; 0x46e8
	rol.w	#3, d0	; 0x46ec
	andi.w	#3, d0	; 0x46ee
	bsr.b	printHexDigit	; 0x46f2
	move.l	#$63a60003, (4, a5)	; 0x46f4
	move.w	(LBL_ffffba4a).w, d0	; 0x46fc
	rol.w	#4, d0	; 0x4700
	andi.w	#1, d0	; 0x4702
	bsr.b	printHexDigit	; 0x4706
	move.l	#$63ae0003, (4, a5)	; 0x4708
	move.w	(LBL_ffffba4a).w, d0	; 0x4710
	rol.w	#5, d0	; 0x4714
	andi.w	#1, d0	; 0x4716
	bsr.b	printHexDigit	; 0x471a
	rts		; 0x471c

printHexU8:
	move.w	d0, d1	; 0x471e
	lsr.w	#8, d1	; 0x4720
	andi.w	#$000f, d1	; 0x4722
	move.b	(hexDigitsAlt, pc, d1.w), d1	; 0x4726
	move.w	d1, (a5)	; 0x472a
	move.w	d0, d1	; 0x472c
	lsr.w	#4, d1	; 0x472e
	andi.w	#$000f, d1	; 0x4730
	move.b	(hexDigitsAlt, pc, d1.w), d1	; 0x4734
	move.w	d1, (a5)	; 0x4738

printHexDigit:
	move.w	d0, d1	; 0x473a
	andi.w	#$000f, d1	; 0x473c
	move.b	(hexDigitsAlt, pc, d1.w), d1	; 0x4740
	move.w	d1, (a5)	; 0x4744
	rts		; 0x4746
	dc.b	"b", $10, $00	; 0x4748
	dc.b	"   VRAM DUMP", $ff, $ff, $ff, "COLOR=   V=  H=", $ff, $ff, "0123456789ABCDEF", $00	; 0x474b