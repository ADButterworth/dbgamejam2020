local titleGraphics = {}
local currentImg = 1

local timer = 0
local duration = math.random() * 1 + 1

local tween = {a = 1, v = 1}

local ending = false

local music = nil 

function initTitle()
    local titleFiles = love.filesystem.getDirectoryItems("gfx/menu")
    for i,v in ipairs(titleFiles) do
        table.insert(titleGraphics, love.graphics.newImage("gfx/menu/"..v))
    end

    music = love.audio.newSource("sfx/menu.mp3", "static")
end

function titleUpdate(dt)
    timer = timer + dt 

    if timer > duration then
        local prevImage = currentImg
        timer = 0

        if currentImg == 2 then
            duration = 0
            currentImg = 1
        elseif currentImg == 1 then
            if math.random() > 0.5 then
                duration = math.random() * 0.2 + 0.1
                currentImg = 3
            else
                duration = math.random() * 1 + 1
                currentImg = 1
            end
        elseif currentImg == 3 then
            duration = 0
            currentImg = 2
        end 
    end

    -- music
    if music:tell() == music:getDuration() then
        music:seek(73.03)
    end

    music:setVolume(tween.v)
end

function drawTitleScreen()
    love.graphics.setColor(1,1,1,tween.a)
    drawinrect(titleGraphics[currentImg], 0, 0, gameWidth, gameHeight)
    love.graphics.setColor(1,1,1,1)
end

function startTitle()
    GAMESTATE = "TITLE"
    music:play()
end

function endTitle()
    if ending == false then
        flux.to(tween, 2, {a = 0, v = 0}):ease("quartout"):oncomplete(function() 
            GAMESTATE = "PRELUDE"
            music:stop()
            music:release()
        end)

        ending = true 
    end
end