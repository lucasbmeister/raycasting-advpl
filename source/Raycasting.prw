#include 'totvs.ch'
#include 'gameadvpl.ch'

#DEFINE PI 3.14159265
/*{Protheus.doc} Class Raycasting
Classe que contém lógica de execução de objeto utilizando raycasting
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Class Raycasting From BaseGameObject

    Data aLevel1
    Data oCurrentLevel
    Data nCurrentId
    Data oPlayer

    Method New()
    Method Update()
    Method GetNextId()
    Method SetCurrentId()

EndClass

/*{Protheus.doc} Method New(oWindow, oGame) Class Raycasting
Método que instância classe raycasting
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method New(oWindow, oGame) Class Raycasting

    _Super:New(oWindow)

    ::SetCurrentId(0)
    ::aLevel1 := {}

    AAdd(::aLevel1, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1})
    AAdd(::aLevel1, {1, 0, 0, 0, 0, 0, 0, 0, 0, 1})
    AAdd(::aLevel1, {1, 0, 1, 0, 0, 0, 0, 0, 0, 1})
    AAdd(::aLevel1, {1, 0, 0, 0, 0, 0, 0, 0, 0, 1})
    AAdd(::aLevel1, {1, 0, 0, 0, 0, 1, 1, 0, 0, 1})
    AAdd(::aLevel1, {1, 0, 0, 0, 0, 1, 1, 0, 0, 1})
    AAdd(::aLevel1, {1, 0, 0, 1, 1, 1, 0, 0, 0, 1})
    AAdd(::aLevel1, {1, 0, 0, 0, 0, 0, 0, 1, 0, 1})
    AAdd(::aLevel1, {1, 0, 0, 0, 0, 0, 0, 1, 0, 1})
    AAdd(::aLevel1, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1})

    //::oGameObject :=  TPaintPanel():new(0,0,oWindow:nWidth / 2,oWindow:nHeight / 2,oWindow)
    ::oGameObject := TPaintPanel():New(1,1, 500, 500,oWindow)

    ::oCurrentLevel := RaycastLevel():New(::oGameObject, ::aLevel1)
    ::oPlayer := RaycastPlayer():New(::oGameObject, ::oCurrentLevel, 250, 150)

Return Self

/*{Protheus.doc} Method Update() Class Raycasting
Realiza o update for frame do raycasting
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method Update(oGameManager) Class Raycasting

    Local oKeys as object

    oKeys := oGameManager:GetPressedKeys()

    If oKeys['w']
        ::oPlayer:Up()
    EndIF

    If oKeys['s']
        ::oPlayer:Down()
    EndIF

    If oKeys['d']
        ::oPlayer:Right()
    EndIF

    If oKeys['a']
        ::oPlayer:Left()
    EndIF

    If !oKeys['w'] .and. !oKeys['s']
        ::oPlayer:ReleaseWalk()
    EndIf

    If !oKeys['a'] .and. !oKeys['d']
        ::oPlayer:ReleaseRotation()
    EndIF

    ::oGameObject:ClearAll()
    ::SetCurrentId(0)
    //::oCurrentLevel:Draw(Self)
    ::oPlayer:Draw(Self)
Return

/*{Protheus.doc}

@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method GetNextId() Class Raycasting
    ::nCurrentId += 1
Return ::nCurrentId

/*{Protheus.doc}

@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method SetCurrentId(nId) Class Raycasting
    ::nCurrentId := nId
Return

//----------- GENERICAS ------------
/*{Protheus.doc}

@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
User Function AngleNormal(nAngle)

    nAngle := nAngle % (2 * PI)

    If nAngle < 0
        nAngle := nAngle + (2 * PI)
    EndIf

Return nAngle

/*{Protheus.doc}

@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
User Function DiffPoints(nX1, nY1, nX2, nY2)
Return Sqrt((nX2 - nX1) * (nX2 - nX1) + (nY2 - nY1) * (nY2 - nY1))

/*{Protheus.doc}

@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
User Function RadianConv(nAngle)
    nAngle := nAngle * (PI / 180)
Return nAngle