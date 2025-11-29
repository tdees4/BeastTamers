export type BaseItemInterface = {
  ID: string,
  Name: string,
  Type: string,
  Tier: number,
  ModelPath: string | nil,
  DataRef: any,

  ToData: (self: BaseItemInterface) -> { [string]: any },
  GetStaticProperty: (self: BaseItemInterface, propertyName: string) -> any,
  GetDisplayName: (self: BaseItemInterface) -> string
}

export type BaseToolInterface = BaseItemInterface & {
  Durability: number,
  MaxDurability: number,
  IsEquipped: boolean,

  DecreaseDurability: (self: BaseToolInterface, amount: number) -> boolean,
  RepairDurability: (self: BaseToolInterface) -> nil,
  SetEquipped: (self: BaseToolInterface, equipped: boolean) -> nil,
  IsUsable: (self: BaseToolInterface) -> boolean
}

export type TamingNet = BaseToolInterface & {
  CaptureModifier: number
}

export type BaseConsumableInterface = BaseItemInterface & {
  Consume: (self: BaseConsumableInterface) -> boolean
}

export type SuitInterface = {
  ModuleI: boolean,
  ModuleII: boolean,
  ModuleIII: boolean,
  ModuleIV: boolean,
  ModuleV: boolean
}

export type Inventory = {
  UserId: number,
  Tools: { BaseToolInterface },
  Resources: { [string] : number },
  Consumables: { [BaseConsumableInterface] : number },
  Suit: SuitInterface
}

return {}