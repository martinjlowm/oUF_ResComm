--[[
	Elements handled: .ResComm
	
	Optional:
	 - .OthersOnly: (boolean) Defines whether the player's resurrection triggers the element or not.
	   (Default: nil)
]]

local _, ns = ...
local oUF = ns.oUF or oUF

local libResComm = LibStub("LibResComm-1.0")
local playerName = UnitName("player")
local UnitName = UnitName
local next = next

local onUpdate
do
	local duration
	onUpdate = function(self, elapsed)
		duration = self.duration + elapsed
		
		if (duration >= self.endTime) then
			self:Hide()
		end
		
		self.duration = duration
		self:SetValue(duration)
	end
end

local Update = function(self, event, unit, endTime)
	if (not event or event == "VehicleSwitch") then
		return
	end
	
	local resComm = self.ResComm
	if (not resComm) then
		return
	end
	
	if (event == "ResComm_CanRes") then
		if (resComm:IsObjectType("Statusbar")) then
			resComm:SetMinMaxValues(0, 1)
			resComm:SetValue(1)
		end
		
		resComm:Show()
	elseif (event == "ResComm_Ressed") then
		resComm:Hide()
	else
		local beingRessed = libResComm:IsUnitBeingRessed(UnitName(unit))
		if (beingRessed) then
			if (resComm:IsObjectType("Statusbar") and endTime and (not resComm:GetScript("OnUpdate"))) then
				local maxValue = endTime - GetTime()
				
				resComm.duration = 0
				resComm.endTime = maxValue
				resComm:SetMinMaxValues(0, maxValue)
				resComm:SetValue(0)
				
				resComm:SetScript("OnUpdate", onUpdate)
			end
			
			resComm:Show()
		else
			if (resComm:IsObjectType("Statusbar")) then
				resComm.duration = 0
				resComm.endTime = 0
				
				resComm:SetScript("OnUpdate", nil)
			end
			
			resComm:Hide()
		end
	end
end

local Path = function(self, ...)
	return (self.ResComm.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local Enable = function(self)
	local resComm = self.ResComm
	if (resComm) then
		resComm.__owner = self
		resComm.ForceUpdate = ForceUpdate
		
		if (resComm:IsObjectType("Texture") and not resComm:GetTexture()) then
			resComm:SetTexture([=[Interface\Icons\Spell_Holy_Resurrection]=])
		elseif (resComm:IsObjectType("Statusbar") and not resComm:GetStatusBarTexture():GetTexture()) then
			resComm:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
		end
		
		return true
	end
end

local Disable = function(self)
	local resComm = self.ResComm
	if (resComm) then
		if (resComm:IsObjectType("Statusbar") and resComm:GetScript("OnUpdate")) then
			resComm:SetScript("OnUpdate", nil)
		end
	end
end

oUF:AddElement("ResComm", Path, Enable, Disable)

local ResComm_ResStart = function(event, sender, endTime, target)
	local name
	for _, frame in next, oUF.objects do
		name = frame.unit and UnitName(frame.unit)
		if (name == target and frame.ResComm) then
			if (not (frame.ResComm.OthersOnly and sender == playerName)) then
				Path(frame, event, frame.unit, endTime)
			end
		end
	end
end

local ResComm_ResEnd = function(event, sender, target)
	local name
	for _, frame in next, oUF.objects do
		name = frame.unit and UnitName(frame.unit)
		if (name == target and frame.ResComm) then
			Path(frame, event, frame.unit)
		end
	end
end

local ResComm_Shared = function(event, target)
	local name
	for _, frame in next, oUF.objects do
		name = frame.unit and UnitName(frame.unit)
		if (name == target and frame.ResComm) then
			Path(frame, event, frame.unit)
		end
	end
end

libResComm.RegisterCallback("oUF_ResComm", "ResComm_CanRes", ResComm_Shared)
libResComm.RegisterCallback("oUF_ResComm", "ResComm_Ressed", ResComm_Shared)
libResComm.RegisterCallback("oUF_ResComm", "ResComm_ResStart", ResComm_ResStart)
libResComm.RegisterCallback("oUF_ResComm", "ResComm_ResEnd", ResComm_ResEnd)
