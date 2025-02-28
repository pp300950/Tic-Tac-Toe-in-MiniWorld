-- กำหนดสัญลักษณ์ของผู้เล่น
local PLAYER, AI = "X", "O"

-- ฟังก์ชันแสดงตารางปัจจุบัน
function print_board(board)
    Chat:sendSystemMsg("กระดานปัจจุบัน")
    Chat:sendSystemMsg("#Bบอท O ,ผู้เล่น X")
    for i = 1, 9, 3 do
        Chat:sendSystemMsg(" " .. board[i+2] .. " | " .. board[i+1] .. " | " .. board[i])
        if i < 7 then Chat:sendSystemMsg("---+---+---") end
    end
    Chat:sendSystemMsg("")
end


-- ฟังก์ชันตรวจสอบว่ามีผู้ชนะหรือไม่
function check_winner(board)
    local win_patterns = {
        {1, 2, 3}, {4, 5, 6}, {7, 8, 9}, -- แถว
        {1, 4, 7}, {2, 5, 8}, {3, 6, 9}, -- คอลัมน์
        {1, 5, 9}, {3, 5, 7}-- เส้นทแยงมุม
    }

    for _, pattern in ipairs(win_patterns) do
        if board[pattern[1]] ~= " " and 
           board[pattern[1]] == board[pattern[2]] and 
           board[pattern[2]] == board[pattern[3]] then
            return board[pattern[1]] -- คืนค่าผู้ชนะ ("X" หรือ "O")
        end
    end

    return nil -- ไม่มีผู้ชนะ
end

-- ตรวจสอบว่าเต็มหรือไม่
function is_full(board)
    for i = 1, 9 do
        if board[i] == " " then
            return false
        end
    end
    return true
end

-- ฟังก์ชัน Minimax
function minimax(board, depth, is_maximizing)
    local winner = check_winner(board)
    if winner == AI then return 10 - depth end
    if winner == PLAYER then return depth - 10 end
    if is_full(board) then return 0 end

    if is_maximizing then
        local best_score = -math.huge
        for i = 1, 9 do
            if board[i] == " " then
                board[i] = AI
                local score = minimax(board, depth + 1, false)
                board[i] = " "
                best_score = math.max(best_score, score)
            end
        end
        return best_score
    else
        local best_score = math.huge
        for i = 1, 9 do
            if board[i] == " " then
                board[i] = PLAYER
                local score = minimax(board, depth + 1, true)
                board[i] = " "
                best_score = math.min(best_score, score)
            end
        end
        return best_score
    end
end

-- หา move ที่ดีที่สุด
function best_move(board)
    local best_score = -math.huge
    local move = nil

    for i = 1, 9 do
        if board[i] == " " then
            board[i] = AI
            local score = minimax(board, 0, false)
            board[i] = " "
            if score > best_score then
                best_score = score
                move = i
            end
        end
    end
    return move
end

-- ฟังก์ชันดึงค่าตำแหน่งจาก"AIIposi"
function get_positions()
    local result, value = VarLib2:getGlobalVarByName(4, "Aposi")
    if not result or not value then
        print("❌ ไม่สามารถดึงค่าตำแหน่งจากเกมได้")
        return nil
    end

    local board = {" ", " ", " ", " ", " ", " ", " ", " ", " "} -- กระดานเริ่มต้น
    local positions = {}

    for pos in string.gmatch(value, "[^|]+") do
        local x, y, z, entity = pos:match("([^,]+),([^,]+),([^,]+),([^,]+)")
        x, y, z = tonumber(x), tonumber(y), tonumber(z)
        
        if x and z then
            local index = (z * 3) + x + 1  -- แปลงตำแหน่ง X,Z เป็นช่อง 1-9
            if entity == "player" then
                board[index] = PLAYER
            elseif entity == "bot" then
                board[index] = AI
            end
        end
    end

    return board
end

-- ดึงค่าตำแหน่งกระดาน
local board = get_positions()
if board then
    print("กระดานก่อนที่ AI จะเล่น:")
    print_board(board)

    -- AI คำนวณตำแหน่งที่ดีที่สุด
    local move = best_move(board)
    if move then
        board[move] = AI  --เล่นที่ตำแหน่งที่ดีที่สุด
        print("AI เลือกช่องที่: " .. move)
        print_board(board)

        -- แปลงตำแหน่ง 1-9 เป็นพิกัด X, Z
        local x = (move - 1) % 3
        local z = math.floor((move - 1) / 3)

        -- อัปเดตค่าตำแหน่งที่ AI เดินลงไป
        VarLib2:setGlobalVarByName(4, "Group2", x .. "," .. 6 .. "," .. z)

        print("🤖 AI วางบล็อกที่:", x, 7, z)
          if check_winner(board) == AI then
    
            Chat:sendSystemMsg("#Gบอทชนะ!!!")
            return
        end
    else

        Chat:sendSystemMsg("#Yเกมส์จมเเล้วไม่มีช่องให้ลง โปรดรีเกม")
    end
end
