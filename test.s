@====================== CABEÇALHO ==========================================
  
 @r0, r1, r2, r7 -> console
 @r3, r4, r5, r6 -> teclado
 
@================= ENDEREÇO DOS DISPOSITIVOS ===============================
	
	.set KBD_DATA,   	0x00090000	@ENDEREÇO DE DADOS DO TECLADO 
	.set KBD_STATUS, 	0x00090001	@ENDEREÇO DE STATUS DO TECLADO
	
@======================== CONSTANTES =======================================

	.set KBD_READY,		1			@CONTANTE DE VERIFICAÇÃO DO TECLADO PRESSIONADO
	.set KBD_OVRN,   	2			@CONSTANTE DE VERIFICAÇÃO DE ERRO DO TECLADO
	.set SIZE_MSG,		64			@TAMANHO MÁXIMO DA MENSAGEM 
	.set SIZE_CRYPTO,	256			@TAMANHO MÁXIMO DA CRIPTOGRAFIA
	.set SIZE_KYB, 		12			@TAMANHO MÁXIMO DA INFORMAÇÃO DO TECLADO

		
@========================== INICÍO =========================================	

_start:
		
	b 	read_msg	
		
@========================= SUB-ROTINAS =====================================	

@--------- LÊ A MENSAGEM PARA CRIPTOGRAFAR ---------------		
read_msg:

	@ESCREVE O CABEÇALHO
	mov     r0, #1   				@MODO ESCRITA (STDOUT)   	
	ldr     r1, =intro_msg 			@ENDEREÇO INICIAL DA ESCRITA
	ldr     r2, =size_intro_msg  	@TAMANHO DA DOS DADOS A SEREM ESCRITOS
	mov     r7, #4					@R7 DEVE SER 4 POR ORIENTAÇÃO DO DESENVOLVEDOR      	
	svc     #0x55       	 		@FAZ A CHAMADA DO CONSOLE CONFORME OS PARAMETROS ANTERIORES

	@LEITURA DA MENSAGEM
	mov     r0, #0      			@MODO LEITURA (STDIN)
	ldr     r1, =bufIN_msg 			@ENDEREÇO INICIAL PARA GUARDAR A STRING
	ldr     r2, =SIZE_MSG 			@TAMANHO DA STRING EM CARACTRES (BYTES)
	mov     r7, #3      			@R7 DEVE SER 3 POR ORIENTAÇÃO DO DESENVOLVEDOR
	svc     #0x55        			@FAZ A CHAMADA DO CONSOLE CONFORME OS PARAMETROS ANTERIORES
	
	@ESCREVE MENSAGEM DE ENCRIPTAÇÃO
	mov     r0, #1   				@MODO ESCRITA (STDOUT)   	
	ldr     r1, =crypto_msg 		@ENDEREÇO INICIAL DA ESCRITA
	ldr     r2, =size_crypto_msg  	@TAMANHO DA DOS DADOS A SEREM ESCRITOS
	mov     r7, #4					@R7 DEVE SER 4 POR ORIENTAÇÃO DO DESENVOLVEDOR      	
	svc     #0x55       	 		@FAZ A CHAMADA DO CONSOLE CONFORME OS PARAMETROS ANTERIORES
	mov 	r0, #0
	
	b 		encryption				@VAI PARA CRIPTOGRAFIA

	
@----------------- CRIPTOGRAFA A MENSAGEM ----------------
	
encryption:

	
	@------------------------------------------
	@----AQUI DEVE SER REALIZADO A CRIPTOGRAFIA
	@------------------------------------------
	

	mov     r0, #1   				@MODO ESCRITA (STDOUT)   	
	ldr     r1, =key_msg 			@ENDEREÇO INICIAL DA ESCRITA
	ldr     r2, =size_key_msg	  	@TAMANHO DA DOS DADOS A SEREM ESCRITOS
	mov     r7, #4					@R7 DEVE SER 4 POR ORIENTAÇÃO DO DESENVOLVEDOR      	
	svc     #0x55 
	
	b		read_kbd
	
read_kbd:
	
	ldr		r3, =KBD_STATUS			@ATRIBUUI AO R1 O ENDEREÇO DE STATUS DO TECLADO
	mov 	r5, #0					@LIMPA REGISTRADOR QUE GUARDO VALOR DO TECLADO
	ldr		r4, [r3]				@CARREGA NO R4 O VALOR DO ENDEREÇO R3
	cmp     r4, #KBD_READY			@COMPARA R4 COM 0x1
	bne    	read_kbd				@DESVIA SE VERDADEIRO
	ldr		r3, =KBD_DATA			@CARREGA EM R3 O VALOR NO ENDEREÇO DE DADOS DO TECLADO
	ldr		r5,	[r3]				@CARREGA EM R5 O VALOR DO BOTÃO PRESSIONADO
	
	mov    	r0, #1  				@MODO ESCRITA (STDOUT)   	
	ldr    	r1,	=asterisk	 		@ENDEREÇO INICIAL DA ESCRITA
	ldr    	r2, =size_asterisk		@TAMANHO DA DOS DADOS A SEREM ESCRITOS
	mov    	r7, #4					@R7 DEVE SER 4 POR ORIENTAÇÃO DO DESENVOLVEDOR      	
	svc    	#0x55       	 		@FAZ A CHAMADA DO CONSOLE CONFORME OS PARAMETROS ANTERIORES
	
	@-------------------------------------------------
	@----REALIZAR O SALVAMENTO DOS DIGITOS DO TECLADO
	@-------------------------------------------------
	
	cmp		r5, #11					@COMPARA SE FOI APERTADO '#' 
	bne		read_kbd				@SE FOR DIFERENTE, LE OUTRO NUMERO					
	b 		decryption				@SENÃO, FAZ A DESCRIPTOGRAFIA

decryption:
	
	mov     r0, #1   				@MODO ESCRITA (STDOUT)   	
	ldr     r1, =msg_decypted 		@ENDEREÇO INICIAL DA ESCRITA
	ldr     r2, =size_msg_decypted	@TAMANHO DA DOS DADOS A SEREM ESCRITOS
	mov     r7, #4					@R7 DEVE SER 4 POR ORIENTAÇÃO DO DESENVOLVEDOR      	
	svc     #0x55 

	@-------------------------------------
	@----AQUI FAZER A DESCRIPTOGTAFIA
	@-------------------------------------

	b 		exit_con


@ ----------------- FINALIZA O CONSOLE -------------------
exit_con:    

	mov     r0, #0      
	mov     r7, #1      
	svc     #0x55


@=======================  BUFFERS  =========================================	

bufIN_msg:
	.skip	SIZE_MSG				@BUFFER DA MENSAGEM DE ENTRADA
 
buf_msg_encrypted:
	.skip	SIZE_CRYPTO				@BUFFER DA CRIPTOGRAFIA 
 	
buf_kyb:
	.skip 	SIZE_KYB
	
	
@=================  MENSAGENS PARA O CONSOLE  ==============================

intro_msg:
	.ascii "\n--------------------------------------"
	.ascii "\nTRABALHO DE ORGANIZACAO DE COMPUTADORES\n"
	.ascii "\t\t  ARM\n"
	.ascii "--------------------------------------\n"
	.ascii "\n\nINFORME A MENSAGEM A SER CRIPTOGRAFADA.\n"
size_intro_msg = . - intro_msg	

crypto_msg:
	.ascii   "\nMENSAGEM CRIPTOGRAFADA:\n"	
size_crypto_msg = . - crypto_msg

key_msg:
	.ascii "\nINFORME A CHAVE DE DESCRIPTOGRAFIA. (USE O TECLADO VIRTUAL)\n"
	.ascii "\nCHAVE: "
size_key_msg = . - key_msg	

asterisk:
	.ascii "*"			
size_asterisk = . - asterisk
	
msg_decypted:
		.ascii "\n\nMENSAGEM DESCRIPTOGRAFADA:\n\n";
size_msg_decypted= . - msg_decypted
	
	