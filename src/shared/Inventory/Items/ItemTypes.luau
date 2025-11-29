export type Type = {
  Tool: string,
  Resource: string,
  Consumable: string,
  Resource_Currency: string,
  Resouce_Drop: string,
  Resource_Fusion: string
}

local ItemTypes = {}

-- [[ CORE CATEGORIES ]]

-- 1. Items that are equipped and have durability/wear
ItemTypes.Tool = "Tool"

-- 2. Items that stack, are collected, and are used for currency/crafting
ItemTypes.Resource = "Resource"

-- 3. Items that are consumed upon use (e.g., boosts, bait)
ItemTypes.Consumable = "Consumable"

-- This helps when checking if a resource is currency or a material
ItemTypes.Resource_Currency = "Currency"
ItemTypes.Resource_Drop = "AnimalDrop"
ItemTypes.Resource_Fusion = "FusionMaterial"

-- Lock the table so its contents cannot be changed at runtime
return table.freeze(ItemTypes)