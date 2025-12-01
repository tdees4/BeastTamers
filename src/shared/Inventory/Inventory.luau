local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Interfaces = require(ReplicatedStorage.Shared.Inventory.Interfaces)
local BaseItem = require(ReplicatedStorage.Shared.Inventory.Items.BaseItem)
local BaseConsumable = require(ReplicatedStorage.Shared.Inventory.Items.BaseConsumable)
local BaseTool = require(ReplicatedStorage.Shared.Inventory.Items.BaseTool)
local ItemDefinitions = require(ReplicatedStorage.Shared.Inventory.Items.ItemDefinitions)

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

  self.MasterIndex = {}

  return self :: Interfaces.Inventory
end

function Inventory.fromData(data)
  local self = Inventory.new(data.UserId)
  
  for resource, quantity in pairs(data.Resources) do
    self.Resources[resource] = quantity
  end

  for ID, consumable in pairs(data.Consumables) do
    local consumableInstance = BaseItem.fromData(consumable) -- TODO: Change from BaseItem to BaseConsumable
    self.Consumables[ID] = consumableInstance
  end

  for ID, tool in pairs(data.Tools) do
    local toolInstance = BaseTool.fromData(tool)
    self.Tools[ID] = toolInstance
  end

  self.HotBarSlots = data.HotBarSlots
  self.Pets = data.Pets -- TODO: Same as below
  self.Suit = data.Suit
  self.Money = data.Money
  self.MasterIndex = data.MasterIndex

  return self :: Interfaces.Inventory
end

-- =================
-- Inventory Methods
-- =================

-- SETTER METHODS --

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

function Inventory:AddTool(tool: Interfaces.BaseToolInterface): boolean
  if self.MasterIndex[tool.ID] or self.Tools[tool.ID] then
    return false
  end

  self.Tools[tool.ID] = tool
  self.MasterIndex[tool.ID] = tool
  return true
end

function Inventory:RemoveTool(tool: Interfaces.BaseToolInterface): boolean
  if not self.MasterIndex[tool.ID] or not self.Tools[tool.ID] then
    return false
  end

  self.Tools[tool.ID] = nil
  self.MasterIndex[tool.ID] = nil
  return true
end

function Inventory:AddResource(resourceName: string, amount: number): boolean
  if amount <= 0 then
    warn("Attempted to add non-positive amount of resource: "..resourceName)
    return false
  end

  if not ItemDefinitions.Resource[resourceName] then
    warn("Attempted to remove invalid resource: "..resourceName)
    return false
  end

  local current = self.Resources[resourceName] or 0
  local final = math.min(current + amount, ItemDefinitions.Resource[resourceName].MaxStack)

  if current + amount > ItemDefinitions.Resource[resourceName].MaxStack then
    warn("Player "..self.UserId.." attempted to add more "..resourceName.." than max stack size.")
  end

  self.Resources[resourceName] = final

  return true
end

function Inventory:RemoveResource(resourceName: string, amount: number): boolean
  if amount <= 0 then
    warn("Attempted to remove non-positive amount of resource: "..resourceName)
    return false
  end

  if not self.Resources[resourceName] or self.Resources[resourceName] < amount then
    warn("Player "..self.UserId.." does not have enough "..resourceName)
    return false
  end

  local current = self.Resources[resourceName]
  self.Resources[resourceName] = current - amount
  return true
end

function Inventory:AddConsumable(consumableName: string, amount: number)
  if amount <= 0 then
    warn("Attempted to add non-positive amount of consumable: "..consumableName)
    return
  end

  local existing = self.Consumables[consumableName]

  if existing then
    existing:AddStack(amount)
  else
    local consumable = BaseConsumable.new(consumableName, 0)
    consumable:AddStack(amount - 1) -- x - 1 because new consumable starts at 1 stack
  end
end

function Inventory:RemoveConsumable(consumableName: string, amount: number): boolean
  if amount <= 0 then
    warn("Attempted to add non-positive amount of consumable: "..consumableName)
    return false
  end

  local existing = self.Consumables[consumableName]

  if not existing then
    warn("Player "..self.UserId.." does not have any "..consumableName)
    return false
  end

  return existing:RemoveStack(amount)
end

-- HAS METHODS --

function Inventory:HasResource(resourceName: string, amount: number): boolean
  local current = self.Resources[resourceName] or 0
  return current >= amount
end

function Inventory:HasConsumable(consumableName: string, amount: number): boolean
  local existing = self.Consumables[consumableName]

  if not existing then
    return false
  end

  return existing.Stack >= amount
end

function Inventory:HasTool(toolName: string): boolean
  for _, tool in pairs(self.Tools) do
    if tool.Name == toolName then
      return true
    end
  end

  return false
end

function Inventory:HasToolID(toolID: string): boolean
  return self.Tools[toolID] ~= nil
end

-- DATA METHODS --

function Inventory:ToData(): { [string]: any }
  local data = {}

  data.UserId = self.UserId

  local resourceData = {}
  for _, resource in pairs(self.Resources) do
    resourceData[resource] = self.Resources[resource]
  end
  data.Resources = resourceData

  local consumables = {}
  for ID, consumable in pairs(self.Consumables) do
    consumables[ID] = consumable
  end
  data.Consumables = consumables

  local tools = {}
  for ID, tool in pairs(self.Tools) do
    tools[ID] = tool
  end
  data.Tools = tools

  data.HotBarSlots = self.HotBarSlots
  data.Pets = self.Pets -- TODO: Change this once Pet classes have been made
  data.Suit = self.Suit
  data.Money = self.Money
  data.MasterIndex = self.MasterIndex

  return data
end

return Inventory