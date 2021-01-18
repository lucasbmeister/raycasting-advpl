#include "totvs.ch"
#include "gameadvpl.ch"

/*
{Protheus.doc} Class GameManager
Classe que gerencia o jogo. Faz a comunicação com loop de jogo e
também de dados que devem ser persistidos entre cenas
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Class GameManager From LongNameClass

    Data oKeys
    Data oActiveScene
    Data nDeltaTime
    Data aScenes
    Data oWindow
    Data cGameName
    Data oWebChannel
    Data oWebEngine
    Data nTop
    Data nLeft
    Data nHeight
    Data nWidth
    Data nPlayerScore
    Data nPlayerLife

    Data lCameraUpdate
    Data cCameraDirection
    Data nCameraSpeed

    Data oStartLimit
    Data oEndLimit

    Data IsPaused

    Data oPauseMenu

    Method New() Constructor
    Method AddScene()
    Method SetActiveScene()
    Method GetActiveScene()
    Method LoadScene()
    Method Start()
    Method SetPressedKeys()
    Method GetPressedKeys()
    Method GetMainWindow()
    Method GetDimensions()
    Method StartEngine()
    Method Update()
    Method HandleEvent()
    Method ExportAssets()
    Method Processed()
    Method GetColliders()
    Method UpdateScore()
    Method GetScore()
    Method UpdateLife()
    Method GetLife()
    Method GameOver()
    Method SetCameraUpdate()
    Method ShouldUpdateCamera()
    Method GetMidScreen()
    Method SetCameraLimits()
    Method GetStartLimit()
    Method GetEndLimit()
    Method IsPaused()
    Method SetPaused()
    Method ShowPauseMenu()
    Method HidePauseMenu()
    Method CheckPause()
    Method PlaySound()
    Method GetSoundList()

EndClass

/*
{Protheus.doc} Method New(cGameName, nTop, nLeft, nHeight, nWidth) Class GameManager
Instância classe GameManager
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method New(cGameName, nTop, nLeft, nHeight, nWidth) Class GameManager

    Static oInstance as object
    Default cGameName := "Game 2D"
    Default nTop := 180
    Default nLeft := 180
    Default nHeight := 550
    Default nWidth := 700

    ::nPlayerScore := 0
    ::nPlayerLife := 0

    ::nTop := nTop
    ::nLeft := nLeft
    ::nHeight := nHeight
    ::nWidth := nWidth

    ::oStartLimit := nil
    ::oEndLimit := nil

    ::cGameName := cGameName
    ::aScenes := {}
    ::oKeys := JsonObject():New()

    ::lCameraUpdate := .F.
    ::cCameraDirection := ''
    ::nCameraSpeed := 0

    ::nDeltaTime := 0

    oInstance := Self

    ::oWindow := TDialog():New(::nTop ,::nLeft, ::nHeight,::nWidth,::cGameName ,,,,,CLR_BLACK,CLR_WHITE,,,.T.)

    ::ExportAssets()

Return Self

/*
{Protheus.doc} Method AddScene(oScene) Class GameManager
Adiciona uma nova cena no jogo
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method AddScene(oScene) Class GameManager
    Aadd(::aScenes, oScene)
Return

/*
{Protheus.doc} Method GetMainWindow() Class GameManager
Retorna dialog criado para o jogo
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method GetMainWindow() Class GameManager
Return ::oWindow

/*
{Protheus.doc} Method Start(cFirstScene) Class GameManager
Inicia o jogo com a primeira cena configurada por parâmetro
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method Start(cFirstScene) Class GameManager

    Local nPos as numeric
    Static oInstance as object

    oInstance := Self

    nPos := AScan(::aScenes,{|x| x:GetSceneID() == cFirstScene })

    ::SetActiveScene(::aScenes[nPos])

    ::oWindow:bStart := {||::aScenes[nPos]:Start(),  oInstance:StartEngine() }
    ::oWindow:Activate()

Return

/*
{Protheus.doc} Method StartEngine() Class GameManager
Inicia motor web para loop de jogo em JS.
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method StartEngine() Class GameManager

    Static oInstance as object
    Local cLink as char

    oInstance := Self

    cLink := GetTempPath() + "gameadvpl\gameadvpl.html"

    ::oWebChannel := TWebChannel():New()
    ::oWebChannel:Connect()

    If !::oWebChannel:lConnected
        UserException("Erro na conexao com o WebSocket")
        Return
    EndIf

    ::oWebChannel:bJsToAdvpl := {|self,codeType,codeContent| oInstance:HandleEvent(self, codeType, codeContent)}

    //::oWebEngine := TWebEngine():New(oInstance:oWindow, 0, 0, ::nWidth, 10,,::oWebChannel:nPort)
    ::oWebEngine := TWebEngine():New(oInstance:oWindow, 0, 0, ::nWidth, 10,,::oWebChannel:nPort)
    ::oWebEngine:Navigate(cLink)

Return

/*
{Protheus.doc} Method HandleEvent(oWebChannel, codeType, codeContent) Class GameManager
Método que age como proxy entre as requisições JS e Advpl
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method HandleEvent(oWebChannel, codeType, codeContent) Class GameManager

    If codeType == "start"
        ::oWebChannel:advplToJs("started", "true")
    ElseIf codeType == "update"
        ::Update(oWebChannel, codeType, Upper(codeContent))
    ElseIf codeType == "load_assets"
        ::oWebChannel:advplToJs("assets", ::GetSoundList())
    EndIf

Return

/*
{Protheus.doc} Method SetPressedKeys(oKeys) Class GameManager
Define quais as teclas pressionadas em determinado frame
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method SetPressedKeys(oKeys) Class GameManager
    ::oKeys := oKeys
REturn

/*
{Protheus.doc} Method GetPressedKeys() Class GameManager
Retorna as teclas pressionadas em determinado frame
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method GetPressedKeys() Class GameManager
Return ::oKeys

/*
{Protheus.doc} Method Update(oWebChannel, codeType, codeContent) Class GameManager
Method executa em cada frame responsável por passar a informações que os objetos devem ser atualizados
dentro da cena e também avisar o loop de jogo em JS que processamento do frame foi concluído
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method Update(oWebChannel, codeType, codeContent) Class GameManager

    Local oKeys as object
    Local oActiveScene as object

    oKeys := JsonObject():New()

    oKeys:FromJson(Lower(codeContent))

    ::CheckPause()

    oActiveScene := ::GetActiveScene()

    ::SetPressedKeys(oKeys)
    ::nDeltaTime := TimeCounter() - ::nDeltaTime

    If !::IsPaused()
        oActiveScene:Update(Self)
    EndIf

    If ::ShouldUpdateCamera()
        //basicamente move todos os objetos na direção contrário do player (incluindo o player)
        oActiveScene:UpdateCamera(Self, ::cCameraDirection, ::nCameraSpeed)
        ::SetCameraUpdate(.F.)
    EndIf

    ::Processed()

Return

/*
{Protheus.doc} Method Processed()  Class GameManager
Avisar o loop de jogo em JS que processamento do frame foi concluído
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method Processed()  Class GameManager
    ::oWebChannel:advplToJs("processed", "true")
Return

/*
{Protheus.doc} Method GetDimensions() Class GameManager
Retorna array com dimensões da tela de jogo
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method GetDimensions() Class GameManager
Return {::nTop, ::nLEft, ::nHeight, ::nWidth}

/*
{Protheus.doc} Method ExportAssets() Class GameManager
Exporta os assests (sprites, js, html) de jogo para o diretório temporário do computador
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method ExportAssets() Class GameManager

    Local cTempPath as char
    Local cFile as char

    cTempPath := GetTempPath()
    cFile := "gameadvpl.app"

    If !Resource2File(cFile,  cTempPath + cFile)
        UserException("Nao foi possivel copiar o arquivo "+cFile+" para o diretorio temporario")
        Return
    EndIf

    If !ExistDir(cTempPath + "gameadvpl\" )
        If MakeDir(cTempPath + "gameadvpl\" ) != 0
            UserException("Nao foi criar o diretorio" + cTempPath + "gameadvpl\")
            Return
        EndIf
    EndIf

    FUnzip(cTempPath + cFile, cTempPath + "gameadvpl\")

Return

/*
{Protheus.doc} Method SetActiveScene(oScene) Class GameManager
Define qual cena está ativa no momento
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method SetActiveScene(oScene) Class GameManager
    ::oActiveScene := oScene
Return

/*
{Protheus.doc} Method GetActiveScene() Class GameManager
Retorna a cena atva
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method GetActiveScene() Class GameManager
Return ::oActiveScene

/*
{Protheus.doc} Method LoadScene(cSceneID) Class GameManager
Carrega uma cena no jogo. Caso exista uma cena aberta, ela é encerrada antes de
ser aberta a nova
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method LoadScene(cSceneID) Class GameManager

    Local nPos as numeric

    nPos := AScan(::aScenes,{|x| x:GetSceneID() == cSceneID })

    If !Empty(::oActiveScene)
        ::oActiveScene:EndScene()
    EndIf

    ::SetActiveScene(::aScenes[nPos])
    ::oActiveScene:Start()

    ::PlaySound('menu_loop')

    ::oWebEngine:SetFocus()
    ProcessMessage()

Return

/*{Protheus.doc} Method GetColliders() Class GameManager
Retorna todos os objetos da cena ativa que possuam colisão ativada
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method GetColliders() Class GameManager
Return ::GetActiveScene():GetObjectsWithColliders()

/*{Protheus.doc} Method GameOver() Class GameManager
(WIP) Caso o player morra, apresenta tela de gameover
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method GameOver() Class GameManager

    Local oSay as object
    Local cText as char
    Local oFont32 as object

    oFont32 := TFont():New('Impact',, -32,.T.)

    cText := "GAME OVER"

    oSay := TSay():New(130, ::GetMidScreen() - 370,{||cText}, ::oWindow,,oFont32,,,,.T.,CLR_WHITE,CLR_BLACK,100,50,,,,,,.T.)
    oSay:SetTextAlign(2,2)
    oSay:MoveToTop()

    ProcessMessage()
    oSay:Refresh()

    Sleep(4000)

    oSay:Hide()
    FreeObj(oSay)

    ::UpdateLife(100, .T.)
    ::UpdateScore(0, .T.)

    ::LoadScene(::GetActiveScene():GetSceneID())

Return

/*{Protheus.doc} Method UpdateScore(nValue) Class GameManager
Atualiza váriavel com pontuação do player
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method UpdateScore(nValue, lSet) Class GameManager
    
    Default lSet := .F.

    If !lSet
        ::nPlayerScore += nValue
    Else
        ::nPlayerScore := nValue
    EndIF

Return ::nPlayerScore

/*{Protheus.doc} Method GetScore() Class GameManager
Retorna pontuação do player
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method GetScore() Class GameManager
Return ::nPlayerScore

/*{Protheus.doc} Method UpdateLife(nLife) Class GameManager
Atualiza váriavel com vida do player
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method UpdateLife(nLife, lSet) Class GameManager

    Default lSet := .F.

    If !lSet
        ::nPlayerLife += nLife
    Else
        ::nPlayerLife := nLife
    EndIf

Return ::nPlayerLife

/*{Protheus.doc} Method GetLife() Class GameManager
Retorna vida do player
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method GetLife() Class GameManager
Return ::nPlayerLife

/*{Protheus.doc} Method SetCameraUpdate(lUpdate, cDirection, nSpeed) Class GameManager
Define que a câmera deve ser atualizada antes do fim de processamento do frame
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method SetCameraUpdate(lUpdate, cDirection, nSpeed) Class GameManager
    ::lCameraUpdate := lUpdate
    ::cCameraDirection := cDirection
    ::nCameraSpeed := nSpeed
Return

/*{Protheus.doc} Method ShouldUpdateCamera() Class GameManager
Retorna se câmera deve ser atualizada
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method ShouldUpdateCamera() Class GameManager
Return ::lCameraUpdate

/*{Protheus.doc} Method GetMidScreen() Class GameManager
Retorna meio da tela
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method GetMidScreen() Class GameManager
Return ::oWindow:nWidth / 2

/*{Protheus.doc} Method SetCameraLimits(oStartLimit, oEndLimit) Class GameManager
Define objetos que representam os limites da área de jogo
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method SetCameraLimits(oStartLimit, oEndLimit) Class GameManager
    ::oStartLimit := oStartLimit
    ::oEndLimit := oEndLimit
Return

/*{Protheus.doc} Method GetStartLimit() Class GameManager
Retorna coordenada de limite inicial (esquerdo) da area de jogo
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method GetStartLimit() Class GameManager

    Local nLimit as numeric

    If Empty(::oStartLimit)
        nLimit := ::oWindow:nLeft
    Else
        nLimit := ::oStartLimit:oGameObject:nLeft
    EndIf

Return nLimit

/*{Protheus.doc} Method GetEndLimit() Class GameManager
Retorna coordenada de limite final (direita) da area de jogo
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method GetEndLimit() Class GameManager

    Local nLimit as numeric

    If Empty(::oStartLimit)
        nLimit := ::oWindow:nWidth
    Else
        nLimit := ::oEndLimit:oGameObject:nLeft
    EndIf

Return nLimit

/*{Protheus.doc} Method IsPaused() Class GameManager
Retorna se jogo está pausado
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method IsPaused() Class GameManager
Return ::IsPaused

/*{Protheus.doc} Method SetPaused(lPause) Class GameManager
Define se jogo está pausado ou não
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method SetPaused(lPause) Class GameManager
    ::IsPaused := lPause
Return

/*{Protheus.doc} Method ShowPauseMenu() Class GameManager
Mostra menu de pausa
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method ShowPauseMenu() Class GameManager
    ::oPauseMenu := PausePanel():New(::oWindow, Self)
Return

/*{Protheus.doc} Method HidePauseMenu() Class GameManager
Esconde menu de pausa
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method HidePauseMenu() Class GameManager
    ::oPauseMenu:HideGameObject()
    FreeObj(::oPauseMenu)
Return

/*{Protheus.doc} Method CheckPause() Class GameManager
Verifica se tecla de pause foi pressionada
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method CheckPause() Class GameManager

    Local oKeys as char
    Local oActiveScene as object

    oKeys := ::GetPressedKeys()
    oActiveScene := ::GetActiveScene()

    If !(oActiveScene:GetSceneID() $ 'editor;menu;levels')
        If oKeys['p'] .and. !::IsPaused()
            ::SetPaused(.T.)
            ::ShowPauseMenu()
        EndIf
    EndIf

Return

/*{Protheus.doc} Method PlaySound(cSound) Class GameManager
Manda comando para JS executar um som
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method PlaySound(cSound) Class GameManager

    ::oWebChannel:advplToJs("play_sound", cSound)

Return

/*{Protheus.doc} Method GetSoundList() Class GameManager
Retora lista de sons disponiveis
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method GetSoundList() Class GameManager

    Local oList as object
    Local aFiles as array
    Local aSizes as array
    Local cPath as char
    Local oSound as object
    Local nX as numeric

    cPath := GetTempPath() + 'gameadvpl\assets\sounds\'

    aFiles := {}
    aSizes := {}

    ADir(cPath + "*.mp3", @aFiles, @aSizes)

    If Empty(aFiles)
        aFiles := {}
    EndIf

    For nX := 1 To Len(aFiles)
        oSound := JsonObject():New()
        oSound['file'] := Lower(SubStr(aFiles[nX],1,At('.',aFiles[nX]) - 1))
        oSound['path'] := 'assets/sounds/' + aFiles[nX]

        aFiles[nX] := oSound
    Next

    oList := JsonObject():New()

    oList['sounds'] := aFiles

Return oList:ToJson()
