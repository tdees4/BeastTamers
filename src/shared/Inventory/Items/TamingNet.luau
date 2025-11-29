local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BaseTool = require(ReplicatedStorage.Shared.Inventory.Items.BaseTool)
local Interfaces = require(ReplicatedStorage.Shared.Inventory.Interfaces)

local TamingNet = setmetatable({}, BaseTool)
TamingNet.__index = TamingNet

function TamingNet.new(name: string, tier: number)
  local self = BaseTool.new(name, tier)
  setmetatable(self, TamingNet)

  local data = self.DataRef

  self.CaptureModifier = data.CaptureModifier

  return self :: Interfaces.TamingNet
end

function TamingNet.fromData(data)
  local self = BaseTool.fromData(data)
  setmetatable(self, TamingNet)

  local dataRef = self.DataRef

  self.CaptureModifier = data.CaptureModifier or dataRef.CaptureModifier

  return self :: Interfaces.TamingNet
end

-- ==================
-- Taming Net Methods
-- ==================

function TamingNet:GetCaptureParameters(creatureRarityTier: number)
  local creatureDifficulty = creatureRarityTier * 0.15

  local finalDifficulty = creatureDifficulty - self.CaptureModifier

  return math.max(0.1, finalDifficulty)
end

function TamingNet:DecreaseDurability(amount: number)
  if self.Tier == 1 then
    return false
  end

  return BaseTool.DecreaseDurability(self, amount)
end

return TamingNet