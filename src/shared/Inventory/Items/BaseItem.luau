-- BaseItem should never be DIRECTLY instatiated --
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemTypes = require(ReplicatedStorage.Shared.Inventory.Items.ItemTypes)
local Interfaces = require(ReplicatedStorage.Shared.Inventory.Interfaces)

local BaseItem = {}
BaseItem.__index = BaseItem

local ItemDefinitions = {}

-- Base constructor (Should only be called by subclasses) --
function BaseItem.new(name: string, type: ItemTypes.Type)
  local self = setmetatable({}, BaseItem)

  self.ID = HttpService:GenerateGUID(false)
  self.Type = type

  self.DataRef = ItemDefinitions[type][name]

  if not self.DataRef then
    warn("BaseItem: Attempted to instatiate item without definition: \"", name, "\" Type: ", type)
  end

  self.Tier = self.DataRef and self.DataRef.Tier or 0
  self.ModelPath = self.DataRef and self.DataRef.ModelPath or nil

  return self :: Interfaces.BaseItemInterface
end

-- Constructor for loading data from data stores --
function BaseItem.fromData(data: { ID: string, name: string, type: ItemTypes.Type })
  local self = BaseItem.new(data.name, data.type)

  self.ID = data.ID

  return self :: Interfaces.BaseItemInterface
end

-- ==============
-- BASE METHODS
-- ==============

function BaseItem:ToData(): { [string]: any }
  return {
    ID = self.ID,
    Type = self.Type,
    Name = self.Name,
    Tier = self.Tier,
    -- Note: Subclasses will override this method to include unique properties
  }
end

function BaseItem:GetStaticProperty(propertyName: string): any
  return self.DataRef[propertyName]
end

function BaseItem:GetDisplayName(): string
  if self.Tier > 0 then
    return self.Name.." (T"..self.Tier..")"
  end
  return self.Name
end

return BaseItem