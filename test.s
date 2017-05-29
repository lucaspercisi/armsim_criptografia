@========================================= CABEÇALHO ============================================  
@  
@
@	O montador decide a alocação da memória.
@
@
@================================= ENDEREÇO DOS DISPOSOTIVOS ====================================	
	
	.set KBD_DATA,   	0x00090000	@ENDEREÇO DE DADOS DO TECLADO 
	.set KBD_STATUS, 	0x00090001	@ENDEREÇO DE STATUS DO TECLADO
	
@========================================= CONSTANTES ===========================================
	
	.equ KBD_READY,		1			@CONTANTE DE VERIFICAÇÃO DO TECLADO PRESSIONADO
	.equ SIZE_MSG,		128			@TAMANHO MÁXIMO DA MENSAGEM EM CARACTERES
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
		
		mov 	r12, #0						@LIMPA CONTADOR QUE SERÁ USADO COMO DESLOCAMENTO DA MENSAGEM
		mov 	r9, #0						@LIMPA CONTADOR QUE SERÁ USADO COMO DESLOCAMENTO DA CHAVE
		
	crypto_init:
		
		mov		r10, #0						@LIMPA CONTADOR QUE SERÁ USADO PARA QUANTIDADE DE VOLTAS NO MAPA DE CARACTERS
		
		ldr     r0, =buf_in_msg				@CARREGA R0 COM ENDEREÇO DE MENSAGEM DA ENTRADA
		ldr		r1, =key					@CARREGA R1 COM ENDEREÇO DA CHAVE
		ldr 	r2, =buf_msg_encrypted		@CARREGA R2 COM ENDEREÇO DE MENSAGEM DA ENCRIPTADA
		ldr		r3, =buf_char_turns			@CARREGA R3 COM ENDEREÇO DA QUANTIDADE DE VOLTAS DO CARACTER
		ldr		r4, =mapa_caracters			@CARREGA R4 COM ENDEREÇO DO MAPA DE CARACTRES
		
		ldrb	r5, [r0, r12]				@COLOCA O R5 O CARACTER SUBSEQUENTE
		cmp		r5, #0						@VERIFICA SE A MENSAGEM CHEGOU AO FIM
		beq		crypto_finish				@TERMINA A CRIPTOGRAFIA
		
		ldrb	r6, [r1, r9]				@COLOCA EM R6 O DIGITO DA CHAVE SUBSEQUENTE
		add		r7, r5, r6					@SOMA O CARACTER ASCII COM O DIGITO DA CHAVE
		
		
		sub_byte_init:
		
			cmp		r7, #64					@COMPARA COM O TAMANHO DO MAPA DE CARACTER
			bls		save_byte_cripto		@SE A SOMA DO CARACTER COM A CHAVE FOR MENOR OU IGUAL A 64 SALVA 
			sub		r7, r7, #64				@SENÃO SUBTRAI 64 (1 VOLTA DO MAPA)
			add		r10, r10, #1			@SOMA 1 NO CONTADOR DE VOLTAS
			b 		sub_byte_init			@VERIFICA NOVAMENRE
			
		save_byte_cripto:
			
			strb 	r10, [r3, r12]			@GUARDA NA MEMÓRIA QUANTIDADE DE VOLTAS DO CARACTER
			ldrb	r7, [r4, r7]			@CARREGA EM R7 O CARACTER EQUIAVLENTE NO MAPA DE MEMORIA
			strb	r7, [r2 , r12]			@GUARDO NA MEMORIA O CARACTER CRIPTOGRAFADO
			add 	r12, r12, #1			@INCREMENTA O DESLOCAMENTO PARA O CARACTER SUBSEQUENTE
			
			add 	r9, r9, #1				@INCREMENTA CONTADOR DE DESLOCAMENTO DA CHAVE
			cmp		r9, #SIZE_KBD_KEY		@COMPRA COM O TAMANHO DA CHAVE
			bne		crypto_init				@SE A CHAVE É MENOR QUE O TAMNANHO, CRIPTA O PROXIMO CHAR
			mov 	r9, #0					@SENÃO A CHAVE É O PRIMEIRO DIGITO DA KEY
			
			b		crypto_init				@CRIPTA O PROXIMO CHAR
		
		
	crypto_finish:

	@EXIBE MENSAGEM DE ENCRIPTAÇÃO
	
	mov     r0, #1   				@MODO ESCRITA (STDOUT)   	
	ldr     r1, =crypto_msg 		@ENDEREÇO INICIAL DA ESCRITA
	ldr     r2, =size_crypto_msg  	@TAMANHO DA DOS DADOS A SEREM ESCRITOS
	mov     r7, #4					@R7 DEVE SER 4 POR ORIENTAÇÃO DO DESENVOLVEDOR      	
	svc     #0x55       	 		@FAZ A CHAMADA DO CONSOLE CONFORME OS PARAMETROS ANTERIORES
	

	@EXIBE MENSAGEM DE ENCRIPTADA
	
	mov     r0, #1   				@MODO ESCRITA (STDOUT)   	
	ldr     r1, =buf_msg_encrypted	@ENDEREÇO INICIAL DA ESCRITA
	ldr     r2, =SIZE_MSG		  	@TAMANHO DA DOS DADOS A SEREM ESCRITOS
	mov     r7, #4					@R7 DEVE SER 4 POR ORIENTAÇÃO DO DESENVOLVEDOR      	
	svc     #0x55       	 		@FAZ A CHAMADA DO CONSOLE CONFORME OS PARAMETROS ANTERIORES

	
	@EXIBE MENSAGEM DE INSERÇÃO DA CHAVE
	
	mov    	r0, #1  				@MODO ESCRITA (STDOUT)   	
	ldr    	r1,	=key_msg	 		@ENDEREÇO INICIAL DA ESCRITA
	ldr    	r2, =size_key_msg		@TAMANHO DA DOS DADOS A SEREM ESCRITOS
	mov    	r7, #4					@R7 DEVE SER 4 POR ORIENTAÇÃO DO DESENVOLVEDOR      	
	svc    	#0x55       	 		@FAZ A CHAMADA DO CONSOLE CONFORME OS PARAMETROS ANTERIORES
	
	mov		r5, #0
	
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
	
	b		read_kbd				@RETORNA PARA LER A PRÓXIMA TECLA

	
@------------------------------------------------------------------------------------------------
@REALIZA A DESCRIPTOGRAFIA E EXIBE A MENSAGEM DESCRIPTOGRAFADA

decryption:
		
		mov 	r12, #0						@LIMPA CONTADOR QUE SERÁ USADO COMO DESLOCAMENTO DA MENSAGEM
		mov		r10, #0						@LIMPA CONTADOR QUE SERÁ USADO COMO DESLOCAMENTO DO MAPA
		mov 	r9, #0						@LIMPA CONTADOR QUE SERÁ USADO COMO DESLOCAMENTO DA CHAVE
		
	decrypto_init:
		
		ldr     r0, =buf_out_msg			@CARREGA R0 COM ENDEREÇO DE MENSAGEM DE SAIDA
		ldr		r1, =buf_kbd_key			@CARREGA R1 COM ENDEREÇO DA CHAVE DE ENTARDA DO TECLADO
		ldr 	r2, =buf_msg_encrypted		@CARREGA R2 COM ENDEREÇO DE MENSAGEM DA ENCRIPTADA
		ldr		r3, =buf_char_turns			@CARREGA R3 COM ENDEREÇO DA QUANTIDADE DE VOLTAS DO CARACTER
		ldr		r4, =mapa_caracters			@CARREGA R4 COM ENDEREÇO DO MAPA DE CARACTRES
		
		ldrb 	r5, [r2, r12]				@CARREGA EM R5 O CARACTER SUBSEQUENTA DA MSG CRIPTO
		cmp		r5, #0						@VERIFICA SE A MENSAGEM CHEGOU AO FIM
		beq 	decrypto_end				@FINALIZA A DESCRIPTO
		
		mov		r10, #0
		
		search_char:
		
			ldrb	r6, [r4, r10]			@SENÃO CARREGA EM R6 O CHAR DO SUBSEQUENTE DO MAPA
			cmp		r5, r6					@COMPARA SE CHAR DA CRIPTO = CHAR DO MAPA
			beq		decrypto				@SE ENCONTRO DESCRIPTA
			add 	r10, r10, #1			@SENÃO INCREMENTA DESLOCAMENTO DO MAPA
			b 		search_char				@VOLTA A ACOMPARAR COM O PROXIMO CHAR DO MAPA

		decrypto:
						
			mov 	r8, #0					@R8 TERÁ O VALOR DE VOLTAS * 64
			ldrb 	r7, [r3, r12]			@CERREGA EM R7 QTD DE VOLTAS DE CADA CHAR
		
			multi_turns:
				
				cmp		r7 , #0				@COMPARA QTD DE VOLTAS COM 0
				beq		multi_turns_end		@SE FOR 0, FINALIZA A MULTIPLICAÇÃO
				add		r8, r8, #64			@SENÃO SOMA 0x40 EM, R8
				sub		r7, r7, #1			@DECREMENTA QTD DE VOLTAS
				b   	multi_turns			@VOLTA PARA VERIFICAR MULTIPLICAÇÃO

			multi_turns_end:
				
				
				add 	r8, r8, r10			@					
				ldrb 	r6, [r1, r9]		@CARREGA EM R8 A CHAVE DO CHAR DE ENTRADA
				sub 	r5, r8, r6			@DIMINUI O CHAR DA MSG CRIPTO DO VALOR DA CHAVE
				strb 	r5, [r0, r12]		@GUARDA NA MEMORIA O RESULTADO DE DESCRITOGRAFIA
				
				add 	r12, r12, #1		@INCREMENTA DESLOCAMENTO DA MENSAGEM
				add 	r9, r9, #1			@INCREMENMTA DESLOCAMENTO DA CHAVE
				
				cmp		r9, #SIZE_KBD_KEY
				bne		decrypto_init
				mov 	r9, #0
				
				b		decrypto_init		@TUDO DENOVO PARA O PROXIMO CARACTER
	
	decrypto_end:
	
		
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
	add 	r0, r0, #SIZE_MSG		@MEMÓRIA SEQUENCIALMENTE CONFORME DECLARADO EM CÓDIGO
	add 	r0, r0, #SIZE_MSG
	add 	r0, r0, #SIZE_MSG
	add 	r0, r0, #SIZE_KBD_KEY	@
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
buf_msg_encrypted:	.skip	SIZE_MSG				@BUFFER DA MENSAGEM CRIPTOGRAFADA 
buf_kbd_key:		.skip	SIZE_KBD_KEY			@BUFFER DA CHAVE DE CRIPTOGRAFIA
buf_char_turns:		.skip	SIZE_MSG
buf_test:			.skip	SIZE_MSG

@MAPA DE CARACTERES UTILIZADO NA CRIPTOGRAFIA
mapa_caracters: 	.byte 	0X40,0x30,0x31,0x32		@@,0,1,2
					.byte	0x33,0x34,0x35,0x36		@3,4,5,6	
					.byte	0x37,0x38,0x39,0x61		@7,8,9,a
					.byte	0x62,0x63,0x64,0x65		@b,c,d,e
					.byte	0x66,0x67,0x68,0x69		@f,g,h,i
					.byte	0x6A,0x6B,0x6C,0x6D		@j,k,l,m
					.byte	0x6E,0x6F,0x70,0x71		@n,o,p,q
					.byte	0x72,0x73,0x74,0x75		@r,s,t,u
					.byte	0x76,0x77,0x78,0x79		@v,w,x,y
					.byte	0x7A,0x41,0x42,0x43		@z,A,B,C
					.byte	0x44,0x45,0x46,0x47		@D,E,F,G
					.byte	0x48,0x49,0x4A,0x4B		@H,I,J,K
					.byte	0x4C,0x4D,0x4E,0x4F		@L,M,N,O
					.byte	0x50,0x51,0x52,0x53		@P,Q,R,S		
					.byte	0x54,0x55,0x56,0x57		@T,U,V,W
					.byte	0x58,0x59,0x5A,0x24		@X,Y,Z,$
					
key:				.byte	0x01,0x03,0x04,0x07 	@CHAVE DE CRIPTOGRAFIA
					.byte	0x01,0x01,0x01,0x08		@1347 1118 2947 7613
					.byte	0x02,0x09,0x04,0x07		@FIBONACCI COM 1 E 3 ATÉ 16 CHAR EXCLUIDO O ULTIMO 2
					.byte	0x07,0x06,0x01,0x03		@BY RAFAEL
					
@=============================== MENSAGEM PARA EXIBUÇÃO NO CONSOLE ==============================

intro_msg:
	.ascii "\n ===================================================================================="
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
