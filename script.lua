local rs = game:GetService("ReplicatedStorage")
local plr = game:GetService("Players").LocalPlayer
local run = game:GetService("RunService")
local ws = workspace
local chr = ws:WaitForChild("Characters")
local cam = ws.CurrentCamera

local rmt, cwp, lst, lck = nil, nil, 0, false

for _,v in next, getgc(true) do
    if type(v)=="table" and rawget(v,"ShootWeapon") then rmt=v break end
end

local function gtm()
    for _,f in next, chr:GetChildren() do
        if f:IsA("Folder") and f:FindFirstChild(plr.Name) then return f.Name end
    end
end

local function gnr(mp)
    local mt = gtm()
    if not mt then return end
    local nr, nd = nil, math.huge
    for _,f in next, chr:GetChildren() do
        if f:IsA("Folder") and f.Name~=mt then
            for _,e in next, f:GetChildren() do
                local eh = e:FindFirstChild("HumanoidRootPart")
                local hm = e:FindFirstChildOfClass("Humanoid")
                local hd = e:FindFirstChild("Head")
                if eh and hm and hm.Health>0 then
                    local tp = hd and hd.Position or eh.Position
                    local d = (tp-mp).Magnitude
                    if d<nd then nd,nr = d,{p=tp,h=hd or eh} end
                end
            end
        end
    end
    return nr
end

local function igw(wp)
    if not wp then return false end
    local pr = rawget(wp,"Properties")
    if not pr then return false end
    return rawget(pr,"FireRate") and rawget(pr,"BulletsPerShot") and rawget(pr,"Rounds")
end

local function uwp()
    for _,v in next, getgc(true) do
        if type(v)=="table" then
            local ok,r = pcall(rawget,v,"IsEquipped")
            if ok and r and rawget(v,"Identifier") and rawget(v,"Player")==plr then
                if igw(v) then
                    cwp = v
                    return true
                end
            end
        end
    end
    cwp = nil
    return false
end

local function rld()
    if not cwp or lck then return end
    local pr = rawget(cwp,"Properties")
    if not pr then return end
    local mx = rawget(pr,"Rounds")
    local cr = rawget(cwp,"Rounds")
    local cp = rawget(cwp,"Capacity")
    if not (mx and cr and cp) then return end
    if cr<mx and cp>0 then
        lck = true
        local nd = math.min(mx-cr,cp)
        cwp.Rounds = cr+nd
        cwp.Capacity = cp-nd
        task.wait(0.05)
        lck = false
    end
end

run.Heartbeat:Connect(function()
    if tick()-lst < 0.1 then return end
    local mc = plr.Character
    if not mc or mc:GetAttribute("Dead") then return end
    local hrp = mc:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if not cwp or not rawget(cwp,"IsEquipped") then 
        if not uwp() then return end
    end
    
    if not igw(cwp) then 
        cwp = nil
        return 
    end
    
    local pr = rawget(cwp,"Properties")
    if not pr then return end
    local mx = rawget(pr,"Rounds")
    local cr = rawget(cwp,"Rounds")
    
    if cr and mx and cr<mx*0.3 then
        rld()
    end
    
    if not cr or cr<=0 then 
        rld()
        return 
    end
    
    if not rmt or not rmt.ShootWeapon then return end
    
    local tg = gnr(hrp.Position)
    if not tg then return end
    
    lst = tick()
    local og = cam.CFrame.Position
    local dr = (tg.p-og).Unit
    
    cwp.Rounds = cr-1
    rmt.ShootWeapon.Send({
        IsSniperScoped = false,
        ShootingHand = "Right",
        Identifier = cwp.Identifier,
        Capacity = cwp.Capacity,
        Rounds = cwp.Rounds,
        Bullets = {{
            Direction = dr,
            Origin = og,
            Hits = {{
                Instance = tg.h,
                Position = tg.p,
                Normal = -dr,
                Material = "Plastic",
                Distance = (tg.p-og).Magnitude,
                Exit = false
            }}
        }}
    })
end)

task.spawn(function()
    while task.wait(0.12) do
        if cwp and igw(cwp) then
            local cr = rawget(cwp,"Rounds")
            local pr = rawget(cwp,"Properties")
            if pr and cr then
                local mx = rawget(pr,"Rounds")
                if mx and cr<mx then rld() end
            end
        end
    end
end)
