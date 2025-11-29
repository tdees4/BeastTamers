local StarterGui = game:GetService("StarterGui")

-- Disable default backpack GUI --
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

-- Start server-side modules --
for _, des in script.Parent:GetDescendants() do
  if des.ClassName == "ModuleScript" and des.Init then
    des.Init()
  end
end

for _, des in script.Parent:GetDescendants() do
  if des.ClassName == "ModuleScript" and des.Start then
    des.Start()
  end
end