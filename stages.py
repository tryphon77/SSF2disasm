# -*- coding: utf-8 -*-

from buffer import Buffer
from gfx import Surface4bpp, VdpPatterns, Vdp
from text import *

import pygame, sys

source = Buffer.load("ssf2.bin")
stage_names = ["ryu", "e_honda", "blanka", "guile", 
			   "ken", "chun_li", "zangief", "dhalsim",
			   "dictator", "sagat", "boxer", "claw",
			   "cammy", "t_hawk", "feilong", "deejay", 
			   "bonus_1", "bonus_2", "bonus_3"]


def put_object(name, source, vdp, source_tiles=0, tile_flags=0, frame_def=0, long_frames=False):
	vdp.clear_sprites()
	
	source.set_pos(frame_def)
	
	n_sprites = source.read_w() + 1
	for k in range(n_sprites):
		dx = source.read_w(signed=True)
		dy = source.read_w(signed=True)

		if long_frames:
			tile = source.read_w()
			flags = source.read_w()

			width = (((flags >> 2) & 3) + 1)
			height = ((flags & 3) + 1)
		else:
			delta_tile = source.read_b()
			tile = source_tiles + delta_tile
			flags = source.read_b()
			
			if flags & 0x80:
				tile |= tile_flags
		
		vflip = (flags & 0x40) != 0
		hflip = (flags & 0x20) != 0
		
		tile |= ((flags << 7)& 0x1800)
		
		width = (((flags >> 2) & 3) + 1)
		height = ((flags & 3) + 1)
		print("dx=%d, dy=%d, tile=%04X, vflip=%d, hflip=%d, width=%d, height=%d" % (dx, dy, tile, vflip, hflip, width, height))
		
		vdp.put_sprite_at((128 + dx, 128 + dy), (width, height), tile)

	vdp.save_sprites("debug/object_%s_%X.png" % (name, frame_def))

def get_frame_defs(source, anims_id=[], frames_id=[]):
	frame_defs = []
	anim1_table_base = source.read_l(0x32bc8)	
	for anim_id in anims_id:
		print("anim %02d" % anim_id)
		anim1_table_pos = anim1_table_base + source.read_w(anim1_table_base + 2*anim_id)
		anim2_table_pos = 0x2ca344 + source.read_w(0x2ca344 + 2*anim_id)
		for frame_id in frames_id:
			print("frame %02d" % frame_id)

			spritedef_pos = anim2_table_pos + source.read_w(anim2_table_pos + 2*frame_id)
			print("1C: %X, 20: %X, 24: %X" % (anim1_table_pos, spritedef_pos, anim2_table_pos))
			frame_defs.append(spritedef_pos)
			
	return frame_defs	

def get_object_14(source, vdp, stage_id):
	max_param = -1
	
	nb_objs = source.read_b(0x2abe8 + stage_id)
	
	subobjects_anims = 0x2ac48 + source.read_w(0x2ac48 + 2*stage_id)
	subobjects_anims_data = 0x2ac08 + source.read_w(0x2ac08 + 2*stage_id)

	for k in range(nb_objs):
		nb_anims = source.read_b(subobjects_anims + k)
		print("nb_anims of anim #%d: %d" % (k, nb_anims))
	
		offset = source.read_b(subobjects_anims_data + k)
		for anim_id in range(nb_anims):
			timing = source.read_b(subobjects_anims_data + offset + anim_id)
			param = source.read_b(subobjects_anims_data + offset + anim_id + nb_anims)
			print("anim_id: %d, offset = %X, param=%d, timing=%d" % (anim_id, offset, param, timing))
			
			max_param = max(max_param, param)

	base_pos = source.read_l(0x32bd0 + 4*stage_id)		
	for anim_id in range(max_param + 1):
		vdp.clear_plane(0)
		pos = 0x32bd0 + source.read_w(base_pos + 2*anim_id)
		print("anim #%d data at %X" % (anim_id, pos))
		
		source.set_pos(pos)

		while True:
			half_dma = source.read_w()
			if half_dma == 0:
				break
			
			height = source.read_b() + 1
			width = source.read_b() + 1
			data_pos = source.read_l()
			
			vpos = 0xC000 | (half_dma & 0x3FFF)
			x = ((vpos - 0xE000) & 0x7F) // 2
			y = (vpos - 0xE000) // 0x80
			
			print("area: dma=%04X, vpos=%X (%d, %d), height=%d, width=%d, data at %X" % (half_dma, vpos, x, y, height, width, data_pos))
			
			source.push()
			source.set_pos(data_pos)
			for dy in range(height):
				for dx in range(width):
					vdp.plane_put_at(Vdp.plane_A, (x + dx)*8, (y + dy)*8, source.read_w())
			source.pop()

		vdp.save_plane(0, "debug/ken_stage_plane_a_area_%02d.png" % (anim_id,), bg_color=0xE0E)
		

def get_object_0_0(source, vdp):
	# e. honda
	for frame_def in get_frame_defs(source, anims_id=[1], frames_id=[0,1,2,3,4,5,6,7]):
		put_object("0_0", source, vdp, source_tiles=0x400, tile_flags=0, frame_def=frame_def)

def get_object_0_1(source, vdp):
	# ken : les bornes
	for frame_def in get_frame_defs(source, anims_id=[3], frames_id=[6]):
		put_object("0_1", source, vdp, source_tiles=0x3bb, tile_flags=0x2000, frame_def=frame_def)

def get_object_7_2(source, vdp):
	# ken : tonneau
	for frame_def in get_frame_defs(source, anims_id=[3], frames_id=[0, 1, 5]):
		put_object("7_2", source, vdp, source_tiles=0x3BB, tile_flags=0x2000, frame_def=frame_def)

def get_object_35(source, vdp):
	# e. honda
	for frame_def in get_frame_defs(source, anims_id=[1], frames_id=[0, 1]):
		put_object("35", source, vdp, source_tiles=0x400, tile_flags=0x2000, frame_def=frame_def)

def get_object_4A(source, vdp):
	# ryu : les oiseaux
	for frame_def in get_frame_defs(source, anims_id=[0], frames_id=[0, 1, 2, 3, 4, 5, 6, 7, 8]):
		put_object("4A", source, vdp, source_tiles=0x400, tile_flags=0x2000, frame_def=frame_def)

def get_object_59(stage_id, source, vdp):
	# dépend du stage_id
	# ken : personnes sur un bateau
	if stage_id in [0]:
		return

	if stage_id == 1:
		for pos in [0x2f212, 0x2F234]:
			put_object("59", source, vdp, tile_flags=0x2000, frame_def=pos, long_frames=True)
	
	if stage_id == 4:
		for pos in [0x2F2DA, 0x2F31C]:
			put_object("59", source, vdp, tile_flags=0x2000, frame_def=pos, long_frames=True)
	

def extract_stage(stage_id):
	stage_name = stage_names[stage_id]
	
	vdp = Vdp(plane_A_size = (512, 512))
	
	pal_data = source.read_l(0x14862 + 4*stage_id)
	source.set_pos(pal_data)
	vdp.load_palette(source, 0)
	vdp.load_palette(source, 16)
	
	gfx_data_addr = 0x148c0 + source.read_w(0x148c0 + 2*stage_id)
	
	source.set_pos(gfx_data_addr)
	while True:
		ln = source.read_w()
		if ln == 0:
			break
		tileset_addr = source.read_l()
		vdest = source.read_w()
		
		if vdest == 0xE000:
			tilemap_addr = tileset_addr
		
		source.push()
		source.set_pos(tileset_addr)
		vdp.load_tiles(source, vdest // 0x20, ln // 0x20)
		source.pop()
	
	vdp.save_tiles("debug/%s_stage_pal_0.png" % stage_name, pal_id=0)
	vdp.save_tiles("debug/%s_stage_pal_1.png" % stage_name, pal_id=1)
	
	print("tilemap at %X" % tilemap_addr)
	
	source.set_pos(tilemap_addr)
	
	for y in range(0, 512, 8):
		for x in range(0, 512, 8):
			vdp.plane_put_at(Vdp.plane_A, x, y, source.read_w())
	
	vdp.save_plane(0, "debug/%s_stage_plane_a.png" % stage_name, bg_color=0xE0E)

	# ken
	#get_object_0_1(source, vdp)
	#get_object_7_2(source, vdp)
	#get_object_59(source, vdp)
	get_object_14(source, vdp, stage_id)

	# ryu	
	#get_object_4A(source, vdp)
	
	# e. honda
	#get_object_0_0(source, vdp)
	#get_object_35(source, vdp)
	#get_object_59(stage_id, source, vdp)



extract_stage(7)
#for k in range(len(stage_names)):
#	extract_stage(k)




