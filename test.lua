local librescomm = LibStub("LibResComm-1.0")

local function Update(self)
	if not self.unit or not UnitIsConnected(self.unit) then
		return Hide(self)
	end

	local maxHP = UnitHealthMax(self.unit) or 0
	if maxHP == 0 or maxHP == 100 then return Hide(self) end

	local guid = UnitGUID(self.unit)
	local incHeals = self.HealCommOthersOnly and healcomm:GetOthersHealAmount(guid, healcomm.ALL_HEALS) or not self.HealCommOthersOnly and healcomm:GetHealAmount(guid, healcomm.ALL_HEALS) or 0
	if incHeals == 0 then return Hide(self) end

	incHeals = incHeals * healcomm:GetHealModifier(guid)

	if self.HealCommBar then
		local curHP = UnitHealth(self.unit)
		local percHP = curHP / maxHP
		local percInc = (self.allowHealCommOverflow and incHeals or math.min(incHeals, maxHP - curHP)) / maxHP

		self.HealCommBar:ClearAllPoints()

		if self.Health:GetOrientation() == "VERTICAL" then
			self.HealCommBar:SetHeight(percInc * self.Health:GetHeight())
			self.HealCommBar:SetWidth(self.Health:GetWidth())
			self.HealCommBar:SetPoint("BOTTOM", self.Health, "BOTTOM", 0, self.Health:GetHeight() * percHP)
		else
			self.HealCommBar:SetHeight(self.Health:GetHeight())
			self.HealCommBar:SetWidth(percInc * self.Health:GetWidth())
			self.HealCommBar:SetPoint("LEFT", self.Health, "LEFT", self.Health:GetWidth() * percHP, 0)
		end

		self.HealCommBar:Show()
	end

	if self.HealCommText then self.HealCommText:SetText(self.HealCommTextFormat and self.HealCommTextFormat(incHeals) or format("%d", incHeals)) end
end


local function Enable(self)
	local rescomm = self.ResComm
	
	if rescomm then
		self:RegisterEvent("UNIT_HEALTH", Update)
		
		if not rescomm:IsObjectType("Texture") and not rescomm:GetTexture() then
			rescomm:SetTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		return true
	end
end


local function Disable(self)
	local rescomm = self.ResComm
	
	if rescomm then
		self:UnregisterEvent("UNIT_HEALTH", Update)
	end
end

oUF:AddElement('ResComm', Update, Enable, Disable)

local function MultiUpdate(...)
	for i = 1, select("#", ...) do
		for _, frame in ipairs(oUF.objects) do
			if frame.unit and (frame.HealCommBar or frame.HealCommText) and UnitGUID(frame.unit) == select(i, ...) then Update(frame) end
		end
	end
end


local function ResStart(event, casterGUID, spellID, healType, _, ...)
	MultiUpdate(...)
end

"oUF_ResComm", "ResComm_ResStart", ResComm_Heal_Update
librescomm.RegisterCallback("oUF_ResComm", "ResComm_ResStart", ResStart)
-- lib.Callbacks:Fire("ResComm_ResStart", playerName, endTime, target)
-- lib.Callbacks:Fire("ResComm_ResStart", sender, endTime, targetName)

librescomm.RegisterCallback("oUF_ResComm", "ResComm_ResEnd")
-- lib.Callbacks:Fire("ResComm_ResEnd", sender, target)

librescomm.RegisterCallback("oUF_ResComm", "ResComm_Ressed")
-- lib.Callbacks:Fire("ResComm_Ressed", sender)

librescomm.RegisterCallback("oUF_ResComm", "ResComm_CanRes")
-- lib.Callbacks:Fire("ResComm_CanRes", sender)

librescomm.RegisterCallback("oUF_ResComm", "ResComm_ResExpired")
-- lib.Callbacks:Fire("ResComm_ResExpired",sender)