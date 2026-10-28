--[[
  HYBRID GOD'S GUARD FARM — ArMON HUB integration patch
  รวมแนวทางจาก main.luau.txt + ArMONHUB.lua:
  - เลือกเป้าหมายที่ยังมีชีวิตและอยู่ใกล้ที่สุด
  - ใช้ TweenController ของ ArMON HUB แทนการสร้าง Tween ซ้ำถี่ ๆ
  - ใช้ระบบ CombatController.Attack เดิม
  - ใช้ BringEnemy แบบ 3 ช่องคงที่ โดยเพิ่มพารามิเตอร์ชื่อมอน
  - ไม่ Destroy() โมเดลมอนเอง และไม่แตะระบบฟาร์มเลเวลส่วนอื่น

  วิธีใช้:
  1) แก้บรรทัดประกาศเดิม `BringEnemy = function()` เป็น `BringEnemy = function(requestedName)`
  2) ใน BringEnemy ให้แทนบรรทัดกำหนด targetName เดิมด้วย:
       local targetName = (requestedName and requestedName ~= "") and requestedName
           or ((Mon and Mon ~= "") and Mon or nil)
  3) แทนที่บล็อก `elseif h == 3 then ...` เดิม ด้วยบล็อกด้านล่าง
  หมายเหตุ: ไฟล์นี้เป็น PATCH สำหรับวางใน ArMONHUB.lua ไม่ใช่สคริปต์เต็มแบบ standalone
]]

-- === Replacement for the h == 3 branch inside LevelFarm:RegisterMethod("Start") ===
elseif h == 3 then
    local TARGET_NAME = "God's Guard"
    local SPAWN_FALLBACK = CFrame.new(-4650, 872, -1775)
    local ARRIVE_DISTANCE = 45
    local SEARCH_RADIUS = 350

    -- ตรวจตำแหน่งเฉพาะ Sea 1; ถ้า attribute ไม่พร้อมให้ไปจุด Skylands ก่อน
    if SeaIndex == 1 then
        local location = LocalPlayer:GetAttribute("CurrentLocation")
        if location ~= "Skylands" and location ~= "Upper Skylands" then
            TweenController.Create(SPAWN_FALLBACK)
            task.wait(1)
            return
        end
    end

    SetTask("MainTask", "Level Farm | God's Guard | Skylands")

    local character = LocalPlayer.Character
    local playerRoot = character and character:FindFirstChild("HumanoidRootPart")
    if not playerRoot then
        SetTask("SubTask", "Waiting for character...")
        return
    end

    -- God's Guard ที่อยู่ใน Workspace เท่านั้นคือตัวที่กำลังเกิด/ต่อสู้ได้จริง
    local enemyFolder = workspace:FindFirstChild("Enemies")
    local bestTarget, bestRoot, bestHumanoid
    local bestDistance = math.huge

    if enemyFolder then
        for _, mob in ipairs(enemyFolder:GetChildren()) do
            if mob:IsA("Model") and mob.Name == TARGET_NAME then
                local humanoid = mob:FindFirstChildOfClass("Humanoid")
                local root = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
                if humanoid and humanoid.Health > 0 and root and root:IsA("BasePart") then
                    local distance = (root.Position - playerRoot.Position).Magnitude
                    if distance <= SEARCH_RADIUS and distance < bestDistance then
                        bestTarget, bestRoot, bestHumanoid = mob, root, humanoid
                        bestDistance = distance
                    end
                end
            end
        end
    end

    if not bestTarget then
        SetTask("SubTask", "Searching God's Guard...")
        local spawnFolder = game:GetService("ReplicatedStorage"):FindFirstChild(
            "FortBuilderReplicatedSpawnPositionsFolder"
        )
        local spawnPoint = spawnFolder and spawnFolder:FindFirstChild(TARGET_NAME)
        if spawnPoint then
            local ok, pivot = pcall(function()
                return spawnPoint:GetPivot()
            end)
            if ok then
                TweenController.Create(pivot + Vector3.new(0, 22, 0))
            else
                TweenController.Create(SPAWN_FALLBACK)
            end
        else
            TweenController.Create(SPAWN_FALLBACK)
        end
        return
    end

    SetTask("SubTask", "Farming God's Guard | HP: " ..
        tostring(math.floor(bestHumanoid.Health)))

    -- ให้ระบบรวมมอนที่มีอยู่ดึงมอนชื่อเดียวกันเข้าช่องคงที่ 2–3 ตัว
    -- ต้องแก้ BringEnemy ตามคำแนะนำด้านบนให้รับ TARGET_NAME ได้
    if typeof(BringEnemy) == "function" then
        pcall(function()
            BringEnemy(TARGET_NAME)
        end)
    end

    -- ขยับเข้าหาเป้าหมายเฉพาะเมื่อยังอยู่ไกล ลดการสั่ง Tween ซ้ำโดยไม่จำเป็น
    if bestTarget.Parent and bestHumanoid.Health > 0 then
        local distanceNow = (bestRoot.Position - playerRoot.Position).Magnitude
        if distanceNow > ARRIVE_DISTANCE then
            local goal = bestRoot.CFrame * CFrame.new(0, 22, 4)
            pcall(function()
                TweenController.Create(goal)
            end)
        else
            -- ใช้ระบบโจมตี/เลือกอาวุธเดิมของ ArMON HUB
            pcall(function()
                CombatController.Attack(TARGET_NAME)
            end)
        end
    end
