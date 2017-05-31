# armsim_criptografia
Criptografia rodando em arquitetura ARM utilizando o simulador ArmSim, codificado em Assembly

UNIVERSIDADE FEDERAL DA FRONTEIRA SUL
Curso de Ciência da Computação

Trabalho parcial de Organização de Computadores
Professor: Adriano Sanick Padilha

Descrição:
	
	O trabalho consiste em ler uma mensagem passada pelo usuario 
	através do console, criptografar a mensagem, mostrar a mensagem
	criptografada, solicitar chave de descriptografia, descriptografar a mensagem
	e por fim mostra-la no console.
		
	A codificação deve ser feita em Assembly para ARM utilizando o simulador ArmSim
		
	O simulador e suas instruções de uso encontram-se no site:
	http://www.ic.unicamp.br/~ranido/livrolm/ferramentas/arm.html

	
O trabalho será realizado por:
	- Lucas Percisi
	- Rafael Nascimento
	- Eduardo Stefanello

A entrega e apresentação na data: 31/05/2017

OBS.: 	Para entender com maior facilidade funcionamento da criptografia 
		deve-se ler o arquivo "funcionamento_da_criptografia.pdf"
		na pasta "documentação" deste repositório. 
____________________________________________________

=================== INSTRUÇÕES =====================

- Abra o terminal no local dos arquivos do repósitório.
- Execute o montador:
	
	Linux: 
			./arm-none-eabi-as -o test.o test.s
	
	Windows: 
			arm-none-eabi-as.exe -o test.o test.s

- Depois o ligador:

	Linux: 
			./arm-none-eabi-ld -T mapa.lds -o test test.o
	
	Windows: 
			arm-none-eabi-ld -T mapa.lds -o test test.o

- Por fim, o simulador:

	Linux: 
			armsim -c -l test -d devices.txt

	Windows:

			java -jar armsim.jar -c -l test -d devices.txt

OU .... sem alterar nenhum arquivo e utilizando Windows, execute o arquivo start.bat			
			
- No simulador, execute "g _start" para iniciar a simulção.
- Caso tenha dúvidas com o simulador, execute 'h' para ver as opções de Help.
____________________________________________________
====================================================