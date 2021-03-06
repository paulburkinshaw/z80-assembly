## System Variables
----------------
Address from:	23552 (5C00H)
Address to:		23733 (5CB5H)
No bytes:				

Memory area in RAM with addresses from 23552 (5C00H) to 23733 (5CB5H) is used by the Basic interpreter and OS for storing the system variables.
For variables of 2 bytes the first address contains the least significant byte and the second the most significant byte.

## Common variables
----------------
Address(D)		Adress(H)		Variable name		Bytes		Comments
23552			5C00			KSTATE				8			Used in keyboard reading operation

23560			5C08			LAST K				1			Stores code of most recently depressed keyboard

23675			5C7B			UDG					2			23675(&6) hold the 16 bit address of first user defined graphic symbol,
																address 65368 (FF58H) by default but it can be poked with a new address
																

# The Screen Display

## The Character Set
-----------------

	Each character assigned a unique decimal code from 0-255

	- There are 224 characters that can be displayed on screen, codes 32 to 255, these are stored in memory from address 15616 to 16383.
		- Each character is defined by the contents of 8 successive memory bytes.


	User Defined Graphics (UDGs)
	----------------------------
	Address from:	65368 (FF58H)
	Address to:		
	No bytes:		

	UDGs are accessed using characters 144 to 164 of the ASCII table.
	There are a maximum of 21. 


	Display File (screen memory/pixel data)
	---------------------------------------
	Address from:	16384 (4000H)
	Address to:		22527 (57FFH)
	No bytes:		6,144 (32 bytes by 192 pixel rows)

	The spectrums screen memory starts at the very beginning of the RAM at address 4000H.


	Attribute File
	--------------
	Address from:	22528 (5800H)
	Address to:		23295 (5AFFH)
	No bytes:		768 (32x24 characters of data)	

	There are 768 attributes, 1 for every 8x8pixel character square on the screen (24rows x 32columns)
	Each block of 8x8 pixels can be coloured by setting a single byte.
	Starting at 0,0 top left of the screen to colour a character at position x,y where x is character column number and y is character row number we use:
    #5800 + ((y*32) + x) so to set the attributes for character (3,2):
	#5800 + ((2*32) + 3) = #5843


	The character grid
	------------------
	Paper on screen is arranged as 22 x 32 character grid.
	The rows are numbered 0 to 21 from the top (rows 22 and 23 are reserved for BASIC reporting)
	the columns are numbered 0 to 31 from the left

 	The pixel grid
	--------------
	The pixels on screen are arranged as a 176 x 256 grid (8x22 and 8x32).
	
	The columns in the x-direction are numbered 0 to 255 from the left hand side
	The rows in y-direction are numbered from 0-175 starting from the bottom.
	The pixel grid overlays the character grid, such that each character square contains 64 pixels.
	
	
	Drawing to screen
	-----------------
	*Drawing pixels*
	The 8 bytes of a character are not stored sequentially in memory and the computer does not sequentially write the 192 lines of the display (176 + 2 character rows for reporting)
	The character screen grid is arranged in 3 sections of 32 columns and 8 rows 
	The characters are written onto the screen a section at a time starting at character row 0, screen section 0 
	and the computer sequentially outputs the byte for each of the 32 characters in row 0, starting at column 0, then byte 0 for all 32 characters in row 1 and so on 
	so if we were to poke in a value of 255 into each memory location from 16384 to 22527 you would see 
	a thin 1 pixel line all the way across from left to right as the top line of each character (the first byte) is written to the screen for section 0
	
	Calculate the address of any display file byte:
	#4000 (16384) + character column number + (32 * character row number) + (256 * character byte number) + (2048 * screen section number)
	
	for example, the address of: 
		- character column 5, character row 0, character byte 0, screen section 0 is:
			#4000 + 5 + (32*0) + (256*0) + (2048*0) = #4005
		- character column 5,  character row 0, character byte 1, screen section 0 is: 
			#4000 + 5 + (32*0) + (256*1) + (2048*0) = #4105
		- character column 5,  character row 0, character byte 2, screen section 0 is: 
			#4000 + 5 + (32*0) + (256*2) + (2048*0) = #4205
		- character column 5,  character row 0, character byte 3, screen section 0 is: 
			#4000 + 5 + (32*0) + (256*3) + (2048*0) = #4305
		- character column 5,  character row 0, character byte 4, screen section 0 is: 
			#4000 + 5 + (32*0) + (256*4) + (2048*0) = #4405
		- character column 5,  character row 0, character byte 5, screen section 0 is: 
			#4000 + 5 + (32*0) + (256*5) + (2048*0) = #4505
		- character column 5,  character row 0, character byte 6, screen section 0 is: 
			#4000 + 5 + (32*0) + (256*6) + (2048*0) = #4605
		- character column 5,  character row 0, character byte 7, screen section 0 is: 
			#4000 + 5 + (32*0) + (256*7) + (2048*0) = #4705
	
	
### finding a pixel address using a lookup table

This approach uses a lookup table to store each 

In current programming terms we store the address of the first pixel in each screen row, in an array. We then calculate the address as screen_map[y*2] + x. The multiplier of 2 is because it is an array of bytes and the addresses are words
so for instance if y contains 2 (it is at pixel line 2 of 192) and the addresses for the rows are:

#4000
#4100
#4200
#4300

then the address we're after is #4200 as its the second row (counting 0 index) but to get to this row in assembly we have to move down 4 (y*2, or y+y) times through the screen_map array as the addresses are stored in bytes so the physical addresses are stored like so:

|-address byte number-|-address-|
		0				40
		1				00
		2				41
		3				00
		4				42
		5				00
		6				43
		7				00


### preshifting

Now, there are two general approaches to “moving” a sprite on screen. One is to have a single image and shift it (by multiplying or dividing the values it consists of by two), depending on the sprite’s intended position inside a screen byte. You’ll need to make up to seven such shifts. This is pretty slow but very memory-efficient. The other method is essentially that of animation. You create several (say, eight) different sprite “frames,” each preshifted by one pixel and then choose to display the frame which corresponds to the offset within a byte.

The actual offset value is obtained by simply masking off the five highest bits of the horizontal coordinate. Say, you horizontal position is 67. Sixty-seven divided by 8 is 8 and the remainder is 3. So, you’ll be drawing your sprite in the seventh byte counting from the lefthand edge of the screen, and the sprite will be shifted three pixels to the right within that byte. Thus, you’ll either need to shift your single sprite image right three times (divide it by eight), or choose to display Frame 3 of your pre-shifted sprite.


You can print vertically from any line (there are 192 of these), so vertical movement is easy and smooth, but horizontally you can only print per column (there are only 32), so a 16 x 16 sprite has to be printed as a 24 x 16 object. Therefore you need to preshift the sprite as 8 images for how it would move between columns (8 pixels apart)

And for additional info, in this slowed down animation below, see how the lowest 3 bits of the x coordinate cycles 0 - 7 (decimal). So whatever the x coordinate is, we can grab the lowest 3 bits and get the correct sprite graphic.

![](src/spriteexample.gif)


### Screen address map

![](src/ScreenAddressMap.PNG)

adding 1 to the low byte moves left to right across one character column, with the 4 low bits we can move to up to 32 columns (0-31) 

adding 1 to the high byte moves down one pixel line within a character row

adding 32 to the low byte moves down one character row

adding 8 to the high byte moves down one screen third


### timing

zx spectrum screen is refreshed 50 times per second which = 50hz
there are 50 interrupts generated per second 
interput mode 1 is the default mode and this is generated when the v scan line reaches the bottom of the screen
the halt instruction waits for the scan line to reach the bottom of the screen before resuming execution
1 halt instruction within the main game loop would mean the program would run at 50fps
2 halt instructions 25fps
3 17fps
4 12.5 fps