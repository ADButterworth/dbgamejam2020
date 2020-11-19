local failGraphic = love.graphics.newImage("gfx/fail.png")
local music = love.audio.newSource("sfx/menu.mp3", "static")
local tween = {a = 0, v = 0}
local ending = false

function drawFailScreen()
    love.graphics.setColor(1,1,1,tween.a)
    drawinrect(failGraphic, 0, 0, gameWidth, gameHeight)
    love.graphics.setColor(1,1,1,1)
end

function startFail()
    GAMESTATE = "FAILED"
    flux.to(metaCam, 2, {v = 0}):ease("quartout")
    music:play()
    flux.to(tween, 2, {a = 1, v = 1}):ease("quartout")
end

function endFail()
    if ending == false then
        flux.to(tween, 2, {a = 0, v = 0}):ease("quartout"):oncomplete(function() 
            music:stop()
            music:release()

            GAMESTATE = "PRELUDE"
        end)

        ending = true 
    end
end

function failUpdate(dt)
    -- music
    if music:tell() == music:getDuration() then
        music:seek(73.03)
    end

    music:setVolume(tween.v)
end