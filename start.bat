arm-none-eabi-as.exe -o test.o test.s
arm-none-eabi-ld -T mapa.lds -o test test.o
java -jar armsim.jar -c -l test -d devices.txt

Fin(x) = Cin[x] * Key[x] - 	{0 if  x <= 64; }           
							{0x40 if 64 > x <= 128}
							{0x80 if 128 > x <= 192}
							{0xC0 if 192 > x <= 255}

							
MAPA DE CARACTERS:

0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
@ 0 1 2 3 4 5 6 7 8 9  a  b  c  d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u

32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63
v  w  x  y  z  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q  R  S  T  U  V  W  X  Y  Z  null

TESTE
							CRIPTOGRAFANDO
	
	L  u  c  a  s     P  e  r  c  i  s  i     P  a  n  d  o  l  f  o	String de Entrada
	4c 75 63 61 73 20 50 65 72 63 69 73 69 20 50 61 6e 64 6f 6c 66 6f	String em ASCII
	03 01 06 07 07 04 09 02 08 01 01 01 07 04 03 01 03 01 06 07 07 04	Chave para cada Char
	4f 76 69 68 7a 24 59 67 7a 64 6a 74 70 24 53 62 71 65 75 73 6d 73	Soma do caracter com a chave
	01 01 01 01 01 00 01 01 01 01 01 01 01 00 01 01 01 01 01 01 01 01	Quantidade de voltas
	0f 36 29 28 3a 24 19 27 3a 24 2a 34 30 24 13 22 31 25 35 33 2d 33	(Soma do caracter com a chave)-(Quantidade de voltas*64)
	15 54 41 40 58 36 25 39 58 36 42 52 48 36 19 34 49 37 53 51 45 51	Resultado em Decimal
	e  R  E  D  V  z  o  C  V  z  F  P  L  z  i  x  M  A  Q  O  I  O	Char resultado do mapa de Caracter
							
							DESCRIPTOGRAFANDO
	e																	Busca o char no mapa
	15																	Quantidade de deslocamentos
	01																	Quantidade de voltas na cripto
	4f																	(Quantidade de deslocamentos)+(Quantidade de voltas na cripto*0x40)
	03																	Subtrai a chave
	4c																	Char resultando em ASCII
	L																	Char resultante
	
	