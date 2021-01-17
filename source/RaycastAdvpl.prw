#include 'totvs.ch'
#include 'gameadvpl.ch'

/*{Protheus.doc} Main Function Animation3D()
Realiza a rota��o de um cubo 3d
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Main Function Raycasting()

    Local oGame as object
    Local oWindow as object
    Local aDimensions as array

    // inst�ncia gerenciador do jogo
    oGame := GameManager():New("Raycasting", 50, 50, 650, 1330)

    // obt�m janela princial onde as cenas ser�o adicionadas
    oWindow := oGame:GetMainWindow()

    // retorna dimens�es de tela do jogo
    aDimensions := oGame:GetDimensions()

    oCubeScene := Scene():New(oWindow, "raycasting", aDimensions[TOP], aDimensions[LEFT], aDimensions[HEIGHT], aDimensions[WIDTH])
    oCubeScene:SetInitCodeBlock({|oLevel| LoadRaycast(oLevel, oGame)})

    // adiciona cena ao jogo
    oGame:AddScene(oCubeScene)

    oGame:Start(oCubeScene:GetSceneID())

Return
/*{Protheus.doc} Static FUnction LoadRaycast(oLevel, oGame)
Carrega cena com raycast
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
*/
Static FUnction LoadRaycast(oLevel, oGame)

    Local oWindow as object
    Local oRaycast as object

    oWindow := oLevel:GetSceneWindow()

    oRaycast := Raycasting():New(oWindow, oGame)

    oLevel:AddObject(oRaycast)

Return
