;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   20:23 pm 24/2/2021   Started a Bit of Life
;   21:23 pm 24/2/2021   Planted an animated tree
;
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
Start:
        call DrawTheSky
        call DrawTheFloor
MainLoop:
        halt
        halt
        halt
        halt
        halt
        halt
        call DeleteTree
        call IncrementSpriteFrame
        call DrawTree
        djnz MainLoop
        ret

IncrementSpriteFrame:
        ld a, (tree_frame_number)
        inc a
        ld (tree_frame_number), a
        cp 7
        ret c
        ld a, 0
        ld (tree_frame_number), a
        ret

DrawTheSky:
       ;set border colour to black
       ld a,0
       call 8859                        ;bios call
       ld a, %00000000 or %00000011;    ;set paper to black and & ink to magenta
       ld hl, #5800                     ;start at address #5800
       ld de, #5800 + 1                 ;load next attribute address into de
       ld bc, 735                       ;loop counter - 735 blocks from top left 0,0 to second to last char row
       ld (hl), a                       ;initialize the first attribute
       ldir                             ;fill the attributes - ldir repeats LDI (LD (DE),(HL), then increments DE, HL, and decrements BC) until BC=0
       ret

DrawTheFloor:
        ld b, 32                        ;loop counter - 32 columns
floorloop:
        push bc                         ;push floor loop counter onto stack
        ld a,(floor_attr_x)             ;load attribute x,y coords into bc
        ld c, a
        ld a,(floor_attr_y)
        ld b, a
        call GetAttrAddress             ;get attribute address of x,y
        ld a, %00100000 or %00000011    ;paper green ink magenta
        ld (hl),a                       ;colour attribute
        ld a,(floor_attr_x)             ;increment column(x) number
        inc a
        ld(floor_attr_x), a
        pop bc
        djnz floorloop                  ;draw 32 blocks
        ret



DeleteTree:
        ld b, 16                        ;16 pixel line loop counter
        ld a, (tree_y_coordinate)
        push af                         ;save y coord as this will be used below to draw the 8 pixel lines
deletetreeloop:
        push bc                         ;save 8 pixel line loop counter as b will be used below
        ld a, (tree_x_coordinate)
        ld c, a
        ld a, (tree_y_coordinate)
        ld b, a
        push de
        call GetXYAddress
        pop de

        ;sprite is 2 columns
        ld a, 0                         ;empty A to delete
        ld (hl), a
        inc l                           ;repeat for next char column
        ld a, 0
        ld (hl), a
        dec l

        pop bc
        ld a, (tree_y_coordinate)
        inc a
        ld (tree_y_coordinate), a
        DJNZ deletetreeloop
        pop af
        ld (tree_y_coordinate), a
        ret

DrawTree:
        ld a,(tree_frame_number)
        call GetSpriteFrameGraphic
        ld de,hl                        ;load sprite man frame graphic address into de
        ld a, (tree_y_coordinate)
        push af                         ;save y coord as this will be used below to draw the 8 pixel lines
        ld b, 16                        ;16 pixel line loop counter
drawtreeloop:
        push bc                         ;save 16 pixel line loop counter as b will be used below
        ld a, (tree_x_coordinate)
        ld c, a
        ld a, (tree_y_coordinate)
        ld b, a
        push de
        call GetXYAddress
        pop de

        ;sprite is 2 columns so
        ld a, (de)                      ;take a byte of graphic
        ld (hl), a                      ;put it on screen
        inc de                          ;next byte of graphic
        inc l                           ;next column on screen
        ld a, (de)                      ;take a byte of graphic
        ld (hl), a                      ;put it on screen
        inc de                          ;next byte of graphic
        dec l

        pop bc                          ;retrieve loop counter
        ld a, (tree_y_coordinate)       ;increment y coord 16 times to draw the sprite
        inc a
        ld (tree_y_coordinate), a
        DJNZ drawtreeloop
        pop af                          ;retrieve y coord and put it back in memory
        ld (tree_y_coordinate), a
        ret


; IN - a = sprite frame number 0 - 7
; OUT - hl - pointing at the correct sprite frame graphic
; gets the sprite frame graphic from the sprite_man_addresses_table
GetSpriteFrameGraphic:
        add a,a                         ;multiplay a by 2, this converts a single byte number 0-7 into a 2 byte table entry
        ld h,0
        ld l,a
        ld bc,sprite_tree_address_table
        add hl,bc                       ;hl is now pointing at the correct table address entry
        ;implement ld hl,(hl)
        ld a,(hl)                       ;get first part of table address into a
        inc hl                          ;
        ld h,(hl)
        ld l,a                          ;now hl is pointing at the correct sprite graphic
        ret



; IN  -  b = y coord - pixel row (0..191)
; IN  -  c = x coord - pixel column (0..255)
; OUT -  hl = screen address
; OUT -  de = trash
GetXYAddress:
        ld  h, 0
        ld  l, b                        ;hl = Y (pixel row)
        add hl, hl                      ;hl = Y (pixel row number) * 2
        ld  de, screen_map              ;de = screen map
        add hl, de                      ;de = screen_map + (row * 2)
        ld  a, (hl)                     ;implements ld hl, (hl)
        inc hl
        ld  h, (hl)
        ld  l, a                        ;hl = address of first pixel in screen map

        ;get the character column offset number
        ;divide x coord by 8 and then mask off 5 highest bits of x coord to get char column offset
        ;effectively increments the char column by 1 for every of 8th value of x coord
        ;|x coord|char col|
        ;|   ;0  |  0     |
        ;|   ;1  |  0     |
        ;|   ;2  |  0     |
        ;|   ;8  |  1     |
        ;|   ;9  |  1     |
        ;|   ;10 |  1     |
        ;|   ;16 |  2     |
        ld a,c
        rra                             ;shift bits right 3 times to divide x coord by 8
        rra
        rra                                                                      ;128 64 32 16 8 4 2 1
        and 31                          ;mask off 5 highest bits of x coordinate 0    0  0  1  1 1 1 1

        ld  d, 0
        ld  e, a
        add hl, de                      ;hl = screen addr of first pixel in pixel row + offset of char columns
        ret                             ;return screen_map[pixel_row]

; Address of attribute for x,y = #5800 + ((y*32) + x)
; IN - b = row number(y) (0-23)
; IN - c = column number(x) (0-31)
; OUT - hl = attribute address
GetAttrAddress:
        ld l,b
        ld h,0
        add hl,hl                       ;y*32
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl
        ld b,0
        add hl,bc                       ;add column(x) offset
        ld bc,#5800                     ;add start of attribute file
        add hl,bc
        ret

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

tree_frame_number:      db -10
tree_x_coordinate:      db 0
tree_y_coordinate:      db 168
floor_attr_x:           db 0
floor_attr_y:           db 23
sky_attr_x:             db 0
sky_attr_y:             db 0






sprite_man:
        DEFB 24,24,126,24,24,24,36,102



;a table of sprite man addresses
;each address in the table contains the 16 bit address of the sprite_man_frame_0, sprite_man_frame_1 etc
sprite_tree_address_table:
        dw sprite_tree_frame_0
        dw sprite_tree_frame_1
        dw sprite_tree_frame_2
        dw sprite_tree_frame_3
        dw sprite_tree_frame_4
        dw sprite_tree_frame_5
        dw sprite_tree_frame_6
        dw sprite_tree_frame_7

;GRAPHIC DATA:
;Pixel Size:      (16,16)
;Char Size:       (2,2)
;Frames:           8
;Sort Priorities: X char, Char line, Y char, Frame number
sprite_tree_frame_0:
        DEFB     14,128, 18, 64, 89, 92, 79, 84
        DEFB     51,208, 29, 16,  3,240,  1,128
        DEFB      1,128,  1,128,  1,128,  1,128
        DEFB      1,128,  1,128,  3,192,  7,224

sprite_tree_frame_1:
        DEFB      6, 96,  2, 68, 57, 92, 15, 80
        DEFB    115,208, 93, 16,  3,240,  1,128
        DEFB      1,128,  1,128,  1,128,  1,128
        DEFB      1,128,  1,128,  3,192,  7,224

;sprite_tree_frame_2:
;        DEFB      6, 96,  2, 68, 57, 92, 15, 80
;        DEFB    115,208, 93, 16,  3,240,  1,128
;        DEFB      1,128,  1,128,  1,128,  1,128
;        DEFB      1,128,  1,128,  3,192,  7,224
sprite_tree_frame_2:
        DEFB      6,  0, 18,100, 25, 92, 15, 80
        DEFB    115,208, 93, 16,  3,240,  1,128
        DEFB      1,128,  1,128,  1,128,  1,128
        DEFB      1,128,  1,128,  3,192,  7,224

;sprite_tree_frame_3:
;        DEFB     14,  0, 34,112, 57, 80, 15, 80
;        DEFB     19,208, 29, 16,  3,240,  1,128
;        DEFB      1,128,  1,128,  1,128,  1,128
;        DEFB      1,128,  1,128,  3,192,  7,224
sprite_tree_frame_3:
        DEFB      6,  0, 18,100, 25, 92, 15, 80
        DEFB    115,208, 93, 16,  3,240,  1,128
        DEFB      1,128,  1,128,  1,128,  1,128
        DEFB      1,128,  1,128,  3,192,  7,224

sprite_tree_frame_4:
        DEFB      6,  0, 18,100, 25, 92, 15, 80
        DEFB    115,208, 93, 16,  3,240,  1,128
        DEFB      1,128,  1,128,  1,128,  1,128
        DEFB      1,128,  1,128,  3,192,  7,224

sprite_tree_frame_5:
        DEFB     14,  0, 34,112, 57, 80, 15, 80
        DEFB     19,208, 29, 16,  3,240,  1,128
        DEFB      1,128,  1,128,  1,128,  1,128
        DEFB      1,128,  1,128,  3,192,  7,224

sprite_tree_frame_6:
        DEFB     14,128, 18, 64, 89, 92, 79, 84
        DEFB     51,208, 29, 16,  3,240,  1,128
        DEFB      1,128,  1,128,  1,128,  1,128
        DEFB      1,128,  1,128,  3,192,  7,224

sprite_tree_frame_7:
        DEFB      6,  0, 18,100, 25, 92, 15, 80
        DEFB    115,208, 93, 16,  3,240,  1,128
        DEFB      1,128,  1,128,  1,128,  1,128
        DEFB      1,128,  1,128,  3,192,  7,224



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


