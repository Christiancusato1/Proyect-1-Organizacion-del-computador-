.data
mensaje1: .asciiz "Bienvenido al menu. \n 1. Decimal a Punto Flotante \n 2. Hexadecimal a Punto Flotante. \n Por favor ingrese su opcion: "
mensaje2: .asciiz "El numero representado en coma flotante es: "
error1: .asciiz " El numero introducido debe comenzar con su signo '+' o '-'\n"
pedirnumero: .asciiz " Por favor ingrese su numero:"
numeroNormalizado: .asciiz "\n El numero normalizado es: "
puntoFlotante: .asciiz "\n Y su representacion punto flotante es: "
normalizado: .asciiz "1."
cadenaExponente: .asciiz "*2^"
saltoLinea: .asciiz "\n"
espacio: .asciiz " "
exponenteCero: .asciiz "00000000"
numerodecimal: .space 10      # Guarda el espacio para el numero que ingresara el usuario en la opcion decimal
numerohexadecimal: .space 10  # Guarda el espacio para el numero que ingresara el usuario en la opcion hexadecimal
signo: .space 2 # 
binarioEntero: .space 33      # Guarda el espacio para la representacion binaria del entero (32 bits + null)
binarioFraccion: .space 24    # Guarda el espacio para la representacion binaria del flotante (23 bits + null)
binarioExponente: .space 9    # Guarda el espacio para la representacion binaria del exponente  (8 bits + null)
divisor: .float 10.0
uno: .float 1.0
dos: .float 2.0
cero: .float 0.0
exponente: .byte 0
mantisa: .space 24             # Guarda el espacio para la representacion binarioa de la mantisa (8 bits + null)

.text
inicializarMantisa:
li $t1, 23
li $t2, '0'
la $t3, mantisa

# Escribe '0' es los 23 espacios del arreglo 'mantisa'
llenarMantisa:
sb $t2, ($t3)  
addiu $t3, $t3, 1  
addiu $t1, $t1, -1 
bnez $t1, llenarMantisa

# Despliega el mensaje inicial
menu:
li $v0, 4
la $a0, mensaje1
syscall
li $v0, 5
syscall
beq $v0, 1, decimal
beq $v0, 2, hexadecimal
j fin

# Opcion marcada 'hexadecimal'
hexadecimal: 
li $v0, 4
la $a0, pedirnumero
syscall
li $v0, 8
la $a0, numerohexadecimal # Almacenamos el string introducido en el arreglo 'numeroHexadecimal'
li $a1, 10                # 1 del Signo + 7 digitos maximos + 1 de la coma o punto + 1 del último carcater null
syscall
la $t0, numerohexadecimal
li $t1, 0 		    # Registro donde se almacenara la parte entera del flotante
li $t2, 0 		    # Registro donde se almacenara la parte fraccional del flotante
lb $t3, ($t0)		    # Lee el signo del número
beq $t3, '+', signoMasHex   # Si el primer caracter es un más
beq $t3, '-', signoMenosHex # Si el primer caracter es un menos
j faltaSignoHex 

signoMasHex:
li $t3, '+'
sb $t3, signo
addi $t0, $t0, 1 # Salta al siguiente carácter
j obtenerEnteroHex

signoMenosHex:
li $t3, '-'
sb $t3, signo
addi $t0, $t0, 1 # Salta al siguiente carácter
j obtenerEnteroHex

#Se solicita al usuario que introduzca de nuevo un número
faltaSignoHex:
li $v0, 4
la $a0, error1
syscall
j hexadecimal

obtenerEnteroHex:
lb $t3, ($t0) 			  # Lee el siguiente carácter de la entrada
beq $t3, 0, convertirABinario     # Si el carácter es nulo, salta a convertirABinario
beq $t3, 10, convertirABinario    # Si el carácter es linefeed, salta a convertirABinario
beq $t3, ',', buscamosFraccionHex # Si el carácter es una coma, salta a obtenerFraccional
beq $t3, '.', buscamosFraccionHex # Si el carácter es un punto, salta a obtenerFraccional
ble  $t3, '9', restar48		  # Si el caracter es un número solo restamos 48
addi $t3, $t3, -55                # Si el caracter es una letra mayuscula restamos 55

acumularHex:
mul $t1, $t1, 16  	# Multiplicar entero acumulado por 16
add $t1, $t1, $t3 	# Sumar el nuevo dígito al acumulado anterior
addi $t0, $t0, 1  	# Salta al siguiente carácter
j obtenerEnteroHex

restar48: 
addi $t3, $t3, -48
j acumularHex

buscamosFraccionHex:
addi $t0, $t0, 1 # Ignoramos la coma o punto

obtenerFraccionHex:
lb $t3, ($t0) 			# Lee el siguiente carácter de la entrada
beq $t3, 0, convertirABinario   # Si el carácter es nulo, salta a convertirABinario
beq $t3, 10, convertirABinario  # Si el carácter es linefeed, salta a convertirABinario
ble  $t3, '9', restar48Fraccion # Si el caracter es un número solo restamos 48
addi $t3, $t3, -55              # Si el caracter es una letra mayuscula restamos 55

acumularFraccionHex:
mul $t2, $t2, 16  	# Multiplicar entero acumulado por 16
add $t2, $t2, $t3 	# Sumar el nuevo dígito al acumulado anterior
addi $t0, $t0, 1  	# Salta al siguiente carácter
j obtenerFraccionHex

restar48Fraccion: 
addi $t3, $t3, -48
j acumularFraccionHex

# Opción marcada 'decimal'
decimal: 
li $v0, 4
la $a0, pedirnumero
syscall
li $v0, 8
la $a0, numerodecimal # Almacenamos el string introducido en el arreglo 'numerodecimal'
li $a1, 11            # 1 del Signo + 8 digitos maximos + 1 de la coma o punto + 1 del último carcater null
syscall

# Separa la parte entera y la parte decimal del número
la $t0, numerodecimal
li $t1, 0 		    # Registro donde se almacenara la parte entera del flotante
li $t2, 0 		    # Registro donde se almacenara la parte fraccional del flotante
lb $t3, ($t0) 		    # Lee el signo del número
beq $t3, '+', signoMas      # Si el primer caracter es un más
beq $t3, '-', signoMenos    # Si el primer caracter es un menos
j faltaSigno

signoMas:
li $t3, '+'
sb $t3, signo
addi $t0, $t0, 1 # Salta al siguiente carácter
j obtenerEntero

signoMenos:
li $t3, '-'
sb $t3, signo
addi $t0, $t0, 1 # Salta al siguiente carácter
j obtenerEntero

#Se solicita al usuario que introduzca de nuevo un número
faltaSigno:
li $v0, 4
la $a0, error1
syscall
j decimal

obtenerEntero:
lb $t3, ($t0) 			# Lee el siguiente carácter de la entrada
beq $t3, 0, convertirABinario   # Si el carácter es nulo, salta a convertirABinario
beq $t3, 10, convertirABinario  # Si el carácter es linefeed, salta a convertirABinario
beq $t3, ',', buscarFraccion    # Si el carácter es una coma, salta a buscarFraccion
beq $t3, '.', buscarFraccion    # Si el carácter es un punto, salta a buscarFraccion
sub $t3, $t3, 48 		# Convierte el carácter a un dígito
mul $t1, $t1, 10 		# Multiplicar entero acumulado por 10
add $t1, $t1, $t3 		# Sumar el nuevo dígito al acumulado anterior
addi $t0, $t0, 1 		# Salta al siguiente carácter
j obtenerEntero

buscarFraccion:
addi $t0, $t0, 1 # Ignoramos la coma

obtenerFraccion:
lb $t3, 0($t0) 			# Lee el siguiente carácter de la entrada
beq $t3, 0, convertirABinario   # Si el carácter es nulo, salta a convertirABinario
beq $t3, 10, convertirABinario  # Si el carácter es linefeed, salta a convertirABinario
sub $t3, $t3, 48 		# Convierte el carácter a un dígito
mul $t2, $t2, 10 		# Multiplicar entero acumulado por 10
add $t2, $t2, $t3 		# Sumar el nuevo dígito al acumulado anterior
addi $t0, $t0, 1 		# Salta al siguiente carácter
j obtenerFraccion

# Convertimos la parte entera y la fracción a binario
convertirABinario:
add $t5, $t1, $t2            # Sumamos la parte entera y la fraccion
beqz $t5, representacionCero # Si el numero anterior es 0, saltamos
la $t3, binarioEntero        # String donde almacenaremos la representación binaria de la parte entera
li $t4, 31                   # Tamaño máximo de la representación binaria

enteroABinario:
srav $t5, $t1, $t4        # Hacer shift derecho del número entero según el contador del ciclo
andi $t5, $t5, 1          # Extraemos el bit menos significativo
addi $t5, $t5, 48         # Convertimos el valor del bit en ASCII '0' o '1'
sb $t5, ($t3)             # Almacenamos este valor en su representación de string
addiu $t3, $t3, 1         # Aumentamos la dirección actual del string
addiu $t4, $t4, -1     	  # Decrementamos el valor del ciclo
bgez $t4, enteroABinario  # Seguimos el ciclo si el contador sigue siendo mayor a 0
li $t5, 0                 # Null
sb $t5, ($t3)             # Marcamos un null al final de la cadena

# Pasamos la parte flotante del string leido a un registro punto flotante. 
# Ej.  +10.25 => Parte flotante = 25 => Despues de la función: $f0 = 0.25
fraccionABinario:
mtc1 $t2, $f0      # En el registro t2 se tiene la parte decimal del flotante leido
cvt.s.w $f0, $f0   # Convertir palabra a punto flotante
lwc1 $f1, divisor  # Cargamos el valor 10.0 a un registro flotante
lwc1 $f2, uno      # Cargamos el valor 1.0 a un registro flotante
c.lt.s $f2, $f0    # Comparamos el valor el flotante obtenido con 1.0
bc1t cicloDivision # Si 1.0 < f0, entonces entramos al ciclo
j conversionABinario

cicloDivision:
div.s $f0, $f0, $f1    # Dividimos el flotante entre 10
c.lt.s $f2, $f0        # Si el resultado sigue siendo mayor a 1, seguimos dividiendo 
bc1t  cicloDivision

#Convertimos el flotante en $f0 a binario
conversionABinario:
la $t3, binarioFraccion # String donde almacenaremos la representación binaria de la parte flotante
lwc1 $f2, dos           # Cargamos el valor 2.0 a un registro flotante
lwc1 $f3, uno    	# Cargamos el valor 1.0 a un registro flotante
lwc1 $f4, cero   	# Cargamos el valor 0.0 a un registro flotante
li $t4, 22       	# Maximo de iteraciones
lwc1 $f5, dos 

cicloConversion:
mul.s $f0, $f0, $f2  # Multiplacar por 2.0
c.le.s $f3, $f0      # Comparar resultado con 1.0
bc1t restarUno       # Si es mayor a 1.0, le restamos uno
li $t5, '0'          # Si no, Seguimos el ciclo y el bit a guardar es '0'
sb $t5, ($t3)        # Almacenamos este valor en su representación de string
j seguirConversion

restarUno:
li $t5, '1'          # Seguimos el ciclo y el bit a guardar es '1'
sb $t5, ($t3)        # Almacenamos este valor en su representación de string
sub.s $f0, $f0, $f3  # Le restamos 1 al valor flotante

seguirConversion:
addiu $t4, $t4, -1           # Decrementamos el valor del ciclo
addiu $t3, $t3, 1            # Aumentamos la dirección actual del string
beqz $t4, obtenerExponente   # Si se alcanzaron el número máximo de iteraciones, terminamos el ciclo
c.eq.s $f0, $f4              # Si el flotante actual es 0.0, terminamos el ciclo
bc1t obtenerExponente  
j cicloConversion            # En caso contrario, continuamos el ciclo 

obtenerExponente:
beqz $t1, exponenteEnteroCero   # Si el entero es 0, saltamos
la $t3, binarioEntero 		# String esta almacenada el entero en binario
li $t4, 31            		# Tamaño máximo del string anterior

# Calcular exponente si la parte entera es diferente de 0, el exponente es positivo
cicloExponente:
lb $t5, ($t3)
beq $t5, '1', exponenteEncontrado # Verificamos la posición actual del string, si es uno, el valor actual de $t4 es el exponente
addiu $t3, $t3, 1                 # Aumentamos la dirección actual del string
addiu $t4, $t4, -1                # Decrementamos el valor del ciclo
bnez $t4, cicloExponente
j exponenteEncontrado

# Calcular exponente si la parte entera es 0, el exponente es negativo
exponenteEnteroCero:
la $t5, binarioFraccion
li $t4, 0

saltarCeroInicialesFraccion:
lb $t6, ($t5)
li $t7, ' '               # Null
sb $t7, ($t5)           # Marcamos un null el número flotante
addiu $t5, $t5, 1
subi $t4, $t4, 1
beq $t6, '0', saltarCeroInicialesFraccion

exponenteEncontrado:
sb $t4, exponente       #Almaecenamos el valor del exponente

# Imprimimos el valor del número normalizado
imprimirNormalizado:
la $t3, mantisa
li $v0, 4
la $a0, numeroNormalizado
syscall
li $v0, 4
la $a0, signo
syscall
li $v0, 4
la $a0, normalizado
syscall
la $t5, binarioEntero

# Ignoremos los cero a la izquierda del binario de la parte entera
saltarCerosIniciales:
lb $t6, ($t5)
addiu $t5, $t5, 1
beq $t6, '0' saltarCerosIniciales 

# Imprimimos el resto de la parte entera y guardamos estos caracteres a la mantisa
imprimirElResto:
lb $t6, ($t5)                       # Caracter a imprimir
beq $t6, 0, imprimirBinarioFraccion # Si el carácter es nulo, salta
beq $t6, ' ', seguir1 		    # Si el carácter es un espacio, ignoralo
li $v0, 11         		    
move $a0, $t6
syscall				    # Imprimimos el caracter
sb $t6, ($t3)                       # Añadir caracter a la mantisa
addi $t3, $t3, 1                    # Salta al siguiente carácter de la mantisa
seguir1:
addiu $t5, $t5, 1
j imprimirElResto

# Imprimimos el binario de la parte decimal del flotante
imprimirBinarioFraccion:
la $t5, binarioFraccion

cicloBinarioFraccion:
lb $t6, ($t5)                   # Cargamos el caracter a imprimir
beq $t6, 0, seguirImprimiendo   # Si el carácter es nulo, salta
beq $t6, ' ', seguir2 		# Si el carácter es un espacio, ignoralo
li $v0, 11                    
move $a0, $t6 
syscall			        # Imprimimos el carcater
sb $t6, ($t3)   		# Añadir a la mantisa
addi $t3, $t3, 1	 	# Salta al siguiente carácter de la mantisa
seguir2:
addiu $t5, $t5, 1
j cicloBinarioFraccion

#Imprimimos el exponente y terminamos la representación normalizada
seguirImprimiendo:
li $v0, 4
la $a0, cadenaExponente
syscall
li $v0, 1
lb $a0, exponente
syscall

#Imprimimos la representación punto flotante
imprimirPuntoFlotante:
li $v0, 4
la $a0, puntoFlotante
syscall
la $t5, signo
lb $t6, ($t5)
beq $t6, '-', imprimirUno    #Si el signo leido es -, imprimimos un 1
beq $t6, '+', imprimirCero   #Si el signo leido es -, imprimimos un 0

imprimirCero:
li $v0, 1
li $a0, 0
syscall
j imprimirExponente

imprimirUno:
li $v0, 1
li $a0, 1
syscall

imprimirExponente:
li $v0, 4
la $a0, espacio
syscall

# Convertimos el valor de (exponente - 127) a binario
exponenteABinario:
lb $t1, exponente
add $t1, $t1, 127           # Le restamos 127 al exponente obtenido
la $t3, binarioExponente
li $t4, 7

cicloABinario:
srav $t5, $t1, $t4      # Hacer shift derecho del número entero según el contador del ciclo
andi $t5, $t5, 1        # Extraemos el bit menos significativo
addi $t5, $t5, 48       # Convertimos el valor del bit en ASCII '0' o '1'
sb $t5, ($t3)           # Almacenamos este valor en su representación de string
addiu $t3, $t3, 1       # Aumentamos la dirección actual del string
addiu $t4, $t4, -1      # Decrementamos el valor del ciclo
bgez $t4, cicloABinario # Seguimos el ciclo si el contador sigue siendo mayor a 0
li $t5, 0               # Null
sb $t5, ($t3)           # Marcamos un null al final de la cadena

#Imprimimos la mantisa almacenada cuando imprimimos el número normalizado
imprimirExpMantisa:
li $v0, 4
la $a0, binarioExponente
syscall
li $v0, 4
la $a0, espacio
syscall

imprimirMantisa:
la $t3, mantisa
li $t4, 22

cicloMantisa:
lb $t5, ($t3)
li $v0, 11                    
move $a0, $t5 
syscall			  # Imprimimos el caracter
addiu $t3, $t3, 1
addiu $t4, $t4, -1      # Decrementamos el valor del ciclo
bgez $t4, cicloMantisa    # Seguimos el ciclo si el contador sigue siendo mayor a 0
j fin 

representacionCero:
li $v0, 4  # Caso que solo ocurre cuando el numero leido es 0
la $a0, numeroNormalizado
syscall
li $v0, 1
li $a0, 0
syscall
li $v0, 4
la $a0, puntoFlotante
syscall
la $t5, signo
lb $t6, ($t5)
beq $t6, '-', imprimirUno2
beq $t6, '+', imprimirCero2

imprimirCero2:
li $v0, 1
li $a0, 0
syscall
j seguirRepresentacion

imprimirUno2:
li $v0, 1
li $a0, 1
syscall

seguirRepresentacion:
li $v0, 4
la $a0, espacio
syscall
li $v0, 4
la $a0, exponenteCero
syscall
li $v0, 4
la $a0, espacio
syscall
li $v0, 4
la $a0, mantisa
syscall

#Termina el programa
fin:
li $v0, 10
syscall
#Proyect 1 
#Integrantes:
#Christian Cusato C.I.28.301.116
#Jesus Matcha C.I.29.954.818
#Catalina Matheus C.I.28.315.479

