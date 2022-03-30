require('gamestate')
require('state_game')

State_MainMenu = GameState:new({})

local ACTION_DELAY = 0.15
local MENUFONT_SIZE = 30
local MENU_TEXTS = {
    "<Start>",
    "<Options>",
    "<Quit>",
}

local menuState

function State_MainMenu:init()
    menuState = {}
    menuState.bgText = love.graphics.newImage("res/menubg.png")
    menuState.mainFont = love.graphics.newFont(MENUFONT_SIZE)

    menuState.mainTimer = 0
    menuState.actionTimer = 0
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
        return State_Game

    elseif menuState.curMainOption == 3 then
        love.event.quit()
    end

    return nil
end

function State_MainMenu:update(dt)
    local newState = nil
    menuState.mainTimer = menuState.mainTimer + dt

    if menuState.mainTimer - menuState.actionTimer > ACTION_DELAY then
        if love.keyboard.isDown("right") then
            mainmenuNextOpt()
            menuState.actionTimer = menuState.mainTimer
        end

        if love.keyboard.isDown("left") then
            mainmenuPrevOpt()
            menuState.actionTimer = menuState.mainTimer
        end

        if love.keyboard.isDown("return") then
            newState = activateSelOption()
            menuState.actionTimer = menuState.mainTimer
        end
    end

    return newState
end

function State_MainMenu:draw()
    love.graphics.draw(menuState.bgText, 0, 0)

    love.graphics.printf(MENU_TEXTS[menuState.curMainOption], menuState.mainFont, 0, 300 - MENUFONT_SIZE/2, 800, "center")
end

function State_MainMenu:fini()
    menuState = nil
end
