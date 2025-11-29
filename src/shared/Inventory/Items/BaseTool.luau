-- BaseTool should never be DIRECTLY instatiated --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BaseItem = require(ReplicatedStorage.Shared.Inventory.Items.BaseItem)
local ItemTypes = require(ReplicatedStorage.Shared.Inventory.Items.ItemTypes)
local Interfaces = require(ReplicatedStorage.Shared.Inventory.Interfaces)

local BaseTool = setmetatable({}, BaseItem)
BaseTool.__index = BaseTool

function BaseTool.new(name: string, tier: number)
  local self = BaseItem.new(name, ItemTypes.Tool)
  setmetatable(self, BaseTool)

  assert(self.Type == ItemTypes.Tool, "BaseTool: Attempted to instantiate non-Tool type.")
  assert(self.ModelPath, "BaseTool: Attempted to instantiate tool without a model path.")

  local data = self.DataRef

  self.Tier = tier or data.Tier
  self.MaxDurability = data.MaxDurability or 100
  self.Durability = data.MaxDurability

  self.IsEquipped = false

  return self :: Interfaces.BaseToolInterface
end

function BaseTool.fromData(data)
  local self = BaseItem.fromData(data)
  setmetatable(self, BaseTool)

  local dataRef = self.DataRef

  self.Durability = data.Durability or dataRef.MaxDurability
  self.MaxDurability = dataRef.MaxDurability or 100
  self.IsEquipped = false

  return self :: Interfaces.BaseToolInterface
end

-- =================
-- Base Tool Methods
-- =================

--[[
Decreases the durability of the tool.

@param amount The amount to decrease the durability by

@returns true if the tool has 0 durability left, false otherwise.
]]
function BaseTool:DecreaseDurability(amount: number?): boolean
  local reduction = amount or 1
  self.Durability = math.max(0, self.Durability - reduction)

  if self.Durability <= 0 then
    warn(self.Name.." has broken!")
    return true
  end
  return false
end

--[[
Repair the tool to max durability.
]]
function BaseTool:RepairDurability()
  self.Durability = self.DataRef.MaxDurability
  -- Handle repair remotevents and whatnot here
end

--[[
Set whether the tool is equipped or not

@param equipped Whether the item should be equipped or not
]]
function BaseTool:SetEquipped(equipped: boolean)
  self.IsEquipped = equipped
  -- Handle equipping remotevents and whatnot here
end

--[[
@returns true if the tool is equipped and has durability, false otherwise
]]
function BaseTool:IsUsable(): boolean
  return self.Durability > 0 and self.IsEquipped
end

function BaseTool:ToData()
  local data = BaseItem.ToData(self)

  data.Durability = self.Durability

  return data
end

return BaseTool