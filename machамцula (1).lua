-- Machula (custom UI)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local E = Enum
local LP = Players.LocalPlayer
local OWNERS = {3064558341, 1992293734}
if not (table.find(OWNERS, LP.UserId) or (game.CreatorType == E.CreatorType.User and LP.UserId == game.CreatorId)) then
warn("[Machula] not an owner")
return
end
local S = {
Enabled = false,
TeamCheck = false,
ShowNames = false,
FillColor = Color3.fromRGB(255, 60, 60),
OutlineColor = Color3.fromRGB(255, 255, 255),
FillTransparency = 0.5,
OutlineTransparency = 0,
MaxDistance = 1000,
NameSize = 11,
DeathCheck = true,
}
local K = {}
local function isTeammate(player)
if player == LP then return false end
local myTeam, theirTeam = LP.Team, player.Team
if myTeam ~= nil and theirTeam ~= nil then
return myTeam == theirTeam
end
if not LP.Neutral and not player.Neutral then
return LP.TeamColor == player.TeamColor
end
return false
end
local function isAlive(character, check)
local hum = character and character:FindFirstChildOfClass("Humanoid")
if not hum then return false end
if not check then return true end
if hum.Health <= 0 then return false end
local fx = character:FindFirstChild("BodyEffects")
if fx then
local ko, dead = fx:FindFirstChild("K.O"), fx:FindFirstChild("Dead")
if (ko and ko.Value == true) or (dead and dead.Value == true) then return false end
end
if character:GetAttribute("KO") == true or character:GetAttribute("Knocked") == true or character:GetAttribute("Dead") == true then return false end
return true
end
local container = Instance.new("Folder")
container.Name = "MachulaHighlights"
container.Parent = workspace
local tracked = {}
local function removeFor(player)
local data = tracked[player]
if not data then return end
if data.Highlight then data.Highlight:Destroy() end
if data.Tag then data.Tag:Destroy() end
tracked[player] = nil
end
local function createFor(player)
removeFor(player)
if player == LP or not S.Enabled then return end
if S.TeamCheck and isTeammate(player) then return end
local character = player.Character
if not character then return end
local data = {}
local highlight = Instance.new("Highlight")
highlight.Name = player.Name
highlight.Adornee = character
highlight.FillColor = S.FillColor
highlight.OutlineColor = S.OutlineColor
highlight.FillTransparency = S.FillTransparency
highlight.OutlineTransparency = S.OutlineTransparency
highlight.DepthMode = E.HighlightDepthMode.AlwaysOnTop
highlight.Parent = container
data.Highlight = highlight
if S.ShowNames then
local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
if root then
local tag = Instance.new("BillboardGui")
tag.Name = player.Name .. "_Tag"
tag.Adornee = root
tag.Size = UDim2.fromOffset(100, 16)
tag.StudsOffset = Vector3.new(0, 3, 0)
tag.AlwaysOnTop = true
tag.MaxDistance = S.MaxDistance
tag.Parent = container
local label = Instance.new("TextLabel")
label.Size = UDim2.fromScale(1, 1)
label.BackgroundTransparency = 1
label.Text = player.DisplayName
label.TextColor3 = S.OutlineColor
label.TextStrokeTransparency = 0.3
label.Font = E.Font.GothamMedium
label.TextScaled = false
label.TextSize = S.NameSize
label.Parent = tag
data.Tag = tag
end
end
tracked[player] = data
end
local function refreshAll()
for _, player in ipairs(Players:GetPlayers()) do
createFor(player)
end
end
local function clearAll()
for player in pairs(tracked) do
removeFor(player)
end
end
K[#K + 1] = RunService.Heartbeat:Connect(function()
if not S.Enabled then return end
local myChar = LP.Character
local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
if not myRoot then return end
for player, data in pairs(tracked) do
local char = player.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
if root and data.Highlight then
local visible = (root.Position - myRoot.Position).Magnitude <= S.MaxDistance and isAlive(char, S.DeathCheck)
data.Highlight.Enabled = visible
if data.Tag then data.Tag.Enabled = visible end
end
end
end)
local function hookPlayer(player)
K[#K + 1] = player.CharacterAdded:Connect(function()
task.wait(0.2)
createFor(player)
end)
K[#K + 1] = player.CharacterRemoving:Connect(function()
removeFor(player)
end)
K[#K + 1] = player:GetPropertyChangedSignal("Team"):Connect(function()
createFor(player)
end)
if player.Character then
createFor(player)
end
end
for _, player in ipairs(Players:GetPlayers()) do
hookPlayer(player)
end
K[#K + 1] = Players.PlayerAdded:Connect(hookPlayer)
K[#K + 1] = Players.PlayerRemoving:Connect(removeFor)
K[#K + 1] = LP:GetPropertyChangedSignal("Team"):Connect(function()
if S.Enabled then refreshAll() end
end)
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local aim = {
Enabled = false,
Smoothness = 50,
HitPart = "Head",
AimMode = "Hold Bind",
Bind = E.UserInputType.MouseButton2,
Active = false,
Binding = false,
Sticky = false,
Locked = nil,
TeamCheck = false,
DeathCheck = false,
OffsetX = 0,
OffsetY = 0,
AutoUnlock = false,
TargetPlayer = nil,
PauseUntil = 0,
WallCheck = false,
FOV = 200,
UseFOV = false,
SmoothCurve = 1,
ShowFOV = false,
PredictX = 0,
PredictY = 0,
EaseStyle = "None",
EaseDir = "In",
FallOffset = false,
FallOffsetY = 0,
FallThreshold = 10,
Filter = 50,
ResX = 0,
ResY = 0,
ResZ = 0,
}
local fovGui = Instance.new("ScreenGui")
fovGui.Name = "MachulaFOV"
fovGui.IgnoreGuiInset = true
fovGui.ResetOnSpawn = false
fovGui.Parent = LP:WaitForChild("PlayerGui")
local fovCircle = Instance.new("Frame")
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
fovCircle.Parent = fovGui
local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovCircle
local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Color3.fromRGB(220, 30, 40)
fovStroke.Thickness = 1
fovStroke.Parent = fovCircle
local rayParams = RaycastParams.new()
rayParams.FilterType = E.RaycastFilterType.Exclude
local function aimOrigin()
local cam = workspace.CurrentCamera
local base = cam and (cam.ViewportSize / 2) or UIS:GetMouseLocation()
return Vector2.new(base.X + aim.OffsetX, base.Y + aim.OffsetY)
end
-- No Spread state: declared early so every raycall in this script can mark
-- itself and bypass the no-spread __namecall hook installed further down
local noSpreadOn = false
local noSpreadBusy = false
local function isVisible(part, camera)
rayParams.FilterDescendantsInstances = { LP.Character }
local origin = camera.CFrame.Position
noSpreadBusy = true
local result = workspace:Raycast(origin, part.Position - origin, rayParams)
noSpreadBusy = false
return result == nil or result.Instance:IsDescendantOf(part.Parent)
end
local function getBodyPart(character, choice, center, camera)
if choice == "Torso" then
return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
elseif choice == "Closest Part" then
local best, bestDist
for _, part in ipairs(character:GetChildren()) do
if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Transparency < 1 then
local pos, onScreen = camera:WorldToViewportPoint(part.Position)
if onScreen then
local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
if not bestDist or d < bestDist then
best, bestDist = part, d
end
end
end
end
return best
end
return character:FindFirstChild(choice)
end
local function getTarget(camera)
local center = aimOrigin()
local bestPart, bestPlayer, bestDist = nil, nil, aim.UseFOV and aim.FOV or math.huge
for _, player in ipairs(Players:GetPlayers()) do
local character = player.Character
if player ~= LP and character then
local sameTeam = aim.TeamCheck and isTeammate(player)
local humanoid = character:FindFirstChildOfClass("Humanoid")
if not sameTeam and humanoid and isAlive(character, aim.DeathCheck) then
local part = getBodyPart(character, aim.HitPart, center, camera)
if part then
local pos, onScreen = camera:WorldToViewportPoint(part.Position)
if onScreen then
local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
if dist < bestDist and (not aim.WallCheck or isVisible(part, camera)) then
bestPart, bestPlayer, bestDist = part, player, dist
end
end
end
end
end
end
return bestPart, bestPlayer
end
-- re-executing the script must not die on a duplicate binding name
pcall(function() RunService:UnbindFromRenderStep("MachulaAim") end)
RunService:BindToRenderStep("MachulaAim", E.RenderPriority.Camera.Value + 1, function(dt)
local camera = workspace.CurrentCamera
fovCircle.Visible = aim.Enabled and aim.ShowFOV
if fovCircle.Visible and camera then
local center = aimOrigin()
fovCircle.Size = UDim2.fromOffset(aim.FOV * 2, aim.FOV * 2)
fovCircle.Position = UDim2.fromOffset(center.X, center.Y)
end
if not aim.Enabled or not camera then
aim.Locked = nil
aim.FilterTarget = nil
aim.TargetPlayer = nil
return
end
if not isAlive(LP.Character, aim.DeathCheck) then
aim.Locked = nil
aim.FilterTarget = nil
aim.TargetPlayer = nil
return
end
if aim.AimMode ~= "Always On" and not aim.Active then
aim.Locked = nil
aim.FilterTarget = nil
aim.TargetPlayer = nil
return
end
if aim.AutoUnlock and aim.TargetPlayer and not isAlive(aim.TargetPlayer.Character, true) then
aim.TargetPlayer = nil
aim.Locked = nil
aim.FilterTarget = nil
if aim.AimMode == "Always On" then
aim.PauseUntil = os.clock() + 1
else
aim.Active = false
end
return
end
if os.clock() < aim.PauseUntil then return end
local target
if aim.Sticky and aim.Locked then
local lockedPlayer = aim.Locked
local character = lockedPlayer.Character
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
if lockedPlayer.Parent == Players
and isAlive(character, aim.DeathCheck)
and not (aim.TeamCheck and isTeammate(lockedPlayer)) then
target = getBodyPart(character, aim.HitPart, aimOrigin(), camera)
if target then aim.TargetPlayer = lockedPlayer end
end
if not target then
aim.Locked = nil
end
end
if not target then
local part, player = getTarget(camera)
target = part
aim.TargetPlayer = player
if aim.Sticky then
aim.Locked = player
end
end
if not target then return end
if aim.Sticky and aim.WallCheck and not isVisible(target, camera) then
return
end
local t = 1 - (math.clamp(aim.Smoothness, 0, 100) / 100) ^ aim.SmoothCurve
if aim.EaseStyle ~= "None" then
t = math.clamp(TweenService:GetValue(t, E.EasingStyle[aim.EaseStyle], E.EasingDirection[aim.EaseDir]), 0, 1)
end
local rawVel = target.AssemblyLinearVelocity
local newTarget = aim.FilterTarget ~= target
local fa = 1 - math.exp(-math.min(dt, 0.1) * (80 * (1 - aim.Filter / 100) + 4))
if newTarget then
aim.FilterTarget = target
aim.FilterVel = rawVel
end
aim.FilterVel = aim.FilterVel:Lerp(rawVel, fa)
local vel = aim.FilterVel
local aimPos = target.Position + Vector3.new(vel.X * aim.PredictX, vel.Y * aim.PredictY, vel.Z * aim.PredictX)
if aim.FallOffset and vel.Y < -aim.FallThreshold then
aimPos = aimPos + Vector3.new(0, aim.FallOffsetY, 0)
end
if newTarget then aim.FilterPos = aimPos end
aim.FilterPos = aim.FilterPos:Lerp(aimPos, fa)
local camPos = camera.CFrame.Position
local o = aimOrigin()
local ray = camera:ViewportPointToRay(o.X, o.Y)
local dist = (aim.FilterPos - camPos).Magnitude
local cur = camPos + ray.Direction.Unit * dist
local d = aim.FilterPos - cur
local pulled = cur + Vector3.new(d.X * (1 - aim.ResX / 100), d.Y * (1 - aim.ResY / 100), d.Z * (1 - aim.ResZ / 100))
local fromDir = (cur - camPos).Unit
local toDir = (pulled - camPos).Unit
local axis = fromDir:Cross(toDir)
local goal = camera.CFrame
if axis.Magnitude > 1e-6 then
local ang = math.acos(math.clamp(fromDir:Dot(toDir), -1, 1))
goal = CFrame.new(camPos) * CFrame.fromAxisAngle(axis.Unit, ang) * camera.CFrame.Rotation
end
local speed = 3 * 100 ^ t
local alpha = 1 - math.exp(-speed * math.min(dt, 0.1))
camera.CFrame = camera.CFrame:Lerp(goal, math.clamp(alpha, 0, 1))
end)
K[#K + 1] = {Disconnect = function() RunService:UnbindFromRenderStep("MachulaAim") end}
local function matchesBind(input)
if aim.Bind.EnumType == E.KeyCode then
return input.KeyCode == aim.Bind
end
return input.UserInputType == aim.Bind
end
K[#K + 1] = UIS.InputBegan:Connect(function(input, gameProcessed)
if aim.Binding or not aim.Enabled or not matchesBind(input) then return end
if gameProcessed and aim.Bind.EnumType == E.KeyCode then return end
if aim.AimMode == "Hold Bind" then
aim.Active = true
elseif aim.AimMode == "Toggle Bind" then
aim.Active = not aim.Active
end
end)
K[#K + 1] = UIS.InputEnded:Connect(function(input)
if aim.AimMode == "Hold Bind" and matchesBind(input) then
aim.Active = false
end
end)
-- ESP: boxes + traces (drawn with GUI frames)
S.Boxes = false
S.Traces = false
S.BoxColor = Color3.fromRGB(255, 255, 255)
S.TraceColor = Color3.fromRGB(255, 60, 60)
S.TraceOrigin = "Bottom"
local espGui = Instance.new("ScreenGui")
espGui.Name = "MachulaESP"
espGui.IgnoreGuiInset = true
espGui.ResetOnSpawn = false
espGui.DisplayOrder = 50
espGui.Parent = LP:WaitForChild("PlayerGui")
local espObjs = {}
local function getEsp(player)
local o = espObjs[player]
if o then return o end
local box = Instance.new("Frame")
box.BackgroundTransparency = 1
box.BorderSizePixel = 0
box.Visible = false
box.Parent = espGui
local stroke = Instance.new("UIStroke")
stroke.Thickness = 1
stroke.Color = S.BoxColor
stroke.LineJoinMode = E.LineJoinMode.Miter
stroke.Parent = box
local line = Instance.new("Frame")
line.AnchorPoint = Vector2.new(0.5, 0.5)
line.BorderSizePixel = 0
line.BackgroundColor3 = S.TraceColor
line.Visible = false
line.Parent = espGui
o = {Box = box, Stroke = stroke, Line = line}
espObjs[player] = o
return o
end
local function hideEsp(o)
o.Box.Visible = false
o.Line.Visible = false
end
local function removeEsp(player)
local o = espObjs[player]
if o then
o.Box:Destroy()
o.Line:Destroy()
espObjs[player] = nil
end
end
K[#K + 1] = Players.PlayerRemoving:Connect(removeEsp)
K[#K + 1] = RunService.RenderStepped:Connect(function()
local camera = workspace.CurrentCamera
if not camera or not (S.Boxes or S.Traces) then
for _, o in pairs(espObjs) do hideEsp(o) end
return
end
local viewport = camera.ViewportSize
local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
for _, player in ipairs(Players:GetPlayers()) do
if player ~= LP then
local character = player.Character
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
local root = character and character:FindFirstChild("HumanoidRootPart")
local o = getEsp(player)
local show = root ~= nil and isAlive(character, S.DeathCheck)
if show and S.TeamCheck and isTeammate(player) then show = false end
if show and myRoot and (root.Position - myRoot.Position).Magnitude > S.MaxDistance then show = false end
if not show then
hideEsp(o)
else
if S.Boxes then
local cf, size = character:GetBoundingBox()
local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
local inFront = true
for x = -1, 1, 2 do
for y = -1, 1, 2 do
for z = -1, 1, 2 do
local p = camera:WorldToViewportPoint(cf:PointToWorldSpace(size / 2 * Vector3.new(x, y, z)))
if p.Z <= 0 then inFront = false end
minX, minY = math.min(minX, p.X), math.min(minY, p.Y)
maxX, maxY = math.max(maxX, p.X), math.max(maxY, p.Y)
end
end
end
o.Box.Visible = inFront
if inFront then
o.Stroke.Color = S.BoxColor
o.Box.Position = UDim2.fromOffset(minX, minY)
o.Box.Size = UDim2.fromOffset(maxX - minX, maxY - minY)
end
else
o.Box.Visible = false
end
if S.Traces then
local p = camera:WorldToViewportPoint(root.Position)
if p.Z > 0 then
local from
if S.TraceOrigin == "Center" then
from = Vector2.new(viewport.X / 2, viewport.Y / 2)
elseif S.TraceOrigin == "Mouse" then
from = UIS:GetMouseLocation()
else
from = Vector2.new(viewport.X / 2, viewport.Y)
end
local to = Vector2.new(p.X, p.Y)
local d = to - from
o.Line.BackgroundColor3 = S.TraceColor
o.Line.Size = UDim2.fromOffset(d.Magnitude, 1)
o.Line.Position = UDim2.fromOffset((from.X + to.X) / 2, (from.Y + to.Y) / 2)
o.Line.Rotation = math.deg(math.atan2(d.Y, d.X))
o.Line.Visible = true
else
o.Line.Visible = false
end
else
o.Line.Visible = false
end
end
end
end
end)
-- MAP: material changer + world visuals
local Lighting = game:GetService("Lighting")
local M = {ChangeMaterial = false, Material = "None", Fullbright = false, NoFog = false}
local origLight = {
Brightness = Lighting.Brightness,
ClockTime = Lighting.ClockTime,
Ambient = Lighting.Ambient,
OutdoorAmbient = Lighting.OutdoorAmbient,
FogEnd = Lighting.FogEnd,
FogStart = Lighting.FogStart,
}
local function restoreLight(keys)
for _, k in ipairs(keys) do Lighting[k] = origLight[k] end
end
local matNames = {"None", "CrackedLava", "Neon", "Glass", "ForceField", "Ice", "Glacier", "Slate", "Marble", "Granite", "Basalt", "Brick", "WoodPlanks", "DiamondPlate", "Metal", "Foil", "Grass", "Sand", "Snow", "Concrete", "SmoothPlastic"}
local origMat = setmetatable({}, {__mode = "k"})
local function isCharacterPart(part)
local m = part:FindFirstAncestorOfClass("Model")
while m do
if m:FindFirstChildOfClass("Humanoid") then return true end
m = m.Parent and m.Parent:FindFirstAncestorOfClass("Model")
end
return false
end
local function applyMat(part)
if M.Material == "None" then return end
if not part:IsA("BasePart") or part == workspace.Terrain or isCharacterPart(part) then return end
if origMat[part] == nil then origMat[part] = part.Material end
part.Material = E.Material[M.Material]
end
local function restoreMat()
for part, mat in pairs(origMat) do
if part.Parent then part.Material = mat end
origMat[part] = nil
end
end
local function applyAllMat()
if M.Material == "None" then
restoreMat()
return
end
task.spawn(function()
local n = 0
for _, d in ipairs(workspace:GetDescendants()) do
if not M.ChangeMaterial then return end
applyMat(d)
n = n + 1
if n % 400 == 0 then task.wait() end
end
end)
end
K[#K + 1] = workspace.DescendantAdded:Connect(function(d)
if M.ChangeMaterial then applyMat(d) end
end)
K[#K + 1] = RunService.Heartbeat:Connect(function()
if M.Fullbright then
Lighting.Brightness = 2
Lighting.ClockTime = 14
Lighting.Ambient = Color3.fromRGB(255, 255, 255)
Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
end
if M.NoFog then
Lighting.FogStart = 1e6
Lighting.FogEnd = 1e6
end
end)
-- PLAYER: walk speed + fly
local walk = {Name = "Walk", Enabled = false, Mode = "Always On", Bind = E.KeyCode.LeftShift, Value = 32, Active = false, Binding = false, Method = "Auto"}
local fly = {Name = "Fly", Enabled = false, Mode = "Toggle Bind", Bind = E.KeyCode.F, Value = 60, Active = false, Binding = false}
local jump = {Name = "Jump", Enabled = false, Mode = "Always On", Bind = E.KeyCode.X, Value = 100, Active = false, Binding = false, Method = "Auto"}
local bhop = {Name = "Bhop", Enabled = false, Mode = "Always On", Bind = E.KeyCode.V, Value = 0, Force = 55, Active = false, Binding = false}
local moves = {walk, fly, jump, bhop}
local function bindMatches(st, input)
if st.Bind.EnumType == E.KeyCode then
return input.KeyCode == st.Bind
end
return input.UserInputType == st.Bind
end
K[#K + 1] = UIS.InputBegan:Connect(function(input, gp)
for _, st in ipairs(moves) do
if st.Binding then
local ut = input.UserInputType
local nb
if ut == E.UserInputType.Keyboard then
if input.KeyCode == E.KeyCode.Escape then
st.Binding = false
st.Label:Set(st.Name .. " Bind: " .. st.Bind.Name)
return
end
nb = input.KeyCode
elseif ut == E.UserInputType.MouseButton1 or ut == E.UserInputType.MouseButton2 or ut == E.UserInputType.MouseButton3 then
nb = ut
end
if nb then
st.Bind = nb
st.Binding = false
st.Active = false
st.Label:Set(st.Name .. " Bind: " .. nb.Name)
end
return
end
end
for _, st in ipairs(moves) do
	if st.Enabled and st.Mode ~= "Always On" and bindMatches(st, input) and not (gp and st.Bind.EnumType == E.KeyCode) then
if st.Mode == "Hold Bind" then
st.Active = true
else
st.Active = not st.Active
end
end
end
end)
K[#K + 1] = UIS.InputEnded:Connect(function(input)
for _, st in ipairs(moves) do
if st.Mode == "Hold Bind" and bindMatches(st, input) then
st.Active = false
end
end
end)
local function restoreWalk()
if walk.Applied then
if walk.Applied.Parent then walk.Applied.WalkSpeed = walk.Orig end
walk.Applied = nil
end
end
local function restoreJump()
if jump.Applied then
if jump.Applied.Parent then
if jump.OrigMode then jump.Applied.JumpPower = jump.Orig else jump.Applied.JumpHeight = jump.Orig end
end
jump.Applied = nil
end
end
local function stopFly()
if fly.BV then fly.BV:Destroy() fly.BV = nil end
if fly.BG then fly.BG:Destroy() fly.BG = nil end
if fly.Hum and fly.Hum.Parent then fly.Hum.PlatformStand = false end
fly.Hum = nil
end
-- Speed/jump/bhop tick: enforced at THREE points of the frame so no game
-- script can win the race: RenderPriority.Last (after every RenderStepped
-- write, e.g. Counter Blox / BloxStrike anticheat resets), Stepped (right
-- before physics) and Heartbeat (after physics).
local function stOn(st) return st.Active or st.Mode == "Always On" end
local function speedTick()
	local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
	local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	-- WALK: property write + auto velocity-force bypass when the game overwrites it
	if hum and walk.Enabled and stOn(walk) then
		if walk.Applied ~= hum then
			restoreWalk()
			walk.Orig = hum.WalkSpeed
			walk.Applied = hum
			walk.Wrote = false
			walk.Overwritten = false
		end
		if walk.Wrote and hum.WalkSpeed ~= walk.Value then
			walk.Overwritten = true
		end
		hum.WalkSpeed = walk.Value
		walk.Wrote = true
		local needVel = walk.Method == "Velocity Force" or (walk.Method == "Auto" and walk.Overwritten)
		if needVel and root then
			if not walk.BV or walk.BV.Parent ~= root then
				if walk.BV then walk.BV:Destroy() end
				walk.BV = Instance.new("BodyVelocity")
				walk.BV.MaxForce = Vector3.new(1e9, 0, 1e9)
				walk.BV.P = 1e4
				walk.BV.Parent = root
			end
			local md = hum.MoveDirection
			walk.BV.Velocity = Vector3.new(md.X * walk.Value, 0, md.Z * walk.Value)
		elseif walk.BV then
			walk.BV:Destroy()
			walk.BV = nil
		end
	else
		restoreWalk()
		if walk.BV then
			walk.BV:Destroy()
			walk.BV = nil
		end
		walk.Overwritten = false
	end
	if hum and jump.Enabled and stOn(jump) then
		if jump.Applied ~= hum then
			restoreJump()
			jump.OrigMode = hum.UseJumpPower
			jump.Orig = hum.UseJumpPower and hum.JumpPower or hum.JumpHeight
			jump.Applied = hum
			jump.Wrote = false
			jump.Overwritten = false
			jump.Airborne = false
		end
		if hum.UseJumpPower then
			if jump.Wrote and hum.JumpPower ~= jump.Value then jump.Overwritten = true end
			hum.JumpPower = jump.Value
		else
			local want = jump.Value ^ 2 / (2 * workspace.Gravity)
			if jump.Wrote and math.abs(hum.JumpHeight - want) > 0.01 then jump.Overwritten = true end
			hum.JumpHeight = want
		end
		jump.Wrote = true
		local wantImpulse = jump.Method == "Impulse" or (jump.Method == "Auto" and jump.Overwritten)
		jump.Impulse = wantImpulse
		local grounded = hum.FloorMaterial ~= E.Material.Air
		if wantImpulse and root and grounded and not jump.Airborne then
			local v = root.AssemblyLinearVelocity
			if v.Y > 2 then
				root.AssemblyLinearVelocity = Vector3.new(v.X, math.max(jump.Value, v.Y), v.Z)
			end
		end
		jump.Airborne = not grounded
	else
		restoreJump()
		jump.Impulse = false
		jump.Overwritten = false
	end
	-- bunny hop: hop the instant we touch the ground while moving
	if hum and bhop.Enabled and stOn(bhop) and hum.Health > 0 then
		local grounded = hum.FloorMaterial ~= E.Material.Air
		if grounded and hum.MoveDirection.Magnitude > 0.05 then
			hum.Jump = true
			pcall(function() hum:ChangeState(E.HumanoidStateType.Jumping) end)
			if root then
				local v = root.AssemblyLinearVelocity
				root.AssemblyLinearVelocity = Vector3.new(v.X, math.max(bhop.Force, v.Y), v.Z)
			end
		end
	end
end
pcall(function() RunService:UnbindFromRenderStep("MachulaSpeed") end)
RunService:BindToRenderStep("MachulaSpeed", E.RenderPriority.Last.Value, speedTick)
K[#K + 1] = {Disconnect = function() RunService:UnbindFromRenderStep("MachulaSpeed") end}
K[#K + 1] = RunService.Stepped:Connect(speedTick)
K[#K + 1] = RunService.Heartbeat:Connect(speedTick)
K[#K + 1] = RunService.RenderStepped:Connect(function()
local camera = workspace.CurrentCamera
local char = LP.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
local hum = char and char:FindFirstChildOfClass("Humanoid")
if fly.Enabled and fly.Active and camera and root and hum and hum.Health > 0 then
if not fly.BV or fly.BV.Parent ~= root then
stopFly()
fly.BV = Instance.new("BodyVelocity")
fly.BV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
fly.BV.Velocity = Vector3.zero
fly.BV.Parent = root
fly.BG = Instance.new("BodyGyro")
fly.BG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
fly.BG.P = 9e4
fly.BG.Parent = root
fly.Hum = hum
end
hum.PlatformStand = true
local cf = camera.CFrame
local dir = Vector3.zero
if not UIS:GetFocusedTextBox() then
if UIS:IsKeyDown(E.KeyCode.W) then dir = dir + cf.LookVector end
if UIS:IsKeyDown(E.KeyCode.S) then dir = dir - cf.LookVector end
if UIS:IsKeyDown(E.KeyCode.D) then dir = dir + cf.RightVector end
if UIS:IsKeyDown(E.KeyCode.A) then dir = dir - cf.RightVector end
if UIS:IsKeyDown(E.KeyCode.Space) then dir = dir + Vector3.yAxis end
if UIS:IsKeyDown(E.KeyCode.LeftControl) then dir = dir - Vector3.yAxis end
end
fly.BV.Velocity = dir.Magnitude > 0 and dir.Unit * fly.Value or Vector3.zero
fly.BG.CFrame = cf
elseif fly.BV then
stopFly()
end
end)
local U, UO, US, RGB = UDim2.new, UDim2.fromOffset, UDim2.fromScale, Color3.fromRGB
local RED, BG, PNL, DIM, GRY, WHT = RGB(230, 30, 50), RGB(9, 8, 10), RGB(17, 14, 17), RGB(58, 14, 20), RGB(150, 132, 138), RGB(255, 255, 255)
local L, R = E.TextXAlignment.Left, E.TextXAlignment.Right
local MB1, TCH = E.UserInputType.MouseButton1, E.UserInputType.Touch
local CFG = {ctl = {}}
function CFG.reg(box, name, get, set)
	CFG.ctl[#CFG.ctl + 1] = {id = box.Name .. "/" .. name, get = get, set = set}
end
local ord = 0
local drag, ds, sp

-- ===== UI helpers / effects =====
local FX = {
	OFF = RGB(26, 20, 23),
	HOV = RGB(38, 17, 22),
	LINE = RGB(40, 34, 40),
	SOFT = RGB(172, 172, 178),
	NAV = RGB(21, 16, 19),
	HI = RGB(255, 60, 80),
}
function FX.tw(o, t, p, st)
	TweenService:Create(o, TweenInfo.new(t, st or E.EasingStyle.Quad, E.EasingDirection.Out), p):Play()
end
function FX.closeCur()
	if FX.cur then FX.cur.close() end
end
function FX.hover(b, prop, on, off)
	b.MouseEnter:Connect(function() FX.tw(b, 0.12, {[prop] = on}) end)
	b.MouseLeave:Connect(function() FX.tw(b, 0.12, {[prop] = off}) end)
end

local function new(c, p, par)
	local i = Instance.new(c)
	if i:IsA("GuiObject") then
		i.BorderSizePixel = 0
		i.BackgroundTransparency = p.BackgroundColor3 and 0 or 1
		ord = ord + 1
		i.LayoutOrder = ord
	end
	if c == "TextLabel" or c == "TextButton" then
		i.Font = E.Font.Arcade
		i.TextSize = 14
		if c == "TextButton" then i.AutoButtonColor = false end
	end
	for k, v in pairs(p) do i[k] = v end
	i.Parent = par
	return i
end
local function round(i, r) new("UICorner", {CornerRadius = UDim.new(0, r)}, i) end
local function list(par, pad, ha)
	return new("UIListLayout", {Padding = UDim.new(0, pad), SortOrder = E.SortOrder.LayoutOrder, HorizontalAlignment = ha or E.HorizontalAlignment.Left}, par)
end
local function text(par, t, col, al, size, pos)
	return new("TextLabel", {Text = t, TextColor3 = col, TextXAlignment = al or L, Size = size or US(1, 1), Position = pos or U()}, par)
end
local function clk(i) return i.UserInputType == MB1 or i.UserInputType == TCH end

-- ===== window =====
local gui = new("ScreenGui", {Name = "MachulaUI", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 100}, LP:WaitForChild("PlayerGui"))
local win = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = US(0.5, 0.5), Size = UO(760, 480), BackgroundColor3 = RGB(12, 10, 13)}, gui)
round(win, 10)
local title, side, body
do
	-- animated gradient border
	-- pop-in animation whenever the menu opens
	local scale = new("UIScale", {Scale = 0.9}, win)
	FX.tw(scale, 0.3, {Scale = 1}, E.EasingStyle.Back)
	win:GetPropertyChangedSignal("Visible"):Connect(function()
		if not win.Visible then FX.closeCur() end
		if win.Visible then
			scale.Scale = 0.92
			FX.tw(scale, 0.25, {Scale = 1}, E.EasingStyle.Back)
		end
	end)

	-- drag handle (covers the brand area)
	title = new("Frame", {Active = true, Size = U(1, 0, 0, 74)}, win)
	FX.catcher = new("TextButton", {Text = "", Size = US(1, 1), ZIndex = 49, Visible = false}, win)
	FX.catcher.MouseButton1Click:Connect(function() FX.closeCur() end)

	-- sidebar
	local sb = new("Frame", {Position = UO(10, 10), Size = U(0, 172, 1, -20), BackgroundColor3 = PNL}, win)
	round(sb, 8)
	new("UIStroke", {Color = RGB(52, 15, 21), Thickness = 1}, sb)
	local brand = text(sb, "machula", RED, nil, U(1, -28, 0, 30), UO(16, 12))
	brand.Font = E.Font.Arcade
	brand.TextSize = 28
	text(sb, "roblox script", GRY, nil, U(1, -28, 0, 14), UO(16, 43)).TextSize = 11

	-- shimmering divider
	local shim = new("Frame", {Position = UO(14, 80), Size = U(1, -28, 0, 2), BackgroundColor3 = RGB(60, 12, 18), ClipsDescendants = true}, sb)
	round(shim, 1)
	local shimBit = new("Frame", {Size = U(0.3, 0, 1, 0), BackgroundColor3 = RGB(255, 60, 80)}, shim)
	round(shimBit, 1)

	side = new("Frame", {Position = UO(10, 94), Size = U(1, -20, 1, -140)}, sb)
	list(side, 6)
	text(sb, "menu key: see SET tab", GRY, E.TextXAlignment.Center, U(1, -20, 0, 16), U(0, 10, 1, -28)).TextSize = 10

	body = new("Frame", {Position = UO(194, 14), Size = U(1, -206, 1, -28), ClipsDescendants = true}, win)

	-- per-frame animation (rotating border + moving shimmer)
	K[#K + 1] = RunService.RenderStepped:Connect(function()
		if not win.Visible then return end
		local t = os.clock()
		shimBit.Position = US((math.sin(t * 1.6) + 1) / 2 * 0.7, 0)
	end)
end

-- ===== tabs =====
local tabs = {}
local function pick(t)
	FX.closeCur()
	for _, o in ipairs(tabs) do
		local on = o == t
		o.on = on
		o.page.Visible = on
		FX.tw(o.btn, 0.2, {BackgroundColor3 = on and RED or FX.NAV, TextColor3 = on and WHT or GRY})
	end
	t.page.Position = UO(0, 12)
	FX.tw(t.page, 0.25, {Position = UO(0, 0)})
end
local function addTab(name)
	local t = {col = {}, name = name}
	t.btn = new("TextButton", {Text = name, Font = E.Font.Arcade, TextSize = 14, TextColor3 = GRY, Size = U(1, 0, 0, 34), BackgroundColor3 = FX.NAV}, side)
	round(t.btn, 7)
	t.btn.MouseEnter:Connect(function()
		if not t.on then FX.tw(t.btn, 0.12, {BackgroundColor3 = FX.HOV, TextColor3 = WHT}) end
	end)
	t.btn.MouseLeave:Connect(function()
		if not t.on then FX.tw(t.btn, 0.12, {BackgroundColor3 = FX.NAV, TextColor3 = GRY}) end
	end)
	t.page = new("ScrollingFrame", {Size = US(1, 1), ScrollBarThickness = 3, ScrollBarImageColor3 = RED, AutomaticCanvasSize = E.AutomaticSize.Y, CanvasSize = U(), Visible = false}, body)
	for i = 1, 2 do
		t.col[i] = new("Frame", {Size = U(0.5, -6, 0, 0), Position = U((i - 1) * 0.5, (i - 1) * 6, 0, 0), AutomaticSize = E.AutomaticSize.Y}, t.page)
		list(t.col[i], 10)
	end
	function t:section(col, name)
		local w = new("Frame", {Size = U(1, 0, 0, 0), AutomaticSize = E.AutomaticSize.Y}, t.col[col])
		list(w, 6)
		-- header styled like the reference dropdown box (dark, bordered, red text, v arrow)
		local hd = new("TextButton", {Text = "", Size = U(1, 0, 0, 30), BackgroundColor3 = BG}, w)
		round(hd, 6)
		new("UIStroke", {Color = FX.LINE, Thickness = 1, ApplyStrokeMode = E.ApplyStrokeMode.Border}, hd)
		local hl = text(hd, name, RED, nil, U(1, -40, 1, 0), UO(12, 0))
		local arrow = text(hd, "^", GRY, E.TextXAlignment.Center, U(0, 18, 1, 0), U(1, -26, 0, 0))
		FX.hover(hd, "BackgroundColor3", FX.HOV, BG)
		local box = new("Frame", {Name = t.name .. "." .. name, Size = U(1, 0, 0, 0), AutomaticSize = E.AutomaticSize.Y, BackgroundColor3 = PNL}, w)
		box.BackgroundTransparency = 0.25
		box.Visible = true
		hd.MouseButton1Click:Connect(function()
			box.Visible = not box.Visible
			arrow.Text = box.Visible and "^" or "v"
			FX.tw(hl, 0.15, {TextColor3 = RED})
		end)
		round(box, 7)
		new("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 9)}, box)
		list(box, 6)
		return box
	end
	t.btn.MouseButton1Click:Connect(function() pick(t) end)
	tabs[#tabs + 1] = t
	if #tabs == 1 then pick(t) end
	return t
end

-- ===== controls =====
local function tg(box, name, def, cb)
	local b = new("TextButton", {Size = U(1, 0, 0, 24), Text = ""}, box)
	local sq = new("Frame", {Position = U(0, 0, 0.5, -9), Size = UO(18, 18), BackgroundColor3 = FX.OFF}, b)
	round(sq, 4)
	local ring = new("UIStroke", {Color = FX.LINE, Thickness = 1}, sq)
	local dot = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = US(0.5, 0.5), Size = UO(0, 0), BackgroundColor3 = RED}, sq)
	round(dot, 3)
	local lab = text(b, name, FX.SOFT, nil, U(1, -26, 1, 0), UO(26, 0))
	local on
	local o = {}
	function o:Set(v)
		on = v
		FX.tw(dot, 0.18, {Size = v and UO(10, 10) or UO(0, 0)}, v and E.EasingStyle.Back or E.EasingStyle.Quad)
		FX.tw(ring, 0.18, {Color = v and RED or FX.LINE})
		FX.tw(lab, 0.18, {TextColor3 = v and WHT or FX.SOFT})
	end
	o:Set(def)
	b.MouseEnter:Connect(function() if not on then FX.tw(ring, 0.12, {Color = FX.HI}) end end)
	b.MouseLeave:Connect(function() if not on then FX.tw(ring, 0.12, {Color = FX.LINE}) end end)
	b.MouseButton1Click:Connect(function()
		o:Set(not on)
		cb(on)
	end)
	CFG.reg(box, name, function() return on end, function(x) o:Set(x == true) cb(on) end)
end
local function dl(box, name, opts, def, cb)
	local row = new("Frame", {Size = U(1, 0, 0, 32)}, box)
	text(row, name, FX.SOFT, nil, U(0.45, 0, 1, 0))
	local b = new("TextButton", {Text = "", AnchorPoint = Vector2.new(1, 0.5), Position = US(1, 0.5), Size = U(0.55, 0, 0, 28), BackgroundColor3 = BG}, row)
	round(b, 6)
	new("UIStroke", {Color = FX.LINE, Thickness = 1, ApplyStrokeMode = E.ApplyStrokeMode.Border}, b)
	FX.hover(b, "BackgroundColor3", FX.HOV, BG)
	local v = text(b, "", RED, nil, U(1, -34, 1, 0), UO(12, 0))
	local arrow = text(b, "v", GRY, E.TextXAlignment.Center, U(0, 18, 1, 0), U(1, -26, 0, 0))
	local cur = table.find(opts, def) and def or opts[1]
	local h = math.min(#opts * 24 + 8, 150)
	-- floating list: parented to the window (not the layout) so it opens OVER the menu
	local lst = new("ScrollingFrame", {Size = UO(120, h), BackgroundColor3 = BG, ScrollBarThickness = 3, ScrollBarImageColor3 = RED, AutomaticCanvasSize = E.AutomaticSize.Y, CanvasSize = U(), Visible = false, ZIndex = 50}, win)
	round(lst, 6)
	new("UIStroke", {Color = RED, Thickness = 1, ApplyStrokeMode = E.ApplyStrokeMode.Border}, lst)
	new("UIPadding", {PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 3), PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 3)}, lst)
	list(lst, 2)
	local items = {}
	local function refresh()
		v.Text = cur
		arrow.Text = lst.Visible and "^" or "v"
		for n, it in pairs(items) do
			it.TextColor3 = n == cur and RED or FX.SOFT
		end
	end
	local function closeMe()
		lst.Visible = false
		refresh()
		if FX.cur and FX.cur.lst == lst then
			FX.cur = nil
			FX.catcher.Visible = false
		end
	end
	for _, n in ipairs(opts) do
		local it = new("TextButton", {Text = n, TextColor3 = FX.SOFT, Size = U(1, -6, 0, 22), BackgroundColor3 = PNL, ZIndex = 51}, lst)
		round(it, 4)
		FX.hover(it, "BackgroundColor3", FX.HOV, PNL)
		items[n] = it
		it.MouseButton1Click:Connect(function()
			cur = n
			closeMe()
			cb(n)
		end)
	end
	b.MouseButton1Click:Connect(function()
		if lst.Visible then closeMe() return end
		FX.closeCur()
		local k = win.AbsoluteSize.X / 760
		local x = (b.AbsolutePosition.X - win.AbsolutePosition.X) / k
		local y = (b.AbsolutePosition.Y - win.AbsolutePosition.Y + b.AbsoluteSize.Y) / k + 3
		if y + h > 472 then
			y = (b.AbsolutePosition.Y - win.AbsolutePosition.Y) / k - h - 3
		end
		lst.Position = UO(x, y)
		lst.Size = UO(b.AbsoluteSize.X / k, h)
		lst.Visible = true
		refresh()
		FX.cur = {lst = lst, btn = b, close = closeMe}
		FX.catcher.Visible = true
	end)
	refresh()
	CFG.reg(box, name, function() return cur end, function(x)
		if items[x] then
			cur = x
			closeMe()
			cb(x)
		end
	end)
end
local function dd(box, name, opts, def, cb)
	return dl(box, name, opts, def, cb)
end
local function ml(box, name, items, cfgName)
	local row = new("Frame", {Size = U(1, 0, 0, 32)}, box)
	text(row, name, FX.SOFT, nil, U(0.45, 0, 1, 0))
	local b = new("TextButton", {Text = "", AnchorPoint = Vector2.new(1, 0.5), Position = US(1, 0.5), Size = U(0.55, 0, 0, 28), BackgroundColor3 = BG}, row)
	round(b, 6)
	new("UIStroke", {Color = FX.LINE, Thickness = 1, ApplyStrokeMode = E.ApplyStrokeMode.Border}, b)
	FX.hover(b, "BackgroundColor3", FX.HOV, BG)
	local v = text(b, "", RED, nil, U(1, -34, 1, 0), UO(12, 0))
	local arrow = text(b, "v", GRY, E.TextXAlignment.Center, U(0, 18, 1, 0), U(1, -26, 0, 0))
	local h = #items * 28 + 8
	-- floating checklist (opens over the menu, stays open while you tick things)
	local lst = new("Frame", {Size = UO(190, h), BackgroundColor3 = BG, Visible = false, ZIndex = 50}, win)
	round(lst, 6)
	new("UIStroke", {Color = RED, Thickness = 1, ApplyStrokeMode = E.ApplyStrokeMode.Border}, lst)
	new("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4)}, lst)
	list(lst, 2)
	local states = {}
	local function refresh()
		local n = 0
		for _, s in ipairs(states) do
			if s.on then n = n + 1 end
		end
		v.Text = n .. " / " .. #items .. " on"
		arrow.Text = lst.Visible and "^" or "v"
	end
	local function closeMe()
		lst.Visible = false
		refresh()
		if FX.cur and FX.cur.lst == lst then
			FX.cur = nil
			FX.catcher.Visible = false
		end
	end
	for _, it in ipairs(items) do
		local r = new("TextButton", {Text = "", Size = U(1, 0, 0, 26), BackgroundColor3 = PNL, ZIndex = 51}, lst)
		round(r, 4)
		FX.hover(r, "BackgroundColor3", FX.HOV, PNL)
		local sq = new("Frame", {Position = U(0, 6, 0.5, -8), Size = UO(16, 16), BackgroundColor3 = FX.OFF, ZIndex = 52}, r)
		round(sq, 4)
		local ring = new("UIStroke", {Color = FX.LINE, Thickness = 1}, sq)
		local dot = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = US(0.5, 0.5), Size = UO(0, 0), BackgroundColor3 = RED, ZIndex = 53}, sq)
		round(dot, 3)
		local lab = text(r, it.label, FX.SOFT, nil, U(1, -30, 1, 0), UO(30, 0))
		lab.ZIndex = 52
		local st = {on = false}
		states[#states + 1] = st
		local function set(val)
			st.on = val == true
			FX.tw(dot, 0.18, {Size = st.on and UO(10, 10) or UO(0, 0)}, st.on and E.EasingStyle.Back or E.EasingStyle.Quad)
			FX.tw(ring, 0.18, {Color = st.on and RED or FX.LINE})
			FX.tw(lab, 0.18, {TextColor3 = st.on and WHT or FX.SOFT})
			refresh()
		end
		set(it.def)
		r.MouseButton1Click:Connect(function()
			set(not st.on)
			it.cb(st.on)
		end)
		-- same config ids as before, so saved configs keep working
		CFG.reg({Name = cfgName or box.Name}, it.label, function() return st.on end, function(x)
			set(x == true)
			it.cb(st.on)
		end)
	end
	b.MouseButton1Click:Connect(function()
		if lst.Visible then closeMe() return end
		FX.closeCur()
		local k = win.AbsoluteSize.X / 760
		local x = (b.AbsolutePosition.X - win.AbsolutePosition.X) / k
		local y = (b.AbsolutePosition.Y - win.AbsolutePosition.Y + b.AbsoluteSize.Y) / k + 3
		if y + h > 472 then
			y = (b.AbsolutePosition.Y - win.AbsolutePosition.Y) / k - h - 3
		end
		lst.Position = UO(x, y)
		lst.Size = UO(math.max(b.AbsoluteSize.X / k, 190), h)
		lst.Visible = true
		refresh()
		FX.cur = {lst = lst, btn = b, close = closeMe}
		FX.catcher.Visible = true
	end)
	refresh()
end
local function bt(box, name, cb)
	local b = new("TextButton", {Text = name, TextColor3 = RGB(255, 110, 122), Size = U(1, 0, 0, 28), BackgroundColor3 = RGB(38, 13, 18)}, box)
	round(b, 5)
	new("UIStroke", {Color = RGB(86, 22, 31), Thickness = 1, ApplyStrokeMode = E.ApplyStrokeMode.Border}, b)
	b.MouseEnter:Connect(function() FX.tw(b, 0.12, {BackgroundColor3 = RED, TextColor3 = WHT}) end)
	b.MouseLeave:Connect(function() FX.tw(b, 0.12, {BackgroundColor3 = RGB(38, 13, 18), TextColor3 = RGB(255, 110, 122)}) end)
	local o = {}
	function o:Set(t) b.Text = t end
	b.MouseButton1Click:Connect(cb)
	return o
end
local function sl(box, name, min, max, def, step, cb)
	local row = new("Frame", {Size = U(1, 0, 0, 42)}, box)
	text(row, name, FX.SOFT, nil, U(1, 0, 0, 16))
	local bar = new("Frame", {Position = UO(0, 19), Size = U(1, 0, 0, 22), BackgroundColor3 = FX.OFF, ClipsDescendants = true}, row)
	round(bar, 6)
	local fill = new("Frame", {Size = US(0, 1), BackgroundColor3 = RGB(205, 28, 48)}, bar)
	round(fill, 6)
	local knob = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = US(1, 0.5), Size = UO(6, 22), BackgroundColor3 = RGB(255, 120, 135)}, fill)
	round(knob, 3)
	local val = text(bar, "", WHT, E.TextXAlignment.Center, US(1, 1))
	val.TextSize = 12
	local cur = def
	local fmt = step < 1 and "%.2f" or "%.0f"
	local function set(v)
		fill.Size = US((v - min) / (max - min), 1)
		val.Text = string.format(fmt, v)
		cur = v
	end
	local function upd(x)
		local v = min + math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1) * (max - min)
		v = math.clamp(math.floor((v - min) / step + 0.5) * step + min, min, max)
		set(v)
		cb(v)
	end
	set(def)
	local hit = new("TextButton", {Text = "", Position = UO(0, 19), Size = U(1, 0, 0, 22)}, row)
	hit.MouseEnter:Connect(function() FX.tw(bar, 0.12, {BackgroundColor3 = FX.HOV}) end)
	hit.MouseLeave:Connect(function() FX.tw(bar, 0.12, {BackgroundColor3 = FX.OFF}) end)
	hit.InputBegan:Connect(function(i)
		if clk(i) then
			drag = upd
			upd(i.Position.X)
		end
	end)
	CFG.reg(box, name, function() return cur end, function(x)
		x = math.clamp(tonumber(x) or def, min, max)
		set(x)
		cb(x)
	end)
end
K[#K + 1] = UIS.InputChanged:Connect(function(i)
if i.UserInputType == E.UserInputType.MouseMovement or i.UserInputType == TCH then
if drag then
drag(i.Position.X)
elseif ds then
local d = i.Position - ds
win.Position = U(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
end
end
end)
K[#K + 1] = UIS.InputEnded:Connect(function(i)
if clk(i) then drag, ds = nil, nil end
end)
title.InputBegan:Connect(function(i)
if clk(i) then ds, sp = i.Position, win.Position end
end)
local menuKey, menuBinding, MB = E.KeyCode.RightControl, false
K[#K + 1] = UIS.InputBegan:Connect(function(i, gp)
if menuBinding then
if i.UserInputType == E.UserInputType.Keyboard then
menuBinding = false
if i.KeyCode ~= E.KeyCode.Escape then menuKey = i.KeyCode end
MB:Set("Menu Bind: " .. menuKey.Name)
end
elseif not gp and not aim.Binding and i.KeyCode == menuKey then
win.Visible = not win.Visible
end
end)
local colors = {Red = RGB(255, 60, 60), Green = RGB(60, 255, 90), Blue = RGB(60, 120, 255), Yellow = RGB(255, 220, 50), Purple = RGB(170, 70, 255), White = WHT}
local cn = {"Red", "Green", "Blue", "Yellow", "Purple", "White"}
local A = addTab("AIM")
local m = A:section(1, "MAIN")
tg(m, "Aimbot", false, function(v) aim.Enabled = v end)
dd(m, "Aim Mode", {"Hold Bind", "Toggle Bind", "Always On"}, "Hold Bind", function(v)
aim.AimMode = v
aim.Active = false
end)
local BB
BB = bt(m, "Aim Bind: " .. aim.Bind.Name, function()
aim.Binding = true
aim.Active = false
BB:Set("press a key... (Esc = cancel)")
end)
dd(m, "Hit Part", {"Head", "Torso", "HumanoidRootPart", "Closest Part"}, "Head", function(v) aim.HitPart = v end)
ml(m, "Target Checks", {
{label = "Sticky Aim (lock on)", def = false, cb = function(v)
aim.Sticky = v
aim.Locked = nil
end},
{label = "Team Check", def = aim.TeamCheck, cb = function(v) aim.TeamCheck = v end},
{label = "Wall Check", def = false, cb = function(v) aim.WallCheck = v end},
{label = "Auto Unlock On Death", def = aim.AutoUnlock, cb = function(v)
aim.AutoUnlock = v
aim.TargetPlayer = nil
end},
{label = "Death Check", def = aim.DeathCheck, cb = function(v)
aim.DeathCheck = v
aim.Locked = nil
end},
}, "AIM.TARGET CHECKS")
sl(m, "Smoothness", 0, 100, aim.Smoothness, 0.5, function(v) aim.Smoothness = v end)
sl(m, "Smooth Curve", 0.3, 3, aim.SmoothCurve, 0.1, function(v) aim.SmoothCurve = v end)
sl(m, "Jitter Filter", 0, 100, aim.Filter, 1, function(v) aim.Filter = v end)
local pr = A:section(1, "PREDICTION")
sl(pr, "Prediction X", 0, 1, aim.PredictX, 0.01, function(v) aim.PredictX = v end)
sl(pr, "Prediction Y", 0, 1, aim.PredictY, 0.01, function(v) aim.PredictY = v end)
local fo = A:section(1, "FALL OFFSETS")
tg(fo, "Fall Offset", false, function(v) aim.FallOffset = v end)
sl(fo, "Offset Y", -10, 10, aim.FallOffsetY, 0.1, function(v) aim.FallOffsetY = v end)
sl(fo, "Fall Speed Threshold", 1, 100, aim.FallThreshold, 1, function(v) aim.FallThreshold = v end)
local rs = A:section(1, "PULL RESISTANCE")
sl(rs, "Resistance X", 0, 100, aim.ResX, 1, function(v) aim.ResX = v end)
sl(rs, "Resistance Y", 0, 100, aim.ResY, 1, function(v) aim.ResY = v end)
sl(rs, "Resistance Z", 0, 100, aim.ResZ, 1, function(v) aim.ResZ = v end)
local fv = A:section(2, "FOV")
tg(fv, "Use FOV", aim.UseFOV, function(v) aim.UseFOV = v end)
sl(fv, "FOV Radius", 50, 800, aim.FOV, 10, function(v) aim.FOV = v end)
tg(fv, "Show FOV Circle", aim.ShowFOV, function(v) aim.ShowFOV = v end)
local ao = A:section(2, "AIM OFFSET")
sl(ao, "Offset X (px)", -200, 200, aim.OffsetX, 1, function(v) aim.OffsetX = v end)
sl(ao, "Offset Y (px)", -200, 200, aim.OffsetY, 1, function(v) aim.OffsetY = v end)
local es = A:section(2, "EASING")
dl(es, "Easing Style", {"None", "Linear", "Sine", "Quad", "Cubic", "Quart", "Quint", "Exponential", "Circular", "Back", "Bounce", "Elastic"}, aim.EaseStyle, function(v) aim.EaseStyle = v end)
dl(es, "Direction", {"In", "Out", "InOut"}, aim.EaseDir, function(v) aim.EaseDir = v end)
K[#K + 1] = UIS.InputBegan:Connect(function(i)
if not aim.Binding then return end
local nb
local ut = i.UserInputType
if ut == E.UserInputType.Keyboard then
if i.KeyCode == E.KeyCode.Escape then
aim.Binding = false
BB:Set("Aim Bind: " .. aim.Bind.Name)
return
end
nb = i.KeyCode
elseif ut == MB1 or ut == E.UserInputType.MouseButton2 or ut == E.UserInputType.MouseButton3 then
nb = ut
end
if nb then
aim.Bind = nb
aim.Binding = false
aim.Active = false
BB:Set("Aim Bind: " .. nb.Name)
end
end)
local ES = addTab("ESP")
local em = ES:section(1, "MAIN")
tg(em, "ESP", false, function(v)
S.Enabled = v
if v then refreshAll() else clearAll() end
end)
ml(em, "ESP Options", {
{label = "Team Check", def = false, cb = function(v)
S.TeamCheck = v
if S.Enabled then refreshAll() end
end},
{label = "Show Names", def = false, cb = function(v)
S.ShowNames = v
if S.Enabled then refreshAll() end
end},
{label = "Boxes", def = false, cb = function(v) S.Boxes = v end},
{label = "Traces", def = false, cb = function(v) S.Traces = v end},
}, "ESP.MAIN")
dd(em, "Trace Origin", {"Bottom", "Center", "Mouse"}, "Bottom", function(v) S.TraceOrigin = v end)
sl(ES:section(1, "RANGE"), "Max Distance", 50, 5000, S.MaxDistance, 50, function(v)
S.MaxDistance = v
for _, d in pairs(tracked) do
if d.Tag then d.Tag.MaxDistance = v end
end
end)
local ea = ES:section(2, "APPEARANCE")
sl(ea, "Name Size", 8, 24, S.NameSize, 1, function(v)
S.NameSize = v
for _, d in pairs(tracked) do
local l = d.Tag and d.Tag:FindFirstChildOfClass("TextLabel")
if l then l.TextSize = v end
end
end)
dd(ea, "Fill Color", cn, "Red", function(n)
S.FillColor = colors[n]
for _, d in pairs(tracked) do d.Highlight.FillColor = colors[n] end
end)
dd(ea, "Outline Color", cn, "White", function(n)
S.OutlineColor = colors[n]
for _, d in pairs(tracked) do
d.Highlight.OutlineColor = colors[n]
local l = d.Tag and d.Tag:FindFirstChildOfClass("TextLabel")
if l then l.TextColor3 = colors[n] end
end
end)
dd(ea, "Box Color", cn, "White", function(n) S.BoxColor = colors[n] end)
dd(ea, "Trace Color", cn, "Red", function(n) S.TraceColor = colors[n] end)
sl(ea, "Fill Transparency", 0, 1, S.FillTransparency, 0.05, function(v)
S.FillTransparency = v
for _, d in pairs(tracked) do d.Highlight.FillTransparency = v end
end)
sl(ea, "Outline Transparency", 0, 1, S.OutlineTransparency, 0.05, function(v)
S.OutlineTransparency = v
for _, d in pairs(tracked) do d.Highlight.OutlineTransparency = v end
end)
local MP = addTab("MAP")
local mm = MP:section(1, "MATERIAL")
tg(mm, "Change Material", false, function(v)
M.ChangeMaterial = v
if v then applyAllMat() else restoreMat() end
end)
dl(mm, "Material", matNames, M.Material, function(n)
M.Material = n
if M.ChangeMaterial then applyAllMat() end
end)
local mw = MP:section(2, "WORLD")
tg(mw, "Fullbright", false, function(v)
M.Fullbright = v
if not v then restoreLight({"Brightness", "ClockTime", "Ambient", "OutdoorAmbient"}) end
end)
tg(mw, "No Fog", false, function(v)
M.NoFog = v
if not v then restoreLight({"FogStart", "FogEnd"}) end
end)
do
	-- map-wide weather: a big grid of particle emitters that follows the camera + atmosphere haze
	local W = {on = false, kind = "Rain", amountMul = 1, speedMul = 1, bolt = 0, parts = {}, ems = {}}
	local C3 = Color3.fromRGB
	local GRID, STEP, HEIGHT = 2, 120, 60
	local COUNT = (GRID * 2 + 1) ^ 2
	local origExp = Lighting.ExposureCompensation
	-- rate = total particles/second across the whole grid
	local presets = {
		["Rain"] = {rate = 9000, speed = 90, size = 0.55, color = C3(190, 210, 240), transp = 0.3, glow = 0.5, spread = 3, streak = true,
			atmo = {0.18, 0, C3(170, 180, 195), C3(110, 115, 125), 1}},
		["Heavy Rain"] = {rate = 20000, speed = 105, size = 0.6, color = C3(165, 185, 215), transp = 0.25, glow = 0.3, spread = 4, streak = true,
			exp = -0.25, atmo = {0.3, 0.1, C3(150, 155, 165), C3(90, 95, 105), 1.5}},
		["Snow"] = {rate = 3000, speed = 9, size = 0.7, color = C3(255, 255, 255), transp = 0.1, glow = 0.3, spread = 35, tex = "rbxasset://textures/particles/smoke_main.dds",
			atmo = {0.15, 0, C3(220, 225, 235), C3(170, 175, 185), 1}},
		["Ash"] = {rate = 2500, speed = 7, size = 0.6, color = C3(255, 80, 50), transp = 0.2, glow = 0.9, spread = 40, tex = "rbxasset://textures/particles/smoke_main.dds",
			atmo = {0.2, 0, C3(120, 60, 55), C3(80, 40, 40), 1.5}},
		["Fog"] = {atmo = {0.45, 0.2, C3(190, 190, 200), C3(110, 110, 120), 2}},
		["Storm"] = {rate = 24000, speed = 115, size = 0.6, color = C3(150, 165, 195), transp = 0.25, glow = 0.3, spread = 6, streak = true,
			exp = -0.45, atmo = {0.4, 0.1, C3(90, 95, 110), C3(50, 55, 65), 2}},
	}
	local function useAtmo(a)
		local at = Lighting:FindFirstChildOfClass("Atmosphere")
		if at then
			W.existing = at
			W.saved = {Density = at.Density, Offset = at.Offset, Color = at.Color, Decay = at.Decay, Haze = at.Haze}
		else
			at = Instance.new("Atmosphere")
			at.Parent = Lighting
			W.atmo = at
		end
		at.Density, at.Offset, at.Color, at.Decay, at.Haze = a[1], a[2], a[3], a[4], a[5]
	end
	local function clear()
		for _, d in ipairs(W.parts) do d.part:Destroy() end
		W.parts, W.ems = {}, {}
		if W.atmo then W.atmo:Destroy() W.atmo = nil end
		if W.existing and W.saved then
			for k, v in pairs(W.saved) do pcall(function() W.existing[k] = v end) end
		end
		W.existing, W.saved = nil, nil
		Lighting.ExposureCompensation = origExp
	end
	-- live-update amount/speed without rebuilding
	local function tune()
		local p = presets[W.kind]
		if not p or not p.rate then return end
		local spd = p.speed * W.speedMul
		local life = math.clamp((HEIGHT + 4) / spd, 0.3, 14)
		for _, e in ipairs(W.ems) do
			e.Rate = p.rate * W.amountMul / COUNT
			e.Speed = NumberRange.new(spd)
			e.Lifetime = NumberRange.new(life)
		end
	end
	local function build()
		clear()
		if not W.on then return end
		local p = presets[W.kind]
		if not p then return end
		if p.atmo then useAtmo(p.atmo) end
		if p.exp then Lighting.ExposureCompensation = origExp + p.exp end
		if p.rate then
			for gx = -GRID, GRID do
				for gz = -GRID, GRID do
					local part = Instance.new("Part")
					part.Name = "MachulaWeather"
					part.Anchored = true
					part.CanCollide = false
					part.CanQuery = false
					part.CanTouch = false
					part.Transparency = 1
					part.Size = Vector3.new(STEP, 1, STEP)
					part.Parent = workspace
					local e = Instance.new("ParticleEmitter")
					e.Size = NumberSequence.new(p.size)
					e.Color = ColorSequence.new(p.color)
					e.Transparency = NumberSequence.new(p.transp)
					e.LightEmission = p.glow or 0
					e.EmissionDirection = Enum.NormalId.Bottom
					e.SpreadAngle = Vector2.new(p.spread, p.spread)
					e.LockedToPart = false
					e.Acceleration = Vector3.zero
					if p.tex then e.Texture = p.tex end
					if p.streak then
						e.Orientation = Enum.ParticleOrientation.VelocityParallel
						e.Squash = NumberSequence.new(-1.5)
					end
					e.Parent = part
					W.parts[#W.parts + 1] = {part = part, ox = gx * STEP, oz = gz * STEP}
					W.ems[#W.ems + 1] = e
				end
			end
			tune()
		end
		W.bolt = os.clock() + 2
	end
	K[#K + 1] = RunService.RenderStepped:Connect(function()
		if not W.on then return end
		local c = workspace.CurrentCamera
		if c then
			local pos = c.CFrame.Position
			for _, d in ipairs(W.parts) do
				d.part.CFrame = CFrame.new(pos.X + d.ox, pos.Y + HEIGHT, pos.Z + d.oz)
			end
		end
		if W.kind == "Storm" and os.clock() >= W.bolt then
			W.bolt = os.clock() + 5 + math.random() * 7
			Lighting.ExposureCompensation = origExp + 1.4
			TweenService:Create(Lighting, TweenInfo.new(0.5), {ExposureCompensation = origExp + presets.Storm.exp}):Play()
		end
	end)
	K[#K + 1] = {Disconnect = clear}
	tg(mw, "Weather", false, function(v)
		W.on = v
		build()
	end)
	dl(mw, "Weather Type", {"Rain", "Heavy Rain", "Snow", "Fog", "Storm", "Ash"}, "Rain", function(n)
		W.kind = n
		build()
	end)
	sl(mw, "Weather Amount (%)", 10, 500, 100, 5, function(v)
		W.amountMul = v / 100
		tune()
	end)
	sl(mw, "Weather Speed (%)", 30, 300, 100, 5, function(v)
		W.speedMul = v / 100
		tune()
	end)
end
do
	local mw = MP:section(1, "SKYBOX")
	-- skybox changer (client-side): real 6-face Sky images + matching time of day
	local SB = {on = false, kind = "Morning", hidden = {}}
	-- ids order: bk, dn, ft, lf, rt, up
	local presets = {
		["Morning"] = {clock = 8, stars = 0, ids = {"6444884337", "6444884785", "6444884337", "6444884337", "6444884337", "6412503613"}},
		["Evening"] = {clock = 18, stars = 0, ids = {"16136021536", "16136025360", "16136021536", "16136021536", "16136021536", "16136023362"}},
		["Night"] = {clock = 0, stars = 3000, ids = {"15536110634", "15536112543", "15536116141", "15536114370", "15536118762", "15536117282"}},
		["Classic"] = {clock = 14, stars = 0, ids = {"225469345", "225469349", "225469359", "225469364", "225469372", "225469380"}},
		["Space"] = {clock = 0, stars = 9000},
		["Custom"] = {stars = 0},
	}
	local function restore()
		if SB.sky then SB.sky:Destroy() SB.sky = nil end
		for _, s in ipairs(SB.hidden) do s.Parent = Lighting end
		SB.hidden = {}
		if SB.origClock then
			Lighting.ClockTime = SB.origClock
			SB.origClock = nil
		end
	end
	local function build()
		restore()
		if not SB.on then return end
		local p = presets[SB.kind]
		if not p then return end
		local ids = p.ids
		if SB.kind == "Custom" then
			ids = SB.custom
			if not ids then return end
		end
		SB.origClock = Lighting.ClockTime
		for _, o in ipairs(Lighting:GetChildren()) do
			if o:IsA("Sky") then
				SB.hidden[#SB.hidden + 1] = o
				o.Parent = nil
			end
		end
		local sky = Instance.new("Sky")
		sky.Name = "MachulaSky"
		sky.StarCount = p.stars
		if ids then
			local function tex(i) return "rbxassetid://" .. ids[i] end
			sky.SkyboxBk, sky.SkyboxDn, sky.SkyboxFt = tex(1), tex(2), tex(3)
			sky.SkyboxLf, sky.SkyboxRt, sky.SkyboxUp = tex(4), tex(5), tex(6)
		else
			sky.SkyboxBk, sky.SkyboxDn, sky.SkyboxFt = "", "", ""
			sky.SkyboxLf, sky.SkyboxRt, sky.SkyboxUp = "", "", ""
		end
		sky.Parent = Lighting
		SB.sky = sky
		if p.clock then Lighting.ClockTime = p.clock end
	end
	K[#K + 1] = {Disconnect = restore}
	tg(mw, "Skybox", false, function(v)
		SB.on = v
		build()
	end)
	dl(mw, "Skybox Type", {"Morning", "Evening", "Night", "Classic", "Space", "Custom"}, "Morning", function(n)
		SB.kind = n
		build()
	end)
	-- custom skybox: paste 6 asset ids (bk, dn, ft, lf, rt, up) or a single id for all faces
	local cbox = new("TextBox", {Size = U(1, 0, 0, 28), BackgroundColor3 = BG, Text = "", PlaceholderText = "custom ids: bk,dn,ft,lf,rt,up", PlaceholderColor3 = GRY, TextColor3 = WHT, Font = E.Font.Arcade, TextSize = 12, ClearTextOnFocus = false, TextTruncate = E.TextTruncate.AtEnd}, mw)
	round(cbox, 6)
	new("UIStroke", {Color = FX.LINE, Thickness = 1, ApplyStrokeMode = E.ApplyStrokeMode.Border}, cbox)
	cbox.FocusLost:Connect(function()
		local ids = {}
		for n in cbox.Text:gmatch("%d+") do ids[#ids + 1] = n end
		if #ids == 1 then
			for i = 2, 6 do ids[i] = ids[1] end
		end
		if #ids >= 6 then
			SB.custom = ids
			if SB.kind == "Custom" then build() end
		else
			SB.custom = nil
		end
	end)
end
-- ===== EFFECTS: bullet tracers, impact markers, world tint (HvH-style) =====
local EF = addTab("EFFECTS")
local tracer = {on = false, Marker = true, Color = "Red", Thickness = 0.08, Duration = 0.6}
local tint = {on = false, Color = "Purple", Strength = 40, cc = nil}
local function fxFade(inst, life)
	task.delay(life, function()
		if not inst.Parent then return end
		if inst:IsA("BasePart") then
			TweenService:Create(inst, TweenInfo.new(0.2), {Transparency = 1}):Play()
			task.wait(0.25)
		end
		if inst.Parent then inst:Destroy() end
	end)
end
local lastShot = 0
local function shotFx()
	if not tracer.on then return end
	if os.clock() - lastShot < 0.04 then return end
	lastShot = os.clock()
	local cam = workspace.CurrentCamera
	if not cam then return end
	-- bullet goes where the crosshair points (hitscan games ray from centre)
	local ray = cam:ViewportPointToRay(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
	local params = RaycastParams.new()
	params.FilterType = E.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {LP.Character}
	noSpreadBusy = true
	local hit = workspace:Raycast(ray.Origin, ray.Direction * 1500, params)
	noSpreadBusy = false
	local endPos = hit and hit.Position or (ray.Origin + ray.Direction * 1500)
	local tool = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
	local muzzle = tool and (tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart", true))
	local startPos = muzzle and muzzle.Position or ray.Origin
	local col = colors[tracer.Color] or colors.Red
	local dist = (endPos - startPos).Magnitude
	if dist > 1 then
		local beam = Instance.new("Part")
		beam.Name = "MachulaTracer"
		beam.Anchored = true
		beam.CanCollide = false
		beam.CanQuery = false
		beam.CanTouch = false
		beam.Material = E.Material.Neon
		beam.Color = col
		beam.Size = Vector3.new(tracer.Thickness, tracer.Thickness, dist)
		beam.CFrame = CFrame.lookAt(startPos:Lerp(endPos, 0.5), endPos)
		beam.Transparency = 0.1
		beam.Parent = workspace
		fxFade(beam, tracer.Duration)
	end
	if tracer.Marker and hit then
		local m = Instance.new("Part")
		m.Name = "MachulaImpact"
		m.Anchored = true
		m.CanCollide = false
		m.CanQuery = false
		m.CanTouch = false
		m.Material = E.Material.Neon
		m.Shape = E.PartType.Ball
		m.Size = Vector3.new(0.5, 0.5, 0.5)
		m.Color = col
		m.CFrame = CFrame.new(endPos + hit.Normal * 0.1)
		m.Parent = workspace
		local l = Instance.new("PointLight")
		l.Color = col
		l.Range = 6
		l.Brightness = 2
		l.Parent = m
		fxFade(m, tracer.Duration * 1.5)
	end
end
-- NO RECOIL: pin the camera pitch while firing — kills recoil kick and
-- walk/spray sway; yaw (turning with the mouse) still works normally.
local noRec = {on = false, Window = 0.25, Firing = false, Until = 0, PreRot = nil}
local function noRecCapture()
	if not noRec.on then return end
	noRec.Until = math.max(noRec.Until, os.clock() + noRec.Window)
end
local function noRecTick()
	if not noRec.on then return end
	local cam = workspace.CurrentCamera
	if not cam then return end
	local active = noRec.Firing or os.clock() <= noRec.Until
	if not active or not noRec.PreRot then
		-- settled pose becomes the new baseline for the next shot
		noRec.PreRot = cam.CFrame.Rotation
		return
	end
	if cam.CameraType == E.CameraType.Scriptable then return end
	local _, preYaw = noRec.PreRot:ToEulerAnglesYXZ()
	local _, curYaw = cam.CFrame:ToEulerAnglesYXZ()
	local dyaw = (curYaw - preYaw + math.pi) % (2 * math.pi) - math.pi
	cam.CFrame = CFrame.new(cam.Position) * CFrame.Angles(0, dyaw, 0) * noRec.PreRot
end
pcall(function() RunService:UnbindFromRenderStep("MachulaNoRec") end)
RunService:BindToRenderStep("MachulaNoRec", E.RenderPriority.Last.Value, noRecTick)
K[#K + 1] = {Disconnect = function() RunService:UnbindFromRenderStep("MachulaNoRec") end}
-- NO SPREAD (opt-in, default OFF): intercept the game's aim ray and keep it
-- exactly on the crosshair line. Our own raycalls set noSpreadBusy and stay
-- untouched. If the game spreads bullets without a local Raycast, or the
-- executor has no hookmetamethod, this toggle simply does nothing.
local origNC
pcall(function()
	origNC = hookmetamethod(game, "__namecall", function(self, ...)
		if noSpreadOn and not noSpreadBusy and getnamecallmethod() == "Raycast" then
			local origin, direction, params = ...
			local cam = workspace.CurrentCamera
			if cam and typeof(origin) == "Vector3" and typeof(direction) == "Vector3" and direction.Magnitude > 0 then
				if (origin - cam.CFrame.Position).Magnitude < 12 then
					local look = cam.CFrame.LookVector
					if direction.Unit:Dot(look) > 0.94 then
						return origNC(self, origin, look * direction.Magnitude, params)
					end
				end
			end
		end
		return origNC(self, ...)
	end)
end)
K[#K + 1] = UIS.InputBegan:Connect(function(input, gp)
	if not gp and input.UserInputType == MB1 then
		noRec.Firing = true
		noRecCapture()
		shotFx()
	end
end)
K[#K + 1] = UIS.InputEnded:Connect(function(input)
	if input.UserInputType == MB1 then
		noRec.Firing = false
	end
end)
-- character-safe: LP.Character can be nil at execution time (death/respawn),
-- which previously killed the whole script at this line ("menu disappeared")
local function hookShotTool(char)
	if not char then return end
	char.ChildAdded:Connect(function(c)
		if c:IsA("Tool") then
			c.Activated:Connect(function()
				task.defer(function()
					noRecCapture()
					shotFx()
				end)
			end)
		end
	end)
end
K[#K + 1] = LP.CharacterAdded:Connect(hookShotTool)
if LP.Character then hookShotTool(LP.Character) end
local function applyTint()
	if tint.on then
		if not tint.cc or not tint.cc.Parent then
			tint.cc = Instance.new("ColorCorrectionEffect")
			tint.cc.Name = "MachulaTint"
			tint.cc.Parent = Lighting
		end
		if tint.Color == "Rainbow" then return end
		local col = colors[tint.Color] or colors.Purple
		local s = math.clamp(tint.Strength / 100, 0, 1)
		tint.cc.TintColor = Color3.fromRGB(255, 255, 255):Lerp(col, s)
	elseif tint.cc then
		tint.cc:Destroy()
		tint.cc = nil
	end
end
K[#K + 1] = RunService.RenderStepped:Connect(function()
	if tint.on and tint.Color == "Rainbow" and tint.cc then
		local s = math.clamp(tint.Strength / 100, 0, 1)
		tint.cc.TintColor = Color3.fromRGB(255, 255, 255):Lerp(Color3.fromHSV((os.clock() * 0.2) % 1, 1, 1), s)
	end
end)
local bs = EF:section(1, "BULLET TRACERS")
tg(bs, "Bullet Tracers", false, function(v) tracer.on = v end)
tg(bs, "Impact Marker", tracer.Marker, function(v) tracer.Marker = v end)
dd(bs, "Tracer Color", cn, tracer.Color, function(n) tracer.Color = n end)
sl(bs, "Tracer Thickness", 0.02, 0.5, tracer.Thickness, 0.02, function(v) tracer.Thickness = v end)
sl(bs, "Tracer Duration (s)", 0.1, 3, tracer.Duration, 0.1, function(v) tracer.Duration = v end)
local nr = EF:section(1, "NO RECOIL")
tg(nr, "No Recoil", false, function(v)
	noRec.on = v
	noRec.Firing = false
	if not v then noRec.PreRot = nil end
end)
tg(nr, "No Spread", false, function(v) noSpreadOn = v end)
sl(nr, "Recoil Window (s)", 0.05, 0.6, noRec.Window, 0.05, function(v) noRec.Window = v end)
local wt = EF:section(2, "WORLD TINT")
tg(wt, "World Tint", false, function(v)
	tint.on = v
	applyTint()
end)
dd(wt, "Tint Color", {"Red", "Green", "Blue", "Yellow", "Purple", "White", "Rainbow"}, tint.Color, function(n)
	tint.Color = n
	applyTint()
end)
sl(wt, "Tint Strength (%)", 5, 100, tint.Strength, 5, function(v)
	tint.Strength = v
	applyTint()
end)
local PT = addTab("PLAYER")
local function moveSection(st, col, title, label, slName, min, max)
local sec = PT:section(col, title)
tg(sec, label, false, function(v)
st.Enabled = v
st.Active = false
end)
dd(sec, "Mode", {"Hold Bind", "Toggle Bind", "Always On"}, st.Mode, function(v)
st.Mode = v
st.Active = false
end)
st.Label = bt(sec, st.Name .. " Bind: " .. st.Bind.Name, function()
st.Binding = true
st.Active = false
st.Label:Set("press a key... (Esc = cancel)")
end)
sl(sec, slName, min, max, st.Value, 1, function(v) st.Value = v end)
return sec
end
local wsec = moveSection(walk, 1, "WALK SPEED", "Walk Speed", "Speed", 16, 200)
dd(wsec, "Speed Method", {"Auto", "WalkSpeed Only", "Velocity Force"}, walk.Method, function(v) walk.Method = v end)
local jsec = moveSection(jump, 1, "JUMP POWER", "Jump Power", "Power", 50, 300)
dd(jsec, "Jump Method", {"Auto", "JumpPower Only", "Impulse"}, jump.Method, function(v) jump.Method = v end)

-- ===== THIRD PERSON (BloxStrike / any forced first-person game) =====
local third = {Enabled = false, Dist = 25, Saved = nil}
local thirdRay = RaycastParams.new()
thirdRay.FilterType = E.RaycastFilterType.Exclude
local function applyThird()
	if not third.Enabled then return end
	if not third.Saved then
		third.Saved = {Max = LP.CameraMaxZoomDistance, Min = LP.CameraMinZoomDistance, Mode = LP.CameraMode}
	end
	LP.CameraMode = E.CameraMode.Classic
	LP.CameraMaxZoomDistance = third.Dist
	if LP.CameraMinZoomDistance > 1 then LP.CameraMinZoomDistance = 1 end
end
local function restoreThird()
	if third.Saved then
		LP.CameraMaxZoomDistance = third.Saved.Max
		LP.CameraMinZoomDistance = third.Saved.Min
		LP.CameraMode = third.Saved.Mode
		third.Saved = nil
	end
end
-- late renderstep: lock the zoom settings AFTER the game's own camera code;
-- if the game pins the camera to Scriptable (FPS viewmodel scripts), drive
-- the camera ourselves: wall-checked orbit behind the character.
local function thirdTick()
	if not third.Enabled then return end
	applyThird()
	local cam = workspace.CurrentCamera
	local char = LP.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not cam or not root or not hum or hum.Health <= 0 then return end
	if cam.CameraType ~= E.CameraType.Scriptable then return end
	local look = root.CFrame.LookVector
	local yaw = math.atan2(-look.X, -look.Z)
	local pitch = -0.18
	local pivot = root.Position + Vector3.new(0, 1.7, 0)
	local dir = CFrame.Angles(pitch, yaw, 0).LookVector
	local pos = pivot - dir * third.Dist
	thirdRay.FilterDescendantsInstances = {char}
	noSpreadBusy = true
	local hit = workspace:Raycast(pivot, pos - pivot, thirdRay)
	noSpreadBusy = false
	if hit then
		pos = hit.Position + hit.Normal * 0.6
	end
	cam.CFrame = CFrame.lookAt(pos, pivot)
end
pcall(function() RunService:UnbindFromRenderStep("MachulaCam") end)
RunService:BindToRenderStep("MachulaCam", E.RenderPriority.Last.Value, thirdTick)
K[#K + 1] = {Disconnect = function() RunService:UnbindFromRenderStep("MachulaCam") end}
K[#K + 1] = UIS.InputChanged:Connect(function(i)
	if third.Enabled and i.UserInputType == E.UserInputType.MouseWheel then
		third.Dist = math.clamp(third.Dist - i.Position.Y * 4, 8, 150)
	end
end)

-- ===== SPINBOT: spins your own character (HvH anti-aim) =====
local spin = {Enabled = false, Mode = "Jitter (HvH)", RPM = 120, Yaw = 0, Next = 0, WasAuto = nil}
local function spinApply(hum, on)
	if on then
		if spin.WasAuto == nil then spin.WasAuto = hum.AutoRotate end
		hum.AutoRotate = false
	elseif spin.WasAuto ~= nil then
		hum.AutoRotate = spin.WasAuto
		spin.WasAuto = nil
	end
end
-- yaw advances ONCE per frame (plain RenderStepped, the event every UI in
-- this script already relies on); the rotation is then RE-APPLIED at every
-- later stage of the frame (Last renderstep + Heartbeat). Whichever write
-- lands last before the render is what you see, so neither the game's own
-- character code nor a flaky BindToRenderStep can keep the body frozen.
local function spinAdvance(dt)
	if spin.Mode == "Jitter (HvH)" then
		if os.clock() >= spin.Next then
			spin.Next = os.clock() + 0.05 + math.random() * 0.1
			spin.Yaw = math.rad(math.random(0, 359))
		end
	else
		spin.Yaw = spin.Yaw + math.rad(spin.RPM) * dt
	end
end
local function spinWrite()
	if not spin.Enabled then return end
	local char = LP.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not (hum and root and hum.Health > 0) then
		if hum and spin.WasAuto ~= nil then spinApply(hum, false) end
		return
	end
	spinApply(hum, true)
	root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, spin.Yaw, 0)
end
K[#K + 1] = RunService.RenderStepped:Connect(function(dt)
	spinAdvance(dt)
	spinWrite()
end)
K[#K + 1] = RunService.Heartbeat:Connect(spinWrite)
pcall(function() RunService:UnbindFromRenderStep("MachulaSpin") end)
RunService:BindToRenderStep("MachulaSpin", E.RenderPriority.Last.Value, spinWrite)
K[#K + 1] = {Disconnect = function() RunService:UnbindFromRenderStep("MachulaSpin") end}
do
	-- the engine's very last pre-render signal: beats every RenderStepped
	-- binding no matter what priority the game used
	local ok, sig = pcall(function() return RunService.PreRender end)
	if ok and sig then
		K[#K + 1] = sig:Connect(spinWrite)
	end
end
K[#K + 1] = LP.CharacterAdded:Connect(function()
	spin.WasAuto = nil
	spin.Yaw = 0
	spin.Next = 0
end)
local sp = PT:section(2, "SPINBOT")
tg(sp, "Spinbot", false, function(v)
	spin.Enabled = v
	if not v then
		spin.Yaw = 0
		local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
		if hum and spin.WasAuto ~= nil then spinApply(hum, false) end
	end
end)
dl(sp, "Spin Mode", {"Jitter (HvH)", "Smooth"}, spin.Mode, function(n)
	spin.Mode = n
	spin.Next = 0
end)
sl(sp, "Spin Speed (RPM)", 30, 720, spin.RPM, 10, function(v) spin.RPM = v end)
local tp = PT:section(1, "THIRD PERSON")
tg(tp, "Third Person", false, function(v)
	third.Enabled = v
	if v then applyThird() else restoreThird() end
end)
sl(tp, "Camera Distance", 8, 150, third.Dist, 1, function(v)
	third.Dist = v
	if third.Enabled then applyThird() end
end)

-- ===== SELF AURAS =====
local AURA = "MachulaAura"
local aura = {on = false, Kind = "Fire", Color = "Red", Amount = 100, em = nil}
local auraColors = {Red = RGB(255, 60, 60), Orange = RGB(255, 140, 30), Yellow = RGB(255, 220, 50), Green = RGB(60, 255, 90), Cyan = RGB(60, 240, 255), Blue = RGB(60, 120, 255), Purple = RGB(170, 70, 255), Pink = RGB(255, 90, 180), White = WHT}
local acn = {"Red", "Orange", "Yellow", "Green", "Cyan", "Blue", "Purple", "Pink", "White"}
local auraPresets = {
	["Fire"] = {tex = "rbxasset://textures/particles/smoke_main.dds", rate = 70, speed = 7, size = 1.3, life = 0.9, spread = 22, glow = 1, transp = 0.15, accel = Vector3.new(0, 10, 0), inst = "Fire", light = 9},
	["Sparkles"] = {tex = "rbxasset://textures/particles/sparkles_main.dds", rate = 45, speed = 3, size = 0.7, life = 1.7, spread = 180, glow = 1, transp = 0.05, accel = Vector3.new(0, 2, 0), inst = "Sparkles"},
	["Smoke"] = {tex = "rbxasset://textures/particles/smoke_main.dds", rate = 35, speed = 1.5, size = 2.2, life = 2.4, spread = 70, glow = 0, transp = 0.4, accel = Vector3.new(0, 3, 0), inst = "Smoke"},
	["Neon Glow"] = {tex = "rbxasset://textures/particles/sparkles_main.dds", rate = 90, speed = 4, size = 0.9, life = 1.2, spread = 180, glow = 1, transp = 0.02, accel = Vector3.new(0, 2, 0), highlight = true, light = 8},
	["Electric"] = {tex = "rbxasset://textures/particles/sparkles_main.dds", rate = 140, speed = 15, size = 0.35, life = 0.5, spread = 180, glow = 1, transp = 0, squash = -1, light = 7},
	["Rainbow"] = {tex = "rbxasset://textures/particles/sparkles_main.dds", rate = 90, speed = 4, size = 0.9, life = 1.2, spread = 180, glow = 1, transp = 0.02, accel = Vector3.new(0, 2, 0), highlight = true, rainbow = true, light = 8},
}
local function auraCleanup(char)
	if not char then return end
	for _, o in ipairs(char:GetChildren()) do
		if o.Name == AURA then o:Destroy() end
	end
	aura.em = nil
end
local function auraApply()
	local char = LP.Character
	if not aura.on or not char then return end
	auraCleanup(char)
	local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
	if not root then return end
	local p = auraPresets[aura.Kind] or auraPresets["Fire"]
	local col = auraColors[aura.Color] or auraColors.Red
	local e = Instance.new("ParticleEmitter")
	e.Name = AURA
	e.Texture = p.tex
	e.Color = ColorSequence.new(col)
	e.LightEmission = p.glow or 0
	e.Rate = (p.rate or 60) * aura.Amount / 100
	e.Speed = NumberRange.new(p.speed or 4)
	e.Size = NumberSequence.new(p.size or 1)
	e.Lifetime = NumberRange.new((p.life or 1) * 0.8, (p.life or 1) * 1.2)
	e.Transparency = NumberSequence.new(p.transp or 0.1)
	e.SpreadAngle = Vector2.new(p.spread or 30, p.spread or 30)
	e.Acceleration = p.accel or Vector3.zero
	e.EmissionDirection = E.NormalId.Top
	e.LockedToPart = false
	if p.squash then
		e.Orientation = E.ParticleOrientation.VelocityParallel
		e.Squash = NumberSequence.new(p.squash)
	end
	e.Parent = root
	aura.em = e
	if p.inst then
		pcall(function()
			local i = Instance.new(p.inst)
			i.Name = AURA
			if p.inst == "Fire" then
				i.Size, i.Heat = 1.2, 8
				i.Color = col
				i.SecondaryColor = auraColors.Yellow
			elseif p.inst == "Sparkles" then
				i.SparkleColor = col
			elseif p.inst == "Smoke" then
				i.Opacity, i.RiseVelocity, i.Size = 0.35, 2, 1.6
				i.Color = col
			end
			i.Parent = root
		end)
	end
	if p.highlight then
		local hl = Instance.new("Highlight")
		hl.Name = AURA
		hl.Adornee = char
		hl.FillColor = col
		hl.OutlineColor = col
		hl.FillTransparency = 0.7
		hl.OutlineTransparency = 0.1
		hl.DepthMode = E.HighlightDepthMode.AlwaysOnTop
		hl.Parent = char
	end
	if p.light then
		local l = Instance.new("PointLight")
		l.Name = AURA
		l.Color = col
		l.Range = p.light
		l.Brightness = 1.4
		l.Parent = root
	end
end
K[#K + 1] = RunService.RenderStepped:Connect(function()
	if not aura.on then return end
	local p = auraPresets[aura.Kind]
	if not (p and p.rainbow and aura.em) then return end
	local c = Color3.fromHSV((os.clock() * 0.25) % 1, 1, 1)
	aura.em.Color = ColorSequence.new(c)
	local char = LP.Character
	if char then
		for _, o in ipairs(char:GetChildren()) do
			if o.Name == AURA and o:IsA("Highlight") then
				o.FillColor = c
				o.OutlineColor = c
			elseif o.Name == AURA and o:IsA("PointLight") then
				o.Color = c
			end
		end
	end
end)
K[#K + 1] = LP.CharacterAdded:Connect(function()
	if aura.on then
		task.wait(0.4)
		auraApply()
	end
end)
local ap = PT:section(1, "SELF AURAS")
tg(ap, "Aura", false, function(v)
	aura.on = v
	if v then auraApply() else auraCleanup(LP.Character) end
end)
dl(ap, "Aura Type", {"Fire", "Sparkles", "Smoke", "Neon Glow", "Electric", "Rainbow"}, aura.Kind, function(n)
	aura.Kind = n
	if aura.on then auraApply() end
end)
dl(ap, "Aura Color", acn, aura.Color, function(n)
	aura.Color = n
	if aura.on then auraApply() end
end)
sl(ap, "Aura Amount (%)", 20, 300, aura.Amount, 5, function(v)
	aura.Amount = v
	if aura.on and aura.em then
		local p = auraPresets[aura.Kind]
		if p then aura.em.Rate = (p.rate or 60) * v / 100 end
	end
end)

-- ===== BUNNY HOP (BloxStrike runs) =====
local bh = PT:section(2, "BUNNY HOP")
tg(bh, "Bunny Hop", false, function(v)
	bhop.Enabled = v
	bhop.Active = false
end)
dd(bh, "Mode", {"Hold Bind", "Toggle Bind"}, bhop.Mode, function(v)
	bhop.Mode = v
	bhop.Active = false
end)
bhop.Label = bt(bh, "Bhop Bind: " .. bhop.Bind.Name, function()
	bhop.Binding = true
	bhop.Active = false
	bhop.Label:Set("press a key... (Esc = cancel)")
end)
sl(bh, "Hop Power", 20, 150, bhop.Force, 5, function(v) bhop.Force = v end)
moveSection(fly, 2, "FLY", "Fly", "Speed", 10, 300)

-- ===== OWNER SKIN CHANGER =====
-- Uses skin models stored in ReplicatedStorage/Wraps and ReplicatedStorage/Knives.
local SkinRS = game:GetService("ReplicatedStorage")
local SkinCfg = {
    Enabled = false,
    DoubleBarrel = "Ascension",
    Revolver = "Ascension",
    TacticalShotgun = "Ascension",
    SMG = "Ascension",
    Shotgun = "Ascension",
    Knife = "Beta",
}
local skinHandleMap = {DB_HANDLE = "DoubleBarrel", REV_HANDLE = "Revolver"}

local function skinIsPart(x)
    return typeof(x) == "Instance" and x:IsA("BasePart")
end

local function skinPrimary(model)
    if model and model:IsA("Model") then
        if not skinIsPart(model.PrimaryPart) then
            local first = model:FindFirstChildWhichIsA("BasePart", true)
            if first then model.PrimaryPart = first end
        end
        return model.PrimaryPart
    end
end

local function skinPrep(model, isKnife)
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Anchored = false
            part.Massless = true
            part.Transparency = math.clamp(part.Transparency, 0, 1)
        end
        if isKnife and part:IsA("MeshPart") then
            local sa = part:FindFirstChildOfClass("SurfaceAppearance")
            if sa then sa:Destroy() end
            if part.TextureID == "" then
                local n = part.Name:lower()
                if n:find("box") or n:find("cube") or n:find("part") or n:find("hit") then
                    part.Transparency = 1
                end
            end
        end
    end
end

local function skinWeld(a, b)
    if skinIsPart(a) and skinIsPart(b) then
        local weld = Instance.new("WeldConstraint")
        weld.Part0, weld.Part1, weld.Parent = a, b, a
    end
end

local function getWrapSkin(weaponName, skinName)
    local wraps = SkinRS:FindFirstChild("Wraps")
    local folder = wraps and wraps:FindFirstChild("[" .. weaponName .. "]")
    return folder and folder:FindFirstChild(skinName)
end

local function applySkinModel(holder, skinModel)
    if not holder or not skinModel then return false end
    local handle = holder:FindFirstChild("Handle")
    if not skinIsPart(handle) then return false end
    local old = holder:FindFirstChild("SkinModel")
    if old then old:Destroy() end
    local clone = skinModel:Clone()
    clone.Name = "SkinModel"
    local primary = skinPrimary(clone)
    if not skinIsPart(primary) then clone:Destroy() return false end
    local isKnife = holder.Name:find("Knife") ~= nil
    skinPrep(clone, isKnife)
    clone.Parent = holder
    clone:PivotTo(handle.CFrame)
    for _, part in ipairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then skinWeld(handle, part) end
    end
    handle.Transparency = 1
    return true
end

local function applyToolSkin(tool)
    if not tool or not tool:IsA("Tool") then return false end
    local weaponName = tool.Name:match("^%[(.+)%]$")
    if not weaponName then return false end
    local skinName = SkinCfg[weaponName]
    if not skinName or skinName == "" then return false end
    local model = getWrapSkin(weaponName, skinName)
    return model and applySkinModel(tool, model) or false
end

local function applyKnifeSkin(tool)
    if not tool or not tool:IsA("Tool") or tool.Name ~= "[Knife]" then return false end
    local knives = SkinRS:FindFirstChild("Knives")
    local model = knives and knives:FindFirstChild(SkinCfg.Knife)
    return model and applySkinModel(tool, model) or false
end

local function applyHandleSkin(character, folderName)
    local weaponName = skinHandleMap[folderName]
    if not weaponName then return false end
    local folder = character:FindFirstChild(folderName)
    local model = getWrapSkin(weaponName, SkinCfg[weaponName])
    return folder and model and applySkinModel(folder, model) or false
end

local function applyAllWeaponSkins(character)
    if not SkinCfg.Enabled or not character then return end
    for _, item in ipairs(character:GetChildren()) do
        if item:IsA("Tool") then
            applyToolSkin(item)
            applyKnifeSkin(item)
        end
    end
    for folderName in pairs(skinHandleMap) do
        applyHandleSkin(character, folderName)
    end
end

local function hookSkinCharacter(character)
    character.ChildAdded:Connect(function(child)
        if not SkinCfg.Enabled then return end
        if child:IsA("Tool") then
            task.defer(function()
                if child.Parent then
                    applyToolSkin(child)
                    applyKnifeSkin(child)
                end
            end)
        elseif skinHandleMap[child.Name] then
            task.defer(function() applyHandleSkin(character, child.Name) end)
        end
    end)
    applyAllWeaponSkins(character)
end

LP.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    hookSkinCharacter(character)
end)
if LP.Character then hookSkinCharacter(LP.Character) end

local SK = addTab("SKINS")
local skinMain = SK:section(1, "HOOD CUSTOMS")
tg(skinMain, "Enable Skin Changer", false, function(v)
    SkinCfg.Enabled = v
    if v and LP.Character then applyAllWeaponSkins(LP.Character) end
end)
local skinOptions = {"Ascension", "Adurite", "Amethyst", "Arctic", "Arsenic", "Binary", "Black Cat", "Black Ice", "Blacksteel Dragon", "Candy Cane", "Crimson"}
dd(skinMain, "DoubleBarrel Skin", skinOptions, SkinCfg.DoubleBarrel, function(v)
    SkinCfg.DoubleBarrel = v
    if SkinCfg.Enabled and LP.Character then applyAllWeaponSkins(LP.Character) end
end)
dd(skinMain, "Revolver Skin", skinOptions, SkinCfg.Revolver, function(v)
    SkinCfg.Revolver = v
    if SkinCfg.Enabled and LP.Character then applyAllWeaponSkins(LP.Character) end
end)
dd(skinMain, "TacticalShotgun Skin", skinOptions, SkinCfg.TacticalShotgun, function(v)
    SkinCfg.TacticalShotgun = v
    if SkinCfg.Enabled and LP.Character then applyAllWeaponSkins(LP.Character) end
end)
dd(skinMain, "SMG Skin", skinOptions, SkinCfg.SMG, function(v)
    SkinCfg.SMG = v
    if SkinCfg.Enabled and LP.Character then applyAllWeaponSkins(LP.Character) end
end)
dd(skinMain, "Shotgun Skin", skinOptions, SkinCfg.Shotgun, function(v)
    SkinCfg.Shotgun = v
    if SkinCfg.Enabled and LP.Character then applyAllWeaponSkins(LP.Character) end
end)
dd(skinMain, "Knife Skin", {"Beta"}, SkinCfg.Knife, function(v)
    SkinCfg.Knife = v
    if SkinCfg.Enabled and LP.Character then applyAllWeaponSkins(LP.Character) end
end)
bt(skinMain, "Apply Skins Now", function()
    if LP.Character then applyAllWeaponSkins(LP.Character) end
end)

local sc = addTab("SET"):section(1, "SCRIPT")
MB = bt(sc, "Menu Bind: " .. menuKey.Name, function()
menuBinding = true
MB:Set("press a key... (Esc = cancel)")
end)
bt(sc, "Close Script", function()
S.Enabled = false
S.Boxes = false
S.Traces = false
M.ChangeMaterial = false
M.Fullbright = false
M.NoFog = false
walk.Enabled = false
fly.Enabled = false
jump.Enabled = false
bhop.Enabled = false
third.Enabled = false
aura.on = false
restoreWalk()
restoreJump()
stopFly()
restoreThird()
auraCleanup(LP.Character)
spin.Enabled = false
if walk.BV then walk.BV:Destroy() walk.BV = nil end
jump.Impulse = false
do
	local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
	if hum and spin.WasAuto ~= nil then spinApply(hum, false) end
end
tracer.on = false
noRec.on = false
noRec.Firing = false
noRec.PreRot = nil
tint.on = false
if tint.cc then tint.cc:Destroy() tint.cc = nil end
for _, o in ipairs(workspace:GetChildren()) do
	if o.Name == "MachulaTracer" or o.Name == "MachulaImpact" then o:Destroy() end
end
aim.Enabled = false
clearAll()
for _, c in ipairs(K) do c:Disconnect() end
container:Destroy()
fovGui:Destroy()
espGui:Destroy()
restoreMat()
restoreLight({"Brightness", "ClockTime", "Ambient", "OutdoorAmbient", "FogStart", "FogEnd"})
gui:Destroy()
end)
do
local function build()
local HttpService = game:GetService("HttpService")
local okEnv, fenv = pcall(getfenv)
if not okEnv or type(fenv) ~= "table" then fenv = {} end
local WF, RF, IF, LF, DF = fenv.writefile, fenv.readfile, fenv.isfile, fenv.listfiles, fenv.delfile
local IFo, MF = fenv.isfolder, fenv.makefolder
local FS = type(WF) == "function" and type(RF) == "function" and type(IF) == "function" and type(LF) == "function" and type(DF) == "function"
local FOLDER = "MachulaConfigs"
local mem = {}
if FS and type(IFo) == "function" and type(MF) == "function" then
pcall(function() if not IFo(FOLDER) then MF(FOLDER) end end)
end
local function bindStr(b)
return (b.EnumType == E.KeyCode and "K:" or "U:") .. b.Name
end
local function strBind(s)
if type(s) ~= "string" then return nil end
local kind, n = s:match("^(%a):(.+)$")
local enum = (kind == "K" and E.KeyCode) or (kind == "U" and E.UserInputType) or nil
if not enum then return nil end
local ok, v = pcall(function() return enum[n] end)
return ok and v or nil
end
local function collect()
local d = {version = 1, controls = {}, binds = {}}
for _, c in ipairs(CFG.ctl) do d.controls[c.id] = c.get() end
d.binds.aim = bindStr(aim.Bind)
d.binds.walk = bindStr(walk.Bind)
d.binds.fly = bindStr(fly.Bind)
d.binds.jump = bindStr(jump.Bind)
d.binds.bhop = bindStr(bhop.Bind)
d.binds.menu = bindStr(menuKey)
return d
end
local function apply(d)
if type(d) ~= "table" then return false end
for _, c in ipairs(CFG.ctl) do
local v = type(d.controls) == "table" and d.controls[c.id] or nil
if v ~= nil then pcall(c.set, v) end
end
local b = d.binds
if type(b) == "table" then
local nb = strBind(b.aim)
if nb then
aim.Bind = nb
aim.Active = false
BB:Set("Aim Bind: " .. nb.Name)
end
for _, st in ipairs({walk, fly, jump, bhop}) do
local k = strBind(b[st.Name:lower()])
if k then
st.Bind = k
st.Active = false
st.Label:Set(st.Name .. " Bind: " .. k.Name)
end
end
local mk = strBind(b.menu)
if mk and mk.EnumType == E.KeyCode then
menuKey = mk
MB:Set("Menu Bind: " .. mk.Name)
end
end
return true
end
local function clean(s)
s = tostring(s or "")
s = s:gsub("[^%w_%- ]", "")
s = s:gsub("^%s+", "")
s = s:gsub("%s+$", "")
return s:sub(1, 32)
end
local function listNames()
local out = {}
if FS then
local ok, files = pcall(LF, FOLDER)
if ok and type(files) == "table" then
for _, f in ipairs(files) do
local n = tostring(f):match("([^/\\]+)%.json$")
if n then out[#out + 1] = n end
end
end
else
for n in pairs(mem) do out[#out + 1] = n end
end
table.sort(out, function(a, b) return a:lower() < b:lower() end)
return out
end
local function readCfg(name)
local path = FOLDER .. "/" .. name .. ".json"
if FS then
local ok, raw = pcall(function()
if not IF(path) then return nil end
return RF(path)
end)
return ok and raw or nil
end
return mem[name]
end

local box = tabs[#tabs]:section(2, "CONFIGS")
text(box, FS and ("storage: files (" .. FOLDER .. ")") or "storage: session only", GRY, nil, U(1, 0, 0, 14)).TextSize = 11
local nameBox = new("TextBox", {Size = U(1, 0, 0, 24), BackgroundColor3 = BG, Text = "", PlaceholderText = "config name", PlaceholderColor3 = GRY, TextColor3 = WHT, Font = E.Font.Code, TextSize = 13, ClearTextOnFocus = false}, box)
round(nameBox, 4)
local lst = new("ScrollingFrame", {Size = U(1, 0, 0, 110), BackgroundColor3 = BG, ScrollBarThickness = 3, ScrollBarImageColor3 = RED, AutomaticCanvasSize = E.AutomaticSize.Y, CanvasSize = U()}, box)
round(lst, 4)
new("UIPadding", {PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 3), PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 3)}, lst)
list(lst, 2)
local status
local function say(t) status.Text = t end
local function rebuild()
for _, c in ipairs(lst:GetChildren()) do
if c:IsA("TextButton") then c:Destroy() end
end
for _, n in ipairs(listNames()) do
local it = new("TextButton", {Text = n, TextColor3 = (n == clean(nameBox.Text)) and RED or WHT, Size = U(1, -6, 0, 20), BackgroundColor3 = PNL}, lst)
round(it, 3)
it.MouseButton1Click:Connect(function()
nameBox.Text = n
rebuild()
end)
end
end
bt(box, "Save", function()
local name = clean(nameBox.Text)
if name == "" then say("enter a name first") return end
local ok, json = pcall(function() return HttpService:JSONEncode(collect()) end)
if not ok then say("save failed (encode)") return end
if FS then
if not pcall(WF, FOLDER .. "/" .. name .. ".json", json) then say("save failed (write)") return end
else
mem[name] = json
end
nameBox.Text = name
say("saved: " .. name)
rebuild()
end)
bt(box, "Load", function()
local name = clean(nameBox.Text)
if name == "" then say("pick or type a name") return end
local raw = readCfg(name)
if not raw then say("not found: " .. name) return end
local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
if not ok or not apply(data) then say("load failed (bad file)") return end
say("loaded: " .. name)
end)
bt(box, "Delete", function()
local name = clean(nameBox.Text)
if name == "" then say("pick or type a name") return end
if FS then
if not pcall(function() DF(FOLDER .. "/" .. name .. ".json") end) then say("delete failed") return end
else
mem[name] = nil
end
say("deleted: " .. name)
rebuild()
end)
bt(box, "Refresh List", function()
rebuild()
say("list refreshed")
end)
status = text(box, "", GRY, nil, U(1, 0, 0, 14))
status.TextSize = 11
status.TextTruncate = E.TextTruncate.AtEnd
rebuild()
end
build()
end
print("[Machula] loaded")
