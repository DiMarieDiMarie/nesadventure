.include "constants.inc"

.segment "CODE"
.export draw_backgrounds
.proc draw_backgrounds
  PHA
  TXA
  PHA
  TYA
  PHA
  PHP

  ; Draw background objects by writing tile numbers
  ; into nametable PPU address space.
  ; There are definitely more efficient ways to do this!
  ; (compression techniques like "RLE" help a lot)

  ; lake
  LDX #$22
  LDY #$84
  JSR draw_water
  LDX #$22
  LDY #$86
  JSR draw_water
  LDX #$22
  LDY #$88
  JSR draw_water
  LDX #$22
  LDY #$c6
  JSR draw_water
  LDX #$22
  LDY #$c8
  JSR draw_water

  ; desert
  LDX #$21
  LDY #$d8
  JSR draw_desert
  LDX #$21
  LDY #$da
  JSR draw_desert
  LDX #$22
  LDY #$16
  JSR draw_desert
  LDX #$22
  LDY #$18
  JSR draw_desert
  LDX #$22
  LDY #$1a
  JSR draw_desert
  LDX #$22
  LDY #$58
  JSR draw_desert
  LDX #$22
  LDY #$5a
  JSR draw_desert

	; forest (table 2)
	LDX #$25
	LDY #$4e
	JSR draw_forest
	LDX #$25
	LDY #$50
	JSR draw_forest
	LDX #$25
	LDY #$52
	JSR draw_forest
	LDX #$25
	LDY #$8a
	JSR draw_forest
	LDX #$25
	LDY #$8e
	JSR draw_forest
	LDX #$25
	LDY #$90
	JSR draw_forest
	LDX #$25
	LDY #$92
	JSR draw_forest
	LDX #$25
	LDY #$cc
	JSR draw_forest
	LDX #$25
	LDY #$d0
	JSR draw_forest
	LDX #$25
	LDY #$d2
	JSR draw_forest
	LDX #$26
	LDY #$0c
	JSR draw_forest
	LDX #$26
	LDY #$12
	JSR draw_forest
	LDX #$26
	LDY #$14
	JSR draw_forest
	LDX #$26
	LDY #$54
	JSR draw_forest

  ; carve out a few desert tiles to make it look less blocky
  ; (overwrite previously-written desert tiles with empty background)
  LDA PPUSTATUS
  LDA #$22
  STA PPUADDR
  LDA #$36
  STA PPUADDR
  LDA #$00  ; "blank" tile
  STA PPUDATA

  LDA #$22
  STA PPUADDR
  LDA #$7b
  STA PPUADDR
  LDA #$00
  STA PPUDATA

  LDA #$21
  STA PPUADDR
  LDA #$fb
  STA PPUADDR
  LDA #$00
  STA PPUDATA

  ; finally, set up the palettes
  ; for each 2x2 area of nametable
  ; by writing to the attribute table
  JSR write_attribute_table

  PLP
  PLA
  TAY
  PLA
  TAX
  PLA
  RTS
.endproc

.proc draw_water
  ; draw a 2x2 block of water tiles
  ; memory address to start at stored in X and Y
  ; X = high byte
  ; Y = low byte
  ; This uses all registers and does not save them!
  ; (beware)
  LDA PPUSTATUS
  STX PPUADDR
  STY PPUADDR
  LDA #$09  ; water, top left
  STA PPUDATA
  LDA #$0a  ; water, top right
  STA PPUDATA
  TYA   ; move Y to A; add 32 to get next row
  CLC
  ADC #$20
  TAY   ; move result back to Y
  LDA PPUSTATUS
  STX PPUADDR
  STY PPUADDR
  LDA #$0b  ; water, bottom left
  STA PPUDATA
  LDA #$0c  ; water, bottom right
  STA PPUDATA
  RTS
.endproc

.proc draw_forest
	LDA PPUSTATUS
	STX PPUADDR
	STY PPUADDR
	LDA #$05 ; tree, top left
	STA PPUDATA
	LDA #$06 ; tree, top right
	STA PPUDATA
	TYA
	CLC
	ADC #$20
	TAY
	LDA PPUSTATUS
	STX PPUADDR
	STY PPUADDR
	LDA #$07 ; tree, bottom left
	STA PPUDATA
	LDA #$08 ; tree, bottom right
	STA PPUDATA
	RTS
.endproc

.proc draw_desert
  ; draw a 2x2 block of desert tiles
  ; memory address to start at stored in X and Y
  ; X = high byte
  ; Y = low byte
  ; This uses all registers and does not save them!
  ; (beware)
  LDA PPUSTATUS
  STX PPUADDR
  STY PPUADDR
  LDA #$0d  ; desert
  STA PPUDATA
  STA PPUDATA
  TYA   ; move Y to A; add 32 to get next row
  CLC
  ADC #$20
  TAY   ; move result back to Y
  LDA PPUSTATUS
  STX PPUADDR
  STY PPUADDR
  LDA #$0d  ; load desert tile again
  STA PPUDATA
  STA PPUDATA
  RTS
.endproc


.proc write_attribute_table
  LDA PPUSTATUS
  ; write water backgrounds to attribute table
  LDA #$23
  STA PPUADDR
  LDA #$e9
  STA PPUADDR ; select a 4x4 area using "AtOff"
              ; from NES Screen Tool
  LDA #%01000101 ; for this 4x4 area, all but bottom-left is palette 2
  STA PPUDATA
  ; next memory address is $23ea, which is where we want to write anyway
  LDA #%00010001  ; left two 2x2 areas are palette 2
  STA PPUDATA

  ; now desert tiles
  LDA #$23
  STA PPUADDR
  LDA #$de
  STA PPUADDR
  LDA #%10100101  ; bottom 2 2x2 areas should be palette 3 ("desert")
  STA PPUDATA

  LDA #$23
  STA PPUADDR
  LDA #$e5
  STA PPUADDR
  LDA #%00001000
  STA PPUDATA
  LDA #%10101010
  STA PPUDATA

  RTS
.endproc
