; Disassembly of the file "D:\Documents\ghidra\ssf2\unknown.bin"
; 
; CPU Type: Z80
; 
; Created with dZ80 2.0
; 
; on Tuesday, 01 of August 2023 at 06:34 PM
; 
0000 ff        rst     38h
0001 00        nop     
0002 00        nop     
0003 2d        dec     l
0004 010000    ld      bc,0000h
0007 00        nop     
0008 03        inc     bc
0009 01002d    ld      bc,2d00h
000c bb        cp      e
000d 05        dec     b
000e 00        nop     
000f 00        nop     
0010 03        inc     bc
0011 bc        cp      h
0012 05        dec     b
0013 2d        dec     l
0014 53        ld      d,e
0015 07        rlca    
0016 00        nop     
0017 00        nop     
0018 03        inc     bc
0019 0f        rrca    
001a 0d        dec     c
001b 2d        dec     l
001c 43        ld      b,e
001d 08        ex      af,af'
001e 00        nop     
001f 00        nop     
0020 03        inc     bc
0021 52        ld      d,d
0022 15        dec     d
0023 2d        dec     l
0024 da0400    jp      c,0004h
0027 00        nop     
0028 03        inc     bc
0029 2c        inc     l
002a 1a        ld      a,(de)
002b 2d        dec     l
002c 3607      ld      (hl),07h
002e 00        nop     
002f 00        nop     
0030 03        inc     bc
0031 62        ld      h,d
0032 212dde    ld      hl,0de2dh
0035 07        rlca    
0036 00        nop     
0037 00        nop     
0038 02        ld      (bc),a
0039 40        ld      b,b
003a 29        add     hl,hl
003b 2d        dec     l
003c 53        ld      d,e
003d 02        ld      (bc),a
003e 00        nop     
003f 00        nop     
0040 03        inc     bc
0041 93        sub     e
0042 2b        dec     hl
0043 2d        dec     l
0044 1d        dec     e
0045 04        inc     b
0046 00        nop     
0047 00        nop     
0048 02        ld      (bc),a
0049 b0        or      b
004a 2f        cpl     
004b 2d        dec     l
004c 5a        ld      e,d
004d 03        inc     bc
004e 00        nop     
004f 00        nop     
0050 03        inc     bc
0051 0a        ld      a,(bc)
0052 33        inc     sp
0053 2d        dec     l
0054 e0        ret     po

0055 0b        dec     bc
0056 00        nop     
0057 00        nop     
0058 02        ld      (bc),a
0059 ea3e2d    jp      pe,2d3eh
005c e7        rst     20h
005d 04        inc     b
005e 00        nop     
005f 00        nop     
0060 03        inc     bc
0061 d1        pop     de
0062 43        ld      b,e
0063 2d        dec     l
0064 3c        inc     a
0065 09        add     hl,bc
0066 00        nop     
0067 00        nop     
0068 03        inc     bc
0069 0d        dec     c
006a 4d        ld      c,l
006b 2d        dec     l
006c 9e        sbc     a,(hl)
006d 0e00      ld      c,00h
006f 00        nop     
0070 03        inc     bc
0071 ab        xor     e
0072 5b        ld      e,e
0073 2d        dec     l
0074 41        ld      b,c
0075 0c        inc     c
0076 00        nop     
0077 00        nop     
0078 03        inc     bc
0079 ec672d    call    pe,2d67h
007c 17        rla     
007d 0c        inc     c
007e 00        nop     
007f 00        nop     
0080 03        inc     bc
0081 03        inc     bc
0082 74        ld      (hl),h
0083 2d        dec     l
0084 3e11      ld      a,11h
0086 00        nop     
0087 00        nop     
0088 014185    ld      bc,8541h
008b 2d        dec     l
008c a3        and     e
008d 41        ld      b,c
008e 00        nop     
008f 00        nop     
0090 01e4c6    ld      bc,0c6e4h
0093 2d        dec     l
0094 cc1000    call    z,0010h
0097 00        nop     
0098 01b0d7    ld      bc,0d7b0h
009b 2d        dec     l
009c 1b        dec     de
009d 0b        dec     bc
009e 00        nop     
009f 00        nop     
00a0 01cbe2    ld      bc,0e2cbh
00a3 2d        dec     l
00a4 bf        cp      a
00a5 1a        ld      a,(de)
00a6 00        nop     
00a7 00        nop     
00a8 018afd    ld      bc,0fd8ah
00ab 2d        dec     l
00ac cf        rst     08h
00ad 05        dec     b
00ae 00        nop     
00af 00        nop     
00b0 015903    ld      bc,0359h
00b3 2e8f      ld      l,8fh
00b5 110000    ld      de,0000h
00b8 01e814    ld      bc,14e8h
00bb 2ec2      ld      l,0c2h
00bd 1a        ld      a,(de)
00be 00        nop     
00bf 00        nop     
00c0 01aa2f    ld      bc,2faah
00c3 2e34      ld      l,34h
00c5 1a        ld      a,(de)
00c6 00        nop     
00c7 00        nop     
00c8 04        inc     b
00c9 de49      sbc     a,49h
00cb 2ea3      ld      l,0a3h
00cd 2e00      ld      l,00h
00cf 00        nop     
00d0 03        inc     bc
00d1 81        add     a,c
00d2 78        ld      a,b
00d3 2ee1      ld      l,0e1h
00d5 1600      ld      d,00h
00d7 00        nop     
00d8 03        inc     bc
00d9 62        ld      h,d
00da 8f        adc     a,a
00db 2eeb      ld      l,0ebh
00dd 0f        rrca    
00de 00        nop     
00df 00        nop     
00e0 03        inc     bc
00e1 4d        ld      c,l
00e2 9f        sbc     a,a
00e3 2e49      ld      l,49h
00e5 19        add     hl,de
00e6 00        nop     
00e7 00        nop     
00e8 03        inc     bc
00e9 96        sub     (hl)
00ea b8        cp      b
00eb 2e5f      ld      l,5fh
00ed 04        inc     b
00ee 00        nop     
00ef 00        nop     
00f0 04        inc     b
00f1 f5        push    af
00f2 bc        cp      h
00f3 2ee0      ld      l,0e0h
00f5 25        dec     h
00f6 00        nop     
00f7 00        nop     
00f8 03        inc     bc
00f9 d5        push    de
00fa e22e88    jp      po,882eh
00fd 0e00      ld      c,00h
00ff 00        nop     
0100 03        inc     bc
0101 5d        ld      e,l
0102 f1        pop     af
0103 2e64      ld      l,64h
0105 0a        ld      a,(bc)
0106 00        nop     
0107 00        nop     
0108 03        inc     bc
0109 c1        pop     bc
010a fb        ei      
010b 2e5f      ld      l,5fh
010d 12        ld      (de),a
010e 00        nop     
010f 00        nop     
0110 03        inc     bc
0111 200e      jr      nz,0121h
0113 2f        cpl     
0114 0c        inc     c
0115 07        rlca    
0116 00        nop     
0117 00        nop     
0118 04        inc     b
0119 2c        inc     l
011a 15        dec     d
011b 2f        cpl     
011c c8        ret     z

011d 25        dec     h
011e 00        nop     
011f 00        nop     
0120 03        inc     bc
0121 f43a2f    call    p,2f3ah
0124 19        add     hl,de
0125 1800      jr      0127h
0127 00        nop     
0128 03        inc     bc
0129 0d        dec     c
012a 53        ld      d,e
012b 2f        cpl     
012c 70        ld      (hl),b
012d 0a        ld      a,(bc)
012e 00        nop     
012f 00        nop     
0130 03        inc     bc
0131 7d        ld      a,l
0132 5d        ld      e,l
0133 2f        cpl     
0134 8c        adc     a,h
0135 04        inc     b
0136 00        nop     
0137 00        nop     
0138 03        inc     bc
0139 09        add     hl,bc
013a 62        ld      h,d
013b 2f        cpl     
013c ca0500    jp      z,0005h
013f 00        nop     
0140 03        inc     bc
0141 d367      out     (67h),a
0143 2f        cpl     
0144 29        add     hl,hl
0145 13        inc     de
0146 00        nop     
0147 00        nop     
0148 03        inc     bc
0149 fc7a2f    call    m,2f7ah
014c d40900    call    nc,0009h
014f 00        nop     
0150 04        inc     b
0151 d0        ret     nc

0152 84        add     a,h
0153 2f        cpl     
0154 7a        ld      a,d
0155 2a0000    ld      hl,(0000h)
0158 03        inc     bc
0159 4a        ld      c,d
015a af        xor     a
015b 2f        cpl     
015c eb        ex      de,hl
015d 08        ex      af,af'
015e 00        nop     
015f 00        nop     
0160 03        inc     bc
0161 35        dec     (hl)
0162 b8        cp      b
0163 2f        cpl     
0164 d306      out     (06h),a
0166 00        nop     
0167 00        nop     
0168 03        inc     bc
0169 08        ex      af,af'
016a bf        cp      a
016b 2f        cpl     
016c 78        ld      a,b
016d 05        dec     b
016e 00        nop     
016f 00        nop     
0170 03        inc     bc
0171 80        add     a,b
0172 c42fd0    call    nz,0d02fh
0175 08        ex      af,af'
0176 00        nop     
0177 00        nop     
0178 03        inc     bc
0179 50        ld      d,b
017a cd2f1f    call    1f2fh
017d 1b        dec     de
017e 00        nop     
017f 00        nop     
0180 04        inc     b
0181 6f        ld      l,a
0182 e8        ret     pe

0183 2f        cpl     
0184 6c        ld      l,h
0185 34        inc     (hl)
0186 00        nop     
0187 00        nop     
0188 03        inc     bc
0189 db1c      in      a,(1ch)
018b 3061      jr      nc,01eeh
018d 0f        rrca    
018e 00        nop     
018f 00        nop     
0190 03        inc     bc
0191 3c        inc     a
0192 2c        inc     l
0193 307b      jr      nc,0210h
0195 03        inc     bc
0196 00        nop     
0197 00        nop     
0198 03        inc     bc
0199 b7        or      a
019a 2f        cpl     
019b 3020      jr      nc,01bdh
019d 05        dec     b
019e 00        nop     
019f 00        nop     
01a0 04        inc     b
01a1 d7        rst     10h
01a2 34        inc     (hl)
01a3 30a3      jr      nc,0148h
01a5 2e00      ld      l,00h
01a7 00        nop     
01a8 03        inc     bc
01a9 7a        ld      a,d
01aa 63        ld      h,e
01ab 30e3      jr      nc,0190h
01ad 08        ex      af,af'
01ae 00        nop     
01af 00        nop     
01b0 03        inc     bc
01b1 5d        ld      e,l
01b2 6c        ld      l,h
01b3 303a      jr      nc,01efh
01b5 0d        dec     c
01b6 00        nop     
01b7 00        nop     
01b8 03        inc     bc
01b9 97        sub     a
01ba 79        ld      a,c
01bb 309d      jr      nc,015ah
01bd 0d        dec     c
01be 00        nop     
01bf 00        nop     
01c0 03        inc     bc
01c1 34        inc     (hl)
01c2 87        add     a,a
01c3 30ca      jr      nc,018fh
01c5 09        add     hl,bc
01c6 00        nop     
01c7 00        nop     
01c8 04        inc     b
01c9 fe90      cp      90h
01cb 30a8      jr      nc,0175h
01cd 310000    ld      sp,0000h
01d0 03        inc     bc
01d1 a6        and     (hl)
01d2 c23018    jp      nz,1830h
01d5 1000      djnz    01d7h
01d7 00        nop     
01d8 03        inc     bc
01d9 be        cp      (hl)
01da d2306e    jp      nc,6e30h
01dd 02        ld      (bc),a
01de 00        nop     
01df 00        nop     
01e0 03        inc     bc
01e1 2c        inc     l
01e2 d5        push    de
01e3 3006      jr      nc,01ebh
01e5 24        inc     h
01e6 00        nop     
01e7 00        nop     
01e8 04        inc     b
01e9 32f930    ld      (30f9h),a
01ec 2026      jr      nz,0214h
01ee 00        nop     
01ef 00        nop     
01f0 03        inc     bc
01f1 52        ld      d,d
01f2 1f        rra     
01f3 316e16    ld      sp,166eh
01f6 00        nop     
01f7 00        nop     
01f8 03        inc     bc
01f9 c0        ret     nz

01fa 35        dec     (hl)
01fb 313408    ld      sp,0834h
01fe 00        nop     
01ff 00        nop     
0200 03        inc     bc
0201 f43d31    call    p,313dh
0204 83        add     a,e
0205 09        add     hl,bc
0206 00        nop     
0207 00        nop     
0208 03        inc     bc
0209 77        ld      (hl),a
020a 47        ld      b,a
020b 31c105    ld      sp,05c1h
020e 00        nop     
020f 00        nop     
0210 03        inc     bc
0211 384d      jr      c,0260h
0213 31bf04    ld      sp,04bfh
0216 00        nop     
0217 00        nop     
0218 03        inc     bc
0219 f7        rst     30h
021a 51        ld      d,c
021b 31b013    ld      sp,13b0h
021e 00        nop     
021f 00        nop     
0220 04        inc     b
0221 a7        and     a
0222 65        ld      h,l
0223 31802d    ld      sp,2d80h
0226 00        nop     
0227 00        nop     
0228 03        inc     bc
0229 27        daa     
022a 93        sub     e
022b 31e109    ld      sp,09e1h
022e 00        nop     
022f 00        nop     
0230 03        inc     bc
0231 08        ex      af,af'
0232 9d        sbc     a,l
0233 316d0f    ld      sp,0f6dh
0236 00        nop     
0237 00        nop     
0238 04        inc     b
0239 75        ld      (hl),l
023a ac        xor     h
023b 31c037    ld      sp,37c0h
023e 00        nop     
023f 00        nop     
0240 03        inc     bc
0241 35        dec     (hl)
0242 e431b2    call    po,0b231h
0245 110000    ld      de,0000h
0248 03        inc     bc
0249 e7        rst     20h
024a f5        push    af
024b 31ca10    ld      sp,10cah
024e 00        nop     
024f 00        nop     
0250 03        inc     bc
0251 b1        or      c
0252 0632      ld      b,32h
0254 9a        sbc     a,d
0255 09        add     hl,bc
0256 00        nop     
0257 00        nop     
0258 03        inc     bc
0259 4b        ld      c,e
025a 1032      djnz    028eh
025c 8f        adc     a,a
025d 14        inc     d
025e 00        nop     
025f 00        nop     
0260 03        inc     bc
0261 da2432    jp      c,3224h
0264 5d        ld      e,l
0265 110000    ld      de,0000h
0268 04        inc     b
0269 37        scf     
026a 3632      ld      (hl),32h
026c 8b        adc     a,e
026d 310000    ld      sp,0000h
0270 03        inc     bc
0271 c26732    jp      nz,3267h
0274 be        cp      (hl)
0275 0a        ld      a,(bc)
0276 00        nop     
0277 00        nop     
0278 03        inc     bc
0279 80        add     a,b
027a 72        ld      (hl),d
027b 326c15    ld      (156ch),a
027e 00        nop     
027f 00        nop     
0280 03        inc     bc
0281 ec8732    call    pe,3287h
0284 e9        jp      (hl)
0285 110000    ld      de,0000h
0288 03        inc     bc
0289 d5        push    de
028a 99        sbc     a,c
028b 32ca05    ld      (05cah),a
028e 00        nop     
028f 00        nop     
0290 03        inc     bc
0291 9f        sbc     a,a
0292 9f        sbc     a,a
0293 32aa0e    ld      (0eaah),a
0296 00        nop     
0297 00        nop     
0298 03        inc     bc
0299 49        ld      c,c
029a ae        xor     (hl)
029b 32a014    ld      (14a0h),a
029e 00        nop     
029f 00        nop     
02a0 04        inc     b
02a1 e9        jp      (hl)
02a2 c232cd    jp      nz,0cd32h
02a5 2600      ld      h,00h
02a7 00        nop     
02a8 03        inc     bc
02a9 b6        or      (hl)
02aa e9        jp      (hl)
02ab 32700d    ld      (0d70h),a
02ae 00        nop     
02af 00        nop     
02b0 03        inc     bc
02b1 26f7      ld      h,0f7h
02b3 32a707    ld      (07a7h),a
02b6 00        nop     
02b7 00        nop     
02b8 03        inc     bc
02b9 cdfe32    call    32feh
02bc bf        cp      a
02bd 09        add     hl,bc
02be 00        nop     
02bf 00        nop     
02c0 03        inc     bc
02c1 8c        adc     a,h
02c2 08        ex      af,af'
02c3 33        inc     sp
02c4 1c        inc     e
02c5 0c        inc     c
02c6 00        nop     
02c7 00        nop     
02c8 04        inc     b
02c9 a8        xor     b
02ca 14        inc     d
02cb 33        inc     sp
02cc c5        push    bc
02cd 2d        dec     l
02ce 00        nop     
02cf 00        nop     
02d0 03        inc     bc
02d1 6d        ld      l,l
02d2 42        ld      b,d
02d3 33        inc     sp
02d4 50        ld      d,b
02d5 14        inc     d
02d6 00        nop     
02d7 00        nop     
02d8 03        inc     bc
02d9 bd        cp      l
02da 56        ld      d,(hl)
02db 33        inc     sp
02dc 96        sub     (hl)
02dd 08        ex      af,af'
02de 00        nop     
02df 00        nop     
02e0 03        inc     bc
02e1 53        ld      d,e
02e2 5f        ld      e,a
02e3 33        inc     sp
02e4 2c        inc     l
02e5 0600      ld      b,00h
02e7 00        nop     
02e8 04        inc     b
02e9 7f        ld      a,a
02ea 65        ld      h,l
02eb 33        inc     sp
02ec 3a2c00    ld      a,(002ch)
02ef 00        nop     
02f0 03        inc     bc
02f1 b9        cp      c
02f2 91        sub     c
02f3 33        inc     sp
02f4 94        sub     h
02f5 1000      djnz    02f7h
02f7 00        nop     
02f8 03        inc     bc
02f9 4d        ld      c,l
02fa a2        and     d
02fb 33        inc     sp
02fc 4f        ld      c,a
02fd 1c        inc     e
02fe 00        nop     
02ff 00        nop     
0300 03        inc     bc
0301 9c        sbc     a,h
0302 be        cp      (hl)
0303 33        inc     sp
0304 2c        inc     l
0305 09        add     hl,bc
0306 00        nop     
0307 00        nop     
0308 03        inc     bc
0309 c8        ret     z

030a c7        rst     00h
030b 33        inc     sp
030c ea0800    jp      pe,0008h
030f 00        nop     
0310 03        inc     bc
0311 b2        or      d
0312 d0        ret     nc

0313 33        inc     sp
0314 dd0b      dec     bc
0316 00        nop     
0317 00        nop     
0318 03        inc     bc
0319 8f        adc     a,a
031a dc3308    call    c,0833h
031d 04        inc     b
031e 00        nop     
031f 00        nop     
0320 03        inc     bc
0321 97        sub     a
0322 e0        ret     po

0323 33        inc     sp
0324 58        ld      e,b
0325 19        add     hl,de
0326 00        nop     
0327 00        nop     
0328 04        inc     b
0329 ef        rst     28h
032a f9        ld      sp,hl
032b 33        inc     sp
032c c0        ret     nz

032d 27        daa     
032e 00        nop     
032f 00        nop     
0330 03        inc     bc
0331 af        xor     a
0332 213453    ld      hl,5334h
0335 13        inc     de
0336 00        nop     
0337 00        nop     
0338 03        inc     bc
0339 02        ld      (bc),a
033a 35        dec     (hl)
033b 34        inc     (hl)
033c 66        ld      h,(hl)
033d 03        inc     bc
033e 00        nop     
033f 00        nop     
0340 03        inc     bc
0341 68        ld      l,b
0342 3834      jr      c,0378h
0344 05        dec     b
0345 1a        ld      a,(de)
0346 00        nop     
0347 00        nop     
0348 03        inc     bc
0349 6d        ld      l,l
034a 52        ld      d,d
034b 34        inc     (hl)
034c 70        ld      (hl),b
034d 04        inc     b
034e 00        nop     
034f 00        nop     
0350 03        inc     bc
0351 dd5634    ld      d,(ix+34h)
0354 df        rst     18h
0355 19        add     hl,de
0356 00        nop     
0357 00        nop     
0358 04        inc     b
0359 bc        cp      h
035a 70        ld      (hl),b
035b 34        inc     (hl)
035c 60        ld      h,b
035d 29        add     hl,hl
035e 00        nop     
035f 00        nop     
0360 03        inc     bc
0361 1c        inc     e
0362 9a        sbc     a,d
0363 34        inc     (hl)
0364 68        ld      l,b
0365 110000    ld      de,0000h
0368 03        inc     bc
0369 84        add     a,h
036a ab        xor     e
036b 34        inc     (hl)
036c a1        and     c
036d 0f        rrca    
036e 00        nop     
036f 00        nop     
0370 03        inc     bc
0371 25        dec     h
0372 bb        cp      e
0373 34        inc     (hl)
0374 c9        ret     

0375 07        rlca    
0376 00        nop     
0377 00        nop     
0378 03        inc     bc
0379 eec2      xor     0c2h
037b 34        inc     (hl)
037c 3d        dec     a
037d 04        inc     b
037e 00        nop     
037f 00        nop     
0380 03        inc     bc
0381 2b        dec     hl
0382 c7        rst     00h
0383 34        inc     (hl)
0384 91        sub     c
0385 03        inc     bc
0386 00        nop     
0387 00        nop     
0388 03        inc     bc
0389 bc        cp      h
038a ca342d    jp      z,2d34h
038d 1f        rra     
038e 00        nop     
038f 00        nop     
0390 03        inc     bc
0391 e9        jp      (hl)
0392 e9        jp      (hl)
0393 34        inc     (hl)
0394 23        inc     hl
0395 3c        inc     a
0396 00        nop     
0397 00        nop     
0398 03        inc     bc
0399 0c        inc     c
039a 2635      ld      h,35h
039c 6e        ld      l,(hl)
039d 1f        rra     
039e 00        nop     
039f 00        nop     
03a0 03        inc     bc
03a1 7a        ld      a,d
03a2 45        ld      b,l
03a3 35        dec     (hl)
03a4 220400    ld      (0004h),hl
03a7 00        nop     
03a8 03        inc     bc
03a9 9c        sbc     a,h
03aa 49        ld      c,c
03ab 35        dec     (hl)
03ac f21000    jp      p,0010h
03af 00        nop     
03b0 03        inc     bc
03b1 8e        adc     a,(hl)
03b2 5a        ld      e,d
03b3 35        dec     (hl)
03b4 8f        adc     a,a
03b5 13        inc     de
03b6 00        nop     
03b7 00        nop     
03b8 03        inc     bc
03b9 1d        dec     e
03ba 6e        ld      l,(hl)
03bb 35        dec     (hl)
03bc 64        ld      h,h
03bd 0d        dec     c
03be 00        nop     
03bf 00        nop     
03c0 03        inc     bc
03c1 81        add     a,c
03c2 7b        ld      a,e
03c3 35        dec     (hl)
03c4 35        dec     (hl)
03c5 0c        inc     c
03c6 00        nop     
03c7 00        nop     
03c8 03        inc     bc
03c9 b6        or      (hl)
03ca 87        add     a,a
03cb 35        dec     (hl)
03cc 210d00    ld      hl,000dh
03cf 00        nop     
03d0 03        inc     bc
03d1 d7        rst     10h
03d2 94        sub     h
03d3 35        dec     (hl)
03d4 62        ld      h,d
03d5 110000    ld      de,0000h
03d8 03        inc     bc
03d9 39        add     hl,sp
03da a6        and     (hl)
03db 35        dec     (hl)
03dc 8d        adc     a,l
03dd 0d        dec     c
03de 00        nop     
03df 00        nop     
03e0 03        inc     bc
03e1 c6b3      add     a,0b3h
03e3 35        dec     (hl)
03e4 6b        ld      l,e
03e5 0f        rrca    
03e6 00        nop     
03e7 00        nop     
03e8 03        inc     bc
03e9 31c335    ld      sp,35c3h
03ec 380a      jr      c,03f8h
03ee 00        nop     
03ef 00        nop     
03f0 03        inc     bc
03f1 69        ld      l,c
03f2 cd35c2    call    0c235h
03f5 0d        dec     c
03f6 00        nop     
03f7 00        nop     
03f8 03        inc     bc
03f9 2b        dec     hl
03fa db35      in      a,(35h)
03fc df        rst     18h
03fd 0f        rrca    
03fe 00        nop     
03ff 00        nop     
0400 03        inc     bc
0401 0a        ld      a,(bc)
0402 eb        ex      de,hl
0403 35        dec     (hl)
0404 23        inc     hl
0405 12        ld      (de),a
0406 00        nop     
0407 00        nop     
0408 03        inc     bc
0409 2d        dec     l
040a fd3595    dec     (iy-6bh)
040d 1a        ld      a,(de)
040e 00        nop     
040f 00        nop     
0410 04        inc     b
0411 c21736    jp      nz,3617h
0414 49        ld      c,c
0415 0b        dec     bc
0416 00        nop     
0417 00        nop     
0418 04        inc     b
0419 0b        dec     bc
041a 23        inc     hl
041b 3618      ld      (hl),18h
041d 0d        dec     c
041e 00        nop     
041f 00        nop     
0420 04        inc     b
0421 23        inc     hl
0422 3036      jr      nc,045ah
0424 99        sbc     a,c
0425 09        add     hl,bc
0426 00        nop     
0427 00        nop     
0428 04        inc     b
0429 bc        cp      h
042a 39        add     hl,sp
042b 3614      ld      (hl),14h
042d 0f        rrca    
042e 00        nop     
042f 00        nop     
0430 04        inc     b
0431 d0        ret     nc

0432 48        ld      c,b
0433 3661      ld      (hl),61h
0435 110000    ld      de,0000h
0438 04        inc     b
0439 315a36    ld      sp,365ah
043c 3a0b00    ld      a,(000bh)
043f 00        nop     
0440 04        inc     b
0441 6b        ld      l,e
0442 65        ld      h,l
0443 36ab      ld      (hl),0abh
0445 0c        inc     c
0446 00        nop     
0447 00        nop     
0448 04        inc     b
0449 1672      ld      d,72h
044b 3625      ld      (hl),25h
044d 0b        dec     bc
044e 00        nop     
044f 00        nop     
0450 04        inc     b
0451 3b        dec     sp
0452 7d        ld      a,l
0453 3680      ld      (hl),80h
0455 0a        ld      a,(bc)
0456 00        nop     
0457 00        nop     
0458 04        inc     b
0459 bb        cp      e
045a 87        add     a,a
045b 3660      ld      (hl),60h
045d 0e00      ld      c,00h
045f 00        nop     
0460 04        inc     b
0461 1b        dec     de
0462 96        sub     (hl)
0463 36da      ld      (hl),0dah
0465 0e00      ld      c,00h
0467 00        nop     
0468 04        inc     b
0469 f5        push    af
046a a4        and     h
046b 363d      ld      (hl),3dh
046d 0b        dec     bc
046e 00        nop     
046f 00        nop     
0470 04        inc     b
0471 32b036    ld      (36b0h),a
0474 e60d      and     0dh
0476 00        nop     
0477 00        nop     
0478 04        inc     b
0479 18be      jr      0439h
047b 36fc      ld      (hl),0fch
047d 0d        dec     c
047e 00        nop     
047f 00        nop     
0480 04        inc     b
0481 14        inc     d
0482 cc3696    call    z,9636h
0485 0f        rrca    
0486 00        nop     
0487 00        nop     
0488 04        inc     b
0489 aa        xor     d
048a db36      in      a,(36h)
048c 3a1000    ld      a,(0010h)
048f 00        nop     
0490 04        inc     b
0491 e4eb36    call    po,36ebh
0494 25        dec     h
0495 0e00      ld      c,00h
0497 00        nop     
0498 03        inc     bc
0499 09        add     hl,bc
049a fa3639    jp      m,3936h
049d 2600      ld      h,00h
049f 00        nop     
04a0 03        inc     bc
04a1 42        ld      b,d
04a2 2037      jr      nz,04dbh
04a4 fc0b00    call    m,000bh
04a7 00        nop     
04a8 03        inc     bc
04a9 3e2c      ld      a,2ch
04ab 37        scf     
04ac ec0700    call    pe,0007h
04af 00        nop     
04b0 03        inc     bc
04b1 2a3437    ld      hl,(3734h)
04b4 e9        jp      (hl)
04b5 09        add     hl,bc
04b6 00        nop     
04b7 00        nop     
04b8 04        inc     b
04b9 13        inc     de
04ba 3e37      ld      a,37h
04bc 55        ld      d,l
04bd 0a        ld      a,(bc)
04be 00        nop     
04bf 00        nop     
04c0 04        inc     b
04c1 68        ld      l,b
04c2 48        ld      c,b
04c3 37        scf     
04c4 eb        ex      de,hl
04c5 0a        ld      a,(bc)
04c6 00        nop     
04c7 00        nop     
04c8 04        inc     b
04c9 53        ld      d,e
04ca 53        ld      d,e
04cb 37        scf     
04cc 5c        ld      e,h
04cd 0b        dec     bc
04ce 00        nop     
04cf 00        nop     
04d0 04        inc     b
04d1 af        xor     a
04d2 5e        ld      e,(hl)
04d3 37        scf     
04d4 68        ld      l,b
04d5 0a        ld      a,(bc)
04d6 00        nop     
04d7 00        nop     
04d8 03        inc     bc
04d9 17        rla     
04da 69        ld      l,c
04db 37        scf     
04dc 48        ld      c,b
04dd 0c        inc     c
04de 00        nop     
04df 00        nop     
04e0 03        inc     bc
04e1 5f        ld      e,a
04e2 75        ld      (hl),l
04e3 37        scf     
04e4 eb        ex      de,hl
04e5 0a        ld      a,(bc)
04e6 00        nop     
04e7 00        nop     
04e8 03        inc     bc
04e9 4a        ld      c,d
04ea 80        add     a,b
04eb 37        scf     
04ec 72        ld      (hl),d
04ed 0b        dec     bc
04ee 00        nop     
04ef 00        nop     
04f0 03        inc     bc
04f1 bc        cp      h
04f2 8b        adc     a,e
04f3 37        scf     
04f4 8b        adc     a,e
04f5 0b        dec     bc
04f6 00        nop     
04f7 00        nop     
04f8 03        inc     bc
04f9 47        ld      b,a
04fa 97        sub     a
04fb 37        scf     
04fc d7        rst     10h
04fd 0c        inc     c
04fe 00        nop     
04ff 00        nop     
0500 03        inc     bc
0501 1ea4      ld      e,0a4h
0503 37        scf     
0504 55        ld      d,l
0505 08        ex      af,af'
0506 00        nop     
0507 00        nop     
0508 03        inc     bc
0509 73        ld      (hl),e
050a ac        xor     h
050b 37        scf     
050c 3b        dec     sp
050d 0c        inc     c
050e 00        nop     
050f 00        nop     
0510 03        inc     bc
0511 ae        xor     (hl)
0512 b8        cp      b
0513 37        scf     
0514 fd08      ex      af,af'
0516 00        nop     
0517 00        nop     
0518 03        inc     bc
0519 ab        xor     e
051a c1        pop     bc
051b 37        scf     
051c 1a        ld      a,(de)
051d 110000    ld      de,0000h
0520 10c5      djnz    04e7h
0522 d23727    jp      nc,2737h
0525 2000      jr      nz,0527h
0527 00        nop     
0528 00        nop     
