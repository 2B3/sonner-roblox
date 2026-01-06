local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local services = ServerStorage.Services

local Promise = require(ReplicatedStorage.Packages.Promise)

local Providers = {}
local Modules = {}

for _, module in services:GetChildren() do
	if not module:IsA("ModuleScript") then
		continue
	end

	Modules[module.Name] = require(module)
	table.insert(Providers, Modules[module.Name])
end

Promise.new(function(resolve: (() -> ()), reject: (() -> ()))
	for _, Provider in Providers do
		assert(type(Provider.Init) == "function" or not Provider.Init, "Provider->Init is not a function or null.")

		if Provider.Init then
			Provider:Init()
		end
	end

	resolve()
end):andThen(function()
	for _, Provider in Providers do
		assert(type(Provider.Start) == "function" or not Provider.Start, "Provider->Start is not a function or null.")

		if Provider.Start then
			Provider:Start()
		end
	end
end)