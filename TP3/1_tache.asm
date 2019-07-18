DATA SEGMENT
	deroute db "Deroutement fait....",10,13,"$"
	message db 10,13,"**** Programme principal en cours **** $"
	ch1 db "oh, la 1ch.... $"
DATA ENDS

MY_STACK SEGMENT STACK "stack"
		dw 128 dup(?)
		TOP label word
MY_STACK ENDS

CODE SEGMENT
	ASSUME CS: CODE, DS: DATA , SS: MY_STACK
	
OUTPUT PROC NEAR          ; procédure d'affichage des messages

		MOV AH , 09
		INT 21H
		RET
OUTPUT ENDP

DEROUTER PROC NEAR                  ; procédure de déroutement qui sera dans la 1 CH

		CMP BL , 3DH         ; why ? 
		Jl NOAFFICHAGE       
		PUSH DX
		MOV DX, OFFSET ch1
		CALL OUTPUT        ; affichage 
		MOV BL , 0H        ; 0 ? 
		POP DX 
NOAFFICHAGE:    IRET

DEROUTER ENDP

INSTALLATION PROC NEAR     ; installation du la nouvelle procédure dans la 1 CH 

		PUSH DS 
		MOV AX , CS
		MOV DS , AX
		MOV DX , OFFSET DEROUTER
		mov ax,251CH
		INT 21H 
		POP DS
		RET
		
INSTALLATION ENDP 

START:
		MOV AX, DATA
		MOV DS,AX
		MOV AX , MY_STACK
		MOV SS, AX
		MOV SP, TOP
		CALL INSTALLATION
		MOV AX, 3 
    	        INT 10H     ; clear screen grace a l'interruption 10H
		MOV BL ,0
		
BIGLOOP: 	MOV DX , offset message ; la boucle qui fait l'affichage en continu .. 	
		CALL OUTPUT	
		MOV CX , 3C0H    ; 3C0H = 960 D qui représente le temps pour afficher le message "message" entre deux "message"
lap:	
		INC BL
		MOV AX ,3D09H       ; 3D09H = 15760 D qui représente le temps entre deux messages "1ch
		
LOOPIN:	DEC AX               ; code des deux boucles imbriquées (donné) 
		JNZ LOOPIN
		LOOP lap
		JMP BIGLOOP	

CODE ENDS
		END START
