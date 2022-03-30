require('gamestate')

State_MainMenu = GameState:new({})

local menuFontSize = 30
local menuTexts = {
    "<Start>",
    "<Options>",
    "<Quit>",
}

local menuState = {}

function State_MainMenu:init()
    menuState.bgSprite = Sprite:new()
    menuState.bgSprite:loadTexture("res/menubg.png")

    menuState.mainFont = love.graphics.newFont(menuFontSize)

    menuState.curMainOption = 1
end

function State_MainMenu:update(dt)

end

function State_MainMenu:draw()
    menuState.bgSprite:draw()

    love.graphics.printf(menuTexts[menuState.curMainOption], menuState.mainFont, 0, 300 - menuFontSize/2, 800, "center")
end

function State_MainMenu:fini()
    menuState = {}
end
