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

local Update = function(self, event, destUnit, endTime)
	local resComm = self.ResComm
	
	if (resComm) then
		local unitName, unitRealm = UnitName(destUnit)
		
		if (unitName and unitRealm and unitRealm ~= "") then
			unitName = unitName .. "-" .. unitRealm
		elseif (not unitName) then
			unitName = destUnit
		end
		
		local beingRessed, resserName = libResComm:IsUnitBeingRessed(unitName)
		if (beingRessed and (not (resComm.OthersOnly and resserName == playerName))) then
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

oUF:AddElement("ResComm", Path, Enable, nil)

local ResComm_Update = function(event, ...)
	local endTime = type(select(2, ...)) == "number" and select(2, ...) or nil
	
	local destUnit
	for _, frame in next, oUF.objects do
		if (frame.unit and frame.ResComm) then
			destUnit = frame.unit
			Update(frame, event, destUnit, endTime)
		end
	end
end

libResComm.RegisterCallback("oUF_ResComm", "ResComm_ResStart", ResComm_Update)
libResComm.RegisterCallback("oUF_ResComm", "ResComm_ResEnd", ResComm_Update)