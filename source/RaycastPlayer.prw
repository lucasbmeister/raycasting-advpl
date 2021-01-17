#include 'totvs.ch'
#include 'gameadvpl.ch'

#DEFINE PI 3.14159265
#DEFINE PLAYER_COLOR '#FFFFFF'

/*{Protheus.doc} Class RaycastPlayer From BaseGameObject
Classe que contém lógica de execução do jogar em raycast
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Class RaycastPlayer From BaseGameObject

    Data oLevel
    Data oPanel
    Data nX
    Data nY
    Data nWalk
    Data nRotation
    Data nRotationAngle
    Data nMovementSpeed
    Data nRotationSpeed
    Data oRay
    Data aRays
    Data nRayNumber
    Data nFOV

    Method New() Constructor
    Method Draw()
    Method Up()
    Method Down()
    Method Right()
    Method Left()
    Method ReleaseWalk()
    Method ReleaseRotation()
    Method Update()
    Method Colision()

EndClass

/*{Protheus.doc} Method New(oLevel, nX, nY) Class RaycastPlayer
Método que instância classe RaycastPlayer
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method New(oPanel, oLevel, nX, nY) Class RaycastPlayer

    Local nIndex as numeric
    Local nAngleIncrement as numeric
    Local nIntialAngle as numeric
    Local nRayAngle as numeric
    Local nMidFOV as numeric

    ::oPanel := oPanel
    ::oLevel := oLevel

    ::nX := nX
    ::nY := nY

    ::nWalk := 0 // 0 = parado; 1 = avança; 2 = retroced
    ::nRotation := 0 // -1 = esquerda; 1 = direita

    ::nRotationAngle := 0

    ::nMovementSpeed := 3 // pixels
    ::nRotationSpeed := 3 * (PI / 180) // grados

    ::nRayNumber := ::oPanel:nWidth
    ::aRays := {}

    ::nFOV := 60
    nMidFOV := ::nFOV / 2

    nAngleIncrement := U_RadianConv(::nFOV / ::nRayNumber)
    nIntialAngle := U_RadianConv(::nRotationAngle - nMidFOV)
    
    nRayAngle := nIntialAngle

    For nIndex := 1 To ::nRayNumber
        AAdd(::aRays, Ray():New(oPanel, oLevel, nX, nY, ::nRotationAngle, nRayAngle, nIndex, ::nFOV))
        nRayAngle += nAngleIncrement
    Next
    //::oRay := Ray():New(oPanel, oLevel, nX, nY, ::nRotationAngle, 0)

Return

/*{Protheus.doc}

@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method Draw(oRaycastManager) Class RaycastPlayer

    Local cId as char
    Local cX as char
    Local cY as char
    Local cHeight as char
    Local cWidth as char
    Local cXTarget as numeric
    Local cYTarget as numeric
    Local nIndex as numeric

    ::Update()

    For nIndex := 1 To ::nRayNumber
        ::aRays[nIndex]:Draw(oRaycastManager)
        //::aRays[nIndex]:RenderWall(oRaycastManager)
    Next

    // cId := cValToChar(oRaycastManager:GetNextId())

    // cX := cValToChar(::nX - 3)
    // cY := cValToChar(::nY - 3)
    // cHeight := '6'
    // cWidth := '6'

    // ::oPanel:AddShape("id="+cId+";type=1;left="+cX+";top="+cY+";width="+cWidth+";height="+cHeight+";" + ;
    //     "gradient=1,0,0,0,0,0.0,"+PLAYER_COLOR+";"+;
    //     "pen-width=1;pen-color="+PLAYER_COLOR+";can-move=0;can-mark=0;is-container=1;")

    // cXTarget := cValToChar(::nX + Cos(::nRotationAngle) * 40)
    // cYTarget := cValToChar(::nY + Sin(::nRotationAngle) * 40)

    // cId := cValToChar(oRaycastManager:GetNextId())

    // ::oPanel:AddShape("id="+cId+";type=9;from-left="+cValToChar(::nX)+";from-top="+cValToChar(::nY)+";" + ;
    //     "to-left="+cXTarget+";to-top="+cYTarget+";pen-width=1;pen-color=#FFFFFF;")

Return

/*{Protheus.doc}

@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method Up() Class RaycastPlayer
    ::nWalk := 1
Return

/*{Protheus.doc}

@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method Down() Class RaycastPlayer
    ::nWalk := -1
Return

/*{Protheus.doc}

@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method Right() Class RaycastPlayer
    ::nRotation := 1
Return

/*{Protheus.doc}

@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method Left() Class RaycastPlayer
    ::nRotation := -1
Return

/*{Protheus.doc}

@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method ReleaseWalk() Class RaycastPlayer
    ::nWalk := 0
Return

/*{Protheus.doc}

@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method ReleaseRotation() Class RaycastPlayer
    ::nRotation := 0
Return

/*{Protheus.doc}

@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method Update() Class RaycastPlayer

    Local nNewX as numeric
    Local nNewY as numeric
    Local nIndex as numeric

    nNewX := ::nX + (::nWalk * Cos(::nRotationAngle) * ::nMovementSpeed)
    nNewY := ::nY + (::nWalk * Sin(::nRotationAngle) * ::nMovementSpeed)

    If !::Colision(nNewX, nNewY)
        ::nX := nNewX
        ::nY := nNewY
    EndIf

    ::nRotationAngle += ::nRotation * ::nRotationSpeed

    ::nRotationAngle := U_AngleNormal(::nRotationAngle)

    For nIndex := 1 To ::nRayNumber

        ::aRays[nIndex]:nX := ::nX
        ::aRays[nIndex]:nY := ::nY

        ::aRays[nIndex]:SetAngle(::nRotationAngle)
    Next

Return

/*{Protheus.doc}

@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method Colision(nX, nY) Class RaycastPlayer

    Local nTileX as numeric
    Local nTileY as numeric

    nTileX := Int(nX / ::oLevel:nTileSizeX)
    nTileY := Int(nY / ::oLevel:nTileSizeY)

Return ::oLevel:Colision(nTileX, nTileY)
