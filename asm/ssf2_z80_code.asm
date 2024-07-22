; Disassembly of the file "D:\Documents\ghidra\ssf2\ssf2_z80_code.bin"
; 
; CPU Type: Z80
; 
; Created with dZ80 2.0
; 
; on Tuesday, 01 of August 2023 at 06:31 PM
; 
0000 f3        di      
0001 ed56      im      1
0003 310010    ld      sp,1000h
0006 3eff      ld      a,0ffh
0008 32fe1f    ld      (1ffeh),a
000b 32ff1f    ld      (1fffh),a
000e 2a0110    ld      hl,(1001h)
0011 22e31f    ld      (1fe3h),hl
0014 22eb1f    ld      (1febh),hl
0017 3a0310    ld      a,(1003h)
001a 32e51f    ld      (1fe5h),a
001d 32ed1f    ld      (1fedh),a
0020 010060    ld      bc,6000h
0023 11fd1f    ld      de,1ffdh
0026 3afe1f    ld      a,(1ffeh)
0029 feff      cp      0ffh
002b 2838      jr      z,0065h
002d 6f        ld      l,a
002e 2600      ld      h,00h
0030 29        add     hl,hl
0031 29        add     hl,hl
0032 29        add     hl,hl
0033 eb        ex      de,hl
0034 dd210010  ld      ix,1000h
0038 dd19      add     ix,de
003a eb        ex      de,hl
003b 3ae01f    ld      a,(1fe0h)
003e 6f        ld      l,a
003f dd7e00    ld      a,(ix+00h)
0042 bd        cp      l
0043 381b      jr      c,0060h
0045 32e01f    ld      (1fe0h),a
0048 dd6e04    ld      l,(ix+04h)
004b dd6605    ld      h,(ix+05h)
004e 22e11f    ld      (1fe1h),hl
0051 dd6e01    ld      l,(ix+01h)
0054 dd6602    ld      h,(ix+02h)
0057 22e31f    ld      (1fe3h),hl
005a dd7e03    ld      a,(ix+03h)
005d 32e51f    ld      (1fe5h),a
0060 3eff      ld      a,0ffh
0062 32fe1f    ld      (1ffeh),a
0065 3aff1f    ld      a,(1fffh)
0068 feff      cp      0ffh
006a 2838      jr      z,00a4h
006c 6f        ld      l,a
006d 2600      ld      h,00h
006f 29        add     hl,hl
0070 29        add     hl,hl
0071 29        add     hl,hl
0072 eb        ex      de,hl
0073 dd210010  ld      ix,1000h
0077 dd19      add     ix,de
0079 eb        ex      de,hl
007a 3ae81f    ld      a,(1fe8h)
007d 6f        ld      l,a
007e dd7e00    ld      a,(ix+00h)
0081 bd        cp      l
0082 381b      jr      c,009fh
0084 32e81f    ld      (1fe8h),a
0087 dd6e04    ld      l,(ix+04h)
008a dd6605    ld      h,(ix+05h)
008d 22e91f    ld      (1fe9h),hl
0090 dd6e01    ld      l,(ix+01h)
0093 dd6602    ld      h,(ix+02h)
0096 22eb1f    ld      (1febh),hl
0099 dd7e03    ld      a,(ix+03h)
009c 32ed1f    ld      (1fedh),a
009f 3eff      ld      a,0ffh
00a1 32ff1f    ld      (1fffh),a
00a4 2ae31f    ld      hl,(1fe3h)
00a7 7c        ld      a,h
00a8 07        rlca    
00a9 02        ld      (bc),a
00aa 3ae51f    ld      a,(1fe5h)
00ad 02        ld      (bc),a
00ae 0f        rrca    
00af 02        ld      (bc),a
00b0 0f        rrca    
00b1 02        ld      (bc),a
00b2 0f        rrca    
00b3 02        ld      (bc),a
00b4 0f        rrca    
00b5 02        ld      (bc),a
00b6 0f        rrca    
00b7 02        ld      (bc),a
00b8 0f        rrca    
00b9 02        ld      (bc),a
00ba 0f        rrca    
00bb 02        ld      (bc),a
00bc cbfc      set     7,h
00be 7e        ld      a,(hl)
00bf 08        ex      af,af'
00c0 2aeb1f    ld      hl,(1febh)
00c3 7c        ld      a,h
00c4 07        rlca    
00c5 02        ld      (bc),a
00c6 3aed1f    ld      a,(1fedh)
00c9 02        ld      (bc),a
00ca 0f        rrca    
00cb 02        ld      (bc),a
00cc 0f        rrca    
00cd 02        ld      (bc),a
00ce 0f        rrca    
00cf 02        ld      (bc),a
00d0 0f        rrca    
00d1 02        ld      (bc),a
00d2 0f        rrca    
00d3 02        ld      (bc),a
00d4 0f        rrca    
00d5 02        ld      (bc),a
00d6 0f        rrca    
00d7 02        ld      (bc),a
00d8 cbfc      set     7,h
00da 3e2a      ld      a,2ah
00dc 12        ld      (de),a
00dd 320040    ld      (4000h),a
00e0 08        ex      af,af'
00e1 86        add     a,(hl)
00e2 1f        rra     
00e3 320140    ld      (4001h),a
00e6 af        xor     a
00e7 12        ld      (de),a
00e8 2ae11f    ld      hl,(1fe1h)
00eb 7c        ld      a,h
00ec b5        or      l
00ed 2818      jr      z,0107h
00ef 2b        dec     hl
00f0 22e11f    ld      (1fe1h),hl
00f3 7c        ld      a,h
00f4 b5        or      l
00f5 2818      jr      z,010fh
00f7 21e31f    ld      hl,1fe3h
00fa 34        inc     (hl)
00fb 201e      jr      nz,011bh
00fd 2ae41f    ld      hl,(1fe4h)
0100 23        inc     hl
0101 22e41f    ld      (1fe4h),hl
0104 c32301    jp      0123h
0107 3e05      ld      a,05h
0109 3d        dec     a
010a 20fd      jr      nz,0109h
010c 00        nop     
010d 1814      jr      0123h
010f af        xor     a
0110 32e01f    ld      (1fe0h),a
0113 00        nop     
0114 00        nop     
0115 1800      jr      0117h
0117 1800      jr      0119h
0119 1808      jr      0123h
011b 3e00      ld      a,00h
011d 1800      jr      011fh
011f 1800      jr      0121h
0121 1800      jr      0123h
0123 2ae91f    ld      hl,(1fe9h)
0126 7c        ld      a,h
0127 b5        or      l
0128 2818      jr      z,0142h
012a 2b        dec     hl
012b 22e91f    ld      (1fe9h),hl
012e 7c        ld      a,h
012f b5        or      l
0130 2818      jr      z,014ah
0132 21eb1f    ld      hl,1febh
0135 34        inc     (hl)
0136 201e      jr      nz,0156h
0138 2aec1f    ld      hl,(1fech)
013b 23        inc     hl
013c 22ec1f    ld      (1fech),hl
013f c32301    jp      0123h
0142 3e05      ld      a,05h
0144 3d        dec     a
0145 20fd      jr      nz,0144h
0147 00        nop     
0148 1814      jr      015eh
014a af        xor     a
014b 32e81f    ld      (1fe8h),a
014e 00        nop     
014f 00        nop     
0150 1800      jr      0152h
0152 1800      jr      0154h
0154 1808      jr      015eh
0156 3e00      ld      a,00h
0158 1800      jr      015ah
015a 1800      jr      015ch
015c 1800      jr      015eh
015e c32600    jp      0026h
0161 c20000    jp      nz,0000h
