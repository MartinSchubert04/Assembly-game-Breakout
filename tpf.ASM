.8086
.model small
.stack 100h
.data
	
	ventana_width dw 140h		;ancho (320px)
	ventana_height dw 0c8h		;alto (200px)
	ventana_limites dw 6		;checkea las colisiones antes

	tiempo db 0 				;variable de chequeo
	actividad db 1				;variable para saber si se esta jugando (1=true 0=false)
	escena db 1				;0 es el menu y 1 es el juego
	dificutad db 0
	exit db 0					;variable para cerrar el juego

	ball_inicialPos_x dw 0a0h	;pos inicial x
	ball_inicialPos_y dw 64h	;pos inicial y
	ball_x dw 0dh 				;posicion en x
	ball_y dw 0ah 				;pos en y
	ball_size dw 04h			;tamaño en pixeles
	ball_mov_x dw 02h			;velocidad horizontal
	ball_mov_y dw 05h			;velocidad vertical
	aumentaVel dw 0

	x dw 0
	y dw 0

	barra_x dw 88h
	barra_y dw 0b9h
	barra_width dw 30h
	barra_height dw 04h
	barra_inicialPos_x dw 88h 	;le resto la mitad del ancho asi queda en el medio
	barra_inicialPos_y dw 0b9h
	barra_vel dw 05h
	barra_bot_x dw 88h
	barra_bot_y dw 1bh

	vidas db 3					
	vidasAscii db '3',0ah,0dh,24h

	elegirDif db 'Eliga una dificutad',0ah,0dh,24h
	facil db '1.Facil',0ah,0dh,24h
	normal db '2.Normal',0ah,0dh,24h
	dificil db '3.Dificil',0ah,0dh,24h


	vidasTxt db 'Vidas:',0ah,0dh,24h			
	puntosTxt db 'Puntos: ',0ah,0dh,24h
	gameOverTxt	db 'Game Over',0ah,0dh,24h
	ganasteTxt db 'Ganaste!!!',0ah,0dh,24h
	menuTitle db " ___  ____  ____   ___   _   __",0ah,0dh
			  db "   | _ \|  _ \| ___| / _ \ | |_/ /",0ah,0dh
		      db "   | _ <| |/ /| ___|| /_\ ||  _ \ ",0ah,0dh
			  db "   |___/|_|\_\|____||_| |_||_| \_\",0ah,0dh,24h


	menuTitle2 db "____  _  _  _____  ", 0dh, 0ah
			   db "         |    || || ||_   _| ", 0dh, 0ah
		       db "         | || || || |  | |   ",0dh, 0ah
			   db "         |____||____|  |_|	 ",0dh, 0ah,24h
	ingreseTecla db 'Ingrese una tecla para continuar...',0dh, 0ah,24h
	restartTxt db '1. Restart',0ah,0dh,24h
	goMenuTxt db '2. Menu',0ah,0dh,24h
	exitTxt db '3.Exit game',0ah,0dh,24h
	limiteTxt db '________________________________________',0ah,0dh,24h
	opcion1 db '1.Jugar',0ah,0dh,24h
	opcion2 db '2.Instrucciones',0ah,0dh,24h
	opcion3 db '3.Exit',0ah,0dh,24h
	descripcion db 	'Objetivos: destruir todos lo bloques    para ganar.',0ah,0dh
				db 	'',0ah,0dh
				db 	'',0ah,0dh
				db 	'',0ah,0dh
				db	'Dificultades:',0ah,0dh
				db 	'',0ah,0dh
				db  'Facil: experiencia normal del juego.',0ah,0dh
				db 	'',0ah,0dh
				db  'Normal: la peota aumenta la velocidad   cada 3 bloques destruidos.',0ah,0dh
				db 	'',0ah,0dh
				db  'Dificil: mayor cantidad de bloques y    velocidades mas altas.',0ah,0dh
				db 	'',0ah,0dh
				db 	'',0ah,0dh
				db 	'',0ah,0dh
				db 	'',0ah,0dh
				db 	'',0ah,0dh
				db 	'',0ah,0dh
				db 	'',0ah,0dh
				db 	'1. Volver al menu',0ah,0dh,24h

	bloque_x dw 02h
	bloque_y dw 0

	negFlag db ?				;uso para generar numero random

	columnas dw 09h,2fh,55h,7bh,0a1h,0c7h,0edh,113h
	fila1 dw 14h
	fila2 dw 1bh
	fila3 dw 22h
	fila4 dw 29h
	

	recorreFila dw 09h

	limitesX_fila1 dw 280 dup(0)
	limitesY_fila1 dw 280 dup(0)

	block_width dw 35
	block_height dw 4

	note dw 1387 



.code
	

	main proc

	mov ax,@data
	mov ds,ax

	mov ah, 00h 				;cofiguracion de video
	mov al, 13h 				;elegir tipo de video
	int 10h 

	mov ah, 0bh 				;color fondo config 
	mov bh, 00h 
	mov bl, 00h 				;tipo color: negro
	int 10h

	call clsPantalla
	call ResetPosFun
	call intro
	mov escena,1
	
checkTiempo:

	cmp exit,01h
	je exitGameFun
	cmp escena,1
	je menuScreen
	cmp escena,03h
	je instrucScreen
	
	cmp actividad,0
	je gameOverScreen


	mov ah,2ch 					;da el tiempo interno
	int 21h

	cmp dl,tiempo 				;cheque si el tiempo es igual al anterior
	je checkTiempo
	mov tiempo, dl 				;actualizo

	call clsPantalla
	call mainBloques

	call ballMov
	call ballArt

	
	call barraMov
	call barraArt

	call clear

			;limpio pantalla

	call interfazArt
jmp checkTiempo 

	gameOverScreen:
		call gameOverMenu
	jmp checkTiempo 			;repito

	menuScreen:
		call mainMenu
		jmp checkTiempo

	instrucScreen:
		call instrucDescrip
		jmp checkTiempo
		ret
	exitGameFun:
		call exitProc
	main endp

	mainBloques proc
		xor di,di
		lea di,fila1
		call dibujarBloques
		lea di,fila2
		call dibujarBloques
		lea di,fila3
		call dibujarBloques
		lea di,fila4
		call dibujarBloques
			
		ret
	mainBloques endp

	dibujarBloques proc

	xor ax,ax
	xor bx,bx
	xor cx,cx
	xor si,si
	mov dx,[di]
	loopColumna:
		mov cx,columnas[bx]
		mov dx,[di]				;fila inicial

		dibujoBloqueHorizontal: 
			mov ah,0ch 				;config
			mov al,0fh 				;tipo blanco
			mov bh,00h 				;numero de pagina
			int 10h					;imprimo pixel

				
			inc cx					;incremento en uno cx para imprimir a la derecha	
			mov ax,cx				;muevo cx a ax
			sub ax,columnas[bx]				;le resto a ax la pos original de x, para tener el ancho real
			cmp ax,block_width
		jng dibujoBloqueHorizontal 	;agrego pixeles y cheque que no supere 4 por columna
			mov cx,columnas[bx]				;cx vuelve a la pos inicial en X	
							
			inc dx					;bajo de linea para la altura en Y
			mov ax,dx				;lo mismo pero en filas
			sub ax,[di]
			cmp ax,block_height
		jng dibujoBloqueHorizontal
			cmp bx,14
			je fin
			add bx,2
		jmp loopColumna
		fin:
			ret
	dibujarBloques endp

	colisionBloques proc
		
            ret
	colisionBloques endp

	proc cube
	mov ah, 0ch 
	xor bx, bx  
	mov cx, 40 
	cub: ; print cube  
	push cx  
	mov cx, 10 
	mov dx, [x]
	inc dx 
	mov [x], dx 
	mov dx, [y]   


	prp: ;print pixels in a line
	push cx
	mov cx, [x]
	int 10h
	inc dx ;y 
	   
	pop cx  
	loop prp

	pop cx 
	loop cub
	ret 
endp cube 

	ballMov proc

		mov ax,ball_mov_x		;mover horizontal
		add ball_x,ax

		mov ax,ventana_limites
		cmp ball_x,ax			;si la pos en x es menor a 0 la colision es izq
		jl movNegX	

		mov ax,ventana_width 	;y si es mayor a ventana_width la colision es por derecha
		sub ax,ball_size
		sub ax,ventana_limites
		cmp ball_x,ax
		jg movNegX


		mov ax,ball_mov_y		;mover vertical
		add ball_y,ax

		mov ax,ventana_limites
		add ax, 05h
		cmp ball_y,ax			;checkea si la pos vertical es menor a los limites si es, colisiona
		jl movNegY

		mov ax,ventana_height
		sub ax,ball_size		;checkea colision de abajo
		sub ax,ventana_limites
		cmp ball_y,ax
		jg pierdeVida

		;me fijo si la pelota colisiona con la barra
		;minx1 < maxx2 && maxx1 > minx2 && maxy1 > miny2 && miny1 < maxy2
		;ball_x + ball_size > barra_x && ball_x < barra_x + barra_width
		;&& ball_y + ball_size > barra_y && ball_y < barra_y + barra_height
		

		mov ax,ball_x
		add ax,ball_size
		cmp ax,barra_x
		jng noColisiona

		mov ax,barra_x
		add ax,barra_width
		cmp ball_x,ax
		jnl noColisiona

		mov ax,ball_y
		add ax,ball_size
		cmp ax,barra_y
		jng noColisiona

		mov ax,barra_y
		add ax,barra_height
		cmp ball_y,ax
		jnl noColisiona

		jmp colision
		movNegX:					;le da velocidad negativa a la pelota para la colision en X
		neg ball_mov_x

		ret
		movNegY: 					;le da velocidad negativa a la pelota para la colision en Y
		neg ball_mov_y
		ret
		colision:
		call aumenta
		neg ball_mov_y
		cmp ball_mov_x,0
		ja vaPorDerecha
		call beep

		vaPorIzq:
		cmp barra_vel,0
		ja cambioX
		ret
		cambioX:
		neg ball_mov_x
		ret

		vaPorDerecha:
		cmp barra_vel,0
		jb barraVaIzq
		ret

		barraVaIzq:
		neg ball_mov_x
		ret

		noColisiona:
			ret

			;me fijo si toca los bloques

		;si pasa aca, la pelota colisiono
	

	

	pierdeVida:
		dec vidas				;saco una vida a las que le quedan
		call ResetPosFun		;se termina esa vida y reseteo las pos
		call ResetPosBarra
		call actualizarVidas
		mov aumentaVel,0
		mov ball_mov_x,2		;reset de velocidad
		mov ball_mov_y,5
		;quiero que cuando termine una vida la direccion de la pelota sea aleatoria
	    ;Generar otro número aleatorio para decidir si negarlo
	    call random
	    mov [negFlag], al

	    ;Verificar si el byte para la negación es impar (bit menos significativo es 1)
	    mov bl, [negFlag]
	    test bl, 1
	    jz noNegar        		;Si el bit menos significativo es 0, no se niega

	    mov ax,ball_mov_x		;invierto la velocidad en x dsp de perder una vida 
		not ax
		add al,1
		mov ball_mov_x,ax
		noNegar:
			call mainBloques
			cmp vidas,00h 			;si tiene 0 vidas salta a game over
			je gameOver
			ret

	gameOver:
		call actualizarVidas
		mov actividad,00h
		mov vidas,03h
		ret

	ballMov endp

	barraMov proc
		;checkeo si se aprieta una letra
		mov ah,01h
		int 16h
		jz movBarraFin

	
		;checkeo cual se toca
		mov ah,00h
		int 16h

		; si es d (mover a la derecha)
		cmp al,'D'
		je movBarraDer
		cmp al,'d'
		je movBarraDer

		;si es a(mover a la izquierda)
		cmp al,'A'
		je movBarraIzq
		cmp al,'a'
		je movBarraIzq
		ret
	movBarraDer:
		mov ax,barra_vel
		add barra_x, 15

		cmp ball_mov_x,0
		ja seguirMovD
		call checkColBarraEnMovimiento
		seguirMovD:
		mov ax,ventana_width
		sub ax,ventana_limites
		sub ax,barra_width
		cmp barra_x,ax
		jg movBarraLimiteDer
	jmp movBarraFin
		movBarraLimiteDer:
			mov barra_x,ax
		jmp movBarraFin

	movBarraIzq:
		mov ax,barra_vel
		sub barra_x, 15

		cmp ball_mov_x,0
		jb seguirMovI
		call checkColBarraEnMovimiento
		seguirMovI:
		mov ax,ventana_limites
		cmp barra_x,ax
		jl movBarraLimiteIzq
	jmp movBarraFin
		movBarraLimiteIzq:
			mov barra_x,ax
		jmp movBarraFin

	movBarraFin:
		ret
	barraMov endp

	clear proc
		
		mov ah, 01H ;Get the State of the keyboard buffer
		int 16h
		jz no_se_presiono_tecla
		mov ah, 00H ;Si encuentra una tecla, la obtiene y la manda a AL
		int 16h

		cmp al,27 ;ESC 
		je TERMIAR_TODO
		jmp no_se_presiono_tecla

	TERMIAR_TODO:
		call exitProc

	no_se_presiono_tecla:
		ret
	clear endp



	ResetPosFun proc
		mov ax,ball_inicialPos_x
		mov ball_x,ax

		mov ax,ball_inicialPos_y
		mov ball_y,ax

		ret
	ResetPosFun endp

	ResetPosBarra proc
		mov ax,barra_inicialPos_x
		mov barra_x,ax

		mov ax,barra_inicialPos_y
		mov barra_y,ax

		ret
	ResetPosBarra endp



	ballArt proc

		mov cx,ball_x 			;columna inicial
		mov dx,ball_y 			;fila inicial

	dibujoHorizontal: 
		mov ah,0ch 				;config
		mov al,0fh 				;tipo blanco
		mov bh,00h 				;numero de pagina
		int 10h					;imprimo pixel

		inc cx			
		mov ax,cx		
		sub ax,ball_x
		cmp ax,ball_size
	jng dibujoHorizontal 		;agrego pixeles y cheque que no supere 4 por columna

		mov cx,ball_x
		inc dx					;me muevo de linea

		mov ax,dx				;lo mismo pero en filas
		sub ax,ball_y
		cmp ax,ball_size
	jng dibujoHorizontal
	



		ret
	ballArt endp

	barraArt proc

		mov cx,barra_x 			;columna inicial
		mov dx,barra_y 			;fila inicial

	dibujoBarraHorizontal: 
		mov ah,0ch 				;config
		mov al,0fh 				;tipo blanco
		mov bh,00h 				;numero de pagina
		int 10h					;imprimo pixel

		inc cx			
		mov ax,cx		
		sub ax,barra_x
		cmp ax,barra_width
	jng dibujoBarraHorizontal 	;agrego pixeles y cheque que no supere 4 por columna

		mov cx,barra_x
		inc dx					;me muevo de linea

		mov ax,dx				;lo mismo pero en filas
		sub ax,barra_y
		cmp ax,barra_height
	jng dibujoBarraHorizontal

		ret
	barraArt endp

	checkColBarraEnMovimiento proc
		mov ax,ball_x
		add ax,ball_size
		cmp ax,barra_x
		jng noColisionaEnMovimiento

		mov ax,barra_x
		add ax,barra_width
		cmp ball_x,ax
		jnl noColisionaEnMovimiento

		mov ax,ball_y
		add ax,ball_size
		cmp ax,barra_y
		jng noColisionaEnMovimiento

		mov ax,barra_y
		add ax,barra_height
		cmp ball_y,ax
		jnl noColisionaEnMovimiento

		colisionEnMov:
		neg ball_mov_x
		ret

	noColisionaEnMovimiento:
		ret
	checkColBarraEnMovimiento endp


	interfazArt proc
		mov ah,02h				;imprimo las vidas que le quedan a jugador
		mov bh,00h
		mov dh,00h
		mov dl,08h
		int 10h

		mov ah,9
		lea dx,vidasAscii
		int 21h

		mov ah,02h				;imprimo el texto vidas
		mov bh,00h
		mov dh,00h
		mov dl,01h
		int 10h

		mov ah,9
		lea dx,vidasTxt
		int 21h

		mov ah,02h				;imprimo el texto de la dificutad
		mov bh,00h
		mov dh,00h
		mov dl,12h
		int 10h

		mov ah,9
		lea dx,puntosTxt
		int 21h

		mov ah,02h				;imprimo la separacion del texto y el juego
		mov bh,00h
		mov dh,01h
		mov dl,00h
		int 10h

		mov ah,9
		lea dx,limiteTxt
		int 21h

		ret
	interfazArt endp

	gameOverMenu proc
		call lossSnd
		call clsPantalla
	wait4Key:
		mov ah,02h
		mov bh,00h
		mov dh,06h
		mov dl,10h
		int 10h

		mov ah,9
		lea dx,gameOverTxt
		int 21h

		mov ah,02h				
		mov bh,00h
		mov dh,08h
		mov dl,0fh
		int 10h

		mov ah,9
		lea dx,restartTxt
		int 21h

		mov ah,02h				
		mov bh,00h
		mov dh,0ah
		mov dl,0fh
		int 10h

		mov ah,9
		lea dx,goMenuTxt
		int 21h

		mov ah,0
		int 16h

		cmp al,31h
		je restart
		cmp al,32h
		je salirMenu
	jmp wait4Key
		ret
		restart:
			mov actividad,01h
			mov vidasAscii,33h
			ret
		salirMenu:
			mov actividad,00h
			mov escena,01h
			ret	

	gameOverMenu endp

	intro proc
		
		call clsPantalla
		
		mov ah,02h
		mov bh,00h
		mov dh,06h
		mov dl,03h
		int 10h

		mov ah,9
		lea dx,menuTitle			;imprimo el titulo
		int 21h

		mov ah,02h
		mov bh,00h
		mov dh,0bh
		mov dl,0ah
		int 10h

		mov ah,9
		lea dx,menuTitle2		;imprimo el titulo
		int 21h

		

		
		mov si, 17

		scroll:
		cmp si, 0
		je scroll_out
		mov cx, 02      ;WAIT del scroll
		mov dx, 41248
		mov ah, 86h
		int 15h
		call scroll_down
		dec si
		jmp scroll
		scroll_out:
		

		ret
	intro endp

	mainMenu proc
		call clsPantalla
	waitForKey:

		call clsPantalla

		mov ah,02h
		mov bh,00h
		mov dh,05h
		mov dl,0eh
		int 10h

		mov ah,9
		lea dx,opcion1			;opcion para jugar
		int 21h

		mov ah,02h
		mov bh,00h
		mov dh,08h
		mov dl,0eh
		int 10h

		mov ah,9
		lea dx,opcion2			;opcion para ver Instrucciones
		int 21h

		mov ah,02h
		mov bh,00h
		mov dh,0bh
		mov dl,0eh
		int 10h

		mov ah,9
		lea dx,opcion3			;opcion para salir
		int 21h

		mov ah,00h
		int 16h

		cmp al,31h
		je jugar
		cmp al,32h
		je instruc
		cmp al,33h
		je exitGame
	jmp waitForKey

	instruc:
		mov escena,03h
		ret
	exitGame:
		mov exit,01h
		ret

	jugar:
		call clsPantalla

		mov ah,02h
		mov bh,00h
		mov dh,05h
		mov dl,0ah
		int 10h

		mov ah,9
		lea dx,elegirDif		;opcion para jugar
		int 21h
		mov ah,02h
		mov bh,00h
		mov dh,08h
		mov dl,0fh
		int 10h

		mov ah,9
		lea dx,facil		;opcion para jugar
		int 21h
		mov ah,02h
		mov bh,00h
		mov dh,0ah
		mov dl,0fh
		int 10h

		mov ah,9
		lea dx,normal		;opcion para jugar
		int 21h
		mov ah,02h
		mov bh,00h
		mov dh,0ch
		mov dl,0fh
		int 10h

		mov ah,9
		lea dx,dificil		;opcion para jugar
		int 21h


		mov ah,00h
		int 16h


		


		cmp al,31h
		je op1
		cmp al,32h
		je op2
		cmp al,33h
		je op3
	jmp jugar

		op1:
			mov dificutad,1
			mov escena,02h
			mov actividad,01h
			mov vidasAscii,'3'
			ret
		op2:
			mov dificutad,2
			mov escena,02h
			mov actividad,01h
			mov vidasAscii,'3'
			ret
		op3:
			mov dificutad,3
			mov escena,02h
			mov actividad,01h
			mov vidasAscii,'3'
			ret
	
	mainMenu endp

	instrucDescrip proc
		call clsPantalla

		mov ah,02h
		mov bh,00h
		mov dh,00h
		mov dl,00h
		int 10h

		mov ah,9
		lea dx,descripcion			;opcion para ver Instrucciones
		int 21h

		mov ah,00h
		int 16h

		cmp al,31h
		je volver
		ret
	volver:
		mov escena,01h
		ret
	instrucDescrip endp

	actualizarVidas proc
		xor ax,ax
		mov al,vidas

		add al,30h
		mov [vidasAscii],al
		ret
	actualizarVidas endp

	random proc
		mov al, 0           ; Canal 0, latchea el valor del temporizador
	    out 43h, al
	    in al, 40h          ; Leer byte bajo del temporizador
	    mov ah, al
	    in al, 40h          ; Leer byte alto del temporizador
	    xor ah, al          ; Combina los dos bytes para obtener un pseudoaleatorio
	    ret
	random endp

	clsPantalla proc

	mov ah, 06h
	mov al, 0
	mov bh, 00h
	mov cx, 0000h
	mov dx, 184Fh
	int 10h 

	ret
	clsPantalla endp

	exitProc proc 				;sale al modo de texto

		mov ah,00h
		mov al,02h
		int 10h

		mov ax,4c00h
		int 21h
		ret
	exitProc endp

	Beep proc  ;plays a beep when the ball lands on the paddle (uses ax) ;taken from gavhim website
		; open speaker
		in al, 61h
		or al, 00000011b
		out 61h, al
		; send control word to change frequency
		mov al, 0B6h
		out 43h, al
		; play frequency 860Hz
		mov ax, [note]
		out 42h, al ; Sending lower byte
		mov al, ah
		out 42h, al ; Sending upper byte
		; wait for any key
		mov cx, 8 
		beeeeeeeeeeeeep:
		push cx 
		;call delayproc
		pop cx 
		loop beeeeeeeeeeeeep
		; close the speaker
		in al, 61h
		and al, 11111100b
		out 61h, al
	beep endp  

		DelayProc proc 
		  mov cx,1 
		  mov dx,3dah
		  loop11:
		    push cx
		    l1:
		      in al,dx
		      and al,08h
		      jnz l1
		    l2:
		      in al,dx
		      and al,08h
		      jz l2
		   pop cx
		   loop loop11
		   ret
		DelayProc endp

	aumenta proc
		cmp aumentaVel,4
		je salirAumenta
		add ball_mov_y,1
		add ball_mov_x,4
		add aumentaVel,1
		salirAumenta:
		ret
	aumenta endp

	scroll_down proc
    mov ah, 6               
    mov al, 1               ; number of lines to scroll
    mov bh, 0               ; attribute
    mov ch, 0               ; row top
    mov cl, 0               ; col left
    mov dh, 25              ; row bottom
    mov dl, 80              ; col right
    int 10h

    ret
	scroll_down endp

	lossSnd proc
    push ax
	push bx
	push cx
	push dx
	push si
	push di
    pushf

    mov ax, 1809
    mov cx, 03

    ;mov BX, AX       
    ;mov AL, 182      
    ;out 43h, AL       
    ;mov AX, BX         
    out 42h, AL         
    mov AL, AH          
    out 42h, AL        
    in AL, 61h         
    or AL, 03h        
    out 61h, AL       
    mov AH, 86h        
    int 15h             
    in AL, 61h         
    and AL, 0FCh       
    out 61h, AL        

    mov ax, 2031
    
    ;mov BX, AX          
    ;mov AL, 182         
    ;out 43h, AL        
    ;mov AX, BX          
    out 42h, AL         
    mov AL, AH          
    out 42h, AL        
    in AL, 61h          
    or AL, 03h          
    out 61h, AL         
    mov AH, 86h        
    int 15h             
    in AL, 61h          
    and AL, 0FCh        
    out 61h, AL       

    mov ax, 2152
    

    ;mov BX, AX         
    ;mov AL, 182        
    ;out 43h, AL         
    ;mov AX, BX          
    out 42h, AL         
    mov AL, AH          
    out 42h, AL         
    in AL, 61h          
    or AL, 03h          
    out 61h, AL        
    mov AH, 86h         
    int 15h             
    and AL, 0FCh        
    out 61h, AL         

    mov ax, 2280
    mov cx, 05

    ;mov BX, AX      
    ;mov AL, 182             
    ;out 43h, AL        
    ;mov AX, BX          
    out 42h, AL        
    mov AL, AH          
    out 42h, AL         
    in AL, 61h          
    or AL, 03h          
    out 61h, AL         
    mov AH, 86h         
    int 15h             
    in AL, 61h          
    and AL, 0FCh        
    out 61h, AL  

    popf
    pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
    ret                 
lossSnd endp




end