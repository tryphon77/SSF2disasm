; ROM Header	; 0x-1
hSystemType	dc.b	"SEGA GENESIS    "	; 0x100
hCopyrightInfo	dc.b	"(C)T-12 1994.JUN"	; 0x110
hGameTitle	dc.b	"SUPER STREET FIGHTER2 The New Challengers       "	; 0x120
hAlternateTitle	dc.b	"SUPER STREET FIGHTER2 The New Challengers       "	; 0x150
hSerialNumber	dc.b	"GM T-12056 -00"	; 0x180
hChecksum	dc.w	$e017	; 0x18e
hDeviceSupport	dc.b	"J6              "	; 0x190
hRomStart	dc.l	$0	; 0x1a0
hRomEnd	dc.l	$3fffff	; 0x1a4
hRamStart	dc.l	$ff0000	; 0x1a8
hRamEnd	dc.l	$ffffff	; 0x1ac
hExtraMemory	dc.b	"            "	; 0x1b0
hModemSupport	dc.b	"            "	; 0x1bc
hReserved1	dc.b	"                                        "	; 0x1c8
hRegion	dc.b	"U  "	; 0x1f0
hReserved2	dc.b	"             "	; 0x1f3