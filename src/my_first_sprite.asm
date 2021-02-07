; This is a basic template file for writing 48K Spectrum code.

AppFilename             equ "NewFile"                   ; What we're called (for file generation)

AppFirst                equ $8000                       ; First byte of code (uncontended memory)

                        zeusemulate "48K","ULA+"        ; Set the model and enable ULA+


; Start planting code here. (When generating a tape file we start saving from here)

                        org AppFirst            ; Start of application

AppEntry                halt                    ; Replace these lines with your code

LASTK                   EQU 23560               ; LAST K System variable
PRINT                   EQU 8252
UDGSV                   EQU 23675               ;

                        LD A, 2                 ; set print channel to screen
                        CALL 5633
                        LD HL, GFX              ; set up UDGs
                        LD (UDGSV), HL          ; set System Variable UDG (stored in 23675 and 23676) to address of our first UDG

MAINLP                  CALL PRTPLAY            ; print player sprite
                        LD A, (LASTK)           ; read last key-press
                        CP "o"                  ; was it "o"?
                        JR Z, GOLEFT            ; if so, jump to GOLEFT
                        CP "p"                  ; was it "p"?
                        JR Z, GORIGHT           ; if so, jump to GORIGHT
                        JR MAINLP               ; loop back to scan again

GOLEFT                  LD A, " "               ; change graphic to empty space
                        LD (PLAYER+3), A        ; store it
                        CALL PRTPLAY            ; undraw graphic from screen
                        LD A, 144               ; change graphic back to normal
                        LD (PLAYER+3), A        ; store it
                        LD A, (PLAYER+2)        ; get player's X coordinate
                        DEC A                   ; subtract 1
                        LD (PLAYER+2), A        ; store new X coordinate
                        LD A, 0                 ; load A with 0 (meaning no key-press)
                        LD (LASTK), A           ; clear last key-press
                        JR MAINLP               ; jump to start of main loop

GORIGHT                 EQU $                   ; TODO

PRTPLAY                 LD DE, PLAYER           ; print graphic
                        LD BC, EOPLYER-PLAYER   ; number of bytes to print
                        CALL PRINT
                        RET

PLAYER                  DEFB 22, 5, 5, 144
EOPLYER                 EQU $

GFX                     DEFB 24, 24, 255, 189, 189, 60, 36, 102


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


