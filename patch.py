# -*- coding: utf-8 -*-

from buffer import Buffer

source = Buffer.load("original.bin")


if True:
	# remove checksum check
	source.write("4e71" * 29, 0x3bdc)

if False:
	# enable debug mode
	source.write_l(0x79b6, pos=0xa1be)
	
	if True:
		source.write_l(0x94a2, pos=0x7afa)
	if True:
		source.write_w(0x6000, pos=0x7b86)

if True:
	# invulnerability (doesn't work)
	source.write_w(0x4e71, pos=0x3742)

if False:
	# vitesse bateau chez Ken
	source.set_pos(0x2d04)
	for x in [8, 24, 40, 64, 64, 40, 24, 8]:
		source.write_w(x)

source.save("out.bin")