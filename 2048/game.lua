--! state 0 as "menu"
--! state 1 as "game loop"
--! state 2 as "check end"
--! state 10 as "pause"

--! 0 --> 1
--! 1 --> 2
--! 1 --> 10
--! 2 --> 1
--! 10 --> 0

--! 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4192?, 8384?, 16768?, 33536?, 67072?, 134144?, 268288?
--!                                            /\                   /\              /\               /\

local function init(std, game)

end

local function loop(std, game)

end

local function draw(std, game)

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
