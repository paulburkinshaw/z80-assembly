; will continue looping until the "space" key is pressed
; it works by checking the Z (zero) flag is set
; the flag will be set when CP 32 is true - A register value is equal to 32

	ORG 30000

LOOP	
	LD A, (23560)	; load last key pressed into A
	CP 32		; compare A register with 32 ("space")
	JR NZ, LOOP	; if z is not set (A is not identical to "space"), keep looping
	JR Z, WHOOP	; if Z is set (if A is identical to "space"), jump
WHOOP 	
	RET
