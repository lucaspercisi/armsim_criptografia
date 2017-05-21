@========================================= CABEÇALHO ============================================  
@  
@
@	O montador decide a alocação da memória.
@
@  
@
@
@  
@
@
@  
@
@
@  
@
@
@  
@
@
@ 
@================================= ENDEREÇO DOS DISPOSOTIVOS ====================================	
	
	.set KBD_DATA,   	0x00090000	@ENDEREÇO DE DADOS DO TECLADO 
	.set KBD_STATUS, 	0x00090001	@ENDEREÇO DE STATUS DO TECLADO
	
@========================================= CONSTANTES ===========================================
	
	.equ KBD_READY,		1			@CONTANTE DE VERIFICAÇÃO DO TECLADO PRESSIONADO
	.equ SIZE_MSG,		128			@TAMANHO MÁXIMO DA MENSAGEM EM CARACTERES
	.equ SIZE_CRYPTO,	256			@TAMANHO MÁXIMO DA CRIPTOGRAFIA
	.equ SIZE_KBD_KEY,	16			@QUANTIDADE DE DIGITOS DA CHAVE DE CRIPTOGRAFIA
	
	.equ KEY,			7			@ZOERA
	
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
	
	
	@REMOVE O CARACTER 'ENTER' DA MENSAGEM
	
	mov		r0, #0					@VALOR PARA MANIPULAÇÃO DO DESLOCAMENTO	
	search_caracter:
	
		ldr 	r2, =buf_in_msg 	@ENDEREÇO DA MENSAGEM
		ldrb 	r3, [r2, r0]		@CAREGA A BYTE O CARACTER DA MENSAGEM
		add 	r0, r0, #1			@INCRMENTA O DESLOCAMENTO
		mov		r1, #0				@LIMPA R1
		cmp		r3, r1				@COMPARA COM NULL
		beq		encryption			@SE IGUAL, ACABA A BUSCA PARA NÃO FICAR EM LOOP
		mov 	r1, #0x0A			@'LINE FEED' OU 'ENTER' DA ASCII
		cmp		r3, r1				@COMPARA COM LINE FEED
		bne		search_caracter		@SE DIFERENTE DE 'ENTER' COMPARA COM OUTRO CARACTER
		
		mov 	r3, #0				@SENÃO LIMPA R3
		sub 	r0, r0, #1			@RETORNA UMA POSIÇÃO NA MEMÓRIA
		strb 	r3, [r2, r0]		@LIMPA LOCAL DA MEMÓRIA AONDE FOI PRESSIONADO ENTER
		
	b 		encryption				@VAI PARA CRIPTOGRAFIA


@------------------------------------------------------------------------------------------------	
@CRIPTOGRAFA A MENSAGEM

encryption:

	mov		r8, #KEY
	mov 	r0, #0
	
	crypto_init:
		
		ldr     r12, =buf_in_msg
		ldrb	r9, [r12, r0]
		cmp		r9, #0
		beq		crypto_finish
		add		r9, r9, r8
		ldr     r12, =buf_msg_encrypted
		strb	r9, [r12, r0]
		add 	r0, r0, #1
		b		crypto_init		

	crypto_finish:

	@EXIBE MENSAGEM DE ENCRIPTAÇÃO
	
	mov     r0, #1   				@MODO ESCRITA (STDOUT)   	
	ldr     r1, =crypto_msg 		@ENDEREÇO INICIAL DA ESCRITA
	ldr     r2, =size_crypto_msg  	@TAMANHO DA DOS DADOS A SEREM ESCRITOS
	mov     r7, #4					@R7 DEVE SER 4 POR ORIENTAÇÃO DO DESENVOLVEDOR      	
	svc     #0x55       	 		@FAZ A CHAMADA DO CONSOLE CONFORME OS PARAMETROS ANTERIORES
	mov 	r0, #0					@FAZ A CHAMADA DO CONSOLE CONFORME OS PARAMETROS ANTERIORES

	
	@EXIBE MENSAGEM DE ENCRIPTADA
	
	mov     r0, #1   				@MODO ESCRITA (STDOUT)   	
	ldr     r1, =buf_msg_encrypted	@ENDEREÇO INICIAL DA ESCRITA
	ldr     r2, =SIZE_CRYPTO	  	@TAMANHO DA DOS DADOS A SEREM ESCRITOS
	mov     r7, #4					@R7 DEVE SER 4 POR ORIENTAÇÃO DO DESENVOLVEDOR      	
	svc     #0x55       	 		@FAZ A CHAMADA DO CONSOLE CONFORME OS PARAMETROS ANTERIORES
	mov 	r0, #0					@FAZ A CHAMADA DO CONSOLE CONFORME OS PARAMETROS ANTERIORES
		
	@EXIBE MENSAGEM DE INSERÇÃO DA CHAVE
	
	mov    	r0, #1  				@MODO ESCRITA (STDOUT)   	
	ldr    	r1,	=key_msg	 		@ENDEREÇO INICIAL DA ESCRITA
	ldr    	r2, =size_key_msg		@TAMANHO DA DOS DADOS A SEREM ESCRITOS
	mov    	r7, #4					@R7 DEVE SER 4 POR ORIENTAÇÃO DO DESENVOLVEDOR      	
	svc    	#0x55       	 		@FAZ A CHAMADA DO CONSOLE CONFORME OS PARAMETROS ANTERIORES

	@CONFIGURA RESGITRADORES PARA PROXIMA ROTINA
	
	mov		r6, #0					@LIMPA RESITRADOR QUE CONTERÁ A CHAVE DE DESCRIPTOGRAFIA
	mov 	r5, #0					@LIMPA REGISTRADOR USADO PARA DESLOCAMENTO
	
	
	b		read_kbd_asterisco		@VAI PARA LEITURA DO TECLADO VIRTUAL
	
	
@------------------------------------------------------------------------------------------------	
@LÊ O TECLADO VIRTUAL
	
read_kbd_asterisco:
	
	@EXIGE O USUÁRIO PRESSIONAR '*' PARA INSERIR A CHAVE
	
	ldr		r3, =KBD_STATUS			@ATRIBUUI AO R1 O ENDEREÇO DE STATUS DO TECLADO
	ldr		r4, [r3]				@CARREGA NO R4 O VALOR DO ENDEREÇO R3
	cmp     r4, #KBD_READY			@COMPARA R4 COM 0x1
	bne    	read_kbd_asterisco		@DESVIA SE VERDADEIRO
	ldr		r3, =KBD_DATA			@CARREGA EM R3 O VALOR NO ENDEREÇO DE DADOS DO TECLADO
	ldr		r4, [r3]				@CARREGA EM R4 O CONTEUDO DO ENDEREÇO DE R3
	cmp		r4, #10					@COMPARA COM O BOTÃO '*' DO TECLADO VIRTUAL
	bne		read_kbd_asterisco		@SE DIFERENTE VOLTA A MONITORAR A TECLA
	
	
	@EXIBE UM ASTERISCO DEVIDO APERTO DE TECLA
	
	mov    	r0, #1  				@MODO ESCRITA (STDOUT)   	
	ldr    	r1,	=asterisk	 		@ENDEREÇO INICIAL DA ESCRITA
	ldr    	r2, =size_asterisk		@TAMANHO DA DOS DADOS A SEREM ESCRITOS
	mov    	r7, #4					@R7 DEVE SER 4 POR ORIENTAÇÃO DO DESENVOLVEDOR      	
	svc    	#0x55       	 		@FAZ A CHAMADA DO CONSOLE CONFORME OS PARAMETROS ANTERIORES
	
read_kbd:
	
	@MONITORA AS TECLAS DO TECLADO E GUARDA O DADO QUANDO PRESSIONADO
	
	ldr		r3, =KBD_STATUS			@ATRIBUUI AO R3 O ENDEREÇO DE STATUS DO TECLADO
	ldr		r4, [r3]				@CARREGA NO R4 O VALOR DO ENDEREÇO R3
	cmp     r4, #KBD_READY			@COMPARA R4 COM 0x1
	bne    	read_kbd				@DESVIA SE VERDADEIRO
	ldr		r3, =KBD_DATA			@CARREGA EM R3 O VALOR NO ENDEREÇO DE DADOS DO TECLADO
	ldr		r4, [r3]				@CARREGA EM R4 O CONTEUDO DO ENDEREÇO DE R3

	
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

	@REALIZAR O SALVAMENTO DOS DIGITOS DO TECLADO EM MEMÓRIA	
	
	@ANTES DE SALVAR, A CHAVE NÃO DEVE SOBREPOR A MEMÓRIA RESERVADA PARA OUTRA COISA.
	@PORTANTO O USUÁRIO PODERÁ DIGITAR QUANTOS DIGITOS QUISER, PORÉM SERÁ SALVO
	@NA MEMÓRIA SOMENTE O ESTIPULADO NA MONTAGEM
	
	mov		r10, #SIZE_KBD_KEY		@TAMANHO DA CHAVE NO R10
	sub		r10, r10, #1			@DECREMENTA R10 (CONSIDERAÇÃO DE 0 NA CONTAGEM)
	cmp 	r10, r5					@COMPARA COM O DESLOCAMENTO DE ESCRITA DA CHAVE
	bcc		read_kbd				@SE DESLOCAMENTO MENOR QUE MEMÓRIA RESERVADA, NÃO SALVA E LÊ OUTRO CARACTER 

	@AQUI ACONTECE O SALVAMENTO NA MEMÓRIA 		
	ldr 	r6, =buf_kbd_key		@R6 CONTÉM O ENDEREÇO DO BUFFER DO TECLADO	
	strb	r4, [r6, r5]			@ARMAZENA O LBS DE R4 NO BUFFER DO TECLADO 
	add 	r5, r5, #1				@INCREMENTA O DESLOCAMENTO
	mov 	r4, #0					@LIMPA REGISTRADOR QUE ARMAZENA VALOR DO TECLADO
	
	b		read_kbd				@RETORNA PARA LER A PRÓXIMA TECLA

	
@------------------------------------------------------------------------------------------------
@REALIZA A DESCRIPTOGRAFIA E EXIBE A MENSAGEM DESCRIPTOGRAFADA

decryption:
	
	ldr	r8, buf_kbd_key
	mov r0, #0

		decryption_init:
			
			ldr     r12, =buf_msg_encrypted
			ldrb	r9, [r12, r0]
			cmp		r9, #0
			beq		decryption_finish
			sub		r9, r9, r8
			ldr     r12, =buf_out_msg
			strb	r9, [r12, r0]
			add 	r0, r0, #1
			b 		decryption_init
			
		decryption_finish:
		
		
	@EXIBE MENSAGEM DE DESCRIPTOGRAFIA
	
	mov    	r0, #1  				@MODO ESCRITA (STDOUT)   	
	ldr    	r1,	=msg_decrypted		@ENDEREÇO INICIAL DA ESCRITA
	ldr    	r2, =size_msg_decrypted	@TAMANHO DA DOS DADOS A SEREM ESCRITOS
	mov    	r7, #4					@R7 DEVE SER 4 POR ORIENTAÇÃO DO DESENVOLVEDOR      	
	svc    	#0x55       	 		@FAZ A CHAMADA DO CONSOLE CONFORME OS PARAMETROS ANTERIORES
	
	
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

	@ROTINA PARA LIMPEZA COMPLETA DOS BUFFERS (NECESSÁRIO PARA SIMULAÇÃO DIRETA, SEM MONTAGEM).	
	
	mov 	r0, #0					@LIMPA R0
	add 	r0, r0, #SIZE_MSG		@OS 4 COMANDOS A SEGUIR É PARA SOMAR A QUANTIDADE
	add 	r0, r0, #SIZE_MSG		@DE MEMÓRIA TOTAL RESERVADA QUE QUERO LIMPAR,
	add 	r0, r0, #SIZE_CRYPTO	@ESTOU APROVEITANDO QUE O MONTADOR RESERVA A
	add 	r0, r0, #SIZE_KBD_KEY	@MEMÓRIA SEQUENCIALMENTE CONFORME DECLARADO EM CÓDIGO
	sub		r0, r0, #4
	mov 	r1, #0					@DADO A SER GRAVADO NA MEMPRIA
	ldr		r2, =buf_in_msg			@R2 TEM O ENDEREÇO INICIAL DA LIMPEZA
	
	
	clear_intit:	

		str		r1, [r2, r0]			@LIMPA DE TRÁS PARA FRENTE (DESLOCAMENTO MÁXIMO)
		sub		r0, r0, #4				@SUBTRAI O DESLOCAMENTO EM 1 WORD
		cmp		r0, #0					@COMPARA SE CHEGOU A ZERO
		bne		clear_intit				@SE NÃO É ZERO, LIMPA A WORD ANTERIOR
		str		r1, [r2]				@SE FOR ZERO LIMPA A WORD INICIAL
	
	
	@FINALIZAÇÃO DO CONSOLE	CONFORME DESENVOLVEDOR
	
	mov     r0, #0      			
	mov     r7, #1      
	svc     #0x55

	
@------------------------------------------------------------------------------------------------
@============================================ BUFFERS ===========================================	

buf_in_msg:			.skip	SIZE_MSG				@BUFFER DA MENSAGEM 
buf_out_msg:		.skip	SIZE_MSG				@BUFFER DA MENSAGEM DESCRIPTOGRAFADA
buf_msg_encrypted:	.skip	SIZE_CRYPTO				@BUFFER DA MENSAGEM CRIPTOGRAFADA 
buf_kbd_key:		.skip	SIZE_KBD_KEY			@BUFFER DA CHAVE DE CRIPTOGRAFIA

@=============================== MENSAGEM PARA EXIBUÇÃO NO CONSOLE ==============================

intro_msg:
	.ascii " ===================================================================================="
	.ascii "\n ------------------------------------------"
	.ascii "\n  TRABALHO DE ORGANIZACAO DE COMPUTADORES\n"
	.ascii "\t\t    ARM\n"
	.ascii " ------------------------------------------\n"
	.ascii "\n\n INFORME A MENSAGEM A SER CRIPTOGRAFADA (128 CARACTERES).\n"
size_intro_msg = . - intro_msg	


crypto_msg:
	.ascii   "\n MENSAGEM CRIPTOGRAFADA:\n\n "	
size_crypto_msg = . - crypto_msg


key_msg:
	.ascii "\n\n INFORME A CHAVE DE DESCRIPTOGRAFIA (USE O TECLADO VIRTUAL).\n"
	.ascii "\n CHAVE: "
size_key_msg = . - key_msg	


asterisk:
	.ascii "*"			
size_asterisk = . - asterisk

	
msg_decrypted:
		.ascii "\n\n MENSAGEM DESCRIPTOGRAFADA:\n\n ";
size_msg_decrypted= . - msg_decrypted
