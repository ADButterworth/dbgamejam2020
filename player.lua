player = {}

local function clamp(min, val, max)
    return math.max(min, math.min(val, max));
end

function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end
function math.angle(x1,y1, x2,y2) return math.atan2(y2-y1, x2-x1) end

-- test if line passes inside box
function boxSegmentIntersection(l,t,w,h, x1,y1,x2,y2)
    local dx, dy  = x2-x1, y2-y1
  
    local t0, t1  = 0, 1
    local p, q, r
  
    for side = 1,4 do
      if     side == 1 then p,q = -dx, x1 - l
      elseif side == 2 then p,q =  dx, l + w - x1
      elseif side == 3 then p,q = -dy, y1 - t
      else                  p,q =  dy, t + h - y1
      end
  
      if p == 0 then
        if q < 0 then return nil end  -- Segment is parallel and outside the bbox
      else
        r = q / p
        if p < 0 then
          if     r > t1 then return nil
          elseif r > t0 then t0 = r
          end
        else -- p > 0
          if     r < t0 then return nil
          elseif r < t1 then t1 = r
          end
        end
      end
    end
  
    local ix1, iy1, ix2, iy2 = x1 + t0 * dx, y1 + t0 * dy,
                               x1 + t1 * dx, y1 + t1 * dy
  
    if ix1 == ix2 and iy1 == iy2 then return ix1, iy1 end
    return ix1, iy1, ix2, iy2
end

-- it crashes if you remove this lmao, must be referenced somewhere else
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
        x2 < x1+w1 and
        y1 < y2+h2 and
        y2 < y1+h1
end

-- this is black magic, do not touch, it will become even more broken than it already is 
local function playerCols(dt)
    onBlock = false
    for i,v in ipairs(world.blocks) do
        -- check y alignment with block
        if ((player.y + player.h) > v.y) and (player.y < (v.y + v.h)) then
            -- check on left of block
            if (player.x + player.w) <= v.x then
                -- check on next frame if past block
                if (player.x + player.w + (player.vx * dt)) >= v.x then
                    player.x = v.x - player.w
                    player.vx = 0
                end
            end

            -- check on right of block
            if player.x >= (v.x + v.w) then
                -- check on next frame if past block
                if (player.x + (player.vx * dt)) <= (v.x + v.w) then
                    player.x = v.x + v.w
                    player.vx = 0
                end
            end
        end 

        -- check x alignment with block
        if ((player.x + player.w) > v.x) and player.x < (v.x + v.w) then
            -- check above block
            if (player.y + player.h) <= v.y then
                -- check below on next frame
                if (player.y + player.h + (player.vy * dt)) >= v.y then 
                    player.y = v.y - player.h 
                    player.vy = 0 
                    player.grounded = true
                    onBlock = true
                end 
            end

            -- check below block
            if player.y >= (v.y + v.h) then
                -- check above on next frame
                if (player.y + (player.vy * dt)) <= (v.y + v.h) then
                    player.y = v.y + v.h
                    player.vy = 0
                end
            end
        end
    end

    if onBlock then
        player.grounded = true
    else
        player.grounded = false
    end
end

local function vents() -- and stairs
    for i,v in ipairs(world.vents) do
        -- check both sides
        -- nb setting the player to arrive centered on the x axis, and with their bottom edge aligned with the vents bottom edge
        if CheckCollision(player.x, player.y, player.w, player.h, v[1].x,v[1].y, v[1].w,v[1].h) then
            player.x = v[2].x + (v[2].w/2) - (player.w/2)
            player.y = v[2].y + v[2].h - player.h

            player.vx = 0
            player.vy = 0

            TEsound.pitch("vent", math.random(90,110)/100)
            TEsound.play(player.ventSound, "static", {"vent"}, 0.1)
        elseif CheckCollision(player.x, player.y, player.w, player.h, v[2].x,v[2].y, v[2].w,v[2].h) then
            player.x = v[1].x + (v[1].w/2) - (player.w/2)
            player.y = v[1].y + v[1].h - player.h

            player.vx = 0
            player.vy = 0

            TEsound.pitch("vent", math.random(90,110)/100)
            TEsound.play(player.ventSound, "static", {"vent"}, 0.1)
        end
    end

    for i,v in ipairs(world.stairs) do
        -- check both sides
        -- nb setting the player to arrive centered on the x axis, and with their bottom edge aligned with the vents bottom edge
        if CheckCollision(player.x, player.y, player.w, player.h, v[1].x,v[1].y, v[1].w,v[1].h) then
            player.x = v[2].x + (v[2].w/2) - (player.w/2)
            player.y = v[2].y + v[2].h - player.h

            player.vx = 0
            player.vy = 0
        elseif CheckCollision(player.x, player.y, player.w, player.h, v[2].x,v[2].y, v[2].w,v[2].h) then
            player.x = v[1].x + (v[1].w/2) - (player.w/2)
            player.y = v[1].y + v[1].h - player.h

            player.vx = 0
            player.vy = 0
        end
    end
end

function player:setup()
    player.speed = 600
    player.accel = 1500
    player.gravity = 1750
    player.jumpVel = 800
    player.friction = 2000

    player.runningSprites = {}
    local playerFiles = love.filesystem.getDirectoryItems("gfx/player/run")
    for i,v in ipairs(playerFiles) do
        local img = love.graphics.newImage("gfx/player/run/"..v)
        table.insert(player.runningSprites, img)
    end
    player.jumpSprite = love.graphics.newImage("gfx/player/Don Sprite Jump.png")
    player.crosshair = {}
    player.crosshair.img = love.graphics.newImage("gfx/ch.png")
    player.crosshair.w = player.crosshair.img:getWidth()
    player.crosshair.h = player.crosshair.img:getHeight()
    player.idleSprite = 8
    player.currentSprite = 8
    player.animDuration = 0.08
    player.animTimer = 0
    player.idleRight = true

    player.laserCDMAX = 5
    player.laserCD = 0
    player.laserX = 0
    player.laserY = 0
    player.laserMouseX = 0
    player.laserMouseY = 0
    player.laserAlpha = 1
    player.laserRemaining = 3
    player.laserSound = "sfx/lazer.mp3"

    player.ventSound = "sfx/vent.mp3"
    
    player.footsteps = {}
    local playerFiles = love.filesystem.getDirectoryItems("sfx/feetpics")
    for i,v in ipairs(playerFiles) do
        table.insert(player.footsteps, "sfx/feetpics/"..v)
    end
    player.playedStep = false
    player.jumpSound = "sfx/jump.mp3"

    player.scale = 2.4
    --player.w = player.runningSprites[player.idleSprite]:getWidth() * player.scale
    player.w = 20 * player.scale -- hardcoded to make the hitbox smaller, this hopefully will not cause awful problems later
    player.h = player.runningSprites[player.idleSprite]:getHeight() * player.scale

    player.spriteOffsetX = -7

    player.x = world.phonebox.x + (world.phonebox.w/2) - (player.w/2)
    player.y = FLOOR_HEIGHT-player.h

    player.prevVX = 0
    player.vx = 0
    player.vy = 0
    player.grounded = true

    player.inRoom = false
end

function player:update(dt)
    player.prevVX = player.vx

    -- GROUND MOVEMENT --
    if player.grounded then
        local turnFlag = false
        local input = false
        if love.keyboard.isDown("d") then
            if player.vx < 0 then
                turnFlag = true
            end
            player.vx = player.vx + player.accel * dt
            input = true
        end
        if love.keyboard.isDown("a") then
            if player.vx > 0 then
                turnFlag = true
            end
            player.vx = player.vx - player.accel * dt
            input = true
        end 
        
        if (turnFlag or not input) then
            if player.vx < 0 then
                if player.vx + player.friction * dt > 0 then
                    player.vx = 0
                else
                    player.vx = player.vx + player.friction * dt
                end
            end
            if player.vx > 0 then
                if player.vx - player.friction * dt < 0 then
                    player.vx = 0
                else
                    player.vx = player.vx - player.friction * dt
                end
            end
        end
    else
    -- AIR MOVEMENT --
        if love.keyboard.isDown("d") then
            player.vx = player.vx + (player.accel/2) * dt
        end
        if love.keyboard.isDown("a") then
            player.vx = player.vx - (player.accel/2) * dt
        end 
    end

    -- GRAVITY and JUMP --
    if not player.grounded then
        player.vy = player.vy + player.gravity * dt
    end
    
    if player.grounded and love.keyboard.isDown("space") then
        TEsound.pitch("jump", math.random(90,110)/100)
        TEsound.play(player.jumpSound, "static", {"jump"}, 0.1)
        player.grounded = false
        player.vy = -player.jumpVel
    end

    -- PUT THIS LAST YOU APE --
    playerCols(dt)
    player.vx = clamp(-1 * player.speed, player.vx, player.speed)
    player.x = player.x + player.vx * dt 
    player.y = player.y + player.vy * dt

    -- ANIMATION, after the last cue because yolo 
    player.animTimer = player.animTimer + dt 
    if player.animTimer >= player.animDuration then
        player.currentSprite = player.currentSprite + 1
        if player.currentSprite > #player.runningSprites then
            player.currentSprite = 1
        end
        player.animTimer = player.animTimer - player.animDuration
    end

    if player.vx == 0 then
        player.currentSprite = player.idleSprite
    end

    -- Footsteps
    if not (player.currentSprite == 2 or player.currentSprite == 6) then 
        player.playedStep = false
    end

    if (player.currentSprite == 2 or player.currentSprite == 6) and not player.playedStep and player.grounded then
        TEsound.pitch("toes", math.random(90,110)/100)
        TEsound.play(player.footsteps[math.random(1, #player.footsteps)], "static", {"toes"}, 0.1)
        player.playedStep = true 
    end

    -- catch frame when movement stops
    if player.vx == 0 and player.prevVX ~= 0 then
        if player.prevVX > 0 then
            player.idleRight = true
        else
            player.idleRight = false
        end
    end

    -- In room check for camera zoom
    local prevInRoom = player.inRoom
    local roomCheck = false
    for i,v in ipairs(world.rooms) do
        if CheckCollision(player.x, player.y, player.w, player.h, v.x,v.y,v.w,v.h) then
            roomCheck = true
            break
        end
    end
    if not roomCheck then
        for i,v in ipairs(world.windows) do
            if CheckCollision(player.x, player.y, player.w, player.h, v.x,v.y,v.w,v.h) then
                roomCheck = true
                break
            end
        end
    end
    if roomCheck then
        player.inRoom = true
        
        if not prevInRoom then
            flux.to(metaCam, 1, {sx=1.5, sy=1.5}):ease("quartout")
        end
    else 
        player.inRoom = false
    
        if prevInRoom then
            flux.to(metaCam, 1, {sx=1, sy=1}):ease("quartout")
        end
    end

    -- lazars
    if player.laserCD >= 0 then
        player.laserCD = player.laserCD - dt 
    end
end

function player:keypressed(key)
    if key == "f" then
        vents()
    elseif key == "e" then
        world.showVentConnections = not world.showVentConnections
    end
    
    if DEVELOPER then
        if key == "j" then
            player.spriteOffsetX = player.spriteOffsetX - 1
        elseif key == "k" then
            player.spriteOffsetX = player.spriteOffsetX + 1
        end
    end
end 

function player:mousepressed(x, y, button)
    if (player.laserCD <= 0) and (player.laserRemaining > 0) and button == 1 then
        for i,v in ipairs(world.enemies) do 
            local x1, y1 = boxSegmentIntersection(v.x,v.y,v.w,v.h, player.x + player.w/2, player.y + player.h/2 - 40, mouse.wx,mouse.wy)
            if x1 ~= nil then -- check if hit enemy
                local blocked = false
                for j,b in ipairs(world.blocks) do
                    if boxSegmentIntersection(b.x,b.y,b.w,b.h, player.x + player.w/2, player.y + player.h/2 - 40, x1,y1) then
                        blocked = true
                        break
                    end
                end

                if not blocked then
                    v.dead = true
                    break
                end
            end
        end

        player.laserX = player.x + player.w/2
        player.laserY = player.y + player.h/2 - 40
        player.laserMouseX = mouse.wx
        player.laserMouseY = mouse.wy
        player.laserAlpha = 1

        player.laserCD = player.laserCDMAX
        player.laserRemaining = player.laserRemaining - 1 

        TEsound.pitch("laser", math.random(90,110)/100)
        TEsound.play(player.laserSound, "static", {"laser"}, 0.1)

        flux.to(player, 0.5, {laserAlpha=0}):ease("quartout")
    end
end

function player:draw()
    if player.laserCD > 0 then
        love.graphics.setColor(1,0,0,player.laserAlpha)
        love.graphics.line(player.laserX,player.laserY, player.laserMouseX,player.laserMouseY)
    end

    love.graphics.setColor(1,1,1,1)
    if player.grounded then
        if player.vx > 0 then  
            love.graphics.draw(player.runningSprites[player.currentSprite], player.x + player.spriteOffsetX, player.y, 0, player.scale,player.scale)
        elseif player.vx < 0 then 
            love.graphics.draw(player.runningSprites[player.currentSprite], player.x - player.spriteOffsetX, player.y, 0, -player.scale,player.scale, player.w/player.scale)
        else
            if player.idleRight then
                love.graphics.draw(player.runningSprites[player.currentSprite], player.x + player.spriteOffsetX, player.y, 0, player.scale,player.scale)
            else
                love.graphics.draw(player.runningSprites[player.currentSprite], player.x - player.spriteOffsetX, player.y, 0, -player.scale,player.scale, player.w/player.scale)
            end 
        end
    else
        if player.vx > 0 then  
            love.graphics.draw(player.jumpSprite, player.x + player.spriteOffsetX, player.y, 0, player.scale,player.scale)
        elseif player.vx < 0 then 
            love.graphics.draw(player.jumpSprite, player.x - player.spriteOffsetX, player.y, 0, -player.scale,player.scale, player.w/player.scale)
        else
            if player.idleRight then
                love.graphics.draw(player.jumpSprite, player.x + player.spriteOffsetX, player.y, 0, player.scale,player.scale)
            else
                love.graphics.draw(player.jumpSprite, player.x - player.spriteOffsetX, player.y, 0, -player.scale,player.scale, player.w/player.scale)
            end 
        end
    end

    love.graphics.setColor(1,0,0,(0.5 * (1 - (player.laserCD / player.laserCDMAX))) + 0.1)
    love.graphics.draw(player.crosshair.img, mouse.wx, mouse.wy, 0,1,1, player.crosshair.w/2, player.crosshair.h/2)
    love.graphics.print(tostring(player.laserRemaining), mouse.wx+5, mouse.wy+5)
    love.graphics.setColor(1,1,1,1)

    -- bounding box test
    --love.graphics.rectangle("line", player.x, player.y, player.w, player.h)
    --love.graphics.line(player.x + player.w/2, player.y, player.x + player.w/2, player.y + player.h)
end

function player:respawn()
    player.laserCDMAX = 5
    player.laserCD = 0
    player.laserX = 0
    player.laserY = 0
    player.laserMouseX = 0
    player.laserMouseY = 0
    player.laserAlpha = 1
    player.laserRemaining = 3

    player.x = world.phonebox.x + (world.phonebox.w/2) - (player.w/2)
    player.y = FLOOR_HEIGHT-player.h
    player.grounded = true

    for i,v in ipairs(world.enemies) do
        v.dead = nil
    end
end