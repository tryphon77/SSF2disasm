# -*- coding: utf-8 -*-

from buffer import Buffer
from gfx import Surface4bpp, VdpPatterns
from text import *

import pygame, sys

source = Buffer.load("ssf2.bin")

patterns = VdpPatterns()

def _get_frame(char_id, frame_id):
	frame_id &= 0x7F
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
		print("no words")
		return
	patterns.save_as_tga("debug/patterns-%X.tga" % patterns_data, palette)
	
	source.set_pos(gfx_data)
	count = source.read_w()
	
	print("%0X" % source.pos)
	print("counter: %d" % count)
	surf = Surface4bpp((256, 256))
	
	k = 0
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

		patterns.put_sprite_at(surf, (x, y), (width, height), dp, hflip, vflip)
		k += width*height
	
#	pyg_surf = surf.to_pygame(palette)
	return surf

class Frames:
	def __init__(self):
		self.registered = {}
	
	def get(self, char_id, frame_id, palette):
		if (char_id, frame_id) not in self.registered.keys():
			self.registered[(char_id, frame_id)] = _get_frame(char_id, frame_id)
		return self.registered[(char_id, frame_id)].to_pygame(palette)
	
class Animation:
	anim_id = 0

	def __init__(self, char_id):
		self.ptr_1C_anims_data = source.read_l(0x32948 + 4*char_id)
		self.ptr_2C = source.read_l(0x329c8 + 4*char_id)
		self.ptr_30_collision = source.read_l(0x32988 + 4*char_id)
		self.anim_id = -1
		self.anim_data = None
		self.last_anim = 0
		self.box_id = -1
		self.frame_id = -1
		self.boxes = []
		
	def init(self, id_):
		self.anim_id = id_
		
		print("%x" % self.ptr_1C_anims_data)
		self.anim_data = self.ptr_1C_anims_data + source.read_w(self.ptr_1C_anims_data + self.anim_id*2)
		self.last_anim = 0
		self.box_id = -1
		self.frame_id = -1
		
		self.next_frame()
		
	def next_frame(self):
		source.set_pos(self.anim_data)
		if self.last_anim < 0:
			self.anim_data += source.read_w(signed = True)
			self.last_anim = False
			self.next_frame()
		else:
			self.tick = source.read_b()
			self.last_anim = source.read_b(signed = True)
			frame_id = source.read_b()
			self.frame_id = frame_id & 0x7F
			self.box_id = source.read_b()
			self.anim_data = source.pos
			
			source.set_pos(self.ptr_2C + 16*self.box_id)
			print('collision_data at %X' % source.pos)
			self.collision_data = [source.read_b() for _ in range(16)]
			print(' '.join(["0x%02X" % x for x in self.collision_data]))

#			text_at((36, 8), ' '.join(["%02X" % x for x in self.collision_data[:8]]))
#			text_at((36, 10), ' '.join(["%02X" % x for x in self.collision_data[8:]]))
			
			print(zip(['HEAD', 'BODY', 'FOOT', 'WEAK', 'ATCK', 'BDY1', 'KAGE', 'PRIO', 'CACH', 'BLCK', 'SITG', 'CDIR', 'TRYY', 'WTYP', 'YOK2', 'YOKE'], self.collision_data))
			text_at((40, 8), '\n'.join(['%s: %02X' % (t, v) for (t, v) in zip(['HEAD', 'BODY', 'FOOT', 'WEAK', 'ATCK', 'BDY1', 'KAGE', 'PRIO', 'CACH', 'BLCK', 'SITG', 'CDIR', 'TRYY', 'WTYP', 'YOK2', 'YOKE'], self.collision_data)]))
			
			self.boxes = []
			val = 0
			for k, o, l in [
					(0, 0, 4), 
					(1, 2, 4), 
					(2, 4, 4), 
					(4, 6, 12),
					(5, 8, 4)
				]:
				val = self.collision_data[k]
				if val:
					print('%x' % self.ptr_30_collision)
#					box_data = self.ptr_30_collision + source.read_w(self.ptr_30_collision + 0) + 12*val
					box_data = self.ptr_30_collision + source.read_w(self.ptr_30_collision + o) + l*val
					source.set_pos(box_data)
					print('box_data at %X' % source.pos)
					if k == 4:
						text_at((40, 25), "%x" % source.pos)
					
					x, y, w, h = source.read_b(signed = True), source.read_b(signed = True), source.read_b(signed = True), source.read_b(signed = True)
					self.boxes.append((x - w, y + h, 2*w, 2*h))
#					print("dx=%d, dy=%d, w=%d, h=%d" % self.boxes[0])
#					close()
				else:
					self.boxes.append(None)
			
			print("ticks=%d, frame_id=%d, last_anim=%d, box_id=%d" % (self.tick, self.frame_id, self.last_anim, self.box_id))
			print(' '.join(['%02X' % x for x in self.collision_data]))
	
	def update(self):
		if self.tick == 0:
			self.next_frame()
		self.tick -= 1
		
	


def close():
	pygame.display.quit()
	pygame.quit()
	sys.exit()

snap_id = 1
def take_snapshot():
	global snap_id
	pygame.image.save(screen, "snap%02d.png" % snap_id)
	snap_id += 1

rect_cols = [
	pygame.Color("red"),
	pygame.Color("green"),
	pygame.Color("blue"),
	pygame.Color("cyan"),
	pygame.Color("magenta"),
	pygame.Color("yellow"),
	pygame.Color("white"),
	pygame.Color("black"),
]

def update_anim_show():
	global frame_buffer, joy, anim_id, palette
	
	if joy & JOY_LEFT and anim_id > 0:
		anim_id -= 1
		animation.init(anim_id)
	elif joy & JOY_RIGHT:
		anim_id += 1
		animation.init(anim_id)
	elif joy & JOY_UP and anim_id > 10:
		anim_id -= 10
		animation.init(anim_id)
	elif joy & JOY_DOWN:
		anim_id += 10
		animation.init(anim_id)

	animation.update()				
#	print("anim_id: 0x%02X" % anim_id)
	text_at((40, 4), "Animation: %02X" % anim_id)
	text_at((40, 6), "Frame: %02X" % animation.frame_id)
	frame_buffer.blit(frames.get(char_id, animation.frame_id, palette), (0, 0))
	
	for i, box in enumerate(animation.boxes):
		if box:
			x, y, w, h = box
			pygame.draw.rect(frame_buffer, rect_cols[i], (x + 128, 128 - y, w, h), width=1)

def update_frame_show():
	global frame_buffer, joy, frame_id
	
	needs_refresh = False
	if joy & JOY_LEFT and frame_id > 0:
		frame_id -= 1
		needs_refresh = True
	elif joy & JOY_RIGHT:
		frame_id += 1
		needs_refresh = True

	if needs_refresh:
		print(frame_id)
		text_at((40, 6), "Frame: %02X" % frame_id)
		frame_buffer.blit(frames.get(char_id, frame_id, palette), (0, 0))
	

if True:
	# get addresses of patterns
	char_id = 1
	nb_tilesets = [196, 110, 100, 146, 196, 137, 135, 134, 128, 99, 117, 136, 166, 146, 182, 191][char_id]
	ptr_tilesets_commands = source.read_l(0x32908 + 4*char_id)
	
	min_pos = 0xFFFFFFFF
	max_pos = 0
	for k in range(nb_tilesets):
		cmd_pos = ptr_tilesets_commands + source.read_w(ptr_tilesets_commands + 2*k)
		source.set_pos(cmd_pos)
		while True:
			sz = source.read_w()
			if sz == 0:
				break
	
			half_pos = source.read_l()
			pos = 2*half_pos
#			print("%X" % pos)
			end_pos = pos + sz*2
			
			dest = source.read_w()
			
			if pos >= 0x200000:
				if min_pos > pos:
					min_pos = pos
					print("min: %X, max: %X" % (min_pos, max_pos))
				
				if max_pos < end_pos:
					max_pos = end_pos
					print("min: %X, max: %X" % (min_pos, max_pos))
		
		

if False:
	frame = _get_frame(0, 120)
	# pygame.image.save(frame, "frame01.png")
	
	
if True:
	width, height = size = (512, 512)
	screen = pygame.display.set_mode(size)

	frame_buffer = pygame.Surface((width, height)).convert()
	clock = pygame.time.Clock()
	fps = 3

	frames = Frames()
	
	WAITING, FORWARD, BACKWARD, ROTATING = 0, 1, 2, 3
	
	state = WAITING
	snap_id = 0
	needs_refresh = True

	char_id = 0
	animation = Animation(char_id)
	anim_id = 0x38
	animation.init(anim_id)
	animation.frame_id = 0

	palette_data = source.read_l(0x32a08 + 4*char_id)
	source.set_pos(palette_data)
	print("palette at %x" % palette_data)
	palette = [source.read_w() for _ in range(16)]
	print(['%03X' % x for x in palette])
	
	JOY_UP, JOY_DOWN, JOY_LEFT, JOY_RIGHT, JOY_A, JOY_B, JOY_C = 1, 2, 4, 8, 16, 32, 64
	
	text_at((40, 2), "SUPER STREET FIGHTER 2")
	
	while True:
		screen.blit(frame_buffer, (0, 0))
		screen.blit(text_layer, (0, 0))
		pygame.display.flip()

#		take_snapshot()

		clock.tick(fps)
		
		joy = 0
		snapshot_mode = False
		for event in pygame.event.get():
			if event.type == pygame.QUIT: 
				sys.exit()
			elif event.type in [pygame.KEYDOWN]:
				if event.key == pygame.K_ESCAPE: 
					close()
				elif event.key == pygame.K_p:
					snapshot_mode = not snapshot_mode
				elif event.key == pygame.K_UP:
					joy |= JOY_UP
				elif event.key == pygame.K_DOWN:
					joy |= JOY_DOWN
				elif event.key == pygame.K_LEFT:
					joy |= JOY_LEFT
				elif event.key == pygame.K_RIGHT:
					joy |= JOY_RIGHT

		if snapshot_mode:
			take_snapshot()

		update_anim_show()
		
