;*********************************************************
;* GenesisVDPBenchmark.asm
;*
;* Program description:
;*   This program tests the performance of the Sega
;*   Genesis (Gen) Video Display Processor (VDP)
;*   using the following algorithm:
;*     1) Load and initalize the Gen settings.
;*     2) Display 32x28 background tiles 4,608 times.
;*     4) Turn off the screen.
;*     5) Loop until Gen is reset or turned off.
;*
;* Update History:
;*   Oct 09 2022 - First version. Hagop Mouradian
;*********************************************************

; Local constants.
VDPController       equ $00C00004
VDPBuffer           equ $00C00000
VDPVRAMWrite        equ 0x40000000
VDPCRAMWrite        equ 0xC0000000
VRAMTileAddress     equ 0x0000
GenVersionAddress   equ 0x00A10001
TMSSAddress         equ 0x00A14000
TMSSSignature       equ 'SEGA'
ByteSizeWord        equ 2
ByteSizeLong        equ 4
ByteSizePalette     equ 32
ByteSizePaletteWord equ ByteSizePalette / ByteSizeWord
ByteSizeTile        equ 20
ByteSizeTileLong    equ ByteSizeTile / ByteSizeLong
NUM_xC0000003       equ $C0000003
NUM_x8F00           equ $8F00
NUM_254             equ $00FE
NUM_127             equ $007F
NUM_35              equ $0023
NUM_31              equ $001F
NUM_27              equ $001B
NUM_23              equ $0017
BGTileCount         equ $0020

; Initialize game ROM header.
InitializeROMHeader:
	dc.l $00FFFFFE
	dc.l StartProgram
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.l HandlerEmpty
	dc.b "Sega Genesis    "
	dc.b "Hagop Mouradian "
	dc.b "GenesisCPUBenchTest                               "
	dc.b "GenesisCPUBenchTest                               "
	dc.b "2022/10/02    "
	dc.w $0000
	dc.b "J               "
	dc.l $00000000
	dc.l HandlerEmpty
	dc.l $00FF0000
	dc.l $00FFFFFF
	dc.l $00000000
	dc.l $00000000
	dc.l $00000000
	dc.l $00000000
	dc.l $00000000
	dc.l $00000000
	dc.b "                                        "
	dc.b "JUE             "
	
VDPRegisters:
	dc.b 0x14 ; 1
	dc.b 0x74 ; 2
	dc.b 0x30 ; 3
	dc.b 0x00 ; 4
	dc.b 0x07 ; 5
	dc.b 0x78 ; 6
	dc.b 0x00 ; 7
	dc.b 0x00 ; 8
	dc.b 0x00 ; 9
	dc.b 0x00 ; 10
	dc.b 0x08 ; 11
	dc.b 0x00 ; 12
	dc.b 0x00 ; 13
	dc.b 0x3F ; 14
	dc.b 0x00 ; 15
	dc.b 0x02 ; 16
	dc.b 0x00 ; 17
	dc.b 0x00 ; 18
	dc.b 0x00 ; 19
	dc.b 0xFF ; 20
	dc.b 0xFF ; 21
	dc.b 0x00 ; 22
	dc.b 0x00 ; 23
	dc.b 0x80 ; 24

; Colour palette
Palette:
	;     0000BBB0GGG0RRR0
    	dc.w %0000000000000000 ; 0
	dc.w %0000000000001110 ; 1
    	dc.w %0000000011100000 ; 2
    	dc.w %0000111000000000 ; 3
    	dc.w %0000011000100010 ; 4
    	dc.w %0000001001100000 ; 5
    	dc.w %0000100000010000 ; 6
    	dc.w %0000111011100010 ; 7
    	dc.w %0000110000001100 ; 8
    	dc.w %0000011000000010 ; 9
    	dc.w %0000000011101100 ; 10
    	dc.w %0000111000000100 ; 11
    	dc.w %0000010001000100 ; 12
    	dc.w %0000101000000000 ; 13
    	dc.w %0000000000100000 ; 14
    	dc.w %0000111011100000 ; 15

; BG tiles
CharacterSpace:
	;      01234567
	dc.l 0x00000000 ; 0
	dc.l 0x00000000 ; 1
	dc.l 0x00000000 ; 2
	dc.l 0x00000000 ; 3
	dc.l 0x00000000 ; 4
	dc.l 0x00000000 ; 5
	dc.l 0x00000000 ; 6
	dc.l 0x00000000 ; 7

BGTile1:
	;      01234567
	dc.l 0x11111111 ; 0
	dc.l 0x11111111 ; 1
	dc.l 0x11111111 ; 2
	dc.l 0x11111111 ; 3
	dc.l 0x11111111 ; 4
	dc.l 0x11111111 ; 5
	dc.l 0x11111111 ; 6
	dc.l 0x11111111 ; 7

BGTile2:
	;      01234567
	dc.l 0x22222222 ; 0
	dc.l 0x22222222 ; 1
	dc.l 0x22222222 ; 2
	dc.l 0x22222222 ; 3
	dc.l 0x22222222 ; 4
	dc.l 0x22222222 ; 5
	dc.l 0x22222222 ; 6
	dc.l 0x22222222 ; 7

BGTile3:
	;      01234567
	dc.l 0x33333333 ; 0
	dc.l 0x33333333 ; 1
	dc.l 0x33333333 ; 2
	dc.l 0x33333333 ; 3
	dc.l 0x33333333 ; 4
	dc.l 0x33333333 ; 5
	dc.l 0x33333333 ; 6
	dc.l 0x33333333 ; 7

BGTile4:
	;      01234567
	dc.l 0x44444444 ; 0
	dc.l 0x44444444 ; 1
	dc.l 0x44444444 ; 2
	dc.l 0x44444444 ; 3
	dc.l 0x44444444 ; 4
	dc.l 0x44444444 ; 5
	dc.l 0x44444444 ; 6
	dc.l 0x44444444 ; 7

BGTile5:
	;      01234567
	dc.l 0x55555555 ; 0
	dc.l 0x55555555 ; 1
	dc.l 0x55555555 ; 2
	dc.l 0x55555555 ; 3
	dc.l 0x55555555 ; 4
	dc.l 0x55555555 ; 5
	dc.l 0x55555555 ; 6
	dc.l 0x55555555 ; 7

BGTile6:
	;      01234567
	dc.l 0x66666666 ; 0
	dc.l 0x66666666 ; 1
	dc.l 0x66666666 ; 2
	dc.l 0x66666666 ; 3
	dc.l 0x66666666 ; 4
	dc.l 0x66666666 ; 5
	dc.l 0x66666666 ; 6
	dc.l 0x66666666 ; 7

BGTile7:
	;      01234567
	dc.l 0x77777777 ; 0
	dc.l 0x77777777 ; 1
	dc.l 0x77777777 ; 2
	dc.l 0x77777777 ; 3
	dc.l 0x77777777 ; 4
	dc.l 0x77777777 ; 5
	dc.l 0x77777777 ; 6
	dc.l 0x77777777 ; 7

BGTile8:
	;      01234567
	dc.l 0x88888888 ; 0
	dc.l 0x88888888 ; 1
	dc.l 0x88888888 ; 2
	dc.l 0x88888888 ; 3
	dc.l 0x88888888 ; 4
	dc.l 0x88888888 ; 5
	dc.l 0x88888888 ; 6
	dc.l 0x88888888 ; 7

BGTile9:
	;      01234567
	dc.l 0x99999999 ; 0
	dc.l 0x99999999 ; 1
	dc.l 0x99999999 ; 2
	dc.l 0x99999999 ; 3
	dc.l 0x99999999 ; 4
	dc.l 0x99999999 ; 5
	dc.l 0x99999999 ; 6
	dc.l 0x99999999 ; 7

BGTile10:
	;      01234567
	dc.l 0xAAAAAAAA ; 0
	dc.l 0xAAAAAAAA ; 1
	dc.l 0xAAAAAAAA ; 2
	dc.l 0xAAAAAAAA ; 3
	dc.l 0xAAAAAAAA ; 4
	dc.l 0xAAAAAAAA ; 5
	dc.l 0xAAAAAAAA ; 6
	dc.l 0xAAAAAAAA ; 7

BGTile11:
	;      01234567
	dc.l 0xBBBBBBBB ; 0
	dc.l 0xBBBBBBBB ; 1
	dc.l 0xBBBBBBBB ; 2
	dc.l 0xBBBBBBBB ; 3
	dc.l 0xBBBBBBBB ; 4
	dc.l 0xBBBBBBBB ; 5
	dc.l 0xBBBBBBBB ; 6
	dc.l 0xBBBBBBBB ; 7

BGTile12:
	;      01234567
	dc.l 0xCCCCCCCC ; 0
	dc.l 0xCCCCCCCC ; 1
	dc.l 0xCCCCCCCC ; 2
	dc.l 0xCCCCCCCC ; 3
	dc.l 0xCCCCCCCC ; 4
	dc.l 0xCCCCCCCC ; 5
	dc.l 0xCCCCCCCC ; 6
	dc.l 0xCCCCCCCC ; 7

BGTile13:
	;      01234567
	dc.l 0xDDDDDDDD ; 0
	dc.l 0xDDDDDDDD ; 1
	dc.l 0xDDDDDDDD ; 2
	dc.l 0xDDDDDDDD ; 3
	dc.l 0xDDDDDDDD ; 4
	dc.l 0xDDDDDDDD ; 5
	dc.l 0xDDDDDDDD ; 6
	dc.l 0xDDDDDDDD ; 7

BGTile14:
	;      01234567
	dc.l 0xEEEEEEEE ; 0
	dc.l 0xEEEEEEEE ; 1
	dc.l 0xEEEEEEEE ; 2
	dc.l 0xEEEEEEEE ; 3
	dc.l 0xEEEEEEEE ; 4
	dc.l 0xEEEEEEEE ; 5
	dc.l 0xEEEEEEEE ; 6
	dc.l 0xEEEEEEEE ; 7

BGTile15:
	;      01234567
	dc.l 0xFFFFFFFF ; 0
	dc.l 0xFFFFFFFF ; 1
	dc.l 0xFFFFFFFF ; 2
	dc.l 0xFFFFFFFF ; 3
	dc.l 0xFFFFFFFF ; 4
	dc.l 0xFFFFFFFF ; 5
	dc.l 0xFFFFFFFF ; 6
	dc.l 0xFFFFFFFF ; 7

BGTile16:
	;      01234567
	dc.l 0x11111111 ; 0
	dc.l 0x11111111 ; 1
	dc.l 0x11111111 ; 2
	dc.l 0x11111111 ; 3
	dc.l 0x11111111 ; 4
	dc.l 0x11111111 ; 5
	dc.l 0x11111111 ; 6
	dc.l 0x11111111 ; 7

BGTile17:
	;      01234567
	dc.l 0x22222222 ; 0
	dc.l 0x22222222 ; 1
	dc.l 0x22222222 ; 2
	dc.l 0x22222222 ; 3
	dc.l 0x22222222 ; 4
	dc.l 0x22222222 ; 5
	dc.l 0x22222222 ; 6
	dc.l 0x22222222 ; 7

BGTile18:
	;      01234567
	dc.l 0x33333333 ; 0
	dc.l 0x33333333 ; 1
	dc.l 0x33333333 ; 2
	dc.l 0x33333333 ; 3
	dc.l 0x33333333 ; 4
	dc.l 0x33333333 ; 5
	dc.l 0x33333333 ; 6
	dc.l 0x33333333 ; 7

BGTile19:
	;      01234567
	dc.l 0x44444444 ; 0
	dc.l 0x44444444 ; 1
	dc.l 0x44444444 ; 2
	dc.l 0x44444444 ; 3
	dc.l 0x44444444 ; 4
	dc.l 0x44444444 ; 5
	dc.l 0x44444444 ; 6
	dc.l 0x44444444 ; 7

BGTile20:
	;      01234567
	dc.l 0x55555555 ; 0
	dc.l 0x55555555 ; 1
	dc.l 0x55555555 ; 2
	dc.l 0x55555555 ; 3
	dc.l 0x55555555 ; 4
	dc.l 0x55555555 ; 5
	dc.l 0x55555555 ; 6
	dc.l 0x55555555 ; 7

BGTile21:
	;      01234567
	dc.l 0x66666666 ; 0
	dc.l 0x66666666 ; 1
	dc.l 0x66666666 ; 2
	dc.l 0x66666666 ; 3
	dc.l 0x66666666 ; 4
	dc.l 0x66666666 ; 5
	dc.l 0x66666666 ; 6
	dc.l 0x66666666 ; 7

BGTile22:
	;      01234567
	dc.l 0x77777777 ; 0
	dc.l 0x77777777 ; 1
	dc.l 0x77777777 ; 2
	dc.l 0x77777777 ; 3
	dc.l 0x77777777 ; 4
	dc.l 0x77777777 ; 5
	dc.l 0x77777777 ; 6
	dc.l 0x77777777 ; 7

BGTile23:
	;      01234567
	dc.l 0x88888888 ; 0
	dc.l 0x88888888 ; 1
	dc.l 0x88888888 ; 2
	dc.l 0x88888888 ; 3
	dc.l 0x88888888 ; 4
	dc.l 0x88888888 ; 5
	dc.l 0x88888888 ; 6
	dc.l 0x88888888 ; 7

BGTile24:
	;      01234567
	dc.l 0x99999999 ; 0
	dc.l 0x99999999 ; 1
	dc.l 0x99999999 ; 2
	dc.l 0x99999999 ; 3
	dc.l 0x99999999 ; 4
	dc.l 0x99999999 ; 5
	dc.l 0x99999999 ; 6
	dc.l 0x99999999 ; 7

BGTile25:
	;      01234567
	dc.l 0xAAAAAAAA ; 0
	dc.l 0xAAAAAAAA ; 1
	dc.l 0xAAAAAAAA ; 2
	dc.l 0xAAAAAAAA ; 3
	dc.l 0xAAAAAAAA ; 4
	dc.l 0xAAAAAAAA ; 5
	dc.l 0xAAAAAAAA ; 6
	dc.l 0xAAAAAAAA ; 7

BGTile26:
	;      01234567
	dc.l 0xBBBBBBBB ; 0
	dc.l 0xBBBBBBBB ; 1
	dc.l 0xBBBBBBBB ; 2
	dc.l 0xBBBBBBBB ; 3
	dc.l 0xBBBBBBBB ; 4
	dc.l 0xBBBBBBBB ; 5
	dc.l 0xBBBBBBBB ; 6
	dc.l 0xBBBBBBBB ; 7

BGTile27:
	;      01234567
	dc.l 0xCCCCCCCC ; 0
	dc.l 0xCCCCCCCC ; 1
	dc.l 0xCCCCCCCC ; 2
	dc.l 0xCCCCCCCC ; 3
	dc.l 0xCCCCCCCC ; 4
	dc.l 0xCCCCCCCC ; 5
	dc.l 0xCCCCCCCC ; 6
	dc.l 0xCCCCCCCC ; 7

BGTile28:
	;      01234567
	dc.l 0x88888888 ; 0
	dc.l 0x88888888 ; 1
	dc.l 0x88888888 ; 2
	dc.l 0x88888888 ; 3
	dc.l 0x88888888 ; 4
	dc.l 0x88888888 ; 5
	dc.l 0x88888888 ; 6
	dc.l 0x88888888 ; 7

BGTile29:
	;      01234567
	dc.l 0x55555555 ; 0
	dc.l 0x55555555 ; 1
	dc.l 0x55555555 ; 2
	dc.l 0x55555555 ; 3
	dc.l 0x55555555 ; 4
	dc.l 0x55555555 ; 5
	dc.l 0x55555555 ; 6
	dc.l 0x55555555 ; 7

BGTile30:
	;      01234567
	dc.l 0x11111111 ; 0
	dc.l 0x11111111 ; 1
	dc.l 0x11111111 ; 2
	dc.l 0x11111111 ; 3
	dc.l 0x11111111 ; 4
	dc.l 0x11111111 ; 5
	dc.l 0x11111111 ; 6
	dc.l 0x11111111 ; 7

BGTile31:
	;      01234567
	dc.l 0xAAAAAAAA ; 0
	dc.l 0xAAAAAAAA ; 1
	dc.l 0xAAAAAAAA ; 2
	dc.l 0xAAAAAAAA ; 3
	dc.l 0xAAAAAAAA ; 4
	dc.l 0xAAAAAAAA ; 5
	dc.l 0xAAAAAAAA ; 6
	dc.l 0xAAAAAAAA ; 7

;**************************************************************
;*
;* SetVRAMWrite Macro
;*
;* Description:
;*   Sets the next VRAM write address.
;*
;**************************************************************
SetVRAMWrite: macro addr
	 move.l #(VDPVRAMWrite)|((\addr)&$3FFF)<<16|(\addr)>>14,VDPController
	endm

;**************************************************************
;*
;* SetCRAMWrite Macro
;*
;* Description:
;*   Set the next CRAM write address.
;*
;**************************************************************
SetCRAMWrite: macro addr
	 move.l #(VDPCRAMWrite)|((\addr)&$3FFF)<<16|(\addr)>>14,VDPController
	endm

;**************************************************************
;*
;* InitializeVRAM Macro
;*
;* Description:
;*   Initializes the VRAM.
;*
;**************************************************************
InitializeVRAM: macro
	 SetVRAMWrite 0x0000
	 move.w #(0x00010000/ByteSizeWord)-1,d0
NextInitializeVRAM:
	 move.w #0x0,VDPBuffer
	 dbra d0,NextInitializeVRAM
	endm

StartProgram:
	; Initialize VDP security.
	move.b GenVersionAddress,d0
	andi.b #0x0F,d0
	beq NextBypassTMSS
	move.l #TMSSSignature,TMSSAddress
NextBypassTMSS:
	move.w VDPController,d0

	; Initialize the VDP registers and VRAM.
	lea VDPRegisters,a0
	move.w #0x18-1,d0
	move.w #0x8000,d1
LoopVDPController:
	move.b (a0)+,d1
	move.w d1,VDPController
	addi.w #0x0100,d1
	dbra d0,LoopVDPController
	InitializeVRAM

	; Set the colour palette.
	SetCRAMWrite 0x0000
	lea Palette,a0
	move.w #ByteSizePaletteWord-1,d0
LoopSetPalette:
	move.w (a0)+,VDPBuffer
	dbra d0,LoopSetPalette

	; Copy the BG tiles to VRAM.	
	SetVRAMWrite VRAMTileAddress
	
	lea CharacterSpace,a0
	move.w #(BGTileCount*ByteSizeTileLong)-1,d0
LoopCharacterSpace:
	move.l (a0)+,VDPBuffer
	dbra d0,LoopCharacterSpace

	; Short delay before continuing.
	move.w #NUM_23,d3
LoopD3Register:
	move.w #NUM_254,d2
LoopD2Register:
	move.w #NUM_254,d1
LoopD1Register:
	dbra d1,LoopD1Register
	dbra d2,LoopD2Register
	dbra d3,LoopD3Register

	; Load 32*28 BG tiles for 128*36 times.
	moveq #NUM_35,d4
LoopD4Register2:
	moveq #NUM_127,d3
LoopD3Register2:
	move.l #($40000003),VDPController
	moveq #NUM_27,d2
LoopD2Register2:
	moveq #NUM_31,d1
LoopD1Register2:
	move.w d1,VDPBuffer
	dbra d1,LoopD1Register2 ; Loop 31->0
	dbra d2,LoopD2Register2 ; Loop 27->0
	dbra d3,LoopD3Register2 ; Loop 127->0
	dbra d4,LoopD4Register2 ; Loop 35->0

	; Clear screen.
	 move.w #(0x00010000/ByteSizeWord)-1,d0
NextClearVRAM:
	 move.w #0x0,VDPBuffer
	 dbra d0,NextClearVRAM

LoopProgram:
	jmp LoopProgram

; Handler.
HandlerEmpty:
	rte

;***************
;* End of file *
;***************