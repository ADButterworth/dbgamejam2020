local building = {h=0.6, w=0.1}
local width, height = love.graphics.getDimensions()
local LAYER_COUNT = 3
local BUILDINGS_PER_LAYER = 6
local layers = {}
local buildingSprites = {}
local cloudSprites = {} 
local layerMods = {0.4, 0.3, 0.1, 0.05}
local BUILDING_SCALE = {12,16,24}
local CLOUD_SCALE = 10
local layerTint = {0.7, 0.9, 1}
local skyImg = 0

function drawinrect(img, x, y, w, h)
    return -- tail call for a little extra bit of efficiency
    love.graphics.draw(img, x, y, 0, w / img:getWidth(), h / img:getHeight())
end

local function gradient(colors)
    local direction = colors.direction or "horizontal"
    if direction == "horizontal" then
        direction = true
    elseif direction == "vertical" then
        direction = false
    else
        error("Invalid direction '" .. tostring(direction) .. "' for gradient.  Horizontal or vertical expected.")
    end
    local result = love.image.newImageData(direction and 1 or #colors, direction and #colors or 1)
    for i, color in ipairs(colors) do
        local x, y
        if direction then
            x, y = 0, i - 1
        else
            x, y = i - 1, 0
        end
        result:setPixel(x, y, color[1], color[2], color[3], color[4] or 255)
    end
    result = love.graphics.newImage(result)
    result:setFilter('linear', 'linear')
    return result
end

local function checkInitX(b, l)
    for i,v in ipairs(l) do
        if not ((b.initx > (v.x+v.w+1)) or ((b.initx+b.w+1) < v.x)) then
            return false
        end
    end
    return true
end

function loadBGSprites()
    skyImg = gradient({{0, 85/255, 119/255}, {146/255, 201/255, 221/255}, gradient="vertical"})
    buildingSprites = {}
    buildingFiles = love.filesystem.getDirectoryItems("gfx/ss")
    for i,v in ipairs(buildingFiles) do
        sprite = {}
        sprite.img = love.graphics.newImage("gfx/ss/"..v)
        sprite.w = sprite.img:getWidth()
        sprite.h = sprite.img:getHeight() 
        table.insert(buildingSprites, sprite)
    end
    
    cloudSprites = {}
    cloudFiles = love.filesystem.getDirectoryItems("gfx/cloud")
    for i,v in ipairs(cloudFiles) do
        sprite = {}
        sprite.img = love.graphics.newImage("gfx/cloud/"..v)
        sprite.w = sprite.img:getWidth()
        sprite.h = sprite.img:getHeight()
        table.insert(cloudSprites, sprite)
    end
end

function genBGLayers()
    loadBGSprites()
    
    layers = {}
    for i=1,LAYER_COUNT do 
        l = {}
        for j=1,love.math.random(1, BUILDINGS_PER_LAYER) do
            b = {}
            b.sprite = love.math.random(1, #cloudSprites)
            b.y = CLOUD_HEIGHT + love.math.random(-200,200)
            b.w = cloudSprites[b.sprite].w * CLOUD_SCALE
            b.h = cloudSprites[b.sprite].h * CLOUD_SCALE

            local loopIterations = 0
            repeat
                b.initx = love.math.random(world.width*0.1, world.width - cloudSprites[b.sprite].w - (world.width * 0.1))
                loopIterations = loopIterations + 1
            until (checkInitX(b, l) or (loopIterations > 100))
            b.x = b.initx

            b.building = false
            table.insert(l, b)
        end
        cloudLayer = l

        l = {}
        for j=1,BUILDINGS_PER_LAYER do
            b = {}
            b.sprite = love.math.random(1, #buildingSprites)
            b.y = FLOOR_HEIGHT - (buildingSprites[b.sprite].h * BUILDING_SCALE[i])
            b.w = buildingSprites[b.sprite].w * BUILDING_SCALE[i]
            b.h = buildingSprites[b.sprite].h * BUILDING_SCALE[i]

            local loopIterations = 0
            repeat
                b.initx = love.math.random(world.width*0.1, world.width - buildingSprites[b.sprite].w - (world.width * 0.1))
                loopIterations = loopIterations + 1
            until (checkInitX(b, l) or (loopIterations > 100))
            b.x = b.initx

            b.building = true
            table.insert(l, b)
        end
    
        for j,b in ipairs(cloudLayer) do
            table.insert(l, b)
        end
        table.insert(layers, l)
    end 
end

function drawBGLayers()
    love.graphics.setColor(0.3,0.3,0.45,1)
    --love.graphics.setColor(146/255, 201/255, 221/255)
    --love.graphics.rectangle("fill",camera.x-camera.w/2,camera.y-camera.h/2, camera.w, camera.h)
    drawinrect(skyImg, camera.x-camera.w/2,camera.y-camera.h/2, camera.w, camera.h)
    love.graphics.setColor(1,1,1,1)
    for i,v in ipairs(layers) do 
        for j,b in ipairs(v) do
            if b.building then -- buildings
                love.graphics.setColor(1,1,1,1)
                love.graphics.draw(buildingSprites[b.sprite].img, b.x, b.y, 0, BUILDING_SCALE[i])
            else
                love.graphics.setColor(layerTint[i], layerTint[i], layerTint[i], 0.8)
                love.graphics.draw(cloudSprites[b.sprite].img, b.x, b.y, 0, CLOUD_SCALE)
            end
        end
    end 
    love.graphics.setColor(1,1,1,1)
end

function updateBGLayers(camx)
    for i,v in ipairs(layers) do 
        for j,b in ipairs(v) do
            b.x = b.initx + (camx-world.width/2) * layerMods[i]
        end
    end 
end