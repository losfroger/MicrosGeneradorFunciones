LIST P = 18f45K50
 #include<p18f45K50.inc>
    
    CONFIG WDTEN = OFF
    CONFIG MCLRE = ON
    CONFIG DEBUG = OFF
    CONFIG LVP = OFF
    CONFIG FOSC = INTOSCIO
    
Ajustador EQU 0x00 ; Frecuencias
Est EQU 0x01 ; Contador para voltajes de onda
 
ORG 0x00

Start:
   MOVLB 0x0F
    CLRF ANSELD ; PORTD como puerto digital
    CLRF TRISD ; PORTD como salida
    CLRF PORTD ;Limpia PORTD
    CLRF ANSELB
    SETF TRISB
    CLRF ANSELC
    SETF TRISC
    MOVLW b'01100000' ; Oscilador en 8 MHz
    MOVWF OSCCON
    CLRF Est ;limpia Est
    MOVLW 0x01
    MOVWF Ajustador ;Carga valor inical a Ajustador
    
MainLoop:
    MOVLW 0x00
    MOVWF PORTD
    BTFSC PORTB,0
    CALL On
    GOTO MainLoop
    
On:
    INCF Est,F ;Incrementa Est cada que el primgrama regresa a esta linea
    MOVLW 0X7F
    CPFSLT Est ;Salta de linea si Est es menor que 0x7C 
	CLRF Est ;Si Est no es menor que 0x7C, entonces limpia Est
    CALL SS
    MOVWF PORTD ;El programa regresa con un valor cargado en W, que es el valor que genera la onda senoidal
    BTFSC PORTB,1 ;Si el pin 1 del puerto B esta en 0, salta de instruccion
	INCF Ajustador ;Si el pin 1 del puerto B esta en 1, incrementa el valor de Ajustador, disminuyendo la frecuencia
    BTFSC PORTB,2 ;Si el pin 2 del puerto B esta en 0, salta de instruccion
	DECF Ajustador ;Si el pin 1 del puerto B esta en 1, decrementa el valor de Ajustador, aumentando la frecuencia
    CALL Retardo 
    BTFSS PORTB,0 ; Si el valor del pin 0 del puerto B esta en 1, el programa regresa a MainLoop
	GOTO On ; Si el valor del pin 0 del puerto B esta en 0, el programa regresa a On, por lo tanto, sigue generando la onda
    RETURN
    
SS: ;SS => Selección tipo de Señal
    BTFSC PORTC,0
	CALL Sine
    BTFSC PORTC,1
	CALL Rampa
    BTFSC PORTC,2
	CALL Square
    RETURN

    
Retardo:
    DECFSZ Ajustador,F
    GOTO Retardo
    RETURN

    
ORG 2000h ; Con esta instruccion, "Senoidal" empieza en la línea 3000h para evitar desbordamiento de stack

Sine:
    MOVF    Est,W
    ADDWF   PCL,W
    ADDLW   0x04
    MOVWF   PCL
    ADDWF   PCL,F
    RETLW 0x7F
    RETLW 0x8C
    RETLW 0x99
    RETLW 0xA5
    RETLW 0x99 ; B1
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
    RETLW 0x7F

ORG 4000h
Rampa:
    MOVF    Est,W
    ADDWF   PCL,W
    ADDLW   0x04
    MOVWF   PCL
    ADDWF   PCL,F
   RETLW 0x00
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
    RETLW 0xFF

    org 5000h
Square:
    MOVF    Est,W
    ADDWF   PCL,W
    ADDLW   0x04
    MOVWF   PCL
    ADDWF   PCL,F
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
    RETLW 0x01
    
END