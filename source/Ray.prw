#include 'totvs.ch'
#include 'gameadvpl.ch'


#DEFINE PI 3.14159265
#DEFINE TILE_SIZE 50
/*{Protheus.doc}

@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Class Ray

    Data oPanel
    Data oLevel
    Data nX
    Data nY
    Data nAngleIncrement
    Data nPlayerAngle
    Data nColumn
    Data nInterceptX
    Data nInterceptY
    Data lDown
    Data lLeft
    Data nAngle
    Data nStepY
    Data nStepX
    Data nWallHitX
    Data nWallHitY
    Data nWallHitXHorizontal
    Data nWallHitYHorizontal
    Data nWallHitXVertical
    Data nWallHitYVertical
    Data nDistance
    Data nFOV
    Data nMidFOV

    Method New() Constructor
    Method Cast()
    Method SetAngle()
    Method Draw()
    Method RenderWall()

EndClass

/*{Protheus.doc}

@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method New(oPanel, oLevel, nX, nY, nPlayerAngle, nAngleIncrement, nColumn, nFOV) Class Ray

    ::oPanel := oPanel
    ::oLevel := oLevel

    ::nFOV := nFOV
    ::nMidFOV := nFOV / 2

    ::nX := nX
    ::nY := nY

    ::nPlayerAngle := nPlayerAngle
    ::nAngleIncrement := nAngleIncrement
    ::nAngle := nPlayerAngle + ::nAngleIncrement

    ::nColumn := nColumn

    ::nWallHitX := 0
    ::nWallHitY := 0

    ::nWallHitXHorizontal := 0
    ::nWallHitYHorizontal := 0

    ::nWallHitXVertical := 0
    ::nWallHitYVertical  := 0

Return Self

/*{Protheus.doc}

@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method Cast() Class Ray

    Local lHorColision as logical
    Local lVerColision as logical
    Local nAdjacent as numeric
    Local nNextHorX as numeric
    Local nNextHorY as numeric
    Local nNextVerX as numeric
    Local nNextVerY as numeric
    Local nOposite as numeric
    Local nTileX as numeric
    Local nTileY as numeric
    Local nHorDistance as numeric
    Local nVerDistance as numeric

    ::nInterceptX := 0
    ::nInterceptY := 0

    ::nStepY := 0
    ::nStepX := 0

    ::lDown := .F.
    ::lLeft := .F.

    If ::nAngle < PI
        ::lDown := .T.
    EndIf

    If ::nAngle > PI / 2 .and. ::nAngle < 3 * PI / 2
        ::lLeft := .T.
    EndIf
    // Horizontal
    lHorColision := .F.

    ::nInterceptY := Int(::nY / TILE_SIZE) * TILE_SIZE

    If ::lDown
        ::nInterceptY += TILE_SIZE
    EndIf

    nAdjacent := (::nInterceptY - ::nY) / Tan(::nAngle)

    ::nInterceptX := ::nX + nAdjacent

    ::nStepY := TILE_SIZE
    ::nStepX := ::nStepY / Tan(::nAngle)

    If !::lDown
        ::nStepY := -::nStepY
    EndIF

    If (::lLeft .and. ::nStepX > 0) .or. (!::lLeft .and. ::nStepX < 0)
        ::nStepX *= -1
    EndIF

    nNextHorX := ::nInterceptX
    nNextHorY := ::nInterceptY

    If !::lDown
        nNextHorY--
    EndIf

    While !lHorColision

        nTileX := Int(nNextHorX / TILE_SIZE)
        nTileY := Int(nNextHorY / TILE_SIZE)

        If ::oLevel:Colision(nTileX, nTileY)
            lHorColision := .T.
            ::nWallHitXHorizontal := nNextHorX
            ::nWallHitYHorizontal := nNextHorY
        Else
            nNextHorX += ::nStepX
            nNextHorY += ::nStepY
        EndIf
    End
    // Vertical
    lVerColision := .F.

    ::nInterceptX := Int(::nX / TILE_SIZE) * TILE_SIZE

    If !::lLeft
        ::nInterceptX += TILE_SIZE 
    EndIf

    nOposite := (::nInterceptX - ::nX) * Tan(::nAngle)

    ::nInterceptY := ::nY + nOposite

    ::nStepX := TILE_SIZE

    If ::lLeft
        ::nStepX := -::nStepX
    EndIf

    ::nStepY := TILE_SIZE * Tan(::nAngle)

    If (!::lDown .and. ::nStepY > 0) .or. (::lDown .and. ::nStepY < 0)
        ::nStepY := -::nStepY
    EndIf

    nNextVerX := ::nInterceptX
    nNextVerY := ::nInterceptY

    If ::lLeft
        nNextVerX--
    EndIf

    While !lVerColision .and. (nNextVerX >= 0 .and. nNextVerY >= 0 .and. nNextVerX < ::oPanel:nWidth .and. nNextVerY < ::oPanel:nHeight)
        
        nTileX := Int(nNextVerX / TILE_SIZE)
        nTileY := Int(nNextVerY / TILE_SIZE)

        If ::oLevel:Colision(nTileX, nTileY)
            lVerColision := .T.
            ::nWallHitXVertical := nNextVerX
            ::nWallHitYVertical := nNextVerY
        Else
            nNextVerX += ::nStepX
            nNextVerY += ::nStepY
        EndIf

    End

    nHorDistance := 9999
    nVerDistance := 9999

    If lHorColision
        nHorDistance := U_DiffPoints(::nX, ::nY, ::nWallHitXHorizontal, ::nWallHitYHorizontal)
    EndIF

    If lVerColision
        nVerDistance := U_DiffPoints(::nX, ::nY, ::nWallHitXVertical, ::nWallHitYVertical)
    EndIF

    If nHorDistance < nVerDistance
        ::nWallHitX := ::nWallHitXHorizontal
        ::nWallHitY := ::nWallHitYHorizontal

        ::nDistance := nHorDistance
    Else
        ::nWallHitX := ::nWallHitXVertical
        ::nWallHitY := ::nWallHitYVertical

        ::nDistance := nVerDistance
    EndIf

Return

/*{Protheus.doc}

@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method RenderWall(oRaycastManager) Class Ray

    Local nDisProjPlan as numeric
    Local nTileHeight as numeric
    Local nWallHeight as numeric
    Local nY0 as numeric
    Local nY1 as numeric
    Local nX as numeric
    Local cId as char

    nTileHeight := 500

    nDisProjPlan := (500 / 2) / Tan(::nMidFOV)

    nWallHeight := (nTileHeight / ::nDistance) * nDisProjPlan

    nY0 := Int(500 / 2) - Int(nWallHeight / 2)
    nY1 := nY0 + nWallHeight

    nX := ::nColumn

    cId := cValToChar(oRaycastManager:GetNextId())

    ::oPanel:AddShape("id="+cId+";type=9;from-left="+cValToChar(nX)+";from-top="+cValToChar(nY0)+";" + ;
        "to-left="+cValToChar(nX)+";to-top="+cValToChar(nY1)+";pen-width=1;pen-color=#666666;")

Return

/*{Protheus.doc}

@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method Draw(oRaycastManager) Class Ray

    Local cTargetX as numeric
    Local cTargetY as numeric
    Local cId as char

    ::Cast()

    // cTargetX := cValToChar(::nWallHitX)
    // cTargetY := cValToChar(::nWallHitY)

    // cId := cValToChar(oRaycastManager:GetNextId())

    // ::oPanel:AddShape("id="+cId+";type=9;from-left="+cValToChar(::nX)+";from-top="+cValToChar(::nY)+";" + ;
    //     "to-left="+cTargetX+";to-top="+cTargetY+";pen-width=1;pen-color=#FF0000;")
    ::RenderWall(oRaycastManager)

Return


/*{Protheus.doc}

@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method SetAngle(nAngle) Class Ray
    ::nPlayerAngle := nAngle
    ::nAngle := U_AngleNormal(nAngle + ::nAngleIncrement)
Return