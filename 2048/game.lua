--! state 0 as "menu"
--! state 1 as "game loop"
--! state 2 as "check end"
--! state 3 as "generate new number"
--! state 10 as "pause"
--! state 99 as "end screen"

--! 0 --> 1
--! 1 --> 2
--! 1 --> 10
--! 2 --> 3
--! 2 --> 99
--! 3 --> 1
--! 10 --> 0

--! 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4192?, 8384?, 16768?, 33536?, 67072?, 134144?, 268288?
--!                                            /\                   /\              /\               /\
--! cores  r    g    b
--! 2   = 240, 223,  21
--! 4   = 240, 179,  21
--! 8   = 240, 127,  21
--! 16  = 240,  83,  21
--! 32  = 240,  28,  21
--! 64  = 240,  21,  86
--! 128 = 240,  21, 162
--! 256 = 240,  21, 225
--!

local function setRGBColor(std,r,g,b)
    r = std.math.clamp(r, 0, 255)
    g = std.math.clamp(g, 0, 255)
    b = std.math.clamp(b, 0, 255)
    std.draw.colorRgb(r,g,b)
end

local function init(std, game)
    game.colors = {}
    game.colors[0] =   {192, 192, 192}
    game.colors[2] =   {240, 223,  21}
    game.colors[4] =   {240, 179,  21}
    game.colors[8] =   {240, 127,  21}
    game.colors[16] =  {240,  83,  21}
    game.colors[32] =  {240,  28,  21}
    game.colors[64] =  {240,  21,  86}
    game.colors[128] = {240,  21, 162}
    game.colors[256] = {240,  21, 225}

    game.board = {}
    game.boardHSize = 320
    game.boardVSize = 320
    game.score = 0
    game.highscore = game.highscore or 0

    game.state = 1
    game.switchState = false
    game.finish = false
    game.loopCount = 1
    game.canReadInput = true

    game.direction = ''

    for i = 1, 4 do
        game.board[i] = {}
        for j = 1, 4 do
            game.board[i][j] = 0
            if i == 1 and (j == 2 or j == 3) then
                game.board[i][j] = 2
            end
        end
    end
end

local function move_numbers(std, game, direction)
    print('move_numbers ' .. direction)
    local i = 1
    local j = 1
    local newJ = j
    if direction == 'left' then
        i = 1
        while (i < 5) do
            j = 2
            while (j < 5) do
                print(i .. '-' .. j)
                if game.board[i][j] > 0 then
                    newJ = j
                    while true do
                        if newJ > 1 then
                            if game.board[i][newJ - 1] == 0 then
                                print('zero')
                                game.board[i][newJ - 1] = game.board[i][newJ]
                                game.board[i][newJ] = 0
                                newJ = newJ - 1
                            elseif game.board[i][newJ - 1] == game.board[i][newJ] then
                                print('igual')
                                game.board[i][newJ - 1] = game.board[i][newJ - 1] * 2
                                game.board[i][newJ] = 0
                                newJ = newJ - 1
                            elseif game.board[i][newJ - 1] ~= game.board[i][newJ] then
                                print('diferente')
                                --newJ = 1
                                j = j + 1
                                break
                            end
                        else
                            break
                        end
                    end
                else 
                    j = j + 1
                end
            end
            i = i + 1
        end
        game.switchState = true
    elseif direction == 'right' then
        i = 1
        while (i < 5) do
            j = 3
            while (j > 0) do
                print(i .. '-' .. j)
                if game.board[i][j] > 0 then
                    newJ = j
                    while true do
                        if newJ < 4 then
                            if game.board[i][newJ + 1] == 0 then
                                print('zero')
                                game.board[i][newJ + 1] = game.board[i][newJ]
                                game.board[i][newJ] = 0
                                newJ = newJ + 1
                            elseif game.board[i][newJ + 1] == game.board[i][newJ] then
                                print('igual')
                                game.board[i][newJ + 1] = game.board[i][newJ + 1] * 2
                                game.board[i][newJ] = 0
                                newJ = newJ + 1
                            elseif game.board[i][newJ + 1] ~= game.board[i][newJ] then
                                print('diferente')
                                j = j - 1
                                break
                            end
                        else
                            break
                        end
                    end
                else 
                    j = j - 1
                end
            end
            i = i + 1
        end
        game.switchState = true
    end
end

local function check_end(std, game)
    game.finish = true
    for i = 1, 4 do
        for j = 1, 4 do
            if game.board[i][j] == 0 then
                game.finish = false
            end
        end
    end
    game.switchState = true
end

local function generate_number(std, game)
    print('generate_number')
    local i, j
    repeat
        i = std.math.random(1,4)
        j = std.math.random(1,4)
    until(game.board[i][j] == 0)
    local num = std.math.random(1, 100)
    if num < 90 then
        game.board[i][j] = 2
    else
        game.board[i][j] = 4
    end
    game.switchState = true
end

local function loop(std, game)
    if game.state == 1 then
        if std.key.press.left == 1 then
            move_numbers(std, game, 'left')
            game.direction = 'left'
            game.canReadInput = false
        elseif std.key.press.right == 1 then
            move_numbers(std, game, 'right')
            game.direction = 'right'
            game.canReadInput = false
        elseif std.key.press.up == 1 then
            move_numbers(std, game, 'up')
            game.direction = 'up'
            game.canReadInput = false
        elseif std.key.press.down == 1 then
            move_numbers(std, game, 'down')
            game.direction = 'down'
            game.canReadInput = false
        end
    elseif game.state == 2 then
        check_end(std, game)
    elseif game.state == 3 then
        generate_number(std, game)
    end
    if game.switchState then
        game.switchState = false
        if game.state == 1 then
            game.state = 2
        elseif game.state == 2 then
            if game.finish then
                game.state = 99
            else
                game.state = 3
            end
        elseif game.state == 3 then
            game.state = 1
        end
    end
    if game.loopCount <= 120 then
        game.loopCount = game.loopCount + 1
    else
        game.loopCount = 1
        if game.canReadInput == false then
            game.canReadInput = true
        end
    end
end

local function draw(std, game)
    local startH = (game.width - game.boardHSize) / 2
    local startV = (game.height - game.boardVSize) / 2
    std.draw.clear()

    if game.state == 99 then
        std.draw.color('white')
        std.draw.text(startH, game.height - 20, 'GAME OVER')
    else
        local offsetH = 0
        local offsetV = 0
        for i = 1, 4 do
            for j = 1, 4 do
                local num = game.board[i][j]
                setRGBColor(std, game.colors[num][1], game.colors[num][2], game.colors[num][3])
                std.draw.rect('fill', startH + offsetH, startV + offsetV, 80, 80)
                std.draw.color('black')
                std.draw.text(startH + offsetH, startV + offsetV, num)
                offsetH = offsetH + 80
            end
            offsetH = 0
            offsetV = offsetV + 80
        end

        std.draw.color('white')
        std.draw.text(startH, game.height - 20, game.fps)
        std.draw.text(startH, game.height - 40, game.direction)
    end
end

local function exit(std, game)
    game.highscore = std.math.max(game.highscore, game.score)
end

local P = {
    meta={
        title='2048 Clone',
        description='Simple clone of the game 2048',
        version='1.0.0'
    },
    callbacks={
        init=init,
        loop=loop,
        draw=draw,
        exit=exit
    }
}

return P;
