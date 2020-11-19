love.graphics.setDefaultFilter("nearest", "nearest")
screen = {}
screen.width, screen.height = love.window.getDesktopDimensions()

local push = require "lib/push"

gameWidth, gameHeight = 1920, 1080 --fixed game resolution
push:setupScreen(gameWidth, gameHeight, screen.width, screen.height, {fullscreen = true})

local gamera = require 'lib/gamera'
bitser = require "lib/bitser"
flux = require "lib/flux"
require("lib/TEsound")
require("parallax")
require("world")
require("player")
require("build")
require("prelude")
require("titlescreen")
require("enemy")
require("failscreen")

bitser.registerClass(Enemy)

defaultFont = love.graphics.newFont(10)
love.graphics.setFont(defaultFont)

camera = gamera.new(0,0,1,1)
metaCam = {}
metaCam.sx = 1
metaCam.sy = 1
metaCam.v = 0 

mouse = {}
mouse.sx, mouse.sy = love.mouse.getPosition()
mouse.wx, mouse.wy = camera:toWorld(mouse.sx,mouse.sy)
local cameraSpeed = 5

local saveDirString = love.filesystem.getSaveDirectory()
local saveDirStringWidth = defaultFont:getWidth(saveDirString)
local saveDirStringHeight = defaultFont:getHeight(saveDirString)

local fpsString = "FPS: "..tostring(love.timer.getFPS( ))
local fpsStringWidth = defaultFont:getWidth(fpsString)
local fpsStringHeight = defaultFont:getHeight(fpsString)

GAMESTATE = "LOADING"
LEVEL = 1

DEVELOPER = true

function love.load()
    love.mouse.setVisible(false)
    love.profiler = require('lib/profile') 
    love.profiler.start()

    initTitle()
    startTitle()

    initWorld()
    love.graphics.setBackgroundColor(255/255, 105/255, 63/180)
    genBGLayers()
    player:setup()

    loadPrelude(LEVEL)
    loadLevel("levels/1.lvl")
end

love.frame = 0
function love.update(dt)
    local prevState = GAMESTATE
    TEsound.cleanup()
    flux.update(dt)
    mouse.sx, mouse.sy = love.mouse.getPosition()
    mouse.wx, mouse.wy = camera:toWorld(mouse.sx,mouse.sy)
    updateBGLayers(camera.x)
    levelMusic:setVolume(metaCam.v)

    if GAMESTATE == "PRELUDE" then
        -- DO PHONECALL STUFF
    elseif GAMESTATE == "LEVEL" then
        if not BUILD_MODE then
            worldUpdate(dt)
        end 
        
        player:update(dt)
    elseif GAMESTATE == "TITLE" then
        titleUpdate(dt)
    elseif GAMESTATE == "FAILED" then
        failUpdate(dt)
    end

    local camVX = (math.floor(player.x + player.w/2) - camera.x) * cameraSpeed * dt
    local camVY = (math.floor(player.y + player.h/2) - camera.y) * cameraSpeed * dt
    camera:setPosition(camera.x + camVX, camera.y + camVY)

    fpsString = "FPS: "..tostring(love.timer.getFPS( ))
    fpsStringWidth = defaultFont:getWidth(fpsString)
    fpsStringHeight = defaultFont:getHeight(fpsString)

    love.frame = love.frame + 1
    if love.frame%100 == 0 then
      love.report = love.profiler.report(20)
      love.profiler.reset()
    end

    camera:setScale(metaCam.sx,metaCam.sy)
end

function love.draw()
    push:start()

    if GAMESTATE == "LOADING" then
        -- TITLE SCREEN HERE
    elseif GAMESTATE == "LEVEL" or GAMESTATE == "PRELUDE" then
        camera:draw(function(l,t,w,h)
            if BUILD_MODE then
                drawWorld()
                drawBuild()
            else
                drawBGLayers()
                drawWorld()
            end

            player:draw()
        end)

        if GAMESTATE == "PRELUDE" then
            drawPrelude()
        end
    elseif GAMESTATE == "TITLE" then
        drawTitleScreen()
    elseif GAMESTATE == "FAILED" then
        drawFailScreen()
    end

    if DEVELOPER and GAMESTATE ~= "TITLE" then
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle("fill", screen.width - saveDirStringWidth,0,saveDirStringWidth,saveDirStringHeight)
        love.graphics.rectangle("fill", screen.width - fpsStringWidth,saveDirStringHeight,fpsStringWidth,fpsStringHeight)
        love.graphics.rectangle("fill", 0,0,500,93)
        love.graphics.setColor(0,0,0)
        love.graphics.print("Camera x: "..camera.x, 10,0)
        love.graphics.print("Camera y: "..camera.y, 10,10)
        love.graphics.print("Player x, vx: "..player.x.." "..player.vx, 10,20)
        love.graphics.print("Player y, vy: "..player.y.." "..player.vy, 10,30)
        love.graphics.print("Player w, h: "..player.w.." "..player.h, 10,40)
        love.graphics.print("Player anim: "..player.currentSprite, 10,50)
        love.graphics.print("Player inRoom: "..tostring(player.inRoom), 10,60)
        love.graphics.print("Player spriteOffset: "..tostring(player.spriteOffsetX), 10,70)
        love.graphics.print("GAMESTATE: "..GAMESTATE, 10,80)

        love.graphics.setColor(0,0,0)
        love.graphics.print(saveDirString, screen.width - saveDirStringWidth, 0)
        love.graphics.print(fpsString, screen.width - fpsStringWidth, saveDirStringHeight)
    end


    love.graphics.setColor(1,1,1)
    --love.graphics.print(love.report or "Please wait...")
    push:finish()
end

function love.keypressed(key, scancode, isrepeat)
    if (key == "r") then
        player:setup()
        loadPrelude(LEVEL)
        loadLevel("levels/1.lvl")
        GAMESTATE = "PRELUDE"

        if GAMESTATE == "FAILED" then
            endFail()
        end
    elseif (key == "q") then
        love.event.quit()
    elseif key == "f1" and DEVELOPER then
        BUILD_MODE = not BUILD_MODE
    end

    if GAMESTATE == "PRELUDE" then
        preludeKeypressed(key)
    else
        worldKeyPressed(key)
        buildKeyPressed(key)
        player:keypressed(key)
    end 

    if GAMESTATE == "TITLE" then
        endTitle()
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if BUILD_MODE then
        buildMousePressed(x, y, button)
    end

    if GAMESTATE == "LEVEL" then
        player:mousepressed(x, y, button)
    end
end