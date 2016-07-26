-----------------------------------------------------------------------------------------
--
-- ピンボールゲームを作ってみよう
-- main.lua
--
-----------------------------------------------------------------------------------------



-- ############################## 変数とは？ ##############################

-- `width` は画面の横幅(1080)が入っている
width = display.contentWidth
-- `height` は画面の縦幅(1920)が入っている
height = display.contentHeight

-- 描画グループ
displayGroup = display.newGroup()

-- ############################## 変数とは？ ##############################



-- ############################## 物理演算とは？ ##############################

-- 物理演算をするための機能を読み込んで `physics` に入れておく
physics = require("physics")
-- 物理演算を起動する
physics.start(true)
physics.setGravity(0, 0)

-- ############################## 物理演算とは？ ##############################



-- ############################## 壁を作ろう ##############################

-- 壁の連想配列を作ろう
walls = {}
walls[1] = display.newLine(displayGroup, 0, 0, width, 0)
walls[1].tag = "topWall"

walls[2] = display.newLine(displayGroup, 0, 0, 0, height)
walls[2].tag = "leftWall"

walls[3] = display.newLine(displayGroup, width, 0, width, height)
walls[3].tag = "rightWall"

walls[4] = display.newLine(displayGroup, 0, height, width, height)
walls[4].tag = "bottomWall"

-- for i = 最初の値, 最後の値(含む), 幾つづつiをプラスするか do ~ end
-- `#` は要素数
for i = 1, #walls, 1 do
    walls[i].strokeWidth = 50
    physics.addBody(walls[i], "static", {density = 0.0, friction = 0.0, bounce = 1.0})
end

-- ############################## 壁を作ろう ##############################



-- ############################## ボールを動かそう ##############################

ball = display.newCircle(displayGroup, 0, 0, 25)
ball.tag = "ball"
physics.addBody(ball, "dynamic", {density = 0.0, friction = 0.0, bounce = 1.0})

function resetBallPos()
    ball.x = width/2
    ball.y = 1200
end

function gameStart()
    resetBallPos()
    ball:setLinearVelocity(0, 500)
end

gameStart()

-- ############################## ボールを動かそう ##############################



-- ############################## ブロックを配置してみよう ##############################

maxNumBlocks = 0
numBlocks = 0

blocks = {}

function deleteBlock(index)
    if (blocks[index] == nil) then
        return
    end

    blocks[index]:removeSelf()
    blocks[index] = nil
    numBlocks = numBlocks - 1
end

function deleteAllBlocks()
    for i = 0, maxNumBlocks, 1 do
        deleteBlock(i)
    end

    maxNumBlocks = 0
    numBlocks = 0
    blocks = {}
end

function deployBlocks()
    -- ブロックを配置する前に全てのブロックを削除
    deleteAllBlocks()

    -- ブロックを配置
    for y = 0, 1, 1 do
        for x = 0, 4, 1 do
            -- 何番目の要素か
            local index = x + (y * 5)
            blocks[index] = display.newImageRect(displayGroup, "block.jpg", width * 1/8, 100)
            blocks[index].x = (x + 1) * (width * 1/6)
            blocks[index].y = 400 + (200 * y)
            blocks[index].tag = "block"
            blocks[index].index = index
            physics.addBody(blocks[index], "static", {density = 0.0, friction = 0.0, bounce = 1.0})

            numBlocks = numBlocks + 1
        end
    end

    maxNumBlocks = numBlocks
end

deployBlocks()

-- ############################## ブロックを配置してみよう ##############################



-- ############################## ラケットを配置しよう ##############################

racket = display.newRect(displayGroup, width/2, 1700, 200, 20)
racket.tag = "racket"
racket:setFillColor(1.0, 1.0, 0.0)
physics.addBody(racket, "static", {density = 0.0, friction = 0.0, bounce = 1.0})

-- ############################## ラケットを配置しよう ##############################



-- ############################## ラケットを動かそう ##############################

function racketMove(event)
    racket.x = event.x
end

function displayTouchListener(event)
   racketMove(event) 
end

-- 画面全体のタッチイベントを設定
Runtime:addEventListener("touch", displayTouchListener)

-- ############################## ラケットを動かそう ##############################



-- ############################## ゲーム判定 ##############################

completeText = nil

function completeGame()
    physics.pause()
    completeText = display.newText(displayGroup, "Complete", width/2, height/2, native.systemFont, 100)
    completeText:setTextColor(1.0, 1.0, 1.0)
end

function failGame()
    physics.pause()
    completeText = display.newText(displayGroup, "Fail", width/2, height/2, native.systemFont, 100)
    completeText:setTextColor(1.0, 1.0, 1.0)
end

-- ############################## ゲーム判定 ##############################



-- ############################## ボールの角度と速度を安定させよう ##############################

function ballStabilization()
    local vx, vy = ball:getLinearVelocity()
        
    if (0 < vx) then
        vx = 500
    else
        vx = -500
    end

    if (0 < vy) then
        vy = 500
    else
        vy = -500
    end
    
    ball:setLinearVelocity(vx, vy)
end

function ballCollision(event)
    if (event.phase == "began") then
        print("collision: "..event.other.tag)
    elseif (event.phase == "ended") then
        ballStabilization()

        -- ブロックに当たった時はブロックを削除
        if (event.other.tag == "block") then
            local hitBlock = event.other
            deleteBlock(hitBlock.index)
            -- ブロックがなくなった場合はクリア判定
            if (numBlocks == 0) then
                completeGame()
            end
        elseif (event.other.tag == "bottomWall") then
            failGame()
        end
    end
end

-- 衝突イベントをボールに設定
ball:addEventListener("collision", ballCollision)

-- ############################## ボールの角度と速度を安定させよう ##############################