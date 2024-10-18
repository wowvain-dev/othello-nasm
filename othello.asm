section .bss
	board resb 64 

section .data
    hello_msg db "Hello, NCurses!", 0  ; Null-terminated message to display
		walls db         "|         |         |         |         |         |         |         |         |", 0 	
		row_separator db "+---------+---------+---------+---------+---------+---------+---------+---------+", 0

		black_piece db '@', 0
		white_piece db 'o', 0

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

		call draw_pieces		

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
