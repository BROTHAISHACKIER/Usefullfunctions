local funcs = {}
function funcs:getpath(instance)
	if not instance then
		return "nil"
	end

	local path = {}

	while instance and instance ~= game do
		local name = instance.Name

		if name:match("[%W]") then
			table.insert(path, 1, '["' .. name .. '"]')
		else
			table.insert(path, 1, "." .. name)
		end

		instance = instance.Parent
	end

	table.insert(path, 1, "game")

	local result = table.concat(path)

	result = result:gsub("game%.", "game.", 1)

	return result
end
function funcs:getasstring(val)
  local t = typeof(val)
	if t == "string" then
		return'"' .. val..'"'
	elseif t == "number" then
		return tostring(val)
	elseif t == "nil" then
		return "nil"
	elseif t == "boolean" then
		if val then
			return "true"
		else
			return "false"
		end
	elseif t == "table" then
		local str = "{"
		local n = false
		for i, v in pairs(val) do
			if typeof(i) == "number" then 
				n = true
				str = str .. "".. getasstring(v, true) .. ","
			else
				str = str .. "\n    "..'["'.. tostring(i).. '"] = ' .. getasstring(v, true) .. ","
			end
		end
		if n then
			return str .. "}"
		end
		return str .. "\n}"
	elseif t == "EnumItem" then
		return tostring(val)
	elseif t == "Enum" then
		return "Enum."..tostring(val)
	elseif t == "function" then
		return "[function]"
	elseif t == "thread" then
		return "[thread]"
	elseif t == "Instance" then
		return self:getpath(val)
	elseif t == "userdata" then
		return "[Unsuported userdata]"
	elseif t == "CFrame" then
		local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = val:GetComponents()

		local function clean(n)
			if math.abs(n) < 1e-6 then
				return 0
			end
			return math.floor(n * 1000 + 0.5) / 1000
		end

		return string.format(
			"CFrame.new(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)",
			clean(x), clean(y), clean(z),
			clean(r00), clean(r01), clean(r02),
			clean(r10), clean(r11), clean(r12),
			clean(r20), clean(r21), clean(r22)
		)
	elseif t == "Vector2" then
		local x = val.X
		local y = val.Y
		return "Vector2.new("..x..", "..y..")"
	elseif t == "Vector3" then
		local x = val.X
		local y = val.Y
		local z = val.Z
		return "Vector3.new("..x..", "..y..", "..z..")"
	elseif t == "Vector3int16" then
		local x = val.X
		local y = val.Y
		local z = val.Z
		return "Vector3int16.new("..x..", "..y..", "..z..")"
	elseif t == "Vector2int16" then
		local x = val.X
		local y = val.Y
		return "Vector2int16.new("..x..", "..y..")"
	elseif t == "BrickColor" then
		return 'BrickColor.new("'.. tostring(val) .. '")'
	elseif t == "Color3" then
		return "Color3.fromRGB("..tostring(math.floor((val.R*255)+0.5))..", "..tostring(math.floor((val.G*255)+0.5))..", "..tostring(math.floor((val.B*255)+0.5))..")"
	end
	return "[Unsuported Value] "
end
return funcs
