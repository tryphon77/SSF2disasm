# -*- coding: utf-8 -*-

import pygame

transp_color = pygame.Color(0x123456)
font_surf = pygame.image.load("font.png")
text_layer = pygame.Surface((512, 512))
text_layer.fill(transp_color)
text_layer.set_colorkey(transp_color)

def text_at(pos, text):
	x0, y0 = pos
	lines = text.upper().split("\n")
	for line in lines:
		x = x0
		for c in line:
			i = ord(c) - 32
			text_layer.blit(font_surf, (x*8, y0*8), (i*8, 0, 8, 8))
			x += 1
		y0 += 1

def clear_text(rect = None):
	if rect is None:
		text_layer.fill(transp_color)
	else:
		text_layer.fill(transp_color, rect)
	