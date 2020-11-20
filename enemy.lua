class = require("lib/middleclass")

Enemy = class("Enemy")

enemySprites = {}
enemyIdleSprite = 8
enemyScale = 2.4

enemyVisionAngle = math.pi / 4
enemyVisionRange = 300
local enemyFiles = love.filesystem.getDirectoryItems("gfx/enemy")
for i,v in ipairs(enemyFiles) do
    local img = love.graphics.newImage("gfx/enemy/"..v)
    table.insert(enemySprites, img)
end
deadEnemySprite = love.graphics.newImage("gfx/deadene.png")

local function enemyDraw(ene)
    love.graphics.setColor(1,1,1,1)

    if ene.dead == nil then
        if ene.facingRight then
            love.graphics.draw(enemySprites[ene.currentSprite], ene.x + ene.spriteOffsetX, ene.y, 0, ene.scale,ene.scale)

            love.graphics.setColor(1,0,0,0.1)
            love.graphics.arc("fill", ene.x + ene.w/2, ene.y + ene.h/2 - 40, enemyVisionRange, -enemyVisionAngle/2, enemyVisionAngle/2)
        else
            love.graphics.draw(enemySprites[ene.currentSprite], ene.x - ene.spriteOffsetX, ene.y, 0, -ene.scale,ene.scale, ene.w/ene.scale)
            love.graphics.setColor(1,0,0,0.1)
            love.graphics.arc("fill", ene.x + ene.w/2, ene.y + ene.h/2 - 40, enemyVisionRange, math.pi-enemyVisionAngle/2, math.pi + enemyVisionAngle/2)
        end 
    else
        love.graphics.draw(deadEnemySprite, ene.x + ene.spriteOffsetX + ene.w - (deadEnemySprite:getWidth() * ene.scale), ene.y + ene.h - (deadEnemySprite:getHeight() * ene.scale), 0, ene.scale,ene.scale)
    end

    love.graphics.setColor(1,1,1,1)
end

function Enemy:initialize(x,y, left, pl,pr, idle)
    self.idleSprite = enemyIdleSprite
    self.currentSprite = 8
    self.animDuration = 0.16
    self.animTimer = 0
    self.facingRight = not left 

    self.scale = enemyScale
    self.w = 20 * self.scale -- hardcoded to make the hitbox smaller, this hopefully will not cause awful problems later
    self.h = enemySprites[self.idleSprite]:getHeight() * self.scale
    self.spriteCount = #enemySprites
    self.spriteOffsetX = -7

    self.x = x
    self.y = y

    self.startX = self.x
    self.patrolLeft = pl
    self.patrolRight = pr

    self.speed = 150
    self.prevVX = 0
    self.vx = 0
    self.vy = 0

    self.idle = idle
end

function Enemy:setPatrol(left, right)
    self.patrolLeft = left
    self.patrolRight = right
    self.idle = false
end

function Enemy:update(dt)
    if self.dead == nil then -- mood
        if not self.idle then
            if self.facingRight and (self.x - self.startX >= self.patrolRight) then
                self.facingRight = false
            elseif (not self.facingRight) and (self.startX - self.x >= self.patrolLeft) then
                self.facingRight = true
            end

            if self.facingRight then
                self.vx = self.speed
            else
                self.vx = -self.speed
            end
        end

        self.x = self.x + self.vx * dt 
        self.y = self.y + self.vy * dt

        -- ANIMATION, after the last cue because yolo 
        self.animTimer = self.animTimer + dt 
        if self.animTimer >= self.animDuration then
            self.currentSprite = self.currentSprite + 1
            if self.currentSprite > self.spriteCount then
                self.currentSprite = 1
            end
            self.animTimer = self.animTimer - self.animDuration
        end

        if self.vx == 0 then
            self.currentSprite = self.idleSprite
        end
    end
end

function Enemy:draw()
    enemyDraw(self)
end

function EnemyVisionCheck(px,py)
    local enemyNotices = false
    
    for i,v in ipairs(world.enemies) do 
        if v.dead == nil then
            love.graphics.setColor(1,0,0,1)

            local angle = math.angle(v.x + v.w/2, v.y + v.h/2 - 40, px, py)
            local angleMatch = false
            if v.facingRight then
                if angle < enemyVisionAngle/2 and angle > -enemyVisionAngle/2 then -- angle
                    angleMatch = true
                end
            else
                if angle < (math.pi + enemyVisionAngle/2) and angle > (math.pi - enemyVisionAngle/2) then -- angle
                    angleMatch = true
                end
            end

            if angleMatch then
                if math.dist(v.x + v.w/2, v.y + v.h/2 - 40, px, py) < enemyVisionRange then -- distance

                    -- walls
                    local blockCheck = false
                    for j,b in ipairs(world.blocks) do 
                        if (boxSegmentIntersection(b.x,b.y,b.w,b.h, v.x + v.w/2, v.y + v.h/2 - 40, px, py)) then
                            blockCheck = true
                            break
                        end
                    end

                    if not blockCheck then
                        enemyNotices = true
                        break
                    end
                end 
            end
        end
    end

    return enemyNotices
end