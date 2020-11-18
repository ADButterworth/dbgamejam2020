local TEXT_HEIGHT = screen.height - 300

local lines = {}
local speaker = {}
local lineNumber = 1

local font = love.graphics.newFont("FORCED_SQUARE.ttf", 40)

local tbox = {}
tbox.w = 800
tbox.h = 0

local picScale = 3
local donPic = love.graphics.newImage("gfx/portrait/don.png")
local fellowPic = love.graphics.newImage("gfx/portrait/fellow.png")

local donWidth = donPic:getWidth() * picScale
local fellowWidth = fellowPic:getWidth() * picScale

local drawText = true

function endPrelude()
    drawText = false
    flux.to(metaCam, 2, {sx=1, sy=1}):ease("quartout"):oncomplete(function() GAMESTATE = "LEVEL" end)
end

function loadPrelude(levelNumber)
    metaCam.sx = 2
    metaCam.sy = 2
    camera:setScale(metaCam.sx, metaCam.sy)
    camera:setPosition(math.floor(player.x + player.w/2), math.floor(player.y + player.h/2))

    if levelNumber == 1 then
        lines = {
            "Hello agent, i'm your handler for this assignment codenamed FELLOW. I will be your guide and assist how ever I can with your mission.",
            "Oh great just what i need a tech guy spouting off in my ear, dont you worry about TRUTH by the time im done with them, they wont be a threat to anyone even techies hiding in a basement at HQ.",
            "Charming agent DON, however HQ has decided you need a handler especially after the mess you caused in Hong Kong.",
            "Alright FELLOW where is my first target?",
            "Your first target is a Nova City stock exchange in the centre of the city, once there you will need to make your way to the top floor to acquire your first keycard.",
            "What kind of resistance should I expect?",
            "Security is fairly light at this target since it’s still a public building, as well as a large amount of renovations which taking place that has moved much of TRUTH's staff and security away... I would suggest you start quiet here agent, but I know you have a habit of creating a scene.",
            "If you mean I get the job done, then yes.",
            "Agent it seems TRUTH are aware of our incursion, might I suggest you find... alternate routes to the top floor; a large amount of scaffolding and pipe-works will aid your ascent.",
        }
        

        speaker[1] = "FELLOW"
        speaker[2] = "DON"
        speaker[3] = "FELLOW"
        speaker[4] = "DON"
    end

    tbox.x = screen.width/2 - tbox.w/2
    _, wraps = font:getWrap(lines[lineNumber], tbox.w)
    tbox.h = font:getHeight("A") * #wraps
    drawText = true
end

function drawPrelude()
    if drawText then
        drawTextBox()
        love.graphics.setColor(1,1,1,1)
        love.graphics.setFont(font)
        love.graphics.printf(lines[lineNumber], tbox.x + 10, TEXT_HEIGHT+5, tbox.w)
        love.graphics.setFont(defaultFont)
    end
end

function drawTextBox()
    love.graphics.setColor(0,0,0,1)
    love.graphics.rectangle("fill", tbox.x, TEXT_HEIGHT, tbox.w + 20, tbox.h+10, 5, 5)
    love.graphics.setColor(1,1,1,1)
    love.graphics.rectangle("line", tbox.x, TEXT_HEIGHT, tbox.w + 20, tbox.h+10, 5, 5)

    if speaker[lineNumber] == "DON" then
        love.graphics.draw(donPic, tbox.x - donWidth - 10, TEXT_HEIGHT, 0, picScale)
    elseif speaker[lineNumber] == "FELLOW" then
        love.graphics.draw(fellowPic, tbox.x - donWidth - 10, TEXT_HEIGHT, 0, picScale)
    end 
end

function preludeKeypressed(key)
    lineNumber = lineNumber + 1
    if lineNumber > #lines then
        lineNumber =  #lines
        endPrelude()
    end 
    tbox.x = screen.width/2 - tbox.w/2
    _, wraps = font:getWrap(lines[lineNumber], tbox.w)
    tbox.h = font:getHeight("A") * #wraps
end