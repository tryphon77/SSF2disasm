# -*- coding: utf-8 -*-

from buffer_alt import Buffer, ext24to32, int_to_str


class Label:
	labels = {}
	
	def __init__(self, pos, name = "", candidates=None, scope=None):
		if scope is None:
			print("Label %s at %x untyped" % (name, pos))
			raise Exception()
		self.pos = pos & 0xffffffff
		if candidates is not None:
			candidates.append(pos)
		if name == "":
			name = "loc_%08X" % self.pos
		self.name = name
		self.is_defined = False	 	# True when defined in source code
		self.is_used = False 		# True when used by some instruction
		self.scope = scope.upper()
		self.offset = 0
	
	@staticmethod
	def make(pos, name = "", scope=None):
		pos = ext24to32(pos)
		if pos in Label.labels:
			res = Label.labels[pos]
			if name and res.name.startswith("loc_"):
				res.name = name
		else:
			if name:
				name = name.replace("?", "_")
			res = Label(pos, name, scope=scope)
			Label.labels[pos] = res			
		return res
	
	@staticmethod
	def at_pos(pos):			
		pos = ext24to32(pos)
		offset = 0
		if data := Data.at_pos(pos):
			offset = pos - data.start
			pos = data.start

		if pos in Label.labels:
			return Label.labels[pos], offset
		else:
			return None, 0
	
	def to_string(self, offset=0):
		self.is_used = True
		if self.scope != "GLOBAL":
			res = "@%s" % self.name
		else:
			res = self.name
		if self.offset != 0:
			res += "+%s" % int_to_str(self.offset)
			
		return res

class Data:
	datas = {}
	
	def __init__(self, datatype=None, length=0):
		self.length = length
		self.datatype=datatype
		self.size = self.length*self.datatype.size
		
	@staticmethod
	def make(start=0, datatype=None, length=0):
		data = Data(datatype=datatype, length=length)
		data.start = start
		Data.datas[start] = data

	def render(self, program, out):
		if self.datatype.read_and_render:
			self.datatype.read_and_render(program, out)
		else:
			program.error("Data could not be rendered at position 0x%x" % self.start)

	@staticmethod
	def at_pos(pos):
		for p in Data.datas:
			data = Data.datas[p]
			if p <= pos < p + data.size:
				return data

class Type:
	declared_types = {}
	def __init__(self, name="", size=0, read_and_render_function=None):
		if name not in Type.declared_types:
			Type.declared_types[name] = self
		self.name = name
		self.size = size
		self.read_and_render = read_and_render_function
	
	@staticmethod
	def from_string(s):
		return Type.declared_types.get(s, None)


def render_data(program, data, out, funcs):
	if data.datatype not in funcs:
		program.error("Unhandled datatype %s at position %x" % (data.datatype, program.source.pos))
	funcs[data.datatype](program, out)

def write_data(buf, out, params):
	func = {
		"b": Buffer.next_byte, 
		"w": Buffer.next_word, 
		"l": Buffer.next_long
	}
	for data, size in params:
		if size.startswith("str"):
			str_size = int(size[3:])
			out.append((buf.pos, '%s\tdc.b\t"%s"' % (data, buf.read_str(str_size))))
		elif size.startswith("p"):
			pos = buf.next_long()
			lbl = Label.make(pos, name = data, scope="GLOBAL")
			lbl.is_used = True
			out.append((buf.pos, 'v%s\tdc.l\t%s' % (data, lbl.to_string())))
		else:
			out.append((buf.pos, "%s\tdc.%s\t$%x" % (data, size, func[size](buf))))


def read_vector_table(program, main):
	buf = program.source
	out = []
	out.append((-1, "; Vector Table"))
	write_data(buf, out, [
		("Stack", "p"),
		("Reset", "p"),
		("BusError", "p"),
		("AddressError", "p"),
		("IllegalInstruction", "p"),
		("DivisionByZero", "p"),
		("ChkInstruction", "p"),
		("TrapvInstruction", "p"),
		("PrivilegeViolation", "p"),
		("Trace", "p"),
		("LineA", "p"),
		("LineF", "p"),
		("Unused1", "p"),
		("Unused2", "p"),
		("Unused3", "p"),
		("UninitializedInterrupt", "p"),
		("Reserved1", "p"),
		("Reserved2", "p"),
		("Reserved3", "p"),
		("Reserved4", "p"),
		("Reserved5", "p"),
		("Reserved6", "p"),
		("Reserved7", "p"),
		("Reserved8", "p"),
		("SpuriousInt", "p"),
		("Irq1Int", "p"),
		("ExtInt", "p"),
		("Irq3Int", "p"),
		("HInt", "p"),
		("Irq5Int", "p"),
		("VInt", "p"),
		("Irq7Int", "p"),
		("Trap00", "p"),
		("Trap01", "p"),
		("Trap02", "p"),
		("Trap03", "p"),
		("Trap04", "p"),
		("Trap05", "p"),
		("Trap06", "p"),
		("Trap07", "p"),
		("Trap08", "p"),
		("Trap09", "p"),
		("Trap10", "p"),
		("Trap11", "p"),
		("Trap12", "p"),
		("Trap13", "p"),
		("Trap14", "p"),
		("Trap15", "p"),
		("FpUnused1", "p"),
		("FpUnused2", "p"),
		("FpUnused3", "p"),
		("FpUnused4", "p"),
		("FpUnused5", "p"),
		("FpUnused6", "p"),
		("FpUnused7", "p"),
		("FpUnused8", "p"),
		("MmuUnused1", "p"),
		("MmuUnused2", "p"),
		("MmuUnused3", "p"),
		("Reserved9", "p"),
		("Reserved10", "p"),
		("Reserved11", "p"),
		("Reserved12", "p"),
		("Reserved13", "p"),
	])
	program.include(out, "VectorTable")

def read_rom_header(program, main):
	buf = program.source
	out = []
	out.append((-1, "; ROM Header"))
	write_data(buf, out, [	
		("hSystemType", "str16"),
		("hCopyrightInfo", "str16"),
		("hGameTitle", "str48"),
		("hAlternateTitle", "str48"),
		("hSerialNumber", "str14"),
		("hChecksum", "w"),
		("hDeviceSupport", "str16"),
		("hRomStart", "l"),
		("hRomEnd", "l"),
		("hRamStart", "l"),
		("hRamEnd", "l"),
		("hExtraMemory", "str12"),
		("hModemSupport", "str12"),
		("hReserved1", "str40"),
		("hRegion", "str3"),
		("hReserved2", "str13")
	])
	buf.pos = 0x200
	program.include(out, "RomHeader")

def read_byte(program, out):
	buf = program.source
	pos = buf.pos
	data = Data.at_pos(pos)
	res = ["$%02x" % buf.next_byte() for _ in range(data.length)]
	out.append((pos, "\tdc.b\t%s" % ", ".join(res)))

def read_char(program, out):
	buf = program.source
	pos = buf.pos
	data = Data.at_pos(pos)
	res = ["'%s'" % chr(buf.next_byte()) for _ in range(data.length)]
	out.append((pos, "\tdc.b\t%s" % ", ".join(res)))

def read_string(program, out):
	buf = program.source
	pos = buf.pos
	res = []
	last_res = []
	while True:
		c = buf.next_byte()
		if 0x20 <= c < 0x80:
			last_res.append(chr(c))
		else:
			if last_res:
				res.append('"%s"' % ''.join(last_res))
			res.append("$%02x" % c)
			last_res = []
		
		if c == 0:
			break

	if last_res:
		res.append('"%s"' % ''.join(last_res))
	out.append((pos, "\tdc.b\t%s" % ", ".join(res)))

def read_word(program, out):
	buf = program.source
	pos = buf.pos
	data = Data.at_pos(pos)
	res = ["$%04x" % buf.next_word() for _ in range(data.length)]
	out.append((pos, "\tdc.w\t%s" % ", ".join(res)))

def read_dword(program, out):
	buf = program.source
	pos = buf.pos
	data = Data.at_pos(pos)
	res = ["$%08x" % buf.next_long() for _ in range(data.length)]
	out.append((pos, "\tdc.l\t%s" % ", ".join(res)))

def read_pointer(program, out):
	buf = program.source
#	datas = program.datas
	pos = buf.pos
	ptr = buf.next_long()
	label, offset = Label.at_pos(ptr)
	if label is None:
		program.error("no label at position %x, referenced at position %x" % (ptr, pos))
	out.append((pos, "\tdc.l\t%s" % label.to_string()))

def compute_checksums(program, out):
	buf = program.source
	for _ in range(11):
		pos = buf.pos
		out.append((pos, "\tdc.l\t$%08x" % buf.next_long()))

def compute_jump_table(program, out):
	buf = program.source
#	datas = program.datas
	pos = buf.pos
	base_label, base_offset = Label.at_pos(pos)
	if base_label is None:
		program.error("no label at position %x" % pos)
	assert base_offset == 0
	while True:
		pos_ = buf.pos
		data = Data.at_pos(pos_)
		lbl, _ = Label.at_pos(pos_)

		if (lbl is None or lbl == base_label) and data and data.datatype == type_JumpOffset:
			o = buf.next_word(signed=True)
			ptr = pos + o
			label, offset = Label.at_pos(ptr)
			if label is None:
				program.error("no label at position %x, referenced at position %x, offset=%x" % (ptr, pos, o))
			assert offset == 0
			out.append((pos_, "\tdc.w\t%s-%s" % (label.to_string(), base_label.to_string())))
		else:
			return

def read_struct_tiledata_dma(program, out):
	buf = program.source
	pos = buf.pos
	
	out.append((pos, "\tdc.w\t$%04X\t; length in words" % buf.next_word()))
	half_addr = buf.next_long()
	label, offset = Label.at_pos(half_addr*2)
	if label is None:
		program.error("At position 0x%x: no tiledata label at 0x%x" % (pos + 2, half_addr*2))
		
	out.append((pos + 2, "\tdc.l\t%s/2\t; source" % (label.to_string(offset))))
	out.append((pos + 6, "\tdc.w\t$%x\t; dest" % buf.next_word()))
	out.append((-1, ""))

def read_struct_palette_loader(program, out):
	buf = program.source
	pos = buf.pos
	
	nb_colors = buf.next_byte()
	start = buf.next_byte()
	src = buf.next_long()

	label, offset = Label.at_pos(src)
	if label is None:
		program.error("At position 0x%x: no palette label at 0x%x" % (pos + 2, src))

	out.append((pos, "\tdc.b\t$%02X\t; nb of colors: %d" % (nb_colors, nb_colors*2 + 1)))
	out.append((pos + 1, "\tdc.b\t$%02X\t; first colors: 0x%02x" % (start, start//2)))
	out.append((pos + 2, "\tdc.l\t%s/2\t; source" % (label.to_string())))
	out.append((-1, ""))

def read_struct_data_loader(program, out):
	buf = program.source
	pos = buf.pos
	
	length = buf.next_word()
	src = buf.next_long()
	dest = buf.next_word()

	label, offset = Label.at_pos(src)
	if label is None:
		program.error("At position 0x%x: no palette label at 0x%x" % (pos + 2, src))

	out.append((pos, "\tdc.w\t$%02X\t; nb of bytes" % length))
	out.append((pos + 2, "\tdc.l\t%s/2\t; source" % (label.to_string())))
	out.append((pos + 6, "\tdc.w\t$%02X\t; destination in VRAM" % dest))
	out.append((-1, ""))

def read_struct_patterns_loader(program, out):
	# même chose que struct_data_loader
	buf = program.source
	pos = buf.pos
	
	length = buf.next_word()
	src = buf.next_long()
	dest = buf.next_word()

	label, offset = Label.at_pos(src)
	if label is None:
		program.error("At position 0x%x: no palette label at 0x%x" % (pos + 2, src))

	out.append((pos, "\tdc.w\t$%02X\t; nb of bytes" % length))
	out.append((pos + 2, "\tdc.l\t%s/2\t; source" % (label.to_string())))
	out.append((pos + 6, "\tdc.w\t$%02X\t; destination in VRAM" % dest))
	out.append((-1, ""))

def read_struct_word_box(program, out):
	buf = program.source
	pos = buf.pos

	x = buf.next_word(signed=True)
	y = buf.next_word(signed=True)
	w = buf.next_word()
	h = buf.next_word()
	
	out.append((pos, "\tdc.w\t%d,%d,%d,%d\t; box" % (x, y, w, h)))

def read_struct_tilemap(program, out):
	buf = program.source
	pos = buf.pos

	dma_cmd = buf.next_word()
	upper = buf.next_byte()
	
	out.append((pos, "\tdc.w\t$%x; write to 0x%x" % (dma_cmd, 0xc000 | (dma_cmd & 0x3fff))))
	out.append((pos + 2, "\tdc.b\t$%02x; upper byte" % upper))
	
	res = []
	pos = buf.pos
	while True:
		c = buf.next_byte()
		if c == 0:
			break
		res.append(c)
		if c == 0xff:
			out.append((pos, "\tdc.b\t%s" % ",".join(["$%02x" % x for x in res])))
			pos = buf.pos
			res = []
	
	out.append((pos, "\tdc.b\t%s" % ",".join(["$%02x" % x for x in res])))

	if buf.pos & 1:
		out.append((buf.pos, "\tdc.b\t$00,$%02x" % buf.next_byte()))
	else:
		out.append((buf.pos, "\tdc.b\t$00"))
#	out.append((-1, "; =================================="))

def read_struct_tilemap_chunk(program, out):
	buf = program.source
	pos = buf.pos

	length = buf.next_byte()
	upper = buf.next_byte()
	dma_cmd = buf.next_word()

	out.append((pos, "\tdc.b\t%d\t; length - 1" % length))	
	out.append((pos + 2, "\tdc.b\t$%02x; upper byte" % upper))
	out.append((pos + 4, "\tdc.w\t$%x; write to 0x%x" % (dma_cmd, 0xc000 | (dma_cmd & 0x3fff))))
	
	res = []
	pos = buf.pos
	for _ in range(length + 1):
		c = buf.next_byte()
		res.append(c)
	
	out.append((pos, "\tdc.b\t%s" % ",".join(["$%02x" % x for x in res])))
	if buf.pos & 1:
		out.append((buf.pos, "\tdc.b\t$%02x" % buf.next_byte()))

data_type_readers = {
	"VectorsTable": read_vector_table,
	"RomHeader": read_rom_header,
	"Checksums": compute_checksums,
	"JumpOffset": compute_jump_table,
	"structPaletteLoader": read_struct_palette_loader,
	"structDataLoader": read_struct_data_loader,
	"structPatternsLoader": read_struct_patterns_loader,
	"structTileDataDMA": read_struct_tiledata_dma,
	"structWordBox": read_struct_word_box,
	"structTilemap": read_struct_tilemap,
	"structTilemapChunk": read_struct_tilemap_chunk,
	"byte": read_byte,
	"char": read_char,
	"string": read_string,
	"word": read_word,
	"dword": read_dword,
	"pointer": read_pointer
}


type_VectorsTable = Type(name="VectorsTable", size=0x100, read_and_render_function=read_vector_table)
type_RomHeader = Type(name="RomHeader", size=0x100, read_and_render_function=read_rom_header)
type_Checksums = Type(name="Checksums", size=4, read_and_render_function=compute_checksums)
type_JumpOffset = Type(name="JumpOffset", size=2, read_and_render_function=compute_jump_table)
type_structPaletteLoader = Type(name="structPaletteLoader", size=6, read_and_render_function=read_struct_palette_loader)
type_structDataLoader = Type(name="structDataLoader", size=8, read_and_render_function=read_struct_data_loader)
type_structPatternsLoader = Type(name="structPatternsLoader", size=8, read_and_render_function=read_struct_patterns_loader)
type_structTileDataDMA = Type(name="structTileDataDMA", size=8, read_and_render_function=read_struct_tiledata_dma)
type_structWordBox = Type(name="structWordBox", size=8, read_and_render_function=read_struct_word_box)
type_structTilemap = Type(name="structTilemap", size=3, read_and_render_function=read_struct_tilemap)
type_structTilemapChunk = Type(name="structTilemapChunk", size=4, read_and_render_function=read_struct_tilemap_chunk)
type_byte = Type(name="byte", size=1, read_and_render_function=read_byte)
type_char = Type(name="char", size=1, read_and_render_function=read_char)
type_string = Type(name="string", size=1, read_and_render_function=read_string)
type_word = Type(name="word", size=2, read_and_render_function=read_word)
type_dword = Type(name="dword", size=4, read_and_render_function=read_dword)
type_pointer = Type(name="pointer", size=4, read_and_render_function=read_pointer)

type_undefined1 = Type(name="undefined1", size=1)
type_undefined2 = Type(name="undefined2", size=1)
type_undefined3 = Type(name="undefined3", size=1)
type_undefined4 = Type(name="undefined4", size=1)
type_sword = Type(name="sword", size=2)
type_qword = Type(name="qword", size=4)
type_structAltTileDataDMA = Type(name="structAltTileDataDMA", size=6)
type_structSpriteDefElement = Type(name="structSpriteDefElement", size=6)
type_structSpriteDefElementAlt = Type(name="structSpriteDefElementAlt", size=8)
type_structWalkSpeed = Type(name="structWalkSpeed", size=8)
type_structBgArea = Type(name="structBgArea", size=8)
type_structBox = Type(name="structBox", size=4)
type_structProjectionPosition = Type(name="structProjectionPosition", size=4)
type_unicode = Type(name="unicode", size=1)
type_structAnimationStep = Type(name="structAnimationStep", size=4)
type_structFrameAttributes = Type(name="structFrameAttributes", size=16)
type_structPlayer = Type(name="structPlayer", size=0x300)
type_structObject = Type(name="structObject", size=24)
type_structJoyState = Type(name="structJoyState", size=6)


