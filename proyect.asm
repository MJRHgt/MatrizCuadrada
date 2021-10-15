GotoXY Macro  X,Y
	Mov Dl,X
	Mov Dh,y
	Xor Bh,Bh	;limpiar el registro BH
	Mov Ah,02h	;Se mueve el código de función de la interrupción 10h
	Int 10h		;Se llama a la interrupción 10H
ENDM GotoXY
Mapeo Macro I,J,Filas,Columna,Tamano
	Mov AL,I
	Mov Bl,Filas
	Mul Bl
	Mov BL,Tamano
	Mul BL
	Mov CL,AL
	Mov AL,J
	Mov BL,Tamano
	Mul BL
	Add AL,CL
endm
.model small
.stack
.data
	positionX		db 0h
	positionY		db 0h
	direction		db 0h
	movements		db 0h
    points      dw 0h    							;cantidad de puntos a dibujar
    instruction     db 'Ingrese un numero $'
	errorString		db 'cantidad no valida $'
	position 		db 'Coordenada $'
	symbol			db '* $'
	I DB 1												; Contador de filas
    J DB 1												; Contador de columnas
    K DB 1												; Posicion 
	Columna DB 1
    Fila DB 1
    X DB 1
    Y DB 1
.code
programa:
    mov ax, @data
    mov ds, ax
	;variables
	mov direction, 0h
	mov movements, 0h
	mov positionX, 0h
	mov positionY, 0h
	mov points, 03h
	imprimirinstrucciones:
		lea dx, instruction
		call printString
		call printNum
	;---------------------------leer cantidad de puntos-------------------------------------
	reading:
		;centenas
		mov bl, 64h										;*100
		call readDigit
		mov points, ax
		;decenas
		mov bl, 0ah										;*10
		call readDigit
		add points, ax
		;unidades
		mov bl, 01h										;*1
		call readDigit
		add points, ax
		call printNum    
	
	;evaluar rango
	mov ax, points
	cmp ax, 64h
	jg outRange											;si el points - 100 >=  0 
	cmp ax, 0h
	jne inRange											;si el points - 100 <=  0 
	outRange:
		lea dx, errorString
		call printString
		call printNum
		lea dx, instruction
		call printString
		jmp reading
	inRange:
	call matriz
	;imprimir primer punto
	lea dx, position
	call printString
	mov ax, 01h
	mov bl, 64h
	call numPrint
	mov dl, 20h
	call printChar
	mov dl, 28h
	call printChar
	mov ax, 0h
	mov bl, 01h
	call numPrint
	mov dl, 2ch
	call printChar
	mov ax, 0h
	mov bl, 01h
	call numPrint
	mov dl, 29h
	call printChar
	call printNum
	
	cmp points, 01h
	je spiral
	mov bh, 01h
	mov cx, 0h
	ciclowhile:
		cmp direction, 0h 								;direction = 0? (derecha)
		je aumentarmovs
		cmp direction, 2h 								;direction = 2? (izquierda)
		je aumentarmovs
		jne setcx
		aumentarmovs:	  								;aumentar movs si va para derecha o izquierda
		inc movements
		setcx:
		mov cl, movements
		ciclofor:
			cmp direction, 0h
			je right
			cmp direction, 01h
			je up
			cmp direction, 02h
			je left
			;si no es ninguna de las anteriores, es abajo
			dec positionY
			jmp continuar
			right:
				inc positionX
				jmp continuar
			up:
				inc positionY
				jmp continuar
			left:
				dec positionX
				jmp continuar
			continuar:
			inc bh
			;imprimir punto y coordenada
			call imprimirptocoordenada
			mov ax, points
			cmp al, bh
			jg continue
			mov cx, 1h
			continue:
			loop ciclofor
		inc direction
		xor ah, ah
		mov al, direction
		mov bl, 04h
		div bl											;direction % 4 en ah
		mov direction, ah
		mov ax, points
		cmp al, bh
		jg ciclowhile
	spiral:
	jmp finalizar
	
	;------------------------------------------------------------------------------------------------------------------------------------ 
	matriz proc near 
		xor ax,ax
		xor bx,bx
		xor cx,cx
		xor dx,dx
		MOV BX, points
		XOR CX, CX
		calcular:
			MUL CX
			MOV AX, CX
			CMP AX, BX
			JA salirMayor
			JB menor
			JC igual 
		menor:
			INC CX
			MOV AX, CX
			MUL CX
			CMP AX, BX
			JA salirMayor
			JE igual
			JB menor
		salirMayor:
			DEC CX
			JMP igual
		igual: 										;Resultado queda en CX
			hlt
		mov i, cl
        mov j, cl
        Mov Y,00
        Mov Fila,10
		CicloFilas:
			Mov X,00
			Mov Columna, 30
		CicloColumnas:
			MOV DX, offset symbol
    		CALL PrintLine
			Inc Columna
			Inc Columna
			Inc Columna
			Inc X
			Mov CL,X
			cmp CL,J
			jl CicloColumnas
			call printCR
			inc Y       
			inc Fila
			Mov CL,Y
			cmp CL,I
			jl CicloFilas
		ret
	matriz endp

	printCR proc near
		MOV DL, 0Ah                     				; imprime Enter
		MOV AH, 02h                      
		int 21h
		ret
	printCR endp
	
	PrintLine proc near 
		MOV AH, 09h                     				;Interupcion para imprimir cadenas
		INT 21h                         				;Ejecuta la interrupcion
		ret
	PrintLine endp
	
	imprimirptocoordenada proc near
	lea dx, position
	call printString									;"punto: "
	xor ah, ah
	mov al, bh
	mov bl, 64h
	call numPrint										;punto
	mov dl, 20h
	call printChar										;" "
	mov dl, 28h
	call printChar										;"("
	xor ah, ah
	mov al, positionX
	cmp positionX, 0h
	jge sinsigno1
	mov dl, 2dh				
	call printChar										;"-"
	xor ax, ax
	sub al, positionX
	sinsigno1:
	mov bl, 01h
	call numPrint										;x
	mov dl, 2ch
	call printChar										;","
	xor ah, ah
	mov al, positionY
	cmp positionY, 0h
	jge sinsigno2
	mov dl, 2dh				
	call printChar										;"-"
	xor ax, ax
	sub al, positionY
	sinsigno2:
	mov bl, 01h
	call numPrint										;y
	mov dl, 29h
	call printChar										;")"
	call printNum
	ret
	imprimirptocoordenada endp
	
	numPrint proc near
		ciclo:
			div bl										;cociente en al
			mov dl, al 									;preparar para imprimir
			add dl, 30h
			mov dh, ah 									;mover residuo a dh
			call printChar
			xor ah, ah
			mov al, bl 									;poner bl(potencia de 10) en ax
			mov bl, 0ah
			div bl										;dividir potencia de 10 entre 10
			mov bl, al 									;resultado en bl
			mov al, dh 									;mover residuo de dl a al
			cmp bl, 01h
			jg ciclo
			jl fin
			mov dl, al
			add dl, 30h
			call printChar
			fin:
	ret
	numPrint endp
		
	printChar proc near
	mov ah, 02h
	int 21h
	ret
	printChar endp
	
	readDigit proc near
	mov ah, 01h											;el valor leído debería estar en al
    int 21h
	sub al, 30h
	mul bl												;en bl está la potencia de 10 por la que se multiplicará el digito
	ret
	readDigit endp
	
	printString proc near
	mov ah, 09h
	int 21h
	ret
	printString endp
	
	printNum proc near
	mov dl, 0ah
	mov ah, 02h
	int 21h
	ret
	printNum endp
	
	finalizar:
	mov ah, 4ch											;interrupcion
	int 21h												;ejecuta	
	end programa