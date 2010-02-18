--[[	
	Elements handled: .ResComm
	
	Boolean:
	 - OthersOnly: Defines whether the player's resurrection triggers the element or not. (Default: nil)
]]

local _, ns = ...
local oUF = ns.oUF or oUF

local libResComm = LibStub("LibResComm-1.0")
local playerName = UnitName("player")

local Update = function(self, event, destUnit)
	local resComm = self.ResComm
	local unitName, unitRealm = UnitName(destUnit)
	
	if unitName and unitRealm and unitRealm ~= "" then
		unitName = unitName .. "-" .. unitRealm
	elseif not unitName then
		unitName = destUnit
	end
	
	if resComm then
		local beingRessed, resserName = libResComm:IsUnitBeingRessed(unitName)
		
		if (beingRessed and not (resComm.OthersOnly and resserName == playerName)) then
			resComm:Show()
		else
			resComm:Hide()
		end
	end
end

local Enable = function(self)
	local resComm = self.ResComm
	
	if resComm then		
		if resComm:IsObjectType("Texture") and not resComm:GetTexture() then
			resComm:SetTexture([=[Interface\Icons\Spell_Holy_Resurrection]=])
		end
		
		return true
	end
end

oUF:AddElement("ResComm", Update, Enable, nil)

local ResComm_Update = function(event)
	local destUnit
	for _, frame in ipairs(oUF.objects) do
		if frame.unit then
			destUnit = frame.unit
			Update(frame, event, destUnit)
		end
	end
end

libResComm.RegisterCallback("oUF_ResComm", "ResComm_ResStart", ResComm_Update)
libResComm.RegisterCallback("oUF_ResComm", "ResComm_ResEnd", ResComm_Update)