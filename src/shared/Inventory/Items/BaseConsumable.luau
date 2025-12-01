-- BaseConsumable should never be DIRECTLY instatiated --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BaseItem = require(ReplicatedStorage.Shared.Inventory.Items.BaseItem)
local ItemTypes = require(ReplicatedStorage.Shared.Inventory.Items.ItemTypes)
local Interfaces = require(ReplicatedStorage.Shared.Inventory.Interfaces)

local BaseConsumable = setmetatable({}, BaseItem)
BaseConsumable.__index = BaseConsumable

function BaseConsumable.new(name: string, tier: number): Interfaces.BaseConsumableInterface
  local self = BaseItem.new(name, ItemTypes.Consumable)
  setmetatable(self, BaseConsumable)

  assert(self.Type == ItemTypes.Consumable, "BaseConsumable: Attempted to instantiate non-Consumable type.")

  local data = self.DataRef

  self.Tier = tier or data.Tier
  self.MaxStack = data.MaxStack or 1
  self.Stack = 1

  return self :: Interfaces.BaseConsumableInterface
end

function BaseConsumable.fromData(data): Interfaces.BaseConsumableInterface
  local self = BaseItem.fromData(data)
  setmetatable(self, BaseConsumable)

  local dataRef = self.DataRef

  self.Tier = data.Tier or dataRef.Tier
  self.MaxStack = dataRef.MaxStack or 1
  self.Stack = data.Stack or 1

  return self :: Interfaces.BaseConsumableInterface
end

-- =======================
-- Base Consumable Methods
-- =======================

function BaseConsumable:Consume(): boolean
  -- Override in derived classes
  warn("BaseConsumable:Consume() called on base class. This should be overridden in derived classes.")
  return false
end

function BaseConsumable:AddStack(amount: number)
  self.Stack = math.min(self.Stack + amount, self.MaxStack)
end

function BaseConsumable:RemoveStack(amount: number): boolean
  if self.Stack < amount then
    warn("Attempted to remove more consumables than available in stack.")
    return false
  end

  self.Stack = self.Stack - amount
  return true
end

function BaseConsumable:ToData(): { [string]: any }
  local data = BaseItem.ToData(self)

  data.Stack = self.Stack
  data.MaxStack = self.MaxStack

  return data
end

return BaseConsumable