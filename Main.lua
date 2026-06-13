local funcs = {}
function funcs:getpath(instance)
	if not instance then
		return "nil"
	end

	if instance == game then
		return "game"
	end

	local path = {}

	while instance and instance ~= game do
		local parent = instance.Parent

		if parent == game then
			table.insert(path, 1, 'game:GetService("' .. instance.ClassName .. '")')
			break
		end

		local name = instance.Name

		if name:match("[%W]") then
			table.insert(path, 1, '["' .. name .. '"]')
		else
			table.insert(path, 1, "." .. name)
		end

		instance = parent
	end

	if #path == 0 then
		return "game"
	end

	return table.concat(path)
end
function funcs:getasstring(val, check, lol)
  if not lol then
		lol = 0
	end
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
		local compare = 0
		local cur = 0
		for i,v in pairs(val) do
			compare += 1
		end
		for i, v in pairs(val) do
			cur += 1
			if cur == compare then
				if typeof(i) == "number" then 
					n = true
					str = str .. "".. self:getasstring(v, true) .. ""
				else
					local hmm = "	"
					for i = 1, lol do
						hmm = hmm.."	"
					end
					str = str .. "\n"..hmm..'["'.. tostring(i).. '"] = ' .. self:getasstring(v, true, lol+1) .. ""
				end
			else
				if typeof(i) == "number" then 
					n = true
					str = str .. "".. self:getasstring(v, true) .. ", "
				else
					local hmm = "    "
					for i = 1, lol do
						hmm = hmm.."    "
					end
					str = str .. "\n"..hmm..'["'.. tostring(i).. '"] = ' .. self:getasstring(v, true, lol+1) .. ","
				end
			end	
		end
		if n or string.sub(str, -1) == "}" then
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
		return getpath(val)
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
	elseif t == "ColorSequenceKeypoint" then
		return "ColorSequenceKeypoint.new("..val.Time..", ".. self:getasstring(val.Value) .. ")"
	elseif t == "ColorSequence" then
		local str = "ColorSequence.new({\n"
		for i, v in ipairs(val.Keypoints) do
			str = str .. "    ".. self:getasstring(v) .. ",\n"
		end
		return str .. "})"
	elseif t == "UDim" then
		if check then
			return val.Scale..", ".. val.Offset
		end
		return "UDim.new("..val.Scale..", ".. val.Offset..")"
	elseif t == "UDim2" then
		return "UDim2.new("..self:getasstring(val.X, true)..", "..self:getasstring(val.Y, true)..")"
	elseif t == "NumberRange" then
		return "NumberRange.new("..val.Min..", "..val.Max..")"
	elseif t == "NumberSequenceKeypoint" then
		if val.Envelope <= 0 then
			return "NumberSequenceKeypoint.new(" .. val.Time .. ", ".. val.Value ..")"
		else
			return "NumberSequenceKeypoint.new(" .. val.Time .. ", ".. val.Value ..", ".. val.Envelope .. ")"
		end
	elseif t == "NumberSequence" then
		local str = "NumberSequence.new({\n"
		for i, v in ipairs(val.Keypoints) do
			str = str .. "    ".. self:getasstring(v) .. ",\n"
		end
		return str .. "})"
	end
	return "[Unsuported Value ("..t..")]"
end
function funcs:logger(thing, ...)
	local content = thing .. "("
	for k, v in pairs({...}) do
		if k == #{...} then
			content = content .. self:getasstring(v)
		else
			content = content .. self:getasstring(v) .. ", "
		end
	end
	content = content .. ")"
	if ... == nil then
		content = thing
	end
	if thing == "pcall error" then
		content = thing .. " " .. ...
	end
	if thing == "ERROR" then
		content = thing .. " " .. ...
	end
	if self.LOGGGGGG and table.find(listfiles("./"), "./"..self.LOGGGGGG) then
		writefile(self.LOGGGGGG, readfile(self.LOGGGGGG).."\n\n"..content.."   | time: "..os.date("!%H:%M:%S"))
	else
		if table.find(listfiles("./"), "./.ULogger") or table.find(listfiles("./"), ".ULogger") then
			local log = "Log_"..string.sub(math.random(1,9999999)..".log", 3, -1)
			self.LOGGGGGG = ".ULogger/"..log
			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "log is avaiable at",
				Text = "workspace/"..string.sub(self.LOGGGGGG, 2, -1),
				Duration = 5,
			})
			writefile(self.LOGGGGGG, content .. "   | time: " .. os.date("!%H:%M:%S"))
		else
			makefolder(".ULogger")
			local log = "Log_"..string.sub(script:GetDebugId()..".log", 3, -1)
			self.LOGGGGGG = ".ULogger/"..log
			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "log is avaiable at",
				Text = "workspace/"..string.sub(self.LOGGGGGG, 2, -1),
				Duration = 5,
			})
			writefile(self.LOGGGGGG, content .. "   | time: " .. os.date("!%H:%M:%S"))
		end
	end
end
function funcs:funcedit(fn, env)
	local global = {
		--globals
		assert = assert,
		collectgarbage = collectgarbage,
		DebuggerManager = DebuggerManager,
		delay = delay,
		elapsedTime = elapsedTime,
		Enum = Enum,
		game = {
			CreatorId = game.CreatorId,
			CreatorType = game.CreatorType,
			PlaceId = game.PlaceId,
			PlaceVersion = game.PlaceVersion,

			Lighting = game.Lighting,
			Workspace = game.Workspace,
			workspace = game.workspace,

			RunService = game:GetService("RunService"),

			GetService = function(_, ...)
				return game:GetService(...)
			end,
			HttpGet = function(_, ...)
				return game:HttpGet(...)
			end,
			TweenService = game:GetService("TweenService"),
			UserInputService = game:GetService("UserInputService"),
			CoreGui = game:GetService("CoreGui"),
			Players = game:GetService("Players"),
			GuiService = game:GetService("GuiService"),
		},
		error = error,
		gcinfo = gcinfo,
		getfenv = getfenv,
		getmetatable = getmetatable,
		ipairs = ipairs,
		loadstring = loadstring,
		newproxy = newproxy,
		next = next,
		pairs = pairs,
		pcall = pcall,
		plugin = plugin,
		PluginManager = PluginManager,
		print = print,
		printidentity = printidentity,
		rawequal = rawequal,
		rawget = rawget,
		rawlen = rawlen,
		rawset = rawset,
		require = require,
		script = script,
		select = select,
		GetDebugId = GetDebugId,
		setfenv = setfenv,
		setmetatable = setmetatable,
		settings = settings,
		shared = shared,
		spawn = spawn,
		stats = stats,
		tick = tick,
		time = time,
		tonumber = tonumber,
		tostring = tostring,
		type = type,
		typeof = typeof,
		unpack = unpack,
		UserSettings = UserSettings,
		version = version,
		wait = wait,
		warn = warn,
		workspace = workspace,
		xpcall = xpcall,
		ypcall = ypcall,
		_G = _G,
		_VERSION = _VERSION,
		--libraries
		bit32 = bit32,
		buffer = buffer,
		coroutine = {
			close = coroutine.close,
			create = coroutine.create,
			isyieldable = coroutine.isyeildable,
			resume = coroutine.resume,
			running = coroutine.running,
			status = coroutine.status,
			wrap = coroutine.wrap,
			yield = coroutine.yeild,
		},
		debug = debug,
		math = math,
		os = {
			clock = os.clock,
			date = os.date,
			difftime = os.difftime,
			time = os.time,
		},
		string = string,
		table = table,
		task = {
			spawn = task.spawn,
			defer = task.defer,
			delay = task.delay,
			desynchronize = task.desynchronize,
			synchronize = task.synchronize,
			wait = task.wait,
			cancel = task.cancel,
		},
		utf8 = utf8,
		vector = vector,
		--Data types
		Axes = Axes,
		BrickColor = BrickColor,
		CatalogSearchParams = CatalogSearchParams,
		CFrame = CFrame,
		Color3 = Color3,
		ColorSequence = ColorSequence,
		ColorSequenceKeypoint = ColorSequenceKeypoint,
		Content = Content,
		DateTime = DateTime,
		DockWidgetPluginGuiInfo = {
			InitialEnabled = DockWidgetPluginGuiInfo.InitialEnabled,
			InitialEnabledShouldOverrideRestore = DockWidgetPluginGuiInfo.InitialEnabledShouldOverrideRestore,
			FloatingXSize = DockWidgetPluginGuiInfo.FloatingXSize,
			FloatingYSize = DockWidgetPluginGuiInfo.FloatingYSize,
			MinWidth = DockWidgetPluginGuiInfo.MinWidth,
			MinHeight = DockWidgetPluginGuiInfo.MinHeight,
		},
		EnumItem = EnumItem,
		Enums = Enums,
		Faces = Faces,
		FloatCurveKey = FloatCurveKey,
		Font = Font,
		Instance = {
			new = Instance.new,
			fromExisting = Instance.fromExisting,
		},
		NumberRange = NumberRange,
		NumberSequence = {
			new = NumberSequence.new,
		},
		NumberSequenceKeypoint = NumberSequenceKeypoint,
		OverlapParams = OverlapParams,
		Path2DControlPoint = Path2DControlPoint,
		PathWaypoint = PathWaypoint,
		PhysicalProperties = PhysicalProperties,
		Random = Random,
		Ray = Ray,
		RaycastParams = RaycastParams,
		RaycastResult = RaycastResult,
		RBXScriptConnection = RBXScriptConnection,
		RBXScriptSignal = RBXScriptSignal,
		Rect = Rect,
		Region3 = Region3,
		Region3int16 = Region3int16,
		RotationCurveKey = RotationCurveKey,
		Secret = Secret,
		SecurityCapabilities = SecurityCapabilities,
		SharedTable = SharedTable,
		TweenInfo = TweenInfo,
		UDim = UDim,
		UDim2 = UDim2,
		ValueCurveKey = ValueCurveKey,
		Vector2 = Vector2,
		Vector2int16 = Vector2int16,
		Vector3 = Vector3,
		Vector3int16 = Vector3int16,
		--exec
		readfile = readfile,
		writefile = writefile,
		delfile = delfile,
		makefolder = makefolder,
		listfiles = listfiles,
		getgenv = getgenv,
		getfenv = getfenv,
		getrenv = getrenv,
		setclipboard = setclipboard,
	}
	for i, v in pairs(env) do
		if typeof(v) == "table" then
			for i2, v2 in pairs(v) do
				if not pcall(function()
					global[i][i2] = v2
				end) then
					global[i] = v
					warn("Attempt to change a protected metatable, Trying to set the whole metatable into the set env.")
				end
			end
		else
			global[i] = v
		end
	end

	setfenv(fn, setmetatable(global, {
		__index = _G
	}))
	local a,b = pcall(fn)
	if not a then
		error(b, 0)
		self:logger("ERROR", b)
	end
	return a,b
end
funcs.loggerenv = {
	print = function(...)
		funcs:logger("print", ...)
		return print(...)
	end,

	warn = function(...)
		funcs:logger("warn", ...)
		return warn(...)
	end,

	error = function(...)
		funcs:logger("error", ...)
		return error(...)
	end,
	Instance = {
		new = function(...)
			local args = table.pack(...)
			task.spawn(function()
				funcs:logger("Instance.new", table.unpack(args, 1, args.n))
			end)
			return Instance.new(...)
		end,
	},
	loadstring = function(...)
		local args = table.pack(...)

		task.spawn(function()
			log("loadstring", table.unpack(args, 1, args.n))
		end)
		return loadstring(...)
	end,
	assert = function(...)
		log("assert", ...)
		return assert(...)
	end,
	game = {
		HttpGet = function(_, ...)
			local args = table.pack(...)
	
			task.spawn(function()
				log("game:HttpGet", table.unpack(args, 1, args.n))
			end)
			return game:HttpGet(...)
		end,
	},
	delfile = function(...)
		log("delfile", ...)
		return delfile(...)
	end,
	makefolder = function(...)
		log("makefolder", ...)
		return makefolder(...)
	end,
	readfile = function(...)
		log("readfile", ...)
		return readfile(...)
	end,
	writefile = function(...)
		log("writefile", ...)
		return writefile(...)
	end,
	listfiles = function(...)
		log("listfiles", ...)
		return listfiles(...)
	end,
	pcall = function(...)
		local args = table.pack(...)

		task.spawn(function()
			log("pcall", table.unpack(args, 1, args.n))
		end)

		local results = table.pack(pcall(table.unpack(args, 1, args.n)))

		if not results[1] then
			task.spawn(function()
				log("pcall error", results[2])
			end)
			warn("pcall error", results[2])
		end

		return table.unpack(results, 1, results.n)
	end,
}

return funcs
