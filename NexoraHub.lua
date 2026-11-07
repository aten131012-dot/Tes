--[[
 NEXORA HUB v2  (ไฟล์เดียวรวมทุกส่วน)
 แก้ค่าตั้งต้นได้ที่ CFG ด้านล่าง โดยเฉพาะ DISCORD_LINK
]]
local CFG={
 LOGO_ID="89636151751928",
 LOGO_DARK=Color3.fromRGB(165,165,165), -- ยิ่งเลขน้อยยิ่งเข้ม (255=สีเดิม)
 DISCORD_ICON_ID="17056354182",
 DISCORD_LINK="https://discord.gg/YOUR_INVITE", -- <<< ใส่ลิงก์ดิสคอสของคุณตรงนี้
 NAME="NEXORA HUB",
 SETTINGS_FILE="NexoraHub_Settings_v2.json",
}

local Players=game:GetService("Players")
local TS=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local RS=game:GetService("RunService")
local LIN=Enum.EasingStyle.Linear
local SINE=Enum.EasingStyle.Sine
local IO=Enum.EasingDirection.InOut

local COL={
 Bg=Color3.fromRGB(8,6,20),
 Side=Color3.fromRGB(26,18,52),
 Chip=Color3.fromRGB(34,24,68),
 Purple=Color3.fromRGB(140,80,255),
 Pink=Color3.fromRGB(215,125,255),
 Text=Color3.fromRGB(242,235,255),
 Sub=Color3.fromRGB(165,150,200),
 Red=Color3.fromRGB(255,80,110),
 Green=Color3.fromRGB(90,230,160),
}
local function make(c,p,par)
 local o=Instance.new(c)
 for k,v in pairs(p) do o[k]=v end
 o.Parent=par
 return o
end
local function round(o,r) return make("UICorner",{CornerRadius=UDim.new(0,r)},o) end

-- โหลดรูปจากไอดี: แข่งโหลดหลายแหล่งพร้อมกัน ใครเสร็จก่อนใช้อันนั้น (เร็วขึ้นมาก)
local CP=game:GetService("ContentProvider")
local imgCache={}
local function resolveImg(id)
 if imgCache[id] then return imgCache[id] end
 local c={}
 imgCache[id]=c
 for _,u in ipairs({"rbxassetid://"..id,"rbxthumb://type=Asset&id="..id.."&w=420&h=420"}) do
  task.spawn(function()
   local p=Instance.new("ImageLabel")
   p.Image=u
   pcall(function() CP:PreloadAsync({p}) end)
   if not c.url and p.IsLoaded then c.url=u end
   p:Destroy()
  end)
 end
 return c
end
local function setImg(o,id)
 local c=resolveImg(id)
 o.Image=c.url or ("rbxassetid://"..id)
 if c.url then return end
 task.spawn(function()
  local t=0
  while not c.url and t<8 do task.wait(.05) t+=.05 end
  if c.url then o.Image=c.url end
 end)
end
-- เริ่มโหลดรูปทันทีตั้งแต่บรรทัดแรก ก่อนสร้าง GUI
resolveImg(CFG.LOGO_ID)
resolveImg(CFG.DISCORD_ICON_ID)

-- ระบบเปลี่ยนสีธีม
local accents={}
local function onAccent(fn) accents[#accents+1]=fn fn(COL.Purple,COL.Pink) end
local function setAccent(a,b) COL.Purple=a COL.Pink=b for _,fn in ipairs(accents) do fn(a,b) end end
local function glow(o,t)
 local s=make("UIStroke",{Thickness=t or 1.5,Color=Color3.new(1,1,1),ApplyStrokeMode=Enum.ApplyStrokeMode.Border},o)
 local g=make("UIGradient",{},s)
 onAccent(function(a,b) g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,a),ColorSequenceKeypoint.new(.5,b),ColorSequenceKeypoint.new(1,a)}) end)
 TS:Create(g,TweenInfo.new(4,LIN,Enum.EasingDirection.In,-1),{Rotation=360}):Play()
 return s
end

local parent=(gethui and gethui()) or game:GetService("CoreGui")
if parent:FindFirstChild("NexoraHubUI") then parent.NexoraHubUI:Destroy() end
if parent:FindFirstChild("NexoraLoading") then parent.NexoraLoading:Destroy() end

-- อ่านภาษาที่บันทึกไว้ (ไว้ใช้กับหน้าโหลด)
local savedLang="TH"
pcall(function()
 if isfile and isfile(CFG.SETTINGS_FILE) then
  local d=game:GetService("HttpService"):JSONDecode(readfile(CFG.SETTINGS_FILE))
  if d.lang=="EN" or d.lang=="TH" then savedLang=d.lang end
 end
end)

------------------------------------------------------------------
-- หน้าโหลด
------------------------------------------------------------------
local Loader={ready=false,done=false}
function Loader.finish(cb) Loader.cb=cb Loader.ready=true end
do
 local TH=(savedLang=="TH")
 local cam=workspace.CurrentCamera
 local vp=cam and cam.ViewportSize or Vector2.new(800,500)
 local kk=math.clamp(math.min(vp.X/820,vp.Y/520),.6,1.15)
 local CY=.42
 local ld=make("ScreenGui",{Name="NexoraLoading",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=999999,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},parent)
 pcall(function() ld.ScreenInsets=Enum.ScreenInsets.None end)
 local root=make("CanvasGroup",{Position=UDim2.fromScale(0,0),Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0},ld)
 local bgl=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Active=true},root)
 make("UIGradient",{Color=ColorSequence.new(Color3.fromRGB(30,14,66),Color3.fromRGB(3,2,10)),Rotation=90},bgl)

 -- เนบิวลา
 local function neb(x,y,s,col,dx,dy,t)
  local h=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(x,y),Size=UDim2.fromOffset(s,s),BackgroundTransparency=1},root)
  for i=1,4 do
   local k=1-(i-1)*.2
   local f=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(k,k),BackgroundColor3=col,BackgroundTransparency=.93,BorderSizePixel=0},h)
   make("UICorner",{CornerRadius=UDim.new(.5,0)},f)
  end
  TS:Create(h,TweenInfo.new(t,SINE,IO,-1,true),{Position=UDim2.fromScale(x+dx,y+dy)}):Play()
 end
 neb(.2,.25,520,Color3.fromRGB(110,50,210),.06,.08,8)
 neb(.8,.75,560,Color3.fromRGB(40,80,220),-.07,-.06,10)
 neb(.75,.15,380,Color3.fromRGB(220,70,190),-.05,.08,7)

 -- ดาว
 for i=1,90 do
  local sz=math.random(1,3)
  local s=make("Frame",{Position=UDim2.fromScale(math.random(),math.random()),Size=UDim2.fromOffset(sz,sz),BackgroundColor3=(math.random()<.3) and COL.Pink or Color3.new(1,1,1),BackgroundTransparency=math.random(30,70)/100,BorderSizePixel=0},root)
  make("UICorner",{CornerRadius=UDim.new(.5,0)},s)
  TS:Create(s,TweenInfo.new(math.random(8,25)/10,SINE,IO,-1,true),{BackgroundTransparency=.95}):Play()
 end

 -- ลำแสงหมุนด้านหลัง
 local rayHold=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,CY),Size=UDim2.fromOffset(10,10),BackgroundTransparency=1},root)
 for i=1,12 do
  local r=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset((i%2==0) and 3 or 2,1800),BackgroundColor3=(i%2==0) and COL.Pink or COL.Purple,BorderSizePixel=0,Rotation=i*15},rayHold)
  make("UIGradient",{Rotation=90,Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.5,.8),NumberSequenceKeypoint.new(1,1)})},r)
 end
 TS:Create(rayHold,TweenInfo.new(20,LIN,Enum.EasingDirection.In,-1),{Rotation=360}):Play()

 -- อนุภาคลอยขึ้น
 task.spawn(function()
  while ld.Parent do
   local sz=math.random(2,4)
   local x=math.random()
   local p=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(x,0,1,10),Size=UDim2.fromOffset(sz,sz),BackgroundColor3=(math.random()<.5) and COL.Pink or Color3.new(1,1,1),BackgroundTransparency=.3,BorderSizePixel=0},root)
   make("UICorner",{CornerRadius=UDim.new(.5,0)},p)
   local dur=math.random(30,60)/10
   TS:Create(p,TweenInfo.new(dur,LIN),{Position=UDim2.new(math.clamp(x+(math.random()-.5)*.1,0,1),0,-.05,0),BackgroundTransparency=1}):Play()
   task.delay(dur+.1,function() p:Destroy() end)
   task.wait(.1)
  end
 end)

 -- มุมกรอบ HUD
 local function bracket(ax,ay)
  local f=make("Frame",{AnchorPoint=Vector2.new(ax,ay),Position=UDim2.new(ax,(ax==0) and 20 or -20,ay,(ay==0) and 20 or -20),Size=UDim2.fromOffset(34,34),BackgroundTransparency=1,ZIndex=3},root)
  make("Frame",{AnchorPoint=Vector2.new(ax,ay),Position=UDim2.fromScale(ax,ay),Size=UDim2.new(1,0,0,2),BackgroundColor3=COL.Pink,BorderSizePixel=0},f)
  make("Frame",{AnchorPoint=Vector2.new(ax,ay),Position=UDim2.fromScale(ax,ay),Size=UDim2.new(0,2,1,0),BackgroundColor3=COL.Pink,BorderSizePixel=0},f)
  TS:Create(f,TweenInfo.new(1.2,SINE,IO,-1,true),{BackgroundTransparency=1}):Play()
 end
 bracket(0,0) bracket(1,0) bracket(0,1) bracket(1,1)

 -- กลุ่มกลาง
 local ctr=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,CY),Size=UDim2.fromOffset(340,340),BackgroundTransparency=1,ZIndex=5},root)
 local csc=make("UIScale",{Scale=kk},ctr)
 for i=1,4 do
  local sz=150+i*38
  local h=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(sz,sz),BackgroundColor3=(i%2==0) and COL.Pink or COL.Purple,BackgroundTransparency=.9},ctr)
  make("UICorner",{CornerRadius=UDim.new(.5,0)},h)
  TS:Create(h,TweenInfo.new(1.4+i*.25,SINE,IO,-1,true),{Size=UDim2.fromOffset(sz+30,sz+30),BackgroundTransparency=.96}):Play()
 end
 local function ring(sz,th,c1,c2,speed,rev)
  local r=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(sz,sz),BackgroundTransparency=1},ctr)
  make("UICorner",{CornerRadius=UDim.new(.5,0)},r)
  local s=make("UIStroke",{Thickness=th,Color=Color3.new(1,1,1)},r)
  local g=make("UIGradient",{Color=ColorSequence.new(c1,c2),Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(.5,.15),NumberSequenceKeypoint.new(.62,1),NumberSequenceKeypoint.new(1,1)})},s)
  TS:Create(g,TweenInfo.new(speed,LIN,Enum.EasingDirection.In,-1),{Rotation=rev and -360 or 360}):Play()
 end
 ring(170,4,COL.Pink,COL.Purple,1.5,false)
 ring(208,2.5,Color3.fromRGB(110,220,255),COL.Purple,2.4,true)
 ring(250,1.5,COL.Purple,COL.Pink,4,false)

 -- จุดโคจร
 local dots={}
 for i=1,8 do
  local sz=(i%2==0) and 6 or 4
  local d=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(sz,sz),BackgroundColor3=(i%2==0) and COL.Pink or Color3.new(1,1,1),BorderSizePixel=0},ctr)
  make("UICorner",{CornerRadius=UDim.new(.5,0)},d)
  dots[i]=d
 end
 local orb=RS.RenderStepped:Connect(function()
  local t=os.clock()
  for i,d in ipairs(dots) do
   local a=t*(.9+(i%3)*.35)*((i%2==0) and 1 or -1)+i*(math.pi*2/8)
   local r=130+math.sin(t*1.5+i)*8
   d.Position=UDim2.new(.5,math.cos(a)*r,.5,math.sin(a)*r)
  end
 end)

 -- โลโก้กลาง
 local lgo=make("ImageLabel",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(128,128),BackgroundColor3=COL.Side},ctr)
 round(lgo,64)
 make("UIStroke",{Color=Color3.new(1,1,1),Thickness=2,Transparency=.5},lgo)
 setImg(lgo,CFG.LOGO_ID)
 lgo.ImageColor3=CFG.LOGO_DARK
 local ls=make("UIScale",{Scale=0},lgo)
 TS:Create(ls,TweenInfo.new(.8,Enum.EasingStyle.Back),{Scale=1}):Play()
 task.delay(.9,function()
  if ld.Parent then TS:Create(ls,TweenInfo.new(1.1,SINE,IO,-1,true),{Scale=1.07}):Play() end
 end)

 -- ระลอกคลื่น
 task.spawn(function()
  task.wait(.5)
  while ld.Parent do
   local r=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(128,128),BackgroundTransparency=1},ctr)
   make("UICorner",{CornerRadius=UDim.new(.5,0)},r)
   local s=make("UIStroke",{Color=COL.Pink,Thickness=2,Transparency=.2},r)
   TS:Create(r,TweenInfo.new(1.8,Enum.EasingStyle.Quint),{Size=UDim2.fromOffset(330,330)}):Play()
   TS:Create(s,TweenInfo.new(1.8),{Transparency=1}):Play()
   task.delay(1.9,function() r:Destroy() end)
   task.wait(.9)
  end
 end)
 local function shock()
  local r=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(128,128),BackgroundTransparency=1},ctr)
  make("UICorner",{CornerRadius=UDim.new(.5,0)},r)
  local s=make("UIStroke",{Color=Color3.new(1,1,1),Thickness=4},r)
  TS:Create(r,TweenInfo.new(.7,Enum.EasingStyle.Quint),{Size=UDim2.fromOffset(1800,1800)}):Play()
  TS:Create(s,TweenInfo.new(.7),{Transparency=1}):Play()
 end

 -- ชื่อ + แถบโหลด
 local bot=make("Frame",{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,CY,math.floor(168*kk)),Size=UDim2.fromOffset(340,90),BackgroundTransparency=1,ZIndex=5},root)
 make("UIScale",{Scale=kk},bot)
 local spaced=(CFG.NAME:gsub("(.)","%1 "))
 local ttl=make("TextLabel",{Size=UDim2.new(1,0,0,30),BackgroundTransparency=1,Text=spaced,MaxVisibleGraphemes=0,Font=Enum.Font.GothamBlack,TextSize=26,TextColor3=Color3.new(1,1,1)},bot)
 local tg=make("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,COL.Purple),ColorSequenceKeypoint.new(.5,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,COL.Pink)}),Offset=Vector2.new(-1,0)},ttl)
 TS:Create(tg,TweenInfo.new(1.6,LIN,Enum.EasingDirection.In,-1),{Offset=Vector2.new(1,0)}):Play()
 task.spawn(function()
  for i=0,#spaced do
   if not ld.Parent then return end
   ttl.MaxVisibleGraphemes=i
   task.wait(.07)
  end
 end)
 local barBg=make("Frame",{Position=UDim2.fromOffset(0,42),Size=UDim2.new(1,0,0,8),BackgroundColor3=COL.Chip,BorderSizePixel=0},bot)
 round(barBg,4)
 make("UIStroke",{Color=COL.Pink,Thickness=1,Transparency=.6},barBg)
 local barFill=make("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ClipsDescendants=true},barBg)
 round(barFill,4)
 make("UIGradient",{Color=ColorSequence.new(COL.Purple,COL.Pink)},barFill)
 local bsh=make("Frame",{Size=UDim2.fromScale(.3,1),Position=UDim2.fromScale(-.4,0),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.55,BorderSizePixel=0},barFill)
 TS:Create(bsh,TweenInfo.new(1,Enum.EasingStyle.Quad,IO,-1),{Position=UDim2.fromScale(1.2,0)}):Play()
 local st=make("TextLabel",{Position=UDim2.fromOffset(0,56),Size=UDim2.new(1,-60,0,14),BackgroundTransparency=1,Text="",Font=Enum.Font.Gotham,TextSize=11,TextColor3=COL.Sub,TextXAlignment=Enum.TextXAlignment.Left},bot)
 local pc=make("TextLabel",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,56),Size=UDim2.fromOffset(56,14),BackgroundTransparency=1,Text="0%",Font=Enum.Font.GothamBold,TextSize=12,TextColor3=COL.Pink,TextXAlignment=Enum.TextXAlignment.Right},bot)

 local flash=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=20},root)

 local texts=TH and {"กำลังเริ่มระบบ...","กำลังโหลดทรัพยากร...","กำลังสร้างหน้าต่าง...","กำลังเชื่อมต่อ...","ใกล้เสร็จแล้ว..."} or {"Initializing...","Loading assets...","Building interface...","Connecting services...","Almost ready..."}
 task.spawn(function()
  local t0=os.clock()
  local cur=0
  while ld.Parent do
   local dt=RS.RenderStepped:Wait()
   local el=os.clock()-t0
   local goal=math.min(el/3,1)*92
   if (Loader.ready and el>=3) or el>25 then goal=100 end
   cur+=(goal-cur)*math.min(dt*5,1)
   if goal==100 and cur>99.5 then cur=100 end
   barFill.Size=UDim2.fromScale(cur/100,1)
   pc.Text=math.floor(cur).."%"
   st.Text=texts[math.clamp(math.floor(cur/20)+1,1,5)]
   if cur>=100 then break end
  end
  st.Text=TH and "พร้อมแล้ว ✔" or "Ready ✔"
  task.wait(.35)
  Loader.done=true
  shock()
  TS:Create(flash,TweenInfo.new(.15),{BackgroundTransparency=.6}):Play()
  TS:Create(csc,TweenInfo.new(.7,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Scale=kk*1.6}):Play()
  task.wait(.15)
  TS:Create(flash,TweenInfo.new(.5),{BackgroundTransparency=1}):Play()
  TS:Create(root,TweenInfo.new(.6,Enum.EasingStyle.Quad),{GroupTransparency=1}):Play()
  task.wait(.7)
  orb:Disconnect()
  ld:Destroy()
  if Loader.cb then task.spawn(Loader.cb) end
 end)
end

------------------------------------------------------------------
-- หน้าต่างหลัก
------------------------------------------------------------------
local state={scale=.9,alpha=0,key=true,lang=savedLang,fx=true}

local gui=make("ScreenGui",{Name="NexoraHubUI",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},parent)

local win=make("CanvasGroup",{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(540,376),Position=UDim2.new(.5,0,.5,0),BackgroundTransparency=1,GroupTransparency=1,Visible=false},gui)
round(win,26)
local bgf=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(1,1,1)},win)
round(bgf,26) glow(bgf,1.5)
make("UIGradient",{Color=ColorSequence.new(Color3.fromRGB(22,12,50),Color3.fromRGB(5,4,14)),Rotation=90},bgf)
local sc=make("UIScale",{Scale=.05},win)

local lang=savedLang
local labels={}
local langHooks={}
local function L(o,en,th)
 labels[#labels+1]={o,en,th}
 o.Text=(lang=="TH" and th) and th or en
 return o
end

-- ===== เอฟเฟกต์อวกาศ =====
local space=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ClipsDescendants=true},bgf)
local spaceOn=true
do
 local function blob(x,y,s,col,dx,dy,t)
  local h=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(x,y),Size=UDim2.fromOffset(s,s),BackgroundTransparency=1},space)
  for i=1,4 do
   local k=1-(i-1)*.2
   local c=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(k,k),BackgroundColor3=col,BackgroundTransparency=.93,BorderSizePixel=0},h)
   make("UICorner",{CornerRadius=UDim.new(.5,0)},c)
  end
  TS:Create(h,TweenInfo.new(t,SINE,IO,-1,true),{Position=UDim2.fromScale(x+dx,y+dy)}):Play()
 end
 blob(.15,.25,280,Color3.fromRGB(110,50,210),.08,.1,9)
 blob(.85,.8,320,Color3.fromRGB(40,80,220),-.1,-.08,11)
 blob(.6,.1,220,Color3.fromRGB(220,70,190),-.06,.12,8)

 for i=1,52 do
  local sz=math.random(1,2)+((math.random()<.12) and 1 or 0)
  local s=make("Frame",{Position=UDim2.fromScale(math.random(),math.random()),Size=UDim2.fromOffset(sz,sz),BackgroundColor3=(math.random()<.3) and COL.Pink or Color3.new(1,1,1),BackgroundTransparency=math.random(30,70)/100,BorderSizePixel=0},space)
  make("UICorner",{CornerRadius=UDim.new(.5,0)},s)
  TS:Create(s,TweenInfo.new(math.random(8,25)/10,SINE,IO,-1,true),{BackgroundTransparency=.95}):Play()
 end

 local planet=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.95,.07),Size=UDim2.fromOffset(60,60),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.3},space)
 make("UICorner",{CornerRadius=UDim.new(.5,0)},planet)
 make("UIGradient",{Color=ColorSequence.new(Color3.fromRGB(200,130,255),Color3.fromRGB(35,18,85)),Rotation=45},planet)
 local ringp=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(104,26),BackgroundTransparency=1,Rotation=-22},planet)
 make("UICorner",{CornerRadius=UDim.new(.5,0)},ringp)
 make("UIStroke",{Color=COL.Pink,Thickness=2,Transparency=.5},ringp)
 TS:Create(planet,TweenInfo.new(7,SINE,IO,-1,true),{Position=UDim2.fromScale(.95,.1)}):Play()

 task.spawn(function()
  while gui:IsDescendantOf(game) do
   task.wait(math.random(25,60)/10)
   if spaceOn and win.Visible then
    local x,y=math.random(5,60)/100,math.random(0,30)/100
    local s=make("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.fromScale(x,y),Size=UDim2.fromOffset(64,2),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Rotation=35},space)
    make("UIGradient",{Transparency=NumberSequence.new(1,0)},s)
    TS:Create(s,TweenInfo.new(.8,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.fromScale(x+.35,y+.4)}):Play()
    task.delay(.9,function() s:Destroy() end)
   end
  end
 end)
end
local function setSpace(v) spaceOn=v space.Visible=v end

-- ===== แถบบน =====
local top=make("Frame",{Size=UDim2.new(1,0,0,46),BackgroundTransparency=1},win)
local lg=make("ImageLabel",{Size=UDim2.fromOffset(30,30),Position=UDim2.fromOffset(14,8),BackgroundColor3=COL.Side},top)
round(lg,15) glow(lg,1.5)
setImg(lg,CFG.LOGO_ID)
lg.ImageColor3=CFG.LOGO_DARK
local title=make("TextLabel",{Position=UDim2.fromOffset(52,4),Size=UDim2.fromOffset(150,20),BackgroundTransparency=1,Text=CFG.NAME,Font=Enum.Font.GothamBlack,TextSize=16,TextColor3=Color3.new(1,1,1),TextXAlignment=Enum.TextXAlignment.Left},top)
local tg=make("UIGradient",{Offset=Vector2.new(-1,0)},title)
onAccent(function(a,b) tg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,a),ColorSequenceKeypoint.new(.5,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,b)}) end)
TS:Create(tg,TweenInfo.new(2.2,LIN,Enum.EasingDirection.In,-1,false,1.2),{Offset=Vector2.new(1,0)}):Play()
local sub=make("TextLabel",{Position=UDim2.fromOffset(52,24),Size=UDim2.new(1,-260,0,12),BackgroundTransparency=1,Text=game.Name,Font=Enum.Font.Gotham,TextSize=10,TextColor3=COL.Sub,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},top)

-- ตัวสลับภาษา (ใหญ่ ชัด มีไอคอนโลก)
local langF=make("Frame",{Size=UDim2.fromOffset(112,26),Position=UDim2.new(1,-190,0,10),BackgroundColor3=COL.Side},top)
round(langF,13)
local lfs=make("UIStroke",{Color=COL.Pink,Thickness=1,Transparency=.4},langF)
onAccent(function(a,b) lfs.Color=b end)
make("TextLabel",{Position=UDim2.fromOffset(6,0),Size=UDim2.fromOffset(18,26),BackgroundTransparency=1,Text="🌐",TextSize=13},langF)
local function lbtn(x,t)
 local b=make("TextButton",{Position=UDim2.fromOffset(x,3),Size=UDim2.fromOffset(40,20),BackgroundColor3=COL.Chip,Text=t,Font=Enum.Font.GothamBlack,TextSize=11,TextColor3=COL.Sub,AutoButtonColor=false},langF)
 round(b,10)
 return b
end
local thB=lbtn(26,"ไทย")
local enB=lbtn(68,"EN")
local curAcc=COL.Purple
local function paintLang()
 local th=(lang=="TH")
 TS:Create(thB,TweenInfo.new(.2),{BackgroundColor3=th and curAcc or COL.Chip,TextColor3=th and Color3.new(1,1,1) or COL.Sub}):Play()
 TS:Create(enB,TweenInfo.new(.2),{BackgroundColor3=(not th) and curAcc or COL.Chip,TextColor3=(not th) and Color3.new(1,1,1) or COL.Sub}):Play()
end
onAccent(function(a) curAcc=a paintLang() end)
local function setLang(l)
 lang=l state.lang=l
 for _,v in ipairs(labels) do v[1].Text=(l=="TH" and v[3]) and v[3] or v[2] end
 paintLang()
 for _,fn in ipairs(langHooks) do pcall(fn,l) end
 local n=getgenv().NX
 if n and n.save then n.save() end
end
thB.MouseButton1Click:Connect(function() setLang("TH") end)
enB.MouseButton1Click:Connect(function() setLang("EN") end)

local function tbtn(x,txt,col)
 local b=make("TextButton",{Size=UDim2.fromOffset(26,26),Position=UDim2.new(1,x,0,10),BackgroundColor3=col,Text=txt,Font=Enum.Font.GothamBold,TextSize=14,TextColor3=Color3.new(1,1,1),AutoButtonColor=false},top)
 round(b,13)
 b.MouseEnter:Connect(function() TS:Create(b,TweenInfo.new(.15),{Size=UDim2.fromOffset(30,30),Position=UDim2.new(1,x-2,0,8)}):Play() end)
 b.MouseLeave:Connect(function() TS:Create(b,TweenInfo.new(.15),{Size=UDim2.fromOffset(26,26),Position=UDim2.new(1,x,0,10)}):Play() end)
 return b
end
local minB=tbtn(-68,"–",COL.Purple)
local clsB=tbtn(-36,"X",COL.Red)
onAccent(function(a) minB.BackgroundColor3=a end)

-- ===== เมนูข้าง + หน้า =====
local side=make("Frame",{Position=UDim2.fromOffset(10,50),Size=UDim2.new(0,112,1,-60),BackgroundColor3=COL.Side,BackgroundTransparency=.45},win)
round(side,20)
local menu=make("Frame",{Size=UDim2.new(1,0,1,-56),BackgroundTransparency=1},side)
make("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},menu)
make("UIPadding",{PaddingTop=UDim.new(0,10),PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8)},menu)
local content=make("Frame",{Position=UDim2.fromOffset(130,50),Size=UDim2.new(1,-140,1,-60),BackgroundTransparency=1,ClipsDescendants=true},win)

local pages,btns,ord={}, {},0
local TI=TweenInfo.new(.3,Enum.EasingStyle.Quint)
local function selectPage(name)
 for n,p in pairs(pages) do
  if n==name then
   if not p.Visible then
    p.Visible=true p.Position=UDim2.fromOffset(18,0)
    TS:Create(p,TI,{Position=UDim2.new()}):Play()
   end
  else p.Visible=false end
 end
 for n,b in pairs(btns) do TS:Create(b,TI,{BackgroundTransparency=(n==name) and 0 or 1}):Play() end
end
local function section(en,th)
 ord+=1
 L(make("TextLabel",{LayoutOrder=ord,Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=9,TextColor3=COL.Sub,TextXAlignment=Enum.TextXAlignment.Left},menu),en,th)
end
local function addPage(name,icon,en,th)
 ord+=1
 local b=make("TextButton",{LayoutOrder=ord,Size=UDim2.new(1,0,0,32),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Text="",AutoButtonColor=false},menu)
 round(b,16)
 local g=make("UIGradient",{},b)
 onAccent(function(a,c2) g.Color=ColorSequence.new(a,c2) end)
 make("TextLabel",{Position=UDim2.fromOffset(8,0),Size=UDim2.fromOffset(20,32),BackgroundTransparency=1,Text=icon,TextSize=14},b)
 L(make("TextLabel",{Position=UDim2.fromOffset(32,0),Size=UDim2.new(1,-36,1,0),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=Color3.new(1,1,1),TextXAlignment=Enum.TextXAlignment.Left},b),en,th)
 local p=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false},content)
 pages[name]=p btns[name]=b
 b.MouseButton1Click:Connect(function() selectPage(name) end)
 return p
end
section("MAIN","หลัก")
addPage("home","⌂","HOME","HOME")
section("SYSTEM","ระบบ")
addPage("settings","☼","SETTINGS","SETTINGS")
selectPage("home")

-- ===== โลโก้ลอย + เอฟเฟกต์ =====
local LS=52
local logo=make("ImageButton",{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(0,0),Position=UDim2.new(0,42,.5,0),BackgroundColor3=COL.Bg,Image="",AutoButtonColor=false},gui)
round(logo,26) glow(logo,1.5)
setImg(logo,CFG.LOGO_ID)
logo.ImageColor3=CFG.LOGO_DARK
TS:Create(make("UIScale",{},logo),TweenInfo.new(1.8,SINE,IO,-1,true),{Scale=1.06}):Play()

local fxOn=true
local fxObjs={}
-- วงแหวนนีออนหมุนรอบโลโก้ (เห็นชัด เข้าใจง่าย)
local function fxRing(extra,th,speed,rev)
 local r=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.new(1,extra,1,extra),BackgroundTransparency=1},logo)
 make("UICorner",{CornerRadius=UDim.new(.5,0)},r)
 local s=make("UIStroke",{Thickness=th,Color=Color3.new(1,1,1)},r)
 local g=make("UIGradient",{Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(.45,.1),NumberSequenceKeypoint.new(.6,1),NumberSequenceKeypoint.new(1,1)})},s)
 onAccent(function(a,b) g.Color=ColorSequence.new(b,a) end)
 TS:Create(g,TweenInfo.new(speed,LIN,Enum.EasingDirection.In,-1),{Rotation=rev and -360 or 360}):Play()
 fxObjs[#fxObjs+1]=r
end
fxRing(12,3,1.4,false)
fxRing(26,2,2.2,true)
local function setLogoFx(v)
 fxOn=v
 for _,r in ipairs(fxObjs) do r.Visible=v end
end
logo.MouseEnter:Connect(function() TS:Create(logo,TweenInfo.new(.2,Enum.EasingStyle.Back),{Size=UDim2.fromOffset(LS+8,LS+8)}):Play() end)
logo.MouseLeave:Connect(function() TS:Create(logo,TweenInfo.new(.2,Enum.EasingStyle.Back),{Size=UDim2.fromOffset(LS,LS)}):Play() end)

local function ripple()
 local r=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(1,1),BackgroundTransparency=1},logo)
 make("UICorner",{CornerRadius=UDim.new(.5,0)},r)
 local s=make("UIStroke",{Color=COL.Pink,Thickness=1.5,Transparency=.2},r)
 TS:Create(r,TweenInfo.new(1.4,Enum.EasingStyle.Quint),{Size=UDim2.fromScale(2.4,2.4)}):Play()
 TS:Create(s,TweenInfo.new(1.4),{Transparency=1}):Play()
 task.delay(1.5,function() r:Destroy() end)
end
local function burst()
 for i=1,10 do
  local a=math.rad(i*36)
  local d=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(5,5),BackgroundColor3=(i%2==0) and COL.Pink or COL.Purple},logo)
  make("UICorner",{CornerRadius=UDim.new(.5,0)},d)
  TS:Create(d,TweenInfo.new(.7,Enum.EasingStyle.Quint),{Position=UDim2.new(.5,math.cos(a)*48,.5,math.sin(a)*48),BackgroundTransparency=1,Size=UDim2.fromOffset(2,2)}):Play()
  task.delay(.8,function() d:Destroy() end)
 end
end

local open,busy=false,false
local winPos=UDim2.new(.5,0,.5,0)
local function setOpen(v)
 if busy or v==open then return end
 busy=true open=v
 burst()
 logo.Rotation=0
 TS:Create(logo,TweenInfo.new(.6,Enum.EasingStyle.Back),{Rotation=360}):Play()
 task.delay(.65,function() logo.Rotation=0 busy=false end)
 if v then
  -- จำตำแหน่งเดิม และกันหลุดนอกจอ
  local av=gui.AbsoluteSize
  local hw,hh=540*state.scale/2,376*state.scale/2
  local ax=math.clamp(winPos.X.Scale*av.X+winPos.X.Offset,math.min(hw,av.X/2),math.max(av.X-hw,av.X/2))
  local ay=math.clamp(winPos.Y.Scale*av.Y+winPos.Y.Offset,math.min(hh,av.Y/2),math.max(av.Y-hh,av.Y/2))
  winPos=UDim2.fromOffset(ax,ay)
  win.Visible=true
  win.Position=logo.Position
  sc.Scale=.05 win.GroupTransparency=1
  local ti=TweenInfo.new(.55,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
  TS:Create(win,ti,{Position=winPos,GroupTransparency=state.alpha}):Play()
  TS:Create(sc,ti,{Scale=state.scale}):Play()
 else
  local ti=TweenInfo.new(.38,Enum.EasingStyle.Quint,Enum.EasingDirection.In)
  TS:Create(win,ti,{Position=logo.Position,GroupTransparency=1}):Play()
  TS:Create(sc,ti,{Scale=.05}):Play()
  task.delay(.4,function() if not open then win.Visible=false end end)
 end
end
local function resetPos()
 winPos=UDim2.new(.5,0,.5,0)
 logo.Position=UDim2.new(0,42,.5,0)
 if open then win.Position=winPos end
end

local function drag(handle,target,onClick,onEnd)
 local d,ds,sp,moved
 handle.InputBegan:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
   d=true moved=false ds=i.Position sp=target.Position
   i.Changed:Connect(function()
    if i.UserInputState==Enum.UserInputState.End then
     d=false
     if onEnd then onEnd() end
     if onClick and not moved then onClick() end
    end
   end)
  end
 end)
 UIS.InputChanged:Connect(function(i)
  if d and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
   local v=i.Position-ds
   if v.Magnitude>6 then moved=true end
   target.Position=UDim2.new(sp.X.Scale,sp.X.Offset+v.X,sp.Y.Scale,sp.Y.Offset+v.Y)
  end
 end)
end
drag(top,win,nil,function() if open and not busy then winPos=win.Position end end)
drag(logo,logo,function() setOpen(not open) end)
minB.MouseButton1Click:Connect(function() setOpen(false) end)
clsB.MouseButton1Click:Connect(function() gui:Destroy() end)
UIS.InputBegan:Connect(function(i,gp)
 if not gp and state.key and i.KeyCode==Enum.KeyCode.RightShift then setOpen(not open) end
end)

task.spawn(function()
 while gui:IsDescendantOf(game) do
  if not open and fxOn then ripple() end
  task.wait(2.4)
 end
end)

getgenv().NX={COL=COL,make=make,round=round,glow=glow,L=L,setLang=setLang,getLang=function() return lang end,
 onLang=function(fn) langHooks[#langHooks+1]=fn end,
 content=content,sub=sub,side=side,pages=pages,onAccent=onAccent,setAccent=setAccent,setSpace=setSpace,
 setLogoFx=setLogoFx,resetPos=resetPos,setImg=setImg,CFG=CFG,gui=gui,
 state=state,win=win,sc=sc,setOpen=setOpen,isOpen=function() return open end}

------------------------------------------------------------------
-- หน้า HOME
------------------------------------------------------------------
do
local NX=getgenv().NX
local COL,make,round,glow,L=NX.COL,NX.make,NX.round,NX.glow,NX.L
local Players=game:GetService("Players")
local TS=game:GetService("TweenService")
local RS=game:GetService("RunService")
local Stats=game:GetService("Stats")
local MPS=game:GetService("MarketplaceService")
local lp=Players.LocalPlayer
local TI=TweenInfo.new(.35,Enum.EasingStyle.Quint)
local c=NX.pages.home
local CEN=Enum.TextXAlignment.Center
local function T(en,th) return (NX.getLang()=="TH") and th or en end

local function txt(p,props)
 props.BackgroundTransparency=1
 props.Font=props.Font or Enum.Font.GothamBold
 props.TextColor3=props.TextColor3 or COL.Text
 props.TextXAlignment=props.TextXAlignment or Enum.TextXAlignment.Left
 return make("TextLabel",props,p)
end
local function pop(o,d)
 local s=make("UIScale",{Scale=0},o)
 task.delay(d,function() TS:Create(s,TweenInfo.new(.45,Enum.EasingStyle.Back),{Scale=1}):Play() end)
end
local function tag(p,props)
 props.AutomaticSize=Enum.AutomaticSize.X
 props.Size=UDim2.fromOffset(0,16)
 props.BackgroundColor3=COL.Bg
 props.BackgroundTransparency=.35
 props.Font=Enum.Font.GothamBold
 props.TextSize=9
 props.TextColor3=COL.Text
 local t=make("TextLabel",props,p)
 round(t,8)
 make("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8)},t)
 return t
end

-- แถวหัวข้อ + แท็ก
local th=make("Frame",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1},c)
local tl=L(txt(th,{Position=UDim2.fromOffset(2,0),Size=UDim2.fromOffset(110,20),Font=Enum.Font.GothamBlack,TextSize=17,TextColor3=Color3.new(1,1,1)}),"HOME","หน้าหลัก")
local tlg=make("UIGradient",{},tl)
NX.onAccent(function(a,b) tlg.Color=ColorSequence.new(a,b) end)
local tr=make("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,2),Size=UDim2.new(.7,0,0,16),BackgroundTransparency=1},th)
make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Right,Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},tr)
L(tag(tr,{LayoutOrder=1}),"🎂 "..lp.AccountAge.." days","🎂 "..lp.AccountAge.." วัน")
tag(tr,{LayoutOrder=2,Text="🆔 "..lp.UserId})

-- โปรไฟล์
local pg=make("Frame",{Position=UDim2.fromOffset(0,26),Size=UDim2.new(1,-156,0,58),BackgroundTransparency=1},c)
local ring=make("Frame",{Position=UDim2.fromOffset(0,2),Size=UDim2.fromOffset(54,54),BackgroundTransparency=1},pg)
round(ring,27) glow(ring,1.5)
TS:Create(make("UIScale",{},ring),TweenInfo.new(1.6,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Scale=1.07}):Play()
local av=make("ImageLabel",{Size=UDim2.fromOffset(46,46),Position=UDim2.fromOffset(4,6),BackgroundColor3=COL.Side},pg)
round(av,23)
task.spawn(function()
 local ok,img=pcall(function() return Players:GetUserThumbnailAsync(lp.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150) end)
 if ok then av.Image=img end
end)
local nm=txt(pg,{Position=UDim2.fromOffset(66,4),Size=UDim2.new(1,-66,0,18),Text=lp.DisplayName,Font=Enum.Font.GothamBlack,TextSize=15,TextColor3=Color3.new(1,1,1),TextTruncate=Enum.TextTruncate.AtEnd})
local ng=make("UIGradient",{},nm)
NX.onAccent(function(a,b) ng.Color=ColorSequence.new(b,a) end)
txt(pg,{Position=UDim2.fromOffset(66,22),Size=UDim2.new(1,-66,0,12),Text="@"..lp.Name,Font=Enum.Font.Gotham,TextSize=10,TextColor3=COL.Sub,TextTruncate=Enum.TextTruncate.AtEnd})
local hpBack=make("Frame",{Position=UDim2.fromOffset(66,38),Size=UDim2.new(1,-66,0,16),BackgroundColor3=COL.Chip,BackgroundTransparency=.3},pg)
round(hpBack,8)
local fill=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=COL.Green,ClipsDescendants=true},hpBack)
round(fill,8)
local shine=make("Frame",{Size=UDim2.fromScale(.25,1),Position=UDim2.fromScale(-.3,0),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.7,BorderSizePixel=0},fill)
round(shine,8)
TS:Create(shine,TweenInfo.new(1.6,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,false,1),{Position=UDim2.fromScale(1.05,0)}):Play()
local hpTxt=txt(hpBack,{Size=UDim2.fromScale(1,1),Text="❤ -- / --",TextSize=10,TextColor3=Color3.new(1,1,1),TextXAlignment=CEN,ZIndex=2})
pop(pg,.05)

local function bindChar(ch)
 local hum=ch:WaitForChild("Humanoid",5)
 if not hum then return end
 local function upd()
  local r=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
  TS:Create(fill,TI,{Size=UDim2.fromScale(r,1),BackgroundColor3=COL.Red:Lerp(COL.Green,r)}):Play()
  hpTxt.Text="❤ "..math.floor(hum.Health).." / "..math.floor(hum.MaxHealth)
 end
 hum.HealthChanged:Connect(upd)
 hum:GetPropertyChangedSignal("MaxHealth"):Connect(upd)
 upd()
end
if lp.Character then task.spawn(bindChar,lp.Character) end
lp.CharacterAdded:Connect(bindChar)

-- ข้อมูลตัวละครฝั่งขวา
local rp=make("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,26),Size=UDim2.fromOffset(148,58),BackgroundTransparency=1},c)
local function pill(y,icon)
 local p=make("Frame",{Position=UDim2.fromOffset(0,y),Size=UDim2.new(1,0,0,26),BackgroundColor3=COL.Chip,BackgroundTransparency=.4},rp)
 round(p,13) glow(p,1)
 return txt(p,{Size=UDim2.fromScale(1,1),TextSize=10,TextXAlignment=CEN,Text=icon.." --"})
end
local spdL=pill(0,"🏃")
local posL=pill(32,"📍")
pop(rp,.1)

-- กราฟ FPS / Ping
local N,W,H=26,144,30
local function chart(i,en,th2,unit,maxLbl,midLbl)
 local f=make("Frame",{Position=UDim2.new(i*.5,i*4,0,90),Size=UDim2.new(.5,-4,0,78),BackgroundColor3=COL.Chip,BackgroundTransparency=.35},c)
 round(f,18) glow(f,1.6)
 L(txt(f,{Position=UDim2.fromOffset(12,6),Size=UDim2.new(.5,0,0,10),TextSize=9,TextColor3=COL.Sub}),en,th2)
 local avg=txt(f,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-12,0,6),Size=UDim2.new(.5,0,0,10),TextSize=9,TextColor3=COL.Sub,TextXAlignment=Enum.TextXAlignment.Right})
 local v=txt(f,{Position=UDim2.fromOffset(12,15),Size=UDim2.new(.7,0,0,18),TextSize=16,Text="--"})
 local gf=make("Frame",{Position=UDim2.fromOffset(10,36),Size=UDim2.new(1,-20,0,38),BackgroundColor3=COL.Bg,BackgroundTransparency=.2},f)
 round(gf,10)
 local gs=make("UIStroke",{Color=COL.Pink,Thickness=1.4,Transparency=.05},gf)
 NX.onAccent(function(a,b) gs.Color=b end)
 local area=make("Frame",{Position=UDim2.fromOffset(26,4),Size=UDim2.fromOffset(W,H),BackgroundTransparency=1},gf)
 for g=0,2 do
  make("Frame",{Position=UDim2.new(0,0,g/2,g==2 and -1 or 0),Size=UDim2.new(1,0,0,1),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.78,BorderSizePixel=0},area)
  txt(gf,{Position=UDim2.fromOffset(3,4+g*H/2-5),Size=UDim2.fromOffset(22,10),Font=Enum.Font.Gotham,TextSize=7,TextColor3=COL.Sub,TextXAlignment=Enum.TextXAlignment.Right,Text=(g==0) and maxLbl or ((g==1) and midLbl or "0")})
 end
 for g=1,3 do
  make("Frame",{Position=UDim2.new(g/4,0,0,0),Size=UDim2.new(0,1,1,0),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.9,BorderSizePixel=0},area)
 end
 local cols,segs={},{}
 for k=1,N do
  cols[k]=make("Frame",{AnchorPoint=Vector2.new(.5,1),Position=UDim2.fromOffset((k-1)/(N-1)*W,H),Size=UDim2.fromOffset(math.ceil(W/N),0),BackgroundColor3=COL.Purple,BorderSizePixel=0},area)
  make("UIGradient",{Rotation=90,Transparency=NumberSequence.new(.5,1)},cols[k])
 end
 for k=1,N-1 do
  segs[k]=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(0,2),BackgroundColor3=COL.Purple,BorderSizePixel=0},area)
 end
 local dot=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(7,7),Position=UDim2.fromOffset(W,H),BackgroundColor3=Color3.new(1,1,1)},area)
 round(dot,4)
 pop(f,.15+i*.1)
 local vals,norm={},{}
 for k=1,N do vals[k]=0 norm[k]=0 end
 local ti=TweenInfo.new(.35,Enum.EasingStyle.Quint)
 return function(val,n,good)
  table.remove(vals,1) table.insert(vals,val)
  table.remove(norm,1) table.insert(norm,n)
  local s,cnt=0,0
  for _,x in ipairs(vals) do if x>0 then s+=x cnt+=1 end end
  avg.Text="avg "..math.floor(s/math.max(cnt,1))
  v.Text=val..unit
  local col=COL.Red:Lerp(COL.Green,good)
  TS:Create(v,ti,{TextColor3=col}):Play()
  local px,py={},{}
  for k=1,N do
   px[k]=(k-1)/(N-1)*W
   py[k]=H-math.max(norm[k],.05)*H
   cols[k].BackgroundColor3=col
   TS:Create(cols[k],ti,{Size=UDim2.fromOffset(math.ceil(W/N),H-py[k])}):Play()
  end
  for k=1,N-1 do
   local dx,dy=px[k+1]-px[k],py[k+1]-py[k]
   segs[k].BackgroundColor3=col
   TS:Create(segs[k],ti,{Position=UDim2.fromOffset(px[k]+dx/2,py[k]+dy/2),Size=UDim2.fromOffset(math.sqrt(dx*dx+dy*dy)+1.5,2),Rotation=math.deg(math.atan2(dy,dx))}):Play()
  end
  dot.BackgroundColor3=col
  TS:Create(dot,ti,{Position=UDim2.fromOffset(W,py[N])}):Play()
 end
end
local updFps=chart(0,"⚡ FPS","⚡ FPS","","60","30")
local updPing=chart(1,"📡 Ping","📡 ปิง"," ms","300","150")

local frames,acc=0,0
local conn
conn=RS.RenderStepped:Connect(function(dt)
 if not c:IsDescendantOf(game) then conn:Disconnect() return end
 frames+=1 acc+=dt
 if acc<.6 then return end
 local fps=math.floor(frames/acc+.5)
 frames,acc=0,0
 local r=math.clamp(fps/60,0,1)
 updFps(fps,r,r)
 local ok,ms=pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
 if ok and ms then
  ms=math.floor(ms)
  local q=math.clamp(ms/300,0,1)
  updPing(ms,q,1-q)
 end
end)

-- ปกแมพ
local mp=make("Frame",{Position=UDim2.fromOffset(0,174),Size=UDim2.new(1,0,0,64),BackgroundTransparency=1,ClipsDescendants=true},c)
round(mp,20) glow(mp,1.6)
local aur=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0},mp)
round(aur,20)
local ag=make("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(90,50,200)),ColorSequenceKeypoint.new(.5,Color3.fromRGB(30,20,90)),ColorSequenceKeypoint.new(1,Color3.fromRGB(190,100,240))})},aur)
TS:Create(ag,TweenInfo.new(6,Enum.EasingStyle.Linear,Enum.EasingDirection.In,-1),{Rotation=360}):Play()
local img=make("ImageLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ImageTransparency=1,ScaleType=Enum.ScaleType.Crop},mp)
round(img,20)
local ov=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0},mp)
round(ov,20)
make("UIGradient",{Rotation=90,Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.8),NumberSequenceKeypoint.new(.5,.6),NumberSequenceKeypoint.new(1,.1)})},ov)
local sh=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(-.2,0,.5,0),Size=UDim2.new(0,28,2,0),Rotation=20,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.88,BorderSizePixel=0},mp)
TS:Create(sh,TweenInfo.new(2.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,false,1.5),{Position=UDim2.new(1.2,0,.5,0)}):Play()
L(txt(mp,{Position=UDim2.fromOffset(14,8),Size=UDim2.new(1,-190,0,12),Font=Enum.Font.Gotham,TextSize=10,TextColor3=COL.Pink}),"🗺 Current map","🗺 แมพที่เล่นอยู่")
local mn=txt(mp,{Position=UDim2.fromOffset(14,28),Size=UDim2.new(1,-28,0,28),Text=game.Name,Font=Enum.Font.GothamBlack,TextSize=17,TextTruncate=Enum.TextTruncate.AtEnd})
local mt=make("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-10,0,7),Size=UDim2.new(0,180,0,16),BackgroundTransparency=1},mp)
make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Right,Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},mt)
local pl=tag(mt,{LayoutOrder=1,Text="👥 -- / --"})
local tm=tag(mt,{LayoutOrder=2,Text="⏱ 00:00:00"})
pop(mp,.3)

local srcs={
 "rbxthumb://type=GameIcon&id="..game.GameId.."&w=256&h=256",
 "rbxthumb://type=GameIcon&id="..game.GameId.."&w=150&h=150",
 "rbxthumb://type=Asset&id="..game.PlaceId.."&w=420&h=420",
}
task.spawn(function()
 for _,s in ipairs(srcs) do
  img.Image=s
  local t=0
  while not img.IsLoaded and t<3 do task.wait(.2) t+=.2 end
  if img.IsLoaded then TS:Create(img,TweenInfo.new(.8),{ImageTransparency=0}):Play() return end
 end
 img.Image=""
end)
task.spawn(function()
 local ok,info=pcall(function() return MPS:GetProductInfo(game.PlaceId) end)
 if ok and info then mn.Text=info.Name NX.sub.Text=info.Name end
end)

-- ชิปข้อมูลด้านล่าง (กดคัดลอกได้)
local cr=make("Frame",{Position=UDim2.fromOffset(0,244),Size=UDim2.new(1,0,0,22),BackgroundTransparency=1},c)
make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},cr)
local function chipBtn(i,text,copyVal)
 local b=make("TextButton",{LayoutOrder=i,Size=UDim2.new(1/3,-3,1,0),BackgroundColor3=COL.Chip,BackgroundTransparency=.4,AutoButtonColor=false,Text=text,Font=Enum.Font.GothamBold,TextSize=9,TextColor3=COL.Text},cr)
 round(b,11) glow(b,1)
 if copyVal then
  b.MouseButton1Click:Connect(function()
   pcall(function() setclipboard(copyVal) end)
   local old=b.Text
   b.Text="✔ copied"
   task.delay(1,function() b.Text=old end)
  end)
 end
 pop(b,.4+i*.05)
 return b
end
local memB=chipBtn(1,"🧠 -- MB")
chipBtn(2,"📍 "..game.PlaceId,tostring(game.PlaceId))
chipBtn(3,"🔗 "..string.sub(game.JobId,1,8),game.JobId)

-- ปุ่มคัดลอกลิงก์ Discord
local dc=make("TextButton",{Position=UDim2.fromOffset(0,272),Size=UDim2.new(1,0,0,38),BackgroundColor3=Color3.new(1,1,1),AutoButtonColor=false,Text="",ClipsDescendants=true},c)
round(dc,14)
make("UIGradient",{Color=ColorSequence.new(Color3.fromRGB(88,101,242),Color3.fromRGB(140,90,255)),Rotation=0},dc)
make("UIStroke",{Color=Color3.new(1,1,1),Transparency=.75,Thickness=1},dc)
local dci=make("ImageLabel",{Position=UDim2.fromOffset(9,5),Size=UDim2.fromOffset(28,28),BackgroundTransparency=1,ScaleType=Enum.ScaleType.Fit},dc)
NX.setImg(dci,NX.CFG.DISCORD_ICON_ID)
txt(dc,{Position=UDim2.fromOffset(46,4),Size=UDim2.new(1,-140,0,16),Text="Discord",Font=Enum.Font.GothamBlack,TextSize=14,TextColor3=Color3.new(1,1,1)})
local dsub=L(txt(dc,{Position=UDim2.fromOffset(46,21),Size=UDim2.new(1,-140,0,12),Font=Enum.Font.Gotham,TextSize=9,TextColor3=Color3.fromRGB(228,230,255),TextTruncate=Enum.TextTruncate.AtEnd}),"Copy invite link","คัดลอกลิงก์เชิญ")
local dp=make("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-8,.5,0),Size=UDim2.fromOffset(84,24),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.55},dc)
round(dp,12)
local dbl=L(txt(dp,{Size=UDim2.fromScale(1,1),TextSize=10,TextColor3=Color3.new(1,1,1),TextXAlignment=CEN}),"Copy","คัดลอก")
local dsh=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(-.2,0,.5,0),Size=UDim2.new(0,26,2,0),Rotation=20,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.8,BorderSizePixel=0},dc)
TS:Create(dsh,TweenInfo.new(1.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,false,2),{Position=UDim2.new(1.2,0,.5,0)}):Play()
dc.MouseButton1Click:Connect(function()
 local ok=pcall(function() setclipboard(NX.CFG.DISCORD_LINK) end)
 dbl.Text=ok and T("✔ Copied","✔ คัดลอกแล้ว") or T("✖ Failed","✖ ไม่รองรับ")
 if not ok then dsub.Text=NX.CFG.DISCORD_LINK end
 task.delay(1.6,function()
  dbl.Text=T("Copy","คัดลอก")
  dsub.Text=T("Copy invite link","คัดลอกลิงก์เชิญ")
 end)
end)
pop(dc,.55)

-- สถานะใต้เมนูข้าง
local st=make("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,8,1,-8),Size=UDim2.new(1,-16,0,42),BackgroundColor3=COL.Chip,BackgroundTransparency=.4},NX.side)
round(st,16)
local dot=make("Frame",{Position=UDim2.fromOffset(10,8),Size=UDim2.fromOffset(7,7),BackgroundColor3=COL.Green},st)
round(dot,4)
TS:Create(dot,TweenInfo.new(.9,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{BackgroundTransparency=.8}):Play()
L(txt(st,{Position=UDim2.fromOffset(22,4),Size=UDim2.new(1,-26,0,14),TextSize=10,TextColor3=COL.Green}),"Online","ออนไลน์")
local clk=txt(st,{Position=UDim2.fromOffset(10,20),Size=UDim2.new(1,-14,0,16),TextSize=14,Text=os.date("%H:%M:%S")})

-- ลูปอัปเดตสด
task.spawn(function()
 while c:IsDescendantOf(game) do
  local t=math.floor(workspace.DistributedGameTime)
  tm.Text=string.format("⏱ %02d:%02d:%02d",math.floor(t/3600),math.floor(t%3600/60),t%60)
  pl.Text="👥 "..#Players:GetPlayers().." / "..Players.MaxPlayers
  clk.Text=os.date("%H:%M:%S")
  local ok,mem=pcall(function() return math.floor(Stats:GetTotalMemoryUsageMb()) end)
  if ok then memB.Text="🧠 "..mem.." MB" end
  task.wait(1)
 end
end)
task.spawn(function()
 while c:IsDescendantOf(game) do
  local ch=lp.Character
  local hum=ch and ch:FindFirstChildOfClass("Humanoid")
  local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
  if hum then spdL.Text="🏃 "..(math.floor(hum.WalkSpeed*10)/10).." speed" end
  if hrp then
   local p=hrp.Position
   posL.Text=string.format("📍 %d, %d, %d",math.floor(p.X),math.floor(p.Y),math.floor(p.Z))
  end
  task.wait(.25)
 end
end)
end

------------------------------------------------------------------
-- หน้า SETTINGS
------------------------------------------------------------------
do
local NX=getgenv().NX
local COL,make,round,L=NX.COL,NX.make,NX.round,NX.L
local TS=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local HttpService=game:GetService("HttpService")
local TeleportService=game:GetService("TeleportService")
local Lighting=game:GetService("Lighting")
local Players=game:GetService("Players")
local lp=Players.LocalPlayer
local TI=TweenInfo.new(.2,Enum.EasingStyle.Quint)
local S=NX.state
local DEF={scale=.9,alpha=0,accent=1,space=true,afk=false,fps=0,key=true,fx=true,fov=70,fovOn=false,fullbright=false,boost=false}
for k,v in pairs(DEF) do if S[k]==nil then S[k]=v end end

-- โหลด/บันทึกการตั้งค่า (ถ้า executor รองรับ)
local FILE=NX.CFG.SETTINGS_FILE
pcall(function()
 if isfile and isfile(FILE) then
  for k,v in pairs(HttpService:JSONDecode(readfile(FILE))) do S[k]=v end
 end
end)
S.scale=.9 -- เริ่มที่ 90% ทุกครั้ง
local function save() pcall(function() if writefile then writefile(FILE,HttpService:JSONEncode(S)) end end) end
NX.save=save
local function T(en,th) return (NX.getLang()=="TH") and th or en end

local sf=make("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=COL.Pink,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},NX.pages.settings)
make("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},sf)
make("UIPadding",{PaddingRight=UDim.new(0,6),PaddingBottom=UDim.new(0,8)},sf)
local ord=0
local ctrls={}

local function txt(p,props)
 props.BackgroundTransparency=1
 props.Font=props.Font or Enum.Font.GothamBold
 props.TextColor3=props.TextColor3 or COL.Text
 props.TextXAlignment=props.TextXAlignment or Enum.TextXAlignment.Left
 return make("TextLabel",props,p)
end
local function header(en,th,big)
 ord+=1
 local l=txt(sf,{LayoutOrder=ord,Size=UDim2.new(1,0,0,big and 22 or 16),Font=big and Enum.Font.GothamBlack or Enum.Font.GothamBold,TextSize=big and 17 or 10,TextColor3=big and Color3.new(1,1,1) or COL.Pink})
 if big then
  local g=make("UIGradient",{},l)
  NX.onAccent(function(a,b) g.Color=ColorSequence.new(a,b) end)
 end
 L(l,en,th)
end
local function row(h)
 ord+=1
 local r=make("Frame",{LayoutOrder=ord,Size=UDim2.new(1,0,0,h),BackgroundColor3=COL.Chip,BackgroundTransparency=.4},sf)
 round(r,14)
 local s=make("UIStroke",{Color=COL.Pink,Transparency=.65,Thickness=1},r)
 NX.onAccent(function(a,b) s.Color=b end)
 return r
end
local function titles(r,en,th,dEn,dTh,w)
 L(txt(r,{Position=UDim2.fromOffset(14,6),Size=UDim2.new(1,w or -80,0,16),TextSize=12}),en,th)
 if dEn then L(txt(r,{Position=UDim2.fromOffset(14,22),Size=UDim2.new(1,w or -80,0,14),Font=Enum.Font.Gotham,TextSize=9,TextColor3=COL.Sub}),dEn,dTh) end
end

local function toggle(key,en,th,dEn,dTh,cb)
 local r=row(42)
 titles(r,en,th,dEn,dTh)
 local sw=make("TextButton",{Text="",AutoButtonColor=false,Size=UDim2.fromOffset(38,20),Position=UDim2.new(1,-52,.5,-10),BackgroundColor3=COL.Bg},r)
 round(sw,10)
 local knob=make("Frame",{Size=UDim2.fromOffset(14,14),Position=UDim2.fromOffset(3,3),BackgroundColor3=Color3.new(1,1,1)},sw)
 round(knob,7)
 local function set(v,fire)
  S[key]=v
  TS:Create(sw,TI,{BackgroundColor3=v and COL.Purple or COL.Bg}):Play()
  TS:Create(knob,TI,{Position=v and UDim2.fromOffset(21,3) or UDim2.fromOffset(3,3)}):Play()
  if fire then cb(v) save() end
 end
 sw.MouseButton1Click:Connect(function() set(not S[key],true) end)
 set(S[key],false)
 NX.onAccent(function() sw.BackgroundColor3=S[key] and COL.Purple or COL.Bg end)
 ctrls[key]=set
end

local function button(en,th,dEn,dTh,bEn,bTh,cb,dyn)
 local r=row(42)
 L(txt(r,{Position=UDim2.fromOffset(14,6),Size=UDim2.new(1,-110,0,16),TextSize=12}),en,th)
 local d=txt(r,{Position=UDim2.fromOffset(14,22),Size=UDim2.new(1,-110,0,14),Font=Enum.Font.Gotham,TextSize=9,TextColor3=COL.Sub,TextTruncate=Enum.TextTruncate.AtEnd})
 if dyn then d.Text=T(dEn,dTh) else L(d,dEn,dTh) end
 local b=make("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-10,.5,0),Size=UDim2.fromOffset(84,26),BackgroundColor3=COL.Purple,Text="",AutoButtonColor=false},r)
 round(b,13)
 NX.onAccent(function(a) b.BackgroundColor3=a end)
 local bl=L(txt(b,{Size=UDim2.fromScale(1,1),TextSize=10,TextColor3=Color3.new(1,1,1),TextXAlignment=Enum.TextXAlignment.Center}),bEn,bTh)
 b.MouseButton1Click:Connect(function() cb(d,bl,b) end)
 return d,bl
end

local function slider(key,en,th,min,max,fmt,onRelease,cb)
 local r=row(50)
 titles(r,en,th,nil,nil,-90)
 local vl=txt(r,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,6),Size=UDim2.fromOffset(70,16),TextSize=11,TextColor3=COL.Pink,TextXAlignment=Enum.TextXAlignment.Right})
 local track=make("Frame",{Position=UDim2.new(0,14,0,34),Size=UDim2.new(1,-28,0,6),BackgroundColor3=COL.Bg},r)
 round(track,3)
 local fill=make("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=COL.Purple},track)
 round(fill,3)
 local knob=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(0,.5),Size=UDim2.fromOffset(14,14),BackgroundColor3=Color3.new(1,1,1)},track)
 round(knob,7)
 NX.onAccent(function(a) fill.BackgroundColor3=a end)
 local hit=make("TextButton",{Text="",BackgroundTransparency=1,Position=UDim2.new(0,14,0,22),Size=UDim2.new(1,-28,0,26)},r)
 local function show(v)
  local t=(v-min)/(max-min)
  fill.Size=UDim2.fromScale(t,1) knob.Position=UDim2.fromScale(t,.5)
  vl.Text=fmt(v)
 end
 local function set(v,fire)
  v=math.clamp(v,min,max) S[key]=v show(v)
  if fire then cb(v) end
 end
 local dragging=false
 local function fromX(x)
  local t=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
  local v=min+(max-min)*t
  S[key]=v show(v)
  if not onRelease then cb(v) end
 end
 local function isPtr(i) return i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch end
 hit.InputBegan:Connect(function(i) if isPtr(i) then dragging=true fromX(i.Position.X) end end)
 UIS.InputChanged:Connect(function(i)
  if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then fromX(i.Position.X) end
 end)
 UIS.InputEnded:Connect(function(i)
  if dragging and isPtr(i) then
   dragging=false
   if onRelease then cb(S[key]) end
   save()
  end
 end)
 show(S[key])
 ctrls[key]=set
end

-- ตัวเลือกหลายปุ่ม (ล็อก FPS)
local function segmented(key,en,th,opts,cb)
 local r=row(56)
 titles(r,en,th)
 local holder=make("Frame",{Position=UDim2.fromOffset(14,26),Size=UDim2.new(1,-28,0,24),BackgroundTransparency=1},r)
 make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,5)},holder)
 local bs={}
 local function mark()
  for v,b in pairs(bs) do
   TS:Create(b,TI,{BackgroundColor3=(S[key]==v) and COL.Purple or COL.Bg}):Play()
  end
 end
 for _,o in ipairs(opts) do
  local b=make("TextButton",{Size=UDim2.new(1/#opts,-4,1,0),BackgroundColor3=COL.Bg,Text=o[2],Font=Enum.Font.GothamBold,TextSize=10,TextColor3=COL.Text,AutoButtonColor=false},holder)
  round(b,12)
  bs[o[1]]=b
  b.MouseButton1Click:Connect(function() S[key]=o[1] mark() cb(o[1]) save() end)
 end
 mark()
 NX.onAccent(function() mark() end)
 ctrls[key]=function(v,fire) S[key]=v mark() if fire then cb(v) end end
end

-- เลือกภาษา (ปุ่มใหญ่ ชัดเจน)
local function langRow()
 local r=row(60)
 titles(r,"Language","ภาษา (Language)")
 local holder=make("Frame",{Position=UDim2.fromOffset(14,26),Size=UDim2.new(1,-28,0,28),BackgroundTransparency=1},r)
 make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,8)},holder)
 local bs={}
 local function mark()
  for v,b in pairs(bs) do
   local on=(NX.getLang()==v)
   TS:Create(b,TI,{BackgroundColor3=on and COL.Purple or COL.Bg,TextColor3=on and Color3.new(1,1,1) or COL.Sub}):Play()
  end
 end
 for _,o in ipairs({{"TH","🌐 ไทย"},{"EN","🌐 English"}}) do
  local b=make("TextButton",{Size=UDim2.new(.5,-4,1,0),BackgroundColor3=COL.Bg,Text=o[2],Font=Enum.Font.GothamBlack,TextSize=12,TextColor3=COL.Sub,AutoButtonColor=false},holder)
  round(b,14)
  bs[o[1]]=b
  b.MouseButton1Click:Connect(function() NX.setLang(o[1]) end)
 end
 NX.onLang(mark)
 NX.onAccent(function() mark() end)
end

-- เลือกสีธีม
local PRESETS={
 {Color3.fromRGB(140,80,255),Color3.fromRGB(215,125,255)},
 {Color3.fromRGB(50,130,255),Color3.fromRGB(110,220,255)},
 {Color3.fromRGB(255,70,160),Color3.fromRGB(255,150,210)},
 {Color3.fromRGB(35,200,120),Color3.fromRGB(140,255,190)},
 {Color3.fromRGB(255,130,40),Color3.fromRGB(255,205,90)},
}
local function colorRow()
 local r=row(56)
 titles(r,"Theme color","สีธีม")
 local holder=make("Frame",{Position=UDim2.fromOffset(14,26),Size=UDim2.new(1,-28,0,24),BackgroundTransparency=1},r)
 make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,10)},holder)
 local sts={}
 local function mark()
  for i,s in ipairs(sts) do s.Transparency=(S.accent==i) and 0 or 1 end
 end
 for i,p in ipairs(PRESETS) do
  local b=make("TextButton",{Size=UDim2.fromOffset(24,24),BackgroundColor3=p[1],Text="",AutoButtonColor=false},holder)
  round(b,12)
  make("UIGradient",{Color=ColorSequence.new(p[1],p[2]),Rotation=45},b)
  sts[i]=make("UIStroke",{Color=Color3.new(1,1,1),Thickness=2,Transparency=1},b)
  b.MouseButton1Click:Connect(function() S.accent=i mark() NX.setAccent(p[1],p[2]) save() end)
 end
 mark()
 ctrls.accent=function(i) S.accent=i mark() NX.setAccent(PRESETS[i][1],PRESETS[i][2]) end
end

-- ===== ค้นหาเซิร์ฟเวอร์ =====
local function httpGet(url)
 local ok,res=pcall(function() return game:HttpGet(url) end)
 if ok and res and #res>0 then return res end
 local req=(syn and syn.request) or (http and http.request) or http_request or request
 if req then
  local ok2,r=pcall(req,{Url=url,Method="GET"})
  if ok2 and r and r.Body then return r.Body end
 end
end
local function findLow(status)
 local best,cursor
 for page=1,5 do
  status("🔎 "..T("Searching... page ","กำลังค้นหา... หน้า ")..page)
  local url="https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"..(cursor and ("&cursor="..cursor) or "")
  local body=httpGet(url)
  if not body then return nil,"http" end
  local ok,data=pcall(function() return HttpService:JSONDecode(body) end)
  if not ok or not data or not data.data then return nil,"parse" end
  for _,s in ipairs(data.data) do
   if s.id~=game.JobId and s.playing and s.playing<s.maxPlayers then
    if s.playing<=1 then return s end
    if not best or s.playing<best.playing then best=s end
   end
  end
  cursor=data.nextPageCursor
  if not cursor then break end
  task.wait(.5)
 end
 return nil,"none",best
end
local function findRandom()
 local body=httpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100")
 if not body then return nil,"http" end
 local ok,data=pcall(function() return HttpService:JSONDecode(body) end)
 if not ok or not data or not data.data then return nil,"parse" end
 local list={}
 for _,s in ipairs(data.data) do
  if s.id~=game.JobId and s.playing and s.playing<s.maxPlayers then list[#list+1]=s end
 end
 if #list==0 then return nil,"none" end
 return list[math.random(#list)]
end

-- ===== ฟังก์ชันเสริม =====
local afkConn
local function setAFK(v)
 if afkConn then afkConn:Disconnect() afkConn=nil end
 if v then
  local VU=game:GetService("VirtualUser")
  afkConn=lp.Idled:Connect(function() VU:CaptureController() VU:ClickButton2(Vector2.new()) end)
 end
end

local lightBackup
local function setFull(v)
 pcall(function()
  if v then
   if not lightBackup then
    lightBackup={Brightness=Lighting.Brightness,ClockTime=Lighting.ClockTime,FogEnd=Lighting.FogEnd,GlobalShadows=Lighting.GlobalShadows,Ambient=Lighting.Ambient,OutdoorAmbient=Lighting.OutdoorAmbient}
   end
   Lighting.Brightness=2
   Lighting.ClockTime=14
   Lighting.FogEnd=1e6
   Lighting.GlobalShadows=false
   Lighting.Ambient=Color3.fromRGB(180,180,180)
   Lighting.OutdoorAmbient=Color3.fromRGB(180,180,180)
  elseif lightBackup then
   for k,val in pairs(lightBackup) do Lighting[k]=val end
   lightBackup=nil
  end
 end)
end

local boostedFx,boostQ={},nil
local function setBoost(v)
 if v then
  pcall(function()
   if not boostQ then boostQ=settings().Rendering.QualityLevel end
   settings().Rendering.QualityLevel=Enum.QualityLevel.Level01
  end)
  pcall(function()
   for _,o in ipairs(workspace:GetDescendants()) do
    if (o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Smoke") or o:IsA("Fire") or o:IsA("Sparkles") or o:IsA("Beam")) and o.Enabled then
     o.Enabled=false
     boostedFx[#boostedFx+1]=o
    end
   end
  end)
 else
  pcall(function()
   if boostQ then settings().Rendering.QualityLevel=boostQ boostQ=nil end
  end)
  for _,o in ipairs(boostedFx) do pcall(function() o.Enabled=true end) end
  boostedFx={}
 end
end

local origFov
local function applyFov(v)
 local cam=workspace.CurrentCamera
 if cam then cam.FieldOfView=v end
end
local function setFovOn(v)
 local cam=workspace.CurrentCamera
 if not cam then return end
 if v then
  origFov=origFov or cam.FieldOfView
  cam.FieldOfView=S.fov
 elseif origFov then
  cam.FieldOfView=origFov
  origFov=nil
 end
end

------------------------------------------------------------------
-- สร้างเมนูตั้งค่า
------------------------------------------------------------------
header("SETTINGS","ตั้งค่า",true)

header("LANGUAGE","ภาษา")
langRow()

header("SERVER","เซิร์ฟเวอร์")
local pending,searching
button("Find empty server","หาเซิร์ฟเวอร์คนน้อย","Find a server with 0-1 players and join","ค้นหาเซิร์ฟที่มี 0–1 คน แล้ววาร์ปไป","Search","ค้นหา",function(d,bl)
 if searching then return end
 if pending then
  d.Text="🚀 "..T("Teleporting...","กำลังวาร์ป...")
  pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId,pending.id,lp) end)
  return
 end
 searching=true
 task.spawn(function()
  local s,err,best=findLow(function(t) d.Text=t end)
  searching=false
  if s then
   d.Text="✅ "..T("Found ","พบเซิร์ฟ ")..s.playing..T(" player, joining..."," คน กำลังวาร์ป...")
   pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId,s.id,lp) end)
  elseif best then
   pending=best
   d.Text="⚠ "..T("None with 0-1. Lowest: ","ไม่พบ 0–1 คน ต่ำสุดคือ ")..best.playing..T(" - press again to join"," คน กดอีกครั้งเพื่อไป")
   bl.Text=T("Join","ไป")
  else
   d.Text="❌ "..((err=="none") and T("No server found","ไม่พบเซิร์ฟเวอร์") or T("Request failed (HttpGet blocked?)","เรียกข้อมูลไม่ได้ (executor อาจไม่รองรับ)"))
  end
 end)
end,true)
local hopping
button("Server hop","สุ่มเปลี่ยนเซิร์ฟเวอร์","Join a random different server","สุ่มเข้าเซิร์ฟเวอร์อื่น","Hop","สลับ",function(d)
 if hopping then return end
 hopping=true
 d.Text="🔎 "..T("Searching...","กำลังค้นหา...")
 task.spawn(function()
  local s,err=findRandom()
  hopping=false
  if s then
   d.Text="🚀 "..T("Teleporting...","กำลังวาร์ป...")
   pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId,s.id,lp) end)
  else
   d.Text="❌ "..((err=="none") and T("No server found","ไม่พบเซิร์ฟเวอร์") or T("Request failed","เรียกข้อมูลไม่ได้"))
  end
 end)
end,true)
button("Rejoin","รีจอยเซิร์ฟเวอร์นี้","Rejoin the current server","เข้าเซิร์ฟเวอร์เดิมใหม่","Rejoin","รีจอย",function()
 if #Players:GetPlayers()<=1 then
  pcall(function() TeleportService:Teleport(game.PlaceId,lp) end)
 else
  pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId,game.JobId,lp) end)
 end
end)
button("Copy Job ID","คัดลอก Job ID","Copy this server's ID","คัดลอกไอดีเซิร์ฟเวอร์นี้","Copy","คัดลอก",function(d,bl)
 pcall(function() setclipboard(game.JobId) end)
 local o=bl.Text bl.Text="✔"
 task.delay(1,function() bl.Text=o end)
end)
button("Copy game link","คัดลอกลิงก์เกม","Copy this game's Roblox link","คัดลอกลิงก์เกมนี้","Copy","คัดลอก",function(d,bl)
 pcall(function() setclipboard("https://www.roblox.com/games/"..game.PlaceId) end)
 local o=bl.Text bl.Text="✔"
 task.delay(1,function() bl.Text=o end)
end)

header("APPEARANCE","หน้าตา GUI")
slider("scale","GUI size","ขนาด GUI",.7,1.3,function(v) return math.floor(v*100+.5).."%" end,true,function(v)
 if NX.isOpen() then TS:Create(NX.sc,TweenInfo.new(.25,Enum.EasingStyle.Quint),{Scale=v}):Play() end
end)
slider("alpha","Transparency","ความโปร่งใส",0,.6,function(v) return math.floor(v*100+.5).."%" end,false,function(v)
 if NX.isOpen() then NX.win.GroupTransparency=v end
end)
colorRow()
toggle("space","Space effects","เอฟเฟกต์อวกาศ","Stars, nebula, shooting stars","ดาว เนบิวลา ดาวตก",function(v) NX.setSpace(v) end)
toggle("fx","Logo effects","เอฟเฟกต์โลโก้","Orbit, shine and ripple on the logo","วงโคจร แสงวิบ และระลอกที่โลโก้",function(v) NX.setLogoFx(v) end)
button("Reset GUI position","รีเซ็ตตำแหน่ง GUI","Move window and logo back to default","ย้ายหน้าต่างและโลโก้กลับที่เดิม","Reset","รีเซ็ต",function(d,bl)
 NX.resetPos()
 local o=bl.Text bl.Text="✔"
 task.delay(1,function() bl.Text=o end)
end)

header("GRAPHICS","กราฟิก")
do
 local r=row(58)
 L(txt(r,{Position=UDim2.fromOffset(14,6),Size=UDim2.new(1,-150,0,16),TextSize=12}),"Field of view (FOV)","มุมมอง (FOV)")
 local vl=txt(r,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-100,0,6),Size=UDim2.fromOffset(50,16),TextSize=11,TextColor3=COL.Pink,TextXAlignment=Enum.TextXAlignment.Right})
 local st=txt(r,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-58,0,7),Size=UDim2.fromOffset(30,14),Font=Enum.Font.GothamBlack,TextSize=10,TextXAlignment=Enum.TextXAlignment.Right})
 local sw=make("TextButton",{Text="",AutoButtonColor=false,Size=UDim2.fromOffset(38,20),Position=UDim2.new(1,-52,0,5),BackgroundColor3=COL.Bg},r)
 round(sw,10)
 local sk=make("Frame",{Size=UDim2.fromOffset(14,14),Position=UDim2.fromOffset(3,3),BackgroundColor3=Color3.new(1,1,1)},sw)
 round(sk,7)
 local track=make("Frame",{Position=UDim2.new(0,14,0,40),Size=UDim2.new(1,-28,0,6),BackgroundColor3=COL.Bg},r)
 round(track,3)
 local fill=make("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=COL.Purple},track)
 round(fill,3)
 local knob=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(0,.5),Size=UDim2.fromOffset(14,14),BackgroundColor3=Color3.new(1,1,1)},track)
 round(knob,7)
 NX.onAccent(function(a) fill.BackgroundColor3=a if S.fovOn then sw.BackgroundColor3=a end end)
 local hit=make("TextButton",{Text="",BackgroundTransparency=1,Position=UDim2.new(0,14,0,28),Size=UDim2.new(1,-28,0,26)},r)
 local function showV(v)
  local t=(v-50)/70
  fill.Size=UDim2.fromScale(t,1) knob.Position=UDim2.fromScale(t,.5)
  vl.Text=math.floor(v+.5).."°"
 end
 local function setV(v,fire)
  v=math.clamp(v,50,120) S.fov=v showV(v)
  if fire and S.fovOn then applyFov(v) end
 end
 local function setOn(v,fire)
  S.fovOn=v
  TS:Create(sw,TI,{BackgroundColor3=v and COL.Purple or COL.Bg}):Play()
  TS:Create(sk,TI,{Position=v and UDim2.fromOffset(21,3) or UDim2.fromOffset(3,3)}):Play()
  TS:Create(fill,TI,{BackgroundTransparency=v and 0 or .6}):Play()
  st.Text=v and "ON" or "OFF"
  st.TextColor3=v and COL.Green or COL.Sub
  if fire then setFovOn(v) save() end
 end
 sw.MouseButton1Click:Connect(function() setOn(not S.fovOn,true) end)
 local dragging=false
 local function isPtr(i) return i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch end
 local function fromX(x)
  local t=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
  setV(50+70*t,true)
 end
 hit.InputBegan:Connect(function(i) if isPtr(i) then dragging=true fromX(i.Position.X) end end)
 UIS.InputChanged:Connect(function(i)
  if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then fromX(i.Position.X) end
 end)
 UIS.InputEnded:Connect(function(i)
  if dragging and isPtr(i) then dragging=false save() end
 end)
 setV(S.fov,false) setOn(S.fovOn,false)
 ctrls.fov=setV ctrls.fovOn=setOn
end
toggle("fullbright","Fullbright","แสงสว่างเต็มที่","Remove darkness and fog","ลบความมืดและหมอก",setFull)
toggle("boost","FPS booster","เพิ่ม FPS","Lower quality + disable particles","ลดกราฟิกและปิดพาร์ติเคิล",setBoost)

header("GENERAL","ทั่วไป")
toggle("afk","Anti-AFK","กันหลุดเมื่อ AFK","Prevents idle kick (20 min)","กันโดนเตะเมื่อไม่ขยับ",setAFK)
segmented("fps","FPS cap","ล็อก FPS",{{30,"30"},{60,"60"},{120,"120"},{240,"240"},{0,"∞"}},function(v)
 pcall(function() if setfpscap then setfpscap(v==0 and 999 or v) end end)
end)
toggle("key","Hotkey (RightShift)","คีย์ลัด (RightShift)","Show / hide GUI with RightShift","ซ่อน/แสดง GUI ด้วย RightShift",function(v) S.key=v end)
button("Reset character","รีเซ็ตตัวละคร","Respawn your character","เกิดใหม่","Reset","รีเซ็ต",function()
 local ch=lp.Character
 local h=ch and ch:FindFirstChildOfClass("Humanoid")
 if h then h.Health=0 end
end)

header("COMMUNITY","ชุมชน")
button("Discord","ดิสคอส","Copy the Discord invite link","คัดลอกลิงก์เชิญดิสคอส","Copy","คัดลอก",function(d,bl)
 local ok=pcall(function() setclipboard(NX.CFG.DISCORD_LINK) end)
 local o=bl.Text bl.Text=ok and "✔" or "✖"
 task.delay(1,function() bl.Text=o end)
end)

header("MANAGE","จัดการ")
button("Reset settings","รีเซ็ตการตั้งค่า","Restore default GUI settings","คืนค่าตั้งต้นของ GUI","Reset","รีเซ็ต",function()
 for k,v in pairs(DEF) do S[k]=v end
 for k,v in pairs(DEF) do
  if ctrls[k] then ctrls[k](v,true) end
 end
 save()
end)
button("Unload GUI","ปิดสคริปต์","Remove the GUI and undo changes","ลบ GUI และคืนค่าที่แก้ไว้","Unload","ปิด",function()
 setFull(false) setBoost(false) setAFK(false) setFovOn(false)
 NX.gui:Destroy()
end)

-- ใช้ค่าที่บันทึกไว้ตอนเริ่ม
ctrls.accent(S.accent)
NX.setSpace(S.space)
NX.setLogoFx(S.fx)
setAFK(S.afk)
pcall(function() if setfpscap and S.fps~=0 then setfpscap(S.fps) end end)
if S.fullbright then setFull(true) end
if S.boost then setBoost(true) end
if S.fovOn then setFovOn(true) end
task.spawn(function()
 while NX.gui.Parent do
  if S.fovOn and S.fov then applyFov(S.fov) end
  task.wait(.5)
 end
end)
end

------------------------------------------------------------------
-- เริ่มทำงาน: รอหน้าโหลดจบ แล้วเด้งโลโก้ + เปิดหน้าต่าง
------------------------------------------------------------------
do
 local NX=getgenv().NX
 NX.setLang(NX.state.lang or "TH")
 Loader.finish(function()
  if not NX.gui.Parent then return end
  TS:Create(logo,TweenInfo.new(.5,Enum.EasingStyle.Back),{Size=UDim2.fromOffset(LS,LS)}):Play()
  task.delay(.6,function() NX.setOpen(true) end)
 end)
end
