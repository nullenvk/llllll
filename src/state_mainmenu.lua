require('src.gamestate')
require('src.state_game')
require('src.effect_fade')

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
    FadeEffect.preload()

    menuState = {}
    menuState.bgText = love.graphics.newImage("res/menubg.png")
    menuState.mainFont = love.graphics.newFont(MENUFONT_SIZE)
    menuState.introFade = FadeEffect:new(nil, true)
    menuState.choiceFade = FadeEffect:new(nil, false)

    menuState.mainTimer = 0
    menuState.curMainOption = 1
    menuState.optActivated = false

    menuState.introFade:start()
end

local function mainmenuNextOpt()
    menuState.curMainOption = menuState.curMainOption + 1
    if menuState.curMainOption > #MENU_TEXTS then menuState.curMainOption = 1 end
end

local function mainmenuPrevOpt()
    menuState.curMainOption = menuState.curMainOption - 1
    if menuState.curMainOption == 0 then menuState.curMainOption = #MENU_TEXTS end
end

local function processSelOption()
    if menuState.curMainOption == 1 then
        -- Launch game here
        newState = State_Game

    -- debug
    elseif menuState.curMainOption == 2 then
    elseif menuState.curMainOption == 3 then
        love.event.quit()
    end

    menuState.optActivated = false
    menuState.choiceFade:reset()
end

local function activateSelOption()
    menuState.optActivated = true
    menuState.choiceFade:start()
end

function State_MainMenu:update(dt)
    menuState.mainTimer = menuState.mainTimer + dt

    if menuState.optActivated and menuState.choiceFade:hasFinished() then
        processSelOption()
    end

    return newState
end

function State_MainMenu:keypressed(key, scancode, isrepeat)
    if isrepeat then return end
    if menuState.optActivated then return end

    if key == "a" then mainmenuNextOpt()
    elseif key == "d" then mainmenuPrevOpt()
    elseif key == "return" then activateSelOption() end
end

function State_MainMenu:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(menuState.bgText, 0, 0)
    love.graphics.printf(MENU_TEXTS[menuState.curMainOption], menuState.mainFont, 0, 300 - MENUFONT_SIZE / 2, 800, "center")

    menuState.introFade:draw()
    menuState.choiceFade:draw()
end

function State_MainMenu:fini()
    menuState = nil
    newState = nil

    FadeEffect.free()
end
