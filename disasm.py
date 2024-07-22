# -*- coding: utf-8 -*-

# @Todo:
#	* movea (0x......), a0 : 0x...... should be recognized as a label
#   * faire quelque chose pour les labels locaux
#   * reprendre la gestion des types

import numpy as np
import os
from m68k_alt import m68k_opcodes, parse_opcode, Label
from data import Data, Type
from buffer_alt import Buffer


class Section:
	def __init__(self, name, pos):
		self.name = name
		self.start = pos
		self.end = 0x10000000
		self.code = []
	
	def close_at(self, pos):
		self.end = pos
	
	def __repr__(self):
		return "[Section '%s' from 0x%x to 0x%x]" % (self.name, self.start, self.end)
		
def match_fields(model, value):
	fields = {}
	start = 0
	score = 0
	current_field = ""
	for k, m in enumerate(model):
		if m != current_field:
			if current_field:
				fields[current_field] = value[start : k]
			current_field = m
			start = k
		
		if m == "0":
			if value[k] == "0":
				score += 1
			else:
				return 0, {}
		elif m == "1":
			if value[k] == "1":
				score += 1
			else:
				return 0, {}
	if current_field:
		fields[current_field] = value[start:]
	return score, fields
				

def disassemble_one_line(buf, candidates = []):
	code = buf.next_word_as_bin()
	instr, score, fields = None, 0, {}
	for instr in m68k_opcodes:
		opcode = instr[1]
		score, fields = match_fields(opcode, code)
		if score > 0:
#			print("\t %s | %s" % (instr, fields))
			res = parse_opcode(buf, instr, fields)
			if res is not None:
				return res
	print("code |%s| not found at %X" % (code, buf.pos - 2))


def dump(res, buf, start, end):
	for pos in range(start, end, 16):
		res[pos] = {
			'data_type': 'dump',
			'dump': ' '.join(['%02X' % x for x in buf[pos : min(pos + 16, end)]])
		}


def disassemble(buf, pos, disassembly, memory_mask):
	code_candidates = []
	buf.pos = pos
	
	while True:
		pos = buf.pos 
		res = None
		if pos < len(buf) and memory_mask[pos] != 1:
			try:
				print ("trying to disassemble %X" % pos)
				res = disassemble_one_line(buf)
				print ("disassembling %X" % pos)
			except:
				pass
				
		if res == None:
			print ("unable to disassemble at %06X" % pos)
		else:
			disassembly[pos] = res['code']
			memory_mask[pos : buf.pos] = 1

			for candidate in res['candidates']:
				if candidate not in disassembly.keys() and candidate not in code_candidates:
					code_candidates += [candidate]
		
		if code_candidates:
			buf.pos = code_candidates[0]
			del code_candidates[0]
		else:
			break
	
	dump_mode = False
	for pos in range(len(memory_mask)):
		if memory_mask[pos] == 0 and not dump_mode:
			dump_start = pos
			dump_mode = True
		elif memory_mask[pos] == 1 and dump_mode:
			dump_end = pos
			dump_mode = False
			print ('dump from %X to %X' % (dump_start, dump_end))
			dump(disassembly, buf, dump_start, dump_end)
	   
	if dump_mode:
		dump_end = pos
		print ('dump from %X to %X' % (dump_start, dump_end))
		dump(disassembly, buf, dump_start, dump_end)
	
def format_code_line(line, comment=""):
	code = line["code"]
	
	instr = code["instruction"]
	size = code["size"]
	params = code["params"]
	
	if size:
		res = "\t%s.%s\t%s" % (instr, size, ", ".join(["%s" % p for p in params]))
	else:
		res = "\t%s\t%s" % (instr, ", ".join(["%s" % p for p in params]))
	
	if comment:
		comment_lines = comment.split("\n")
		
		res += "\t; %s" % comment_lines[0]
		for l in comment_lines[1:]:
			res += "\n\t\t\t; %s" % l
	return res

def print_code_line(line):
	print(format_code_line(line))

def check_rom(buf, path, exceptions={}):		
	with open(path) as f:
		lines = f.readlines()
	
	for line in lines:
		line = line.strip()
		if line.startswith("S"):
			line_type = line[1]
			if line_type == "3":
				line_ln = int(line[2:4], 16) - 5
				line_addr = int(line[4:12], 16)
				line_data = line[12 : 12 + 2*line_ln]
#				print("%X: %s" % (line_addr, line_data))
				
				pos = line_addr
				i = 0
				while i < line_ln:
#					print("\t%02d/%02d: |%s|" % (2*i, line_ln, line_data[2*i : 2*i + 2]))
					s, d = buf[pos], int(line_data[2*i : 2*i + 2], 16)
					i += 1
					if s != d:
						if pos in exceptions:
							print("found")
							code = exceptions[pos]
							print(code)
							print(line_data[2*i - 2 : 2*i - 2 + len(code)])
							if code.upper() == line_data[2*i - 2 : 2*i - 2 + len(code)]:
								pos += len(code)//2
								i += pos - 1
								continue
						# raise Exception("mismatch at 0x%x: %02X != %02X" % (pos, s, d))
					pos += 1

def make_rom(buf, path):		
	with open(path) as f:
		lines = f.readlines()
	
	res = np.zeros_like(buf.data)
	
	for line in lines:
		line = line.strip()
#		print(line)
		if line.startswith("S"):
			line_type = line[1]
			if line_type == "3":
				line_ln = int(line[2:4], 16) - 5
				line_addr = int(line[4:12], 16)
				line_data = line[12 : 12 + 2*line_ln]
#				print("%X: %s" % (line_addr, line_data))
				
				pos = line_addr
				for i in range(line_ln):
#					print("\t%02d/%02d: |%s|" % (2*i, line_ln, line_data[2*i : 2*i + 2]))
					res[pos] = int(line_data[2*i : 2*i + 2], 16)
					pos += 1
	
	return res


class Program:
	def __init__(self):
		self.source = None
		self.symbols = []
		self.comments = {}
		self.datas = {}
		self.sections = {}
		self.errors = []

	def error(self, msg):
		self.errors.append(msg)
	
	def handle_errors(self):
		if self.errors:
			print("\n".join(self.errors))
			raise Exception("Errors during parsing")

	def include(self, code, name):
		self.current_code.append((-1, '\tinclude\t"%s.asm"' % name))
		section = Section(name, program.source.pos)
		section.code += code
		self.sections[pos] = section

	def set_source(self, path):
		self.source = Buffer(np.fromfile(path, dtype=np.uint8))
		self.rom_size = len(self.source.data)
		self.source_attrs = np.zeros((self.rom_size,), dtype=np.uint8)

	def read_ghidra_xml(self, path):
		
		def xml_get_tag(s, tag):
			i = s.index(tag + "=")
			j = s.index('"', i + 1)
			k = s.index('"', j + 1)
			return s[j + 1 : k]
	
		def xml_get_inner(s):
			s = s.strip()
#			print(s)
			assert s[0] == "<"
			a = s.index(" ")
			nm = s[1:a]
			b = s.index(">", a)
#			print("%d, %d, |%s|" % (a, b, nm))
			c = s.index("</%s>" % nm)
#			print(a, b, c, nm)
			return s[b + 1: c]
			
	
		with open(path, newline="") as f:
			xml_file = f.read()
		
		for line in xml_file.split("\r"):
			line = line.strip()
			if line.startswith("<CODE_BLOCK"):
				start = int(xml_get_tag(line, "START"), 16)
#				end = int(xml_get_tag(line, "END"), 16)
			
			elif line.startswith("<SYMBOL "):
				address = int(xml_get_tag(line, "ADDRESS"), 16)
#				namespace = xml_get_tag(line, "NAMESPACE").replace(":", "")
				name = xml_get_tag(line, "NAME")
				scope = xml_get_tag(line, "TYPE")
				
				if True: # address < 0x400000:
					Label.make(address, name, scope=scope)
			
			elif line.startswith("<DEFINED_DATA "):
				base_type_name = data_type = xml_get_tag(line, "DATATYPE")
				start = int(xml_get_tag(line, "ADDRESS"), 16)
#				size = int(xml_get_tag(line, "SIZE"), 16)
				scope = xml_get_tag(line, "TYPE")
				sz = 1
				if "[" in data_type:
					i = data_type.index("[")
					j = data_type.index("]")

					base_type_name = data_type[:i]
					sz = int(data_type[i + 1 : j])

				base_type = Type.from_string(base_type_name)
				if base_type is None:
					raise Exception("unrecognized type %s at position 0x%x" %(base_type_name, start))

				Data.make(start=start, datatype=base_type, length=sz)
				

			elif line.startswith("<FUNCTION "):
				address = int(xml_get_tag(line, "ENTRY_POINT"), 16)
				name = xml_get_tag(line, "NAME")

				if address < 0x400000:
					Label.make(address, name, scope="global")

			elif line.startswith("<COMMENT "):
				address = int(xml_get_tag(line, "ADDRESS"), 16)
				type_ = xml_get_tag(line, "TYPE")
				comment = xml_get_inner(line)
				
				if type_ == "pre":
					if comment.startswith("section"):
						section_name = comment[8:]
						current_section = self.sections[address] = Section(section_name, address)
				
				if type_ == "post":
					if comment.startswith("endsection"):
						current_section.close_at(address)
					
				
				for c in ["VSRAM write", "DMA VRAM write"]:
					if comment.startswith(c):
						self.comments[address] = comment


if __name__ == '__main__':
	program = Program()
	program.set_source("ssf2.bin")

	program.read_ghidra_xml("ssf2.xml")
	
	Data.make(start=0x200, datatype = Type.from_string("Checksums"), length=11)
	
	disasm = [(-1, '\tinclude\t"MoreSymbols.asm"')]
	main = program.main = program.current_code = disasm
	
	source = program.source
	source_attrs = program.source_attrs
	source.pos = 0
	data_start = source.pos
	section = None
	display_source_pos = True
	
	while source.pos < 0xafae: # rom_size:
		pos = source.pos

		if not section:
			if pos in program.sections:
				section = program.sections[pos]
				print("%x: switching to %r" % (pos, section))
				main.append((-1, '\tinclude\t"%s.asm"' % section.name))
				disasm = section.code
				program.current_code = section.code
		
		if section:
			if pos > section.end:
				print("%x: switching to main" % pos)
				section = None
				disasm = main
				program.current_code = main
		
		data = Data.at_pos(pos)
		if data:
			data.render(program, disasm)
			continue

		line = disassemble_one_line(source, candidates = [])
		if line is None:
			break
		comment = program.comments.get(pos, "")

		disasm.append((pos, format_code_line(line, comment=comment)))
#		source.pos = line["next"]


	main_section = Section("main", 0)
	main_section.code = main
	program.sections[-1] = main_section

	include_sources = []
	for section in program.sections.values():
		print(section)

		disasm_code = []
		for pos, line in section.code:
			if pos >= 0:
				label, offset = Label.at_pos(pos)
				if label and offset==0:
					if label.scope == "GLOBAL":
						disasm_code.append("")
					disasm_code.append("%s:" % label.to_string(offset=offset))
					label.is_defined = True
					label.is_used = True
			if display_source_pos:
				line += "\t; 0x%x" % pos

			disasm_code.append(line)

		include_sources.append(("%s.asm" % section.name, "\n".join(disasm_code)))
	
	disasm_code = []
	for label in Label.labels.values():
		label.offset = 0
		if not label.is_defined and label.is_used:
			disasm_code.append("%s\tequ\t$%0x\t; %s %s" % (label.to_string(), label.pos, ["", "defined"][label.is_defined], ["", "used"][label.is_used]))
			
	include_sources.append(("MoreSymbols.asm", "\n".join(disasm_code)))
		

	for path, disasm_code in include_sources:
		with open(path, "w") as f:
			print(path)
			f.write(disasm_code)

	program.handle_errors()
	
	dirname = os.getcwd()
#	cmd = "bin\\vasmm68k_mot.exe -Fsrec -spaces -no-opt ssf2.asm"
	cmd = "bin\\asm68k.exe /o os+ /ps main.asm,a.out"
	print(cmd)
	os.system(cmd)
	
	out = make_rom(source, "a.out")
	out.tofile("out.bin")
	
	check_rom(source, "a.out", exceptions = {
		0x3818: "c14e", 	# exg a6, a0 / exg a0, a6
		0x15890: "c54e", 	# exg a6, a2 / exg a2, a6
	})
	