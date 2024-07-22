# -*- coding: utf-8 -*-

from buffer import Buffer
from gfx import Surface4bpp, VdpPatterns
from text import *

import pygame, sys

source = Buffer.load("ssf2.bin")


patterns = VdpPatterns()

def get_frame(char_id, frame_id, no_bg = True):
	palette_data = source.read_l(0x32a08 + 4*char_id)
	source.set_pos(palette_data)
	print("palette at %x" % palette_data)
	palette = [source.read_w() for _ in range(16)]
	print(['%03X' % x for x in palette])

	ptr_24_gfx_data = source.read_l(0x328c8 + 4*char_id)
	
	ptr_5A_dma_data = source.read_l(0x32908 + 4*char_id)
						
	gfx_data = ptr_24_gfx_data + source.read_w(ptr_24_gfx_data + 2*frame_id)
	dma_data = ptr_5A_dma_data + source.read_w(ptr_5A_dma_data + 2*frame_id)
	print("ptr_5A=%X, dma_data=%X" % (ptr_5A_dma_data, dma_data))
	source.set_pos(dma_data)
	total_words = 0
	arg3 = 0
	while True:
		print("[%X] dma at %X" % (source.pos, dma_data))
		nb_of_words = source.read_w()
		if nb_of_words == 0:
			break
		total_words += nb_of_words
		patterns_data = source.read_l()
		
		arg1 = source.read_w()
#		arg2 = source.read_w()
#		patterns_data += arg1

		print("ignoring %04X" % arg1)
		
		print("nb_of_words: %X, source: %X" % (nb_of_words, patterns_data))
		source.push()
		source.set_pos(patterns_data*2)
		patterns.load(source, arg1//0x20, nb_of_words // 0x10)
#		arg3 += nb_of_words//0x10
		source.pop()

	if total_words == 0:
		return
#	patterns.save_as_tga("debug/patterns-%X.tga" % patterns_data, palette)
	
	source.set_pos(gfx_data)
	count = source.read_w()
	
	print("%0X" % source.pos)
	print("counter: %d" % count)
	surf = Surface4bpp((256, 256))
	
	k = 0
	x0 = x1 = y0 = y1 = 128
	for i in range(count + 1):
		dx = source.read_w(signed = True)
		dy = source.read_w(signed = True)
		dp = source.read_b()
		attribs = source.read_b()
		height = (attribs & 3) + 1
		width = ((attribs >> 2) & 3) + 1
		hflip = (attribs & 0x10) != 0
		vflip = (attribs & 0x20) != 0
		
		print("(%d, %d, %d, %d (dp=%02X, attribs=%02X)" % (dx, dy, width, height, dp, attribs))
		
		x, y = 128 + dx, 128 + dy
		x0 = min(x0, x)
		x1 = max(x1, x + width*8)
		y0 = min(y0, y)
		y1 = max(y1, y + height*8)

		patterns.put_sprite_at(surf, (x, y), (width, height), dp, hflip, vflip)
		k += width*height
	
	pygsurf = surf.to_pygame(palette, crop = no_bg)
#	pygame.draw.rect(pygsurf, pygame.Color("white"), (x0, y0, x1 - x0, y1 - y0), 1)
	
#	pyg_surf = surf.to_pygame(palette)
	return {"hotspot": (128 - x0, 128 - y0), "surface": pygsurf.subsurface((x0, y0, x1 - x0, y1 - y0))}


def get_anim(char_id, anim_id):
	ptr_1C_anims_data = source.read_l(0x32948 + 4*char_id)
	ptr_2C = source.read_l(0x329c8 + 4*char_id)
	ptr_30_collision = source.read_l(0x32988 + 4*char_id)
	
	print("%x" % ptr_1C_anims_data)
	anim_data = ptr_1C_anims_data + source.read_w(ptr_1C_anims_data + anim_id*2)


	res = []
	
	while True:
		source.set_pos(anim_data)
		print('reading at %X' % source.pos)
		tick = source.read_b()
		last_anim = source.read_b()
		frame_id = source.read_b()
		box_id = source.read_b()
		anim_data = source.pos
		
		source.set_pos(ptr_2C + 16*box_id)
		print('collision_data at %X' % source.pos)
		collision_data = [source.read_b() for _ in range(16)]
		print(' '.join(["0x%02X" % x for x in collision_data]))
		
		print(zip(['HEAD', 'BODY', 'FOOT', 'WEAK', 'ATCK', 'BDY1', 'KAGE', 'PRIO', 'CACH', 'BLCK', 'SITG', 'CDIR', 'TRYY', 'WTYP', 'YOK2', 'YOKE'], collision_data))
		
		sitg = collision_data[10] != 0
		blck = collision_data[9]
		cach = collision_data[8]
		
		boxes = {}
		val = 0
		for box_name, k, o, l in [
				("head_box", 0, 0, 4), 
				("torso_box", 1, 2, 4), 
				("feet_box", 2, 4, 4),
				("attack_box", 4, 6, 12), 
				("collision_box", 5, 8, 4)
			]:
			val = collision_data[k]
			if val:
				print('%x' % ptr_30_collision)
				box_data = ptr_30_collision + source.read_w(ptr_30_collision + o) + l*val
				source.set_pos(box_data)
				print('box_data at %X' % source.pos)
				
#				x, y, w, h = source.read_b(signed = True), source.read_b(signed = True), source.read_b(signed = True), source.read_b(signed = True)
	#					close()
				boxes[box_name] = tuple([source.read_b(signed = (x < 4)) for x in range(l)])
			else:
				boxes[box_name] = None #tuple([0] *l)
			
			print("ticks=%d, frame_id=%d, last_anim=%d, box_id=%d" % (tick, frame_id, last_anim, box_id))
			print(' '.join(['%02X' % x for x in collision_data]))
		
		anim_step = {'frame_id': frame_id, 'ticks': tick, 'last_anim': last_anim, 'sitg': sitg, 'blck': blck, 'cach': cach}
		anim_step.update(boxes)
		res.append(anim_step)
		
		if last_anim >= 128:
			source.set_pos(anim_data)
			anim_step = {'frame_id': 0, 'ticks': 0, 'last_anim': 0, 'back': source.read_w(signed=True)//4}
			res.append(anim_step)
			break
#		f = input()
	
	return res


max_frame_id = 0
res1 = []
res2 = []
for name, k in [
	('forward', 0),
	('backward', 1),
	('forward_stop', 2),
	('backward_stop', 3),
	('stand_to_crouch', 4),
	('knocked_to_crouch', 5),
	('attack_to_crouch', 6),
	('crouch_to_stand_2', 7),
	('crouch_to_stand_1', 8),
	('jump_fwd', 10), ('jump_bwd', 11), ('jump_vert1', 12), ('jump_vert2', 13),
	('reception', 14),
	('flip', 15),
	('crouch_flip', 17),
	('high_guard_1', 22), ('high_guard_4', 23), ('high_guard_5', 24), ('high_guard_3', 25), 
	('low_guard_1', 26),('low_guard_3', 28), ('low_guard_2', 29), 
	('hit_stand_1', 30), ('hit_stand_6', 31), ('hit_stand_5', 32), ('hit_stand_2', 33), ('hit_stand_3', 34), ('hit_stand_4', 35), ('hit_or_guard_stand_6', 36), ('guard_stand_from_jump', 38),
	('hit_crouch_1', 39), ('hit_crouch_2', 40),('hit_crouch_3', 41), ('hit_stand_7', 42), ('hit_crouch_4', 43),
	('hit_knock_out_3', 44), ('hit_knock_out_1', 45), ('hit_knock_out_2', 46),
	('recover_1', 51),
	('hit_in_jump_1', 54),
	('close_wp', 80), ('wp', 81), ('close_mp', 82), ('mp', 83), ('close_fp', 84), ('fp', 85), 
	('close_wk', 86), ('wk', 87), ('close_mk', 88), ('mk', 89), ('close_fk', 90), ('fk', 91), 	
	('close_crouch_wp', 92), ('crouch_wp', 93), ('close_crouch_mp', 94), ('crouch_mp', 95), ('crouch_close_fp', 96), ('crouch_fp', 97), 
	('close_crouch_wk', 98), ('crouch_wk', 99), ('close_crouch_mk', 100), ('crouch_mk', 101), ('crouch_close_fk', 102), ('crouch_fk', 103), 	
	('jump_neutral_wp', 104), ('jump_wp', 105), ("jump_neutral_mp", 106), ("jump_mp", 107), ("jump_neutral_fp", 108), ("jump_fp", 109),
	('jump_neutral_wk', 110), ('jump_wk', 111), ("jump_neutral_mk", 112), ("jump_mk", 113), ("jump_neutral_fk", 114), ("jump_fk", 115),
	('projection_1', 131),
	]:
	
	anim = get_anim(0, k)
	while len(res1) < k:
		res1.append("\tNone,")
	res1.append("\t%s_anim_data,\t# 0x%02X" % (name, k))
	res2.append("%s_anim_data = [\n%s\n]\n" % (name, ',\n'.join(["\t%d" % a['back'] if 'back' in a else "\t(%d, %d, %d, %s, %s, %s, %s, %s, %s, %s, %s)" % (a['frame_id'], a['ticks'], a['last_anim'], a['collision_box'], a['head_box'], a['torso_box'], a['feet_box'], a['attack_box'], a['blck'], a['sitg'], a['cach']) for a in anim])))
	
	for a in anim:
		max_frame_id = max(max_frame_id, a['frame_id'])
	
frame_sheet = pygame.Surface((1024, 1024))
frame_sheet.fill(pygame.Color("magenta"))
x = y = 0
height = 0

res = []
res3 = []
for f_id in range(max_frame_id + 1):
	frame = get_frame(0, f_id)
	if frame:
		w, h = frame["surface"].get_size()
		res3.append("\t%s, \t # frame %d" % (frame["hotspot"], f_id))
		if x + w >= 1024:
			x = 0
			y += height
			height = 0
		res.append("\t(%d, %d, %d, %d),\t# frame %d" % (x, y, w, h,f_id))
		frame_sheet.blit(frame["surface"], (x, y))
		x += w + 8
		height = max(height, h)
	else:
		res3.append("\t%s, \t # frame %d" % ((0, 0), f_id))
		res.append("\t(%d, %d, %d, %d),\t# frame %d" % (0, 0, 0, 0,f_id))

pygame.image.save(frame_sheet, "frame_sheet.png")

with open("ryu_data.py", "w") as f:
	f.write("# -*- coding: utf-8 -*-\n\n\n")
	f.write("hotspots = [\n%s\n]\n\n" % "\n".join(res3))
	f.write("frames_rects = [\n%s\n]\n\n" % '\n'.join(res))
	f.write('\n'.join(res2) + '\n')
	f.write("anims = [\n%s\n]\n\n" % '\n'.join(res1))
	

