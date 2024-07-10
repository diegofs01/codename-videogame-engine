--! state 0 as "menu"
--! state 1 as "game"
--! state 2 as "check matches"
--! state 3 as "remove matched"
--! state ? as "pause"

--! 0 --> 1
--! 1 --> 2
--! 2 --> 3
--! 3 --> 1
--! 1 --> ?
--! ? ->> 1

local function init(std, game)
    game.state = 1
    game.switchState = false
    game.difficulty = 3 -- 1 easy, 2 normal, 3 hard
    game.highscore = game.highscore or 0
    game.score = 0

    game.boardStartHorizontal = 200
    game.boardStartVertical   = 120
    game.boardHorSize =  {7, 9, 11}  -- easy, normal, hard
    game.boardVerSize =  {8, 10, 12} -- easy, normal, hard
    game.board = {}

    local maxBrocos
    if game.difficulty == 1 then
        maxBrocos = 4
    elseif game.difficulty == 2 then
        maxBrocos = 5
    else
        maxBrocos = 6
    end
    for cont = 1, (game.boardHorSize[game.difficulty] * game.boardVerSize[game.difficulty]) do
        game.board[cont] = std.math.random(1, maxBrocos)
    end

    game.selected = {}
    game.selected.broco = 0
    game.selected.h = 0
    game.selected.v = 0

    game.playerPos = {}
    game.playerPos.h = 0
    game.playerPos.v = 0

    game.basePoints = 10
    game.brocoMultiplier = {10, 5, 2} -- easy, normal, hard
    game.bingoMultiplier = {5, 3, 1}  -- easy, normal, hard
    game.bingo = 0
    game.matches = 0
    
    game.count = {}
    game.count.squares = 0
    game.count.diamonds = 0
    game.count.triangles = 0
    game.count.plus = 0
    game.count.trapezoid = 0
    game.count.star = 0
    
    game.loopCount = 0
    game.canReadInput = true
end

local function draw_logo(std, game)
    std.draw.font('sans', 100)
    std.draw.color('white')
    std.draw.text(0, 0, 'BROCOS')
end

local function menu_logic(std, game)

end

local function draw_menu(std, game)
    
end

local function loop(std, game)

    --game
    if game.state == 1 then
        if game.canReadInput then
            if std.key.press.right == 1 and game.playerPos.h < (game.boardHorSize[game.difficulty] - 1) then
                game.playerPos.h = game.playerPos.h + 1
                game.canReadInput = false
            end
            if std.key.press.left == 1 and game.playerPos.h > 0 then
                game.playerPos.h = game.playerPos.h - 1
                game.canReadInput = false
            end
            if std.key.press.down == 1 and game.playerPos.v < (game.boardVerSize[game.difficulty] - 1) then
                game.playerPos.v = game.playerPos.v + 1
                game.canReadInput = false
            end
            if std.key.press.up == 1 and game.playerPos.v > 0 then
                game.playerPos.v = game.playerPos.v - 1
                game.canReadInput = false
            end
            if std.key.press.red == 1 then
                local index = 0
                -- if is empty
                if game.selected.broco == 0 then
                    index = (game.playerPos.v * game.boardHorSize[game.difficulty]) + game.playerPos.h + 1
                    game.selected.broco = game.board[index]
                    game.selected.h = game.playerPos.h
                    game.selected.v = game.playerPos.v
                --if is not empty
                else
                    local newSelectedH = game.playerPos.h
                    local newSelectedV = game.playerPos.v

                    local diffH = std.math.abs(game.selected.h - newSelectedH)
                    local diffV = std.math.abs(game.selected.v - newSelectedV)
                    
                    if (diffH + diffV) == 1 then
                        local toSwitch = 0
                        index = (game.playerPos.v * game.boardHorSize[game.difficulty]) + game.playerPos.h + 1
                        toSwitch = game.board[index]
                        if game.selected.broco ~= toSwitch then
                            game.board[index] = game.selected.broco
                            index = (game.selected.v * game.boardHorSize[game.difficulty]) + game.selected.h + 1
                            game.board[index] = toSwitch
                            game.switchState = true
                        end
                    end
                    index = 0
                    game.selected.broco = 0
                    game.selected.h = -1
                    game.selected.v = -1
                end
                game.canReadInput = false
            end
        end
    elseif game.state == 2 then
        local checkPosH = 0
        local checkPosV = 0
        local index = 0
        local limitH = game.boardHorSize[game.difficulty] - 2
        local limitV = game.boardVerSize[game.difficulty] - 2

        game.matches = 0
        game.bingo = 0
        --check rows
        while (checkPosV < game.boardVerSize[game.difficulty]) do
            while (checkPosH < limitH) do
                index = (checkPosV * game.boardHorSize[game.difficulty]) + checkPosH + 1
                game.matches = 0

                if game.board[index] > 0
                and game.board[index] < 7
                and game.board[index] == game.board[index + 1]
                and game.board[index] == game.board[index + 2] then
                    if checkPosH < (limitH - 1) and game.board[index] == game.board[index + 3] then
                        game.matches = game.matches + 1
                        game.board[index + 3] = 7
                        if checkPosH < (limitH - 2) and game.board[index] == game.board[index + 4] then
                            game.matches = game.matches + 1
                            game.board[index + 4] = 7
                        end
                    end

                    game.matches = game.matches + 3
                    game.bingo = game.bingo + 1
                    game.score = game.score + (game.matches * (game.basePoints * game.brocoMultiplier[game.difficulty]))
                    game.score = game.score + (game.bingo * game.bingoMultiplier[game.difficulty])
                    
                    if game.board[index] == 1 then
                        game.count.squares = game.count.squares + game.matches
                    elseif game.board[index] == 2 then
                        game.count.diamonds = game.count.diamonds + game.matches
                    elseif game.board[index] == 3 then
                        game.count.triangles = game.count.triangles + game.matches
                    elseif game.board[index] == 4 then
                        game.count.plus = game.count.plus + game.matches
                    elseif game.board[index] == 5 then
                        game.count.trapezoid = game.count.trapezoid + game.matches
                    elseif game.board[index] == 6 then
                        game.count.star = game.count.star + game.matches
                    end
                    
                    game.board[index + 2] = 7
                    game.board[index + 1] = 7
                    game.board[index] = 7
                end

                checkPosH = checkPosH + 1
            end
            checkPosH = 0
            checkPosV = checkPosV + 1
        end

        checkPosH = 0
        checkPosV = 0
        --check columns
        while (checkPosH < game.boardHorSize[game.difficulty]) do
            while (checkPosV < limitV) do
                index = (checkPosV * game.boardHorSize[game.difficulty]) + checkPosH + 1
                if game.board[index] > 0
                and game.board[index] < 7
                and game.board[index] == game.board[index + game.boardHorSize[game.difficulty]]
                and game.board[index] == game.board[index + (game.boardHorSize[game.difficulty] * 2)] then
                    if checkPosH < (limitV - 1) and game.board[index] == game.board[index + (game.boardHorSize[game.difficulty] * 3)] then
                        game.matches = game.matches + 1
                        game.board[index + 3] = 8
                        if checkPosH < (limitV - 2) and game.board[index] == game.board[index + (game.boardHorSize[game.difficulty] * 4)] then
                            game.matches = game.matches + 1
                            game.board[index + 4] = 8
                        end
                    end

                    game.matches = game.matches + 3
                    game.bingo = game.bingo + 1
                    game.score = game.score + (game.matches * (game.basePoints * game.brocoMultiplier[game.difficulty]))
                    game.score = game.score + (game.bingo * game.bingoMultiplier[game.difficulty])

                    if game.board[index] == 1 then
                        game.count.squares = game.count.squares + game.matches
                    elseif game.board[index] == 2 then
                        game.count.diamonds = game.count.diamonds + game.matches
                    elseif game.board[index] == 3 then
                        game.count.triangles = game.count.triangles + game.matches
                    elseif game.board[index] == 4 then
                        game.count.plus = game.count.plus + game.matches
                    elseif game.board[index] == 5 then
                        game.count.trapezoid = game.count.trapezoid + game.matches
                    elseif game.board[index] == 6 then
                        game.count.star = game.count.star + game.matches
                    end
                    
                    game.board[index + (game.boardHorSize[game.difficulty] * 2)] = 8
                    game.board[index + game.boardHorSize[game.difficulty]] = 8
                    game.board[index] = 8
                end
                checkPosV = checkPosV + 1
            end
            checkPosV = 0
            checkPosH = checkPosH + 1
        end
        game.switchState = true
    elseif game.state == 3 then
        local maxBrocos
        if game.difficulty == 1 then
            maxBrocos = 4
        elseif game.difficulty == 1 then
            maxBrocos = 5
        else
            maxBrocos = 6
        end
        for cont = 1, (game.boardHorSize[game.difficulty] * game.boardVerSize[game.difficulty]) do
            if game.board[cont] >= 7 then
                game.board[cont] = std.math.random(1, maxBrocos)
            end
        end
        game.switchState = true
    end
    if game.switchState then
        if game.state == 1 then
            game.state = 2
        elseif game.state == 2 then
            if game.bingo > 0 then
                game.state = 3
            else
                game.state = 1
            end
        elseif game.state == 3 then
            game.state = 1
        end
        game.switchState = false
    end
    if game.loopCount <= 60 then
        game.loopCount = game.loopCount + 1
    else
        game.loopCount = 1
    end
    if (game.loopCount % 10) == 0 and game.canReadInput == false then
        game.canReadInput = true
    end
end

local function renderBroco(std, game, posX, posY, broco)
    if broco == 1 then -- square
        std.draw.colorRgb(225, 215, 0) -- Gold #FFD700
        std.draw.rect('fill', posX + 2, posY + 2, 36, 36)
    elseif broco == 2 then -- diamond
        local diamond1 = {posX+19, posY+19, posX+2, posY+19, posX+19, posY+2}
        local diamond2 = {posX+20, posY+19, posX+37, posY+19, posX+20, posY+2}
        local diamond3 = {posX+20, posY+20, posX+37, posY+20, posX+20, posY+37}
        local diamond4 = {posX+19, posY+20, posX+2, posY+20, posX+19, posY+37}
        std.draw.colorRgb(185, 242, 255) -- Diamond #B9F2FF
        std.draw.poly('fill', diamond1)
        std.draw.poly('fill', diamond2)
        std.draw.poly('fill', diamond3)
        std.draw.poly('fill', diamond4)
    elseif broco == 3 then -- triangle
        local triangleLeft = {posX+19, posY+2, posX+19, posY+37, posX+2, posY+37}
        local triangleRight = {posX+20, posY+2, posX+20, posY+37, posX+37, posY+37}
        std.draw.colorRgb(0, 208, 98) -- Emerald #00D062
        std.draw.poly('fill', triangleLeft)
        std.draw.poly('fill', triangleRight)
    elseif broco == 4 then -- plus
        std.draw.colorRgb(61, 53, 75) -- Obsidian #3D354B
        std.draw.rect('fill', posX+14, posY+2, 11, 35)
        std.draw.rect('fill', posX+2, posY+14, 35, 11)
    elseif broco == 5 then -- trapezoid
        local trapezoid1 = {posX+12, posY+2, posX+12, posY+37, posX+2, posY+37}
        local trapezoid2 = {posX+12, posY+2, posX+12, posY+37, posX+27, posY+2}
        local trapezoid3 = {posX+27, posY+37, posX+27, posY+2, posX+12, posY+37}
        local trapezoid4 = {posX+27, posY+37, posX+27, posY+2, posX+37, posY+37}
        std.draw.colorRgb(23, 47, 93) -- Sapphire #172F5D
        std.draw.poly('fill', trapezoid1)
        std.draw.poly('fill', trapezoid2)
        std.draw.poly('fill', trapezoid3)
        std.draw.poly('fill', trapezoid4)
    elseif broco == 6 then -- star
        local star1 = {posX+2, posY+15, posX+20, posY+26, posX+37, posY+15}
        local star2 = {posX+20, posY+2, posX+20, posY+26, posX+2, posY+37}
        local star3 = {posX+20, posY+2, posX+20, posY+26, posX+37, posY+37}
        std.draw.colorRgb(220, 20, 60) -- Crimson #DC143C
        std.draw.poly('fill', star1)
        std.draw.poly('fill', star2)
        std.draw.poly('fill', star3)
    elseif broco == 7 then -- square, row/horizontal match
        std.draw.color('black')
        std.draw.rect('fill', posX+2, posY+14, 35, 11)
    elseif broco == 8 then -- square, column/vertical match
        std.draw.color('black')
        std.draw.rect('fill', posX+14, posY+2, 11, 35)
    end
end

local function draw(std, game)
    local startH = 0
    local startV = 0

    -- fill background
    std.draw.colorRgb(66, 66, 66)
    std.draw.rect('fill', 0, 0, game.width, game.height)
    --std.draw.clear('black')

    --draw_logo(std, game)

    if game.state == 0 then
        draw_menu(std, game)
    else 

        -- draw highscore
        startH = 40
        startV = 120
        std.draw.colorRgb(192, 192, 192)
        --std.draw.color('white')
        std.draw.rect('fill', startH , startV, 120, 80)
        std.draw.color('black')
        std.draw.text(startH, startV, 'HI-SCORE')
        std.draw.text(startH, startV + 40, string.format("%07d", game.highscore))

        -- draw broco count
        startH = 40
        startV = 240

        local maxV = 280
        if game.difficulty == 1 then
            maxV = 200
        elseif game.difficulty == 2 then
            maxV = 240
        else
            maxV = 280
        end

        std.draw.colorRgb(192, 192, 192)
        --std.draw.color('white')
        std.draw.rect('fill', startH, startV, 120, maxV)
        std.draw.color('black')
        std.draw.text(startH, startV, 'BROCO COUNT')

        renderBroco(std, game, startH, startV + 40, 1) --square
        std.draw.color('black')
        std.draw.text(startH + 40, startV + 40, string.format("%05d", game.count.squares))

        renderBroco(std, game, startH, startV + 80, 2) --diamond
        std.draw.color('black')
        std.draw.text(startH + 40, startV + 80, string.format("%05d", game.count.diamonds))

        renderBroco(std, game, startH, startV + 120, 3) --triangle
        std.draw.color('black')
        std.draw.text(startH + 40, startV + 120, string.format("%05d", game.count.triangles))

        renderBroco(std, game, startH, startV + 160, 4) --plus
        std.draw.color('black')
        std.draw.text(startH + 40, startV + 160, string.format("%05d", game.count.plus))

        if game.difficulty > 1 then
            renderBroco(std, game, startH, startV + 200, 5) --square
            std.draw.color('black')
            std.draw.text(startH + 40, startV + 200, string.format("%05d", game.count.trapezoid))

            if game.difficulty == 3 then
                renderBroco(std, game, startH, startV + 240, 6) --square
                std.draw.color('black')
                std.draw.text(startH + 40, startV + 240, string.format("%05d", game.count.star))
            end
        end

        local hor = 0
        local ver = 0
        local posH = 0
        local posV = 0

        if game.difficulty == 1 then
            startH = game.boardStartHorizontal + 80
            startV = game.boardStartVertical
        elseif game.difficulty == 2 then
            startH = game.boardStartHorizontal + 40
            startV = game.boardStartVertical
        else
            startH = game.boardStartHorizontal
            startV = game.boardStartVertical
        end

        -- draw board background
        std.draw.colorRgb(192, 192, 192)
        std.draw.rect('fill', startH, startV, (game.boardHorSize[game.difficulty] * 40), (game.boardVerSize[game.difficulty] * 40))

        -- draw brocos
        for i = 1, (game.boardHorSize[game.difficulty] * game.boardVerSize[game.difficulty]) do
            posH = startH + (hor * 40)
            posV = startV + (ver * 40)
            renderBroco(std, game, posH, posV, game.board[i])       
            hor = hor + 1
            if(hor >= game.boardHorSize[game.difficulty]) then
                hor = 0
                ver = ver + 1
            end
        end

        -- draw player
        startH = startH + (game.playerPos.h * 40)
        startV = startV + (game.playerPos.v * 40)
        std.draw.color('black')
        std.draw.rect('line', startH, startV, 40, 40)

        -- draw selected broco
        startH = 680
        startV = 120
        std.draw.colorRgb(192, 192, 192)
        --std.draw.color('white')
        std.draw.rect('fill', startH, startV, 120, 160)
        std.draw.color('black')
        std.draw.text(startH, startV, 'SELECTED')
        if game.selected.broco > 0 then
            renderBroco(std, game, startH+40, startV + 80, game.selected.broco)
            startH = game.boardStartHorizontal + (game.selected.h * 40)
            startV = game.boardStartVertical + (game.selected.v * 40)
            if game.difficulty == 1 then
                startH = startH + 80
            elseif game.difficulty == 1 then
                startH = startH + 40
            end
            std.draw.color('black')
            std.draw.rect('line', startH, startV, 40, 40)
        end

        startH = 680
        startV = 320
        -- draw score
        std.draw.colorRgb(192, 192, 192)
        --std.draw.color('white')
        std.draw.rect('fill', startH , startV, 96, 64)
        std.draw.color('black')
        std.draw.text(startH, startV, '  SCORE')
        std.draw.text(startH, startV + 40, string.format("%07d", game.score))
          
    end
end

local function exit(std, game)
    game.highscore = std.math.clamp(game.highscore, game.score, game.highscore)
end

local P = {
    meta={
        title='Brocos',
        description='brocos',
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