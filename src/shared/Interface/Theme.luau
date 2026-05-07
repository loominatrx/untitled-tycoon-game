local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Themer = require(ReplicatedStorage.Packages._Index["imavafe_onyx-ui@1.0.4"]["onyx-ui"].Themer)

local Theme: Themer.ThemeSpec = {
    Colors = {
        Primary = {
			Main = Color3.fromHex('F39005'),
		},
		Secondary = {
			Main = Color3.fromHex('E0A24C'),
		},
		Accent = {
			Main = Color3.fromHex('6D7A79'),
		},
        Base = {
			Main = Color3.fromHex('121717'),
		},
		BaseContent = {
			Main = Color3.fromHex('EAE6DC'),
		},
    },
    Font = {
        Body = "rbxassetid://11702779409",
        Heading = "rbxassetid://11702779409",
        Monospace = "rbxasset://fonts/families/RobotoMono.json",
    },

    FontWeight = {
        Body = Enum.FontWeight.Medium,
        Bold = Enum.FontWeight.Bold,
        Heading = Enum.FontWeight.Bold,
    },
}

return Themer.NewTheme(Fusion.scoped(), Theme)