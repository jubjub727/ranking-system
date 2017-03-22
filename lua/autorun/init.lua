
RANK = {}

if SERVER then

    include("rank/main.lua")
    include("rank/sv_hooks.lua")
    include("rank/ui/sv_ui.lua")

    AddCSLuaFile("rank/ui/cl_ui.lua")

else

    include("rank/ui/cl_ui.lua")

end