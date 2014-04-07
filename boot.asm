[bits 16]
[org 0]

;--------------------------;
; CorkthomasOS		   ;
; Created by Alex Heritier ;
; Revised 12/08/11	   ;
;--------------------------;

;boot.asm
	mov ax, 0x07c0
	mov ds, ax

	mov si, msg
	call print

	mov bl, 0x00		;initialize prompt switch to on

;main program
main:	
	mov si, buffer		

.loop:
	or bl, bl		;if bl = 0, write prompt
	jz int_prompt
	
	mov ah, 0x00
	int 0x16		;wait for keyboard input

	cmp al, 0x0D		;compare al and enter key
	je .return		;if equal, print \n

	cmp al, 0x08		;compare al and backspace key
	je .backspace		;if equal, print buffer

	cmp al, 0x1B		;compare al and backspace key
	je .esc			;if equal, print buffer

	cmp si, buffer+41	;if buffer full ########(OFFSET MUST BE EQUAL TO SIZE OF BUFFER)########
	je .loop		;loop

	mov ah, 0x0E		
	int 0x10		;print input

	mov [si], al		;add character to buffer
	inc si			;increment si
	jmp .loop		

.return:
	mov si, return_key
	call print

	call input_check

	mov bl, 0x00		;set prompt switch to on

	mov si, buffer
	call clear_buffer

	jmp main

.backspace:
	cmp si, buffer		;if start of line
	je .loop		;do nothing

	dec si			;go back one character
	mov byte [si], 0	;delete previous entry in buffer

	mov ah, 0x0E
  	mov al, 0x08
   	int 0x10		; backspace on the screen

	mov al, ' '
	int 0x10		; blank character out
 
	mov al, 0x08
	int 0x10		; backspace again
 
	jmp .loop		; go to the main loop

.esc:
	mov si, return_key
	call print
	
	mov si, buffer
	call print
	
	jmp main


int_prompt:
	jmp prompt


input_check:
	mov si, buffer		;load buffer to check it
	
	mov bh, 'c'
	cmp [si], bh
	je input_check2
	
	mov bh, 'h'
	cmp [si], bh		;check first char in buffer for 'h'
	je .h
	jmp bad_command
.h:
	mov bh, 'e'
	cmp [si+1], bh		;check second char for 'e'
	je .e
	jmp bad_command
.e:
	mov bh, 'l'
	cmp [si+2], bh		;check second char for 'l'
	je .l
	jmp bad_command
.l:
	mov bh, 'p'
	cmp [si+3], bh		;check second char for 'e'
	je help_com
	jmp bad_command


input_check2:
	mov bh, 'l'
	cmp [si+1], bh
	je .l
	jmp bad_command
.l:
	mov bh, 's'
	cmp [si+2], bh
	je cls_com
	jmp bad_command


bad_command:
	mov si, buffer
	cmp byte [si], 0
	je .empty_line
.good:
	mov si, bad_com
	call print
	mov bl, 0x00		;set prompt switch to on

	mov si, buffer
	call clear_buffer

	jmp main
.empty_line:
	mov bl, 0x00		;set prompt switch to on

	mov si, buffer
	call clear_buffer

	jmp main
	

help_com:
	mov si, help		;print help
	call print
	ret


echo_com:


cls_com:
	mov ah, 6 		; Use function 6 - clear screen
	mov al, 0 		; clear whole screen
	mov bh, 7	 	; use black spaces for clearing
	mov cx, 0 		; set upper corner value
	mov dl, 79 		; coord of right of screen
	mov dh, 24 		; coord of bottom of screen
	int 10h 		; go!and to set the cursor to the top left of the screen use:
				; move the cursor to the top of the screen
	mov ah, 2 		; use function 2 - go to x,y
	mov bh, 0 		; display page 0
	mov dh, 0 		; y coordinate to move cursor to
	mov dl, 0 		; x coordinate to move cursor to
	int 10h 		; go!Try putting those two snippets in your own application and see how you go.

	ret

	
clear_buffer:
	mov bh, 0x00
.loop:
	cmp bh, 0x2C
	je .done
	mov byte [si], 0
	inc bh
	inc si
	jmp .loop
.done:
	ret
	

print:
	lodsb
	or al, al
	jz .done
	mov ah, 0x0E
	int 0x10
	jmp print
.done:
	ret


prompt:
	mov ah, 0x0E		;print '>'
	mov al, '>'
	int 0x10

	mov bl, 0x01		;set prompt switch to off
	
	jmp main


return_key db 10, 13, 0
msg db "+------------------+", 10, 13, "| CorkthomasOS     |", 10, 13, "| by Alex Heritier |", 10, 13, "| 11/24/11         |", 10, 13, "+------------------+", 10, 13, 0
bad_com db "ERROR: not a command.", 10, 13, 0
help db "Commands: help, cls", 13, 10, 0
buffer times 41 db 0		;####(BUFFER SIZE : 41)####

times 510-($-$$) db 0
db 0x55
db 0xAA
