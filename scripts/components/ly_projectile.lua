local Ly_Projectile = Class(function(self, inst)
    self.inst = inst
    self.owner = nil   
    self.target = nil  
    self.start = nil
    self.dest = nil
    self.speed = nil
	self.onthrown = nil 
    self.hitdist = 1.5  
    self.dohit = true
    self.range = nil  
    self.onhit = nil
    self.onmiss = nil
	self.canhit = nil 
	self.damage = 0
	self.launchoffset = Vector3(0.5, 0, 0)
	
	self.onfreeupdate = nil 
	
	inst:AddTag("projectile")
end)

local function getdis(pos1,pos2)
	local dx = pos1.x - pos2.x
	local dy = pos1.y - pos2.y
	local dz = pos1.z - pos2.z
	return math.sqrt(dx*dx + dy*dy + dz * dz)
end 

function Ly_Projectile:CopyFrom(component)
	component = component or self.inst.components.projectile or nil 
	if component then 
		self:SetSpeed(component.speed)
		self:SetRange(component.range)
		self:SetOnThrownFn(component.onthrown)
		self:SetHitDist(component.hitdist)
		self:SetOnHitFn(component.onhit)
		self:SetOnMissFn(component.onmiss)
		self:SetLaunchOffset(component.launchoffset)
	end 
end 

function Ly_Projectile:GetDebugString()
    return string.format("target: %s, owner %s", tostring(self.target), tostring(self.owner) )
end

function Ly_Projectile:SetOnFreeUpdateFn(fn)
	self.onfreeupdate = fn  
end 

function Ly_Projectile:SetSpeed(speed) 
    self.speed = speed
end

function Ly_Projectile:SetRange(range) 
    self.range = range
end

function Ly_Projectile:SetOnThrownFn(fn)
    self.onthrown = fn
end

function Ly_Projectile:SetHitDist(dist) 
    self.hitdist = dist
end

function Ly_Projectile:SetOnHitFn(fn)  
    self.onhit = fn
end

function Ly_Projectile:SetOnMissFn(fn)  
    self.onmiss = fn
end

function Ly_Projectile:SetLaunchOffset(offset)
    self.launchoffset = offset 
end

function Ly_Projectile:SetCanHit(fn)
	self.canhit = fn 
end 

function Ly_Projectile:SetSuitabel()
	self.inst:DoTaskInTime(25,self.inst.Remove)
	self.inst.persists = false
	self.inst:DoTaskInTime(0.3,function()
		self.inst:ListenForEvent("entitysleep",self.inst.Remove)
	end)
end 

function Ly_Projectile:Throw(owner, dest,can_updata,startfn,no_suitable)
    self.owner = owner
    self.start = Vector3(owner.Transform:GetWorldPosition() ) 
    self.dest = dest 
    local offset = self.launchoffset or Vector3(0,0,0)
	local x, y, z = self.inst.Transform:GetWorldPosition() 
	local facing_angle = owner.Transform:GetRotation() * DEGREES
    if owner ~= nil and offset ~= nil then
       
        self.inst.Transform:SetPosition(x + offset.x * math.cos(facing_angle), y + offset.y, z - offset.x * math.sin(facing_angle))
    end
	if startfn then 
		startfn(self.inst)
	end 
    self:RotateToTarget(self.dest)
	local dy = math.abs( (y + offset.y) - self.dest.y )
	local dx = math.abs( (x + offset.x * math.cos(facing_angle)) - self.dest.x )
	
	
	if self.onthrown ~= nil then
        self.onthrown(self.inst, owner)
    end
	
	if not self.onfreeupdate then 
		local dist = self.start:Dist(dest)
		local time = dist / self.speed
		local speed_y =  - dy / time
		self.inst.Physics:SetMotorVel(self.speed,speed_y/3,0)
	else
		self.onfreeupdate(self.inst,dest,0)
	end 
	
	self.inst:PushEvent("onthrown", { thrower = owner})
	
	if can_updata  then 
		self.inst:StartUpdatingComponent(self)
		if not no_suitable then  
			self:SetSuitabel()
		end 
	end 
end

function Ly_Projectile:Miss()
    local owner = self.owner
    self:Stop()
    if self.onmiss then
        self.onmiss(self.inst, owner)
    end
end

function Ly_Projectile:Stop()
    self.inst:StopUpdatingComponent(self)
	self.inst.Physics:Stop()
    self.target = nil
    self.owner = nil
end

function Ly_Projectile:ProbalyHit(v)
	return v and v:IsValid() and not v:IsInLimbo() 
		and v ~=self.owner and (self.canhit and self.canhit(self.inst,self.owner,v) or self.canhit == nil)
		and v.components.health ~=nil and v.components.combat ~=nil  and not v.components.health:IsDead()
end 

function Ly_Projectile:CanHit(v)
	return v and v:IsValid() and not v:IsInLimbo()
	and getdis(v:GetPosition(),self.inst:GetPosition()) < self.hitdist + (v.Physics and v.Physics:GetRadius() or 0) 
	and v ~=self.owner and (self.canhit and self.canhit(self.inst,self.owner,v) or self.canhit == nil)
	and v.components.health ~=nil and v.components.combat ~=nil  and not v.components.health:IsDead()
end 

function Ly_Projectile:Hit(target,owner)
	local attacker = owner
    local weapon = self.inst
	if target.components.combat then
		target.components.combat:GetAttacked(self.owner, self.damage ,self.inst)
        target.components.combat:SuggestTarget(self.owner)
	end
    
	self.inst:PushEvent("lyprojectilehit",{owner = owner,target = target})
	
	if self.onhit then
        self.onhit(self.inst, self.owner, target)
    end  
	self:Stop()
end



function Ly_Projectile:OnUpdate(dt)
	local x,y,z =  self.inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x,0,z, self.hitdist)
    local dest = self.dest
    local current = Vector3(self.inst.Transform:GetWorldPosition() )
    local direction = (dest - current):GetNormalized()
    local projectedSpeed = self.speed*TheSim:GetTickTime()*TheSim:GetTimeScale()
    local projected = current + direction*projectedSpeed
    local coveredDistSq = distsq(self.start, current)
	
	if self.onfreeupdate then 
		self.onfreeupdate(self.inst,dest,dt)
	end 
	
    if self.range and coveredDistSq > self.range*self.range then
        self:Miss() 
    elseif self.dohit then
		for i,v in pairs(ents) do 
			if self:CanHit(v) then
				self.target = v
				self:Hit(v,self.owner)
				break
			end
		end
    else
    end   
end

function Ly_Projectile:RotateToTarget(dest)
    local current = Vector3(self.inst.Transform:GetWorldPosition() )
    local direction = (dest - current):GetNormalized()
    local angle = math.acos(direction:Dot(Vector3(1, 0, 0) ) ) / DEGREES
    self.inst.Transform:SetRotation(angle)
    self.inst:FacePoint(dest)
end

return Ly_Projectile
