# -*- coding: utf-8 -*-


def ext24to32(x):
	x = x & 0xffffff
	if x & 0x800000:
		x |= 0xff000000
	return x

def s8(v):
	if type(v) is str:
		v_ = int(v, 2)
	else:
		v_ = int(v)
	if v_ >= 128:
		v_ -= 256
	return v_

def s16(v):
	if type(v) is str:
		v_ = int(v, 2)
	else:
		v_ = int(v)
	if v_ >= 32768:
		v_ -= 65536
	return v_

def u32(v):
	v_ = int(v)
	if v_ < 0:
		v_ += 0x100000000
	return v_

def u16_to_s32(x):
	if x & 0x8000:
		return int(x) - 0x10000
	return int(x)

def int_to_str(x):
	if -10 < x < 10:
		return str(x)
	else:
		return "$%x" % x

class Buffer:
	def __init__(self, data):
		self.data = data
		self.pos = 0
	
	def __len__(self):
		return len(self.data)
	
	def __getitem__(self, it):
		return self.data.__getitem__(it)

	def next_byte(self, signed=False):
		res = self.data[self.pos]
		if signed and res >= 0x80:
			res -= 0x100
		self.pos += 1
#		print ('next_word: %04X' % res)
		return res

	def next_word(self, signed=False):
		res = (int(self.data[self.pos]) << 8) + int(self.data[self.pos + 1])
		if signed and res >= 0x8000:
			res -= 0x10000
		self.pos += 2
#		print ('next_word: %04X' % res)
		return res
	
	def next_word_as_bin(self):
		return format(self.next_word(), '016b')
	
	def next_long(self):
		res = (int(self.data[self.pos]) << 24) + (int(self.data[self.pos + 1]) << 16)\
	+ (int(self.data[self.pos + 2]) << 8) + int(self.data[self.pos + 3])
		self.pos += 4
#		print ('next_long: %08X' % res)
		return res
	
	def read_str(self, size, encoding=None):
		res = ""
		for i in range(size):
			c = self.next_byte()
#			print("\t%d/%d %X: %x (%s)" % (i, size, self.pos - 1, c, chr(c)))
			res += chr(c)
		return res
