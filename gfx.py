# -*- coding: utf-8 -*-

from buffer import Buffer, LittleEndianBuffer
import pygame, png
import numpy as np

base_palette = [0x000, 0x00E, 0x0E0, 0x0EE, 0xE00, 0xE0E, 0xEE0, 0xEEE,
				0x444, 0x44A, 0x4A4, 0x4AA, 0xA44, 0xA4A, 0xAA4, 0xAAA]

def get_pygame_palette(md_pal):
	def cvt_3bpp_to_8bpp(x):
		return x*16
#			return int(round(x * 255/14))
	
	palette_pyg = []
	i = 0
	for color in md_pal:
		b0, g0, r0 = (color >> 8), (color >> 4) & 15, color & 15
		a, b, g, r = 255, cvt_3bpp_to_8bpp(b0), cvt_3bpp_to_8bpp(g0), cvt_3bpp_to_8bpp(r0)
#		print("color %d: (%04X) %X %X %X -> %02X %02X %02X" % (i, color, b0, g0, r0, b, g, r))
		i += 1
		palette_pyg.append(pygame.Color((r, g, b, a)))
	
	return palette_pyg


class Surface4bpp:
	
	debug_counter = 0

	def __init__(self, size, palette = base_palette):
		self.width, self.height = size
		self.data = np.zeros((self.height, self.width), dtype = np.uint8)
		self.left, self.right = self.width, 0
		self.top, self.bottom = self.height, 0
		self.palette = palette
	
	def split(self, size=(8, 8)):
		y = 0
		w, h = size
		res = []
		while y < self.height:
			x = 0
			while x < self.width:
				s = Surface4bpp(size, self.palette)
				s.blit(self, (0, 0), (x, y, w, h))
				res.append(s)
				x += w
			y += h
		return res
	
	def get_at(self, x, y):
		return self.data[y, x]
	
	def set_at(self, pos, color):
		x, y = pos
		self.data[y, x] = color
	
	def blit(self, src, dest_pos, src_rect = (0,0), hflip=False, vflip=False, transparence=False):
#		print(dest_pos, src_rect)
		dx, dy = dest_pos
		
		if len(src_rect) == 4:
			sx, sy, w, h = src_rect
		else:
			sx, sy = src_rect[:2]
			w, h = self.width, self.height
		dw, dh = self.width - dx, self.height - dy
		sw, sh = src.width - sx, src.height - sy
		w, h = min(w, sw, dw), min(h, sh, dh)

		src_data = src.data[sy:sy+h, sx:sx+w].copy()
		if vflip:
			src_data = src_data[::-1, :]
		if hflip:
			src_data = src_data[:, ::-1]
		
		if transparence:
			self.data[dy:dy+h, dx:dx+w][src_data != 0] = src_data[src_data != 0] # [sy:sy+h, sx:sx+w]
		else:
			self.data[dy:dy+h, dx:dx+w] = src_data # [sy:sy+h, sx:sx+w]

		self.left = min(dx, self.left)
		self.right = max(dx + w, self.right)
		self.top = min(dy, self.top)
		self.bottom = max(dy + h, self.bottom)

	def fill(self, col, rect=None):
		if rect:
			x, y, w, h = rect
			self.data[y : y + h, x : x + w] = col
		else:
			self.data[:,:] = col
		
	def hflip(self):
		self.save_as_tga("debug/debug1.tga")
		self.data = self.data[:, ::-1]
		self.save_as_tga("debug/debug2.tga")
		
	def vflip(self):
		self.save_as_tga("debug/debug1.tga")
		self.data = self.data[::-1, :]
		self.save_as_tga("debug/debug2.tga")
		
	def set_at(self, x, y, color):
		self.data[y, x] = color
		self.left = min(x, self.left)
		self.right = max(x + 1, self.right)
		self.top = min(y, self.top)
		self.bottom = max(y + 1, self.bottom)
		
	def save_as_tga(self, path, palette = None):
		if palette is None:
			palette = self.palette
			
		res = LittleEndianBuffer(length = 32000000)
		# 1 byte : ID length (Length of the image ID field)
		res.write_b(0)
		# 1 byte : Color map type (Whether a color map is included)
		res.write_b(1)
		# 1 byte : Image type (Compression and color types)
		res.write_b(1)
		# 5 bytes : Color map specification (Describes the color map)
		res.write_w(0)  # index of first color
		res.write_w(16) # number of colors
		res.write_b(24) # palettes bpp
		# 10 bytes : Image specification (Image dimensions and format)
		res.write_w(0)  # X origin
		res.write_w(0)  # Y origin
		res.write_w(self.width)
		res.write_w(self.height)
		res.write_b(8)  # bpp
		res.write_b(0x20)
		
		# color map data
		def cvt_3bpp_to_8bpp(x):
			return int(round(x * 255/14))
			
		for color in palette:
			b0, g0, r0 = (color >> 8), (color >> 4) & 15, color & 15
			b, g, r = cvt_3bpp_to_8bpp(b0), cvt_3bpp_to_8bpp(g0), cvt_3bpp_to_8bpp(r0)
#			print("(%04X) %X %X %X -> %02X %02X %02X" % (color, b0, g0, r0, b, g, r))
			res.write_b(b)
			res.write_b(g)
			res.write_b(r)
		
		# image data
		res.data[res.pos:res.pos + len(self.data)] = bytearray(self.data.flatten())
#		raise Exception()
		
# 		for y in range(self.height):
# 			for x in range(self.width):
# #				print(x, y, self.get_at(x, y))
# 				res.write_b(self.get_at(x, y))
		
		res.save(path)

	@staticmethod
	def load_from_tga_8(path):
		def cvt_(x):
			r, g, b = x.r, x.g, x.b
			return ((b // 32) << 9) + ((g//32) << 5) + ((r // 32) << 1)
		   
		pysurf = pygame.image.load(path)
		palette_32 = pysurf.get_palette()
		
		pal = [cvt_(x) for x in palette_32[:16]]
		
		res = Surface4bpp(pysurf.get_size())
		pypixels = pygame.surfarray.pixels2d(pysurf)
		res.data[:] = (pypixels & 0xF).transpose()
		del pypixels
		
		return res, pal
	
	def to_pygame_8(self, pal, offset=0):
#		def cvt_(col):
#			if col == 255:
#				return pygame.Color((0xFE, 0xDC, 0xBA))
#			b, g, r = (col >> 8), ((col >> 4) & 15), col & 15
#			return pygame.Color((r*16, g*16, b*16))

		w, h = self.width, self.height
		res = pygame.Surface((w, h), depth=8)
		ares = pygame.surfarray.pixels2d(res)
		ares[:] = offset + self.data[:].transpose()
		ares.tofile("debug/array_%d.bin" % Surface4bpp.debug_counter)
		del ares
#		res.set_palette([(0, 0, 0)] * offset + [cvt_(col) for col in pal])
		
#		pygame.image.save(res, "debug/debug_tile_%04d.png" % self.debug_counter)
		Surface4bpp.debug_counter += 1
		return res
	
	def save_as_tga_8(self, path, pal):
		pygame.image.save(self.to_pygame_8(pal), path)
	
	@staticmethod
	def load_from_tga(path):
		tga = LittleEndianBuffer.load(path)
		# 1 byte : ID length (Length of the image ID field)
		id_length = tga.read_b()
		# 1 byte : Color map type (Whether a color map is included)
		cmap_type = tga.read_b()
		# 1 byte : Image type (Compression and color types)
		img_type = tga.read_b()
		# 5 bytes : Color map specification (Describes the color map)
		first_col_index = tga.read_w()  # index of first color
		nb_colors = tga.read_w() # number of colors
		color_bpp = tga.read_b() # palettes bpp
		# 10 bytes : Image specification (Image dimensions and format)
		x0 = tga.read_w()  # X origin
		y0 = tga.read_w()  # Y origin
		width = tga.read_w()
		height = tga.read_w()
		bpp = tga.read_b()  # bpp
		_ = tga.read_b()
		
		# color map data
		def cvt_8bpp_to_3bpp(r, g, b):
			r0 = int((r/255)*7)*2
			g0 = int((g/255)*7)*2
			b0 = int((b/255)*7)*2
			c = (b0 << 8) + (g0 << 4) + r0
#			print("(0x%02X, 0x%02X, 0x%02X) -> 0x%04X" % (r, g, b, c))
			return c
		
		pal = []
		for _ in range(16):
			r0, g0, b0 = tga.read_b(), tga.read_b(), tga.read_b()
			col = cvt_8bpp_to_3bpp(b0, g0, r0)
			pal.append(col)
		
#		print("ID length: %d\nColor map type: %d\nImage type: %d\nIndex of first color: %d\nNumber of colors: %d\nPalettes bpp: %d\nOrigin: %d, %d\nWidth=%d, height=%d\nbpp=%d" % (id_length, cmap_type, img_type, first_col_index, nb_colors, color_bpp, x0, y0, width, height, bpp))
		
		res = Surface4bpp((width, height), palette=pal)
		# image data
		for y in range(height):
			for x in range(width):
#				print(x, y, self.get_at(x, y))
				res.set_at(x, y, tga.read_b())
		
		return res

	def to_pygame(self, palette, crop = False):
		res = pygame.Surface((self.width, self.height))
		
		# color map data
		palette_pyg = get_pygame_palette(palette)
		
		if crop:
			x0, y0, w, h = self.left, self.top, self.right - self.left, self.bottom - self.top
		x0, y0, w, h = 0, 0, self.width, self.height
		
		# image data
		for y in range(y0, h):
			for x in range(x0, w):
#				print(x, y, self.get_at(x, y))
				res.set_at((x, y), palette_pyg[self.get_at(x, y)])
		
		if crop:
			res.set_colorkey(palette_pyg[0])
		return res
	
	def save_as_png_8(self, path, palette=base_palette, crop=False, offset=0):
		def cvt_(col):
			b, g, r = (col >> 8), ((col >> 4) & 15), col & 15
			return (r*16, g*16, b*16)
		
		print("save %s, with offset=%d" % (path, offset))
#		print(', '.join(["%03x" % x for x in palette]))
		w = png.Writer(self.width, self.height, palette=[cvt_(col) for col in palette], bitdepth=8)
		with open(path, 'wb') as f:
			w.write(f, offset + self.data)
		
		
	@staticmethod
	def load_from_png(path, palette):
		pysurf = pygame.image.load(path)
		
		r, g, b = np.transpose(pygame.surfarray.pixels_red(pysurf)), np.transpose(pygame.surfarray.pixels_green(pysurf)), np.transpose(pygame.surfarray.pixels_blue(pysurf))
		
		rf, gf, bf = np.array(r, dtype=np.float32), np.array(g, dtype=np.float32), np.array(b, dtype=np.float32)
#		ri, gi, bi = np.array(rf*7/255, dtype=np.uint16), np.array(gf*7/255, dtype=np.uint16), np.array(bf*7/255, dtype=np.uint16)
		ri, gi, bi = np.array(rf/32, dtype=np.uint16), np.array(gf/32, dtype=np.uint16), np.array(bf/32, dtype=np.uint16)
		isurf = (bi << 9) | (gi << 5) | (ri << 1)
		
#		np.set_printoptions(formatter={'int':hex})
#		print(isurf)

		w, h = pysurf.get_size()
		res = Surface4bpp((w, h))
		masked = np.zeros(shape=(h, w), dtype=bool)
#		print(isurf.shape, res.data.shape)
		for k, col in enumerate(palette):
			res.data[isurf == col] = k & 0xF
			masked[isurf == col] = True
	
		if not masked.all():
			print(np.logical_not(masked).nonzero()[0][0], np.logical_not(masked).nonzero()[1][0])
			raise Exception("Unknown color in %s" % path)
		return res

	@staticmethod
	def load_from_png_8(path):
		def cvt_(col):
			r, g, b = col
			return ((b // 32) << 9) + ((g // 32) << 5) + ((r // 32) << 1)
	
		r = png.Reader(filename=path)
		w, h, arr, info = r.read()
		
		res = Surface4bpp((w, h))
		res.data[:] = list(arr)
		palette = [cvt_(col) for col in info['palette'][:64]]

		return res, palette

	def subsurface(self, rect):
		x, y, w, h = rect
		res = Surface4bpp((w, h))
		res.data = self.data[y:y+h, x:x+w]
		return res

class VdpPatterns(Surface4bpp):
	def __init__(self):
		Surface4bpp.__init__(self, (128, 1024))
	
	def load(self, source, tile_id, nb_of_tiles):
		print('load 0x%X patterns from 0x%X to tile %X' % (nb_of_tiles, source.pos, tile_id))
		y0 = (tile_id // 16)*8
		x0 = (tile_id & 15) * 8
		for _ in range(nb_of_tiles):
			y = y0
			for _ in range(8):
				x = x0
				for _ in range(4):
					cc = source.read_b()
					c1, c2 = cc >> 4, cc & 15
					self.set_at(x, y, c1)
					self.set_at(x + 1, y, c2)
					x += 2
				y += 1
			x0 += 8
			if x0 >= 128:
				x0 = 0
				y0 += 8
	
	def put_at(self, dest, x, y, ptrn_id):
		vflip = (ptrn_id & 0x1000) != 0
		hflip = (ptrn_id & 0x0800) != 0
		ptrn_id &= 0x7FF
		
		sx = (ptrn_id % 16)*8
		sy = (ptrn_id // 16)*8
		dest.blit(self, (x, y), (sx, sy, 8, 8), hflip=hflip, vflip=vflip, transparence=True)

	def put_sprite_at(self, surf, pos, size, ptrn_id, hflip=False, vflip=False):
		x0, y0 = pos
		w, h = size
		res = Surface4bpp((w*8, h*8))
		x = 0
		for i in range(w):
			y = 0
			for j in range(h):
				self.put_at(res, x, y, ptrn_id)
				ptrn_id += 1
				y += 8
			x += 8
		
#		res.save_as_tga('debug-%d.tga' % ptrn_id, [0x11*i for i in range(16)])
		if hflip:
			res.hflip()

		if vflip:
			res.vflip()

		surf.blit(res, (x0, y0))

def gradient_palette(r, g, b):
	return [k*((b << 8) + (g << 4) + r) for k in range(0, 16, 2)] +  [14 *((b << 8) + (g << 4) + r) + k*(((1 - b) << 8) + ((1 - g) << 4) + (1 - r)) for k in range(0, 16, 2)]

class Vdp:
	plane_A=0
	plane_B=1
	
	def __init__(self, plane_A_size = (512, 256), plane_B_size = (512, 256)):
		self.patterns = [Surface4bpp((8, 8)) for _ in range(0x800)]
		self.palettes = np.array(gradient_palette(1, 0, 0) + gradient_palette(0, 1, 0) + gradient_palette(0, 0, 1) + gradient_palette(1, 1, 0), dtype = np.uint16)
		self.planes = [
			Surface4bpp(plane_A_size),
			Surface4bpp(plane_B_size)
		]

		self.sprite_plane = Surface4bpp((512 + 256, 512 + 256))

		self.bg_color = 0
		self.screen = Surface4bpp((512, 512))

	def clear(self):
		for ptrn in self.patterns:
			ptrn.fill(0)
			
	def load_palette(self, source, start, sz=16):
		for k in range(sz):
			self.palettes[start + k] = source.read_w()

#		pg_palette = get_pygame_palette(self.palettes)
#		self.planes[0].set_palette(pg_palette)
		
	def load_tiles(self, source, tile_id, nb_of_tiles):
		print('load 0x%X patterns from 0x%X to tile %X' % (nb_of_tiles, source.pos, tile_id))
		for _ in range(nb_of_tiles):
			y = 0
			for _ in range(8):
				x = 0
				for _ in range(4):
					cc = source.read_b()
					c1, c2 = cc >> 4, cc & 15
					self.patterns[tile_id].set_at(x, y, c1)
					self.patterns[tile_id].set_at(x + 1, y, c2)
					x += 2
				y += 1
			tile_id += 1
	
	def put_at(self, surf, x, y, ptrn_id):
		pal_id = (ptrn_id >> 13) & 3
		vflip = (ptrn_id & 0x1000) != 0
		hflip = (ptrn_id & 0x0800) != 0
		ptrn_id &= 0x7FF
		
		temp = Surface4bpp((8, 8))
		temp.blit(self.patterns[ptrn_id], (0, 0), (0, 0, 8, 8), hflip=hflip, vflip=vflip)
		temp.data = 16*pal_id + temp.data
		surf[y : y + 8, x : x + 8] = temp.data

	def clear_plane(self, plane):
		self.planes[plane].fill(0)

	def plane_put_at(self, plane, x, y, ptrn_id):
		self.put_at(self.planes[plane], x, y, ptrn_id)

	def clear_sprites(self):
		self.sprite_plane.fill(0)
	
	def put_sprite_at(self, pos, size, ptrn_id, hflip=False, vflip=False):
		vflip = (ptrn_id & 0x1000) != 0
		hflip = (ptrn_id & 0x800) != 0
		x0, y0 = pos
		w, h = size
		res = Surface4bpp((w*8, h*8))
		res.fill(2)
	
		x1 = w*8 if hflip else 0
		y1 = h*8 if vflip else 0

		x = x1
		for i in range(w):
			if hflip:
				x -= 8

			y = y1
			for j in range(h):
				if vflip:
					y -= 8
				self.put_at(res, x, y, ptrn_id)
				ptrn_id += 1

				if not vflip:
					y += 8
			
			if not hflip:
				x += 8
		
		self.sprite_plane.blit(res, (x0, y0))

	def render(self):
		self.screen.fill(self.bg_color)
		
		self.screen.blit(self.planes[0], (0, 0))
		self.screen.blit(self.planes[1], (0, 0), transparence=True)
		self.screen.blit(self.sprite_plane, (0, 0), src_rect=(0, 0, 512, 512), transparence=True)
	
	def save_screen(self, path):
		palette = self.palettes[:]
		self.screen.save_as_png_8(path, palette=palette)

	def save_tiles(self, path, start=0, end=0x800, pal_id=0):
		h = (end - start) // 16
		if (end - start) % 16:
			h += 1
		h *= 8
		
		sheet = Surface4bpp((128, h))
		
		t = start
		for y in range(0, 1024, 8):
			for x in range(0, 128, 8):
				sheet.blit(self.patterns[t], (x, y))
				t += 1
				if t == end:
					break
			if t == end:
				break
		
		sheet.save_as_png_8(path, palette=self.palettes, offset=pal_id*16)

	def save_plane(self, plane_id, path, bg_color=None, binary=False):
#		pygame.image.save(self.planes[plane_id], path)
		palette = self.palettes[:]
		if bg_color:
			palette[0] = palette[16] = palette[32] = palette[48] = bg_color
		self.planes[plane_id].save_as_png_8(path, palette=palette)

	def save_sprites(self, path, bg_color=None, binary=False):
#		pygame.image.save(self.planes[plane_id], path)
		palette = self.palettes[:]
		if bg_color:
			palette[0] = palette[16] = palette[32] = palette[48] = bg_color
		self.sprite_plane.save_as_png_8(path, palette=palette)
	
	def print_palettes(self):
		for i in range(4):
			print("%d: %s" % (i, " ".join(["%03X" % x for x in self.palettes[i*16 : i*16 + 16]])))

