local P=game.Players.LocalPlayer
local function boot()
local RS=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local cam=workspace.CurrentCamera
local PGUI=P:WaitForChild("PlayerGui")

for _,g in ipairs(PGUI:GetChildren())do
 if g.Name=="CombatGui"or g.Name=="CrashError"then g:Destroy()end
end
pcall(function()RS:UnbindFromRenderStep("NaAim")end)
pcall(function()RS:UnbindFromRenderStep("AIM")end)

local okD,Dr=pcall(function()return Drawing end)
local hasD=okD and Dr~=nil and Dr.new~=nil
local function dnew(k)if hasD then return Dr.new(k)end return nil end

local LOCK=nil
local lastFire=0
local AIM,ESP,TRIG=false,false,false
local clicks={aim=0,esp=0,trig=0}
local WHEEL={}
local function cyc(list,i)return list[i%#list+1],(i%#list)+1 end
WHEEL.HOLD={"Always","Mouse1","Mouse2","E","LeftAlt"}local hI=1
WHEEL.FOV={30,60,90,120,180,270,360}local fI=4
WHEEL.SM={0,0.05,0.1,0.2,0.3,0.4,0.6,0.8}local sI=3
WHEEL.PART={"Head","UpperTorso","HumanoidRootPart"}local pI=1
WHEEL.DIST={200,500,1000,2000,5000}local dI=3
WHEEL.MODE={"Crosshair","Distance","Health"}local mI=1
WHEEL.TSIZE={12,14,16,18,20}local tI=3
WHEEL.EDIST={200,500,1000,2000,5000}local edI=2
WHEEL.THOLD={"Always","Mouse1","Mouse2"}local thI=1
WHEEL.DELAY={0,25,50,75,100,150,250}local dlI=3
WHEEL.TFOV={1,2,3,5,8,12}local tfI=2
WHEEL.TPART={"Head","UpperTorso","HumanoidRootPart"}local tpI=1
local A_VIS,A_TEAM,A_ROT,A_CIRC=true,true,true,true
local E_BOX,E_NAME,E_HP,E_DIST,E_TEAM=true,true,true,true,true
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
local dbg=Instance.new("TextLabel")dbg.Size=UDim2.fromOffset(420,16)dbg.Position=UDim2.new(0,6,1,-20)
dbg.BackgroundTransparency=1 dbg.TextXAlignment=Enum.TextXAlignment.Left
dbg.TextColor3=Color3.fromRGB(255,220,0)dbg.Font=Enum.Font.Code dbg.TextSize=12 dbg.Parent=sg
local function dbgUpd()dbg.Text=string.format("[Drawing=%s] aim=%d esp=%d trig=%d",hasD and"OK"or"NONE",clicks.aim,clicks.esp,clicks.trig)end
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
 local y=6+counts[folder]*26
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

row(fE,"Box",function()return E_BOX and"ON"or"OFF"end,function()E_BOX=not E_BOX end)
row(fE,"Name",function()return E_NAME and"ON"or"OFF"end,function()E_NAME=not E_NAME end)
row(fE,"HP bar",function()return E_HP and"ON"or"OFF"end,function()E_HP=not E_HP end)
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

local circle=dnew("Circle")
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
local function isEnemy(plr,tc)return plr~=P and not(tc and plr.Team and P.Team and plr.Team==P.Team)end
local function partOf(ch,part)return ch and(ch:FindFirstChild(part)or ch:FindFirstChild("Head")or ch:FindFirstChild("HumanoidRootPart"))end
local function visible(o,t)
 local pr=RaycastParams.new()pr.FilterType=Enum.RaycastFilterType.Exclude
 pr.FilterDescendantsInstances={P.Character}
 local hit=workspace:Raycast(o,t.Position-o,pr)
 return not hit or hit.Instance==t or hit.Instance:IsDescendantOf(t.Parent)
end
local function ang(o,l,p)local d=p-o if d.Magnitude<.001 then return 180 end
 return math.deg(math.acos(math.clamp(d.Unit:Dot(l),-1,1)))end

RS:BindToRenderStep("NaAim",Enum.RenderPriority.Last.Value,function()
 if not AIM then LOCK=nil return end
 if not keyDown(WHEEL.HOLD[hI])then LOCK=nil return end
 local o,l=cam.CFrame.Position,cam.CFrame.LookVector
 local fov=WHEEL.FOV[fI]local maxd=WHEEL.DIST[dI]
 local t=LOCK and partOf(LOCK.Character,WHEEL.PART[pI])
 if not t or (t.Position-o).Magnitude>maxd or(A_VIS and not visible(o,t))then
  t=nil LOCK=nil
  local bs=1e9
  for _,p in ipairs(game.Players:GetPlayers())do
   if isEnemy(p,A_TEAM)then
    local ch=p.Character
    local hum=ch and ch:FindFirstChildOfClass("Humanoid")
    local h=partOf(ch,WHEEL.PART[pI])
    if h and hum and hum.Health>0 and (h.Position-o).Magnitude<=maxd and ang(o,l,h.Position)<=fov and(not A_VIS or visible(o,h))then
     local score
     if WHEEL.MODE[mI]=="Crosshair"then score=ang(o,l,h.Position)+(h.Position-o).Magnitude*.005
     elseif WHEEL.MODE[mI]=="Distance"then score=(h.Position-o).Magnitude
     else score=hum.Health end
     if score<bs then bs=score t=h LOCK=p end
    end
   end
  end
 end
 if not t then return end
 local goal=CFrame.lookAt(o,t.Position)
 if WHEEL.SM[sI]==0 then cam.CFrame=goal else cam.CFrame=cam.CFrame:Lerp(goal,math.clamp(1-WHEEL.SM[sI],0.05,1))end
 if A_ROT then
  local r=P.Character and P.Character:FindFirstChild("HumanoidRootPart")
  local h=P.Character and P.Character:FindFirstChildOfClass("Humanoid")
  if r and h then
   h.AutoRotate=false
   local f=Vector3.new(t.Position.X-r.Position.X,0,t.Position.Z-r.Position.Z)
   if f.Magnitude>.1 then r.CFrame=CFrame.lookAt(r.Position,r.Position+f)end
  end
 end
end)

local function fire()
 if mouse1click then pcall(mouse1click)
 else local t=P.Character and P.Character:FindFirstChildWhichIsA("Tool")if t then pcall(function()t:Activate()end)end end
end

task.spawn(function()
 local t0=0
 while true do
  local dt=task.wait()
  if TRIG and keyDown(WHEEL.THOLD[thI])then
   local o,l=cam.CFrame.Position,cam.CFrame.LookVector
   local found=false
   for _,p in ipairs(game.Players:GetPlayers())do
    if isEnemy(p,T_TEAM)then
     local ch=p.Character
     local hum=ch and ch:FindFirstChildOfClass("Humanoid")
     local h=partOf(ch,WHEEL.TPART[tpI])
     if h and hum and hum.Health>0 and ang(o,l,h.Position)<=WHEEL.TFOV[tfI]and(not T_VIS or visible(o,h))then
      found=true break
     end
    end
   end
   if found then
    t0=t0+dt
    if t0>=WHEEL.DELAY[dlI]/1000 and(tick()-lastFire)>0.1 then
     if T_AUTO then fire()end
     lastFire=tick()t0=0
    end
   else t0=0 end
  else t0=0 end
 end
end)

local esp={}
local function create()
 if not hasD then return nil end
 local d={}
 d.box=Dr.new("Square")d.box.Thickness=1.5 d.box.Filled=false d.box.Transparency=1
 d.name=Dr.new("Text")d.name.Center=true d.name.Outline=true d.name.OutlineColor=Color3.new(0,0,0)d.name.Transparency=1
 d.hpbg=Dr.new("Square")d.hpbg.Filled=true d.hpbg.Color=Color3.new(0,0,0)d.hpbg.Transparency=.5
 d.hp=Dr.new("Square")d.hp.Filled=true d.hp.Color=Color3.fromRGB(0,255,0)d.hp.Transparency=1
 d.dist=Dr.new("Text")d.dist.Center=true d.dist.Outline=true d.dist.OutlineColor=Color3.new(0,0,0)d.dist.Transparency=1
 return d
end
local function hide(d)if not d then return end d.box.Visible=false d.name.Visible=false d.hpbg.Visible=false d.hp.Visible=false d.dist.Visible=false end
local function getD(plr)if not hasD then return nil end if not esp[plr]then esp[plr]=create()end return esp[plr]end
RS.RenderStepped:Connect(function()
 local vs=cam.ViewportSize
 if circle then
  if AIM and A_CIRC then
   local r=(math.tan(math.rad(WHEEL.FOV[fI]))/math.tan(math.rad(cam.FieldOfView*0.5)))*(vs.Y/2)
   circle.Position=Vector2.new(vs.X/2,vs.Y/2)circle.Radius=math.clamp(r,5,vs.Y)circle.Visible=true
  else circle.Visible=false end
 end
 if not ESP or not hasD then return end
 local maxd=WHEEL.EDIST[edI]
 for _,plr in ipairs(game.Players:GetPlayers())do
  if plr~=P then
   local d=getD(plr)
   if d then
    local ch=plr.Character
    local hum=ch and ch:FindFirstChildOfClass("Humanoid")
    local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
    local head=ch and ch:FindFirstChild("Head")
    if not(hum and hrp and head and hum.Health>0)then hide(d)continue end
    if E_TEAM and plr.Team and P.Team and plr.Team==P.Team then hide(d)continue end
    if (hrp.Position-cam.CFrame.Position).Magnitude>maxd then hide(d)continue end
    local top,on1=cam:WorldToViewportPoint(head.Position+Vector3.new(0,0.8,0))
    local bot,on2=cam:WorldToViewportPoint(hrp.Position-Vector3.new(0,3,0))
    if not on1 and not on2 then hide(d)continue end
    local hgt=math.abs(bot.Y-top.Y)local w=hgt*0.55
    local x=top.X-w/2 local y=top.Y
    local col=(P.Team and plr.Team and plr.Team==P.Team)and Color3.fromRGB(0,255,90)or Color3.fromRGB(255,60,60)
    d.box.Visible=E_BOX d.box.Color=col d.box.Position=Vector2.new(x,y)d.box.Size=Vector2.new(w,hgt)
    d.name.Visible=E_NAME d.name.Text=plr.DisplayName d.name.Color=col d.name.Size=WHEEL.TSIZE[tI]d.name.Position=Vector2.new(top.X,y-19)
    d.dist.Visible=E_DIST d.dist.Text=string.format("%dm",math.floor((hrp.Position-cam.CFrame.Position).Magnitude))
    d.dist.Color=col d.dist.Size=WHEEL.TSIZE[tI]-2 d.dist.Position=Vector2.new(top.X,y+hgt+3)
    local frac=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
    d.hpbg.Visible=E_HP d.hpbg.Position=Vector2.new(x-8,y)d.hpbg.Size=Vector2.new(4,hgt)
    d.hp.Visible=E_HP d.hp.Color=Color3.fromRGB(255,0,0):Lerp(Color3.fromRGB(0,255,0),frac)
    d.hp.Position=Vector2.new(x-8,y+hgt*(1-frac))d.hp.Size=Vector2.new(4,hgt*frac)
   end
  end
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
 if not v then for _,d in pairs(esp)do hide(d)end end
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
