#include 'totvs.ch'
#include 'gameadvpl.ch'

#DEFINE WALL_COLOR '#000000'
#DEFINE FLOOR_COLOR '#666666'

/*{Protheus.doc}

@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Class RaycastLevel

    Data aLevel
    Data nSizeY
    Data nSizeX
    Data oPanel

    Data nHeight
    Data nWidth

    Data nTileSizeX
    Data nTileSizeY

    Method New() Constructor
    Method Draw()
    Method Colision()

EndClass

/*{Protheus.doc}

@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method New(oPanel, aLevel) Class RaycastLevel

    ::oPanel := oPanel

    ::aLevel := aLevel

    ::nSizeY := Len(aLevel)
    ::nSizeX := Len(aLevel[1])

    ::nHeight := oPanel:nHeight / 2// - 90
    ::nWidth := oPanel:nWidth / 2// / 2

    ::nTileSizeX := Int(::nWidth / ::nSizeX)
    ::nTileSizeY := Int(::nHeight / ::nSizeY)

Return Self

/*{Protheus.doc}

@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method Draw(oRaycastManager) Class RaycastLevel

    Local nIndexY as numeric
    Local nIndexX as numeric
    Local cId as char
    Local cTileX as numeric
    Local cTileY as numeric
    Local cTileHeight as numeric
    Local cTileWidth as numeric

    For nIndexY := 1 To ::nSizeY
        For nIndexX := 1 To ::nSizeX

            cId := cValToChar(oRaycastManager:GetNextId())//cValToChar(nIndexY) + cValToChar(nIndexX)
            //::oPanel:DeleteItem(Val(cId))

            cTileX := cValToChar(nIndexX * ::nTileSizeX)
            cTileY := cValToChar(nIndexY * ::nTileSizeY)
            cTileHeight := cValToChar(::nTileSizeY)
            cTileWidth := cValToChar(::nTileSizeX)

            If ::aLevel[nIndexY][nIndexX] == 1
                // ::oPanel:addShape("id="+cId+";type=5;polygon=280:04,310:085,280:085;gradient=1,0,0,0,0,0.0," + WALL_COLOR + ";"+;
                //  "gradient-hover=1,0,0,0,0,0.0,#ffff00;tooltip=Poligono;pen-width=1;"+;
                //  "pen-color=#000000;can-move=1;can-mark=1;is-container=0;is-blinker=01;")
                ::oPanel:AddShape("id="+cId+";type=1;left="+cTileX+";top="+cTileY+";width="+cTileWidth+";height="+cTileHeight+";" + ;
                    "gradient=1,0,0,0,0,0.0,"+WALL_COLOR+";"+;
                    "pen-width=1;pen-color="+WALL_COLOR+";can-move=0;can-mark=0;is-container=1;")
            Else
                // ::oPanel:addShape("id="+cId+";type=5;polygon=280:04,310:085,280:085;gradient=1,0,0,0,0,0.0," + FLOOR_COLOR + "+;
                // "gradient-hover=1,0,0,0,0,0.0,#ffff00;tooltip=Poligono;pen-width=1;"+;
                // "pen-color=#000000;can-move=1;can-mark=1;is-container=0;is-blinker=01;")

                ::oPanel:AddShape("id="+cId+";type=1;left="+cTileX+";top="+cTileY+";width="+cTileWidth+";height="+cTileHeight+";" + ;
                    "gradient=1,0,0,0,0,0.0,"+FLOOR_COLOR+";"+;
                    "pen-width=1;pen-color="+FLOOR_COLOR+";can-move=0;can-mark=0;is-container=1;")
            EndIf
        Next
    Next

Return

/*{Protheus.doc}

@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Method Colision(nX, nY) Class RaycastLevel

    Local lColision as logical

    lColision := .F.

    If nX < 1 .or. nY < 1 .or. nX > Len(::aLevel[1]) .or. nY > Len(::aLevel) .or. ::aLevel[nY][nX] != 0
        lColision := .T.
    EndIF

Return lColision