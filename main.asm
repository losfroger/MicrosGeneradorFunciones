;GENERADOR DE ONDAS SENOIDAL; CUADRADA Y RAMPA
;Este proyecto es un generador de 3 tipos de onda: Senoidal, Cuadrada y Rampa
;Mediante el uso del Pic PIC18F45K50
  
LIST P = 18f45K50 ;PIC18F45K50
#include<p18f45K50.inc>;Libreria del PIC18F45K50

; Sección de bits de configuración inicial 
CONFIG WDTEN = OFF
CONFIG MCLRE = ON
CONFIG DEBUG = OFF
CONFIG LVP = OFF
CONFIG FOSC = INTOSCIO
    
;Seccion de variable  

;Variables contadores
Ajustador EQU 0x00 ; Frecuencias 1
Ajustador2 EQU 0X01; Frecuencias 2
Est EQU 0x02 ; Contador para voltajes de onda
Aux1 EQU 0x03 ; Variable Auxiliar1 para Retardo
Aux2 EQU 0x04 ; Variable Auxiliar2 para Retardo2
R2Aux EQU 0X0E ; Variable Auxiliar para configurar Retardo2
 
; Variables Serial
AuxSerial EQU 0X05 ; Variable que almacena el valor recibido
ValorSerial EQU 0x06 ; Guarda temporalmente el valor recibido
Tipo EQU 0X07 ; Variable para almacenar el tipo de onda:
	      ;  1 = Senoidal, 2 = Cuadrada, 3 = Rampa

;Variables SAjustador1 y SAjustador2 para almacenar temporalmente la frecuencia
;de la onda temporalmente cuando se hace la transmision de datos
SAjustador1 EQU 0X08
SAjustador2 EQU 0X09

; Variables para mostrar en el LCD la frecuencia de la onda
Frec1 EQU 0X0A
Frec2 EQU 0X0B
Frec3 EQU 0X0C
Frec4 EQU 0X0D

; Bandera de que se cambio el tipo de onda, se activa si se pone en 0
; Bandera para el cambio de onda:
 ;0->Activado
 ;1->Desactivado
 Cambio EQU 0xF 
 
;Inicia en la linea 0
ORG 0
GOTO Start
ORG 0x08
GOTO Receptor

Start:
    ;
    MOVLB 0x0F
    ;Declaracion el PORTD como puerto digital
    CLRF ANSELD ; PORTD como puerto digital
    CLRF TRISD ; PORTD como salida
    CLRF PORTD ;Limpia PORTD
    
    ;Declaracion el PORTA como puerto digital
    CLRF ANSELA ; PORTA como puerto digital
    CLRF TRISA ; PORTA como salida
    CLRF PORTA ;Limpia PORTA
    
    CLRF ANSELB
    SETF TRISB
    
    BCF TRISB, 6
    BCF TRISB, 7
    
    CLRF ANSELC
    SETF TRISC
    CLRF PORTC
    
    MOVLW b'01110000' ; Oscilador en 16 MHz
    MOVWF OSCCON
    
    ; Config puerto serial asincrono
    MOVLB   0x0F
    CLRF    ANSELC,1

    MOVLW   b'00000000'
    MOVWF   BAUDCON1 ; Registro de control de velocidad de transmision
    
    MOVLW   b'11000000'
    MOVWF   TRISC ; Para poner entradas y salidas
    
    ;definicion de la razon de baudios
    MOVLW   d'100' ;4MHz = 25 16MHz = 100
    MOVWF   SPBRG1

    MOVLW   b'00100100' ;BRGH=1
    MOVWF   TXSTA1 ;Se habilita la transmision de datos
    
    MOVLW   b'00000000'
    MOVWF   SPBRGH1
    
    MOVLW   b'10010000'
    MOVWF   RCSTA1  ;Se habilita el puerto serial
    
    MOVLW b'11000000' ; Activa interrupciones de alto y bajo nivel
    MOVWF INTCON
    
    BSF PIE1, RCIE
    
    
    ;Configurar LCD
    CALL Retardo2
    CALL LCDInit
    
    MOVLW h'80'
    CALL LCD_Comm
    
    CALL Retardo2
    
    CLRF Est ;limpia Est
    MOVLW 0xFF
    MOVWF Ajustador ;Carga valor inical a Ajustador
    
    CLRF ValorSerial
    CLRF Tipo
    CLRF SAjustador1
    CLRF SAjustador2
    CLRF Frec1
    CLRF Frec2
    CLRF Frec3
    CLRF Frec4
    
    MOVLW d'1'
    MOVWF AuxSerial
    MOVLW d'50' ; Configurar retardo del retardo 2
    MOVWF R2Aux
    MOVLW d'1' ; Desactivar bandera de cambio
    MOVWF Cambio
    
; Loop principal del programa, espera hasta que se active la bandera que indica
; que hubo un cambio el tipo de onda
MainLoop:
    MOVLW d'0'
    CPFSGT Cambio ; Comprobar si hay un cambio
	CALL SS
    GOTO MainLoop

; Funcion de retardo ajustable
Retardo:
    MOVFF Ajustador, Aux1
RetardoLoop:
    DECFSZ Aux1,F
	GOTO RetardoLoop
    RETURN

RetardoB: ; Retardo con ajustador 2
    MOVFF Ajustador, Aux1
    MOVFF Ajustador2, Aux2
RetardoBLoop:
    DECFSZ Aux1,F
	GOTO RetardoBLoop
    DECFSZ Aux2, F
	GOTO RetardoBLoop
    RETURN
   
; Retardo fijo
Retardo2:
   MOVFF R2Aux, Aux2
LoopRetardo2:
    DECFSZ Aux2,F
	GOTO LoopRetardo2
    RETURN

; =========================================================================
; Receptor asincrono
; Recibe los datos del puerto serial asincrono y los guarda en diferentes registros
; dependiendo de cuantos ya ha recibido
; =========================================================================
Receptor:
    MOVF RCREG1, W
    MOVWF ValorSerial
    
    ; Usar PCL para ir cambiando que valor se asigna cada que se mandan
    ; 8 Caracteres
    MOVF AuxSerial, W
    ADDWF PCL ; Sumarle a PCL hace que salte al número de instrucciones que le sumas
    MOVFF ValorSerial, Tipo
    GOTO EndR
    MOVFF ValorSerial, SAjustador1
    GOTO EndR
    MOVFF ValorSerial, SAjustador2
    GOTO EndR
    MOVFF ValorSerial, Frec1
    GOTO EndR
    MOVFF ValorSerial, Frec2
    GOTO EndR
    MOVFF ValorSerial, Frec3
    GOTO EndR
    MOVFF ValorSerial, Frec4
    GOTO EndR
    
    ; Final de pasar datos
    ; Mostrar tipo de onda
    MOVLW h'80'
    CALL LCD_Comm

    MOVLW d'48'
    SUBWF Tipo, 0
    CALL LCD_Char
    
    ; Mostrar frecuencia
    MOVLW h'C0'
    CALL LCD_Comm
    
    MOVF Frec1, W
    CALL LCD_Char
    MOVF Frec2, W
    CALL LCD_Char
    MOVF Frec3, W
    CALL LCD_Char
    MOVF Frec4, W
    CALL LCD_Char
    
    MOVLW 'H'
    CALL LCD_Char
    MOVLW 'z'
    CALL LCD_Char
    
    ; Reiniciar el valor de AuxSerial
    MOVLW d'1'
    MOVWF AuxSerial
    
    ;Activar bandera de cambio
    MOVLW d'0'
    MOVWF Cambio
    
    MOVFF SAjustador1, Ajustador
    MOVFF SAjustador2, Ajustador2
    RETFIE 1
    
    EndR:
    ; Sumarle al saltador de instrucciones para que guarde el siguiente valor
    ; en un registro diferente
    MOVLW d'8'
    ADDWF AuxSerial
    RETFIE 1
    
; =========================================================================
; Configuracion del LCD
; =========================================================================

; Comandos para inicializar correctamente el LCD
LCDInit:
    Call Retardo2
    MOVLW h'38'  ; Configurar pantalla a 8bits
    CALL LCD_Comm ;Llamada de la funcion para aplicar la configuracion

    ; Configurar caracteres especiales
    CALL LCD_Senoidal
    CALL LCD_Cuadrada
    CALL LCD_Rampa
    
    MOVLW h'80' ;Poner el cursor en la primer posicion del primer renglon
    CALL LCD_Comm;Llamada de la funcion para aplicar la configuracion
    
    MOVLW h'0C' ; Prender pantalla sin cursor
    CALL LCD_Comm;Llamada de la funcion para aplicar la configuracion
    
    RETURN ;Fin de LCDInit

; Funcion para poder mandar un comando a la pantalla LCD, para usarlo se pone el
; comando en el registro W antes de mandarlo a llamar
LCD_Comm:
    MOVWF PORTA
    BCF PORTB, RB6 ; Registro de commandos
    BSF PORTB, RB7 ; Mandar un pulso en alto al pin de Enable
    NOP
    BCF PORTB, RB7
    Call Retardo2
    RETURN  ;Fin de LCD_Comm

; Funcion para mandar un caracter a la pantalla LCD
; Utilizado para escribir un caracter en la pantalla a partir de lo que está
; en el registro W
LCD_Char:
    MOVWF PORTA
    BSF PORTB, RB6 ; Mandar datos
    BSF PORTB, RB7 ; Mandar un pulso en alto al pin de Enable
    NOP
    BCF PORTB, RB7 ; Desactivar el pin Enable
    Call Retardo2
    RETURN;Fin de LCD_Char

;=====================================
;Carateres especiales para las onda
;(Para usarlo, mueve al registro W el valor h'01' y luego 
; manda a llamar LCD_Char)
;======================================
;Para generar los caracteres especiales para las ondas, se modifica el caracter
;que iria en esa posicion y se van encendiendo los pixelen que se necesita para
;crear el caracter de cada onda

;Caracter de onda Senoidal
;valor h'01'
LCD_Senoidal:
    MOVLW h'48';Se le indica al LCD que se modificar un caracter para formar 
		;el simbolo de la onda Senoidal
    CALL LCD_Comm
    ;Creacion del caracter de onda Senoidal
    MOVLW d'0'
    CALL LCD_Char
    MOVLW d'8'
    CALL LCD_Char
    MOVLW d'20'
    CALL LCD_Char
    MOVLW d'21'
    CALL LCD_Char
    MOVLW d'5'
    CALL LCD_Char
    MOVLW d'2'
    CALL LCD_Char
    MOVLW d'0'
    CALL LCD_Char
    MOVLW d'0'
    CALL LCD_Char
    RETURN;Fin de LCD_Senoidal

;Caracter de onda Cuadrada
; Valor: h'02'
LCD_Cuadrada:
    MOVLW h'50';Se le indica al LCD que se modificar un caracter para formar 
		;el simbolo de la onda Senoidal
    CALL LCD_Comm
    ;Creacion del caracter de onda Cuadrada
    MOVLW d'0'
    CALL LCD_Char
    MOVLW d'14'
    CALL LCD_Char
    MOVLW d'10'
    CALL LCD_Char
    MOVLW d'10'
    CALL LCD_Char
    MOVLW d'27'
    CALL LCD_Char
    MOVLW d'0'
    CALL LCD_Char
    MOVLW d'0'
    CALL LCD_Char
    MOVLW d'0'
    CALL LCD_Char
    RETURN;Fin de LCD_Cuadrada

;Caracter de onda Rampa
; Valor: h'03'
LCD_Rampa:
    MOVLW h'58'
    CALL LCD_Comm;Se le indica al LCD que se modificar un caracter para formar 
		;el simbolo de la onda Senoidal
    ;Creacion del caracter de onda Rampa
    MOVLW d'0'
    CALL LCD_Char
    MOVLW d'2'
    CALL LCD_Char
    MOVLW d'6'
    CALL LCD_Char
    MOVLW d'10'
    CALL LCD_Char
    MOVLW d'19'
    CALL LCD_Char
    MOVLW d'0'
    CALL LCD_Char
    MOVLW d'0'
    CALL LCD_Char
    MOVLW d'0'
    CALL LCD_Char
    RETURN;Fin de LCD_Rampa

; =========================================================================
; Generador de funciones
; =========================================================================

SS: ;SS => Seleccion tipo de Señal
    MOVLW d'1'
    MOVWF Cambio
    NOP
    MOVF Tipo, w
    ; Switch case
    ;Se llama al ciclo para imprimir la señal de onda senoidal
    XORLW '1'
	BZ SenoLoop
    ;Se llama al ciclo para imprimir la señal de onda cuadrada
    XORLW '2'^'1'
	BZ CuadLoop
    ;Se llama al ciclo para imprimir la señal de onda rampa
    XORLW '3'^'2'
	BZ RampaLoop
    
    ; Desactivar la bandera de cambio
    MOVLW d'1'
    MOVWF Cambio
    
    RETURN;Fin de SS

; ciclo para mostrar la onda Senoidal hasta que haya un cambio
SenoLoop:
    INCF Est,F ;Incrementa Est cada que el programa regresa a esta linea
    CALL Sine;Se llama a Sine para obtener el siguiente valor de la onda
    MOVWF PORTD ;El programa regresa con un valor cargado en W
		;que es el valor que genera la onda senoidal
    MOVLW d'1'
    CPFSEQ Ajustador2;revisa si ajustador2 = 1, si esigual a 1 saltara a CPFSGT
		    ;Si es diferente ira al CALL 
	CALL RetardoB
    CPFSGT Ajustador2;revisa si ajustador2 es mayor a 1, si es mayor a 1
		    ;saltara a TSTFSZ Cambio, si no, ira a Call Retardo
	Call Retardo
    
    TSTFSZ Cambio;Sirve para poder salir de SenoLoop cuando se cambie de onda
	GOTO SenoLoop
    RETURN

; ciclo para mostrar la onda cuadrada hasta que haya un cambio
CuadLoop:
    INCF Est,F ;Incrementa Est cada que el programa regresa a esta linea
    CALL Square;Se llama a Square para obtener el siguiente valor de la onda
    MOVWF PORTD ;El programa regresa con un valor cargado en W
		;que es el valor que genera la onda cuadrada
    MOVLW d'1'
    CPFSEQ Ajustador2;revisa si ajustador2 = 1, si esigual a 1 saltara a CPFSGT
		    ;Si es diferente ira al CALL
	CALL RetardoB
    CPFSGT Ajustador2;revisa si ajustador2 es mayor a 1, si es mayor a 1
		    ;saltara a TSTFSZ Cambio, si no, ira a Call Retardo
	Call Retardo
	
    TSTFSZ Cambio;Sirve para poder salir de CuadLoop cuando se cambie de onda
	GOTO CuadLoop
    RETURN

; ciclo para mostrar la onda Rampa hasta que haya un cambio
RampaLoop:
    INCF Est,F ;Incrementa Est cada que el programa regresa a esta linea
    CALL Rampa ;Se llama a Rampa para obtener el siguiente valor de la onda
    MOVWF PORTD ;El programa regresa con un valor cargado en W
		;que es el valor que genera la onda cuadrada
    MOVLW d'1'
    CPFSEQ Ajustador2;revisa si ajustador2 = 1, si esigual a 1 saltara a CPFSGT
		    ;Si es diferente ira al CALL
	CALL RetardoB
    CPFSGT Ajustador2;revisa si ajustador2 es mayor a 1, si es mayor a 1
		    ;saltara a TSTFSZ Cambio, si no, ira a Call Retardo
	Call Retardo

    TSTFSZ Cambio;Sirve para poder salir de RampaLoop cuando se cambie de onda
	GOTO RampaLoop
    RETURN

;==========================================
;FUNCIONES
;==========================================
; Con esta instruccion, "Senoidal" empieza en la linea 2000h para evitar 
;desbordamiento de stack
ORG 2000h 
;Funcion para mostrar la onda Senoidal
Sine:
    MOVF    Est,W
    ADDWF   PCL,W;PLC guarda la direccion de memoria de la siguiente instruccion
		  ;Se incrementa para poder tomar los puntos siguiente la onda
		  ;hace un incremento cada vez que se llama a Sine
    ADDLW   0x04
    MOVWF   PCL
    ADDWF   PCL,F;incrementamos PLC
    RETLW 0x7F;Cada RTL es un punto de la onda
    RETLW 0x8C
    RETLW 0x99
    RETLW 0xA5
    RETLW 0x99
    RETLW 0xBD
    RETLW 0xC8
    RETLW 0xD2
    RETLW 0xDB
    RETLW 0xE3
    RETLW 0xEB
    RETLW 0xF1
    RETLW 0xF6
    RETLW 0xFA
    RETLW 0xFD
    RETLW 0xFE
    RETLW 0xFE
    RETLW 0xFD
    RETLW 0xFA
    RETLW 0xF6
    RETLW 0xF1
    RETLW 0xEB
    RETLW 0xE3
    RETLW 0xDB
    RETLW 0xD2
    RETLW 0xC8
    RETLW 0xBD
    RETLW 0xB1
    RETLW 0xA5
    RETLW 0x99
    RETLW 0x8C
    RETLW 0x7F
    RETLW 0x72
    RETLW 0x65
    RETLW 0x59
    RETLW 0x4D
    RETLW 0x41
    RETLW 0x36
    RETLW 0x2C
    RETLW 0x23
    RETLW 0x1B
    RETLW 0x13
    RETLW 0x0D
    RETLW 0x08
    RETLW 0x04
    RETLW 0x01
    RETLW 0x00
    RETLW 0x00
    RETLW 0x01
    RETLW 0x04
    RETLW 0x08
    RETLW 0x0D
    RETLW 0x13
    RETLW 0x1B
    RETLW 0x23
    RETLW 0x2C
    RETLW 0x36
    RETLW 0x41
    RETLW 0x4D
    RETLW 0x59
    RETLW 0x65
    RETLW 0x72
    CLRF Est
    RETLW 0x7F

; Con esta instruccion, "RAMPA" empieza en la linea 4000h para evitar 
;desbordamiento de stack
ORG 4000h
;Funcion para mostrar la onda Rampa
Rampa:
    MOVF    Est,W
    ADDWF   PCL,W;PLC guarda la direccion de memoria de la siguiente instruccion
		  ;Se incrementa para poder tomar los puntos siguiente la onda
		  ;hace un incremento cada vez que se llama a Rampa
    ADDLW   0x04
    MOVWF   PCL
    ADDWF   PCL,F;incrementamos PLC
    RETLW 0x00;Cada RTL es un punto de la onda
    RETLW 0x04
    RETLW 0x08
    RETLW 0x0C
    RETLW 0x10
    RETLW 0x15
    RETLW 0x19
    RETLW 0x1D
    RETLW 0x21
    RETLW 0x25
    RETLW 0x29
    RETLW 0x2D
    RETLW 0x31
    RETLW 0x35
    RETLW 0x3A
    RETLW 0x3E
    RETLW 0x42
    RETLW 0x46
    RETLW 0x4A
    RETLW 0x4E
    RETLW 0x52
    RETLW 0x56
    RETLW 0x5A
    RETLW 0x5F
    RETLW 0x63
    RETLW 0x67
    RETLW 0x6B
    RETLW 0x6F
    RETLW 0x73
    RETLW 0x77
    RETLW 0x7B
    RETLW 0x80
    RETLW 0x84
    RETLW 0x88
    RETLW 0x8C
    RETLW 0x90
    RETLW 0x94
    RETLW 0x98
    RETLW 0x9C
    RETLW 0xA0
    RETLW 0xA5
    RETLW 0xA9
    RETLW 0xAD
    RETLW 0xB1
    RETLW 0xB5
    RETLW 0xB9
    RETLW 0xBD
    RETLW 0xC1
    RETLW 0xC5
    RETLW 0xCA
    RETLW 0xCE
    RETLW 0xD2
    RETLW 0xD6
    RETLW 0xDA
    RETLW 0xDE
    RETLW 0xE2
    RETLW 0xE6
    RETLW 0xEA
    RETLW 0xEF
    RETLW 0xF3
    RETLW 0xF7
    RETLW 0xFB
    CLRF Est
    RETLW 0xFF
    
; Con esta instruccion, "RAMPA" empieza en la linea 5000h para evitar 
;desbordamiento de stack
ORG 5000h
;Funcion para mostrar la onda Cuadrada
Square:
    MOVF    Est,W
    ADDWF   PCL,W;PLC guarda la direccion de memoria de la siguiente instruccion
		  ;Se incrementa para poder tomar los puntos siguiente la onda
		  ;hace un incremento cada vez que se llama a Rampa
    ADDLW   0x04
    MOVWF   PCL
    ADDWF   PCL,F;incrementamos PLC
    RETLW 0xFE;Cada RTL es un punto de la onda
    RETLW 0xFE
    RETLW 0xFE
    RETLW 0xFE
    RETLW 0xFE
    RETLW 0xFE
    RETLW 0xFE
    RETLW 0xFE
    RETLW 0xFE
    RETLW 0xFE
    RETLW 0xFE
    RETLW 0xFE
    RETLW 0xFE
    RETLW 0xFE
    RETLW 0xFE
    RETLW 0xFE
    RETLW 0xFE
    RETLW 0xFE
    RETLW 0xFE
    RETLW 0xFE
    RETLW 0xFE
    RETLW 0xFE
    RETLW 0xFE
    RETLW 0xFE
    RETLW 0xFE
    RETLW 0xFE
    RETLW 0xFE
    RETLW 0xFE
    RETLW 0xFE
    RETLW 0xFE
    RETLW 0xFE
    RETLW 0xFE
    RETLW 0x01
    RETLW 0x01
    RETLW 0x01
    RETLW 0x01
    RETLW 0x01
    RETLW 0x01
    RETLW 0x01
    RETLW 0x01
    RETLW 0x01
    RETLW 0x01
    RETLW 0x01
    RETLW 0x01
    RETLW 0x01
    RETLW 0x01
    RETLW 0x01
    RETLW 0x01
    RETLW 0x01
    RETLW 0x01
    RETLW 0x01
    RETLW 0x01
    RETLW 0x01
    RETLW 0x01
    RETLW 0x01
    RETLW 0x01
    RETLW 0x01
    RETLW 0x01
    RETLW 0x01
    RETLW 0x01
    RETLW 0x01
    RETLW 0x01
    CLRF Est
    RETLW 0x01
    
END