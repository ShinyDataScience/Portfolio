#INCLUDE "PROTHEUS.CH"
#INCLUDE "SPEDXFUN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "SPEDPISCOF.CH"
#INCLUDE "SPEDXDEF.CH"

#Define 0210 1
#Define K001 2
#Define K100 3
#Define K200 4
#Define K210 5
#Define K215 6
#Define K220 7
#Define K230 8
#Define K235 9
#Define K250 10
#Define K255 11
#Define K260 12
#Define K265 13
#Define K270 14
#Define K275 15
#Define K280 16
#Define K300 17
#Define K301 18
#Define K302 19
#Define K990 20
#Define 0200 21
#Define K290 22
#Define K291 23
#Define K292 24

STATIC lNotAs400 := (TcSrvType()<>"AS/400")

STATIC aExistBloc	:= {	ExistBlock("SPDFIS02"),;		// 01
							ExistBlock("SPDFIS06"),;		// 02
							ExistBlock("SPEDRTMS"),;		// 03
							ExistBlock("SPDFIS08"),;		// 04
							ExistBlock("SPEDPROD"),;		// 05
							ExistBlock("SPEDPTMS"),;		// 06
							ExistBlock("SPED1300"),;		// 07
							ExistBlock("SPED1390"),;		// 08
							ExistBlock("SPEDREGD"),;		// 09
							ExistBlock("SPDFIS001",,.T.),;	// 10
							ExistBlock("SPDFIS05"),;		// 11
							ExistBlock("SPDFIS04"),;		// 12
							ExistBlock("SPEDR450"),;		// 13
							ExistBlock("SPEDR460"),;		// 14
							ExistBlock("SPEDG126"),;		// 15
							ExistBlock("SPDFIS07"),;		// 16
							ExistBlock("SPDFIS10",,.T.),;	// 17
							ExistBlock("SPDPISIC"),;		// 18
							ExistBlock("SPDFIS09"),;		// 19
							ExistBlock("SPED0205"),;		// 20
							ExistBlock("SPED0150"),;		// 21
							ExistBlock("SPDFIS03"),;		// 22
							ExistBlock("SPDPINFO"),;		// 23
							ExistBlock("SPDFISBLCK"),;		// 24
							ExistBlock("SPEDFANT"),;		// 25
							ExistBlock("SPEDH020"),;		// 26
							ExistBlock("SPDFIS27"),;		// 27
							ExistBlock("SPDF500A"),;		// 28
							ExistBlock("SPDF500C"),;		// 29
							ExistBlock("SPED1400"),;		// 30
							ExistBlock("SPEDALTH"),;		// 31
							ExistBlock("SPDFIS11")}			// 32

// Chamada das funcoes de cache do dicionario na inicializacao do SPEDXFUN.
STATIC aSPDSX2  := SpedLoadX2()
STATIC aSPDSX3  := SpedLoadX3()
STATIC aSPDSX6  := SpedLoadX6()
STATIC aCpo3Dec := SpedCp3Dec()
STATIC aCpo4Dec := SpedCp4Dec()
STATIC aCpoVaz  := SpedCpVaz()

STATIC lQryNoParal	:= iif(empty(aSPDSX6[MV_QRYPARA]) .OR. aSPDSX6[MV_QRYPARA] =="2",.F.,.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³InfPartDoc| Autor ³Gustavo G. Rueda              ³ Data ³03.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ATRIBUICAO DOS DADOS DO PARTICIPANTE NO ARRAY                      ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpN1 := InfPartDoc(cAlsSA,dDataDe,dDataAte,cAliasSFT,lCadParti)   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlsSA -> Alias da tabela SA1, SA2 ou SA4.                         ³±±
±±³          |dDataDe -> Data inicial para utilizar os dados cadastrais do       ³±±
±±³          | periodo de processamento.                                         ³±±
±±³          |dDataAte -> Data final  para utilizar os dados cadastrais do       ³±±
±±³          | periodo de processamento.                                         ³±±
±±³          |cAliasSFT -> Alias da query com join quando houver                 ³±±
±±³          |lCadParti -> Flag de existencia do PE SPDFIS06                     ³±±
±±³          |aHistSA   -> Array com os historicos de alteracoes do SA1/SA2      ³±±
±±³          |lHistTab  ->                                                       ³±±
±±³          |lExtratTAF-> Indica se foi chamado pelo Extrator TAF               ³±±
±±ÃÄÄÄÄÄÄÄÄÄ ÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1 - Array com as informacoes do participante do documento      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function InfPartDoc(cAlsSA,dDataDe,dDataAte,cAliasSFT,lCadParti,aHistSA,lHistTab,lExtratTAF)

Local aA1A2      := {}
Local cA1A2      := SubStr (cAlsSA, 3, 1)
Local cAlsCorr   := ""
Local cCodMun    := ""
Local cCmpCod    := ""
Local cCmpLoja   := ""
Local cCmpNome   := ""
Local cCmpTipo   := ""
Local cCmpCgc    := ""
Local cCmpEst    := ""
Local cCmpInsc   := ""
Local cCmpCodM   := ""
Local cCmpEnd    := ""
Local cCmpBairro := ""
Local cCmpCdPais := ""
Local cCmpSuframa:= ""
Local cCmpInscM  := ""
Local cCmpPessoa := ""
Local cContCampo := ""
Local cCmpCompl  := ""
Local cIndRur    := ""
Local aMod       := {}
Local aPart      := {}
Local lTop       := .F.
Local lConcFil   := aSPDSX6[MV_COFLSPD]
Local cInscricao := ""
Local lInscPar   := aSPDSX6[MV_INSCPAR]
Local lMv_CliFat := aSPDSX6[MV_CLIFAT]
Local lCmpCompEx := .F.
Local lDevBen    := .F.
Local lCteD100   := .F.
Local lTpMov     := .F.
Local lRural	 := aSPDSX3[FP_A2_CPFRUR] .And. aSPDSX3[FP_A2_INDRUR]

Default cAliasSFT  := ""
Default lHistTab   := aSPDSX6[MV_HISTTAB] .And. aSPDSX2[AI_AIF]
Default lExtratTAF := .F.

#IFDEF TOP
	If lNotAs400
		lTop := .T.
	Endif
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para quando jah vier por parametro, com isso evito³
//³  de chamar a funcao novamente                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lHistTab	:= Iif(aHistSA==Nil,lHistTab,.F.)
aMod		:= Iif(aHistSA==Nil,aMod,aHistSA)

//Tratamento para utilizar os campos do SELECT quando for TOP ao inves de posicionar a tabela
If lTop .And. !Empty(cAliasSFT)
	cAlsCorr := cAliasSFT
	// Validacao para não utilizar o cliente de entrega p/ nfs de devolucao e beneficiamento.
	lDevBen  := (cAliasSFT)->FT_TIPO $ "DB"
	//alteração para no caso de nota fiscal de transporte CTE levar no 150 o faturado e não o de entrega
	lCteD100 := ALLTRIM((cAliasSFT)->FT_ESPECIE) == "CTE"
	lTpMov   := ALLTRIM((cAliasSFT)->FT_TIPOMOV) == "S"
Else
	cAlsCorr := cAlsSA
EndIf

//³Campos do cadastro a serem considerados³
If cAlsSA == "SM0"
	cCmpNome	:= SM0->M0_NOMECOM
	cCmpTipo	:= "J"
	cCmpCgc		:= SM0->M0_CGC
	cCmpEst		:= SM0->M0_ESTENT
	cCmpInsc	:= SM0->M0_INSC
	cCmpCodM	:= SM0->M0_CODMUN
	cCmpEnd		:= SM0->M0_ENDENT
	cCmpBairro	:= SM0->M0_BAIRENT
	cCmpCdPais	:= ""
	cCmpSuframa	:= ""
	cCmpInscM	:= SM0->M0_INSCM
	cCmpPessoa	:= "J"
	cCmpCompl	:= ""
ElseIf cAlsSA == "SA1" .and. !lMv_CliFat .and. SpdAvalEntr(cAliasSFT,lDevBen,lCteD100,lTpMov,lMv_CliFat)
	//Tabela SA1 para que traga as informacoes do cliente de entrega
	cCmpCod		:= "SA1->A1_COD"
	cCmpLoja	:= "SA1->A1_LOJA"
	cCmpNome	:= "SA1->A1_NOME"
	cCmpTipo	:= "SA1->A1_PESSOA"
	cCmpCgc		:= "SA1->A1_CGC"
	cCmpEst		:= "SA1->A1_EST"
	cCmpInsc	:= "SA1->A1_INSCR"
	cCmpCodM	:= "SA1->A1_COD_MUN"
	cCmpEnd		:= "SA1->A1_END"
	cCmpBairro	:= "SA1->A1_BAIRRO"
	cCmpCdPais	:= "SA1->A1_CODPAIS"
	cCmpSuframa	:= "SA1->A1_SUFRAMA"
	cCmpInscM	:= "SA1->A1_INSCRM"
	cCmpPessoa	:= "SA1->A1_PESSOA"
	cCmpCompl	:= "SA1->A1_COMPLEM"
	cAlsCorr	:= cAlsSA
Else
	cCmpCod		:= cAlsCorr+"->A"+cA1A2+"_COD"
	cCmpLoja	:= cAlsCorr+"->A"+cA1A2+"_LOJA"
	cCmpNome	:= cAlsCorr+"->A"+cA1A2+"_NOME"
	cCmpTipo	:= cAlsCorr+"->A"+cA1A2+Iif ("2"$cA1A2, "_TIPO", "_PESSOA")
	cCmpCgc		:= cAlsCorr+"->A"+cA1A2+"_CGC"
	cCmpEst		:= cAlsCorr+"->A"+cA1A2+"_EST"
	cCmpInsc	:= IIF(cA1A2=="4",cAlsCorr+"->A"+cA1A2+"_INSEST" ,cAlsCorr+"->A"+cA1A2+"_INSCR")
	cCmpCodM	:= cAlsCorr+"->A"+cA1A2+"_COD_MUN"
	cCmpEnd		:= cAlsCorr+"->A"+cA1A2+"_END"
	cCmpBairro	:= cAlsCorr+"->A"+cA1A2+"_BAIRRO"
	cCmpCdPais	:= Iif(&(cAlsSA)->(FieldPos("A"+cA1A2+"_CODPAIS")) > 0,cAlsCorr+"->A"+cA1A2+"_CODPAIS","")
	cCmpSuframa	:= Iif(&(cAlsSA)->(FieldPos("A"+cA1A2+"_SUFRAMA")) > 0,cAlsCorr+"->A"+cA1A2+"_SUFRAMA","")
	cCmpInscM	:= cAlsCorr+"->A"+cA1A2+"_INSCRM"
	cCmpPessoa	:= cAlsCorr+"->A"+cA1A2+"_PESSOA"
	cCmpCompl	:= cAlsCorr+"->A"+cA1A2+"_COMPLEM"

	If cAlsSA == "SA2" .AND. lRural
		cIndRur		:= cAlsCorr+"->A"+cA1A2+"_INDRUR"
		if (&(cCmpTipo) $ "F") .AND. (&(cIndRur) $ "1,2,3") .AND. (&(cCmpEst) $ "SP|MG") //--Conforme o manual da totvs, é necessário a validação do estado, link: https://centraldeatendimento.totvs.com/hc/pt-br/articles/360026219274-MP-FIS-Como-habilitar-utiliza%C3%A7%C3%A3o-do-campo-A2-CPFRUR
			cCmpCgc := cAlsCorr+"->A"+cA1A2+"_CPFRUR"
		EndIf
	EndIf
EndIf
IF	lInscPar
	cInscricao:= RetCmpHist(cCmpInsc,aMod,dDataAte)
EndIf

If cAlsSA == "SM0"

	aAdd (aA1A2, "SM0" + SM0->(M0_CODIGO+M0_CODFIL+M0_CGC))				//02 COD_PART Código de identificação do participante no arquivo.
	aAdd (aA1A2, cCmpNome)												//03 NOME Nome pessoal ou empresarial do participante.
	aAdd (aA1A2, "01058")												//04 COD_PAIS Código do país do participante, conforme a tabela indicada no item 3.2.1
	aAdd (aA1A2, cCmpCgc)												//05 CNPJ do participante.
	aAdd (aA1A2, "")													//06 CPF do participante.
	aAdd (aA1A2, cCmpInsc)												//07 IE Inscrição Estadual do participante.
	aAdd (aA1A2, cCmpCodM)												//08 COD_MUN Código do município, conforme a tabela IBGE.
	aAdd (aA1A2, "")													//09 SUFRAMA Número de inscrição do participante na SUFRAMA.
	aAdd (aA1A2, cCmpEnd)												//10 END Logradouro e endereço do imóvel.
	aAdd (aA1A2, "SN") 													//11 NUM Número do imóvel.
	aAdd (aA1A2, cCmpCompl)												//12 COMPL Dados complementares do endereço.
	aAdd (aA1A2, cCmpBairro)											//13 BAIRRO Bairro em que o imóvel está situado.
	//aAdd (aA1A2, cCmpEst)												//13	-	UF
	//aAdd (aA1A2, cCmpInscM)											//14	-	InscMun

ElseIf cAlsSA == "SA4"

	If lHistTab .And. dDataDe<>Nil
		aMod := MsConHist(cAlsSA,,,dDataDe,,,&(cCmpCod))
	EndIf

	aAdd (aA1A2, "SA4"+Iif(lConcFil,cFilAnt,"")+(cAlsCorr)->A4_COD+cInscricao)									//01	-	COD_PART

	cContCampo := RetCmpHist(cCmpNome,aMod,dDataAte)
	aAdd (aA1A2, cContCampo)																					//02	-	NOME

	If !Empty(cCmpCdPais)
		cContCampo := RetCmpHist(cCmpCdPais,aMod,dDataAte)
		aAdd (aA1A2, AllTrim(cContCampo))																		//03	-	COD_PAIS
	Else
		aAdd (aA1A2, "01058")																					//03	-	COD_PAIS
	EndIf

	aAdd (aA1A2, "")																							//04	-	CNPJ
	aAdd (aA1A2, "")																							//05	-	CPF
	aAdd (aA1A2, "")																							//06	-	IE
	aAdd (aA1A2, "")																							//07	-	COD_MUN
	aAdd (aA1A2, "")																							//08	-	Inscricao SUFRAMA
	//
	If "01058" $ aA1A2[3]
		cContCampo := RetCmpHist(cCmpCgc,aMod,dDataAte)
		If Len(AllTrim(cContCampo))>=14 .And. &(cCmpEst)<>"EX"
			aA1A2[04] := SPEDConType(SPEDVldIE(cContCampo,,.F.))												//04	-	CNPJ

		ElseIf Len(AllTrim(cContCampo))<14 .And. &(cCmpEst)<>"EX"
			aA1A2[05] := SPEDConType(SPEDVldIE(cContCampo,,.F.))												//05	-	CPF
		EndIf

		aA1A2[06] := SPEDConType(SPEDVldIE((cAlsCorr)->A4_INSEST))												//06	-	IE

		If aSPDSX3[FP_A4_COD_MUN]
			//Tratamento para o codigo de municipio, se nao possuir o codigo do estado, tenho de colocar
			cContCampo := RetCmpHist(cCmpCodM,aMod,dDataAte)
			If Upper((cAlsCorr)->A4_EST) == "EX"
				aA1A2[07]	:=	"9999999"																		//07	-	COD_MUN

			ElseIf Len(Alltrim(cContCampo))<=5
				aA1A2[07]	:=	UfCodIBGE((cAlsCorr)->A4_EST)+Alltrim(cContCampo)								//07	-	COD_MUN
			Else
				aA1A2[07]	:=	Alltrim(cContCampo)																//07	-	COD_MUN
			EndIf
		EndIf

		If aSPDSX3[FP_A4_SUFRAMA]
			cContCampo := RetCmpHist(cCmpSuframa,aMod,dDataAte)
			aA1A2[08] := SPEDConType(cContCampo)																//08	-	SUFRAMA
		EndIf
	Else
		aA1A2[07] := "9999999"
	EndIf

	lCmpCompEx := &(cAlsCorr)->(FieldPos("A"+cA1A2+"_COMPLEM")) > 0

	cContCampo := RetCmpHist(cCmpEnd,aMod,dDataAte)
	aEnd := MyGetEnd(cContCampo,cAlsSA,cAlsCorr)
	aAdd (aA1A2, SPEDConType(aEnd[1]))																			//09	-	END
	aAdd (aA1A2, Iif(!Empty(aEnd[2]),aEnd[3],"SN"))															//10	-	NUM
	aAdd (aA1A2, Iif(!Empty(aEnd[4]) .Or. !lCmpCompEx, SPEDConType(aEnd[4]), &(cCmpCompl)))					//11	-	COMPL
	cContCampo := RetCmpHist(cCmpBairro,aMod,dDataAte)
	aAdd (aA1A2, SPEDConType(cContCampo))																		//12	-	BAIRRO

	aAdd (aA1A2, (cAlsCorr)->A4_EST)																				//13	-	UF
	aAdd (aA1A2, "")																							//14	-	InscMun
Else

	If lHistTab .And. dDataDe<>Nil
		aMod := MsConHist(cAlsSA,&(cCmpCod),&(cCmpLoja),dDataDe)
	EndIf

	If !lExtratTAF
		aAdd (aA1A2, cAlsSA+Iif(lConcFil,cFilAnt,"")+&(cCmpCod)+&(cCmpLoja)+cInscricao)						//01	-	COD_PART
	Else
		if cAlsSA == 'SA1'
			aAdd (aA1A2, 'C'+&(cCmpCod)+&(cCmpLoja))															//01	-	COD_PART
		elseif cAlsSA == 'SA2'
			aAdd (aA1A2, 'F'+&(cCmpCod)+&(cCmpLoja))															//01	-	COD_PART
		endif
	EndIf

	cContCampo := RetCmpHist(cCmpNome,aMod,dDataAte)
	aAdd (aA1A2, cContCampo)																					//02	-	NOME

	If !Empty(cCmpCdPais)
		cContCampo := RetCmpHist(cCmpCdPais,aMod,dDataAte)
		aAdd(aA1A2,cContCampo)																					//03	-	COD_PAIS
	Else
		aAdd (aA1A2, "01058")																					//03	-	COD_PAIS
	EndIf

	//No cadastro do cliente quem determina se o cliente é uma pessoa fisica ou juridica
	//seria o campo A1_PESSOA, no caso do Fornecedor seria o campo A2_TIPO.
	cContCampo := RetCmpHist(cCmpCgc,aMod,dDataAte)
	If cAlsSA=="SA1"
		aAdd (aA1A2, IIF(&(cCmpPessoa)=="J" .And. (cAlsCorr)->A1_TIPO<>"X",SPEDConType(SPEDVldIE(cContCampo,,.F.)),""))	//04	-	CNPJ
		aAdd (aA1A2, IIF(&(cCmpPessoa)=="F" .And. (cAlsCorr)->A1_TIPO<>"X",SPEDConType(SPEDVldIE(cContCampo,,.F.)),""))	//05	-	CPF
	Else
		aAdd (aA1A2, IIF(&(cCmpTipo)=="J",SPEDConType(SPEDVldIE(cContCampo,,.F.)),""))							//04	-	CNPJ
		aAdd (aA1A2, IIF(&(cCmpTipo)=="F",SPEDConType(SPEDVldIE(cContCampo,,.F.)),""))							//05	-	CPF
	Endif

	cContCampo := RetCmpHist(cCmpInsc,aMod,dDataAte)
	aAdd(aA1A2, SPEDConType(SPEDVldIE(cContCampo)))																//06	-	IE

	If !"01058"$aA1A2[3] .And. AllTrim(aA1A2[3])<>""
		aAdd (aA1A2, "9999999")																					//07	-	COD_MUN
	Else
		//Tratamento para o codigo de municipio, se nao possuir o codigo do estado, tenho de colocar
		cContCampo := RetCmpHist(cCmpCodM,aMod,dDataAte)
		If Len(Alltrim(cContCampo))<=5
			aAdd (aA1A2, UfCodIBGE(&(cCmpEst))+Alltrim(cContCampo))											//07	-	COD_MUN
			//Se possuir, considero como esta, desde que o estado nao seja "EX"
		Else
			aAdd (aA1A2, Iif(Upper(&(cCmpEst)) == "EX","9999999", cContCampo))									//07	-	COD_MUN
		EndIf
	EndIf

	cContCampo := RetCmpHist(cCmpSuframa,aMod,dDataAte)
	aAdd (aA1A2,cContCampo)																						//08	-	SUFRAMA

	cContCampo := RetCmpHist(cCmpEnd,aMod,dDataAte)

	lCmpCompEx := &(cAlsCorr)->(FieldPos("A"+cA1A2+"_COMPLEM")) > 0

	aEnd := MyGetEnd(cContCampo,cAlsSA,cAlsCorr)
	aAdd (aA1A2, SPEDConType(aEnd[1]))																			//09	-	END
	aAdd (aA1A2, Iif(!Empty(aEnd[2]),aEnd[3],"SN"))															//10	-	NUM
	aAdd (aA1A2, IIf(!Empty(AllTrim(aEnd[4])) .Or. !lCmpCompEx,SPEDConType(aEnd[4]),&(cCmpCompl)))			//11	-	COMPL

	//Ponto de entrada para gerar informacoes do endereco e numero.
	If lCadParti
		aPart := ExecBlock("SPDFIS06", .F., .F., {cAlsSA})
		aA1A2[09] := aPart[01]
		aA1A2[10] := aPart[02]
	Endif
	cContCampo := RetCmpHist(cCmpBairro,aMod,dDataAte)
	aAdd (aA1A2,cContCampo)																						//12	-	BAIRRO

	aAdd (aA1A2, &(cCmpEst))																					//13	-	UF
	aAdd (aA1A2, &(cCmpInscM))																					//14	-	InscMun
EndIf
Return (aA1A2)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³RetCmpHist| Autor ³Gustavo G. Rueda 			   ³ Data ³02.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao que retorna uma informacao de um campo conforme data de     ³±±
±±³          ³ alteracao do controle de historico de alteracoes.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpC1 := RetCmpHist(cPar1,aPar2,dPar3,lPar4)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPar1 - Campo a ser avaliado o conteudo.                          ³±±
±±³          ³ aPar2 - Array retornado pela funcao MsConHist com as informacoes  ³±±
±±³          ³         sobre a alteracao.                                        ³±±
±±³          ³         [1]: Campo que sofreu alteracao                           ³±±
±±³          ³         [2]: Conteudo do campo antes da alteracao                 ³±±
±±³          ³         [3]: Data da alteracao                                    ³±±
±±³          ³         [4]: Hora da alteracao                                    ³±±
±±³          ³ dPar3 - Data base para analise da informacao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpC1 - Informacao a ser processada                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RetCmpHist(cCmp,aMod,dData,lUltAlt)
Local	cRet		:=	""
Local	nX			:=	0
Local	lMVSPEDHIS	:=	aSPDSX6[MV_SPEDHIS]	//NAO DIVULGAR - Parametro criado para contornar o historica cadastral caso haja urgente.
Default lUltAlt 	:= .F.

For nX := 1 To Len(aMod)
	If aMod[nX,3]>dData .And. AllTrim(aMod[nX,1])$cCmp
		cRet	:=	aMod[nX][2]
		If !lUltAlt
			Exit
		EndiF
	EndIf
Next nX
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for vazio o cadastro de historico, retorno o proprio campo passado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (Empty(cRet) .And. !Empty(cCmp)) .Or. lMVSPEDHIS
	cRet	:=	&(cCmp)
EndIf
Return cRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    |SPEDSitDoc| Autor ³Gustavo G. Rueda              ³ Data ³03.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³SITUACAO DO DOCUMENTO FISCAL                                       ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpN1 := SPEDSitDoc (cAliasSFT)                                    ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cSituaDoc -> Situacao do documento                                 ³±±
±±³          ³ onde:                                                             ³±±
±±³          ³ 00=Normal                                                         ³±±
±±³          ³ 02=Cancelado                                                      ³±±
±±³          ³ 04=Uso Denegado                                                   ³±±
±±³          ³ 05=Inutilizacao                                                   ³±±
±±³          ³ 06=Complemento                                                    ³±±
±±³          ³ 08=Regime especial ou norma especifica                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|NaoUsar   -> Nao utilizar este parametro, pois trata-se de uma com-³±±
±±³          ³             patibilidade com outras chamadas desta funcao         ³±±
±±³          ³cAliasSFT -> Alias da tabela SFT filtrada e posicionada            ³±±
±±³          ³             na funcao principal                                   ³±±
±±³          ³cAliasSA  -> Alias da tabela SA1 ou SA2, filtrada e posicionada    ³±±
±±³          ³             na funcao principal                                   ³±±
±±³          ³cCmpSimpN -> Indica se o cliente ou fornecedor é optante pelo      ³±±
±±³          ³             Simples Nacional.                                     ³±±
±±³          ³dDataDe   -> Data inicial do período de geração do arquivo         ³±±
±±³          ³             informada ma wizard pelo usuário.                     ³±±
±±³          ³dDataAte  -> Data final  do período de geração do arquivo          ³±±
±±³          ³             informada ma wizard pelo usuário.                     ³±±
±±³          ³lRegEsp   -> Verifica se ( MV_ESTADO $ MV_UFRESPD) Assim, deve     ³±±
±±³          ³             considerar como Regime Especial os clientes/fornec.   ³±±
±±³          ³             optantes pelo Simples Nacional (A?_SIMPNAC)==1        ³±±
±±³          ³lSitDocCDT-> Situação do Documento extemporânea                    ³±±
±±³          ³cSitExt   -> Campo da tabela CDT(CDT_SITEXT)que identifica a       ³±±
±±³          ³             opção da escrituração extemporânea.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPEDSitDoc(NaoUsar,cAliasSFT,cAliasSA,cCmpSimpN,dDataDe,dDataAte,lRegEsp,lSitDocCDT,cSitExt,cAliasSF3,cAliasSF4,lRotina)
Local	cSituaDoc	:= ""
Local	dDtCanc		:= (cAliasSFT)->FT_DTCANC
Local	cOriglan	:= ""
Local	cModNot		:= ""

Local	lDataEnt := .F.
Local 	cSerie		:= ""
Local	cCodRSef	:= ""

Default dDataDe		:= Ctod("  /  /    ")
Default dDataAte	:= Ctod("  /  /    ")
Default lRegEsp		:= .F.
Default lSitDocCDT	:= .F.
Default cSitExt		:= ""
Default cAliasSF3	:= "SF3"
Default cAliasSF4	:= ""
Default lRotina		:= .F.


lDataEnt := ValType((cAliasSFT)->FT_ENTRADA) == "D"

If Empty(cAliasSF4) .Or. ValType(cAliasSF4) <> "C"
	cAliasSF4 := IIF(cAliasSFT == "SFT", "SF4", cAliasSFT)
EndIf

//³Posicionamento realizado para encontrar os itens das Notas Fiscais ³
//³ de Frete incluidas atraves da rotina MATA116.                     ³
If (cAliasSFT)->FT_TIPO$"ICP"
	If (cAliasSFT)->FT_TIPOMOV=="E"
		dbSelectArea("SD1")
		SD1->(dbSetOrder(1))
		If SD1->(dbSeek(xFilial("SD1")+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA+(cAliasSFT)->FT_PRODUTO+(cAliasSFT)->FT_ITEM))
			cOriglan := SD1->D1_ORIGLAN
		EndIf
	EndIf
	If !cOriglan$"FR|F |FD"
		//Situacao da NF
		If lSitDocCDT .And. cSitExt == "P"
			cSituaDoc	:=	"07"	//Escrituração extemporânea de documento complementar
		Else
			cSituaDoc	:=	"06"	//Complemento de IPI, Complemento de ICMS, Complemento de Preco e Beneficiamento
		EndIf
	EndIf
EndIf

If !(Empty (dDtCanc))
	// Como o cancelamento de NF-e pode ser feito apenas até 24 horas após a emissão,
	// não precisaremos fazer o controle da data de cancelamento para depois gerar ajuste.
	cModNot := IIF(Empty(cModNot),AModNot((cAliasSFT)->FT_ESPECIE),cModNot)
	If (!(Alltrim(cModNot)=="55") .Or. lRotina) .And. !Empty(dDataDe) .And. !Empty(dDataAte)
		If dDtCanc >= dDataDe .And. dDtCanc <= dDataAte
			cSituaDoc	:=	"02"
		Else
			cSituaDoc	:=	"00"
		EndIf
	Else
		cSituaDoc	:=	"02"	//Cancelado
	EndIf
Elseif Empty(cSituaDoc)
	If lSitDocCDT .And. cSitExt == "R" .And. (cAliasSFT)->FT_TIPOMOV =="E"
		cSituaDoc	:=	"01"	//Escrituração extemporânea de documento regular
	Else
		cSituaDoc	:=	"00"	//Normal
	EndIf
EndIf

If aSPDSX3[FP_F3_CODRSEF] //³Tratamento para notas fiscais eletronicas³

	If cAliasSF3 = "SF3" //se for o alias default eh necessario posicionar no registro correto
		SF3->(DbSetOrder(1)) //F3_FILIAL+DTOS(F3_ENTRADA)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA
		If lDataEnt
			SF3->(DbSeek((cAliasSFT)->(FT_FILIAL+DTOS(FT_ENTRADA)+FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA)))
		Else
			SF3->(DbSeek((cAliasSFT)->(FT_FILIAL+FT_ENTRADA+FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA)))
		EndIf
	EndIf

	If !Empty(cCodRSef := Alltrim((cAliasSF3)->F3_CODRSEF) )
		If cCodRSef $ XFUNCodSef({"D"})		//NFe - Uso denegado
			cSituaDoc := "04"
		ElseIf cCodRSef $ XFUNCodSef({"I"})	//NFe - Numeracao Inutilizada
			cSituaDoc := "05"
		ElseIf cCodRSef $ XFUNCodSef({"C"})	//Nfe - Cancelamento de NF-e homologado fora de prazo.
			cSituaDoc := "03"
		EndIf
	EndIf
EndIf

If !(Alltrim(cSituaDoc)$"02|04|05|03")

	If ((cAliasSFT)->FT_RGESPST == "1" .Or. (cAliasSF4)->F4_RGESPCI=="1") 		.Or. ; //Campo do livro fiscal que determina Regime Especial ou Norma Especifica para ST ou CIAP.
		(cAliasSA <> Nil .And. (cAliasSA)->(&(cCmpSimpN)) == "1" .And. lRegEsp) .Or. ; //Considera como Reg. Especial se o cliente/fornecedor for optante pelo Simples Nacional e ( MV_ESTADO $ MV_UFRESPD ) -> (lRegEsp)
		((cAliasSFT)->FT_NORESP == "1") 										.Or. ;
		((cSerie := SerienfId(cAliasSFT, 2, "FT_SERIE")) >= "890" .And. cSerie <= "899")
		cSituaDoc := "08"
	EndIf

	If (cAliasSFT)->FT_TIPO == "C" .And. AllTrim((cAliasSFT)->FT_ESPECIE) $ "NFS|RPS"
		cSituaDoc := "00"
	EndIf
EndIf

 Return cSituaDoc
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |GrvRegTrS ³ Autor ³Gustavo G. Rueda       ³ Data ³16.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³              GRAVACAO DO REGISTRO NO TRB                   ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Gravacao do registro passado como parametro (aReg) no TRB   ³±±
±±³          ³ que sera posteiormente lido e gerado o TXT.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlias -> Alias do TRB gerado na funcao principal           ³±±
±±³          ³nRelac -> Codigo de indicacao de relacionamento com outros  ³±±
±±³          ³ registros.                                                 ³±±
±±³          ³aReg -> Registro a ser gravado no TRB.                      ³±±
±±³          ³nItem -> Identificador de itens para um mesmo relacionamento³±±
±±³          ³nFlag -> Flag de controle de grupo que antecede o           ³±±
±±³          ³ relacionamento entre registros. Ex:                        ³±±
±±³          ³ Se o FLAG nao for passado o codigo fica ...2...2, se for   ³±±
±±³          ³ passado por exemplo 3, o codigo fiscal ...3...2            ³±±
±±³          ³l4Casas -> Indica se a funcao devera formatar com 4 casas os³±±
±±³          ³ campos definidos neste formato segundo o layout.           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GrvRegTrS(cAlias,nRelac,aReg,nItem,nFlag,l4Casas)

Local	nX			:=	0
Local	lRet		:=	.T.
Local	cDelimit	:=	"|"
Local	nZ			:=	0
Local	cLinha		:=	""
Local	cReg		:=	""
Local	nTamTRBIt	:=	Len((cAlias)->TRB_RELAC)/2	//Efetuo divisao por dois porque faco dois controles em um mesmo campo. O relacionamento e sequencia. Ex: ...0001...1, ...0001...2
Local	cRegNoGr	:=  aSPDSX6[MV_REGSPED]		//Parametro para identificar quais registros nao devem ser gerados pelo SPEDFISCAL
Local	nDecim		:= Nil
Local nSer		:= 0
Local cRegSer		:= "1101|1105|1110|1500|1501|1900|1923|A100|C100|C113|C176|C195|C300|C350|C500|C600|C700|D100|D162|D200|D300|D500|D600|D695|E113|E240|G130|"

Default	nRelac	:=	0
Default	nFlag	:=	Nil
Default l4Casas	:= .F.

If nFlag==Nil
	cFlag	:=	Iif(Valtype(nRelac)=="N",StrZero (nRelac, nTamTRBIt, 0),nRelac)
Else
	cFlag	:=	StrZero (nFlag, nTamTRBIt, 0)
EndIf

For nZ := 1 To Len (aReg)
	cLinha	:=	cDelimit
	//Monto cLinha para gravar no TRB
	For nX := 1 To Len (aReg[nZ])

		nDecim := Nil
		If ValType(aReg[nZ][nX]) == "N"
			If aReg[1,1] == '0210' .And. nX == 3
				nDecim := 6
			ElseIf aReg[1,1] == 'G126' .And. nX == 8
				nDecim := 8
			// se igual a zero altera para branco
			ElseIf Empty(aReg[nZ][nX]) .And. SPDVldZero(aReg[nZ][1],nX)
				aReg[nZ][nX] := ""
			// Se for para formatar campos com 3 ou 4 casas decimais
			ElseIf l4Casas
				If SPDGet4Dec(aReg[nZ,1],nX)
					nDecim := 4
				ElseIf SPDGet3Dec(aReg[nZ,1],nX)
					nDecim := 3
				EndIf
			EndIf
		EndIf

		If (ValType (aReg[nZ][nX])="A")

			If nX == 1 .And. aReg[nZ][nX] $ cRegSer
				nSer := PosSerie(aReg[nZ][nX])
			EndIF

			If nSer == nX
				cLinha	+=	RetStr (SubStr(aReg[nZ][nX][1],1,3), aReg[nZ][nX][2])+cDelimit
				nSer := 0
			Else
				cLinha	+=	RetStr (aReg[nZ][nX][1], aReg[nZ][nX][2])+cDelimit
			EndIF

		Else

			If nX == 1 .And. AllTrim(aReg[nZ][nX]) $ cRegSer
				nSer := PosSerie(aReg[nZ][nX])
			EndIF

			If nSer == nX
			   If Valtype(aReg[nZ][nX]) <> "N"
				  cLinha	+=	RetStr (SubStr(aReg[nZ][nX],1,3),nDecim)+cDelimit
				  nSer := 0
				Else
				  cLinha	+=	RetStr (SubStr(cValToChar(aReg[nZ][nX]),1,3),nDecim)+cDelimit
				  nSer := 0
				EndIf
			Else
				cLinha	+=	RetStr (aReg[nZ][nX],nDecim)+cDelimit
			EndIF

		EndIf
	Next (nX)

	cReg := SubStr (cLinha, 2, 4)
	nSer := 0

	// Conteudo do parametro MV_REGSPED para identificar quais registros nao devem ser gerados pelo SPEDFISCAL
	If (cReg$cRegNoGr)
		Return (lRet)
	EndIf

	//Tratamento para nao permitir gerar uma string maior que o tamanho do campo TRB_CONT. Se acontecer, somente serah no registro 0450.
	If Len(cLinha)>Len((cAlias)->TRB_CONT)
		cLinha	:=	AllTrim(Left(cLinha,Len((cAlias)->TRB_CONT)-1))+cDelimit
	EndIf
	//
	//Monto TRB
	RecLock (cAlias, .T.)
		(cAlias)->TRB_TPREG		:=	cReg
		(cAlias)->TRB_RELAC		:=	cFlag+Iif(Valtype(nRelac)=="N",StrZero (nRelac, nTamTRBIt, 0),nRelac)
		(cAlias)->TRB_CONT		:=	cLinha
		(cAlias)->TRB_ITEM		:=	nItem
	MsUnLock ()
Next nZ

Return(lRet)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    |SPEDSitFrt| Autor ³Gustavo G. Rueda              ³ Data ³03.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Define o Tipo de Frete do Documento Fiscal conforme os pedidos caso³±±
±±³          ³ existam                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpN1 := SPEDSitFrt(cAliasSFT,cAlsSD,lTop)                         ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Retorna o Tipo de Frete,onde:                                      ³±±
±±³          ³ 9 - Sem Frete                                                     ³±±
±±³          ³ 2 - Emitente                                                      ³±±
±±³          ³ Para frete 0-Terceiro e 1-Destinatario nao ha informacoes         ³±±
±±³          ³ e o retorno padrao iremos definir que toda NFS ou NFE nao         ³±±
±±³          ³ possui Frete                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAliasSFT -> Alias da tabela SFT filtrada e posicionada            ³±±
±±³          ³             na funcao principal                                   ³±±
±±³          ³cAlsSD    -> Alias da tabela SD1 ou SD2 caso nao seja utilizado    ³±±
±±³          ³             query                                                 ³±±
±±³          ³lTop      -> Flag que indica se estah utilizando TOP ou nao        ³±±
±±³          ³cAlsSF    -> Alias da tabela SF1 ou SF2 caso nao seja utilizado    ³±±
±±³          ³             query                                                 ³±±
±±³          ³cCmpFrete -> Conteudo do campo F1_FRETE                            ³±±
±±³          ³lAchSFSD  -> Flag de posicionamento das tabelas SF? e SD?          ³±±
±±³          ³lJOIN     -> Variavel lJOIN determina se quando TOP as tabelas que ³±±
±±³          ³             serao utilizadas (SFT, SD? e SF?) estao no mesmo JOIN ³±±
±±³          ³lF1TpFrete-> FiledPos do campo F1_TPFRETE                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL / SPEDPISCOF                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPEDSitFrt(cAliasSFT,cAlsSD,lTop,cAlsSF,cCmpFrete,lAchSFSD,lJOIN,lF1TpFrete,lNewIndic)

Local cSitFrt   := "9" //Definir por Padrao Nota Fiscal sem Frete
Local cChvSeek  := ""
Local cAlsCorr  := ""

Default lF1TpFrete := aSPDSX3[FP_F1_TPFRETE]
Default lAchSFSD   := .T.
Default lJOIN      := .T.
Default lNewIndic  := ((cAliasSFT)->FT_EMISSAO >= IIF( VALTYPE( (cAliasSFT)->FT_EMISSAO ) == "C","20120101",CtoD("01/01/2012") ) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Como as informacoes abaixo sao utilizadas da tabela SF?/SD?, a mesma precisa estar posicionada.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAchSFSD
	//Tratamento para utilizar os campos Co SELECT quando for TOP ao inves de posicionar a tabela
	If lTop .And. lJOIN		//Variavel lJOIN determina se quando TOP as tabelas que serao utilizadas (SFT, SD? e SF?) estao no mesmo JOIN
		cAlsCorr := cAliasSFT
		cAlsSF   := cAliasSFT
	Else
		cAlsCorr :=	cAlsSD
	EndIf
	If (cAliasSFT)->FT_TIPOMOV=="E" .And. (cAliasSFT)->FT_TIPO <> "D" .And. !Empty((cAlsCorr)->(D1_PEDIDO+D1_ITEM))
		SC7->(dbSetOrder(1))
		cChvSeek := xFilial("SC7")+(cAlsCorr)->(D1_PEDIDO+D1_ITEM)
		//C-CIF - Por conta do emitente
		If lF1TpFrete .And. (cAlsSF)->F1_TPFRETE=="C"
			cSitFrt := Iif(lNewIndic,"0","1")

		//F-FOB - Por conta do destinatario
		ElseIf lF1TpFrete .And. (cAlsSF)->F1_TPFRETE=="F"
			cSitFrt := Iif(lNewIndic,"1","2")

		//T-Por Conta Terceiros
		ElseIf lF1TpFrete .And. (cAlsSF)->F1_TPFRETE=="T"
			cSitFrt := Iif(lNewIndic,"2","0")

		//S-Sem Frete
		ElseIf lF1TpFrete .And. (cAlsSF)->F1_TPFRETE=="S"
			cSitFrt  := Iif(lNewIndic,"9","0")

		//R = Por conta remetente
		ElseIf cVersao >= "012" .And. lF1TpFrete .And. (cAlsSF)->F1_TPFRETE=="R"
			cSitFrt := "3"

		//D = Por conta destinatário
		ElseIf cVersao >= "012" .And. lF1TpFrete .And. (cAlsSF)->F1_TPFRETE=="D"
			cSitFrt := "4"

		//Se nao encontrar na SF1 pega a informacao da SC7
		ElseIf SC7->(MsSeek(cChvSeek))
			//Sem Frete
			If Empty(SC7->C7_TPFRETE)
				cSitFrt := "9"

			//Por conta do emitente
			ElseIf Alltrim(SC7->C7_TPFRETE)=="C"
				cSitFrt := Iif(lNewIndic,"0","1")

			//Por conta do destinatario
			ElseIf Alltrim(SC7->C7_TPFRETE)=="F"
				cSitFrt := Iif(lNewIndic,"1","2")

			//Por conta de terceiros
			ElseIf Alltrim(SC7->C7_TPFRETE)=="T"
				cSitFrt := Iif(lNewIndic,"2","0")

			//R = Por conta remetente
			ElseIf cVersao >= "012" .And. Alltrim(SC7->C7_TPFRETE)=="R"
				cSitFrt := "3"

			//D = Por conta destinatário
			ElseIf cVersao >= "012" .And. Alltrim(SC7->C7_TPFRETE)=="D"
				cSitFrt := "4"
			EndIf

		//Caso tenha Valor de Frete
		ElseIf (cAlsSF)->(&(cCmpFrete))>0
			cSitFrt := "2"
		Endif
	ElseIf (cAliasSFT)->FT_TIPOMOV=="S" .And. !Empty((cAlsCorr)->D2_PEDIDO)
		SC5->(dbSetOrder(1))
		cChvSeek := xFilial("SC5")+Alltrim((cAlsCorr)->D2_PEDIDO)
		If 	SC5->(MsSeek(cChvSeek))

			//Sem Frete
			If Empty(SC5->C5_TPFRETE) .Or. Alltrim(SC5->C5_TPFRETE)== "S"
				cSitFrt := "9"

			//Frete por conta Emitente
			ElseIf Alltrim(SC5->C5_TPFRETE)=="C"
				cSitFrt := Iif(lNewIndic,"0","1")

			//Frete por conta do destinatario
			ElseIf Alltrim(SC5->C5_TPFRETE)=="F"
				cSitFrt := Iif(lNewIndic,"1","2")

			//Frete por conta de Terceiros
			ElseIf Alltrim(SC5->C5_TPFRETE)=="T"
				cSitFrt := Iif(lNewIndic,"2","0")

			//R = Por conta remetente
			ElseIf cVersao >= "012" .And. Alltrim(SC5->C5_TPFRETE)=="R"
				cSitFrt := "3"

			//D = Por conta destinatário
			ElseIf cVersao >= "012" .And. Alltrim(SC5->C5_TPFRETE)=="D"
				cSitFrt := "4"
			EndIf
		Endif
	Endif
EndIf
Return cSitFrt
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |GrRegDep  ³ Autor ³Gustavo G. Rueda       ³ Data ³16.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³              GRAVO REGISTROS DEPENDENTES                   ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Suponhamos o cabecalho e os itens do documento fiscal, onde ³±±
±±³          ³ o cabecalho eh o pai e os itens eh o filho, portanto tenho ³±±
±±³          ³ varios itens para um pai. Para que esta funcao interprete  ³±±
±±³          ³ este caso, a primeira posicao do registro filho indica a   ³±±
±±³          ³ posicao do registro pai, ou seja, leio a primeira posicao  ³±±
±±³          ³ do array pai e procuro todos os registros itens que possuem³±±
±±³          ³ na primeira posicao a posicao lida do registro pai.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlias -> Alias do TRB criado atraves da funcao principal.  ³±±
±±³          |aRegPai -> Registro Pai.                                    ³±±
±±³          |aRegFilho -> Registro tipo filho (1:N) Varios para cada Pai.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GrRegDep(cAlias,aRegPai,aRegFilho,lRegPaiDup,nRegEcf,lCtdtem,nFlag,lOrdena)
Local	aReg		:= {}
Local	nCtd		:= 1
Local	nZ			:= 0
Local	nX			:= 0
Local 	bRblSort	:= {|x,y|x[1]<y[1]}
Local 	nTamReg1	:= 0
Local	nRegsProc	:= 0
Local   nRegPai 	:= 0

DEFAULT lRegPaiDup 	:= .F.
DEFAULT nRegEcf		:= 0
DEFAULT lCtdtem		:= .T.	//Tratamento para quando se tem mais de uma ocorrencia no subnivel. Ex. Registro 1100, 1105 e 1110
DEFAULT nFlag		:= Nil
DEFAULT lOrdena		:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Para o C405 precisa acrescentar a posicao 3 (data) no bloco de ordenacao ³
//³ Para o C420 precisa ordenar tambem pela legenda							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRegEcf == 405
	If Len(aRegFilho) > 0 .AND. Len(aRegFilho[1]) > 0
		nTamReg1 := Len(STR(aRegFilho[1][1]))	// Pega a quantidade total de casas para depois acrescentar zeros
	EndIf
	bRblSort:= {|x,y| AllTrim( StrZero(x[1],nTamReg1)+DTOS(x[3])) < AllTrim(StrZero(y[1],nTamReg1)+DTOS(y[3])) }
ElseIf nRegEcf == 420
	If Len(aRegFilho) > 0 .AND. Len(aRegFilho[1]) > 0
		nTamReg1 := Len(STR(aRegFilho[1][1]))	// Pega a quantidade total de casas para depois acrescentar zeros
	EndIf
	bRblSort:= {|x,y| AllTrim(StrZero(x[1],nTamReg1)+x[3]) < AllTrim(StrZero(y[1],nTamReg1)+y[3]) }
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o registro PAI tiver somente 1 item, nao precisa ordenar, pois o filho somente terah ³
//³ um codigo de relacionamento, o que corresponde ao PAI                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lOrdena
	aRegFilho  := Asort(aRegFilho,,,bRblSort)
EndIf

For nZ := 1 To Len(aRegPai)

	If !lRegPaiDup
		GrvRegTrS(cAlias,nZ,{aRegPai[nZ]},,nFlag)
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³nCod e a posicao lida do C420(Cabecalho) que se relaciona com o conteudo da posicao 1 do array c425(Itens)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aRegFilho)>=1  .AND. nCtd <= Len(aRegFilho)
		If nRegEcf == 460 .Or. nRegEcf == 470 .Or. nRegEcf == 480
			nRegPai := aRegFilho[nCtd][1]
		Else
			nRegPai := nZ
		EndIf
		Do While nCtd<=Len (aRegFilho) .And. (aRegFilho[nCtd][1]==nRegPai)

			aReg	:=	{}
			For nX := 2 To Len (aRegFilho[nCtd])
				aAdd (aReg, aRegFilho[nCtd][nX])
			Next (nX)

			GrvRegTrS(cAlias,nRegPai,{aReg},Iif(lCtdtem,nCtd,aRegFilho[nCtd][1]),nFlag)

			nCtd++
		EndDo
	EndIf
Next (nZ)

Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |UfCodIBGE ³ Autor ³Gustavo G. Rueda       ³ Data ³16.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que retorna o codigo da UF do participante, de acordo³±±
±±³          ³com a tabela disponibilizada pelo IBGE.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cCod -> Codigo da UF                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cUf  -> Sigla da UF do cliente/fornecedor                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function UfCodIBGE(cUf,lForceUF)
Local nX       := 0
Local cRetorno := ""

DEFAULT lForceUF := .T.

Static aUF := {}

If Empty(aUF)
	aadd(aUF,{"RO","11"})
	aadd(aUF,{"AC","12"})
	aadd(aUF,{"AM","13"})
	aadd(aUF,{"RR","14"})
	aadd(aUF,{"PA","15"})
	aadd(aUF,{"AP","16"})
	aadd(aUF,{"TO","17"})
	aadd(aUF,{"MA","21"})
	aadd(aUF,{"PI","22"})
	aadd(aUF,{"CE","23"})
	aadd(aUF,{"RN","24"})
	aadd(aUF,{"PB","25"})
	aadd(aUF,{"PE","26"})
	aadd(aUF,{"AL","27"})
	aadd(aUF,{"SE","28"})
	aadd(aUF,{"BA","29"})
	aadd(aUF,{"MG","31"})
	aadd(aUF,{"ES","32"})
	aadd(aUF,{"RJ","33"})
	aadd(aUF,{"SP","35"})
	aadd(aUF,{"PR","41"})
	aadd(aUF,{"SC","42"})
	aadd(aUF,{"RS","43"})
	aadd(aUF,{"MS","50"})
	aadd(aUF,{"MT","51"})
	aadd(aUF,{"GO","52"})
	aadd(aUF,{"DF","53"})
EndIf

If !Empty(cUF)
	nX := aScan(aUF,{|x| x[1] == cUF})
	If nX == 0
		nX := aScan(aUF,{|x| x[2] == cUF})
		If nX <> 0
			cRetorno := aUF[nX][1]
		EndIf
	Else
		cRetorno := aUF[nX][2]
	EndIf
Else
	cRetorno := IIF(lForceUF,"",aUF)
EndIf

Return(cRetorno)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SPLancCDA ³ Autor ³Gustavo G. Rueda       ³ Data ³04.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que verifica os lancamentos de documentos fiscais    ³±±
±±³          ³ criados durante sua inclusão no sistema de forma manual ou ³±±
±±³          ³ automatica atraves das amarracoes no TES                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Se trata de Function porque eh chamada de outros programas, ³±±
±±³          ³ Exemplo: AUDITFIS.PRW                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 -> Flag de movimento, .T. = tem movimento e .F. = nao ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAliasSFT -> Alias da tabela SFT posicionada no momento     ³±±
±±³          ³cFlag		-> Variavel nao utilizada pela rotina, mais deve  ³±±
±±³          ³             estar nos parametros da funcao porque ela estah³±±
±±³          ³             sendo utilizada por outros programas neste     ³±±
±±³          ³             formato de chamada                             ³±±
±±³          ³aLanCDA  -> Retorna por referencia os lancamentos encontra- ³±±
±±³          ³             dos para o documento fiscal.                   ³±±
±±³          ³cMVEstado -> Conteudo do paramentro MV_ESTADO               ³±±
±±³          ³lAchouCDT -> Flag de localizacao da tabela CDT              ³±±
±±³          ³cAliasCDT -> Alias da tabela CDT em processamento,TOP ou DBF³±±
±±³			 ³cPartDoc -> Codigo do Participante do documento.			  ³±±
±±³          ³aLanCDA2 -> Retorna por referencia os lancamentos encontra- ³±±
±±³          ³             dos para o documento fiscal. (Totalizador)     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPLancCDA(cAliasSFT,cFlag,aLanCDA,cMVEstado,lAchouCDT,cAliasCDT,cPartDoc,aLanCDA2,lOldLan,cEspecie,cProd,aInfE313,lDifal,lExtratTaf,cAliasSF4,aInfE531,lachouCDA)

Local nX		:= 0
Local aPar		:= {}
Local aLancIt	:= {}
Local aSubitem	:= {}
Local lAntSys	:= .T.
Local lRet		:= .F.
Local lVL197	:= .T.
Local lTop		:= .F.
Local cCodPad	:= ""
Local cCodAj	:= ""
Local cCodLanc	:= ""
Local cCodDeclar := ""
Local cDescAj	:= ""
Local cCodObs   := ""
Local cDesObs   := ""
Local cDescObs	:= ""
Local cAliasCDA	:= "CDA"
Local cAliasCC6	:= "CC6"
Local cAliasCDO	:= "CDO"
Local cAliasCCE	:= "CCE"
Local lForSeek	:= lAchouCDT==Nil .And. cAliasCDT==Nil
Local cLancVazio:= aSPDSX6[MV_CDATPL] //Tratamento para CDA_TPLANC = Vazio. MV_CDATPL: 1 = Apuracao, 2 = Nota, padrao = Nota
Local lCDAVL197	:= aSPDSX3[FP_CDA_VL197]
Local nPosE316	:= 0
Local cFormul	:= Iif(Empty((cAliasSFT)->FT_FORMUL),Iif((cAliasSFT)->FT_TIPOMOV == "S","S"," "),(cAliasSFT)->FT_FORMUL)
Local lSeekCCE	:= .F.
Local nPosE531	:= 0
Local lDevLanc	:= FindFunction("DevLanc")
Local nDevDebEsp := 0
Local nOriItem 	 := 0
Local NdevItem 	 := 0
Local nCDAValor  := 0

Default	cFlag		:= ""	//Variavel para manter a compatibilidade com outras chamadas de outros fontes.
Default	lAchouCDT	:= CDT->(dbSetOrder(1),MsSeek(xFilial("CDT")+(cAliasSFT)->(FT_TIPOMOV+FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA)))
Default	cAliasCDT	:= "CDT"
Default	cPartDoc	:= ""
Default	aLanCDA2	:= {}
Default	cMVEstado	:= aSPDSX6[MV_ESTADO]
Default lOldLan		:= (aSPDSX2[AI_CC6] .And. aSPDSX3[FP_CC6_TIPOAJ])
Default cEspecie	:= ''
Default cProd		:= ''
Default aInfE313	:= {}
Default aInfE531	:= {}
Default lDifal		:= .F.
Default	lExtratTaf	:= .F.
Default cAliasSF4	:= ''
Default lachouCDA	:= .F.

dbSelectArea("CDO")
dbSetOrder(1)

If !lachouCDA
	lachouCDA := CDA->(MsSeek(xFilial("CDA") +;
		(cAliasSFT)->FT_TIPOMOV + ;
		(cAliasSFT)->FT_ESPECIE + ;
		Iif(Empty((cAliasSFT)->FT_FORMUL),Iif((cAliasSFT)->FT_TIPOMOV == "S","S"," "),(cAliasSFT)->FT_FORMUL) +;
		(cAliasSFT)->FT_NFISCAL + ;
		(cAliasSFT)->FT_SERIE + ;
		(cAliasSFT)->FT_CLIEFOR +;
		(cAliasSFT)->FT_LOJA))
Endif

If  lachouCDA .and. ((lAchouCDT .And. !Empty((cAliasCDT)->CDT_IFCOMP)) .Or. (!lAchouCDT))


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Para ambiiente TOP, a query eh um JOIN da CDT eh o mesmo da CCE³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFDEF TOP
		If lNotAs400
			lTop := .T.
			If !lForSeek .And. lAchouCDT	//lForSeek eh tratamento legado, para forcar quando chamado de outra funcao, fazer o SEEK na CCE. Ex: AUDITFIS
				cAliasCCE := cAliasCDT
			EndIf
		EndIf
	#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posicionamento da tabela CCE caso não seja TOP, pois TOP eh feito um JOIN na query³
	//|                                                                                  |
	//|lForSeek eh tratamento legado, para forcar quando chamado de outra funcao, fazer o|
	//|  SEEK na CCE. Ex: AUDITFIS                                                       |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAchouCDT .And. (!lTop .Or. lForSeek)
		(cAliasCCE)->(MsSeek(xFilial("CCE")+(cAliasCDT)->CDT_IFCOMP))
		lSeekCCE := .T.
	EndIf

	aAdd(aPar,(cAliasSFT)->FT_TIPOMOV)
	aAdd(aPar,(cAliasSFT)->FT_ESPECIE)
	aAdd(aPar,cFormul)
	aAdd(aPar,(cAliasSFT)->FT_NFISCAL)
	aAdd(aPar,(cAliasSFT)->FT_SERIE)
	aAdd(aPar,(cAliasSFT)->FT_CLIEFOR)
	aAdd(aPar,(cAliasSFT)->FT_LOJA)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query que sera utilizada para montar os lancamentos provenientes do       ³
	//| documento fiscal, sendo eles:                                            |
	//³CDO - Lancamento de Apuracao                                              ³
	//³CC6 - Lancamento de Notas Fiscais                                         ³
	//³A SPEDFILTRO retorna um JOIN do lancamento com a CC6 e/ou CDO dependendo  ³
	//| do campo CDA_TPLANC.                                                     |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SPEDFFiltro(1,"CDA",@cAliasCDA,aPar)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Para ambiiente TOP, a query eh um JOIN da CDA com a CC6 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTop
			cAliasCC6	:=	cAliasCDA
			cAliasCDO	:=	cAliasCDA
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o campo existir na base e for ambiente TOP, a tabela CCE serah³
			//³  um JOIN na query.                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			// Podemos ignorar o CCE preenchido com base na CDT antes da query, pois se estiver preenchido o CDA_IFCOMP, ele será prioridade
			If !Empty((cAliasCDA)->CDA_IFCOMP)
				cAliasCCE	:=	cAliasCDA
				lSeekCCE := .T.
			EndIf
		EndIf

		lRet 	:= .T.
		aLancIt	:= {}
		lAntSys	:= .T.

		While !(cAliasCDA)->(Eof())

			nCDAValor := (cAliasCDA)->CDA_VALOR

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Validacao de Tipo de Lancamento A = Apuracao e N = Notas Fiscais. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If lDifal .AND. SubStr((cAliasCDA)->CDA_CODLAN,3,1) $ '2|3'
				//Se o Código de lançamento for da apuração do DIFAL então alimenta array com informações da nota
				aAdd(aInfE313, {})
				nPosE316	:=	Len (aInfE313)
				aAdd (aInfE313[nPosE316], SubStr((cAliasCDA)->CDA_CODLAN,1,2))  //1UF
				aAdd (aInfE313[nPosE316], AllTrim((cAliasCDA)->CDA_CODLAN)) 	//2Código de lançamento
				aAdd (aInfE313[nPosE316], cPartDoc)								//3Código 0150
				aAdd (aInfE313[nPosE316], cEspecie)								//4Modelo documento
				aAdd (aInfE313[nPosE316], (cAliasSFT)->FT_SERIE)				//5Serie
				aAdd (aInfE313[nPosE316], (cAliasSFT)->FT_NFISCAL)				//6Nota Fiscal
				aAdd (aInfE313[nPosE316], (cAliasSFT)->FT_CHVNFE)				//7Chave documento eletrônico
				aAdd (aInfE313[nPosE316], (cAliasSFT)->FT_EMISSAO)				//8Data documento
				aAdd (aInfE313[nPosE316], cProd)								//9Código 0200
				aAdd (aInfE313[nPosE316], (cAliasCDA)->CDA_VALOR)				//10VAlor do código de lançamento
				aAdd (aInfE313[nPosE316], (cAliasSFT)->FT_TIPOMOV + (cAliasSFT)->FT_SERIE + (cAliasSFT)->FT_NFISCAL + (cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA)	//11Chave da NF
				aAdd (aInfE313[nPosE316], .F.)									//12Já processado
			EndIF

			//Código de IPI
			If cVersao >= "012" .And. aSPDSX3[FP_CDA_ORIGEM] .And. AllTrim((cAliasCDA)->CDA_ORIGEM) == '3'
				aAdd(aInfE531, {})
				nPosE531	:=	Len (aInfE531)
				aAdd (aInfE531[nPosE531], AllTrim((cAliasCDA)->CDA_CODLAN)) 	//1 - Código de lançamento
				aAdd (aInfE531[nPosE531], cPartDoc)								//2 - Código 0150
				aAdd (aInfE531[nPosE531], cEspecie)								//3 - Modelo documento
				aAdd (aInfE531[nPosE531], (cAliasSFT)->FT_SERIE)				//4 - Serie
				aAdd (aInfE531[nPosE531], (cAliasSFT)->FT_NFISCAL)				//5 - Nota Fiscal
				aAdd (aInfE531[nPosE531], (cAliasSFT)->FT_EMISSAO)				//6 - Data documento
				aAdd (aInfE531[nPosE531], "")									//7 - Código 0200
				aAdd (aInfE531[nPosE531], (cAliasCDA)->CDA_VALOR)				//8 - Valor do código de lançamento
				aAdd (aInfE531[nPosE531], (cAliasSFT)->FT_CHVNFE)				//9 - Chave documento eletrônico
				aAdd (aInfE531[nPosE531], (cAliasCDA)->CDA_NUMITE)				//10-Item NF
				aAdd (aInfE531[nPosE531], (cAliasSFT)->FT_TIPOMOV + (cAliasSFT)->FT_NFISCAL + (cAliasSFT)->FT_SERIE + (cAliasSFT)->FT_ESPECIE + cPartDoc)	//11-Chave da NF
			Endif


			If aSPDSX3[FP_CDA_TPLANC] .And. ( (cAliasCDA)->CDA_TPLANC == '1' .Or. ( (cAliasCDA)->CDA_TPLANC == ' ' .And. cLancVazio == "1" ) )

				//Quando codigo de Debito especial verifica se houve devolução
				If lDevLanc .and. SubStr((cAliasCDA)->CDA_CODLAN,4,1) == "5"
					nDevDebEsp := DevLanc(CDA->CDA_NUMERO,CDA->CDA_SERIE,CDA->CDA_NUMITE,CDA->CDA_CLIFOR,CDA->CDA_LOJA,(cAliasSFT)->FT_ENTRADA,'E')

					//Como não é possivel ter certeza do calculo  realizado no reflexo então proporcionalizo valor pelos itens
					IF nDevDebEsp > 0
						nOriItem := nCDAValor / SFT->FT_QUANT // Valor Item origem
						NdevItem := nOriItem * nDevDebEsp   // Valor Item Devolução
						nCDAValor := MAX(nCDAValor - NdevItem,0)
					Endif
				EndIf

				If nCDAValor > 0
					If lTop .Or. (cAliasCDO)->(MsSeek(xFilial("CDO")+AllTrim((cAliasCDA)->CDA_CODLAN)))
						AADD(aLanCDA2,{AllTrim((cAliasCDA)->CDA_CODLAN),;																					//01
								(cAliasCDO)->CDO_DESCR,;          																							//02
								(cAliasCDA)->CDA_BASE,;        																								//03
								(cAliasCDA)->CDA_ALIQ,;        																								//04
								If (SubStr((cAliasCDA)->CDA_CODLAN,3,1) == "9", 0,nCDAValor),;																//05
								If (SubStr((cAliasCDA)->CDA_CODLAN,3,1) == "9", nCDAValor,0),;											  					//06
								"",;		 				  																								//07
								(cAliasCDA)->CDA_ESPECI,;     																								//08
								(cAliasCDA)->CDA_SERIE,;       																								//09
								(cAliasCDA)->CDA_NUMERO,;     				 																				//10
								(cAliasCDA)->CDA_TPMOVI,;    				 				 																//11
								(cAliasCDA)->CDA_CODLAN,;    		 				 																		//12
								"",;                           																								//13
								(cAliasCDA)->CDA_NUMITE,;										 										     				//14
								cPartDoc,;																									   				//15
								(cAliasSFT)->FT_ENTRADA,;																									//16
								(cAliasSFT)->FT_CHVNFE,;																									//17
								(cAliasSFT)->FT_TIPOMOV + (cAliasSFT)->FT_SERIE + (cAliasSFT)->FT_NFISCAL + (cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA,; 	//18
								Iif (aSPDSX3[FP_CDO_AGRUPA] , (cAliasCDO)->CDO_AGRUPA , '1' ),;																//19
								Iif ((cAliasSFT)->(FieldPos("F1_SUBSERI"))>0 .And. (cAliasSFT)->FT_TIPOMOV == "E", (cAliasSFT)->F1_SUBSERI, "") })			//20
					EndIf
				Endif
			Else
				//Quando encontrado lancamento de usuario deve desconsiderar os lancamentos de sistema
				If (cAliasCDA)->CDA_CALPRO == "2" .And. lAntSys
					aLancIt	:= {}
					lAntSys	:= .F.
				EndIf

				If lTop .Or. (cAliasCC6)->(MsSeek(xFilial("CC6")+AllTrim((cAliasCDA)->CDA_CODLAN)))

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Implementacao do novo tratamento para o codigo de lancamento fiscal do documento    |
					//|  atraves da amarracao de lancamento de apuracao no TES.                            ³
					//³Sem este tratamento, considera-se o formato antigo, onde somente 1 por documento era³
					//³  utilizado para gerar o C195.                                                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty((cAliasCDA)->CDA_IFCOMP)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Posicionamento da tabela CCE caso não seja TOP, pois TOP eh feito um JOIN na query³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !lTop
							(cAliasCCE)->(MsSeek(xFilial("CCE")+(cAliasCDA)->CDA_IFCOMP))
						EndIf
						cCodObs := (cAliasCCE)->CCE_COD
						cDesObs := (cAliasCCE)->CCE_DESCR

					ElseIf lAchouCDT
						cCodObs := (cAliasCDT)->CDT_IFCOMP
						cDesObs := (cAliasCDT)->CDT_DCCOMP
						If Empty(cDesObs) .And. CCE->(MsSeek(xFilial("CCE")+cCodObs))
								cDesObs := CCE->CCE_DESCR
						EndIf
					EndIf

					//respeitar o parâmetro mesmo que seja gerado pela CDA.
					If !Empty(cAliasSF4)
						If !Empty((cAliasSF4)->F4_CODOBSE) .AND. aSPDSX6[MV_SPDTC95] $ "3" .AND. !EMPTY((cAliasSFT)->FT_FORMULA)
							cDesObs:= (cAliasSFT)->(Formula((cAliasSFT)->FT_FORMULA)+FT_OBSERV)
						EndIF
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Monto o codigo de lancamento no formato antigo, a primeira criada logo no inicio do sped fiscal³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lOldLan
						If (cAliasCC6)->CC6_TIPOAJ=="1"
							If aSPDSX3[FP_CC6_STUF] .And. !Empty((cAliasCC6)->CC6_STUF)
								cCodLanc += (cAliasCC6)->CC6_STUF
							Else
								cCodLanc += cMVEstado
							EndIf

							Do Case
							Case (cAliasCC6)->CC6_REFLEX == "001" ; cCodLanc += "3"
							Case (cAliasCC6)->CC6_REFLEX == "002" ; cCodLanc += "4"		//	Outros debitos
							Case (cAliasCC6)->CC6_REFLEX == "003" ; cCodLanc += "5"
							Case (cAliasCC6)->CC6_REFLEX == "005" ; cCodLanc += "0"
							Case (cAliasCC6)->CC6_REFLEX == "006" ; cCodLanc += "1"		//	Outros creditos
							Case (cAliasCC6)->CC6_REFLEX == "007" ; cCodLanc += "2"
							Case (cAliasCC6)->CC6_REFLEX == "012" ; cCodLanc += "6"
							Case (cAliasCC6)->CC6_REFLEX == "999" ; cCodLanc += "9"
							EndCase

							cCodLanc += SubStr(STRZERO(Val(Alltrim((cAliasCC6)->CC6_TPAPUR)),3),3,1)
							cCodLanc += SubStr(STRZERO(Val(Alltrim((cAliasCC6)->CC6_RESPON)),3),3,1)
							cCodLanc += SubStr(STRZERO(Val(Alltrim((cAliasCC6)->CC6_INFLUE)),3),3,1)
							cCodLanc += SubStr(STRZERO(Val(Alltrim((cAliasCC6)->CC6_ORIGEM)),3),3,1)

							cCodAj	:= SubStr((cAliasCC6)->CC6_CODAJU,4,3)

							cCodPad	:= cCodAj			// 000-Operacao Normal/001-Diferencial de aliquota/002-Transf. Credito
							If cCodAj > "002"
								If cCodAj <= "007" 		// Credito Presumido
									cCodPad := "009"
								ElseIf cCodAj $ "009" 	// Ativo Fixo
									cCodPad := "008"
								ElseIf cCodAj $ "012" 	// Diferencial de aliquota
									cCodPad := "008"
								Else					// Outros Ajustes
									cCodPad := "999"
								EndIf
							EndIf

							cCodLanc += cCodPad

							cDescAj := MSMM((cAliasCC6)->CC6_DESCR2)
							cDescAj := IIF(Empty(cDescAj),(cAliasCC6)->CC6_DESCR,cDescAj)
						Endif
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Este eh o tratamento para utilizar o codigo conforme o cadastro caso esteja³
					//³ com os lancamentos atualizados, os novos codigos e novas estruturas       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !lOldLan
						cCodDeclar := Iif(aSPDSX3[FP_CC6_DECLAR],(cAliasCC6)->CC6_DECLAR,"")
						cCodLanc := (cAliasCC6)->CC6_CODLAN
						If !Empty(cCodDeclar)
							cDescAj  := cCodDeclar
						//Tratamento para pegar a descrição da tabela 5.2 caso esteja preenchido na F3K a 5.3 x 5.2
						ElseIf  aSPDSX3[FP_CDA_ORIGEM] .And. aSPDSX3[FP_CDA_CLANC] .And. AllTrim((cAliasCDA)->CDA_ORIGEM) == '5' .And. !Empty((cAliasCDA)->CDA_CLANC)
							cDescAj:= (cAliasCDA)->CDA_CLANC
						Else
							cDescAj  := MSMM((cAliasCC6)->CC6_DESCR2)
							cDescAj  := IIF(Empty(cDescAj),(cAliasCC6)->CC6_DESCR,cDescAj)
						Endif
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Monto o array a ser retornado com as informacoes dos lancamentos.   ³
					//³Obs: A posica 13 estah sendo retornada como BRANCO, porem serah     ³
					//³     atualizada a medida que os itens forem sendo passando, pois    ³
					//³     preciso deste codigo para montar o C197 por nfe. Como neste    ³
					//³     momento nao tenho a variavel cProd para todos os itens,        |
					//|     necessito atualizar depois, jah que a query vai apenas uma vez |
					//|     por documento no BD e retorna todos os lancamentos.            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lCDAVL197
						lVL197 := .T.
						If !(cAliasCDA)->CDA_VL197=="1"
							lVL197 := .F.
						Endif
						If Empty(cCodObs) .And. lSeekCCE
							cCodObs := (cAliasCCE)->CCE_COD
							cDesObs := (cAliasCCE)->CCE_DESCR
						Endif
					Endif
					If !Empty(cCodLanc) .And. !Empty(cCodObs)
						//Descricao do 0460 - Posicao 20 do array aLancIt
						If  aSPDSX3[FP_CDA_ORIGEM] .And. AllTrim((cAliasCDA)->CDA_ORIGEM) == '5'
							cDescObs:= cDesObs
						ElseIf  aSPDSX3[FP_CDA_CLANC] .And. !Empty((cAliasCDA)->CDA_CLANC)
							cDescObs:= (cAliasCDA)->CDA_CLANC
						ElseIf Empty((cAliasCDA)->CDA_IFCOMP)
							cDescObs:= cDesObs
						Else
							cDescObs := cDescAj
						EndIf

						IF !lExtratTAF
							AADD(aLancIt,{cCodLanc,;							//01
									cDescAj,;									//02
									(cAliasCDA)->CDA_BASE,;						//03
									(cAliasCDA)->CDA_ALIQ,;						//04
									If (SubStr(cCodLanc,3,1) == "9" .And. !lVL197,0,(cAliasCDA)->CDA_VALOR),;		//05
									If (SubStr(cCodLanc,3,1) == "9" .And. !lVL197,(cAliasCDA)->CDA_VALOR,0),;		//06
									cCodObs,;									//07
									(cAliasCDA)->CDA_ESPECI,;					//08
									(cAliasCDA)->CDA_SERIE,;					//09
									(cAliasCDA)->CDA_NUMERO,;					//10
									(cAliasCDA)->CDA_TPMOVI,;					//11
									(cAliasCDA)->CDA_CODLAN,;					//12
									"",;										//13
									(cAliasCDA)->CDA_NUMITE,;					//14
									cPartDoc,;									//15
									(cAliasSFT)->FT_ENTRADA,;					//16
									cDesObs ,;									//17
									(cAliasSFT)->FT_ESTADO ,;					//18
									"" ,;										//19
									cDescObs,;									//20
									"",; //21
									""}) //22 - CFOP
						Else
							aSubitem := FSubItRegras(cMVEstado,,,,(cAliasSFT)->FT_CFOP)
							AADD(aLancIt,{cCodLanc,;							//01
									cDescAj,;									//02
									(cAliasCDA)->CDA_BASE,;						//03
									(cAliasCDA)->CDA_ALIQ,;						//04
									If (SubStr(cCodLanc,3,1) == "9" .And. !lVL197,0,(cAliasCDA)->CDA_VALOR),;		//05
									If (SubStr(cCodLanc,3,1) == "9" .And. !lVL197,(cAliasCDA)->CDA_VALOR,0),;		//06
									cCodObs,;										//07
									(cAliasCDA)->CDA_ESPECI,;					//08
									(cAliasCDA)->CDA_SERIE,;						//09
									(cAliasCDA)->CDA_NUMERO,;					//10
									(cAliasCDA)->CDA_TPMOVI,;					//11
									(cAliasCDA)->CDA_CODLAN,;					//12
									"",;											//13
									(cAliasCDA)->CDA_NUMITE,;					//14
									cPartDoc,;									//15
									(cAliasSFT)->FT_ENTRADA,;					//16
									cDesObs ,;									//17
									(cAliasSFT)->FT_ESTADO ,;					//18
									"" ,;										//19
									Iif(aSPDSX3[FP_CDA_CLANC] .And. !Empty((cAliasCDA)->CDA_CLANC),(cAliasCDA)->CDA_CLANC,cDescAj),; //20
									aSubitem[1],; //21
									""}) //22 - CFOP
						Endif
					EndIf
				EndIf
			EndIf
			cCodObs := ""
			(cAliasCDA)->(dbSkip())
		EndDo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Fecho query ou indregua criada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SPEDFFiltro(2,"",cAliasCDA)
	EndIf
	For nX := 1 to len(aLancIt)
		aAdd(aLanCDA,aLancIt[nX])
	Next
EndIf
Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TotalizSFI³ Autor ³ Vendas e CRM				   ³ Data ³ 24/04/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica todas as tributacoes que foram registradas nos campos    ³±±
±±³          ³ da tabela SFI ( Resumo da Reducao Z )                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TotalizSFI( nRecSFI, lISS , lCodAliq )

Local cCampo	:= ""      	// Utilizada para armazenar o campo encotrad no SF3
Local aTotaliz	:= {}		// Array com o codigo e os valores dos totalizadores
Local cCodAliq	:= ""		// Codigo dos totalizadores das aliquotas
Local nCount	:= 0        // Contador
Local cAliqISS  := cValToChar(aSPDSX6[MV_ALIQISS])
Local cLegTrib	:= "T"		// Legenda de Tributado
Local cCampoCod	:= ""      	// Utilizada para armazenar o campo referente ao código da aliquota( Utilizado para validação do PAF-ECF )
Local cValorCod	:= ""		// Armazena o valor da alíquota, utilizada no Menu Fiscal(Movimento por ECF-LOJXFUND) para o PAF-ECF
Local lTrataISS	:= .F.

DEFAULT nRecSFI := 0		// Recno do registro d SFI
DEFAULT lISS    := .F.
DEFAULT lCodAliq:= .F.

DbSelectArea("SFI")			// Seleciono a Area do arquivo SFI
DbGoto(nRecSFI)				// Posiciona no Registro DO SFI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe um valor no totalizador de Cancelamento 		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SFI->FI_CANCEL > 0
	aAdd(aTotaliz,{ "Can-T", SFI->FI_CANCEL,""})
EndIf

If aSPDSX3[FP_FI_CANISS] .AND. SFI->FI_CANISS > 0
	aAdd(aTotaliz,{ "Can-S", SFI->FI_CANISS,""})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe um valor no totalizador de Desconto 	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SFI->FI_DESC > 0
	aAdd(aTotaliz,{"DT", SFI->FI_DESC,""})
EndIf

If aSPDSX3[FP_FI_DESISS] .AND. SFI->FI_DESISS > 0
	aAdd(aTotaliz,{"DS", SFI->FI_DESISS , ""})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe um valor no totalizador de Subistuicao Tributaria³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SFI->FI_SUBTRIB > 0
	aAdd(aTotaliz,{"F1", SFI->FI_SUBTRIB,""})
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe um valor no totalizador de Isento                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SFI->FI_ISENTO > 0
	aAdd(aTotaliz,{"I1",SFI->FI_ISENTO,""})
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe um valor no totalizador de Nao Tributado 		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SFI->FI_NTRIB > 0
	aAdd(aTotaliz,{ "N1", SFI->FI_NTRIB,""})
EndIf
//----------------------------------------------------------------------
//³Verifica se existe um valor no totalizador de ISS Isento 		   ³
//----------------------------------------------------------------------
If aSPDSX3[FP_FI_ISSISEN] .AND. SFI->FI_ISSISEN > 0
	aAdd(aTotaliz,{ "IS1", SFI->FI_ISSISEN,""})
EndIf
//----------------------------------------------------------------------
//³Verifica se existe um valor no totalizador de ISS Nao Tributado	   ³
//----------------------------------------------------------------------
If aSPDSX3[FP_FI_ISSNTRI] .AND. SFI->FI_ISSNTRI > 0
	aAdd(aTotaliz,{ "NS1", SFI->FI_ISSNTRI,""})
EndIf
//----------------------------------------------------------------------
//³Verifica se existe um valor no totalizador de ISS Substituido	   ³
//----------------------------------------------------------------------
If aSPDSX3[FP_FI_ISSFTRI] .AND. SFI->FI_ISSFTRI > 0
	aAdd(aTotaliz,{ "FS1", SFI->FI_ISSFTRI,""})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a aliquota de ISS ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Verifica se está preparado para tratar as aliquotas de ISS que devem ser mostradas e tratadas separadamente
lTrataISS := (aSPDSX3[FP_FI_BIS0300] .OR. aSPDSX3[FP_FI_BIS0500] .OR. aSPDSX3[FP_FI_BIS0700])

If !lTrataISS .AND. lISS .AND. SFI->FI_ISS > 0
    cAliqISS := AllTrim( StrTran(cAliqISS, ",", ".") )
    cAliqISS := TransForm(cAliqISS, "@E 99.99")
    nAliqIss := Val(SubStr(cAliqISS , 1, At(".", cAliqISS)))
    cAliqISS := StrTran(cAliqISS, ".")
    cAliqISS := AllTrim(cAliqISS)
    If nAliqIss >= 10
	    cAliqISS := "S" + PadR(cAliqISS, 4, "0")
	Else
		cAliqISS := "S0" + PadR(cAliqISS, 3, "0")
    EndIf
	aAdd(aTotaliz,{ cAliqISS, SFI->FI_ISS, "00"})
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica todos os tipos de aliquotas existentes  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX3")
DbSetOrder(2)
DbSeek("FI_BAS" , .T.)
Do While !SX3->(Eof()) .AND. SubStr(SX3->X3_CAMPO,1,6) == "FI_BAS"
	cCampo := SX3->X3_CAMPO
	If SFI->(&cCampo) > 0
		nCount++
		If Len(AllTrim(cCampo)) == 7 .OR. Len(AllTrim(cCampo)) == 9
			cLegTrib	:= "T0"		// Acrescenta um zero para entrar no padrao do arquivo
		Else
			cLegTrib	:= "T"
		EndIf
		cCodAliq := Subs(cLegTrib + PadR(AllTrim(StrTran(Subs(cCampo,7,Len(cCampo)) , ",", ".")) , 4 ,"0" ),0,5)

	    cCampoCod	:= "FI_COD" + Substr( cCampo, 7, Len(cCampo)-6)

		If lCodAliq .AND. SFI->(FieldPos(cCampoCod))>0
		    cValorCod := SFI->(&cCampoCod)
		Else
			cValorCod := ""
		EndIf

		aAdd(aTotaliz,{ cCodAliq , SFI->(&cCampo),StrZero(nCount,2),cValorCod})
	Endif
	SX3->(dbSkip())
Enddo

If lTrataISS
	//Tratamento para alíquotas de ISS
	DbSelectArea("SX3")
	DbSetOrder(2)
	DbSeek("FI_BIS" , .T.)
	Do While !SX3->(Eof()) .AND. SubStr(SX3->X3_CAMPO,1,6) == "FI_BIS"
		cCampo := SX3->X3_CAMPO
		If SFI->(&cCampo) > 0
			nCount++
			cCodAliq := Substr(cCampo,6,Len(cCampo))

			cCampoCod	:= "FI_ICOD" + AllTrim(Str(Val(substr(cCampo,7,Len(cCampo)))/100))

			If lISS .AND.	(SFI->(FieldPos(cCampoCod)) > 0)
			    cValorCod := SFI->(&cCampoCod)
			Else
				cValorCod := ""
			EndIf

			aAdd(aTotaliz,{ cCodAliq , SFI->(&cCampo),StrZero(nCount,2),cValorCod})
		Endif
		SX3->(dbSkip())
	Enddo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso possua apenas uma aliquota de tributacao grava    ³
//³ "00" o campo referente ao numero do totalizador  	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nCount == 1
	aTotaliz[Len(aTotaliz)][3] := "00"
ElseIf nCount > 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso ter adicionado mais de uma aliquota Tributado ,deve  		³
	//³ordernar para que os registros filhos sejam gerados corretamentes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTotaliz  := Asort(aTotaliz,,,{|x,y|x[1]<y[1]})
EndIf

DbSelectArea("SFI")			// Seleciono a Area do arquivo SFI
DbGoto(nRecSFI)				// Posiciona no Registro DO SFI ( Garantir o posicionamento)

Return(aTotaliz)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TMSCodMun | Autor ³Gustavo G. Rueda              ³ Data ³11.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Esta função tem como objetivo tratar o processo de Importacao e    ³±±
±±³          ³Exportacao referente ao envio do Codigo do Municipio (Estado=EX)   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³1) Para utilizar esta funcao a tabela SA1 deve SEMPRE estar        ³±±
±±³          ³   posicionada.                                                    ³±±
±±³          ³2) Se trata de uma function porque eh utilizada em outros programas³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpC1 := TMSCodMun(cRegiao)                                        ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1 -> Codigo do municipio conforme DUY ou "9999999" para 'EX'   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cPar1 -> Regiao de calculo conforme regra TMS                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSCodMun(cRegiao, lUsaReg, lExtrator)
Local cCodMun:= ""
Local cUF    := ""

default lExtrator := .F.

Default lUsaReg := .F.

If Upper(SA1->A1_EST) == "EX" .Or. lUsaReg
	If aSPDSX3[FP_DUY_CODMUN]
		If DUY->(MsSeek(xFilial('DUY')+cRegiao)) .And. !Empty(DUY->DUY_CODMUN)
			cCodMun := DUY->DUY_CODMUN
			If Len(cCodMun)<=5
				If lExtrator
					cUF := DUY->DUY_EST
				Else
					cUF := UFCodIBGE(DUY->DUY_EST)
				EndIf

				If Empty(cUF)
					cUf := '99'
				EndIf
				cCodMun := cUF+cCodMun
			ElseIF lExtrator
				If Len(cCodMun) > 5
					cCodMun := DUY->DUY_EST+SubStr(cCodMun,3,5)
				EndIf
			EndIf
		Else
			cCodMun := '9999999'
		EndIf
	Else
		cCodMun := '9999999'
	EndIf
Else
	cCodMun := SA1->A1_COD_MUN
	If Len(cCodMun)<=5
		cCodMun := UFCodIBGE(SA1->A1_EST)+cCodMun
	EndIf
EndIf

Return(cCodMun)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ConvType  ³ Autor ³Gustavo G. Rueda       ³ Data ³22.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcoes de tratamento de caracteres especiais copiadas do   ³±±
±±³          ³ NFESEFAZ                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1 -> Retorna a string convertida                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³xValor -> String a ser convertida                           ³±±
±±³          ³nTam	 -> Tamanho da string                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPEDConType(xValor,nTam)

Local cNovo := ""

If nTam==Nil
	xValor := AllTrim(xValor)
EndIf
DEFAULT nTam := 60
cNovo := AllTrim(EnCodeUtf8(NoAcento(SubStr(xValor,1,nTam))))

Return(cNovo)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SPEDVldIE ³ Autor ³Gustavo G. Rueda       ³ Data ³22.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcoes de validacao da IE do contribuinte                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1 -> Retorna a string convertida                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cInsc -> Inscricao                                          ³±±
±±³          ³lContr-> Indica se retorna a palavra isento                 ³±±
±±³          ³lIsent-> Indica se trata isento                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPEDVldIE(cInsc,lContr,lIsent)

Local 		cRet	:=	""
Local 		nI		:=	1
Default 	lContr  :=	.T.
Default		lIsent	:=	.T.

For nI:=1 To Len(cInsc)
	If Isdigit(Subs(cInsc,nI,1)) .Or. IsAlpha(Subs(cInsc,nI,1))
		cRet+=Subs(cInsc,nI,1)
	Endif
Next
cRet := AllTrim(cRet)

If lIsent
	If "ISENT"$Upper(cRet)
		cRet := ""
	EndIf
	If !(lContr) .And. !Empty(cRet)
		cRet := "ISENTA"
	EndIf
EndIf
Return(cRet)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SPEDFFiltr| Autor ³Gustavo G. Rueda  			   ³ Data ³02.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao que efetua filtros em tabelas, indregua em dbf e query em   ³±±
±±³          ³ top. Ela deve ser chamada como 1 para criar e 2 para fechar a area³±±
±±³          ³ criada.                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpL1 := SPEDFFiltro(nPar,cPar,cPar,aPar)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nPar - Parametro que define se criara o filtro ou feche um filtro  ³±±
±±³          ³       jah criado. 1=Criar, 2=Fechar.                              ³±±
±±³          ³cPar - Se trata de um flag atraves do nome da tabela a ser criada o³±±
±±³          ³       o filtro. No caso de haver mais de um filtro para a mesma   ³±±
±±³          ³       tabela em situacoes diferentes, basta acrescentar um identi-³±±
±±³          ³       ficador na quarta posicao do nome. Ex: SFT, SFT1, SF2, etc..³±±
±±³          ³cPar - Variavel passada por referencia para retornar o alias criado³±±
±±³          ³       para a tabela em questao.                                   ³±±
±±³          ³aPar - Parametros para execucao dos filtros                        ³±±
±±³          ³nPar - Se esta variavel for passada diferente de NIL, significa que³±±
±±³          ³       a query deve retornar a quantidade de registros. Utilizado  ³±±
±±³          ³       para montar a regua de processamento mais precisa. O retorno³±±
±±³          ³       serah nesta mesma variavel que deve ser passada como        ³±±
±±³          ³       referencia. O retorno da funcao ainda continua sendo .T.    ³±±
±±³          ³       quando tiver registros ou .F. quando nao tiver.             ³±±
±±³          ³nPar - Indica o indice a ser usado (base Codebase)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 - Booleano para identificar se a tabela possui registros ou  ³±±
±±³          ³        nao. No caso de retornar .F., nao eh necessário chamar a   ³±±
±±³          ³        funcao com o primeiro parametro igual a 2, pois se nao     ³±±
±±³          ³        houver movimento, ela fecha o alias automaticamente.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPEDFFiltro(nOpc,cTabela,cAlias,aPar,nRecCount,nOrdDBF)

Local	ApeF500		:=	{}
Local	cFiltro		:=	""
Local	cIndex		:=	""
Local	cSelect		:= 	""
Local	cFrom		:= 	""
Local	cWhere		:=	""
Local	lRet		:=	.F.
Local	lCountReg	:=	nRecCount<>Nil
Local	lMVAprComp	:= 	aSPDSX6[MV_APRCOMP]
Local	lMVBemEnt	:= 	aSPDSX6[MV_ESTADO] $ aSPDSX6[MV_BEMENT]
Local	nIndex		:=	0

#IFDEF TOP
	Local	aSetField	:=	{}
	Local	nI			:=	0
	Local	cOrderBy	:=	""
#ENDIF
Default nOrdDBF := 0

If nOpc==1
	If cTabela=="CVB"
		#IFDEF TOP
			If lNotAs400
				//Select padrao (legado), sem campos de inicio e fim de vinculo
				cSelect	:=	"%CVB.CVB_CPF,CVB.CVB_CGC,CVB.CVB_NOME,CVB.CVB_CRC,CVB.CVB_END,CVB.CVB_UF,CVB.CVB_BAIRRO,CVB.CVB_CEP,CVB.CVB_CODMUN,CVB.CVB_TEL,CVB.CVB_FAX,CVB.CVB_EMAIL,CVB.CVB_COMPL%"
				//Order by padrao
				cOrderBy := "%"
				cFrom	:=	"%"+RetSqlName("CVB")+" CVB%"
				cWhere	:=	"%CVB.CVB_FILIAL='"+xFilial("CVB")+"'"
				If aSPDSX3[FP_CVB_DTINI] .And. aSPDSX3[FP_CVB_DTFIM]
					//Caso tenha campos de inicio e fim de vinculo, muda o select
					cSelect	:=	"%CVB.CVB_DTFIM,CVB.CVB_DTINI,CVB.CVB_CPF,CVB.CVB_CGC,CVB.CVB_NOME,CVB.CVB_CRC,CVB.CVB_END,CVB.CVB_UF,CVB.CVB_BAIRRO,CVB.CVB_CEP,CVB.CVB_CODMUN,CVB.CVB_TEL,CVB.CVB_FAX,CVB.CVB_EMAIL,CVB.CVB_COMPL%"
					cWhere	+=	" AND (CVB.CVB_DTINI<='" + aPar[2]	+ "' OR CVB.CVB_DTINI='') "
					cWhere	+=	" AND ((CVB.CVB_DTFIM>='" + aPar[1]	+"' AND CVB.CVB_DTFIM<='" + aPar[2] + "') "
					cWhere	+=	" OR (CVB.CVB_DTFIM>'" + aPar[2]	+"' OR CVB.CVB_DTFIM = ' ')) "
					//Sempre ordena pela maior data fim
					cOrderBy := " ORDER BY 1 DESC%"
				EndIf
				If aSPDSX3[FP_CVB_ASSIN]
					cWhere	+=  " AND (CVB_ASSIN = '' OR CVB_ASSIN = '900') "
				EndIf
				If !Empty(aPar[3]) .And. aSPDSX3[FP_CVB_CPF]
					cWhere	+=  " AND CVB.CVB_CPF = '" + aPar[3] + "'"
				EndIf
				If !Empty(aPar[4])	.And. aSPDSX3[FP_CVB_CGC]
					 cWhere	+=  " AND CVB.CVB_CGC = '" + aPar[4] + "'"
				EndIf
				cWhere	+=	" AND CVB.D_E_L_E_T_=' '"
			Else
		#ENDIF
				cFiltro	:= 	"CVB_FILIAL=='"+xFilial("CVB")+"' .And. "
				If aSPDSX3[FP_CVB_DTINI] .And. aSPDSX3[FP_CVB_DTFIM]
					cFiltro	+= 	" (DToS(CVB_DTINI)<='"+aPar[2]+"' .Or. DToS(CVB_DTINI)==' ') "
					cFiltro	+= 	" .And. ((DToS(CVB_DTFIM)>='"+aPar[1]+"' .And. DToS(CVB_DTFIM)<='"+aPar[2]+"') "
					cFiltro	+= 	".Or. (DToS(CVB_DTFIM)>'"+aPar[2]+"' .Or. DToS(CVB_DTFIM)==' ')) "
				EndIf
				If 	aSPDSX3[FP_CVB_ASSIN]
					cFiltro	+=  " .And. ( Empty(CVB_ASSIN) .Or. CVB_ASSIN == '900') "
				EndIf
				If !Empty(aPar[3]) .And. aSPDSX3[FP_CVB_CPF]
					cFiltro	+=  " .And. CVB_CPF == '" + aPar[3] + "'"
				EndIf
				If !Empty(aPar[4]) .And. aSPDSX3[FP_CVB_CGC]
					cFiltro	+=  " .And. CVB_CGC == '" + aPar[4] + "'"
				EndIf
		#IFDEF TOP
			EndIf
		#ENDIF

	ElseIf cTabela=="SFT"

		#IFDEF TOP
			If lNotAs400
				cSelect	:=	"%SFT.FT_FILIAL,SFT.FT_TIPOMOV,SFT.FT_SERIE,SFT.FT_NFISCAL,SFT.FT_CLIEFOR,SFT.FT_LOJA,SFT.FT_ITEM,SFT.FT_PRODUTO,SFT.FT_CFOP,SFT.FT_EMISSAO,"
				cSelect	+=	"SFT.FT_CHVNFE,SFT.FT_ESPECIE,"
				cSelect	+=	IIf(aSPDSX3[FP_FT_SERSAT],"SFT.FT_SERSAT,","")
				cSelect	+=	"SB1.B1_UM,      SB1.B1_SELO,    SB1.B1_TAB_IPI, SB1.B1_VLR_IPI, SB1.B1_TIPO,    SB1.B1_DESC, "
				cSelect	+=	"SB1.B1_CODBAR,  SB1.B1_CODANT,  SB1.B1_POSIPI,  SB1.B1_EX_NCM,  SB1.B1_CODISS,  SB1.B1_PICM, "
				cSelect	+=	"SB1.B1_FECP,    SB1.B1_DATREF,  SB1.B1_SEGUM,   SB1.B1_TIPCONV, SB1.B1_CONV,    SB1.B1_VLR_PIS, "
				cSelect	+=	"SB1.B1_VLR_COF, SB1.B1_CLASSE,  SB1.B1_CONTA,   SB1.B1_ORIGEM,  SB1.B1_IMPORT,  SB1.B1_CC "
				If aSPDSX3[FP_B1_CODGTIN]
					cSelect += ", SB1.B1_CODGTIN"
				Endif
				cSelect	+=	IIf(aSPDSX3[FP_B1_CEST],", SB1.B1_CEST ","")
				cSelect	+=	"%"
				cFrom	:=	"%"+RetSqlName("SFT")+" SFT "
				cFrom	+=	"LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SFT.FT_PRODUTO=SB1.B1_COD AND SB1.D_E_L_E_T_=' '%"
				cWhere	:=	"%SFT.FT_FILIAL='"+xFilial("SFT")+"' AND "
				cWhere	+=	"SFT.FT_TIPOMOV='"+aPar[1]+"' AND "
				cWhere	+=	"SFT.FT_SERIE='"+aPar[2]+"' AND "
				cWhere	+=	"SFT.FT_NFISCAL='"+aPar[3]+"' AND "
				cWhere	+=	"SFT.FT_CLIEFOR='"+aPar[4]+"' AND "
				cWhere	+=	"SFT.FT_LOJA='"+aPar[5]+"' AND "
				If Len(aPar) >= 6 .And. !Empty(aPar[6])
					cWhere	+=	"SFT.FT_ITEM='"+aPar[6]+"' AND "
				EndIf
				cWhere	+=	"SFT.D_E_L_E_T_=' '%"

				aAdd(aSetField,{"FT_EMISSAO","D",8,0})
			Else
		#ENDIF
				cFiltro	:= 	"FT_FILIAL=='"+xFilial("SFT")+"' .And. "
				cFiltro	+= 	"FT_TIPOMOV=='"+aPar[1]+"' .And. "
				cFiltro	+= 	"FT_SERIE=='"+aPar[2]+"' .And. "
				cFiltro	+= 	"FT_NFISCAL=='"+aPar[3]+"' .And. "
				cFiltro	+= 	"FT_CLIEFOR=='"+aPar[4]+"' .And. "
				If Len(aPar) >= 6 .And. !Empty(aPar[6])
					cFiltro	+=	"FT_ITEM=='"+aPar[6]+"' .And. "
				EndIf
				cFiltro	+= 	"FT_LOJA=='"+aPar[5]+"'"
		#IFDEF TOP
			EndIf
		#ENDIF

	ElseIf cTabela=="SFT2" // Uso do SPEDPISCOF

		#IFDEF TOP
			If lNotAs400
				cSelect :=	"%SFT.FT_FILIAL,SFT.FT_ENTRADA,SFT.FT_DTCANC,SFT.FT_CFOP,SFT.FT_TIPO,SFT.FT_BASEPIS,SFT.FT_CSTPIS,SFT.FT_BASECOF,"
				cSelect	+=	"SFT.FT_CSTCOF,SFT.FT_ESPECIE,SFT.FT_NRLIVRO,SFT.FT_NFISCAL,SFT.FT_SERIE,SFT.FT_ITEM,SFT.FT_CLIEFOR,SFT.FT_LOJA,"
				cSelect	+=	"SFT.FT_TIPOMOV,SFT.FT_VALPIS,SFT.FT_BASEPIS,SFT.FT_VALCOF,SFT.FT_BASECOF,SFT.FT_EMISSAO,SFT.FT_ALIQPIS,SFT.FT_ALIQCOF,"
				cSelect	+=	"SFT.FT_CSTPIS,SFT.FT_CSTCOF,SFT.FT_PAUTPIS,SFT.FT_PAUTCOF,SFT.FT_MVALCOF,SFT.FT_MALQCOF "
				If SerieNfId("SFT",3,"FT_SERIE") == "FT_SDOC"
					cSelect += ", SFT.FT_SDOC "
				EndIf
				cFrom	:=	"%"+RetSqlName("SFT")+" SFT "
				cWhere	:=	"%SFT.FT_FILIAL='"+xFilial("SFT")+"' AND "
				cWhere	+=	"SFT.FT_TIPOMOV='S' AND "
				cWhere	+=	"SFT.FT_ENTRADA<'"+aPar[1]+"' AND "
				cWhere	+=	"SFT.FT_ENTRADA>='"+aPar[3]+"' AND "
				cWhere	+=	"SFT.FT_DTCANC>='"+aPar[1]+"' AND "
				cWhere	+=	"SFT.FT_DTCANC<='"+aPar[2]+"' AND "
				cWhere	+=	"((SFT.FT_CFOP NOT LIKE '000' AND SFT.FT_CFOP NOT LIKE '999') OR SFT.FT_TIPO='"+aPar[7]+"') AND "
				cWhere	+=	"(SFT.FT_BASEPIS > 0   OR  SFT.FT_BASECOF > 0   OR SFT.FT_CFOP LIKE '7') AND SFT.FT_ESPECIE <> 'CF' AND "
				If (aPar[5]<>"*")
					cWhere += " SFT.FT_NRLIVRO = '" +aPar[5]+"' AND "
				EndiF
				cWhere	+=	"SFT.D_E_L_E_T_=''%"

				If aPar[4]$"3"
					If aPar[6]==1  .And. aSPDSX3[FP_F4_TPREG] .And. aSPDSX3[FP_B1_TPREG]
						cSelect	+=	" ,SF4.F4_TPREG,SB1.B1_TPREG%"
						cFrom	+=	" LEFT JOIN "+RetSqlName("SD1")+" SD1 ON SD1.D1_FILIAL='"+xFilial("SD1")+"' AND SD1.D1_DOC=SFT.FT_NFISCAL AND SD1.D1_SERIE=SFT.FT_SERIE AND "
						cFrom	+=	" SD1.D1_FORNECE=SFT.FT_CLIEFOR AND SD1.D1_LOJA=SFT.FT_LOJA AND SD1.D1_ITEM=SFT.FT_ITEM AND SD1.D_E_L_E_T_='' "
						cFrom	+=	" LEFT JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO=SD1.D1_TES AND SF4.D_E_L_E_T_='' "
						cFrom	+=	" LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.D_E_L_E_T_=''%"
					Elseif aPar[6]==2 .And. aSPDSX3[FP_B1_TPREG]
						cSelect	+=	" ,SB1.B1_TPREG%"
						cFrom	+=	" LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.D_E_L_E_T_=''%"
					Elseif aPar[6]==3 .And. aSPDSX3[FP_A1_TPREG]
						cSelect	+=	" ,SA1.A1_TPREG%"
						cFrom	+=	" LEFT JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=SFT.FT_CLIEFOR AND "
						cFrom	+=	" SA1.A1_LOJA=SFT.FT_LOJA AND SA1.D_E_L_E_T_=''%"
					Else
						cFrom   +=  "%"
						cSelect	+=	"%"
					Endif
				Else
					cFrom   +=  "%"
					cSelect	+=	"%"
				Endif

		  		aAdd(aSetField,{"FT_EMISSAO","D",8,0})
		  		aAdd(aSetField,{"FT_ENTRADA","D",8,0})
		  		aAdd(aSetField,{"FT_DTCANC","D",8,0})
		  Else
		#ENDIF
				cFiltro	:= 'FT_FILIAL=="'+xFilial ("SFT")+'" .And. '
			   	cFiltro += 'DTOS(FT_ENTRADA)<"'+aPar[1]+'" .And. '
			   	cFiltro	+= 'DTOS(FT_ENTRADA)>="'+aPar[3]+'" .And. '
			   	cFiltro	+= 'DTOS(FT_DTCANC)>="'+aPar[1]+'" .And. '
			   	cFiltro	+= 'DTOS(FT_DTCANC)<="'+aPar[2]+'" .And. '
				cFiltro += '(!SubStr (FT_CFOP,1,3)$"999/000" .Or. FT_TIPO=="'+aPar[7]+'") .And. '
				cFiltro	+= '(FT_VALPIS > 0 .OR. FT_VALCOF > 0) .And. '
				cFiltro	+= 'FT_ESPECIE <> "CF" '
				If (aPar[5]<>"*")
				    cFiltro	+=	'.And. FT_NRLIVRO ="'+aPar[5]+'" '
			   	EndIf
		#IFDEF TOP
			EndIf
		#ENDIF


	ElseIf cTabela=="SFT3" // Uso do SPEDPISCOF

		#IFDEF TOP
			If lNotAs400
	        	cSelect :=	"SFT.FT_FILIAL,SFT.FT_VALCONT,SFT.FT_CSTPIS,SFT.FT_BASEPIS,SFT.FT_ALIQPIS,SFT.FT_CSTCOF,SFT.FT_BASECOF,SFT.FT_ALIQCOF,SFT.FT_TIPO,"
    			cSelect	+=	"SFT.FT_ESPECIE,SFT.FT_CFOP ,SFT.FT_CONTA,SFT.FT_TNATREC,SFT.FT_CNATREC,SFT.FT_GRUPONC, SFT.FT_DTFIMNT,SFT.FT_PAUTPIS,SFT.FT_PAUTCOF,"
    			cSelect	+=  "SFT.FT_NFISCAL,SFT.FT_CLIEFOR,SFT.FT_PRODUTO,SFT.FT_TIPOMOV,SFT.FT_SERIE,SFT.FT_LOJA,SFT.FT_ENTRADA,SFT.FT_QUANT,SFT.FT_VALPIS,SFT.FT_VALCOF,"
    			cSelect	+=  "SFT.FT_SERORI,SFT.FT_NFORI,SFT.FT_ITEMORI,SFT.FT_ITEM,SFT.FT_VALIPI,SFT.FT_ICMSRET,SFT.FT_EMISSAO,SFT.FT_VALICM, "
				cSelect	+=	"SB1.B1_COD, SB1.B1_TIPO, SB1.B1_CODISS, SB1.B1_POSIPI, SB1.B1_DESC, SB1.B1_CODBAR, "
				If aSPDSX3[FP_B1_CODGTIN]
					cSelect += "SB1.B1_CODGTIN,"
				Endif
				cSelect	+=	"SB1.B1_CODANT, SB1.B1_UM, SB1.B1_EX_NCM,SB1.B1_PICM, SB1.B1_FECP, SB1.B1_DATREF, SB1.B1_VLR_PIS, SB1.B1_VLR_COF, SB1.B1_TNATREC, "
				cSelect	+=	"SB1.B1_CNATREC, SB1.B1_GRPNATR, SF2.F2_VALBRUT, SF2.F2_VALFAT "
				If aSPDSX3[FP_FT_ATIVCPB] .And. aSPDSX3[FP_FT_VALCPB] .And. aSPDSX3[FP_FT_ALIQCPB] .And. aSPDSX3[FP_FT_BASECPB]
					cSelect	+=	", SFT.FT_ATIVCPB, SFT.FT_VALCPB, SFT.FT_ALIQCPB, SFT.FT_BASECPB "
				Endif
    			cFrom	:=	""+RetSqlName("SFT")+" SFT "
				cFrom	+=	" LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.D_E_L_E_T_=''"
				cFrom	+=	" LEFT JOIN "+RetSqlName("SF2")+" SF2 ON(SF2.F2_FILIAL='"+xFilial("SF2")+"'  AND SF2.F2_DOC=SFT.FT_NFISCAL AND SF2.F2_SERIE=SFT.FT_SERIE AND SF2.F2_CLIENTE=SFT.FT_CLIEFOR AND SF2.F2_LOJA=SFT.FT_LOJA AND SF2.D_E_L_E_T_=' ') "
				IF aPar[7]=="01"
			   		cSelect	+= " ,SA1.A1_CGC "
			   		cFrom += " LEFT JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=SFT.FT_CLIEFOR AND "
			   		cFrom += " SA1.A1_LOJA=SFT.FT_LOJA AND SA1.D_E_L_E_T_=''"
				EndIF

    			cWhere	:=	"SFT.FT_FILIAL='"+xFilial("SFT")+"' AND "
				cWhere	+=	"SFT.FT_TIPOMOV='S' AND "
				cWhere	+=	"SFT.FT_ENTRADA='"+aPar[1]+"' AND "
				cWhere	+=	"SFT.FT_SERIE='"+aPar[2]+"' AND "
				cWhere	+=	"SFT.FT_NFISCAL='"+aPar[3]+"' AND "
				cWhere	+=	"SFT.FT_CLIEFOR='"+aPar[4]+"' AND "
				cWhere	+=	"SFT.FT_LOJA='"+aPar[5]+"' AND "
				cWhere	+=	"(SFT.FT_BASEPIS > 0 OR SFT.FT_BASEPS3 > 0 OR  SFT.FT_BASECOF > 0 OR SFT.FT_BASECF3 > 0 OR SFT.FT_CSTPIS IN ('07','08','09','49') OR SFT.FT_CSTCOF IN ('07','08','09','49')) AND "
				If (aPar[6]<>"*")
		        	cWhere += " SFT.FT_NRLIVRO = '" +aPar[6]+"' AND "
		  		EndiF
		  		cWhere	+=	"SFT.D_E_L_E_T_=''"

				If aExistBloc[28] // PE para SCP com Filial unica - TTUXH9
					ApeF500 := ExecBlock("SPDF500A", .F. , .F. , {cFrom,cWhere})
					cFrom 	:= ApeF500[1]
					cWhere	:= ApeF500[2]
				Endif

				cSelect	:= "%"+cSelect+"%"
				cFrom 	:= "%"+cFrom+"%"
				cWhere	:= "%"+cWhere+"%"

		  		aAdd(aSetField,{"FT_EMISSAO","D",8,0})
		  		aAdd(aSetField,{"FT_ENTRADA","D",8,0})
		  		aAdd(aSetField,{"FT_DTCANC","D",8,0})
		  Else
		#ENDIF
		       cFiltro	:= 'FT_FILIAL=="'+xFilial ("SFT")+'" .And. '
			   cFiltro += ' FT_TIPOMOV = "S" .AND. DTOS(FT_ENTRADA)="'+aPar[1]+'" .And. FT_SERIE == "' + aPar[2]  + '" .AND.  '
			   cFiltro += 'FT_NFISCAL =="'+aPar[3]+'" .And. FT_CLIEFOR =="'+aPar[4]+'"  .AND. FT_LOJA =="'+aPar[5] + '" .AND.  '
			   cFiltro	+= '(FT_BASEPIS > 0 .OR. FT_BASEPS3 > 0 .OR. FT_VALCOF > 0 .OR. FT_BASECF3 > 0 .OR. FT_CSTPIS $"07#08#09#49" .OR. FT_CSTCOF $"07#08#09#49")'
				If (aPar[6]<>"*")
				    cFiltro	+=	'.And. FT_NRLIVRO ="'+aPar[6]+'" '
			   	EndIf
		#IFDEF TOP
			EndIf
		#ENDIF

	ElseIf cTabela=="SFTDEV"

		#IFDEF TOP
			If lNotAs400
	        	cSelect :=	"%SFT.FT_FILIAL,SFT.FT_TIPOMOV,SFT.FT_NFORI,SFT.FT_SERORI,SFT.FT_ITEMORI,SFT.FT_NFISCAL,SFT.FT_SERIE,SFT.FT_CLIEFOR,"
				cSelect	+=	"SFT.FT_LOJA,SFT.FT_ITEM,SFT.FT_VALCOF,SFT.FT_VALPIS,SFT.FT_PRODUTO,SFT.FT_QUANT,SFT.FT_BASEPIS,SFT.FT_BASECOF"
				cFrom	:=	"%"+RetSqlName("SFT")+" SFT "
	            cWhere	:=	"%SFT.FT_FILIAL='"+xFilial("SFT")+"' AND "
				cWhere	+=	"SFT.FT_TIPOMOV='"+aPar[4]+"' AND "
				cWhere	+=	"SFT.FT_ENTRADA>='"+aPar[1]+"' AND "
				cWhere	+=	"SFT.FT_ENTRADA<='"+aPar[2]+"' AND "
				cWhere	+=	"SFT.FT_DTCANC='' AND "
				cWhere	+=	"SFT.FT_TIPO='D' AND "
				If aPar[3]<>"*"
		        	cWhere += " SFT.FT_NRLIVRO = '"+aPar[3]+"' AND "
		  		Endif
		  		cWhere	+=	"SFT.D_E_L_E_T_=''"
  				cOrderBy:=	" ORDER BY 1,2,3,4,5,6,7,8%"

  				If aPar[6]$"3"
					If aPar[5]==1
						If aPar[4]=="E" .And. aSPDSX3[FP_F4_TPREG] .And. aSPDSX3[FP_B1_TPREG]
							cSelect	+=	" ,SF4.F4_TPREG ,SB1.B1_TPREG"
							cFrom	+=	" LEFT JOIN "+RetSqlName("SD1")+" SD1 ON SD1.D1_FILIAL='"+xFilial("SD1")+"' AND SD1.D1_DOC=SFT.FT_NFISCAL AND SD1.D1_SERIE=SFT.FT_SERIE AND "
							cFrom	+=	" SD1.D1_FORNECE=SFT.FT_CLIEFOR AND SD1.D1_LOJA=SFT.FT_LOJA AND SD1.D1_ITEM=SFT.FT_ITEM AND SD1.D_E_L_E_T_='' "
							cFrom	+=	" LEFT JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO=SD1.D1_TES AND SF4.D_E_L_E_T_='' "
							cWhere	+=	" AND ((SF4.F4_TPREG='2') OR (SF4.F4_TPREG='3' AND SB1.B1_TPREG='2') OR (SFT.FT_FORMUL='S' AND (SFT.FT_CSTPIS IN ('98','99') OR SFT.FT_CSTCOF IN ('98','99')) ) )"
						ElseIf  aSPDSX3[FP_F4_TPREG] .And. aSPDSX3[FP_B1_TPREG]
					 	  	cSelect	+=	" ,SF4.F4_TPREG ,SB1.B1_TPREG"
							cFrom	+=	" LEFT JOIN "+RetSqlName("SD2")+" SD2 ON SD2.D2_FILIAL='"+xFilial("SD2")+"' AND SD2.D2_DOC=SFT.FT_NFISCAL AND SD2.D2_SERIE=SFT.FT_SERIE AND "
							cFrom	+=	" SD2.D2_CLIENTE=SFT.FT_CLIEFOR AND SD2.D2_LOJA=SFT.FT_LOJA AND SD2.D2_ITEM=SFT.FT_ITEM  AND SD2.D_E_L_E_T_='' "
							cFrom	+=	" LEFT JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO=SD2.D2_TES AND SF4.D_E_L_E_T_='' "
							cWhere	+=	" AND ((SF4.F4_TPREG='1') OR (SF4.F4_TPREG='3' AND SB1.B1_TPREG='1'))"
						Endif

						cFrom	+=	" LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.D_E_L_E_T_=''"

					Elseif aPar[5]==2 .And. aSPDSX3[FP_B1_TPREG]
						cSelect	+=	" ,SB1.B1_TPREG"
						cFrom	+=	" LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.D_E_L_E_T_=''"

						If aPar[4]=="E"
							cWhere	+=	" AND ((SB1.B1_TPREG='2') OR (SFT.FT_FORMUL='S' AND (SFT.FT_CSTPIS IN ('98','99') OR SFT.FT_CSTCOF IN ('98','99')) )  )"
						Else
							cWhere	+=	" AND SB1.B1_TPREG='1'"
						Endif

					Elseif aPar[5]==3
						If aPar[4]=="E" .And. aSPDSX3[FP_A1_TPREG]
							cSelect	+=	" ,SA1.A1_TPREG"
							cFrom	+=	" LEFT JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=SFT.FT_CLIEFOR AND "
							cFrom	+=	" SA1.A1_LOJA=SFT.FT_LOJA AND SA1.D_E_L_E_T_=''"
							cWhere	+=	" AND ((SA1.A1_TPREG='2') OR (SFT.FT_FORMUL='S' AND (SFT.FT_CSTPIS IN ('98','99') OR SFT.FT_CSTCOF IN ('98','99')) )  )"
						Elseif aSPDSX3[FP_A2_TPREG]
							cSelect	+=	" ,SA2.A2_TPREG"
							cFrom	+=	" LEFT JOIN "+RetSqlName("SA2")+" SA2 ON SA2.A2_FILIAL='"+xFilial("SA2")+"' AND SA2.A2_COD=SFT.FT_CLIEFOR AND "
							cFrom	+=	" SA2.A2_LOJA=SFT.FT_LOJA AND SA2.D_E_L_E_T_=''"
							cWhere	+=	" AND SA2.A2_TPREG='1'"
						Endif
					Endif
				ElseIf aPar[6]$"1" .And. aPar[4]=="E"
					cFrom	+=	" LEFT JOIN "+RetSqlName("SD1")+" SD1 ON SD1.D1_FILIAL='"+xFilial("SD1")+"' AND SD1.D1_DOC=SFT.FT_NFISCAL AND SD1.D1_SERIE=SFT.FT_SERIE AND "
					cFrom	+=	" SD1.D1_FORNECE=SFT.FT_CLIEFOR AND SD1.D1_LOJA=SFT.FT_LOJA AND SD1.D1_ITEM=SFT.FT_ITEM AND SD1.D_E_L_E_T_='' "
					cFrom	+=	" LEFT JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO=SD1.D1_TES AND SF4.D_E_L_E_T_='' "
					cWhere	+=	" AND (SFT.FT_FORMUL='S' AND SF4.F4_OPERGAR<>'1') AND (SFT.FT_CSTPIS IN ('98','99') OR SFT.FT_CSTCOF IN ('98','99')) "
				Endif
				cFrom   +=  "%"
				cSelect	+=	"%"
			Else
		#ENDIF
				cFiltro	:= 'FT_FILIAL=="'+xFilial ("SFT")+'" .And. '
			   	cFiltro += 'DTOS(FT_ENTRADA)>="'+aPar[1]+'" .And. '
			   	cFiltro	+= 'DTOS(FT_ENTRADA)<="'+aPar[2]+'" .And. '
			   	cFiltro	+= 'DTOS(FT_DTCANC)=="" .And. '
				cFiltro += 'FT_TIPO == "D" .And. '
				If (aPar[3]<>"*")
				    cFiltro	+=	'FT_NRLIVRO =="'+aPar[3]+'" .And. '
			   	EndIf
				cFiltro	+= 'FT_TIPOMOV == "'+aPar[4]+'"'

		#IFDEF TOP
			EndIf
		#ENDIF

	ElseIf cTabela=="CDA"

		#IFDEF TOP
			If lNotAs400
				cSelect	:=	"%CDA.CDA_TPMOVI,CDA.CDA_ESPECI,CDA.CDA_NUMERO,CDA.CDA_SERIE,CDA.CDA_NUMITE,"
				cSelect	+=	"CDA.CDA_CALPRO,CDA.CDA_CODLAN,CDA.CDA_BASE,CDA.CDA_ALIQ,CDA.CDA_VALOR,CDA.CDA_IFCOMP,CCE.CCE_COD,CCE.CCE_DESCR"
				If aSPDSX3[FP_CDA_TPLANC]	//Campo que determina se o lancamento eh de Apuracao (1) ou de NF (2)
					cSelect	+=	",CDA.CDA_TPLANC"
				EndIf
				If aSPDSX3[FP_CDA_ORIGEM]	//Campo Origem do código na CC7
					cSelect	+=	",CDA.CDA_ORIGEM"
				EndIf
				If aSPDSX3[FP_CDA_VL197]
					cSelect	+=	",CDA.CDA_VL197"
				Endif
				If aSPDSX3[FP_CDA_CLANC]
					cSelect	+=	",CDA.CDA_CLANC"
				Endif
				//TRATAMENTO PARA LANCAMENTO DE NOTA FISCAL
				If aSPDSX3[FP_CC6_TIPOAJ]
					cSelect	+=	",CC6.CC6_TIPOAJ,CC6.CC6_REFLEX,CC6.CC6_TPAPUR,CC6.CC6_RESPON,CC6.CC6_INFLUE,CC6.CC6_ORIGEM,CC6.CC6_CODAJU"
					If aSPDSX3[FP_CC6_STUF]
						cSelect	+=	",CC6.CC6_STUF"
					EndIf
				Else
					cSelect	+=	",CC6.CC6_CODLAN"
				EndIf
				cSelect	+=	",CC6.CC6_DESCR2,CC6.CC6_DESCR"
				If aSPDSX3[FP_CC6_DECLAR]
					cSelect	+=	",CC6.CC6_DECLAR"
				Endif
				//TRATAMENTO PARA LANCAMENTO DE APURACAO
				If aSPDSX3[FP_CDA_TPLANC]	//Campo que determina se o lancamento eh de Apuracao (1) ou de NF (2)
					cSelect	+=	",CDO.CDO_DESCR"
				EndIf
				If aSPDSX3[FP_CDO_AGRUPA]
					cSelect	+=	",CDO.CDO_AGRUPA"
				EndIF

				cSelect	+=	"%"
				cFrom	:=	"%"+RetSqlName("CDA")+" CDA "
				cFrom	+=	"LEFT JOIN "+RetSqlName("CC6")+" CC6 ON CC6.CC6_FILIAL='"+xFilial("CC6")+"' AND CC6.CC6_CODLAN=CDA.CDA_CODLAN AND CC6.D_E_L_E_T_=' ' "
				If aSPDSX3[FP_CDA_TPLANC]	//Campo que determina se o lancamento eh de Apuracao (1) ou de NF (2)
					cFrom	+=  "LEFT JOIN "+RetSqlName("CDO")+" CDO ON CDO.CDO_FILIAL='"+xFilial("CDO")+"' AND CDO.CDO_CODAJU=CDA.CDA_CODLAN AND CDO.D_E_L_E_T_=' ' "
				EndIf

				//TRATAMENTO PARA OBSERVACAO DO LANCAMENTO ATRAVES DO DOCUMENTO
				cFrom	+=	"LEFT JOIN "+RetSqlName("CCE")+" CCE ON CCE.CCE_FILIAL='"+xFilial("CCE")+"' AND CCE.CCE_COD=CDA.CDA_IFCOMP AND CCE.D_E_L_E_T_=' ' "
				cFrom	+=	"%"
				cWhere	:=	"%CDA.CDA_FILIAL='"+xFilial("CDA")+"' AND "
				cWhere	+=	"CDA.CDA_TPMOVI='"+aPar[1]+"' AND "
				cWhere	+=	"CDA.CDA_ESPECI='"+aPar[2]+"' AND "
				cWhere	+=	"CDA.CDA_FORMUL='"+aPar[3]+"' AND "
				cWhere	+=	"CDA.CDA_NUMERO='"+aPar[4]+"' AND "
				cWhere	+=	"CDA.CDA_SERIE='"+aPar[5]+"' AND "
				cWhere	+=	"CDA.CDA_CLIFOR='"+aPar[6]+"' AND "
				cWhere	+=	"CDA.CDA_LOJA='"+aPar[7]+"' AND "
				cWhere	+=	"CDA.CDA_VALOR > 0 AND "
				cWhere	+=	"CDA.D_E_L_E_T_=''%"
			Else
		#ENDIF
				cFiltro	:=	"CDA_FILIAL=='"+xFilial("CDA")+"' .AND. "
				cFiltro	+=	"CDA_TPMOVI=='"+aPar[1]+"' .AND. "
				cFiltro	+=	"CDA_ESPECI=='"+aPar[2]+"' .AND. "
				cFiltro	+=	"CDA_FORMUL=='"+aPar[3]+"' .AND. "
				cFiltro	+=	"CDA_NUMERO=='"+aPar[4]+"' .AND. "
				cFiltro	+=	"CDA_SERIE=='"+aPar[5]+"' .AND. "
				cFiltro	+=	"CDA_CLIFOR=='"+aPar[6]+"' .AND. "
				cFiltro	+=	"CDA_LOJA=='"+aPar[7]+"' .AND. "
				cFiltro	+=	"CDA_VALOR > 0 "
		#IFDEF TOP
			EndIf
		#ENDIF

	ElseIf cTabela=="CDG2" // Uso do SPEDPISCOF

		#IFDEF TOP
			If lNotAs400
				cSelect	:=	"%CDG.CDG_FILIAL,CDG.CDG_TPMOV,CDG.CDG_DOC,CDG.CDG_SERIE,CDG.CDG_CLIFOR,CDG.CDG_LOJA,CDG.CDG_PROCES,CDG.CDG_TPPROC,CDG.CDG_IFCOMP,CDG.CDG_PROCES,CDG.CDG_TPPROC,"
				cSelect +=  "CCF.CCF_NUMERO, CCF.CCF_IDSEJU,CCF.CCF_IDVARA, CCF.CCF_NATJU,CCF.CCF_DESCJU, CCF.CCF_DTSENT,CCF.CCF_NATAC, CCF.CCF_DTADM,CCF.CCF_TPCOMP  %"
				cFrom	:=	""+RetSqlName("CDG")+" CDG "
				cFrom	+=	"LEFT JOIN "+RetSqlName("CCF")+" CCF ON CCF.CCF_FILIAL='"+xFilial("CCF")+"' AND CDG.CDG_PROCES=CCF.CCF_NUMERO AND CDG.CDG_TPPROC=CCF.CCF_TIPO AND CCF.D_E_L_E_T_=' '"
				cWhere	:=	"CDG.CDG_FILIAL='"+xFilial("CDG")+"' AND "
				cWhere	+=	"CDG.CDG_TPMOV='"+aPar[1]+"' AND "
				cWhere	+=	"CDG.CDG_DOC='"+aPar[2]+"' AND "
				cWhere	+=	"CDG.CDG_SERIE='"+aPar[3]+"' AND "
				cWhere	+=	"CDG.CDG_CLIFOR='"+aPar[4]+"' AND "
				cWhere	+=	"CDG.CDG_LOJA='"+aPar[5]+"' AND "
				cWhere	+=	"CDG.D_E_L_E_T_=' '"

				If aExistBloc[29] // PE para SCP com Filial unica - TTUXH9
					ApeF500 := ExecBlock("SPDF500C", .F. , .F. , {cFrom,cWhere})
					cFrom 	:= ApeF500[1]
					cWhere	:= ApeF500[2]
				Endif

				cFrom 	:= "%"+cFrom+"%"
				cWhere	:= "%"+cWhere+"%"

				aAdd(aSetField,{"CCF_DTSENT","D",8,0})
				aAdd(aSetField,{"CCF_DTADM","D",8,0})

			Else
		#ENDIF
				cFiltro	:=	"CDG_FILIAL=='"+xFilial("CDG")+"' .AND. "
				cFiltro	+=	"CDG_TPMOV=='"+aPar[1]+"' .AND. "
				cFiltro	+=	"CDG_DOC=='"+aPar[2]+"' .AND. "
				cFiltro	+=	"CDG_SERIE=='"+aPar[3]+"' .AND. "
				cFiltro	+=	"CDG_CLIFOR=='"+aPar[4]+"' .AND. "
				cFiltro	+=	"CDG_LOJA=='"+aPar[5]+"' "
		#IFDEF TOP
			EndIf
		#ENDIF

	ElseIf cTabela=="CD5"  // Uso do SPEDPISCOF/SPEDFISCAL

		#IFDEF TOP
			If lNotAs400
				cSelect	:=	"%CD5.CD5_FILIAL,CD5.CD5_DOC,CD5.CD5_SERIE,CD5.CD5_FORNEC,CD5.CD5_LOJA,CD5.CD5_DOCIMP,CD5.CD5_ESPEC,CD5.CD5_TPIMP,CD5.CD5_BSPIS,CD5.CD5_ALPIS,CD5.CD5_VLPIS,CD5.CD5_BSCOF,CD5.CD5_ALCOF,CD5.CD5_VLCOF"
				If aSPDSX3[FP_CD5_ACDRAW]
					cSelect	+=	",CD5.CD5_ACDRAW"
				EndIf
				If aSPDSX3[FP_CD5_DTPPIS]
					cSelect	+=	",CD5.CD5_DTPPIS"
				EndIf
				If aSPDSX3[FP_CD5_DTPCOF]
					cSelect	+=	",CD5.CD5_DTPCOF"
				EndIf
				If aSPDSX3[FP_CD5_LOCAL]
					cSelect	+=	",CD5.CD5_LOCAL"
				EndIf
				If aSPDSX3[FP_CD5_ITEM]
					cSelect	+=	",CD5.CD5_ITEM"
				EndIf
				cSelect	+=	"%"
				cFrom	:=	"%"+RetSqlName("CD5")+" CD5 %"
				cWhere	:=	"%CD5.CD5_FILIAL='"+xFilial("CD5")+"' AND "
				cWhere	+=	"CD5.CD5_DOC='"+aPar[2]+"' AND "
				cWhere	+=	"CD5.CD5_SERIE='"+aPar[3]+"' AND "
				cWhere	+=	"CD5.CD5_FORNEC='"+aPar[4]+"' AND "
				cWhere	+=	"CD5.CD5_LOJA='"+aPar[5]+"' AND "

				// Utilizado para Registro C199 do SPED PIS COFINS
				If (Len(aPar)>5) .AND. !Empty(aPar[6])
					cWhere	+=	"CD5.CD5_ITEM='"+aPar[6]+"' AND "
				EndIf

				cWhere	+=	"CD5.D_E_L_E_T_=' '%"
			Else
		#ENDIF
				cFiltro	:=	"CD5_FILIAL=='"+xFilial("CD5")+"' .AND. "
				cFiltro	+=	"CD5_DOC=='"+aPar[2]+"' .AND. "
				cFiltro	+=	"CD5_SERIE=='"+aPar[3]+"' .AND. "
				cFiltro	+=	"CD5_FORNEC=='"+aPar[4]+"' .AND. "

				// Utilizado para Registro C199 do SPED PIS COFINS
				If (Len(aPar)>5) .AND. !Empty(aPar[6])
					cFiltro	+=	"CD5_ITEM =='"+aPar[6]+"' .AND. "
				EndIf
				cFiltro	+=	"CD5_LOJA=='"+aPar[5]+"' "

		#IFDEF TOP
			EndIf
		#ENDIF

	ElseIf cTabela=="SF92"   // Uso do SPEDFISCAL

		#IFDEF TOP
			If lNotAs400
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Quando lCountReg estiver como .T., significa que a query deve retornar a quantidade³
				//³ de registros. Utilizado para montar a regua de processamento mais precisa.        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lCountReg
					cSelect	:=	"%COUNT(*) COUNTREG%"
				Else
					cSelect	:=	"%SFA.FA_FILIAL,SFA.FA_CODIGO,SFA.FA_TIPO,SFA.FA_MOTIVO,SFA.FA_DATA,SFA.FA_FATOR,SFA.FA_VALOR,SFA.FA_ROTINA,SFA.FA_BAIXAPR,SF9.F9_CODIGO,F9_CODBAIX,"

					If aSPDSX3[FP_FA_TOTSAI]
						cSelect	+=	"SFA.FA_TOTSAI,"
					EndIf
					If aSPDSX3[FP_FA_TOTTRIB]
						cSelect	+=	"SFA.FA_TOTTRIB,"
					EndIf
					If aSPDSX3[FP_B1_CEST]
						cSelect	+=	"SB1.B1_CEST,"
					EndIf

					cSelect	+=	"SF9.F9_CODIGO,SFA.R_E_C_N_O_ AS SFARECNO,SF9.R_E_C_N_O_ SF9RECNO, SFT.R_E_C_N_O_ SFTRECNO, SFT2.R_E_C_N_O_ SFT2RECNO, SD1.R_E_C_N_O_ SD1RECNO, SD2.R_E_C_N_O_ SD2RECNO, SA1.R_E_C_N_O_ SA1RECNO, SA2.R_E_C_N_O_ SA2RECNO, SB1.R_E_C_N_O_ SB1RECNO, SB12.R_E_C_N_O_ SB12RECNO,SN1.R_E_C_N_O_ SN1RECNO,SN3.R_E_C_N_O_ SN3RECNO,SFT3.R_E_C_N_O_ FTRECDEVOL,SD23.R_E_C_N_O_ D2RECDEVOL,SA23.R_E_C_N_O_ A2RECDEVOL,SB13.R_E_C_N_O_ B1RECDEVOL%"

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Tratamento retirado devido a um problema de JOIN em ambiente ORACLE, bug da versao 10G.                 ³
					//³Como estas duas informacoes nao estao sendo utilizadas no momento, estou desativando.                   ³
					//³                                                                                                        ³
					//³Error : 1445 - ORA-01445: cannot select ROWID from, or sample, a join view without a key-preserved table³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//cSelect	+=	"(SELECT COUNT(*) FROM "+RetSqlName("SFA")+" SFAX WHERE SFAX.FA_FILIAL='"+xFilial("SFA")+"' AND SFAX.FA_CODIGO=SFA.FA_CODIGO AND SFAX.FA_DATA<='"+aPar[2]+"' AND SFAX.D_E_L_E_T_='') QTDAPR,"
					//cSelect	+=	"(SELECT COUNT(*) FROM "+RetSqlName("SFA")+" SFAY WHERE SFAY.FA_FILIAL='"+xFilial("SFA")+"' AND SFAY.FA_CODIGO=SFA.FA_CODIGO AND SFAY.FA_DATA>'"+aPar[2]+"' AND SFAY.D_E_L_E_T_='') QTDAPRPOST,"
					//cSelect	+=	"(SELECT COUNT(*) FROM "+RetSqlName("SF9")+" SF9X WHERE SF9X.F9_FILIAL='"+xFilial("SF9")+"' AND SF9X.F9_DTENTNE=SF9.F9_DTENTNE AND SF9X.F9_DOCNFE=SF9.F9_DOCNFE AND SF9X.F9_SERNFE=SF9.F9_SERNFE AND SF9X.F9_FORNECE=SF9.F9_FORNECE AND SF9X.F9_LOJAFOR=SF9.F9_LOJAFOR AND SF9X.F9_ITEMNFE=SF9.F9_ITEMNFE AND SF9X.D_E_L_E_T_=' ') QTDSF9%"
				EndIf

				cFrom	:=	"%"+RetSqlName("SF9")+" SF9 "
				cFrom	+=	"LEFT JOIN "+RetSqlName("SFA")+" SFA ON SFA.FA_FILIAL='"+xFilial("SFA")+"' AND SFA.FA_CODIGO=SF9.F9_CODIGO AND SFA.D_E_L_E_T_=' ' AND SFA.FA_DATA>='"+aPar[1]+"' AND SFA.FA_DATA <='"+aPar[2]+"' "
				If !lCountReg
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Relacionamento com o documento de ENTRADA³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cFrom	+=	"LEFT JOIN "+RetSqlName("SFT")+" SFT ON SFT.FT_FILIAL='"+xFilial("SFT")+"' AND SFT.FT_TIPOMOV='E' AND SFT.FT_SERIE=SF9.F9_SERNFE AND SFT.FT_NFISCAL=SF9.F9_DOCNFE AND SFT.FT_CLIEFOR=SF9.F9_FORNECE AND SFT.FT_LOJA=SF9.F9_LOJAFOR AND SFT.FT_ITEM=SF9.F9_ITEMNFE AND SFT.D_E_L_E_T_=' ' "
					cFrom	+=	"LEFT JOIN "+RetSqlName("SD1")+" SD1 ON SD1.D1_FILIAL='"+xFilial("SD1")+"' AND SD1.D1_DOC=SFT.FT_NFISCAL AND SD1.D1_SERIE=SFT.FT_SERIE AND SD1.D1_FORNECE=SFT.FT_CLIEFOR AND SD1.D1_LOJA=SFT.FT_LOJA AND SD1.D1_COD=SFT.FT_PRODUTO AND SD1.D1_ITEM=SFT.FT_ITEM AND SD1.D_E_L_E_T_=' ' "
					cFrom	+=	"LEFT JOIN "+RetSqlName("SA2")+" SA2 ON SA2.A2_FILIAL='"+xFilial("SA2")+"' AND SA2.A2_COD=SF9.F9_FORNECE AND SA2.A2_LOJA=SF9.F9_LOJAFOR AND SA2.D_E_L_E_T_=' ' "
					cFrom	+=	"LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.D_E_L_E_T_=' ' "
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Relacionamento com o documento de SAIDA³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cFrom	+=	"LEFT JOIN "+RetSqlName("SFT")+" SFT2 ON SFT2.FT_FILIAL='"+xFilial("SFT")+"' AND SFT2.FT_TIPOMOV='S' AND SFT2.FT_SERIE=SF9.F9_SERNFS AND SFT2.FT_NFISCAL=SF9.F9_DOCNFS AND SFT2.FT_CLIEFOR=SF9.F9_CLIENTE AND SFT2.FT_LOJA=SF9.F9_LOJACLI AND SFT2.FT_ITEM="+Iif(aSPDSX3[FP_F9_ITEMNFS],"SF9.F9_ITEMNFS","''")+" AND SFT2.D_E_L_E_T_=' ' "
					cFrom	+=	"LEFT JOIN "+RetSqlName("SD2")+" SD2  ON SD2.D2_FILIAL='"+xFilial("SD2")+"' AND SD2.D2_DOC=SFT2.FT_NFISCAL AND SD2.D2_SERIE=SFT2.FT_SERIE AND SD2.D2_CLIENTE=SFT2.FT_CLIEFOR AND SD2.D2_LOJA=SFT2.FT_LOJA AND SD2.D2_COD=SFT2.FT_PRODUTO AND SD2.D2_ITEM=SFT2.FT_ITEM AND SD2.D_E_L_E_T_=' ' "
					cFrom	+=	"LEFT JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=SF9.F9_CLIENTE AND SA1.A1_LOJA=SF9.F9_LOJACLI AND SA1.D_E_L_E_T_=' ' "
					cFrom	+=	"LEFT JOIN "+RetSqlName("SB1")+" SB12 ON SB12.B1_FILIAL='"+xFilial("SB1")+"' AND SB12.B1_COD=SFT2.FT_PRODUTO AND SB12.D_E_L_E_T_=' ' "
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Relacionamento com o documento de SAIDA DEVOLUCAO³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cFrom	+=	"LEFT JOIN "+RetSqlName("SFT")+" SFT3 ON SFT3.FT_FILIAL='"+xFilial("SFT")+"' AND SFT3.FT_TIPOMOV='S'         AND SFT3.FT_SERIE=SF9.F9_SERNFS AND SFT3.FT_NFISCAL=SF9.F9_DOCNFS   AND SFT3.FT_CLIEFOR=SF9.F9_FORNECE AND SFT3.FT_LOJA=SF9.F9_LOJAFOR AND SFT3.FT_ITEM="+Iif(aSPDSX3[FP_F9_ITEMNFS],"SF9.F9_ITEMNFS","''")+" AND SFT3.D_E_L_E_T_=' ' "
					cFrom	+=	"LEFT JOIN "+RetSqlName("SD2")+" SD23 ON SD23.D2_FILIAL='"+xFilial("SD2")+"' AND SD23.D2_DOC=SFT3.FT_NFISCAL AND SD23.D2_SERIE=SFT3.FT_SERIE AND SD23.D2_CLIENTE=SFT3.FT_CLIEFOR AND SD23.D2_LOJA=SFT3.FT_LOJA      AND SD23.D2_COD=SFT3.FT_PRODUTO AND SD23.D2_ITEM=SFT3.FT_ITEM AND SD23.D_E_L_E_T_=' ' "
					cFrom	+=	"LEFT JOIN "+RetSqlName("SA2")+" SA23 ON SA23.A2_FILIAL='"+xFilial("SA2")+"' AND SA23.A2_COD=SF9.F9_FORNECE  AND SA23.A2_LOJA=SF9.F9_LOJAFOR AND SA23.D_E_L_E_T_=' ' "
					cFrom	+=	"LEFT JOIN "+RetSqlName("SB1")+" SB13 ON SB13.B1_FILIAL='"+xFilial("SB1")+"' AND SB13.B1_COD=SFT3.FT_PRODUTO AND SB13.D_E_L_E_T_=' ' "
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Relacionamento com o cadastro de ativo (SN1/SN3)³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cFrom	+=	"LEFT JOIN "+RetSqlName("SN1")+" SN1 ON SN1.N1_FILIAL='"+xFilial("SN1")+"' AND SN1.N1_CODCIAP=SF9.F9_CODIGO AND SN1.D_E_L_E_T_=' ' "
					cFrom	+=	"LEFT JOIN "+RetSqlName("SN3")+" SN3 ON SN3.N3_FILIAL='"+xFilial("SN3")+"' AND SN3.N3_CBASE=SN1.N1_CBASE AND SN3.N3_ITEM=SN1.N1_ITEM AND SN3.D_E_L_E_T_=' '"
				EndIf
				cFrom	+=	"%"
				cWhere	:= 	"%SF9.F9_FILIAL='"+xFilial("SF9")+"' AND "
				cWhere	+= 	"((SFA.FA_DATA>='"+aPar[1]+"' AND "
				cWhere	+= 	"SFA.FA_DATA<='"+aPar[2]+"') "

				IF !lMVAprComp
					cWhere	+= 	" OR (SF9.F9_DTINIUT >='"+aPar[1]+"' AND "
					cWhere	+= 	"SF9.F9_DTINIUT <='"+aPar[2]+"' AND F9_TIPO = '03' ) "
				EndIf

				If lMVAprComp .And. lMVBemEnt
					//Esta situação é prevista apenas na primeira situação do bloco G125
					//MSERV-339 contém uma consulta, para verificação da situação apresentada.
					cWhere	+= 	" OR (SF9.F9_DTENTNE >='"+aPar[1]+"' AND "
					cWhere	+= 	"SF9.F9_DTENTNE <='"+aPar[2]+"' AND (F9_TIPO = '01' OR F9_TIPO = '') ) "
				EndIf

				cWhere	+= 	")  AND SF9.D_E_L_E_T_ = ' ' "

				If !lCountReg
					cOrderBy := " ORDER BY SF9.F9_CODIGO "
					cOrderBy := " %"
				Else
					cWhere	+= 	" %"
				EndIf

				aAdd(aSetField,{"FA_DATA","D",8,0})
				aAdd(aSetField,{"F9_DTENTNE","D",8,0})
				aAdd(aSetField,{"F9_DTEMINE","D",8,0})
				aAdd(aSetField,{"F9_DTEMINS","D",8,0})
			Else
		#ENDIF
				cFiltro	:=	"F9_FILIAL=='"+xFilial("SF9")+"'"
		#IFDEF TOP
			EndIf
		#ENDIF

	ElseIf cTabela=="SFA5"   // Uso do SPEDFISCAL apenas quando não for TOP.

		cFiltro	:=	"FA_FILIAL=='"+xFilial("SFA")+"' .AND. "
		cFiltro	+= 	"DToS(FA_DATA)>='"+aPar[1]+"' .AND. "
		cFiltro	+= 	"DToS(FA_DATA)<='"+aPar[2]+"' "


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento criado isoladamente da condicao anterior (cTabela=="SFA") devido a um problema de JOIN em    ³
	//|  ambiente ORACLE, bug da versao 10G.                                                                   |
	//³Como estas duas informacoes nao estao sendo utilizadas no momento, estou desativando.                   ³
	//³                                                                                                        ³
	//³Error : 1445 - ORA-01445: cannot select ROWID from, or sample, a join view without a key-preserved table³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cTabela=="SFA2" // Uso do SPEDFISCAL

		#IFDEF TOP
			If lNotAs400
				cSelect	:=	"%COUNT(*) QTDAPR%"
				cFrom	:=	"%"+RetSqlName("SFA")+" SFAX%"
				cWhere	:=	"%SFAX.FA_FILIAL='"+xFilial("SFA")+"' AND "
				cWhere	+=	"SFAX.FA_CODIGO='"+aPar[1]+"' AND "
				cWhere	+=	"SFAX.FA_DATA<='"+aPar[2]+"' AND "
				cWhere	+=	"SFAX.D_E_L_E_T_=''%"
			Else
		#ENDIF
				cFiltro	:=	"FA_FILIAL=='"+xFilial("SFA")+"' .AND. "
				cFiltro	+=	"FA_CODIGO=='"+aPar[1]+"' .AND. "
				cFiltro	+=	"DToS(FA_DATA)<='"+aPar[2]+"' "
		#IFDEF TOP
			EndIf
		#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento criado isoladamente da condicao anterior (cTabela=="SFA") devido a um problema de JOIN em    ³
	//|  ambiente ORACLE, bug da versao 10G.                                                                   |
	//³Como estas duas informacoes nao estao sendo utilizadas no momento, estou desativando.                   ³
	//³                                                                                                        ³
	//³Error : 1445 - ORA-01445: cannot select ROWID from, or sample, a join view without a key-preserved table³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cTabela=="SFA3" // Uso do SPEDFISCAL

		#IFDEF TOP
			If lNotAs400
				cSelect	:=	"%COUNT(*) QTDAPRPOST%"
				cFrom	:=	"%"+RetSqlName("SFA")+" SFAY%"
				cWhere	:=	"%SFAY.FA_FILIAL='"+xFilial("SFA")+"' AND "
				cWhere	+=	"SFAY.FA_CODIGO='"+aPar[1]+"' AND "
				cWhere	+=	"SFAY.FA_DATA>'"+aPar[2]+"' AND "
				cWhere	+=	"SFAY.FA_TIPO='1' AND "
				cWhere	+=	"SFAY.D_E_L_E_T_=''%"

			Else
		#ENDIF
				cFiltro	:=	"FA_FILIAL=='"+xFilial("SFA")+"' .AND. "
				cFiltro	+=	"FA_CODIGO=='"+aPar[1]+"' .AND. "
				cWhere	+=	"FA_TIPO=='1' .AND. "
				cFiltro	+=	"DToS(FA_DATA)>'"+aPar[2]+"' "
		#IFDEF TOP
			EndIf
		#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento nao foi criado como uma subquery na condicao anterior (cTabela=="SFA") devido a um problema  ³
	//|  de JOIN em ambiente ORACLE, bug da versao 10G.                                                        |
	//³Como estas duas informacoes nao estao sendo utilizadas no momento, estou desativando.                   ³
	//³                                                                                                        ³
	//³Error : 1445 - ORA-01445: cannot select ROWID from, or sample, a join view without a key-preserved table³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cTabela=="SFA4" // Uso do SPEDFISCAL

		#IFDEF TOP
			If lNotAs400
				cSelect	:=	"%SUM(SFA4.FA_VALOR) VLRBAIXA%"
				cFrom	:=	"%"+RetSqlName("SFA")+" SFA4%"
				cWhere	:=	"%SFA4.FA_FILIAL='"+xFilial("SFA")+"' AND "
				cWhere	+=	"SFA4.FA_CODIGO='"+aPar[1]+"' AND "
				cWhere	+=	"SFA4.FA_DATA<='"+aPar[2]+"' AND "
				cWhere	+=	"SFA4.FA_TIPO='2' AND "
				cWhere	+=	"SFA4.FA_BAIXAPR='1' AND "
				cWhere	+=	"SFA4.D_E_L_E_T_=''%"

			Else
		#ENDIF

				//PARA DBF NAO NECESSITA DE FILTRO, POIS EH UM IF DIFERENTE NA CHAMADA DA FUNCAO

		#IFDEF TOP
			EndIf
		#ENDIF

	ElseIf cTabela=="SF9" // Uso do SPEDFISCAL

		#IFDEF TOP
			If lNotAs400

				cSelect :=	"%COUNT(*) QTDSF9%"
				cFrom	:=	"%"+RetSqlName("SF9")+" SF9X %"
				cWhere	:=	"%SF9X.F9_FILIAL='"+xFilial("SF9")+"' AND "
				cWhere	+=	"SF9X.F9_DTENTNE='"+aPar[1]+"' AND "
				cWhere	+=	"SF9X.F9_DOCNFE='"+aPar[2]+"' AND "
				cWhere	+=	"SF9X.F9_SERNFE='"+aPar[3]+"' AND "
				cWhere	+=	"SF9X.F9_FORNECE='"+aPar[4]+"' AND "
				cWhere	+=	"SF9X.F9_LOJAFOR='"+aPar[5]+"' AND "
				cWhere	+=	"SF9X.F9_ITEMNFE='"+aPar[6]+"' AND "
				cWhere	+=	"SF9X.D_E_L_E_T_=' ' %"
			Else
		#ENDIF
				cFiltro	:=	"F9_FILIAL=='"+xFilial("SF9")+"' .AND. "
				cFiltro	+=	"DToS(F9_DTENTNE)=='"+aPar[1]+"' .AND. "
				cFiltro	+=	"F9_DOCNFE=='"+aPar[2]+"' .AND. "
				cFiltro	+=	"F9_SERNFE=='"+aPar[3]+"' .AND. "
				cFiltro	+=	"F9_FORNECE=='"+aPar[4]+"' .AND. "
				cFiltro	+=	"F9_LOJAFOR=='"+aPar[5]+"' .AND. "
				cFiltro	+=	"F9_ITEMNFE=='"+aPar[6]+"' "

		#IFDEF TOP
			EndIf
		#ENDIF

	ElseIf cTabela=="CDH" // Uso do SPEDFISCAL

		#IFDEF TOP
			If lNotAs400
				cSelect :=	"%A.*,SF6.R_E_C_N_O_ SF6RECNO%"
				cFrom	:=	"%"+RetSqlName("CDH")+" A "
				cFrom	+=	" LEFT JOIN "+RetSqlName("SF6")+" SF6 ON SF6.F6_FILIAL='"+xFilial("SF6")+"' AND A.CDH_ESTGNR=SF6.F6_EST AND A.CDH_GNRE=SF6.F6_NUMERO AND SF6.D_E_L_E_T_=' '%"
				cWhere	:=	"%A.CDH_FILIAL='"+xFilial("CDH")+"' AND "
				cWhere	+=	"A.CDH_TIPOIP='"+aPar[1]+"' AND "
				cWhere	+=	"A.CDH_TIPOPR='"+aPar[2]+"' AND "
				cWhere	+=	"A.CDH_PERIOD='"+aPar[3]+"' AND "
				cWhere	+=	"A.CDH_DTINI='"+aPar[4]+"' AND "
				cWhere	+=	"A.CDH_LIVRO='"+aPar[5]+"' AND "
				cWhere	+=	"A.CDH_SEQUEN=(SELECT MAX(B.CDH_SEQUEN) FROM "+RetSqlName("CDH")+" B WHERE B.CDH_FILIAL=A.CDH_FILIAL AND B.CDH_TIPOIP=A.CDH_TIPOIP AND B.CDH_TIPOPR=A.CDH_TIPOPR AND B.CDH_PERIOD=A.CDH_PERIOD AND B.CDH_DTINI=A.CDH_DTINI AND B.CDH_LIVRO=A.CDH_LIVRO AND B.D_E_L_E_T_='') AND "
				cWhere	+=	"A.D_E_L_E_T_=' '%"
			Else
		#ENDIF
				cFiltro	:=	"CDH_FILIAL=='"+xFilial("CDH")+"' .AND. "
				cFiltro	+=	"CDH_TIPOIP=='"+aPar[1]+"' .AND. "
				cFiltro	+=	"CDH_TIPOPR=='"+aPar[2]+"' .AND. "
				cFiltro	+=	"CDH_PERIOD=='"+aPar[3]+"' .AND. "
				cFiltro	+=	"DToS(CDH_DTINI)=='"+aPar[4]+"' .AND. "
				cFiltro	+=	"CDH_LIVRO=='"+aPar[5]+"' .AND. "
				cFiltro	+=	"CDH_SEQUEN=='"+aPar[6]+"' "
		#IFDEF TOP
			EndIf
		#ENDIF

	ElseIf cTabela=="CDP" // Uso do SPEDFISCAL

		#IFDEF TOP
			If lNotAs400
				cSelect :=	"%CDP.*,CCK.R_E_C_N_O_ CCKRECNO%"
				cFrom	:=	"%"+RetSqlName("CDP")+" CDP "
				cFrom	+=	" LEFT JOIN "+RetSqlName("CCK")+" CCK ON CCK.CCK_FILIAL='"+xFilial("CCK")+"' AND CCK.CCK_CODAJU=CDP.CDP_CODLAN AND CCK.D_E_L_E_T_=' '%"

				cWhere	:=	"%CDP.CDP_FILIAL='"+xFilial("CDP")+"' AND "
				cWhere	+=	"CDP.CDP_TIPOIP='"+aPar[1]+"' AND "
				cWhere	+=	"CDP.CDP_TIPOPR='"+aPar[2]+"' AND "
				cWhere	+=	"CDP.CDP_PERIOD='"+aPar[3]+"' AND "
				cWhere	+=	"CDP.CDP_DTINI='"+aPar[4]+"' AND "
				cWhere	+=	"CDP.CDP_LIVRO='"+aPar[5]+"' AND "
				cWhere	+=	"CDP.CDP_SEQUEN=(SELECT MAX(B.CDP_SEQUEN) FROM "+RetSqlName("CDP")+" B WHERE B.CDP_FILIAL=CDP.CDP_FILIAL AND B.CDP_TIPOIP=CDP.CDP_TIPOIP AND B.CDP_TIPOPR=CDP.CDP_TIPOPR AND B.CDP_PERIOD=CDP.CDP_PERIOD AND B.CDP_DTINI=CDP.CDP_DTINI AND B.CDP_LIVRO=CDP.CDP_LIVRO AND B.D_E_L_E_T_=' ') AND "
				cWhere	+=	"CDP.D_E_L_E_T_=' '%"
			Else
		#ENDIF
				cFiltro	:=	"CDP_FILIAL=='"+xFilial("CDP")+"' .AND. "
				cFiltro	+=	"CDP_TIPOIP=='"+aPar[1]+"' .AND. "
				cFiltro	+=	"CDP_TIPOPR=='"+aPar[2]+"' .AND. "
				cFiltro	+=	"CDP_PERIOD=='"+aPar[3]+"' .AND. "
				cFiltro	+=	"DToS(CDP_DTINI)=='"+aPar[4]+"' .AND. "
				cFiltro	+=	"CDP_LIVRO=='"+aPar[5]+"' .AND. "
				cFiltro	+=	"CDP_SEQUEN=='"+aPar[6]+"' "
		#IFDEF TOP
			EndIf
		#ENDIF

	ElseIf cTabela=="CDL" // Uso do SPEDFISCAL

		#IFDEF TOP
			If lNotAs400
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Quando lCountReg estiver como .T., significa que a query deve retornar a quantidade³
				//³ de registros. Utilizado para montar a regua de processamento mais precisa.        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lCountReg
					cSelect	:=	"%COUNT(*) COUNTREG%"
				Else
					cSelect :=	"%*%"
				EndIf
				cFrom	:=	"%"+RetSqlName("CDL")+" CDL%"
				cWhere	:=	"%CDL.CDL_FILIAL='"+xFilial("CDL")+"' AND "
				cWhere	+=	"CDL.CDL_DTAVB>='"+aPar[1]+"' AND "
				cWhere	+=	"CDL.CDL_DTAVB<='"+aPar[2]+"' AND "
				cWhere	+=	"CDL.D_E_L_E_T_=' '%"
			Else
		#ENDIF
				cFiltro	:=	"CDL_FILIAL=='"+xFilial("CDL")+"' .AND. "
				cFiltro	+=	"DToS(CDL_DTAVB)>='"+aPar[1]+"' .AND. "
				cFiltro	+=	"DToS(CDL_DTAVB)<='"+aPar[2]+"' "
		#IFDEF TOP
			EndIf
		#ENDIF

	ElseIf cTabela=="EEC" // Uso do SPEDFISCAL

		#IFDEF TOP
			If lNotAs400
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Quando lCountReg estiver como .T., significa que a query deve retornar a quantidade³
				//³ de registros. Utilizado para montar a regua de processamento mais precisa.        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lCountReg
					cSelect	:=	"%COUNT(*) COUNTREG%"
				Else
					cSelect :=	"%*%"
				EndIf
				cFrom	:=	"%"+RetSqlName("EEC")+" EEC "
				cFrom	+=	"JOIN "+RetSqlName("EE9")+" EE9 "
				cFrom	+=	"ON EE9.EE9_FILIAL='"+xFilial("EE9")+"' AND EE9.EE9_PREEMB=EEC.EEC_PREEMB AND EE9.D_E_L_E_T_=''%"
		      	cWhere	:=	"%EEC.EEC_FILIAL='"+xFilial("EEC")+"' AND "
		        cWhere	+=	"EEC.EEC_DTEMBA>='"+aPar[1]+"' AND "
		        cWhere	+=	"EEC.EEC_DTEMBA<='"+aPar[2]+"' AND "
				cWhere	+=	"EEC.D_E_L_E_T_=''%"
			Else
		#ENDIF
		      	cFiltro	:=	"EEC_FILIAL=='"+xFilial("EEC")+"' .AND. "
		        cFiltro	+=	"DToS(EEC_DTEMBA)>='"+aPar[1]+"' .AND. "
		        cFiltro	+=	"DToS(EEC_DTEMBA)<='"+aPar[2]+"' "
		#IFDEF TOP
			EndIf
		#ENDIF

	ElseIf cTabela=="SFI" // Uso do SPEDFISCAL

		#IFDEF TOP
			If lNotAs400
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Quando lCountReg estiver como .T., significa que a query deve retornar a quantidade³
				//³ de registros. Utilizado para montar a regua de processamento mais precisa.        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lCountReg
					cSelect	:=	"%COUNT(*) COUNTREG%"
				Else
					cSelect := "%SFI.FI_DTMOVTO,SFI.R_E_C_N_O_ SFIRECNO%"
				EndIf
				cFrom	:=	"%"+RetSqlName("SFI")+" SFI %"
		      	cWhere	:=	"%SFI.FI_FILIAL='"+xFilial("SFI")+"' AND "
		        cWhere	+=	"SFI.FI_DTMOVTO>='"+aPar[1]+"' AND "
		        cWhere	+=	"SFI.FI_DTMOVTO<='"+aPar[2]+"' AND "
		        cWhere	+=	"SFI.FI_PDV='"+aPar[3]+"' AND "
		        cWhere	+=	"SFI.FI_SERPDV='"+aPar[4]+"' AND "
		        cWhere	+=	"( (SFI.FI_VALCON > 0 ) OR (FI_ISS > 0) ) AND "
				cWhere	+=	"SFI.D_E_L_E_T_=''"
				If !lCountReg
					cOrderBy := " ORDER BY 1%"
				Else
					cOrderBy := "%"
				EndIf
			Else
		#ENDIF
		      	cFiltro	:=	"FI_FILIAL=='"+xFilial("SFI")+"' .AND. "
		        cFiltro	+=	"DToS(FI_DTMOVTO)>='"+aPar[1]+"' .AND. "
		        cFiltro	+=	"DToS(FI_DTMOVTO)<='"+aPar[2]+"' .AND. "
		        cFiltro	+=	"FI_PDV=='"+aPar[3]+"' .AND. "
		        cFiltro	+=	"FI_SERPDV=='"+aPar[4]+"' .AND. "
		        cFiltro	+=	"( (FI_VALCON > 0 ) .OR. (FI_ISS > 0) )  "
		#IFDEF TOP
			EndIf
		#ENDIF

    Elseif cTabela=="CE6" // Uso do SPEDFISCAL

    	#IFDEF TOP
			If lNotAs400
				If lCountReg
					cSelect	:=	"%COUNT(*) COUNTREG%"
				Else
					cSelect :=	"%CE6.*, CE5.*%"
				EndIf
				cFrom	:=	"%"+RetSqlName("CE6")+" CE6 "
				cFrom	+=	" LEFT JOIN "+RetSqlName("CE5")+" CE5 ON CE5.CE5_FILIAL='"+xFilial("CE6")+"' AND CE5.CE5_CODLAN=CE6.CE6_CODLAN AND "
				cFrom	+=	"CE5.CE5_PERIOD=CE6.CE6_PERIOD AND CE5.D_E_L_E_T_=''%"
				cWhere	:=	"%CE6.CE6_FILIAL='"+xFilial("CE6")+"' AND "
				cWhere	+=	"CE6.CE6_PERIOD='"+aPar[1]+"' AND "
				//cWhere	+=	"CE5.CE5_TPMOV IN ('U','R') AND "
				cWhere	+=	"substring(CE6.CE6_CODLAN,4,1)='9' AND "
				cWhere	+=	"CE6.D_E_L_E_T_=''%"
			Else
		#ENDIF
				cFiltro	:=	"CE6_FILIAL=='"+xFilial("CE6")+"' .AND. "
				cFiltro	+=	"CE6_PERIOD=='"+aPar[1]+"' "
		#IFDEF TOP
			EndIf
		#ENDIF

	Elseif cTabela=="CF5" // Uso do SPEDPISCOF

		#IFDEF TOP
			If lNotAs400
				cSelect :=	"%CF5.*%"
				cFrom	:=	"%"+RetSqlName("CF5")+" CF5 %"
				cWhere	:=	"%CF5.CF5_FILIAL='"+xFilial("CF5")+"' AND "
				cWhere	+=	"CF5.CF5_DTREF>='"+aPar[1]+"' AND "
				cWhere	+=	"CF5.CF5_DTREF<='"+aPar[2]+"' AND "
				cWhere	+=	"CF5.CF5_PISCOF='"+aPar[4] +"' AND "
				If aSPDSX3[FP_CF5_CODCRE]
					cWhere	+=	"CF5.CF5_CODCRE='"+aPar[3] +"' AND "
				Endif
				cWhere	+=	"CF5.D_E_L_E_T_=''%"
				aAdd(aSetField,{"CF5_DTREF","D",8,0})
			Else
		#ENDIF
				cFiltro	:= 'CF5_FILIAL=="'+xFilial ("CF5")+'" .And. '
	   			cFiltro += 'DTOS(CF5_DTREF)>="'+aPar[1]+'" .And. '
	   			cFiltro += 'DTOS(CF5_DTREF)<="'+aPar[2]+'" .And. '
	   			If aSPDSX3[FP_CF5_CODCRE]
	   				cFiltro += 'CF5_CODCRE=="'+aPar[3]+'" .And. '
	   			Endif
	   			cFiltro += 'CF5_PISCOF=="'+aPar[4]+'" '
		#IFDEF TOP
			EndIf
		#ENDIF

    Elseif cTabela=="CF6" // Uso do SPEDPISCOF

    	#IFDEF TOP
			If lNotAs400
				cSelect	:=	"%CF6.*%"
				cFrom	:=	"%"+RetSqlName("CF6")+" CF6 %"
				cWhere	:=	"%CF6.CF6_FILIAL='"+xFilial("CF6")+"' AND "
				cWhere	+=	"CF6.CF6_DTOPER>='"+aPar[1]+"' AND "
				cWhere	+=	"CF6.CF6_DTOPER<='"+aPar[2]+"' AND "
				cWhere	+=	"CF6.D_E_L_E_T_=''%"

				aAdd(aSetField,{"CF6_DTOPER","D",8,0})
			Else
		#ENDIF
				cFiltro	:= 'CF6_FILIAL=="'+xFilial("CF6")+'" .And. '
	   			cFiltro += 'DTOS(CF6_DTOPER)>="'+aPar[1]+'" .And. '
	   			cFiltro	+= 'DTOS(CF6_DTOPER)<="'+aPar[2]+'" '
		#IFDEF TOP
			EndIf
		#ENDIF

    Elseif cTabela=="CF8" // Uso do SPEDPISCOF

    	#IFDEF TOP
			If lNotAs400
				cSelect	:=	"%CF8.*%"
				cFrom	:=	"%"+RetSqlName("CF8")+" CF8 %"
				cWhere	:=	"%CF8.CF8_FILIAL='"+xFilial("CF8")+"' AND "
				cWhere	+=	"CF8.CF8_DTOPER>='"+aPar[1]+"' AND "
				cWhere	+=	"CF8.CF8_DTOPER<='"+aPar[2]+"' AND "
				cWhere	+=	"CF8.D_E_L_E_T_=''%"
				aAdd(aSetField,{"CF8_DTOPER","D",8,0})
				If aSPDSX3[FP_CF8_DTFIMN]
					aAdd(aSetField,{"CF8_DTFIMN","D",8,0})
				Endif
			Else
		#ENDIF
				cFiltro	:= 'CF8_FILIAL=="'+xFilial("CF8")+'" .And. '
	   			cFiltro += 'DTOS(CF8_DTOPER)>="'+aPar[1]+'" .And. '
	   			cFiltro	+= 'DTOS(CF8_DTOPER)<="'+aPar[2]+'" '
		#IFDEF TOP
			EndIf
		#ENDIF

	Elseif cTabela=="CF2" // Uso do SPEDPISCOF

    	#IFDEF TOP
			If lNotAs400
				cSelect	:=	"%CF2.*%"
				cFrom	:=	"%"+RetSqlName("CF2")+" CF2 %"
				cWhere	:=	"%CF2.CF2_FILIAL='"+xFilial("CF2")+"' AND "
				If !Empty(aPar[1])
					cWhere	+=	"CF2.CF2_INDNAT='"+aPar[1]+"' AND "
				Endif
				cWhere	+=	"CF2.CF2_PER='"+aPar[2]+"' AND "
				cWhere	+=	"CF2.D_E_L_E_T_=''%"
			Else
		#ENDIF
				cFiltro	:= 'CF2_FILIAL=="'+xFilial("CF2")+'" .And. '
	   			If !Empty(aPar[1])
	   				cFiltro += 'CF2_INDNAT=="'+aPar[1]+'" .And. '
	   			Endif
	   			cFiltro	+= 'CF2_PER=="'+aPar[2]+'" '
		#IFDEF TOP
			EndIf
		#ENDIF

    Elseif cTabela=="CF3" // Uso do SPEDPISCOF

    	#IFDEF TOP
			If lNotAs400
				cSelect	:=	"%CF3.CF3_PERORI, CF3.CF3_REGIME, CF3.CF3_VLRPIS, CF3.CF3_VLRCOF, CF3.CF3_ORIGEM"
				cSelect	+=	Iif(aPar[1],",CF3.CF3_NFDEV, CF3.CF3_NFORI%","%")
				cFrom	:=	"%"+RetSqlName("CF3")+" CF3 %"
				cWhere	:=	"%CF3.CF3_FILIAL='"+xFilial("CF3")+"' AND "
				cWhere	+=	"CF3.CF3_PERUTI='"+aPar[2]+"' AND "
				cWhere	+=	"CF3.CF3_ORIGEM IN ('D','E','A','C') AND "
				cWhere	+=	"CF3.D_E_L_E_T_=''%"

				aAdd(aSetField,{"CF3_PERORI","D",8,0})
			Else
		#ENDIF
				cFiltro	:= 'CF3_FILIAL=="'+xFilial("CF3")+'" .And. '
	   			cFiltro += 'CF3_PERUTI =="'+ aPar[2] + '" .And. '
		   		cFiltro	+= '(CF3_ORIGEM$ "D#E#A#C")'
		#IFDEF TOP
			EndIf
		#ENDIF

    Elseif cTabela=="CFA"

    	#IFDEF TOP
			If lNotAs400
				cSelect	:=	"%CFA.CFA_CODCON, CFA.CFA_TPCON, CFA.CFA_CNPJ, CFA.CFA_TOTVEN, CFA.CFA_VLNREC, CFA.CFA_CONDIF, "
				cSelect	+=	"CFA.CFA_PERAPU, CFA.CFA_ALIQ, CFA_CREDIF, CFA_CODCRE%"
				cFrom	:=	"%"+RetSqlName("CFA")+" CFA %"
				cWhere	:=	"%CFA.CFA_FILIAL='"+xFilial("CFA")+"' AND "
				cWhere	+=	"CFA.CFA_PERAPU='"+aPar[1]+"' AND "
				cWhere	+=	"CFA.CFA_TPCON='"+aPar[2]+"' AND "
				cWhere	+=	"CFA.D_E_L_E_T_=''%"
			Else
		#ENDIF
				cFiltro	:= 'CFA_FILIAL=="'+xFilial("CFA")+'" .And. '
	   			cFiltro += 'CFA_PERAPU =="'+ aPar[1] + '" .And. '
	   			cFiltro += 'CFA_TPCON =="'+ aPar[2] + '"'
		#IFDEF TOP
			EndIf
		#ENDIF

    Elseif cTabela=="CFA2"

    	#IFDEF TOP
			If lNotAs400
				cSelect	:=	"%CFA.CFA_PERAPU, CFA.CFA_ALIQ, CFA_CREDIF,CFA_TPCON, CFA_CODCRE%"
				cFrom	:=	"%"+RetSqlName("CFA")+" CFA %"
				cWhere	:=	"%CFA.CFA_FILIAL='"+xFilial("CFA")+"' AND "
				cWhere	+=	"CFA.CFA_PERAPU='"+aPar[1]+"' AND "
				cWhere	+=	"CFA.D_E_L_E_T_=''%"
			Else
		#ENDIF
				cFiltro	:= 'CFA_FILIAL=="'+xFilial("CFA")+'" .And. '
	   			cFiltro += 'CFA_PERAPU =="'+ aPar[1] + '"'
		#IFDEF TOP
			EndIf
		#ENDIF
    Elseif cTabela=="CFB"

    	#IFDEF TOP
			If lNotAs400
				cSelect	:=	"%CFB.CFB_CODCON, CFB.CFB_TPCON, CFB.CFB_DTPGTO, CFB.CFB_PERDIF, CFB.CFB_CONREC, "
				cSelect	+=	"CFB.CFB_PERAPU, CFB.CFB_ALIQ,CFB.CFB_NATCRE, CFB.CFB_CREDES%"
				cFrom	:=	"%"+RetSqlName("CFB")+" CFB %"
				cWhere	:=	"%CFB.CFB_FILIAL='"+xFilial("CFB")+"' AND "
				cWhere	+=	"CFB.CFB_PERAPU='"+aPar[1]+"' AND "
				cWhere	+=	"CFB.CFB_TPCON='"+aPar[2]+"' AND "
				cWhere	+=	"CFB.D_E_L_E_T_=''%"
			Else
		#ENDIF
				cFiltro	:= 'CFB_FILIAL=="'+xFilial("CFB")+'" .And. '
	   			cFiltro += 'CFB_PERAPU =="'+ aPar[1] + '" .And. '
	   			cFiltro += 'CFB_TPCON =="'+ aPar[2] + '"'
		#IFDEF TOP
			EndIf
		#ENDIF

    EndIf

	#IFDEF TOP
		If lNotAs400
			cAlias	:=	SPEDGetAlias(cTabela)
			BeginSql Alias cAlias
				SELECT
					%Exp:cSelect%

				FROM
					%Exp:cFrom%

				WHERE
					%Exp:cWhere+cOrderBy%

				//%Exp:cOrderBy%
			EndSql

			If !lCountReg
				For nI := 1 To Len(aSetField)
					TcSetField(cAlias,aSetField[nI,1],aSetField[nI,2],aSetField[nI,3],aSetField[nI,4])
				Next
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o retorno deve ser a quantidade de registros, armazeno em uma variavel para retornar³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lCountReg
				nRecCount := (cAlias)->COUNTREG
			EndIf
		Else
	#ENDIF
		    cIndex  := CriaTrab(Nil,.F.)
		    cTabela := SubStr(cTabela,1,3)
		    IndRegua(cAlias,cIndex,(cTabela)->(IndexKey (nOrdDBF)),,cFiltro,,.F.)
		    nIndex  := RetIndex(cAlias)
			#IFNDEF TOP
				DbSetIndex(cIndex+OrdBagExt())
			#ENDIF
			DbSelectArea(cAlias)
		    DbSetOrder(nIndex+1)
			(cAlias)->(DbGoTop())
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o retorno deve ser a quantidade de registros, armazeno em uma variavel para retornar³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lCountReg
				nRecCount := (cAlias)->(RecCount())
			EndIf
	#IFDEF TOP
		EndIf
	#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Como jah armazenei em uma variavel o valor da quantidade de registros, ³
	//³  posso fechar a area. O retorno da quantidade eh atraves de um        ³
	//³  parametro passado por referencia. O retorno da funcao ainda continua ³
	//³  sendo .T. quando tiver registros ou .F. quando nao tiver.            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCountReg
		SPEDFFiltro(2,"",cAlias)
		lRet := nRecCount>0
	ElseIf !(cAlias)->(Eof())
		lRet := .T.
	Else
		SPEDFFiltro(2,"",cAlias)
	EndIf

Else
	#IFDEF TOP
		If lNotAs400
			If Select(cAlias)<>0
				(cAlias)->(DbCloseArea())
			EndIf
		Else
	#ENDIF
			RetIndex(cAlias)
	#IFDEF TOP
		EndIf
	#ENDIF
EndIf

Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MyGetEnd  ³ Autor ³Gustavo G. Rueda              ³ Data ³22.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o participante e do DF, ou se tem um tipo de endereco ³±±
±±³          ³ que nao se enquadra na regra padrao de preenchimento de endereco  ³±±
±±³          ³ por exemplo: Enderecos de Area Rural (essa verificção e feita     ³±±
±±³          ³ atraves do campo ENDNOT).                                         ³±±
±±³          ³ Caso seja do DF, ou ENDNOT = 'S', somente ira retornar o campo    ³±±
±±³          ³ Endereco (sem numero ou complemento). Caso contrario ira retornar ³±±
±±³          ³ o padrao do FisGetEnd                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Obs.     ³ Esta funcao so pode ser usada quando ha um posicionamento de      ³±±
±±³          ³ registro, pois será verificado o ENDNOT do registro corrente      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MyGetEnd(cEndereco,cAlias,cAlsQry)

Local cCmpEndN	:= SubStr(cAlias,2,2)+"_ENDNOT"
Local cCmpEst	:= SubStr(cAlias,2,2)+"_EST"
Local aRet		:= {"",0,"",""}

Default	cAlsQry	:=	""

//Tratamento para quando os campos base estiverem no select
If Empty(cAlsQry)
	cAlsQry	:=	cAlias
EndIf

//Campo ENDNOT indica que endereco participante mao esta no formato <logradouro>, <numero> <complemento>
//Se tiver com 'S' somente o campo de logradouro sera atualizado (numero sera SN)
If (&(cAlsQry+"->"+cCmpEst) == "DF") .Or. ((cAlias)->(FieldPos(cCmpEndN)) > 0 .And. &(cAlsQry+"->"+cCmpEndN) == "1")
	aRet[1] := cEndereco
	aRet[3] := "SN"
Else
	aRet := FisGetEnd(cEndereco,&(cAlsQry+"->"+cCmpEst))
EndIf

Return aRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RetStr    ³ Autor ³Gustavo G. Rueda       ³ Data ³16.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³  RECEBE, TRANSFORMA E RETORNA A STRING NO FORMATO EXIGIDO  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Transforma a string ou valor passado para o padrao exigido  ³±±
±±³          ³ pelo leyout.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³xRet -> A string ou valor no padrao do layout               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|xValor -> Conteudo a ser padronizado                        ³±±
±±³          ³nDec   -> Quantidade de decimais para valores numericos     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RetStr(xValor,nDec)
Local	xRet

If (ValType (xValor)=="N")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Todas as variaveis numericas que nao tiverem definicao de casas decimais     |
	//³serao convertidas para apresentarem 2 decimais                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (xValor==0)
		xRet	:=	"0"
	ElseIf nDec == NIL
		xRet	:=	AllTrim (StrTran (Str (xValor,,2), ".", ","))
	Else
		xRet	:=	AllTrim (StrTran (Str (xValor,,nDec), ".", ","))
	EndIf

ElseIf (ValType (xValor)=="C")
	xRet	:=	AllTrim (xValor)

ElseIf (ValType (xValor)=="D") .And. !Empty(xValor)
	xRet	:=	StrZero (Day(xValor),2)+StrZero(Month(xValor),2)+StrZero(Year(xValor),4)

Else
	xRet	:=	""

EndIf
Return(xRet)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³NoAcento  ³ Autor ³Gustavo G. Rueda       ³ Data ³22.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retira acentos das strings                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1 -> Retorna a string convertida                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cString -> String a ser convertida                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function NoAcento(cString)
Local cChar  := ""
Local nX     := 0
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
Local cTrema := "äëïöü"+"ÄËÏÖÜ"
Local cCrase := "àèìòù"+"ÀÈÌÒÙ"
Local cTio   := "ãõ"
Local cCecid := "çÇ"

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
		nY:= At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTio)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("ao",nY,1))
		EndIf
		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf
	Endif
Next
For nX:=1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	If Asc(cChar) < 32 .Or. Asc(cChar) > 123 .Or. cChar $ '&'
		cString:=StrTran(cString,cChar,".")
	Endif
Next nX
cString := _NoTags(cString)
Return cString

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³FSModeloP7| Autor ³Gustavo G. Rueda  			   ³ Data ³29.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Recupera as informacoes do registro de inventario Mod. P7 contidas³±±
±±³          ³ no arquivo temporario.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cArquivo - Nome do arquivo a ser importado                        ³±±
±±³          ³ nTipo    - Tipo de Saldo a Ser Considerado:                       ³±±
±±³          ³            1 - Saldo em Estoque                                   ³±±
±±³          ³            2 - Saldo em Processo                                  ³±±
±±³          ³            4 - Saldo De Terceiros                                 ³±±
±±³          ³            5 - Saldo Em Terceiros                                 ³±±
±±³          ³ aRetInv  - Array de retorno contendo as informacoes do Sped Fiscal³±±
±±³          ³            Array[n,1] - Codigo do produto                         ³±±
±±³          ³            Array[n,2] - Unidade de Medida                         ³±±
±±³          ³            Array[n,3] - Quantidade                                ³±±
±±³          ³            Array[n,4] - Valor Unitario                            ³±±
±±³          ³            Array[n,5] - Valor Total                               ³±±
±±³          ³            Array[n,6] - Cliente/Fornecedor                        ³±±
±±³          ³            Array[n,7] - Loja                                      ³±±
±±³                       Array[n,11] - Armazem                                  ³±±
±±³          ³lExtTaf   -> Indica que a chamada da funcao eh o Extrator   	    ³±±
±±³          ³			   TAF											         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FSModeloP7(cArquivo,nTipo,aRetInv,aWizard,lExtTaf)
	Local aAreaAnt := GetArea()
	Local cAlias   := ""
	Local cIndTmp1 := ""
	Local lAglH010 := aSPDSX6[MV_AGLH010]
	Local cProd	   := ""
	Local lArmazem := .F.
	Local nWiz     := 0
	Local nH

	Default cArquivo := ""
	Default nTipo    := ""
	Default aRetInv  := {}
	Default aWizard  := {}
	Default lExtTaf  := .F.

	If !lExtTaf
		nWiz := 4
	Else
		nWiz := 2
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico se o arquivo base da movimentacao foi passado para processamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cArquivo)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Somente os tipos permitidos³
	//³                           ³
	//³1 - Saldo em Estoque       ³
	//³2 - Saldo em Processo      ³
	//³4 - Saldo De Terceiros     ³
	//³5 - Saldo Em Terceiros     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nTipo==1 .Or. nTipo==2 .Or. nTipo==4 .Or. nTipo==5

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifico a existencia do arquivo gerado pelo MATR460³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nH := fopen(cArquivo+GetDBExtension() , 0 )
			If !nH == -1
				fclose(nH)

				If MSFile(cArquivo+GetDBExtension(),,__LocalDriver)

					cFiltro		:=	"SITUACAO=='"+Str(nTipo,1)+"'"
					cAlias   := GetNextAlias()
					cIndTmp1 := CriaTrab(Nil,.F.)
					dbUseArea(.T.,__LocalDriver,cArquivo,cAlias)

					If RecCount() > 0 .And. !Eof()
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Tratamento para comportar o processamento de muti-filiais³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !(cAlias)->(FieldPos("FILIAL"))>0
							Alert("Bloco H: Houveram mudanças no layout do relatório Modelo P7 referente ao processamento de filiais. Favor atualizar o repositório e gerar os arquivos novamente.")
						Else

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Monto o filtro do arquivo solicitado conforme tipo passado³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							IndRegua(cAlias,cIndTmp1,"FILIAL+PRODUTO+SITUACAO+CLIFOR+LOJA	",,cFiltro)
							dbClearIndex()
							dbSetIndex(cIndTmp1+OrdBagExt())
							dbSetOrder(1)

							lArmazem := (cAlias)->(Fieldpos("ARMAZEM")) > 0

							While !(cAlias)->(Eof())

								cProd	 :=	PadR(Alltrim((cAlias)->PRODUTO),TamSX3("B1_COD")[1])

								If Len(aWizard) > 0
									If lArmazem
										cArmazen := PadR(Alltrim((cAlias)->ARMAZEM),TamSX3("B1_LOCPAD")[1])
										If (!Empty(aWizard[nWiz][1]+aWizard[nWiz][2]) .And. ;
												(cProd < aWizard[nWiz][1] .Or. cProd > aWizard[nWiz][2])) .Or. ;
												(!Empty(aWizard[nWiz][3]+aWizard[nWiz][4]) .And. ;
												(cArmazen < aWizard[nWiz][3] .Or. cArmazen > aWizard[nWiz][4]))
											(cAlias)->(dbSkip())
											Loop
										EndIf
									Else
										SB1->(DbSetOrder(1))
										SB1->(MsSeek(xFilial("SB1")+cProd))
										If (!Empty(aWizard[nWiz][1]+aWizard[nWiz][2]) .And. ;
												(cProd < aWizard[nWiz][1] .Or. cProd > aWizard[nWiz][2])) .Or. ;
												(!Empty(aWizard[nWiz][3]+aWizard[nWiz][4]) .And. ;
												(SB1->B1_LOCPAD < aWizard[nWiz][3] .Or. SB1->B1_LOCPAD > aWizard[nWiz][4]))
											(cAlias)->(dbSkip())
											Loop
										EndIf
									EndIf
								EndIf

									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Efetuo o processamento do arquivo solicitado conforme tipo passado³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If 	lAglH010 .And.;
										((cAlias)->SITUACAO == "4" .Or. (cAlias)->SITUACAO == "5") .And.;
										aScan(aRetInv,{|x|x[1] == cProd}) > 0

									nPos := Ascan(aRetInv,{|x|x[1] == (cAlias)->PRODUTO})
									aRetInv[nPos][3] += (cAlias)->QUANTIDADE
									aRetInv[nPos][4] += (cAlias)->VALOR_UNIT
									aRetInv[nPos][5] += (cAlias)->TOTAL
								Else
									aAdd(aRetInv,{cProd,;				// 01 - Produto.
									(cAlias)->UM,;         // 02 - Unidade.
									(cAlias)->QUANTIDADE,; // 03 - Quantidade.
									(cAlias)->VALOR_UNIT,; // 04 - Valor Unidade.
									(cAlias)->TOTAL,;      // 05 - Valor Total.
									(cAlias)->CLIFOR,;     // 06 - Codigo do Cliente/Fornecedor.
									(cAlias)->LOJA,;       // 07 - Codigo da loja Cliente/Fornecedor.
									(cAlias)->SITUACAO,;   // 08 - Situacao do estoque.
									(cAlias)->TPCF,;       // 09 - Cliente/Fornecedor.
									(cAlias)->FILIAL,;		// 10 - Filial.
									(cAlias)->ARMAZEM})		// 11 - Armazem.
								EndIF
								(cAlias)->(dbSkip())
							End

						EndIf
				EndIf
			Else

				MsgInfo("O arquivo " + cArquivo+GetDBExtension()+", esta em uso, portanto a geração dos registros relacionados ao Inventario, ";
					+ "poderão ser gerados sem as informações corretaas. Para correção, verifique o nome do arquivo informado no ";
				    + "campo: Nome arq. Gerado no Reg. Inv. Mod.7, ";
					+ "encontrado na tela 5 da Wizard de geração do SPEDFISCAL. Erro de abertura : FERROR "+str(ferror(),4))
				fclose(nH)
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Fecho o alias criado para o arquivo de trabalho³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Select(cAlias) > 0
				(cAlias)->(dbCloseArea())
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaAnt)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SPEDOpenEn³ Autor ³Gustavo G. Rueda       ³ Data ³31.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de inicializacao de ambiente de processamento.       ³±±
±±³          ³Abre todas as tabelas a serem utilizadas e valida os campos ³±±
±±³          ³ criados pelo UPDFIS                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lTabComp -> Flag de existencias das tabelas de complementos ³±±
±±³          ³lTabCDT  -> Flag de existencia da tabela CDT                ³±±
±±³          ³lTabCD0  -> Flag de existencia da tabela CD0                ³±±
±±³          ³lIntTMS  -> Flag como retorno da funcao INTTMS()            ³±±
±±³          ³lCmpsVld -> Flag de validacao dos campos criados pelo UPDFIS³±±
±±³          ³lTabCE5  -> Flag de existencia da tabela CE5                ³±±
±±³          ³lTabCD1  -> Flag de existencia da tabela CD1                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPEDOpenEnv(lTabComp,lTabCDT,lTabCD0,lIntTMS,lCmpsVld,lTabCE5,lTabCD1,lTabF0A)
Local	nX			:=	0
Local	cAlsUpd		:=	""
Local	cCmpUpd		:=	""
Local	cCmpsNaoEx	:=	""
Local	aCmpsUpd	:=	{"SF4->F4_VLAGREG",	"SFT->FT_CSTPIS",	"SFT->FT_CSTCOF",	"SF6->F6_AUTENT",	"SFT->FT_CHVNFE",	"CD5->CD5_ACDRAW",;
				   		"CD6->CD6_UFPLAC",	"SF4->F4_MOVFIS",	"SF4->F4_CSOSN",	"SFT->FT_PAUTPIS",	"SFT->FT_PAUTCOF",	"SFT->FT_PAUTIPI",;
				   		"SFU->FU_GRUPT",	"SFU->FU_TIPLIGA",	"SFU->FU_CLASSIF",	"SFX->FX_TPASSIN",	"SF9->F9_QTDPARC",	"SF9->F9_SLDPARC",;
				   		"SFA->FA_TOTSAI",	"SFA->FA_TOTTRIB",	"CDL->CDL_DOCORI",	"CDL->CDL_SERORI",	"CDL->CDL_NFEXP",	"CDL->CDL_SEREXP",;
				   		"CDL->CDL_ESPEXP",	"CDL->CDL_EMIEXP",	"CDL->CDL_CHVEXP",	"CDL->CDL_QTDEXP",	"CDL->CDL_FORNEC",	"CDL->CDL_LOJFOR",;
				   		"SF3->F3_CHVNFE",	"SFU->FU_GRUPT",	"SA4->A4_COD_MUN",	"SA1->A1_REGPB",	"SA4->A4_SUFRAMA",	"SF3->F3_CODRSEF",;
				   		"SF9->F9_ITEMNFS",	"SFT->FT_RGESPST",	"CDH->CDH_GNREF3",	"SF6->F6_NUMPROC",	"SF6->F6_INDPROC",	"SF6->F6_DESCOMP",;
				   		"SA1->A1_SIMPNAC",	"SA2->A2_SIMPNAC", 	"SF4->F4_COMPONE", 	"SF9->F9_TIPO", 	"SF9->F9_CODBAIX",  "CC6->CC6_CLANAP",;
				   		"CDA->CDA_IFCOMP",	"CC7->CC7_IFCOMP",	"SF3->F3_CLASCO",	"SF1->F1_TPCTE", 	"SF4->F4_CODOBSE",  "CDT->CDT_SITEXT",;
				   		"CDT->CDT_DTAREC",  "CDL->CDL_ITEMNF",  "CDL->CDL_PRODNF",  "CDL->CDL_ITEORI",  "CDL->CDL_PRDORI", "SF4->F4_CONSUMO",;
				   		"SFT->FT_NATOPER"}

lTabCDT		:= 	aSPDSX2[AI_CDT]
lTabCD0		:=	aSPDSX2[AI_CD0]
lTabCD1		:=	aSPDSX2[AI_CD1]
lTabCE5		:=	aSPDSX2[AI_CE5] .And. aSPDSX2[AI_CE6] .And. aSPDSX2[AI_CE7]
lIntTMS		:=	IntTms()
lCmpsVld	:=	.T.
lTabComp	:=  .T.
lTabF0A		:=	aSPDSX2[AI_F0A]

IF lTabCD1
	aAdd(aCmpsUpd,"CD1->CD1_FILIAL")
 	aAdd(aCmpsUpd,"CD1->CD1_CODNAT")
  	aAdd(aCmpsUpd,"CD1->CD1_DESCR")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³DEFINICAO DE ORDEM DAS TABELAS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea ("SFT")	//Livro Fiscal por item
SFT->(DbSetOrder (1))
DbSelectArea ("SX5")	//Tabelas Genericas
SX5->(DbSetOrder (1))
DbSelectArea ("SA1")	//Cadastro do Cliente/Fornecedor
SA1->(DbSetOrder (1))
DbSelectArea ("SA2")	//Cadastro do Cliente/Fornecedor
SA2->(DbSetOrder (1))
DbSelectArea ("SA4")	//Cadastro do Transportadoras
SA4->(DbSetOrder (1))
DbSelectArea ("SF1")	//Cabecalho das Notas Fiscais de Entrada/Saida
SF1->(DbSetOrder (1))
DbSelectArea ("SF2")	//Cabecalho das Notas Fiscais de Entrada/Saida
SF2->(DbSetOrder (1))
DbSelectArea ("SF3")	//Posicionando Livros Fiscais
SF3->(DbSetOrder (1))
DbSelectArea ("SF4")	//Cadastro de TES
SF4->(DbSetOrder (1))
DbSelectArea ("SF6")	//GNRE
SF6->(DbSetOrder (1))
DbSelectArea ("SD1")	//Itens das NF´s de Entrada
SD1->(DbSetOrder (1))
DbSelectArea ("SD2")	//Itens das NF´s de Saida
SD2->(DbSetOrder (3))
DbSelectArea ("SB1")	//Cadastro de Produtos
SB1->(DbSetOrder (1))
DbSelectArea ("SB5")	//Complemento de Produto
SB5->(DbSetOrder (1))
DbSelectArea ("SB8")	//Saldos por Lote
SB8->(DbSetOrder (3))
DbSelectArea ("SAH")	//Unidades de Medida
SAH->(DbSetOrder (1))
DbSelectArea ("SX6")
SX6->(DbSetOrder (1))
dbSelectArea("SFA")     //Apropriacoes CIAP
SFA->(dbSetOrder(1))
dbSelectArea("SF9")     //Cadastro CIAP
SF9->(dbSetOrder(1))

If lTabF0A
	DbSelectArea ("F0A")	//Complemento de Rastro
	F0A->(DbSetOrder (1))
EndIf

If lTabComp
	DbSelectArea ("CC6")	//Lançamentos de apuração de ICMS
	CC6->(DbSetOrder (1))
	DbSelectArea ("CD3")	//Complemento de Gas
	CD3->(DbSetOrder (1))
	DbSelectArea ("CD4")	//Complemento de Agua Canalizada
	CD4->(DbSetOrder (1))
	DbSelectArea ("CD5")	//Complemento de Importação
	CD5->(DbSetOrder (1))
	DbSelectArea ("CD6")	//Complemento de Combustiveis
	CD6->(DbSetOrder (1))
	DbSelectArea ("CD7")	//Complemento de Medicamentos
	CD7->(DbSetOrder (1))
	DbSelectArea ("CD8")	//Complemento de Armas de Fogo
	CD8->(DbSetOrder (1))
	DbSelectArea ("CD9")	//Complemento de Veiculo Automotor
	CD9->(DbSetOrder (1))
	DbSelectArea ("CDA")	//Lancamentos de apuracao por Documento Fiscal
	CDA->(DbSetOrder (1))
	DbSelectArea ("CDH")	//Arquivo de apuracoes de ICMS
	CDH->(DbSetOrder (1))
	DbSelectArea ("CDG")	//Processos referenciados no documento
	CDG->(DbSetOrder (1))
	DbSelectArea ("CDC")	//Guias de Recolhimento Referenciada no documento
	CDC->(DbSetOrder (1))
	DbSelectArea ("CDD")	//Documentos Referenciados
	CDD->(DbSetOrder (1))
	DbSelectArea ("CDE")	//Cupom Fiscal Referenciado
	CDE->(DbSetOrder (1))
	DbSelectArea ("CDF")	//Local de Coleta Entrega
	CDF->(DbSetOrder (1))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso o campo CDL_ITEMNF exista no banco de dados deve ser utilizado na composicao      ³
	//³da ordem de exibicao dos registros devido a implementacao da amarracao do documento de ³
	//³exportacao ao item da nota fiscal                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea ("CDL")	//Complemento de Exportacao
 	SIX->(DbSetOrder(1))
    If SIX->(DbSeek("CDL2"))
		CDL->(DbSetOrder(2))
    Else
	   	CDL->(DbSetOrder(1))
    EndIf
	DbSelectArea ("CCE")	//Informacoes Complementares
	CCE->(DbSetOrder (1))
	DbSelectArea ("SFU")	//Informacoes complementares das NF de Energia Eletrica
	SFU->(DbSetOrder (1))
	DbSelectArea ("SFX")	//Informacoes complementares das NF de Comunicacao/Telecomunicacao
	SFX->(DbSetOrder (1))
	If aSPDSX2[AI_CDO]
		DbSelectArea ("CDO")//Ajustes manuais de apuração de ICMS
		CDO->(DbSetOrder (1))
	EndIf
	If aSPDSX2[AI_CDP]
		DbSelectArea ("CDP")//Tabela da apuração de IPI
		CDP->(DbSetOrder(1))
	EndIf
	If aSPDSX2[AI_CCK]
		DbSelectArea ("CCK")//Ajustes da apuração de IPI
		CCK->(DbSetOrder (1))
	EndIf
EndIf
If aSPDSX2[AI_AIF]
	DbSelectArea ("AIF")	//Historico de ALteracoes SA1/SA2/SB1
	AIF->(DbSetOrder (1))
EndIf

If lIntTMS
	DbSelectArea ("DT6")	//Documentos de Transporte
	DT6->(DbSetOrder (1))
	DbSelectArea ("DTC")	//Notas Fiscais do Cliente
	DTC->(DbSetOrder (3))
	DbSelectArea ("DUD")	//Movimento da Viagem
	DUD->(DbSetOrder (1))
	DbSelectArea ("DTQ")	//Viagem
	DTQ->(DbSetOrder (2))
	DbSelectArea ("DTR")	//Veiculos da viagem
	DTR->(DbSetOrder (1))
	DbSelectArea ("DT8")	//Composicao do frete
	DT8->(DbSetOrder (2))
	DbSelectArea ("DUY")	//Grupos de Regioes
	DUY->(DbSetOrder(1))
EndIf

DbSelectArea ("DA3")	//Cadastro de Veiculos
DA3->(DbSetOrder (1))
DbSelectArea ("DB2")	//Aviso de recebimento de carga
DB2->(DbSetOrder (1))
DbSelectArea ("DB1")	//Cabecalho do documento de recebimento
DB1->(DbSetOrder (1))
DbSelectArea ("DB3")	//Itens do documento de recebimento
DB3->(DbSetOrder (1))
DbSelectArea("SC7")		//Pedido de Compra
SC7->(DbSetOrder(1))
DbselectArea("SC5")		//Pedido de venda
SC5->(DbSetOrder(1))
DbselectArea("SN1")		//Cadastro Ativo
SN1->(DbSetOrder(4))
DbselectArea("SN3")		//Ativo X Classificacao
SN3->(DbSetOrder(1))

If lTabCE5
	DbSelectArea("CE5")		//Controle de Crédito de ICMS
	CE5->(DbSetOrder(2))
	DbSelectArea("CE6")		//Saldo de Crédito de ICMS
	CE6->(DbSetOrder(1))
Endif

If CtbInUse()
	dbSelectArea("CT1")		//Cadastro de conta contabil quando CTB
	CT1->(dbSetOrder(1))
	dbSelectArea("CTT")		//Cadastro de centro de custo quando CTB
	CTT->(dbSetOrder(1))
Else
	dbSelectArea("SI1")		//Cadastro de conta contabil quando SIGACON
	SI1->(dbSetOrder(1))
	dbSelectArea("SI3") 	//Cadastro de centro de custo quando SIGACON
	SI3->(dbSetOrder(1))
EndIf

If lTabCD0
	dbSelectarea("CD0")	//Complemento de ressarcimento
	dbSetOrder(1)
EndIF

If lTabCD1
	dbSelectarea("CD1")	//Natureza da Operacao/Prestacao
	dbSetOrder(1)
EndIF

If aSPDSX2[AI_CDV]
	DbSelectArea("CDV")		//Informacoes adicionais a Apuracao de ICMS
	CDV->(DbSetOrder(1))
EndIf

dbSelectArea("SLG")
SLG->(dbSetOrder(1))

dbSelectArea("SFI")
If SIX->(dbSeek("SFI"+"3"))
	SFI->(DbSetorder(3))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³TODOS OS CAMPOS NOVOS DEVEM ESTAR NESTA CONDICAO E DEVEM SER TRATADOS EXISTINDO OU³
//³         NAO NA BASE DE DADOS, DEVE TER UM CONTEUDO PADRAO CASO NAO EXISTA        ³
//³                                                                                  ³
//³Flag de existencia dos campos criados pelo UPDFIS e que sao utilizados pela rotina³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aCmpsUpd)
	cAlsUpd	:=	AllTrim(SubStr(aCmpsUpd[nX],1,3))
	cCmpUpd	:=	AllTrim(SubStr(aCmpsUpd[nX],6))

	If (cAlsUpd)->(FieldPos(cCmpUpd))==0
		cCmpsNaoEx	+=	cAlsUpd+"->"+cCmpUpd+", "
	EndIf
Next nX
cCmpsNaoEx	:=	Iif(!Empty(cCmpsNaoEx),Left(cCmpsNaoEx, Len(cCmpsNaoEx)-2),cCmpsNaoEx)
lCmpsVld	:=	Empty(cCmpsNaoEx)

Return cCmpsNaoEx

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SPEDSeek  | Autor ³Gustavo G. Rueda 			   ³ Data ³02.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao de posicionamento de tabelas especifica para o SPED Fiscal. ³±±
±±³          ³ Onde ora posiciono pelo RECNO e ora pelo Seek.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias - Alias da tabela que serah efetuado o posicionamento      ³±±
±±³          ³ nOrder - Ordem da tabela que serah utilizada para posicionamento. ³±±
±±³          ³ cSeek  - Chave de seek para a ordem selecionada. (QUANDO FOR EFE- ³±±
±±³          ³          TUAR O MSSEEK)                                           ³±±
±±³          ³ nRecno - RECNO da tabela em caso de DBGOTO()                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPEDSeek(cAlias,nOrder,cSeek,nRecno)
Local	lRet		:=	.F.
Local	lTop		:=	.F.
Local	lProcSeek	:=	.T.

Default	nOrder	:=	0

#IFDEF TOP
	If lNotAs400
		lTop 		:= 	.T.
		lProcSeek	:=	.F.
	Endif
#ENDIF

If lTop
	If nRecno<>Nil .And. nRecno>0
		If (cAlias)->(Recno())<>nRecno
			(cAlias)->(dbGoTo(nRecno))
		EndIf
		lRet	:=	.T.

	ElseIf nRecno==Nil
		lProcSeek	:=	.T.
	EndIf
EndIf

If lProcSeek .And. cSeek<>Nil
	If nOrder==0
		nOrder	:=	(cAlias)->(IndexOrd())
	EndIf

	(cAlias)->(dbSetOrder(nOrder))

	lRet	:=	(cAlias)->(MSSeek(cSeek))
EndIf

Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |SPEDGrvLin³ Autor ³Gustavo G. Rueda       ³ Data ³16.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³      GRAVACAO DE UM REGISTRO E MARCA COMO GRAVADO          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Gravo o registro posicionado do TRB e marco ele como ja gra-³±±
±±³          ³ vado evitanto duplicidade.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|nHandle -> Handle do arquivo txt aberto.                    ³±±
±±³          |cAlias -> Alias do TRB criado atraves da funcao principal.  ³±±
±±³          |cTpReg -> Tipo de registro que compoe a chave de pesquisa.  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPEDGrvLin(nHandle, cAlias)
	Local	cConteudo := AllTrim ((cAlias)->TRB_CONT)+Chr (13)+Chr (10)	//+"**"+(cAlias)->TRB_RELAC+"**"

	FWrite (nHandle, cConteudo, Len (cConteudo))

	RecLock(cAlias, .F.)
		(cAlias)->TRB_FLAG	:=	"*"
	MsUnLock ()
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SPEDQryPri| Autor ³Gustavo G. Rueda  			   ³ Data ³24.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao que retorna o valor de reducao da base de calculo do ICMS   ³±±
±±³          ³ utilizando a regra convencional (SENTO/OUTROS/BASE) ou recalcu-   ³±±
±±³          ³ conforme percentual de reducao gravada na tabela CD2              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                   ³±±
±±³          ³cTpMov    -> Tipo de movimentacao, E=Entrada, S=Saida              ³±±
±±³          ³dDataDe   -> Data inicial do periodo                               ³±±
±±³          ³dDataAte  -> Data final do periodo                                 ³±±
±±³          ³aF2EspVol -> Array com os campos da tabela F2 de volume/especie    ³±±
±±³          ³lTabComp  -> Flag de existencia das tabelas do SPED Fiscal         ³±±
±±³          ³lIntTMS   -> Flag que identifica a integracao com o TMS            ³±±
±±³          ³cNrLivro  -> Numero do livro de processamento selecionado no wizard³±±
±±³          ³cAliasSFT -> Alias da tabela SFT a ser retornada por referencia    ³±±
±±³          ³lTabCD0   -> Flag de existencia da tabela CD0 - Compl Ressarcimento³±±
±±³          ³lTabCD1   -> Flag de existencia da tabela CD1 - Natureza Oper/Prest³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1 - 0=Nao tem movimento e maior que ZERO identifica com movimto³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPEDQryPri(NaoUsar,cTpMov,dDataDe,dDataAte,aF2EspVol,lTabComp,lIntTMS,cNrLivro,cAliasSFT,lTabCD1)
Local cFiltro := ""
Local cSlctSFT := ""
Local cSlctSF3 := ""
Local cSlctF1F2 := ""
Local cScan := "1"
Local cSlctD1D2 := ""
Local cSlctSB1 := ""
Local cSlctSB5 := ""
Local cSlctA1 := ""
Local cSlctA2 := ""
Local cSlctA4 := ""
Local cSlctF4 := ""
Local cSlct := ""
Local cSlctAll := ""
Local cSlctGIC := ""
Local cSlctGZU := ""
Local cSlctCII := ""
Local cJoinF3 := ""
Local cJoinD1D2 := ""
Local cJoinF1F2 := ""
Local cJoinSF4 := ""
Local cJoinSA4 := ""
Local cJoinCII := ""
Local cJoinCompl := ""
Local cJoinGICGZU  := ""
Local cOrderBy := "%%"
Local cMVDTINCB1 := AllTrim(aSPDSX6[MV_DTINCB1])
Local cPRDPRIB5 := AllTrim(aSPDSX6[MV_PRDPRI])
Local aFieldDt := {}
Local nX := 0
Local cApurSep := Alltrim(aSPDSX6[MV_APUSEP])
Local aApurSep := {}
Local nPos := 0
Local cApur := ""
Local cMvD310MUN := Alltrim(aSPDSX6[MV_D310MUN])
Local cCliDvMc := ""
Local lTabF0A := aSPDSX2[AI_F0A]
Local cPDVEmpty := Space(TamSX3("FT_PDV")[1])
Local lDadosGTP := cTpMov == "S" .And. aSPDSX6[MV_INTGTP] == "1" .And. aSPDSX2[AI_GIC] .And. aSPDSX2[AI_GZU]
Local cTipoDB	:= AllTrim(Upper(TcGetDb()))// Tipo do banco de dados

For nPos := 1 to Len(cApurSep)
	cApur := Substr(cApurSep,nPos,1)
	If cApur$"123456789" .And. aScan(aApurSep, {|x| x==cApur})==0
		aAdd(aApurSep, cApur)
	EndIf
Next nPos

DbSelectArea (cAliasSFT)
(cAliasSFT)->(DbSetOrder(2))

#IFDEF TOP
	If lNotAs400
		cFiltro := "%"
		If cNrLivro <> "*"
			If Len(aApurSep)>0
				cFiltro += " ( "
				For nX := 1 To Len(aApurSep)
					cFiltro += " SFT.FT_NRLIVRO = '" +%Exp:(aApurSep[nX])% +"' OR "
				Next nX
				cFiltro += " SFT.FT_NRLIVRO = '" +%Exp:(cNrLivro)% +"' ) AND "
			Else
				cFiltro += " SFT.FT_NRLIVRO = '" +%Exp:(cNrLivro)% +"' AND "
			EndIf
		EndIf
		cFiltro += "%"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Campos da tabela SFT³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSlctSFT := "SFT.FT_FILIAL,  SFT.FT_TIPOMOV, SFT.FT_ENTRADA, SFT.FT_SERIE,   SFT.FT_NFISCAL, SFT.FT_CLIEFOR,"
		cSlctSFT += "SFT.FT_LOJA,    SFT.FT_ITEM,    SFT.FT_PRODUTO, SFT.FT_NRLIVRO, SFT.FT_CFOP,    SFT.FT_ESPECIE, "
		cSlctSFT += "SFT.FT_TIPO,    SFT.FT_EMISSAO, SFT.FT_DTCANC,  SFT.FT_FORMUL,  SFT.FT_ALIQPIS, SFT.FT_VALPIS, "
		cSlctSFT += "SFT.FT_ALIQCOF, SFT.FT_VALCOF,  SFT.FT_VALCONT, SFT.FT_BASEICM, SFT.FT_VALICM,  SFT.FT_ISSST, "
		cSlctSFT += "SFT.FT_BASERET, SFT.FT_ICMSRET, SFT.FT_VALIPI,  SFT.FT_ISENICM, SFT.FT_QUANT,   SFT.FT_DESCONT, "
		cSlctSFT += "SFT.FT_TOTAL,   SFT.FT_FRETE,   SFT.FT_SEGURO,  SFT.FT_DESPESA, SFT.FT_OUTRICM, SFT.FT_BASEIPI, "
		cSlctSFT += "SFT.FT_ISENIPI, SFT.FT_OUTRIPI, SFT.FT_ICMSCOM, SFT.FT_RECISS,  SFT.FT_BASEIRR, SFT.FT_ALIQICM, "
		cSlctSFT += "SFT.FT_ALIQIPI, SFT.FT_CTIPI,   SFT.FT_POSIPI,  SFT.FT_CLASFIS, SFT.FT_PRCUNIT, SFT.FT_CFPS, "
		cSlctSFT += "SFT.FT_OBSERV,  SFT.FT_ESTADO,  SFT.FT_CODISS,  SFT.FT_ALIQIRR, SFT.FT_VALIRR,  SFT.FT_BASEINS, "
		cSlctSFT += "SFT.FT_VALINS,  SFT.FT_PDV,     SFT.FT_ISSSUB,  SFT.FT_CREDST,  SFT.FT_ISENRET, SFT.FT_OUTRRET, "
		cSlctSFT += "SFT.FT_CONTA,   SFT.FT_BASEPIS, SFT.FT_BASECOF, SFT.FT_PESO,    SFT.FT_SOLTRIB, SFT.FT_NFORI, "
		cSlctSFT += "SFT.FT_SERORI,  SFT.FT_ITEMORI, SFT.FT_IDENTF3, SFT.FT_OBSSOL,  SFT.FT_FORMULA, SFT.FT_CLIENT,  SFT.FT_LOJENT, "
		cSlctSFT += "SFT.FT_VALFECP, SFT.FT_ALQFECP, SFT.FT_VFECPST, SFT.FT_CSTPIS,  SFT.FT_CSTCOF,  SFT.FT_PAUTPIS, SFT.FT_PAUTCOF, "
		cSlctSFT += "SFT.FT_CHVNFE,  SFT.FT_VALPS3,  SFT.FT_VALCF3,  SFT.FT_RGESPST, SFT.FT_PAUTIPI, SFT.FT_DESCZFR, SFT.FT_AGREG, "
		cSlctSFT += "SFT.FT_DESCICM, SFT.FT_NORESP, SFT.FT_NATOPER, SFT.FT_MVALCOF, SFT.FT_MALQCOF, SFT.FT_ALIQSOL, SFT.FT_TPPRODE, SFT.FT_CPPRODE, "
		cSlctSFT += "SFT.FT_ISSMAT, SFT.FT_ISSSUB "

		If SerieNfId("SFT",3,"FT_SERIE") == "FT_SDOC"
			cSlctSFT += ", SFT.FT_SDOC"
		EndIf
		//--UpdFis - Serie SAT - 16/09/2015
		If aSPDSX3[FP_FT_SERSAT]
			cSlctSFT += ", SFT.FT_SERSAT"
		Endif
		//--UpdFis - Difal - 23/12/2015
		If aSPDSX3[FP_FT_DIFAL]
			cSlctSFT += ", SFT.FT_DIFAL"
		Endif
		//--UpdFis - FECP Des. - 23/12/2015
		If aSPDSX3[FP_FT_VFCPDIF]
			cSlctSFT += ", SFT.FT_VFCPDIF"
		Endif
		//--UpdFis - Cod.Sit.Oper.ICMS.SimpNac - 05/07/2016
		If aSPDSX3[FP_FT_CSOSN]
			cSlctSFT += ", SFT.FT_CSOSN"
		Endif
		//--UpdFis - Perc.Difal Dest. - 23/12/2015
		If aSPDSX3[FP_FT_PDDES]
			cSlctSFT += ", SFT.FT_PDDES"
		Endif
		If aSPDSX3[FP_FT_COLVDIF]
			cSlctSFT += ", SFT.FT_COLVDIF"
		Endif
		If aSPDSX3[FP_FT_ICMSDIF]
			cSlctSFT += ", SFT.FT_ICMSDIF"
		Endif

		If aSPDSX3[FP_FT_TES]
			cSlctSFT += ", SFT.FT_TES"
		Endif
		If aSPDSX3[FP_FT_INFITEM]
			cSlctSFT += ", SFT.FT_INFITEM"
		Endif

		If aSPDSX3[FP_FT_VFCPANT]
			cSlctSFT += " ,SFT.FT_VFCPANT"
		Endif

		If aSPDSX3[FP_FT_DESCFIS]
			cSlctSFT += " ,SFT.FT_DESCFIS"
		Endif

		If aSPDSX3[FP_FT_CLIDVMC] .And. aSPDSX3[FP_FT_LOJDVMC]
			cSlctSFT += ", SFT.FT_CLIDVMC, SFT.FT_LOJDVMC"
			cCliDvMc := "CASE WHEN SFT.FT_CLIDVMC<>'" + Space(TamSx3("FT_CLIDVMC")[1]) + "' THEN SFT.FT_CLIDVMC ELSE SFT.FT_CLIEFOR END AND SA1.A1_LOJA = CASE WHEN SFT.FT_LOJDVMC<>'" + Space(TamSx3("FT_LOJDVMC")[1]) + "' THEN SFT.FT_LOJDVMC ELSE SFT.FT_LOJA END"
		Else
			cCliDvMc := 'SFT.FT_CLIEFOR AND SA1.A1_LOJA=SFT.FT_LOJA'
		Endif

		aAdd(aFieldDt,"FT_EMISSAO")
		aAdd(aFieldDt,"FT_ENTRADA")
		aAdd(aFieldDt,"FT_DTCANC")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Campos para o SELECT da tabela SB1³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSlctSB1 := "SB1.B1_UM,      SB1.B1_SELO,    SB1.B1_TAB_IPI, SB1.B1_VLR_IPI, SB1.B1_TIPO,   SB1.B1_DESC, "
		cSlctSB1 += "SB1.B1_CODBAR,  SB1.B1_CODANT,  SB1.B1_POSIPI,  SB1.B1_EX_NCM,  SB1.B1_CODISS, SB1.B1_PICM, "
		cSlctSB1 += "SB1.B1_FECP,    SB1.B1_CC,      SB1.B1_SEGUM,   SB1.B1_TIPCONV, SB1.B1_CONV,   SB1.B1_VLR_PIS, "
		cSlctSB1 += "SB1.B1_VLR_COF, SB1.B1_CLASSE,  SB1.B1_CONTA,   SB1.B1_ORIGEM,  SB1.B1_IMPORT, SB1.B1_DATREF, SB1.B1_COD, "
		cSlctSB1 += "SB1.B1_MEPLES"
		If aSPDSX3[FP_B1_CODGTIN]
			cSlctSB1 += ", SB1.B1_CODGTIN"
		Endif
		//--UpdFis - Cod.Espec.ST - 13/11/2015
		If aSPDSX3[FP_B1_CEST]
			cSlctSB1 += ",SB1.B1_CEST"
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para um campo da tabela SB1 que podera ser utilizado no processamento, ³
		//³  este campo deve estar na query                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If "B1_"$cMVDTINCB1
			If SB1->(FieldPos(cMVDTINCB1))>0 .And. !cMVDTINCB1$cSlctSB1
				cSlctSB1 += "," + cMVDTINCB1
				aAdd(aFieldDt,cMVDTINCB1)
			EndIf
		EndIf

		If !Empty(cPRDPRIB5)
			If SB5->(FieldPos(cPRDPRIB5))>0
				cSlctSB5 += "SB5." + cPRDPRIB5+","
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Campos para o SELECT da tabela SF2 ou SF1³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aF2EspVol := {}
		cSlctF1F2 := ""
		If cTpMov=="E"
			cSlctF1F2 += "SF1.F1_FRETE, SF1.F1_COND, SF1.F1_TIPO, SF1.F1_FORMUL, SF1.F1_ESPECIE, SF1.F1_DOC, SF1.F1_SERIE, "
			cSlctF1F2 += "SF1.F1_FORNECE, SF1.F1_LOJA, SF1.F1_EMISSAO, SF1.F1_PREFIXO, SF1.F1_DUPL, SF1.F1_CHVNFE, SF1.F1_HAWB "
			If aSPDSX3[FP_F1_TRANSP]
				cSlctF1F2 += ", SF1.F1_TRANSP "
			EndIf
			If aSPDSX3[FP_F1_TPFRETE]
				cSlctF1F2 += ", SF1.F1_TPFRETE "
			EndIf
			If aSPDSX3[FP_F1_TPCTE]
				cSlctF1F2 += ", SF1.F1_TPCTE "
			EndIf
			If aSPDSX3[FP_F1_MENNOTA]
				cSlctF1F2 += ", SF1.F1_MENNOTA "
			EndIf
			If aSPDSX3[FP_F1_UFORITR] .And. aSPDSX3[FP_F1_UFDESTR] .And. aSPDSX3[FP_F1_MUORITR] .And. aSPDSX3[FP_F1_MUDESTR]
				cSlctF1F2 += ", SF1.F1_UFORITR, SF1.F1_UFDESTR, SF1.F1_MUORITR, SF1.F1_MUDESTR "
			EndIf
			If aSPDSX3[FP_F1_SUBSERI]
				cSlctF1F2 += ", SF1.F1_SUBSERI "
			EndIf
			If aSPDSX3[FP_F1_ESTPRES] .And. aSPDSX3[FP_F1_INCISS]
				cSlctF1F2 += ", SF1.F1_ESTPRES, SF1.F1_INCISS "
			EndIf
		Else
			cSlctF1F2 += "SF2.F2_FRETE, SF2.F2_COND, SF2.F2_TIPO, SF2.F2_FORMUL, SF2.F2_ESPECIE, SF2.F2_EMISSAO, SF2.F2_CLIENTE, "
			cSlctF1F2 += "SF2.F2_LOJA, SF2.F2_NFCUPOM, SF2.F2_PDV, SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_TRANSP, SF2.F2_VEICUL1, "
			cSlctF1F2 += "SF2.F2_VEICUL2, SF2.F2_VEICUL3, SF2.F2_PBRUTO, SF2.F2_PLIQUI, SF2.F2_PREFIXO, SF2.F2_DUPL, SF2.F2_ECF, "
			cSlctF1F2 += "SF2.F2_VALPIS, SF2.F2_VALCOFI, SF2.F2_FILIAL, SF2.F2_CHVNFE"
			If aSPDSX3[FP_F2_MENNOTA]
				cSlctF1F2 += ", SF2.F2_MENNOTA"
			EndIf
			If aSPDSX3[FP_F2_ESTPRES] .And. aSPDSX3[FP_F2_MUNPRES]
				cSlctF1F2 += ", SF2.F2_ESTPRES, SF2.F2_MUNPRES "
			EndIf
			If aSPDSX3[FP_F2_CMUNOR] .And. aSPDSX3[FP_F2_UFORIG]
				cSlctF1F2 += ", SF2.F2_CMUNOR, SF2.F2_UFORIG"
			EndIf
			If  aSPDSX3[FP_F2_UFDEST]  .And. aSPDSX3[FP_F2_CMUNDE]
				cSlctF1F2 += ", SF2.F2_UFDEST, SF2.F2_CMUNDE "
			EndIf
			If  aSPDSX3[FP_F2_CLIREM]  .And. aSPDSX3[FP_F2_LOJAREM]
				cSlctF1F2 += ", SF2.F2_CLIREM, SF2.F2_LOJAREM "
			EndIf

			cScan := "1"
			While SF2->(FieldPos("F2_ESPECI"+cScan))>0 .Or. SF2->(FieldPos("F2_VOLUME"+cScan))>0
				If SF2->(FieldPos("F2_ESPECI"+cScan))>0
					cSlctF1F2 += ",F2_ESPECI"+cScan
				EndIf
				If SF2->(FieldPos("F2_VOLUME"+cScan))>0
					cSlctF1F2 += ",F2_VOLUME"+cScan
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Campos de volume utilizado no registro C160 e que estarao na query³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd(aF2EspVol,{"F2_ESPECI"+cScan,,"F2_VOLUME"+cScan,})
				cScan := Soma1(cScan,1)
			EndDo
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Campos para o SELECT da tabela SD2 ou SD1³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cTpMov=="E"
			cSlctD1D2 := "SD1.D1_TES,SD1.D1_TIPO,SD1.D1_UM,SD1.D1_PEDIDO,SD1.D1_ITEM,SD1.D1_SEGUM,SD1.D1_QTSEGUM,SD1.D1_DOC,SD1.D1_VALIPI,SD1.D1_DESCICM"
		Else
			cSlctD1D2 := "SD2.D2_TES,SD2.D2_TIPO,SD2.D2_UM,SD2.D2_PEDIDO,SD2.D2_SEGUM,SD2.D2_QTSEGUM,SD2.D2_DOC,SD2.D2_DESCICM"
			If SD2->(FieldPos(cMvD310MUN))>0
				cSlctD1D2 += ","+cMvD310MUN
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Campos para o SELECT da tabela SA1, SA2 e SA4³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//Tabela SA1
		cSlctA1 := "SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA1.A1_PESSOA, SA1.A1_CGC, SA1.A1_EST, SA1.A1_INSCR, SA1.A1_COD_MUN, "
		cSlctA1 += "SA1.A1_END, SA1.A1_BAIRRO, SA1.A1_INSCRM, SA1.A1_TIPO"
		If aSPDSX3[FP_A1_CODPAIS]
			cSlctA1	+=	", SA1.A1_CODPAIS"
		EndIf
		If aSPDSX3[FP_A1_SUFRAMA]
			cSlctA1	+=	", SA1.A1_SUFRAMA"
		EndIf
		If aSPDSX3[FP_A1_ENDNOT]
			cSlctA1	+=	", SA1.A1_ENDNOT"
		EndIf
		If aSPDSX3[FP_A1_SIMPNAC]
			cSlctA1	+=	", SA1.A1_SIMPNAC"
		EndIf
		If aSPDSX3[FP_A1_REGPB]
			cSlctA1	+=	", SA1.A1_REGPB"
		EndIf
		If aSPDSX3[FP_A1_COMPLEM]
			cSlctA1	+=	", SA1.A1_COMPLEM"
		EndIf

		//Tabela SA2
		cSlctA2	:=	"SA2.A2_COD, SA2.A2_LOJA, SA2.A2_NOME, SA2.A2_TIPO, SA2.A2_CGC, SA2.A2_EST, SA2.A2_INSCR, SA2.A2_COD_MUN, "
		cSlctA2	+=	"SA2.A2_END, SA2.A2_BAIRRO, SA2.A2_INSCRM"
		If aSPDSX3[FP_A2_CODPAIS]
			cSlctA2	+=	", SA2.A2_CODPAIS"
		EndIf
		If aSPDSX3[FP_A2_SUFRAMA]
			cSlctA2	+=	", SA2.A2_SUFRAMA"
		EndIf
		If aSPDSX3[FP_A2_ENDNOT]
			cSlctA2	+=	", SA2.A2_ENDNOT"
		EndIf
		If aSPDSX3[FP_A2_SIMPNAC]
			cSlctA2	+=	", SA2.A2_SIMPNAC"
		EndIf
		If aSPDSX3[FP_A2_REGPB]
			cSlctA2	+=	", SA2.A2_REGPB"
		Endif
		If aSPDSX3[FP_A2_COMPLEM]
			cSlctA2	+=	", SA2.A2_COMPLEM"
		EndIf
		If aSPDSX3[FP_A2_CPFRUR] .and. aSPDSX3[FP_A2_INDRUR]
			cSlctA2	+=	", SA2.A2_CPFRUR"
			cSlctA2	+=	", SA2.A2_INDRUR"
		EndIf

		//Tabela SA4
		cSlctA4	:=	"A4_COD, A4_NOME, A4_CGC, A4_INSEST, A4_EST, A4_END, A4_BAIRRO"
		If aSPDSX3[FP_A4_CODPAIS]
			cSlctA4	+=	", SA4.A4_CODPAIS"
		EndIf
		If aSPDSX3[FP_A4_COD_MUN]
			cSlctA4	+=	", SA4.A4_COD_MUN"
		EndIf
		If aSPDSX3[FP_A4_SUFRAMA]
			cSlctA4	+=	", SA4.A4_SUFRAMA"
		EndIf
		If aSPDSX3[FP_A4_ENDNOT]
			cSlctA4	+=	", SA4.A4_ENDNOT"
		EndIf
		If aSPDSX3[FP_A4_COMPLEM]
			cSlctA4	+=	", SA4.A4_COMPLEM"
		EndIf

		//Tabela SF4
		cSlctF4 := "SF4.F4_VLAGREG, SF4.F4_SELO, SF4.F4_TEXTO, SF4.F4_ESTOQUE, SF4.F4_BASEICM, SF4.F4_SITTRIB, SF4.F4_CSTPIS, SF4.F4_CSTCOF, SF4.F4_ICM, SF4.F4_LFICM, SF4.F4_CODIGO, SF4.F4_LFIPI,SF4.F4_IPI, "
		cSlctF4 += "SF4.F4_PISDSZF, SF4.F4_COFDSZF, SF4.F4_MOVFIS, SF4.F4_CSOSN, SF4.F4_RGESPCI, SF4.F4_OBSSOL, SF4.F4_AGREG, SF4.F4_CODOBSE, SF4.F4_CONSUMO, SF4.F4_OPERGAR, SF4.F4_IPMSP, SF4.F4_IPMMG, F4_CPPRODE"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Campos do SELECT caso as tabelas estejam criadas na base de dados³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSlct	:=	""

		If lTabComp
			cSlct	:=	",SFU.R_E_C_N_O_ SFURECNO"
			cSlct	+=	",SFX.R_E_C_N_O_ SFXRECNO"
			cSlct	+=	",CD3.R_E_C_N_O_ CD3RECNO"
			cSlct	+=	",CD7.R_E_C_N_O_ CD7RECNO"
			cSlct	+=	",CD8.R_E_C_N_O_ CD8RECNO"
			cSlct	+=	",CD9.R_E_C_N_O_ CD9RECNO"
			cSlct	+=	",CCE.R_E_C_N_O_ CCERECNO"
		EndIf

		If lTabF0A
			cSlct	+=	",F0A.R_E_C_N_O_ F0ARECNO"
		EndIf

	/*	If lTabCD0
			cSlct	+=	",CD0.R_E_C_N_O_ CD0RECNO"
		EndIf*/

		If lTabCD1
			cSlct	+=	",CD1.R_E_C_N_O_ CD1RECNO"
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se houver integracao com o TMS, trago o recno do conhecimento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lIntTMS
			cSlct	+=	",DT6.R_E_C_N_O_ DT6RECNO"
		EndIf

		//Campos das tabelas do GTP p/ geração dos registros D400 e filhos.
		If lDadosGTP
			cSlct   += ", GZU.GZU_AGENCI, GZU.GZU_DOC, GZU.GZU_SERIE, GZU.GZU_SUBSER, GZU.GZU_DTMOV, GZU.GZU_CONTA, GZU.GZU_SITUAC"
			cSlct   += ", GZU.GZU_VLDOC, GZU.GZU_VLDESC, GZU.GZU_VLSERV, GZU.GZU_VLBASE, GZU.GZU_VLICMS, GZU.GZU_VLPIS, GZU.GZU_COFINS, GZU.GZU_CONTA"
			cSlct   += ", GIC.GIC_CODRMD"

			aAdd(aFieldDt,"GZU_DTMOV")
		EndIf

		If lRegCompST
			cSlctCII := ", CII.CII_QTDMOV , CII.CII_UNID , CII.CII_VUNIT , CII.CII_ICMEFE , CII.CII_BURET , CII.CII_VURET , CII.CII_VURFCP , CII.CII_CODDA, "
			cSlctCII += " CII.CII_NUMDA , CII.CII_ITEM  , CII.CII_PRODUT , CII.CII_CST , CII.CII_CFOP , CII.CII_ENQLEG , CII.CII_QTDMOV , CII.CII_UNID , CII.CII_CODRES, "
			cSlctCII += " CII.CII_ICMEFS , CII.CII_VUCRED , CII.CII_MUBST , CII.CII_MUVSTF , CII.CII_MUVSF , CII.CII_VUREST , CII.CII_VURTFC , CII.CII_VUCST , CII.CII_VUCFC , CII.CII_CST , CII.CII_CFOP, "
			cSlctCII += " CII.CII_VCREDI, CII.CII_VRESSA, CII.CII_VREFCP, CII.CII_VCMPL, CII.CII_VCMFCP, CII.CII_MUCRED "
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Concateno todas as variaveis individuais de SELECT para formar uma³
		//³  soh a ser utilizada no EMBEDED SQL                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if cTipoDB == "ORACLE" .and. lQryNoParal
			cSlctAll	+= " /*+ no_parallel */ " //Não executar com paralelismo
		endif

		cSlctAll	+= cSlctSFT+","+cSlctSB1+","+cSlctSB5+cSlctD1D2+","+cSlctF4+","+cSlctF1F2+","+cSlctA1+","+cSlctA2+","+cSlctA4 + cSlctCII+","+cSlctSF3
		cSlctAll	+= "SF3.R_E_C_N_O_ SF3RECNO"
		cSlctAll	+= cSlct
		cSlctAll	:= "%"+cSlctAll+"%"
		cSlctSB1	:= "%"+cSlctSB1+"%"
		cSlctF4		:= "%"+cSlctF4+"%"
		cSlctA1		:= "%"+cSlctA1+"%"
		cSlctA2		:= "%"+cSlctA2+"%"
		cSlctA4		:= "%"+cSlctA4+"%"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento retirado devido a um problema de JOIN em ambiente ORACLE, bug da versao 10G.                 ³
		//³Como estas duas informacoes nao estao sendo utilizadas no momento, estou desativando.                   ³
		//³                                                                                                        ³
		//³Error : 1445 - ORA-01445: cannot select ROWID from, or sample, a join view without a key-preserved table³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//cSlctAll	+=	"(SELECT COUNT(*) FROM "+RetSqlName("SF3")+" SF3A WHERE SF3A.F3_FILIAL='"+xFilial("SF3")+"' AND SF3A.F3_ENTRADA=SFT.FT_ENTRADA AND SF3A.F3_NFISCAL=SFT.FT_NFISCAL AND SF3A.F3_SERIE=SFT.FT_SERIE AND SF3A.F3_CLIEFOR=SFT.FT_CLIEFOR AND SF3A.F3_LOJA=SFT.FT_LOJA AND SF3A.F3_TIPO='S' AND SF3A.D_E_L_E_T_=' ') F3CTDTPS,"
		//cSlctAll	+=	"(SELECT COUNT(*) FROM "+RetSqlName("SF3")+" SF3B WHERE SF3B.F3_FILIAL='"+xFilial("SF3")+"' AND SF3B.F3_ENTRADA=SFT.FT_ENTRADA AND SF3B.F3_NFISCAL=SFT.FT_NFISCAL AND SF3B.F3_SERIE=SFT.FT_SERIE AND SF3B.F3_CLIEFOR=SFT.FT_CLIEFOR AND SF3B.F3_LOJA=SFT.FT_LOJA AND SF3B.F3_TIPO=' ' AND SF3B.D_E_L_E_T_=' ') F3CTDTPN

		cOrderBy := "%"
		cOrderBy += " ORDER BY 1,2,3,4,5,6,7,8,9"

		if cTipoDB == "MSSQL" .and. lQryNoParal
			cOrderBy += " OPTION (MAXDOP 1)" //Não executar com paralelismo
		endif

		cOrderBy += "%"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para campos de tabelas que variam quando ENTRADA ou SAIDA³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//JOIN SF3
		If cTpMov=="E"
			cJoinF3 := "SF3.F3_CFO<'5'"
		Else
			cJoinF3 := "SF3.F3_CFO>'4'"
		EndIf
		cJoinF3 := "%" + cJoinF3 + "%"

		//JOIN SD1 e SD2
		If cTpMov=="E"
			cJoinD1D2 := "LEFT JOIN "+RetSqlName("SD1")+" SD1 ON(SD1.D1_FILIAL='"+xFilial("SD1")+"'  AND SD1.D1_DOC=SFT.FT_NFISCAL AND SD1.D1_SERIE=SFT.FT_SERIE AND SD1.D1_FORNECE=SFT.FT_CLIEFOR AND SD1.D1_LOJA=SFT.FT_LOJA AND SD1.D1_COD=SFT.FT_PRODUTO AND SD1.D1_ITEM=SFT.FT_ITEM AND SD1.D_E_L_E_T_=' ') "
		Else
			cJoinD1D2 := "LEFT JOIN "+RetSqlName("SD2")+" SD2 ON(SD2.D2_FILIAL='"+xFilial("SD2")+"'  AND SD2.D2_DOC=SFT.FT_NFISCAL AND SD2.D2_SERIE=SFT.FT_SERIE AND SD2.D2_CLIENTE=SFT.FT_CLIEFOR AND SD2.D2_LOJA=SFT.FT_LOJA AND SD2.D2_COD=SFT.FT_PRODUTO AND SD2.D2_ITEM=SFT.FT_ITEM AND SD2.D_E_L_E_T_=' ') "
		EndIf
		cJoinD1D2 := "%" + cJoinD1D2 + "%"

		//JOIN SF1 e SF2
		If cTpMov=="E"
			cJoinF1F2 := "LEFT JOIN "+RetSqlName("SF1")+" SF1 ON(SF1.F1_FILIAL='"+xFilial("SF1")+"'  AND SF1.F1_DOC=SFT.FT_NFISCAL AND SF1.F1_SERIE=SFT.FT_SERIE AND SF1.F1_FORNECE=SFT.FT_CLIEFOR AND SF1.F1_LOJA=SFT.FT_LOJA AND SF1.D_E_L_E_T_=' ') "
		Else
			cJoinF1F2 := "LEFT JOIN "+RetSqlName("SF2")+" SF2 ON(SF2.F2_FILIAL='"+xFilial("SF2")+"'  AND SF2.F2_DOC=SFT.FT_NFISCAL AND SF2.F2_SERIE=SFT.FT_SERIE AND SF2.F2_CLIENTE=SFT.FT_CLIEFOR AND SF2.F2_LOJA=SFT.FT_LOJA AND SF2.D_E_L_E_T_=' ') "
		EndIf
		cJoinF1F2 := "%" + cJoinF1F2 + "%"

		//JOIN SF4
		If cTpMov=="E"
			cJoinSF4 := "SF4.F4_CODIGO=SD1.D1_TES"
		Else
			cJoinSF4 := "SF4.F4_CODIGO=SD2.D2_TES"
		EndIf
		cJoinSF4 := "%" + cJoinSF4 + "%"

		//JOIN SA4
		If cTpMov=="E"
			If aSPDSX3[FP_F1_TRANSP]
				cJoinSA4 := "SA4.A4_COD=SF1.F1_TRANSP"
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se nao existir o campo referente a transportadora nao trago nada.           ³
				//³Esta condicao (='') eh soh para nao ter que ficar tratando a existencia     ³
				//³  deste campo para ora montar o join ou nao. Este " ='' " faz com que       ³
				//³  a query nao retorne nada, pois nao eh possivel cadastrar codigo em branco.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cJoinSA4 := "SA4.A4_COD=''"
			EndIf
		Else
			cJoinSA4 := "SA4.A4_COD=SF2.F2_TRANSP"
		EndIf
		cJoinSA4 := "%" + cJoinSA4 + "%"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tabelas do JOIN caso as mesmas estejam criadas no dicionario de dados³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTabComp
			cJoinCompl := "LEFT JOIN "+RetSqlName("SFU")+" SFU ON(SFU.FU_FILIAL='"+xFilial("SFU")+"' AND SFU.FU_TIPOMOV=SFT.FT_TIPOMOV AND SFU.FU_SERIE=SFT.FT_SERIE AND SFU.FU_DOC=SFT.FT_NFISCAL AND SFU.FU_CLIFOR=SFT.FT_CLIEFOR AND SFU.FU_LOJA=SFT.FT_LOJA AND SFU.FU_ITEM=SFT.FT_ITEM AND SFU.FU_COD=SFT.FT_PRODUTO AND SFU.D_E_L_E_T_='')"
			cJoinCompl += "LEFT JOIN "+RetSqlName("SFX")+" SFX ON(SFX.FX_FILIAL='"+xFilial("SFX")+"' AND SFX.FX_TIPOMOV=SFT.FT_TIPOMOV AND SFX.FX_SERIE=SFT.FT_SERIE AND SFX.FX_DOC=SFT.FT_NFISCAL AND SFX.FX_CLIFOR=SFT.FT_CLIEFOR AND SFX.FX_LOJA=SFT.FT_LOJA AND SFX.FX_ITEM=SFT.FT_ITEM AND SFX.FX_COD=SFT.FT_PRODUTO AND SFX.D_E_L_E_T_='') "
			cJoinCompl += "LEFT JOIN "+RetSqlName("CD3")+" CD3 ON(CD3.CD3_FILIAL='"+xFilial("CD3")+"' AND CD3.CD3_TPMOV=SFT.FT_TIPOMOV AND CD3.CD3_SERIE=SFT.FT_SERIE AND CD3.CD3_DOC=SFT.FT_NFISCAL AND CD3.CD3_CLIFOR=SFT.FT_CLIEFOR AND CD3.CD3_LOJA=SFT.FT_LOJA AND CD3.CD3_ITEM=SFT.FT_ITEM AND CD3.CD3_COD=SFT.FT_PRODUTO AND CD3.D_E_L_E_T_='') "
			cJoinCompl += "LEFT JOIN "+RetSqlName("CD7")+" CD7 ON(CD7.CD7_FILIAL='"+xFilial("CD7")+"' AND CD7.CD7_TPMOV=SFT.FT_TIPOMOV AND CD7.CD7_SERIE=SFT.FT_SERIE AND CD7.CD7_DOC=SFT.FT_NFISCAL AND CD7.CD7_CLIFOR=SFT.FT_CLIEFOR AND CD7.CD7_LOJA=SFT.FT_LOJA AND CD7.CD7_ITEM=SFT.FT_ITEM AND CD7.CD7_COD=SFT.FT_PRODUTO AND CD7.D_E_L_E_T_='') "
			cJoinCompl += "LEFT JOIN "+RetSqlName("CD8")+" CD8 ON(CD8.CD8_FILIAL='"+xFilial("CD8")+"' AND CD8.CD8_TPMOV=SFT.FT_TIPOMOV AND CD8.CD8_SERIE=SFT.FT_SERIE AND CD8.CD8_DOC=SFT.FT_NFISCAL AND CD8.CD8_CLIFOR=SFT.FT_CLIEFOR AND CD8.CD8_LOJA=SFT.FT_LOJA AND CD8.CD8_ITEM=SFT.FT_ITEM AND CD8.CD8_COD=SFT.FT_PRODUTO AND CD8.D_E_L_E_T_='') "
			cJoinCompl += "LEFT JOIN "+RetSqlName("CD9")+" CD9 ON(CD9.CD9_FILIAL='"+xFilial("CD9")+"' AND CD9.CD9_TPMOV=SFT.FT_TIPOMOV AND CD9.CD9_SERIE=SFT.FT_SERIE AND CD9.CD9_DOC=SFT.FT_NFISCAL AND CD9.CD9_CLIFOR=SFT.FT_CLIEFOR AND CD9.CD9_LOJA=SFT.FT_LOJA AND CD9.CD9_ITEM=SFT.FT_ITEM AND CD9.CD9_COD=SFT.FT_PRODUTO AND CD9.D_E_L_E_T_='') "
			cJoinCompl += "LEFT JOIN "+RetSqlName("CCE")+" CCE ON(CCE.CCE_FILIAL='"+xFilial("CCE")+"' AND CCE.CCE_COD=SF4.F4_CODOBSE AND CCE.D_E_L_E_T_='') "
		EndIf

		If lTabF0A
			cJoinCompl += "LEFT JOIN "+RetSqlName("F0A")+" F0A ON(F0A.F0A_FILIAL='"+xFilial("F0A")+"' AND F0A.F0A_TPMOV=SFT.FT_TIPOMOV AND F0A.F0A_SERIE=SFT.FT_SERIE AND F0A.F0A_DOC=SFT.FT_NFISCAL AND F0A.F0A_CLIFOR=SFT.FT_CLIEFOR AND F0A.F0A_LOJA=SFT.FT_LOJA AND F0A.F0A_ITEM=SFT.FT_ITEM AND F0A.F0A_COD=SFT.FT_PRODUTO AND F0A.D_E_L_E_T_='') "
		EndIf

		/*If lTabCD0
			cJoinCompl += "LEFT JOIN "+RetSqlName("CD0")+" CD0 ON(CD0.CD0_FILIAL='"+xFilial("CD0")+"' AND CD0.CD0_TPMOV=SFT.FT_TIPOMOV AND CD0.CD0_SERIE=SFT.FT_SERIE AND CD0.CD0_DOC=SFT.FT_NFISCAL AND CD0.CD0_CLIFOR=SFT.FT_CLIEFOR AND CD0.CD0_LOJA=SFT.FT_LOJA AND CD0.CD0_ITEM=SFT.FT_ITEM AND CD0.CD0_COD=SFT.FT_PRODUTO AND CD0.D_E_L_E_T_='') "
		EndIf*/

		If lTabCD1
			cJoinCompl += "LEFT JOIN "+RetSqlName("CD1")+" CD1 ON(CD1.CD1_FILIAL='"+xFilial("CD1")+"' AND CD1.CD1_CODNAT=SFT.FT_NATOPER AND CD1.D_E_L_E_T_='') "
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se houver integracao com o TMS, faco o JOIN das tabelas      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lIntTMS
			cJoinCompl += "LEFT JOIN "+RetSqlName("DT6")+" DT6 ON(SFT.FT_TIPOMOV='S' AND DT6_FILIAL='"+xFilial("DT6")+"' AND DT6_FILDOC=SFT.FT_FILIAL AND DT6_DOC=SFT.FT_NFISCAL AND DT6_SERIE=SFT.FT_SERIE AND DT6.D_E_L_E_T_='') "
		EndIf

		//Se utilizar informacao de produto primario incluo JOIN com tabela SB5
		If !Empty(cPRDPRIB5)
			If SB5->(FieldPos(cPRDPRIB5))>0
				cJoinCompl += "LEFT JOIN "+RetSqlName("SB5")+" SB5 ON(SB5.B5_FILIAL ='"+xFilial("SB5")+"' AND SB5.B5_COD=SB1.B1_COD AND SB5.D_E_L_E_T_='') "
			Endif
		Endif

		// JOIN com as tabelas do GTP p/ geração dos registros D400 e filhos.
		If lDadosGTP
			cJoinCompl += "LEFT JOIN " + RetSqlName("GIC") + " GIC ON(GIC.GIC_FILIAL = " + ValToSql(xFilial("GIC")) + " AND GIC.GIC_FILNF = SFT.FT_FILIAL AND GIC.GIC_NOTA = SFT.FT_NFISCAL AND GIC.GIC_SERINF = SFT.FT_SERIE AND GIC.GIC_CLIENT = SFT.FT_CLIEFOR AND GIC.GIC_LOJA = SFT.FT_LOJA AND GIC.D_E_L_E_T_ = '')"
			cJoinCompl += "LEFT JOIN " + RetSqlName("GZU") + " GZU ON(GZU.GZU_FILIAL = " + ValToSql(xFilial("GZU")) + " AND GZU.GZU_DOC = GIC.GIC_CODRMD AND GZU.GZU_AGENCI = GIC.GIC_AGENCI AND GZU.D_E_L_E_T_ = '')"
		EndIf

		// JOIN com a tabela CII p/ gera??o dos registros da apura??o do ICMS ST
		If lRegCompST
			If cTpMov=="E"
				cJoinCII := " LEFT JOIN "+RetSqlName("CII")+" CII ON( CII.CII_FILIAL= '"+xFilial("CII")+"' AND  CII.CII_TPMOV=SFT.FT_TIPOMOV AND CII.CII_NFISCA=SFT.FT_NFISCAL AND CII.CII_SERIE=SFT.FT_SERIE AND CII.CII_PARTIC=SFT.FT_CLIEFOR AND CII.CII_LOJA=SFT.FT_LOJA AND CII.CII_PRODUT=SFT.FT_PRODUTO AND CII.CII_ITEM=SFT.FT_ITEM AND CII.D_E_L_E_T_='')  "
			Else
				cJoinCII := " LEFT JOIN "+RetSqlName("CII")+" CII ON( CII.CII_FILIAL= '"+xFilial("CII")+"' AND  CII.CII_TPMOV=SFT.FT_TIPOMOV AND CII.CII_NFISCA=SFT.FT_NFISCAL AND CII.CII_SERIE=SFT.FT_SERIE AND CII.CII_PARTIC=SFT.FT_CLIEFOR AND CII.CII_LOJA=SFT.FT_LOJA AND CII.CII_PRODUT=SFT.FT_PRODUTO AND CII.CII_ITEM=SFT.FT_ITEM AND CII.D_E_L_E_T_='')  "
			EndIf
			cJoinCompl += cJoinCII
		EndIf

		cJoinCompl := "%" + cJoinCompl + "%"
		cCliDvMc	:=	"%" + cCliDvMc +	"%"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³SELECT real para a execucao da rotina³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cAliasSFT := GetNextAlias()

		BeginSql Alias cAliasSFT

			SELECT
				%Exp:cSlctAll%
			FROM
				%Table:SFT% SFT
				/*
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Inserida condicao para desconsiderar itens de notas ³
				//³conjugadas que possuam o campo observacao           ³
				//³igual a NOTA DE SERVICO que se enquadram            ³
				//³na seguinte situacao:                               ³
				//³                                                    ³
				//³TES Produto 1, ISS                                  ³
				//³                                                    ³
				//³F4_ICM = Nao                                        ³
				//³F4_LFICM = Isento                                   ³
				//³F4_ISS = Sim                                        ³
				//³F4_SITRIB = 41                                      ³
				//³F4_CFO = 5933                                       ³
				//³                                                    ³
				//³TES Produto 2, ICMS                                 ³
				//³                                                    ³
				//³F4_ICM = Sim                                        ³
				//³F4_LFICM = Tributado                                ³
				//³F4_ISS = Nao                                        ³
				//³F4_SITRIB = 00                                      ³
				//³F4_CFO = 5102                                       ³
				//³                                                    ³
				//³Como a escrituracao gera um item na tabela SF3      ³
				//³para o ICMS Isento da nota de servico, este item    ³
				//³deve ser desconsiderado na geracao do SpedFiscal    ³
				//³pois sua inclusao recorria em valores duplicados    ³
				//³no arquivo                                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				*/
				LEFT JOIN %Table:SF3% SF3 ON(SF3.F3_FILIAL=%xFilial:SF3% AND %Exp:cJoinF3% AND SF3.F3_SERIE=SFT.FT_SERIE AND SF3.F3_NFISCAL=SFT.FT_NFISCAL AND SF3.F3_CLIEFOR=SFT.FT_CLIEFOR AND SF3.F3_LOJA=SFT.FT_LOJA AND SF3.F3_IDENTFT=SFT.FT_IDENTF3 AND SF3.F3_ENTRADA=SFT.FT_ENTRADA AND SF3.F3_OBSERV NOT LIKE('NOTA FISCAL DE SERVICO%') AND SF3.%NotDel%)
				%Exp:cJoinD1D2%
				LEFT JOIN (SELECT %Exp:cSlctSB1% FROM %Table:SB1% SB1 WHERE SB1.B1_FILIAL=%xFilial:SB1%  AND SB1.%NotDel%) SB1 ON(SB1.B1_COD=SFT.FT_PRODUTO)
				LEFT JOIN (SELECT %Exp:cSlctF4% FROM %Table:SF4% SF4 WHERE SF4.F4_FILIAL=%xFilial:SF4%  AND SF4.%NotDel%) SF4 ON(%Exp:cJoinSF4%)
				%Exp:cJoinCompl%
				LEFT JOIN (SELECT %Exp:cSlctA1% FROM %Table:SA1% SA1 WHERE SA1.A1_FILIAL=%xFilial:SA1% AND SA1.%NotDel%) SA1 ON(SA1.A1_COD =%Exp:cCliDvMc%)
				LEFT JOIN (SELECT %Exp:cSlctA2% FROM %Table:SA2% SA2 WHERE SA2.A2_FILIAL=%xFilial:SA2% AND SA2.%NotDel%) SA2 ON(SA2.A2_COD=SFT.FT_CLIEFOR AND SA2.A2_LOJA=SFT.FT_LOJA)
				%Exp:cJoinF1F2%
				LEFT JOIN (SELECT %Exp:cSlctA4% FROM %Table:SA4% SA4 WHERE SA4.A4_FILIAL=%xFilial:SA4% AND SA4.%NotDel%) SA4 ON(%Exp:cJoinSA4%)
			WHERE
				SFT.FT_FILIAL=%xFilial:SFT% AND
				SFT.FT_TIPOMOV=%Exp:cTpMov% AND
				SFT.FT_ENTRADA>=%Exp:DToS(dDataDe)% AND
				SFT.FT_ENTRADA<=%Exp:DToS(dDataAte)% AND
				((SFT.FT_CFOP NOT LIKE '000%' AND SFT.FT_CFOP NOT LIKE '999%') OR SFT.FT_TIPO='S') AND
				(SFT.FT_ESPECIE <> 'CF' OR (SFT.FT_ESPECIE = 'CF' AND SFT.FT_VALIPI > 0)) AND
				(SFT.FT_ESPECIE <> 'BPR' OR (SFT.FT_ESPECIE = 'BPR' AND SFT.FT_PDV = %Exp:cPDVEmpty%)) AND
				%Exp:cFiltro%
				SFT.%NotDel%

				%Exp:cOrderBy%
		EndSql


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o objetivo for soh para retornar o COUNT, posso salvar em uma variavel ³
		//³  e fechar o alias, pois nao serah mais utilizado                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 To Len(aFieldDt)
			TcSetField(cAliasSFT,aFieldDt[nX],"D",8,0)
		Next nX
	Else
#ENDIF
		cIndex	:= CriaTrab(NIL,.F.)
		cFiltro	:= 'FT_FILIAL=="'+xFilial ("SFT")+'".And.'
		cFiltro += 'FT_TIPOMOV=="'+cTpMov+'" .And. '
		cFiltro += 'DToS (FT_ENTRADA)>="'+DToS (dDataDe)+'".And.DToS (FT_ENTRADA)<="'+DToS (dDataAte)+'" '
		cFiltro += '.And. (!SubStr (FT_CFOP,1,3)$"999/000" .Or. FT_TIPO=="S")'
		cFiltro += '.And. FT_ESPECIE <> "CF" .Or. (FT_ESPECIE == "CF" .And. FT_VALIPI > 0) '
		If (cNrLivro<>"*")
			cFiltro	+=	'.And.FT_NRLIVRO ="'+cNrLivro+'" '
		EndIf
		IndRegua (cAliasSFT, cIndex, SFT->(IndexKey ()),, cFiltro)
		nIndex := RetIndex(cAliasSFT)
		#IFNDEF TOP
			DbSetIndex(cIndex+OrdBagExt ())
		#ENDIF
		DbSelectArea(cAliasSFT)
		DbSetOrder(nIndex+1)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o objetivo for soh para retornar o COUNT, posso salvar em uma variavel ³
		//³  e fechar o alias, pois nao serah mais utilizado                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea (cAliasSFT)
		(cAliasSFT)->(DbGoTop ())
#IFDEF TOP
	Endif
#ENDIF

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |SpedMntWiz³ Autor ³Gustavo G. Rueda       ³ Data ³16.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³                    MONTAGEM DO WIZARD                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Funcao que monta o Wizard em tela para processamento.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T. se o wizard foi finalizado com sucesso ou .F. se³±±
±±³          ³ foi cancelado.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cNomWiz  -> Nome do arquivo que sera gravado com as confi-  ³±±
±±³			 | guracoes da Wizard.			  							  ³±±
±±³          ³cPerfil  -> Perfil informado no parametro MV_PRFSPED		  ³±±
±±³          ³cNomeAnt -> Arquivo .cfp que ja possui as configuracoes da  ³±±
±±³			 | Wizard.                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SpedMntWiz ( cNomWiz , cPerfil , cNomeAnt , cSped )
Local	aTxtApre	:=	{}
Local	aPaineis	:=	{}
Local	aItens1		:=	{}
Local	aItens2		:=	{}
Local	cTitObj1	:=	""
Local	cTitObj2	:=	""
Local	cVercorp	:=	GetVersao()
Local	lRet		:=	.T.
Local	nPos		:=	0
Local	nTam		:=	iif(cVercorp =="11", 20, 30)

Default	cNomeAnt	:= ""
Default	cSped		:=	"FISCAL"

If cSped == "FISCAL"

	aAdd (aTxtApre, "Parâmetros necessários.")
	aAdd (aTxtApre, "")
	aAdd (aTxtApre, "Preencha corretamente as informações solicitadas.")
	aAdd (aTxtApre, "Informações necessárias para a geração do meio-magnético SPED FISCAL.")
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                                                                     PAINEL 0     															   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd (aPaineis, {})
	nPos	:=	Len (aPaineis)
	aAdd (aPaineis[nPos], "Preencha corretamente as informações solicitadas.")
	aAdd (aPaineis[nPos], "Parâmetros para Geração")
	aAdd (aPaineis[nPos], {})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Data de";								   			cTitObj2	:=	"Data até"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
	//
	aAdd (aPaineis[nPos][3], {2,,,3,,,,});							aAdd (aPaineis[nPos][3], {2,,,3,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Livro"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//
	cTitObj1	:=	Replicate ("X", 1)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,1,,,,{"xMagGetCon",4}})

	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Diretório do Arquivo Destino";						cTitObj2	:=	"Nome do Arquivo Destino"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
	//
	cTitObj1	:=	Replicate ("X", 50);								cTitObj2	:=	Replicate ("X", nTam)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});					aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,nTam})

	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Gera Inventário";									cTitObj2	:=	"Gera Registros Complementares de Frete"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

	aItens1	:=	{};														aItens2	:=	{}
	aAdd (aItens1, "1-Sim");											aAdd (aItens2, "1-Sim")
	aAdd (aItens1, "2-Não");											aAdd (aItens2, "2-Não")
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,});						aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aItens2	:=	{}
	aItens2	:=	{"1-Sim","2-Nao"}
	cTitObj1	:=	"Data de fechamento do estoque";					cTitObj2	:=	"Gera Registros de ECF"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
	aAdd (aPaineis[nPos][3], {2,,,3,,,,});							aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {1,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"QUANTO A APURAÇÃO DO ICMS"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Arq. periodo anterior";							cTitObj2	:=	"Imprime Credito ST"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
	//
	aItens1	:=	{}
	aAdd (aItens1, "1-Sim")

	aAdd (aItens1, "2-Não")
	//
	cTitObj1	:=	Replicate ("X", 50)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});					aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,})
	//
	aAdd (aPaineis[nPos][3], {1,"",,,,,,});							aAdd (aPaineis[nPos][3], {1,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"QUANTO A APURAÇÃO DO IPI";							cTitObj2	:=	"Seleciona Filiais ?"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

	cTitObj1	:=	"Período de Apuração";								aItens2	:=	{"1-Sim","2-Nao"}

	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,})

	aItens1	:=	{"0 - Mensal","1 - Decendial"}
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,});						aAdd (aPaineis[nPos][3], {1,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Permite gerar os blocos G130 e G140 para "
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, "",,,,,,})
	//
	cTitObj1    := " todos os bens que tiveram movimentação "
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, "",,,,,,})
	//
	cTitObj1    := "do ativo imobilizado quando o campo "
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, "",,,,,,})
	//
	cTitObj1    := "TIPO_MOV do registro G125(Movimentação de "
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, "",,,,,,})
	//
	cTitObj1    := "Bem ou componente do ativo imobilizado)"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, "",,,,,,})
	//
	cTitObj1    := "for igual  a 'SI'"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, "",,,,,,})

	//
	aAdd (aPaineis[nPos][3], {1,"",,,,,,});							aAdd (aPaineis[nPos][3], {1,"",,,,,,})

	//
	cTitObj1	:=	"Inicio Obrigação Escrituração Fiscal CIAP";	    cTitObj2	:=	"Considera Valores de Pis/Cofins?"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,});

	//
	aItens1	:=	{"1-Sim","2-Não"};										aItens2	:=	{"1-Sim","2-Não"}
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,{.F.,"2-Não",.T.}});	aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,})
	aAdd (aPaineis[nPos][3], {1,"",,,,,,});          					aAdd (aPaineis[nPos][3], {1,"",,,,,,})

	aAdd (aPaineis[nPos][3], {1,"",,,,,,});							aAdd (aPaineis[nPos][3], {1,"",,,,,,})
	//
	cTitObj1	:=	"Gera Bloco K";		   							cTitObj2	:=	"Reg. 0210 por Mov.?"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,});

	aItens1	:=	{};													aItens2	:=	{}
	aAdd (aItens1, "2-Não");										aAdd (aItens2, "2-Não")
	aAdd (aItens1, "1-Sim");										aAdd (aItens2, "1-Sim")
	aAdd (aItens1, "3-Sim - K200/K280")
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,});					aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,})

	aAdd (aPaineis[nPos][3], {1,"",,,,,,});							aAdd (aPaineis[nPos][3], {1,"",,,,,,})

	cTitObj1	:=	"Gera Registros DIFAL (EC 87/15)";				cTitObj2	:=	"Motivo do Inventário"
																	aItens2	:=	{}
																	aAdd (aItens2, "01-Final do período")
																	aAdd (aItens2, "02-Mudança de trib. da mercadoria (ICMS)")
																	aAdd (aItens2, "03-Solic. da baixa cad., paral. temp. e outras")
																	aAdd (aItens2, "04-Na alteração de regime de pagamento")
	aItens1	:=	{"","1-Sim","2-Não"};								aAdd (aItens2, "05-Por determinação dos fiscos")
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,{.F.,"2-Não",.T.}});	aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,})
	aAdd (aPaineis[nPos][3], {1,"",,,,,,});

	aAdd (aPaineis[nPos][3], {1,"",,,,,,});

	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Gera Registro 0400 - Natureza da Oper./Prest.?"; 	cTitObj2	:=	"Gera H020 - Motivo Inventário 01"
	aAdd (aPaineis[nPos][3], {1,cTitObj1,,,,,,});							aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,});						aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,})

	aAdd (aPaineis[nPos][3], {1,"",,,,,,});

	aAdd (aPaineis[nPos][3], {1,"",,,,,,});
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Processa histórico do Bloco K"; 				cTitObj2	:=	"Gera Registros de FECP"
	aItens1	:=	{"1-Sim","2-Não"};									aItens2		:=	{"2-Não","1-Sim"}
	aAdd (aPaineis[nPos][3], {1,cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,});					aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,})
	aAdd (aPaineis[nPos][3], {1,"",,,,,,});                         aAdd (aPaineis[nPos][3], {1,"",,,,,,})

	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Gera Bloco G";									cTitObj2	:=	"Gera Bloco B"
	aItens1	:=	{"1-Sim","2-Não"};									aItens2		:=	{"1-Sim","2-Não"}
	aAdd (aPaineis[nPos][3], {1,cTitObj1,,,,,,}); 					aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,});					aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,})

	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {1,"",,,,,,});							aAdd (aPaineis[nPos][3], {1,"",,,,,,})

	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Gera Inf.Compl ST";							cTitObj2	:=	"Gera registro 0210?"
	aItens1	:=	{"2-Não","1-Sim"};									aItens2		:=	{"1-Sim","2-Não"}
	aAdd (aPaineis[nPos][3], {1,cTitObj1,,,,,,}); 					aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,});					aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,})

	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {1,"",,,,,,});							aAdd (aPaineis[nPos][3], {1,"",,,,,,})

	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                                                                     PAINEL 1     															   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd (aPaineis, {})
	nPos	:=	Len (aPaineis)
	aAdd (aPaineis[nPos], "Preencha corretamente as informações solicitadas.")
	aAdd (aPaineis[nPos], "Identificação do Contribuinte")
	aAdd (aPaineis[nPos], {})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Código da Finalidade do Arquivo";		   			cTitObj2	:=	""
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {0, cTitObj2,,,,,,})
	//
	aItens1	:=	{}
	aAdd (aItens1, "0-Remessa regular de arquivo")
	aAdd (aItens1, "1-Remessa de arquivo substituto")
	//
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Filial de";										cTitObj2	:=	"Filial ate"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
	//
	cTitObj1	:=	Replicate ("X", FWGETTAMFILIAL);				    cTitObj2	:=	Replicate ("X", FWGETTAMFILIAL)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,FWGETTAMFILIAL});		aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,FWGETTAMFILIAL})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Perfil de Apresentação";							cTitObj2	:=	"Tipo de Atividade"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
	//
	aItens1	:=	{};														aItens2	:=	{}
	aAdd (aItens1, "A - Perfil A");										aAdd (aItens2, "0 - Industrial ou Equiparado")
	aAdd (aItens1, "B - Perfil B");										aAdd (aItens2, "1 - Outros")
	aAdd (aItens1, "C - Perfil C");
	//
	If Empty(cPerfil)
		aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,})
	Else
		aAdd(aPaineis[nPos][3],{2,,cPerfil,1,,,,2,{.T.,cPerfil}})
	EndIf
																		aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Aglutina por CNPJ+IE ?"
	aAdd (aPaineis[nPos][3], {1,cTitObj1,,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//
	aItens1	:=	{"1-Sim","0-Nao"}
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"INFORMAÇÕES CADASTRAIS"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"E-Mail";										cTitObj2	:=	"Classe de Atividade Industrial"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
	//
	cTitObj1	:=	Replicate ("X", 50);							aItens1	:=	{}
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});				aAdd (aItens1, "")
																	aAdd (aItens1, "00 - Industrial - Transformação")
																	aAdd (aItens1, "01 - Industrial - Beneficiamento")
																	aAdd (aItens1, "02 - Industrial - Montagem")
																	aAdd (aItens1, "03 - Industrial - Acondicionamento ou Reacondicionamento")
																	aAdd (aItens1, "04 - Industrial - Renovação ou Recondicionamento")
																	aAdd (aItens1, "05 - Equiparado a industrial - Por opção")
																	aAdd (aItens1, "06 - Equiparado a industrial - Importação Direta")
																	aAdd (aItens1, "07 - Equiparado a industrial - Por lei específica")
																	aAdd (aItens1, "08 - Equiparado a industrial - Não enquadrado nos códigos 05, 06 ou 07")
																	aAdd (aItens1, "09 - Outros")
																	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,})
	//
	aAdd (aPaineis[nPos][3], {1,"",,,,,,});							aAdd (aPaineis[nPos][3], {1,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                                                                     PAINEL 2     															   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd (aPaineis, {})
	nPos	:=	Len (aPaineis)
	aAdd (aPaineis[nPos], "Preencha corretamente as informações solicitadas.")
	aAdd (aPaineis[nPos], "Dados do contabilista")
	aAdd (aPaineis[nPos], {})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Nome"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//
	cTitObj1	:=	Replicate ("X", 100)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,100,,,,{"xMagGetCon",2}})

	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"CNPJ";												cTitObj2	:=	"CPF"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
	//
	cTitObj1	:=	Replicate ("X", 14);								cTitObj2	:=	Replicate ("X", 11)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,14});					aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,11})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"CRC"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//
	cTitObj1	:=	Replicate ("X", 15)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,15});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"CEP" ;												cTitObj2	:=	"Cod. Município"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
	//
	cTitObj1	:=	Replicate ("X", 8);									cTitObj2	:=	"@E 9999999"

	//----CEP
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,8,,,,{"xMagGetCon",3}})

	//----Cod. Municipio
	aAdd (aPaineis[nPos][3], {2,,cTitObj2,2,0,,,7,,,,{"xMagGetCon",3}})

	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Endereço";											cTitObj2	:=	"Número"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
	//
	cTitObj1	:=	Replicate ("X", 50);								cTitObj2	:=	Replicate ("X", 5)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});					aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,5})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Complemento";										cTitObj2	:=	"Bairro"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
	//
	cTitObj1	:=	Replicate ("X", 20);								cTitObj1	:=	Replicate ("X", 20)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,20});					aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,20})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Fone";												cTitObj2	:=	"Fax"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

	cTitObj1	:=	Replicate ("X", 10);								cTitObj2	:=	Replicate ("X", 10)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,10});					aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,10})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"E-Mail"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//
	cTitObj1	:=	Replicate ("X", 50)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//
	aAdd (aPaineis[nPos][3], {1,"",,,,,,});							aAdd (aPaineis[nPos][3], {1,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                                                                     PAINEL 3     															   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                                                                     PAINEL 4     															   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd (aPaineis, {})
	nPos	:=	Len (aPaineis)
	aAdd (aPaineis[nPos], "Preencha corretamente as informacoes solicitadas.")
	aAdd (aPaineis[nPos], "Informacoes para processamento do Bloco 1")
	aAdd (aPaineis[nPos], {})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aItens1		:=	{}
	aAdd (aItens1, "1 - Sim")
	aAdd (aItens1, "2 - Não")
	aItens2		:=	{}
	aAdd (aItens2, "1 - Sim")
	aAdd (aItens2, "2 - Não")
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Gera Registro 1100 - Exportação?"
	cTitObj2	:=	"Gera Registro 1200 - Créditos Fiscais?"

	aAdd (aPaineis[nPos][3], {1,cTitObj1,,,,,,})
	aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})

	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,})
	aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,})

	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});						   	       	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Gera Registro 1300 - Combustíveis?"
	cTitObj2	:=	"Gera Registro 1390 - Usina de açúcar/álcool?"

	aAdd (aPaineis[nPos][3], {1,cTitObj1,,,,,,})
	aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})

	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,})
	aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,})

	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});						   	       	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Gera Registro 1400 - Valores Agregados?"
	cTitObj2	:=	"Gera Registro 1500 - Energia Elétrica?"

	aAdd (aPaineis[nPos][3], {1,cTitObj1,,,,,,})
	aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})

	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,})
	aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,})

	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});						   	       	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Gera Registro 1600 - Cartão de Crédito/Débito?"
	cTitObj2	:=	"Gera Registro 1700 - Documentos Fiscais?"

	aAdd (aPaineis[nPos][3], {1,cTitObj1,,,,,,})
	aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})

	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,})
	aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,})

	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});						   	       	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Gera Registro 1800 - Transporte Aéreo?"
	cTitObj2	:=	"Gera Registro 1400 - Movimentação Anual?"

	aAdd (aPaineis[nPos][3], {1,cTitObj1,,,,,,})
	aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})

	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,})
	aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {1,"",,,,,,});									aAdd (aPaineis[nPos][3], {1,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//

	aItens1		:=	{}
	aAdd (aItens1, "2 - Não")
	aAdd (aItens1, "1 - Sim")
	cTitObj1	:=	"Gera Registro 1960 - GIAF 1?"
	cTitObj2	:=	"Gera Registros 1970 e 1975 - GIAF 3?"

	aAdd (aPaineis[nPos][3], {1,cTitObj1,,,,,,})
	aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})

	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,})
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {1,"",,,,,,});									aAdd (aPaineis[nPos][3], {1,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//

	cTitObj1	:=	"Gera Registro 1980 - GIAF 4?"
	cTitObj2	:=	"Gera Registro 1250 - ICMS ST"

	aAdd (aPaineis[nPos][3], {1,cTitObj1,,,,,,})
	aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})

	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,})
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {1,"",,,,,,});									aAdd (aPaineis[nPos][3], {1,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//

Endif

lRet	:=	xMagWizard (aTxtApre, aPaineis, cNomWiz, cNomeAnt)
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A905ValCa ºAutor  ³ Vitor Felipe       º Data ³  08/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validar campos necessarios para rotina de componente.      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function SPEDValC()

Local lValid	:= .F.

If aSPDSX3[FP_F4_COMPONE] .And. aSPDSX3[FP_F9_TIPO] .And. aSPDSX3[FP_F9_CODBAIX] .And. aSPDSX3[FP_D1_CODBAIX]
	lValid := .T.
EndIf

Return(lValid)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SPEDRegs  | Autor ³Gustavo G. Rueda  			   ³ Data ³28.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao que efetua a gravacao de registros dependentes de forma     ³±±
±±³          ³ herarquica no TRB utilizando uma formatacao diferenciada do campo ³±±
±±³          ³ TRB_RELAC, onde o mesmo eh dividido em dois e o primeiro grupo    ³±±
±±³          ³ corresponde ao PAI e o segundo ao FILHO. Exemplo:                 ³±±
±±³          ³                                                                   ³±±
±±³          ³E200 --> E210 --> E220, nesta hierarquia, a gravacao eh efetuada da³±±
±±³          ³ segunite forma:                                                   ³±±
±±³          ³ Reg. E200 -> TRB_RELAC = 0000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000002
±±³          ³ Reg. E210 -> TRB_RELAC = 0000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000003
±±³          ³ Reg. E220 -> TRB_RELAC = 0000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000001
±±³          ³                                                                   ³±±
±±³          ³ onde:                                                             ³±±
±±³          ³                                                                   ³±±
±±³          ³ O segundo grupo do E200 (...0002) corresponde ao primeiro do E210 ³±±
±±³          ³ (...0002) e o segundo do E210 corresponde ao primeiro do E220     ³±±
±±³          ³ (...0003)                                                         ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³1) Os array a serem passados devem seguir a ordem hierarquica de   ³±±
±±³          ³   gracao.                                                         ³±±
±±³          ³2) Para os registros que estiverem na sequencia mais nao correspon-³±±
±±³          ³   derem a hierarquia informada, deve ser passado no seguinte for- ³±±
±±³          ³   mato. Ex: (aReg,2}                                              ³±±
±±³          ³   a) O primeiro nivel corresponde ao registro;                    ³±±
±±³          ³   b) O segundo corresponde ao pai deste registro que nao eh o     ³±±
±±³          ³      antecessor. Um exemplo de utilizacao eh a geracao do bloco E.³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³SPEDRegs(cAlias,aRegs)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias    -> Alias do TRB em processamento para gravar as informa- ³±±
±±³          ³             coes                                                  ³±±
±±³          ³aRegs     -> Array com as informacoes dos registros a serem grava- ³±±
±±³          ³             dos.                                                  ³±±
±±³          ³aRegs     ->                                                       ³±±
±±³          ³lSpedC    -> Indica se está processando registro do SPED           ³±±
±±³          ³             Contribuições (PIS/COFINS).                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPEDRegs(cAlias,aRegs,cMensagem,lSpedC)
Local aAux		:= {}
Local nAux		:= 0
Local nI1		:= 0
Local nI2		:= 0
Local nI3		:= 0
Local aPai		:= {}
Local lProc		:= .T.
Local nRegsProc	:= 0
Local nSvnI3	:= 0
Local aRegsPai	:= {}

Default	cMensagem	:=	""
Default lSpedC	:= .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem de um array de hierarquias como base para leitura dos arrays pela funcao.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI1 := 1 To Len(aRegs)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³O primeiro sempre serah o pai de todos, portanto nao tem um PAI³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nI1==1
		aAdd(aPai,{nI1,0})	//Sem pai, eh o pai de todos
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para verificar o registro cujo pai NA0 estah na sequencia. ³
		//³  Ex: E200 eh pai do E210 que eh pai do E220 que eh pai do E230 e E240³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType(aRegs[nI1])=="A" .And. Len(aRegs[nI1])>=2 .And. ValType(aRegs[nI1,2])=="N"
			aAdd(aPai,{nI1,aRegs[nI1,2]})
		Else
			aAdd(aPai,{nI1,nI1-1})
		EndIf
	EndIf

Next nI1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processamento da estrutura hierarquica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI1 := 2 To Len(aPai)	//A primeira posicao sempre eh o pai de todos
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Localizo o registro PAI e utilizo as informacoes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRegsPai := aRegs[aPai[nI1,2]]
	If ValType(aRegsPai)=="A" .And. Len(aRegsPai)>=2 .And. ValType(aRegsPai[2])=="N"	//Tratamento para verificar o registro cujo pai nao eh o antecessor
		aRegsPai := aRegsPai[1]
	EndIf

	aRegsFil := aRegs[aPai[nI1,1]]
	If ValType(aRegsFil)=="A" .And. Len(aRegsFil)>=2 .And. ValType(aRegsFil[2])=="N"	//Tratamento para verificar o registro cujo pai nao eh o antecessor
		aRegsFil := aRegsFil[1]
	EndIf

	For nI2 := 1 To Len(aRegsPai)

		lProc := .T.

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se nao existir filho para este PAI, deve gerar as informacoes doo PAI independente³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aScan(aRegsFil,{|aX| aX[1]==nI2})==0 .And. nI1==2
			aAux := {}
			For nAux := 1 To Len(aRegsPai[nI2])
				aAdd(aAux,aRegsPai[nI2,nAux])
			Next nAux
			GrvRegTrS(cAlias,0,{aAux},,nI2)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Variavel de controle do flag de relacionamento dos filhos com o pai³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nSvnI3	:= 0
		For nI3 := 1 To Len(aRegsFil)

			If aRegsFil[nI3,1]==nI2

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Para cada pai, efetuo a gravacao do PAI e do FILHO³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nI1==2 .And. lProc
					lProc := .F.

					aAux := {}
					For nAux := Iif(nI1==2,1,2) To Len(aRegsPai[nI2])
						aAdd(aAux,aRegsPai[nI2,nAux])
					Next nAux
					GrvRegTrS(cAlias,nI3,{aAux},,nI2,lSpedC)

					aAux := {}
					For nAux := 2 To Len(aRegsFil[nI3])
						aAdd(aAux,aRegsFil[nI3,nAux])
					Next nAux
					GrvRegTrS(cAlias,nI3,{aAux},,nI3,lSpedC)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Variavel utilizada para salvar a posicao do nI3 para utilizar quando existir mais de um filho³
					//³  para o mesmo pai (else abaixo).                                                            ³
					//³                                                                                             ³
					//³Quando sair do FOR (processamento de todos os filhos do mesmo pai), devo ZERAR a             ³
					//³  variavel para manter o controle que havia antes, "nI2"                                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nSvnI3	:=	nI3

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Quando o processamento ainda estiver no loop, gravo o pai somente para o³
				//³  primeiro registro e para os outros, somente os filhos                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atribuicao do nI2 para quando o nivel hierarquico for acima de 2 (nI1>2)³
					//³  nao entrando no if acima, somente neste else, e neste momento devo    ³
					//³  considerar o nI2.                                                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nSvnI3==0
						nSvnI3	:=	nI2
					EndIf

					aAux := {}
					For nAux := 2 To Len(aRegsFil[nI3])
						aAdd(aAux,aRegsFil[nI3,nAux])
					Next nAux
					GrvRegTrS(cAlias,nI3,{aAux},,nSvnI3,lSpedC)

				EndIf
			EndIf
		Next nI3
	Next nI2
Next nI1

Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SPEDGetAli| Autor ³Gustavo G. Rueda  			   ³ Data ³19.10.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao parecia com a GetNextAlias(), que gera um alias aleatorio   ³±±
±±³          ³ para a query com um limite maior. A GETNEXTALIAS() estava chegando³±±
±±³          ³ ao limite e reiniciando a numeracao, apresentando erro de alias in³±±
±±³          ³ use                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Os array aA GETNEXTALIAS() estava chegando ao limite e reiniciando ³±±
±±³          ³ a numeracao, apresentando erro de alias in use                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³SPEDGetAlias(ExpC)                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC -> PARAMETRO NAO OBRIGATORIO: Flag de controle para tornar o  ³±±
±±³          ³ alias mais exclusivo.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC -> Retorna o alias a ser utilizado e que não esteja aberto    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPEDGetAlias(cTabela)
Local	cArq		:=	"000000000"

Default	cTabela	:=	""

cTabela	:=	AllTrim(cTabela)
While Select("SF_"+cTabela+cArq)<>0
	cArq	:=	SOMA1(cArq)
End

Return "SF_"+cTabela+cArq


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SPEDLeRegs| Autor ³Gustavo G. Rueda  			   ³ Data ³28.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao efetua a leitura das informacoes gravadas pela funcao       ³±±
±±³          ³ SPEDRegs, conforme seu criterio de gravacao                       ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³1) Os array a serem passados devem seguir a ordem hierarquica de   ³±±
±±³          ³   gracao.                                                         ³±±
±±³          ³2) Para os registros que estiverem na sequencia mais nao correspon-³±±
±±³          ³   derem a hierarquia informada, deve ser passado no seguinte for- ³±±
±±³          ³   mato. Ex: (aReg,2}                                              ³±±
±±³          ³   a) O primeiro nivel corresponde ao registro;                    ³±±
±±³          ³   b) O segundo corresponde ao pai deste registro que nao eh o     ³±±
±±³          ³      antecessor. Um exemplo de utilizacao eh a geracao do bloco E.³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³SPEDRegs(cAlias,aRegs)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nHandle   -> Handle do arquivo texto                               ³±±
±±³          ³cAlias    -> Alias do TRB em processamento para gravar as informa- ³±±
±±³          ³             coes                                                  ³±±
±±³          ³aRegs     -> Array com os codigos de registros a serem tratados    ³±±
±±³          ³cRelac    -> Conteudo do campo TRB_RELAC do registro PAI gravado   ³±±
±±³          ³             fora desta funcao para relacionamento com seus filhos ³±±
±±³          ³nFor      -> Controle da recursividade (NAO USAR)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPEDLeRegs(nHandle,cAlias,aRegs,cRelac,nFor)
Local	nTamTRBIt	:=	Len((cAlias)->TRB_RELAC)/2	//Efetuo divisao por dois porque faco dois controles em um mesmo campo. O relacionamento e sequencia. Ex: ...0001...1, ...0001...2
Local	nX			:=	0
Local	nRecno		:=	0
Local	nPai		:=	0
Local	aAux  		:=	aClone(aRegs)
Local	lTemFil		:=	.T.
Local	nPosFil		:=	0
Local	cReg		:=	""
Local	cRelacPai	:=	""
Local	cRelacFil	:=	""

Default	nFor		:=	1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Percorrendo os registros a serem gerados segundo sua hierarquia (conforme passado no array).³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := nFor To Len(aRegs)
	cRelacPai	:=	SubStr(cRelac,1,nTamTRBIt)
	cRelacFil	:=	SubStr(cRelac,nTamTRBIt+1)
	nRecno		:=	(cAlias)->(Recno())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³No array aRegs, a hierarquia pode ser construida de duas formas:            ³
	//³1) Ordem dos registros formatados no array, ou;                             ³
	//³2) Cada determinado registro apesar de estar na sequencia, nao              ³
	//³    faz parte dela, pois seu pai correspondente eh outro de outro nivel     ³
	//³   da cadeia.                                                               ³
	//³                                                                            ³
	//³Ex:                                                                         ³
	//³1) {"C300","C310","C320","C321"}  --> Neste temos a sequencia correta       ³
	//³                                      a seguir, pois o array jah estah no   ³
	//³                                      ordem hierarquica correta.            ³
	//³                                                                            ³
	//³2) {"E210","E220","E230",{"E240",2},{"E250",1}} --> Neste exemplo,          ³
	//³                                     temos uma ordem ateh o registro E230,  ³
	//³                                     depois disso, a sequencia eh quebrada, ³
	//³                                     pois o pai do E240 nao eh o E230 e sim ³
	//³                                     o E220, cuja a indicacao eh o segundo  ³
	//³                                     nivel do array. O mesmo acontece com   ³
	//³                                     o E250, cujo pai e a primeira posicao, ³
	//³                                     o E210                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType(aRegs[nX])=="A"
		cReg	:=	aRegs[nX,1]
		nPai	:=	aRegs[nX,2]
	Else
		cReg	:=	aRegs[nX]
		nPai	:=	nX-1
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Este eh um tratamento para retornar a posicao, se tiver na cadeia,                 ³
	//³  outro registro fora da sequencia que seja filho deste em processamento.          ³
	//³                                                                                   ³
	//³Este tratamento eh necessario para que se nao encontrar o registro filho,          ³
	//³  seja verificado se pode abandonar o processamento, jah que nao tem mais          ³
	//³  filhos a verificar, ou se o filho estah fora da sequencia, neste caso vou direto ³
	//³  a ele no ELSEIF abaixo.                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPosFil	:=	aScan(aRegs,{|aX| ValType(aX)<>"C" .And. aX[2]==nPai},nX+1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento de buscao do filho correspondente ao pai em processamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTemFil .And. (lTemFil := (cAlias)->(MsSeek(cReg+cRelacFil)))

		While !(cAlias)->(Eof()) .And. (cAlias)->TRB_TPREG==cReg .And. SubStr((cAlias)->TRB_RELAC,1,nTamTRBIt)==cRelacFil

			If (cAlias)->TRB_FLAG<>"*"
				SPEDGrvLin(nHandle,cAlias)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Para que se procure um registro filho, deve-se fazer as seguintes verificacoes:               ³
				//³1) O array deve ter o tamanho compativel com o proximo nivel a ser processado;                ³
				//³2) Este proximo registro(filho) deve ter como ordem hierarquica a sequencia do array passado; ³
				//³3) Ou, no caso de array, o segundo indice que indica o Pai, deve ser o registro corrente, pois³
				//³    caso seja um que jah foi processado, nao preciso chamar a funcao recursica, pois nao irah ³
				//³    encontrar a correspondencia.                                                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Len(aAux)>=nX+1 .And. (ValType(aAux[nX+1])<>"A" .Or. (ValType(aAux[nX+1])=="A" .And. aAux[nX+1,2]>=nX))
					nRecno	:=	(cAlias)->(Recno())
					SPEDLeRegs(nHandle,cAlias,aAux,(cAlias)->TRB_RELAC,nX+1)
					(cAlias)->(dbGoTo(nRecno))
				EndIf
			EndIf

			(cAlias)->(dbSkip())
		End

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Este eh um tratamento para retornar a posicao, se tiver na cadeia,                 ³
		//³  outro registro fora da sequencia que seja filho deste em processamento.          ³
		//³                                                                                   ³
		//³Este tratamento eh necessario para que se nao encontrar o registro filho,          ³
		//³  seja verificado se pode abandonar o processamento, jah que nao tem mais          ³
		//³  filhos a verificar, ou se o filho estah fora da sequencia, neste caso vou direto ³
		//³  a ele no ELSEIF abaixo.                                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nPosFil := aScan(aRegs,{|aX| ValType(aX)<>"C" .And. aX[2]==nPai},nX+1))==0
			Exit
		Else
			nX		:=	nPosFil-1
		EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para seguir com o processamento. Ele se dah em duas situacoes:               ³
	//³1) Caso o registro PAI nao esteja na cadeia (nPai===0), isso significa que o registro   ³
	//³    principal (Nivel 1) nao foi encontrado, entao nao tem o que gerar, portanto continuo³
	//³    o processamento caso existam outros para serem gerados;                             ³
	//³                                                                                        ³
	//³2) No caso de o filho nao estar na sequencia passada, mas se referir a algum fora da    ³
	//³    sequencia, neste caso, deve-se posicionar no referido e processa-lo                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf nPai==0 .Or. (!lTemFil .And. nPosFil>0)

		(cAlias)->(dbGoTo(nRecno))

		If nPai<>0 .And. !lTemFil .And. nPosFil>0
			nX		:=	nPosFil-1
		EndIf

		lTemFil	:=	.T.
	Else
		Exit
	EndIf

Next nX

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SPEDVlBSRD| Autor ³Gustavo G. Rueda  			   ³ Data ³16.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao que retorna o valor de reducao da base de calculo do ICMS   ³±±
±±³          ³ utilizando a regra convencional (SENTO/OUTROS/BASE) ou recalcu-   ³±±
±±³          ³ conforme percentual de reducao gravada na tabela CD2              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpN1 := SPEDVlBSRD(lAchouCD2,cAliasCD2,lAchouSF4,cAliasSF4,;      ³±±
±±³          ³                    cAliasSFT,lCalcCD2)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lPar1 - Flag de registro valido para a tabela CD2                  ³±±
±±³          ³cPar2 - Alias da tabela CD2 para processamento                     ³±±
±±³          ³lPar3 - Flag de registro valido para a tabela SF4                  ³±±
±±³          ³cPar4 - Alias da tabela SF4 para processamento                     ³±±
±±³          ³cPar5 - Alias da tabela SFT para processamento                     ³±±
±±³          ³lPar6 - Flag que determina o tipo de tratamento para retorno do    ³±±
±±³          ³        valor de reducao. (.T.) conforme tabela CD2, (.F.) conforme³±±
±±³          ³        gravacao dos campos ISENTO/OUTROS/BASE                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1 - Valor de reducao da base de calculo                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPEDVlBSRD(lAchouCD2,cAliasCD2,lAchouSF4,cAliasSF4,cAliasSFT,lCalcCD2)
Local	nRedBSICM	:=	0
Local	lAtvPerm 	:= .F.
Local	lConsumo 	:= .F.
Local	nVlrRed		:=	0
Local	lNRPRBIC	:=  aSPDSX6[MV_NRPRBIC]		//Parâmetro indicando para não recalcular a parcelo referente a redução de base de cálculo de ICMS.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Identificacao de material de uso e consumo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Substr(Alltrim((cAliasSFT)->FT_CFOP),2,3)$"97 " .Or.;
	(Substr(Alltrim((cAliasSFT)->FT_CFOP),2,3)$"556" .And. Substr(Alltrim((cAliasSFT)->FT_CLASFIS),2,2)<>"40")
   	lConsumo := .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Identificacao de ativo permanente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Substr(Alltrim((cAliasSFT)->FT_CFOP),2,3)$"91 " .Or. Substr(Alltrim((cAliasSFT)->FT_CFOP),2,3)$"551"
	lAtvPerm := .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Leitura da tabela de imposto quebrada por IMPOSTO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAchouCD2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³While na tabela CD2 JAH FILTRADA para achar o percentual de reducao        ³
	//³  da base de calculo do ICM, pois eh utilizado em varios registros e nao eh³
	//³ correto utilizar do TES, pois pode nao existir SF4 ou nao corresponder ao ³
	//³ documento gerado, pois eh um cadastro e pode sofrer alteracoes.           ³
	//|Depois da nota gerada a informacao nao pode ser alterada, somente se       |
	//| excluir a NF e gerar de novo                                              |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nRedBSICM	:=	(cAliasCD2)->CD2_PREDBC

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao existir CD2, ae nao tem como, tem que pegar do TES³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf lAchouSF4
	nRedBSICM	:=	(cAliasSF4)->F4_BASEICM

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se houver reducao de base de calculo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRedBSICM>0

  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³Se o produto estiver amarrado a uma excecao fiscal e o TES nao ³
  //³calcula ICMS e livros Fiscais = ISENTO, Red. de Base retorna 0 ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  If (cAliasSF4)->F4_LFICM == "I" .And. (cAliasSF4)->F4_ICM == "N"
  	nVlrRed	:= 0
  Else

  	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se efetuar o tratamento de reducao via CD2, refaco o calculo utilizando³
	//³ o % gravado na tabela.                                                ³
	//³                                                                       ³
	//³Se NAO efetuar o tratamento via CD2, faco o processamento utilizando   ³
	//³ os valores gravados em OUTROS/ISENTO/BASE                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCalcCD2
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³As reducoes de base se comportam diferente para Ativo Fixo/Mat. de uso/consumo³
		//³ que o restante das operacoes.                                                ³
		//³                                                                              ³
		//³Para Ativo Fixo e/ou Material de Uso e Consumo, sempre a base do ICMS eh      ³
		//³ escriturado como outros, e quando cabe reducao de base de calculo, uma       ³
		//³ parte fica em outros e o valor da reducao vai para isento.                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAtvPerm .Or. lConsumo
			nVlrRed	:=	(cAliasSFT)->(FT_OUTRICM+FT_ISENICM)
			nVlrRed	-=	(cAliasSFT)->(FT_OUTRICM+FT_ISENICM)*nRedBSICM/100
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso a base de calculo do ICMS seja zero, deve-se realizar o calculo da reducao de base pelos livros 			   ³
			//³Outros/Isento, pois a variavel nRedBSICM indica que existe reducao na nf,e a mesma deve ser levada para o campo 10  ³
			//³do registro C190 do Sped Fiscal                                                                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (cAliasSFT)->FT_BASEICM == 0
				If (cAliasSFT)->FT_OUTRICM > 0
					nVlrRed	:=	(cAliasSFT)->FT_OUTRICM
				ElseIf (cAliasSFT)->FT_ISENICM > 0
					nVlrRed	:=	(cAliasSFT)->FT_ISENICM
				EndIf
				//Irá fazer cálculo se parâmetro MV_NRPRBIC estiver igual a .F.
				If !lNRPRBIC
					nVlrRed := nVlrRed - (nVlrRed * (nRedBSICM/100))
				EndIF
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o parâmetro MV_NRPRBIC estiver como .T. não irá refazer o cálculo da parcela de ICMS referente a redução de base de cálculo,³
				//³	e sim irá considerar o valor jpa gravado na SFT no campo FT_OUTRICM ou FT_ISENICM.                                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lNRPRBIC
					If (cAliasSFT)->FT_ISENICM > 0
						nVlrRed	:=	(cAliasSFT)->FT_ISENICM
					ElseIf (cAliasSFT)->FT_OUTRICM > 0
						nVlrRed	:=	(cAliasSFT)->FT_OUTRICM
					EndIF
				Else
					nVlrRed	:=	((cAliasSFT)->FT_BASEICM*100)/nRedBSICM
					nVlrRed	-=	(cAliasSFT)->FT_BASEICM
				EndIF
			EndIf
		EndIf

	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³As reducoes de base se comportam diferente para Ativo Fixo/Mat. de uso/consumo³
		//³ que o restante das operacoes.                                                ³
		//³                                                                              ³
		//³Para Ativo Fixo e/ou Material de Uso e Consumo, sempre a base do ICMS eh      ³
		//³ escriturado como outros, e quando cabe reducao de base de calculo, uma       ³
		//³ parte fica em outros e o valor da reducao vai para isento.                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAtvPerm .Or. lConsumo
			If (cAliasSFT)->FT_OUTRICM>0 .And. (cAliasSFT)->FT_ISENICM>0
				nVlrRed	:=	(cAliasSFT)->FT_ISENICM
			EndIf

		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso a base de calculo do ICMS seja zero, deve-se realizar o calculo da reducao de base pelos livros 			   ³
			//³Outros/Isento, pois a variavel nRedBSICM indica que existe reducao na nf,e a mesma deve ser levada para o campo 10  ³
			//³do registro C190 do Sped Fiscal                                                                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (cAliasSFT)->FT_BASEICM == 0
				If (cAliasSFT)->FT_OUTRICM > 0
					nVlrRed	:=	(cAliasSFT)->FT_OUTRICM
				ElseIf (cAliasSFT)->FT_ISENICM > 0
					nVlrRed	:=	(cAliasSFT)->FT_ISENICM
				EndIf
				//Irá fazer cálculo se parâmetro MV_NRPRBIC estiver igual a .F.
				If !lNRPRBIC
					nVlrRed := nVlrRed - (nVlrRed * (nRedBSICM/100))
				EndIf
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Para os casos de reducao normal de base de calculo, uma parte eh  ³
				//³ tributado e outra (reducao) vai para a coluna OUTROS ou ISENTO   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (cAliasSFT)->FT_BASEICM>0 .And. (cAliasSFT)->FT_OUTRICM>0
					nVlrRed	:=	(cAliasSFT)->FT_OUTRICM
				EndIf

				If (cAliasSFT)->FT_BASEICM>0 .And. (cAliasSFT)->FT_ISENICM>0
					nVlrRed	:=	(cAliasSFT)->FT_ISENICM
				EndIf
			EndIf
		EndIf
	EndIf
  EndIf
EndIf
Return nVlrRed

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SpedCkApST³ Autor ³Gustavo G. Rueda       ³ Data ³22.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao utilizada processar alguns valores de ICMS/ST por UF,³±±
±±³          ³ baseado no array aApuracao passado por parametro que eh o  ³±±
±±³          ³ resultado da chamada da RESUMEF3.                          ³±±
±±³          ³Estas informacoes irao compor o registro E210               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1 -> Retorna um array com as informacoes necessarias    ³±±
±±³          ³         para gerar alguns campos do registro E210:         ³±±
±±³          ³         [1] Valor a ser levado no campo 3 do registro E210 ³±±
±±³          ³         [2] Valor a ser levado no campo 4 do registro E210 ³±±
±±³          ³         [3] Valor a ser levado no campo 6 do registro E210 ³±±
±±³          ³         [4] Valor a ser levado no campo 8 do registro E210 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aApuracao -> Array com o retorno da cahamada da RESUMEF3    ³±±
±±³          ³nApuracao	-> Variavel que define o tipo de apuracao. Padrao ³±±
±±³          ³             = 3 = Mensal                                   ³±±
±±³          ³nPeriodo  -> Identifica o periodo, Padrao 1 = 1. periodo    ³±±
±±³          ³cNrLivro  -> Numero do livro a ser tratado                  ³±±
±±³          ³cArqAnt   -> Arquivo do periodo anterior caso seja informado³±±
±±³          ³cMVEstado -> Conteudo do paramentro MV_ESTADO               ³±±
±±³          ³cUF       -> UF a ser considerado no processamento          ³±±
±±³          ³cMVSUBTRIB-> Conteudo do parametro MV_SUBTRIB               ³±±
±±³          ³dDataRef  -> Data final do periodo selecionado              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SpedCkApST(aApuracao,nApuracao,nPeriodo,cNrLivro,cArqAnt,cMVEstado,cUF,cMVSUBTRIB,dDataRef)
Local	nX			:=	0
Local	nMes 		:=	Month(dDataRef)
Local	nAno		:=	Year(dDataRef)
Local	lArqAnt		:=	aSPDSX6[MV_APURANT]
Local	cMVCFE210	:=	SpedPrSeq("MV_CFE210","1410,1411,1414,1415,1660,1661,1662,2410,2411,2414,2415,2660,2661,2662")
Local	cMVCFERES	:=	SpedPrSeq("MV_CFERES","1603,2603")
Local	aRetorno	:=	{0,0,0,0,0}

For nX := 1 to len(aApuracao)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa entradas e devolucoes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aApuracao[nX,1]==cUF .And. SubStr(AllTrim(aApuracao[nX,2]),1,1)$"1256"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para as entradas³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Val(SubStr(AllTrim(aApuracao[nX,2]),1,1))<=2
			If AllTrim(aApuracao[nX,2])$cMVCFERES
				aRetorno[5]	+= 	aApuracao[nX,3] 	//Ressarcimento ICMS
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Para as notas fiscais de entrada tipo devolucao, apos retorno da SEFAZ e analise das regras do layout e validacao do PVA,³
			//³  chegou-se a seguinte conclusao:                                                                                        ³
			//³                                                                                                                         ³
			//³Para as notas fiscais de entrada tipo devolucao, o valor de ICMS/ST somente deverah ser considerado nos registro C100,   ³
			//³  C170, C190 e E210, quando o contribuinte tiver IE no estado emitente do documento (FT_ESTADO estah contido no          ³
			//³  SUBTRIB), caso contrario deverah levar ZERO nos respectivos campos, pois a NF original, a de saida, teve o ICMS/ST     ³
			//³  recolhido antecipadamente, nao tendo como compensar o credito. Quando houver IE no estado do emitente, segue o fluxo   ³
			//³  normal, pois como o valor do ICMS/ST serah recolhido via Auracao, terah com compensar o debito pelo credito.           ³
			//³                                                                                                                         ³
			//³Base legal: Alteracao efetuada conforme FNC 00000001419/2011, que contem uma consulta da SEFAZ embasando o entendimento  ³
			//|  acmia.                                                                                                                 |
			//³                                                                                                                         ³
			//³ Alteracao 19.08.2011 - FNC 00000016165/2011-01                                                                          ³
			//³ Tratamento para acordo entre os estados preenchidos no parametro MV_STNIEUF, quando em um movimento com ICMS-ST NAO e'  ³
			//³ necessario ter Incsc.Est. (MV_SUBTRIB NAO preenchido) Este tratamento foi feit a partir da necessidade das UF d MG p/ PR³
			//³ onde existe esse acordo. PROTOCOLO ICMS CONSELHO NACIONAL DE POLÍTICA FAZENDÁRIA - CONFAZ Nº 191 DE 11.12.2009          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf (aApuracao[nX,1]==cMVEstado .Or. (!aApuracao[nX,1]==cMVEstado .And. (aApuracao[nX,1]$cMVSUBTRIB .OR. ((cMVEstado+aApuracao[nX,1])$AllTrim(aSPDSX6[MV_STNIEUF]))))) .And. AllTrim(aApuracao[nX,2])$cMVCFE210
		 		aRetorno[2] += aApuracao[nX,4]		//Valor ICMS - ST
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Mesmo estado do contribuinte³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		 	Elseif aApuracao[nX,1]==cMVEstado .And. aApuracao[nX,1]==cUF
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Credito de ST por entrada soh sera considerado quando do mesmo estado do contribuinte ³
				//³ Conforme descrito no MATA953 (consulta IOB em 01/11/2006)                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		 		aRetorno[3]	+= 	aApuracao[nX,3] 	//Valor ICMS - ST
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Outros estados que ele tambem tem inscricao, mais que nao eh³
			//³  o mesmo dele                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Else
		   		aRetorno[3] += aApuracao[nX,4] 	//Valor ICMS - ST
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Mesmo estado do contribuinte³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aApuracao[nX,1]==cMVEstado
				aRetorno[4] 	+= aApuracao[nX,3] 	//Valor ICMS - ST
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Outros estados que ele tambem tem inscricao, mais que nao eh³
			//³  o mesmo dele                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Else
				aRetorno[4] += aApuracao[nX,5] 	//Valor ICMS - ST
            EndIf
	 	EndIf
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso o parametro indique, o nome do arquivo do periodo anterior³
//³sera montado automaticamente pela rotina.                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cArqAnt)
	If lArqAnt
		If nMes == 1
			nAno := nAno - 1
			nMes := 12
		Else
			nMes := nMes - 1
		Endif

		cArqAnt := NmArqApur("ST",nAno,nMes,nApuracao,nPeriodo,cNrLivro)
	Endif
EndIf

// Se o nome foi preenchido ou montado
If !Empty(cArqAnt)
	cArqAnt := AllTrim(cArqAnt)
   	nValor := LoadAnt(substr(cArqAnt,1,Len(cArqAnt)-3)+"ST"+substr(cArqAnt,Len(cArqAnt),1),"1"+cUF)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³So' soma se o valor retornado na variavel nValor for negativo, ³
	//³pois assim sabemos que se trata de um cre'dito do periodo      ³
	//³anterior. Nao somando os valores de de'bito ST.                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRetorno[1]	+= Iif(nValor<0,Abs(nValor),0)
EndIf

Return aRetorno

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±³ÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ±±
±±³Programa  ³SpedApDoc ³ Autor ³Gustavo G. Rueda       ³ Data ³31.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao utilizada para obter alguns valores de de apuracao   ³±±
±±³          ³ durante o processamento dos documentos fiscais.            ³±±
±±³          ³Os calculos abaixos foram copiados do programa FISXAPUR,    ³±±
±±³          ³ portanto qualquer alteracao que haja lah ou aqui, ela deve ³±±
±±³          ³ ser replicada, pois ambas devem chegar ao mesmo VALOR      ³±±
±±³          ³Ela foi replicada para economizar processamento, pois se    ³±±
±±³          ³ chamassemos a RESUMEF3, processaria o livro fiscal duas    ³±±
±±³          ³ vezes, tornando a rotina muito lenta.                      ³±±
±±³          ³                                                            ³±±
±±³          ³O array aApuracao desta rotina corresponde ao array         ³±±
±±³          ³ aApuracao da RESUMEF3 da seguinte forma:                   ³±±
±±³          ³                                                            ³±±
±±³          ³aApuracao[1](SPEDFISCAL) eh igual ao aApuracao[08](FISXAPUR)³±±
±±³          ³aApuracao[2](SPEDFISCAL) eh igual ao aApuracao[12](FISXAPUR)³±±
±±³          ³aApuracao[3](SPEDFISCAL) eh igual ao aApuracao[13](FISXAPUR)³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1 -> Retorna um array com as informacoes necessarias    ³±±
±±³          ³         para gerar alguns campos do registro E210:         ³±±
±±³          ³         [1] UF do documento                                ³±±
±±³          ³         [1] CFOP do item do documento                      ³±±
±±³          ³         [2] Valor total de ICMS/ST das devolucoes          ³±±
±±³          ³         [3] Valor total de ajustes Outros Creditos e/ou    ³±±
±±³          ³             Estorno de debitos                             ³±±
±±³          ³         [4] Valor total de ICMS Retido por ST              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cEntSai   -> Flag de entrada=1,saida=2                      ³±±
±±³          ³cMv_StUfS	-> Conteudo do parametro MV_STUFS                 ³±±
±±³          ³cMv_StUf	-> Conteudo do parametro MV_STUF                  ³±±
±±³          ³lResF3FT  -> Conteudo do parametro MV_RESF3FT               ³±±
±±³          ³cAliasSFT -> Alias para a tabela SFT (QUERY)                ³±±
±±³          ³lUsaSped  -> Conteudo do parametro MV_USASPED               ³±±
±±³          ³lImpCrdST -> Opcao configurada no WIZARD da rotina          ³±±
±±³          ³aCmpAntSFT-> Campos de cabecalho do documento               ³±±
±±³          ³cMVEstado -> Conteudo do parametro MV_ESTADO                ³±±
±±³          ³aRetorno -> Variavel a ser retornada por referencia         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SpedApDoc(cEntSai,cMv_StUfS,cMv_StUf,lResF3FT,cAliasSFT,lUsaSped,lImpCrdST,aCmpAntSFT,cMVEstado,aRetorno)
Local	lSTSaida 	:= .F.
Local	lProcST		:= .T.
Local	aApuracao	:=	{0,0,0}
Local	nPos		:=	0
Local	lMVUFICSEP	:= cMvEstado$aSPDSX6[MV_UFICSEP]

//----------------------------------- INICIO DO TRECHO COPIADO DO FISXAPUR ----------------------------------//

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Trecho copiado do FISXAPUR, se houver alteracao lah, ela deve refletir aqui. O inverso tambem.³
//|                                                                                              ³
//³Tratamento para os valores de ICMS Retido na SAIDA                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cEntSai=="2"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica a existencia do parametro para ICMS Retido na saida.³
	//³Caso esteja preenchido, apenas as UFs indicadas no mesmo     ³
	//³devem ser processadas na saida. Caso contrario, a regra do   ³
	//³MV_STUF foi mantida (tanto para entradas como para saidas),  ³
	//|codigo mais abaixo                                           |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cMv_StUfS)

		If (cAliasSFT)->FT_ESTADO $ cMv_StUfS

			If lResF3FT
				If lUsaSped
					aApuracao[1]	+=	(cAliasSFT)->(Iif(FT_ICMSRET>0,FT_ICMSRET,FT_OBSSOL))-(cAliasSFT)->(IIF(!lMVUFICSEP.Or.Left(FT_CFOP,1)<>'5'.Or.FT_TIPO$"BD",0,FT_VFECPST)) 	//ICMSRET
				Else
					If cMvEstado$"RJ"
						If (cAliasSFT)->FT_ESTADO$"RJ"
							aApuracao[1]	+=	(cAliasSFT)->(Iif(FT_ICMSRET>0,FT_ICMSRET,FT_OBSSOL)) 	//ICMSRET
						EndIf
					Else
						aApuracao[1]	+=	(cAliasSFT)->(Iif(FT_ICMSRET>0,FT_ICMSRET,FT_OBSSOL))-(cAliasSFT)->(IIF(!lMVUFICSEP.Or.Left(FT_CFOP,1)<>'5'.Or.FT_TIPO$"BD",0,FT_VFECPST)) 		//ICMSRET
					EndIf
				EndIf
				lSTSaida := .T.

			Else
				If lUsaSped
					aApuracao[1]	+= SF3->F3_ICMSRET-SF3->(IIF(!lMVUFICSEP.Or.Left(F3_CFO,1)<>'5'.Or.F3_TIPO$"BD",0,F3_VFECPST))	//ICMSRET
				Else
					If cMvEstado$"RJ"
						aApuracao[1]	+=	Iif(SF3->F3_ESTADO$cMvEstado,SF3->F3_ICMSRET,0) 	//ICMSRET
					Else
						aApuracao[1]	+=	SF3->F3_ICMSRET-SF3->(IIF(!lMVUFICSEP.Or.Left(F3_CFO,1)<>'5'.Or.F3_TIPO$"BD",0,F3_VFECPST))	//ICMSRET
					EndIf
				EndIf
				lSTSaida := .T.
			Endif
		Else
			lProcST := .F.
		Endif
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Trecho copiado do FISXAPUR, se houver alteracao lah, ela deve refletir aqui. O inverso tambem.³
//|                                                                                              ³
//³Tratamento para os valores de ICMS Retido das ENTRADAS e SAIDAS                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (!Empty(cMv_StUf) .And. (cAliasSFT)->FT_ESTADO$cMv_StUf) .Or. Empty(cMv_StUf)

	If !lSTSaida .And. lProcST

		If lResF3FT
			If lUsaSped
				aApuracao[1]	+= (cAliasSFT)->(Iif(FT_ICMSRET>0,FT_ICMSRET,FT_OBSSOL)) 	//ICMSRET
			Else
				If cMvEstado$"RJ"
					If (cAliasSFT)->FT_ESTADO$cMvEstado
						aApuracao[1]	+=	(cAliasSFT)->(Iif(FT_ICMSRET>0,FT_ICMSRET,FT_OBSSOL)) 	//ICMSRET
					EndIf
				Else
					aApuracao[1]	+=	(cAliasSFT)->(Iif(FT_ICMSRET>0,FT_ICMSRET,FT_OBSSOL)) 		//ICMSRET
				EndIf
			EndIf
		Else
			If lUsaSped
				aApuracao[1] += SF3->F3_ICMSRET
			Else
				If cMvEstado$"RJ"
					aApuracao[1]	+=	Iif(SF3->F3_ESTADO$cMvEstado,SF3->F3_ICMSRET,0) 	//ICMSRET
				Else
					aApuracao[1]	+=	SF3->F3_ICMSRET 	//ICMSRET
				EndIf
			EndIf
		Endif
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para o ICMS Solidario conforme configuracao do CredST.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lResF3FT .And. (cAliasSFT)->FT_SOLTRIB>0
	If (cAliasSFT)->FT_CREDST$" #1"
		If lImpCrdSt .And. (((!Empty(cMv_StUf) .And. (cAliasSFT)->FT_ESTADO$cMv_StUf) .Or. Empty(cMv_StUf)) .And.lProcST) .Or. lSTSaida
   	    	If lUsaSped
				aApuracao[1]	-=	(cAliasSFT)->FT_SOLTRIB
			Else
		   		If cMvEstado$"RJ"
		   			If (cAliasSFT)->FT_ESTADO$cMvEstado
			   			aApuracao[1]	-=	(cAliasSFT)->FT_SOLTRIB
		   			EndIf
		   		Else
		   			aApuracao[1]	-=	(cAliasSFT)->FT_SOLTRIB
		   		EndIf
			EndIf
		EndIf

	ElseIf (cAliasSFT)->FT_CREDST=="3"
		If lUsaSped
			aApuracao[1]	-=	IIf(lImpCrdSt,(cAliasSFT)->FT_SOLTRIB,(cAliasSFT)->(Iif(FT_ICMSRET>0,FT_ICMSRET,FT_OBSSOL)))
		Else
	   		If cMvEstado$"RJ"
	   			If (cAliasSFT)->FT_ESTADO$cMvEstado
					aApuracao[1]	-=	IIf(lImpCrdSt,(cAliasSFT)->FT_SOLTRIB,(cAliasSFT)->(Iif(FT_ICMSRET>0,FT_ICMSRET,FT_OBSSOL)))
				EndIf
			Else
				aApuracao[1]	-=	IIf(lImpCrdSt,(cAliasSFT)->FT_SOLTRIB,(cAliasSFT)->(Iif(FT_ICMSRET>0,FT_ICMSRET,FT_OBSSOL)))
			EndIf
		EndIf
	EndIf

ElseIf SF3->F3_SOLTRIB>0
	If SF3->F3_CREDST$" #1"
		If lImpCrdSt .And. (((!Empty(cMv_StUf) .And. SF3->F3_ESTADO$cMv_StUf) .Or. Empty(cMv_StUf)) .And. lProcST) .Or. lSTSaida
			If lUsaSped
				aApuracao[1]	-=	SF3->F3_SOLTRIB
			Else
		   		If cMvEstado$"RJ"
		   			If SF3->F3_ESTADO$cMvEstado
						aApuracao[1]	-=	SF3->F3_SOLTRIB
		   			EndIf
		   		Else
					aApuracao[1]	-=	SF3->F3_SOLTRIB
				EndIf
			EndIf
		EndIf
	EndIf

ElseIf SF3->F3_CREDST=="3"
	If lUsaSped
		aApuracao[1]	-=	SF3->(IIf(lImpCrdSt,F3_SOLTRIB,F3_ICMSRET))
	Else
   		If cMvEstado$"RJ"
   			If SF3->F3_ESTADO$cMvEstado
				aApuracao[1]	-=	SF3->(IIf(lImpCrdSt,F3_SOLTRIB,F3_ICMSRET))
			EndIf
		Else
			aApuracao[1]	-=	SF3->(IIf(lImpCrdSt,F3_SOLTRIB,F3_ICMSRET))
		EndIf

	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ICMS Retido Fonte - PB-RICMS Anexo 46                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cEntSai=="2"
	If cMvEstado$"PB" .And. aSPDSX3[FP_A1_REGPB]
		If aCmpAntSFT[37]=="1"
			aApuracao[1] -= (cAliasSFT)->FT_ICMSRET
		Endif
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processamento das notas fiscais de entrada tipo DEVOLUCAO. Devolucao de vendas com ICMS Retido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cEntSai=="1" .And. (cAliasSFT)->FT_TIPO=="D"
	If lResF3FT
		If (cAliasSFT)->FT_CREDST<>"4"
			aApuracao[2]	+=	(cAliasSFT)->(Iif(FT_ICMSRET>0,FT_ICMSRET,FT_OBSSOL))	//ICMSRET
		Endif

	Else
		If SF3->F3_CREDST<>"4"
			aApuracao[2]	+=	SF3->F3_ICMSRET
		Endif
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processamento das Notas Fiscais de SAIDA tipo NORMAL para obter o valor do ICMS Retido na SAIDA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf cEntSai=="2" .And. (cAliasSFT)->FT_TIPO!="D"
	If lResF3FT
		aApuracao[3]	+=	(cAliasSFT)->(Iif(FT_ICMSRET>0,FT_ICMSRET,FT_OBSSOL))	//ICMSRET
	Else
		aApuracao[3]	+=	SF3->F3_ICMSRET
	Endif
EndIf


//----------------------------------- FIM DO TRECHO COPIADO DO FISXAPUR ----------------------------------//

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para cumulatividade de valor por UF+CFOP³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nPos := aScan(aRetorno,{|aX|aX[1]==(cAliasSFT)->FT_ESTADO .And. aX[2]==(cAliasSFT)->FT_CFOP}))==0
	aAdd(aRetorno,{(cAliasSFT)->FT_ESTADO,(cAliasSFT)->FT_CFOP,aApuracao[1],aApuracao[2],aApuracao[3]})
Else
	aRetorno[nPos,3]	+=	aApuracao[1]
	aRetorno[nPos,4]	+=	aApuracao[2]
	aRetorno[nPos,5]	+=	aApuracao[3]
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SpedBGCIAP| Autor ³Gustavo G. Rueda 			   ³ Data ³18.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao utilizada para montar um array com as informacoes dos       ³±±
±±³          ³ documentos de acordo com o tipo de movimento para gerar os        ³±±
±±³          ³ registro G130 e G140                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lTop       -> Flag que indica processamento em ambiente TOP        ³±±
±±³          ³lAchouSN3  -> Flag de SEEK da tabela SN1 e SN3                     ³±±
±±³          ³lAchouSD1  -> Flag que indica posicionamento da tabela SD1 para o  ³±±
±±³          ³  documento de entrada                                             ³±±
±±³          ³cMVF9CTBCC -> Conteudo do parametro MV_F9CTBCC                     ³±±
±±³          ³aCmpsSF9   -> Informacoes processadas atraves de parametros para   ³±±
±±³          ³   dados dos documentos de entrada que nao existam no sistema      ³±±
±±³          ³lCtbInUse  -> Flag que determina se eh CTB ou SIGACON              ³±±
±±³          ³cMVF9GENCC -> Conteudo do parametro MV_F9GENCC, centro de custo    ³±±
±±³          ³              generico para quando o fluxo padrao do sistema não   ³±±
±±³          ³              encontrar no cadastro.                               ³±±
±±³          ³cMVF9GENCT -> Conteudo do parametro MV_F9GENCT, conta contabil     ³±±
±±³          ³              generico para quando o fluxo padrao do sistema não   ³±±
±±³          ³              encontrar no cadastro.                               ³±±
±±³          ³lF9SKPNF   -> Conteudo do paramentro MV_F9SKPNF                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SpedBGCIAP(lAchouSB1,lAchouSN3,lAchouSD1,cMVF9CTBCC,aCmpsSF9,lCtbInUse,cMVF9GENCC,cMVF9GENCT,lF9SKPNF,lConcFil,lExtratTAF)
Local	cCContab	:=	""
Local	cCCusto		:=	""
Local	cFuncaoBem	:=	""
Local   cFilConta	:=  ""
Local   cFilCCusto	:=  ""

Default	lF9SKPNF	:= .F.
DEFAULT 	lConcFil	:= .T.
Default	lExtratTAF	:= .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para obter a filial da tabela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lConcFil
	If lCtbInUse
		cFilConta	:=	xFilial("CT1")
		cFilCCusto	:=	xFilial("CTT")
	Else
		cFilConta	:=	xFilial("SI1")
		cFilCCusto	:=	xFilial("SI3")
	EndIf
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faco a seguinte ordem de pesquisa:                                      ³
//³                                                                        ³
//³Primeiro procuro SN3;                                                   ³
//³Se nao encontrar, localizo a NF;                                        ³
//³Se nao encontrar, conforme parametro MV_F9CTBCC, utilizo a informacao do³
//³  produto (se tiver) ou do proprio SF9                                  ³
//³                                                                        ³
//³Porém caso o parâmetro MV_F9SKPNF estiver habilitado, toda a ordem      ³
//³ de pesquisa deve ser ignorada, assim buscando todas as informações da  ³
//³ tabela SF9                                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAchouSN3
	cCContab	:=	SN3->N3_CCONTAB
	cCCusto		:=	SN3->N3_CUSTBEM
	cFuncaoBem	:=	SN3->N3_HISTOR

ElseIf lAchouSD1 .And. Len(Alltrim(SD1->D1_CONTA))>0 .And. Len(Alltrim(SD1->D1_CC))>0
	cCContab	:=	SD1->D1_CONTA
	cCCusto		:=	SD1->D1_CC


Else
	If cMVF9CTBCC=="1" .And. lAchouSB1
		cCContab	:=	SB1->B1_CONTA
		cCCusto		:=	SB1->B1_CC
	Else
		cCContab	:=	aCmpsSF9[14]
		cCCusto		:=	aCmpsSF9[12]
	EndIf

EndIf

if !lAchouSN3 .And. !empty(aCmpsSF9[10])
	cFuncaoBem	:=	aCmpsSF9[10]
Elseif 	!lAchouSN3 .And. empty(aCmpsSF9[10])
    cFuncaoBem	:= SF9->F9_FUNCIT
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para quando for setado atraves do parametro para nao utilizar³
//³  as informacoes do documento fiscal                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lF9SKPNF
	cCContab	:=	aCmpsSF9[14]
	cCCusto		:=	aCmpsSF9[12]
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento dos parametro abaixo para quando o tratamento acima retornar BRANCO, ou seja,       ³
//³  nao encontrar a informacoes atraves das amarracoes do sistema. Estes parametros possibilitam ³
//³  um tratamento generico para o centro de custo e a conta contabil.                            ³
//³                                                                                               ³
//³cMVF9GENCC -> Conteudo do parametro MV_F9GENCC                                                 ³
//³cMVF9GENCT -> Conteudo do parametro MV_F9GENCT                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cCContab)
	cCContab	:=	PadR(cMVF9GENCT,TamSx3("B1_CONTA")[1])
EndIf
If Empty(cCCusto)
	cCCusto		:=	PadR(cMVF9GENCC,TamSx3("B1_CC")[1])
EndIf
If !lExtratTAF
	cCContab	:=	cCContab+cFilConta
	cCCusto		:=	cCCusto+cFilCCusto
EndIf

Return{cCContab,cCCusto,cFuncaoBem}

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SpedBGQf9 | Autor ³Gustavo G. Rueda 			   ³ Data ³17.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao para retornar a quantidade de registros na tabela SF9 de    ³±±
±±³          ³ determinado item de entrada, nos casos de desmembramento de bens. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cNumnota - Numero da NF de entrada                                 ³±±
±±³          ³dtDigit  - Data de digitacao da NF de entrada                      ³±±
±±³          ³cSerie   - Serie da NF de entrada                                  ³±±
±±³          ³cFor     - Fornededor da NF de entrada                             ³±±
±±³          ³cLojaFor - Loja do Fornecedor da NF de entrada                     ³±±
±±³          ³cItem    - Item da NF de entrada                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SpedBGQf9(cNumnota,dtDigit,cSerie,cFor,cLojaFor,cItem)
Local	nCont		:=	0
Local	aAreaSF9	:=	SF9->(GetArea())

dbSelectArea("SF9")
SF9->(dbSetOrder(2))
If SF9->(dbSeek(xFilial("SF9")+DToS(dtDigit)+cNumnota+cSerie+cFor+cLojaFor))
	While SF9->(!Eof() .And. F9_ITEMNFE==cItem .And. F9_DTENTNE==dtDigit .And. F9_DOCNFE==cNumnota .And. F9_SERNFE==cSerie .And. F9_FORNECE==cFor .And. F9_LOJAFOR==cLojaFor)
		nCont += 1
		SF9->(dbskip())
	EndDo
EndIf

RestArea(aAreaSF9)
Return nCont

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SpedPrSeq | Autor ³Gustavo G. Rueda              ³ Data ³03.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao para ler varios paramentros que se iniciam com o mesmo      |±±
±±³          ³ nome. Ex: MV_DCTF??? onde pode ser MV_DCTF000, MV_DCTF001,        ³±±
±±³          ³etc...                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpN1 := SpedPrSeq(cPar,cContPad)                                   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cRet -> Conteudo do parametro                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cPar -> Nome do parametro                                          ³±±
±±³          ³cContPad -> Conteudo padrao a ser retornado caso o mesmo nao       ³±±
±±³          ³ exista.                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SpedPrSeq(cPar,cContPad)
Local	cRet	:=	""

Default	cPar	:=	""

cPar	:=	AllTrim(cPar)

//Leitura exclusiva
If SX6->(DbSeek (cFilAnt+cPar))
	Do While !SX6->(Eof ()) .And. (cPar$SX6->X6_VAR) .And. (cFilAnt==SX6->X6_FIL)
		If !Empty(SX6->X6_CONTEUD)
			cRet	+=	"/"+AllTrim (SX6->X6_CONTEUD)
		EndIf
		SX6->(DbSkip ())
	EndDo
EndIf

//Leitura Compartilhada
If SX6->(DbSeek (PadR("",FWGETTAMFILIAL)+cPar))
	Do While !SX6->(Eof ()) .And. (cPar$SX6->X6_VAR) .And. Empty(SX6->X6_FIL)
		If !Empty(SX6->X6_CONTEUD)
			cRet	+=	"/"+AllTrim (SX6->X6_CONTEUD)
		EndIf
		SX6->(DbSkip ())
	EndDo
EndIf

If Empty(cRet)
	cRet	:=	Iif(cContPad<>Nil,cContPad,"")
EndIf

If cPar=="MV_SUBTRI" .And. Empty(cRet)
	cRet := GetSubTrib()
Endif

Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |SpedProSE1 ³ Autor ³Gustavo G. Rueda       ³ Data ³15.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³            PROCESSAMENTO DO CONTAS A RECEBER               ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Filtro os titulos do documento fiscal                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aParc -> Array com as parcelas do documento fiscal, onde:   ³±±
±±³          ³ [1]=Tipo                                                   ³±±
±±³          ³ [2]=Historico                                              ³±±
±±³          ³ [3]=Numero                                                 ³±±
±±³          ³ [4]=Parcela                                                ³±±
±±³          ³ [5]=Vencimento Real                                        ³±±
±±³          ³ [6]=Valor                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|aCmpAntSFT -> Informacoes do cabecalho do documento         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SpedProSE1(aCmpAntSFT, lSeek)
	Local	aParc		:=	{}
	Local	cPrefixo	:= 	aCmpAntSFT[27]
	Local 	cTipoTit	:=	aSPDSX6[MV_C140TIT]
	Local	cNum		:=	Iif(Empty(aCmpAntSFT[28]) ,Space(TamSX3("F2_DUPL")[1]),aCmpAntSFT[28])
	Local	cCli		:=	aCmpAntSFT[3]
	Local	cLoj		:=	aCmpAntSFT[4]
	Local	cAliasSE1	:=	"SE1"
	Local cFilSE1   := xFilial("SE1")

	Default lSeek       := .F.

	SE1->(DbSetOrder (2))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para quando o PREFIXO nao estiver gravado no documento fiscal³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cPrefixo)
		aAreaSF2	:=	SF2->(GetArea())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o prefixo nao estiver gravado no documento fiscal, tenho que utilizar o parametro MV_1DUPREF,³
		//³ porem o parametro eh uma macro e pode abranger ateh um rdmake, para isso, temos que manter     ³
		//³ o padrao de chamada da mesma forma do MATA461, o SF2 deve estar posicionado.                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SF2->(MsSeek(xFilial("SF2")+aCmpAntSFT[1]+aCmpAntSFT[2]+aCmpAntSFT[3]+aCmpAntSFT[4]))

		cPrefixo	:= 	&(aSPDSX6[MV_1DUPREF])

		RestArea(aAreaSF2)
	EndIf

	#IFDEF TOP
		If lNotAs400 .And. !lSeek
			cAliasSE1	:=	GetNextAlias()

			BeginSql Alias cAliasSE1

			COLUMN E1_VENCTO AS DATE
			COLUMN E1_VENCREA AS DATE

			SELECT
				SE1.E1_FILIAL,SE1.E1_PREFIXO,SE1.E1_NUM,SE1.E1_PARCELA,SE1.E1_TIPO,SE1.E1_CLIENTE,SE1.E1_LOJA,
				SE1.E1_HIST,SE1.E1_VENCREA,SE1.E1_VALOR,SE1.E1_VLCRUZ,SE1.E1_VENCTO
			FROM
				%Table:SE1% SE1
			WHERE
				SE1.E1_FILIAL=%xFilial:SE1% AND
				SE1.E1_CLIENTE=%Exp:cCli% AND
				SE1.E1_LOJA=%Exp:cLoj% AND
				SE1.E1_PREFIXO=%Exp:cPrefixo% AND
				SE1.E1_NUM=%Exp:cNum% AND
				SE1.%NotDel%
			ORDER BY
				1,6,7,2,3
			EndSql
		Else
	#ENDIF
			SE1->(dbSeek (xFilial("SE1")+cCli+cLoj+cPrefixo+cNum))
	#IFDEF TOP
		EndIf
	#ENDIF

	Do While (!(cAliasSE1)->(Eof ()) .And.;
		cFilSE1==(cAliasSE1)->E1_FILIAL .And.;
		cCli==(cAliasSE1)->E1_CLIENTE .And.;
		cLoj==(cAliasSE1)->E1_LOJA .And.;
		cPrefixo==(cAliasSE1)->E1_PREFIXO .And.;
		cNum==(cAliasSE1)->E1_NUM )

		If !(AllTrim ((cAliasSE1)->E1_TIPO)$MVTAXA+"|"+MVTXA+"|"+MVABATIM+"|"+cTipoTit) .And. (Substr((cAliasSE1)->E1_TIPO,1,2) <> "NC")
			aAdd (aParc, {(cAliasSE1)->E1_TIPO, (cAliasSE1)->E1_HIST, (cAliasSE1)->E1_NUM, (cAliasSE1)->E1_PARCELA, (cAliasSE1)->E1_VENCREA, (cAliasSE1)->E1_VLCRUZ, (cAliasSE1)->E1_VENCTO})
		EndIf

		DbSelectArea (cAliasSE1)
		(cAliasSE1)->(DbSkip ())
	EndDo

	#IFDEF TOP
		DbSelectArea (cAliasSE1)
		(cAliasSE1)->(DbCloseArea ())
	#ENDIF

Return (aParc)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |SpedProSE2³ Autor ³Gustavo G. Rueda       ³ Data ³15.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³            PROCESSAMENTO DO CONTAS A PAGAR                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Filtro os titulos do documento fiscal. Copiado do MATA103x  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aParc -> Array com as parcelas do documento fiscal, onde:   ³±±
±±³          ³ [1]=Tipo                                                   ³±±
±±³          ³ [2]=Historico                                              ³±±
±±³          ³ [3]=Numero                                                 ³±±
±±³          ³ [4]=Parcela                                                ³±±
±±³          ³ [5]=Vencimento Real                                        ³±±
±±³          ³ [6]=Valor                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|aCmpAntSFT -> Informacoes do cabecalho do documento         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SpedProSE2(aCmpAntSFT, lSeek)	//Copiado do MATA103x
	Local	aParc		:=	{}
	Local	cPrefixo	:= 	aCmpAntSFT[27]
	Local 	cTipoTit	:=	aSPDSX6[MV_C140TIT]
	Local	cAliasSE2	:=	"SE2"
	Local	cNum		:=	aCmpAntSFT[28]
	Local	cFor		:=	aCmpAntSFT[3]
	Local	cLoj		:=	aCmpAntSFT[4]
	Local	aAreaSF1	:=	{}

	Default lSeek := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para quando o PREFIXO nao estiver gravado no documento fiscal³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cPrefixo)
		aAreaSF1	:=	SF1->(GetArea())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o prefixo nao estiver gravado no documento fiscal, tenho que utilizar o parametro MV_2DUPREF,³
		//³ porem o parametro eh uma macro e pode abranger ateh um rdmake, para isso, temos que manter     ³
		//³ o padrao de chamada da mesma forma do MATA103, o SF1 deve estar posicionado.                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SF1->(MsSeek(xFilial("SF1")+aCmpAntSFT[1]+aCmpAntSFT[2]+aCmpAntSFT[3]+aCmpAntSFT[4]))

		cPrefixo	:= 	&(aSPDSX6[MV_2DUPREF])

		RestArea(aAreaSF1)
	EndIf

	#IFDEF TOP
		If lNotAs400 .And. !lSeek
			cAliasSE2	:=	GetNextAlias()

			BeginSql Alias cAliasSE2

			COLUMN E2_VENCTO AS DATE
			COLUMN E2_VENCREA AS DATE

			SELECT
				SE2.E2_FILIAL,SE2.E2_PREFIXO,SE2.E2_NUM,SE2.E2_PARCELA,SE2.E2_TIPO,SE2.E2_FORNECE,SE2.E2_LOJA,
				SE2.E2_HIST,SE2.E2_VENCREA,SE2.E2_VALOR,SE2.E2_VLCRUZ,SE2.E2_VENCTO
			FROM
				%Table:SE2% SE2
			WHERE
				SE2.E2_FILIAL=%xFilial:SE2% AND
				SE2.E2_FORNECE=%Exp:cFor% AND
				SE2.E2_LOJA=%Exp:cLoj% AND
				SE2.E2_PREFIXO=%Exp:cPrefixo% AND
				SE2.E2_NUM=%Exp:cNum% AND
				SE2.%NotDel%
			ORDER BY
				1,2,3,4,5,6,7
			EndSql
		Else
	#ENDIF
			SE2->(DbSetOrder (6))
			SE2->(dbSeek (xFilial("SE2")+cFor+cLoj+cPrefixo+cNum))
	#IFDEF TOP
		EndIf
	#ENDIF

	Do While (!(cAliasSE2)->(Eof ()) .And.;
		xFilial("SE2")==(cAliasSE2)->E2_FILIAL .And.;
		cFor==(cAliasSE2)->E2_FORNECE .And.;
		cLoj==(cAliasSE2)->E2_LOJA .And.;
		cPrefixo==(cAliasSE2)->E2_PREFIXO .And.;
		cNum==(cAliasSE2)->E2_NUM )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Montando as parcelas³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !(AllTrim ((cAliasSE2)->E2_TIPO)$MVTAXA+"|"+MVTXA+"|"+MVABATIM+"|"+cTipoTit) .And. (Substr((cAliasSE2)->E2_TIPO,1,2) <> "NC")
			aAdd (aParc, {(cAliasSE2)->E2_TIPO, (cAliasSE2)->E2_HIST, (cAliasSE2)->E2_NUM, (cAliasSE2)->E2_PARCELA, (cAliasSE2)->E2_VENCREA, (cAliasSE2)->E2_VLCRUZ, (cAliasSE2)->E2_VENCTO})
		EndIf

		(cAliasSE2)->(DbSkip())
	EndDo
	#IFDEF TOP
		(cAliasSE2)->(DbCloseArea ())
	#ENDIF

Return (aParc)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SpedPCCG1 | Autor ³Caio César M. oliveira        ³ Data ³18.04.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao para retornar a alíquota cadastrada na tabela CG1 de acordo ³±±
±±³          ³ com o código e data informados                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCodigo  - Código da tabela 5.1.1                                  ³±±
±±³          ³dtDigit  - Data de vigência                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDPISCOF                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SpedPCCG1(cCodigo,dtData)
Local 	lCG1 		:= aSPDSX2[AI_CG1]
Local	cCG1Alias	:= "CG1"
Local 	nAliq     	:= 0
Local 	aArea		:= GetArea()
Local 	dLastDt		:= CtoD("//")
Local 	clIndex		:= ""
Local 	clFiltro	:= ""
Local 	nlIndex		:= 0

Local 	aSetField	:= {}
Local   nI			:= 0
Local   lCg1DtIni	:= aSPDSX3[FP_CG1_DTINI]

Default cCodigo		:= ""
Default dtData		:= CtoD("//")

If lCG1
	DbSelectArea(cCG1Alias)
	(cCG1Alias)->( DbSetOrder(1))

	#IFDEF TOP
		If lNotAs400

	    	cCG1Alias	:= GetNextAlias()

	 		cSlctCG1	:= "CG1.CG1_CODIGO,	CG1.CG1_ALIQ, CG1.CG1_DTFIM"
			If lCg1DtIni
				cSlctCG1 += ", CG1.CG1_DTINI"
				aAdd(aSetField,{"CG1_DTINI","D",8,0})
			Endif

			cSlctCG1 := "%" + cSlctCG1 + "%"

	    	BeginSql Alias cCG1Alias

	    		COLUMN CG1_DTFIM AS DATE

	    		SELECT
					%Exp:cSlctCG1%


	    		FROM
	    			%Table:CG1% CG1
	    		WHERE
	    			CG1.%NotDel%
	    			AND CG1.CG1_FILIAL	= %xFilial:CG1%
	    			AND CG1.CG1_CODIGO	= %Exp:cCodigo%
	    		ORDER BY
	    			CG1.CG1_DTFIM
	    	EndSql

			For nI := 1 To Len(aSetField)
				TcSetField(cCG1Alias,aSetField[nI,1],aSetField[nI,2],aSetField[nI,3],aSetField[nI,4])
			Next

		Else
	#ENDIF

	clIndex		:= CriaTrab(NIL,.F.)
	clFiltro    := " CG1_FILIAL=='"+ xFilial("CG1") + "' "
	clFiltro    += " .AND. CG1_CODIGO=='"		+ cCodigo		+"' "

	IndRegua(cCG1Alias,clIndex,CG1->(IndexKey()),,clFiltro)
	nlIndex := RetIndex(cCG1Alias)

	#IFNDEF TOP
		dbSetIndex(clIndex+OrdBagExt())
	#ENDIF

	dbSelectArea(cCG1Alias)
	dbSetOrder(nlIndex+1)

	#IFDEF TOP
		Endif
	#ENDIF

	While (cCG1Alias)->(!Eof())
		If lCg1DtIni
			If !Empty((cCG1Alias)->CG1_DTINI)
		    	If (dtData>=(cCG1Alias)->CG1_DTINI) .AND. (dtData<=(cCG1Alias)->CG1_DTFIM .OR. EMPTY((cCG1Alias)->CG1_DTFIM )) .AND. !Empty(dtData)
		 			nAliq := (cCG1Alias)->CG1_ALIQ
		    	EndIf
			Elseif !Empty((cCG1Alias)->CG1_DTFIM) .AND. (dtData<=(cCG1Alias)->CG1_DTFIM  .OR. EMPTY((cCG1Alias)->CG1_DTFIM ))
				nAliq := (cCG1Alias)->CG1_ALIQ
			EndIf
		Else
			If !Empty((cCG1Alias)->CG1_DTFIM)
		    	If (dtData<=(cCG1Alias)->CG1_DTFIM) .AND. ( Empty(dLastDt) .OR. (dtData>dLastDt))
		 			nAliq := (cCG1Alias)->CG1_ALIQ
		    	EndIf
		    	dLastDt := (cCG1Alias)->CG1_DTFIM
			Else
				nAliq := (cCG1Alias)->CG1_ALIQ
			EndIf
		EndIf
		(cCG1Alias)->(dbSkip())
	EndDo

	RestArea(aArea)

	#IFDEF TOP
		If lNotAs400
			DbSelectArea (cCG1Alias)
			(cCG1Alias)->(DbCloseArea ())
		Else
	#ENDIF
			RetIndex(cCG1Alias)
			FErase(clIndex+OrdBagExt())
	#IFDEF TOP
		EndIf
	#ENDIF
EndIf

Return nAliq
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |SpdGrIndM ³ Autor ³Gustavo G. Rueda       ³ Data ³16.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³          GRAVACAO DOS INDICADORES DE MOVIMENTO             ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Gravo os indicadores de movimento para todos os registros   ³±±
±±³          ³ a serem gerados.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlias -> Alias do TRB criado atraves da funcao principal.  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SpdGrIndM (cAlias, aWizard)
	Local	lRet		:=	.T.
	Local	nQtd0990	:=	0
	Local	nQtdA990	:=	0
	Local	nQtdB990	:=	0
	Local	nQtdC990	:=	0
	Local	nQtdD990	:=	0
	Local	nQtdE990	:=	0
	Local	nQtdG990	:=	0
	Local	nQtdH990	:=	0
	Local	nQtdI990	:=	0
	Local	nQtdJ990	:=	0
	Local	nQtdK990	:=	0
	Local	nQtdL990	:=	0
	Local	nQtdZ990	:=	0
	Local	nQtd1990	:=	0
	Local 	nQtd9990	:=	0
	Local	nPos		:=	0
	Local	aReg9900	:=	{}
	DEFAULT 	aWizard := {}

	DbSelectArea (cAlias)
	(cAlias)->(DbSetOrder (1))
	(cAlias)->(DbGoTop ())

	Do While !(cAlias)->(Eof ())

		If (nPos := aScan (aReg9900, {|aX| aX[2]==(cAlias)->TRB_TPREG}))==0
			aAdd (aReg9900, {"9900",(cAlias)->TRB_TPREG,"1"})
		Else
			aReg9900[nPos][3] := Alltrim(STR( Val( aReg9900[nPos][3] )+1))
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTROS - 0³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (Left ((cAlias)->TRB_TPREG, 1)$"0")
			nQtd0990++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTROS - A³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf (Left ((cAlias)->TRB_TPREG, 1)$"A")
			nQtdA990++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTROS - B³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf (Left ((cAlias)->TRB_TPREG, 1)$"B")
			nQtdB990++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTROS - C³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf (Left ((cAlias)->TRB_TPREG, 1)$"C")
			nQtdC990++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTROS - D³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf (Left ((cAlias)->TRB_TPREG, 1)$"D")
			nQtdD990++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTROS - E³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf (Left ((cAlias)->TRB_TPREG, 1)$"E")
			nQtdE990++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTROS - G³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf (Left ((cAlias)->TRB_TPREG, 1)$"G")
			nQtdG990++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTROS - H³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf (Left ((cAlias)->TRB_TPREG, 1)$"H")
			nQtdH990++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTROS - I³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf (Left ((cAlias)->TRB_TPREG, 1)$"I")
			nQtdI990++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTROS - J³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf (Left ((cAlias)->TRB_TPREG, 1)$"J")
			nQtdJ990++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTROS - K³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf (Left ((cAlias)->TRB_TPREG, 1)$"K")
			nQtdK990++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTROS - L³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf (Left ((cAlias)->TRB_TPREG, 1)$"L")
			nQtdL990++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTROS - Z³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf (Left ((cAlias)->TRB_TPREG, 1)$"Z")
			nQtdZ990++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTROS - 8³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf (Left ((cAlias)->TRB_TPREG, 1)$"1")
			nQtd1990++
		EndIf

		(cAlias)->(DbSkip ())
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gravacao do indicador de movimento do bloco 0.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BlAbEnc ("A", cAlias, "0001", Iif (nQtd0990>0, "0", "1"),)
	BlAbEnc ("E", cAlias, "0990",, nQtd0990)
	aAdd (aReg9900, {"9900","0001","1"})
	aAdd (aReg9900, {"9900","0990","1"})
	If cVersao >= "013"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gravacao do indicador de movimento do bloco C.   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BlAbEnc ("A", cAlias, "B001", Iif (nQtdB990>0, "0", "1"),)
		BlAbEnc ("E", cAlias, "B990",, nQtdB990)
		aAdd (aReg9900, {"9900","B001","1"})
		aAdd (aReg9900, {"9900","B990","1"})
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gravacao do indicador de movimento do bloco C.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BlAbEnc ("A", cAlias, "C001", Iif (nQtdC990>0, "0", "1"),)
	BlAbEnc ("E", cAlias, "C990",, nQtdC990)
	aAdd (aReg9900, {"9900","C001","1"})
	aAdd (aReg9900, {"9900","C990","1"})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gravacao do indicador de movimento do bloco D.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BlAbEnc ("A", cAlias, "D001", Iif (nQtdD990>0, "0", "1"),)
	BlAbEnc ("E", cAlias, "D990",, nQtdD990)
	aAdd (aReg9900, {"9900","D001","1"})
	aAdd (aReg9900, {"9900","D990","1"})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gravacao do indicador de movimento do bloco E.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BlAbEnc ("A", cAlias, "E001", Iif (nQtdE990>0, "0", "1"),)
	BlAbEnc ("E", cAlias, "E990",, nQtdE990)
	aAdd (aReg9900, {"9900","E001","1"})
	aAdd (aReg9900, {"9900","E990","1"})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gravacao do indicador de movimento do bloco G.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cVersao >="004"
		BlAbEnc ("A", cAlias, "G001", Iif (nQtdG990>0, "0", "1"),)
		BlAbEnc ("E", cAlias, "G990",, nQtdG990)
		aAdd (aReg9900, {"9900","G001","1"})
		aAdd (aReg9900, {"9900","G990","1"})
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gravacao do indicador de movimento do bloco H.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BlAbEnc ("A", cAlias, "H001", Iif (nQtdH990>0, "0", "1"),)
	BlAbEnc ("E", cAlias, "H990",, nQtdH990)
	aAdd (aReg9900, {"9900","H001","1"})
	aAdd (aReg9900, {"9900","H990","1"})
	IF cVersao >= '010'
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Gravacao do indicador de movimento do bloco K.   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			BlAbEnc ("A", cAlias, "K001", Iif (nQtdK990>0, "0", "1"),)
			BlAbEnc ("E", cAlias, "K990",, nQtdK990)
			aAdd (aReg9900, {"9900","K001","1"})
			aAdd (aReg9900, {"9900","K990","1"})
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gravacao do indicador de movimento do bloco 1.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BlAbEnc ("A", cAlias, "1001", Iif (nQtd1990>0, "0", "1"),)
	BlAbEnc ("E", cAlias, "1990",, nQtd1990)
	aAdd (aReg9900, {"9900","1001","1"})
	aAdd (aReg9900, {"9900","1990","1"})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Outros registros que devem ser totalizados       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd (aReg9900, {"9900","9001","1"})
	aAdd (aReg9900, {"9900","9990","1"})
	aAdd (aReg9900, {"9900","9999","1"})
	aAdd (aReg9900, {"9900","9900",STR(len(aReg9900)+1)})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gravacao do bloco 9 (Totalizacao dos registros)  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SpdReg9900(cAlias, aReg9900)
	nQtd9990 := Len(aReg9900) + 1
	BlAbEnc ("A", cAlias, "9001", Iif (nQtd9990>0, "0", "1"),)
	BlAbEnc ("E", cAlias, "9990",, nQtd9990)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gravacao do registro 9999 (Encerramento do arquivo) ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SpdReg9999(cAlias)

Return (lRet)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    |BlAbEnc   | Autor ³Gustavo G. Rueda              ³ Data ³03.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³GRAVACAO DO INDICADOR DE BLOCO COM MOVIMENTO                       ³±±
±±³          ³                                                                   ³±±
±±³          ³Funcao de gravacao do indicador de bloco com movimento(0) ou       ³±±
±±³          ³ sem movimento(1) conforme passagem de parametros. Utilizado       ³±±
±±³          ³ na funcao SpdGrIndM.                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpN1 := BlAbEnc(cAbEnc,cAlias,cReg,cIndMov,nQtdLin)               ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAbEnt -> Indicador de Bloco de Abertura (A) ou Encerramento       ³±±
±±³          ³ (E).                                                              ³±±
±±³          ³cAlias -> Alias do TRB onde sera gravado as informacoes.           ³±±
±±³          ³cReg -> Codigo do registro                                         ³±±
±±³          ³cIndMov -> Indicador de movimento (0=Sim, 1=Nao)                   ³±±
±±³          ³nQtdLin -> Quantidade de linha do registro                         ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 - Sempre .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function BlAbEnc(cAbEnc,cAlias,cReg,cIndMov,nQtdLin)
	Local	lRet		:=	.T.
	Local	aBlAbEnc	:=	{}
	//
	aAdd(aBlAbEnc, {})
	nPos	:=	Len (aBlAbEnc)
	//
	If ("A"$cAbEnc)
		aAdd (aBlAbEnc[nPos], cReg)
		aAdd (aBlAbEnc[nPos], cIndMov)
	Else
		aAdd (aBlAbEnc[nPos], cReg)
		aAdd (aBlAbEnc[nPos], Alltrim(STR(nQtdLin+2)))	// O +2 eh para somar o registro de abertura mais o registro de encerramento
	EndIf
	//
	GrvRegTrS (cAlias,,aBlAbEnc,)
Return (lRet)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SPEDLC195 ³ Autor ³Natalia Antonucci      ³ Data ³21.12.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³     REGISTRO C195 - OBSERVACOES DO LANCAMENTO FISCAL       ³±±
±±³          ³                    (CODIGO 01 E 55)                        ³±±
±±³          ³                                                            ³±±
±±³          ³Geracao e gravacao dos Registros C195 			          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrS com o embasamento legal para tais      ³±±
±±³          ³ observacoes                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3(1:N) Para cada C100                                       ³±±
±±³          ³4(1:N) Para cada C195                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAliasSFT-> Alias da tabela SFT em processamento         	  ³±±
±±³			 ³aLancFis  -> Array com a estrutura do registro 0150 a ser   ³±±
±±³          ³			gravado no TRB no final do processamento da rotina³±±
±±³          ³cAliasSF4-> Informa qual o alias da tabela SF4, podendo ser ³±±
±±³          ³            query                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPEDLC195( cAliasSFT , aLancFis , cAliasSF4 , cMVSPDTC95 , lAchouCCE)
Local	nPos		:=	0
Local 	cMensagem   := ""
Local	cMsgmCompl	:= ""
Default	cMVSPDTC95	:= "1"
Default	lAchouCCE	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Geracao do REGISTRO C195 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !Empty((cAliasSF4)->F4_CODOBSE) .AND. (nPos := aScan(aLancFis,{|aX| aX[1]==(cAliasSF4)->F4_CODOBSE}))==0
   	If (cMVSPDTC95 $ "1" .And. !lAchouCCE)  .Or. cMVSPDTC95 $ "3"
   		cMensagem := IIF(EMPTY((cAliasSFT)->FT_FORMULA) = .T.,(cAliasSFT)->FT_OBSERV,(cAliasSFT)->(Formula((cAliasSFT)->FT_FORMULA)+FT_OBSERV))
	ElseIf cMVSPDTC95 $ "1|2" .And. lAchouCCE
   		cMensagem := CCE->CCE_DESCR
   	Endif

   	// ----------------------------------------------------------------------------
   	//  Preenchimento do campo 03 - TXT_COMPL do registro C195
   	//  Atraves do Parametro MV_SPD3C195 o usuario ira informar como deseja
   	//  preencher este campo: 1 = SFT/CCE; 2 = CCE; 3 = SFT; 4 = vazio
   	// ----------------------------------------------------------------------------
   	If cMVSPDTC95 <> "4"

   		If cMVSPDTC95 $ "1|3" .And. !Empty((cAliasSFT)->FT_FORMULA)
   			cMsgmCompl := (cAliasSFT)->(Formula((cAliasSFT)->FT_FORMULA)+FT_OBSERV)
   		Elseif cMVSPDTC95 $ "1|2"
   			cMsgmCompl := CCE->CCE_DESCR
   		Endif

   	Endif

   	aAdd(aLancFis, {})
	nPos	:=	Len (aLancFis)
	aAdd (aLancFis[nPos], (cAliasSF4)->F4_CODOBSE)
	aAdd (aLancFis[nPos], cMensagem) // Apenas para o C195, este deve entrar na regra do MV_SPDTC95
	aAdd (aLancFis[nPos], cMsgmCompl)
	aAdd (aLancFis[nPos], CCE->CCE_DESCR) //Para que o campo 3 do 0460 seja sempre seja preenchido - é um campo obrigatório - Não deve entrar na regra do MV_SPDTC95
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SPEDDevol ³ Autor ³Luccas Curcio          ³ Data ³25.06.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processa as devolucoes que serao enviadas para o SPED Contri³±±
±±³          ³buicoes. 													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Para as devolucoes do mesmo periodo, devera verificar 	  ³±±
±±³          ³o regime e a operacao realizada, para aplicar a reducao	  ³±±
±±³          ³de base de calculo ou dar direito a credito - Bloco A/C/D.  ³±±
±±³          ³Para as devolucoes de outros periodos ira realizar os 	  ³±±
±±³          ³ajustes eprtinentes no bloco M	  						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³dDataDe   -> Data inicial do processamento         	  	  ³±±
±±³			 ³dDataAte  -> Data final do processamento   				  ³±±
±±³          ³cNrLivro  -> Numero do livro de processamento selecionado no³±±
±±³          ³             wizard                                         ³±±
±±º          ³nMVM996TPR-> Conteudo do Parametro MV_M996TPR               º±±
±±³          ³lTop      -> Flag que indica se estah utilizando TOP ou nao ³±±
±±³          ³cTpMov    -> Indica o tipo de movimento das devolucoes      ³±±
±±³          ³aDevol    -> Array que retorna as devolucoes do periodo     ³±±
±±³          ³aDevOutPer-> Array que retorna devolucoes de outro periodo  ³±±
±±º          ³cRegime   -> Informa o tipo do Regime                       º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPEDDevol(dDataDe,dDataAte,cNrLivro,nMVM996TPR,lTop,cTpMov,aDevol,aDevOutPer,cRegime)
Local	lAchouSFT	:=	.F.
Local	cAliasSFT	:=	"SFT"
Local	cRegDev		:=	""
Local	cNotaOri	:=	""
Local	cIteOri		:=	""
Local	aPar		:=	{}
Local	aAreaSFT	:=	SFT->(GetArea())
Local	nPos		:=	0
Local	nPercDevP	:=	0
Local	nPercDevC	:=	0
Local   cClie		:= ""
Local cCodOriPIS := ""
Local cCodOriCOF := ""
Local lImport := .F.
Local cIndCont := ""
Local lAgrIndust := .F.


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros que serao enviados na montagem da query das notas de devolucao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aPar,DTOS(dDataDe))
aAdd(aPar,DTOS(dDataAte))
aAdd(aPar,cNrLivro)
aAdd(aPar,Iif(cTpMov=="S","E","S"))
aAdd(aPar,nMVM996TPR)
aAdd(aPar,cRegime)

If (lAchouSFT := SPEDFFiltro(1,"SFTDEV",@cAliasSFT,aPar))

	Do While !(cAliasSFT)->(Eof ())
		cCodOriPIS := ""
		cCodOriCOF := ""
		cClie:= (cAliasSFT)->FT_CLIEFOR
	    aAreaSFT	:= SFT->(GetArea())
	    SFT->(DbSetOrder(6))
	    //FT_FILIAL+FT_TIPOMOV+FT_NFISCAL+FT_SERIE
	    IF SFT->(MsSeek(xFilial("SFT")+cTpMov+Alltrim((cAliasSFT)->FT_NFORI+(cAliasSFT)->FT_SERORI)))
	    	Do While !SFT->(Eof ()) .And. (cAliasSFT)->FT_NFORI == SFT->FT_NFISCAL .And. (cAliasSFT)->FT_SERORI == SFT->FT_SERIE .And. (cAliasSFT)->FT_CLIEFOR == SFT->FT_CLIEFOR .And. (cAliasSFT)->FT_LOJA == SFT->FT_LOJA
	    		IF  Alltrim((cAliasSFT)->FT_PRODUTO) == Alltrim(SFT->FT_PRODUTO)
	    			cClie:= SFT->FT_CLIEFOR
		    		EXIT
		    	Else
		    		SFT->(DbSkip())
		    	EndIf
		    EndDo
	    Else
	      	cClie:= (cAliasSFT)->FT_CLIEFOR
	    EndIf
	    RestArea (aAreaSFT)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Para as devolucoes de venda, preciso verificar qual o regime da operacao  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cTpMov == "S"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ambiente DBF - Posiciono as tabelas necessarias e utilizo a funcao SPEDRegime³
			//³para verificar qual o regime da operacao 									³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cRegime == "3" .And. !lTop

				SPEDSeek("SD1",1,xFilial("SD1")+(cAliasSFT)->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_PRODUTO+FT_ITEM))
				SPEDSeek("SF4",1,xFilial("SF4")+SD1->D1_TES)
				SPEDSeek("SB1",1,xFilial("SB1")+(cAliasSFT)->FT_PRODUTO)
				SPEDSeek("SA1",1,xFilial("SA1")+(cAliasSFT)->(FT_CLIEFOR+FT_LOJA))

				If SPEDRegime(cRegime,"SF4","SB1","SA1",nMVM996TPR) == "C"
					cRegDev := "2"
				Else
					cRegDev := "1"
				Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ambiente TOP - Ja possuo os campo necessarios atraves do JOIN feito na query ³
			//³Utilizo a funcao SPEDRegime para verificar qual o regime da operacao			³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Elseif cRegime == "3" .And. lTop

				If SPEDRegime(cRegime,cAliasSFT,cAliasSFT,cAliasSFT,nMVM996TPR) == "C"
					cRegDev := "2"
				Else
					cRegDev := "1"
				Endif
			Elseif cRegime == "2"
				cRegDev := "2"
			Else
				cRegDev := "1"
			Endif
		Endif

		SFT->(DbSetOrder(1))
		aAreaSFT	:= SFT->(GetArea())
		cNotaOri	:=	(cAliasSFT)->FT_NFISCAL
		cIteOri		:=	(cAliasSFT)->FT_ITEMORI

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciono na nota fiscal original, para calcular a porcentagem de devolucao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SFT->(MsSeek(xFilial("SFT")+cTpMov+(cAliasSFT)->(FT_SERORI+FT_NFORI+cClie+FT_LOJA+FT_ITEMORI+FT_PRODUTO))) .And.;
			SFT->FT_VALPIS > 0 .OR. SFT->FT_VALCOF  > 0

			IF (cAliasSFT)->FT_BASEPIS > 0 .AND. (cAliasSFT)->FT_BASEPIS <= SFT->FT_BASEPIS
				nPercDevP :=	(cAliasSFT)->FT_BASEPIS / SFT->FT_BASEPIS
			Else
				nPercDevP := (((cAliasSFT)->FT_QUANT * 100) / SFT->FT_QUANT ) / 100
			EndIF

			IF (cAliasSFT)->FT_BASECOF > 0 .AND. (cAliasSFT)->FT_BASECOF <= SFT->FT_BASECOF
				nPercDevC := (cAliasSFT)->FT_BASECOF / SFT->FT_BASECOF
			Else
				nPercDevC := (((cAliasSFT)->FT_QUANT * 100) / SFT->FT_QUANT ) / 100
			EndIF

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Devolucao no proprio periodo³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If DTOS(SFT->FT_ENTRADA) >= DTOS(dDataDe) .And. DTOS(SFT->FT_ENTRADA) <= DTOS(dDataAte)

				If (nPos := aScan(aDevol,{|x| x[1]+x[3]+x[4]+x[5]+x[6]==(cAliasSFT)->(FT_NFORI+FT_SERORI+FT_ITEMORI+FT_CLIEFOR_+FT_LOJA)})) == 0

					aAdd(aDevol, {})
					nPos	:=	Len (aDevol)
					aAdd (aDevol[nPos], SFT->FT_NFISCAL)
					aAdd (aDevol[nPos], SFT->FT_EMISSAO)
					aAdd (aDevol[nPos], SFT->FT_SERIE)
					aAdd (aDevol[nPos], SFT->FT_ITEM)
					aAdd (aDevol[nPos], SFT->FT_CLIEFOR)
					aAdd (aDevol[nPos], SFT->FT_LOJA)
					aAdd (aDevol[nPos], Round(SFT->FT_BASEPIS*nPercDevP,2))
					aAdd (aDevol[nPos], Round(SFT->FT_VALPIS*nPercDevP,2))
					aAdd (aDevol[nPos], Round(SFT->FT_BASECOF*nPercDevC,2))
					aAdd (aDevol[nPos], Round(SFT->FT_VALCOF*nPercDevC,2))
					aAdd (aDevol[nPos], (cAliasSFT)->FT_QUANT)
				Else
					If SFT->FT_QUANT == aDevol[nPos][11] + (cAliasSFT)->FT_QUANT
						aDevol[nPos][7]		:=	SFT->FT_BASEPIS
						aDevol[nPos][8]		:=	SFT->FT_VALPIS
						aDevol[nPos][9]		:=	SFT->FT_BASECOF
						aDevol[nPos][10]	:=	SFT->FT_VALCOF
						aDevol[nPos][11]	:=	SFT->FT_QUANT
					Else
						aDevol[nPos][7]		+=	Round(SFT->FT_BASEPIS*nPercDevP,2)
						aDevol[nPos][8]		+=	Round(SFT->FT_VALPIS*nPercDevP,2)
						aDevol[nPos][9]		+=	Round(SFT->FT_BASECOF*nPercDevC,2)
						aDevol[nPos][10]	+=	Round(SFT->FT_VALCOF*nPercDevC,2)
						aDevol[nPos][11]	+=	(cAliasSFT)->FT_QUANT
					Endif
				Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Devolucao em outro periodo  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Else
				If cTpMov == "E"
					aAdd (aDevOutPer, {})
					nPos :=	Len (aDevOutPer)
					aAdd (aDevOutPer[nPos], SFT->FT_ENTRADA)
					aAdd (aDevOutPer[nPos], SFT->FT_VALPIS)
					aAdd (aDevOutPer[nPos], SFT->FT_VALCOF)
					aAdd (aDevOutPer[nPos], SFT->FT_NFISCAL)
					aAdd (aDevOutPer[nPos], SFT->FT_SERIE)
					aAdd (aDevOutPer[nPos], Round(SFT->FT_BASEPIS*nPercDevP,2))
					aAdd (aDevOutPer[nPos], Round(SFT->FT_VALPIS*nPercDevP,2))
					aAdd (aDevOutPer[nPos], Round(SFT->FT_BASECOF*nPercDevC,2))
					aAdd (aDevOutPer[nPos], Round(SFT->FT_VALCOF*nPercDevC,2))
					aAdd (aDevOutPer[nPos], cNotaOri)
					aAdd (aDevOutPer[nPos], cIteOri)
					aAdd (aDevOutPer[nPos], .F. )
					aAdd (aDevOutPer[nPos], .F. )

					lImport := Iif(Substr(SFT->FT_CFOP,1,1) == "3",.T.,.F.)
					lAgrIndust := Iif(Substr(SFT->FT_TNATREC,1,1) $ "439",.T.,.F.)

					If SFT->FT_CSTPIS $ "50|51|52"

						If SFT->FT_ALIQPIS == 0.65 .OR. SFT->FT_ALIQPIS == 1.65
							cIndCont := "1"
						Else
					    	cIndCont := "2"
						EndIf

						cCodOriPIS := SPEDCodCre(SFT->FT_CSTPIS,;		// Codigo da Situacao Tributaria - CST
										SFT->FT_CODBCC,;		// Codigo de Base de Calculo do Credito - CODBCC
										SFT->FT_PAUTPIS > 0,;		// Operacao com Unidade de Produto - Pauta
										lImport,;		// Operacao de Importacao
										SFT->FT_CNATREC,;		// Codigo da Natureza da Receita
										cIndCont,;		// Tipo de Aliquota (Basica/Diferenciada)
										NIL,;      // Aliquota Unidade de Produto
										NIL,;
										lAgrIndust)	//Operação Agroindustria

					Else
						cCodOriPIS := ""
					EndIf

					If SFT->FT_CSTCOF $ "50|51|52"

						If	SFT->FT_ALIQCOF == 3 .OR. SFT->FT_ALIQCOF == 7.60
							cIndCont := "1"
						Else
							cIndCont := "2"
						EndIf

						cCodOriCOF := SPEDCodCre(SFT->FT_CSTCOF,;		// Codigo da Situacao Tributaria - CST
										SFT->FT_CODBCC,;		// Codigo de Base de Calculo do Credito - CODBCC
										SFT->FT_PAUTCOF > 0,;		// Operacao com Unidade de Produto - Pauta
										lImport,;		// Operacao de Importacao
										SFT->FT_CNATREC,;		// Codigo da Natureza da Receita
										cIndCont,;		// Tipo de Aliquota (Basica/Diferenciada)
										NIL,;      // Aliquota Unidade de Produto
										NIL,;
										lAgrIndust)	//Operação Agroindustria
					Else
						cCodOriCOF := ""
					EndIf

					aAdd (aDevOutPer[nPos], cCodOriPIS ) // 14.
					aAdd (aDevOutPer[nPos], cCodOriCOF ) // 15.
					aAdd (aDevOutPer[nPos], (cAliasSFT)->FT_SERIE) // 16 - Série da NF de devolucao.
					aAdd (aDevOutPer[nPos], SFT->FT_FILIAL) // 17 - Filial da NF original.
					aAdd (aDevOutPer[nPos], (cAliasSFT)->FT_ITEM) // 18 - Item da NF de devolucao.

				Else
					aAdd(aDevOutPer, {})
					nPos	:=	Len (aDevOutPer)
					aAdd (aDevOutPer[nPos], (cAliasSFT)->FT_NFISCAL)
					aAdd (aDevOutPer[nPos], SFT->FT_ENTRADA)
					aAdd (aDevOutPer[nPos], IIf(SFT->FT_QUANT==(cAliasSFT)->FT_QUANT, SFT->FT_VALPIS, Round(SFT->FT_VALPIS*nPercDevP,2)))
					aAdd (aDevOutPer[nPos], IIf(SFT->FT_QUANT==(cAliasSFT)->FT_QUANT, SFT->FT_VALCOF, Round(SFT->FT_VALCOF*nPercDevC,2)))
					aAdd (aDevOutPer[nPos], SFT->FT_NFISCAL)
					aAdd (aDevOutPer[nPos], cRegDev)
					aAdd (aDevOutPer[nPos], (cAliasSFT)->FT_FILIAL)
					aAdd (aDevOutPer[nPos], (cAliasSFT)->FT_SERIE)
					aAdd (aDevOutPer[nPos], cIteOri)
					aAdd (aDevOutPer[nPos], SFT->FT_FILIAL)
					aAdd (aDevOutPer[nPos], SFT->FT_SERIE)
					aAdd (aDevOutPer[nPos], (cAliasSFT)->FT_ITEM)
				Endif
			Endif
		Endif
		RestArea (aAreaSFT)
		(cAliasSFT)->(DbSkip())
	EndDo
Endif

If lAchouSFT
	SPEDFFiltro(2,,cAliasSFT)
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SPEDRegime³ Autor ³Erick Dias             ³ Data ³25.06.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna qual o regime que foi utilizado na operacao         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Devem ser passados os parametros necessarios para 		  ³±±
±±³          ³identificar a operacao, e a funcao ira retornar qual o      ³±±
±±³          ³regime que foi utilizado  								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cRetorno -> "C" indica que eh cumulativo, "N" indica nao-   ³±±
±±³          ³			  cumulativo                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cRegime   -> Informa o tipo do Regime                       º±±
±±³			 ³cAliasSF4 -> Alias da tabela SF4   				  		  ³±±
±±³          ³caliasSB1 -> Alias da tabela SB1							  ³±±
±±³          ³cAliasSA1 -> Alias da tabela SA1 					  		  ³±±
±±º          ³nMVM996TPR-> Conteudo do Parametro MV_M996TPR               º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPEDRegime(cRegime,cAliasSF4,caliasSB1,cAliasSA1,nMVM996TPR)
Local lCumulativ := .F.
Local cRetorno   := ""
Local lB1TPREG   := aSPDSX3[FP_B1_TPREG]

Default nMVM996TPR := aSPDSX6[MV_M996TPR]

IF nMVM996TPR = 1 //TES
	If (cAliasSF4)->F4_TPREG == "2"	//Cumulativo
		lCumulativ := .T.
	ElseIF (cAliasSF4)->F4_TPREG == "3"	//Ambos, neste caso irei no produto para definir qual o regime
		IF lB1TPREG .AND. (caliasSB1)->B1_TPREG == "2" //Cumulativo
			lCumulativ := .T.
		EndIF
	EndIF
Elseif nMVM996TPR == 2 //PRODUTO
	IF lB1TPREG .AND. (cAliasSB1)->B1_TPREG == "2" //Cumulativo
		lCumulativ := .T.
	EndIF
Elseif nMVM996TPR == 3 .And. aSPDSX3[FP_A1_TPREG] //CLIENTE
	IF (cAliasSA1)->A1_TPREG == "2" //Cumulativo
		lCumulativ := .T.
	EndIf
EndIF

If lCumulativ
	cRetorno :="C" //Regime Cumulativo
Else
	cRetorno := "N" //Regime Não Cumulativo
EndIF

Return (cRetorno)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcoes de tratamento de caracteres especiais copiadas do NFESEFAZ  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Function SPEDConvType(xValor,nTam)

Local cNovo := ""

If nTam==Nil
	xValor := AllTrim(xValor)
EndIf
DEFAULT nTam := 60
cNovo := AllTrim(EnCodeUtf8(NoAcento(SubStr(xValor,1,nTam))))

Return(cNovo)

FUNCTION SPEDNoAcento(cString)
Local cChar  := ""
Local nX     := 0
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
Local cTrema := "äëïöü"+"ÄËÏÖÜ"
Local cCrase := "àèìòù"+"ÀÈÌÒÙ"
Local cTio   := "ãõ"
Local cCecid := "çÇ"

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
		nY:= At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTio)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("ao",nY,1))
		EndIf
		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf
	Endif
Next
For nX:=1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	If Asc(cChar) < 32 .Or. Asc(cChar) > 123 .Or. cChar $ '&'
		cString:=StrTran(cString,cChar,".")
	Endif
Next nX
cString := _NoTags(cString)
Return cString

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SPEDNcmCAgºAutor  ³Erick G. Dias       º Data ³  08/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Retornar se o NCM pertence aos NCMS de exportação          º±±
±±º          ³ Para considerar percentual da base de cálculo do crédito   º±±
±±º          ³ presumido de PIS e COFINS conforme lei 12.058/2009.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ cNcm   -> NCM que consta no produto.                    	  ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SPEDNcmCAg(cNcm)

Local nPos		:= 0
Local aNCM     	:= aSPDSX6[MV_NCMCPPC]
local lRet		:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta um array com os códigos NCMs que serão considerados como exportação para percentual do cálculo da base de cálculo de crédito Presumido.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aNCM   			:= Iif (Len(aNCM) > 1,&(aNCM),aNCM)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Irá fazer for para verificar todos NCMs³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nPos := 1 to len(aNCM)

	IF aNCM[nPos] $ Alltrim(cNcm)
		lRet := .T.
		exit
	EndIf
Next nPos
Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SPDRetCCST| Autor ³Gustavo G. Rueda              ³ Data ³22.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao que retorna o codigo de situacao tributaria dos impostos    ³±±
±±³          ³ ICMS, IPI, PIS e COFINS                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpA1 :=SPDRetCCST(cPar1,lPar2,lPar3,lPar4,cPar5,cPar6,cPar7,cPar8)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cPar1 - Alias da tabela SFT em processamento                       ³±±
±±³          ³lPar2 - Booleano de identificacao da existencia do registro na     ³±±
±±³          ³        tabela SF4 correspondente ao item da tabela SFT            ³±±
±±³          ³lPar3 - Booleano de identificacao da existencia do campo de CST    ³±±
±±³          ³        do PIS na tabela SFT                                       ³±±
±±³          ³lPar4 - Booleano de identificacao da existencia do campo de CST    ³±±
±±³          ³        da COFINS na tabela SFT                                    ³±±
±±³          ³cPar5 - Especie do documento fiscal em processamento               ³±±
±±³          ³cPar6 - Alias da tabela SF4, query ou SF4                          ³±±
±±³          ³cPar7 - Alias da tabela SB1, query ou SB1                          ³±±
±±³          ³cPar8 - Estado do cliente/Forncedor do documento fiscal            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aRet -> Array com os codigos de situacao tributaria                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPDRetCCST(cAliasSFT,lAchouSF4,cEspecie,cAliasSF4,cAliasSB1,cPartEst)
//						Icm Ipi Pis	Cof
Local	aRet		:= {"" ,"", "", ""}
Local   lStfrete    := aSPDSX6[MV_STFRETE] //Cod.Situação Tributaria para notas de conhecimento de frete

DEFAULT cEspecie 	:=	"01"
DEFAULT cAliasSF4	:=	"SF4"
DEFAULT cAliasSB1	:=	"SB1"
DEFAULT cPartEst	:=	SA1->A1_EST

//Situacao Tributaria ICMS
If Empty((cAliasSFT)->FT_CLASFIS) .Or. Len(Alltrim((cAliasSFT)->FT_CLASFIS))<>3

	If Empty((cAliasSB1)->B1_ORIGEM)

		If Empty((cAliasSB1)->B1_IMPORT) .Or. (cAliasSB1)->B1_IMPORT=="N"
			aRet[1] := "0"
		Else
			If cPartEst=="EX"
				aRet[1] := "1"
			Else
				aRet[1] := "2"
			EndIf
		EndIf
	Else
		aRet[1] := (cAliasSB1)->B1_ORIGEM
	EndIf

	If lAchouSF4
		aRet[1]	+=	(cAliasSF4)->F4_SITTRIB
	EndIf
Else
	aRet[1] :=(cAliasSFT)->FT_CLASFIS
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄd¿
//³Tratamento para notas de conhecimento de frete.                                         ³
//³  Em consulta junto nossa consultoria Tributária, foi necessario a criação do parametro ³
//³  MV_STFRETE para definir se o campo (CST)Cod.Situação Tributaria  das notas de         ³
//³ conhecimento de frete será considerado do B1_ORIGEM ou se iniciará em "0"              ³
//³ mesmo sendo uma importação.                                                            ³
//³Solicitação feita na FNC 00000019516/2010-01                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄdÙ
If lStfrete
	If cEspecie$"07#08#09#10#11#26#27#57"
    	aRet[1] := "0"+ SubStr((cAliasSFT)->FT_CLASFIS,2,3)
  	EndIf
EndIf

//Situacao Tributaria IPI
aRet[2] := (cAliasSFT)->FT_CTIPI

//Situacao Tributaria PIS
If !Empty((cAliasSFT)->FT_CSTPIS)
	aRet[3] := (cAliasSFT)->FT_CSTPIS
ElseIf lAchouSF4
	aRet[3] := (cAliasSF4)->F4_CSTPIS
EndIf

//Situacao Tributaria COFINS
If !Empty((cAliasSFT)->FT_CSTCOF)
	aRet[4] := (cAliasSFT)->FT_CSTCOF
ElseIf lAchouSF4
	aRet[4] := (cAliasSF4)->F4_CSTCOF
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para alterar a classificação fiscal do produto.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aExistBloc[22]
	aRet :=  ExecBlock("SPDFIS03", .F., .F., {(cAliasSFT)->FT_FILIAL,;
						(cAliasSFT)->FT_TIPOMOV,;
						(cAliasSFT)->FT_SERIE,;
						(cAliasSFT)->FT_NFISCAL,;
						(cAliasSFT)->FT_CLIEFOR,;
						(cAliasSFT)->FT_LOJA,;
						(cAliasSFT)->FT_ITEM,;
						(cAliasSFT)->FT_PRODUTO})
EndIf
Return(aRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |SPDRePorNf³ Autor ³Gustavo G. Rueda       ³ Data ³16.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³   GRAVACAO DE UM REGISTRO RELACIONADO COM SEU SUPERIOR     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Posiciono no registro com a chave passada como parametro e  ³±±
±±³          ³ gero o TXT na funcao SPEDGrvLin                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|nHandle -> Handle do arquivo txt aberto.                    ³±±
±±³          |cAlias -> Alias do TRB criado atraves da funcao principal.  ³±±
±±³          |cTpReg -> Tipo de registro que compoe a chave de pesquisa.  ³±±
±±³          |cRelac -> Relacionamento do registro que compoe a chave de  ³±±
±±³          | pesquisa                                                   ³±±
±±³          |nItem -> Item por relacionamento.                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPDRePorNf(nHandle,cAlias,cTpReg,cRelac,nItem,lExact)
	Local	lRet		:=	.T.
	Local	cChave		:=	cTpReg+cRelac
	Local	aAreaLoc	:=	(cAlias)->(GetArea())
	Local	bWhile		:=	{||!(cAlias)->(Eof ()) .And. cChave==(cAlias)->TRB_TPREG+(cAlias)->TRB_RELAC+Iif (nItem<>Nil .And. nItem>0, StrZero ((cAlias)->TRB_ITEM, 7, 0),"")}

	Default	lExact		:=	.F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para considerar o item de quebra ao efetuar o seek³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nItem<>Nil .And. nItem>0)
		cChave	+=	StrZero (nItem, 7, 0)
	EndIf

	If lExact
		bWhile	:=	{|| !(cAlias)->(Eof ()) .And. cChave==Left((cAlias)->TRB_TPREG+(cAlias)->TRB_RELAC+Iif(nItem<>Nil .And. nItem>0,StrZero((cAlias)->TRB_ITEM, 7, 0),""),Len(cChave))}
	EndIf

	If ((cAlias)->(DbSeek (cChave)))
		Do While Eval(bWhile)
			SPEDGrvLin(nHandle, cAlias)

			(cAlias)->(DbSkip ())
		EndDo
	EndIf

	RestArea (aAreaLoc)
Return (lRet)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SpdReg9900| Autor ³Gustavo G. Rueda              ³ Data ³03.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³REGISTROS DO ARQUIVO                                               ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Expl1 := SpdReg9900(cAlias,aReg9900)                               ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias   -> Alias do TRB que recebera as informacoes               ³±±
±±³          ³aReg9900 -> Array com informacoes que serao gravadas no TRB        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 - Sempre .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SpdReg9900(cAlias,aReg9900)
	Local	lRet	:=	.T.

	GrvRegTrS (cAlias,,aReg9900,)

Return (lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    |SpdReg9999| Autor ³Gustavo G. Rueda              ³ Data ³03.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ENCERRAMENTO DO ARQUIVO DIGITAL                                    ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpN1 := SpdReg9999(cAlias)                                        ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias   -> Alias do TRB que recebera as informacoes               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 - Sempre .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SpdReg9999(cAlias)
	Local	lRet	:=	.T.
	Local	nPos	:=	0
	Local	aReg	:= {}

	aAdd(aReg, {})
	nPos	:=	Len (aReg)
	nTotLin := (cAlias)->(RecCount()) + 1
	aAdd (aReg[nPos], "9999")					//01 - REG
	aAdd (aReg[nPos], Alltrim(STR(nTotLin)))	//02 - QTD_LIN
	GrvRegTrS (cAlias,,aReg,)
	//
Return (lRet)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    |SPDGerTrb | Autor ³Gustavo G. Rueda              ³ Data ³03.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ GERACAO DA ESTRUTURA DO TRB                                       ³±±
±±³          ³                                                                   ³±±
±±³          ³Geracao da estrutura do TRB utilizado em todo o processamento      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpL1 := GeraTrb (nTipo, aArq, cAlias)                             ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|nTipo -> 1=Gerar o TRB, 2=Fechar o TRB                             ³±±
±±³          ³cArq -> Nome fisico do TRB criado                                  ³±±
±±³          ³cAlias -> Alias do TRB criado                                      ³±±
±±³          ³lExtTaf -> Indica se a chamada da Funcao eh o Extrator TAF         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 - Sempre .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPDGerTrb(nTipo,aArq,cAlias,lExtTaf)
Local	lRet  		:=	.T.
Local	aCmp  		:=	{}
Local	cArq  		:=	""
Local	nI	  		:=	0
Local	nTamTRBIt	:=	50	//Tamanho do campo relac no TRB - Tem que ser numero exato, pois faco divisao por dois nos calculos.
Local   lInscPar := aSPDSX6[MV_INSCPAR]

Default lExtTaf := .F.

//
If (nTipo==0)
	//Refaz o indice do TRB
	If aScan(aArq, {|x| x[1]==cAlias}) > 0
		cArq := aArq[aScan(aArq, {|x| x[1]==cAlias})][2]
		IndRegua(cAlias, cArq, "TRB_TPREG+TRB_RELAC+StrZero(TRB_ITEM, 7, 0)")
	EndIf
ElseIf (nTipo==1)

	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³TRB Geral³
	//ÀÄÄÄÄÄÄÄÄÄÙ
	cAlias	:=	"TRB"
	aAdd (aCmp, {"TRB_TPREG",	"C", 	004,	   			0})
	aAdd (aCmp, {"TRB_RELAC",	"C", 	nTamTRBIt*2,		0})
	aAdd (aCmp, {"TRB_FLAG",	"C", 	001,				0})
	aAdd (aCmp, {"TRB_CONT",	"C", 	999,				0})
	aAdd (aCmp, {"TRB_ITEM",	"N", 	007,				0})
	cArq	:=	CriaTrab (aCmp)
	DbUseArea (.T., __LocalDriver, cArq, cAlias)
	IndRegua(cAlias, cArq, "TRB_TPREG+TRB_RELAC+StrZero(TRB_ITEM, 7, 0)")
 	aAdd (aArq, {cAlias, cArq})

Else
	For nI := 1 To Len (aArq)
		DbSelectArea (aArq[nI][1])
		(aArq[nI][1])->(DbCloseArea ())
		//Ferase (aArq[nI][2]+GetDBExtension ())
		//Ferase (aArq[nI][2]+OrdBagExt ())
	Next nI
EndIf

cAlias	:=	"TRB"	//Devo sempre retornar para os casos que nao tiverem TRB proprio.
Return (lRet)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SPDGet4DecºAutor  ³Demetrio De Los Riosº Data ³  05/25/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o campo em questao deve gerar 4 casas decimais º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ clReg = Registro a ser procurado no array alRegs           º±±
±±º          ³ nlNum = Numero do campo                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno  ³  llREt = Boolean (se deve exustir 4 casas decimais         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SPED PIS COFINS                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPDGet4Dec(clReg , nlNum)

Local lRet 	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VERIFICA SE O REGISTRO TEM CAMPOS COM 4 CASAS DECIMAIS  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := aScan(aCpo4Dec, {|x|x[1] == clReg .And. x[2] == nlNum}) > 0

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SPDGet3DecºAutor  ³Fabio Vessoni Santanaº Data ³  17/06/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o campo em questao deve gerar 4 casas decimais  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ clReg = Registro a ser procurado no array alRegs            º±±
±±º          ³ nlNum = Numero do campo                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno  ³  llREt = Boolean (se deve exustir 3 casas decimais          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SPED PIS COFINS                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPDGet3Dec(clReg , nlNum)

Local lRet 	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VERIFICA SE O REGISTRO TEM CAMPOS COM 3 CASAS DECIMAIS  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := aScan(aCpo3Dec, {|x|x[1] == clReg .And. x[2] == nlNum}) > 0

Return lRet

Function SPDGERNF();Return() // ***VERSÃO OBSOLETA*** - Rotina de Geracao do SPED PIS e COFINS buscando informacoes da Nota Fiscal da Saida, que nao foi gerado Livros Fiscais. - ***VERSÃO OBSOLETA***
// RETIRADAS TAMBEM AS FUNÇÕES PCCodCon() , SPEDPCFRT() , GrvNFTrS() TODAS ELAS FILHAS DA FUNÇÃO SPDGERNF()


//-------------------------------------------------------------------
/*/{Protheus.doc} SPDCodCont
Funcao que retorna o Codigo da Contribuicao, conforme
tabela 4.3.5 do Sped Contribuicoes

@param  NaoUsar	- Compatibilidade com a chamada da funcao
		lSemNota  - Origem de nota fiscal ou nao
		cCST  - Codigo da Situacao Tributaria
		nAliq  - Aliquota
		lCumulativ  - Indice da cumulatividade (originado de cadastros)
		aAtvImob  - Array com informacoes originadas de Ativo Imobilizado
		cRegime  - Tipo do Regime (wizard)
		lSCP - Indica se eh uma Contribuicao apurada de SCP

@return cCondCont - Retorna Codigo da Contribuicao

@author Luccas Curcio
@since 24/10/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function SPDCodCont(NaoUsar,lSemNota,cCST,nAliq,lCumulativ,aAtvImob,cRegime,lSCP)
Local	cCodCont	:=	""
Local	lSpedAz		:=	aSPDSX6[MV_SPEDAZ]
Default	lSemNota	:=	.F.
Default	lCumulativ	:=	.F.
Default	aAtvImob	:=	{}
Default	lSCP		:=	.F.
Default nAliq       := 0

//------------------------------------------------------------------------------------------
//Informacoes originadas de Ativo Imobilizado
//------------------------------------------------------------------------------------------
If Len(aAtvImob) > 0

	//Cumulativo
	If cRegime == "2"
		//Contribuicao cumulativa apurada a aliquota basica - Atividade Imobiliaria
		cCodCont	:=	"54"
	Else
		//Contribuicao nao-cumulativa apurada a aliquota basica - Atividade Imobiliaria
		cCodCont	:=	"04"
	EndIf

//------------------------------------------------------------------------------------------
//CSTs abaixo nao geram codigo de contribuicao
//------------------------------------------------------------------------------------------
Elseif cCST $ "04|06|07|08|09|49|98|99"
	cCodCont	:=	"  "

//------------------------------------------------------------------------------------------
//Contribuicao apurada de SCP - sociedade em conta de participacao
//------------------------------------------------------------------------------------------
Elseif lSCP

	//Operacao cumulativa
	If lCumulativ

		//Contribuicao apurada de SCP - Incidencia Cumulativa
		cCodCont	:=	"72"

	Else

		//Contribuicao apurada de SCP - Incidencia Nao Cumulativa
		cCodCont	:=	"71"

	Endif

Else
//------------------------------------------------------------------------------------------
//Operacao de Pis/Cofins de Substituicao Tributaria
//------------------------------------------------------------------------------------------
	If cCST == "05" .And. (!lSemNota .Or. (!lSpedAz .And. lSemNota))

		//Verifica Aliquota basica cumulativa
		If !lCumulativ .And. SA1->A1_EST = 'AM'
			cCodCont:=Iif(nAliq>0 ,"32" ,"" )
			//Contribuicao apurada por substituicao tributaria - Vendas a Zona Franca de Manaus
		Else
			cCodCont:=Iif(nAliq>0 ,"31" ,"" )
			//Contribuicao apurada por substituicao tributaria
		Endif

	Else
//------------------------------------------------------------------------------------------
//Demais Operacoes
//------------------------------------------------------------------------------------------

		//-----------------------------------------------------------------------
		//Preencho primeiro caracter do codigo, utilizando Regime como parametro
		//-----------------------------------------------------------------------
		//Regime Nao-Cumulativo (wizard) / Nao-Cumulativo (caso de escolher 3=Ambos na wizard)
		If "1"$cRegime .Or. ("3"$cRegime .And. !lCumulativ)

			cCodCont	:=	"0"

		//Regime Cumulativo (wizard) / Cumulativo (caso de escolher 3=Ambos na wizard)
		ElseIf "2"$cRegime .Or. ("3"$cRegime .And. lCumulativ)

			cCodCont	:=	"5"

		Endif

	    //-----------------------------------------------------------------------
	    //Preencho segundo caracter do codigo, utilizando CST como parametro
		//-----------------------------------------------------------------------

		//Operacao Tributavel com Aliquota Diferenciada
		If cCST == "02"

			cCodCont	+=	"2"

		//Operacao Tributavel com Aliquota por Unidade de Medida de Produto
		Elseif cCST == "03"

			cCodCont	+=	"3"

		//Operacao Tributavel com Aliquota Basica
		Else

			cCodCont	+=	"1"

		Endif
	Endif
Endif

Return cCodCont

//-------------------------------------------------------------------
/*/{Protheus.doc} SPEDCodCre
Funcao que retorna o Codigo de Tipo de Credito, conforme
tabela 4.3.6 do Sped Contribuicoes

@param  cCST  - Codigo da Situacao Tributaria
		cCodBCC  - Codigo de Base de Calculo do Credito
		lPauta  - Operacao com Unidade de Produto
		lImport  - Operacao de Importacao
		cCodNatRec  - Codigo da Natureza da Receita
		cIndCont  - Tipo de Aliquota (Basica/Diferenciada)
		cAlqUni  - Aliquota Unidade de Produto
		nCont  - Contador com Posicao do Tipo de Receita (1,2,3)
		lAgrIndust - Operação Agroindustria

@return cCodCred - Retorna Codigo do Tipo de Credito

@author Luccas Curcio
@since 28/11/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function SPEDCodCre(cCST,cCodBCC,lPauta,lImport,cCodNatRec,cIndCont,cAlqUni,nCont,lAgrIndust)

Local	cCodCred		:=	""
Local	lMultTpRec		:=	.F.

Default nCont			:=	0
Default cAlqUni		:=	""
Default lAgrIndust 	:= .F.

Do Case

	//Codigos Vinculados a Receita Tributada no Mercado Interno
	Case cCST $ "50/60"
		cCodCred	:=	"1"

	//Codigos Vinculados a Receita Nao Tributada no Mercado Interno
	Case cCST $ "51/61"
		cCodCred	:=	"2"

	//Codigos Vinculados a Receita de Exportacao
	Case cCST $ "52/62"
		cCodCred	:=	"3"

	//Chamada da funcao CSTREC() para mais de um tipo de receita
	OtherWise
		cCodCred	:=	CSTREC(cIndCont,cAlqUni,lImport,nCont,cCst,cCodBCC,lAgrIndust)
		lMultTpRec	:=	.T.

EndCase

If !lMultTpRec
	//Codigo de Base de Calculo do Credito 15 - Atividade Imobiliaria - Custo Incorrido de Unidade Imobiliaria
	//Codigo de Base de Calculo do Credito 16 - Atividade Imobiliaria - Custo Orcado de unidade nao concluida
	If cCodBCC $ "15/16"

		//Atividade Imobiliaria
		cCodCred	+=	"09"

	//Codigo de Base de Calculo do Credito 18 - Estoque de abertura de bens
	Elseif cCodBCC == "18"

		//Estoque de Abertura
		cCodCred	+=	"04"

	//Codigo da Situacao Tributaria 6x (exceto 67) - Credito Presumido - Operacao de Aquisicao Vinculada Exclusivamente a Receita Tributada no Mercado Interno
	Elseif Substr(cCST,1,1) $ "6" .And. cCst <> "67"

		If lAgrIndust
			cCodCred	+=	"06" 		//Presumido da Agroindustria
		Else
			cCodCred	+=	"07" 		//Outros Créditos Presumidos
		EndIf

	//Importacao
	Elseif lImport

		//Importacao
			cCodCred	+=	"08"

	//Operacoes com Unidade de Produto
	Elseif  lPauta

		//Codigo da Natureza da Receita iniciado por 7
		If cCodNatRec == "7"

		    //Aquisicao Embalagens para revenda
			cCodCred	+=	"05"

		Else
		    //Aliquota por Unidade de Produto
			cCodCred	+=	"03"
		Endif

	//Aliquota basica
	ElseIf cIndCont == "1"

	    //Aliquota Basica
		cCodCred	+=	"01"

	Else

	    //Aliquota Diferenciada
		cCodCred	+=	"02"
	EndIf
Endif

Return cCodCred

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |SPDLeRegRel³ Autor ³Gustavo G. Rueda       ³ Data ³16.03.2011³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o³Essa funcao primeiramente procura o relacionamento exato,    ³±±
±±³          ³ caso nao encontre, ela procura novamente quebrando pelo    ³±±
±±³          ³ grupo. Os codigos de grupo devem ser unicos por grupo, para³±±
±±³          ³ nao gerar informacoes divergentes.                         ³±±
±±³          ³Esta funcao soh prepara os registros para gravacao que serah³±±
±±³          ³ efetuada pela funcao SPDRePorNf                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|nHandle -> Handle do arquivo txt aberto.                    ³±±
±±³          |cAlias -> Alias do TRB criado atraves da funcao principal.  ³±±
±±³          |cRegP  -> Identificador do registro PAI                     ³±±
±±³          |aRegF  -> Array com os identificadores dos registros filhos ³±±
±±³          |cRelac -> Relacionamento do registro pai para com os filhos ³±±
±±³          |nTo    -> Determina se permite fazer o segundo seek ou nao  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPDLeRegRel(nHandle,cAlias,cRegP,aRegF,cRelac,nTo)
Local	nTamTRBIt	:=	Len((cAlias)->TRB_RELAC)/2		//Efetuo divisao por dois porque faco dois controles em um mesmo campo. O relacionamento e sequencia. Ex: ...0001...1, ...0001...2
Local	cChave		:=	cRegP+cRelac					//Chave do primeiro SEEK
Local	cChave2		:=	cRegP+SubStr(cRelac,1,nTamTRBIt)//Chave do segundo SEEK
Local	nI			:=	0
Local	nX			:=	0
Local	aAreaLoc	:=	(cAlias)->(GetArea())

Default	nTo			:=	1

For nI := 1 To nTo
	If (cAlias)->(DbSeek (cChave))
		Do While !(cAlias)->(Eof ()) .And. cChave==Left((cAlias)->TRB_TPREG+(cAlias)->TRB_RELAC,Len(cChave))

			If Empty((cAlias)->TRB_FLAG)

				SPEDGrvLin(nHandle,cAlias)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Utilizo o codigo de relacionamento do PAI para procurar os FILHOS.     ³
				//³Esta troca deve ser executada sometne para o segundo seek, pois no pri-³
				//³ meiro o RELAC fica a criterio de como for passado, para o segundo nao,³
				//| pego do TRB                                                           |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nI==2
					cRelac	:=	(cAlias)->TRB_RELAC
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Gravo todos os filhos correspondentes ao PAI³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nX := 1 To Len(aRegF)
			   		SPDRePorNf(nHandle,cAlias,aRegF[nX],cRelac,(cAlias)->TRB_ITEM,nTo==2)
			 	Next nX
			EndIf

			(cAlias)->(DbSkip ())
		EndDo
		//Exit
	EndIf
	cChave	:=	cChave2	//Trocando a chave para o segundo SEEK
Next nI

RestArea(aAreaLoc)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SpedRg1010³ Autor ³ Luccas Curcio          ³ Data ³25.07.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera o Registro 1010 									   ³±±
±±³          ³ 											                   ³±±
±±³          ³ OBRIGATORIEDADE DE REGISTROS DO BLOCO 1                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> informacoes preenchidas no Wizard                 ³±±
±±³          ³ cAlias -> Alias do TRB   								   ³±±
±±³          ³ aReg1010 -> Array que contem os registros obrigatorios	   ³±±
±±³          ³ 			  declarados no registro 1010					   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SpedRg1010(aWizard,cAlias,aReg1010)
Local	nPos	:=	0
Local	nX		:=	0

aAdd(aReg1010, {})
nPos	:=	Len (aReg1010)
aAdd (aReg1010[nPos], "1010")	//01 - REG

//Verifico se o periodo utiliza a partir da versao 006 do layout
If cVersao >= "006"

	//Se possui as perguntas do registro na wizard, verifico as respostas do usuario, senao preencho o registro com "N"
	If Len(aWizard) >= 4
		For nX := 1 To 9
			aAdd(aReg1010[nPos], Iif("1"$aWizard[4][nX],"S","N"))
		Next nX
	Else
		For nX := 1 To 9
			aAdd(aReg1010[nPos], "N")
		Next nX
	Endif

	//Tratamento específico para o registro 1400, pois existem duas opções na Wizard.
	if "1" $ aWizard[4][5]  .or. "1" $ aWizard[4][10]
		aReg1010[nPos][6] := "S"
	endif

	If cVersao >= "013"
		aAdd(aReg1010[nPos], Iif("1"$aWizard[4][11],"S","N"))
		aAdd(aReg1010[nPos], Iif("1"$aWizard[4][12],"S","N"))
		aAdd(aReg1010[nPos], Iif("1"$aWizard[4][13],"S","N"))
	Endif
	If cVersao >= "014"
		aAdd(aReg1010[nPos], Iif("1"$aWizard[4][14],"S","N"))
	EndIf

	//Efetuo gravacao do registro 1010 na temporaria
	GrvRegTrS (cAlias,,aReg1010)

/* Se estiver utilizando layout antes da versao 006, apenas preencho o registro
para gerar os demais do bloco 1, mas nao gravo o registro 1010 na temporaria */
Else
	For nX := 1 To 9
		aAdd(aReg1010[nPos], "S")
	Next nX
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SpedMotInv
Funcao que retorna se o produto devera ser gerado nos registros do
Inventario (Bloco H)

@param  cMotInv  - Motivo do Inventario (01 - 05)
		cProd  - Codigo do produto
		nAliqProd  - Aliquota interna do produto

@return lRet - Processa ou nao o produto

@author Luccas Curcio
@since 20/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function SpedMotInv(cMotInv,cProd,lCmpAltTri,nAliqProd)
Local	lRet	:=	.F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Motivos de Inventario:	01 - No final no periodo;															³
//³							03 - Na solicitacao da baixa cadastral, paralisacao temporaria e outras situacoes;	³
//³							04 - Na alteracao de regime de pagamento - condicao do contribuinte;				³
//³							05 - Por determinacao dos fiscos													³
//³																												³
//³Processo todos os produtos para o H010 e soh nao processa H020 para Motivo 01 (verificacao no SPEDFISCAL)	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cMotInv $ "01|03|04|05"

	lRet := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Motivo de Inventario 02 - Na mudanca de forma de tributacao da mercadoria (ICMS)	³
//³																					³
//³Apenas gero o registro H010 se houve alteracao na forma de tributacao, indicado	³
//³no campo B5_ALTTRIB 																³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifico se houve alteracao na forma de tributacao de ICMS	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCmpAltTri .And. SB5->(MsSeek(xFilial("SB5")+PadR(Alltrim(cProd),TamSX3("B1_COD")[1])))
		If SB5->B5_ALTTRIB == "1"
			lRet := .T.
		Endif
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para obter a aliquota interna do produto, caso o campo no cadastro nao esteja preenchido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nAliqProd <= 0
	nAliqProd := aSPDSX6[MV_ICMPAD]
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SpedApE200| Autor ³Gustavo G. Rueda 			   ³ Data ³04.05.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³                        GERACAO DO BLOCO E                         ³±±
±±³          ³REGISTRO E200 - PERIODO DA APURACAO DO ICMS ST                     ³±±
±±³          ³REGISTRO E210 - APURACAO DO ICMS - SUBSTITUICAO TRIBUTARIA         ³±±
±±³          ³REGISTRO E250 - OBRIGACOES DO ICMS A RECOLHER - SUBSTITUICAO       ³±±
±±³          ³                TRIBUTARIA                                         ³±±
±±³          ³                                                                   ³±±
±±³          ³Funcao utilizada para montar a estrutura dos registros acima       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 -> Identifica se houve movimento no periodo ou nao           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aRegE200 -> Array com as informacoes do registro E200              ³±±
±±³          ³aRegE210 -> Array com as informacoes do registro E210              ³±±
±±³          ³aRegE250 -> Array com as informacoes do registro E250              ³±±
±±³          ³aVlrMovST- Valores de apuracao obtidos durante o processamento dos ³±±
±±³          ³           documentos                                              ³±±
±±³          ³nApuracao -> Tipo de apuracao, padrao 3                            ³±±
±±³          ³nPeriodo  -> Periodo de apuracao, padrao 1                         ³±±
±±³          ³cNrLivro  -> Numero do livro selecionado no wizard                 ³±±
±±³          ³cArqAnt- Arquivo de apuraao do periodo anterior inf. no wizard     ³±±
±±³          ³cMVEstado -> Conteudo do parametro MV_ESTADO                       ³±±
±±³          |aIcmPago - Informacoes das GNREs de documentos fiscais para o E250 ³±±
±±³          ³cMVSUBTRIB-Conteudo do parametro MV_SUBTRIB                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SpedApE200(aRegE200,aRegE210,aRegE250,aVlrMovST,nApuracao,nPeriodo,cNrLivro,cArqAnt,cMVEstado,aIcmPago,cMVSUBTRIB,lExtratTAF)
Local	nX			:=	0
Local	nUf			:=	0
Local	nPos		:=	0

local lFindSF6 := .F.

Default lExtratTAF := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Apos a execucao do RESUMEF3, apuro alguns valores para por UF para alimentar o E210 corretametne³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nUF := 1 To Len(aRegE200)

	aApuracao	:=	SpedCkApST(aVlrMovST,nApuracao,nPeriodo,cNrLivro,cArqAnt,cMVEstado,aRegE200[nUF,2],cMVSUBTRIB,aRegE200[nUF,4])

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³(3) VL_SLD_CRED_ANT_ST - Valor do "SALDO CREDOR DE PERIODO ANTERIOR -ST"³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRegE210[nUF,4]	+=	aApuracao[1]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³(4) VL_DEVOL_ST - Valor total de ICMS ST de devolucao de mercadorias³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRegE210[nUF,5]	+=	aApuracao[2]

   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³(5) VL_RESSARC_ST - Valor total do ICMS ST de ressarcimentos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRegE210[nUF,6]	+=	aApuracao[5]
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³(6)VL_OUT_CRED_ST = Valor total de ajustes "OUTROS CREDITOS ST ou ³
	//³                                        ESTORNO DE DEBITOS ST"    ³
	//³                                                                  ³
	//³O valor considerado aqui se refere ao credST                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRegE210[nUF,7]	+=	aApuracao[3]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³(8)VL_RETENCAO_ST - Valor total do ICMS ST retido por ST³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRegE210[nUF,9]	+=	aApuracao[4]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualizando valores de alguns campos do registro E210 que dependem³
	//³ dos valores dos lancamentos                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//(11)VL_SLD_DEV_ANT_ST - Valor total do saldo devedor antes das deducoes
	aRegE210[nUf,12]	:=	(aRegE210[nUf,9]+aRegE210[nUf,10]+aRegE210[nUf,11])-(aRegE210[nUf,4]+aRegE210[nUf,5]+aRegE210[nUf,6]+aRegE210[nUf,7]+aRegE210[nUf,8])

	//(13)VL_ICMS_RECOL_ST - Imposto a recolher ST
	aRegE210[nUf,14]	:=	aRegE210[nUf,12]-aRegE210[nUf,13]

	//(14)VL_SLD_CRED_ST_TRANSPORTAR - Saldo credor a transportar para o periodo seguinte
	If aRegE210[nUf,14]<0
		aRegE210[nUf,15]	:=	Abs(aRegE210[nUf,14])

		//Acertando valores negativos
		aRegE210[nUf,12]	:=	Max(aRegE210[nUf,12],0)
		aRegE210[nUf,14]	:=	Max(aRegE210[nUf,14],0)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se algum valor de ST foi encontrado na apuracao do periodo,    |
	//|  altero o Flag para "1" para indicar movimento                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 4 To Len(aRegE210[nUf])
		If aRegE210[nUf,nX]>0
			aRegE210[nUf][3]	:=	"1"
			Exit
		EndIf
	Next nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica GUIAS pagas na emissao do documento para agregar no registro E250 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to Len(aIcmPago)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Garanto que as GNREs em processamento sejam para o mesmo estado da apuracao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aIcmPago[nX][1]==aRegE200[nUF,2] .AND. Iif(Len(aIcmPago[nX]) >= 12,aIcmPago[nX][12] == '3',.T. ) //Não considera valores do Difal em E250

			//Se tiver GUIA, tenho que alterar o STATUS do registro E210, mesmo que tenha somente a GNRE, sem nenhum valor no E210
			aRegE210[nUf][3]	:=	"1"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³REGISTRO E250 - OBRIGACOES DO ICMS A RECOLHER - SUBSTITUICAO TRIBUTARIA                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAdd(aRegE250, {})
			nPos	:=	Len (aRegE250)
			aAdd (aRegE250[nPos], nUF)							//Relacionamento com E210
			aAdd (aRegE250[nPos], "E250")						//01 - REG

			lFindSF6 := SPEDSeek("SF6",1,xFilial("SF6")+cMVESTADO+aIcmPago[nX][3])

			if	lFindSF6

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Definindo o codigo da obrigacao a recolher³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SF6->F6_OPERNF == "1"
					aAdd (aRegE250[nPos], "001")				//02 - COD_OR - Entradas
				ElseIf SF6->F6_EST==cMvEstado
					aAdd (aRegE250[nPos], "002")				//02 - COD_OR - Saidas p/ Estado
				Else
					aAdd (aRegE250[nPos], "999")				//02 - COD_OR - Saidas fora Estado
				EndIf
			Else
				aAdd (aRegE250[nPos], "999")					//02 - COD_OR - Saidas fora Estado
			EndIf
			aAdd (aRegE250[nPos], aIcmPago[nX][2])				//03 - VL_OR
			aAdd (aRegE250[nPos], aIcmPago[nX][4])				//04 - DT_VCTO
			aAdd (aRegE250[nPos], aIcmPago[nX][5])				//05 - COD_REC
			aAdd (aRegE250[nPos], aIcmPago[nX][9])				//06 - NUM_PROC
			aAdd (aRegE250[nPos], aIcmPago[nX][10])			//07 - IND_PROC
			aAdd (aRegE250[nPos], aIcmPago[nX][11])			//08 - PROC
			aAdd (aRegE250[nPos], aIcmPago[nX][6])				//09 - TXT_COMPL

			If cVersao >= "004" //A partir de janeiro de 2011 incluir o campo 10 mmaaaa
				aAdd (aRegE250[nPos], StrZero(aIcmPago[nX][7],2) + cValToChar(aIcmPago[nX][8]))//10 - MES_REF
			EndIf

			//Para o extrator fiscal preciso levar o número da GNRE para amarrar no TAF
			if lExtratTAF
				if lFindSF6
					aAdd(aRegE250[nPos], SF6->F6_NUMERO)					//11-Numero da Guia
					aAdd(aRegE250[nPos], IIF(Empty(SF6->F6_NUMERO),"",iIF(SF6->F6_TIPOIMP=="0","0","1")) )//12 - COD_DA
				else
					aAdd(aRegE250[nPos], '')					//11-Numero da Guia
					aAdd(aRegE250[nPos], '' )//12 - COD_DA
				endif
			endif

		EndIf
	Next
Next nUF
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SpedXAjSCP
Funcao que processa os documentos fiscais de Sociedade em Conta de
Participacao, para que sejam gerados os ajustes e registros correspondentes

@param  nOpc  - Opcao de processamento da funcao. Opcao 1: Ajustes de
				Contribuicao com base nos documentos apurados; Opcao 2: Ajustes
				de Credito com base nos documentos apurados; Opcao 3: Ajustes
				de Contribuicao com base nos Ajustes de Credito
		xInfDoc  - Informacoes do documento de origem
		aAjReduc  - Array preenchido com informacoes dos ajustes de reducao
		aAjAcres  - Array preenchido com informacoes dos ajustes de acrescimo
		lCumulativ  - Indica se eh uma operacao do regime cumulativo
		cRegime  - Regime selecionado na wizard da rotina
		dDataAte  - Data Final do processamento

@return Nil

@author Luccas Curcio
@since 19/12/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function SpedXAjSCP(nOpc,xInfDoc,aAjReduc,aAjAcres,lCumulativ,cRegime,dDataAte)
Local	nPos		:=	0
Local	nValPis		:=	0
Local	nValCof		:=	0
Local	nAliqPis	:=	0
Local	nAliqCof	:=	0
Local	cCST		:=	""
Local	cCodCont	:=	""
Local	lTypeChar	:=	ValType(xInfDoc) == "C"

//Verifico se as informacoes do documento sao passadas por uma query (Blocos A, C, D) ou um array (Bloco F)
nValPis		:=	Iif ( lTypeChar,	(xInfDoc)->FT_VALPIS,	xInfDoc[6] )
nValCof		:=	Iif ( lTypeChar,	(xInfDoc)->FT_VALCOF,	xInfDoc[10])
nAliqPis	:=	Iif ( lTypeChar,	(xInfDoc)->FT_ALIQPIS,	xInfDoc[5] )
nAliqCof	:=	Iif ( lTypeChar,	(xInfDoc)->FT_ALIQCOF,	xInfDoc[9] )
cCST		:=	Iif ( lTypeChar,	(xInfDoc)->FT_CSTPIS,	xInfDoc[3] )

//-----------------------------------------------------------------------
//Opcao 1: Ajustes de Contribuicao com base nos documentos apurados
//-----------------------------------------------------------------------
If nOpc == 1

	//Verifico o codigo da contribuicao
	cCodCont	:=	SpdCodCont(,.F.,cCST,,lCumulativ,,cRegime)

	//Gravo na posicao 10 do array aAjReduc a filial SCP que esta fazendo o ajuste, pois devo segregar esta informacao
	//ao gerar os registros de contribuicao. Utilizo o Codigo de Contribuicao e a filial na chave do processamento
	If (nPos := aScan( aAjReduc, {|x| x[1] == cCodCont .And. x[10] == FWGETCODFILIAL } ) ) == 0

		//Ajuste de reducao
		aAdd(aAjReduc, {})
		nPos := Len(aAjReduc)
		aAdd (aAjReduc[nPos], cCodCont)
		aAdd (aAjReduc[nPos], nValPis)
		aAdd (aAjReduc[nPos], nValCof)
		aAdd (aAjReduc[nPos], "05")
		aAdd (aAjReduc[nPos], "")
		aAdd (aAjReduc[nPos], "Ajuste de Redução - Sociedade em Conta de Participação (Filial: "+FWGETCODFILIAL+")")
		aAdd (aAjReduc[nPos], dDataAte)
		aAdd (aAjReduc[nPos], nAliqPis)
		aAdd (aAjReduc[nPos], nAliqCof)
		aAdd (aAjReduc[nPos], FWGETCODFILIAL)
	Else
		//Aglutina valores - Ajuste de reducao
		aAjReduc[nPos][2]	+=	nValPis
		aAjReduc[nPos][3]	+=	nValCof
	Endif


	//Retorno codigo da contribuicao em relacao a SCP - 71 ou 72
	cCodCont	:=	SpdCodCont(,.F.,cCST,,lCumulativ,,cRegime,.T.)

	If (nPos := aScan( aAjAcres, {|x| x[1] == cCodCont .And. x[10] == FWGETCODFILIAL } ) ) == 0

		//Ajuste de acrescimo
		aAdd(aAjAcres, {})
		nPos := Len(aAjAcres)
		aAdd (aAjAcres[nPos], cCodCont)
		aAdd (aAjAcres[nPos], nValPis)
		aAdd (aAjAcres[nPos], nValCof)
		aAdd (aAjAcres[nPos], "05")
		aAdd (aAjAcres[nPos], "")
		aAdd (aAjAcres[nPos], "Ajuste de Acréscimo - Sociedade em Conta de Participação (Filial: "+FWGETCODFILIAL+")")
		aAdd (aAjAcres[nPos], dDataAte)
		aAdd (aAjAcres[nPos], nAliqPis)
		aAdd (aAjAcres[nPos], nAliqCof)
		aAdd (aAjAcres[nPos], FWGETCODFILIAL)
	Else
		//Aglutina valores - Ajuste de acrescimo
		aAjAcres[nPos][2]	+=	nValPis
		aAjAcres[nPos][3]	+=	nValCof
	Endif

//-----------------------------------------------------------------------
//Opcao 2: Ajustes de Credito com base nos documentos apurados
//-----------------------------------------------------------------------
Elseif nOpc == 2

	If (nPos := aScan( aAjReduc, {|x| x[1] == FWGETCODFILIAL } ) ) == 0

		//Ajuste de reducao
		aAdd(aAjReduc, {})
		nPos := Len(aAjReduc)
		aAdd (aAjReduc[nPos], FWGETCODFILIAL)
		aAdd (aAjReduc[nPos], "0")
		aAdd (aAjReduc[nPos], nValPis)
		aAdd (aAjReduc[nPos], nValCof)
		aAdd (aAjReduc[nPos], "05")
		aAdd (aAjReduc[nPos], "Ajuste de Redução - Sociedade em Conta de Participação (Filial: "+FWGETCODFILIAL+")")
		aAdd (aAjReduc[nPos], dDataAte)

	Else

		//Aglutina valores - Ajuste de reducao
		aAjReduc[nPos][3]	+=	nValPis
		aAjReduc[nPos][4]	+=	nValCof

	Endif

//-----------------------------------------------------------------------
//Opcao 3: Ajustes de Contribuicao com base nos Ajustes de Credito
//-----------------------------------------------------------------------
Elseif nOpc == 3

	//Retorno codigo da contribuicao em relacao a SCP - 71 ou 72
	cCodCont	:=	SpdCodCont(,.F.,cCST,,lCumulativ,,cRegime,.T.)

	//Gravo na posicao 10 do array aAjReduc a filial SCP que esta fazendo o ajuste, pois devo segregar esta informacao
	//ao gerar os ajustes. Utilizo o Codigo de Contribuicao e a filial na chave do processamento
	If (nPos := aScan( aAjReduc, {|x| x[1] == cCodCont .And. x[10] == FWGETCODFILIAL } ) ) == 0

		//Ajuste de reducao
		aAdd(aAjReduc, {})
		nPos := Len(aAjReduc)
		aAdd (aAjReduc[nPos], cCodCont)
		aAdd (aAjReduc[nPos], nValPis)
		aAdd (aAjReduc[nPos], nValCof)
		aAdd (aAjReduc[nPos], "05")
		aAdd (aAjReduc[nPos], "")
		aAdd (aAjReduc[nPos], "Ajuste de Redução Proveniente de Ajustes de Crédito - Sociedade em Conta de Participação (Filial: "+FWGETCODFILIAL+")")
		aAdd (aAjReduc[nPos], dDataAte)
		aAdd (aAjReduc[nPos], nAliqPis)
		aAdd (aAjReduc[nPos], nAliqCof)
		aAdd (aAjReduc[nPos], FWGETCODFILIAL)

	Else
		//Aglutina valores - Ajuste de reducao
		aAjReduc[nPos][2]	+=	nValPis
		aAjReduc[nPos][3]	+=	nValCof

	Endif
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SpdXRetCod
Funcao que retorna os codigos conforme regime ou outra caracteristica
especifica, conforme parametros enviados

@param  nTipo  - Opcao do tipo de codigo. Tipo 1: Codigos de Contribuicao
		aTipo  - Array com os tipos de codigos que serao retornados.
				 Ex.: NC -> Nao Cumulativo; C -> Cumulativo

@return Nil

@author Luccas Curcio
@since 19/12/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function SpdXRetCod(nTipo,aTipo)
Local	cRet	:=	""
Local	nX		:=	0
Default aTipo	:=	{}

For nX := 1 To Len(aTipo)

	//Retorna codigos de Contribuicao
	If nTipo == 1
		//Codigos de Contribuicao - Cumulativo
		If aTipo[nX] == "C"
			cRet	+=	"51, 52, 53, 54, 41, 72, 31, "
		//Codigos de Contribuicao - Nao Cumulativo
		Elseif aTipo[nX] == "NC"
			cRet	+=	"01, 02, 03, 04, 32, 71, "
		//Codigos de Contribuicao - Atividade Imobiliaria - RET
		Elseif aTipo[nX] == "RET"
			cRet	+=	"70, "
		//Codigos de Contribuicao - Folha de Salario
		Elseif aTipo[nX] == "FS"
			cRet	+=	"99, "
		Endif
	Endif

Next nX

//Exclui a virgula no final da string
cRet	:=	Substr(cRet,1,Len(cRet)-2)

Return cRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SPDG130140| Autor ³Gustavo G. Rueda 			   ³ Data ³18.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ OLD => SPDBGPrDoc                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao utilizada para montar um array com as informacoes dos       ³±±
±±³          ³ documentos de acordo com o tipo de movimento para gerar os        ³±±
±±³          ³ registro G130 e G140                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lTop     - Flag que indica processamento em ambiente TOP           ³±±
±±³          ³cAliasSFA- Alias de processamento da tabela SFA                    ³±±
±±³          ³cTpMov   - Flag que identifica o tipo de movimento CIAP            ³±±
±±³          ³lAchouSFT- Flag que indica posicionamento da tabela SFT para o     ³±±
±±³          ³  documento de entrada                                             ³±±
±±³          ³lAchouSA2- Flag que indica posicionamento da tabela SA2 para o     ³±±
±±³          ³  documento de entrada                                             ³±±
±±³          ³aCmpsSF9 - Informacoes processadas atraves de parametros para dados³±±
±±³          ³  dos documentos de entrada que nao existam no sistema             ³±±
±±³          ³aReg0150 - Array com os dados dos participantes para validacao     ³±±
±±³          ³cAlias   - Alias do TRB                                            ³±±
±±³          ³aWizard  - Informacoes do assistente da rotina                     ³±±
±±³          ³lAchouSB1- Flag que indica posicionamento da tabela SB1 para o     ³±±
±±³          ³  documento de entrada                                             ³±±
±±³          ³aReg0190 - Array de UM      para consistir um novo dado            ³±±
±±³          ³aReg0200 - Array de produto para consistir um novo dado            ³±±
±±³          ³aReg0220 - Array de produto para consistir um novo dado            ³±±
±±³          ³nRecnoSFT - Recno do SFT do registro                               ³±±
±±³          ³lF9SKPNF - Conteudo do parametro MV_F9SKPNF                        ³±±
±±³          ³lExtratTAF - Informa se a chamada da funcao eh o Extrator TAF      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPDG130140(lTop,cAliasSFA,cTpMov,lAchouSFT,lAchouSA2,aCmpsSF9,aReg0150,cAlias,aWizard,lAchouSB1,aReg0200,aReg0190,aReg0220,nRecnoSFT,lF9SKPNF,aExistBloc,aAlIndic,lExtratTAF,lConcFil,nVLLEG)
Local  aPartDoc	    :=	{}
Local  aInf		    :=	{}
Local  n2RecnoSFT	:=	Nil
Local  nRecnoSD2	:=	Nil
Local  nRecnoSA1	:=	Nil
Local  n2RecnoSB1	:=	Nil
Local  lAchou2SFT	:=	.F.
Local  lAchouSA1	:=	.F.
Local  lAchouSD2 	:= 	.F.
Local  lAchouSD1	:=	.F.
Local  dDataDe		:=	""
Local  dDataAte	    :=	""
Local  lIniObrFis   := 	""
Local  cCodPro		:=	""
Local  cNumItem	    :=	""
Local  cEspecie	    :=	""
Local  cChvNfe		:=	""
Local  aProd		:=	Nil
Local  cUnid	    :=	Nil
Local  cSegUnid	    := ""
Local  cTpUnid		:= ""
Local  nConvUnid	:= 0
Local  cIndEmit     := ""
Local  nRecnoSN3    := 0
Local  lAdiant		:= .F.
local  cGNRE        := ""
Local  aAreaAnt     := {}
Local  nQuantia     := 0
Local  cTes         := ""
Local  nMV_SPEDQTD	:=	aSPDSX6[MV_SPEDQTD]
Local  lCompFret	:= .F.
Local  lComplIcm	:= .F.

Default nRecnoSFT	:= Nil
Default lF9SKPNF	:= .F.
Default lExtratTAF  := .F.
Default lConcFil	:= .T.
Default aAlIndic    := {}
Default aWizard   	:={}

If !lExtratTAF
	dDataDe		:=	SToD(aWizard[1,1])
	dDataAte	:=	SToD(aWizard[1,2])
	lIniObrFis  := Iif("1"$aWizard[1][14],.T.,.F.)
Else
	dDataDe		:=	aWizard[1,3]
	dDataAte	:=	aWizard[1,4]
	lIniObrFis  := Iif("1"$aWizard[1][8],.T.,.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para enviar as informacoes de saida para os respectivos TIPO DE MOVIMENTO³
//| MC e IA nao eh tratado pela aplicacao                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aInf, {})
If cTpMov$"MC/IM/IA/AT/SI/CI"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso o campo "Inicio Obrigacao Escrituraca Fiscal CIAP" seja "Sim" os blocos G130 e G140 serao gerados para todos os bens que tiveram movimentacao  |
	//| do ativo imobilizado (campo TIPO_MOV do registro G125(Movimentação de Bem ou componente do ativo imobilizado) igual a "SI")                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cTpMov$"/IM/IA/CI" .Or. (lIniObrFis .And. cTpMov $ "/SI") //ENTRADA

		// Reposiciona a tabela SFT. pois quando ha devolucao na baixa a mesma e' desposicionada
		If !lF9SKPNF
			lAchouSFT := SPEDSeek("SFT",,xFilial("SFT")+"E"+SF9->(F9_SERNFE+F9_DOCNFE+F9_FORNECE+F9_LOJAFOR+F9_ITEMNFE),nRecnoSFT)
			If lAchouSFT
				lAchouSD1 := SPEDSeek("SD1",,xFilial("SD1")+SF9->F9_DOCNFE+SF9->F9_SERNFE+SF9->F9_FORNECE+SF9->F9_LOJAFOR+SFT->FT_PRODUTO+SF9->F9_ITEMNFE)
				If lAchouSD1
					lCompFret := SD1->D1_TIPO == "C" .And. SF9->F9_VALFRET == 0
					lComplIcm := SD1->D1_TIPO == "I"
				EndIf
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para verificar o tipo de emissao do documento fiscal³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//Emissao Propria
		If lAchouSFT .And. "S" $SFT->FT_FORMUL
			cIndEmit := "0"
		//Emissao de Terceiros
		Else
			cIndEmit := "1"
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para participante³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAchouSA2 .And. !(AllTrim(SF9->F9_CODBAIX) $ 'BFINAL')
			aPartDoc :=	InfPartDoc ("SA2",,,,,,,lExtratTAF)
			If !lExtratTAF
				SDPF150175(@aReg0150,aPartDoc,cAlias,aWizard,,lExtratTAF)
			EndIf
		Else
			aAdd(aPartDoc,"")
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para quando nao encontrar a NF, possibilita a criacao de um campo³
		//³ no SF9 para gerar a informacao                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAchouSFT   .Or. Empty(aCmpsSF9[1])
			cEspecie	:=	AModNot(SFT->FT_ESPECIE)
		ElseIf !Empty(aCmpsSF9[1])	//f9_especie
			cEspecie	:=	iif(AModNot(aCmpsSF9[2])<>"", AModNot(aCmpsSF9[2]), AModNot(SFT->FT_ESPECIE))
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para quando nao encontrar a NF, possibilita a criacao de um campo³
		//³ no SF9 para gerar a informacao                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAchouSFT
			cChvNfe	:=	SFT->FT_CHVNFE
		ElseIf !Empty(aCmpsSF9[2])
			cChvNfe	:=	aCmpsSF9[4]
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para utilizar o padrao ou customizado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(SF9->F9_ITEMNFE)
			cNumItem	:=iif(!empty(aCmpsSF9[6]),AllTrim(Str(Val(aCmpsSF9[6]))),"1")
		Else
			cNumItem	:= iif(!empty(SF9->F9_ITEMNFE), AllTrim(Str(Val(SF9->F9_ITEMNFE))),"1")
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para o produto posicionado na funcao principal³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAchouSB1
			If !lExtratTAF
				cCodPro	:=	SB1->B1_COD+ Iif(lConcFil,cFilAnt,"")
				cSegUnid		:= SB1->B1_SEGUM
				nConvUnid		:= SB1->B1_CONV
				cTpUnid	 		:= SB1->B1_TIPCONV
				cUnid	        := SB1->B1_UM
			Else
				cCodPro	:=	SB1->B1_COD
			EndIf
		Elseif !empty(aCmpsSF9[28]) //Deve utilizar o codigo e nao descrição.
		    cCodpro := aCmpsSF9[28] + Iif(lConcFil,cFilAnt,"")
		Else
			cCodPro	:=	""
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processando chamada do registro 0190/0200/0220 para verificar o produto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cCodPro)

		   	If !lExtratTAF

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ponto de entrada para taratmento da informação de produtos quando o mesmo estah fora do padrao do sistema³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aExistBloc[05]
					aProd := Execblock("SPEDPROD", .F., .F., {"SFT","G140"})
					If Len(aProd)>=11
						cCodPro 	:= 	aProd[1]
						cUnid		:=	aProd[5]
					Else
						aProd := {"","","","","","","","","","","",""}
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Processamento do ponto de entrada para alteracao da unidade de medida caso exista³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aExistBloc[01]
					aSpdFis02 := ExecBlock("SPDFIS02", .F., .F., {"SFT",SFT->FT_TIPOMOV,"G140"})
					If ValType(aSpdFis02)=="A"
						cUnid := aSpdFis02[1]
						nQuantia := Iif(Len(aSpdFis02) >= 2, aSpdFis02[2], SFT->FT_QUANT)
					Else
						cUnid := ExecBlock("SPDFIS02", .F., .F., {"SFT",SFT->FT_TIPOMOV,"G140"})
					EndIf
				EndIf

				nQuantia := Iif(nQuantia > 0, nQuantia, Iif(SFT->FT_QUANT > 0,SFT->FT_QUANT,nMV_SPEDQTD)) //Verificação de quantidade para notas de complementos.

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Processando chamada do registro 0190/0200/0220 para verificar o produto³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				If aScan(aReg0200,{|aX| aX[2]==cCodPro}) == 0 .And. SF9->F9_CODBAIX<>"BFINAL"
					SFRG0200(cAlias,@aReg0200,@aReg0190,dDataDe,dDataAte,aProd,cCodPro,@aReg0220,,cUnid,,,,,,,,,{cSegUnid,nConvUnid,cTpUnid},,lAchouSB1,aCmpsSF9,,,,,aWizard,lAchouSFT,,lExtratTAF)
				EndIf
			EndIf
		EndIf

		If lAchouSFT .And. SFT->FT_QUANT >= 1
			//Busca TES referente ao item para descobrir se foi gravado como desmembrar o bem em várias SF9 ou apenas uma.
			aAreaAnt := SF4->(GetArea())

			If SFT->FT_QUANT > 1
				dbSelectArea("SF4")
				DBSetOrder(1)

				If aSPDSX3[FP_FT_TES] .And. !Empty(SFT->FT_TES)
					cTes := SFT->FT_TES
				Else
					// Reposiciona a tabela SD1. pois quando ha devolucao na baixa a mesma é desposicionada
					SPEDSeek("SD1",1,xFilial("SD1")+SFT->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_PRODUTO+FT_ITEM))
					cTes := SD1->D1_TES
				EndIf

				If MSSeek(xFilial("SF4")+cTes)
					If SF4->F4_BENSATF == "2"
						nQuantia := SFT->FT_QUANT
					Else
						nQuantia := 1
					EndIf
				EndIf
			Else
				nQuantia := SFT->FT_QUANT
			Endif

			If SFT->FT_TIPOMOV == "E"
				//Busca no complemento da nota, o número do documento de arrecadação estadual
				dbSelectArea("CDC")
				DBSetOrder(1)

				If msSeek(xFilial("CDC")+"E"+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA)
					cGNRE := CDC->CDC_GUIA
				EndIf
			EndIf

			RestArea(aAreaAnt)
		EndIf

		If nQuantia == 0 .And. !Empty(aCmpsSF9[30])
			nQuantia := aCmpsSF9[30]
		ElseIf !lAchouSFT
			nQuantia := 1
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processamento do ponto de entrada para alteracao da unidade de medida caso exista³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aExistBloc[01]
			aSpdFis02 := ExecBlock("SPDFIS02", .F., .F., {"SFT",SFT->FT_TIPOMOV,"G140"})
			If ValType(aSpdFis02)=="A"
				cUnid := aSpdFis02[1]
				nQuantia := Iif(Len(aSpdFis02) >= 2, aSpdFis02[2], SFT->FT_QUANT)
			Else
				cUnid := ExecBlock("SPDFIS02", .F., .F., {"SFT",SFT->FT_TIPOMOV,"G140"})
			EndIf
		EndIf

		nQuantia := Iif(nQuantia > 0, nQuantia, Iif(SFT->FT_QUANT > 0,SFT->FT_QUANT,nMV_SPEDQTD))//Verificação de quantidade para notas de complementos.

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Montando array para retornar as informacoes³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd(aInf[1], cIndEmit)
		aAdd(aInf[1], aPartDoc[1])
		aAdd(aInf[1], cEspecie)
		aAdd(aInf[1], SF9->F9_SERNFE)
		aAdd(aInf[1], SF9->F9_DOCNFE)
		aAdd(aInf[1], cChvNfe)
		aAdd(aInf[1], SF9->F9_DTEMINE)
		aAdd(aInf[1], cNumItem)
		aAdd(aInf[1], cCodPro)
		aAdd(aInf[1], SF9->F9_CODBAIX)
		If cVersao >= "014"
			aAdd(aInf[1], cGNRE)
			aAdd(aInf[1], nQuantia)
			aAdd(aInf[1], cUnid)
			If SF9->F9_VALFRET > 0
				aAdd(aInf[1], Iif(lComplIcm,SD1->D1_VALICM,(SF9->F9_VALICMP-SF9->F9_VALFRET)+nVLLEG))
			Else
				aAdd(aInf[1], Iif(lComplIcm,SD1->D1_VALICM,(SF9->F9_VALICMP + nVLLEG)))
			EndIf
			aAdd(aInf[1], Iif(lAchouSD1,SD1->D1_ICMSRET,SF9->F9_VALICST))
			aAdd(aInf[1], Iif(lCompFret,SD1->D1_VALICM,SF9->F9_VALFRET))
			aAdd(aInf[1], Iif(lAchouSD1,SD1->D1_ICMSCOM,SF9->F9_VALICCO))
		EndIf

	ElseIf cTpMov$"/AT/"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se NAO for TOP tenho que posicioar a tabela SF9³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTop
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona na SN3 para saber se á um adiantamento ou não.
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nRecnoSN3	:= (cAliasSFA)->SN3RECNO
			If SPEDSeek("SN3",,,nRecnoSN3)
				If SN3->N3_TIPO == '03'
					lAdiant := .T.
				EndIf
			EndIf

			If lAdiant
				n2RecnoSFT	:=	(cAliasSFA)->SFTRECNO
				n2RecnoSB1	:=	(cAliasSFA)->SB1RECNO
			Else
				n2RecnoSFT	:=	(cAliasSFA)->SFT2RECNO
				n2RecnoSB1	:=	(cAliasSFA)->SB12RECNO
			EndIf
			nRecnoSD2	:=	(cAliasSFA)->SD2RECNO
			nRecnoSA1	:=	(cAliasSFA)->SA1RECNO
			nRecnoSA2	:=	(cAliasSFA)->SA2RECNO

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando houver baixa por devolucao, o codigo do cliente nao eh informado, devendo ser utilizado o codigo do proprio fornecedor³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (cAliasSFA)->FA_MOTIVO=="4"
				n2RecnoSFT	:=	(cAliasSFA)->FTRECDEVOL
				nRecnoSD2	:=	(cAliasSFA)->D2RECDEVOL
				nRecnoSA1	:=	Nil
				nRecnoSA2	:=	(cAliasSFA)->A2RECDEVOL
				n2RecnoSB1	:=	(cAliasSFA)->B1RECDEVOL
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posicionando o SFT para utilizar algumas informacoes do documento ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (cAliasSFA)->FA_MOTIVO=="4"	//Quando houver baixa por devolucao, o codigo do cliente nao eh informado, devendo ser utilizado o codigo do proprio fornecedor
			lAchou2SFT	:=	SPEDSeek("SFT",,xFilial("SFT")+"S"+SF9->(F9_SERNFS+F9_DOCNFS+F9_FORNECE+F9_LOJAFOR),n2RecnoSFT)
		Else
			lAchou2SFT	:=	SPEDSeek("SFT",,xFilial("SFT")+"S"+SF9->(F9_SERNFS+F9_DOCNFS+F9_CLIENTE+F9_LOJACLI),n2RecnoSFT)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posicionando a SA2/SA1 para utilizar algumas informacoes do documento.                      ³
		//|No caso de devolucao, devo considerar o fornecedor, pois a NF de saida foi emitida para ele.|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAchou2SFT .And. SFT->FT_TIPO$"DB"
			lAchouSA2	:=	SPEDSeek("SA2",,xFilial("SA2")+SF9->(F9_FORNECE+F9_LOJAFOR),nRecnoSA2)
		Else
			lAchouSA1	:=	SPEDSeek("SA1",,xFilial("SA1")+SF9->(F9_CLIENTE+F9_LOJACLI),nRecnoSA1)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para verificar se a despesa acessoria compoe a base  ³
		//³ de calculo do ICMS, pois o registro exige a informacao separada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAchou2SFT
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posicionando o SD1 para utilizar algumas informacoes do documento ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lAchouSD2 := SPEDSeek("SD2",2,xFilial("SD2")+SFT->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_PRODUTO+FT_ITEM),nRecnoSD2)

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posicionando a SA2 para utilizar algumas informacoes do documento ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lAchouSB1	:=	SPEDSeek("SB1",,xFilial("SB1")+SFT->FT_PRODUTO,n2RecnoSB1)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para verificar o tipo de emissao do documento fiscal³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//Emissao Propria
		If !lAchou2SFT .Or. (lAchou2SFT .And. (Empty(SFT->FT_FORMUL) .Or. "S"$SFT->FT_FORMUL))
			cIndEmit := "0"

		//Emissao de Terceiros
		Else
			cIndEmit := "1"

		EndIf

		If SFT->FT_TIPOMOV == "E"
			//Busca no complemento da nota, o número do documento de arrecadação estadual
			dbSelectArea("CDC")
			DBSetOrder(1)

			If msSeek(xFilial("CDC")+"E"+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA)
				cGNRE := CDC->CDC_GUIA
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para participante³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAchou2SFT .And. SFT->FT_TIPO$"DB" .And. lAchouSA2
			aPartDoc :=	InfPartDoc ("SA2",,,,,,,lExtratTAF)
		ElseIf lAchouSA1
			aPartDoc :=	InfPartDoc ("SA1",,,,,,,lExtratTAF)
		Else
			aAdd(aPartDoc,"")
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processando chamada do registro 0150/0175 para verificar o participante³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lExtratTAF
			If !Empty(aPartDoc[1])
				SDPF150175(@aReg0150,aPartDoc,cAlias,aWizard,,lExtratTAF)
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para o produto posicionado na funcao principal³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAchouSB1
			If !lExtratTAF
				cCodPro	:=	SB1->B1_COD+Iif(lConcFil,cFilAnt,"")
				cSegUnid		:= SB1->B1_SEGUM
				nConvUnid		:= SB1->B1_CONV
				cTpUnid			:= SB1->B1_TIPCONV
				cUnid	        := SB1->B1_UM
			Else
				cCodPro	:=	SB1->B1_COD
			EndIf
		Else
			cCodPro	:=	""
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processando chamada do registro 0190/0200/0220 para verificar o produto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cCodPro)

			If !lExtratTAF
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ponto de entrada para taratmento da informação de produtos quando o mesmo estah fora do padrao do sistema³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aExistBloc[05]
					aProd := Execblock("SPEDPROD", .F., .F., {"SFT","G140"})
					If Len(aProd)>=11
						cCodPro	:= 	aProd[1]
						cUnid	:=	aProd[5]
					Else
						aProd := {"","","","","","","","","","","",""}
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Processamento do ponto de entrada para alteracao da unidade de medida caso exista³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aExistBloc[01]
					aSpdFis02 := ExecBlock("SPDFIS02", .F., .F., {"SFT",SFT->FT_TIPOMOV,"G140"})
					If ValType(aSpdFis02)=="A"
						cUnid := aSpdFis02[1]
						nQuantia := Iif(Len(aSpdFis02) >= 2, aSpdFis02[2], SFT->FT_QUANT)
					Else
						cUnid := ExecBlock("SPDFIS02", .F., .F., {"SFT",SFT->FT_TIPOMOV,"G140"})
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Processando chamada do registro 0190/0200/0220 para verificar o produto³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Processando chamada do registro 0190/0200/0220 para verificar o produto³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SF9->F9_CODBAIX<>"BFINAL"
					SFRG0200(cAlias,@aReg0200,@aReg0190,dDataDe,dDataAte,aProd,cCodPro,@aReg0220,,cUnid,,,,,,,,,{cSegUnid,nConvUnid,cTpUnid},,,,,,,,aWizard)
				Endif
			EndIF
		EndIf

		nQuantia := Iif(nQuantia > 0, nQuantia, nMV_SPEDQTD) //Verificação de quantidade para notas de complementos.

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Montando array para retornar as informacoes, para notas fiscais de saida nao precisa do parametro, pois se a NF tem de existir no sistema.³
		//| Se tiver ocorrido esta venda em outro sistema, o processo teve suas fases completas no outro sistema, nao tem sentido estar aqui.        |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAdiant // Em caso de adiantamento a Nf conciderada deve ser a de entrada.
			If Empty(SF9->F9_ITEMNFE)
				cNumItem	:=iif(!empty(aCmpsSF9[6]),AllTrim(Str(Val(aCmpsSF9[6]))),"1")
			Else
				cNumItem	:= iif(!empty(SF9->F9_ITEMNFE), AllTrim(Str(Val(SF9->F9_ITEMNFE))),"1")
			EndIf
			aAdd(aInf[1], cIndEmit)
			aAdd(aInf[1], aPartDoc[1])
			aAdd(aInf[1], AModNot(SFT->FT_ESPECIE))
			aAdd(aInf[1], SF9->F9_SERNFE)
			aAdd(aInf[1], SF9->F9_DOCNFE)
			aAdd(aInf[1], SFT->FT_CHVNFE)
			aAdd(aInf[1], SF9->F9_DTEMINE)
			aAdd(aInf[1], cNumItem)
			aAdd(aInf[1], cCodPro)
			aAdd(aInf[1], "")
			If cVersao >= "014"
				aAdd(aInf[1], cGNRE)
				aAdd(aInf[1], nQuantia)
				aAdd(aInf[1], cUnid)
				aAdd(aInf[1], SF9->F9_VALICMP)
				aAdd(aInf[1], SF9->F9_VALICST)
				aAdd(aInf[1], SF9->F9_VALFRET)
				aAdd(aInf[1], SF9->F9_VALICCO)
			EndIf
		Else
			aAdd(aInf[1], cIndEmit)
			aAdd(aInf[1], aPartDoc[1])
			aAdd(aInf[1], AModNot(SFT->FT_ESPECIE))
			aAdd(aInf[1], SF9->F9_SERNFS)
			aAdd(aInf[1], SF9->F9_DOCNFS)
			aAdd(aInf[1], SFT->FT_CHVNFE)
			aAdd(aInf[1], SF9->F9_DTEMINS)
			If aSPDSX3[FP_F9_ITEMNFS]
				aAdd(aInf[1], AllTrim(Str(Val(SF9->F9_ITEMNFS))))
			Else
				aAdd(aInf[1], "1")
			EndIf
			aAdd(aInf[1], cCodPro)
			aAdd(aInf[1], "")
			If cVersao >= "014"
				aAdd(aInf[1], cGNRE)
				aAdd(aInf[1], nQuantia)
				aAdd(aInf[1], cUnid)
				aAdd(aInf[1], SF9->F9_VALICMP)
				aAdd(aInf[1], SF9->F9_VALICST)
				aAdd(aInf[1], SF9->F9_VALFRET)
				aAdd(aInf[1], SF9->F9_VALICCO)
			EndIf
		EndIf
	EndIf
EndIf

Return aInf
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SDPF150175| Autor ³Gustavo G. Rueda              ³ Data ³03.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ OLD => R150R175                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³REGISTRO 0150 - TABELA DE CADASTRO DE PARTICIPANTES                ³±±
±±³          ³REGISTRO 0175 - ALTERACAO DA TABELA DE CADASTRO DE PARTICIPANTE    ³±±
±±³          ³                                                                   ³±±
±±³          ³- Geracao e gravacao dos Registros                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpL1 := SDPF150175(aReg0150,aPartDoc,cAlias,aWizard)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aReg0150 -> Array com todas as informacoes do Cliente/Forne-       ³±±
±±³          ³ cedor para controle da rotina.                                    ³±±
±±³          ³aPartDoc -> Array com todas as informacoes do Cliente/Forne-       ³±±
±±³          ³ cedor.                                                            ³±±
±±³          ³cAlias   -> Alias do arquivo temporario base de geracao do TXT     ³±±
±±³          ³aWizard  -> Parametros informados no wizard da rotina              ³±±
±±³          ³aExistBloc  -> Array de cacheamento de ExistBlock                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function SDPF150175(aReg0150,aPartDoc,cAlias,aWizard,aExistBloc,lExtFisxTaf)
Local nPos     := 0
Local nX       := 0
Local lHistTab := .F.
Local dDataDe  := ''
Local dDataAte := ''
Local aRegAux  := {}

Default aExistBloc	:= {,,,,,,,,,,,,,,,,,,,,ExistBlock("SPED0150")}
Default lExtFisxTaf := .F.

if !lExtFisxTaf
	dDataDe  := SToD( aWizard[1][1] )
	dDataAte := SToD( aWizard[1][2] )
else
	dDataDe  := SToD( aWizard[1][3] )
	dDataAte := SToD( aWizard[1][4] )
endif

lHistTab := aSPDSX6[MV_HISTTAB] .And. aSPDSX2[AI_AIF] .And. SubStr(aPartDoc[1],1,3) != "SM0" // AliasIndic("AIF")

If Len(aPartDoc)>0 .And. aScan(aReg0150, {|aX| aX[2]==aPartDoc[1]})==0
	aAdd (aReg0150, {})
	nPos := Len (aReg0150)
	aAdd (aReg0150[nPos], "0150")
	For nX := 1 to 12
		aAdd (aReg0150[nPos], aPartDoc[nX])
	Next

	If aExistBloc[ 21 ]
		aRegAux := ExecBlock( "SPED0150" , .F. , .F. , { aReg0150[nPos] } )
		If Len( aRegAux ) == 13
			aReg0150[nPos] := aRegAux
		Endif
	Endif

	GrvRegTrS (cAlias,aReg0150[nPos][2], {aReg0150[nPos]})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³REGISTRO 0175 - ALTERACAO DA TABELA DE CADASTRO DE PARTICIPANTE³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lHistTab
		SPDFHistP(aPartDoc,dDataDe,dDataAte,cAlias)
	EndIf
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SPDFHistP | Autor ³Gustavo G. Rueda              ³ Data ³03.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ OLD => HistPrtDoc                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Gravacao do registro 0175, historico dos participantes             ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³HistPrtDoc(aPartDoc,dDataDe,dDataAte,cAlias)                       ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|aPartDoc -> Informacoes sobre os participantes                     ³±±
±±³          |dDataDe  -> Data inicial para utilizar os dados cadastrais do      ³±±
±±³          | periodo de processamento.                                         ³±±
±±³          |dDataAte -> Data final  para utilizar os dados cadastrais do       ³±±
±±³          | periodo de processamento.                                         ³±±
±±³          |cAlias   -> Alias do arquivo de trabalho base para geracao do TXT  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPDFHistP(aPartDoc,dDataDe,dDataAte,cAlias)
Local	aHist		:=	{}
Local	aReg0175 	:=	{}
Local	nCmp		:=	0
Local	nX			:=	0
Local	cAlsPart 	:= 	""
Local	cCmpCod	 	:=	""
Local	cCodPart 	:= 	""
Local	cLojPart 	:= 	""
Local	cNumCampo	:=	""
Local	cEnd 		:= 	""
Local	cNum 		:= 	""
Local	cCom 		:= 	""
Local	aNcampo		:=	{}
Local   nHistAux   :=  0

cAlsPart := SubStr(aPartDoc[1],1,3)
cCmpCod  := Substr(cAlsPart,2,2)+"_COD"
cCodPart := SubStr(aPartDoc[1],(len(cAlsPart) + len(FWCodFil()))+1,TamSx3(cCmpCod)[1])
cLojPart := SubStr(aPartDoc[1],(len(cAlsPart) + len(FWCodFil()))+1+TamSx3(cCmpCod)[1],TamSx3("A1_LOJA")[1])

aNcampo	:= {	{"03","A1_NOME/A2_NOME/A4_NOME"},;
				{"04","A1_CODPAIS/A2_CODPAIS/A4_CODPAIS"},;
				{"05","A1_CGC/A2_CGC/A4_CGC"},;
				{"08","A1_COD_MUN/A2_COD_MUN/A4_COD_MUN"},;
				{"09","A1_SUFRAMA/A2_SUFRAMA/A4_SUFRAMA"},;
				{"10","A1_END/A2_END/A4_END"},;
				{"12","A1_COMPLEM/A2_COMPLEM/A4_COMPLEM"},;
				{"13","A1_BAIRRO/A2_BAIRRO/A4_BAIRRO"}}

aHist 	 := MsConHist(cAlsPart,cCodPart,cLojPart,dDataDe,dDataAte,,cCodPart)
For nX := 1 to len(aHist)
	If !Empty(aHist[nX][2]) .And. ( nCmp := ASCAN(aNcampo,{|x| Alltrim(aHist[nX][1])$x[2] }) ) > 0

		cNumCampo := ""

		If aNcampo[nCmp][1] == "05" .And. (Empty(aPartDoc[4]) .And. !Empty(aPartDoc[5]))
			//Verifica cpf x cnpj
			cNumCampo := "06"
		ElseIf aNcampo[nCmp][1] == "10"
			//Verifica end x num
			cEnd := FisGetEnd(aHist[nX][2],aPartDoc[12])[1]
			cNum := FisGetEnd(aHist[nX][2],aPartDoc[12])[3]
			cCom := FisGetEnd(aHist[nX][2],aPartDoc[12])[4]

			If !(Alltrim(aPartDoc[9]) == Alltrim(cEnd))
				SPDFR0175 (cAlias, aHist[nX][3], "10", cEnd, aPartDoc[1],aReg0175)
			EndIf

			If !(Alltrim(aPartDoc[10]) == Alltrim(cNum))
				SPDFR0175 (cAlias, aHist[nX][3], "11", cNum, aPartDoc[1],aReg0175)
			EndIf

			If !Empty(cCom) .And. !(Alltrim(aPartDoc[11]) == Alltrim(cCom))
				SPDFR0175 (cAlias, aHist[nX][3], "12", cCom, aPartDoc[1],aReg0175)
			EndIf
		ElseIf (aNcampo[nCmp][1] == "08" .And. Len(Alltrim(aHist[nX][2]))<=5)
			If (nHistAux := ASCAN(aHist,{|x| Alltrim(x[1]) $ "A1_EST" .And. x[3] == aHist[nX][3] .And. x[4] == aHist[nX][4] })) > 0
				SPDFR0175 (cAlias, aHist[nX][3], "08", UfCodIBGE(aHist[nHistAux][2])+AllTrim(aHist[nX][2]), aPartDoc[1],aReg0175)
			Else
				SPDFR0175 (cAlias, aHist[nX][3], "08", UfCodIBGE(aPartDoc[13])+AllTrim(aHist[nX][2]), aPartDoc[1],aReg0175)
			EndIf
		Else
			cNumCampo := aNcampo[nCmp][1]
		EndIf

		If !Empty(cNumCampo)
			SPDFR0175(cAlias,aHist[nX][3],cNumCampo,aHist[nX][2],aPartDoc[1],aReg0175)
		EndIf

	EndIf
Next
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SPDFR0175 | Autor ³Gustavo G. Rueda              ³ Data ³03.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ OLD => Reg0175                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³REGISTRO 0175 - ALTERACAO DA TABELA DE CADASTRO DE PARTICIPANTE    ³±±
±±³          ³                                                                   ³±±
±±³          ³- Geracao e gravacao dos Registros                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias   -> Alias do arquivo temporario base de geracao do TXT     ³±±
±±³          ³dDtAlt -> Data de alteracao do campo                               ³±±
±±³          ³cNumCmp-> Numero do campo alterado                                 ³±±
±±³          ³cCont  -> Conteudo do campo                                        ³±±
±±³          ³cIdPart  -> Id do participante para criar o relacionamento de      ³±±
±±³          ³            registros                                              ³±±
±±³          ³aReg0175 -> Estrutura do registro 0175 a ser gravado               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³1(1 por arquivo)                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPDFR0175(cAlias,dDtAlt,cNumCmp,cCont,cIdPart,aReg0175)
Local nPos := 0

If (nPos := aScan (aReg0175, {|aX| aX[2]==dDtAlt .And. aX[3]==cNumCmp }) ) == 0
	aAdd(aReg0175, {})
	nPos := Len (aReg0175)
	aAdd (aReg0175[nPos], "0175")		//01 - REG
	aAdd (aReg0175[nPos], dDtAlt)		//02 - DT_ALT
	aAdd (aReg0175[nPos], cNumCmp)		//03 - NR_CAMPO
	aAdd (aReg0175[nPos], cCont)		//04 - CONT_ANT

	GrvRegTrS (cAlias,cIdPart,{aReg0175[nPos]})
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SPDFTotSFI³ Autor ³ Vendas e CRM				   ³ Data ³ 30/Jan/13³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica todas as tributacoes que foram registradas nos campos    ³±±
±±³          ³ da tabela SFI ( Resumo da Reducao Z )                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - So p/ Ambiente TOP. P/ ambiente Nao TOP usar TotalizSFI ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPDFTotSFI( lISS, cAliqISS, cQryAlias, aCmpAliICM, lCodAliq, aCmpAliISS )
Local cCampo	:= ""      	// Utilizada para armazenar o campo
Local aTotaliz	:= {}		// Array com o codigo e os valores dos totalizadores
Local cCodAliq	:= ""		// Codigo dos totalizadores das aliquotas
Local nCount	:= 0        // Contador
Local cCampoCod	:= ""      	// Utilizada para armazenar o campo referente ao código da aliquota( Utilizado para validação do PAF-ECF )
Local cValorCod	:= ""		// Armazena o valor da alíquota, utilizada no Menu Fiscal(Movimento por ECF-LOJXFUND) para o PAF-ECF
Local nY 		:= 0
Local nPos		:= 0
Local lMVUFICSEP:= aSPDSX6[MV_ESTADO]$aSPDSX6[MV_UFICSEP]

DEFAULT lCodAliq:= .F.
DEFAULT aCmpAliISS:={}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe um valor no totalizador de Cancelamento 		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cQryAlias)->FI_CANCEL > 0
	aAdd(aTotaliz,{ "Can-T", (cQryAlias)->FI_CANCEL,""}) //Valores de Cancelamentos de ICMS
EndIf
If aSPDSX3[FP_FI_CANISS] .AND. (cQryAlias)->FI_CANISS > 0
	aAdd(aTotaliz,{ "Can-S", (cQryAlias)->FI_CANISS,""}) //Valores de Cancelamentos de ISS
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe um valor no totalizador de Desconto 	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cQryAlias)->FI_DESC > 0
	aAdd(aTotaliz,{"DT", (cQryAlias)->FI_DESC,""}) //Valores de Descontos de ICMS
EndIf
If aSPDSX3[FP_FI_DESISS] .AND. (cQryAlias)->FI_DESISS > 0
	aAdd(aTotaliz,{"DS", (cQryAlias)->FI_DESISS , ""}) //Valores de Descontos de ISS
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe um valor no totalizador de Subistuicao Tributaria³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cQryAlias)->FI_SUBTRIB > 0
	aAdd(aTotaliz,{"F1", (cQryAlias)->FI_SUBTRIB,""})
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe um valor no totalizador de Isento                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cQryAlias)->FI_ISENTO > 0
	aAdd(aTotaliz,{"I1",(cQryAlias)->FI_ISENTO,""})
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe um valor no totalizador de Nao Tributado 		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cQryAlias)->FI_NTRIB > 0
	aAdd(aTotaliz,{ "N1", (cQryAlias)->FI_NTRIB,""})
EndIf
//----------------------------------------------------------------------
//³Verifica se existe um valor no totalizador de ISS Isento 		   ³
//----------------------------------------------------------------------
If aSPDSX3[FP_FI_ISSISEN] .AND. (cQryAlias)->FI_ISSISEN > 0
	aAdd(aTotaliz,{ "IS1", (cQryAlias)->FI_ISSISEN,""})
EndIf
//----------------------------------------------------------------------
//³Verifica se existe um valor no totalizador de ISS Nao Tributado	   ³
//----------------------------------------------------------------------
If aSPDSX3[FP_FI_ISSNTRI] .AND. (cQryAlias)->FI_ISSNTRI > 0
	aAdd(aTotaliz,{ "NS1", (cQryAlias)->FI_ISSNTRI,""})
EndIf
//----------------------------------------------------------------------
//³Verifica se existe um valor no totalizador de ISS Substituido	   ³
//----------------------------------------------------------------------
If aSPDSX3[FP_FI_ISSFTRI] .AND. (cQryAlias)->FI_ISSFTRI > 0
	aAdd(aTotaliz,{ "FS1", (cQryAlias)->FI_ISSFTRI,""})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a aliquota de ISS ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aCmpAliISS) > 0 //Verifica se está preparado para tratar as aliquotas de ISS que devem ser mostradas e tratadas separadamente (Ex.: FI_BIS0300, FI_BIS0500, FI_BIS0700,...)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Percorre todos os tipos de aliquotas de ISS existentes na tabela SFI  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nY:=1 to Len(aCmpAliISS)
		cCampo 		:= aCmpAliISS[nY][1]
		cCampoCod 	:= aCmpAliISS[nY][2]
		cCodAliq 	:= aCmpAliISS[nY][3]

		If (cQryAlias)->(&cCampo) > 0
			nCount++

			If lCodAliq .AND. !Empty(cCampoCod)
				cValorCod := (cQryAlias)->(&cCampoCod)
			Else
				cValorCod := ""
			EndIf

			aAdd(aTotaliz,{ cCodAliq , (cQryAlias)->(&cCampo),StrZero(nCount,2),cValorCod})
		Endif
	Next nY
Else
	//Considera o ISS acumulado no campo FI_ISS, pois neste caso nao existem os campos de aliquota separada de ISS (Ex.: FI_BIS0300, FI_BIS0500, FI_BIS0700,...)
	If lISS .AND. (cQryAlias)->FI_ISS > 0
		aAdd(aTotaliz,{ cAliqISS, (cQryAlias)->FI_ISS, "00"})
	EndIf
EndIf

nCount := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Percorre todos os tipos de aliquotas de ICMS existentes na tabela SFI ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nY:=1 to Len(aCmpAliICM)
	cCampo 		:= aCmpAliICM[nY][1]
	cCampoCod 	:= aCmpAliICM[nY][2]
	cCodAliq 	:= aCmpAliICM[nY][3]

	If (cQryAlias)->(&cCampo) > 0
		nCount++

		If lCodAliq .AND. !Empty(cCampoCod)
			cValorCod := (cQryAlias)->(&cCampoCod)
		Else
			cValorCod := ""
		EndIf
		If lMVUFICSEP
			If cCodAliq == "T2000"
				cCodAliq := "T1800"
			ElseIf cCodAliq == "T2700"
				cCodAliq := "T2500"
			EndIf
			nPos := aScan(aTotaliz,{|x|x[1]==cCodAliq})
			If nPos == 0
				aAdd(aTotaliz,{ cCodAliq , (cQryAlias)->(&cCampo),StrZero(nCount,2),cValorCod})
			Else
				aTotaliz[nPos,2] += (cQryAlias)->(&cCampo)
			EndIf
		Else
			aAdd(aTotaliz,{ cCodAliq , (cQryAlias)->(&cCampo),StrZero(nCount,2),cValorCod})
		EndIf
	Endif
Next nY

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso possua apenas uma aliquota de tributacao grava    ³
//³ "00" o campo referente ao numero do totalizador  	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nCount == 1
	aTotaliz[Len(aTotaliz)][3] := "00"
ElseIf nCount > 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso ter adicionado mais de uma aliquota Tributado ,deve  		³
	//³ordernar para que os registros filhos sejam gerados corretamentes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTotaliz  := Asort(aTotaliz,,,{|x,y|x[1]<y[1]})
EndIf

Return(aTotaliz)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SPDFCliCC ³ Autor ³ Vendas e CRM              ³ Data ³05/02/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera o Cadastro das Administradoras de Cartao para gravacao    ³±±
±±³          ³ do Registro 150                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ PARAM01 - Codigo do cartao na tabela SA1                       ³±±
±±³          ³ PARAM02 - Filial onde foi feita a venda                        ³±±
±±³          ³ PARAM03 - Loja onde foi feita a venda                          ³±±
±±³          ³ PARAM04 - Array com o Cadastro de Clientes para a gravacao     ³±±
±±³          ³ do Registro 150						                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - So p/ Ambiente TOP. P/ ambiente Nao TOP usar CriCliCC³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SPDFCliCC(cCodCli,aReg0150,cAdmin,cAlias,aWizard,cAliasSA1,lConcFil)

Local aDadCli  := {}          // Array para gravacao das Administradoras no Registro 150
Local cCodReg  := ""          // Campo 02 Cod Reg partic.
Local cNome    := ""          // Nome da empresa ou participante
Local cCodPais := "01058"     // Cod do Pais Valor fixo da tabela
Local cCNPJ    := ""          // CNPJ do cliente
Local cCPF     := ""          // CPF do cliente
Local cUF      := ""          // Estado do Cliente
Local cIE      := ""          // Inscricao Estadual
Local cCodMuni := ""          // Codigo do Municipio
Local cCodSufr := ""          // Codigo de inscricao do participante na SuFrama
Local cEnd     := ""          // Endereco
Local cNum     := ""          // Numero
Local cComple  := ""          // Complemento do endereco
Local aEnderc  := {}          // Array para retorno do enderco e numero e complemento
Local cBairro  := ""          // Bairro

Default cCodCli := ""

cCodReg  	:= 	"SA1" + Iif(lConcFil,cFilAnt,"") + AllTrim(cCodCli) + AllTrim((cAliasSA1)->A1_LOJA)
cNome    	:= 	If(AllTrim(cAdmin) <> "", cAdmin ,  (cAliasSA1)->A1_NOME )
cCNPJ    	:= 	(cAliasSA1)->A1_CGC
cUF      	:= 	(cAliasSA1)->A1_EST
cIE      	:= 	SPEDVldIE((cAliasSA1)->A1_INSCR)
cCodMuni 	:= 	Iif (Upper((cAliasSA1)->A1_EST) == "EX","9999999",IIF(Len((cAliasSA1)->A1_COD_MUN) <= 5,UfCodIBGE((cAliasSA1)->A1_EST),"") + (cAliasSA1)->A1_COD_MUN)
cCodSufr 	:= 	(cAliasSA1)->A1_SUFRAMA
aEnderc  	:= 	FisGetEnd((cAliasSA1)->A1_END,(cAliasSA1)->A1_EST)  //{cEnderec,nNumero,cNumero,cComplemen}
cEnd     	:= 	aEnderc[1]
cNum     	:= 	str(aEnderc[2])
cComple  	:= 	aEnderc[4]
cBairro  	:= 	(cAliasSA1)->A1_BAIRRO
aDadCli  	:= 	{cCodReg,cNome,cCodPais,cCNPJ,cCPF,cIE,cCodMuni,cCodSufr,cEnd,cNum,cComple,cBairro}

SDPF150175(@aReg0150,aDadCli,cAlias,aWizard)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SPDFGr1600 ³ Autor ³ Vendas e CRM              ³ Data ³05/02/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera os Dados do Cadastro das Administradoras de Cartao para     ³±±
±±³          ³ gravacao do Registro 150 e o Registro 1600                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ PARAM01 - Array com os Dados das Vendas dos Cartoes              ³±±
±±³          ³ PARAM02 - Array com o Cadastro de Clientes para a gravacao       ³±±
±±³          ³ do Registro 150						                            ³±±
±±³          ³ PARAM03 - Variavel data com a data inicial			            ³±±
±±³          ³ PARAM04 - Variavel data com a data final                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - So p/ Ambiente TOP. P/ ambiente Nao TOP usar GerDad1600³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPDFGr1600( aReg1600, aReg0150, dDataDe, dDataAte, cAlias, aWizard, lExtrat,lConcFil )
Local cQuery    := ""
Local cAliasTrb := GetNextAlias()
Local cCodADM   := ""      				 	// Cod da administradora
Local cDesADM   := ""       			 	// Descricao da administradora
Local nValCC    := 0        			 	// Valor do CC
Local nValCD    := 0       				 	// Valor do CD
Local cCodReg   := ""      				 	// Codigo cartao
Local nCodSAE   := TamSx3("AE_COD")[1]
//Local nL4ADMINIS:= TamSx3("L4_ADMINIS")[1]
Local nI        := 0                     	// Tamanho do array para adicinar os itens
Local nCount    := 0
Local cRede     := ""                    	// Nome da Administradora da rede de Cartoes
Local nPosRede  := 0                     	// Posicao da Administradora da Rede
Local aCampos   := {}                    	// Array para criar os campo p/ tabela temporaria
Local cTipoDB	:= AllTrim(Upper(TcGetDb()))// Tipo do banco de dados

Default lExtrat	:= .F.
DEFAULT lConcFil	:= .T.
cQuery := "SELECT TABSL4.L4_FILIAL,TABSL4.L4_ADMINIS,TABSL4.L4_FORMA,TABSL4.VALOR, SA1.A1_COD AS CODADM, "
cQuery += " SA1.A1_LOJA, SA1.A1_NOME, SA1.A1_CGC, SA1.A1_EST, SA1.A1_INSCR, SA1.A1_COD_MUN, SA1.A1_SUFRAMA, "
cQuery += " SA1.A1_END, SA1.A1_BAIRRO, AE_REDE, X5_DESCRI "
cQuery += " FROM ( SELECT SL4.L4_FILIAL, SL4.L4_ADMINIS, SL4.L4_FORMA, SUM(L4_VALOR) AS VALOR "
cQuery += "          FROM " + RetSQLName("SL4") + " SL4, " + RetSQLName("SL1") + " SL1 "
cQuery += "         WHERE SL4.L4_FILIAL = SL1.L1_FILIAL "
cQuery += "           AND SL1.L1_FILIAL = '"+xFilial("SL1")+"'"
cQuery += "           AND SL4.L4_NUM 	= SL1.L1_NUM "
cQuery += "           AND SL1.L1_EMISNF >= '" + DToS(dDataDe)  + "'"
cQuery += "           AND SL1.L1_EMISNF <= '" + DToS(dDataAte) + "'"
cQuery += "           AND SL4.L4_DATA   >= '" + DToS(dDataDe)  + "'"
cQuery += "           AND SL4.L4_DATA   <= '" + DToS(dDataAte) + "'"
cQuery += "           AND SL1.L1_ORCRES = '' "
cQuery += "           AND ( ( SL1.L1_TIPO = 'V' AND SL1.L1_DOC <> '' ) OR ( SL1.L1_TIPO = 'P' AND SL1.L1_DOCPED <> '' ) ) "
cQuery += "           AND (SL1.L1_CARTAO > 0 OR SL1.L1_VLRDEBI > 0 ) "
cQuery += "           AND (SL4.L4_FORMA = 'CC' OR SL4.L4_FORMA = 'CD' )"
cQuery += "           AND SL4.D_E_L_E_T_ = ' '"
cQuery += "           AND SL1.D_E_L_E_T_ = ' '"
cQuery += "	   	 GROUP BY SL4.L4_FILIAL,SL4.L4_ADMINIS,SL4.L4_FORMA ) TABSL4 "
cQuery += " LEFT JOIN "+RetSQLName("SA1")+" SA1 ON (SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.A1_LOJA = '01' "
If cTipoDB $ "ORACLE|DB2"
	cQuery += " AND SUBSTR(TABSL4.L4_ADMINIS,1,3) = RTrim(SA1.A1_COD) "
ElseIf cTipoDB == "INFORMIX"
	cQuery += " AND TABSL4.L4_ADMINIS[1,3] = SA1.A1_COD "
Else
	cQuery += " AND SUBSTRING(TABSL4.L4_ADMINIS,1,3) = SA1.A1_COD "
EndIf
cQuery += "  AND SA1.D_E_L_E_T_ = ' ' )"
cQuery += " LEFT JOIN "+RetSQLName("SAE")+" SAE ON (SAE.AE_FILIAL = '"+xFilial("SAE")+"' AND RTrim(SA1.A1_COD) = SAE.AE_COD AND SAE.D_E_L_E_T_ = ' ' )"
cQuery += " LEFT JOIN "+RetSQLName("SX5")+" SX5 ON (SX5.X5_FILIAL = '"+xFilial("SX5")+"' AND X5_TABELA = 'L9' AND RTrim(SAE.AE_REDE) = RTrim(SX5.X5_CHAVE) AND SX5.D_E_L_E_T_ = ' ' )"
cQuery := ChangeQuery( cQuery )
DbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cAliasTrb, .T., .F. )

While !(cAliasTrb)->( Eof() )
	cCodADM := AllTrim((cAliasTrb)->CODADM)
	cDesADM := SUBSTR((cAliasTrb)->L4_ADMINIS,nCodSAE+3)

	If lExtrat
		cCodReg := "C" + Padr( cCodADM , TamSX3("A1_COD")[1] ) + "01"
	Else
		cCodReg := "SA1" + Iif(lConcFil,cFilAnt,"") + cCodADM + "01"
	Endif

	nValCC  := If( AllTrim( (cAliasTrb)->L4_FORMA ) == "CC",(cAliasTrb)->VALOR, 0 )
	nValCD  := If( AllTrim( (cAliasTrb)->L4_FORMA ) == "CD",(cAliasTrb)->VALOR, 0 )

	If (nPosRede := aScan(aReg1600, { |x| x[6] == (cAliasTrb)->AE_REDE }) ) == 0
    	cRede := (cAliasTrb)->X5_DESCRI
	    If Empty(cRede)
	       cRede := cDesADM
	    EndIf
	    Aadd(aReg1600, {} )
		nI := Len(aReg1600)
		AAdd(aReg1600[nI], (cAliasTrb)->L4_FILIAL  )   	// Filial
		AAdd(aReg1600[nI], cCodReg 			       )   	// CodAdm
		AAdd(aReg1600[nI], cRede				   )   	// Descicao da Administradora
		AAdd(aReg1600[nI], nValCC				   )   	// Valor de CC
		AAdd(aReg1600[nI], nValCD				   )   	// Valor do CD
		AAdd(aReg1600[nI], (cAliasTrb)->AE_REDE	   )   	// Rede dos Cartoes
		AAdd(aReg1600[nI], cCodADM				   )   	// Rede dos Cartoes

		If !lExtrat
			//Cadastro das Administradoras de Cartao para gravacao do Registro 150
			SPDFCliCC(cCodADM,@aReg0150,cRede,cAlias,aWizard,cAliasTrb,lConcFil)
	    EndIf
	Else
    	aReg1600[nPosRede][5] += nValCD
		aReg1600[nPosRede][4] += nValCC
	EndIf

	(cAliasTrb)->(DbSkip())
End

(cAliasTrb)->(DbCloseArea())

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SPDFRgC425³ Autor ³ Vendas e CRM             ³ Data ³ 31/01/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a carga dos dados dos registros C425                   ³±±
±±³          ³ REGISTRO C425 - RESUMO DE ITENS DO MOVIMENTO DIARIO           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - So p/ Ambiente TOP. P/ ambiente Nao TOP usar RegC425³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPDFRgC425(	aRegC425 	, sDtMovim	, cPdv		, aLinhaPai	,;
						aWizard 	, nQuantD 	, cConfFil 	, cQryAlias ,;
						cSitTriAnt	, nPosPai )

Local nPos			:= 0     				// Posicao atual
Local cProd			:= ""
Local aProd			:= {}

cProd := (cQryAlias)->FT_PRODUTO+cConfFil
If aExistBloc[05]
	aProd := Execblock("SPEDPROD", .F., .F., {cQryAlias,"C425"})
	If Len(aProd)>=11
		cProd 	:= 	aProd[1]
	Else
		aProd := {"","","","","","","","","","","",""}
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenchimento do registro 425    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aRegC425, {})
nPos :=	Len(aRegC425)

aAdd (aRegC425[nPos], aLinhaPai[nPosPai][1]			) 	//00 - POSICAO DO REG. PAI
aAdd (aRegC425[nPos], "C425"						) 	//01 - REG
aAdd (aRegC425[nPos], cProd							) 	//02 - COD_ITEM
aAdd (aRegC425[nPos], {(cQryAlias)->FT_QUANT , nQuantD}	) 	//03 - QTD
aAdd (aRegC425[nPos], (cQryAlias)->B1_UM				)  	//04 - UNID
aAdd (aRegC425[nPos], (cQryAlias)->FT_VALCONT			)	//05 - VL_ITEM
If "1"$aWizard[1][15]
	aAdd (aRegC425[nPos], Iif((cQryAlias)->FT_VALPIS>0,(cQryAlias)->FT_VALPIS,""))  	//06 - VL_PIS
	aAdd (aRegC425[nPos], Iif((cQryAlias)->FT_VALCOF>0,(cQryAlias)->FT_VALCOF,"")) 	//07 - VL_COFINS
Else
	aAdd (aRegC425[nPos], ""							)  	//06 - VL_PIS
	aAdd (aRegC425[nPos], ""							) 	//07 - VL_COFINS
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o   ³SPDFC460470³ Autor ³ Vendas e CRM                ³ Data ³31/01/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a carga dos dados dos registros C460 e C470               ³±±
±±³          ³ REGISTRO C460 - DOCUMENTO FISCAL EMITIDO POR ECF                 ³±±
±±³          ³ REGISTRO C470 - ITENS DO DOCUMENTO FISCAL EMITIDO POR ECF        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - So p/ Ambiente TOP. P/ ambiente Nao TOP usar RegC460470³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPDFC460470( 	aRegC460 , aRegC470	 , sDtMovim	 , cPdv		 ,;
						nLinhaPai, aWizard 	 , nQuantD 	 , cQryAlias ,;
						cFilSB1	 , cFilSA1 	 , lCancSft  , nPosC460	 ,;
						cNfC460  , aItensC470, nPosC470	 , lConcFil	 ,;
						cConfFil , aInfPart	 , cCpfCNPJ	 , cChvCliAnt,;
						cCupFiscal, aRegC480 )

Local lRet 		:= .T.
Local cSituaDoc	:= ""
Local nQtCanc  	:= 0
Local nAliqSFT	:= 0
Local nBCIcms	:= 0
Local cSitTrib	:= ""
Local lMVUFICSEP:= .F.

Default cCupFiscal := (cQryAlias)->FT_NFISCAL

lMVUFICSEP:= aSPDSX6[MV_ESTADO]$aSPDSX6[MV_UFICSEP]

If	cNfC460 <> cCupFiscal
	cNfC460 	:= cCupFiscal
	aSize(aItensC470, 0) //Zera variavel para desalocar memoria

	If !lCancSft
		If cChvCliAnt <> cFilSA1 + (cQryAlias)->FT_CLIEFOR + (cQryAlias)->FT_LOJA

			cChvCliAnt := cFilSA1 + (cQryAlias)->FT_CLIEFOR + (cQryAlias)->FT_LOJA

			If SA1->(DbSeek(cChvCliAnt))
				aInfPart := InfPartDoc("SA1")
			Else
				aInfPart  := {"","","","",""}
			EndIf
		EndIf
		If !Empty( (cQryAlias)->L1_CGCCLI )
			cCpfCNPJ := (cQryAlias)->L1_CGCCLI
		Else
			cCpfCNPJ := IIf( Empty(aInfPart[4]), aInfPart[5], aInfPart[4] )
		EndIf

		cSituaDoc := "00" //00=Documento Regular
	Else
		cSituaDoc := "02" //02=Cancelado
	EndIf

	//------------------------------
	//Preenchimento do registro C460
	//------------------------------
	aAdd(aRegC460, {})
	nPosC460++

	aAdd (aRegC460[nPosC460], nLinhaPai		 				)	 	   	//00 - RELACIONAMENT0 COM REGISTRO PAI
	aAdd (aRegC460[nPosC460], "C460"		 				)	 	   	//01 - REG
	aAdd (aRegC460[nPosC460], "2D"		 					)	 	   	//02 - COD_MOD
	aAdd (aRegC460[nPosC460], cSituaDoc						)	 	   	//03 - COD_SIT
	aAdd (aRegC460[nPosC460], cCupFiscal		)	 		//04 - NUM_DOC
	If !lCancSft
		aAdd (aRegC460[nPosC460], (cQryAlias)->FT_EMISSAO		)	 	//05 - DT_DOC
		aAdd (aRegC460[nPosC460], (cQryAlias)->FT_VALCONT		) 	 	//06 - VL_DOC
		aAdd (aRegC460[nPosC460], (cQryAlias)->FT_VALPIS			)		//07 - VL_PIS
		aAdd (aRegC460[nPosC460], (cQryAlias)->FT_VALCOF			)		//08 - VL_COFINS
		aAdd (aRegC460[nPosC460], cCpfCNPJ						)	   	//09 - CPF_CNPJ
		aAdd (aRegC460[nPosC460], aInfPart[2]					)	   	//10 - NOM_ADQ
	Else
		aAdd (aRegC460[nPosC460], ""  	)	 	   	//05 - DT_DOC
		aAdd (aRegC460[nPosC460], ""	) 	     	//06 - VL_DOC
		aAdd (aRegC460[nPosC460], ""	)	 	   	//07 - VL_PIS
		aAdd (aRegC460[nPosC460], ""	)	 	   	//08 - VL_COFINS
		aAdd (aRegC460[nPosC460], ""	)	 	   	//09 - CPF_CNPJ
		aAdd (aRegC460[nPosC460], ""  	)	 	   	//10 - NOM_ADQ
	EndIf
Else
	If !lCancSft
		If Empty(aRegC460[nPosC460][7])
			aRegC460[nPosC460][7]:=(cQryAlias)->FT_VALCONT	//06 - VL_DOC
			aRegC460[nPosC460][8]:=(cQryAlias)->FT_VALPIS	//07 - VL_PIS
			aRegC460[nPosC460][9]:=(cQryAlias)->FT_VALCOF	//08 - VL_COFINS
		Else
			aRegC460[nPosC460][7]+=(cQryAlias)->FT_VALCONT	//06 - VL_DOC
			aRegC460[nPosC460][8]+=(cQryAlias)->FT_VALPIS	//07 - VL_PIS
			aRegC460[nPosC460][9]+=(cQryAlias)->FT_VALCOF	//08 - VL_COFINS
		EndIf
	EndIf
EndIf

//------------------------------------------------------------
//Gera o registro C470 apenas se o cupom nao estiver cancelado
//------------------------------------------------------------
If !lCancSft
	nQtCanc  := (cQryAlias)->LX_QTDCANC

	cSitTrib :=	(cQryAlias)->D2_SITTRIB
	If ("T" $ cSitTrib)
		If Len(cSitTrib) > 4
			nAliqSFT := Val(SubStr(cSitTrib,2,2)+"."+SubStr(cSitTrib,4,Len(cSitTrib)))
		Else
			nAliqSFT := Val(SubStr(cSitTrib,2,Len(cSitTrib)))
		EndIf
		nAliqSFT := nAliqSFT-(cQryAlias)->(IIF(!lMVUFICSEP.Or.Left(FT_CFOP,1)<>'5'.Or.FT_TIPO$"BD".Or.FT_VALFECP==0,0,FT_ALQFECP))
		nBCIcms	 := (cQryAlias)->FT_VALCONT
	ElseIf ("S" $ cSitTrib)
		nAliqSFT := 0
		nBCIcms	 :=	0
	Else
		nAliqSFT := (cQryAlias)->FT_ALIQICM
		nAliqSFT := nAliqSFT-(cQryAlias)->(IIF(!lMVUFICSEP.Or.Left(FT_CFOP,1)<>'5'.Or.FT_TIPO$"BD".Or.FT_VALFECP==0,0,FT_ALQFECP))
		nBCIcms	 :=	(cQryAlias)->FT_BASEICM
	EndIf

	//------------------------------
	//Preenchimento do registro 470
	//------------------------------
	SPDFRgC470( @aRegC470				, (cQryAlias)->FT_PRODUTO	, (cQryAlias)->FT_QUANT		, (cQryAlias)->FT_VALCONT	,;
			 	(cQryAlias)->FT_CFOP	, nAliqSFT					, (cQryAlias)->FT_VALPIS	, (cQryAlias)->FT_VALCOF 	,;
			 	(cQryAlias)->FT_CLASFIS	, nQtCanc					, nPosC460		 			,;
			 	cFilSB1					, (cQryAlias)->B1_UM		, aWizard 					, nQuantD 					,;
			 	@aItensC470 			, @nPosC470					, cQryAlias					, lConcFil					,;
			 	cConfFil, aRegC480 )

EndIf

Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SPDFRgC470³ Autor ³ Vendas e CRM             ³ Data ³ 31/01/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a carga dos dados dos registros C470                   ³±±
±±³          ³ REGISTRO C470 - ITENS DO DOCUMENTO FISCAL EMITIDO POR ECF     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - So p/ Ambiente TOP. P/ ambiente Nao TOP usar RegC470³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPDFRgC470(aRegC470	, cProduto	, nQUANT	, nValCont	,;
					cCFOP		, nALIQICM	, nVALPIS	, nVALCOF	,;
					cCST		, nQtCanc	, nLinhaPai	,;
					cFilSB1		, cProdUN   , aWizard 	, nQuantD	,;
					aItensC470 	, nPosC470  , cQryAlias	, lConcFil	,;
					cConfFil, aRegC480 )

Local lRet 		:= .T.
Local nPosAux	:= 0
Local cProd		:= cProduto+cConfFil
Local aProd		:= {}

If aExistBloc[05]
	aProd := Execblock("SPEDPROD", .F., .F., {cQryAlias,"C470"})
	If Len(aProd)>=11
		cProd 	:= 	aProd[1]
	Else
		aProd := {"","","","","","","","","","","",""}
	EndIf
EndIf

nPosAux := Ascan(aItensC470, {|x| x[1] == cProd .AND. x[2] == cCST})

If nPosAux == 0

	nPosC470++
	aAdd(aItensC470, { cProd, cCST, nPosC470 })

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Preenchimento do registro C470 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aRegC470, {})
	aAdd (aRegC470[nPosC470], nLinhaPai		       		)	//00 - RELACIONAMENTO COM REGISTRO PAI
	aAdd (aRegC470[nPosC470], "C470"			       	)	 	//01 - REG
	aAdd (aRegC470[nPosC470], cProd				   		)	 		//02 - COD_ITEM
	aAdd (aRegC470[nPosC470], {nQUANT+nQtCanc , nQuantD})	 	//03 - QTD
	aAdd (aRegC470[nPosC470], nQtCanc	           		)	 	//04 - QTD_CANC
	aAdd (aRegC470[nPosC470], cProdUN		       		)		//05 - UNID
	aAdd (aRegC470[nPosC470], nValCont  		       	)	 	//06 - VL_ITEM
	aAdd (aRegC470[nPosC470], cCST			       		)	 	//07 - CST_ITEM
	aAdd (aRegC470[nPosC470], cCFOP			       		)	 	//08 - CFOP
	aAdd (aRegC470[nPosC470], nALIQICM		       		)	   	//09 - ALIQ_ICMS
	aAdd (aRegC470[nPosC470], nVALPIS						)	   	//10 - VL_PIS
	aAdd (aRegC470[nPosC470], nVALCOF	    				)		//11 - VL_COFINS

Else
	nPosAux := aItensC470[nPosAux][3]

	aRegC470[nPosAux][4][1] 	+= nQUANT + nQtCanc	   				//03 - QTD
	aRegC470[nPosAux][7]  	+= nValCont		 	   				//06 - VL_ITEM
	aRegC470[nPosAux][5]  	+= nQtCanc			 		   			//04 - QTD_CANC
	aRegC470[nPosAux][11] 	+= nVALPIS 							//10 - VL_PIS
	aRegC470[nPosAux][12] 	+= nVALCOF								//11 - VL_COFINS

EndIf

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SPDFRgC490³ Autor ³ Vendas e CRM             ³ Data ³ 31/01/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a carga dos dados dos registros C490                   ³±±
±±³          ³ REGISTRO C490 - REGISTRO ANALITICO DO MOVIMENTO DIARIO        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - So p/ Ambiente TOP. P/ ambiente Nao TOP usar RegC490³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPDFRgC490(	aRegC490	, sDtMovim	, nLinhaPai	,;
				 		cPdv		, aProdB1	, nPos405	,;
				 		aReg0200	, aReg0190	, aReg0220	,;
				 		nValCof		,nValPis 	, cCupomDe	, cCupomAte )

Local aAuxReg   	:= {}
Local nPos490 		:= 0
Local nPosAux   	:= 0
Local nPosAuxReg   	:= 0
Local nBCIcms		:= 0
Local nAliqSFT  	:= 0
Local nValIcm		:= 0
Local cSitTrib 		:= ""
Local cTemp1     	:= GetNextAlias()
Local cFiltro		:=	""
Local lMVUFICSEP	:= aSPDSX6[MV_ESTADO]$aSPDSX6[MV_UFICSEP]
Local nTamDoc 		:= TAMSX3("FT_NFISCAL")[2]

Default cCupomDe	:= ""
Default cCupomAte	:= ""

cCupomDe 	:= PadR(cCupomDe,nTamDoc)
cCupomAte 	:= PadR(cCupomAte,nTamDoc)

cFiltro := "%"
If !Empty(cCupomDe) .And. !Empty(cCupomAte)
	//Somente deve considerar cupons que facam parte da Reducao Z em questao
	cFiltro += " SFT.FT_NFISCAL >= '" +%Exp:(cCupomDe)% +"' AND SFT.FT_NFISCAL <= '" +%Exp:(cCupomAte)% +"' AND "
EndIf
cFiltro += "%"

BeginSql alias cTemp1
	SELECT 	SUM(FT_VALICM) FT_VALICM, SUM(FT_VALCONT) FT_VALCONT, SUM(FT_VALPIS) FT_VALPIS, SUM(FT_VALCOF) FT_VALCOF,
			SUM(FT_BASEICM) FT_BASEICM, SUM(FT_VALFECP) FT_VALFECP,
			FT_CLASFIS, FT_CFOP, FT_ALIQICM, FT_ALQFECP, D2_SITTRIB, FT_CTIPI, FT_CSTPIS, FT_CSTCOF, FT_TIPO
	FROM %table:SFT% SFT, %table:SD2% SD2
	WHERE   SFT.FT_FILIAL 	= %xfilial:SFT%  		AND
			SD2.D2_FILIAL 	= %xfilial:SD2%  		AND
			SFT.FT_TIPOMOV 	= 'S'   				AND
			SFT.FT_ENTRADA 	= %exp:sDtMovim%  		AND
			SFT.FT_PDV 		= %exp:cPdv%			AND
			(SFT.FT_ESPECIE	= 'CF'				OR SFT.FT_ESPECIE	= 'ECF') AND
			SFT.FT_DTCANC 	= ' '					AND
			%Exp:cFiltro%
			SFT.FT_PDV 		= SD2.D2_PDV     		AND
			SFT.FT_NFISCAL 	= SD2.D2_DOC        	AND
			SFT.FT_SERIE 	= SD2.D2_SERIE			AND
			SFT.FT_ITEM 	= SD2.D2_ITEM			AND
			SFT.%notDel% 							AND
			SD2.%notDel%
		GROUP BY FT_CLASFIS,FT_CFOP,FT_ALIQICM,FT_ALQFECP,D2_SITTRIB,FT_CTIPI,FT_CSTPIS,FT_CSTCOF,FT_TIPO
		ORDER BY FT_CFOP,FT_CLASFIS,FT_ALIQICM
EndSql

nPos490 := Len(aRegC490)

While !(cTemp1)->(Eof ())
	cSitTrib := (cTemp1)->D2_SITTRIB
	If ("T" $ cSitTrib)
		If Len(cSitTrib) > 4
			nAliqSFT := Val(SubStr(cSitTrib,2,2)+"."+SubStr(cSitTrib,4,Len(cSitTrib)))
		Else
			nAliqSFT := Val(SubStr(cSitTrib,2,Len(cSitTrib)))
		EndIf
		nAliqSFT := nAliqSFT-IIF(!lMVUFICSEP.Or.Left((cTemp1)->FT_CFOP,1)<>'5'.Or.(cTemp1)->FT_TIPO$"BD".Or.(cTemp1)->FT_VALFECP==0,0,(cTemp1)->FT_ALQFECP)
		nBCIcms	 := nBCIcms	 := (cTemp1)->FT_VALCONT
		nValIcm	 := (cTemp1)->FT_VALICM-IIF(!lMVUFICSEP.Or.Left((cTemp1)->FT_CFOP,1)<>'5'.Or.(cTemp1)->FT_TIPO$"BD",0,(cTemp1)->FT_VALFECP)
	ElseIf ("S" $ cSitTrib)
		nAliqSFT := 0
		nBCIcms	 :=	0
		nValIcm	 := 0
	Else
		nAliqSFT := (cTemp1)->FT_ALIQICM-IIF(!lMVUFICSEP.Or.Left((cTemp1)->FT_CFOP,1)<>'5'.Or.(cTemp1)->FT_TIPO$"BD".Or.(cTemp1)->FT_VALFECP==0,0,(cTemp1)->FT_ALQFECP)
		nBCIcms	 :=	(cTemp1)->FT_BASEICM
		nValIcm	 := (cTemp1)->FT_VALICM -IIF(!lMVUFICSEP.Or.Left((cTemp1)->FT_CFOP,1)<>'5'.Or.(cTemp1)->FT_TIPO$"BD",0,(cTemp1)->FT_VALFECP)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Guarda os valores de PIS e Confins para 490 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nValCof += (cTemp1)->FT_VALCOF
	nValPis += (cTemp1)->FT_VALPIS

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Foi criado o array aAuxReg para que nao seja necessario dar o Ascan o array aReg490, ³
	//³ pois estava ocasionando uma lentidao no sistema pelo tamanho. 						³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    nPosAux := Ascan(aAuxReg, {|x| x[1] == nPos405 .AND. x[3] == (cTemp1)->FT_CLASFIS .AND.  x[4] == (cTemp1)->FT_CFOP .AND. x[5] == nAliqSFT })

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Preenchimento do registro C490 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If nPosAux == 0
		aAdd(aRegC490, {})
		nPos490++
		aAdd (aRegC490[nPos490], nPos405		 		)	//00 - RELACIONAMENTO COM O REGISTRO PAI
		aAdd (aRegC490[nPos490], "C490"		 			) 	//01 - REG
		aAdd (aRegC490[nPos490], (cTemp1)->FT_CLASFIS	)	//02 - CST_ITEM
		aAdd (aRegC490[nPos490], (cTemp1)->FT_CFOP		)	//03 - CFOP
		aAdd (aRegC490[nPos490], nAliqSFT				)	//04 - ALIQ_ICMS
		aAdd (aRegC490[nPos490], (cTemp1)->FT_VALCONT	)	//05 - VL_OPR
		aAdd (aRegC490[nPos490], nBCIcms				)	//06 - VL_BC_ICMS
		aAdd (aRegC490[nPos490], nValIcm				)	//07 - VL_ICMS
		aAdd (aRegC490[nPos490], ""						)	//08 - COD_OBS

		aAdd(aAuxReg, {})
		nPosAuxReg++
		aAdd (aAuxReg[nPosAuxReg], nPos405		 		) 	//01 - RELACIONAMENTO COM O REGISTRO PAI
		aAdd (aAuxReg[nPosAuxReg], "C490"		 	   	) 	//02 - REG
		aAdd (aAuxReg[nPosAuxReg], (cTemp1)->FT_CLASFIS)	//03 - CST_ITEM
		aAdd (aAuxReg[nPosAuxReg], (cTemp1)->FT_CFOP	)  	//04 - CFOP
		aAdd (aAuxReg[nPosAuxReg], nAliqSFT				)  	//05 - ALIQ_ICMS
		aAdd (aAuxReg[nPosAuxReg], nPos490				)  	//06 - Posicao do ARegC490
	Else
		nPosAux := aAuxReg[nPosAux][6]
		aRegC490[nPosAux][6] += (cTemp1)->FT_VALCONT		//05 - VL_OPR
		If !("S" $ cSitTrib)
			aRegC490[nPosAux][7] += nBCIcms					//06 - VL_BC_ICMS
			aRegC490[nPosAux][8] += nValIcm					//07 - VL_ICMS
		EndIf
	EndIf

	(cTemp1)->(dbSkip())
End

aSize(aAuxReg, 0) //Zera variavel para desalocar memoria

(cTemp1)->(dbCloseArea())
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SPDFLj0200³ Autor ³ Vendas e CRM                 ³ Data ³05/02/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao utilizada para carregar Registros 0200 separadamente, com  ³±±
±±³          ³ objetivo de melhora de performance na execucao da rotina.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL (Funcao apenas p/ Ambiente TOP)              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPDFLj0200( cAlias, dDataDe, dDataAte, aReg0200, aReg0190, aReg0220, nQtReg0200, cFilSB1, lConcFil, cReg, aWizard )
Local cQryAlias 	:= GetNextAlias() //Alias da Query
Local cQryFields 	:= ""
Local lVerif0200 	:= nQtReg0200 <> Len(aReg0200) //Variavel para indicar se deve verificar se ja existe o produto no array "aReg0200" antes de adiciona-lo
Local cMVDTINCB1	:= AllTrim(aSPDSX6[MV_DTINCB1])
Local aSetField   	:= {} //Campos da query para efetuar conversao "TcSetField"
Local nY 			:= 0
Local aProd			:= {"","","","","","","","","","","",""}
Local cProd			:= ""
Local cConfFil 		:= ""
Local cAliasCD6		:=	"CD6"
Local cOrderBy	:= ""
Local cProdAnt	:= ""

DEFAULT lConcFil	:= .T.
DEFAULT cReg  		:= "C470"
DEFAULT aWizard := {}

cConfFil 	:= Iif(lConcFil,cFilSB1,"")

cMVDTINCB1 := If( Left(cMVDTINCB1,1)=="'" .Or. Left(cMVDTINCB1,1)=='"' , &(cMVDTINCB1) , cMVDTINCB1 )

//------------------------------------------
//CAMPOS DA TABELA SB1 PARA MONTAR A QUERY
//------------------------------------------
cQryFields	:=	"SB1.B1_COD,		SB1.B1_DESC,		SB1.B1_VLR_PIS,		SB1.B1_VLR_COF,		SB1.B1_TNATREC,	"
cQryFields	+=  "SB1.B1_CNATREC, 	SB1.B1_GRPNATR, 	SB1.B1_DTFIMNT,		SB1.B1_TIPO,		SB1.B1_CODBAR,	"
cQryFields	+=  "SB1.B1_CODANT, 	SB1.B1_UM, 			SB1.B1_POSIPI,		SB1.B1_EX_NCM,		SB1.B1_CODISS,	"
cQryFields	+=  "SB1.B1_PICM, 		SB1.B1_FECP, 		SB1.B1_DATREF,		SB1.B1_TIPCONV, 	SB1.B1_SEGUM, "
If aSPDSX3[FP_B1_CODGTIN]
	cQryFields += "SB1.B1_CODGTIN,"
Endif
cQryFields	+=  "SB1.B1_CONV,		SFT.FT_TIPOMOV,	SFT.FT_NFISCAL,		SFT.FT_SERIE,		SFT.FT_CLIEFOR,		SFT.FT_LOJA,	"
cQryFields	+=  "SFT.FT_ITEM,		SFT.FT_PRODUTO	"

If aSPDSX3[FP_B1_CEST]
	cQryFields	+=	",SB1.B1_CEST"
EndIf

If !Empty(cMVDTINCB1) .And. cMVDTINCB1 <> "B1_DATREF" .And. !(cMVDTINCB1 $ cQryFields)
	cQryFields	+=  ",SB1."+cMVDTINCB1
	aAdd( aSetField, { cMVDTINCB1, "D" , 8, 0 } )
EndIf

cQryFields	:=	"%"+cQryFields+"%"

cOrderBy := "%ORDER BY SFT.R_E_C_N_O_ DESC%"
BeginSql Alias cQryAlias

	COLUMN B1_DATREF 	AS DATE

	SELECT
		%Exp:cQryFields%
	FROM
		%Table:SB1% SB1,%table:SFT% SFT
	WHERE
		SB1.B1_FILIAL = %xFilial:SB1% 		 	AND
		SFT.FT_FILIAL = %xFilial:SFT% 		 	AND
		SFT.FT_TIPOMOV = 'S' 					AND
		SFT.FT_ENTRADA >= %Exp:DToS(dDataDe)% 	AND
		SFT.FT_ENTRADA <= %Exp:DToS(dDataAte)% 	AND
		(SFT.FT_ESPECIE	= 'CF'				OR SFT.FT_ESPECIE	= 'ECF') AND
		SB1.B1_COD = SFT.FT_PRODUTO				AND
		SFT.FT_DTCANC = ' ' 					AND
		SB1.%NotDel%  		                    AND
		SFT.%NotDel%
	%Exp:cOrderBy%
EndSql

For nY := 1 To Len(aSetField)
	TcSetField(cQryAlias,aSetField[nY,1],aSetField[nY,2],aSetField[nY,3],aSetField[nY,4])
Next

While !(cQryAlias)->(Eof())
	cProdAnt := cProd
	cProd	:= (cQryAlias)->B1_COD + cConfFil
	If cProd <> cProdAnt
		If aExistBloc[05]
			aProd := Execblock("SPEDPROD", .F., .F., {cQryAlias,cReg})
			If Len(aProd)>=11
				cProd := aProd[1]
			Else
				aProd := {"","","","","","","","","","","",""}
			EndIf
		EndIf
		If lVerif0200
			If AScan(aReg0200, {|aX| aX[2]==cProd}) == 0
				SFRG0200(cAlias, @aReg0200, @aReg0190, dDataDe, dDataAte, aProd, cProd, @aReg0220, cQryAlias,,,,,,,,,,,,,,,,,,aWizard)
			EndIf
		Else
			cChvSeek := xFilial(cAliasCD6)+(cQryAlias)->FT_TIPOMOV+(cQryAlias)->FT_SERIE+(cQryAlias)->FT_NFISCAL+(cQryAlias)->FT_CLIEFOR+(cQryAlias)->FT_LOJA+(cQryAlias)->FT_ITEM+(cQryAlias)->FT_PRODUTO
			lAchouCD6 := SpedSeek(cAliasCD6,1,cChvSeek)
			SFRG0200(cAlias, @aReg0200, @aReg0190, dDataDe, dDataAte, aProd, cProd , @aReg0220, cQryAlias,,,,,,,,cAliasCD6,lAchouCD6,,,,,,,,,aWizard)
		EndIf
	EndIf
	(cQryAlias)->(DbSkip())
End

(cQryAlias)->(dbCloseArea())

nQtReg0200 := Len(aReg0200)

Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} SPDBarkThr
--
Autor: Demetrio Fontes De Los Rios - Data: 04/2013
--
Descrição:  Funcao Bark - "casca" da thread. Ela quem fica num "listen" aguardando
o IpcGo para chamar a funcao passada via parametro.
--
Parametros: 		cSemaphore		-> Identificacao do Semaforo
					cFunction       -> Nome da funcao que o iPCGo ira executar
					cEmp / cFil		-> Empresa/Filial para subida da thread
					cNomeTRB     	-> Nome da tabela temporaria
					cAlias          -> Alias nomeado da tabela temp
					cNThread        -> Identificao da Thread
@version 1.0
//------------------------------------------------------------------------------- */
Function SPDBarkThr( cSemaphore, cFunction, cEmp, cFil, cNomeTRB, cAlias, cNThread )

Local uParm1, uParm2,uParm3, uParm4, uParm5, uParm6, uParm7,  uParm8, uParm9,;
	  uParm10, uParm11, uParm12, uParm13, uParm14, uParm15, uParm16, uParm17
Local nTimeOut := 	0

// Prepara/Abre Ambiente
RpcSetType(3)
RpcSetEnv(cEmp,cFil)

nTimeOut := SuperGetMv("MV_SPDCTTO",,190000000) // Parametro que define TimeOut da Bark -> DEFAULT 190000000 = 52HORAS

// Abre tabela do banco
dbUseArea( .T. ,__cRdd , cNomeTRB , cAlias , .T. , .F. )
(cAlias)->( dbClearIndex() , dbSetIndex(cNomeTRB + '_01' ) )

// ---------------------------------
// LISTEN - AGUARDANDO COMANDO GO
While !KillApp()
	PtInternal( 1 , 'Thread( ' + cNThread + ' ) - SPEDC )' )	// Imprime no monitor Identificacao da Thread
	If IPCWaitEx( cSemaphore, nTimeOut 	, 	@uParm1,;
									   		@uParm2,;
									  		@uParm3,;
											@uParm4,;
											@uParm5,;
											@uParm6,;
											@uParm7,;
											@uParm8,;
											@uParm9,;
											@uParm10,;
											@uParm11,;
											@uParm12,;
											@uParm13,;
											@uParm14,;
											@uParm15,;
											@uParm16,;
											@uParm17 )

		// -------------------------------------------
		// Comando EXIT
		If ValType(uParm1) == "C" .And. uParm1 == "_E_X_I_T_"
			(cAlias)->(dbCloseArea())
			Exit
		EndIF

		// ----------------------
		// Função a ser executada
		&cFunction.(uParm1,;
					uParm2,;
					uParm3,;
					uParm4,;
					uParm5,;
					uParm6,;
					uParm7,;
					uParm8,;
					uParm9,;
					uParm10,;
					uParm11,;
					uParm12,;
					uParm13,;
					uParm14,;
					uParm15,;
					uParm16,;
					uParm17)
	Else
		// --------------------
		// Abandona por TimeOut
		(cAlias)->(dbCloseArea())
		ConOut("_E_X_I_T_!!! -> " + Time() )
	  	Exit
	EndIf
End

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} PCDelTmpDB
--
Autor: Demetrio Fontes De Los Rios - Data: 04/2013
--
Descrição:  Funcao responsavel por excluir tabela temporaria do banco
--
Parametros: 		cTempDB	   -> Nome da tabela temporaria
					lMsg       -> Logico - se exibe mensagem ou não
@version 1.0
//------------------------------------------------------------------------------- */
Function PCDelTmpDB( cTempDB , lMsg  )
Local	lRet		:=	.T.
Local	lOk			:=	.T.
Local	cMsgTempDB	:=	''

Default	lMsg	:=	.T.

//Verifico se a tabela existe no RDBMS
If TcCanOpen( cTempDB )

	cMsgTempDB	:=	"O SPED Contribuições desse período já foi gerada em um outro momento " //STR0123	//'A apuração deste período para este tributo já foi gerada em um outro momento, '
	cMsgTempDB	+=	"as informações já estão carregadas em tabelas temporárias." //STR0124	//'os valores já estão calculados conforme o movimento da ocasião. '
	cMsgTempDB	+=	"Deseja refazer a extração? " + CRLF + CRLF
	cMsgTempDB	+=	"Ao selecionar não, o sistema ira buscar as informações novamente, caso escolha SIM apenas irá gerar o arquivo magnético. "	//'Ao selecionar "Não", as informações a serem apresentadas serão com base no movimento já calculado!'
	If lMsg	//Tratamento para tornar a mensagem opcional
		lOk	:=	MsgYesNo( cMsgTempDB , "Atenção" )	//'Atenção'
	EndIf

	If lOk
		If !TcDelFile( cTempDB )		//Caso exista, apago do RDBMS
			cMsgNotDel	:=	"Erro ao excluir " + ' ( ' + cTempDB + ' ).' + CRLF + CRLF	//'Problema ao excluir TEMPDB
			cMsgNotDel	+=	TcSqlError() + CRLF + CRLF
			cMsgNotDel	+=	"A tabela em questão está presa por alguma thread de processamento pelo TOP CONNECT, entrar em contato com o Administrador do sistema." + CRLF + CRLF	//'A tabela em questão está presa por alguma thread de processamento pelo TOP CONNECT, entrar em contato com o Administrador do sistema.'
			cMsgNotDel	+=	"As informações serão geradas com base nos dados já extraídos."	//'As informações a serem apresentadas serão com base no movimento já calculado!'
			ApMsgAlert( cMsgNotDel )

			lRet	:=	.F.
		EndIf
	Else
		lRet	:=	.F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} PCCriaTab
--
Autor: Demetrio Fontes De Los Rios - Data: 04/2013
--
Descrição:  Funcao responsavel em ciar e/ou abrir a tabela temporaria no banco

Parametros: 		cArq		-> Nome do arquivo
					cAlsTem     -> Alias da tabela temporaria
					aCampos  	-> Array contendo estrutura/campos da tabela temporaria
					xIndice     -> Indice da Temp DB
					lOnlyOpen	-> Logico - Define se ira criar ou apenas abrir a TempDB
@version 1.0
//------------------------------------------------------------------------------- */
Function PCCriaTab( cArq , cAlsTemp, aCampos , xIndice, lOnlyOpen )

Local nCont			:= 0
Local lRet 			:= .T.

Default cArq		:= ""
Default xIndice 	:= ""
Default lOnlyOpen	:= .F.

If !lOnlyOpen
	//Cria a tabela no RDBMS com a estrutura definida acima
	dbCreate( cArq , aCampos , __cRdd )
	dbUseArea( .T. ,__cRdd , cArq , cAlsTemp , .T. , .F. )

	//Funcao que define e retorna indices da tabela temporaria no RDBMS
	If ValType(xIndice)=="A"
		For nCont:=1 to Len(xIndice)
			dbCreateIndex ( cArq + '_'+StrZero(nCont,2) , xIndice[nCont] )
		Next nCont
		(cAlsTemp)->( dbClearIndex() , dbSetIndex(cArq + '_01' ) )
		(cAlsTemp)->( dbCloseArea() )
	Else
		dbCreateIndex ( cArq + '_01' , xIndice )
	   //	(cAlsTemp )->( dbCloseArea() )
	EndIf
Else
	dbUseArea( .T. ,__cRdd , cArq , cAlsTemp , .T. , .F. )
EndIf

Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} MThdGrvTRB
--
Autor: Demetrio Fontes De Los Rios - Data: 04/2013
--
Descrição: Funcao responsavel descarregar as informacoes dos arrays na tabela temporaria
--
Parametros: 		cEmpProc	-> Empresa processando SPED
					cFilProc    -> Filial processando SPED
					cAlias      -> Alias da tabela temporaria
					cArq        -> Arquivo / Tabela temporaria
					aRegFilho   -> Array contendo informacoes dos registros filho
					aRegPai  	-> Array contendo informacoes dos registros pai
					lCtItem     -> Logico. Conta item
					nFlag       -> Flag
					nPai        -> Identificacao do Array pai
					lRegPaiDup  -> Logico. Gera informacoes do pai
					nPos400     -> Posicao do pai C400
					aRegC405    -> Array com as informacoes C405
					nCtC405     -> Contador Registro C405
					aRegC481    -> Array contendo informacoes do item de PIS
					aRegC485    -> Array contendo informacoes do item de COFINS
					_nRecno     -> Numero do Recno
					cJobFile    -> Nome do arquivo para controle da Thread
					cJobAux     -> Utilizado para controle de thread
@version 1.0
//------------------------------------------------------------------------------- */
Function MThdGrvTRB(cEmpProc,cFilProc,cAlias,cArq,aRegFilho,aRegPai,lCtdtem,nFlag,nPai,lRegPaiDup,nPos400,aRegC405,nCt405,aRegC481,aRegC485,_nRecno,cJobFile,cJobAux)

Local	nHd1		:= 0
Local 	nCtd		:= 1
Local 	aReg		:= {}
Local 	nX			:= 0
Local 	nZ			:= 0

Private n_COMMIT	:= 0
Private cNomeTRB 	:= ""
Private n_SPCRecno	:= 0
Private lProcMThr	:= .T.

Default nPos400		:= 0
Default aRegPai		:= Nil
Default lRegPaiDup	:= .F.
Default cJobAux		:=	cJobFile

// Criacao do arquivo de controle de jobs
nHd1 := MSFCreate( cJobAux )

// STATUS 1 - Iniciando execucao do Job
PutGlbValue( cJobAux , "1" )
GlbUnLock()

// nome da tabeçp
cNomeTRB 	:= cArq
n_SPCRecno	:= _nRecno

// STATUS 2 - Iniciando a gravacao
PutGlbValue( cJobAux , "2" )
GlbUnLock()

// Especifico para registros do Loja
If nPos400>0

//	Conout("Descarregando ... ")
	PCGrvReg ( cAlias , nPos400 , aRegC405 , nCt405 , , nPai  , , .T. )
	PCGrvReg ( cAlias , nPos400 , aRegC481 , nCt405 , , nPai  , , .T. )
	PCGrvReg ( cAlias , nPos400 , aRegC485 , nCt405 , , nPai  , , .T. )

// Generico
ElseIf nPos400==0 .AND. ValType( aRegPai )<>"U"

//	Conout("Descarregando ... ")
	For nZ := 1 To Len (aRegPai)
		If !lRegPaiDup
			PCGrvReg (cAlias, nZ, {aRegPai[nZ]}, ,nFlag,nPai  )

			// STATUS 3 - Gravacao Registro PAI
			PutGlbValue( cJobAux , "3" )
			GlbUnLock()
		Endif

		If Len(aRegFilho)>=1  .AND. nCtd <= Len(aRegFilho)
			Do While nCtd<=Len (aRegFilho) .And. (aRegFilho[nCtd][1]==nZ)

				// STATUS 4 - Gravacao Registro FILHO
				PutGlbValue( cJobAux , "4" )
				GlbUnLock()

				aReg	:=	{}

				For nX := 2 To Len (aRegFilho[nCtd])
					aAdd (aReg, aRegFilho[nCtd][nX])
				Next (nX)

				PCGrvReg (cAlias, Iif(lCtdtem,nZ,aRegPai[nZ,1]) , {aReg}, Iif(lCtdtem,nCtd,aRegFilho[nCtd][1]), nFlag,nPai )

				nCtd++
			EndDo
		EndIf
	Next (nZ)

EndIF

//Forco ultimo Commit
TcSQLExec( 'COMMIT' )
n_COMMIT := 0

// STATUS 5 - Gravacao concluida
PutGlbValue( cJobAux , "5" )
GlbUnLock()

If FClose( nHd1 )
	If FErase( cJobAux ) == -1
		// STATUS 6 - Problema ao excluir o semaforo
		PutGlbValue( cJobAux , "6" )
		GlbUnLock()
	EndIf
Else
	// STATUS 6 - Problema ao fechar o semaforo
	PutGlbValue( cJobAux , "6" )
	GlbUnLock()
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} SFPCL
Função para geração dos registros 1300, 1310, 1320, 1350, 1360 e 1370
referente as informações de PCL -Postos de Combustivel e Lubrificante,
onde as informações e valores são extraídos de um template do módulo
SIGALOJA, e serão extraídos através da função T_TpPcSped localizado
no fonte TPLPCLFUNCS.prw

@param  aReg1300  - Array com valores do registro 1300
		aReg1310  - Array com valores do registro 1310
		aReg1320  - Array com valores do registro 1320
		aReg1350  - Array com valores do registro 1350
		aReg1360  - Array com valores do registro 1360
		aReg1370  - Array com valores do registro 1370
		aReg0190  - Array com valores do registro 0190
		aReg0200  - Array com valores do registro 0200
		aReg0220  - Array com valores do registro 0220
		cAlias    - Alias do arquivo temporário
		dDataDe   - Data inicial do processamento
		dDataAte  - Data Final do Processamento

@return cCodCred - Retorna Codigo do Tipo de Credito

@author Erick G Dias
@since 28/10/2013
@version 11.80
/*/
//-------------------------------------------------------------------
Function SPEDPCL(aReg1300,		aReg1310,		aReg1320,		aReg1350,		aReg1360,;
				 aReg1370,		aReg0190,		aReg0200,		aReg0220,		cAlias ,;
				 dDataDe,		dDataAte, aWizard)

Local aRetPCL	:= {}
Local nX1300	:= 0
Local nX1310	:= 0
Local nX1320	:= 0
Local nX1350	:= 0
Local nX1360	:= 0
Local nX1370	:= 0
Local nPos1300	:= 0
Local nPos1310	:= 0
Local nPos1350	:= 0

Default aWizard :={}

aRetPCL:= T_TpPcSped(dDataDe,dDataAte)

/*
Posições do array retornardo através da função T_TpPcSped
aRetPCL[2] - Retorno das informações do registro 1300
aRetPCL[3] - Retorno das informações do registro 1310
aRetPCL[4] - Retorno das informações do registro 1320
aRetPCL[5] - Retorno das informações do registro 1350
aRetPCL[6] - Retorno das informações do registro 1360
aRetPCL[7] - Retorno das informações do registro 1370
*/

If Len(aRetPCL) >= 6

	//Percorre array para gerar registro 1300
	For nX1300:= 1 to Len(aRetPCL[1])

		nPos1300:= Reg1300 (@aReg1300,aRetPCL[1][nX1300],@aReg0200,@aReg0190,@aReg0220,dDataDe,dDataAte,cAlias,aWizard)

		//Percorre array para gerar registro 1310 filhos do registro 1300
		For nX1310 :=1 to Len(aRetPCL[2])
			//Verifica se a primeira posição do array filho é igual ao número corrente do registro pai.
			If aRetPCL[2][nX1310][1] == nX1300
				nPos1310:=Reg1310(@aReg1310,aRetPCL[2][nX1310],nPos1300)

				//Percorre array para gerar registro 1320
				For nX1320 :=1 to Len(aRetPCL[3])
					//Verifica se a primeira posição do array filho é igual ao número corrente do registro pai.
					If aRetPCL[3][nX1320][1] == nX1310
						Reg1320(@aReg1320,aRetPCL[3][nX1320],nPos1310)
					EndIF

				Next nX1320

			EndIF

		Next nX1310

	Next nX1300

	//Percorre array para gerar registro 1350
	For nX1350:= 1 to Len(aRetPCL[4])
		nPos1350:= Reg1350 (@aReg1350,aRetPCL[4][nX1350])

		//Percorre array para gerar registro 1360
		For nX1360	:= 1 to Len(aRetPCL[5])
			If aRetPCL[5][nX1360][1] == nX1350
				Reg1360 (@aReg1360,aRetPCL[5][nX1360] , nPos1350)
			EndIF
		Next nX1360

		//Percorre array para gerar registro 1370
		For nX1370	:= 1 to Len(aRetPCL[6])
			If aRetPCL[6][nX1370][1] == nX1350
				Reg1370(@aReg1370,aRetPCL[6][nX1370],nPos1350,@aReg0200,@aReg0190,@aReg0220,dDataDe,dDataAte,cAlias,aWizard)
			EndIF
		Next nX1370

	Next nX1350

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg1300
Função para geração do registro 1300

@param  aReg1300  - Array com informações do registro 1300
		aPCL1300  - Array com informações do registro 1300 gerado na função do LOJA
		aReg0200  - Array com valores do registro 0200
		aReg0190  - Array com valores do registro 0190
		aReg0220  - Array com valores do registro 0220
		dDataDe   - Data inicial do processamento
		dDataAte  - Data Final do Processamento
		cAlias    - Alias do arquivo temporário

@return nPos 	  - Posição do registro 1300 gerado

@author Erick G Dias
@since 28/10/2013
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function Reg1300 (aReg1300,aPCL1300,aReg0200,aReg0190,aReg0220,dDataDe,dDataAte,cAlias,aWizard)
Local nPos		:= 0
Local cProduto	:= ""
Default aWizard 	:={}

cProduto:= aPCL1300[2]+cFilAnt
If AScan(aReg0200, {|aX| aX[2]==cProduto}) == 0
	SFRG0200(cAlias, @aReg0200, @aReg0190, dDataDe, dDataAte, ,cProduto , @aReg0220,,,,,,,,,,,,,,,,,,,aWizard)
EndIf

nPos := Ascan(aReg1300,{|aX|aX[2] == cProduto .AND. aX[3] == aPCL1300[3]})

If nPos == 0

	aAdd(aReg1300, {})
	nPos	:=	Len (aReg1300)
	aAdd (aReg1300[nPos], "1300")	 	 	  	//01 - REG
	aAdd (aReg1300[nPos], cProduto)	 		 	//02 - COD_ITEM
	aAdd (aReg1300[nPos], aPCL1300[3])	 	 	//03 - DT_FECH
	aAdd (aReg1300[nPos], {aPCL1300[4],3})	 	//04 - ESTQ)ABERT
	aAdd (aReg1300[nPos], {aPCL1300[5],3})	  	//05 - VOL_ENTR
	aAdd (aReg1300[nPos], {aPCL1300[6],3})	  	//06 - VOL_DISP
	aAdd (aReg1300[nPos], {aPCL1300[7],3})	  	//07 - VOL_SAIDAS
	aAdd (aReg1300[nPos], {aPCL1300[8],3})	  	//08 - ESTQ_ESCR
	aAdd (aReg1300[nPos], {aPCL1300[9],3})	  	//09 - VAL_AJ_PERDA
	aAdd (aReg1300[nPos], {aPCL1300[10],3}) 	//10 - VAL_AJ_GANHO
	aAdd (aReg1300[nPos], {aPCL1300[11],3}) 	//11 - FECH_FISICO
Else
	aReg1300[npos][4][1]	+=	aPCL1300[4]		//04 - ESTQ)ABERT
	aReg1300[npos][5][1]	+=	aPCL1300[5]		//05 - VOL_ENTR
	aReg1300[npos][6][1]	+=	aPCL1300[6]		//06 - VOL_DISP
	aReg1300[npos][7][1]	+=	aPCL1300[7]		//07 - VOL_SAIDAS
	aReg1300[npos][8][1]	+=	aPCL1300[8]		//08 - ESTQ_ESCR
	aReg1300[npos][9][1]	+=	aPCL1300[9]		//09 - VAL_AJ_PERDA
	aReg1300[npos][10][1]	+=	aPCL1300[10]	//10 - VAL_AJ_GANHO
	aReg1300[npos][11][1]	+=	aPCL1300[11]	//11 - FECH_FISICO
EndIF

Return nPos

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg1310
Função para geração do registro 1310

@param  aReg1310  - Array com informações do registro 1310
		aPCL1310  - Array com informações do registro 1310 gerado pelo Loja
		nPos1300  - Posição do registro pai 1300

@return nPos	 - Posição do registro 1310 gerado

@author Erick G Dias
@since 28/10/2013
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function Reg1310(aReg1310,aPCL1310,nPos1300)

Local nPos	:= 0

nPos := Ascan(aReg1310,{|aX|aX[1] == nPos1300 .AND. aX[3] == aPCL1310[3]})

If nPos == 0
	aAdd(aReg1310, {})
	nPos	:=	Len (aReg1310)
	aAdd (aReg1310[nPos], nPos1300)	 	 	 	//01 - Relação com registro pai
	aAdd (aReg1310[nPos], "1310")	 	 	 	//01 - REG
	aAdd (aReg1310[nPos], aPCL1310[3])	 		//02 - NUM_TANQUE
	aAdd (aReg1310[nPos], {aPCL1310[4],3})		//03 - ESTQ_ABERT
	aAdd (aReg1310[nPos], {aPCL1310[5],3})		//04 - VOL_ENTR
	aAdd (aReg1310[nPos], {aPCL1310[6],3})		//05 - VOL_DISP
	aAdd (aReg1310[nPos], {aPCL1310[7],3})		//06 - VOL_SAIDAS
	aAdd (aReg1310[nPos], {aPCL1310[8],3})		//07 - ESTQ_ESCR
	aAdd (aReg1310[nPos], {aPCL1310[9],3})		//08 - VAL_AJ_PERDA
	aAdd (aReg1310[nPos], {aPCL1310[10],3})		//09 - VAL_AJ_GANHO
	aAdd (aReg1310[nPos], {aPCL1310[11],3})		//10 - FECH_FISICO
Else
	areg1310[npos][4][1]	+=	aPCL1310[4]		//03 - ESTQ_ABERT
	areg1310[npos][5][1]	+=	aPCL1310[5]		//04 - VOL_ENTR
	areg1310[npos][6][1]	+=	aPCL1310[6]		//05 - VOL_DISP
	areg1310[npos][7][1]	+=	aPCL1310[7]		//06 - VOL_SAIDAS
	areg1310[npos][8][1]	+=	aPCL1310[8]		//07 - ESTQ_ESCR
	areg1310[npos][9][1]	+=	aPCL1310[9]		//08 - VAL_AJ_PERDA
	areg1310[npos][10][1]  	+=	aPCL1310[10]	//09 - VAL_AJ_GANHO
	areg1310[npos][11][1] 	+=	aPCL1310[11]	//10 - FECH_FISICO
EndIF


//

Return nPos

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg1320
Função para geração do registro 1320

@param  aReg1320  - Array com informações do registro 1320
		aPCL1320  - Array com informações do registro 1320 gerado pelo Loja
		nPos1310  - Posição do registro pai 1310

@return

@author Erick G Dias
@since 28/10/2013
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function Reg1320(aReg1320,aPCL1320,nPos1310)

Local nPos		:= 0
Local cNrInterv	:= Iif(aPCL1320[4] == Nil,"",Str(aPCL1320[4]))

nPos := Ascan(aReg1320,{|aX|aX[1] == nPos1310 .AND. aX[3] == aPCL1320[3] .AND. aX[4] == cNrInterv .AND. aX[5] == aPCL1320[5];
								 .AND. aX[6] == aPCL1320[6] .AND. aX[7] == aPCL1320[7] .AND. aX[8] == aPCL1320[8] })

If nPos == 0

	aAdd(aReg1320, {})
	nPos	:=	Len (aReg1320)
	aAdd (aReg1320[nPos], nPos1310)	 	 	  		//01 - Relação com registro pai
	aAdd (aReg1320[nPos], "1320")	 	 	  		//01 - REG
	aAdd (aReg1320[nPos], aPCL1320[3]) 	  			//02 - NUM_BICO
	aAdd (aReg1320[nPos], cNrInterv)				//03 - NR_INTERV
	aAdd (aReg1320[nPos], aPCL1320[5])	 	 		//04 - MOT_INTERV
	aAdd (aReg1320[nPos], aPCL1320[6])	 	 		//05 - NOM_INTERV
	aAdd (aReg1320[nPos], aPCL1320[7]) 		        //06 - CNPJ_INTERV
	aAdd (aReg1320[nPos], aPCL1320[8]) 			    //07 - CPF_INTERV
	aAdd (aReg1320[nPos], {aPCL1320[9],3})	 	 	//08 - VAL_FECHA
	aAdd (aReg1320[nPos], {aPCL1320[10],3})	 	//09 - VAL_ABERTNHO
	aAdd (aReg1320[nPos], {aPCL1320[11],3})	 	//10 - VOL_VENDASO
	aAdd (aReg1320[nPos], {aPCL1320[12],3})	 	//11 - VOL_VENDAS
Else
	aReg1320[npos][9][1]	+=	aPCL1320[9]	    	//08 - VAL_FECHA
	aReg1320[npos][10][1] 	+=	aPCL1320[10]		//09 - VAL_ABERTNHO
	aReg1320[npos][11][1]	+=	aPCL1320[11]		//10 - VOL_VENDASO
	aReg1320[npos][12][1]	+=	aPCL1320[12]		//11 - VOL_VENDAS
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg1350
Função para geração do registro 1350

@param  aReg1350  - Array com informações do registro 1350
		aPCL1350  - Array com informações do registro 1350 gerado pelo Loja

@return nPos	 - Posição do registro 1350 gerado

@author Erick G Dias
@since 28/10/2013
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function Reg1350(aReg1350,aPCL1350)

Local nPos	:= 0

nPos := Ascan(aReg1350,{|aX|aX[2] == aPCL1350[2] .AND. aX[3] == aPCL1350[3] .AND. aX[4]== aPCL1350[4] .AND. aX[5]== aPCL1350[5]})

If nPos == 0
	aAdd(aReg1350, {})
	nPos	:=	Len (aReg1350)
	aAdd (aReg1350[nPos], "1350")	  	  		//01 - REG
	aAdd (aReg1350[nPos], aPCL1350[2])	 	  	//02 - SERIE
	aAdd (aReg1350[nPos], aPCL1350[3])	 	 	//03 - FABRICANTE
	aAdd (aReg1350[nPos], aPCL1350[4])	 	 	//04 - MODELO
	aAdd (aReg1350[nPos], aPCL1350[5])	 	 	//05 - TIPO_MEDICAO
EndIF

Return nPos

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg1360
Função para geração do registro 1360

@param  aReg1360  - Array com informações do registro 1360
		aPCL1360  - Array com informações do registro 1360 gerado pelo Loja
		nPos1350  - Posição do registro pai 1350

@return nPos	 - Posição do registro 1360 gerado

@author Erick G Dias
@since 28/10/2013
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function Reg1360(aReg1360,aPCL1360,nPos1350)

Local nPos	:= 0

nPos := Ascan(aReg1360,{|aX|aX[1] == nPos1350 .AND. aX[3] == aPCL1360[3] .AND. aX[4] == aPCL1360[4]})
If nPos == 0
	aAdd(aReg1360, {})
	nPos	:=	Len (aReg1360)
	aAdd (aReg1360[nPos], nPos1350)	  	  		//Relação com registro Pai
	aAdd (aReg1360[nPos], "1360")	  	  		//01 - REG
	aAdd (aReg1360[nPos], aPCL1360[3])	  		//02 - NUM_LACRE
	aAdd (aReg1360[nPos], aPCL1360[4])	 	  	//03 - DT_APLICACAO
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg1370
Função para geração do registro 1370

@param  aReg1370  - Array com informações do registro 1370
		aPCL1370  - Array com informações do registro 1370 gerado pelo Loja
		nPos1350  - Posição do registro pai 1350
		aReg0200  - Posição do registro pai 1350
		aReg0190  - Array com informações do registro 0200
		aReg0220  - Posição do registro pai 0220
		dDataDe   - data inicial da geração do arquivo
		dDataAte  - Data Final da geração do arquivo
		cAlias    - Alias da tabela temporária

@return

@author Erick G Dias
@since 28/10/2013
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function Reg1370(aReg1370,aPCL1370,nPos1350,aReg0200,aReg0190,aReg0220,dDataDe,dDataAte,cAlias,aWizard)

Local nPos		:= 0
Local cProduto	:= ""
Default aWizard	:={}
cProduto:= aPCL1370[4]+cFilAnt
If AScan(aReg0200, {|aX| aX[2]==cProduto}) == 0
	SFRG0200(cAlias, @aReg0200, @aReg0190, dDataDe, dDataAte, ,cProduto , @aReg0220,,,,,,,,,,,,,,,,,,,,aWizard)
EndIf

nPos := Ascan(aReg1370,{|aX|aX[1] == nPos1350 .AND. aX[3] == aPCL1370[3] .AND. aX[4] == cProduto .AND.aX[5] == aPCL1370[5]})
If nPos == 0
	aAdd(aReg1370, {})
	nPos	:=	Len (aReg1370)
	aAdd (aReg1370[nPos], nPos1350)	  	  		//Relação com registro Pai
	aAdd (aReg1370[nPos], "1370")	  	  		//01 - REG
	aAdd (aReg1370[nPos], aPCL1370[3])	 	  	//02 - NUM_BICO
	aAdd (aReg1370[nPos], cProduto)	 		  	//03 - COD_ITEM
	aAdd (aReg1370[nPos], aPCL1370[5])	 	  	//04 - NUM_TANQUE
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RegI100
Função que irá gerar registro I100

@param	aRegI100 - Array com informações do registro I100
		aDado    - Array com informações que irá gerar I100.
		nI010    - Posição do registro pai I010

@return Posição do registro I100 no array

@author Erick G Dias
@since 23/12/2013
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function RegI100(aRegI100, aDado, nI010)

Local nPos	:= 0

nPos :=AScan(aRegI100, {|aX| aX[1]==nI010 .AND. aX[4]==aDado[3] .AND. aX[8]==aDado[7] .AND. aX[11]==aDado[10] .AND. aX[13]==aDado[12]})
//nPos :=AScan(aRegI100, {|aX| aX[3]==aDado[3] .AND. aX[7]==aDado[7] .AND. aX[10]==aDado[10] .AND. aX[12]==aDado[12]})

If nPos == 0
	aAdd(aRegI100, {})
	nPos	:=	Len (aRegI100)
	aAdd (aRegI100[nPos], nI010)  	  		//Relação com registro Pai registro I010
	aAdd (aRegI100[nPos], "I100")	  		//01 - REG
	aAdd (aRegI100[nPos], aDado[2])	 	  	//02 - VL_REC
	aAdd (aRegI100[nPos], aDado[3])		  	//03 - CST_PIS_COFINS
	aAdd (aRegI100[nPos], aDado[4])	 	  	//04 - VL_TOT_DED_GER
	aAdd (aRegI100[nPos], aDado[5])	 	  	//05 - VL_TOT_DED_ESP
	aAdd (aRegI100[nPos], aDado[6])	 	  	//06 - VL_BC_PIS
	aAdd (aRegI100[nPos], aDado[7])	 	  	//07 - ALIQ_PIS
	aAdd (aRegI100[nPos], aDado[8])	 	  	//08 - VL_PIS
	aAdd (aRegI100[nPos], aDado[9])	 	  	//09 - VL_BC_COFINS
	aAdd (aRegI100[nPos], aDado[10])	 	//10 - ALIQ_COFINS
	aAdd (aRegI100[nPos], aDado[11])	 	//11 - VL_COFINS
	aAdd (aRegI100[nPos], aDado[12])	 	//12 - INFO_COMPL
Else
	aRegI100[nPos][3] += aDado[2]			//02 - VL_REC
	aRegI100[nPos][5] += aDado[4]			//04 - VL_TOT_DED_GER
	aRegI100[nPos][6] += aDado[5]			//05 - VL_TOT_DED_ESP
	aRegI100[nPos][7] += aDado[6]			//06 - VL_BC_PIS
	aRegI100[nPos][9]  += aDado[8]			//08 - VL_PIS
	aRegI100[nPos][10] += aDado[9]			//09 - VL_BC_COFINS
	aRegI100[nPos][12] += aDado[11]			//11 - VL_COFINS
EndIF

Return nPos

//-------------------------------------------------------------------
/*/{Protheus.doc} RegI200
Função que irá gerar registro I200

@param  aRegI200  - Array com informações do registro I200
		  aDado  	- Array com informações que irá gerar I200.
		  nI100  	- Posição do registro pai I100

@return Posição do registro I200 no array

@author Erick G Dias
@since 23/12/2013
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function RegI200(aRegI200, aDado, nI100)

Local nPos	:= 0

nPos :=AScan(aRegI200, {|aX| aX[1]==nI100 .AND. aX[3]==aDado[2] .AND. aX[4]==aDado[3] .AND. aX[6]==aDado[5] .AND. aX[7]==aDado[6]})

If nPos == 0
	aAdd(aRegI200, {})
	nPos	:=	Len (aRegI200)
	aAdd (aRegI200[nPos], nI100)  	  		//Relação com registro Pai registro I100
	aAdd (aRegI200[nPos], "I200")	  		//01 - REG
	aAdd (aRegI200[nPos], aDado[2])	 	  	//02 - NUM_CAMPO
	aAdd (aRegI200[nPos], aDado[3])		  	//03 - COD_DET
	aAdd (aRegI200[nPos], aDado[4])	 	  	//04 - DET_VALOR
	aAdd (aRegI200[nPos], aDado[5])	 	  	//05 - COD_CTA
	aAdd (aRegI200[nPos], aDado[6])	 	  	//06 - INFO_COMPL
Else
	aRegI200[nPos][5] += aDado[4]			//04 - DET_VALOR
EndIF

Return nPos

//-------------------------------------------------------------------
/*/{Protheus.doc} RegI300
Função que irá gerar registro I300

@param  aRegI300  - Array com informações do registro I300
		  aDado  	- Array com informações que irá gerar I300.
		  nI100  	- Posição do registro pai I200

@return Posição do registro I300 no array

@author Erick G Dias
@since 23/12/2013
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function RegI300(aRegI300, aDado, nI200)

Local nPos	:= 0

nPos :=AScan(aRegI300, {|aX| aX[1]==nI200 .AND. aX[3]==aDado[2] .AND. aX[5]==aDado[4] .AND. aX[6]==aDado[5] })

If nPos == 0
	aAdd(aRegI300, {})
	nPos	:=	Len (aRegI300)
	aAdd (aRegI300[nPos], nI200)  	  		//Relação com registro Pai registro I200
	aAdd (aRegI300[nPos], "I300")	  		//01 - REG
	aAdd (aRegI300[nPos], aDado[2])	 	  	//02 - COD_COMP
	aAdd (aRegI300[nPos], aDado[3])		  	//03 - DET_VALOR
	aAdd (aRegI300[nPos], aDado[4])	 	  	//04 - COD_CTA
	aAdd (aRegI300[nPos], aDado[5])	 	  	//05 - INFO_COMPL
Else
	aRegI300[nPos][4] += aDado[3]			//03 - DET_VALOR
EndIF

Return nPos

//-------------------------------------------------------------------
/*/{Protheus.doc} BlocoI
Função que irá realizar a chamada das funções do módulo de saíde e do
módulo Financeiro, para chamar as funções responsáveis pela
geração dos registros.

@param  aRegI100  - Array com informações do registro I100
		  aRegI200  - Array com informações do registro I200
		  aRegI299  - Array com informações do registro I299
		  aRegI300  - Array com informações do registro I300
		  aRegI399  - Array com informações do registro I399
		  aReg0500 - Array com informações do registro 0500
		  aReg1010 - Array com informações do registro 1010
		  aReg1020 - Array com informações do registro 1020
		  nPaiI010  - Relação com registro pai I010
		  dDataDe   - Data inicial do arquivo
		  dDataAte  - Data Final do arquivo.
		  cIndAtiv	 - Indicador da Atividade
		  aRegM400	 - Array com valores do registro M400
		  aRegM410	 - Array com valores do registro M410
		  aRegM800	 - Array com valores do registro M800
		  aRegM810	 - Array com valores do registro M810
		  aRegI199	 - Array com valores do registro I999

@author Erick G Dias
@since 23/12/2013
@version 11.80
/*/
//-------------------------------------------------------------------
Function SPDCBlocoI(aRegI100,aRegI200,aRegI299,aRegI300,aRegI399,aReg0500,aReg1010,aReg1020,nPaiI010,dDataDe,dDataAte,cIndAtiv,aRegM400,aRegM410,aRegM800,aRegM810,aRegI199)

Local aDado		:= {}
Local aParNaoTri:= {}
Local cCst		:= ""
Local cInf		:= ""
Local cCampo	:= ""
Local c711712	:= ""
Local c713714	:= ""
Local cConta	:= ""
Local cProcRef	:= ""
Local cIndProc	:= ""
Local cNota		:= ""
Local cSerie	:= ""
Local cClieFor	:= ""
Local cLoja		:= ""
Local cTnatRec	:= ""
Local cCnatRec	:= ""
Local cGrpRec	:= ""
Local cAliasI	:= "BLOCOI"
Local nValRec	:= 0
Local cExclGer	:= 0
Local cExclEsp	:= 0
Local nBasePis	:= 0
Local nBaseCof	:= 0
Local nAlqPis	:= 0
Local nAlqCof 	:= 0
Local nValPis 	:= 0
Local nValCof 	:= 0
Local n713714	:= 0
Local nPosI100	:= 0
Local nPosI200	:= 0
Local nPosI300	:= 0
Local nCont		:= 0
Local lAchouCDG	:= .F.
Local lAchouCCF	:= .F.
Local lProc		:= .F.
Local lI300		:= .F.
Local dDtNatRec	:= CToD ("//")
Local cIntegra	:= aSPDSX6[MV_INTBLCI]
Local cCLASS	:= "CLASS"

For nCont :=1 to 2
	cAliasI	:= "BLOCOI"
	lProc	:= .F.
	If nCont ==1 .and. cIntegra $ "1/3" .AND. FindFunction("FinSpdBlcI")
		//Função do Financeiro
		FinSpdBlcI(Month(dDataDe),Year(dDataDe),cAliasI)
		lProc := .T.
	ElseIF nCont ==2 .and. cIntegra $ "2/3" .AND. FindFunction("PLSPISCOF")
		//Função de Saúde
		lProc := PLSPISCOF(dDataDe,dDataAte,cAliasI)
	EndIF

	If lProc
		(cAliasI)->(dbGoTop())
		While !(cAliasI)->(EOF())

			aDado		:= {}
			aParNaoTri	:= {}
			nValRec	:= 0
			cCst		:= ""
			cInf		:= ""
			cCampo		:= ""
			c711712	:= ""
			c713714	:= ""
			cConta		:= ""
			cExclGer	:= 0
			cExclEsp	:= 0
			nBasePis	:= 0
			nBaseCof	:= 0
			nAlqPis	:= 0
			nAlqCof 	:= 0
			nValPis 	:= 0
			nValCof 	:= 0
			n713714	:= 0
			nPosI100	:= 0
			nPosI200	:= 0
			nPosI300	:= 0
			cNota		:= ""
			cSerie		:= ""
			cClieFor	:= ""
			cLoja		:= ""

			If nCont ==1	//Valores Financeiro
				nValRec	:= (cAliasI)->VALOR
				cCst		:= (cAliasI)->CSTPIS
				nBasePis	:= (cAliasI)->BASEPIS
				nBaseCof	:= (cAliasI)->BASECOF
				nAlqPis	:= (cAliasI)->ALIQPIS
				nAlqCof	:= (cAliasI)->ALIQCOF
				cConta		:= (cAliasI)->CONTA
				lI300 := .F.
				IF !Empty((cAliasI)->CDRECA)
					c711712	:= Substr((cAliasI)->CDRECA,1,5)
					c713714	:= (cAliasI)->CDRECA
					IF Len(Alltrim((cAliasI)->CDRECA)) == 8
						lI300 := .T.
					EndIF
				Elseif !Empty((cAliasI)->CDDEDA)
					c711712	:= Substr((cAliasI)->CDDEDA,1,5)
					c713714	:= (cAliasI)->CDDEDA
					IF Len(Alltrim((cAliasI)->CDDEDA)) == 8
						lI300 := .T.
					EndIF
				EndIF
				cProcRef	:= (cAliasI)->NUMPRO
				cIndProc	:= (cAliasI)->INDPRO
				cTnatRec	:= (cAliasI)->TABCCZ
				cCnatRec	:= (cAliasI)->CODCCZ
				cGrpRec	:= (cAliasI)->GRUCCZ
				dDtNatRec	:= (cAliasI)->DTFCCZ
			ElseIF nCont ==2  //Valores Saúde
				nValRec	:= (cAliasI)->VALOR
				cCst		:= (cAliasI)->CSTPIS
				nAlqPis	:= (cAliasI)->ALIQPIS
				nAlqCof	:= (cAliasI)->ALIQCOF
				c711712	:=	SubStr((cAliasI)->&(cCLASS),1,5)
				c713714	:= (cAliasI)->&(cCLASS)
				lI300 := .F.
				IF Len(Alltrim((cAliasI)->&(cCLASS))) == 8
					lI300 := .T.
				EndIF
				cNota		:= (cAliasI)->NOTA
				cSerie		:= (cAliasI)->SERIE
				cClieFor	:= (cAliasI)->CLIENTE
				cLoja		:= (cAliasI)->LOJA
				cTnatRec	:= (cAliasI)->NATREC
				cCnatRec	:= (cAliasI)->CNATREC
				cGrpRec	:= (cAliasI)->GRUPONC
				dDtNatRec	:= (cAliasI)->DTFIMNT
			EndIF

			IF !Empty(c711712)

				If !Empty(cProcRef)
					lAchouCCF	:=	CCF->(MsSeek (xFilial ("CCF")+cProcRef+cIndProc))
				EndIF
				cConta	:= Reg0500(@aReg0500,cConta)
				If SubStr(c711712,1,1) == "D" //Deduções/Exclusões
					If SubStr(c711712,1,4) == "D000" //Exclusções e Deduções de caráter Geral
						cExclGer	:= nValRec
						nValRec	:= 0
					Else
						cExclEsp	:= nValRec
						nValRec	:= 0
					EndIF
				EndIF

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Informações para I100³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aDado	:=	{}
				aAdd(aDado,"I100")
				aAdd(aDado,nValRec)
				aAdd(aDado,cCst)
				aAdd(aDado,cExclGer)
				aAdd(aDado,cExclEsp)
				aAdd(aDado,nBasePis)
				aAdd(aDado,nAlqPis)
				aAdd(aDado,0 )
				aAdd(aDado,nBaseCof)
				aAdd(aDado,nAlqCof)
				aAdd(aDado,0 )
				aAdd(aDado,cInf)
				nPosI100	:= RegI100(@aRegI100, aDado, nPaiI010)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Gera registro I199³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lI300
					ProcRBlocI(cIndProc,	cProcRef,	lAchouCCF,	@aReg1010,	@aReg1020,	@aRegI199, "I199", nPosI100 )
				EndIF

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Informações para I200³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nPosI100 > 0
					aDado	:=	{}
					If SubStr(c711712 ,1,1) == "R"	//Receita
						cCampo		:= "02"
						n713714	:= nValRec
					ElseIf SubStr(c711712 ,1,4) == "D000" //Dedução Geral
						cCampo		:= "04"
						n713714	:=	cExclGer
					Else	//Dedução Específica
						cCampo		:= "05"
						n713714	:=	cExclEsp
					EndIF
					aAdd(aDado,"I200")
					aAdd(aDado,cCampo)
					aAdd(aDado,c711712)
					aAdd(aDado,n713714)
					aAdd(aDado,cConta)
					aAdd(aDado,cInf)
					nPosI200:= RegI200(@aRegI200, aDado, nPosI100)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Gera registro I299³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lI300
						ProcRBlocI(cIndProc,	cProcRef,	lAchouCCF,	@aReg1010,	@aReg1020,	@aRegI299, "I299", nPosI200 )
					EndIF
				EndIF

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Informações para I300³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  nPosI200 > 0 .AND. lI300
					aDado	:=	{}
					aAdd(aDado,"I300")
					aAdd(aDado,c713714)
					aAdd(aDado,n713714)
					aAdd(aDado,cConta)
					aAdd(aDado,cInf)
					nPosI300:= RegI300(@aRegI300, aDado, nPosI200)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Gera registro I399³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					ProcRBlocI(cIndProc,	cProcRef,	lAchouCCF,	@aReg1010,	@aReg1020,	@aRegI399, "I399", nPosI300 )
				EndIF

				IF nCont ==2 .AND. lI300
					//Busco informação complementar da SFT pois no módulo de saúde não existe esta informação.
					lAchouCDG:= CDG->(MsSeek (xFilial ("CDG")+"S"+cNota+cSerie+cClieFor+cLoja))
					If lAchouCDG
						ProceRefer(@aRegI199,nPosI100,@aReg1010,@aReg1020,"I199")
						ProceRefer(@aRegI299,nPosI200,@aReg1010,@aReg1020,"I299")
						ProceRefer(@aRegI399,nPosI300,@aReg1010,@aReg1020,"I399")
					EndIf

				EndIF

				IF cCst $ "04/06/07/08/09"
					aParNaoTri	:= {}

					aAdd(aParNaoTri,cCst)
					aAdd(aParNaoTri,nValRec)
					aAdd(aParNaoTri,cConta)
					aAdd(aParNaoTri,cTnatRec)
					aAdd(aParNaoTri,cCnatRec)
					aAdd(aParNaoTri,cGrpRec)
					aAdd(aParNaoTri,dDtNatRec)

					//Devo gerar M400/M800 para as receitas não tributadas
					RegM400(@aRegM400,@aRegM410,,@aReg0500,,,,,aParNaoTri)
					RegM800(@aRegM800,@aRegM810,,@aReg0500,,,,,aParNaoTri)

				EndIF
			EndIF
			(cAliasI)->(dbSkip())
		EndDo

		DbSelectArea(cAliasI)
		dbCloseArea()
		Ferase(cAliasI+GetDBExtension())
		Ferase(cAliasI+OrdBagExt())

	EndIF

Next nCont

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcRBlocI
Função para gerar processo referenciado nos registro I299 e I399

@param  cIndProc  - Indicador do processo referenciado
		  cNumProc  - Número do processo referenciado
		  lAchouCCF - Indica se encontrou informação na tabela CCF
		  aReg1010  - Array com valores do registro 1010
		  aReg1020  - Array com valores do registro 1020
		  aReg 		 - Array com valores do registro I299/I399
		  cReg 		 - Registro a ser processado I299/I399
		  nPosPai   - Relação com registro pai

@author Erick G Dias
@since 27/01/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function ProcRBlocI(cIndProc, cNumProc, lAchouCCF, aReg1010, aReg1020, aReg, cReg, nPosPai)

Local nPos	:= 0

IF !Empty(cIndProc) .AND. !Empty(cNumProc)
	aAdd(aReg, {})
	nPos := Len (aReg)
	aAdd (aReg[nPos], nPosPai)
	aAdd (aReg[nPos], cReg)				//01-REG
	aAdd (aReg[nPos], cNumProc)			//02-NUM_PROC
	aAdd (aReg[nPos], cIndProc)			//03-IND_PROC

	If	lAchouCCF
		If CCF->CCF_TPCOMP == "1" //Complemento do processo referenciado - Judicial
			Reg1010(@aReg1010)
		ElseIf CCF->CCF_TPCOMP == "2" //Complemento do processo referenciado - Administrativo
			Reg1020(@aReg1020)
		EndIf
	Endif
EndIF

Return
//-------------------------------------------------------------------------------
/*/{Protheus.doc} PCGrvReg
--
TOTVS
--
Descrição:
--
@version 1.0
/*/
//------------------------------------------------------------------------------- */
Function PCGrvReg (cAlias, nRelac, aReg, nItem, nFlag, nPai, cChvPai, lLoja , nTamTRBIt )
Local	nX			:=	0
Local	lRet		:=	.T.
Local	cDelimit	:=	"|"
Local	nZ			:=	0
Local	cLinha		:=	""
Local	cReg		:=	""
Local 	llDecim		:= .F.
Local 	llDecim3	:= .F.
Local 	cExecSQL	:= ""

Default	nRelac	:=	0
Default	nFlag	:=	0
Default cChvPai	:= ""
Default lLoja	:= .F.
Default nTamTRBIt	:= 50
Default nItem	:= Iif(lProcMThr ,0, nItem )
Default nPai	:= Iif(lProcMThr ,0, nPai )

If nFlag==0
	cFlag := Iif(Valtype(nRelac)=="N",StrZero (nRelac, nTamTRBIt, 0),nRelac)
Else
	cFlag := StrZero (nFlag, nTamTRBIt, 0)
EndIf

For nZ := 1 To Len (aReg)
	cLinha	:=	cDelimit
	//
	//Monto cLinha para gravar no TRB
	For nX := 1 To Len (aReg[nZ])

		// Verifica se o campo deve conter 4 casas decimais
		llDecim  := SPDGet4Dec(aReg[nZ,1],nX)
		llDecim3 := SPDGet3Dec(aReg[nZ,1],nX)

		If (ValType (aReg[nZ][nX])="A")
			cLinha += PCRetStr (aReg[nZ][nX][1], aReg[nZ][nX][2])+cDelimit
		Else
			cLinha += PCRetStr (aReg[nZ][nX],Iif(llDecim,4,If(llDecim3,3,NIL)))+cDelimit
		EndIf
	Next (nX)

	cReg := SubStr (cLinha, 2, 4)

	//Tratamento para nao permitir gerar uma string maior que o tamanho do campo TRB_CONT. Se acontecer, somente serah no registro 0450.
	If Len(cLinha)>Len((cAlias)->TRB_CONT)
		cLinha := AllTrim(Left(cLinha,Len((cAlias)->TRB_CONT)-1))+cDelimit
	EndIf

	If !lProcMThr
		//
		//Monto TRB
		RecLock (cAlias, .T.)
			(cAlias)->TRB_TPREG		:=	cReg
			(cAlias)->TRB_RELAC		:=	cFlag+Iif(!lLoja,(Iif(Valtype(nRelac)=="N",StrZero(nRelac,nTamTRBIt,0),nRelac)), StrZero (nItem, nTamTRBIt, 0)  )
			(cAlias)->TRB_CONT		:=	cLinha
			(cAlias)->TRB_ITEM		:=	nItem
			(cAlias)->TRB_PAI		:=	nPai
			(cAlias)->TRB_CHVPAI	:=	cChvPai
		MsUnLock ()
	// ---------------  GRAVACAO DIRETO NO BANCO NA FUNCIONALIDADE EM MULTITHREAD
	Else
		cExecSQL := " INSERT INTO " + cNomeTRB + " "
		cExecSQL += " VALUES 	( "
		cExecSQL += "  '" + cReg + "' "
		cExecSQL += ", '" + cFlag+Iif(!lLoja,(Iif(Valtype(nRelac)=="N",StrZero(Iif(cReg$"C400|C490",1,nRelac),nTamTRBIt,0),nRelac)), StrZero ( Iif(cReg$"C400|C490",1,nItem), nTamTRBIt, 0) ) + "' "
		cExecSQL += ", ' ' " 							// TRB_FLAG
		cExecSQL += ", '" + cLinha + "' "
		cExecSQL += ", '"  + cValtoChar(nItem) + "' "
		cExecSQL += ", "  + cValToChar(nPai) + " "
		cExecSQL += ", '" + cChvPai + "' "
		cExecSQL += ", ' ' " 									// D_E_L_E_T_
		cExecSQL += ", "  + cValToChar( n_SPCRecno ) + " "   		// R_E_C_N_O_
		cExecSQL += " 			) "
		If TcSQLExec( cExecSQL ) >= 0
			n_SPCRecno ++
			n_COMMIT++
		Else
			Conout("erro no insert: ")
			Conout(cExecSQL)
		EndIf
	EndIf

Next (nZ)

// Verifica a necessidade de fazer Commit no banco
If lProcMThr .AND. n_COMMIT > 4095
	TcSQLExec( 'COMMIT' )
	n_COMMIT := 0
EndIf

Return (lRet)

Static Function PCRetStr (xValor, nDec)
	Local	xRet
	//
	If (ValType (xValor)=="N")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Todas as variaveis numericas que nao tiverem definicao de casas decimais     |
		//³serao convertidas para apresentarem 2 decimais                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (xValor==0)
			xRet	:=	"0"
		ElseIf nDec == NIL
			xRet	:=	AllTrim (StrTran (Str (xValor,,2), ".", ","))
		Else
			xRet	:=	AllTrim (StrTran (Str (xValor,,nDec), ".", ","))
		EndIf

	ElseIf (ValType (xValor)=="C")
		xRet	:=	AllTrim (xValor)
		xRet 	:=  StrTran(xRet,"'"," ")

	ElseIf (ValType (xValor)=="D") .And. !Empty(xValor)
		xRet	:=	StrZero (Day (xValor), 2)+StrZero (Month (xValor), 2)+StrZero (Year (xValor), 4)

	Else
		xRet	:=	""

	EndIf

Return (xRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SpdFRg1700| Autor ³Gustavo G. Rueda 			   ³ Data ³14.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao utilizada para aglutinar as informacoes a serem geradas nos ³±±
±±³          ³ registros:                                                        ³±±
±±³          ³                1700(DOCUMENTOS FISCAIS UTILIZADOS)                ³±±
±±³          ³         1710(DOCUMENTOS FISCAIS CANCELADOS/INUTILIZADOS)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpC1 := Reg1700(cAliasSFT,cEspecie,aReg1700,@aReg1710,cSituaDoc)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aPar1 - Array com as informacoes do documento fiscal              ³±±
±±³          ³ aPar2 - Array passado por referencia para aglutinar as informacoes|±±
±±³          ³         do registro 1700                                          ³±±
±±³          ³ aPar3 - Array passado por referencia para aglutinar as informacoes|±±
±±³          ³         do registro 1710                                          ³±±
±±³          ³ cPar4 - Variavel que contem o status do documento fiscal          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SpdFRg1700(aRegC100,aReg1700,aReg1710,cSituaDoc,cSerie)
Local	lRet		:=	.T.
Local	cDisp		:=	""
Local	nPos1700	:=	0
Local	aAidf		:=	{}

Default cSerie := aRegC100[1,7]

If cVersao >= "003"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Utilizo a funcao do MATXMAG para retornar o dispositivo AIDF do documento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAidf := RetAidf(aRegC100[1,8],cSerie,.T.)
	If !Empty(aAidf[1])
		Do Case
			Case Alltrim(aAidf[2]) == "1"
				cDisp :="04"
			Case Alltrim(aAidf[2]) == "2"
				cDisp :="03"
			Case Alltrim(aAidf[2]) == "3"
				cDisp :="00"
			Case Alltrim(aAidf[2]) == "4"
				cDisp :="05"
			Case Alltrim(aAidf[2]) == "6"
				cDisp :="02"
			Case Alltrim(aAidf[2]) == "7"
				cDisp :="01"
		EndCase

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³1700(DOCUMENTOS FISCAIS UTILIZADOS)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nPos1700 := aScan(aReg1700,{|aX| aX[2]==cDisp .And. aX[3]==aRegC100[1,5] .And. aX[4]==aRegC100[1,7]}))==0
			aAdd(aReg1700, {})
			nPos	:=	nPos1700	:=	Len (aReg1700)
			aAdd (aReg1700[nPos], "1700")					//01 - REG
			aAdd (aReg1700[nPos], cDisp)					//02 - COD_DIST
			aAdd (aReg1700[nPos], aRegC100[1,5])			//03 - COD_MOD
			aAdd (aReg1700[nPos], aRegC100[1,7])			//04 - SER
			aAdd (aReg1700[nPos], "")						//05 - SUB
			aAdd (aReg1700[nPos], aRegC100[1,8])			//06 - NUM_DOC_INI
			aAdd (aReg1700[nPos], aRegC100[1,8])			//07 - NUM_DOC_FIN
			aAdd (aReg1700[nPos], aAidf[1])					//08 - NUM_AUT
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³O tratamento abaixo eh para quando jah existir um relacionamento, poder ser ³
			//³ verificado se o proximo documento estah dentro do range dos campos 02 e 03.³
			//³                                                                            ³
			//³Este tratamento leva em consideracao que os documentos apresentados no      ³
			//³  periodo, de emissao propria, seguem a ordem normal de emissao, um numero  ³
			//³  de documento crescente e sequencial.                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			//Verifico se eh um numero maior que o ultimo lido
			If Val(aRegC100[1,8])>Val(aReg1700[nPos1700,7])
				aReg1700[nPos1700,7]	:=	aRegC100[1,8]
			EndIf

			//Verifico se eh um numero menor que o ultimo lido
			If Val(aRegC100[1,8])<Val(aReg1700[nPos1700,6])
				aReg1700[nPos1700,6]	:=	aRegC100[1,8]
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³1710(DOCUMENTOS FISCAIS CANCELADOS/INUTILIZADOS)                                  ³
		//|                                                                                  |
		//|Este registro deve ser geradoo conforme a combinacao acima dos campo 02, 03 e 04. |
		//|Ao gerar o arquivo texto, eles devem manter a hierarquia, para isso faco o        |
		//|  relacionamento atraves do primeiro campo do registro 1710.                      |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cSituaDoc$"02#03#05"  //Cancelado/Inutilizado

			//Verifico se ja existe 1710 para este registro 1700
			nPos := aScan(aReg1710,{|aX|aX[1]==nPos1700 .and. ((Val(aRegC100[1,8]) == Val(aX[3]) - 1) .or. (Val(aRegC100[1,8]) == Val(aX[4]) + 1))})

			//Se nao possuir registro 1710 ainda ou se a numeracao nao for continua, devo criar um registro 1710 novo
			If  (nPos == 0)
				aAdd(aReg1710, {})
				nPos	:=	Len (aReg1710)
				aAdd (aReg1710[nPos], nPos1700)										//00 - RELACIONAMENTO COM 1700
				aAdd (aReg1710[nPos], "1710")										//01 - REG
				aAdd (aReg1710[nPos], aRegC100[1,8])								//02 - NUM_DOC_INI
				aAdd (aReg1710[nPos], aRegC100[1,8])								//03 - NUM_DOC_FIN
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³O tratamento abaixo eh para quando jah existir um relacionamento, poder ser ³
				//³ verificado se o proximo documento estah dentro do range dos campos 02 e 03.³
				//³                                                                            ³
				//³Este tratamento leva em consideracao que os documentos apresentados no      ³
				//³  periodo, de emissao propria, seguem a ordem normal de emissao, um numero  ³
				//³  de documento crescente e sequencial.                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				//Verifico se eh um numero maior que o ultimo lido
				If Val(aRegC100[1,8])>Val(aReg1710[nPos,4])
					aReg1710[nPos,4]	:=	aRegC100[1,8]
				EndIf

				//Verifico se eh um numero menor que o ultimo lido
				If Val(aRegC100[1,8])<Val(aReg1710[nPos,3])
					aReg1710[nPos,3]	:=	aRegC100[1,8]
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/Função MontOrdCre
Irá montar array com a ordem dos códigos de créditos da tabela 4.3.6
conforme ordem definida pelo cliente
/*/
//-------------------------------------------------------------------
Function MontOrdCre()
Local nPos		:= 0
Local aRet		:= {}
Local cTexto	:= aSPDSX6[MV_OCODCSC]
Local cCod		:= ""

//Irá montar um array com os códigos da tabela 4.3.6 informados pelo cliente através do parâmetro MV_OCODCSC
IF Len(Alltrim(cTexto)) > 0
	nPos:= At(",",SubStr(cTexto,1,len(cTexto)))
	IF nPos ==0
		//Não há virgula, existe apenas um código
		AADD(aRet,Alltrim(cTexto))
	Else
		While nPos > 0
			cCod := Substr(cTexto,1,nPos-1)
			IF (aScan (aRet, {|aX| aX==alltrim(cCod)})==0)
				AADD(aRet,alltrim(cCod))
			EndIF
			cTexto := Substr(cTexto,nPos+1,len(cTexto))
			nPos  := At(",",SubStr(cTexto,1,len(cTexto)))
		EndDo
		IF len(cTexto) > 0 .AND. (aScan(aRet, {|aX| aX==Alltrim(cTexto)})==0)
			//Adiciona o último código da sequeência
			AADD(aRet,Alltrim(cTexto))
		EndIF
	EndIF
EndIF

Return (aRet)



/*ÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CalcCaixa ºAutor  ³Erick G. Dias       º Data ³  26/06/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Irá gerar os valores dos registros F500 e F510 para o		  º±±
±±º          ³bloco M.                                              	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aRegM210 -> Array com informações do registro M210         º±±
±±ºParametros³ aRegM610 -> Array com informações do registro M610         º±±
±±ºParametros³ aF500	-> Array com informações do registro F500         º±±
±±ºParametros³ aF510 	-> Array com informações do registro F510         º±±*/
Function CalcCaixa(aRegM210,aRegM610,aF500,aF510,aAjusteR,aAjusteA,lFilSCP,cIndNatJur)

Local aPar	:= {}
Local nPos	:= 0
Local nPis	:= 0
Local nCof	:= 0
Local aSCP	:= {}


For nPos	:= 1 to len(aF500)
	//³Preenche array para geração do registro M200 e filhos³
	aPar		:= {}
	aAdd(aPar,aF500[nPos][3])  		//CST DE PIS
	aAdd(aPar,aF500[nPos][6])  		//ALÍQUOTA DE PIS
	aAdd(aPar,Round(aF500[nPos][5], 2)) 		//BASE DE CÁLCULO DE PIS
	aAdd(aPar,Round(aF500[nPos][2], 2)) 		//TOTAL DA RECEITA
	nPis:= Round(aF500[nPos][5] * aF500[nPos][6] /100,2)
	aAdd(aPar,nPis) 				//VALOR DE PIS
	aAdd(aPar,.F.)  				//Indica se é operação com pauta
	aF500[nPos][7]	:= nPis

	//³Geração do registro M200 e filhos³
	RegM210(@aRegM210,,,.T.,,,.T.,,,,,,,,,aPar,.F.)

	//³Geração do registro M600 e filhos³
	aPar		:= {}
	aAdd(aPar,aF500[nPos][8])  		//CST DE COFINS
	aAdd(aPar,aF500[nPos][11])  	//ALÍQUOTA DE COFINS
	aAdd(aPar,Round(aF500[nPos][10], 2)) 		//BASE DE CÁLCULO DE COFINS
	aAdd(aPar,Round(aF500[nPos][2], 2)) 		//TOTAL DA RECEITA
	nCof:= Round(aF500[nPos][10] * aF500[nPos][11] /100,2)
	aAdd(aPar,nCof) 				//VALOR DA COFINS
	aAdd(aPar,.F.)  				//Indica se é operação com pauta
	aF500[nPos][12]	:= nCof

	//³Geração do registro M600 e filhos³
	RegM610(@aRegM610,,,.T.,,,.T.,,,,,,,,,aPar,.F.)
	IF lFilSCP .AND. nCof>0 .AND. nPis>0 .And. !(cIndNatJur$"03#04#05")
		aSCP	:= {}
		Aadd(aSCP,{,,aF500[nPos][3],,aF500[nPos][6],nPis,,,aF500[nPos][11],nCof})
		SpedXAjSCP(1,aSCP[1],@aAjusteR,@aAjusteA,.T.,cRegime,dDataAte)
	EndIF
Next nPos

For nPos	:= 1 to len(aF510)
	//³Preenche array para geração do registro M200 e filhos³
	aPar		:= {}
	aAdd(aPar,aF510[nPos][3])  		//CST DE PIS
	aAdd(aPar,aF510[nPos][6])  		//ALÍQUOTA DE PIS
	aAdd(aPar,aF510[nPos][5]) 		//BASE DE CÁLCULO DE PIS
	aAdd(aPar,aF510[nPos][2]) 		//TOTAL DA RECEITA
	nPis:= Round(aF510[nPos][5] * aF510[nPos][6],2)
	aAdd(aPar,nPis) 				//VALOR DE PIS
	aAdd(aPar,.T.)  				//Indica se é operação com pauta
	aF510[nPos][7]	:= nPis

	//³Geração do registro M200 e filhos³
	RegM210(@aRegM210,,,.T.,,,.T.,,,,,,,,,aPar,.F.)

	//³Geração do registro M600 e filhos³
	aPar		:= {}
	aAdd(aPar,aF510[nPos][8])  		//CST DE COFINS
	aAdd(aPar,aF510[nPos][11])  	//ALÍQUOTA DE COFINS
	aAdd(aPar,aF510[nPos][10]) 		//BASE DE CÁLCULO DE COFINS
	aAdd(aPar,aF510[nPos][2]) 		//TOTAL DA RECEITA
	nCof:= Round(aF510[nPos][10] * aF510[nPos][11],2)
	aAdd(aPar,nCof) 				//VALOR DA COFINS
	aAdd(aPar,.T.)  				//Indica se é operação com pauta
	aF510[nPos][12]	:= nCof
	//³Geração do registro M600 e filhos³
	RegM610(@aRegM610,,,.T.,,,.T.,,,,,,,,,aPar,.F.)
	IF lFilSCP .AND. nCof>0 .AND. nPis>0 .And. !(cIndNatJur$"03#04#05")
		aSCP	:= {}
		Aadd(aSCP,{,,aF510[nPos][3],,aF510[nPos][6],nPis,,,aF510[nPos][11],nCof})
		SpedXAjSCP(1,aSCP[1],@aAjusteR,@aAjusteA,.T.,cRegime,dDataAte)
	EndIF
Next nPos
Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SPDFCFPrfA³ Autor ³ Vendas e CRM          ³ Data ³27/11/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua carga dos arrays dos registros de ECF (Cupom Fiscal)³±±
±±³          ³                     (PERFIL A)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL (Ambiente TOP)                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPDFCFPrfA(aRegC400	, aRegC405	, aRegC410	, aRegC420	,;
					aRegC425	, aRegC460	, aRegC470	, aRegC490	,;
					aRegC495	, aProdB1	, dDataDe	, dDataAte	,;
					cPerfil		, cAlias	, aReg0200	, aReg0190	,;
					aReg0220	, aReg1600	, aReg0150	, aWizard	,;
					lTop		, cUf		, nQtReg0200, lJob		,;
					lLegisPer,	cNrlivro 	, aArq		, oSay)

Local 	nPos400		:= 0
Local 	nPos405		:= 0
Local 	aPos420		:= {}
Local 	aTotaliz	:= {}
Local 	nY 			:= 0
Local 	nValCof 	:= 0
Local	nValPis 	:= 0
Local 	cAliqISS  	:= ""
Local 	nAliqIss 	:= 0
Local 	aCmpAliICM 	:= {} 							// Campos de Aliquota de ICMS da tabela SFI
Local 	aCmpAliISS 	:= {} 							// Campos de Aliquota de ISS da tabela SFI
Local 	nVlBrtLj  	:= 0
Local 	cFilB1		:= cFilAnt
Local 	cQryAlias 	:= GetNextAlias() 				// Alias da Query
Local 	cQryFields 	:= ""  							// Campos da Query
Local 	cChave  	:= ""
Local 	cPDV 		:= ""
Local 	sDTMOVTO	:= ""
Local  	aSLX 		:= {}
Local 	lConcFil	:= aSPDSX6[MV_COFLSPD]
Local 	aItensC470 	:= {}
Local 	lIsBahia 	:= cUf == "BA"
Local   lGer410		:= !lLegisPer .And. "1"$aWizard[1][15]
Local 	cQuery 		:= ""
Local 	aAuxRgC405 	:= {}
Local   cArqTRB		:= aArq[1][2]
Local 	aPrc460470  := {}
Local   nPrc460470  := 0
Local 	cFieldAliq 	:= ""							// Campos de Aliquota de ICMS
Local 	cSemaforo	:= "SPEDFIS_"+Alltrim(Str(ThreadID())) //Semaforo das Threads
Local   nQtdThread 	:= aSPDSX6[MV_SPDFQTC] //Quantidade de Threads a serem consideradas para processamento simultaneo na geracao dos registros C460 e C470
Local 	cCupomDe	:= StrZero(0,6) //Tamanho padrao 6, pois o COO da impressora utiliza 6 digitos
Local 	cCupomAte	:= ""
Local 	nVlrDescto	:= 0
Local 	nVlrCancel	:= 0
Local 	lExitMovto	:= .F. //Indica se existe movimento de Cupom Fiscal no Periodo informado

Default aWizard :={}

nQtdThread := If(nQtdThread<=0,1,nQtdThread) //Por seguranca, garante que tenha pelo menos 1 thread para executar o processamento multithread

//Legenda de ISS
cAliqISS := cValToChar(aSPDSX6[MV_ALIQISS])
cAliqISS := AllTrim( StrTran(cAliqISS, ",", ".") )
cAliqISS := TransForm(cAliqISS, "@E 99.99")
nAliqIss := Val(SubStr(cAliqISS , 1, At(".", cAliqISS)))
cAliqISS := StrTran(cAliqISS, ".")
cAliqISS := AllTrim(cAliqISS)
If nAliqIss >= 10
	cAliqISS := "S" + PadR(cAliqISS, 4, "0")
Else
	cAliqISS := "S0" + PadR(cAliqISS, 3, "0")
EndIf

//Busca os campos das aliquotas de ICMS e ISS.
SPDFRetAli( @aCmpAliICM, @aCmpAliISS )

If !lIsBahia .OR. (lIsBahia .AND. cVersao >= '008')
	//Executa esta funcao separadamente para carregar Registros 0200 (este tratamento foi feito para melhorar a performance do processamento)
	SPDFLj0200( cAlias, dDataDe, dDataAte, @aReg0200, @aReg0190, @aReg0220, @nQtReg0200, cFilB1, lConcFil, "C470", aWizard)
EndIf

//----------------------------
//CAMPOS PARA MONTAR A QUERY
//----------------------------
cQryFields := "SFI.FI_PDV, SFI.FI_DTMOVTO AS DTMOVTO, SFI.FI_DESC,SFI.FI_VALCON,SFI.FI_CRO,SFI.FI_NUMREDZ,SFI.FI_NUMFIM,SFI.FI_NUMINI,SFI.FI_GTFINAL,"
cQryFields += "SFI.FI_ISS,SFI.FI_CANCEL,SFI.FI_SUBTRIB,SFI.FI_ISENTO,SFI.FI_NTRIB,"
cQryFields += "SLG.LG_SERPDV,SLG.LG_IMPFISC,"

If SFI->(FieldPos("FI_CANISS")) > 0
	cQryFields += "SFI.FI_CANISS,"
Else
	cQryFields += "0 AS FI_CANISS,"
EndIf
If SFI->(FieldPos("FI_DESISS")) > 0
	cQryFields += "SFI.FI_DESISS,"
Else
	cQryFields += "0 AS FI_DESISS,"
EndIf
If SFI->(FieldPos("FI_ISSISEN")) > 0
	cQryFields += "SFI.FI_ISSISEN,"
Else
	cQryFields += "0 AS FI_ISSISEN,"
EndIf

If SFI->(FieldPos("FI_ISSNTRI")) > 0
	cQryFields += "SFI.FI_ISSNTRI,"
Else
	cQryFields += "0 AS FI_ISSNTRI,"
EndIf

If SFI->(FieldPos("FI_ISSFTRI")) > 0
	cQryFields += "SFI.FI_ISSFTRI,"
Else
	cQryFields += "0 AS FI_ISSFTRI,"
EndIf
//Acrescenta os campos de tributacao de ICMS (Ex: FI_BAS7, FI_BAS12, FI_BAS18...)
For nY:=1 to Len(aCmpAliICM)
	cFieldAliq += "SFI." + aCmpAliICM[nY][1] + ","
	If !Empty(aCmpAliICM[nY][2])
		cFieldAliq += "SFI." + aCmpAliICM[nY][2] + ","
	EndIf
Next nY

//Acrescenta os campos de tributacao de ISS (Ex: FI_BIS0300, FI_BIS0500, FI_BIS0700...)
For nY:=1 to Len(aCmpAliISS)
	cFieldAliq += "SFI." + aCmpAliISS[nY][1] + ","
	If !Empty(aCmpAliISS[nY][2])
		cFieldAliq += "SFI." + aCmpAliISS[nY][2] + ","
	EndIf
Next nY

//Tira a ultima virgula
cFieldAliq := Left(cFieldAliq,Len(cFieldAliq)-1)

cQryFields := cQryFields + cFieldAliq

cQuery := "SELECT " + cQryFields
cQuery += " FROM " + RetSQLName("SFI") + " SFI, " + RetSQLName("SLG") + " SLG "
cQuery += " WHERE SFI.FI_FILIAL = '"+xFilial("SFI")+"'"
cQuery += " AND SLG.LG_FILIAL = '"+xFilial("SLG")+"'"
cQuery += " AND SLG.LG_PDV = SFI.FI_PDV"
cQuery += " AND SFI.FI_DTMOVTO >= '"+dToS(dDataDe)+"' AND SFI.FI_DTMOVTO <= '"+dToS(dDataAte)+"'"
cQuery += " AND SFI.D_E_L_E_T_ = ' '"
cQuery += " AND SLG.D_E_L_E_T_ = ' '"
cQuery += " AND EXISTS ( SELECT FT_NFISCAL"
cQuery += "                FROM "+RetSQLName("SFT")+" SFT"
cQuery += "               WHERE SFT.FT_FILIAL = '"+xFilial("SFT")+"'"
cQuery += "                 AND SFT.FT_TIPOMOV = 'S'"
cQuery += "                 AND SFT.FT_PDV = SFI.FI_PDV"
cQuery += "                 AND (SFT.FT_ESPECIE = 'CF' OR SFT.FT_ESPECIE = 'ECF')"
cQuery += "                 AND (SFT.FT_ENTRADA = SFI.FI_DTMOVTO OR (SFI.FI_VALCON = 0 AND SFI.FI_CANCEL = 0))"
cQuery += "                 AND SFT.D_E_L_E_T_ = ' ' )"
cQuery += " ORDER BY SFI.FI_PDV, SFI.FI_DTMOVTO, SFI.FI_NUMREDZ"
cQuery := ChangeQuery( cQuery )
DbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cQryAlias, .T., .F. )

lExitMovto := !(cQryAlias)->(Eof())

//---------------------
// Processa Registros.
//---------------------
Do While !(cQryAlias)->(Eof())

    cPDV :=  (cQryAlias)->FI_PDV

	If !lJob
		oSay:cCaption := ("Processando Cupom Fiscal - PDV " + AllTrim(cPDV))
		ProcessMessages()
	EndIf

	RegC400 (@aRegC400, (cQryAlias)->LG_IMPFISC, (cQryAlias)->LG_SERPDV, AllTrim((cQryAlias)->FI_PDV), @nPos400)

	aAdd( aPrc460470, { cPDV, {} } )
	nPrc460470++

	//----------------------------
	// Laco por PDV
	//----------------------------
	While !(cQryAlias)->(Eof()) .AND. cPDV==(cQryAlias)->FI_PDV

		sDTMOVTO 	:= (cQryAlias)->DTMOVTO
		cChave 		:= cPDV + sDTMOVTO

		nVlBrtLj 	:= (cQryAlias)->FI_VALCON 	+ (cQryAlias)->FI_ISS 		// Valor Bruto = FI_VALCON (Valor contabil) + FI_ISS (Valor de Servicos)
		nVlrDescto	:= (cQryAlias)->FI_DESC 	+ (cQryAlias)->FI_DESISS 	// Valor Total Descontos = FI_DESC (Valores de Descontos de ICMS) + FI_DESISS (Valores de Descontos de ISS)
		nVlrCancel	:= (cQryAlias)->FI_CANCEL 	+ (cQryAlias)->FI_CANISS 	// Valor Total Cancelamentos = FI_CANCEL (Valores de Cancelamentos de ICMS) + FI_CANISS (Valores de Cancelamentos de ISS)

		RegC405 (@aRegC405				, nPos400				, sToD((cQryAlias)->DTMOVTO)	, (cQryAlias)->FI_CRO	, ;
				(cQryAlias)->FI_NUMREDZ	, (cQryAlias)->FI_NUMFIM, (cQryAlias)->FI_GTFINAL		, nVlBrtLj   			, ;
				@nPos405				, nVlrDescto  			, nVlrCancel)

		aAuxRgC405 := {aRegC405[nPos405]}

		//Reinicia variaveis
		nValCof 	:= 0
		nValPis 	:= 0
		aSize(aItensC470, 0) //Zera variavel para desalocar memoria
		aSize(aTotaliz, 0) 	 //Zera variavel para desalocar memoria

		If aAuxRgC405[1][8] == 0 //Verifica se o "VL_BRT" (Posicao 7 do registro C405) contém valor
			//Caso seja zerado o valor acumulado no totalizador de venda bruta da Redução Z, nao deve gerar os demais registros filhos.
			//Quando o valor eh zerado, eh porque nao tem movimento. Pode ter sido pelo fato de ter acontecido uma intervencao tecnica na Impressora Fiscal.
			(cQryAlias)->(dbSkip())
			Loop
		EndIf

		cCupomDe   := (cQryAlias)->FI_NUMINI //Numero do Proximo Cupom Emitido apos a Reducao Z
		cCupomAte  := (cQryAlias)->FI_NUMFIM //Numero do ultimo Cupom Emitido antes da Reducao Z

		//--------------------------------------------------------------------
		// Carrego todos os codigos e valores que foram contabilizados no SFI
		//--------------------------------------------------------------------
		aTotaliz 	:= SPDFTotSFI(.T., cAliqISS, cQryAlias, aCmpAliICM, Nil, aCmpAliISS)

		RegC420 (@aRegC420, 	nPos405,   	(cQryAlias)->FI_CRO, 		(cQryAlias)->FI_NUMREDZ,;
				 aTotaliz,		@aPos420)

		If !lIsBahia .OR. (lIsBahia .AND. cVersao >= '008')

	   		//Guarda as informacoes do PDV e DATA da Reducao Z, para gerar os Registros C460 e C470 em MultiThread (Melhoria de Performance)
	   		aAdd( aPrc460470[nPrc460470][2], { (cQryAlias)->DTMOVTO, nPos405, aAuxRgC405 } )

		EndIf

		SPDFRgC490 (@aRegC490	, sDTMOVTO	, nPos405	,;
					cPDV		, @aProdB1	, nPos405	,;
					@aReg0200	, @aReg0190	, @aReg0220 ,;
					@nValCof	, @nValPis	, cCupomDe	, cCupomAte)

		If lGer410 //Depois de ter os valores de PIS e COFINS gera o C410
			RegC410 (  @aRegC410	   	, nPos405 	, nValCof 	, nValPis  ,;
					   Nil 				, Nil 		, lTop )
		EndIf

		(cQryAlias)->(dbSkip())

	EndDo

	If lIsBahia .AND. cVersao < '008'
		//O Registro C495 somente deve ser gerado, caso tenha gerado tambem o Registro C400
		RegC495 (@aRegC495	, @aProdB1			, nPos400	, dDataDe	,;
				 dDataAte	, AllTrim(cPDV)		, @aReg0200	, cAlias 	,;
				 @aReg0190 	, @aReg0220 		, @aSLX 	, cFilB1)
	EndIf
EndDo

DbSelectArea(cQryAlias)
(cQryAlias)->(DbCloseArea())

If lExitMovto
	If !lJob
		oSay:cCaption := ("Processando em MultiThread - Registros C460/C470")
		ProcessMessages()
	EndIf

	// Executa em segundo plano (MultiThread) para geracao dos Registros C460 e C470 [Melhoria de Performance]
	StartJob( "SPDFJ460470", GetEnvServer(), .T., { cEmpAnt, cFilAnt, aWizard, cArqTRB, cAlias, cNrlivro, aPrc460470, cSemaforo, nQtdThread } )

	aSize(aPos420, 0) //Zera variavel para desalocar memoria
EndIf

If "1"$aWizard[4][7]//Verifica se deve gerar registro 1600
	SPDFGr1600(@aReg1600,@aReg0150,dDataDe,dDataAte,cAlias,aWizard,Nil,lConcFil)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SPDFJ460470ºAutor ³ Varejo             º Data ³ 08/Set/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Job para gerenciar os processos IPC de geracao dos registrosº±±
±±º          ³ C460 e C470.                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SPED FISCAL                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SPDFJ460470( aParams )
Local cEmp      := aParams[01]
Local cFil      := aParams[02]
Local aWizard   := aParams[03]
Local cArqTRB   := aParams[04]
Local cArqAlias := aParams[05]
Local cNrLivro  := aParams[06]
Local aPrc460470:= aParams[07]
Local cSemaforo	:= aParams[08]
Local nQtdThread:= aParams[09]
Local nTotPDVs  := Len(aPrc460470) //Qtde total de PDVs p/ processar
Local cPDV      := ""
Local nCont     := 0
Local cControl 	:= "1"

PtInternal( 1 , 'Thread( ' + cSemaforo + ' ) - SPEDFISCAL )' )	// Imprime no monitor a Identificacao da Thread

RPCSetType(3) //Nao console licenca
RPCSetEnv( cEmp, cFil,,, "FIS",, {"SFT"} )

//Inicia as Threads
For nCont := 1 To nQtdThread
	StartJob( "SPDFI460470", GetEnvServer(), .F., {SM0->M0_CODIGO, SM0->M0_CODFIL, cSemaforo} )
Next nCont

nCont := 1
While !KillApp() .and. nCont <= nTotPDVs
	cPDV := aPrc460470[nCont][1]
	If Len( aPrc460470[nCont][2] ) == 0 .OR. IPCGo( cSemaforo, cControl, cEmp, cFil, aWizard, cArqTRB, cArqAlias, cPDV, cNrLivro, aPrc460470[nCont][2] )
		nCont++
	Else
		Sleep( 3000 ) // Aguarda 3 segundos
	EndIf
End

Sleep(5000) // Aguarda 5 segundos

cControl := "0" //Indica que eh para encerrar as threads
nCont := 1
// Finaliza as Threads
While !KillApp() .and. nCont <= nQtdThread
	If IPCGo( cSemaforo, cControl )
		nCont++
	Else
		Sleep( 3000 ) // Aguarda 3 segundos
	EndIf
End

RPCClearEnv()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SPDFI460470ºAutor ³ Varejo             º Data ³ 08/Set/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Threads IPC para processamento dos registros C460 e C470    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SPED FISCAL                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SPDFI460470( aParams )
Local cEmp			:= aParams[1]
Local cFil			:= aParams[2]
Local cSemaforo := aParams[3]
Local aDadosProc:= {}
Local sDtMovDe  := ""
Local sDtMovAte := ""
Local nPos405   := 0
Local nPosic    := 0
Local sDataAnt 	:= ""
Local aRegC460  := {}
Local aRegC470  := {}
Local aRegC480  := {}
Local nPosC460 	:= 0
Local nPosC470  := 0
Local aAuxRgC405:= {}
Local aItensC470:= {}
Local cQryAlias := GetNextAlias() 				// Alias da Query
Local cQryFields:= ""  							// Campos da Query
Local cOrderBy	:= ""  							// Order By da Query
Local cFiltro		:= ""
Local cQuery 		:= ""
Local cNfC460 	:= ""
Local lOracle 	:= .F.
Local aInfPart 	:= {"","","","",""}
Local cCpfCNPJ  := ""
Local cChvCliAnt:= ""
Local aSetField := {} //Campos da query para efetuar conversao "TcSetField"
Local lCancSft  := .F.
Local nQuantD   := 0
Local nTimeOut 	:= 86400000 //Indica o tempo de time-out em milisegundos para a thread sair do ar (86400000 = 24 horas)
Local cControl 	:= ""
Local nY 				:= 0
Local aWizard 	:= {}
Local cArqTRB 	:= ""
Local cArqAlias	:= ""
Local cPDV 			:= ""
Local cNrLivro 	:= ""
Local cFilB1 		:= ""
Local cFilSA1 	:= ""
Local lConcFil	:= .T.
Local cConfFil 	:= ""
Local cSetIndex := ""
Local nCOORedZ	:= 0
Local aCancSLX	:= {} // Array com os registros de cancelamento na SLX que não estão na SFT
Local nPosCanc 	:= 0

RPCSetType(3) //Nao console licenca
RPCSetEnv( cEmp, cFil,,, "FIS",, {"SFT"} )

aSPDSX2 := SpedLoadX2()
aSPDSX3 := SpedLoadX3()
aSPDSX6 := SpedLoadX6()

While !KillApp()
	// Aguarda trabalho da thread principal
	PtInternal( 1 , 'Thread( ' + cSemaforo + ' ) - SPEDFISCAL )' )	// Imprime no monitor a Identificacao da Thread
	If !IPCWaitEx( cSemaforo, nTimeOut, @cControl, @cEmp, @cFil, @aWizard, @cArqTRB, @cArqAlias, @cPDV, @cNrLivro, @aDadosProc )
		Sleep(1000) // Aguarda 1 segundo
		Loop
	EndIf

	// Se for tipo "0" eh sinal de que acabou o processamento
	If cControl == "0"
		Exit
	EndIf

	sDtMovDe	:= aDadosProc[1][1]
	sDtMovAte	:= aDadosProc[Len(aDadosProc)][1]
	lOracle		:= IIF(AllTrim(Upper(TcGetDb())) $ "ORACLE",.T.,.F.)
	nQuantD		:= Min(TAMSX3("FT_QUANT")[2],3)
	cFilB1		:= cFilAnt
	cFilSA1		:= xFilial("SA1")
	lConcFil	:= aSPDSX6[MV_COFLSPD]
	cConfFil	:= Iif(lConcFil,cFilB1,"")
	lRegCompST  := GerCompST(aWizard,sDtMovDe,sDtMovAte)


	//Abre o arquivo TRB do SPED para gravar informacoes dos registros C460 e C470
	DbUseArea(.F., __LocalDriver, cArqTRB, cArqAlias)

	//Abre SX2 e SX3, soh para garantir que estao abertos, pois em algumas cituacoes essas arquivos eram fechados apos a execucao do DbUseArea acima
	DbSelectArea("SX2")
	DbSelectArea("SX3")

	//-----------------------------------------
	//CAMPOS DA TABELA SFT PARA MONTAR A QUERY
	//-----------------------------------------
	cQryFields := "SFT.FT_SERIE,		SFT.FT_NFISCAL,		SFT.FT_CLIEFOR,		SFT.FT_LOJA,	SFT.FT_ITEM, "
	cQryFields += "SFT.FT_ALIQICM,		SFT.FT_BASEICM, 	SFT.FT_CFOP, 		SFT.FT_CLASFIS,	SFT.FT_DTCANC, "
	cQryFields += "SFT.FT_EMISSAO,		SFT.FT_LOJA, 		SFT.FT_PDV, 		SFT.FT_VALPIS,	SFT.FT_PRODUTO, "
	cQryFields += "SFT.FT_QUANT,		SFT.FT_VALCOF,		SFT.FT_VALCONT,		SFT.FT_ENTRADA AS DTMOVTO, "
	cQryFields += "SFT.FT_TIPO,		SFT.FT_VALFECP,	SFT.FT_ALQFECP, "

	//-----------------------------------------
	//CAMPOS DA TABELA CII PARA MONTAR A QUERY
	//-----------------------------------------
	If lRegCompST
		cQryFields += " CII.CII_ITEM, CII.CII_ENQLEG ,CII.CII_QTDMOV ,CII.CII_UNID 	 ,CII.CII_VUNIT  ,CII.CII_ICMEFS ,CII.CII_VUCRED ,CII.CII_MUBST  ,CII.CII_MUVSTF ,CII.CII_MUVSF  ,CII.CII_VUREST ,CII.CII_VURTFC ,CII.CII_VUCST  ,CII.CII_VUCFC , CII.CII_CFOP,  "
	EndIf

	//-----------------------------------------
	//CAMPOS DA TABELA SD2 PARA MONTAR A QUERY
	//-----------------------------------------
	cQryFields += "SD2.D2_SITTRIB, "

	//-----------------------------------------
	//CAMPOS DA TABELA SB1 PARA MONTAR A QUERY
	//-----------------------------------------
	cQryFields	+=  "SB1.B1_UM, "

	//-----------------------------------------
	//CAMPOS DA TABELA SL1 PARA MONTAR A QUERY
	//-----------------------------------------
	DbSelectArea("SL1")
	If aSPDSX3[FP_L1_CGCCLI]
		cQryFields += " L1_CGCCLI,  "
	Else
		cQryFields += " '" + Space(11) + "' AS L1_CGCCLI,  "
	EndIf

	//-----------------------------------------
	//CAMPOS (Sub-Query) Tabela SLX
	//-----------------------------------------
	cQryFields += " 		(SELECT SUM(LX_QTDE) "
	cQryFields += " 		 FROM  " + RetSQLName("SLX") + " SLX "
	cQryFields += " 		 WHERE 	SLX.LX_FILIAL 	= SFT.FT_FILIAL  AND "
	cQryFields += " 		 		SLX.LX_PDV 		= SFT.FT_PDV 	 AND "
	cQryFields += " 		 		SLX.LX_CUPOM 	= SFT.FT_NFISCAL AND "
	cQryFields += " 		 		SLX.LX_SERIE 	= SFT.FT_SERIE 	 AND "
	cQryFields += " 		 		SLX.LX_DTMOVTO	= SFT.FT_EMISSAO AND "
	cQryFields += " 		 		SLX.LX_PRODUTO  = SFT.FT_PRODUTO AND "
	cQryFields += " 		 		SLX.LX_ITEM		= SFT.FT_ITEM    AND "
	cQryFields += "			    SLX.D_E_L_E_T_ =  ' ' ) AS LX_QTDCANC "

	If cNrLivro <> "*"
		cFiltro := " AND SFT.FT_NRLIVRO = '"+cNrLivro+"'"
	EndIf

	cOrderBy  := " ORDER BY SFT.FT_PDV, SFT.FT_ENTRADA, SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_ITEM"

	aAdd( aSetField, { "FT_EMISSAO", "D" , 8, 0 } )
	aAdd( aSetField, { "FT_DTCANC" , "D" , 8, 0 } )

	If !lOracle
		cQuery := "SELECT DISTINCT " + cQryFields
		cQuery += " FROM "
		cQuery += RetSQLName("SFT") +" SFT "
		cQuery += " JOIN " +RetSQLName("SFI") +" SFI ON (SFI.FI_FILIAL= '"+xFilial("SFI")+"' AND SFI.FI_PDV=SFT.FT_PDV AND SFI.FI_DTMOVTO=SFT.FT_ENTRADA AND SFI.D_E_L_E_T_ = ' ')"
		cQuery += " LEFT JOIN " +RetSQLName("SB1") +" SB1 ON(SB1.B1_FILIAL= '"+xFilial("SB1")+"' AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.D_E_L_E_T_ = ' ')"
		cQuery += " LEFT JOIN " +RetSQLName("SB0") +" SB0 ON(SB0.B0_FILIAL= '"+xFilial("SB0")+"' AND SB0.B0_COD=SFT.FT_PRODUTO AND SB0.D_E_L_E_T_ = ' ')"
		cQuery += " LEFT JOIN " +RetSQLName("SD2") +" SD2 ON(SD2.D2_FILIAL= '"+xFilial("SD2")+"' AND SD2.D2_DOC=SFT.FT_NFISCAL AND SD2.D2_SERIE=SFT.FT_SERIE AND SD2.D2_CLIENTE=SFT.FT_CLIEFOR AND SD2.D2_LOJA=SFT.FT_LOJA AND SD2.D2_COD=SFT.FT_PRODUTO AND SD2.D2_ITEM=SFT.FT_ITEM AND SD2.D2_PDV=SFT.FT_PDV AND SD2.D_E_L_E_T_ = ' ')"
		cQuery += " LEFT JOIN " +RetSQLName("SL1") +" SL1 ON(SL1.L1_FILIAL= '"+xFilial("SL1")+"' AND SL1.L1_DOC=SFT.FT_NFISCAL AND SL1.L1_SERIE=SFT.FT_SERIE AND SL1.L1_CLIENTE=SFT.FT_CLIEFOR AND SL1.L1_LOJA=SFT.FT_LOJA AND SL1.L1_SITUA <> 'FR' AND SL1.D_E_L_E_T_ = ' ')"
		If lRegCompST
			cQuery += " LEFT JOIN "+RetSqlName("CII")+" CII ON( CII.CII_FILIAL= '"+xFilial("CII")+"' AND  CII.CII_TPMOV=SFT.FT_TIPOMOV AND CII.CII_NFISCA=SFT.FT_NFISCAL AND CII.CII_SERIE=SFT.FT_SERIE AND CII.CII_PARTIC=SFT.FT_CLIEFOR AND CII.CII_LOJA=SFT.FT_LOJA AND CII.CII_PRODUT=SFT.FT_PRODUTO AND CII.CII_ITEM=SFT.FT_ITEM AND CII.D_E_L_E_T_='')  "
		EndIf
		cQuery += " WHERE "
		cQuery += " SFT.FT_FILIAL= '"+xFilial("SFT")+"'"
		cQuery += " AND SFT.FT_TIPOMOV = 'S'"
		cQuery += " AND SFT.FT_PDV = '"+cPDV+"'"
		cQuery += " AND (SFT.FT_ESPECIE	= 'CF'	OR SFT.FT_ESPECIE	= 'ECF')"
		cQuery += " AND SFT.FT_ENTRADA >= '"+sDtMovDe+"'"
		cQuery += " AND SFT.FT_ENTRADA <= '"+sDtMovAte+"'"
		cQuery +=  cFiltro
		cQuery += " AND SFT.D_E_L_E_T_ = ' '"
		cQuery += cOrderBy
		cQuery := ChangeQuery( cQuery )
	Else
		//Seta os indices que o Banco obrigatoriamente deve utilizar para executar a query (Comandos especificos do SGBD Oracle (para melhora de performance na execucao da query)
		cSetIndex := ' /*+ '
		cSetIndex += ' INDEX(SFT ' + RetSQLName("SFT") + '2)' //Usa o Indice 2 da tabela SFT
		cSetIndex += ' INDEX(SFI ' + RetSQLName("SFI") + '3)' //Usa o Indice 3 da tabela SFI
		cSetIndex += ' INDEX(SB1 ' + RetSQLName("SB1") + '1)' //Usa o Indice 1 da tabela SB1
		cSetIndex += ' INDEX(SB0 ' + RetSQLName("SB0") + '1)' //Usa o Indice 1 da tabela SB0
		cSetIndex += ' INDEX(SD2 ' + RetSQLName("SD2") + '3)' //Usa o Indice 3 da tabela SD2
		cSetIndex += ' INDEX(SL1 ' + RetSQLName("SL1") + '2)' //Usa o Indice 2 da tabela SL1
		cSetIndex += ' */ '

		cQuery := "SELECT " + cSetIndex + " DISTINCT " + cQryFields
		cQuery += " FROM "
		cQuery += RetSQLName("SFT") + " SFT, "
		cQuery += RetSQLName("SFI") + " SFI, "
		cQuery += RetSQLName("SB1") + " SB1, "
		cQuery += RetSQLName("SB0") + " SB0, "
		cQuery += RetSQLName("SD2") + " SD2, "
		cQuery += RetSQLName("SL1") + " SL1 "
		cQuery += " WHERE "
		cQuery += " SFT.FT_FILIAL         = '"+xFilial("SFT")+"'"
		cQuery += " AND SFT.FT_TIPOMOV    = 'S'"
		cQuery += " AND SFT.FT_PDV        = '"+cPDV+"'"
		cQuery += " AND SFT.FT_ESPECIE    = 'CF'"
		cQuery += " AND SFT.FT_ENTRADA   >= '"+sDtMovDe+"'"
		cQuery += " AND SFT.FT_ENTRADA   <= '"+sDtMovAte+"'"
		cQuery += cFiltro
		cQuery += " AND SFT.D_E_L_E_T_    = ' '"
		cQuery += " AND SFI.FI_FILIAL     = '"+xFilial("SFI")+"'"
		cQuery += " AND SFI.FI_PDV        = SFT.FT_PDV"
		cQuery += " AND SFI.FI_DTMOVTO    = SFT.FT_ENTRADA"
		cQuery += " AND SFI.D_E_L_E_T_    = ' '"
		cQuery += " AND SB1.B1_FILIAL  (+)= '"+xFilial("SB1")+"'"
		cQuery += " AND SB1.B1_COD     (+)= SFT.FT_PRODUTO"
		cQuery += " AND SB1.D_E_L_E_T_ (+)= ' '"
		cQuery += " AND SB0.B0_FILIAL  (+)= '"+xFilial("SB0")+"'"
		cQuery += " AND SB0.B0_COD     (+)= SFT.FT_PRODUTO"
		cQuery += " AND SB0.D_E_L_E_T_ (+)= ' '"
		cQuery += " AND SD2.D2_FILIAL  (+)= '"+xFilial("SD2")+"'"
		cQuery += " AND SD2.D2_DOC     (+)= SFT.FT_NFISCAL"
		cQuery += " AND SD2.D2_SERIE   (+)= SFT.FT_SERIE"
		cQuery += " AND SD2.D2_CLIENTE (+)= SFT.FT_CLIEFOR"
		cQuery += " AND SD2.D2_LOJA    (+)= SFT.FT_LOJA"
		cQuery += " AND SD2.D2_COD     (+)= SFT.FT_PRODUTO"
		cQuery += " AND SD2.D2_ITEM    (+)= SFT.FT_ITEM"
		cQuery += " AND SD2.D2_PDV     (+)= SFT.FT_PDV"
		cQuery += " AND SD2.D_E_L_E_T_ (+)= ' '"
		cQuery += " AND SL1.L1_FILIAL  (+)= '"+xFilial("SL1")+"'"
		cQuery += " AND SL1.L1_DOC     (+)= SFT.FT_NFISCAL"
		cQuery += " AND SL1.L1_SERIE   (+)= SFT.FT_SERIE"
		cQuery += " AND SL1.L1_CLIENTE (+)= SFT.FT_CLIEFOR"
		cQuery += " AND SL1.L1_LOJA    (+)= SFT.FT_LOJA"
		cQuery += " AND SL1.D_E_L_E_T_ (+)= ' '"
		cQuery += " AND (SL1.L1_SITUA <> 'FR' OR SL1.L1_SITUA IS NULL) "
		cQuery += cOrderBy
	EndIf

	DbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cQryAlias, .T., .F. )
	aCancSLX := SPDCancSLX(cPDV, sDtMovDe, sDtMovAte)

	For nY := 1 To Len(aSetField)
		TcSetField(cQryAlias,aSetField[nY,1],aSetField[nY,2],aSetField[nY,3],aSetField[nY,4])
	Next nY

	nPosic    := 0
	cNfC460   := ""
	cCpfCNPJ  := ""
	cChvCliAnt:= ""
	aInfPart  := {"","","","",""}
	aItensC470:= {}
	aRegC460  := {}
	aRegC470  := {}
    aRegC480  := {}
	nPosC460  := 0
	nPosC470  := 0

	While !(cQryAlias)->(EoF())

   		sDataAnt := (cQryAlias)->DTMOVTO
		nPosic++
   		nPos405   := aDadosProc[nPosic][2]
   		aAuxRgC405:= aDadosProc[nPosic][3]
   		nCOORedZ  := Val(aAuxRgC405[1][6])

   		While !(cQryAlias)->(Eof()) .And. sDataAnt == (cQryAlias)->DTMOVTO

   			//Verifica se o numero do cupom pertence a Reducao Z em questao (no caso de haver mais de uma reducao Z no mesmo dia, por causa da intervencao tecnica).
   			//Compara o numero do cupom com o numero do COO da Reducao Z, para considerar corretamente os cupons cujo numero do COOs sejam menores que o COO da Reducao Z.
   			If Val((cQryAlias)->FT_NFISCAL) >= nCOORedZ
   				Exit
   			EndIf

	   		lCancSft := !Empty((cQryAlias)->FT_DTCANC) //Verifica se esta cancelado

			SPDFC460470(@aRegC460	, @aRegC470		, (cQryAlias)->DTMOVTO		, (cQryAlias)->FT_PDV	,;
						nPos405		, aWizard 		, nQuantD 					, cQryAlias   			,;
				        cFilB1	 	, cFilSA1  		, lCancSft					, @nPosC460				,;
				        @cNfC460 	, @aItensC470 	, @nPosC470					, lConcFil 				,;
				        cConfFil 	, @aInfPart		, @cCpfCNPJ					, @cChvCliAnt 			,;
				        (cQryAlias)->FT_NFISCAL, @aRegC480 )

	  		(cQryAlias)->(dbSkip())
		EndDo

		//Trata os Cupons que foram cancelados, antes de finalizar a venda (somente existira registro na SLX)
		nPosCanc := aScan( aCancSLX, { |x| x[1]+x[2] == cPDV + sDataAnt } )
		If nPosCanc > 0
			For nY:= 1 To Len(aCancSLX)
				If aCancSLX[nY][1] + aCancSLX[nY][2] <> cPDV + sDataAnt
					Exit
				EndIf

				//Chama funcao para gerar registro C460 referente ao cupom que foi Cancelado antes da venda
				SPDFC460470(@aRegC460		, @aRegC470		, sDataAnt		, cPDV			,;
							nPos405			, aWizard 		, nQuantD 		, Nil		   	,;
					        cFilB1	 		, cFilSA1  		, .T.			, @nPosC460		,;
					        @cNfC460 		, @aItensC470	, @nPosC470		, lConcFil 		,;
					        cConfFil 		, @aInfPart		, @cCpfCNPJ		, @cChvCliAnt	,;
					        aCancSLX[nY][3] , @aRegC480)
			Next nY
		EndIf

		For nY := 1 to nPosC460
			If (Valtype(aRegC460[nY][8]) == "N" .And. aRegC460[nY][8] == 0) .Or. "2" $ aWizard[1][15]
				aRegC460[nY][8] := ""	//06 - VL_PIS
			EndIf
			If (Valtype(aRegC460[nY][9]) == "N" .And. aRegC460[nY][9] == 0) .Or. "2" $ aWizard[1][15]
				aRegC460[nY][9] := ""	//07 - VL_COFINS
			EndIf
		Next nY

		For nY := 1 to nPosC470
			If (Valtype(aRegC470[nY][11]) == "N" .And. aRegC470[nY][11] == 0) .Or. "2" $ aWizard[1][15]
				aRegC470[nY][11] := "" //10 - VL_PIS
			EndIf
			If (Valtype(aRegC470[nY][12]) == "N" .And. aRegC470[nY][12] == 0) .Or. "2" $ aWizard[1][15]
				aRegC470[nY][12] := ""	//11 - VL_COFINS
			EndIf
		Next nY

		//Descarrega no TRB, os arrays dos registros C460 e C470
		GrRegDep(cArqAlias,aAuxRgC405,aRegC460,.T.,460,Nil,,.F.)
		GrRegDep(cArqAlias,aRegC460  ,aRegC470,.T.,470,.F.,nPos405)
		aRegC460 := {}
		aRegC470 := {}
		aRegC480 := {}
		nPosC460:= 0
		nPosC470:= 0

	EndDo

	(cQryAlias)->( dbCloseArea() ) //Fecha arquivo da query
	(cArqAlias)->( dbCloseArea() ) //Fecha arquivo TRB
	dbSelectArea("SFT")
End

RPCClearEnv()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SPDFCFPrfB³ Autor ³ Vendas e CRM          ³ Data ³27/11/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua carga dos arrays dos registros de ECF (Cupom Fiscal)³±±
±±³          ³                     (PERFIL B)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL (Ambiente TOP)                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPDFCFPrfB(aRegC400	, aRegC405	, aRegC410	, aRegC420	,;
					aRegC425	, aRegC460	, aRegC470	, aRegC490	,;
					aRegC495	, aProdB1	, dDataDe	, dDataAte	,;
					cPerfil		, cAlias	, aReg0200	, aReg0190	,;
					aReg0220	, aReg1600	, aReg0150	, aWizard	,;
					lTop		, cUf		, nQtReg0200, lJob  	,;
					lLegisPer	, cNrLivro	, oSay)

Local 	nPos400			:= 0
Local 	nPos405			:= 0
Local 	aPos420			:= {}
Local 	aTotaliz		:= {}
Local 	nY 					:= 0
Local 	nValCof 		:= 0
Local		nValPis 		:= 0
Local 	cAliqISS  	:= ""
Local 	nAliqIss 		:= 0
Local 	aCmpAliICM 	:= {} 							// Campos de Aliquota de ICMS da tabela SFI
Local 	aCmpAliISS 	:= {} 							// Campos de Aliquota de ISS da tabela SFI
Local 	nVlBrtLj  	:= 0
Local 	nQuantD   	:= Min(TAMSX3("FT_QUANT")[2],3)
Local 	cFilB1			:= cFilAnt
Local 	cQuery 			:= ""
Local 	cQryAlias 	:= GetNextAlias() 				// Alias da Query das Vendas
Local 	cQryAliasR	:= GetNextAlias() 				// Alias da Query da Reducao Z
Local 	cQryFields 	:= ""  							// Campos da Query
Local 	cFieldAliq 	:= ""							// Campos de Aliquota de ICMS
Local 	cGroupBy		:= ""  							// Group By da Query
Local 	cChave  		:= ""
Local 	cPDV 				:= ""
Local 	sDtMovto		:= ""
Local  	aSLX 				:= {}
Local 	lConcFil		:= aSPDSX6[MV_COFLSPD]
Local 	cConfFil 		:= Iif(lConcFil,cFilB1,"")
Local 	cSitTriAnt	:= ""
Local 	nPosPai 		:= 0
Local 	lIsBahia 		:= cUf == "BA"
Local   lGer410			:= !lLegisPer .And. "1"$aWizard[1][15]
Local 	cCupomDe		:= ""
Local 	cCupomAte		:= ""
Local 	nVlrDescto	:= 0
Local 	nVlrCancel	:= 0

//Legenda de ISS
cAliqISS := cValToChar(aSPDSX6[MV_ALIQISS])
cAliqISS := AllTrim( StrTran(cAliqISS, ",", ".") )
cAliqISS := TransForm(cAliqISS, "@E 99.99")
nAliqIss := Val(SubStr(cAliqISS , 1, At(".", cAliqISS)))
cAliqISS := StrTran(cAliqISS, ".")
cAliqISS := AllTrim(cAliqISS)
If nAliqIss >= 10
	cAliqISS := "S" + PadR(cAliqISS, 4, "0")
Else
	cAliqISS := "S0" + PadR(cAliqISS, 3, "0")
EndIf

//Busca os campos das aliquotas de ICMS e ISS.
SPDFRetAli( @aCmpAliICM, @aCmpAliISS )

If !lIsBahia .OR. (lIsBahia .AND. cVersao >= '008')
	//Executa esta funcao separadamente para carregar Registros 0200 (este tratamento foi feito para melhorar a performance do processamento)
	SPDFLj0200( cAlias, dDataDe, dDataAte, @aReg0200, @aReg0190, @aReg0220, @nQtReg0200, cFilB1, lConcFil, "C425", aWizard)
EndIf

//Acrescenta os campos de tributacao de ICMS (Ex: FI_BAS7, FI_BAS12, FI_BAS18...)
For nY:=1 to Len(aCmpAliICM)
	cFieldAliq += "SFI." + aCmpAliICM[nY][1] + ","
	If !Empty(aCmpAliICM[nY][2])
		cFieldAliq += "SFI." + aCmpAliICM[nY][2] + ","
	EndIf
Next nY

//Acrescenta os campos de tributacao de ISS (Ex: FI_BIS0300, FI_BIS0500, FI_BIS0700...)
For nY:=1 to Len(aCmpAliISS)
	cFieldAliq += "SFI." + aCmpAliISS[nY][1] + ","
	If !Empty(aCmpAliISS[nY][2])
		cFieldAliq += "SFI." + aCmpAliISS[nY][2] + ","
	EndIf
Next nY

//Tira a ultima virgula
cFieldAliq := Left(cFieldAliq,Len(cFieldAliq)-1)


//-------------------------------------------------
//CAMPOS PARA MONTAR A QUERY DA REDUÇÃO Z - QUERY 1
//-------------------------------------------------
cQryFields := "SFI.FI_PDV, SFI.FI_DTMOVTO, SFI.FI_DESC,SFI.FI_VALCON,SFI.FI_CRO,SFI.FI_NUMREDZ,SFI.FI_NUMFIM,SFI.FI_NUMINI,SFI.FI_GTFINAL,"
cQryFields += "SFI.FI_ISS,SFI.FI_CANCEL,SFI.FI_SUBTRIB,SFI.FI_ISENTO,SFI.FI_NTRIB,"
cQryFields += "SLG.LG_SERPDV,SLG.LG_IMPFISC,"

If SFI->(FieldPos("FI_CANISS")) > 0
	cQryFields += "SFI.FI_CANISS,"
Else
	cQryFields += "0 AS FI_CANISS,"
EndIf
If SFI->(FieldPos("FI_DESISS")) > 0
	cQryFields += "SFI.FI_DESISS,"
Else
	cQryFields += "0 AS FI_DESISS,"
EndIf

If SFI->(FieldPos("FI_ISSISEN")) > 0
	cQryFields += "SFI.FI_ISSISEN,"
Else
	cQryFields += "0 AS FI_ISSISEN,"
EndIf

If SFI->(FieldPos("FI_ISSNTRI")) > 0
	cQryFields += "SFI.FI_ISSNTRI,"
Else
	cQryFields += "0 AS FI_ISSNTRI,"
EndIf

If SFI->(FieldPos("FI_ISSFTRI")) > 0
	cQryFields += "SFI.FI_ISSFTRI,"
Else
	cQryFields += "0 AS FI_ISSFTRI,"
EndIf

//Acrescenta os campos de tributacao de ICMS (Ex: FI_BAS7, FI_BAS12, FI_BAS18...)
cQryFields := cQryFields + cFieldAliq

cQuery := "SELECT " + cQryFields
cQuery += " FROM " + RetSQLName("SFI") + " SFI, " + RetSQLName("SLG") + " SLG "
cQuery += " WHERE SFI.FI_FILIAL = '"+xFilial("SFI")+"'"
cQuery += " AND SLG.LG_FILIAL = '"+xFilial("SLG")+"'"
cQuery += " AND SLG.LG_PDV = SFI.FI_PDV"
cQuery += " AND SFI.FI_DTMOVTO >= '"+dToS(dDataDe)+"' AND SFI.FI_DTMOVTO <= '"+dToS(dDataAte)+"'"
cQuery += " AND SFI.D_E_L_E_T_ = ' '"
cQuery += " AND SLG.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY SFI.FI_PDV, SFI.FI_DTMOVTO, SFI.FI_NUMREDZ"

cQuery := ChangeQuery( cQuery )
DbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cQryAliasR, .T., .F. )


//-----------------------------------------------
//CAMPOS PARA MONTAR A QUERY DAS VENDAS - QUERY 2
//-----------------------------------------------
cQryFields := " SFT.FT_PDV, SFT.FT_ENTRADA, SD2.D2_SITTRIB, SFT.FT_PRODUTO, SB1.B1_UM,"
cQryFields += " SUM(SFT.FT_QUANT) FT_QUANT, SUM(SFT.FT_VALCONT) FT_VALCONT, SUM(SFT.FT_VALPIS) FT_VALPIS, SUM(SFT.FT_VALCOF) FT_VALCOF,"
cQryFields += " SFI.FI_NUMREDZ, SFI.FI_CRO, SFI.FI_NUMFIM, SFI.FI_GTFINAL, SFI.FI_VALCON, SFI.FI_ISS, SFI.FI_DESC, SFI.FI_CANCEL,"
cQryFields += " SFI.FI_SUBTRIB, SFI.FI_ISENTO, SFI.FI_NTRIB, SLG.LG_IMPFISC, SLG.LG_SERPDV,"

//Acrescenta os campos de tributacao de ICMS (Ex: FI_BAS7, FI_BAS12, FI_BAS18...)
cQryFields := cQryFields + cFieldAliq

cGroupBy  := "SFT.FT_PDV, SFT.FT_ENTRADA, SD2.D2_SITTRIB, SFT.FT_PRODUTO, SB1.B1_UM,"
cGroupBy  += "SFI.FI_NUMREDZ, SFI.FI_CRO, SFI.FI_NUMFIM, SFI.FI_GTFINAL, SFI.FI_VALCON, SFI.FI_ISS, SFI.FI_DESC, SFI.FI_CANCEL,"
cGroupBy  += "SFI.FI_SUBTRIB, SFI.FI_ISENTO, SFI.FI_NTRIB, SLG.LG_IMPFISC, SLG.LG_SERPDV"

If !Empty(cFieldAliq)
	cGroupBy  := cGroupBy + ", " + cFieldAliq
EndIf

cQuery := " SELECT "
cQuery += cQryFields
cQuery += " FROM "
cQuery += RetSQLName("SFT") + " SFT, "
cQuery += RetSQLName("SD2") + " SD2, "
cQuery += RetSQLName("SB1") + " SB1, "
cQuery += RetSQLName("SLG") + " SLG, "
cQuery += RetSQLName("SFI") + " SFI "
cQuery += "	WHERE "
cQuery += " SFT.FT_FILIAL = '"+xFilial("SFT")+"'"
cQuery += " AND SFT.FT_TIPOMOV = 'S'"
cQuery += " AND ( SFT.FT_ESPECIE = 'CF' OR SFT.FT_ESPECIE = 'ECF')"
cQuery += " AND SFT.FT_ENTRADA BETWEEN '" + DToS(dDataDe) + "' AND '" + DToS(dDataAte) + "'"
cQuery += " AND SFT.D_E_L_E_T_ = ' '"
cQuery += " AND SFT.FT_DTCANC = ' '"
cQuery += " AND SD2.D2_FILIAL = '" + xFilial("SD2") + "'"
cQuery += " AND SFT.FT_PDV = SD2.D2_PDV"
cQuery += " AND SFT.FT_SERIE = SD2.D2_SERIE"
cQuery += " AND SFT.FT_NFISCAL = SD2.D2_DOC"
cQuery += " AND SFT.FT_CLIEFOR = SD2.D2_CLIENTE"
cQuery += " AND SFT.FT_LOJA = SD2.D2_LOJA"
cQuery += " AND SD2.D_E_L_E_T_ = ' '"
cQuery += " AND SFT.FT_ITEM = SD2.D2_ITEM"
If !(Alltrim(cNrLivro)) == "*"
	cQuery += " AND SFT.FT_NRLIVRO = '" + Alltrim(cNrLivro) + "' "
EndIf
cQuery += " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
cQuery += " AND SB1.B1_COD = FT_PRODUTO"
cQuery += " AND SB1.D_E_L_E_T_ = ' '"
cQuery += " AND SLG.LG_FILIAL = '" + xFilial("SLG") + "'"
cQuery += " AND SLG.LG_PDV = SFT.FT_PDV"
cQuery += " AND SLG.D_E_L_E_T_ = ' '"
cQuery += " AND SFI.FI_FILIAL = '" + xFilial("SFI") + "'"
cQuery += " AND SFI.FI_PDV = SLG.LG_PDV"
cQuery += " AND SFI.FI_DTMOVTO = FT_ENTRADA"
cQuery += " AND SFI.FI_SERPDV = SLG.LG_SERPDV"
cQuery += " AND SFI.D_E_L_E_T_ = ' '"
cQuery += " AND SFT.FT_NFISCAL >= SFI.FI_NUMINI"
cQuery += " AND SFT.FT_NFISCAL <= SFI.FI_NUMFIM"
cQuery += " GROUP BY " + cGroupBy
cQuery += " ORDER BY SFT.FT_PDV, SFT.FT_ENTRADA,FI_NUMREDZ, SD2.D2_SITTRIB"

cQuery := ChangeQuery( cQuery )
DbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cQryAlias, .T., .F. )

//----------------------------
// Processa Registros.
//----------------------------
Do While !(cQryAliasR)->(Eof())

    cPDV :=  (cQryAliasR)->FI_PDV

    If !lJob
		oSay:cCaption := ("Processando Cupom Fiscal - PDV " + AllTrim(cPDV))
		ProcessMessages()
    EndIf

	RegC400 (@aRegC400, (cQryAliasR)->LG_IMPFISC, (cQryAliasR)->LG_SERPDV, AllTrim((cQryAliasR)->FI_PDV), @nPos400)

	//-------------------------------------------
	// Laco por Reducao Z - Por data do Movimento
	//-------------------------------------------
	While !(cQryAliasR)->(Eof()) .AND. cPDV==(cQryAliasR)->FI_PDV

		sDtMovto 	:= (cQryAliasR)->FI_DTMOVTO
		cChave 		:= cPDV + (cQryAliasR)->FI_DTMOVTO + (cQryAliasR)->FI_NUMREDZ
		cCupomDe	:= (cQryAliasR)->FI_NUMINI //Numero do Proximo Cupom Emitido apos a Reducao Z anterior
		cCupomAte	:= (cQryAliasR)->FI_NUMFIM //Numero do ultimo Cupom Emitido antes da Reducao Z

		nVlBrtLj 		:= (cQryAliasR)->FI_VALCON 	+ (cQryAliasR)->FI_ISS 		// Valor Bruto = FI_VALCON (Valor contabil) + FI_ISS (Valor de Servicos)
		nVlrDescto	:= (cQryAliasR)->FI_DESC 	+ (cQryAliasR)->FI_DESISS 	// Valor Total Descontos = FI_DESC (Valores de Descontos de ICMS) + FI_DESISS (Valores de Descontos de ISS)
		nVlrCancel	:= (cQryAliasR)->FI_CANCEL 	+ (cQryAliasR)->FI_CANISS 	// Valor Total Cancelamentos = FI_CANCEL (Valores de Cancelamentos de ICMS) + FI_CANISS (Valores de Cancelamentos de ISS)

		RegC405 (@aRegC405				, nPos400					, SToD((cQryAliasR)->FI_DTMOVTO)	, (cQryAliasR)->FI_CRO	, ;
				(cQryAliasR)->FI_NUMREDZ, (cQryAliasR)->FI_NUMFIM	, (cQryAliasR)->FI_GTFINAL			, nVlBrtLj   			, ;
				@nPos405				, nVlrDescto			  	, nVlrCancel )

		//Reinicia variaveis
		nValCof 		:= 0
		nValPis 		:= 0
		cSitTriAnt	:= ""

		//--------------------------------------------------------------------
		//Carrego todos os codigos e valores que foram contabilizados no SFI
		//--------------------------------------------------------------------
		aTotaliz 	:= SPDFTotSFI(.T., cAliqISS, cQryAliasR, aCmpAliICM, Nil, aCmpAliISS)

		RegC420 (@aRegC420, 	nPos405,   	(cQryAliasR)->FI_CRO, 		(cQryAliasR)->FI_NUMREDZ,;
				 aTotaliz,		@aPos420)

		//----------------------
		// Laco por Reducao Z
		//----------------------
		While !(cQryAlias)->(Eof())  .AND.  cChave == (cQryAlias)->FT_PDV+(cQryAlias)->FT_ENTRADA +(cQryAlias)->FI_NUMREDZ

			If !lIsBahia .Or. (lIsBahia .AND. cVersao >= '008')

				If (cQryAlias)->D2_SITTRIB <> cSitTriAnt
					cSitTriAnt 	:= (cQryAlias)->D2_SITTRIB
				   	nPosPai 	:= Ascan(aPos420,{|x| AllTrim(x[2]) == AllTrim((cQryAlias)->D2_SITTRIB) })
				   	If nPosPai == 0
				   		cSitTriAnt := ""
					   	(cQryAlias)->(dbSkip())
					   	Loop
				   	EndIf
				EndIf

				SPDFRgC425 (@aRegC425	, (cQryAlias)->FT_ENTRADA	, (cQryAlias)->FT_PDV	, aPos420	,;
							aWizard 	, nQuantD					, cConfFil 				, cQryAlias ,;
							cSitTriAnt	, nPosPai )
			EndIf

	  		(cQryAlias)->(dbSkip())
		EndDo

		SPDFRgC490 (@aRegC490	, sDtMovto	, nPos405  	,;
					cPDV		, @aProdB1	, nPos405	,;
					@aReg0200	, @aReg0190 , @aReg0220	,;
					@nValCof	, @nValPis	, cCupomDe 	, cCupomAte)

		If lGer410 // Depois de ter os valores de PIS e COFINS gera o C410
			RegC410 (  @aRegC410	   	, nPos405 	, nValCof 	, nValPis  ,;
					   Nil 				, Nil 		, lTop )
		EndIf

		(cQryAliasR)->(dbSkip())
	EndDo

	If lIsBahia .AND. cVersao < '008' //Alterado conforme solicitação do Roberto (roberto.bernardino)
		//O Registro C495 somente deve ser gerado, caso tenha gerado tambem o Registro C400
		RegC495 (@aRegC495	, @aProdB1			, nPos400	, dDataDe	,;
				 dDataAte	, AllTrim(cPDV)		, @aReg0200	, cAlias 	,;
				 @aReg0190 	, @aReg0220 		, @aSLX 	, cFilB1)
	EndIf

EndDo

DbSelectArea(cQryAliasR)
(cQryAliasR)->(DbCloseArea())
DbSelectArea(cQryAlias)
(cQryAlias)->(DbCloseArea())

If "1"$aWizard[4][7]//Verifica se deve gerar registro 1600
	SPDFGr1600(@aReg1600,@aReg0150,dDataDe,dDataAte,cAlias,aWizard,Nil,lConcFil)
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SPDFCFPrfC³ Autor ³ Vendas e CRM          ³ Data ³27/11/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua carga dos arrays dos registros de ECF (Cupom Fiscal)³±±
±±³          ³                     (PERFIL C)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL (Ambiente TOP)                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPDFCFPrfC(aRegC400	, aRegC405	, aRegC410	, aRegC420	,;
					aRegC425	, aRegC460	, aRegC470	, aRegC490	,;
					aRegC495	, aProdB1	, dDataDe	, dDataAte	,;
					cPerfil		, cAlias	, aReg0200	, aReg0190	,;
					aReg0220	, aReg1600	, aReg0150	, aWizard	,;
					lTop		, cUf		, nQtReg0200, lJob  	,;
					lLegisPer	, cNrLivro	, oSay)

Local 	nPos400			:= 0
Local 	nPos405			:= 0
Local 	aPos420			:= {}
Local 	aTotaliz		:= {}
Local 	nY 					:= 0
Local 	nValCof 		:= 0
Local		nValPis 		:= 0
Local 	cAliqISS  	:= ""
Local 	nAliqIss   	:= 0
Local 	aCmpAliICM 	:= {} 							// Campos de Aliquota de ICMS da tabela SFI
Local 	aCmpAliISS 	:= {} 							// Campos de Aliquota de ISS da tabela SFI
Local 	nVlBrtLj  	:= 0
Local 	cQuery 			:= ""
Local 	cQryAlias 	:= GetNextAlias() 				// Alias da Query de Vendas
Local 	cQryAliasR 	:= GetNextAlias() 				// Alias da Query da Redução Z
Local 	cQryFields 	:= ""  							// Campos da Query
Local 	cFieldAliq 	:= ""							// Campos de Aliquota de ICMS
Local 	cGroupBy		:= ""  							// Group By da Query
Local 	cPDV 				:= ""
Local 	sDtMovto		:= ""
Local 	lConcFil		:= aSPDSX6[MV_COFLSPD]
Local 	cCupomDe		:= ""
Local 	cCupomAte		:= ""
Local 	nVlrDescto	:= 0
Local 	nVlrCancel	:= 0

//Legenda de ISS
cAliqISS := cValToChar(aSPDSX6[MV_ALIQISS])
cAliqISS := AllTrim( StrTran(cAliqISS, ",", ".") )
cAliqISS := TransForm(cAliqISS, "@E 99.99")
nAliqIss := Val(SubStr(cAliqISS , 1, At(".", cAliqISS)))
cAliqISS := StrTran(cAliqISS, ".")
cAliqISS := AllTrim(cAliqISS)
If nAliqIss >= 10
	cAliqISS := "S" + PadR(cAliqISS, 4, "0")
Else
	cAliqISS := "S0" + PadR(cAliqISS, 3, "0")
EndIf

//Busca os campos das aliquotas de ICMS e ISS.
SPDFRetAli( @aCmpAliICM, @aCmpAliISS )

//Acrescenta os campos de tributacao de ICMS (Ex: FI_BAS7, FI_BAS12, FI_BAS18...)
For nY:=1 to Len(aCmpAliICM)
	cFieldAliq += "SFI." + aCmpAliICM[nY][1] + ","
	If !Empty(aCmpAliICM[nY][2])
		cFieldAliq += "SFI." + aCmpAliICM[nY][2] + ","
	EndIf
Next nY

//Acrescenta os campos de tributacao de ISS (Ex: FI_BIS0300, FI_BIS0500, FI_BIS0700...)
For nY:=1 to Len(aCmpAliISS)
	cFieldAliq += "SFI." + aCmpAliISS[nY][1] + ","
	If !Empty(aCmpAliISS[nY][2])
		cFieldAliq += "SFI." + aCmpAliISS[nY][2] + ","
	EndIf
Next nY

//Tira a ultima virgula
cFieldAliq := Left(cFieldAliq,Len(cFieldAliq)-1)

//-------------------------------------------------
//CAMPOS PARA MONTAR A QUERY DA REDUÇÃO Z - QUERY 1
//-------------------------------------------------
cQryFields := "SFI.FI_PDV, SFI.FI_DTMOVTO, SFI.FI_DESC,SFI.FI_VALCON,SFI.FI_CRO,SFI.FI_NUMREDZ,SFI.FI_NUMFIM,SFI.FI_NUMINI,SFI.FI_GTFINAL,"
cQryFields += "SFI.FI_ISS,SFI.FI_CANCEL,SFI.FI_SUBTRIB,SFI.FI_ISENTO,SFI.FI_NTRIB,"
cQryFields += "SLG.LG_SERPDV,SLG.LG_IMPFISC,"

If SFI->(FieldPos("FI_CANISS")) > 0
	cQryFields += "SFI.FI_CANISS,"
Else
	cQryFields += "0 AS FI_CANISS,"
EndIf
If SFI->(FieldPos("FI_DESISS")) > 0
	cQryFields += "SFI.FI_DESISS,"
Else
	cQryFields += "0 AS FI_DESISS,"
EndIf
If SFI->(FieldPos("FI_ISSISEN")) > 0
	cQryFields += "SFI.FI_ISSISEN,"
Else
	cQryFields += "0 AS FI_ISSISEN,"
EndIf

If SFI->(FieldPos("FI_ISSNTRI")) > 0
	cQryFields += "SFI.FI_ISSNTRI,"
Else
	cQryFields += "0 AS FI_ISSNTRI,"
EndIf

If SFI->(FieldPos("FI_ISSFTRI")) > 0
	cQryFields += "SFI.FI_ISSFTRI,"
Else
	cQryFields += "0 AS FI_ISSFTRI,"
EndIf

//Acrescenta os campos de tributacao de ICMS (Ex: FI_BAS7, FI_BAS12, FI_BAS18...)
cQryFields := cQryFields + cFieldAliq

cQuery := "SELECT " + cQryFields
cQuery += " FROM " + RetSQLName("SFI") + " SFI, " + RetSQLName("SLG") + " SLG "
cQuery += " WHERE SFI.FI_FILIAL = '"+xFilial("SFI")+"'"
cQuery += " AND SLG.LG_FILIAL = '"+xFilial("SLG")+"'"
cQuery += " AND SLG.LG_PDV = SFI.FI_PDV"
cQuery += " AND SFI.FI_DTMOVTO >= '"+dToS(dDataDe)+"' AND SFI.FI_DTMOVTO <= '"+dToS(dDataAte)+"'"
cQuery += " AND SFI.D_E_L_E_T_ = ' '"
cQuery += " AND SLG.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY SFI.FI_PDV, SFI.FI_DTMOVTO, SFI.FI_NUMREDZ"

cQuery := ChangeQuery( cQuery )
DbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cQryAliasR, .T., .F. )

//----------------------------
//CAMPOS PARA MONTAR A QUERY
//----------------------------
cQryFields := " SFT.FT_PDV, SFT.FT_ENTRADA,"
cQryFields += " SUM(SFT.FT_QUANT) FT_QUANT, SUM(SFT.FT_VALCONT) FT_VALCONT, SUM(SFT.FT_VALPIS) FT_VALPIS, SUM(SFT.FT_VALCOF) FT_VALCOF,"
cQryFields += " SFI.FI_NUMREDZ, SFI.FI_CRO, SFI.FI_NUMFIM, SFI.FI_GTFINAL, SFI.FI_VALCON, SFI.FI_ISS, SFI.FI_DESC, SFI.FI_CANCEL,"
cQryFields += " SFI.FI_SUBTRIB, SFI.FI_ISENTO, SFI.FI_NTRIB, SLG.LG_IMPFISC, SLG.LG_SERPDV,"


cQryFields := cQryFields + cFieldAliq

cGroupBy  := "SFT.FT_PDV, SFT.FT_ENTRADA,"
cGroupBy  += "SFI.FI_NUMREDZ, SFI.FI_CRO, SFI.FI_NUMFIM, SFI.FI_GTFINAL, SFI.FI_VALCON, SFI.FI_ISS, SFI.FI_DESC, SFI.FI_CANCEL,"
cGroupBy  += "SFI.FI_SUBTRIB, SFI.FI_ISENTO, SFI.FI_NTRIB, SLG.LG_IMPFISC, SLG.LG_SERPDV"

If !Empty(cFieldAliq)
	cGroupBy  := cGroupBy + ", " + cFieldAliq
EndIf

cQuery := " SELECT "
cQuery += cQryFields
cQuery += " FROM "
cQuery += RetSQLName("SFT") + " SFT, "
cQuery += RetSQLName("SLG") + " SLG, "
cQuery += RetSQLName("SFI") + " SFI "
cQuery += "	WHERE "
cQuery += " SFT.FT_FILIAL = '"+xFilial("SFT")+"'"
cQuery += " AND SFT.FT_TIPOMOV = 'S'"
cQuery += " AND ( SFT.FT_ESPECIE = 'CF' OR SFT.FT_ESPECIE = 'ECF')"
cQuery += " AND SFT.FT_ENTRADA BETWEEN '" + DToS(dDataDe) + "' AND '" + DToS(dDataAte) + "'"
cQuery += " AND SFT.D_E_L_E_T_ = ' '"
cQuery += " AND SFT.FT_DTCANC = ' '"
If !(Alltrim(cNrLivro) == "*")
	cQuery += " AND SFT.FT_NRLIVRO = '" + Alltrim(cNrLivro) + "' "
EndIf
cQuery += " AND SLG.LG_FILIAL = '" + xFilial("SLG") + "'"
cQuery += " AND SLG.LG_PDV = SFT.FT_PDV"
cQuery += " AND SLG.D_E_L_E_T_ = ' '"
cQuery += " AND SFI.FI_FILIAL = '" + xFilial("SFI") + "'"
cQuery += " AND SFI.FI_PDV = SLG.LG_PDV"
cQuery += " AND SFI.FI_DTMOVTO = FT_ENTRADA"
cQuery += " AND SFI.FI_SERPDV = SLG.LG_SERPDV"
cQuery += " AND SFI.D_E_L_E_T_ = ' '"
cQuery += " AND SFT.FT_NFISCAL >= SFI.FI_NUMINI"
cQuery += " AND SFT.FT_NFISCAL <= SFI.FI_NUMFIM"
cQuery += " GROUP BY " + cGroupBy
cQuery += " ORDER BY SFT.FT_PDV, SFT.FT_ENTRADA,SFI.FI_NUMREDZ"

cQuery := ChangeQuery( cQuery )
DbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cQryAlias, .T., .F. )

//----------------------------
// Processa Registros.
//----------------------------
Do While !(cQryAliasR)->(Eof())

    cPDV :=  (cQryAliasR)->FI_PDV

    If !lJob
		oSay:cCaption := ("Processando Cupom Fiscal - PDV " + AllTrim(cPDV))
		ProcessMessages()
    EndIf

	RegC400 (@aRegC400, (cQryAliasR)->LG_IMPFISC, (cQryAliasR)->LG_SERPDV, AllTrim((cQryAliasR)->FI_PDV), @nPos400)

	//-------------------------------------------
	// Laco por Reducao Z - Por data do Movimento
	//-------------------------------------------
	While !(cQryAliasR)->(Eof()) .AND. cPDV==(cQryAliasR)->FI_PDV

		sDtMovto 	:= (cQryAliasR)->FI_DTMOVTO
		cCupomDe	:= (cQryAliasR)->FI_NUMINI //Numero do Proximo Cupom Emitido apos a Reducao Z anterior
		cCupomAte	:= (cQryAliasR)->FI_NUMFIM //Numero do ultimo Cupom Emitido antes da Reducao Z

		nVlBrtLj 		:= (cQryAliasR)->FI_VALCON 	+ (cQryAliasR)->FI_ISS 		// Valor Bruto = FI_VALCON (Valor contabil) + FI_ISS (Valor de Servicos)
		nVlrDescto	:= (cQryAliasR)->FI_DESC 	+ (cQryAliasR)->FI_DESISS 	// Valor Total Descontos = FI_DESC (Valores de Descontos de ICMS) + FI_DESISS (Valores de Descontos de ISS)
		nVlrCancel	:= (cQryAliasR)->FI_CANCEL 	+ (cQryAliasR)->FI_CANISS 	// Valor Total Cancelamentos = FI_CANCEL (Valores de Cancelamentos de ICMS) + FI_CANISS (Valores de Cancelamentos de ISS)

		RegC405 (@aRegC405				, nPos400					, SToD((cQryAliasR)->FI_DTMOVTO), (cQryAliasR)->FI_CRO	, ;
				(cQryAliasR)->FI_NUMREDZ, (cQryAliasR)->FI_NUMFIM	, (cQryAliasR)->FI_GTFINAL		, nVlBrtLj   			, ;
				@nPos405				, nVlrDescto  				, nVlrCancel )

		//Reinicia variaveis
		nValCof 	:= 0
		nValPis 	:= 0

		//--------------------------------------------------------------------
		//Carrego todos os codigos e valores que foram contabilizados no SFI
		//--------------------------------------------------------------------
		aTotaliz := SPDFTotSFI(.T., cAliqISS, cQryAliasR, aCmpAliICM, Nil, aCmpAliISS)

		RegC420 (@aRegC420, 	nPos405,   	(cQryAliasR)->FI_CRO, 		(cQryAliasR)->FI_NUMREDZ,;
				 aTotaliz,		@aPos420)

		SPDFRgC490 (@aRegC490	, sDtMovto	, nPos405	, cPDV		,;
					@aProdB1	, nPos405	, @aReg0200	, @aReg0190	,;
					@aReg0220 	, @nValCof	, @nValPis	, cCupomDe	, cCupomAte)

		(cQryAliasR)->(DbSkip())
	EndDo
	(cQryAliasR)->(dbSkip())
EndDo
DbSelectArea(cQryAliasR)
(cQryAliasR)->(DbCloseArea())
DbSelectArea(cQryAlias)
(cQryAlias)->(DbCloseArea())

If "1"$aWizard[4][7]//Verifica se deve gerar registro 1600
	SPDFGr1600(@aReg1600,@aReg0150,dDataDe,dDataAte,cAlias,aWizard,Nil,lConcFil)
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SPDFCFSldCred³ Autor ³ Vendas e CRM       ³ Data ³02/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao auxiliar utilizada pelo SPEDPISCOF, trata saldo de  ³±±
±±³          ³ credito negativo.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDPISCOF                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPDFCFSldCred(nSldCred)
nSldCred := IIf( nSldCred < 0, 0, nSldCred )
Return nSldCred

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SPDFRetAli³ Autor ³ Varejo                ³ Data ³30/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os campos das aliquotas de ICMS e ISS.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPEDFISCAL                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPDFRetAli( aCmpAliICM, aCmpAliISS )
Local cCampo		:= "" // Utilizada para armazenar o campo
Local cLegTrib	:= "T"// Legenda de Tributado
Local cCodAliq	:= "" // Codigo dos totalizadores das aliquotas
Local cCampoCod	:= "" // Utilizada para armazenar o campo referente ao código da aliquota( Utilizado para validação do PAF-ECF )

aCmpAliICM := {}
aCmpAliISS := {}

//--------------------------------------------------------
// Verifica todos os tipos de aliquotas de ICMS existentes
//--------------------------------------------------------
DbSelectArea("SX3")
SX3->( DbSetOrder(2) )
SX3->( DbSeek("FI_BAS", .T.) )
Do While !SX3->(Eof()) .AND. SubStr(SX3->X3_CAMPO,1,6) == "FI_BAS"
	cCampo := AllTrim(SX3->X3_CAMPO)
	//Monta a legenda da tributacao
	If Len(AllTrim(cCampo)) == 7 .OR. Len(AllTrim(cCampo)) == 9
		cLegTrib	:= "T0"	// Acrescenta um zero para entrar no padrao do arquivo
	Else
		cLegTrib	:= "T"
	EndIf
	cCodAliq := Subs(cLegTrib + PadR(AllTrim(StrTran(Subs(cCampo,7,Len(cCampo)) , ",", ".")) , 4 ,"0" ),0,5)
    cCampoCod	:= "FI_COD" + Substr( cCampo, 7, Len(cCampo)-6)

    If !(SFI->(FieldPos(cCampoCod)) > 0)
		cCampoCod := ""
    EndIf
    aAdd( aCmpAliICM, { cCampo, cCampoCod, cCodAliq } )
	SX3->(dbSkip())
Enddo

//--------------------------------------------------------
// Verifica todos os tipos de aliquotas de ISS existentes
//--------------------------------------------------------
DbSelectArea("SX3")
SX3->( DbSetOrder(2) )
SX3->( DbSeek("FI_BIS", .T.) )
Do While !SX3->(Eof()) .AND. SubStr(SX3->X3_CAMPO,1,6) == "FI_BIS"
	cCampo 			:= SX3->X3_CAMPO
	cCodAliq 		:= Subs(cCampo,6,Len(cCampo))
    cCampoCod	:= "FI_ICOD" + AllTrim(Str(Val(substr(cCampo,7,Len(cCampo)))/100))

    If !(SFI->(FieldPos(cCampoCod)) > 0)
		cCampoCod := ""
    EndIf
    aAdd( aCmpAliISS, { cCampo, cCampoCod, cCodAliq } )

	SX3->(dbSkip())
Enddo

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SpedNatOper
Funcao responsavel por retornar o codigo e a descricao da natureza da operacao/prestacao configuradas no ambiente. Existem varias formas de
obter essas informacoes, entre elas: Tabela CD1, campo F4_TEXTO ou tabela SX5.
Utilizado pelas rotinas do SPED: SPEDFISCAL, NFESEFAZ...

@param	lNatOpCD1	-	Indica a utilizacao da tabela CD1 ( a tabela e o campo FT_NATOPER existem e a CD1 esta posicionada no registro correto )
						default: verifica utilizando aliasInDic e fieldPos; posiciona a tabela CD1 utilizando o cAliasSFT.
@param	lSpedNat	-	Conteudo do parametro MV_SPEDNAT. default .F.
@param	cAliasSFT	-	Alias da tabela SFT. default "SFT"
@param	cAliasSFT	-	Alias da tabela SF4. default "SF4"
@param	lSeekSF4	-	Indica que a tabela SF4 esta posicionada e podera utilizar as informacoes dessa tabela no retorno se necessario. default .F.

@return	aNatOper	-	Array com duas informacoes: 1 - Codigo da natureza da operacao/prestacao ; 2 - Descricao da natureza da operacao/prestacao

@author Luccas Curcio
@since 02/09/2014
@version 11.8 / 12
/*/
//-------------------------------------------------------------------
function SpedNatOper( lNatOpCD1 , lSpedNat , cAliasSFT , cAliasSF4 , lSeekSF4 )

local aNatOper	:=	{ "" , "" }

default cAliasSFT	:= "SFT"
default cAliasSF4	:= "SF4"
default lNatOpCD1	:= aSPDSX2[AI_CD1] .And. SpedSeek( "CD1" , , xFilial( "CD1" ) + ( cAliasSFT )->FT_NATOPER )
default lSpedNat	:= aSPDSX6[MV_SPEDNAT]
default lSeekSF4	:= .F.

If IsInCallStack('SPEDFISCAL')
	//utiliza a tabela CD1
	If lNatOpCD1
		aNatOper[ 1 ]	:=	( cAliasSFT )->FT_NATOPER
		aNatOper[ 2 ]	:=	AllTrim( CD1->CD1_DESCR )

	//Se encontrar TES e MV_SPEDNAT = F
	ElseIf !lSpedNat .And. lSeekSF4
		aNatOper[ 1 ]	:=	allTrim( ( cAliasSF4 )->F4_CODIGO )
		aNatOper[ 2 ]	:=	allTrim( ( cAliasSF4 )->F4_TEXTO )

	//MV_SPEDNAT = T
	ElseIf SX5->( MsSeek( xFilial( "SX5" ) + "13" + ( cAliasSFT )->FT_CFOP ) )
		aNatOper[ 1 ]	:=	( cAliasSFT )->FT_CFOP
		aNatOper[ 2 ]	:=	allTrim( SX5->X5_DESCRI )
	EndIf
Else
	//Se encontrar TES e MV_SPEDNAT = F
	If !lSpedNat .And. lSeekSF4
		aNatOper[ 1 ]	:=	allTrim( ( cAliasSF4 )->F4_CODIGO )
		aNatOper[ 2 ]	:=	allTrim( ( cAliasSF4 )->F4_TEXTO )

	//MV_SPEDNAT = T
	ElseIf SX5->( MsSeek( xFilial( "SX5" ) + "13" + ( cAliasSFT )->FT_CFOP ) )
		aNatOper[ 1 ]	:=	( cAliasSFT )->FT_CFOP
		aNatOper[ 2 ]	:=	allTrim( SX5->X5_DESCRI )
	EndIf
EndIf
return aNatOper

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SPDFRetPEs³ Autor ³ Totvs                 ³ Data ³08/08/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna array c/ informacoes de Pontos de Entrada existente³±±
±±³          ³ no ambiente.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SPEDFISCAL			                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPDFRetPEs()
Return aExistBloc

Function BlocoK(cAlias,bWhileSM0,aWizard,cFilDe,cFilAte,aLisFil,aReg0150,aReg0200,aReg0220,aReg0190,aReg0150,lConcFil,aReg0210,oProcess,lK200280)

Local aPartDoc  := {}
Local dDataDe   := SToD(aWizard[1][1])
Local dDataAte  := SToD(aWizard[1][2])
Local cAli0200  := GetNextAlias()
Local cAli0210  := GetNextAlias()
Local cAliK001  := GetNextAlias()
Local cAliK100  := GetNextAlias()
Local cAliK200  := GetNextAlias()
Local cAliK210  := GetNextAlias()
Local cAliK215  := GetNextAlias()
Local cAliK220  := GetNextAlias()
Local cAliK230  := GetNextAlias()
Local cAliK235  := GetNextAlias()
Local cAliK250  := GetNextAlias()
Local cAliK255  := GetNextAlias()
Local cAliK260  := GetNextAlias()
Local cAliK265  := GetNextAlias()
Local cAliK270  := GetNextAlias()
Local cAliK275  := GetNextAlias()
Local cAliK280  := GetNextAlias()
Local cAliK290  := GetNextAlias()
Local cAliK291  := GetNextAlias()
Local cAliK292  := GetNextAlias()
Local cAliK300  := GetNextAlias()
Local cAliK301  := GetNextAlias()
Local cAliK302  := GetNextAlias()
Local cAliK990  := GetNextAlias()
Local nPos      := 0
Local aAlias    := {cAli0210,cAliK001,cAliK100,cAliK200,cAliK210,cAliK215,cAliK220,cAliK230,;
                    cAliK235,cAliK250,cAliK255,cAliK260,cAliK265,cAliK270,cAliK275,cAliK280,;
					cAliK290,cAliK291,cAliK292,cAliK300,cAliK301,cAliK302,cAliK990, cAli0200}
Local aAliProc  := ARRAY(24)
Local aRegK100  := {}
Local aRegK200  := {}
Local aRegK210  := {}
Local aRegK215  := {}
Local aRegK220  := {}
Local aRegK230  := {}
Local aRegK235  := {}
Local aRegK250  := {}
Local aRegK255  := {}
Local aRegK260  := {}
Local aRegK265  := {}
Local aRegK270  := {}
Local aRegK275  := {}
Local aRegK280  := {}
Local aRegK290  := {}
Local aRegK291  := {}
Local aRegK292  := {}
Local aRegK300  := {}
Local aRegK301  := {}
Local aRegK302  := {}
Local aProd		:= Nil //Função SFRG0200 já existe tratamento para default dessa variavel.
Local cProd		:= ""
Local cCodPart	:= ""
Local nRelac	:= ""
Local nPosK235	:= 0
Local nPosK255	:= 0
Local lGera0210	:= aWizard[1][27]=="1-Sim"
Local aAreaSM0	:= SM0->(GetArea())
Local cAliasSB1	:= "SB1"
Local aRetPeBLCK:= {}
Local nX        := 0
Local lGera     := cVersao >= '011'
Local lGeraV013 := cVersao >= '013'
Local lSPDFIS02	:= aExistBloc[01]
Local cUnid			:= ""
Local nQtde			:= 0
Local nFatorPE	:= 0
Local cTpCv			:= ''
Local lBlkApg   := FindFunction("BlkApgArq")
Local nQtdeDez	:= Iif(cVersao <= '012', 3, 6)
Local lRepross  := aWizard[1][22]=="1-Sim"
Local cNew     	:=	"HMNew()"
Local lKill0210	:= .F.
Local lKill0200	:= .F.
Local nPos0210	:= 0

Local cChave			:= ""

DEFAULT lConcFil	:= .T.
DEFAULT aReg0210	:= {}

aAdd(aRegK100, {})
nPos := Len(aRegK100)
aAdd(aRegK100[nPos], 'K100')		//01 - REG
aAdd(aRegK100[nPos], dDataDe)		//02 - DT_INI
aAdd(aRegK100[nPos], dDataAte)		//03 - DT_FIN
GrvRegTrS (cAlias,,aRegK100)

DbSelectArea("SM0")
SM0->(DbGoTop())
SM0->(MsSeek(cEmpAnt+cFilDe, .T.))	//Pego a filial mais proxima
While Eval(bWhileSM0)

	cFilAnt := FWGETCODFILIAL

	If Len(aLisFil)>0 .And. cFilAnt <= cFilAte
		nFilial := Ascan(aLisFil,{|x|x[2]==cFilAnt})
		If nFilial==0 .Or. !(aLisFil[nFilial,1])  /*Filial não marcada, vai para proxima*/
			SM0->(dbSkip())
			Loop
		EndIf
	EndIf

	aSPDSX6 := SpedLoadX6()

  aRegK200 := {}
  aRegK210 := {}
  aRegK215 := {}
  aRegK220 := {}
  aRegK230 := {}
  aRegK235 := {}
  aRegK250 := {}
  aRegK255 := {}
  aRegK260 := {}
  aRegK265 := {}
  aRegK270 := {}
  aRegK275 := {}
  aRegK280 := {}
	aRegK290 := {}
	aRegK291 := {}
	aRegK292 := {}
	aRegK300 := {}
	aRegK301 := {}
	aRegK302 := {}

	aRetPeBLCK := {}
	If aExistBloc[24] //Verifica existencia do ponto de entrada para geração do bloco K

		//Irá excutar o ponto de entrada SPDFISBLCK, onde através deste ponto os arquivo DBF serão criados e alimentados
		//pelo usuário para geração do bloco K
		aRetPeBLCK := ExecBlock("SPDFISBLCK", .F., .F., {dDataDe,dDataAte})
		IF ( cVersao <= "012" .and. Len(aRetPeBLCK) >= 14) .or. ( cVersao >= "013" .and. Len(aRetPeBLCK) >= 20)
            aAlias[0210] := aRetPeBLCK[1]
            aAlias[K200] := aRetPeBLCK[2]
            aAlias[K220] := aRetPeBLCK[3]
            aAlias[K230] := aRetPeBLCK[4]
            aAlias[K235] := aRetPeBLCK[5]
            aAlias[K250] := aRetPeBLCK[6]
            aAlias[K255] := aRetPeBLCK[7]
            aAlias[K210] := aRetPeBLCK[8]
            aAlias[K215] := aRetPeBLCK[9]
            aAlias[K260] := aRetPeBLCK[10]
            aAlias[K265] := aRetPeBLCK[11]
            aAlias[K270] := aRetPeBLCK[12]
            aAlias[K275] := aRetPeBLCK[13]
            aAlias[K280] := aRetPeBLCK[14]

			If cVersao >= "013"
				aAlias[K290] := aRetPeBLCK[15]
				aAlias[K291] := aRetPeBLCK[16]
				aAlias[K292] := aRetPeBLCK[17]
				aAlias[K300] := aRetPeBLCK[18]
				aAlias[K301] := aRetPeBLCK[19]
				aAlias[K302] := aRetPeBLCK[20]
			Endif
		EndIf
	EndIf
	If ( cVersao <= "012" .and. Len(aRetPeBLCK) < 14) .or. ( cVersao >= "013" .and. Len(aRetPeBLCK) < 20) //Se não existir o ponto de entrada ou se não retornou nada então a rotina irá buscar as informações através do padrão.
		//Se gerar somente K200 e k280
		If lK200280
			AFill(aAliProc,.F.)
			aAliProc[K200] := .T.
			aAliProc[K280] := .T.
		Else
			AFill(aAliProc,.T.)
		EndIf
		/*Chama a função que retorna as informações para geração do Arquivo*/
		/*Essa função esta no fonte MatxSped */
		SPDBlocoK(dDataDe,dDataAte,@aAlias,@aAliProc,aWizard[1][17] == "1-Sim",/*lSum*/,/*lGerLogPro*/,lRepross)
	EndIf

	If lBuild

		oHashProd := &cNew
		lKill0200 := .T.
	EndIf

	/*VERIFICANDO OS PRODUTOS QUE FORAM UTILIZADOS E QUE PRECISAM SER GERADOS NO 0200*/
	If Select(aAlias[0200]) > 0
		DbSelectArea(aAlias[0200])
		(aAlias[0200])->(DbGoTop())

		Do While !(aAlias[0200])->(Eof())

			//Ponto de entrada para tratamento da informação de produtos quando o mesmo estah fora do padrao do sistema
			cProd := (aAlias[0200])->COD_ITEM + Iif(lConcFil,cFilAnt,"")
			If aExistBloc[05]
				aProd := Execblock("SPEDPROD", .F., .F., {aAlias[0200],"0200"})



				If Len(aProd)>=11

					If !(Alltrim(cProd) == Alltrim(aProd[1])) .AND. lBuild

						SPDCODPRO(Alltrim(cProd),Alltrim(aProd[1]),@oHashProd)//Chama função para guardar códigos original e alterado pelo PE SPEDPROD
					EndIf

					cProd 	:= 	aProd[1]
					cUnid	:=	aProd[5]
				Else
					aProd := {"","","","","","","","","","","",""}
				EndIf

			EndIF

			(cAliasSB1)->(dbSeek(xFilial("SB1")+(aAlias[0200])->COD_ITEM))
			SFRG0200(cAlias, @aReg0200, @aReg0190, dDataDe, dDataAte, aProd,cProd , @aReg0220,cAliasSB1,iIF(Empty(cUnid),NIL,cUnid),,lSPDFIS02,,,,,,,,,,,,,,,aWizard)
			(aAlias[0200])->(DbSkip())
		EndDo

	EndIf

	//Faz cópia das informações do alias 0210 no hashmap
	If lBuild .AND. Select(aAlias[0210]) > 0 .AND. lGera0210

		//Cria nova instância do hashmap
		oHMBK02010 := &cNew
		lKill0210	:= .T.

		DbSelectArea(aAlias[0210])
		(aAlias[0210])->(DbGoTop())
		Do While !(aAlias[0210])->(Eof())

			//Verifica se o COD_ITEM já foi gravado anteriormente
			nPos0210 := FisFindHash(oHMBK02010, (aAlias[0210])->COD_ITEM)

			If nPos0210 == 0
				//Adiciona nova linha
				aAdd(aBK02010, {})
				nPos0210    :=  Len(aBK02010)
				aAdd(aBK02010[nPos0210],(aAlias[0210])->COD_ITEM) //Código
				aAdd(aBK02010[nPos0210],{{(aAlias[0210])->COD_I_COMP, (aAlias[0210])->QTD_COMP, (aAlias[0210])->PERDA}})

				//Atualiza hashmap com posição
				FisAddHash(oHMBK02010,(aAlias[0210])->COD_ITEM,nPos0210)

			Else
				//Apenas complementa linha já criada
				aAdd(aBK02010[nPos0210][2], {(aAlias[0210])->COD_I_COMP, (aAlias[0210])->QTD_COMP, (aAlias[0210])->PERDA})
			EndIF

			If aExistBloc[24]
				//Ponto de entrada para tratamento da informação de produtos quando o mesmo estah fora do padrao do sistema
				cProd := (aAlias[0210])->COD_I_COMP + Iif(lConcFil,cFilAnt,"")
				If aExistBloc[05]
					aProd := Execblock("SPEDPROD", .F., .F., {aAlias[0210],"0200"})

					If Len(aProd)>=11

						If !(Alltrim(cProd) == Alltrim(aProd[1])) .AND. lBuild

							SPDCODPRO(Alltrim(cProd),Alltrim(aProd[1]),@oHashProd)//Chama função para guardar códigos original e alterado pelo PE SPEDPROD
						EndIf

						cProd 	:= 	aProd[1]
						cUnid	:=	aProd[5]
					Else
						aProd := {"","","","","","","","","","","",""}
					EndIf

				EndIF

				(cAliasSB1)->(dbSeek(xFilial("SB1")+(aAlias[0210])->COD_I_COMP))
				SFRG0200(cAlias, @aReg0200, @aReg0190, dDataDe, dDataAte, aProd,cProd , @aReg0220,cAliasSB1,iIF(Empty(cUnid),NIL,cUnid),,lSPDFIS02,,,,,,,,,,,,,,,aWizard)
			EndIF

			(aAlias[0210])->(DbSkip())
		EndDo
	ENdIF

	Conout("*** SPEDFISCAL Inicio K200: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	/*REGISTRO K200 - ESTOQUE ESCRITURADO*/

	DbSelectArea(aAlias[K200])
	(aAlias[K200])->(DbGoTop())
	Do While !(aAlias[K200])->(Eof())
		aRegK200 := {}
		aAdd(aRegK200, {})
		nPos := Len(aRegK200)
		aAdd(aRegK200[nPos], (aAlias[K200])->REG)												//01 - REG
		aAdd(aRegK200[nPos], (aAlias[K200])->DT_EST)											//02 - DT_EST

		aAdd(aRegK200[nPos], SPDRETPRO(Alltrim((aAlias[K200])->COD_ITEM+Iif(lConcFil,cFilAnt,"")),@oHashProd))	//03 - COD_ITEM

		aAdd(aRegK200[nPos], {(aAlias[K200])->QTD,3})											//04 - QTD
		aAdd(aRegK200[nPos], (aAlias[K200])->IND_EST)											//05 - IND_EST
		/*Verifica se é cliente ou fornecedor para preencher o aPartDoc*/
		IF Substr((aAlias[K200])->COD_PART,1,3) == 'SA1'
			If SA1->(MsSeek (xFilial ("SA1")+Substr((aAlias[K200])->COD_PART,4,Len((aAlias[K200])->COD_PART))))
				aPartDoc :=	InfPartDoc ("SA1")
				SDPF150175(@aReg0150,aPartDoc,cAlias,aWizard)
			EndIf
		ElseIf Substr((aAlias[K200])->COD_PART,1,3) == 'SA2'
			If SA2->(MsSeek (xFilial ("SA2")+Substr((aAlias[K200])->COD_PART,4,Len((aAlias[K200])->COD_PART))))
				aPartDoc :=	InfPartDoc ("SA2")
				SDPF150175(@aReg0150,aPartDoc,cAlias,aWizard)
			EndIf
		EndIf
		aAdd(aRegK200[nPos], If((aAlias[K200])->IND_EST$"1|2",aPartDoc[1],""))			//06 - COD_PART
		GrvRegTrS(cAlias,,aRegK200)

		If aExistBloc[01]
			aSpdFis02 := ExecBlock("SPDFIS02", .F., .F., {aAlias[K200],,"K200"})
			If ValType(aSpdFis02)=="A"
				cUnid := aSpdFis02[1]
				nQtde := aSpdFis02[2]
				If Len(aSpdFis02) > 2
					nFatorPE  := aSpdFis02[3]
				EndIf
				If Len(aSpdFis02) > 3
					cTpCv:= aSpdFis02[4]
				Endif
			Else
				cUnid := ExecBlock("SPDFIS02", .F., .F., {aAlias[K200],,"K200"})
			EndIf
			cProd := (aAlias[K200])->COD_ITEM + Iif(lConcFil,cFilAnt,"")
			(cAliasSB1)->(dbSeek(xFilial("SB1")+(aAlias[K200])->COD_ITEM))
			SFRG0200(cAlias, @aReg0200, @aReg0190, dDataDe, dDataAte, aProd ,cProd , @aReg0220,cAliasSB1,cUnid,,lSPDFIS02,nFatorPe,,,,,,,,,,,,,,aWizard,,cTpCv)
		EndIf

		//Se for via ponto de entrada chama a função do 0200
		If aExistBloc[24]
			cProd := (aAlias[K200])->COD_ITEM + Iif(lConcFil,cFilAnt,"")
			//Ponto de entrada para tratamento da informação de produtos quando o mesmo estah fora do padrao do sistema
			If aExistBloc[05]
				aProd := Execblock("SPEDPROD", .F., .F., {aAlias[K200],"K200"})
				If Len(aProd)>=11
					cProd := aProd[1]
				Else
					aProd := {"","","","","","","","","","","",""}
				EndIf
			EndIf
			/* Verifica se o produto já esta no Reg 0200, se não existir ele chama a função para inserir*/
			(cAliasSB1)->(dbSeek(xFilial("SB1")+(aAlias[K200])->COD_ITEM))
			SFRG0200(cAlias, @aReg0200, @aReg0190, dDataDe, dDataAte, aProd ,cProd , @aReg0220,cAliasSB1,,,lSPDFIS02,nFatorPe,,,,,,,,,,,,,,aWizard,,cTpCv)
		Endif
		(aAlias[K200])->(DbSkip())
	EndDo

	//Os registros K210, K215, K260, K265, K270, K275 e K280 válidos a partir de janeiro de 2017
	//Só posso gerar o K210/K215 se não for marcado para gerar somente K200 e k280 e se for a partir da versão 011
	If lGera .And. !lK200280
		Conout("*** SPEDFISCAL Inicio K210/215: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
		/*REGISTRO K210 - DESMONTAGEM DE MERCADORIAS - ITEM DE ORIGEM*/
		DbSelectArea(aAlias[K210])
		(aAlias[K210])->(DbGoTop())
		Do While !(aAlias[K210])->(Eof())
			aAdd(aRegK210, {})
			nPos := Len(aRegK210)
			If nPos <> 0
				aAdd(aRegK210[nPos],(aAlias[K210])->REG) //Texto fixo contendo "K210"
				aAdd(aRegK210[nPos],(aAlias[K210])->DT_INI_OS) // Data de início da ordem de serviço
				aAdd(aRegK210[nPos],(aAlias[K210])->DT_FIN_OS) // Data de conclusão da ordem de serviço
				aAdd(aRegK210[nPos],(aAlias[K210])->COD_DOC_OS) // Código de identificação da ordem de serviço

				aAdd(aRegK210[nPos],SPDRETPRO((aAlias[K210])->COD_ITEM_O+Iif(lConcFil,cFilAnt,""),@oHashProd)) //Código do item de origem (campo 02 do Registro 0200)

				aAdd(aRegK210[nPos],{(aAlias[K210])->QTD_ORI,nQtdeDez})     //Quantidade de origem - saída do estoqu
			EndIf
			/*REGISTRO K215 - DESMONTAGEM DE MERCADORIAS - ITENS DE DESTINO*/
			DbSelectArea(aAlias[K215])
			If (aAlias[K215])->(DbSeek((aAlias[K215])->(FILIAL+COD_DOC_OS)))
				Do While !(aAlias[K215])->(Eof()) .And. (aAlias[K210])->(FILIAL+COD_DOC_OS) == (aAlias[K215])->(FILIAL+COD_DOC_OS)
				aAdd(aRegK215, {})
				nPosK15 := Len(aRegK215)
				If nPosK15 <> 0
					aAdd(aRegK215[nPosK15], nPos)
					aAdd(aRegK215[nPosK15], (aAlias[K215])->REG)   // Texto fixo contendo "K215"
					aAdd(aRegK215[nPosK15], SPDRETPRO((aAlias[K215])->COD_ITEM_D+Iif(lConcFil,cFilAnt,""),@oHashProd))           //Quantidade de destino - entrada em estoque
					aAdd(aRegK215[nPosK15], {(aAlias[K215])->QTD_DES,nQtdeDez}) //Quantidade de destino - entrada em estoque
				EndIf
				(aAlias[K215])->(DbSkip())
				EndDo
			EndIf
			(aAlias[K210])->(DbSkip())
		EndDo
		/*Gravação dos registros de acordo com a Hierarquia*/
		SPEDRegs(cAlias,{aRegK210,aRegK215},"K210/K215")
	EndIf

	//Só posso gerar o K220 se não for marcado para gerar somente K200 e k280
	IF !lK200280
		Conout("*** SPEDFISCAL Inicio K220: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
		DbSelectArea(aAlias[K220])
		(aAlias[K220])->(DbGoTop())
		/*REGISTRO K220 - OUTRAS MOVIMENTAÇÕES INTERNAS ENTRE MERCADORIAS*/
		Do While !(aAlias[K220])->(Eof())
			aRegK220 := {}
			aAdd(aRegK220, {})
			nPos :=Len(aRegK220)
			If nPos <> 0
				aAdd(aRegK220[nPos], (aAlias[K220])->REG)																//01 - REG
				aAdd(aRegK220[nPos], (aAlias[K220])->DT_MOV)															//02 - DT_MOV

				aAdd(aRegK220[nPos], SPDRETPRO((aAlias[K220])->COD_ITEM_O+Iif(lConcFil,cFilAnt,""),@oHashProd))	//03 - COD_ITEM_ORI

				aAdd(aRegK220[nPos], SPDRETPRO((aAlias[K220])->COD_ITEM_D+Iif(lConcFil,cFilAnt,""),@oHashProd))	//04 - COD_ITEM_DEST

    			aAdd(aRegK220[nPos], {(aAlias[K220])->QTD_ORI,nQtdeDez})												//05 - QTD_ORI
    			aAdd(aRegK220[nPos], {(aAlias[K220])->QTD_DEST,nQtdeDez})												//06 - QTD_DEST
			EndIf
			GrvRegTrS (cAlias,,aRegK220)
			(aAlias[K220])->(DbSkip())
		EndDo
	EndIf

	//Só posso gerar o K230/K235/K250/K255 se não for marcado para gerar somente K200 e k280
	IF !lK200280
		Conout("*** SPEDFISCAL Inicio K230/K235: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
		/*REGISTRO K230 - ITENS PRODUZIDOS*/
		DbSelectArea(aAlias[K230])
		(aAlias[K230])->(DbGoTop())
		Do While !(aAlias[K230])->(Eof())
			aAdd(aRegK230, {})
			nPos := Len(aRegK230)
			If nPos <> 0
				aAdd(aRegK230[nPos], (aAlias[K230])->REG)																//01 - REG
				aAdd(aRegK230[nPos], (aAlias[K230])->DT_INI_OP)															//02 - DT_INI_OP
				aAdd(aRegK230[nPos], IIf(!Empty((aAlias[K230])->DT_FIN_OP),(aAlias[K230])->DT_FIN_OP,""))				//03 - DT_FIN_OP
				aAdd(aRegK230[nPos], (aAlias[K230])->COD_DOC_OP)														//04 - COD_DOC_OP

				aAdd(aRegK230[nPos], SPDRETPRO((aAlias[K230])->COD_ITEM+Iif(lConcFil,cFilAnt,""),@oHashProd))		//05 - COD_ITEM

				aAdd(aRegK230[nPos], {(aAlias[K230])->QTD_ENC,nQtdeDez})												//06 - QTD_ENC
			EndIf

			If aExistBloc[01]
				aSpdFis02 := ExecBlock("SPDFIS02", .F., .F., {aAlias[K230],,"K230"})
				If ValType(aSpdFis02)=="A"
					cUnid := aSpdFis02[1]
					nQtde := aSpdFis02[2]
					If Len(aSpdFis02) > 2
						nFatorPE  := aSpdFis02[3]
					EndIf
					If Len(aSpdFis02) > 3
						cTpCv:= aSpdFis02[4]
					Endif
				Else
					cUnid := ExecBlock("SPDFIS02", .F., .F., {aAlias[K230],,"K230"})
				EndIf
			EndIf

			cProd := (aAlias[K230])->COD_ITEM + Iif(lConcFil,cFilAnt,"")
			If aExistBloc[24]
				//Ponto de entrada para tratamento da informação de produtos quando o mesmo estah fora do padrao do sistema
				If aExistBloc[05]
					aProd := Execblock("SPEDPROD", .F., .F., {aAlias[K230],"K230"})
					If Len(aProd)>=11
						cProd := aProd[1]
					Else
						aProd := {"","","","","","","","","","","",""}
					EndIf
				EndIf
			Endif
			(cAliasSB1)->(dbSeek(xFilial("SB1")+(aAlias[K230])->COD_ITEM))
			SFRG0200(cAlias, @aReg0200, @aReg0190, dDataDe, dDataAte,aProd ,cProd , @aReg0220,cAliasSB1 ,If(Empty(cUnid),nil,cUnid), ,lSPDFIS02 ,nFatorPe , , , , , , , , , ,lGera0210,(aAlias[K230])->COD_ITEM,(aAlias[0210]), @aReg0210,aWizard,,cTpCv )
			/*REGISTRO K235 - INSUMOS CONSUMIDOS*/
			DbSelectArea(aAlias[K235])
			If (aAlias[K235])->(DbSeek((aAlias[K230])->(FILIAL+COD_DOC_OP)))
				Do While !(aAlias[K235])->(Eof()) .And. (aAlias[K230])->(FILIAL+COD_DOC_OP) == (aAlias[K235])->(FILIAL+COD_DOC_OP)
					aAdd(aRegK235, {})
					nPosK235 := Len(aRegK235)
					If nPosK235 <> 0
						aAdd(aRegK235[nPosK235], nPos)
						aAdd(aRegK235[nPosK235], (aAlias[K235])->REG)																					//01 - REG
						aAdd(aRegK235[nPosK235], (aAlias[K235])->DT_SAIDA)																				//02 - DT_SAÍDA

						aAdd(aRegK235[nPosK235],  SPDRETPRO((aAlias[K235])->COD_ITEM+Iif(lConcFil,cFilAnt,""),@oHashProd))							//03 - COD_ITEM

						aAdd(aRegK235[nPosK235], {(aAlias[K235])->QTD,nQtdeDez})																		//04 - QTD
						if lGera0210
							aAdd(aRegK235[nPosK235], Iif(Empty((aAlias[K235])->COD_INS_SU),"",(aAlias[K235])->COD_INS_SU+ Iif(lConcFil,cFilAnt,"")))	//05 - COD_INS_SUBST
						else
							aAdd(aRegK235[nPosK235], "")
						EndIf
					EndIf
					cProd := (aAlias[K235])->COD_ITEM + Iif(lConcFil,cFilAnt,"")
					If aExistBloc[24]
						//Ponto de entrada para tratamento da informação de produtos quando o mesmo estah fora do padrao do sistema
						If aExistBloc[05]
							aProd := Execblock("SPEDPROD", .F., .F., {aAlias[K235],"K235"})
							If Len(aProd)>=11
								cProd := aProd[1]
							Else
								aProd := {"","","","","","","","","","","",""}
							EndIf
						EndIf
					Endif
					(cAliasSB1)->(dbSeek(xFilial("SB1")+(aAlias[K235])->COD_ITEM))
					SFRG0200(cAlias, @aReg0200, @aReg0190, dDataDe, dDataAte,aProd,cProd , @aReg0220,cAliasSB1 , , , , , , , , , , , , , ,lGera0210,(aAlias[K235])->COD_ITEM,(aAlias[0210]), @aReg0210,aWizard )
					(aAlias[K235])->(DbSkip())
				EndDo
			EndIf
			(aAlias[K230])->(DbSkip())
		EndDo
		/*Gravação dos registros de acordo com a Hierarquia*/
		SPEDRegs(cAlias,{aRegK230,aRegK235},"K230/K235")

		Conout("*** SPEDFISCAL Inicio K250/K255: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
		/*REGISTRO K250 - INDUSTRIALIZAÇÃO EFETUADA POR TERCEIROS - ITENS PRODUZIDOS*/
		DbSelectArea (aAlias[K250])
		(aAlias[K250])->(DbGoTop())
		Do While !(aAlias[K250])->(Eof())
			aAdd(aRegK250, {})
			nPos := Len(aRegK250)
			If nPos <> 0
				aAdd(aRegK250[nPos], (aAlias[K250])->REG)																//01 - REG
				aAdd(aRegK250[nPos], (aAlias[K250])->DT_PROD)															//02 - DT_PROD

				aAdd(aRegK250[nPos], SPDRETPRO((aAlias[K250])->COD_ITEM+Iif(lConcFil,cFilAnt,""),@oHashProd))	//03 - COD_ITEM

				aAdd(aRegK250[nPos], {(aAlias[K250])->QTD,nQtdeDez})													//04 - QTD
			EndIf

			cProd :=  SPDRETPRO((aAlias[K250])->COD_ITEM+ Iif(lConcFil,cFilAnt,""),@oHashProd)

			(cAliasSB1)->(dbSeek(xFilial("SB1")+(aAlias[K250])->COD_ITEM))
			SFRG0200(cAlias, @aReg0200, @aReg0190, dDataDe, dDataAte, ,cProd , @aReg0220,cAliasSB1 , , , , , , , , , , , , , , lGera0210,(aAlias[K250])->COD_ITEM,(aAlias[0210]), @aReg0210,aWizard )

			/*REGISTRO K255 - INDUSTRIALIZAÇÃO EM TERCEIROS - INSUMOS CONSUMIDOS*/
			DbSelectArea (aAlias[K255])
			If (aAlias[K255])->(DbSeek((aAlias[K250])->(FILIAL+CHAVE)))
				Do While !(aAlias[K255])->(Eof()) .And. (aAlias[K250])->(FILIAL+CHAVE) == (aAlias[K255])->(FILIAL+CHAVE)
					aAdd(aRegK255, {})
					nPosK255 := Len(aRegK255)
					If nPosK255 <> 0
						aAdd(aRegK255[nPosK255], nPos)
						aAdd(aRegK255[nPosK255], (aAlias[K255])->REG)																//01 - REG
						aAdd(aRegK255[nPosK255], (aAlias[K255])->DT_CONS)															//02 - DT_CONS

						aAdd(aRegK255[nPosK255], SPDRETPRO((aAlias[K255])->COD_ITEM+Iif(lConcFil,cFilAnt,""),@oHashProd))	//03 - COD_ITEM

						aAdd(aRegK255[nPosK255], {(aAlias[K255])->QTD,nQtdeDez})													//04 - QTD
						If lGera0210
							aAdd(aRegK255[nPosK255], Iif(Empty((aAlias[K255])->COD_INS_SU),"",(aAlias[K255])->COD_INS_SU + Iif(lConcFil,cFilAnt,"")))	//05 - COD_INS_SUBST
						else
							aAdd(aRegK255[nPosK255],"")
						EndIf
					EndIf
					(aAlias[K255])->(DbSkip())
				EndDo
			EndIf
			(aAlias[K250])->(DbSkip())
		EndDo
		/*Gravação dos registros de acordo com a Hierarquia*/
		SPEDRegs(cAlias,{aRegK250,aRegK255},"K250/K255")
	EndIf

	//Só posso gerar o K260/k265/K270/K275 se não for marcado para gerar somente K200 e k280 e se for a partir da versão 011
	IF lGera .And. !lK200280
		Conout("*** SPEDFISCAL Inicio K260/K265: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
		/*REGISTRO K260 - REPROCESSAMENTO/REPARO DE PRODUTO/INSUMO*/
		DbSelectArea(aAlias[K260])
		(aAlias[K260])->(DbGoTop())
		Do While !(aAlias[K260])->(Eof())
			aAdd(aRegK260, {})
			nPos := Len(aRegK260)
			If nPos <> 0
				aAdd(aRegK260[nPos], (aAlias[K260])->REG) // Texto fixo contendo "K260"
				aAdd(aRegK260[nPos], (aAlias[K260])->COD_OP_OS) //Código de identificação da ordem de produção, no reprocessamento, ou da ordem de serviço, no reparo

				aAdd(aRegK260[nPos], SPDRETPRO((aAlias[K260])->COD_ITEM+Iif(lConcFil,cFilAnt,""),@oHashProd))  // Código do produto/insumo a ser reprocessado/reparado ou já reprocessado/reparado (campo 02 do Registro 0200)

				aAdd(aRegK260[nPos], (aAlias[K260])->DT_SAIDA) //Data de saída do estoque
				aAdd(aRegK260[nPos], {(aAlias[K260])->QTD_SAIDA,nQtdeDez})  //Quantidade de saída do estoque
				aAdd(aRegK260[nPos], (aAlias[K260])->DT_RET) //Data de retorno ao estoque (entrada)
				aAdd(aRegK260[nPos], {(aAlias[K260])->QTD_RET,nQtdeDez})   //Quantidade de retorno ao estoque (entrada)
			EndIf
			/*REGISTRO K265 - REPROCESSAMENTO/REPARO - MERCADORIAS CONSUMIDAS E/OU RETORNADAS*/
			DbSelectArea (aAlias[K265])
			If (aAlias[K265])->(DbSeek((aAlias[K260])->(FILIAL+COD_OP_OS)))
				Do While !(aAlias[K265])->(Eof()) .And. (aAlias[K260])->(FILIAL+COD_OP_OS) == (aAlias[K265])->(FILIAL+COD_OP_OS)
					aAdd(aRegK265, {})
					nPosK265 := Len(aRegK265)
					If nPosK265 <> 0
						aAdd(aRegK265[nPosK265], nPos)
						aAdd(aRegK265[nPosK265], (aAlias[K265])->REG) //Texto fixo contendo "K265"

						aAdd(aRegK265[nPosK265], SPDRETPRO((aAlias[K265])->COD_ITEM+Iif(lConcFil,cFilAnt,""),@oHashProd)) // Código da mercadoria (campo 02 do Registro 0200)

						aAdd(aRegK265[nPosK265], {(aAlias[K265])->QTD_CONS,nQtdeDez}) //Quantidade consumida - saída do estoque
						aAdd(aRegK265[nPosK265], {(aAlias[K265])->QTD_RET,nQtdeDez})  //Quantidade retornada - entrada em estoque
					EndIf
					(aAlias[K265])->(DbSkip())
				EndDo
			EndIf
			(aAlias[K260])->(DbSkip())
		EndDo
		/*Gravação dos registros de acordo com a Hierarquia*/
		SPEDRegs(cAlias,{aRegK260,aRegK265},"K260/K265")

		Conout("*** SPEDFISCAL Inicio K270/K275: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
		/*REGISTRO K270 - CORREÇÃO DE APONTAMENTO DOS REGISTROS K210, K220, K230, K250 E K260*/
		DbSelectArea(aAlias[K270])
		(aAlias[K270])->(DbGoTop())
		Do While !(aAlias[K270])->(Eof())
			aAdd(aRegK270, {})
			nPos := Len(aRegK270)
			If nPos <> 0
				aAdd(aRegK270[nPos], (aAlias[K270])->REG) //Texto fixo contendo "K270"
				aAdd(aRegK270[nPos], (aAlias[K270])->DT_INI_AP) //Data inicial do período de apuração em que ocorreu o apontamento que está sendo corrigido
				aAdd(aRegK270[nPos], (aAlias[K270])->DT_FIN_AP) //Data final do período de apuração em que ocorreu o apontamento que está sendo corrigido
				aAdd(aRegK270[nPos], (aAlias[K270])->COD_OP_OS) //Código de identificação da ordem de produção ou da ordem de serviço que está sendo corrigida

				aAdd(aRegK270[nPos], SPDRETPRO((aAlias[K270])->COD_ITEM+Iif(lConcFil,cFilAnt,""),@oHashProd)) //Código da mercadoria que está sendo corrigido (campo 02 do Registro 0200)

				aAdd(aRegK270[nPos], Iif((aAlias[K270])->QTD_COR_P > 0,{(aAlias[K270])->QTD_COR_P,nQtdeDez},'')) //Quantidade de correção positiva de apontamento ocorrido em período de apuração anterior
				aAdd(aRegK270[nPos], Iif((aAlias[K270])->QTD_COR_N > 0,{(aAlias[K270])->QTD_COR_N,nQtdeDez},'')) //Quantidade de correção negativa de apontamento ocorrido em período de apuração anterior
				aAdd(aRegK270[nPos], (aAlias[K270])->ORIGEM )//ORIGEM
			EndIf
			/*REGISTRO K275 - CORREÇÃO DE APONTAMENTO E RETORNO DE INSUMOS DOS REGISTROS K215, K220, K235, K255 E K265*/
			DbSelectArea(aAlias[K275])
			If lGeraV013
				cChave := (aAlias[K270])->CHAVE
			Else
				cChave := (aAlias[K270])->COD_OP_OS
				(aAlias[K275])->(DbSetOrder(2))
			Endif
			If (aAlias[K275])->(DbSeek((aAlias[K270])->(FILIAL+cChave)))
				Do While !(aAlias[K275])->(Eof()) .And. (aAlias[K270])->(FILIAL+cChave) == (aAlias[K275])->(FILIAL+Iif(lGeraV013,CHAVE,COD_OP_OS))
					aAdd(aRegK275, {})
					nPosK275 := Len(aRegK275)
					If nPosK275 <> 0
						aAdd(aRegK275[nPosK275], nPos)
						aAdd(aRegK275[nPosK275], (aAlias[K275])->REG) // Texto fixo contendo "K275"

						aAdd(aRegK275[nPosK275], SPDRETPRO((aAlias[K275])->COD_ITEM+ Iif(lConcFil,cFilAnt,""),@oHashProd)) //Código da mercadoria (campo 02 do Registro 0200)

						aAdd(aRegK275[nPosK275], Iif((aAlias[K275])->QTD_COR_P > 0,{(aAlias[K275])->QTD_COR_P,nQtdeDez},'')) // Quantidade de correção positiva de apontamento ocorrido em período de apuração anterior
						aAdd(aRegK275[nPosK275], Iif((aAlias[K275])->QTD_COR_N > 0,{(aAlias[K275])->QTD_COR_N,nQtdeDez},'')) // Quantidade de correção negativa de apontamento ocorrido em período de apuração anterior
						aAdd(aRegK275[nPosK275], Iif(Empty((aAlias[K275])->COD_INS_SU),"",(aAlias[K275])->COD_INS_SU+ Iif(lConcFil,cFilAnt,""))) // Código do insumo que foi substituído, caso ocorra a substituição, relativo aos Registros K235/K255.
					EndIf
					(aAlias[K275])->(DbSkip())
				EndDo
			EndIf
			(aAlias[K270])->(DbSkip())
		EndDo
		/*Gravação dos registros de acordo com a Hierarquia*/
		SPEDRegs(cAlias,{aRegK270,aRegK275},"K270/K275")
	EndIf

	//Só posso gerar o K290/k291/K292 se não for marcado para gerar somente K200 e k280 e se for a partir da versão 013
	IF lGeraV013 .And. !lK200280
		Conout("*** SPEDFISCAL Inicio K290/k291/K292: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
		/*REGISTRO K290 - Produção Conjunta – Ordem de Produção*/

		DbSelectArea(aAlias[K290])
		(aAlias[K290])->(DbGoTop())
		Do While !(aAlias[K290])->(Eof())
			aAdd(aRegK290, {})
			nPos := Len(aRegK290)
			If nPos <> 0
				aAdd(aRegK290[nPos], (aAlias[K290])->REG) 		 // Texto fixo contendo "K290"
				aAdd(aRegK290[nPos], (aAlias[K290])->DT_INI_OP)  //Data de início da ordem de produção
				aAdd(aRegK290[nPos], (aAlias[K290])->DT_FIN_OP)  // Data de conclusão da ordem de produção
				aAdd(aRegK290[nPos], (aAlias[K290])->COD_DOC_OP) //Código de identificação da ordem de produção
			EndIf

			/*REGISTRO K291 - Produção Conjunta – Itens Produzidos*/
			DbSelectArea(aAlias[K291])
			If (aAlias[K291])->(DbSeek((aAlias[K290])->(FILIAL+COD_DOC_OP)))
				Do While !(aAlias[K291])->(Eof()) .And. (aAlias[K290])->(FILIAL+COD_DOC_OP) == (aAlias[K291])->(FILIAL+COD_DOC_OP)
					aAdd(aRegK291, {})
					nPosK291 := Len(aRegK291)
					If nPosK291 <> 0
						aAdd(aRegK291[nPosK291], nPos)
						aAdd(aRegK291[nPosK291], (aAlias[K291])->REG) //Texto fixo contendo "K291"

						aAdd(aRegK291[nPosK291], SPDRETPRO((aAlias[K291])->COD_ITEM+Iif(lConcFil,cFilAnt,""),@oHashProd)) // Código da mercadoria (campo 02 do Registro 0200)

						aAdd(aRegK291[nPosK291], {(aAlias[K291])->QTD,nQtdeDez}) //Quantidade de produção acabada
					EndIf
					(aAlias[K291])->(DbSkip())
				EndDo
			EndIf
			/*REGISTRO K292 - Produção Conjunta – Insumos Consumidos*/
			DbSelectArea(aAlias[K292])
			If (aAlias[K292])->(DbSeek((aAlias[K290])->(FILIAL+COD_DOC_OP)))
				Do While !(aAlias[K292])->(Eof()) .And. (aAlias[K290])->(FILIAL+COD_DOC_OP) == (aAlias[K292])->(FILIAL+COD_DOC_OP)
					aAdd(aRegK292, {})
					nPosK292 := Len(aRegK292)
					If nPosK292 <> 0
						aAdd(aRegK292[nPosK292], nPos)
						aAdd(aRegK292[nPosK292], (aAlias[K292])->REG) //Texto fixo contendo "K292"

						aAdd(aRegK292[nPosK292], SPDRETPRO((aAlias[K292])->COD_ITEM+Iif(lConcFil,cFilAnt,""),@oHashProd)) // Código da mercadoria (campo 02 do Registro 0200)

						aAdd(aRegK292[nPosK292], {(aAlias[K292])->QTD,nQtdeDez}) //Quantidade consumida
					EndIf
					(aAlias[K292])->(DbSkip())
				EndDo
			EndIf
			(aAlias[K290])->(DbSkip())
		EndDo
		/*Gravação dos registros de acordo com a Hierarquia*/
		//SPEDRegs(cAlias,{aRegK290,aRegK291,aRegK292})
		GrRegDep(cAlias,aRegK290,aRegK291,.F.,,,,.T.)
		GrRegDep(cAlias,aRegK290,aRegK292,.T.,,,,.T.)
		aSize(aRegK290, 0)
		aSize(aRegK291, 0)
		aSize(aRegK292, 0)
	EndIf

	//Só posso gerar o K300/k301/K302 se não for marcado para gerar somente K200 e k280 e se for a partir da versão 013
	IF lGeraV013 .And. !lK200280
		Conout("*** SPEDFISCAL Inicio K300/k301/K302: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
		/*REGISTRO K300: PRODUÇÃO CONJUNTA – INDUSTRIALIZAÇÃO EFETUADA POR TERCEIROS*/
		DbSelectArea(aAlias[K300])
		(aAlias[K300])->(DbGoTop())
		Do While !(aAlias[K300])->(Eof())
			aAdd(aRegK300, {})
			nPos := Len(aRegK300)
			If nPos <> 0
				aAdd(aRegK300[nPos], (aAlias[K300])->REG) 	    // Texto fixo contendo "K300"
				aAdd(aRegK300[nPos], (aAlias[K300])->DT_PROD)  //Data do reconhecimento da produção ocorrida no terceiro
			EndIf

			/*REGISTRO K301: PRODUÇÃO CONJUNTA – INDUSTRIALIZAÇÃO EFETUADA POR TERCEIROS – ITENS PRODUZIDOS*/
			DbSelectArea (aAlias[K301])
			If (aAlias[K301])->(DbSeek((aAlias[K300])->(FILIAL+AllTrim(CHAVE))))
				Do While !(aAlias[K301])->(Eof()) .And. (aAlias[K300])->(FILIAL+AllTrim(CHAVE)) == (aAlias[K301])->(FILIAL+SubsTring((aAlias[K301])->Chave,1,8))
					aAdd(aRegK301, {})
					nPosK301 := Len(aRegK301)
					If nPosK301 <> 0
						aAdd(aRegK301[nPosK301], nPos)
						aAdd(aRegK301[nPosK301], (aAlias[K301])->REG) //Texto fixo contendo "K301"

						aAdd(aRegK301[nPosK301], SPDRETPRO((aAlias[K301])->COD_ITEM+Iif(lConcFil,cFilAnt,""),@oHashProd)) // Código da mercadoria (campo 02 do Registro 0200)

						aAdd(aRegK301[nPosK301], {(aAlias[K301])->QTD,nQtdeDez}) //Quantidade produzida
					EndIf
					(aAlias[K301])->(DbSkip())
				EndDo
			EndIf
			/*REGISTRO K302: PRODUÇÃO CONJUNTA – INDUSTRIALIZAÇÃO EFETUADA POR TERCEIROS – INSUMOS CONSUMIDOS*/
			DbSelectArea (aAlias[K302])
			If (aAlias[K302])->(DbSeek((aAlias[K300])->(FILIAL+AllTrim(CHAVE))))
				Do While !(aAlias[K302])->(Eof()) .And. (aAlias[K300])->(FILIAL+AllTrim(CHAVE)) == (aAlias[K302])->(FILIAL+SubsTring((aAlias[K302])->Chave,1,8))
					aAdd(aRegK302, {})
					nPosK302 := Len(aRegK302)
					If nPosK302 <> 0
						aAdd(aRegK302[nPosK302], nPos)
						aAdd(aRegK302[nPosK302], (aAlias[K302])->REG) //Texto fixo contendo "K302"

						aAdd(aRegK302[nPosK302], SPDRETPRO((aAlias[K302])->COD_ITEM+Iif(lConcFil,cFilAnt,""),@oHashProd)) // Código da mercadoria (campo 02 do Registro 0200)

						aAdd(aRegK302[nPosK302], {(aAlias[K302])->QTD,nQtdeDez}) //Quantidade consumida
					EndIf
					(aAlias[K302])->(DbSkip())
				EndDo
			EndIf
			(aAlias[K300])->(DbSkip())
		EndDo
		/*Gravação dos registros de acordo com a Hierarquia*/
		//SPEDRegs(cAlias,{aRegK300,aRegK301,aRegK302})
		GrRegDep(cAlias,aRegK300,aRegK301,.F.,,,,.T.)
		GrRegDep(cAlias,aRegK300,aRegK302,.T.,,,,.T.)
		aSize(aRegK300, 0)
		aSize(aRegK301, 0)
		aSize(aRegK302, 0)
	EndIf

	//Se for versão maior/igual que 011 "OU" escolheu gerar apenas K200/K280
	IF lGera .Or. lK200280
		Conout("*** SPEDFISCAL Inicio K280: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
		/*REGISTRO K280 - CORREÇÃO DE APONTAMENTO - ESTOQUE ESCRITURADO */
		DbSelectArea(aAlias[K280])
		(aAlias[K280])->(DbGoTop ())
		Do While !(aAlias[K280])->(Eof())
			aRegK280 := {}
			aAdd(aRegK280, {})
			nPos := Len(aRegK280)
			If nPos <> 0
				aAdd(aRegK280[nPos], (aAlias[K280])->REG) //Texto fixo contendo "K280"                                             //01 - REG
				aAdd(aRegK280[nPos], (aAlias[K280])->DT_EST) //Data do estoque final escriturado que está sendo corrigido          //02 - DT_MOV

				aAdd(aRegK280[nPos], SPDRETPRO((aAlias[K280])->COD_ITEM+Iif(lConcFil,cFilAnt,""),@oHashProd)) //Código do item (campo 02 do Registro 0200)

				aAdd(aRegK280[nPos], Iif((aAlias[K280])->QTD_COR_P> 0 ,{(aAlias[K280])->QTD_COR_P,3},'')) //Quantidade de correção positiva de apontamento ocorrido em período de apuração anterior
				aAdd(aRegK280[nPos], Iif((aAlias[K280])->QTD_COR_N > 0,{(aAlias[K280])->QTD_COR_N,3},'')) //Quantidade de correção negativa de apontamento ocorrido em período de apuração anterior
				aAdd(aRegK280[nPos],  (aAlias[K280])->IND_EST) //Indicador do tipo de estoque

				/*Verifica se é cliente ou fornecedor para preencher o aPartDoc*/
				If !Empty((aAlias[K280])->COD_PART)
					IF Substr((aAlias[K280])->COD_PART,1,3) == 'SA1'
						If SA1->(MsSeek (xFilial ("SA1")+Substr((aAlias[K280])->COD_PART,4,Len((aAlias[K280])->COD_PART))))
							aPartDoc :=	InfPartDoc ("SA1")
							SDPF150175(@aReg0150,aPartDoc,cAlias,aWizard)
						EndIf
					ElseIf Substr((aAlias[K280])->COD_PART,1,3) == 'SA2'
						If SA2->(MsSeek (xFilial ("SA2")+Substr((aAlias[K280])->COD_PART,4,Len((aAlias[K280])->COD_PART))))
							aPartDoc :=	InfPartDoc ("SA2")
							SDPF150175(@aReg0150,aPartDoc,cAlias,aWizard)
						EndIf
					EndIf
					aAdd(aRegK280[nPos],  aPartDoc[1])
				Else
					aAdd(aRegK280[nPos],  (aAlias[K280])->COD_PART) //Código do participante
				Endif

			EndIf
			GrvRegTrS (cAlias,,aRegK280)
			(aAlias[K280])->(DbSkip())
		EndDo
		Conout("*** SPEDFISCAL Final K280: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	EndIf

	//Fecha os Arquivos Temporarios
	If lBlkApg .And. !aExistBloc[24]
		BlkApgArq(aAlias)
	Else
		For nX := 1 To Len(aAlias)
			// Não fecho os K001,  K100 e K990, pois o ponto de entrada não retorna
			If aExistBloc[24] .And. nX <> 2 .And. nX <> 3 .And. nX <> 20 .And. nX <> 21 .And. Select(aAlias[nX]) > 0
				DbSelectArea(aAlias[nX])
				(aAlias[nX])->(DbCloseArea())
				Ferase(aAlias[nX]+GetDBExtension())
			ElseIf !aExistBloc[24] .And. Select(aAlias[nX]) > 0
				DbSelectArea(aAlias[nX])
				(aAlias[nX])->(DbCloseArea())
				Ferase(aAlias[nX]+GetDBExtension())
			EndIf
		Next nX
	EndIf

	If lKill0210
		FreeObj(oHMBK02010)
		oHMBK02010 := NIL
		aSize(aBK02010, 0)
	EndIF
	lKill0210	:= .F.

	If lKill0200
		FreeObj(oHashProd)
		oHashProd := NIL
	EndIF
	lKill0200	:= .F.

	SM0->(DbSkip())
End
RestArea(aAreaSM0)
cFilAnt := FWGETCODFILIAL

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±³Fun‡…o    ³PosSerie  ³ Autor ³ Fabio V. Santana      ³ Data ³11/03/2014³±
±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±³Descri‡…o ³ Retorna a posicao do campo serie                           ³±
±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±³ Uso      ³ SPEDFISCAL / SPEDPISCOF                                    ³±
±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PosSerie(cRegSped)

Local cReg2 := "C350|"
Local cReg3 := "C300|C700|D162|D695|D300|1105|"
Local cReg4 := "C176|C600|D600|1900|C395|D200|1110|E113|E240|1923|"
Local cReg5 := "G130|1101|1501|"
Local cReg6 := "C113|A100|"
Local cReg7 := "C100|C500|D100|D500|1500|"
Local nPos  := 0

If cRegSped $ cReg2
	nPos := 2
ElseIf cRegSped $ cReg3
	nPos := 3
ElseIf cRegSped $ cReg4
	nPos := 4
ElseIf cRegSped $ cReg5
	nPos := 5
ElseIf cRegSped $ cReg6
	nPos := 6
ElseIf cRegSped $ cReg7
	nPos := 7
EndIf

Return (nPos)

//-------------------------------------------------------------------
/*/{Protheus.doc} SPEDSitInf
// Retorna a situação do documento quando existe um cancelamento
// fora do prazo. Retorno da SEFAZ na Função XFUNCodSef()

@author Jorge Souza
@since 25/05/2015
@version 12

Revogado para:
Art. 18-I O documento fiscal cancelado extemporaneamente deverá ser escriturado pelo contribuinte, no período de referência de sua emissão,
sendo necessário fazer constar na Escrituração Fiscal Digital - EFD, no campo 'COD_SIT' do Registro C100, o código/descrição '02 - Documento Cancelado'.
(Nova redação dada pela Port. 146/17)
Fonte: http://app1.sefaz.mt.gov.br/0325677500623408/07FA81BED2760C6B84256710004D3940/E760EFD23D518130042573B100410E48
/*/
//-------------------------------------------------------------------
Function SPEDSitInf(cAliasSFT,cAliasSF3)

Local cSitDocInf := ""
Local cEst       := aSPDSX6[MV_ESTADO]
Default cAliasSF3:= "SF3"


//Se for o alias default eh necessario posicionar no registro correto
If cAliasSF3 == "SF3"
	SF3->(DbSetOrder(1))
	SF3->(DbSeek((cAliasSFT)->(FT_FILIAL+DTOS(FT_ENTRADA)+FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA)))
EndIf

If aSPDSX3[FP_F3_PROTOC] .And. !Empty((cAliasSF3)->F3_PROTOC)
	If aSPDSX3[FP_F3_CODRSEF] .And. !Empty((cAliasSF3)->F3_CODRSEF) .AND. cEst=='MT'
		//Cancelamento de NF-e homologado fora de prazo.
		If Alltrim((cAliasSF3)->F3_CODRSEF) $ XFUNCodSef({"C"})
			IF DTOS(FT_ENTRADA) >= '20170901'
				cSitDocInf := "02"
			Else
				cSitDocInf := "08"
			Endif
		Endif
	EndIf
Endif
Return cSitDocInf

//-------------------------------------------------------------------
/*/{Protheus.doc} SpedLoadX2
Funcao responsavel por realizar o cache dos AliasInDic utilizados na geracao
dos SPEDS.

@return aRet - Array com o cache do SX2.

@author Joao Pellegrini
/*/
//-------------------------------------------------------------------
Function SpedLoadX2()

Local nX := 0
Local aRet := {}
Local bError
Local lErro	:= .F.

Local aDic  := {	"AIF",; //01
					"CC6",; //02
					"CDT",; //03
					"CE5",; //04
					"CE6",; //05
					"CE7",; //06
					"SFU",; //07
					"SFX",; //08
					"CD0",; //09
					"CD1",; //10
					"CD3",; //11
					"CD4",; //12
					"CD5",; //13
					"CD6",; //14
					"CD7",; //15
					"CD8",; //16
					"CD9",; //17
					"CDA",; //18
					"CDB",; //19
					"CDC",; //20
					"CDD",; //21
					"CDE",; //22
					"CDF",; //23
					"CDG",; //24
					"CDH",; //25
					"CDL",; //26
					"CDN",; //27
					"CDO",; //28
					"CDP",; //29
					"CCK",; //30
					"CDV",; //31
					"CG1",; //32
					"LF1",; //33
					"LEG",; //34
					"LEJ",; //35
					"LEI",; //36
					"CVB",; //37
					"CCK",; //38
					"F09",; //39
					"F0I",; //40
					"F0J",; //41
					"F0K",; //42
					"F0Q",; //43
					"F0W",; //44
					"F0M",; //45
					"D3K",; //46
					"F0A",; //47
					"F3T",; //48
					"F3R",; //49
					"GIC",; //50
					"GZU",; //51
					"CIF",; //52
					"CIG",; //53
					"CIH",; //54
					"CII",; //55
					"CIJ",; //56
					"CIK",; //57
					"CIL",; //58
					"CIM"}  //59


bError := ErrorBlock( {|| lErro := .T. } )

BEGIN SEQUENCE
	//Tentar executar alias indic
	AliasInDic("SFT")
END SEQUENCE

ErrorBlock( bError )

If !lErro
	//O Ambiente está inicializado
	For nX:=1 to Len(aDic)
		aAdd(aRet, AliasIndic(aDic[nX]) )
	Next nX
EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SpedLoadX3
Funcao responsavel por realizar o cache dos fieldpos utilizados na geracao
dos SPEDS.

@return aRet - Array com o cache do SX3.

@author Joao Pellegrini
/*/
//-------------------------------------------------------------------
Function SpedLoadX3()

Local nX := 0
Local nPos := 0
Local aAlias := {}
Local aRet := {}
Local bError
Local lErro	:= .F.
Local aFPCpo := {	{"SA1","A1_TPREG"  },;//01
					{"SA1","A1_CODPAIS"},;//02
					{"SA1","A1_SUFRAMA"},;//03
					{"SA1","A1_ENDNOT" },;//04
					{"SA1","A1_SIMPNAC"},;//05
					{"SA1","A1_REGPB"  },;//06
					{"SA1","A1_COMPLEM"},;//07
					{"SA2","A2_TPREG"  },;//08
					{"SA2","A2_CODPAIS"},;//09
					{"SA2","A2_SUFRAMA"},;//10
					{"SA2","A2_ENDNOT" },;//11
					{"SA2","A2_SIMPNAC"},;//12
					{"SA2","A2_REGPB"  },;//13
					{"SA2","A2_COMPLEM"},;//14
					{"SA4","A4_COD_MUN"},;//15
					{"SA4","A4_SUFRAMA"},;//16
					{"SA4","A4_CODPAIS"},;//17
					{"SA4","A4_COD_MUN"},;//18
					{"SA4","A4_ENDNOT" },;//19
					{"SA4","A4_COMPLEM"},;//20
					{"SB1","B1_TPREG"  },;//21
					{"CC6","CC6_STUF"  },;//22
					{"CC6","CC6_TIPOAJ"},;//23
					{"CC6","CC6_CLANAP"},;//24
					{"CDA","CDA_VL197" },;//25
					{"CDA","CDA_IFCOMP"},;//26
					{"CDA","CDA_TPLANC"},;//27
					{"CDC","CDC_DCCOMP"},;//28
					{"CDH","CDH_GNREF3"},;//29
					{"CDL","CDL_DOCORI"},;//30
					{"CDL","CDL_SERORI"},;//31
					{"CDL","CDL_NFEXP" },;//32
					{"CDL","CDL_SEREXP"},;//33
					{"CDL","CDL_ESPEXP"},;//34
					{"CDL","CDL_EMIEXP"},;//35
					{"CDL","CDL_CHVEXP"},;//36
					{"CDL","CDL_QTDEXP"},;//37
					{"CDL","CDL_ITEMNF"},;//38
					{"CDL","CDL_FORNEC"},;//39
					{"CDL","CDL_LOJFOR"},;//40
					{"CDT","CDT_SITEXT"},;//41
					{"CDT","CDT_DTAREC"},;//42
					{"CDT","CDT_INDFRT"},;//43
					{"CDT","CDT_DCCOMP"},;//44
					{"CD3","CD3_VOL115"},;//45
					{"CD3","CD3_CHV115"},;//46
					{"CD5","CD5_ACDRAW"},;//47
					{"CD5","CD5_DTPPIS"},;//48
					{"CD5","CD5_DTPCOF"},;//49
					{"CD5","CD5_LOCAL" },;//50
					{"CD5","CD5_ITEM"  },;//51
					{"CD6","CD6_UFPLAC"},;//52
					{"CF5","CF5_CODCRE"},;//53
					{"CF8","CF8_DTFIMN"},;//54
					{"CG1","CG1_DTINI" },;//55
					{"CT1","CT1_NTSPED"},;//56
					{"CVB","CVB_CODMUN"},;//57
					{"CVB","CVB_DTINI" },;//58
					{"CVB","CVB_DTFIM" },;//59
					{"CVB","CVB_ASSIN" },;//60
					{"CVB","CVB_CPF"   },;//61
					{"CVB","CVB_CGC"   },;//62
					{"DT3","DT3_TIPCMP"},;//63
					{"DUE","DUE_CODSOL"},;//64
					{"DUL","DUL_CGC"   },;//65
					{"DUL","DUL_INSCR" },;//66
					{"DUY","DUY_CODMUN"},;//67
					{"SD1","D1_CODBAIX"},;//68
					{"SD2","D2_SITTRIB"},;//69
					{"SFA","FA_TOTSAI" },;//70
					{"SFA","FA_TOTTRIB"},;//71
					{"SFI","FI_CANISS" },;//72
					{"SFI","FI_DESISS" },;//73
					{"SFI","FI_BIS0300"},;//74
					{"SFI","FI_BIS0500"},;//75
					{"SFI","FI_BIS0700"},;//76
					{"SFU","FU_VLFORN" },;//77
					{"SFU","FU_GRUPT"  },;//78
					{"SFU","FU_TIPLIGA"},;//79
					{"SFU","FU_CLASSIF"},;//80
					{"SFX","FX_TPASSIN"},;//81
					{"SF1","F1_TPFRETE"},;//82
					{"SF1","F1_TRANSP" },;//83
					{"SF1","F1_TPCTE"  },;//84
					{"SF1","F1_MENNOTA"},;//85
					{"SF2","F2_MENNOTA"},;//86
					{"SF3","F3_CHVNFE" },;//87
					{"SF3","F3_CODRSEF"},;//88
					{"SF3","F3_CLASCO" },;//89
					{"SF4","F4_VLAGREG"},;//90
					{"SF4","F4_MOVFIS" },;//91
					{"SF4","F4_TPREG"  },;//92
					{"SF4","F4_COMPONE"},;//93
					{"SF6","F6_NUMPROC"},;//94
					{"SF6","F6_INDPROC"},;//95
					{"SF6","F6_DESCOMP"},;//96
					{"SF6","F6_AUTENT" },;//97
					{"SF6","F6_DTPAGTO"},;//98
					{"SF9","F9_TIPO"   },;//99
					{"SF9","F9_CODBAIX"},;//100
					{"SF9","F9_QTDPARC"},;//101
					{"SF9","F9_SLDPARC"},;//102
					{"SF9","F9_PARCRED"},;//103
					{"SF9","F9_ITEMNFS"},;//104
					{"SLG","LG_SERPDV" },;//105
					{"SLX","LX_ALIQICM"},;//106
					{"SL1","L1_CGCCLI" },;//107
					{"SF3","F3_PROTOC" },;//108
					{"SF6","F6_COBREC" },;//109
					{"CDA","CDA_CLANC" },;//110
					{"SFT","FT_SERSAT" },;//111
					{"SFT","FT_ATIVCPB"},;//112
					{"SFT","FT_VALCPB" },;//113
					{"SFT","FT_ALIQCPB"},;//114
					{"SFT","FT_BASECPB"},;//115
					{"SFT","FT_DIFAL"  },;//116
					{"SFT","FT_VFCPDIF"},;//117
					{"SFT","FT_DESPICM"},;//118
					{"CLN","CLN_TIPO"  },;//119
					{"SFT","FT_CSOSN"  },;//120
					{"SBZ","BZ_CLASFIS"},;//121
					{"SBZ","BZ_ORIGEM" },;//122
					{"SB1","B1_CEST"   },;//123
					{"CDD","CDD_CHVNFE"},;//124
					{"CDA","CDA_CODREF"},;//125
					{"CE5","CE5_CHVNFE"},;//126
					{"CD0","CD0_CHVNFE"},;//127
					{"CD0","CD0_ITENFE"},;//128
					{"CD0","CD0_VLUNOP"},;//129
					{"CD0","CD0_PICMSE"},;//130
					{"CD0","CD0_ALQSTE"},;//131
					{"CD0","CD0_RESPRE"},;//132
					{"CD0","CD0_MOTRES"},;//133
					{"CD0","CD0_CHNFRT"},;//134
					{"CD0","CD0_PANFRT"},;//135
					{"CD0","CD0_SRNFRT"},;//136
					{"CD0","CD0_NRNFRT"},;//137
					{"CD0","CD0_ITNFRT"},;//138
					{"CD0","CD0_CODDA" },;//139
					{"CD0","CD0_NUMDA" },;//140
					{"F0Q","F0Q_PERIOD"},;//141
					{"F0Q","F0Q_ID"    },;//142
					{"F0M","F0M_UM"    },;//143
					{"F0M","F0M_VUNIT" },;//144
					{"F0M","F0M_TPCF"  },;//145
					{"F0M","F0M_CONTA" },;//146
					{"F0I","F0I_OUTDBF"},;//147
					{"F0I","F0I_OUTCRF"},;//148
					{"F0I","F0I_DEVFCP"},;//149
					{"F0I","F0I_DEDFCP"},;//150
					{"F0I","F0I_DBESPF"},;//151
					{"F0I","F0I_ESTDBF"},;//152
					{"F0I","F0I_ESTCRF"},;//153
					{"CD0","CD0_VLUNRE"},;//154
					{"CD0","CD0_BSULMT"},;//155
					{"CD0","CD0_VLUNCR"},;//156
					{"SD1","D1_II"     },;//157
					{"SFT","FT_PDDES"  },;//158
					{"CDV","CDV_CFOP"  },;//159
					{"CDO","CDO_AGRUPA"},;//160
					{"CDO","CDO_NFDET" },;//161
					{"SFT","FT_COLVDIF"},;//162
					{"SFT","FT_ICMSDIF"},;//163
					{"SFT","FT_TES"    },;//164
					{"SFT","FT_CLIDVMC"},;//165
					{"SFT","FT_LOJDVMC"},;//166
					{"SF1","F1_DEVMERC"},;//167
					{"CDA","CDA_ORIGEM"},;//168
					{"SF1","F1_UFORITR"},;//169
					{"SF1","F1_UFDESTR"},;//170
					{"SF1","F1_MUORITR"},;//171
					{"SF1","F1_MUDESTR"},;//172
					{"SB5","B5_ALTTRIB"},;//173
					{"SF1","F1_SUBSERI"},;//174
					{"F0K","F0K_PROCES"},;//175
					{"F0K","F0K_PROCTP"},;//176
					{"F0K","F0K_PROIND"},;//177
					{"F0K","F0K_ITPROC"},;//178
					{"CDH","CDH_PROCES"},;//179
					{"CDH","CDH_PROCTP"},;//180
					{"CDH","CDH_PROIND"},;//181
					{"CDH","CDH_ITPROC"},;//182
					{"SFT","FT_INFITEM"},;//183
					{"CD0","CD0_FCPST" },;//184
					{"SFT","FT_VFCPANT"},;//185
					{"F3R","F3R_DOCENT"},;//186
					{"F3R","F3R_FORNE" },;//187
					{"F3R","F3R_SERENT"},;//188
					{"F3R","F3R_LOJENT"},;//189
					{"F3R","F3R_QTDENT"},;//190
					{"F3R","F3R_CHVENT"},;//191
					{"F3R","F3R_ITENFE"},;//192
					{"F3R","F3R_ID"    },;//193
					{"F3R","F3R_MODENT"},;//194
					{"F3R","F3R_DTENT" },;//195
					{"CDO","CDO_DECLAR"},;//196
					{"CC6","CC6_DECLAR"},;//197
					{"SF2","F2_CMUNOR" },;//198
					{"SF2","F2_UFORIG" },;//199
					{"GZU","GZU_DOC"   },;//200
					{"GIC","GIC_CODRMD"},;//201
					{"SF1","F1_ESTPRES"},;//202
					{"SF1","F1_INCISS" },;//203
					{"SF2","F2_ESTPRES"},;//204
					{"SF2","F2_MUNPRES"},;//205
					{"CDV","CDV_ZERAVL"},;//206
					{"SFT","FT_DESCFIS"},;//207
					{"SA2","A2_CPFRUR" },;//208
					{"SA2","A2_INDRUR" },;//209
					{"SF2","F2_UFDEST" },;//210
					{"SF2","F2_CMUNDE" },;//211
					{"SFI","FI_ISSISEN"},;//212
					{"SFI","FI_ISSNTRI"},;//213
					{"SFI","FI_ISSFTRI"},;//214
					{"CDD","CDD_ENTSAI"},;//215
					{"CDT","CDT_MDEST" },;//216
					{"CDT","CDT_UFDEST"},;//217
					{"SF2","F2_CLIREM" },;//218
					{"SF2","F2_LOJAREM"},;//219
					{"SB1","B1_CODGTIN"}}//220

bError := ErrorBlock( {|| lErro := .T. } )

BEGIN SEQUENCE
	//Tentar executar alias indic
	AliasIndic("SA1")
END SEQUENCE

ErrorBlock( bError )

If !lErro
	For nX := 1 to Len(aFPCpo)
		nPos := aScan( aAlias , {|x| x[1] == aFPCpo[nX,01] } )
		If nPos == 0
			aAdd( aAlias , { aFPCpo[nX,01] , AliasIndic(aFPCpo[nX,01]) } )
			nPos := Len(aAlias)
		EndIf
		aAdd(aRet , IIf( aAlias[nPos,02] .And. (aFPCpo[nX,01])->(FieldPos(aFPCpo[nX,02])) > 0 , .T. , .F. ) )
	Next nX
EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SpedLoadX6
Funcao responsavel por realizar o cache dos parametros (SX6)
utilizados na geracao dos SPEDS.

@return aRet - Array com o cache do SX6.

@author Joao Pellegrini
/*/
//-------------------------------------------------------------------
Function SpedLoadX6()

Local nX := 0
Local aRet := {}

Local aParam := {	{"MV_PRFSPED", ""                   },;	//01
					{"MV_CONV115", .F.                  },;	//02
					{"MV_HISTTAB", .F.                  },;	//03
					{"MV_LJSPED" , ""                   },;	//04
					{"MV_COMPFRT", "{}"                 },;	//05
					{"MV_NGD162" , ""                   },;	//06
					{"MV_STUF"   , ""                   },;	//07
					{"MV_STUFS"  , ""                   },;	//08
					{"MV_USASPED", .T.                  },;	//09
					{"MV_STNIEUF", ""                   },;	//10
					{"MV_EECFAT" , .F.                  },;	//11
					{"MV_EECSPED", .T.                  },;	//12
					{"MV_EASY"   , "N"                  },;	//13
					{"MV_APUSEP" , ""                   },;	//14
					{"MV_COFLSPD", .T.                  },;	//15
					{"MV_ICMPAD" , 18                   },;	//16
					{"MV_USAXX8" , .F.  		        },;	//17
					{"MV_GER0220", .T.                  },;	//18
					{"MV_C495TRI", .T.                  },;	//19
					{"MV_DATCIAP", "" 	   	            },;	//20
					{"MV_LC102"  , "" 			        },;	//21
					{"MV_ESTE113", ""                   },;	//22
					{"MV_ESTE240", ""                   },;	//23
					{"MV_CF3ENTR", .T.                  },;	//24
					{"MV_RESF3FT", .F.                  },;	//25
					{"MV_SFRBCD2", .T.                  },;	//26
					{"MV_DTINCB1", "B1_DATREF"          },;	//27
					{"MV_PRDPRI" , ""                   },;	//28
					{"MV_SPEDAZ" , .F.                  },;	//29
					{"MV_SPEDNAT", .F.                  },;	//30
					{"MV_UFRESPD", "GO"                 },;	//31
					{"MV_CFC195" , ""                   },;	//32
					{"MV_SPDIFC" , 0                    },;	//33
					{"MV_SPDTC95", "1"                  },;	//34
					{"MV_ESTADO" , ""                   },;	//35
					{"MV_RLCSPD" , "{}"                 },;	//36
					{"MV_SPEDQTD", 1                    },;	//37
					{"MV_SFUFGNR", ""                   },;	//38
					{"MV_CIAPDAC", "S"                  },;	//39
					{"MV_F9ITEM" , "F9_ITEMNFE"         },;	//40
					{"MV_F9PROD" , ""                   },;	//41
					{"MV_F9ESP"  , ""                   },;	//42
					{"MV_F9CHVNF", ""                   },;	//43
					{"MV_F9CC"   , ""                   },;	//44
					{"MV_F9PL"   , ""                   },;	//45
					{"MV_F9CTBCC", "2"                  },;	//46
					{"MV_F9FRT"  , ""     			    },;	//47
					{"MV_F9ICMST", ""         			},;	//48
					{"MV_F9DIF"  , ""          			},;	//49
					{"MV_F9SKPNF", .F.      		    },;	//50
					{"MV_F9FUNC" , "F9_FUNCIT"			},;	//51
					{"MV_SF9PDES", "F9_DESCRI"			},;	//52
					{"MV_F9GENCC", ""          			},;	//53
					{"MV_F9GENCT", ""                   },;	//54
					{"MV_F9VLLEG", "F9_VLLEG"           },;	//55
					{"MV_RNDCIAP", .T.                  },;	//56
					{"MV_DACIAP" , 'S'                  },;	//57
					{"MV_F9CDATF", .F.                  },;	//58
					{"MV_APRCOMP", .F.                  },;	//59
					{"MV_STCIAP" , "S"                  },;	//60
					{"MV_SOMABEM", .F.                  },;	//61
					{"MV_EXPIND" , "5501/5502/6501/6502"},;	//62
					{"MV_D310MUN", ""                   },;	//63
					{"MV_INSCPAR", .T.                  },;	//64
					{"MV_REGSPED", ""                   },;	//65
					{"MV_ALIQISS", 0                    },;	//66
					{"MV_NRPRBIC", .F.                  },;	//67
					{"MV_APURANT", ""                   },;	//68
					{"MV_C140TIT", ""                   },;	//69
					{"MV_1DUPREF", ""                   },;	//70
					{"MV_2DUPREF", ""                   },;	//71
					{"MV_SPDCTTO", 190000000            },;	//72
					{"MV_INTBLCI", ""                   },;	//73
					{"MV_OCODCSC", ""                   },;	//74
					{"MV_SPDFQTC", 10                   },;	//75
					{"MV_SPEDHIS", .F.                  },;	//76
					{"MV_CDATPL" , "2"                  },;	//77
					{"MV_AGLH010", .F.                  },;	//78
					{"MV_M996TPR", 1                    },;	//79
					{"MV_NCMCPPC", {}                   },;	//80
					{"MV_STFRETE", .F.                  },;	//81
					{"MV_UFIPM"  , ''                   },;	//82
					{"MV_ESTE310", ''                   },;	//83
					{"MV_BLKTP00",'ME'                  },;	//84
					{"MV_BLKTP01",'MP'                  },;	//85
					{"MV_BLKTP02",'EM'                  },;	//86
					{"MV_BLKTP03",'PP'                  },;	//87
					{"MV_BLKTP04",'PA'                  },;	//88
					{"MV_BLKTP05",'SP'                  },;	//89
					{"MV_BLKTP06",'PI'                  },;	//90
					{"MV_BLKTP10",'OI'                  },;	//91
					{"MV_ARQPROD", ""                   },;	//92
					{"MV_TXTH020",''                    },;	//93
					{"MV_UFICSEP",""                    },;	//94
					{"MV_205HIST", 0                    },;	//95
					{"MV_BEMENT" , ""                   },;	//96
					{"MV_LEVANCM", .F.                  },;	//97
					{"MV_GIAEFD" , .F.                  },;	//98
					{"MV_VLCTBZL",""                    },;	//99
					{"MV_DEVMERC",""                    },; //100
					{"MV_UFBSST" ,""                    },;	//101
					{"MV_SPDPROD","{}"                  },;	//102
					{"MV_CLIFAT" ,.F.                   },;	//103
					{"MV_BLKTP07",'MC'                  },;	//104
					{"MV_BLKTP08",'AI'                  },;	//105
					{"MV_BLKTP09",'SV'                  },;	//106
					{"MV_INTGTP" ,"2"                   },; //107
					{"MV_COTNFSS",""                    },;	//108
					{"MV_SM0CONT","1"                   },;	//109
					{"MV_SF9QTD" ,""                    },; //110
					{"MV_QRYPARA",""                    },; //111
					{"MV_SPDBIFE",""                    }} //112

If !Empty(aSPDSX2)
	For nX:=1 to Len(aParam)
		aAdd(aRet , GetNewPar((aParam[nX,1]),aParam[nX,2]))
	Next nX
EndIf

Return aRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Reg1400Ano³ Autor ³ TOTVS                 ³ Data ³08/08/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna array c/ informacoes do registro 1400 processado   ³±±
±±³          ³ por ano conforme RESOLUÇÃO Nº 4.746/MG                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SPEDFISCAL			                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Reg1400Ano(aReg1400,cProd,cAliasSFT,cAliasSF4,lGr2001400,cMVEstado,aWizard)
Local	cFrom		:= ""
Local	cJoin		:= ""
Local	cWhere		:= ""
Local	cSelect		:= ""
Local	cJoinDT6	:= ""
Local	cJoinDUY	:= ""
Local	cJoinSD2	:= ""
Local	cJoinSF4	:= ""
Local	cJoinF09	:= ""
Local	cGroupBy	:= ""
Local	lIntTMS		:= IntTms()
Local	lExistF09	:= aSPDSX2[AI_F09]
Local	cAlias1400	:= GetNextAlias()
Local	dDataIni	:= CTOD("01"+"/"+"01"+"/"+Substring(aWizard[1,2],1,4))
Local	dDataFim	:= CTOD("31"+"/"+"12"+"/"+Substring(aWizard[1,2],1,4))
Local	lGera1400	:= .F.
Local	cTpCLN		:= ""

If lIntTMS
	cSelect	:=	"%SUM(SFT.FT_VALCONT) FT_VALCONT, DUY.DUY_CODMUN CODMUN, SF4.F4_IPMMG, SF4.F4_IPMSP, SD2.D2_TES, SFT.FT_EMISSAO, DUY.DUY_EST UF, SFT.FT_ESPECIE, SFT.FT_CFOP"
	If aSPDSX3[FP_FT_TES]
		cSelect += ", SFT.FT_TES"
	Endif
	cSelect +=	IIF(lExistF09,", F09.F09_CODIPM%","%")

	cFrom	:=	"%"+RetSqlName("SFT")+" SFT, "

	cJoinDT6 := RetSqlName("DT6")+" DT6 " +"ON (DT6.DT6_FILIAL='"+xFilial("DT6")+"' AND DT6_FILDOC=SFT.FT_FILIAL AND DT6.DT6_DOC = SFT.FT_NFISCAL AND DT6.DT6_SERIE = SFT.FT_SERIE AND DT6.D_E_L_E_T_ <> '*') "
	cJoinDUY := RetSqlName("DUY")+" DUY " +"ON (DUY.DUY_FILIAL='"+xFilial("DUY")+"' AND DUY.DUY_GRPVEN = DT6.DT6_CDRORI AND DUY.D_E_L_E_T_ <> '*') "
	cJoinSD2 := RetSqlName("SD2")+" SD2 " +"ON (SD2.D2_FILIAL='"+xFilial("SD2")+"' AND SD2.D2_DOC = SFT.FT_NFISCAL AND SD2.D2_SERIE = SFT.FT_SERIE AND SD2.D2_CLIENTE = SFT.FT_CLIEFOR AND SD2.D2_LOJA = SFT.FT_LOJA AND SD2.D2_ITEM = SFT.FT_ITEM AND SD2.D_E_L_E_T_ <> '*') "
	cJoinSF4 := RetSqlName("SF4")+" SF4 " +"ON (SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO = SD2.D2_TES AND SF4.D_E_L_E_T_ <> '*') "

	If lExistF09
		cJoinF09 += "LEFT JOIN "+RetSqlName("F09")+" F09 " +"ON (F09.F09_FILIAL='"+xFilial("F09")+"' AND F09.F09_TES = SF4.F4_CODIGO AND F09.F09_CODIPM <> ' ' AND F09.D_E_L_E_T_ <> '*') "
	Endif

	cWhere	:=	"SFT.FT_FILIAL='"+xFilial("SFT")+"' AND "
	cWhere	+=	"SFT.FT_DTCANC=' ' AND "
	cWhere	+=	"SFT.FT_TIPOMOV = 'S' AND "
	cWhere	+=	"SFT.FT_ENTRADA BETWEEN '" + DToS(dDataIni) + "' AND '" + DToS(dDataFim) + "' "

	cGroupBy := "%DUY.DUY_CODMUN, SF4.F4_IPMMG, SF4.F4_IPMSP, SD2.D2_TES, SFT.FT_EMISSAO, DUY.DUY_EST, SFT.FT_ESPECIE, SFT.FT_CFOP"
	If aSPDSX3[FP_FT_TES]
		cGroupBy += ", SFT.FT_TES"
	Endif
	cGroupBy += IIF(lExistF09,", F09.F09_CODIPM%","%")

	/*cSelect := '%'+cSelect+'%'
    cWhere  := '%'+cWhere+'%'
    cJoin   := '%'+cJoin+'%'
    cOrder  := '%'+cOrder+'%'*/

    //cSelect		:= '%'+cSelect+'%'
    cWhere		:= '%'+cWhere+'%'
    cJoinDT6	:= '%'+cJoinDT6+'%'
    cJoinDUY	:= '%'+cJoinDUY+'%'
	cJoinSD2	:= '%'+cJoinSD2+'%'
	cJoinSF4	:= '%'+cJoinSF4+'%'
	cJoinF09 	:= '%'+cJoinF09+'%'

	BeginSql Alias cAlias1400

		COLUMN FT_ENTRADA AS DATE

		SELECT
			%Exp:cSelect%
		FROM
			%Table:SFT% SFT
		JOIN
			%Exp:cJoinDT6%
			AND DT6.%NotDel%
		JOIN
			%Exp:cJoinDUY%
			AND DUY.%NotDel%
		JOIN
			%Exp:cJoinSD2%
			AND SD2.%NotDel%
		JOIN
			%Exp:cJoinSF4%
			AND SF4.%NotDel%
			%Exp:cJoinF09%
		WHERE
			%Exp:cWhere%
			AND SFT.%NotDel%
		GROUP BY
			%Exp:cGroupBy%
	EndSql
Else
	cSelect  := IIF(lExistF09,", F09.F09_CODIPM","")
	If aSPDSX3[FP_FT_TES]
		cSelect += ", SFT.FT_TES"
	Endif

	cJoinF09 := IIF(lExistF09,"% LEFT JOIN  "+RetSqlName("F09")+" F09 " +"ON(F09.F09_FILIAL='"+xFilial("F09")+"' AND F09.F09_TES = SF4.F4_CODIGO AND F09.F09_CODIPM <> ' ' AND F09.D_E_L_E_T_= '') %","%%")

	cGroupBy := IIF(lExistF09,",F09.F09_CODIPM","")
	If aSPDSX3[FP_FT_TES]
		cGroupBy += ", SFT.FT_TES"
	Endif

	cSelect  := "%"+cSelect+"%"
	cGroupBy := "%"+cGroupBy+"%"

	BeginSql Alias cAlias1400
		COLUMN FT_ENTRADA AS DATE

		SELECT
			SUM(SFT.FT_VALCONT) FT_VALCONT, SA1.A1_COD_MUN CODMUN, SF4.F4_IPMMG, SF4.F4_IPMSP, SD2.D2_TES, SFT.FT_EMISSAO, SFT.FT_ESTADO UF, SFT.FT_ESPECIE, SFT.FT_CFOP
			%Exp:cSelect%
		FROM
			%Table:SFT% SFT
		JOIN
			%Table:SD2% SD2 ON(SD2.D2_FILIAL=%xFilial:SD2% AND SD2.D2_DOC = SFT.FT_NFISCAL AND SD2.D2_SERIE = SFT.FT_SERIE AND SD2.D2_CLIENTE = SFT.FT_CLIEFOR AND SD2.D2_LOJA = SFT.FT_LOJA AND SD2.D2_ITEM = SFT.FT_ITEM AND SD2.%NotDel%)
		JOIN
			%Table:SF4% SF4 ON(SF4.F4_FILIAL=%xFilial:SF4% AND SF4.F4_CODIGO = SD2.D2_TES AND SF4.%NotDel%)
			%Exp:cJoinF09%
		JOIN
			%Table:SA1% SA1 ON(SA1.A1_FILIAL=%xFilial:SA1% AND SA1.A1_COD = SD2.D2_CLIENTE AND SA1.A1_LOJA = SD2.D2_LOJA AND SA1.%NotDel%)
		WHERE
			SFT.FT_FILIAL=%xFilial:SFT% AND
			SFT.FT_DTCANC=' ' AND
			SFT.FT_ENTRADA BETWEEN %Exp:DToS(dDataIni)% AND %Exp:DToS(dDataFim)% AND
			SFT.%NotDel%
		GROUP BY
			SA1.A1_COD_MUN, SF4.F4_IPMMG, SF4.F4_IPMSP, SD2.D2_TES, SFT.FT_EMISSAO, SFT.FT_ESTADO, SFT.FT_ESPECIE, SFT.FT_CFOP
			%Exp:cGroupBy%
	EndSql
Endif

While !(cAlias1400)->(Eof())
	cIte := ""
	If !lExistF09
		cIte	:= (cAlias1400)->F4_IPMMG
	Else
		If !Empty((cAlias1400)->F09_CODIPM)
			cIte	:= (cAlias1400)->F09_CODIPM
		ElseIf !Empty((cAlias1400)->F4_IPMMG)
			cIte	:= (cAlias1400)->F4_IPMMG
		ElseIf !Empty((cAlias1400)->F4_IPMSP)
			cIte	:= (cAlias1400)->F4_IPMSP
		Endif
	Endif

	If cMVEstado==(cAlias1400)->UF .And. !AllTrim((cAlias1400)->FT_CFOP) $ "1949|2949|3949|5949|6949|7949"	//Conforme Versão 2.0.15 do guia pratico EFD
		lGera1400 := .T.
	Endif

	If lGera1400 .And. !Empty(cIte) .And. aSPDSX3[FP_CLN_TIPO]
		If CLN->(MsSeek(XFilial("CLN")+cMVEstado+cIte))
			While CLN->(!EoF()) .And. xFilial("CLN") == CLN->CLN_FILIAL .And. CLN->CLN_CODIPM == cIte .And. CLN->CLN_UF == cMVEstado
				If Empty(DtoS(CLN->CLN_DTFIMV))
					cTpCLN := CLN->CLN_TIPO
				EndIf
				CLN->(DbSkip())
			EndDo
			If cTpCLN == "2"
				If (nPos := aScan(aReg1400, {|aX| AllTrim(aX[2])== Alltrim(cIte) .And. aX[3]==UfCodIBGE(cMVEstado)+(cAlias1400)->CODMUN})) == 0
					aAdd(aReg1400, {})
					nPos	:=	Len(aReg1400)
					aAdd (aReg1400[nPos], "1400")										//01 - REG
					aAdd (aReg1400[nPos], cIte)											//02 - COD_ITEM
					aAdd (aReg1400[nPos], UfCodIBGE(cMVEstado)+(cAlias1400)->CODMUN)	//03 - CODMUN
					aAdd (aReg1400[nPos], (cAlias1400)->FT_VALCONT)         			//04 - VALOR
				Else
					aReg1400[nPos,4] += (cAlias1400)->FT_VALCONT
				Endif
			Endif
		EndIf
	Endif
	(cAlias1400)->(dbSkip())
End

(cAlias1400)->(DbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SpedCompAtf

@return aRet - Array com as informações para gerar o G130 e G140 com os
componentes do ativo criado

@author Mauro Gonçalves
@since 30/06/2016
@version 11.8
/*/
//-------------------------------------------------------------------
Function SpedCompAtf(cCodBaixa,dDataDe,dDataAte,aReg0150,cAlias,aWizard,aExistBloc,aRegG125,nC04G110)
Local	cAliasSFT	:= GetNextAlias()
Local	aPartDoc	:= {}
Local	aInf		:= {}
Local	nPos		:= 0
Local  	nMV_SPEDQTD	:=	aSPDSX6[MV_SPEDQTD]
Local	cUnid		:= ""
Local	nQuantia	:= 0

BeginSQL Alias cAliasSFT
	COLUMN FT_EMISSAO AS DATE

	SELECT SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_FORMUL, SFT.FT_ESPECIE, SFT.FT_EMISSAO, SFT.FT_CHVNFE, SFT.FT_PRODUTO, SF9.F9_ITEMNFE,
	SFT.FT_QUANT, SF9.F9_VALICMP, SF9.F9_VALICST, SF9.F9_VALFRET, SF9.F9_VALICCO, CDC.CDC_GUIA, SB1.B1_UM, SFT.FT_CLIEFOR,
	SFT.FT_LOJA, SFT.FT_FILIAL,SD1.D1_VALICM,SFT.FT_TIPOMOV, SD1.D1_ICMSRET, SD1.D1_VALFRE, SD1.D1_ICMSCOM, SD1.D1_TIPO, SF1.F1_ORIGLAN
	FROM %Table:SF9% SF9
	JOIN %Table:SFT% SFT
	ON SFT.FT_FILIAL=%xFilial:SFT% AND SFT.FT_NFISCAL=SF9.F9_DOCNFE AND SFT.FT_SERIE=SF9.F9_SERNFE AND SFT.FT_CLIEFOR=SF9.F9_FORNECE AND SFT.FT_LOJA=SF9.F9_LOJAFOR AND SFT.FT_ITEM=SF9.F9_ITEMNFE
	AND SFT.%NotDel%
	LEFT OUTER JOIN %Table:CDC% CDC
	ON CDC.CDC_FILIAL=%xFilial:CDC% AND CDC.CDC_TPMOV='E' AND CDC.CDC_DOC=SF9.F9_DOCNFE AND CDC.CDC_SERIE=SF9.F9_SERNFE AND CDC.CDC_CLIFOR=SF9.F9_FORNECE AND CDC.CDC_LOJA=SF9.F9_LOJAFOR AND CDC.%NotDel%
	JOIN %Table:SB1% SB1
	ON SB1.B1_FILIAL=%xFilial:SB1% AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.%NotDel%
	JOIN %Table:SD1% SD1
	ON SD1.D1_FILIAL=%xFilial:SD1% AND SD1.D1_DOC=SFT.FT_NFISCAL AND SD1.D1_SERIE=SFT.FT_SERIE AND SD1.D1_FORNECE=SFT.FT_CLIEFOR AND SD1.D1_LOJA=SFT.FT_LOJA AND SD1.D1_COD=SFT.FT_PRODUTO AND SD1.D1_ITEM=SFT.FT_ITEM AND SD1.%NotDel%
	JOIN %Table:SF1% SF1
	ON SF1.F1_FILIAL=%xFilial:SF1% AND SF1.F1_DOC=SFT.FT_NFISCAL AND SF1.F1_SERIE=SFT.FT_SERIE AND SF1.F1_FORNECE=SFT.FT_CLIEFOR AND SF1.F1_LOJA=SFT.FT_LOJA AND SF1.%NotDel%
	WHERE SF9.F9_FILIAL=%xFilial:SF9% AND SF9.F9_CODBAIX=%Exp:cCodBaixa% AND SF9.%NotDel%
EndSql

If (cAliasSFT)->(EOF())
    aAdd(aInf, {})
Endif
While !(cAliasSFT)->(EOF())

	lAchouSA2 := SPEDSeek("SA2",,xFilial("SA2")+(cAliasSFT)->(FT_CLIEFOR+FT_LOJA))
	lAchouSB1 := SPEDSeek("SB1",,xFilial("SB1")+(cAliasSFT)->FT_PRODUTO)

	If lAchouSB1
		cUnid:= SB1->B1_UM
	EndIf

	If lAchouSA2
		aPartDoc	:= InfPartDoc("SA2")
	EndIf

	If aExistBloc[01]
		aSpdFis02 := ExecBlock("SPDFIS02", .F., .F., {"SFT",(cAliasSFT)->FT_TIPOMOV,"G140"})
		If ValType(aSpdFis02)=="A"
			cUnid := aSpdFis02[1]
			nQuantia := Iif(Len(aSpdFis02) >= 2, aSpdFis02[2], (cAliasSFT)->FT_QUANT)
		Else
			cUnid := ExecBlock("SPDFIS02", .F., .F., {"SFT",(cAliasSFT)->FT_TIPOMOV,"G140"})
		EndIf
	EndIf

	nQuantia := Iif(nQuantia > 0, nQuantia, Iif((cAliasSFT)->FT_QUANT > 0, (cAliasSFT)->FT_QUANT, nMV_SPEDQTD)) //Verificação de quantidade para notas de complementos.

	aAdd(aInf, {})
	nPos	:=	Len(aInf)
	aAdd(aInf[nPos], IIf("S"$(cAliasSFT)->FT_FORMUL,"0","1"))
	aAdd(aInf[nPos], aPartDoc[1])
	aAdd(aInf[nPos], AModNot((cAliasSFT)->FT_ESPECIE))
	aAdd(aInf[nPos], (cAliasSFT)->FT_SERIE)
	aAdd(aInf[nPos], (cAliasSFT)->FT_NFISCAL)
	aAdd(aInf[nPos], (cAliasSFT)->FT_CHVNFE)
	aAdd(aInf[nPos], (cAliasSFT)->FT_EMISSAO)
	aAdd(aInf[nPos], IIf(!Empty((cAliasSFT)->F9_ITEMNFE), AllTrim(Str(Val((cAliasSFT)->F9_ITEMNFE))),"1"))
	aAdd(aInf[nPos], (cAliasSFT)->FT_PRODUTO + Iif(aSPDSX6[MV_COFLSPD],lConcFil,""))
	aAdd(aInf[nPos], "")
	If cVersao >= "014"
		nValICMOP	:= Iif((cAliasSFT)->D1_TIPO == "I" .Or. (cAliasSFT)->D1_VALICM,(cAliasSFT)->D1_VALICM,(cAliasSFT)->F9_VALICMP)
		nValICMRet 	:= Iif((cAliasSFT)->D1_ICMSRET > 0,(cAliasSFT)->D1_ICMSRET, (cAliasSFT)->F9_VALICST)
		nValFrete	:= Iif((cAliasSFT)->D1_TIPO == "C" .And. (cAliasSFT)->F1_ORIGLAN == 'F',(cAliasSFT)->D1_VALICM,(cAliasSFT)->F9_VALFRET)
		nValICMComp := Iif((cAliasSFT)->D1_ICMSCOM > 0,(cAliasSFT)->D1_ICMSCOM,(cAliasSFT)->F9_VALICCO)

		aAdd(aInf[nPos], (cAliasSFT)->CDC_GUIA)
		aAdd(aInf[nPos], nQuantia)
		aAdd(aInf[nPos], cUnid)
		aAdd(aInf[nPos], nValICMOP)
		aAdd(aInf[nPos], nValICMRet)
		aAdd(aInf[nPos], nValFrete)
		aAdd(aInf[nPos], nValICMComp)

		nQuantia := 0

		aRegG125[Len(aRegG125),06] += nValICMRet
		aRegG125[Len(aRegG125),07] += nValFrete
		aRegG125[Len(aRegG125),08] += nValICMComp

	EndIf

	(cAliasSFT)->(DbSkip())

	SDPF150175(@aReg0150,aPartDoc,cAlias,aWizard,aExistBloc)

Enddo

nC04G110 += Iif(aRegG125[Len(aRegG125),04]=="SI",aRegG125[Len(aRegG125),05]+aRegG125[Len(aRegG125),06]+aRegG125[Len(aRegG125),07]+aRegG125[Len(aRegG125),08],0)


(cAliasSFT)->(DbCloseArea())

Return aInf

//-------------------------------------------------------------------
/*/{Protheus.doc} SPDVldZero
verifica se valor igual a zero!

@return lRet - .T. se var. numerica igual a zero e existe na lista abaixo

@author Flavio Luiz Vicco
@since 04/08/2016
@version 11.8
/*/
//-------------------------------------------------------------------
Function SPDVldZero(cReg,nPos)
Local lRet	:= .F.

//-- Localiza registro e posicao e verifica se valor igual a zero.
lRet := aScan(aCpoVaz, {|x|x[1] == cReg .And. x[2] == nPos}) > 0

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SPDCancSLX
Função para retornar os cupons que foram cancelados antes de finalizar
a venda, portanto não estarão na tabela SFT.

@return aRet - Array contendo os dados de cupons que não estão na
 		tabela SFT

@author eduardo.sales
@since	01/06/2017
@version 11.8
/*/
//-------------------------------------------------------------------
Function SPDCancSLX(cPDV, sDtMovDe, sDtMovAte)

Local aRet 		:= {}
Local cSLXAlias := GetNextAlias() // Alias da Query
Local cQuery 	:= ""
Local cSubQuery := ""

cSubQuery := "( SELECT FT_NFISCAL "
cSubQuery += "	FROM " + RetSQLName("SFT") + " SFT "
cSubQuery += "  WHERE SFT.FT_FILIAL = '" + xFilial("SFT") + "' AND "
cSubQuery += "			SFT.FT_TIPOMOV = 'S' AND "
cSubQuery += "			SFT.FT_PDV = SLX.LX_PDV AND "
cSubQuery += "			(SFT.FT_ESPECIE = 'CF' OR SFT.FT_ESPECIE = 'ECF') AND"
cSubQuery += "			SFT.FT_ENTRADA = SLX.LX_DTMOVTO AND "
cSubQuery += "			SFT.FT_NFISCAL = SLX.LX_CUPOM AND "
cSubQuery += "			SFT.FT_SERIE = SLX.LX_SERIE AND "
cSubQuery += "			SFT.D_E_L_E_T_ = ' ' )"

cQuery := " SELECT DISTINCT	SLX.LX_PDV, SLX.LX_DTMOVTO, SLX.LX_CUPOM, SLX.LX_SERIE "
cQuery += " FROM " + RetSQLName("SLX") + " SLX "
cQuery += " WHERE SLX.LX_FILIAL = '" + xFilial("SLX") + "' AND "
cQuery += "			SLX.LX_DTMOVTO >= '" + sDtMovDe + "' AND SLX.LX_DTMOVTO <= '" + sDtMovAte + "' AND "
cQuery += "			SLX.LX_PDV = '" + cPDV + "' AND "
cQuery += "			SLX.LX_TPCANC = 'C' AND "
cQuery += "			NOT EXISTS " + cSubQuery + " AND "
cQuery += "			SLX.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY SLX.LX_PDV, SLX.LX_DTMOVTO, SLX.LX_CUPOM, SLX.LX_SERIE "

ChangeQuery( cQuery )
DbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cSLXAlias, .T., .F. )

While !(cSLXAlias)->(EoF())
	aAdd (aRet, { (cSLXAlias)->LX_PDV, (cSLXAlias)->LX_DTMOVTO, (cSLXAlias)->LX_CUPOM })
	(cSLXAlias)->(dbSkip())
EndDo

(cSLXAlias)->(DbCloseArea())

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SpedCp3Dec

Funcao responsável por retornar os campos dos registros que devem ser
apresentados com 3 casas decimais no arquivo.

@return aRet - Array contendo os campos.

@author joao.pellegrini
@since	13/11/2017
/*/
//-------------------------------------------------------------------
Function SpedCp3Dec()

Local aRet := {}

If type("aCpo3Dec") <> "A"
	aRet := {{"C170",28},; 	//01
				{"C170",34},;	//02
				{"C181",08},; //03
				{"C185",08},; //04
				{"C191",09},; //05
				{"C195",09},; //06
				{"C381",07},; //07
				{"C385",07},; //08
				{"C481",06},; //09
				{"C485",06},; //10
				{"C491",08},; //11
				{"C495",08},; //12
				{"C820",06},; //13
				{"C820",10},; //14
				{"C880",06},; //15
				{"C880",10},; //16
				{"D350",14},; //17
				{"D350",20},; //18
				{"F510",05},; //19
				{"F510",10},; //20
				{"F560",05},; //21
				{"F560",10},; //22
				{"M100",06},; //23
				{"M105",08},; //24
				{"M105",09},; //25
				{"M210",06},; //26
				{"M500",06},; //27
				{"M505",08},; //28
				{"M505",09},; //29
				{"M610",06}} 	//30
Else
	aRet := aCpo3Dec
EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SpedCp4Dec

Funcao responsável por retornar os campos dos registros que devem ser
apresentados com 4 casas decimais no arquivo.

@return aRet - Array contendo os campos.

@author joao.pellegrini
@since	13/11/2017
/*/
//-------------------------------------------------------------------
Function SpedCp4Dec()

Local aRet := {}

If type("aCpo4Dec") <> "A"

	aRet := {{"C170",27},;  //01
				{"C170",29},; //02
				{"C170",33},; //03
				{"C170",35},; //04
				{"C181",07},; //05
				{"C181",09},; //06
				{"C185",07},; //07
				{"C185",09},; //08
				{"C191",08},; //09
				{"C191",10},; //10
				{"C195",08},; //11
				{"C195",10},; //12
				{"C381",06},; //13
				{"C381",08},; //14
				{"C385",06},; //15
				{"C385",08},; //16
				{"C396",08},; //17
				{"C396",12},; //18
				{"C481",05},; //19
				{"C481",07},; //20
				{"C485",05},; //21
				{"C485",07},; //22
				{"C491",07},; //23
				{"C491",09},; //24
				{"C495",07},; //25
				{"C495",09},; //26
				{"C501",06},; //27
				{"C505",06},; //28
				{"C601",05},; //29
				{"C605",05},; //30
				{"D101",07},; //31
				{"D105",07},; //32
				{"D201",05},; //33
				{"D205",05},; //34
				{"D300",13},; //35
				{"D300",17},; //36
				{"D350",13},; //37
				{"D350",15},; //38
				{"D350",19},; //39
				{"D350",21},; //40
				{"D501",06},; //41
				{"D505",06},; //42
				{"D601",07},; //43
				{"D605",07},; //44
				{"F100",09},; //45
				{"F100",13},; //46
				{"F120",10},; //47
				{"F120",14},; //48
				{"F130",13},; //49
				{"F130",17},; //50
				{"F150",08},; //51
				{"F150",11},; //52
				{"F200",14},; //53
				{"F200",18},; //54
				{"F205",08},; //55
				{"F205",14},; //56
				{"F210",07},; //57
				{"F210",10},; //58
				{"F600",04},; //59
				{"M100",05},; //60
				{"M100",07},; //61
				{"M210",05},; //62
				{"M210",07},; //63
				{"M500",05},; //64
				{"M500",07},; //65
				{"M610",05},; //66
				{"M610",07},; //67
				{"1101",16},; //68
				{"1210",08},; //69
				{"1501",16},; //70
				{"1610",08},; //71
				{"F510",06},; //72
				{"F510",11},; //73
				{"F500",06},; //74
				{"F500",11},; //75
				{"F550",06},; //76
				{"F550",11},; //77
				{"F560",06},; //78
				{"F560",11}}  //79
Else
	aRet := aCpo4Dec
EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SpedCpVaz

Funcao responsável por retornar os campos dos registros que devem ser
apresentados vazios ("") quando o valor for zero.

@return aRet - Array contendo os campos.

@author joao.pellegrini
@since	13/11/2017
/*/
//-------------------------------------------------------------------
Function SpedCpVaz()

Local aRet := {}

If type("aCpoVaz") <> "A"

	aRet := {{"1510",19},;
			  {"1510",20},;
			  {"C120",04},;
			  {"C120",05},;
			  {"C300",09},;
			  {"C300",10},;
			  {"C321",09},;
			  {"C321",10},;
			  {"C350",10},;
			  {"C350",11},;
			  {"C425",06},;
			  {"C425",07},;
			  {"C460",07},;
			  {"C460",08},;
			  {"C470",10},;
			  {"C470",11},;
			  {"C500",24},;
			  {"C500",25},;
			  {"C510",19},;
			  {"C510",20},;
			  {"C600",21},;
			  {"C600",22},;
			  {"C610",15},;
			  {"C610",16},;
			  {"D500",21},;
			  {"D500",22},;
			  {"D510",18},;
			  {"D510",19},;
			  {"D600",17},;
			  {"D600",18},;
			  {"D610",16},;
			  {"D610",17}}


Else
	aRet := aCpoVaz
EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SPEDMOV()

Classe que representa um movimento a ser escriturado no SPED.

@author erick.dias
@since 08/07/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Class SPEDMOV

Data nVlCont as Numeric //Valor Contábil
Data nMatTer as Numeric //ISS material de terceiros empregado
Data nIssSub as Numeric //ISS sub empreitada
Data nIseOut as Numeric //ISS Isento/Outros
Data nBCIss as Numeric //Base de cálculo de ISS
Data nBCRet as Numeric //Base de cálculo de ISS Retido
Data nAlqIss as Numeric //Alíquota do ISS
Data nIss as Numeric //Valor do ISS
Data nIssRet as Numeric //Valor do ISS Retido
Data cRecISS as Caracter //Indicador de retenção do ISS
Data cIndOpe as Caracter //Indicador de operação
Data cIndEmi as Caracter //Indicador de emissao do documento
Data cEspeci as Caracter //Especie do documento
Data cSitDoc as Caracter //Situação do documento fiscal
Data cNumNf as Caracter //Numero da nota fiscal
Data cSerie as Caracter //Série do documento fiscal
Data dEmiss as Date //Emissao do documento fiscal
Data dCanc as Date //Data de cancelamento do documento
Data cChvNfe as Caracter //Chave da nota fiscal eletrônica
Data cMunPrs as Caracter //Código do município onde o serviço foi prestado
Data cCodObs as Caracter //Código de observação
Data cCodIss as Caracter //Código do ISS
Data cMepLes as Caracter //Indica onde o ISS será retido
Data cEstPres as Caracter //Estado de prestação do serviço
Data cMunPres as Caracter //Município de prestação do serviço
Data cEstDev as Caracter //Estado ondeo ISS é devido
Data cMunDev as Caracter //Município ondeo ISS é devido
Data cPart as Caracter //Código do participante
Data cEntSai as Caracter //Indica se é entrada ou saída

Method new() CONSTRUCTOR
Method clear()
Method setVlCont(nValue)
Method getVlCont()
Method setMatTer(nValue)
Method getMatTer()
Method setIssSub(nValue)
Method getIssSub()
Method setIseOut(nValue)
Method getIseOut()
Method setBCIss(nValue)
Method getBCIss()
Method setBCRet(nValue)
Method getBCRet()
Method setAlqIss(nValue)
Method getAlqIss()
Method setIss(nValue)
Method getIss()
Method setIssRet(nValue)
Method getIssRet()
Method setRecISS(cValue)
Method getRecISS()
Method setIndOpe(cValue)
Method getIndOpe()
Method setIndEmi(cValue)
Method getIndEmi()
Method setEspeci(cValue)
Method getEspeci()
Method setSitDoc(cValue)
Method getSitDoc()
Method setNumNf(cValue)
Method getNumNf()
Method setSerie(cValue)
Method getSerie()
Method setChvNfe(cValue)
Method getChvNfe()
Method setMunPrs(cValue)
Method getMunPrs()
Method setCodObs(cValue)
Method getCodObs()
Method setCodIss(cValue)
Method getCodIss()
Method setEmiss(dValue)
Method getEmiss()
Method setEstPres(cValue)
Method getEstPres()
Method setMunPres(cValue)
Method getMunPres()
Method setEstDev(cValue)
Method getEstDev()
Method setMunDev(cValue)
Method getMunDev()
Method setPart(cValue)
Method getPart()
Method setEntSai(cValue)
Method getEntSai()
Method setdCanc(dValue)
Method getdCanc()

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} new()

Construtor da classe

@author erick.dias
@since 08/07/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Method new() Class SPEDMOV

Self:clear()

Return Self
//-------------------------------------------------------------------
/*/{Protheus.doc} clear()

Método que limpará as propriedades da classe

@author erick.dias
@since 08/07/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Method clear() Class SPEDMOV

Self:nVlCont := 0
Self:nMatTer := 0
Self:nIssSub := 0
Self:nIseOut := 0
Self:nBCIss := 0
Self:nBCRet := 0
Self:nAlqIss := 0
Self:nIss := 0
Self:nIssRet := 0
Self:cRecISS := ""
Self:cIndOpe := ""
Self:cIndEmi := ""
Self:cEspeci := ""
Self:cSitDoc := ""
Self:cNumNf := ""
Self:cSerie := ""
Self:cChvNfe := ""
Self:cMunPrs := ""
Self:cCodObs := ""
Self:cCodIss := ""
Self:cEstPres := ""
Self:cMunPres := ""
Self:cEstDev := ""
Self:cMunDev := ""
Self:cPart := ""
Self:cEntSai	:= ""
Self:dEmiss := CTOD("  /  /    ")
Self:dCanc	:= CTOD("  /  /    ")

Return

//-----------------------------------------
Method setVlCont(nValue) Class SPEDMOV
	Self:nVlCont	:= nValue
Return
Method getVlCont() Class SPEDMOV
Return Self:nVlCont
//-----------------------------------------
Method setMatTer(nValue) Class SPEDMOV
	Self:nMatTer	:= nValue
Return
Method getMatTer() Class SPEDMOV
Return Self:nMatTer
//-----------------------------------------
Method setIssSub(nValue) Class SPEDMOV
	Self:nIssSub	:= nValue
Return
Method getIssSub() Class SPEDMOV
Return Self:nIssSub
//-----------------------------------------
Method setIseOut(nValue) Class SPEDMOV
	Self:nIseOut	:= nValue
Return
Method getIseOut() Class SPEDMOV
Return Self:nIseOut
//-----------------------------------------
Method setBCIss(nValue) Class SPEDMOV
	Self:nBCIss	:= nValue
Return
Method getBCIss() Class SPEDMOV
Return Self:nBCIss
//-----------------------------------------
Method setBCRet(nValue) Class SPEDMOV
	Self:nBCRet	:= nValue
Return
Method getBCRet() Class SPEDMOV
Return Self:nBCRet
//-----------------------------------------
Method setAlqIss(nValue) Class SPEDMOV
	Self:nAlqIss	:= nValue
Return
Method getAlqIss() Class SPEDMOV
Return Self:nAlqIss
//-----------------------------------------
Method setIss(nValue) Class SPEDMOV
	Self:nIss	:= nValue
Return
Method getIss() Class SPEDMOV
Return Self:nIss
//-----------------------------------------
Method setIssRet(nValue) Class SPEDMOV
	Self:nIssRet	:= nValue
Return
Method getIssRet() Class SPEDMOV
Return Self:nIssRet
//-----------------------------------------
Method setRecISS(cValue) Class SPEDMOV
	Self:cRecISS	:= cValue
Return
Method getRecISS() Class SPEDMOV
Return Self:cRecISS
//-----------------------------------------
Method setIndOpe(cValue) Class SPEDMOV
	Self:cIndOpe	:= cValue
Return
Method getIndOpe() Class SPEDMOV
Return Self:cIndOpe
//-----------------------------------------
Method setIndEmi(cValue) Class SPEDMOV
	Self:cIndEmi	:= cValue
Return
Method getIndEmi() Class SPEDMOV
Return Self:cIndEmi
//-----------------------------------------
Method setEspeci(cValue) Class SPEDMOV
	Self:cEspeci	:= cValue
Return
Method getEspeci() Class SPEDMOV
Return Self:cEspeci
//-----------------------------------------
Method setSitDoc(cValue) Class SPEDMOV
	Self:cSitDoc	:= cValue
Return
Method getSitDoc() Class SPEDMOV
Return Self:cSitDoc
//-----------------------------------------
Method setNumNf(cValue) Class SPEDMOV
	Self:cNumNf	:= cValue
Return
Method getNumNf() Class SPEDMOV
Return Self:cNumNf
//-----------------------------------------
Method setSerie(cValue) Class SPEDMOV
	Self:cSerie	:= cValue
Return
Method getSerie() Class SPEDMOV
Return Self:cSerie
//-----------------------------------------
Method setChvNfe(cValue) Class SPEDMOV
	Self:cChvNfe	:= cValue
Return
Method getChvNfe() Class SPEDMOV
Return Self:cChvNfe
//-----------------------------------------
Method setMunPrs(cValue) Class SPEDMOV
	Self:cMunPrs	:= cValue
Return
Method getMunPrs() Class SPEDMOV
Return Self:cMunPrs
//-----------------------------------------
Method setCodObs(cValue) Class SPEDMOV
	Self:cCodObs	:= cValue
Return
Method getCodObs() Class SPEDMOV
Return Self:cCodObs
//-----------------------------------------
Method setCodIss(cValue) Class SPEDMOV
	Self:cCodIss	:= cValue
Return
Method getCodIss() Class SPEDMOV
Return Self:cCodIss
//-----------------------------------------
Method setEmiss(dValue) Class SPEDMOV
	Self:dEmiss	:= dValue
Return
Method getEmiss() Class SPEDMOV
Return Self:dEmiss
//-----------------------------------------
Method setEstPres(cValue) Class SPEDMOV
	Self:cEstPres	:= cValue
Return
Method getEstPres() Class SPEDMOV
Return Self:cEstPres
//-----------------------------------------
Method setMunPres(cValue) Class SPEDMOV
	Self:cMunPres	:= cValue
Return
Method getMunPres() Class SPEDMOV
Return Self:cMunPres
//-----------------------------------------
Method setEstDev(cValue) Class SPEDMOV
	Self:cEstDev	:= cValue
Return
Method getEstDev() Class SPEDMOV
Return Self:cEstDev
//-----------------------------------------
Method setMunDev(cValue) Class SPEDMOV
	Self:cMunDev	:= cValue
Return
Method getMunDev() Class SPEDMOV
Return Self:cMunDev
//-----------------------------------------
Method setPart(cValue) Class SPEDMOV
	Self:cPart	:= cValue
Return
Method getPart() Class SPEDMOV
Return Self:cPart
//-----------------------------------------
Method setEntSai(cValue) Class SPEDMOV
	Self:cEntSai	:= cValue
Return
Method getEntSai() Class SPEDMOV
Return Self:cEntSai
//-----------------------------------------
Method setdCanc(dValue) Class SPEDMOV
	Self:dCanc	:= dValue
Return
Method getdCanc() Class SPEDMOV
Return Self:dCanc
//-----------------------------------------

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SPDDEFMUN()

Função responsável por retornar os municípios de prestação e incidência do ISS

@author joao.pellegrini
@since 08/07/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Function SPDDEFMUN(cEntSai, cMepLes, cEstA1A2, cMunA1A2, cEstOper, cMunOper, cEstSM0, cMunSM0)

Local aRet := {}
Local cEstPres := ""
Local cMunPres := ""
Local cEstIssDev := ""
Local cMunIssDev := ""

//---Município de prestação do serviço---//
If cEntSai == '1'
	If cMepLes $ ' 1' 				//---EP  - ISS devido no Estabelcimento do Prestador (branco tb considera EP - regra geral)---//
		cEstPres  := cEstA1A2
		cMunPres := cMunA1A2
	Else                            //---LES - ISS devido no Local de Execução do Serviço---//
		If !Empty(cMunOper)
			cEstPres  := cEstOper
			cMunPres := cMunOper
		Else
			cEstPres  := cEstSM0
			cMunPres := cMunSM0
		EndIf
	EndIf
	// Municipio de incidencia do ISS.
	// Como o EP/LES já foi avaliado acima, posso utilizar direto o valor de "cEstPres" e "cMunPres".
	cEstIssDev := cEstPres
	cMunIssDev := cMunPres
Else
	If !Empty(cMunOper)
		cEstPres  := cEstOper
		cMunPres := cMunOper
	Else
		cEstPres  := cEstA1A2
		cMunPres := cMunA1A2
	EndIf
	// Municipio de incidencia do ISS. Aqui preciso avaliar o EP/LES.
	If cMepLes $ ' 1' 			//---EP  - ISS devido no Estabelcimento do Prestador (branco tb considera EP - regra geral)---//
		cEstIssDev := cEstSM0
		cMunIssDev := cMunSM0
	Else                        //---LES - ISS devido no Local de Execução do Serviço---//
		cEstIssDev := cEstPres
		cMunIssDev := cMunPres
	EndIf
EndIf

cMunPres := Iif(Upper(cEstPres) == "EX", "", Iif(Len(Alltrim(cMunPres)) <= 5, UfCodIBGE(cEstPres) , "") + cMunPres)
cMunIssDev := Iif(Upper(cEstIssDev) == "EX", "", Iif(Len(Alltrim(cMunIssDev)) <= 5, UfCodIBGE(cEstIssDev) , "") + cMunIssDev)

// Estrutura do aRet:
// [1] - Estado de prestação do serviço.
// [2] - Município de prestação do serviço.
// [3] - Estado de incidência do ISS.
// [4] - Município de incidência do ISS.
aRet := {cEstPres, cMunPres, cEstIssDev, cMunIssDev}

Return aRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SPDCODPRO()

Função responsável guardar produtos que tiveram seus códigos alterados pelo PE SPDPROD em Hash{produto da B1, produto do PE}
cCod 	:= produto SB1
cCodPE	:= produto do PE
oHash	:= Hash de armazenamento dos produtoas alterados com código B1 e novo código do PE


@author ricardo.cavalcante
@since 29/08/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Function SPDCODPRO(cProd,cProdPE,oHashProd)

Local lRet	:= .F.

//Procura no hash
FisFindHash(oHashProd,cProd, @lRet)

//Verifica se encontrou
If !lRet
	//Adiciona
	FisAddHM(oHashProd,{cProd,cProdPE})
EndIf


Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SPDRETPRO()

Função responsável por retornar códigos novos de produtos que tiveram seus códigos alterados pelo PE SPDPROD
cProd 	:= produto SB1
oHash	:= Hash
cRetProd:= retorna o novo código do produto

@author ricardo.cavalcante
@since 29/08/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Function SPDRETPRO(cProd,oHashProd)

Local cRetProd := cProd
Local lRet	:= .F.

If lBuild
	//Procura no hash
	FisFindHash(oHashProd,cProd, @lRet)

	//Verifica se encontrou
	If lRet
		//Retorna novo código
		cRetProd := FisFindHash(oHashProd,cProd)[1][2]
	EndIf
EndIf

Return cRetProd

/*/{Protheus.doc} SpdAvalEntr
//Avalia Cliente do endereço de entrega, para Devolução
@author vitor.pires
@since 26/04/2019
@version 1.0
@return ${lRet}, ${Verdadeiro para localização do cliente}
@param cAliasSFT, characters, Alias da query sendo processada
@param lDevBen, logical, parametro usado anteriormente e trazido para a função
@param lCteD100, logical, parametro usado anteriormente e trazido para a função
@param lTpMov, logical, parametro usado anteriormente e trazido para a função
@param lMv_CliFat, logical, parametro usado anteriormente e trazido para a função
@type function
/*/
Static Function SpdAvalEntr(cAliasSFT,lDevBen,lCteD100,lTpMov,lMv_CliFat)
Local lRet := .F.
Local cChaveSFT:=''
Local aArea:={}

	If (!lDevBen .And. !lCteD100 .And. lTpMov .And. !lMv_CliFat .And. ;
		!Empty((cAliasSFT)->(FT_CLIENT+FT_LOJENT)) .And. (cAliasSFT)->(FT_CLIEFOR+FT_LOJA<>FT_CLIENT+FT_LOJENT) ).And.;
		SPEDSeek("SA1",1,xFilial("SA1")+(cAliasSFT)->(FT_CLIENT+FT_LOJENT))

		lRet := .T.

	ElseIf lDevBen .And. !Empty((cAliasSFT)->FT_NFORI)
		cChaveSFT := xFilial('SFT')+Iif((cAliasSFT)->FT_TIPOMOV=='E','S','E')+(cAliasSFT)->(FT_SERORI+FT_NFORI+FT_CLIEFOR+FT_LOJA+FT_ITEMORI+FT_PRODUTO)
		aArea:=SFT->(getArea())
		SFT->(dbSetOrder(1)) //FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
		If SFT->(dbSeek(cChaveSFT))
			If !Empty(SFT->(FT_CLIENT+FT_LOJENT))
			 	If !(SFT->(FT_CLIEFOR+FT_LOJA == FT_CLIENT+FT_LOJENT))
			 		If SPEDSeek("SA1",1,xFilial("SA1")+SFT->(FT_CLIENT+FT_LOJENT))
			 			lRet := .T.
			 		EndIf
		 		EndIf
	 		EndIf
 		EndIf
		SFT->(RestArea(aArea))
	EndIf

Return(lRet)
