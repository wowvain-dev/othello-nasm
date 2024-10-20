; Copyright 2024 - wowvain-dev (Bogdan Stanciu)
; MIT License


section .bss
	board resb 64 
	input resb 2

section .data
	walls 			db "|         |         |         |         |         |         |         |         |", 0 	
	row_separator	db "+---------+---------+---------+---------+---------+---------+---------+---------+", 0
	black_piece 	db '@', 0
	white_piece 	db 'o', 0

	int_format		db "%d", 0
	char_format 	db "%c", 0		
	title 			db "Othello", 0
	nl 				db "\n", 0
	score 			db "Score:", 0
	b_count 		db "Black pieces: %d", 0
	w_count 		db "White pieces: %d", 0
	keybinds 		db "Keybinds:", 0 
	f1_help 		db "F1 - Help", 0
	f2_about 		db "F2 - About", 0, 
		

section .text
    global main      ; Define the entry point as 'main'

    extern initscr   ; NCurses function to initialize screen
    extern printw    ; NCurses function to print text
    extern refresh   ; NCurses function to refresh screen
    extern getch     ; NCurses function to wait for input
    extern endwin    ; NCurses function to end NCurses mode
	extern mvprintw  

main:
	push rbp
	mov rbp, rsp

	; Initialize NCurses
    call initscr

	call clear_board

	mov byte [board + (4 * 8 + 3)], 2

    ; Draw the Othello board
	call draw_board


    ; Refresh the screen to show the board
    call refresh

	mov byte [board + (4 * 8 + 4)], 1
	call draw_pieces

	call refresh

    ; Wait for a key press
    call getch

	;call game_loop

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
	mov r13, 0
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
		add r8, 65
		mov rcx, r8
		call mvprintw
			
		add r13, 1	
		add r12, 10
		add r14, 4
		cmp r13, 8
	jl draw_board.loop_coords

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
	mov rdx, f1_help
	call mvprintw

	mov rdi, 12
	mov rsi, 92
	mov rdx, f2_about
	call mvprintw

	mov rdi, 15
	mov rsi, 90
	mov rdx, score
	call mvprintw

	mov rcx, 0
	mov r12, 0
	mov r13, 0
	.score_loop:
		xor rdi, rdi
		movzx rdi, byte [board + rcx]		
		cmp rdi, 1
		je draw_menu.white
		cmp rdi, 2
		je draw_menu.black
		jmp draw_menu.end
		.white:
			add r12, 1	
			jmp draw_menu.end
		.black:
			add r13, 1
			jmp draw_menu.end
		.end:
		add rcx, 1	
		cmp rcx, 64
	jl draw_menu.score_loop
	
	mov rdi, 16
	mov rsi, 92
	mov rdx, w_count
	mov rcx, r12
	call mvprintw

	mov rdi, 17
	mov rsi, 92
	mov rdx, b_count
	mov rcx, r13
	call mvprintw

	pop r13
	pop r12

	mov rsp, rbp
	pop rbp
	ret

game_loop:

