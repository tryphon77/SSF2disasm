# -*- coding: utf-8 -*-

import png
import numpy as np
from buffer import Buffer
from gfx import Surface4bpp, Vdp

source = Buffer.load("ssf2.bin")

vdp = Vdp()

def save_png8(data, palette, path, offset=0):
	def cvt_(col):
		b, g, r = (col >> 8), ((col >> 4) & 15), col & 15
		return (r*16, g*16, b*16)
	
	height, width = data.shape
	w = png.Writer(width, height, palette=[cvt_(col) for col in palette], bitdepth=8)
	with open(path, 'wb') as f:
		w.write(f, offset + data)

def save_patterns(name, sz, pos, vpos, pal_id=0):
#	vdp.clear()
	source.set_pos(pos)
	vdp.load_tiles(source, vpos // 0x20, sz//32)
	if name == "":
		name = "patterns_0x%x" % pos
	vdp.save_tiles("res/gfx/%s.png" % name, vpos//32, (vpos + sz)//32, pal_id)
	
def save_tilemap(name, pos, width, height):
	if name == "":
		name="tilemap_0x%x" % pos
	print(name)

	for i in range(16):
		vdp.patterns[i].fill(i)

	offset_ = 0
	res = np.zeros((height, width), dtype=np.uint8)
	source.set_pos(pos)
	for y in range(height//8):
		offset = offset_
		r = []
		for x in range(width//8):
			tile_id = source.read_w()
			offset_ += 2
			r.append("%04X" % tile_id)
			vdp.put_at(res, x*8, y*8, tile_id)
		print("%04X: %s" % (offset, " ".join(r)))
	save_png8(res, vdp.palettes, "res/maps/%s.png" % name)

def save_palette(name, sz, pal_id, pos):
	source.set_pos(pos)
	vdp.load_palette(source, pal_id*16, sz)


if False:
	source.set_pos(0x3a3d40)
	#vdp.load_palette(source, 0, 64)
	
	source.set_pos(0x3a3dc0)
	vdp.load_palette(source, 0, 64)
	
	save_patterns("openingRyu01", 0x5880, 0x3e3880, 0x7780, pal_id=3)
	save_tilemap("openingRyu01", 0x3e9100, 512, 0x2000//128*8) # tilemap
	
	save_patterns("openingRyu02a", 0x1a00, 0x3a4160, 0x1000, pal_id=3)
	save_patterns("openingRyu02b", 0x760, 0x3cd400, 0x2a00, pal_id=3)
	save_patterns("openingRyu02c", 0x720, 0x3cdb60, 0x3200, pal_id=3)
	save_patterns("openingRyu02d", 0x780, 0x3ce280, 0x3a00, pal_id=3)
	save_patterns("openingRyu02e", 0x1de0, 0x3cea00, 0x4200, pal_id=3)
	save_patterns("openingRyu02f", 0xb20, 0x3d07e0, 0x6000, pal_id=3)
	save_patterns("openingRyu02g", 0xc60, 0x3cc7a0, 0x6b20, pal_id=3)
	
	save_tilemap("openingRyu02", 0x3e9100, 512, 0x2000//128*8) # tilemap
	
	# a70a
	save_patterns("openingRyu03a", 0x400*2, 0x1d2db0*2, 0x2a00, pal_id=3)
	save_patterns("openingRyu03b", 0x410*2, 0x1d31b0*2, 0x3200, pal_id=3)
	save_patterns("openingRyu03c", 0x500*2, 0x1d35c0*2, 0x4000, pal_id=3)
	
	save_tilemap("openingRyu03a", 0x1d77e0*2, 512, 0x400//128*16) # tilemap
	save_tilemap("openingRyu03b", 0x1d7be0*2, 512, 0x400//128*16)
	
	# a73a 
	save_patterns("openingRyu04a", 0x500*2, 0x1d3ac0*2, 0x4a00, pal_id=3)
	save_patterns("openingRyu04b", 0x500*2, 0x1d3fc0*2, 0x5400, pal_id=3)
	save_patterns("openingRyu04c", 0x3d0*2, 0x1d44c0*2, 0x5e00, pal_id=3)
	
	save_tilemap("openingRyu04c", 0x1d7fe0*2, 512, 0x400//128*16) # tilemap
	save_tilemap("openingRyu04d", 0x1d83e0*2, 512, 0x400//128*16)
		
	# a75a
	save_patterns("openingRyu05a", 0x3c0*2, 0x1d5c90*2, 0x3800, pal_id=3) 
	save_patterns("openingRyu05b", 0x500*2, 0x1d4890*2, 0x1000, pal_id=3) 
	save_patterns("openingRyu05c", 0x500*2, 0x1d4d90*2, 0x1a00, pal_id=3) 
	save_patterns("openingRyu05d", 0x500*2, 0x1d5290*2, 0x2400, pal_id=3) 
	save_patterns("openingRyu05e", 0x500*2, 0x1d5790*2, 0x2e00, pal_id=3)
	
	save_tilemap("openingRyu05a", 0x1d77e0*2, 512, 0x400//128*16) # tilemap
	save_tilemap("openingRyu05b", 0x1d7be0*2, 512, 0x400//128*16)
		
	# a782
	source.set_pos(0x3a4140)
	vdp.load_palette(source, 0, 16)
	
	save_patterns("openingRyu06a", 0x3c0*2, 0x1d7450*2, 0x6800, pal_id=3)
	save_patterns("openingRyu06b", 0x500*2, 0x1d6050*2, 0x4000, pal_id=3)
	save_patterns("openingRyu06c", 0x500*2, 0x1d6550*2, 0x4a00, pal_id=3)
	save_patterns("openingRyu06d", 0x500*2, 0x1d6a50*2, 0x5400, pal_id=3)
	save_patterns("openingRyu06e", 0x500*2, 0x1d6f50*2, 0x5e00, pal_id=3)
	
	save_tilemap("openingRyu06c", 0x1d7fe0*2, 512, 0x400//128*16) # tilemap
	save_tilemap("openingRyu06d", 0x1d83e0*2, 512, 0x400//128*16)

# abde
save_palette("titleScreenPalette00", 16, 1, 0x3a3880)
save_palette("titleScreenPalette00", 16, 2, 0x3a3ae0)

save_patterns("titleScreen01", 0x0f80, 0x3daf00, 0x2000)
save_patterns("titleScreen02", 0x07e0, 0x3e1680, 0x4000) 
save_patterns("titleScreen03", 0x1820, 0x3e1e60, 0x47e0) 
save_patterns("titleScreen04", 0x2000, 0x3c8ba0, 0x8000) 
save_patterns("titleScreen05", 0x0d00, 0x3caba0, 0xa000) 
save_patterns("titleScreen06", 0x0f00, 0x3cb8a0, 0xae00)
save_tilemap("titleScreen01", 0x3dbe80, 512, 0x1000//128*8) 

# ac18
save_patterns("titleScreen07", 0x1080, 0x3dde80, 0x2f80)
save_tilemap("titleScreen02", 0x3def00, 512, 0x1000//128*8)

# ac3c
save_patterns("ac3c_01", 0x0200, 0x3e3680, 0x1c00) 
save_patterns("ac3c_02", 0x0600, 0x38622c, 0x1000)

# ac2a
save_patterns("ac2a_01", 0x0780, 0x3dff00, 0x2f80) 
save_tilemap("titleScreen03", 0x3e0680, 512, 0x1000//128*8)



print(hex(source.pos))

vdp.save_tiles("res/maps/ptrns.png", pal_id=2)
vdp.print_palettes()


if True:
	save_patterns("6118_01_0", 0x2ae0, 0x477d80, 0x2000)
	save_patterns("6118_01_1", 0x1000, 0x49c040, 0xe000)
	save_patterns("6118_01_2", 0x1000, 0x49c040, 0xf000)
			  			  
	save_patterns("6118_02_0", 0x1000, 0x49d040, 0xe000)
			  
	save_patterns("6118_03_0", 0x1000, 0x49e040, 0xe000)
	save_patterns("6118_03_1", 0x1000, 0x49f040, 0xf000)
	save_patterns("6118_03_2", 0x0fe0, 0x4be440, 0x8000)
			  