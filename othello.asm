; Copyright 2024 - wowvain-dev (Bogdan Stanciu)
; MIT License


section .bss
	board 			resb 64 
	input_buffer 	resb 2



section .data
	white_score 	db 0
	black_score 	db 0
	; the number of consecutive "forfeits" that took place. if we reach two, its game over since nobody is able to move
	skips 			db 0

	current_move 	db 2
	opponent_move   db 1
	directions 		db -1, 0,  1, 0,  0, -1,  0, 1,  -1, -1,   1, -1,      -1, 1,         1, 1 	 
	;					Left,  Right, Up,     Down,  Top-Left, Top-Right   Bottom-left   Bottom-right

	coords 			db "%d %d", 0
	walls 			db "|         |         |         |         |         |         |         |         |", 0 	
	row_separator	db "+---------+---------+---------+---------+---------+---------+---------+---------+", 0
	black_piece 	db 'X', 0
	white_piece 	db 'O', 0

	int_format		db "%d", 0
	char_format 	db "%c", 0		
	string_format   db "%s", 0
	title 			db "Othello", 0
	nl 				db "\n", 0
	score 			db "Score:", 0
	b_count 		db "Black pieces: %d", 0
	w_count 		db "White pieces: %d", 0
	keybinds 		db "Keybinds:", 0 
	f1_help 		db "P - Help", 0
	f2_about 		db "O - About", 0
	i_enter			db "I - Enter Move", 0 
	q_exit			db "Q - Exit", 0

	player			db "CURRENT PLAYER: %s", 0
	player_black 	db "BLACK(@)", 0
	player_white 	db "WHITE(o)", 0

	over			db "   _______________________", 0
	over2			db " /                         \", 0
	over3			db "|         GAME OVER!        |", 0
	over4			db " \ _______________________ /", 0
	over_black		db "BLACK won", 0
	over_white		db "WHITE won", 0
	over_draw 		db "DRAW", 0
	over_prompt     db "Press any key to finish the game.", 0

	sure			db "Are you sure you want to exit? [y/n]"
	sure_end        db 0 ; used to get sure string length

	input 			db "Enter your move (ex: a3, ONLY LOWERCASE, ESC to cancel): __", 0
	input_end 		db 0 ; used to get input string length
	bad_move_input	db "BAD_MOVE: Input, X coord = (a-h); y coord = (1-8). Enter to input again", 0
	already_placed  db "BAD_MOVE: There is already a placed piece at your coords. Enter to input again", 0
	invalid_move  	db "BAD_MOVE: Coordinates are correct, but they don't respect the game's rules. Check <HELP>. Enter to input again.", 0


	help_title		db "HELP MENU", 0
	about_title		db "ABOUT", 0

	about_app  		db "This program has been developed for the CSE1400 Lab Game Assignment by Bogdan Stanciu. It uses ncurses as a backend for the terminal user interface and libc because ncurses requires it.", 0 
	about_app_2 	db "It was been programmed using the NASM language.", 0
	about_app_3 	db "Copyright (c) 2024 - Bogdan Stanciu (wowvain-dev)", 0
	help_link 		db "For a more complete description of the game, I recommend https://www.worldothello.org/about/about-othello/othello-rules/official-rules/english", 0
	help_info_1 	db "A move consists of placing a disc corresponding to your assigned color and flipping all the discs between the placed ones and the first disc that already has your color in any of the 8 directions (you cannot skip over blank cells).", 0
	help_info_2 	db "1. Black always moves first", 0
	help_info_3 	db "2. If on your turn you cannot flip at least one opposing disc, your turn is forfeited and your opponent moves again. If there is any move available, you are not allowed to skip your turn.", 0
	help_info_4 	db "3. Players may not skip over their own color discs in order to outflank an opposing disc. (so you only flip the discs until the FIRST disc of your color in every direction)", 0
	help_info_5		db "4. Discs may only be outflanked as a direct result of a move, so you don't recursively check for each disk you flipped if they also outflank other discs."
	help_info_6 	db "5. All outflanked discs must be flipped, even if it could be in the player's disadvantage.", 0
	help_info_7 	db "6. Once a disc is placed, it can never be moved, only flipped.", 0
	help_info_8 	db "7. When neither player has a legal move left, the game ends.", 0
	help_info_9 	db "NOTE: It is possible (and likely) for a game to end before all 64 squares are filled.", 0

	menu_controls	db "Q - Go back to game", 0
		

section .text
    global main      ; Define the entry point as 'main'

    extern initscr   ; NCurses function to initialize screen
    extern printw    ; NCurses function to print text
    extern refresh   ; NCurses function to refresh screen
    extern getch     ; NCurses function to wait for input
    extern endwin    ; NCurses function to end NCurses mode
	extern mvprintw  
	extern move
	extern clrtoeol
	extern clear

main:
	push rbp
	mov rbp, rsp

	; Initialize NCurses
    call initscr

	; Clearing the board buffer
	call clear_board

	call game_loop

    ; End NCurses mode
    call endwin
	mov rsp, rbp
	pop rbp

    ; Exit the program
mov rax, 60        ; syscall: exit
xor rdi, rdi       ; status: 0
syscall

draw_walls:
	push rbp
	mov rbp, rsp

	mov rdx, walls
	call mvprintw
		
	mov rsp, rbp
	pop rbp
ret

draw_separator:
	push rbp
	mov rbp, rsp

	mov rdx, row_separator
	call mvprintw

	mov rsp, rbp
	pop rbp
ret

draw_board:
	push rbp
	mov rbp, rsp

	push r12
	push r13	
	push r14
	push r15
		
	mov r12, 2
	mov r13, 2
	
	.loop:
		mov rdi, r12
		mov rsi, r13
		call draw_separator	
		add r12, 1
		mov rdi, r12
		mov rsi, r13
		call draw_walls	
		add r12, 1
		mov rdi, r12
		mov rsi, r13
		call draw_walls	
		add r12, 1
		mov rdi, r12
		mov rsi, r13
		call draw_walls	
		add r12, 1
		cmp r12, 34
	jl draw_board.loop

	mov rdi, 34
	mov rsi, 2
	call draw_separator

	mov r14, 4
	mov r13, 1
	mov r12, 7
	.loop_coords:
		mov rdi, r14	
		mov rsi, 0
		mov rdx, int_format	
		mov rcx, r13
		call mvprintw
			
		mov rsi, r12
		mov rdi, 1
		mov rdx, char_format
		mov r8, r13
		add r8, 64
		mov rcx, r8
		call mvprintw
			
		add r13, 1	
		add r12, 10
		add r14, 4
		cmp r13, 8
	jle draw_board.loop_coords

	mov rdi, 38
	mov rsi, 2
	mov rdx, player
	cmp byte [current_move], 2
	je draw_board.black_move
	cmp byte [current_move], 1
	je draw_board.white_move
	.black_move:
		mov rcx, player_black
		call mvprintw
		jmp draw_board.go_pieces
	.white_move:
		mov rcx, player_white
		call mvprintw
		jmp draw_board.go_pieces

	.go_pieces:

	call draw_pieces		

	pop r15
	pop r14
	pop r13
	pop r12

	mov rsp, rbp
	pop rbp
ret

draw_pieces:
	push rbp
	mov rbp, rsp

	push r12
	push r13

	mov r12, 0
	.loop_rows:
		mov r13, 0
		.loop_cols:
			mov rdi, r13
			mov rsi, r12
			call draw_cell	
			add r13, 1		
			cmp r13, 8
		jl .loop_cols
		add r12, 1
		cmp r12, 8	
	jl .loop_rows

	

	call draw_menu

	pop r13
	pop r12
	
	mov rsp, rbp 
	pop rbp
ret

clear_board:
	push rbp
	mov rbp, rsp

	mov rcx, 0
	.loop:
		mov byte [board + rcx], 0
			
		add rcx, 1
		cmp rcx, 64
	jl clear_board.loop

	mov rsp, rbp
	pop rbp
	ret

; The function that draws the value of a specific cell
; params:
;		- Y_coord (RDI) 
;		- X_coord (RSI)
draw_cell:
	push rbp
	mov rbp, rsp

	push r12
	push r13

	mov rax, rdi
	shl rax, 3
	add rax, rsi

	movzx r12, byte [board + rax]

	cmp r12, 0
	je draw_cell.epilogue

	mov rax, 4
	mul rdi
	mov rdi, rax

	mov rax, 10
	mul rsi	
	mov rsi, rax


	add rsi, 7
	add rdi, 4



	cmp r12, 1
	je draw_cell.white

	cmp r12, 2
	je draw_cell.black
	.white:
		mov rdx, white_piece	
		jmp draw_cell.print	
	.black:
		mov rdx, black_piece 	
		jmp draw_cell.print
	.print:
	call mvprintw
	
	.epilogue:
	pop r13
	pop r12

	mov rsp, rbp	
	pop rbp
	ret


draw_menu:
	push rbp
	mov rbp, rsp
		
	push r12
	push r13
	push r14
	push r15

	mov rdi, 7
	mov rsi, 95
	mov rdx, title
	call mvprintw

	mov rdi, 10 
	mov rsi, 90
	mov rdx, keybinds
	call mvprintw

	mov rdi, 11
	mov rsi, 92
	mov rdx, i_enter
	call mvprintw

	mov rdi, 12
	mov rsi, 92
	mov rdx, f1_help
	call mvprintw

	mov rdi, 13
	mov rsi, 92
	mov rdx, f2_about
	call mvprintw

	mov rdi, 14
	mov rsi, 92
	mov rdx, q_exit
	call mvprintw

	mov rdi, 17
	mov rsi, 90
	mov rdx, score
	call mvprintw

	xor r12, r12
	xor r13, r13
	xor r14, r14
	xor r15, r15
	.score_loop:
		movzx r14, byte [board + r15]		
		cmp r14, 1
		je draw_menu.white
		cmp r14, 2
		je draw_menu.black
		jmp draw_menu.end
		.white:
			add r12, 1	
			jmp draw_menu.end
		.black:
			add r13, 1
			jmp draw_menu.end
		.end:
		inc r15
		cmp r15, 64
	jl draw_menu.score_loop

	mov byte [white_score], r12b
	mov byte [black_score], r13b
	
	mov rdi, 18
	mov rsi, 92
	call move
	call clrtoeol

	mov rdi, 18
	mov rsi, 92
	mov rdx, w_count
	xor rcx, rcx
	movzx rcx, r12b
	call mvprintw

	mov rdi, 19
	mov rsi, 92
	call move
	call clrtoeol

	mov rdi, 19
	mov rsi, 92
	mov rdx, b_count
	xor rcx, rcx
	movzx rcx, r13b
	call mvprintw

	pop r15
	pop r14
	pop r13
	pop r12

	mov rsp, rbp
	pop rbp
	ret

game_loop:
	push rbp
	mov rbp, rsp

	; Initial board state
	mov byte [board + (3*8+3)], 1
	mov byte [board + (3*8+4)], 2
	mov byte [board + (4*8+3)], 2
	mov byte [board + (4*8+4)], 1

	.loop:
    	; Draw the Othello board
		call draw_board

    	; Refresh the screen to show the board
    	call refresh

		mov r8b, byte [white_score]
		mov r9b, byte [black_score]

		add r8b, r9b
		cmp r8b, 64
		jge game_loop.over

		call valid_moves
		cmp rax, 0
		jne game_loop.keep_round

		inc byte [skips]
		cmp byte [skips], 2,
		jge game_loop.over

		call switch_player
		jmp game_loop.loop

		.keep_round:
		mov rdi, 39
		mov rsi, 2
		call move

    	; Wait for a key press
    	call getch

		cmp rax, 80
		jne game_loop.help
		call help_menu
		jmp game_loop.loop

		.help:
		cmp rax, 112
		jne game_loop.help_skip
		call help_menu
		jmp game_loop.loop

		.help_skip:

		cmp rax, 79
		jne game_loop.about
		call about_menu
		jmp game_loop.loop

		.about:
		cmp rax, 111
		jne game_loop.skip_menu
		call about_menu
		jmp game_loop.loop

		.skip_menu:
		cmp rax, 73
		je game_loop.input_move
		cmp rax, 105
		je game_loop.input_move

		cmp rax, 81
		je game_loop.ask_exit
		cmp rax, 113
		je game_loop.ask_exit
	jmp game_loop.loop	
	.over:
	mov rdi, 50
	mov rsi, 25
	mov rdx, over
	call mvprintw
	mov rdi, 51
	mov rsi, 25
	mov rdx, over2
	call mvprintw
	mov rdi, 52
	mov rsi, 25
	mov rdx, over3
	call mvprintw
	mov rdi, 53
	mov rsi, 25
	mov rdx, over4
	call mvprintw

	xor r12, r12
	xor r13, r13
	mov r12b, byte [black_score]
	mov r13b, byte [white_score]
	mov r10, over_black
	mov r11, over_white
	mov r8, over_draw
	mov rdi, 54
	mov rsi, 35
	cmp r12b, r13b
	cmovl rdx, r11
	cmovg rdx, r10
	cmove rdx, r8
	call mvprintw

	mov rdi, 57
	mov rsi, 25
	mov rdx, over_prompt
	call mvprintw

	
	call getch
	jmp game_loop.exit

	.input_move:
	call get_input
	jmp game_loop.loop

	.ask_exit:
	mov rdi, 40
	mov rsi, 2
	mov rdx, sure
	call mvprintw

	.repeat_exit:
	mov rdi, 40
	mov rsi, sure_end - sure
	add rsi, 2
	call move
	call getch
	
	; y / Y
	cmp rax, 121
	je game_loop.exit
	cmp rax, 089
	je game_loop.exit
	
	; n / N
	cmp rax, 110
	jne game_loop.lower_n

		mov rdi, 40
		mov rsi, 0
		call move
		call clrtoeol

	jmp game_loop.loop
	
	.lower_n:
	cmp rax, 78
	jne game_loop.repeat_exit

		mov rdi, 40
		mov rsi, 0
		call move
		call clrtoeol

	jmp game_loop.loop

	.exit:
	mov rsp, rbp
	pop rbp
ret

get_input:
	push rbp
	mov rbp, rsp

	push r12
	push r13
	push r14
	push r15

	.retry:
	mov rdi, 39
	mov rsi, 0
	call clrtoeol

	mov rdi, 39
	mov rsi, 2
	mov rdx, input
	call mvprintw

	mov rdi, 39
	mov rsi, input_end - input - 1
	call move

	call getch
	cmp rax, 27
	je get_input.exit
	cmp rax, 97
	jl get_input.bad_input
	cmp rax, 104
	jg get_input.bad_input

	; converting coord to number
	sub rax, 97
	mov r12, rax	

	call getch
	cmp rax, 27
	je get_input.exit
	cmp rax, 49
	jl get_input.bad_input
	cmp rax, 56
	jg get_input.bad_input

	; converting coord to number
	sub rax, 49
	mov r13, rax
	
	jmp get_input.good_input

	.bad_input:
		mov rdi, 39
		mov rsi, 2
		mov rdx, bad_move_input
		call mvprintw
		call getch
		cmp rax, 10
		je get_input.retry
	jmp get_input.bad_input

	.already_placed:
		mov rdi, 39
		mov rsi, 2
		mov rdx, already_placed
		call mvprintw
		call getch
		cmp rax, 10
		je get_input.retry
	jmp get_input.already_placed

	.invalid_move:
		mov rdi, 39
		mov rsi, 2
		mov rdx, invalid_move
		call mvprintw
		call getch
		cmp rax, 10
		je get_input.retry
	jmp get_input.invalid_move

	.good_input:
	xor r14, r14
	movzx r14, byte [board+(r13*8 + r12)]
	cmp r14, 0
	jne get_input.already_placed

	; at this point we are sure the input is valid
	; from a coordinate or pre-placement perspective,
	; now lets check if is a valid move
	mov rdi, r12	
	mov rsi, r13
	call validate_move
	cmp rax, 0
	je get_input.invalid_move

	cmp rax, 1
	jne get_input.switch_player

	mov r14b, byte [current_move]	
	mov byte[board + (rsi*8 + rdi)], r14b

	.switch_player:
	call switch_player
	
	.exit:
	mov rdi, 39
	mov rsi, 0
	call move
	call clrtoeol

	pop r15
	pop r14
	pop r13
	pop r12

	mov rsp, rbp
	pop rbp
ret

; Input: col (rdi), row (rsi), direction_index (rdx)
; Output: valid_move (rax), if valid move found, flips pieces along the way
check_direction:
	push rbp
	mov rbp, rsp

	push r12 
	push r13
	push r14
	push r15

	mov r15, 0 ; start with invalid assumption

	; Load directions
	movzx r12, byte [directions + rdx * 2]
	movzx r13, byte [directions + (rdx * 2 + 1)]

	mov r8, rsi ; current row
	mov r9, rdi ; current col

	.check_loop:
		cmp r13, 0xff
		je check_direction.neg_r13
		add r8, r13 ; next row in the given direction
		jmp check_direction.r12

		.neg_r13:
		sub r8, 1

		.r12:
		cmp r12, 0xff
		je check_direction.neg_r12
		add r9, r12 ; next col in the given direction
		jmp check_direction.borders
		.neg_r12:
		sub r9, 1

		.borders:
		; checking if we reach the end of the board
		cmp r8, 0
		jl check_direction.end_check
		cmp r8, 7
		jg check_direction.end_check

		cmp r9, 0
		jl check_direction.end_check
		cmp r9, 7
		jg check_direction.end_check

		movzx r14, byte [board + (r8*8 + r9)]

		cmp r14b, byte [current_move]
		je check_direction.flip_pieces

		mov r10, 0
		cmp r14b, 0
		cmove r15, r10
		je check_direction.end_check

		mov r11, 1
		cmp r14b, byte [opponent_move]
		cmove r15, r11
		je check_direction.check_loop

		jmp check_direction.end_check

	.flip_pieces:
		cmp r13, 0xff
		je check_direction.neg_r13_2
		sub r8, r13		
		jmp check_direction.r12_2
		.neg_r13_2:
		add r8, 1

		.r12_2:
		cmp r12, 0xff
		je check_direction.neg_r12_2
		sub r9, r12
		jmp check_direction.borders_2
		.neg_r12_2:
		add r9, 1

		.borders_2:
		cmp r8, rsi
		jne check_direction.flip
		cmp r9, rdi
		jne check_direction.flip
		
		;xor r14, r14
		;movzx r14, byte [current_move]
		;mov [board + (r8*8 + r9)], r14b
		jmp check_direction.end_check

		.flip:
		xor r14, r14
		movzx r14, byte [current_move]
		mov [board + (r8*8 + r9)], r14b

	jmp check_direction.flip_pieces

	.end_check:
	mov rax, r15
	pop r15
	pop r14
	pop r13
	pop r12

	mov rsp, rbp
	pop rbp
ret 

; Input: col (rdi), row (rsi)
; Output: valid_move (rax), if valid move found, flips pieces along the way
validate_move:
	push rbp
	mov rbp, rsp

	push r12
	push r13
	push r14
	push r15

	mov rdx, 0 ; the direction index
	mov r15, 0 ; assume invalid move

	.check_next_dir:
		call check_direction

		cmp rax, 1
		cmove r15, rax

		inc rdx
		cmp rdx, 8
	jl validate_move.check_next_dir
	

	mov rax, r15

	pop r15
	pop r14
	pop r13
	pop r12

	mov rsp, rbp
	pop rbp
ret 

validate_move_noflip:
	push rbp
	mov rbp, rsp

	push r12
	push r13
	push r14
	push r15

	mov rdx, 0 ; the direction index
	mov r15, 0 ; assume invalid move

	.check_next_dir:
		call check_direction_noflip

		cmp rax, 1
		cmove r15, rax
		je validate_move_noflip.exit

		inc rdx
		cmp rdx, 8
	jl validate_move_noflip.check_next_dir
	
	.exit:
	mov rax, r15

	pop r15
	pop r14
	pop r13
	pop r12

	mov rsp, rbp
	pop rbp
ret 

; Input: col (rdi), row (rsi), direction_index (rdx)
; Output: valid_move (rax), if valid move found, flips pieces along the way
check_direction_noflip:
	push rbp
	mov rbp, rsp

	push r12 
	push r13
	push r14
	push r15

	mov r15, 0 ; start with invalid assumption

	; Load directions
	movzx r12, byte [directions + rdx * 2]
	movzx r13, byte [directions + (rdx * 2 + 1)]

	mov r8, rsi ; current row
	mov r9, rdi ; current col

	.check_loop:
		cmp r13, 0xff
		je check_direction_noflip.neg_r13
		add r8, r13 ; next row in the given direction
		jmp check_direction_noflip.r12

		.neg_r13:
		sub r8, 1

		.r12:
		cmp r12, 0xff
		je check_direction_noflip.neg_r12
		add r9, r12 ; next col in the given direction
		jmp check_direction_noflip.borders
		.neg_r12:
		sub r9, 1

		.borders:
		; checking if we reach the end of the board
		cmp r8, 0
		jl check_direction_noflip.end_check
		cmp r8, 7
		jg check_direction_noflip.end_check

		cmp r9, 0
		jl check_direction_noflip.end_check
		cmp r9, 7
		jg check_direction_noflip.end_check

		movzx r14, byte [board + (r8*8 + r9)]

		cmp r14b, byte [current_move]
		je check_direction_noflip.end_check

		mov r10, 0
		cmp r14b, 0
		cmove r15, r10
		je check_direction_noflip.end_check

		mov r11, 1
		cmp r14b, byte [opponent_move]
		cmove r15, r11
		je check_direction_noflip.check_loop

		jmp check_direction.end_check

	; .flip_pieces:
	; 	cmp r13, 0xff
	; 	je check_direction.neg_r13_2
	; 	sub r8, r13		
	; 	jmp check_direction.r12_2
	; 	.neg_r13_2:
	; 	add r8, 1

	; 	.r12_2:
	; 	cmp r12, 0xff
	; 	je check_direction.neg_r12_2
	; 	sub r9, r12
	; 	jmp check_direction.borders_2
	; 	.neg_r12_2:
	; 	add r9, 1

	; 	.borders_2:
	; 	cmp r8, rsi
	; 	jne check_direction.flip
	; 	cmp r9, rdi
	; 	jne check_direction.flip
		
	; 	;xor r14, r14
	; 	;movzx r14, byte [current_move]
	; 	;mov [board + (r8*8 + r9)], r14b
	; 	jmp check_direction.end_check

	; 	.flip:
	; 	xor r14, r14
	; 	movzx r14, byte [current_move]
	; 	mov [board + (r8*8 + r9)], r14b
	;jmp check_direction.flip_pieces

	.end_check:
	mov rax, r15
	pop r15
	pop r14
	pop r13
	pop r12

	mov rsp, rbp
	pop rbp
ret 


; Input: none
; Output: valid_moves (RAX): return whether the current 
; player has any valid moves.
valid_moves:
	push rbp
	mov rbp, rsp

	push r12
	push r13
	push r14
	push r15

	mov r15, 0	

	mov r12, 0
	.loop:
		mov r13, 0
		.loop_cols:
			mov rsi, r12
			mov rdi, r13
			call validate_move_noflip

			cmp rax, 1
			cmove r15, rax
			je valid_moves.exit
			
			inc r13
			cmp r13, 8
		jl valid_moves.loop_cols
		inc r12
		cmp r12, 8
	jl valid_moves.loop

	.exit:

	pop r15
	pop r14
	pop r13
	pop r12

	mov rsp, rbp
	pop rbp
ret


; swapts the values of current_move and opponent_move
switch_player:
	push rbp
	mov rbp, rsp

	xor r10, r10
	xor r11, r11

	mov r10b, byte [current_move]
	mov r11b, byte [opponent_move]

	mov byte [current_move], r11b
	mov byte [opponent_move], r10b

	mov rsp, rbp
	pop rbp
ret


help_menu:
	push rbp
	mov rbp, rsp
	
	call clear

	mov rdi, 2
	mov rsi, 50
	mov rdx, help_title
	call mvprintw

	mov rdi, 4
	mov rsi, 2
	mov rdx, help_link
	call mvprintw

	mov rdi, 7
	mov rsi, 2
	mov rdx, help_info_1
	call mvprintw

	mov rdi, 11
	mov rsi, 4
	mov rdx, help_info_2
	call mvprintw

	mov rdi, 13
	mov rsi, 4
	mov rdx, help_info_3
	call mvprintw

	mov rdi, 15
	mov rsi, 4
	mov rdx, help_info_4
	call mvprintw

	mov rdi, 17
	mov rsi, 4
	mov rdx, help_info_5
	call mvprintw

	mov rdi, 19
	mov rsi, 4
	mov rdx, help_info_6
	call mvprintw

	mov rdi, 21
	mov rsi, 4
	mov rdx, help_info_7
	call mvprintw

	mov rdi, 23
	mov rsi, 4
	mov rdx, help_info_8
	call mvprintw

	mov rdi, 25
	mov rsi, 4
	mov rdx, help_info_9
	call mvprintw

	mov rdi, 50
	mov rsi, 25
	mov rdx, menu_controls
	call mvprintw

	call getch

	call clear

	mov rsp, rbp
	pop rbp
ret

about_menu:
	push rbp
	mov rbp, rsp

	call clear

	mov rdi, 2
	mov rsi, 50
	mov rdx, about_title
	call mvprintw

	mov rdi, 3
	mov rsi, 35
	mov rdx, about_app_3
	call mvprintw

	mov rdi, 8
	mov rsi, 2
	mov rdx, about_app
	call mvprintw

	mov rdi, 10
	mov rsi, 2
	mov rdx, about_app_2
	call mvprintw

	mov rdi, 50
	mov rsi, 25
	mov rdx, menu_controls
	call mvprintw

	call getch

	call clear

	mov rsp, rbp
	pop rbp
ret
