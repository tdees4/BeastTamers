local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Interfaces = require(ReplicatedStorage.Shared.Inventory.Interfaces)
local BaseItem = require(ReplicatedStorage.Shared.Inventory.Items.BaseItem)
local BaseTool = require(ReplicatedStorage.Shared.Inventory.Items.BaseTool)

local Inventory = {}
Inventory.__index = Inventory

function Inventory.new(userId: number)
  local self = setmetatable({}, Inventory)

  self.UserId = userId
  self.Resources = {}
  self.Consumables = {}
  self.Tools = {}
  self.Suit = {}
  self.Pets = {}
  self.HotBarSlots = {
    [1] = nil,
    [2] = nil,
    [3] = nil,
    [4] = nil,
    [5] = nil
  }
  self.Money = 0

  return self :: Interfaces.Inventory
end

function Inventory.fromData(data)
  local self = Inventory.new(data.UserId)
  
  for resource, quantity in pairs(data.Resources) do
    self.Resources[resource] = quantity
  end

  for _, consumable in pairs(data.Consumables) do
    local consumableInstance = BaseItem.fromData(consumable) -- TODO: Change from BaseItem to BaseConsumable
    table.insert(self.Consumables, consumableInstance)
  end

  for _, tool in pairs(data.Tools) do
    local toolInstance = BaseTool.fromData(tool)
    table.insert(self.Tools, toolInstance)
  end

  self.HotBarSlots = data.HotBarSlots
  self.Pets = data.Pets -- TODO: Same as below
  self.Suit = data.Suit
  self.Money = data.Money or 0

  return self :: Interfaces.Inventory
end

-- =================
-- Inventory Methods
-- =================

--[[
Takes the desired amount of money from the player's inventory

@param amount The purchase amount

@returns True if the player had enough money for the purchase, false otherwise
]]
function Inventory:SpendMoney(amount: number): boolean
  if amount > self.Money then
    warn("Player "..self.UserId.." does not have enough money for purchase.")
    return false
  end

  self.Money -= amount

  return true
end

function Inventory:EarnMoney(amount: number)
  self.Money += amount

  -- Call any remote events for UI/responsiveness purposess
end

function Inventory:AddResource(resourceName: string, amount: number)
  if self.Resources[resourceName] then
    local current = self.Resources[resourceName]
    self.Resources[resourceName] = current + amount
  else
    self.Resources[resourceName] = amount
  end
end

function Inventory:RemoveResource(resourceName: string, amount: number): boolean
  if not self.Resources[resourceName] or self.Resources[resourceName] < amount then
    warn("Player "..self.UserId.." does not have enough "..resourceName)
    return false
  end

  local current = self.Resources[resourceName]
  self.Resources[resourceName] = current - amount
  return true
end

function Inventory:AddConsumable(consumableName: string, amount: number)
  local existing = self.Consumables[consumableName]

  if existing then
    existing:AddQuantity(amount)
  else
    local newInstance -- Use Consumable constructor here
    -- TODO: Complete logic
  end
end

function Inventory:ToData(): { [string]: any }
  local data = {}

  data.UserId = self.UserId

  local resourceData = {}
  for _, resource in pairs(self.Resources) do
    resourceData[resource] = self.Resources[resource]
  end
  data.Resources = resourceData

  local consumables = {}
  for _, consumable in pairs(self.Consumables) do
    table.insert(consumables, consumable:ToData())
  end
  data.Consumables = consumables

  local tools = {}
  for _, tool in pairs(self.Tools) do
    table.insert(tools, tool:ToData())
  end
  data.Tools = tools

  data.HotBarSlots = self.HotBarSlots
  data.Pets = self.Pets -- TODO: Change this once Pet classes have been made
  data.Suit = self.Suit
  data.Money = self.Money or 0

  return data
end

return Inventory