#include "totvs.ch"

/*
{Protheus.doc} Class BaseGameObject
Classe base para todos os objetos de jogo
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Class BaseGameObject From LongNameClass

    Data cAssetsPath
    Data oWindow
    Data cTag
    Data oGameObject
    Data oCollider
    Data cInternalId
    Data lDestroy

    Data oAnimations

    //fisica
    Data lHasCollider

    Data nTopMargin
    Data nLeftMargin
    Data nBottomMargin
    Data nRightMargin

    Data nHalfHeight
    Data nHalfWidth

    Data nDY
    Data nDX

    Data nMass

    Method New() Constructor
    Method SetWindow()
    Method SetTag()
    Method GetTag()
    Method GetAssetsPath()
    Method LoadFrames()
    Method SetSize()
    Method GetInternalId()
    Method GetHeight()
    Method GetWidth()

    //fisica
    Method SetColliderMargin()
    Method HasCollider()
    Method GetMidX()
    Method GetMidY()
    Method GetTop()
    Method GetLeft()
    Method GetRight()
    Method GetBottom()
    Method GetMass()
    Method Destroy()
    Method SetLeftClickAction()
    Method SetRightClickAction()
    Method ShouldDestroy()
    Method SetTopMargin()
    Method SetLeftMargin()
    Method SetBottomMargin()
    Method SetRightMargin()
    Method SetTop()
    Method SetLeft()
    Method SetHeight()
    Method SetWidth()
    Method MoveUp()
    Method MoveLeft()
    Method MoveDown()
    Method MoveRight()
    Method EnableEditorCollider()
    Method DisableEditorCollider()
    Method UpdateEditorCollider()
    Method HideEditorCollider() 

EndClass

/*
{Protheus.doc} Method New(oWindow)
Classe não é instânciada diretamente. Deve ser herdada por outros objetos
e chamados o método _Super:New()
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method New(oWindow) Class BaseGameObject
    Local cTempPath as char

    cTempPath := GetTempPath()
    ::cAssetsPath := cTempPath + "gameadvpl\assets\

    if !Empty(oWindow)
        ::SetWindow(oWindow)
    EndIf

    ::cInternalId := UUIDRandom()
    ::lHasCollider := .F.
    ::lDestroy := .F.
    ::nDY := 0
    ::nDX := 0

    ::nTopMargin := 0
    ::nLeftMargin := 0
    ::nBottomMargin := 0
    ::nRightMargin := 0

Return Self

/*
{Protheus.doc} Method SetWindow(oWindow)
Define a janela utilizada pelo objeto
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method SetWindow(oWindow) Class BaseGameObject
    ::oWindow := oWindow
Return 

/*
{Protheus.doc} Method GetAssetsPath(cAsset)
Retorna o caminho da pasta com assets do objeto
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method GetAssetsPath(cAsset) Class BaseGameObject
Return ::cAssetsPath + cAsset

/*
{Protheus.doc} Method LoadFrames(cEntity)
Carrega todos os caminhos de frames em um array para utilização em animações
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method LoadFrames(cEntity) Class BaseGameObject

    Local cPath as char
    Local nX as numeric
    Local nY as numeric
    Local aDirectory as array
    Local aAnimations as array
    Local aFramesForward as array
    Local aFramesBackward as array
    Local cTempPath as char

    ::oAnimations := JsonObject():New()

    cPath := ::GetAssetsPath(cEntity + "\animation\")

    aDirectory := Directory(cPath + "*.*", "D",,.F.)
    cTempPath := StrTran(cPath, "\", "/")
    aAnimations := {}

    If !Empty(aDirectory)

        AEval(aDirectory, { |x| IIF(x[5] == 'D', Aadd(aAnimations, x[1]), nil)}, 3)

        For nX := 1 To Len(aAnimations)
            // tem que existir pelo menos um estado
            aFramesForward := Directory(cPath + aAnimations[nX] + "\forward\*.png", "A",,.F.)
            aFramesBackward := Directory(cPath + aAnimations[nX] + "\backward\*.png", "A",,.F.)
            // se for animação deve existir pelo menos a direção forward
            For nY := 1 To Len(aFramesForward)
                aFramesForward[nY] := cTempPath + aAnimations[nX] + "/forward/" + aFramesForward[nY][1]
                If !Empty(aFramesBackward)
                    aFramesBackward[nY] := cTempPath + aAnimations[nX] + "/backward/" + aFramesBackward[nY][1]
                EndIf
            Next nY

            ::oAnimations[aAnimations[nX]] := JsonObject():New()
            ::oAnimations[aAnimations[nX]]['forward'] := aFramesForward
            
            If !Empty(aFramesBackward)
                ::oAnimations[aAnimations[nX]]['backward'] := aFramesBackward
            EndIf

        Next nX

    EndIf

Return 

/*
{Protheus.doc} Method SetTag(cTag)
Define um tag para o objeto
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method SetTag(cTag) Class BaseGameObject
    ::cTag := cTag
Return

/*
{Protheus.doc} Method GetTag()
Retorna qual a tag definida
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method GetTag() Class BaseGameObject
Return ::cTag

/*
{Protheus.doc} Method SetColliderMargin(nTopMargin, nLeftMargin, nBottomMargin, nRightMargin)
Define qual a margem entre a borda do objeto e a área de colisão. Isso e necessário
porque a sprite não corresponde exatamente ao tamanho do objeto de tela
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method SetColliderMargin(nTopMargin, nLeftMargin, nBottomMargin, nRightMargin) Class BaseGameObject

    If nTopMargin != Nil .and. nLeftMargin == Nil .and. nBottomMargin == Nil .and. nRightMargin == Nil

        ::nTopMargin := ::nLeftMargin := ::nBottomMargin := ::nRightMargin := nTopMargin

    ElseIf nTopMargin != Nil .and. nLeftMargin != Nil .and. nBottomMargin == Nil .and. nRightMargin == Nil

        ::nTopMargin := ::nBottomMargin := nTopMargin
        ::nLeftMargin := ::nRightMargin := nLeftMargin
        
    Else
        ::nTopMargin := nTopMargin
        ::nLeftMargin := nLeftMargin
        ::nBottomMargin := nBottomMargin
        ::nRightMargin := nRightMargin
    EndIf

    ::nHalfHeight := (::oGameObject:nHeight + ::nTopMargin + ::nBottomMargin) * 0.5
    ::nHalfWidth := (::oGameObject:nWidth + ::nLeftMargin + ::nRightMargin) * 0.5

    ::lHasCollider := .T.

Return

/*
{Protheus.doc} Method HasCollider()
Verifica se objeto possui colisão ativada
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method HasCollider() Class BaseGameObject
Return ::lHasCollider

/*
{Protheus.doc} Method GetMidX()
Retorna meio do objeto no eixo X
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method GetMidX() Class BaseGameObject
Return ::nHalfWidth + ::oGameObject:nLeft

/*
{Protheus.doc} Method GetMidY()
Retorna meio do objeto no eixo Y
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method GetMidY() Class BaseGameObject
Return ::nHalfHeight + ::oGameObject:nTop

/*
{Protheus.doc} Method GetTop(lMargin)
Retorna coordenada do nTop do objeto com margem, caso possua.
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method GetTop(lMargin) Class BaseGameObject
Return ::oGameObject:nTop + IIF(lMargin, ::nTopMargin, 0)

/*
{Protheus.doc} Method GetLeft(lMargin)
Retorna coordenada nLeft do objeto com margem, caso possua.
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method GetLeft(lMargin) Class BaseGameObject
Return ::oGameObject:nLeft + IIF(lMargin, ::nLeftMargin, 0)

/*
{Protheus.doc} Method GetRight(lMargin) 
Retorna coordenada nRight do objeto com margem, caso possua.
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method GetRight(lMargin) Class BaseGameObject
Return ::oGameObject:nLeft + ::oGameObject:nWidth + IIF(lMargin, ::nRightMargin, 0)

/*
{Protheus.doc} Method GetBottom(lMargin)
Retorna coordenada nBottom do objeto com margem, caso possua.
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method GetBottom(lMargin) Class BaseGameObject
Return ::oGameObject:nTop + ::oGameObject:nHeight + IIF(lMargin, ::nBottomMargin, 0)

/*
{Protheus.doc} Method GetInternalId()
Retorna Id único do objeto
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method GetInternalId() Class BaseGameObject
Return ::cInternalId

/*
{Protheus.doc} Method Destroy()
Marca objeto para destruição
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method Destroy() Class BaseGameObject
    ::lDestroy := .T.
Return 

/*
{Protheus.doc} Method ShouldDestroy() 
Verifica se objeto deve ser destruído
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method ShouldDestroy() Class BaseGameObject
Return ::lDestroy

/*
{Protheus.doc} Method GetHeight()
Retorna propriedade nHeight do objeto
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method GetHeight() Class BaseGameObject
Return ::oGameObject:nHeight

/*
{Protheus.doc} Method GetWidth()
Retorna propriedade nWidth do objeto
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method GetWidth() Class BaseGameObject
Return ::oGameObject:nWidth

/*
{Protheus.doc} Method GetMass()
Retorna massa do objeto
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method GetMass() Class BaseGameObject
Return ::nMass

/*
{Protheus.doc} Method SetLeftClickAction(bBlock)
Define bloco de ação a ser executado quando clicado com o botão esquerdo
do mouse sobre o objeto
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method SetLeftClickAction(bBlock) Class BaseGameObject
    ::oGameObject:bLClicked := bBlock
Return

/*
{Protheus.doc} Method SetRightClickAction(bBlock) 
Define bloco de ação a ser executado quando clicado com o botão direito
do mouse sobre o objeto
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method SetRightClickAction(bBlock) Class BaseGameObject
    ::oGameObject:bRClicked := bBlock
Return

/*
{Protheus.doc} Method SetTopMargin(nTopMargin) Class BaseGameObject
Define margem superior do objeto
do mouse sobre o objeto
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method SetTopMargin(nTopMargin) Class BaseGameObject

    ::oCollider:nTop -= ::nTopMargin
    ::oCollider:nHeight += ::nTopMargin

    ::oCollider:nTop += nTopMargin
    ::oCollider:nHeight -= nTopMargin

    ::nTopMargin := nTopMargin

Return

/*
{Protheus.doc} Method SetLeftMargin(nLeftMargin) Class BaseGameObject
Define margem esquerda do objeto
do mouse sobre o objeto
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method SetLeftMargin(nLeftMargin) Class BaseGameObject

    ::oCollider:nLeft -= ::nLeftMargin
    ::oCollider:nWidth += ::nLeftMargin

    ::oCollider:nLeft += nLeftMargin
    ::oCollider:nWidth -= nLeftMargin

    ::nLeftMargin := nLeftMargin

Return

/*
{Protheus.doc} Method SetObjectBottomMargin(nBottomMargin) Class GameEditor
Define margem inferior do objeto
do mouse sobre o objeto
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method SetBottomMargin(nBottomMargin) Class BaseGameObject

    ::oCollider:nHeight -= ::nBottomMargin

    ::oCollider:nHeight += nBottomMargin

    ::nBottomMargin := nBottomMargin

Return

/*
{Protheus.doc} Method SetRightMargin(nRightMargin) Class BaseGameObject
Define margem direita do objeto
do mouse sobre o objeto
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method SetRightMargin(nRightMargin) Class BaseGameObject

    ::oCollider:nWidth -= ::nRightMargin

    ::oCollider:nWidth += nRightMargin

    ::nRightMargin := nRightMargin

Return

/*
{Protheus.doc} Method EnableEditorCollider() Class BaseGameObject
Habilita objeto de visualização de margem no editor de cenas
do mouse sobre o objeto
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method EnableEditorCollider() Class BaseGameObject

    Local cStyle as char 

    ::lHasCollider := .T.

    cStyle := "TPanel { border: 1 solid black }"

    ::oCollider := TPanel():New(::oGameObject:nTop / 2, ::oGameObject:nLeft / 2, 'Área Colisão', ::oWindow,,,,,, ::oGameObject:nWidth / 2, ::oGameObject:nHeight / 2)
    ::oCollider:SetCss(cStyle)

    ::oCollider:bLClicked := ::oGameObject:bLClicked
    ::oCollider:bRClicked := ::oGameObject:bRClicked

Return

/*
{Protheus.doc} Method DisableEditorCollider() Class BaseGameObject
Desabilita objeto de visualização de margem no editor de cenas
do mouse sobre o objeto
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method DisableEditorCollider() Class BaseGameObject

    ::lHasCollider := .F.

    ::oCollider:Hide()
    FreeObj(::oCollider)

Return

/*
{Protheus.doc} Method EnableEditorCollider() Class BaseGameObject
Habilita objeto de visualização de margem no editor de cenas
do mouse sobre o objeto
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method UpdateEditorCollider(lHeightWidth) Class BaseGameObject
    
    If ::HasCollider()

        // top margin
        ::oCollider:nTop := ::oGameObject:nTop + ::nTopMargin
        ::oCollider:nHeight := ::oGameObject:nHeight - ::nTopMargin

        // left margin
        ::oCollider:nLeft := ::oGameObject:nLeft + ::nLeftMargin
        ::oCollider:nWidth := ::oGameObject:nWidth - ::nLeftMargin

        // bottom margin
        ::oCollider:nHeight += ::nBottomMargin

        //right margin
        ::oCollider:nWidth += ::nRightMargin

    EndIf

Return

/*
{Protheus.doc} Method HideEditorCollider() Class BaseGameObject
Esconde coliso do editor
do mouse sobre o objeto
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method HideEditorCollider() Class BaseGameObject
    If !Empty(::oCollider)
        ::oCollider:Hide()
        FreeObj(::oCollider)
    EndIf
Return

/*
{Protheus.doc} Method SetTop(nTop) Class BaseGameObject
Define posição top do objeto
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method SetTop(nTop) Class BaseGameObject
    ::oGameObject:nTop := nTop
    ::UpdateEditorCollider()
Return

/*
{Protheus.doc} Method SetLeft(nLeft) Class BaseGameObject
Define posição left do objeto
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method SetLeft(nLeft) Class BaseGameObject
    ::oGameObject:nLeft := nLeft
    ::UpdateEditorCollider()
Return

/*
{Protheus.doc} Method SetHeight(nHeight) Class BaseGameObject
Define altura do objeto
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method SetHeight(nHeight) Class BaseGameObject
    ::oGameObject:nHeight := nHeight
    ::UpdateEditorCollider(.T.)
Return

/*
{Protheus.doc} Method SetWidth(nWidth) Class BaseGameObject
Define largura do objeto
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method SetWidth(nWidth) Class BaseGameObject
    ::oGameObject:nWidth := nWidth
    ::UpdateEditorCollider(.T.)
Return

/*
{Protheus.doc} Method MoveUp(nSpeed) Class BaseGameObject
Move objeto para cima
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method MoveUp(nSpeed) Class BaseGameObject
    ::oGameObject:nTop -= nSpeed
    ::UpdateEditorCollider()
Return

/*
{Protheus.doc} Method MoveLeft(nSpeed) Class BaseGameObject
Move objeto para esquerda
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method MoveLeft(nSpeed) Class BaseGameObject
    ::oGameObject:nLeft -= nSpeed
    ::UpdateEditorCollider()
Return

/*
{Protheus.doc} Method MoveDown(nSpeed) Class BaseGameObject
Move objeto para baixo
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method MoveDown(nSpeed) Class BaseGameObject
    ::oGameObject:nTop += nSpeed
    ::UpdateEditorCollider()
Return

/*
{Protheus.doc} Method MoveRight(nSpeed) Class BaseGameObject
Move objeto para direita
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method MoveRight(nSpeed) Class BaseGameObject
    ::oGameObject:nLeft += nSpeed
    ::UpdateEditorCollider()
Return



