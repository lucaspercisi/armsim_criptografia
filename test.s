@========================================= CABEÇALHO ============================================  
  
  
  
  
@================================= ENDEREÇO DOS DISPOSOTIVOS ====================================	
	
	.set KBD_DATA,   	0x00090000	@ENDEREÇO DE DADOS DO TECLADO 
	.set KBD_STATUS, 	0x00090001	@ENDEREÇO DE STATUS DO TECLADO
	
@========================================= CONSTANTES ===========================================
	
	.equ KBD_READY,		1			@CONTANTE DE VERIFICAÇÃO DO TECLADO PRESSIONADO
	.equ SIZE_MSG,		64			@TAMANHO MÁXIMO DA MENSAGEM 
	.equ SIZE_CRYPTO,	256			@TAMANHO MÁXIMO DA CRIPTOGRAFIA
	.equ SIZE_KBD_KEY,	32			@(64bits)TAMANHO DA CHAVE DE CRIPTOGRAFIA
	
@========================================== VARIÁVEIS ===========================================	


@=========================================== INÍCIO =============================================
_start:
	
	b 		read_msg	

	
@========================================== SUB-ROTINAS =========================================	

@------------------------------------------------------------------------------------------------
@LÊ A MENSAGEM PARA CRIPTOGRAFAR		
read_msg:

	@ESCREVE O CABEÇALHO
	mov     r0, #1   				@MODO ESCRITA (STDOUT)   	
	ldr     r1, =intro_msg 			@ENDEREÇO INICIAL DA ESCRITA
	ldr     r2, =size_intro_msg  	@TAMANHO DA DOS DADOS A SEREM ESCRITOS
	mov     r7, #4					@R7 DEVE SER 4 POR ORIENTAÇÃO DO DESENVOLVEDOR      	
	svc     #0x55       	 		@FAZ A CHAMADA DO CONSOLE CONFORME OS PARAMETROS ANTERIORES

	@LEITURA DA MENSAGEM
	mov     r0, #0      			@MODO LEITURA (STDIN)
	ldr     r1, =buf_in_msg 		@ENDEREÇO INICIAL PARA GUARDAR A STRING
	ldr     r2, =SIZE_MSG 			@TAMANHO DA STRING EM CARACTRES (BYTES)
	mov     r7, #3      			@R7 DEVE SER 3 POR ORIENTAÇÃO DO DESENVOLVEDOR
	svc     #0x55        			@FAZ A CHAMADA DO CONSOLE CONFORME OS PARAMETROS ANTERIORES
	
	b 		encryption				@VAI PARA CRIPTOGRAFIA


@------------------------------------------------------------------------------------------------	
@CRIPTOGRAFA A MENSAGEM
encryption:

	@EXIBE MENSAGEM DE ENCRIPTAÇÃO
	mov     r0, #1   				@MODO ESCRITA (STDOUT)   	
	ldr     r1, =crypto_msg 		@ENDEREÇO INICIAL DA ESCRITA
	ldr     r2, =size_crypto_msg  	@TAMANHO DA DOS DADOS A SEREM ESCRITOS
	mov     r7, #4					@R7 DEVE SER 4 POR ORIENTAÇÃO DO DESENVOLVEDOR      	
	svc     #0x55       	 		@FAZ A CHAMADA DO CONSOLE CONFORME OS PARAMETROS ANTERIORES
	mov 	r0, #0					@FAZ A CHAMADA DO CONSOLE CONFORME OS PARAMETROS ANTERIORES
	
	
	@------------------------------------------
	@CRIPTOGRAFIA
	


	@FAZER CRIPTOGRAFIA AQUI
	

	
	@------------------------------------------
	
	
	@EXIBE A MENSAGEM CRIPTOGRAFADA
	mov    	r0, #1  				@MODO ESCRITA (STDOUT)   	
	ldr    	r1,	=buf_msg_encrypted	@ENDEREÇO INICIAL DA ESCRITA
	ldr    	r2, =size_msg_decrypted	@TAMANHO DA DOS DADOS A SEREM ESCRITOS
	mov    	r7, #4					@R7 DEVE SER 4 POR ORIENTAÇÃO DO DESENVOLVEDOR      	
	svc    	#0x55       	 		@FAZ A CHAMADA DO CONSOLE CONFORME OS PARAMETROS ANTERIORES

	@EXIBE MENSAGEM DE INSERÇÃO DA CHAVE
	mov    	r0, #1  				@MODO ESCRITA (STDOUT)   	
	ldr    	r1,	=key_msg	 		@ENDEREÇO INICIAL DA ESCRITA
	ldr    	r2, =size_key_msg		@TAMANHO DA DOS DADOS A SEREM ESCRITOS
	mov    	r7, #4					@R7 DEVE SER 4 POR ORIENTAÇÃO DO DESENVOLVEDOR      	
	svc    	#0x55       	 		@FAZ A CHAMADA DO CONSOLE CONFORME OS PARAMETROS ANTERIORES

	@CONFIGURA RESGITRADORES PARA PROXIMA ROTINA
	mov		r10, #0					@LIMPA RESITRADOR QUE CONTERÁ A CHAVE DE DESCRIPTOGRAFIA
	mov 	r5, #0					@LIMPA REGISTRADOR USADO PARA DESLOCAMENTO
	b		read_kbd				@VAI PARA LEITURA DO TECLADO VIRTUAL

	
@------------------------------------------------------------------------------------------------	
@LÊ O TECLADO VIRTUAL	
read_kbd:
	
	@MONITORA AS TECLAS DO TECLADO E GUARDA O DADO QUANDO PRESSIONADO
	ldr		r3, =KBD_STATUS			@ATRIBUUI AO R1 O ENDEREÇO DE STATUS DO TECLADO
	ldr		r4, [r3]				@CARREGA NO R4 O VALOR DO ENDEREÇO R3
	cmp     r4, #KBD_READY			@COMPARA R4 COM 0x1
	bne    	read_kbd				@DESVIA SE VERDADEIRO
	ldr		r3, =KBD_DATA			@CARREGA EM R3 O VALOR NO ENDEREÇO DE DADOS DO TECLADO
	ldr		r4, [r3]				
	
	@EXIBE UM ASTERISCO PARA CADA APERTO DE TECLA
	mov    	r0, #1  				@MODO ESCRITA (STDOUT)   	
	ldr    	r1,	=asterisk	 		@ENDEREÇO INICIAL DA ESCRITA
	ldr    	r2, =size_asterisk		@TAMANHO DA DOS DADOS A SEREM ESCRITOS
	mov    	r7, #4					@R7 DEVE SER 4 POR ORIENTAÇÃO DO DESENVOLVEDOR      	
	svc    	#0x55       	 		@FAZ A CHAMADA DO CONSOLE CONFORME OS PARAMETROS ANTERIORES
	
	@COMPARA SE APERTOU '#' PARA FAZER A DESCRIPTROGRAFIA OU SALVAR A TECLA
	cmp		r4, #11					@COMPARA SE FOI APERTADO '#' 
	bne		save_data_kbd			@SE FOR DIFERENTE, LE OUTRO NUMERO					
	b 		decryption				@SENÃO, FAZ A DESCRIPTOGRAFIA

	
@------------------------------------------------------------------------------------------------
@SALVA AS TECLAS APERTADAS NA MEMÓRIA	
save_data_kbd:

	@--------------------------------------------
	@VERIFICAR COM O PROFESSOR OS DETALHES DE
	@TRASFERÊNCIA E DE DESLOCAMENTO
	@--------------------------------------------

	@REALIZAR O SALVAMENTO DOS DIGITOS DO TECLADO EM MEMÓRIA	
	ldr 	r10, =buf_kbd_key		@R10 CONTÉM O ENDEREÇO DO BUFFER DO TECLADO	 	
	strb	r4, [r10, r5]			@ARMAZENA O LBS DE R4 NO BUFFER DO TECLADO 
	add 	r5, r5, #1				@INCREMENTA O DESLOCAMENTO
	mov 	r4, #0					@LIMPA REGISTRADOR QUE ARMAZENA VALOR DO TECLADO
	
	b		read_kbd				@RETORNA PARA LER A PRÓXIMA TECLA

	
@------------------------------------------------------------------------------------------------
@REALIZA A DESCRIPTOGRAFIA E EXIBE A MENSAGEM DESCRIPTOGRAFADA
decryption:
		
	ldr 	r8, buf_kbd_key			@CARREGA EM R8 A CHAVE DE DESCRIPTOGRAFIA 
	
	
	@------------------------------------------
	@DESCRIPTOGRAFIA
	


	@FAZER DESCRIPTOGRAFIA AQUI



	
	@------------------------------------------
	
	
	@EXIBE A MENSAGEM DESCRIPTOGRAFADA
	mov    	r0, #1  				@MODO ESCRITA (STDOUT)   	
	ldr    	r1,	=buf_out_msg 		@ENDEREÇO INICIAL DA ESCRITA
	ldr    	r2, =SIZE_MSG			@TAMANHO DA DOS DADOS A SEREM ESCRITOS
	mov    	r7, #4					@R7 DEVE SER 4 POR ORIENTAÇÃO DO DESENVOLVEDOR      	
	svc    	#0x55       	 		@FAZ A CHAMADA DO CONSOLE CONFORME OS PARAMETROS ANTERIORES

	b 		exit_prog				@FIM DO PROGRAMA			

@------------------------------------------------------------------------------------------------
@FINALIZA O PROGRAMA
exit_prog:    
	
	
	@--------------------------------------------
	@MONTAR ROTINA PARA LIMPEZA COMPLETA 
	@DOS BUFFERS
	@--------------------------------------------
	
	
	@FINALIZAÇÃO DO CONSOLE	CONFORME DESENVOLVEDOR
	mov     r0, #0      			
	mov     r7, #1      
	svc     #0x55

	
@------------------------------------------------------------------------------------------------
@============================================ BUFFERS ===========================================	

@--------------------------------------------
@VERIFICAR PORQUE BUF DA MENSAGEM DE ENTRADA
@NÃO FICA COMPLETAMENTE LIMPO
@--------------------------------------------

buf_in_msg:			.skip	SIZE_MSG				@BUFFER DA MENSAGEM 
buf_out_msg:		.skip	SIZE_MSG				@BUFFER DA MENSAGEM DESCRIPTOGRAFADA
buf_msg_encrypted:	.skip	SIZE_CRYPTO				@BUFFER DA MENSAGEM CRIPTOGRAFADA 
buf_kbd_key:		.skip	SIZE_KBD_KEY			@BUFFER DA CHAVE DE CRIPTOGRAFIA

@=============================== MENSAGEM PARA EXIBUÇÃO NO CONSOLE ==============================

intro_msg:
	.ascii "\n--------------------------------------"
	.ascii "\nTRABALHO DE ORGANIZACAO DE COMPUTADORES\n"
	.ascii "\t\t  ARM\n"
	.ascii "--------------------------------------\n"
	.ascii "\n\nINFORME A MENSAGEM A SER CRIPTOGRAFADA.\n"
size_intro_msg = . - intro_msg	


crypto_msg:
	.ascii   "\nMENSAGEM CRIPTOGRAFADA:\n\n"	
size_crypto_msg = . - crypto_msg


key_msg:
	.ascii "\nINFORME A CHAVE DE DESCRIPTOGRAFIA. (USE O TECLADO VIRTUAL)\n"
	.ascii "\nCHAVE: "
size_key_msg = . - key_msg	


asterisk:
	.ascii "*"			
size_asterisk = . - asterisk

	
msg_decrypted:
		.ascii "\n\nMENSAGEM DESCRIPTOGRAFADA:\n\n";
size_msg_decrypted= . - msg_decrypted

