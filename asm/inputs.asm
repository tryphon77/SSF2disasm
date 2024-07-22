
resetControllers:
	moveq	#$0040, d0	; 0x4874
	move.b	d0, pad1Ctrl	; 0x4876
	move.b	d0, pad2Ctrl	; 0x487c
	move.b	d0, IoCtrlExt	; 0x4882
	rts		; 0x4888

readJoysStates:
	move.w	d7, (a4)	; 0x488a
	move.l	#$00a10003, a0	; 0x488c
	lea	(joy1State).w, a1	; 0x4892
	bsr.b	readJoyState	; 0x4896
	lea	(2, a0), a0	; 0x4898
	lea	(joy2State).w, a1	; 0x489c
	bsr.b	readJoyState	; 0x48a0
	move.w	d6, (a4)	; 0x48a2
	rts		; 0x48a4

readJoyState:
	moveq	#0, d0	; 0x48a6
	move.b	#$70, (a0)	; 0x48a8
	bsr.b	readController	; 0x48ac
	swap	d1	; 0x48ae
	add.w	d0, d0	; 0x48b0
	move.b	#$30, (a0)	; 0x48b2
	bsr.b	readController	; 0x48b6
	move.b	d0, (a1)+	; 0x48b8
	andi.w	#$000e, d0	; 0x48ba
	move.w	(buttonsCallbacks, pc, d0.w), d0	; 0x48be
	jmp	(buttonsCallbacks, pc, d0.w)	; 0x48c2

buttonsCallbacks:
	dc.w	buttonsCallback00To05-buttonsCallbacks	; 0x48c6
	dc.w	buttonsCallback00To05-buttonsCallbacks	; 0x48c8
	dc.w	buttonsCallback00To05-buttonsCallbacks	; 0x48ca
	dc.w	buttonsCallback00To05-buttonsCallbacks	; 0x48cc
	dc.w	buttonsCallback00To05-buttonsCallbacks	; 0x48ce
	dc.w	buttonsCallback00To05-buttonsCallbacks	; 0x48d0
	dc.w	buttonsCallback06-buttonsCallbacks	; 0x48d2
	dc.w	buttonsCallback07-buttonsCallbacks	; 0x48d4

readController:
	move.b	(a0), d1	; 0x48d6
	move.b	d1, d2	; 0x48d8
	andi.b	#$0c, d2	; 0x48da
	beq.b	@bits_cleared_1	; 0x48de
	addq.w	#1, d0	; 0x48e0
@bits_cleared_1:
	add.w	d0, d0	; 0x48e2
	move.b	d1, d3	; 0x48e4
	andi.b	#3, d3	; 0x48e6
	beq.b	@bits_cleared_2	; 0x48ea
	addq.w	#1, d0	; 0x48ec
@bits_cleared_2:
	rts		; 0x48ee

buttonsCallback00To05:
	move.b	#$0f, (a1)+	; 0x48f0
	clr.l	(a1)	; 0x48f4
	rts		; 0x48f6

buttonsCallback07:
	move.b	#$ff, (a1)+	; 0x48f8
	clr.l	(a1)	; 0x48fc
	rts		; 0x48fe
	move.b	#$40, (6, a0)	; 0x4900
	move.b	#$ff, (a1)+	; 0x4906
	bra.b	three_buttons_pad_100	; 0x490a

buttonsCallback06:
	move.b	#$40, (6, a0)	; 0x490c
	moveq	#2, d3	; 0x4912
@next:
	move.l	d1, d0	; 0x4914
	andi.b	#$0f, d0	; 0x4916
	beq.b	six_buttons_pad_100	; 0x491a
	move.b	#$40, (a0)	; 0x491c
	moveq	#0, d1	; 0x4920
	nop		; 0x4922
	nop		; 0x4924
	nop		; 0x4926
	move.b	(a0), d1	; 0x4928
	move.b	#0, (a0)	; 0x492a
	swap	d1	; 0x492e
	nop		; 0x4930
	nop		; 0x4932
	nop		; 0x4934
	move.b	(a0), d1	; 0x4936
	dbf	d3, @next	; 0x4938
	move.b	#0, (a1)+	; 0x493c

three_buttons_pad_100:
	move.w	d1, d0	; 0x4940
	swap	d1	; 0x4942
	lsl.w	#2, d0	; 0x4944
	andi.w	#$00c0, d0	; 0x4946
	andi.w	#$003f, d1	; 0x494a
	or.w	d1, d0	; 0x494e
	not.b	d0	; 0x4950
	bsr.b	readJoyKeysPressed	; 0x4952
	move.b	#$40, (a0)	; 0x4954
	rts		; 0x4958

six_buttons_pad_100:
	move.b	#1, (a1)+	; 0x495a
	move.b	#$40, (a0)	; 0x495e
	moveq	#0, d2	; 0x4962
	nop		; 0x4964
	nop		; 0x4966
	nop		; 0x4968
	move.b	(a0), d2	; 0x496a
	move.b	#0, (a0)	; 0x496c
	swap	d2	; 0x4970
	nop		; 0x4972
	nop		; 0x4974
	nop		; 0x4976
	move.b	(a0), d2	; 0x4978
	swap	d2	; 0x497a
	move.w	d1, d0	; 0x497c
	swap	d1	; 0x497e
	lsl.w	#2, d0	; 0x4980
	andi.w	#$00c0, d0	; 0x4982
	andi.w	#$003f, d1	; 0x4986
	andi.w	#$000f, d2	; 0x498a
	lsl.w	#8, d2	; 0x498e
	or.w	d1, d0	; 0x4990
	or.w	d2, d0	; 0x4992
	eori.w	#$0fff, d0	; 0x4994
	bsr.b	readJoyKeysPressed	; 0x4998
	move.b	#$40, (a0)	; 0x499a
	rts		; 0x499e

readJoyKeysPressed:
	move.w	(a1), d1	; 0x49a0
	eor.w	d0, d1	; 0x49a2
	move.w	d0, (a1)+	; 0x49a4
	and.w	d0, d1	; 0x49a6
	move.w	d1, (a1)	; 0x49a8
	rts		; 0x49aa