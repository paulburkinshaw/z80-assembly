; This is a basic template file for writing 48K Spectrum code.

AppFilename             equ "NewFile"                   ; What we're called (for file generation)

AppFirst                equ $8000                       ; First byte of code (uncontended memory)

                        zeusemulate "48K";,"ULA+"       ; Set the model and enable ULA+


; Start planting code here. (When generating a tape file we start saving from here)
; *********************************************************************************


                        org AppFirst

AppEntry                nop

screen_width_pixels:    equ 256
screen_height_pixels:   equ 192
screen_width_chars:     equ 32
screen_height_chars:    equ 24

screen_start:           equ #4000
screen_size:            equ screen_width_chars * screen_height_pixels
attr_start:             equ #5800
attributes_length:      equ screen_width_chars * screen_height_chars

; attribute colour values
ink_black:              equ %000000
ink_blue:               equ %000001
ink_red:                equ %000010
ink_magenta:            equ %000011
ink_green:              equ %000100
ink_cyan:               equ %000101
ink_yellow:             equ %000110
ink_white:              equ %000111

paper_black:            equ ink_black << 3
paper_blue:             equ ink_blue  << 3
paper_red:              equ ink_red  << 3
paper_magenta:          equ ink_magenta  << 3
paper_green:            equ ink_green  << 3
paper_cyan:             equ ink_cyan  << 3
paper_yellow:           equ ink_yellow  << 3
paper_white:            equ ink_white  << 3

bright:                 equ %1000000

; ************************
; *** setup the screen ***
; ************************

; colour the background
        ld a,paper_yellow ;OR bright
        call COLOURSCREEN

; draw the ceiling
        ld b,screen_width_chars
        ld hl,screen_start
        call DRAWCEILING

MAIN:
        ret

; colours all 768 attributes
; uses ldir which loads the contents of HL into the contents of DE then decrements BC until BC=0
; the contents of hl before ldir will be the attribute value passed to the sub routine in a
; ldir takes 21 T-States
COLOURSCREEN:
        ld hl, attr_start               ; start at address #5800
        ld de, attr_start + 1           ; load next attribute address into de
        ld bc, attributes_length - 1    ; decrement attribute length 1 times
        ld (hl), a                      ; initialize the first attribute
        ldir                            ; fill the attributes - ldir repeats LDI (LD (DE),(HL), then increments DE, HL, and decrements BC) until BC=0
        ret

DRAWCEILING:
        ld (hl),255
        inc hl
        djnz DRAWCEILING
        ret

x_coordinate:
        db 0
y_coordinate:
        db 0




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
                        output_tzx AppFilename+".tzx",AppFilename,"",AppFirst,AppLast-AppFirst,1,AppEntry ; A tzx file using the loader


