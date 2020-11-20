world = {}
world.blocks = {}
world.vents = {}
world.stairs = {}
world.rooms = {}
world.enemies = {}
world.windows = {}

world.showVentConnections = false
FLOOR_HEIGHT = nil
CLOUD_HEIGHT = nil

objective = {}
objective.x = 2800
objective.y = -1900
objective.w = 150
objective.h = 150
objective.time = 1
objective.curTime = 0
objectiveSprite = love.graphics.newImage("gfx/safe.png")

local sprites = {} 
world.phonebox = {}
world.bg = {}
world.window = {}

levelMusic = love.audio.newSource("sfx/level.mp3", "static")
levelMusic:setVolume(0.5)
levelMusic:setLooping(true)

local function loadSprites()
    sprites.phonebox = love.graphics.newImage("gfx/phonebox.png")
    sprites.floor = love.graphics.newImage("gfx/floor.png")

    sprites.background = love.graphics.newImage("gfx/background/office.png")
    world.bg.w = sprites.background:getWidth()
    world.bg.h = sprites.background:getHeight()

    sprites.window = love.graphics.newImage("gfx/background/office_window.png")
    world.window.w = sprites.background:getWidth()
    world.window.h = sprites.background:getHeight()

    world.phonebox.scale = 2.25
    world.phonebox.w = sprites.phonebox:getWidth() * world.phonebox.scale
    world.phonebox.h = sprites.phonebox:getHeight() * world.phonebox.scale

    sprites.vent = love.graphics.newImage("gfx/vent.png")
    sprites.stairs = love.graphics.newImage("gfx/stairs.png")
end

function initWorld()
    loadSprites()
    CLOUD_HEIGHT = -2000
    FLOOR_HEIGHT = 0
    world.width = 6000
    world.height = 7000
    world.phonebox.x = 350
    world.phonebox.y = FLOOR_HEIGHT - world.phonebox.h
    camera:setWorld(-1000,-world.height, world.width+1000,world.height+200)
    --createSampleWorld()
end

function loadLevel(file)
    -- clear current level
    world.blocks = {}
    world.vents = {}
    world.stairs = {}
    world.rooms = {}
    world.enemies = {}
    world.windows = {}

    local data = love.filesystem.read(file)
    
    deserializedData = bitser.loads(data)

    if #deserializedData == 2 then 
        world.blocks = deserializedData[1]
        world.vents = deserializedData[2]
    elseif #deserializedData == 4 then
        world.blocks = deserializedData[1]
        world.vents = deserializedData[2]
        world.stairs = deserializedData[3]
        world.rooms = deserializedData[4]
    elseif #deserializedData == 5 then
        world.blocks = deserializedData[1]
        world.vents = deserializedData[2]
        world.stairs = deserializedData[3]
        world.rooms = deserializedData[4]
        world.enemies = deserializedData[5]
    elseif #deserializedData == 6 then
        world.blocks = deserializedData[1]
        world.vents = deserializedData[2]
        world.stairs = deserializedData[3]
        world.rooms = deserializedData[4]
        world.enemies = deserializedData[5]
        world.windows = deserializedData[6]
    else
        error("Failed to load level file")
    end

    -- safety floor 
    addBlock(-1000,FLOOR_HEIGHT, world.width+1000,4000)
end

function addBlock(x,y,w,h, type)
    local b = {}
    b.x = x 
    b.y = y 
    b.w = w 
    b.h = h 

    b.type = type
    
    table.insert(world.blocks, b)
end

function addVent(x1,y1,w1,h1, x2,y2,w2,h2)
    local b = {}
    local p1 = {}
    local p2 = {}
    p1.x = x1 
    p1.y = y1 
    p1.w = w1 
    p1.h = h1

    p2.x = x2 
    p2.y = y2 
    p2.w = w2 
    p2.h = h2 

    table.insert(b, p1)
    table.insert(b, p2)
    
    table.insert(world.vents, b)
end

function addStairs(x1,y1,w1,h1, x2,y2,w2,h2)
    local b = {}
    local p1 = {}
    local p2 = {}
    p1.x = x1 
    p1.y = y1 
    p1.w = w1 
    p1.h = h1

    p2.x = x2 
    p2.y = y2 
    p2.w = w2 
    p2.h = h2 

    table.insert(b, p1)
    table.insert(b, p2)
    
    table.insert(world.stairs, b)
end

function addRoom(x,y,w,h)
    local b = {}
    b.x = x 
    b.y = y 
    b.w = w 
    b.h = h 

    table.insert(world.rooms, b)
end

function addWindow(x,y,w,h)
    local b = {}
    b.x = x 
    b.y = y 
    b.w = w 
    b.h = h 

    table.insert(world.windows, b)
end

function addEnemy(x,y, left, pl,pr, idle)
    local ene = Enemy:new(x,y, left, pl,pr, idle)

    table.insert(world.enemies, ene)
end

function worldUpdate(dt)
    -- enemies
    for i,v in ipairs(world.enemies) do
        v:update(dt)
    end

    if not BUILD_MODE then 
        -- enemy vision
        if EnemyVisionCheck(player.x, player.y) then
            startFail()
        elseif EnemyVisionCheck(player.x + player.w, player.y) then
            startFail()
        elseif EnemyVisionCheck(player.x + player.w, player.y + player.h) then
            startFail()
        elseif EnemyVisionCheck(player.x, player.y + player.h) then
            startFail()
        elseif EnemyVisionCheck(player.x + player.w/2, player.y + player.h/2) then
            startFail()
        end
    end

    if CheckCollision(player.x,player.y,player.w,player.h, objective.x,objective.y,objective.w,objective.h) then
        objective.curTime = objective.curTime + dt
        if objective.curTime >= objective.time then
            GAMESTATE = "CREDITS"
        end
    else
        objective.curTime = 0
    end
end

function drawWorld()
    love.graphics.setColor(1,1,1,1)
    -- room bg
    for i,v in ipairs(world.rooms) do
        if world.bg.w % v.w ~= 0 then
            local bw = world.bg.w * math.floor(v.w / world.bg.w) -- background width with gap
            local dw = v.w - bw -- width error
            local dim = dw / (bw / world.bg.w) -- how much to change each image by to compensate
            local scale = (dim / world.bg.w) + 1 -- how much to scale the image to get that width change
            local newIw = world.bg.w * scale -- new image width

            for x = 0,v.w-1,newIw do
                love.graphics.draw(sprites.background, v.x+x,v.y-25, 0, scale,1)
            end
        else
            for x = 0,v.w-1,world.bg.w do
                love.graphics.draw(sprites.background, v.x+x,v.y-25)
            end
        end
    end

    -- room window
    for i,v in ipairs(world.windows) do
        if world.window.w % v.w ~= 0 then
            local bw = world.window.w * math.floor(v.w / world.window.w) -- background width with gap
            local dw = v.w - bw -- width error
            local dim = dw / (bw / world.window.w) -- how much to change each image by to compensate
            local scale = (dim / world.window.w) + 1 -- how much to scale the image to get that width change
            local newIw = world.window.w * scale -- new image width

            for x = 0,v.w-1,newIw do
                love.graphics.draw(sprites.window, v.x+x,v.y-25, 0, scale,1)
            end
        else
            for x = 0,v.w-1,world.window.w do
                love.graphics.draw(sprites.window, v.x+x,v.y-25)
            end
        end
    end

    -- blocks
    love.graphics.setColor(54/255, 57/255, 63/255)
    for i,v in ipairs(world.blocks) do
        love.graphics.rectangle("fill", v.x,v.y, v.w,v.h)
    end

    -- vents
    love.graphics.setColor(1, 1, 1, 1)
    for i,v in ipairs(world.vents) do
        drawinrect(sprites.vent, v[1].x,v[1].y, v[1].w,v[1].h)
        drawinrect(sprites.vent, v[2].x,v[2].y, v[2].w,v[2].h)

        if world.showVentConnections == true then
            love.graphics.line(v[1].x+v[1].w/2, v[1].y+v[1].h/2, v[2].x+v[2].w/2, v[2].y+v[2].h/2)
        end
    end

    -- stairs
    love.graphics.setColor(1, 1, 1, 1)
    for i,v in ipairs(world.stairs) do
        drawinrect(sprites.stairs, v[1].x,v[1].y, v[1].w,v[1].h)
        drawinrect(sprites.stairs, v[2].x,v[2].y, v[2].w,v[2].h)

        if world.showVentConnections == true then
            love.graphics.line(v[1].x+v[1].w/2, v[1].y+v[1].h/2, v[2].x+v[2].w/2, v[2].y+v[2].h/2)
        end
    end

    -- enemies
    for i,v in ipairs(world.enemies) do
        v:draw()
    end

    -- phonebox
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(sprites.phonebox, world.phonebox.x, world.phonebox.y, 0, world.phonebox.scale)

    -- floor
    for x=-1000, world.width+1301, 300 do 
        love.graphics.draw(sprites.floor, x, FLOOR_HEIGHT, 0, 3)
    end

    -- safe
    drawinrect(objectiveSprite, objective.x,objective.y,objective.w,objective.h)
end

function RoundToNumber(num,roundNum)
    if num%roundNum  >= roundNum/2 then
        return num - num%roundNum + roundNum
    else
        return num - num%roundNum
    end
end

function createSampleWorld()
    -- clear current level
    world.blocks = {}
    world.vents = {}
    world.stairs = {}
    world.rooms = {}
    world.enemies = {}

    -- floor
    addBlock(1000,600-875, 400,25 ,1)

    -- front wall
    addBlock(975,600-875, 25,150 ,1)

    -- back wall
    addBlock(1400,600-875, 25,275 ,1)

    -- floor
    addBlock(-1000,FLOOR_HEIGHT, world.width+1000,4000)

    -- enemy
    addEnemy(1075,-115.2, true, 100,100, false)

    -- vent
    addVent(1200, -50, 50,50, 1200, 550-875, 50,50)
end

function worldKeyPressed(key)
    if key == "f3" then
        loadLevel("level.lvl")
    elseif key == "f4" then
        world.blocks = {}
        world.vents = {} 
        createSampleWorld()
    elseif key == "f5" then -- readd floor lmao
        addBlock(-1000,FLOOR_HEIGHT, world.width+1000,4000)
    end
end