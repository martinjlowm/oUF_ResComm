local _, ns = ...
local oUF = ns.oUF or oUF

local libResComm = LibStub("LibResComm-1.0")
local playerName = UnitName("player")

local Update = function(self)
	local resComm = self.ResComm
	
	if resComm then
		local unitName = UnitName(self.unit)
		local beingRessed, resser = libResComm.IsUnitBeingRessed(unitName)
		print(beingRessed, resser)
		if beingRessed and resser ~= playerName then
			resComm:Show()
		else
			resComm:Hide()
		end
	end
end

local Enable = function(self)
	local resComm = self.ResComm
	
	if resComm then
		--self:RegisterEvent("UNIT_HEALTH", Update)
		
		if resComm:IsObjectType("Texture") and not resComm:GetTexture() then
			resComm:SetTexture([=[Interface\Icons\Spell_Holy_Resurrection]=])
		end
		
		return true
	end
end

local Disable = function(self)
	local resComm = self.ResComm
	
	if resComm then
		--self:UnregisterEvent("UNIT_HEALTH", Update)
	end
end

oUF:AddElement("ResComm", Update, Enable, Disable)

local ResComm_Update = function(...)
	print("Test for casting " .. ...)
	for _, frame in ipairs(oUF.objects) do
		if frame.unit then
			Update(frame)
		end
	end
end

libResComm.RegisterCallback("oUF_ResComm", "ResComm_ResStart", ResComm_Update)
libResComm.RegisterCallback("oUF_ResComm", "ResComm_ResEnd", ResComm_Update)
libResComm.RegisterCallback("oUF_ResComm", "ResComm_Ressed", ResComm_Update)
libResComm.RegisterCallback("oUF_ResComm", "ResComm_CanRes", ResComm_Update)
libResComm.RegisterCallback("oUF_ResComm", "ResComm_ResExpired", ResComm_Update)