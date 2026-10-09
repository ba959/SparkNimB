local P=game.Players.LocalPlayer
local function boot()
local RS=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local cam=workspace.CurrentCamera
local PGUI=P:WaitForChild("PlayerGui")

for _,g in ipairs(PGUI:GetChildren())do
 if g.Name=="CombatGui"or g.Name=="CrashError"then g:Destroy()end
end
for _,d in ipairs(workspace:GetDescendants())do
 if d.Name=="NaHL"or d.Name=="NaESP"then pcall(function()d:Destroy()end)end
end
pcall(function()RS:UnbindFromRenderStep("NaAim")end)
pcall(function()RS:UnbindFromRenderStep("AIM")end)

local okD,Dr=pcall(function()return Drawing end)
local hasD=okD and Dr~=nil and Dr.new~=nil
local hasMouseMove=type(mousemoverel)=="function"
local hasM1=type(mouse1click)=="function"

local LOCK=nil
local lastFire=0
local AIM,ESP,TRIG=false,false,false
local clicks={aim=0,esp=0,trig=0}
local TARGETS={}
local npcRigs={}
local WHEEL={}
local function cyc(list,i)return list[i%#list+1],(i%#list)+1 end
WHEEL.HOLD={"Always","Mouse1","Mouse2","E","LeftAlt"}local hI=1
WHEEL.FOV={30,60,90,120,180,270,360}local fI=4
WHEEL.SM={0,0.05,0.1,0.2,0.3,0.4,0.6,0.8}local sI=3
WHEEL.PART={"Head","UpperTorso","HumanoidRootPart","Any"}local pI=1
WHEEL.DIST={200,500,1000,2000,5000,10000}local dI=5
WHEEL.MODE={"Crosshair","Distance","Health"}local mI=1
WHEEL.TSIZE={12,14,16,18,20}local tI=3
WHEEL.EDIST={500,1000,2000,5000,10000}local edI=3
WHEEL.THOLD={"Always","Mouse1","Mouse2"}local thI=1
WHEEL.DELAY={0,25,50,75,100,150,250}local dlI=3
WHEEL.TFOV={1,2,3,5,8,12}local tfI=3
WHEEL.TPART={"Head","UpperTorso","HumanoidRootPart","Any"}local tpI=1
local A_VIS,A_TEAM,A_ROT,A_CIRC=true,true,false,true
local E_HL,E_NAME,E_HP,E_DIST,E_TEAM=true,true,true,true,true
local T_VIS,T_TEAM,T_AUTO=true,true,true

local sg=Instance.new("ScreenGui")
sg.Name="CombatGui"sg.ResetOnSpawn=false sg.IgnoreGuiInset=true
sg.DisplayOrder=999999 sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling sg.Parent=PGUI

local function topBtn(t,x)
 local b=Instance.new("TextButton")b.Size=UDim2.fromOffset(74,32)b.Position=UDim2.new(.5,x,.02,0)
 b.BackgroundColor3=Color3.fromRGB(38,38,42)b.TextColor3=Color3.new(1,1,1)
 b.Font=Enum.Font.GothamBold b.TextSize=13 b.Active=true b.AutoButtonColor=true b.ZIndex=10
 b.Text=t b.Parent=sg
 Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)return b
end
local aimBtn=topBtn("AIM: OFF",-172)
local espBtn=topBtn("ESP: OFF",-94)
local trigBtn=topBtn("TRIG: OFF",-16)
local sbtn=topBtn("Gear",62)
local hint=Instance.new("TextLabel")hint.Size=UDim2.fromOffset(380,16)hint.Position=UDim2.new(.5,-190,.02,36)
hint.BackgroundTransparency=1 hint.Text="T=AIM Y=ESP U=TRIG RightCtrl=settings"
hint.TextColor3=Color3.fromRGB(160,160,160)hint.Font=Enum.Font.Gotham hint.TextSize=11 hint.Parent=sg
local dbg=Instance.new("TextLabel")dbg.Size=UDim2.fromOffset(460,16)dbg.Position=UDim2.new(0,6,1,-20)
dbg.BackgroundTransparency=1 dbg.TextXAlignment=Enum.TextXAlignment.Left
dbg.TextColor3=Color3.fromRGB(255,220,0)dbg.Font=Enum.Font.Code dbg.TextSize=12 dbg.Parent=sg
local function dbgUpd()dbg.Text=string.format("[Draw=%s Move=%s] targets=%d aim=%d esp=%d trig=%d",hasD and"OK"or"N",hasMouseMove and"OK"or"N",#TARGETS,clicks.aim,clicks.esp,clicks.trig)end
dbgUpd()

local pnl=Instance.new("Frame")pnl.Size=UDim2.fromOffset(184,340)pnl.Position=UDim2.new(.5,-92,.02,56)
pnl.BackgroundColor3=Color3.fromRGB(15,15,17)pnl.BackgroundTransparency=.08 pnl.Visible=false pnl.ZIndex=5 pnl.Parent=sg
Instance.new("UICorner",pnl).CornerRadius=UDim.new(0,10)
local pst=Instance.new("UIStroke",pnl)pst.Thickness=2 pst.Color=Color3.fromRGB(0,200,255)
local pt=Instance.new("TextLabel")pt.Size=UDim2.fromOffset(184,22)pt.BackgroundTransparency=1 pt.ZIndex=6
pt.Text="SETTINGS"pt.TextColor3=Color3.new(1,1,1)pt.Font=Enum.Font.GothamBold pt.TextSize=14 pt.Parent=pnl
local function tab(t,x,w)
 local b=Instance.new("TextButton")b.Size=UDim2.fromOffset(w,22)b.Position=UDim2.fromOffset(x,24) b.ZIndex=6
 b.BackgroundColor3=Color3.fromRGB(40,40,44)b.TextColor3=Color3.new(1,1,1)
 b.Font=Enum.Font.GothamBold b.TextSize=12 b.Active=true b.Text=t b.Parent=pnl
 Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)return b
end
local tA=tab("AIM",4,56)
local tE=tab("ESP",62,56)
local tT=tab("TRIG",120,60)
local fA=Instance.new("Frame")fA.Size=UDim2.fromOffset(184,290)fA.Position=UDim2.fromOffset(0,50)
fA.BackgroundTransparency=1 fA.ZIndex=6 fA.Parent=pnl
local fE=fA:Clone()fE.Parent=pnl
local fT=fA:Clone()fT.Parent=pnl
local function showTab(w)
 fA.Visible=w==1 fE.Visible=w==2 fT.Visible=w==3
 tA.BackgroundColor3=w==1 and Color3.fromRGB(0,110,160)or Color3.fromRGB(40,40,44)
 tE.BackgroundColor3=w==2 and Color3.fromRGB(0,110,160)or Color3.fromRGB(40,40,44)
 tT.BackgroundColor3=w==3 and Color3.fromRGB(0,110,160)or Color3.fromRGB(40,40,44)
end
tA.MouseButton1Click:Connect(function()showTab(1)end)
tE.MouseButton1Click:Connect(function()showTab(2)end)
tT.MouseButton1Click:Connect(function()showTab(3)end)
showTab(1)

local counts={}
local function row(folder,lbl,getText,onClick)
 local y=6+(counts[folder]or 0)*26
 counts[folder]=(counts[folder]or 0)+1
 local b=Instance.new("TextButton")b.Size=UDim2.fromOffset(172,24)b.Position=UDim2.fromOffset(6,y) b.ZIndex=7
 b.BackgroundColor3=Color3.fromRGB(36,36,40)b.TextColor3=Color3.new(1,1,1)
 b.Font=Enum.Font.GothamBold b.TextSize=12 b.Active=true b.Parent=folder
 Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
 local function upd()b.Text=lbl..": "..getText()end
 b.MouseButton1Click:Connect(function()onClick()upd()end)
 upd()return b
end

row(fA,"Mode hold",function()return WHEEL.HOLD[hI]end,function()local _,n=cyc(WHEEL.HOLD,hI)hI=n end)
row(fA,"FOV",function()return WHEEL.FOV[fI]end,function()local _,n=cyc(WHEEL.FOV,fI)fI=n end)
row(fA,"Smooth",function()return WHEEL.SM[sI]==0 and"INSTANT"or tostring(WHEEL.SM[sI])end,function()local _,n=cyc(WHEEL.SM,sI)sI=n end)
row(fA,"Part",function()return WHEEL.PART[pI]end,function()local _,n=cyc(WHEEL.PART,pI)pI=n end)
row(fA,"Max dist",function()return WHEEL.DIST[dI]end,function()local _,n=cyc(WHEEL.DIST,dI)dI=n end)
row(fA,"Target mode",function()return WHEEL.MODE[mI]end,function()local _,n=cyc(WHEEL.MODE,mI)mI=n end)
row(fA,"Visible check",function()return A_VIS and"ON"or"OFF"end,function()A_VIS=not A_VIS end)
row(fA,"Team check",function()return A_TEAM and"ON"or"OFF"end,function()A_TEAM=not A_TEAM end)
row(fA,"Rotate char",function()return A_ROT and"ON"or"OFF"end,function()A_ROT=not A_ROT end)
row(fA,"FOV circle",function()return A_CIRC and"ON"or"OFF"end,function()A_CIRC=not A_CIRC end)

row(fE,"Highlight",function()return E_HL and"ON"or"OFF"end,function()E_HL=not E_HL end)
row(fE,"Name",function()return E_NAME and"ON"or"OFF"end,function()E_NAME=not E_NAME end)
row(fE,"Health",function()return E_HP and"ON"or"OFF"end,function()E_HP=not E_HP end)
row(fE,"Distance",function()return E_DIST and"ON"or"OFF"end,function()E_DIST=not E_DIST end)
row(fE,"Team check",function()return E_TEAM and"ON"or"OFF"end,function()E_TEAM=not E_TEAM end)
row(fE,"Text size",function()return WHEEL.TSIZE[tI]end,function()local _,n=cyc(WHEEL.TSIZE,tI)tI=n end)
row(fE,"Max dist",function()return WHEEL.EDIST[edI]end,function()local _,n=cyc(WHEEL.EDIST,edI)edI=n end)

row(fT,"Mode hold",function()return WHEEL.THOLD[thI]end,function()local _,n=cyc(WHEEL.THOLD,thI)thI=n end)
row(fT,"Delay ms",function()return WHEEL.DELAY[dlI]end,function()local _,n=cyc(WHEEL.DELAY,dlI)dlI=n end)
row(fT,"Part",function()return WHEEL.TPART[tpI]end,function()local _,n=cyc(WHEEL.TPART,tpI)tpI=n end)
row(fT,"FOV",function()return WHEEL.TFOV[tfI].."deg"end,function()local _,n=cyc(WHEEL.TFOV,tfI)tfI=n end)
row(fT,"Visible check",function()return T_VIS and"ON"or"OFF"end,function()T_VIS=not T_VIS end)
row(fT,"Team check",function()return T_TEAM and"ON"or"OFF"end,function()T_TEAM=not T_TEAM end)
row(fT,"Auto fire",function()return T_AUTO and"ON"or"OFF"end,function()T_AUTO=not T_AUTO end)

local circle=hasD and Dr.new("Circle") or nil
if circle then
 circle.Thickness=1.5 circle.Filled=false circle.Color=Color3.fromRGB(0,255,120)
 circle.Transparency=.6 circle.NumSides=60 circle.Visible=false
end

local function keyDown(name)
 if name=="Always"then return true end
 if name=="Mouse1"then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)end
 if name=="Mouse2"then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)end
 if name=="E"then return UIS:IsKeyDown(Enum.KeyCode.E)end
 if name=="LeftAlt"then return UIS:IsKeyDown(Enum.KeyCode.LeftAlt)end
 return false
end
local function pickPart(ch,sel)
 if not ch then return nil end
 if sel~="Any"then
  local n=ch:FindFirstChild(sel)
  if n and n:IsA("BasePart")then return n end
 end
 local h=ch:FindFirstChild("Head")
 if h and h:IsA("BasePart")then return h end
 local r=ch:FindFirstChild("HumanoidRootPart")
 if r and r:IsA("BasePart")then return r end
 local up=ch:FindFirstChild("UpperTorso")
 if up and up:IsA("BasePart")then return up end
 for _,d in ipairs(ch:GetDescendants())do
  if d:IsA("BasePart")then return d end
 end
 return nil
end
local function isEnemy(plr,tc)
 if not plr then return true end
 return plr~=P and not(tc and plr.Team and P.Team and plr.Team==P.Team)
end
local function alive(t)
 if t.hum then return t.hum.Health>0 end
 return true
end
local function visible(o,pospart)
 local pr=RaycastParams.new()pr.FilterType=Enum.RaycastFilterType.Exclude
 local ig={P.Character}
 local deb=workspace:FindFirstChild("Debris")
 if deb then ig[#ig+1]=deb end
 if LOCK and LOCK.ch and LOCK.ch.Parent then ig[#ig+1]=LOCK.ch end
 pr.FilterDescendantsInstances=ig
 local hit=workspace:Raycast(o,pospart.Position-o,pr)
 return not hit or hit.Instance:IsDescendantOf(pospart.Parent)or hit.Instance==pospart
end
local function ang(l,p)local o=cam.CFrame.Position local d=p-o
 if d.Magnitude<.001 then return 180 end
 return math.deg(math.acos(math.clamp(d.Unit:Dot(l),-1,1)))end

local function isRig(m)
 if not m:IsA("Model")then return false end
 local h=m:FindFirstChild("Head")
 local r=m:FindFirstChild("HumanoidRootPart")
 return (h~=nil and h:IsA("BasePart"))and(r~=nil)
end
local function scanRigs()
 local list={}
 local function walk(node,depth)
  if depth>4 or #list>400 then return end
  for _,c in ipairs(node:GetChildren())do
   local nm=c.Name
   if c:IsA("Model")then
    if not string.find(nm,"Ragdoll")then
     if c~=P.Character and isRig(c)then
      list[#list+1]=c
     else
      walk(c,depth+1)
     end
    end
   elseif (c:IsA("Folder")or c:IsA("Workspace"))and nm~="Debris"then
    walk(c,depth+1)
   end
  end
 end
 pcall(function()walk(workspace,0)end)
 return list
end

task.spawn(function()
 while true do
  local list={}
  local seen={}
  local function add(ch,plr)
   if not ch or ch==P.Character or seen[ch]then return end
   if not(ch:FindFirstChild("Head")or ch:FindFirstChild("HumanoidRootPart")or ch:FindFirstChildOfClass("Humanoid"))then return end
   seen[ch]=true
   list[#list+1]={ch=ch,hum=ch:FindFirstChildOfClass("Humanoid"),plr=plr}
  end
  local cf=workspace:FindFirstChild("Characters")
  if cf then
   for _,m in ipairs(cf:GetChildren())do
    if m:IsA("Model")and isRig(m)then
     local pl=game.Players:FindFirstChild(m.Name)or game.Players:GetPlayerFromCharacter(m)
     if pl~=P then add(m,pl)end
    end
   end
  end
  for _,pl in ipairs(game.Players:GetPlayers())do
   if pl~=P then add(pl.Character,pl)end
  end
  for _,m in ipairs(npcRigs)do
   if m.Parent then
    local pl=game.Players:GetPlayerFromCharacter(m)or game.Players:FindFirstChild(m.Name)
    if pl~=P then add(m,pl)end
   end
  end
  TARGETS=list
  task.wait(.15)
 end
end)
task.spawn(function()
 while true do
  pcall(function()npcRigs=scanRigs()end)
  task.wait(1.2)
 end
end)

RS:BindToRenderStep("NaAim",Enum.RenderPriority.Last.Value,function()
 if not AIM then LOCK=nil return end
 if not keyDown(WHEEL.HOLD[hI])then LOCK=nil return end
 local look=cam.CFrame.LookVector
 local fov=WHEEL.FOV[fI]local maxd=WHEEL.DIST[dI]
 local o=cam.CFrame.Position
 local tgt=nil
 if LOCK then
  local pp=LOCK.pt
  if pp and pp.Parent and alive(LOCK)and (pp.Position-o).Magnitude<=maxd and(not A_VIS or visible(o,pp))then
   tgt=LOCK
  else LOCK=nil end
 end
 if not tgt then
  local bs=1e9
  for _,t in ipairs(TARGETS)do
   if isEnemy(t.plr,A_TEAM)and alive(t)then
    local pp=pickPart(t.ch,WHEEL.PART[pI])
    if pp and (pp.Position-o).Magnitude<=maxd and ang(look,pp.Position)<=fov and(not A_VIS or visible(o,pp))then
     local sc
     if WHEEL.MODE[mI]=="Crosshair"then sc=ang(look,pp.Position)+(pp.Position-o).Magnitude*.005
     elseif WHEEL.MODE[mI]=="Distance"then sc=(pp.Position-o).Magnitude
     else sc=t.hum and t.hum.Health or 1e9 end
     if sc<bs then bs=sc tgt={ch=t.ch,hum=t.hum,plr=t.plr,pt=pp}end
    end
   end
  end
  LOCK=tgt
 end
 if not tgt then return end
 local pp=tgt.pt if not pp or not pp.Parent then return end
 local locked=UIS.MouseBehavior==Enum.MouseBehavior.LockCenter or UIS.MouseBehavior==Enum.MouseBehavior.LockCurrentPosition
 if locked and hasMouseMove then
  local sp,on=cam:WorldToViewportPoint(pp.Position)
  if on then
   local vs=cam.ViewportSize
   local dx=sp.X-vs.X/2 local dy=sp.Y-vs.Y/2
   local mag=math.sqrt(dx*dx+dy*dy)
   if mag>1.5 then
    local k=(1-WHEEL.SM[sI])*.4
    local mx,my=dx*k,dy*k
    local m2=math.sqrt(mx*mx+my*my)
    local cap=math.max(4,math.min(vs.X,vs.Y)*.02)
    if m2>cap then local s=cap/m2 mx,my=mx*s,my*s end
    mousemoverel(mx,my)
   end
  end
 else
  local goal=CFrame.lookAt(o,pp.Position)
  if WHEEL.SM[sI]==0 then cam.CFrame=goal else cam.CFrame=cam.CFrame:Lerp(goal,math.clamp(1-WHEEL.SM[sI],.05,1))end
 end
 if A_ROT then
  local r=P.Character and P.Character:FindFirstChild("HumanoidRootPart")
  local h=P.Character and P.Character:FindFirstChildOfClass("Humanoid")
  if r and h then
   h.AutoRotate=false
   local f=Vector3.new(pp.Position.X-r.Position.X,0,pp.Position.Z-r.Position.Z)
   if f.Magnitude>.1 then r.CFrame=CFrame.lookAt(r.Position,r.Position+f)end
  end
 end
end)

local function fire()
 if hasM1 then pcall(mouse1click)
 else local t=P.Character and P.Character:FindFirstChildWhichIsA("Tool")if t then pcall(function()t:Activate()end)end end
end
local function fovPix(deg)
 local vs=cam.ViewportSize
 return (math.tan(math.rad(deg))/math.tan(math.rad(cam.FieldOfView*.5)))*(vs.Y/2)
end
task.spawn(function()
 local t0=0
 while true do
  local dt=task.wait()
  if TRIG and keyDown(WHEEL.THOLD[thI])then
   local o=cam.CFrame.Position
   local vs=cam.ViewportSize
   local rpix=fovPix(WHEEL.TFOV[tfI])
   local found=false
   for _,t in ipairs(TARGETS)do
    if isEnemy(t.plr,T_TEAM)and alive(t)then
     local pp=pickPart(t.ch,WHEEL.TPART[tpI])
     if pp then
      local sp,on=cam:WorldToViewportPoint(pp.Position)
      if on and (Vector2.new(sp.X-vs.X/2,sp.Y-vs.Y/2)).Magnitude<=rpix and(not T_VIS or visible(o,pp))then
       found=true break
      end
     end
    end
   end
   if found then
    t0=t0+dt
    if t0>=WHEEL.DELAY[dlI]/1000 and(tick()-lastFire)>.1 then
     if T_AUTO then fire()end
     lastFire=tick()t0=0
    end
   else t0=0 end
  else t0=0 end
 end
end)

local esp={}
local function ensureESP(model)
 local e=esp[model]
 if not e then e={}esp[model]=e end
 if not e.hl or e.hl.Parent~=model then
  if e.hl then e.hl:Destroy()end
  local hl=Instance.new("Highlight")hl.Name="NaHL"hl.Parent=model
  hl.FillTransparency=.6 hl.OutlineTransparency=0
  pcall(function()hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop end)
  e.hl=hl
 end
 if not e.bg or not e.bg.Parent then
  if e.bg then e.bg:Destroy()end
  local bg=Instance.new("BillboardGui")bg.Name="NaESP"
  bg.Size=UDim2.fromOffset(150,48)bg.StudsOffset=Vector3.new(0,3,0)
  bg.AlwaysOnTop=true bg.ResetOnSpawn=false
  pcall(function()bg.MaxDistance=100000 end)
  local tx=Instance.new("TextLabel")tx.Size=UDim2.fromScale(1,1)tx.BackgroundTransparency=1
  tx.Font=Enum.Font.GothamBold tx.TextScaled=true tx.TextColor3=Color3.new(1,1,1)
  tx.TextStrokeTransparency=0 tx.TextStrokeColor3=Color3.new(0,0,0)tx.Text=""
  tx.Parent=bg
  e.bg=bg e.txt=tx
 end
 return e
end
local function wipeESP()
 for m,e in pairs(esp)do
  if e.hl then e.hl:Destroy()end
  if e.bg then e.bg:Destroy()end
  esp[m]=nil
 end
end
local wtick=0
RS.RenderStepped:Connect(function()
 if circle then
  if AIM and A_CIRC then
   local vs=cam.ViewportSize
   local r=(math.tan(math.rad(WHEEL.FOV[fI]))/math.tan(math.rad(cam.FieldOfView*.5)))*(vs.Y/2)
   circle.Position=Vector2.new(vs.X/2,vs.Y/2)circle.Radius=math.clamp(r,5,vs.Y)circle.Visible=true
  else circle.Visible=false end
 end
 if not ESP then return end
 local o=cam.CFrame.Position
 local maxd=WHEEL.EDIST[edI]
 for _,t in ipairs(TARGETS)do
  local ok=true
  if t.plr==P then ok=false end
  if ok and E_TEAM and t.plr and t.plr.Team and P.Team and t.plr.Team==P.Team then ok=false end
  if ok and not alive(t)then ok=false end
  local pp=pickPart(t.ch,"Head")
  if ok and not pp then ok=false end
  if ok and (pp.Position-o).Magnitude>maxd then ok=false end
  local e=ensureESP(t.ch)
  if ok then
   local col=(t.plr and P.Team and t.plr.Team and t.plr.Team==P.Team)and Color3.fromRGB(0,255,90)or Color3.fromRGB(255,60,60)
   if e.hl then
    e.hl.Enabled=E_HL e.hl.FillColor=col e.hl.OutlineColor=col
   end
   if e.bg and pp then
    if e.bg.Parent~=pp then e.bg.Parent=pp end
    e.bg.Enabled=true
    local nm=t.plr and t.plr.DisplayName or t.ch.Name
    local parts={}
    if E_NAME then parts[#parts+1]=nm end
    if E_HP then parts[#parts+1]="HP "..(t.hum and math.floor(t.hum.Health)or"?")end
    if E_DIST then parts[#parts+1]=math.floor((pp.Position-o).Magnitude).."m" end
    e.txt.Text=table.concat(parts,"  ")
    e.txt.TextSize=WHEEL.TSIZE[tI]
    e.txt.TextColor3=col
   end
  else
   if e.hl then e.hl.Enabled=false end
   if e.bg then e.bg.Enabled=false end
  end
 end
 wtick=wtick+1
 if wtick%180==0 then
  for m,e in pairs(esp)do
   if not m.Parent then
    if e.hl then e.hl:Destroy()end
    if e.bg then e.bg:Destroy()end
    esp[m]=nil
   end
  end
  dbgUpd()
 end
end)

local function setAim(v)
 AIM=v aimBtn.Text="AIM: "..(v and"ON"or"OFF")
 aimBtn.BackgroundColor3=v and Color3.fromRGB(160,0,60)or Color3.fromRGB(38,38,42)
 if not v then LOCK=nil local h=P.Character and P.Character:FindFirstChildOfClass("Humanoid")if h then h.AutoRotate=true end end
 clicks.aim=clicks.aim+1 dbgUpd()
end
local function setEsp(v)
 ESP=v espBtn.Text="ESP: "..(v and"ON"or"OFF")
 espBtn.BackgroundColor3=v and Color3.fromRGB(0,140,70)or Color3.fromRGB(38,38,42)
 if not v then wipeESP()end
 clicks.esp=clicks.esp+1 dbgUpd()
end
local function setTrig(v)
 TRIG=v trigBtn.Text="TRIG: "..(v and"ON"or"OFF")
 trigBtn.BackgroundColor3=v and Color3.fromRGB(200,120,0)or Color3.fromRGB(38,38,42)
 clicks.trig=clicks.trig+1 dbgUpd()
end
aimBtn.MouseButton1Click:Connect(function()setAim(not AIM)end)
espBtn.MouseButton1Click:Connect(function()setEsp(not ESP)end)
trigBtn.MouseButton1Click:Connect(function()setTrig(not TRIG)end)
sbtn.MouseButton1Click:Connect(function()pnl.Visible=not pnl.Visible end)
sbtn.MouseButton2Click:Connect(function()pnl.Visible=not pnl.Visible end)
UIS.InputBegan:Connect(function(i)
 if i.KeyCode==Enum.KeyCode.T then setAim(not AIM)end
 if i.KeyCode==Enum.KeyCode.Y then setEsp(not ESP)end
 if i.KeyCode==Enum.KeyCode.U then setTrig(not TRIG)end
 if i.KeyCode==Enum.KeyCode.RightControl then pnl.Visible=not pnl.Visible end
end)
end

local ok,err=xpcall(boot,function(e)return tostring(e)end)
if not ok then
 local pg=game.Players.LocalPlayer:WaitForChild("PlayerGui")
 local sg=Instance.new("ScreenGui")sg.Name="CrashError"sg.ResetOnSpawn=false sg.DisplayOrder=10000000 sg.Parent=pg
 local f=Instance.new("TextLabel")f.Size=UDim2.fromScale(.9,.4)f.Position=UDim2.fromScale(.05,.3)
 f.BackgroundColor3=Color3.new(0,0,0)f.BackgroundTransparency=.25 f.TextColor3=Color3.fromRGB(255,90,90)
 f.TextScaled=true f.TextWrapped=true f.Font=Enum.Font.Code
 f.Text="SCRIPT ERROR (покажи это):\n"..err f.Parent=sg
end
