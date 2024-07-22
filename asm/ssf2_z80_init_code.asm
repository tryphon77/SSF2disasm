; Disassembly of the file "D:\Documents\ghidra\ssf2\ssf2_z80_init_code.bin"
; 
; CPU Type: Z80
; 
; Created with dZ80 2.0
; 
; on Tuesday, 01 of August 2023 at 06:28 PM
; 
0000 af        xor     a
0001 01d91f    ld      bc,1fd9h
0004 112700    ld      de,0027h
0007 212600    ld      hl,0026h
000a f9        ld      sp,hl
000b 77        ld      (hl),a
000c edb0      ldir    
000e dde1      pop     ix
0010 fde1      pop     iy
0012 ed47      ld      i,a
0014 ed4f      ld      r,a
0016 d1        pop     de
0017 e1        pop     hl
0018 f1        pop     af
0019 08        ex      af,af'
001a d9        exx     
001b c1        pop     bc
001c d1        pop     de
001d e1        pop     hl
001e f1        pop     af
001f f9        ld      sp,hl
0020 f3        di      
0021 ed56      im      1
0023 36e9      ld      (hl),0e9h
0025 e9        jp      (hl)
