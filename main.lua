function love.load()
    wf = require 'libs/windfield'
    anim8 = require 'libs/anim8/anim8'

    sprites = {}
    sprites.playerSheet = love.graphics.newImage('sprites/playerSheet.png')

    local grid = anim8.newGrid(614, 564, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())

    animations = {}
    animations.idle = anim8.newAnimation(grid('1-15', 1), 0.05)
    animations.jump = anim8.newAnimation(grid('1-7', 2), 0.05)
    animations.run = anim8.newAnimation(grid('1-15', 3), 0.05)

    W = love.graphics.getWidth()
    H = love.graphics.getHeight()
    world = wf.newWorld(0, 500, false)
    world:setQueryDebugDrawing(true)

    world:addCollisionClass('Platform')
    world:addCollisionClass('Player')
    world:addCollisionClass('Danger')
    -- world:addCollisionClass('Player', {ignores = {'Platform'}})

    player = world:newRectangleCollider(360, 100, 40, 100, {collision_class = 'Player'})
    player:setFixedRotation(true)
    player.speed = 240
    player.animation = animations.idle
    player.isMoving = false
    player.direction = 1        -- player direction 1 = right, -1 = left
    player.grounded = true

    platform = world:newRectangleCollider(250, 400, 300, 100, {collision_class = 'Platform'})
    platform:setType('static')

    dangerZone = world:newRectangleCollider(0, 550, 800, 50, {collision_class = 'Danger'})
    dangerZone:setType('static')
end

function love.update(dt)
    world:update(dt)

    if player.body then

        local colliders = world:queryRectangleArea(player:getX() - 20, player:getY() + 50, 40, 2, {'Platform'})
        if #colliders > 0 then
            player.grounded = true
        else 
            player.grounded = false
        end        

        player.isMoving = false
        local px, py = player:getPosition()
        if love.keyboard.isDown('right') then
            player:setX(px + player.speed * dt)
            player.isMoving = true
            player.direction = 1
        end
        if love.keyboard.isDown('left') then
            player:setX(px - player.speed * dt)
            player.isMoving = true
            player.direction = -1
        end
    
        if player:enter('Danger') then
            player:destroy()
        end
    end

    if player.grounded then

        if player.isMoving then
            player.animation = animations.run
        else
            player.animation = animations.idle
        end
    else
        player.animation = animations.jump
    end

    player.animation:update(dt)
end

function love.draw()
    world:draw()

    local px, py = player:getPosition()
    player.animation:draw(sprites.playerSheet, px, py, nil, 0.25 * player.direction, 0.25, 130, 300)
end

function love.keypressed(key)
    if key == 'up' then
        if player.grounded then
            player:applyLinearImpulse(0, -4000)
        end
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        local colliders = world:queryCircleArea(x, y, 200)
    end
end