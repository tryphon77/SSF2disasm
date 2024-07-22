
checkAirProjectionBox:
	moveq	#1, d6	; 0x164a
	bra.b	check_projection_box	; 0x164c

checkProjectionBox:
	moveq	#0, d6	; 0x164e

check_projection_box:
	tst.b	(240, a6)	; 0x1650
	bne.w	@return_0	; 0x1654
	cmpi.w	#$0012, (stageId).w	; 0x1658
	beq.w	@return_0	; 0x165e
	tst.b	(116, a6)	; 0x1662
	bne.w	@return_0	; 0x1666
	move.w	(60, a6), d1	; 0x166a
	bmi.w	@return_0	; 0x166e
	cmp.w	(70, a6), d1	; 0x1672
	bne.w	@return_0	; 0x1676
	move.w	(662, a6), a3	; 0x167a
	tst.b	(116, a3)	; 0x167e
	bne.w	@return_0	; 0x1682
	move.w	(60, a3), d1	; 0x1686
	bmi.w	@return_0	; 0x168a
	cmp.w	(70, a3), d1	; 0x168e
	bne.w	@return_0	; 0x1692
	tst.b	(a3)	; 0x1696
	beq.w	@return_0	; 0x1698
	move.b	(3, a3), d1	; 0x169c
	cmpi.b	#$14, d1	; 0x16a0
	beq.w	@return_0	; 0x16a4
	tst.b	(113, a3)	; 0x16a8
	bne.b	@loc_000016B6	; 0x16ac
	cmpi.b	#$0e, d1	; 0x16ae
	beq.w	@return_0	; 0x16b2
@loc_000016B6:
	tst.b	d6	; 0x16b6
	bne.b	@loc_000016C2	; 0x16b8
	tst.b	(193, a3)	; 0x16ba
	bne.w	@return_0	; 0x16be
@loc_000016C2:
	tst.b	(186, a3)	; 0x16c2
	bne.w	@return_0	; 0x16c6
	tst.b	(74, a3)	; 0x16ca
	beq.w	@return_0	; 0x16ce
	tst.b	(75, a3)	; 0x16d2
	beq.w	@return_0	; 0x16d6
	tst.b	(76, a3)	; 0x16da
	beq.w	@return_0	; 0x16de
	tst.b	(234, a3)	; 0x16e2
	bne.w	@return_0	; 0x16e6
	tst.b	(235, a3)	; 0x16ea
	bne.w	@return_0	; 0x16ee
	lea	($1798, pc), a0	; 0x16f2
	adda.w	d0, a0	; 0x16f6
	move.w	(a0)+, d1	; 0x16f8
	move.w	(a0)+, d3	; 0x16fa
	move.w	(a0)+, d2	; 0x16fc
	move.w	(a0)+, d4	; 0x16fe
	tst.b	(25, a6)	; 0x1700
	beq.b	@not_flipped	; 0x1704
	neg.w	d1	; 0x1706
@not_flipped:
	add.w	(6, a6), d1	; 0x1708
	sub.w	(6, a3), d1	; 0x170c
	add.w	(128, a3), d2	; 0x1710
	add.w	d2, d1	; 0x1714
	add.w	d2, d2	; 0x1716
	cmp.w	d2, d1	; 0x1718
	bhi.b	@return_0	; 0x171a
	move.w	(10, a6), d5	; 0x171c
	sub.w	d3, d5	; 0x1720
	move.w	(10, a3), d6	; 0x1722
	sub.w	(130, a3), d6	; 0x1726
	sub.w	d6, d5	; 0x172a
	add.w	d4, d5	; 0x172c
	add.w	d4, d4	; 0x172e
	cmp.w	d4, d5	; 0x1730
	bhi.b	@return_0	; 0x1732
	exg	a6, a3	; 0x1734
	jsr	($1dec, pc)	; 0x1736
	nop		; 0x173a
	exg	a6, a3	; 0x173c
	tst.b	(isSomeoneHit).w	; 0x173e
	bne.b	@no_one_hit	; 0x1742
	move.b	#1, (isSomeoneHit).w	; 0x1744
	move.b	#2, (406, a6)	; 0x174a
	clr.b	(407, a6)	; 0x1750
@no_one_hit:
	moveq	#0, d0	; 0x1754
	move.w	d0, (144, a3)	; 0x1756
	move.b	d0, (194, a3)	; 0x175a
	move.b	#1, (117, a6)	; 0x175e
	move.b	#$ff, (117, a3)	; 0x1764
	move.b	(113, a3), (115, a3)	; 0x176a
	move.b	(393, a3), (416, a3)	; 0x1770
	clr.b	(393, a3)	; 0x1776
	clr.b	(113, a3)	; 0x177a
	move.b	(641, a6), d0	; 0x177e
	bset	d0, (projectionFlags).w	; 0x1782
	jsr	fixFF97F8Alt	; 0x1786
	clr.b	(179, a6)	; 0x178c
	moveq	#1, d0	; 0x1790
	rts		; 0x1792
@return_0:
	moveq	#0, d0	; 0x1794
	rts		; 0x1796

projectionBoxes:
	dc.w	-14,46,14,14	; box	; 0x1798
	dc.w	-18,46,18,14	; box	; 0x17a0
	dc.w	-14,46,14,14	; box	; 0x17a8
	dc.w	-17,62,12,14	; box	; 0x17b0
	dc.w	-17,35,12,14	; box	; 0x17b8
	dc.w	-14,46,14,14	; box	; 0x17c0
	dc.w	-16,49,18,24	; box	; 0x17c8
	dc.w	-19,46,21,14	; box	; 0x17d0
	dc.w	-23,66,13,17	; box	; 0x17d8
	dc.w	-23,48,13,17	; box	; 0x17e0
	dc.w	-16,49,32,55	; box	; 0x17e8
	dc.w	-12,49,27,55	; box	; 0x17f0
	dc.w	-27,49,37,55	; box	; 0x17f8
	dc.w	-15,46,15,14	; box	; 0x1800
	dc.w	-14,46,14,14	; box	; 0x1808
	dc.w	-14,46,14,14	; box	; 0x1810
	dc.w	-17,79,18,14	; box	; 0x1818
	dc.w	0,43,31,42	; box	; 0x1820
	dc.w	-17,45,17,26	; box	; 0x1828
	dc.w	-10,46,14,14	; box	; 0x1830
	dc.w	-16,53,18,26	; box	; 0x1838
	dc.w	-16,75,18,15	; box	; 0x1840
	dc.w	-16,49,32,55	; box	; 0x1848
	dc.w	-9,46,14,14	; box	; 0x1850
	dc.w	-9,46,14,14	; box	; 0x1858

FUN_00001860:
	move.w	(662, a6), a3	; 0x1860
	move.b	#$0c, (101, a6)	; 0x1864
	move.b	#1, (417, a3)	; 0x186a
	bsr.w	createImpactObject	; 0x1870
	tst.b	(123, a6)	; 0x1874
	bmi.b	@loc_00001884	; 0x1878
	move.b	(123, a6), d2	; 0x187a
	move.b	#$ff, (123, a6)	; 0x187e
@loc_00001884:
	tst.b	(isFightOver).w	; 0x1884
	bne.b	@no_damage	; 0x1888
	bsr.w	computeProjectionDamage	; 0x188a
	tst.b	(isMatchOver).w	; 0x188e
	bne.b	@loc_000018A0	; 0x1892
	move.b	(641, a6), d0	; 0x1894
	ror.b	#1, d0	; 0x1898
	or.b	d5, d0	; 0x189a
	jsr	(appendToDamageList).w	; 0x189c
@loc_000018A0:
	tst.b	(LBL_ffff9939).w	; 0x18a0
	bne.b	@no_damage	; 0x18a4
	tst.b	(areWeOnBonusStage).w	; 0x18a6
	bne.b	@no_damage	; 0x18aa
	sub.w	d4, (60, a3)	; 0x18ac
	sub.w	d4, (70, a3)	; 0x18b0
@no_damage:
	tst.w	(60, a3)	; 0x18b4
	bmi.b	@dead	; 0x18b8
	moveq	#0, d0	; 0x18ba
	rts		; 0x18bc
@dead:
	move.w	#0, (60, a3)	; 0x18be
	move.w	#0, (70, a3)	; 0x18c4
	moveq	#0, d0	; 0x18ca
	rts		; 0x18cc

stepHold:
	move.w	(662, a6), a3	; 0x18ce
	move.b	#$0c, (101, a6)	; 0x18d2
	move.b	#1, (417, a3)	; 0x18d8
	bsr.w	createImpactObject	; 0x18de
	tst.b	(123, a6)	; 0x18e2
	bmi.b	@loc_000018F2	; 0x18e6
	move.b	(123, a6), d2	; 0x18e8
	move.b	#$ff, (123, a6)	; 0x18ec
@loc_000018F2:
	tst.b	(isFightOver).w	; 0x18f2
	bne.b	@loc_00001922	; 0x18f6
	bsr.w	computeProjectionDamage	; 0x18f8
	tst.b	(isMatchOver).w	; 0x18fc
	bne.b	@loc_0000190E	; 0x1900
	move.b	(641, a6), d0	; 0x1902
	ror.b	#1, d0	; 0x1906
	or.b	d5, d0	; 0x1908
	jsr	(appendToDamageList).w	; 0x190a
@loc_0000190E:
	tst.b	(LBL_ffff9939).w	; 0x190e
	bne.b	@loc_00001922	; 0x1912
	tst.b	(areWeOnBonusStage).w	; 0x1914
	bne.b	@loc_00001922	; 0x1918
	sub.w	d4, (60, a3)	; 0x191a
	sub.w	d4, (70, a3)	; 0x191e
@loc_00001922:
	tst.w	(60, a3)	; 0x1922
	bmi.b	@loc_0000192C	; 0x1926
@loc_00001928:
	moveq	#0, d0	; 0x1928
	rts		; 0x192a
@loc_0000192C:
	tst.b	(LBL_ffff9933).w	; 0x192c
	beq.b	@loc_00001940	; 0x1930
	move.w	#$00b0, d0	; 0x1932
	move.w	d0, (60, a3)	; 0x1936
	move.w	d0, (70, a3)	; 0x193a
	bra.b	@loc_00001928	; 0x193e
@loc_00001940:
	move.w	#$ffff, (60, a3)	; 0x1940
	move.w	#$ffff, (70, a3)	; 0x1946
	bsr.w	diePlayer	; 0x194c
	bsr.w	escapeHoldOrProjection	; 0x1950
	move.b	#4, (2, a3)	; 0x1954
	move.b	#0, (3, a3)	; 0x195a
	move.b	(25, a6), d0	; 0x1960
	move.b	d0, (72, a3)	; 0x1964
	moveq	#0, d0	; 0x1968
	move.b	d0, (4, a3)	; 0x196a
	move.b	d0, (5, a3)	; 0x196e
	move.b	d0, (191, a3)	; 0x1972
	move.b	d0, (194, a3)	; 0x1976
	move.b	d0, (113, a3)	; 0x197a
	move.b	d0, (393, a3)	; 0x197e
	move.b	d0, (115, a3)	; 0x1982
	move.b	d0, (416, a3)	; 0x1986
	moveq	#1, d0	; 0x198a
	rts		; 0x198c

createImpactObject:
	jsr	(getObjectSlot).w	; 0x198e
	bne.b	@play_sfx	; 0x1992
	addq.b	#1, (a0)	; 0x1994
	move.b	#2, (15, a0)	; 0x1996
	move.b	d3, (16, a0)	; 0x199c
	move.b	(641, a6), (17, a0)	; 0x19a0
	add.w	(6, a6), d4	; 0x19a6
	move.w	d4, (6, a0)	; 0x19aa
	move.w	(10, a6), d0	; 0x19ae
	sub.w	d5, d0	; 0x19b2
	move.w	d0, (10, a0)	; 0x19b4
	move.b	(25, a3), (25, a0)	; 0x19b8
@play_sfx:
	move.b	d6, d0	; 0x19be
	eori.b	#1, (23, a6)	; 0x19c0
	jsr	(putSfxInSfxQueue).w	; 0x19c6
	eori.b	#1, (23, a6)	; 0x19ca
	rts		; 0x19d0

getProjectionDamage:
	tst.b	(isFightOver).w	; 0x19d2
	bne.w	@no_damage	; 0x19d6
	bsr.w	computeProjectionDamage	; 0x19da
	move.w	d4, (118, a3)	; 0x19de
	move.b	d5, (120, a3)	; 0x19e2
	tst.b	(LBL_ffff9939).w	; 0x19e6
	bne.b	@no_damage	; 0x19ea
	tst.b	(areWeOnBonusStage).w	; 0x19ec
	bne.b	@loc_00001A2A	; 0x19f0
	move.w	(60, a3), d0	; 0x19f2
	sub.w	d4, d0	; 0x19f6
	bpl.b	@damage	; 0x19f8
	move.w	#$ffff, (60, a3)	; 0x19fa
	clr.w	(118, a3)	; 0x1a00
	tst.b	(isMatchOver).w	; 0x1a04
	bne.b	@match_over	; 0x1a08
	move.b	(641, a3), d0	; 0x1a0a
	eori.b	#1, d0	; 0x1a0e
	ror.b	#1, d0	; 0x1a12
	or.b	(120, a3), d0	; 0x1a14
	jsr	(appendToDamageList).w	; 0x1a18
@match_over:
	bra.w	diePlayer	; 0x1a1c
@no_damage:
	clr.w	(118, a3)	; 0x1a20
	clr.w	(120, a3)	; 0x1a24
@damage:
	rts		; 0x1a28
@loc_00001A2A:
	clr.w	(118, a3)	; 0x1a2a
	clr.w	(120, a3)	; 0x1a2e
	move.b	(641, a3), d0	; 0x1a32
	eori.b	#1, d0	; 0x1a36
	ror.b	#1, d0	; 0x1a3a
	or.b	d5, d0	; 0x1a3c
	jmp	(appendToDamageList).w	; 0x1a3e

computeProjectionDamage:
	bsr.b	computeProjectionDamageCommon1	; 0x1a42
	bra.w	computeProjectionDamageCommon2	; 0x1a44

computeProjectionDamageCommon1:
	move.b	d2, (LBL_ffffbb58).w	; 0x1a48
	andi.w	#$001f, d2	; 0x1a4c
	lea	LBL_031882, a2	; 0x1a50
	move.b	(0, a2, d2), d5	; 0x1a56
	move.b	d5, (LBL_ffff9896).w	; 0x1a5a
	tst.b	(LBL_ffffbb58).w	; 0x1a5e
	bpl.b	dont_store_in_ff9896	; 0x1a62
	lea	LBL_031893, a2	; 0x1a64
	move.b	(0, a2, d2), (LBL_ffff9896).w	; 0x1a6a

dont_store_in_ff9896:
	lsl.w	#4, d2	; 0x1a70
	lea	LBL_031772, a2	; 0x1a72
	adda.w	d2, a2	; 0x1a78
	move.w	(142, a6), d2	; 0x1a7a
	move.b	(0, a2, d2), d4	; 0x1a7e
	ext.w	d4	; 0x1a82
	rts		; 0x1a84

computeProjectionDamageCommon2:
	move.w	(662, a6), a3	; 0x1a86
	cmpi.w	#$0026, (60, a3)	; 0x1a8a
	bcc.b	@end	; 0x1a90
	lea	LBL_031ae4, a1	; 0x1a92
	move.w	(60, a3), d0	; 0x1a98
	move.b	(0, a1, d0), d0	; 0x1a9c
	ext.w	d0	; 0x1aa0
	mulu.w	d4, d0	; 0x1aa2
	lsr.w	#5, d0	; 0x1aa4
	sub.w	d0, d4	; 0x1aa6
	cmpi.w	#2, d4	; 0x1aa8
	bcc.b	@end	; 0x1aac
	moveq	#2, d4	; 0x1aae
@end:
	rts		; 0x1ab0

computeMultiStepProjectionDamage:
	bsr.b	computeProjectionDamageCommon1	; 0x1ab2
	move.l	d1, (LBL_ffffbb5a).w	; 0x1ab4
	move.l	d2, (LBL_ffffbb5e).w	; 0x1ab8
	move.l	d3, (LBL_ffffbb62).w	; 0x1abc
	move.w	(662, a6), a1	; 0x1ac0
	moveq	#0, d0	; 0x1ac4
	move.w	(142, a1), d2	; 0x1ac6
	move.b	(651, a1), d0	; 0x1aca
	add.w	d0, d0	; 0x1ace
	lea	LBL_031722, a1	; 0x1ad0
	move.w	(0, a1, d0), d0	; 0x1ad6
	lea	(0, a1, d0), a1	; 0x1ada
	moveq	#0, d3	; 0x1ade
	move.b	(0, a1, d2), d3	; 0x1ae0
	moveq	#0, d2	; 0x1ae4
	move.b	(418, a6), d2	; 0x1ae6
	cmpi.w	#$0032, (60, a6)	; 0x1aea
	bcs.b	@low_hp	; 0x1af0
	move.b	(419, a6), d2	; 0x1af2
@low_hp:
	lsl.w	#5, d2	; 0x1af6
	jsr	(random).w	; 0x1af8
	andi.w	#$001f, d0	; 0x1afc
	add.w	d0, d2	; 0x1b00
	lea	LBL_0318a4, a1	; 0x1b02
	move.b	(0, a1, d2), d0	; 0x1b08
	ext.w	d0	; 0x1b0c
	add.w	d0, d4	; 0x1b0e
	bmi.b	@multiplier_2	; 0x1b10
	beq.b	@multiplier_2	; 0x1b12
	bra.b	@process1	; 0x1b14
@multiplier_2:
	moveq	#2, d4	; 0x1b16
@process1:
	mulu.w	d4, d3	; 0x1b18
	lsr.w	#5, d3	; 0x1b1a
	sub.w	d3, d4	; 0x1b1c
	cmpi.w	#2, d4	; 0x1b1e
	bcc.b	@process2	; 0x1b22
	moveq	#2, d4	; 0x1b24
@process2:
	move.l	(LBL_ffffbb5a).w, d1	; 0x1b26
	move.l	(LBL_ffffbb5e).w, d2	; 0x1b2a
	move.l	(LBL_ffffbb62).w, d3	; 0x1b2e
	bra.w	computeProjectionDamageCommon2	; 0x1b32

atHoldingStart:
	move.b	d1, (123, a6)	; 0x1b36
	lea	LBL_030ca0, a3	; 0x1b3a
	move.l	a6, a4	; 0x1b40
	bsr.b	computeHoldCounter	; 0x1b42
	move.w	(124, a6), (126, a6)	; 0x1b44
	rts		; 0x1b4a

atHoldedStart:
	lea	LBL_030c80, a3	; 0x1b4c
	move.w	(662, a6), a4	; 0x1b52
	clr.b	(417, a4)	; 0x1b56

computeHoldCounter:
	ext.w	d0	; 0x1b5a
	move.w	d0, (124, a4)	; 0x1b5c
	jsr	(random).w	; 0x1b60
	andi.w	#$001f, d0	; 0x1b64
	move.b	(0, a3, d0), d0	; 0x1b68
	ext.w	d0	; 0x1b6c
	add.w	d0, (124, a4)	; 0x1b6e
	rts		; 0x1b72

updateHoldedFighter:
	move.w	(662, a6), a4	; 0x1b74
	tst.b	(isFightOver).w	; 0x1b78
	bne.b	@return_1	; 0x1b7c
	bsr.b	handleHoldKeys	; 0x1b7e
	sub.w	d3, (124, a4)	; 0x1b80
	bpl.b	return_100	; 0x1b84
@return_1:
	moveq	#1, d0	; 0x1b86
	rts		; 0x1b88

return_100:
	moveq	#0, d0	; 0x1b8a
	rts		; 0x1b8c

updateHoldingFighter:
	move.l	a6, a4	; 0x1b8e
	bsr.b	handleHoldKeysAlt	; 0x1b90
	sub.w	d3, (124, a6)	; 0x1b92
	bpl.b	return_100	; 0x1b96
	move.w	(126, a6), (124, a6)	; 0x1b98
	moveq	#1, d0	; 0x1b9e
	rts		; 0x1ba0

handleHoldKeys:
	tst.b	(648, a4)	; 0x1ba2
	beq.b	handle_keys_cpu	; 0x1ba6
	bra.b	handle_keys_human	; 0x1ba8

handleHoldKeysAlt:
	tst.b	(648, a4)	; 0x1baa
	beq.b	handle_keys_alt_cpu	; 0x1bae

handle_keys_human:
	moveq	#0, d1	; 0x1bb0
	moveq	#0, d3	; 0x1bb2
	move.w	(656, a4), d0	; 0x1bb4
	andi.w	#$000f, d0	; 0x1bb8
	bne.b	@old_keys_set	; 0x1bbc
	moveq	#1, d1	; 0x1bbe
@old_keys_set:
	move.w	(656, a4), d0	; 0x1bc0
	not.w	d0	; 0x1bc4
	and.w	(654, a4), d0	; 0x1bc6
	move.w	d0, d2	; 0x1bca
	tst.b	d1	; 0x1bcc
	beq.b	@d3_neq_3	; 0x1bce
	andi.w	#$000f, d0	; 0x1bd0
	beq.b	@d3_neq_3	; 0x1bd4
	move.w	#3, d3	; 0x1bd6
@d3_neq_3:
	andi.w	#$7700, d2	; 0x1bda
	beq.b	@return1	; 0x1bde
	addq.w	#1, d3	; 0x1be0
@return1:
	rts		; 0x1be2

handle_keys_cpu:
	moveq	#0, d3	; 0x1be4
	tst.b	(417, a4)	; 0x1be6
	beq.b	@return2	; 0x1bea
	lea	LBL_025d6e, a0	; 0x1bec
	move.w	(142, a4), d0	; 0x1bf2
	lsl.w	#2, d0	; 0x1bf6
	move.l	(0, a0, d0), d2	; 0x1bf8
	jsr	(random).w	; 0x1bfc
	andi.w	#$001f, d0	; 0x1c00
	btst	d0, d2	; 0x1c04
	beq.b	@return2	; 0x1c06
	moveq	#0, d0	; 0x1c08
	move.b	(651, a4), d0	; 0x1c0a
	lea	LBL_030ce0, a0	; 0x1c0e
	move.b	(0, a0, d0), d3	; 0x1c14
@return2:
	rts		; 0x1c18

handle_keys_alt_cpu:
	moveq	#0, d3	; 0x1c1a
	lea	LBL_025dae, a0	; 0x1c1c
	move.w	(142, a6), d0	; 0x1c22
	lsl.w	#2, d0	; 0x1c26
	move.l	(0, a0, d0), d2	; 0x1c28
	jsr	(random).w	; 0x1c2c
	andi.w	#$001f, d0	; 0x1c30
	btst	d0, d2	; 0x1c34
	beq.b	@return3	; 0x1c36
	moveq	#0, d0	; 0x1c38
	move.b	(651, a6), d0	; 0x1c3a
	lea	LBL_030cf0, a0	; 0x1c3e
	move.b	(0, a0, d0), d3	; 0x1c44
@return3:
	rts		; 0x1c48

FUN_00001c4a:
	move.w	(662, a6), a3	; 0x1c4a
	move.b	d0, (122, a3)	; 0x1c4e
	move.b	d1, (72, a3)	; 0x1c52
	bsr.w	getProjectionDamage	; 0x1c56
	move.b	#$14, (3, a3)	; 0x1c5a
	moveq	#0, d0	; 0x1c60
	move.w	d0, (4, a3)	; 0x1c62
	move.b	(115, a3), d0	; 0x1c66
	or.b	(416, a3), d0	; 0x1c6a
	clr.b	(115, a3)	; 0x1c6e
	clr.b	(416, a3)	; 0x1c72
	tst.b	d0	; 0x1c76
	bne.b	@return	; 0x1c78
	tst.w	(60, a3)	; 0x1c7a
	bmi.b	@return	; 0x1c7e
	bsr.w	updateProjected_6a_6c	; 0x1c80
@return:
	bra.w	escapeHoldOrProjection	; 0x1c84

atHoldEnd:
	move.w	(662, a6), a3	; 0x1c88
	move.b	d1, (72, a3)	; 0x1c8c
	move.b	#$0e, (3, a3)	; 0x1c90
	moveq	#0, d0	; 0x1c96
	move.b	d0, (4, a3)	; 0x1c98
	move.b	d0, (5, a3)	; 0x1c9c
	move.b	d0, (116, a3)	; 0x1ca0
	move.b	#$10, d0	; 0x1ca4
	tst.b	(112, a3)	; 0x1ca8
	beq.b	@d0_neq_12	; 0x1cac
	move.b	#$12, d0	; 0x1cae
@d0_neq_12:
	move.b	d0, (96, a3)	; 0x1cb2
	move.b	d0, (98, a3)	; 0x1cb6
	bra.w	escapeHoldOrProjection	; 0x1cba

atProjectionEnd:
	move.w	(662, a6), a3	; 0x1cbe
	move.b	d0, (122, a3)	; 0x1cc2
	move.b	d1, (72, a3)	; 0x1cc6
	bsr.w	createImpactObject	; 0x1cca
	tst.b	(LBL_ffff9939).w	; 0x1cce
	bne.w	fight_over	; 0x1cd2
	tst.b	(isFightOver).w	; 0x1cd6
	bne.b	fight_over	; 0x1cda
	bsr.w	computeProjectionDamage	; 0x1cdc

loop100:
	tst.b	(isMatchOver).w	; 0x1ce0
	bne.b	@match_over	; 0x1ce4
	cmp.w	(60, a3), d4	; 0x1ce6
	bmi.b	@skip	; 0x1cea
	move.b	(LBL_ffff9896).w, d5	; 0x1cec
@skip:
	move.b	(641, a6), d0	; 0x1cf0
	ror.b	#1, d0	; 0x1cf4
	or.b	d5, d0	; 0x1cf6
	jsr	(appendToDamageList).w	; 0x1cf8
@match_over:
	tst.b	(areWeOnBonusStage).w	; 0x1cfc
	bne.b	fight_over	; 0x1d00
	sub.w	d4, (60, a3)	; 0x1d02
	sub.w	d4, (70, a3)	; 0x1d06
	bpl.b	fight_over	; 0x1d0a
	bsr.w	diePlayer	; 0x1d0c
	tst.b	(LBL_ffff9938).w	; 0x1d10
	beq.b	fight_over	; 0x1d14
	tst.b	(LBL_ffffbb58).w	; 0x1d16
	bpl.b	fight_over	; 0x1d1a
	st	(LBL_ffff9942).w	; 0x1d1c

fight_over:
	move.b	#$14, (3, a3)	; 0x1d20
	moveq	#0, d0	; 0x1d26
	move.b	d0, (4, a3)	; 0x1d28
	move.b	d0, (5, a3)	; 0x1d2c
	move.b	(115, a3), d0	; 0x1d30
	or.b	(416, a3), d0	; 0x1d34
	clr.b	(115, a3)	; 0x1d38
	clr.b	(416, a3)	; 0x1d3c
	tst.b	d0	; 0x1d40
	bne.b	escapeHoldOrProjection	; 0x1d42
	tst.b	(60, a3)	; 0x1d44
	bmi.b	escapeHoldOrProjection	; 0x1d48
	bsr.b	updateProjected_6a_6c	; 0x1d4a

escapeHoldOrProjection:
	move.b	#$1c, (projectionCounter).w	; 0x1d4c
	moveq	#0, d0	; 0x1d52
	move.b	d0, (projectionFlags).w	; 0x1d54
	move.b	d0, (117, a6)	; 0x1d58
	move.b	d0, (117, a3)	; 0x1d5c
	move.b	d0, (191, a3)	; 0x1d60
	rts		; 0x1d64

FUN_00001d66:
	move.w	(662, a6), a3	; 0x1d66
	move.b	d0, (122, a3)	; 0x1d6a
	move.b	d1, (72, a3)	; 0x1d6e
	bsr.w	createImpactObject	; 0x1d72
	tst.b	(LBL_ffff9939).w	; 0x1d76
	bne.b	fight_over	; 0x1d7a
	tst.b	(isFightOver).w	; 0x1d7c
	bne.b	fight_over	; 0x1d80
	bsr.w	computeMultiStepProjectionDamage	; 0x1d82
	bra.w	loop100	; 0x1d86

updateProjected_6a_6c:
	tst.b	(112, a3)	; 0x1d8a
	bne.b	@f70_set	; 0x1d8e
	move.w	#$000a, (LBL_ffffbb66).w	; 0x1d90
	addi.w	#$0064, (108, a3)	; 0x1d96
	jsr	FUN_000247fc	; 0x1d9c
	move.w	(LBL_ffffbb66).w, d0	; 0x1da2
	add.w	d0, (106, a3)	; 0x1da6
	move.w	(106, a3), d1	; 0x1daa
	cmpi.w	#$001f, d1	; 0x1dae
	bcs.b	@end	; 0x1db2
@f70_set:
	addq.b	#1, (421, a3)	; 0x1db4
	move.b	#1, (112, a3)	; 0x1db8
	moveq	#0, d0	; 0x1dbe
	move.w	d0, (106, a3)	; 0x1dc0
	move.w	d0, (108, a3)	; 0x1dc4
@end:
	rts		; 0x1dc8

diePlayer:
	tst.b	(areWeOnBonusStage).w	; 0x1dca
	bne.b	@end	; 0x1dce
	jsr	(getObjectSlot).w	; 0x1dd0
	bne.b	@end	; 0x1dd4
	moveq	#1, d0	; 0x1dd6
	move.b	d0, (a0)	; 0x1dd8
	move.b	d0, (15, a0)	; 0x1dda
	move.b	d0, (16, a0)	; 0x1dde
	move.b	d0, (17, a0)	; 0x1de2
	move.b	d0, (LBL_ffff9891).w	; 0x1de6
@end:
	rts		; 0x1dea

loadFighterRegularPalette:
	lea	(paletteBuffers).w, a1	; 0x1dec
	tst.b	(641, a6)	; 0x1df0
	beq.b	@fighter_1	; 0x1df4
	lea	(paletteBuffers).w, a1	; 0x1df6
@fighter_1:
	moveq	#0, d0	; 0x1dfa
	move.b	(651, a6), d0	; 0x1dfc
	lsl.b	#2, d0	; 0x1e00
	lea	charPalettes, a0	; 0x1e02
	move.l	(0, a0, d0), a0	; 0x1e08
	move.b	(653, a6), d0	; 0x1e0c
	adda.w	d0, a0	; 0x1e10
	move.w	#7, d7	; 0x1e12
@next:
	move.l	(a0)+, (a1)+	; 0x1e16
	dbf	d7, @next	; 0x1e18
	st	(flagProcessPalettes).w	; 0x1e1c
	rts		; 0x1e20

loadFlamedFighterPalette:
	lea	(paletteBuffers).w, a1	; 0x1e22
	tst.b	(641, a6)	; 0x1e26
	beq.b	@fighter_1	; 0x1e2a
	lea	(paletteBuffers).w, a1	; 0x1e2c
@fighter_1:
	moveq	#0, d0	; 0x1e30
	cmpi.b	#$22, (96, a6)	; 0x1e32
	bne.b	@normal_flames	; 0x1e38
	moveq	#$0020, d0	; 0x1e3a
@normal_flames:
	lea	redFlamedFighterPalette, a0	; 0x1e3c
	adda.w	d0, a0	; 0x1e42
	move.w	#7, d7	; 0x1e44
@next:
	move.l	(a0)+, (a1)+	; 0x1e48
	dbf	d7, @next	; 0x1e4a
	st	(flagProcessPalettes).w	; 0x1e4e
	rts		; 0x1e52

loadElectrifiedFighterPalette:
	cmpi.b	#2, (651, a6)	; 0x1e54
	beq.b	@blanka	; 0x1e5a
	bclr	#5, (26, a6)	; 0x1e5c
	bne.b	loadFighterRegularPalette	; 0x1e62
	bclr	#6, (26, a6)	; 0x1e64
	beq.b	@blanka	; 0x1e6a
	lea	(paletteBuffers).w, a1	; 0x1e6c
	tst.b	(641, a6)	; 0x1e70
	beq.b	@fighter_1	; 0x1e74
	lea	(paletteBuffers).w, a1	; 0x1e76
@fighter_1:
	moveq	#0, d0	; 0x1e7a
	move.b	(651, a6), d0	; 0x1e7c
	lsl.b	#2, d0	; 0x1e80
	lea	electrifiedPalettes, a0	; 0x1e82
	move.l	(0, a0, d0), a0	; 0x1e88
	move.w	#7, d7	; 0x1e8c
@next:
	move.l	(a0)+, (a1)+	; 0x1e90
	dbf	d7, @next	; 0x1e92
	st	(flagProcessPalettes).w	; 0x1e96
@blanka:
	rts		; 0x1e9a