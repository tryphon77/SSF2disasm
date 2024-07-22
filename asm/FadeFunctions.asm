
fadeInStart:
	tst.b	(fadingAttenuation).w	; 0x22c
	beq.b	@end	; 0x230
	cmpi.b	#$fe, (fadingDelta).w	; 0x232
	beq.b	@end	; 0x238
	move.b	#$fe, (fadingDelta).w	; 0x23a
	move.b	#5, (fadingTimer).w	; 0x240
@end:
	rts		; 0x246

fadeOutStart:
	cmpi.b	#$0e, (fadingAttenuation).w	; 0x248
	beq.b	@end	; 0x24e
	cmpi.b	#2, (fadingDelta).w	; 0x250
	beq.b	@end	; 0x256
	move.b	#2, (fadingDelta).w	; 0x258
	move.b	#5, (fadingTimer).w	; 0x25e
@end:
	rts		; 0x264

fadeInStartAndProcess:
	bsr.b	fadeInStart	; 0x266
	bra.b	fadeOutProcess	; 0x268

fadeOutStartAndProcess:
	bsr.b	fadeOutStart	; 0x26a

fadeOutProcess:
	move.b	#1, d0	; 0x26c
	trap	#3	; 0x270
	tst.b	(fadingDelta).w	; 0x272
	bne.b	fadeOutProcess	; 0x276
	rts		; 0x278