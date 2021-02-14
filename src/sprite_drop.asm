;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   11:25 am 14/2/2021   Started Sprite Drop
;   21:47 pm 14/2/2021   8x8 sprite falls from top of screen
;
;   Simple demo showing an 8x8 sprite
;   "falling" from the top to the bottom
;   of the screen 1 pixel at a time
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This is a basic template file for writing 48K Spectrum code.

AppFilename             equ "NewFile"                   ; What we're called (for file generation)

AppFirst                equ $8000                       ; First byte of code (uncontended memory)

                        zeusemulate "48K";,"ULA+"       ; Set the model and enable ULA+


; Start planting code here. (When generating a tape file we start saving from here)
; *********************************************************************************


        org AppFirst

AppEntry:
        nop
        ld c, 0
        LD b, 183
START   push bc
        halt
        halt
        call DeleteSprite
        call MoveSpriteDown
        call DrawSprite
        pop bc
        djnz START
        ret

DeleteSprite:
        ld b, 7  ;0-7 sprite graphic rows
        ld a, (y_coordinate)
        push af
delloop push bc
        ld a, (x_coordinate)
        ld c, a
        ld a, (y_coordinate)
        ld b, a
        call GetXYAddress
        ld (hl), 0 ;wipe the pixel row
        pop bc
        ld a, (y_coordinate)
        inc a
        ld (y_coordinate), a
        DJNZ delloop
        pop af
        ld (y_coordinate), a
        ret

DrawSprite:
        ld b, 7  ;for sprite row loop
        ld de, sprite
        ld a, (y_coordinate)
        push af
drawlp  push bc
        ld a, (x_coordinate)
        ld c, a
        ld a, (y_coordinate)
        ld b, a
        push de
        call GetXYAddress
        pop de
        ld a, (de) ;take a byte of graphic
        ld (hl), a ;put it on screen
        inc de ;next byte of graphic
        pop bc
        ld a, (y_coordinate)
        inc a
        ld (y_coordinate), a
        DJNZ drawlp
        pop af
        ld (y_coordinate), a
        ret

MoveSpriteDown:
        ;y++
        ld a, (y_coordinate)
        inc a
        ld (y_coordinate), a
        ret

; IN  -  b = pixel row (0..191)
; IN  -  c = character column (0..31)
; OUT -  hl = screen address
; OUT -  de = trash
GetXYAddress:
        ld  h, 0
        ld  l, b            ; hl = Y (pixel row)
        add hl, hl          ; hl = Y (pixel row number) * 2
        ld  de, screen_map  ; de = screen map
        add hl, de          ; de = screen_map + (row * 2)
        ld  a, (hl)         ; implements ld hl, (hl)
        inc hl
        ld  h, (hl)
        ld  l, a            ; hl = address of first pixel in screen map
        ld  d, 0
        ld  e, c            ; de = X (character based)
        add hl, de          ; hl = screen addr + 32
        ret                 ; return screen_map[pixel_row]


screen_map:
        defw #4000, #4100, #4200,  #4300
        defw #4400, #4500, #4600,  #4700
        defw #4020, #4120, #4220,  #4320
        defw #4420, #4520, #4620,  #4720
        defw #4040, #4140, #4240,  #4340
        defw #4440, #4540, #4640,  #4740
        defw #4060, #4160, #4260,  #4360
        defw #4460, #4560, #4660,  #4760
        defw #4080, #4180, #4280,  #4380
        defw #4480, #4580, #4680,  #4780
        defw #40A0, #41A0, #42A0,  #43A0
        defw #44A0, #45A0, #46A0,  #47A0
        defw #40C0, #41C0, #42C0,  #43C0
        defw #44C0, #45C0, #46C0,  #47C0
        defw #40E0, #41E0, #42E0,  #43E0
        defw #44E0, #45E0, #46E0,  #47E0
        defw #4800, #4900, #4A00,  #4B00
        defw #4C00, #4D00, #4E00,  #4F00
        defw #4820, #4920, #4A20,  #4B20
        defw #4C20, #4D20, #4E20,  #4F20
        defw #4840, #4940, #4A40,  #4B40
        defw #4C40, #4D40, #4E40,  #4F40
        defw #4860, #4960, #4A60,  #4B60
        defw #4C60, #4D60, #4E60,  #4F60
        defw #4880, #4980, #4A80,  #4B80
        defw #4C80, #4D80, #4E80,  #4F80
        defw #48A0, #49A0, #4AA0,  #4BA0
        defw #4CA0, #4DA0, #4EA0,  #4FA0
        defw #48C0, #49C0, #4AC0,  #4BC0
        defw #4CC0, #4DC0, #4EC0,  #4FC0
        defw #48E0, #49E0, #4AE0,  #4BE0
        defw #4CE0, #4DE0, #4EE0,  #4FE0
        defw #5000, #5100, #5200,  #5300
        defw #5400, #5500, #5600,  #5700
        defw #5020, #5120, #5220,  #5320
        defw #5420, #5520, #5620,  #5720
        defw #5040, #5140, #5240,  #5340
        defw #5440, #5540, #5640,  #5740
        defw #5060, #5160, #5260,  #5360
        defw #5460, #5560, #5660,  #5760
        defw #5080, #5180, #5280,  #5380
        defw #5480, #5580, #5680,  #5780
        defw #50A0, #51A0, #52A0,  #53A0
        defw #54A0, #55A0, #56A0,  #57A0
        defw #50C0, #51C0, #52C0,  #53C0
        defw #54C0, #55C0, #56C0,  #57C0
        defw #50E0, #51E0, #52E0,  #53E0
        defw #54E0, #55E0, #56E0,  #57E0

x_coordinate:  db #0F
y_coordinate:  db #00
current_screen_address: defw #4000


sprite:
        dg ---##---
        dg --####--
        dg -######-
        dg ##-##-##
        dg ##-##-##
        dg ########
        dg --#--#--
        dg -##--##-





;**********************************************************************************
; Stop planting code after this. (When generating a tape file we save bytes below here)
AppLast                 equ *-1                         ; The last used byte's address

; Generate some useful debugging commands

                        profile AppFirst,AppLast-AppFirst+1     ; Enable profiling for all the code

; Setup the emulation registers, so Zeus can emulate this code correctly

Zeus_PC                 equ AppEntry                            ; Tell the emulator where to start
Zeus_SP                 equ $FF40                               ; Tell the emulator where to put the stack

; These generate some output files

                        ; Generate a SZX file
                        output_szx AppFilename+".szx",$0000,AppEntry    ; The szx file

                        ; If we want a fancy loader we need to load a loading screen
                        ; import_bin AppFilename+".scr",$4000            ; Load a loading screen

                        ; Now, also generate a tzx file using the loader
                        ; output_tzx AppFilename+".tzx",AppFilename,"",AppFirst,AppLast-AppFirst,1,AppEntry ; A tzx file using the loader


