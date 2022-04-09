require('gamestate')
require('state_game')

State_MainMenu = GameState:new({})

local MENUFONT_SIZE = 30
local MENU_TEXTS = {
    "<Start>",
    "<Options>",
    "<Quit>",
}

local menuState
local newState = nil

function State_MainMenu:init()
    menuState = {}
    menuState.bgText = love.graphics.newImage("res/menubg.png")
    menuState.mainFont = love.graphics.newFont(MENUFONT_SIZE)

    menuState.mainTimer = 0
    menuState.curMainOption = 1
end

local function mainmenuNextOpt()
    menuState.curMainOption = menuState.curMainOption + 1
    if menuState.curMainOption > #MENU_TEXTS then menuState.curMainOption = 1 end
end

local function mainmenuPrevOpt()
    menuState.curMainOption = menuState.curMainOption - 1
    if menuState.curMainOption == 0 then menuState.curMainOption = #MENU_TEXTS end
end

local function activateSelOption()
    if menuState.curMainOption == 1 then
        -- Launch game here
        newState = State_Game

    elseif menuState.curMainOption == 3 then
        love.event.quit()
    end
end

function State_MainMenu:update(dt)
    menuState.mainTimer = menuState.mainTimer + dt
    return newState
end

function State_MainMenu:keypressed(key, scancode, isrepeat)
    if isrepeat then return end

    if key == "right" then mainmenuNextOpt()
    elseif key == "left" then mainmenuPrevOpt()
    elseif key == "return" then activateSelOption() end
end

function State_MainMenu:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(menuState.bgText, 0, 0)
    love.graphics.printf(MENU_TEXTS[menuState.curMainOption], menuState.mainFont, 0, 300 - MENUFONT_SIZE/2, 800, "center")
end

function State_MainMenu:fini()
    menuState = nil
    newState = nil
end
