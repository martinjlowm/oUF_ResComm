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
local GetTime = GetTime
local UnitName = UnitName
local next = next

local onUpdate
do
	local duration
	onUpdate = function(self, elapsed)
		duration = self.duration + elapsed
		
		self.duration = duration
		self:SetValue(duration)
	end
end

local Update = function(self, event, unit)
	local resComm = self.ResComm
	
	if (not resComm) then
		return
	end
	
	if (not UnitIsDead(unit)) then
		resComm:Hide()
		return
	end
	
	if (event == "ResComm_CanRes" or event == "ResComm_Ressed") then
		if (resComm:IsObjectType("Statusbar")) then
			resComm:SetMinMaxValues(0, 1)
			resComm:SetValue(1)
		end
		
		resComm:Show()
	elseif (event == "ResComm_ResExpired") then
		resComm:Hide()
	elseif (event == "ResComm_ResStart") then
		if (resComm:IsObjectType("Statusbar")) then
			resComm.duration = 0
			resComm:SetValue(0)
			
			resComm:SetScript("OnUpdate", onUpdate)
		end
		
		resComm:Show()
	elseif (event == "ResComm_ResEnd") then
		if (resComm:IsObjectType("Statusbar")) then
			resComm:SetScript("OnUpdate", nil)
		end
		
		resComm:Hide()
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
		
		resComm:RegisterEvent("UNIT_HEALTH", Path)
		resComm:Hide()
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
		resComm:UnregisterEvent("UNIT_HEALTH")
		
		if (resComm:IsObjectType("Statusbar") and resComm:GetScript("OnUpdate")) then
			resComm:SetScript("OnUpdate", nil)
		end
	end
end

oUF:AddElement("ResComm", Path, Enable, Disable)

ResComm_Shared = function(event, ...)
	local sender, endTime, target
	if (select("#", ...) == 3) then
		sender, endTime, target = ...
	elseif (select("#", ...) == 2) then
		sender, target = ...
	else
		target = ...
	end
	
	local name, resComm
	for _, frame in next, oUF.objects do
		name = frame.unit and UnitName(frame.unit)
		resComm = frame.ResComm
		if (name == target and resComm) then
			if (not sender or not (resComm.OthersOnly and sender == playerName)) then
				if (endTime and resComm:IsObjectType("Statusbar")) then
					local maxValue = endTime - GetTime()
					
					resComm.endTime = maxValue
					resComm:SetMinMaxValues(0, maxValue)
				end
				
				Path(frame, event, frame.unit)
			end
		end
	end
end

libResComm.RegisterCallback("oUF_ResComm", "ResComm_CanRes", ResComm_Shared)
libResComm.RegisterCallback("oUF_ResComm", "ResComm_Ressed", ResComm_Shared)
libResComm.RegisterCallback("oUF_ResComm", "ResComm_ResExpired", ResComm_Shared)
libResComm.RegisterCallback("oUF_ResComm", "ResComm_ResStart", ResComm_Shared)
libResComm.RegisterCallback("oUF_ResComm", "ResComm_ResEnd", ResComm_Shared)