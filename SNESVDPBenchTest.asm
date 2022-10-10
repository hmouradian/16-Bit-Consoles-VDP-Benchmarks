;*********************************************************
;* TG16VDPBenchmark.asm
;*
;* Program description:
;*   This program tests the performance of the Super
;*   Nintendo's (SNES) Video Display Processor (VDP)
;*   using the following algorithm:
;*     1) Load and initalize the SNES settings.
;*     2) Display 32x28 background tiles 4,608 times.
;*     4) Turn off the screen.
;*     5) Loop until SNES is reset or turned off.
;*
;* Update History:
;*   Oct 09 2022 - First version. Hagop Mouradian
;*********************************************************

; Local constants.
.equ ScreenDisplayRegister  $2100
.equ CGRAMAddressRegister   $2121
.equ CGRAMDataWriteRegister $2122
.equ BGTileCount            $20
.equ BGTileByteSize         16 * 2
.equ NUM_255                $FF
.equ NUM_128                $80
.equ NUM_36                 $24
.equ NUM_32                 $20
.equ NUM_28                 $1C
.equ NUM_24                 $18
.equ NUM_16                 $10
.equ NUM_1                  $01
.equ NUM_0                  $00
.equ RAM_x0000              $0000
.equ RAM_x0001              $0001
.equ RAM_x0002              $0002

; SNES memory initializations.
.memorymap
	slotsize $8000
	defaultslot 0
	slot 0 $8000
.endme

.rombanksize $8000
.rombanks 8
.bank $00
.org $00

; SNES cartridge initializations.
.snesheader
	id "SNES"
	name "SNESVDPBenchTest     "
	fastrom
	lorom
	cartridgetype $00
	romsize $08
	sramsize $00
	country $01
	licenseecode $00
	version $00
.endsnes

.snesnativevector
	cop EmptyHandler
	brk EmptyHandler
	abort EmptyHandler
	nmi VBlank
	irq EmptyHandler
.endnativevector

.snesemuvector
	cop EmptyHandler
	abort EmptyHandler
	nmi EmptyHandler
	reset StartProgram
	irqbrk EmptyHandler
.endemuvector

;**************************************************************
;*
;* InitSNESMacro
;*
;* Description:
;*   Initialize the SNES.
;*
;**************************************************************
.macro InitSNES
	  sei
	  clc
	  xce
	  rep #$38
	  ldx #$1FFF
	  txs
	.endm

InitializeSNES:
; Jump to fast memory area.
.base $80
Reset:
   jml NextReset
NextReset:
   jsl StartProgram

.bank $01
.org $00
.section "MainCode"

; Start of game program.
StartProgram:
	InitSNES
	rep #$30
	stz $2121

	; Setup colour palette.
	ldx #$00
LoopPalette:
	lda Palette1.l,x
	sta $2122
	sta $2122
	inx
	cpx #NUM_16
	bne LoopPalette

	; Load background tiles to VRAM.
	ldx #BGTile0
	stx $4302
	lda #:BGTile0
	sta $4304
	ldy #(BGTileCount*BGTileByteSize)
	sty $4305
	lda #$01
	sta $4300
	lda #$18
	sta $4301
	lda #$80
	sta $2115
	ldy #$00
	sty $2116
	lda #$01
	sta $420B

	; Short delay before continuing.
	ldx #NUM_24
LoopRepeat1:
	stx RAM_x0000
	ldx #NUM_255
LoopRegisterX1:
	ldy #NUM_255
LoopRegisterY1:
	dey
	bne LoopRegisterY1
	dex
	bne LoopRegisterX1
	ldx RAM_x0000
	dex
	bne LoopRepeat1

	; Set up the screen.
	lda #$01
	sta $2105
	lda #$40
	sta $2107
	stz $210B
	lda #$01
	sta $212C
	lda #$0F
	sta $2100

	; Load 32*28 BG tiles for 128*36 times.
	ldx #NUM_36
Loop1:
	stx RAM_x0000
	ldx #NUM_128
Loop2:
	stx RAM_x0002
	ldx #NUM_28
	ldy #$4000
	sty $2116
Loop3:
	ldy #NUM_32
Loop4:
	sty $2118
	dey
	bne Loop4 ; Loop 32->1
	dex
	bne Loop3 ; Loop 28->1
	ldx RAM_x0002
	dex
	bne Loop2 ; Loop 128->1
	ldx RAM_x0000
	dex
	bne Loop1 ; Loop 36->1

	; Turn off the screen.
	ldx #$00
	stx $212C
	ldx #$00
	stx $2100

; Keep looping.
LoopProgram:
	jmp LoopProgram

; Video and interrupt handlers.
VBlank:
	rti

EmptyHandler:
	rti

.ends

.bank $02
.org $00
.section "Tiledata"

BGTile0:
	; 0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

BGTile1:
	; 0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

BGTile2:
	; 0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
    .db $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

BGTile3:
	; 0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
    .db $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

BGTile4:
	; 0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00

BGTile5:
	; 0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF

BGTile6:
	; 0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

BGTile7:
	; 0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
    .db $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
    .db $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00

BGTile8:
	; 0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
    .db $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
    .db $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF

BGTile9:
	; 0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00

BGTile10:
	; 0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
    .db $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

BGTile11:
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

BGTile12:
    .db $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
    .db $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF

BGTile13:
    .db $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

BGTile14:
    .db $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
    .db $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00

BGTile15:
	; 0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

BGTile16:
	; 0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
    .db $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
    .db $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF

BGTile17:
	; 0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

BGTile18:
	; 0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
    .db $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

BGTile19:
	; 0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
    .db $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

BGTile20:
	; 0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00

BGTile21:
	; 0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF

BGTile22:
	; 0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

BGTile23:
	; 0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
    .db $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
    .db $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00

BGTile24:
	; 0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
    .db $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
    .db $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF

BGTile25:
	; 0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00

BGTile26:
	; 0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
    .db $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

BGTile27:
	; 0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

BGTile28:
	; 0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
    .db $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
    .db $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF

BGTile29:
	; 0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
    .db $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

BGTile30:
	; 0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
    .db $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
    .db $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00

BGTile31:
	; 0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

Palette1:
	;    0BBBBBGGGGGRRRRR
	.dw %0111110000000000 ; 0
	.dw %0000001111100000 ; 1
	.dw %0000000000011111 ; 2
	.dw %0111111111100000 ; 3
	.dw %0111110000011111 ; 4
	.dw %0000001111111111 ; 5
	.dw %0110000000000001 ; 6
	.dw %0000110000000010 ; 7
	.dw %0000011000000000 ; 8
	.dw %0000000000111000 ; 9
	.dw %0100001100100010 ; 10
	.dw %0000000011000000 ; 11
	.dw %0111110000001111 ; 12
	.dw %0111110001100110 ; 13
	.dw %0100010110001010 ; 14
	.dw %0111110010000000 ; 15

Palette2:
	;    0BBBBBGGGGGRRRRR
	.dw %0111110000000000 ; 0
	.dw %0000001111100000 ; 1
	.dw %0000000000011111 ; 2
	.dw %0111111111100000 ; 3
	.dw %0111110000011111 ; 4
	.dw %0000001111111111 ; 5
	.dw %0110000000000001 ; 6
	.dw %0000110000000010 ; 7
	.dw %0000011000000000 ; 8
	.dw %0000000000111000 ; 9
	.dw %0100001100100010 ; 10
	.dw %0000000011000000 ; 11
	.dw %0111110000001111 ; 12
	.dw %0111110001100110 ; 13
	.dw %0100010110001010 ; 14
	.dw %0111110010000000 ; 15

.ends

;***************
;* End of file *
;***************