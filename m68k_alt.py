# -*- coding: utf-8 -*-

from buffer_alt import s8, s16
from data import Label


# AM1  Addressing mode	   MX	andi, move, btst, movea, add, cmp, lea, jsr
# AM2  Addressing mode	   mx	move
# C	Condition code		C	 b??
# D	Displacement		  D	 bra, b??
# D2   Displacement (word)		 db??
# S1   Size 1				S	 andi, add, cmp,
# S2   Size 2				S	 cmpa
# S3   Size 3				S	 move, movea
# $a   address register	  R	 movea
# $d   data register		 R	 moveq
# d	immediate data		d	 moveq
# I	immediate data			  andi (next word or long)
# dir1 direction			 d	 movem
# dir3 direction			 d	 add
# L	register list			   movem

m68k_opcodes = [
	["abcd",	"1100XXX10000MYYY",	["bcd"]],
	["sbcd",	"1000XXX10000MYYY",	["bcd"]], # before or to prevent ambiguity
	["add",		"1101RRRdSSMMMXXX", ["S1", "AM1", "$d", "dir3"]],
	["adda",	"1101RRRS11MMMXXX", ["S2", "AM1", "$a"]],
	["addi",	"00000110SSMMMXXX",	["S1", "I", "AM1"]],	# addi
	["addq",	"0101ddd0SSMMMXXX",	["S1", "sd", "AM1"]],
	["exg",		"1100XXX1MMMMMYYY", ["exg"]],	# before "and" to prevent ambiguity
	["and",		"1100RRRdSSMMMXXX", ["S1", "AM1", "$d", "dir3"]],
	["andi",	"0000001000111100", ["Sw", "I", "ccr"]], # andi to CCR
	["andi",	"0000001001111100", ["I", "SR"]],
	["andi",	"00000010SSMMMXXX", ["S1", "I", "AM1"]],
	["as",		"1110000d11MMMXXX", ["shiftdir", "AM1"]],
	["as",		"1110rrrdSSM00RRR",	["shiftdir", "S1", "rot", "$d"]],
	["bchg",	"0000100001MMMXXX", ["I", "AM1"]],
	["bra",		"01100000DDDDDDDD", ["D"]],
	["bsr",		"01100001DDDDDDDD", ["D"]],
	["b",	  	"0110CCCCDDDDDDDD", ["C", "D"]],
	["bclr",	"0000100010MMMXXX", ["I", "AM1"]],
	["bclr",	"0000RRR110MMMXXX", ["$d", "AM1"]],
	["bset",	"0000100011MMMXXX", ["I", "AM1"]],
	["bset",	"0000RRR111MMMXXX", ["$d", "AM1"]],
	["btst",	"0000100000MMMXXX", ["I", "AM1"]],
	["btst",	"0000RRR100MMMXXX", ["$d", "AM1"]],	
	["chk",		"0100RRR110MMMXXX",	["Sw", "AM1", "$d"]],
	["clr",		"01000010SSMMMXXX",	["S1", "AM1"]],
	["cmp",		"1011RRR0SSMMMXXX", ["S1", "AM1", "$d"]],
	["cmpa",	"1011RRRS11MMMXXX", ["S2", "AM1", "$a"]],
	["cmpi",	"00001100SSMMMXXX",	["S1", "I", "AM1"]],
	["db",	 	"0101CCCC11001RRR", ["C", "$d", "D2"]],
	["divu", 	"1000RRR011MMMXXX", ["Sw", "AM1", "$d"]],
	["divs", 	"1000RRR111MMMXXX", ["Sw", "AM1", "$d"]],
	["eor",	 	"1011RRR1SSMMMXXX", ["S1", "$d", "AM1"]],
	["eori",	"00001010SSMMMXXX",	["S1", "I", "AM1"]],
	["ext", 	"010010001S000RRR", ["S2", "$d"]],
	["jmp",		"0100111011MMMXXX", ["AM1"]],
	["jsr",		"0100111010MMMXXX", ["AM1"]],
	["lea",		"0100RRR111MMMXXX", ["AM1", "$a"]],
	["ls",		"1110001d11MMMXXX",	["shiftdir", "AM1"]],
	["ls",		"1110rrrdSSM01RRR",	["shiftdir", "S1", "rot", "$d"]],
	["move",	"010011100110dRRR", ["U", "$a", "dir2"]],	# move usp 
	["move",	"0100000011MMMXXX",	["Sw", "SR", "AM1"]],	# move from SR
	["move",	"0100011011MMMXXX",	["Sw", "AM1", "SR"]],	# move to SR
	["move",	"00SSxxxmmmMMMXXX", ["S3", "AM1", "AM2"]],
	["movea",   "00SSRRR001MMMXXX", ["S3", "AM1", "$a"]],
	["movem",   "01001d001SMMMXXX", ["S2", "AM1", "L", "dir2"]],
	["moveq",   "0111RRR0dddddddd", ["d", "$d"]],
	["mulu", 	"1100RRR011MMMXXX", ["Sw", "AM1", "$d"]],
	["muls", 	"1100RRR111MMMXXX", ["Sw", "AM1", "$d"]],
	["neg",		"01000100SSMMMXXX",	["S1", "AM1"]],
	["nop", 	"0100111001110001", []],
	["not",		"01000110SSMMMXXX",	["S1", "AM1"]],
	["ori",		"0000000000111100", ["Sb", "I", "ccr"]], # ori to CCR
	["or",		"1000RRRdSSMMMXXX", ["S1", "AM1", "$d", "dir3"]],
	["ori",		"00000000SSMMMXXX", ["S1", "I", "AM1"]],
	["ro",		"1110rrrdSSM11RRR",	["shiftdir", "S1", "rot", "$d"]],
	["rte",	 	"0100111001110011", []],
	["rts",	 	"0100111001110101", []],
	["s",		"0101CCCC11MMMXXX", ["C", "AM1"]],
	["sub",	 	"1001RRRdSSMMMXXX", ["S1", "AM1", "$d", "dir3"]],
	["suba",	"1001RRRS11MMMXXX", ["S2", "AM1", "$a"]],
	["subi",	"00000100SSMMMXXX",	["S1", "I", "AM1"]],
	["subq",	"0101ddd1SSMMMXXX",	["S1", "sd", "AM1"]],
	["swap",	"0100100001000RRR", ["$d"]],
	["tst",	 	"01001010SSMMMXXX", ["S1", "AM1"]],
	["trap",	"010011100100dddd",	["d"]],
]


class DataRegister:
	def __init__(self, reg_id):
		self.reg_id = reg_id
	
	def __repr__(self):
		return 'd%s' % self.reg_id
		
class AddressRegister:
	def __init__(self, reg_id):
		self.reg_id = reg_id
	
	def __repr__(self):
		return 'a%s' % self.reg_id

class OtherRegister:
	def __init__(self, name):
		self.name = name
	
	def __repr__(self):
		return self.name

usp_register = OtherRegister("usp")
status_register = OtherRegister("sr")
ccr_register = OtherRegister("ccr")

data_registers = [
	DataRegister(0),
	DataRegister(1),
	DataRegister(2),
	DataRegister(3),
	DataRegister(4),
	DataRegister(5),
	DataRegister(6),
	DataRegister(7)
]

address_registers = [
	AddressRegister(0),
	AddressRegister(1),
	AddressRegister(2),
	AddressRegister(3),
	AddressRegister(4),
	AddressRegister(5),
	AddressRegister(6),
	AddressRegister(7)
]

sp_register = address_registers[7]

class Address:
	def __init__(self, reg_id):
		self.register = address_registers[reg_id]
	
	def __repr__(self):
		return '(%s)' % self.register

class PostIncrement:
	def __init__(self, reg_id):
		self.register = address_registers[reg_id]
	
	def __repr__(self):
		return '(%s)+' % self.register
		
class PreDecrement:
	def __init__(self, reg_id):
		self.register = address_registers[reg_id]
	
	def __repr__(self):
		return '-(%s)' % self.register

class Displacement:
	def __init__(self, reg_id, offset):
		self.register = address_registers[reg_id]
		self.offset = offset
	
	def __repr__(self):
		return '(%s, %s)' % (self.offset, self.register)
		
class Index:
	def __init__(self, reg_id, data_reg_id, offset):
		self.address_register = address_registers[reg_id]
		self.data_register = data_registers[data_reg_id]
		self.offset = offset
	
	def __repr__(self):
		return '(%s, a%s, d%s)' % (self.offset, self.address_register, self.data_register)
		
class PCDisplacement:
	def __init__(self, pc_value, offset):
		self.offset = s16(offset)
		self.pc_value = pc_value
	
	def __repr__(self):
		return '($%x, pc)' % (self.pc_value + self.offset)
#		return '($%x, pc)' % self.offset

class PCIndex:
	def __init__(self, extension_word, pos):
		reg_id = (extension_word >> 12) & 7
		self.size = ['w', 'l'][(extension_word >> 11) & 1]
		if extension_word & 0x8000:
			self.register = address_registers[reg_id]
		else:
			self.register = data_registers[reg_id]
		self.pos = pos & 0xffffff
		self.displacement = s8(extension_word & 255)
#		print(self)
	
	def __repr__(self):
#		print("PCIndex")
		label, offset = Label.at_pos(self.pos + self.displacement)
		if label:
			label.is_used = True
			return '(%s, pc, %s.%s)' % (label.to_string(offset), self.register, self.size)
		else:
			return '(%d, pc, %s.%s)' % (self.pos + self.displacement, self.register, self.size)

class Absolute:
	def __init__(self, pos, short = False):
		self.pos = pos & 0xffffffff
		self.short = short
		label, offset = Label.at_pos(self.pos)
		if not label:
			label = Label.make(self.pos, name="LBL_%06x" % self.pos, scope="GLOBAL")
	
	def __repr__(self):
		label, offset = Label.at_pos(self.pos)
		if label:
			label.is_used = True # 
			res = '%s' % label.to_string(offset)
		else:
			res = '$%x' % (self.pos & 0xffffffff)
		
		if self.short:
			res = '(%s).w' % res
		
		return res

class Indexed:
	def __init__(self, base_reg_id, index_reg_id, offset, is_word):
		self.base_register = address_registers[base_reg_id]
		self.index_register = data_registers[index_reg_id]
		self.offset = offset
		self.is_word = is_word
	
	def __repr__(self):
		if self.is_word:
			return '(%s, %s, %s)' % (self.offset, self.base_register, self.index_register)
		return '(%s, %s, %s.l)' % (self.offset, self.base_register, self.index_register)

class Immediate:
	def __init__(self, val, size = 2):
		self.val = val # u32(val)
		self.size = size
	
	def __repr__(self):
#		print(self.val, self.size)
		if -10 < self.val < 10:
			return '#%s' % self.val
		if self.val >= 0:
			return ('#$%0' + str(2*self.size) + 'x') % self.val
		return ('#-$%0' + str(2*self.size) + 'x') % (-self.val)


def get_addressing_mode(buf, sz, M, X):
	x = int(X, 2)
	if M == "000":
		return data_registers[x]
	if M == "001":
		return address_registers[x]
	if M == "010":
		return Address(x)
	if M == "011":
		return PostIncrement(x)
	if M == "100":
		return PreDecrement(x)
	if M == "101":
		return Displacement(x, s16(buf.next_word()))
	if M == "110":
		n = buf.next_byte()
		return Indexed(x, (n >> 4) & 7, s16(buf.next_byte()), (n & 0xF) == 0)
	if X == "000":
		return Absolute(s16(buf.next_word()), short=True)
	if X == "001":
		return Absolute(buf.next_long())
	if X == "010":
		return PCDisplacement(buf.pos, buf.next_word())
	if X == "011":
		pos = buf.pos
		extension = s16(buf.next_word())
		return PCIndex(extension, pos)
	if X == "100":
		if sz == 'b':
			return Immediate(buf.next_word(), size = 1)
		if sz == 'w':
			return Immediate(buf.next_word(), size = 2)
		else:
			return Immediate(buf.next_long(), size = 4)
	raise Exception()

def select(items, mask):
	res = []
	k = 2**15
	for i in items:
		if mask & k:
		   res += [i]
		k = k >> 1
	return res

class RegisterList:
	def __init__(self, reg_list):
		self.register_list = reg_list
	
	def __str__(self):
		return '/'.join([str(x) for x in self.register_list])
	
	@staticmethod
	def from_pre_decrement_mask(mask):
#		print('%04X' % mask)
		return RegisterList(select(data_registers + address_registers, mask))
	
	@staticmethod
	def from_post_increment_mask(mask):
#		print('%04X' % mask)
		return RegisterList(select(reversed(data_registers + address_registers), mask))

def get_addr_mode_1(buf, code, fields):
	code['params'] += [get_addressing_mode(buf, code['size'], fields['M'], fields['X'])]
	return True
	
def get_addr_mode_2(buf, code, fields):
	code['params'] += [get_addressing_mode(buf, code['size'], fields['m'], fields['x'])]
	return True

def get_condition_code(buf, code, fields):
	val = int(fields['C'], 2)
	code['instruction'] += (['t', 'f', 'hi', 'ls', 'cc', 'cs', 'ne', 'eq', 'vc', 'vs', 'pl', 'mi', 'ge', 'lt', 'gt', 'le'][val])
	return True

def get_displacement(buf, code, fields):
	rel_addr = s8(fields['D'])
	if rel_addr == 0:
		code['size'] = 'w'
		rel_addr = s16(buf.next_word() - 2)
	else:
		code['size'] = 'b'
	label = Label.make(buf.pos + rel_addr, scope="LOCAL")
	code['params'] += [label.to_string()]
	return True

def get_displacement_2(buf, code, fields):
	rel_addr = s16(buf.next_word() - 2)
	label = Label.make(buf.pos + rel_addr)
	code['params'] += [label.to_string()]
	return True

def get_size_1(buf, code, fields):
	val = int(fields['S'], 2)
	if val == 3:
		return False
	code['size'] = ['b', 'w', 'l'][val]
	return True

def get_size_2(buf, code, fields):
	val = int(fields['S'], 2)
	if val >= 2:
		return False
	code['size'] = ['w', 'l'][val]
	return True

def get_size_3(buf, code, fields):
	val = int(fields['S'], 2)
	if val == 0:
		return False
	code['size'] = ['b', 'l', 'w'][val - 1]
	return True

def get_size_b(buf, code, fields):
	code['size'] = 'b'
	return True

def get_size_w(buf, code, fields):
	code['size'] = 'w'
	return True

def get_address_reg(buf, code, fields):
	code['params'] += [address_registers[int(fields['R'], 2)]]
	return True

def get_data_reg(buf, code, fields):
	code['params'] += [data_registers[int(fields['R'], 2)]]
	return True

def get_data(buf, code, fields):
	code['params'] += [Immediate(s8(int(fields['d'], 2)))]
	return True

def get_small_data(buf, code, fields):
	value = int(fields['d'], 2)
	if value == 0:
		value = 8
	code['params'] += [Immediate(value)]
	return True

def get_immediate_data(buf, code, fields):
	if code['size'] == 'l':
		code['params'] += [Immediate(buf.next_long(), size = 4)]
	elif code['size'] == 'b':
		code['params'] += [Immediate(buf.next_word(), size = 1)]
	else:
		code['params'] += [Immediate(buf.next_word(), size = 2)]
	return True

def get_register_list(buf, code, fields):
	if isinstance(code['params'][0], PreDecrement):
		code['params'] += [RegisterList.from_pre_decrement_mask(buf.next_word())]
	else:
		code['params'] += [RegisterList.from_post_increment_mask(buf.next_word())] 
#	print ([str(x) for x in code['params']])
	return True

def get_direction_2(buf, code, fields):
	if fields['d'] == "0":
		a, b = code['params']
		code['params'] = [b, a]
	return True
		
def get_direction_3(buf, code, fields):
	if fields['d'] == "1":
		a, b = code['params']
		code['params'] = [b, a]
	return True

def get_shift_direction(buf, code, fields):
	if fields['d'] == "1":
		code["instruction"] += "l"
	else:
		code["instruction"] += "r"
	return True

#	["ls",		"1110rrrdSSM01RRR",	["shiftdir", "S1", "rot", "$d"]],

def get_rotation(buf, code, fields):
	if fields["M"] == "0":
		# immediate
		value = int(fields["r"], 2)
		if value == 0:
			value = 8
		code["params"] += [Immediate(value)]
	else:
		code["params"] += [data_registers[int(fields['R'], 2)]]
	return True

def get_usp_register(buf, code, fields):
	code["size"] = "l"
	code['params'] += [usp_register]
	return True

def get_sr_register(buf, code, fields):
	code['params'] += [status_register]
	return True

def get_sp_register(buf, code, fields):
	code['params'] += [sp_register]
	return True

def get_ccr_register(buf, code, fields):
	code['params'] += [ccr_register]
	return True

def get_bcd(buf, code, fields):
	code['size'] = 'b'
	if fields['M'] == "0":
		code['params'].append(data_registers[int(fields['Y'], 2)])
		code['params'].append(data_registers[int(fields['X'], 2)])
	else:
		code['params'].append(PreDecrement(int(fields['Y'], 2)))
		code['params'].append(PreDecrement(int(fields['X'], 2)))
	return True

def get_exg(buf, code, fields):
	rx = int(fields['X'], 2)
	ry = int(fields['Y'], 2)
	if fields["M"] == "01000":
		code["params"].append(data_registers[rx])
		code["params"].append(data_registers[ry])
	elif fields["M"] == "01001":
		code["params"].append(address_registers[ry])
		code["params"].append(address_registers[rx])
	elif fields["M"] == "10001":
		code["params"].append(data_registers[rx])
		code["params"].append(address_registers[ry])
	else:
		return False
	return True

params_funs = {
	"AM1": get_addr_mode_1,
	"AM2": get_addr_mode_2,
	"C": get_condition_code,
	"D" : get_displacement,
	"D2": get_displacement_2,
	"S1": get_size_1,
	"S2": get_size_2,
	"S3": get_size_3,
	"Sb": get_size_b,
	"Sw": get_size_w,
	"$a": get_address_reg,
	"$d": get_data_reg,
	"d": get_data,
	"sd": get_small_data,
	"I": get_immediate_data,
	"dir2": get_direction_2,
	"dir3": get_direction_3,
	"shiftdir": get_shift_direction,
	"L": get_register_list,
	"rot": get_rotation,
	"U": get_usp_register,
	"SR": get_sr_register,
	"sp": get_sp_register,
	"bcd": get_bcd,
	"ccr": get_ccr_register,
	"exg": get_exg,
}

def parse_opcode(buf, instr, fields):
	global candidates
	
	candidates = []
	instr_name, _, parser = instr
	code = {
		'data_type': 'code',
		'instruction': instr_name,
		'size': '',
		'params': []
	}
	
	for p in parser:
		if not params_funs[p](buf, code, fields):
			return None
	
	if instr_name not in ["rts", "rte", "reset", "stop"]:
		candidates.append(buf.pos)
	
	return {
		'code': code,
		'candidates': candidates,
		'next': buf.pos
		}
