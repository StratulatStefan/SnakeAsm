include masm32rt.inc

XMargin      EQU     118
YMargin      EQU     30
MainColor    EQU     00Fh
ESCAPE       EQU     27
Catch        PROTO C nr        :DWORD
RotateHead   PROTO C key       :DWORD
FINAL        MACRO
					 mov bottom.x,0
					 mov bottom.y,30
					 invoke SetConsoleTextAttribute,StdOutput,MainColor
					 invoke SetConsoleCursorPosition,StdOutput,DWORD PTR bottom
					 printf("\n")
			 EndM
ReloadSnake  MACRO
					 mov snake.text,' '
					 call Show
					 mov snake.text,'O'
             EndM
FOOD         STRUCT
					 position COORD {15,15}
					 text     DWORD '+'
					 color    DWORD 00Dh
FOOD         EndS

SNAKE        STRUCT
					 position   COORD {29,12}
					 text       BYTE 'O',0
					 color      DWORD 00Ch     
					 dimension  DWORD 1
SNAKE        EndS
.data
	StdOutput          DWORD  ?
	StdInput           DWORD  ?
	bottom             COORD  {0,0}
	food               FOOD   {}
	snake              SNAKE  {}
	positionsForFood   COORD  {15,13},{19,21},{100,28},{50,17},{90,23},{80,12},{15,28},{89,12},{85,13},{21,21},{23,5},{54,12}
	CatchColor         DWORD  00Dh
	rotLeft            BYTE   "O\n"
.code
	start:
		invoke GetStdHandle,STD_OUTPUT_HANDLE
		mov StdOutput,EAX
		invoke GetStdHandle,STD_INPUT_HANDLE
		mov StdInput,EAX
		call Show
		XOR EDI,EDI
		.while TRUE
			PUSH EDI
			call crt__getch
			POP EDI
			switch EAX
				case 'a','A'
					.if snake.position.x > 2
						ReloadSnake
						SUB snake.position.x,1
						;invoke RotateHead,EAX
					.endif
					call Show
				case 'd','D'
					.if snake.position.x < XMargin - 2
						ReloadSnake
						ADD snake.position.x,1
						;invoke RotateHead,EAX
					.endif
					call Show
				case 'w','W'
					.if snake.position.y > 1
						ReloadSnake
						SUB snake.position.y,1
						;invoke RotateHead,EAX
					.endif
					call Show
				case 's','S'
					.if snake.position.y < YMargin - 2
						ReloadSnake
						ADD snake.position.y,1
						;invoke RotateHead,EAX

					.endif
					call Show
				.break .if EAX == ESCAPE
			endsw
			invoke Catch,EDI
			.if EAX == 1
				INC EDI
			.endif
		.endw
		inkey
		exit
		Show PROC
			;cls
			call ShowBorders				
			invoke SetConsoleCursorPosition,StdOutput,DWORD PTR food.position
			invoke SetConsoleTextAttribute,StdOutput,food.color
			printf("%s",addr food.text)
			invoke SetConsoleCursorPosition,StdOutput,DWORD PTR snake.position
			invoke SetConsoleTextAttribute,StdOutput,snake.color
			MOV EBX,snake.dimension
			.while EBX > 0
				PUSH EBX
				.if EBX == snake.dimension
					invoke SetConsoleTextAttribute,StdOutput,00Bh
				.else
					invoke SetConsoleTextAttribute,StdOutput,snake.color
				.endif
				printf("%s",addr snake.text)
				POP EBX
				DEC EBX
			.endw
			FINAL	
			Ret
		Show EndP
		
		Catch PROC C nr:DWORD
			XOR EBX,EBX
			XOR ECX,ECX
			MOV BX,food.position.x
			MOV CX,food.position.y
			MOV EDI,nr
			.if snake.position.x == BX && snake.position.y == CX 
				INC snake.dimension
				MOV EAX,positionsForFood[EDI * TYPE positionsForFood]
				MOV food.position,EAX
				MOV EAX,1
				invoke SetConsoleTextAttribute,StdOutput,CatchColor
			.endif
			Ret
		Catch EndP
		
		ShowBorders PROC
			Invoke SetConsoleTextAttribute,StdOutput,00Ah
			XOR EAX,EAX
			mov bottom.y,AX
			.while AX < XMargin
				mov bottom.x,AX
				PUSH EAX
				printf("*")
				POP EAX
				PUSH EAX
				invoke SetConsoleCursorPosition,StdOutput,DWORD PTR bottom
				POP EAX
				inc EAX
			.endw
			XOR EAX,EAX
			mov bottom.x,0
			.while AX < YMargin
				MOV bottom.y,AX
				PUSH EAX
				printf("*")
				POP EAX
				PUSH EAX
				invoke SetConsoleCursorPosition,StdOutput,DWORD PTR bottom
				POP EAX
				INC EAX
			.endw
			XOR EAX,EAX
			.while AX < XMargin
				MOV bottom.x,AX
				PUSH EAX
				printf("*")
				POP EAX
				PUSH EAX
				invoke SetConsoleCursorPosition,StdOutput,DWORD PTR bottom
				POP EAX
				inc EAX
			.endw
			MOV bottom.y,0
			XOR EAX,EAX
				.while AX < YMargin
				MOV bottom.y,AX
				PUSH EAX
				printf("*")
				POP EAX
				PUSH EAX
				invoke SetConsoleCursorPosition,StdOutput,DWORD PTR bottom
				POP EAX
				INC EAX
			.endw
			Ret
		ShowBorders EndP
		
		RotateHead PROC C key:DWORD				
			Ret
		RotateHead EndP
	end start