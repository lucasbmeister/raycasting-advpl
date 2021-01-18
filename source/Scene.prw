#include "totvs.ch"
#include "gameadvpl.ch"

/*
{Protheus.doc} Class Scene
Classe que representa uma cena. Ela é  responsável por armazenar os objetos de uma
cena e realizar operações de atualizções por frame. Ela também atualiza a poição
da câmera
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Class Scene

    Data aObjects
    Data oParent
    Data lActive
    Data cId
    Data nLeft
    Data nTop
    Data nHeight
    Data nWidth
    Data bLoadObjects
    Data cDescription
    Data nCameraPostion
    Data lEditorScene
    Data cSceneJson
    Data oGameManager

    Method New() Constructor
    Method GetSceneID()
    Method AddObject()
    Method GetSceneWindow()
    Method Update()
    Method Start()
    Method EndScene()
    Method SetInitCodeBlock()
    Method GetDimensions()
    Method SetActive()
    Method IsActive()
    Method ClearScene()
    Method GetObjectsWithColliders()
    Method SetDescription()
    Method GetDescription()
    Method UpdateCamera()
    Method IsGameObject()
    Method SetEditorScene()
    Method IsEditorScene()
    Method SetSceneJson()
    Method SetGameManager()
    Method LoadFromEditor()

EndClass

/*
{Protheus.doc} Method New(oWindow, cId, nTop, nLeft, nHeight, nWidth) Class Scene
Instância classe Scene
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method New(oWindow, cId, nTop, nLeft, nHeight, nWidth) Class Scene

    Static oInstance as object

    Default nLeft := 180
    Default nTop := 180
    Default nHeight := 550
    Default nWidth := 700

    oInstance := Self
    ::oParent := oWindow

    ::nLeft := nLeft
    ::nTop := nTop
    ::nHeight := nHeight
    ::nWidth := nWidth
    ::cId := cId
    ::cDescription := cId
    ::nCameraPostion := nil
    ::lEditorScene := .F.

    ::aObjects := {}

    ::SetActive(.F.)

Return

/*
{Protheus.doc} Method GetSceneID() Class Scene
Retorna ID único da cena.
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method GetSceneID() Class Scene
Return ::cId

/*
{Protheus.doc} Method Update(oGameManager) Class Scene
Realiza as lógicas de atualização de frame de cada objeto e remove objetos
marcados para destruição
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method Update(oGameManager) Class Scene

    Local nX as numeric

    For nX := Len(::aObjects)  To 1 STEP -1
        If ::IsActive()
            //::aObjects[nX]:Update(oGameManager)
            If MethIsMemberOf(::aObjects[nX], 'Update')
                ::aObjects[nX]:Update(oGameManager)
            EndIf
            //If ::aObjects[nX]:ShouldDestroy()
            If !Empty(::aObjects) .and. MethIsMemberOf(::aObjects[nX], 'ShouldDestroy', .T.) .and. ::aObjects[nX]:ShouldDestroy()
                FreeObj(::aObjects[nX])
                ADel(::aObjects, nX)
                ASize(::aObjects, Len(::aObjects) - 1)
            EndIf
        Else
            Exit
        EndIf
    Next nX

Return

/*
{Protheus.doc} Method AddObject(oObject) Class Scene
Adiciona um objeto na cena
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method AddObject(oObject) Class Scene
    Aadd(::aObjects, oObject)
Return

/*
{Protheus.doc} Method Start() CLass Scene
Inicia a cena, chamandoo o bloco de código de construção
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method Start() CLass Scene
    ::ClearScene()
    ::SetActive(.T.)

    If ::IsEditorScene()
        ::LoadFromEditor()
    Else
        Eval(::bLoadObjects, Self)
    EndIf

Return

/*
{Protheus.doc} Method EndScene() Class Scene
Encerra uma cena limpando seus objetos
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method EndScene() Class Scene
    ::SetActive(.F.)
    ::ClearScene()
Return

/*
{Protheus.doc} Method GetSceneWindow() Class Scene
Retorna janela pai da cena
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method GetSceneWindow() Class Scene
Return ::oParent

/*
{Protheus.doc} Method SetInitCodeBlock(bBlock) Class Scene
Define bloco de código que será executado no método ::Start()
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method SetInitCodeBlock(bBlock) Class Scene
    ::bLoadObjects := bBlock
Return

/*
{Protheus.doc} Method GetDimensions() Class Scene
Retorna array dimensões da cena
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method GetDimensions() Class Scene
Return { ::nTop, ::nLeft, ::nHeight, ::nWidth}

/*
{Protheus.doc} Method SetActive(lActive) Class Scene
Maraca a cena como ativa
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method SetActive(lActive) Class Scene
    ::lActive := lActive
Return

/*
{Protheus.doc} Method IsActive() Class Scene
Verifica se a cena está ativa
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method IsActive() Class Scene
Return ::lActive

/*
{Protheus.doc} Method ClearScene() Class Scene
Limpa a cena, eliminando todos os objetos
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method ClearScene() Class Scene
    //AEval(::aObjects,{|x| x:HideGameObject(), FreeObj(x) })
    AEval(::aObjects,{|x| IIF(MethIsMemberOf(x, 'HideGameObject', .T.),x:HideGameObject(), x:Hide()), FreeObj(x) })
    ASize(::aObjects , 0)
Return

/*
{Protheus.doc} Method GetObjectsWithColliders() Class Scene
Retorna todos os objetos que possuem colisões ativas
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method GetObjectsWithColliders() Class Scene
    Local aObjColl as array
    aObjColl := {}

    AEval(::aObjects,{|x| IIF(x:HasCollider(), AAdd(aObjColl, x), nil)})

Return aObjColl

/*
{Protheus.doc} Method SetDescription(cDesc) Class Scene
Define descrição da cena
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method SetDescription(cDesc) Class Scene
    ::cDescription := cDesc
Return

/*
{Protheus.doc} Method GetDescription() Class Scene
Retorna descrição da cena
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method GetDescription() Class Scene
Return ::cDescription

/*
{Protheus.doc} Method UpdateCamera(oGame, cDirection, nSpeed) Class Scene
Atualiza posição da câmera
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method UpdateCamera(oGame, cDirection, nSpeed) Class Scene

    Local nX as numeric

    If cDirection == 'forward'
        nSpeed := -nSpeed
    EndIF

    If ::nCameraPostion == nil
        ::nCameraPostion := oGame:GetMidScreen()
    EndIf

    For nX := 1 To Len(::aObjects)
        If ::IsGameObject(::aObjects[nX]) .and.::aObjects[nX]:GetTag() != 'background'
            // If ::nCameraPostion - oGame:GetStartLimit() >= oGame:GetMidScreen() .or.;
            //         oGame:GetEndLimit() - ::nCameraPostion <= oGame:GetMidScreen()
            ::aObjects[nX]:oGameObject:nLeft += nSpeed
            //EndIf
        EndIf
    Next
    
    ::nCameraPostion += nSpeed

Return

/*
{Protheus.doc} Method IsGameObject(oObject) Class Scene
Verifica se objeto é um objeto de jogo
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method IsGameObject(oObject) Class Scene
REturn AttIsMemberOf(oObject, 'oGameObject', .T.) .and. MethIsMemberOf(oObject, 'GetTag', .T.) .and. !Empty(oObject:oGameObject)

/*
{Protheus.doc} Method IsGameObject(oObject) Class Scene
Verifica se objeto é um objeto de jogo
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method SetEditorScene(lEditorScene) Class Scene
    ::lEditorScene := lEditorScene
Return

/*
{Protheus.doc} Method IsGameObject(oObject) Class Scene
Verifica se objeto é um objeto de jogo
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method IsEditorScene() Class Scene
Return ::lEditorScene

/*
{Protheus.doc} Method SetObjects() Class Scene
Define configurações dos objetos de jogos armazenadas no json do editor
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method SetSceneJson(cJsonFile) Class Scene
    ::cSceneJson := cJsonFile
Return

/*
{Protheus.doc} Method IsGameObject(oObject) Class Scene
Verifica se objeto é um objeto de jogo
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method SetGameManager(oGame) Class Scene
    ::oGameManager := oGame
Return

/*
{Protheus.doc} Method LoadFromEditor() Class Scene
Carrega objetos com base nos objetos do editor
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method LoadFromEditor() Class Scene

    Local nX as numeric
    Local oObject as object
    Local oJson as object
    Local oWindow as object
    Local oPlayerLife as object
    Local oPlayerScore as object
    Local aDimensions as array
    
    aDimensions := ::GetDimensions()
    oWindow := ::GetSceneWindow()
    oScene := U_SceneFromJson(::cSceneJson)

    For nX := 1 To Len(oScene['objects'])
        oJson := oScene['objects'][nX]

        oObject := &(oJson['className'] + '():New(oWindow, ' + cValToChar(oJson['top'])  + ','+ cValToChar(oJson['left']) +')')

        oObject:oGameObject:nWidth := oJson['width']
        oObject:oGameObject:nHeight := oJson['height']

        If oJson['hasCollider']
            oObject:SetColliderMargin(oJson['topMargin'], oJson['leftMargin'], oJson['bottomMargin'], oJson['rightMargin'])
        EndIf

        //oObject:SetTag(oJson['tag'])

        AAdd(::aObjects, oObject)
    Next
    
    AEval(::aObjects,{|x| IIF(x:GetTag() == 'background', x:oGameObject:MoveToBottom(), nil)},/*nStart*/,/*nCount*/)

    oPlayerLife := PlayerLife():New(oWindow, 12, 5, 30, 60)
    oPlayerLife:SetTag('background')

    oPlayerScore := PlayerScore():New(oWindow, 12, (aDimensions[WIDTH] / 2) - 85, 30, 60, ::oGameManager)
    oPlayerScore:SetTag('background')

    ::oGameManager:UpdateLife(100, .T.)
    ::oGameManager:UpdateScore(0, .T.)

    AAdd(::aObjects, oPlayerLife)
    AAdd(::aObjects, oPlayerScore)


Return