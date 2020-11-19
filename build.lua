BUILD_MODE = false
build = {}
build.type = 1
build.pos1 = nil
build.pos2 = nil
build.selected = false

function drawBuild()
    -- grid
    love.graphics.setColor(1,1,1,0.5)
    for x=0,world.width,25 do
        love.graphics.line(x,-world.height,x,0)
    end
    for y=0,-world.height,-25 do
        love.graphics.line(0,y,world.width,y)
    end
    love.graphics.setColor(1,1,1,1)
    love.graphics.circle("fill",RoundToNumber(mouse.wx, 25), RoundToNumber(mouse.wy, 25), 5)

    if build.type == 1 then
        love.graphics.print("wall", RoundToNumber(mouse.wx, 25)-20, RoundToNumber(mouse.wy, 25) - 20)
    elseif build.type == 2 then
        love.graphics.print("vent", RoundToNumber(mouse.wx, 25)-20, RoundToNumber(mouse.wy, 25) - 20)
    elseif build.type == 3 then
        love.graphics.print("room", RoundToNumber(mouse.wx, 25)-20, RoundToNumber(mouse.wy, 25) - 20)
    elseif build.type == 4 then
        love.graphics.print("stairs", RoundToNumber(mouse.wx, 25)-20, RoundToNumber(mouse.wy, 25) - 20)
    elseif build.type == 5 then
        love.graphics.print("enemy", RoundToNumber(mouse.wx, 25)-20, RoundToNumber(mouse.wy, 25) - 20)
    elseif build.type == 6 then
        love.graphics.print("window", RoundToNumber(mouse.wx, 25)-20, RoundToNumber(mouse.wy, 25) - 20)
    end
    love.graphics.print(tostring(RoundToNumber(mouse.wx, 25))..", "..RoundToNumber(mouse.wy, 25), RoundToNumber(mouse.wx, 25)-20, RoundToNumber(mouse.wy, 25) + 10)

    if build.type == 1 or build.type == 3 or build.type == 6 then -- walls and rooms and windows
        love.graphics.setColor(0,1,0,1)
        if build.selected == true then
            if build.pos2 == nil then
                love.graphics.rectangle("line", build.pos1.x, build.pos1.y, RoundToNumber(mouse.wx, 25) - build.pos1.x, RoundToNumber(mouse.wy, 25) - build.pos1.y)
            else
                love.graphics.rectangle("fill", build.pos1.x, build.pos1.y, build.pos2.x - build.pos1.x, build.pos2.y - build.pos1.y)
            end
        end
    elseif build.type == 2 or build.type == 4 or build.type == 5 then -- vents and stairs
        love.graphics.setColor(1,0,0,1)
        if build.pos1 ~= nil then
            if build.pos1.w == nil then 
                love.graphics.rectangle("line", build.pos1.x, build.pos1.y, RoundToNumber(mouse.wx, 25) - build.pos1.x, RoundToNumber(mouse.wy, 25) - build.pos1.y)
            else
                love.graphics.rectangle("fill", build.pos1.x, build.pos1.y, build.pos1.w, build.pos1.h)
            end
        end 

        if build.pos2 ~= nil then
            if build.pos2.w == nil then 
                love.graphics.rectangle("line", build.pos2.x, build.pos2.y, RoundToNumber(mouse.wx, 25) - build.pos2.x, RoundToNumber(mouse.wy, 25) - build.pos2.y)
            else
                love.graphics.rectangle("fill", build.pos2.x, build.pos2.y, build.pos2.w, build.pos2.h)
            end
        end 
    end

    -- rooms
    love.graphics.setColor(0,0,1,0.3)
    for i,v in ipairs(world.rooms) do
        love.graphics.rectangle("fill", v.x,v.y, v.w,v.h)
    end
end

function buildMousePressed(x, y, button)
    if build.type == 1 or build.type == 3 or build.type == 6 then -- walls and rooms and windows
        if button == 1 then
            if not build.selected then
                build.pos1 = {x = RoundToNumber(mouse.wx, 25), y = RoundToNumber(mouse.wy, 25)}
                build.selected = true
            else
                build.pos2 = {x = RoundToNumber(mouse.wx, 25), y = RoundToNumber(mouse.wy, 25)}
            end
        end

        if build.selected and button == 2 then -- clear selection
            build.pos1 = nil
            build.pos2 = nil
            build.selected = false
        end

        if build.type == 1 then
            if (not build.selected) and button == 2 then -- delete walls
                for i,v in ipairs(world.blocks) do
                    if CheckCollision(mouse.wx,mouse.wy,0,0, v.x,v.y,v.w,v.h) then
                        table.remove(world.blocks, i)
                        break
                    end
                end
            end
        else
            if (not build.selected) and button == 2 then -- delete rooms
                for i,v in ipairs(world.rooms) do
                    if CheckCollision(mouse.wx,mouse.wy,0,0, v.x,v.y,v.w,v.h) then
                        table.remove(world.rooms, i)
                        break
                    end
                end
            end
        end
    elseif build.type == 2 or build.type == 4 or build.type == 5 then -- vents and stairs and enemies
        if button == 1 then
            if build.pos1 == nil and build.selected == false then -- no point 1 for pos1 
                build.pos1 = {x = RoundToNumber(mouse.wx, 25), y = RoundToNumber(mouse.wy, 25)}
                build.selected = true
            elseif build.pos1.w == nil and build.selected == true then -- pos1 not complete
                build.pos1.w = RoundToNumber(mouse.wx, 25) - build.pos1.x
                build.pos1.h = RoundToNumber(mouse.wy, 25) - build.pos1.y
                build.selected = false
            elseif build.pos2 == nil and build.selected == false then -- no point 1 for pos2
                build.pos2 = {x = RoundToNumber(mouse.wx, 25), y = RoundToNumber(mouse.wy, 25)}
                build.selected = true
            elseif build.pos2.w == nil and build.selected == true then -- pos2 not complete
                build.pos2.w = RoundToNumber(mouse.wx, 25) - build.pos2.x
                build.pos2.h = RoundToNumber(mouse.wy, 25) - build.pos2.y
                build.selected = false 
            end
        end

        if (build.pos1 ~= nil or build.pos2 ~= nil) and button == 2 then -- clear selection
            build.pos1 = nil
            build.pos2 = nil
            build.selected = false
        end

        if (not build.selected) and (button == 2) and (build.pos1 == nil) then -- delete vents or stairs or enemies
            if build.type == 2 then
                for i,v in ipairs(world.vents) do
                    if CheckCollision(mouse.wx,mouse.wy,0,0, v[1].x,v[1].y,v[1].w,v[1].h) then
                        table.remove(world.vents, i)
                        break
                    end

                    if CheckCollision(mouse.wx,mouse.wy,0,0, v[2].x,v[2].y,v[2].w,v[2].h) then
                        table.remove(world.vents, i)
                        break
                    end
                end
            elseif build.type == 4 then
                for i,v in ipairs(world.stairs) do
                    if CheckCollision(mouse.wx,mouse.wy,0,0, v[1].x,v[1].y,v[1].w,v[1].h) then
                        table.remove(world.stairs, i)
                        break
                    end

                    if CheckCollision(mouse.wx,mouse.wy,0,0, v[2].x,v[2].y,v[2].w,v[2].h) then
                        table.remove(world.stairs, i)
                        break
                    end
                end
            else
                for i,v in ipairs(world.enemies) do
                    if CheckCollision(mouse.wx,mouse.wy,0,0, v.x,v.y,v.w,v.h) then
                        table.remove(world.enemies, i)
                        break
                    end
                end
            end
        end
    end
end

function buildKeyPressed(key)
    if key == "return" then
        if build.type == 1 and build.pos2 ~= nil then
            -- protect against backwards blocks, pos1 MUST be the top left for collisions to function properly
            local bw = build.pos2.x - build.pos1.x
            local bh = build.pos2.y - build.pos1.y

            if bw < 0 then
                build.pos1.x = build.pos1.x + bw
                build.pos2.x = build.pos1.x - bw
            end
            if bh < 0 then
                build.pos1.y = build.pos1.y + bh
                build.pos2.y = build.pos1.y - bh
            end

            addBlock(build.pos1.x, build.pos1.y, build.pos2.x - build.pos1.x, build.pos2.y - build.pos1.y, 1)
        elseif (build.type == 2 or build.type == 4 or build.type == 5) and build.pos2 ~= nil and build.pos2.w ~= nil then
            -- protect against backwards blocks as above, just more complex
            if build.pos1.w < 0 then
                local temp = build.pos1
                build.pos1.x = temp.x + temp.w
                build.pos1.w = -temp.w
            end
            if build.pos1.h < 0 then
                local temp = build.pos1
                build.pos1.y = temp.y + temp.h
                build.pos1.h = -temp.h
            end
            if build.pos2.w < 0 then
                local temp = build.pos2
                build.pos2.x = temp.x + temp.w
                build.pos2.w = -temp.w
            end
            if build.pos2.h < 0 then
                local temp = build.pos2
                build.pos2.y = temp.y + temp.h
                build.pos2.h = -temp.h
            end

            if build.type == 2 then
                addVent(build.pos1.x, build.pos1.y, build.pos1.w, build.pos1.h, build.pos2.x, build.pos2.y, build.pos2.w, build.pos2.h)
            elseif build.type == 4 then
                addStairs(build.pos1.x, build.pos1.y, build.pos1.w, build.pos1.h, build.pos2.x, build.pos2.y, build.pos2.w, build.pos2.h)
            else 
                local ex = build.pos1.x + build.pos1.w/2 - (enemySprites[enemyIdleSprite]:getWidth() * enemyScale)/2
                local ey = build.pos1.y + build.pos1.h - (enemySprites[enemyIdleSprite]:getHeight() * enemyScale)
                
                if build.pos2.w ~= 0 then -- patrolling
                    local epl = ex - build.pos2.x
                    local epr = build.pos2.x + build.pos2.w - ex
                    addEnemy(ex, ey, true, epl, epr, false)
                else -- idle
                    if build.pos2.x < ex then
                        addEnemy(ex, ey, true, 0, 0, true)
                    else
                        addEnemy(ex, ey, false, 0, 0, true)
                    end
                end
            end
        elseif (build.type == 3 or build.type == 6) and build.pos2 ~= nil then
            -- protect against backwards blocks, pos1 MUST be the top left for collisions to function properly
            local bw = build.pos2.x - build.pos1.x
            local bh = build.pos2.y - build.pos1.y

            if bw < 0 then
                build.pos1.x = build.pos1.x + bw
                build.pos2.x = build.pos1.x - bw
            end
            if bh < 0 then
                build.pos1.y = build.pos1.y + bh
                build.pos2.y = build.pos1.y - bh
            end

            if build.type == 3 then
                addRoom(build.pos1.x, build.pos1.y, build.pos2.x - build.pos1.x, build.pos2.y - build.pos1.y, 1)
            else
                addWindow(build.pos1.x, build.pos1.y, build.pos2.x - build.pos1.x, build.pos2.y - build.pos1.y, 1)
            end
        end

        build.pos1 = nil 
        build.pos2 = nil 
        build.selected = false
    end 

    -- save to level.lvl in games appdata folder
    if key == "f2" then
        writeWorld()
    end

    -- toggle build type needs to clear the current selection too
    if key == "1" then
        build.type = 1
        build.pos1 = nil
        build.pos2 = nil
        build.selected = false
    elseif key == "2" then
        build.type = 2
        build.pos1 = nil
        build.pos2 = nil
        build.selected = false
    elseif key == "3" then
        build.type = 3
        build.pos1 = nil
        build.pos2 = nil
        build.selected = false
    elseif key == "4" then
        build.type = 4
        build.pos1 = nil
        build.pos2 = nil
        build.selected = false
    elseif key == "5" then
        build.type = 5
        build.pos1 = nil
        build.pos2 = nil
        build.selected = false
    elseif key == "6" then
        build.type = 6
        build.pos1 = nil
        build.pos2 = nil
        build.selected = false
    end
end 

-- voodoo magic
function writeWorld()
    local dir = love.filesystem.getSaveDirectory()
    dir = dir.."/level.lvl"

    local dataString = bitser.dumps({world.blocks, world.vents, world.stairs, world.rooms, world.enemies, world.windows})

    local file, error = love.filesystem.newFile("level.lvl", "w")
    if file == nil then
        print("Couldn't open file: "..error)
    else
        local success, err = file:write(dataString)
        file:flush()
        file:close()
    end
end