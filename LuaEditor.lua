local module = {}
function module:CreateEditor(parent)
    local mod = {}
    local TextService = game:GetService("TextService")
    local envtbl = getfenv and getfenv(0) or _G

    local colors = {
        ["string"] = Color3.fromRGB(142, 233, 182),
        ["comment"] = Color3.fromRGB(106, 111, 129),
        ["keyword"] = Color3.fromRGB(235, 121, 115),
        ["local method"] = Color3.fromRGB(250, 228, 170),
        ["built-in function"] = Color3.fromRGB(143, 180, 255),
        ["local property"] = Color3.fromRGB(112, 160, 255),
        ["number"] = Color3.fromRGB(242, 186, 42),
        ["boolean"] = Color3.fromRGB(242, 186, 42),
        ["operator"] = Color3.fromRGB(188, 190, 200),
        ["selection"] = Color3.fromRGB(255, 255, 255)
    }

    local keywords = {
        ["local"] = true, ["function"] = true, ["end"] = true, ["return"] = true,
        ["if"] = true, ["elseif"] = true, ["else"] = true, ["while"] = true,
        ["for"] = true, ["do"] = true, ["in"] = true, ["break"] = true,
        ["continue"] = true, ["and"] = true, ["or"] = true, ["not"] = true,
        ["nil"] = true, ["true"] = true, ["false"] = true
    }

    local builtins = {
        ["print"] = true, ["wait"] = true, ["spawn"] = true, ["delay"] = true,
        ["warn"] = true, ["error"] = true, ["assert"] = true, ["type"] = true,
        ["typeof"] = true, ["tostring"] = true, ["tonumber"] = true, ["pairs"] = true,
        ["ipairs"] = true, ["next"] = true, ["unpack"] = true, ["pcall"] = true,
        ["xpcall"] = true, ["require"] = true, ["getmetatable"] = true,
        ["setmetatable"] = true, ["math"] = true, ["string"] = true, ["table"] = true,
        ["task"] = true, ["coroutine"] = true, ["Instance"] = true, ["Color3"] = true,
        ["Vector3"] = true, ["Vector2"] = true, ["UDim2"] = true, ["UDim"] = true
    }

    local function colorToHex(color)
        return string.format(
            "#%02X%02X%02X",
            math.floor(color.R * 255 + 0.5),
            math.floor(color.G * 255 + 0.5),
            math.floor(color.B * 255 + 0.5)
        )
    end

    local colorHexes = {
        ["string"] = colorToHex(colors["string"]),
        ["comment"] = colorToHex(colors["comment"]),
        ["keyword"] = colorToHex(colors["keyword"]),
        ["local method"] = colorToHex(colors["local method"]),
        ["built-in function"] = colorToHex(colors["built-in function"]),
        ["local property"] = colorToHex(colors["local property"]),
        ["number"] = colorToHex(colors["number"]),
        ["boolean"] = colorToHex(colors["boolean"]),
        ["operator"] = colorToHex(colors["operator"]),
        ["selection"] = colorToHex(colors["selection"])
    }

    local function escapeRichText(text)
        return text
            :gsub("&", "&amp;")
            :gsub("<", "&lt;")
            :gsub(">", "&gt;")
    end

    local function colorize(text, colorType, bold)
        local hex = colorHexes[colorType]
        local escaped = escapeRichText(text)
        if bold then
            return '<font color="' .. hex .. '"><b>' .. escaped .. '</b></font>'
        else
            return '<font color="' .. hex .. '">' .. escaped .. '</font>'
        end
    end

    local function syntaxHighlight(source, selStart, selEnd)
        local result = {}
        local resultCount = 0

        local i = 1
        local length = #source

        local function add(text)
            if text ~= "" then
                resultCount += 1
                result[resultCount] = text
            end
        end

        local function processToken(tokenText, tokenStart, colorType, bold)
            local tokenLen = #tokenText
            local tokenEnd = tokenStart + tokenLen - 1

            if selStart and selEnd and selStart <= selEnd then
                local overlapStart = math.max(tokenStart, selStart)
                local overlapEnd = math.min(tokenEnd, selEnd)

                if overlapStart <= overlapEnd then
                    if overlapStart > tokenStart then
                        local pre = tokenText:sub(1, overlapStart - tokenStart)
                        add(colorize(pre, colorType, bold))
                    end

                    local selectedPart = tokenText:sub(overlapStart - tokenStart + 1, overlapEnd - tokenStart + 1)
                    add(colorize(selectedPart, "selection", bold))

                    if overlapEnd < tokenEnd then
                        local post = tokenText:sub(overlapEnd - tokenStart + 2)
                        add(colorize(post, colorType, bold))
                    end
                    return
                end
            end

            add(colorize(tokenText, colorType, bold))
        end

        while i <= length do
            local char = source:sub(i, i)

            if char == '"' or char == "'" then
                local quote = char
                local start = i
                i += 1
                while i <= length do
                    local current = source:sub(i, i)
                    if current == "\\" then
                        i += 2
                    elseif current == quote then
                        i += 1
                        break
                    else
                        i += 1
                    end
                end
                processToken(source:sub(start, i - 1), start, "string", false)

            elseif source:sub(i, i + 1) == "[[" then
                local start = i
                local closeStart = source:find("]]", i + 2, true)
                if closeStart then
                    i = closeStart + 2
                else
                    i = length + 1
                end
                processToken(source:sub(start, i - 1), start, "string", false)

            elseif source:sub(i, i + 1) == "--" then
                local start = i
                if source:sub(i + 2, i + 3) == "[[" then
                    local closeStart = source:find("]]", i + 4, true)
                    if closeStart then
                        i = closeStart + 2
                    else
                        i = length + 1
                    end
                else
                    local newline = source:find("\n", i + 2, true)
                    if newline then
                        i = newline
                    else
                        i = length + 1
                    end
                end
                processToken(source:sub(start, i - 1), start, "comment", false)

            elseif char:match("%a") or char == "_" then
                local start = i
                while i <= length and (source:sub(i, i):match("[%w_]")) do
                    i += 1
                end
                local word = source:sub(start, i - 1)

                local prevNonSpace = start - 1
                while prevNonSpace > 0 and source:sub(prevNonSpace, prevNonSpace):match("%s") do
                    prevNonSpace -= 1
                end
                local prevChar = prevNonSpace > 0 and source:sub(prevNonSpace, prevNonSpace) or ""

                local nextNonSpace = i
                while nextNonSpace <= length and source:sub(nextNonSpace, nextNonSpace):match("%s") do
                    nextNonSpace += 1
                end
                local nextChar = nextNonSpace <= length and source:sub(nextNonSpace, nextNonSpace) or ""

                if keywords[word] then
                    if word == "true" or word == "false" or word == "nil" then
                        processToken(word, start, "boolean", true)
                    else
                        processToken(word, start, "keyword", true)
                    end
                elseif builtins[word] then
                    processToken(word, start, "built-in function", false)
                elseif nextChar == "(" or prevChar == ":" then
                    processToken(word, start, "local method", false)
                elseif prevChar == "." then
                    processToken(word, start, "local property", false)
                else
                    processToken(word, start, "operator", false)
                end

            elseif char:match("%d") then
                local start = i
                while i <= length and (source:sub(i, i):match("[%d%.]")) do
                    i += 1
                end
                processToken(source:sub(start, i - 1), start, "number", false)

            else
                processToken(char, i, "operator", false)
                i += 1
            end
        end

        return table.concat(result)
    end
    local scrollingFrame = Instance.new("ScrollingFrame", parent)
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollingFrame.ScrollBarThickness = 10
    scrollingFrame.Size = UDim2.new(0.95, 0, 1, 0)
    scrollingFrame.BackgroundTransparency = 0
    scrollingFrame.Position = UDim2.new(1, 0, 0, 0)
    scrollingFrame.AnchorPoint = Vector2.new(1, 0)
    scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
    scrollingFrame.ScrollBarImageTransparency = 0.5
    scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.XY
    scrollingFrame.BackgroundColor3 = Color3.fromRGB(32, 34, 39)

    local numscroll = Instance.new("ScrollingFrame", parent)

    numscroll.Size = UDim2.new(0.05, 0, 1, 0)
    numscroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    numscroll.ScrollBarThickness = 0
    numscroll.Position = UDim2.new(0, 0, 0, 0)
    numscroll.AnchorPoint = Vector2.new(0, 0)
    numscroll.BackgroundTransparency = 0
    numscroll.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
    numscroll.ScrollBarImageTransparency = 0.5
    numscroll.AutomaticCanvasSize = Enum.AutomaticSize.XY
    numscroll.BackgroundColor3 = Color3.fromRGB(32, 34, 39)

    local syncing = false

    scrollingFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        if syncing then return end
    
        syncing = true
        numscroll.CanvasPosition = Vector2.new(
            numscroll.CanvasPosition.X,
            scrollingFrame.CanvasPosition.Y
        )
        syncing = false
    end)
    
    numscroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        if syncing then return end
    
        syncing = true
        scrollingFrame.CanvasPosition = Vector2.new(
            scrollingFrame.CanvasPosition.X,
            numscroll.CanvasPosition.Y
        )
        syncing = false
    end)


    local aspectRatio = Instance.new("UIAspectRatioConstraint", OFrame)
    aspectRatio.AspectRatio = 4 / 3

    local richText = Instance.new("TextLabel", scrollingFrame)
    richText.Size = UDim2.new(1, 0, 1, 0)
    richText.BackgroundTransparency = 1
    richText.TextColor3 = Color3.fromRGB(188, 190, 200)
    richText.TextSize = 16
    richText.Text = "--script here"
    richText.RichText = true
    richText.TextXAlignment = Enum.TextXAlignment.Left
    richText.TextYAlignment = Enum.TextYAlignment.Top
    richText.ZIndex = 5
    richText.Font = Enum.Font.Code

    local nt = Instance.new("TextLabel", numscroll)
    nt.Size = UDim2.new(1, 0, 1, 0)
    nt.BackgroundTransparency = 1
    nt.TextColor3 = Color3.fromRGB(188, 190, 200)
    nt.TextSize = 16
    nt.Text = "1"
    nt.RichText = true
    nt.TextXAlignment = Enum.TextXAlignment.Center
    nt.TextYAlignment = Enum.TextYAlignment.Top
    nt.ZIndex = 5
    nt.Font = Enum.Font.Code

    local rawText = Instance.new("TextBox", richText)
    rawText.Size = UDim2.new(1, 0, 1, 0)
    rawText.BackgroundTransparency = 1
    rawText.TextColor3 = Color3.new(1, 1, 1)
    rawText.TextTransparency = 1
    rawText.TextSize = 16
    rawText.Text = "--script here"
    rawText.RichText = false
    rawText.ClearTextOnFocus = false
    rawText.TextXAlignment = Enum.TextXAlignment.Left
    rawText.TextYAlignment = Enum.TextYAlignment.Top
    rawText.ZIndex = 6
    rawText.Font = Enum.Font.Code
    rawText.MultiLine = true

    rawText:GetPropertyChangedSignal("Text"):Connect(function()
        local strg = ""
        for i = 1, (function() local _, count = string.gsub(rawText.Text, "\n", "") return count + 1 end)() do
            strg = strg .. i .. "\n"
        end
        nt.Text = strg
    end)

    local selectionContainer = Instance.new("Frame", richText)
    selectionContainer.Name = "SelectionBackground"
    selectionContainer.BackgroundTransparency = 1
    selectionContainer.BorderSizePixel = 0
    selectionContainer.Position = UDim2.fromOffset(0, 0)
    selectionContainer.Size = UDim2.new(1, 0, 1, 0)
    selectionContainer.ZIndex = richText.ZIndex - 1

    local selectionFrames = {}

    local function clearSelection()
        for _, frame in ipairs(selectionFrames) do
            if frame then
                frame:Destroy()
            end
        end

        table.clear(selectionFrames)
    end

    local function createSelectionFrame(x, y, width, height)
        if width <= 0 or height <= 0 then
            return
        end

        local frame = Instance.new("Frame", selectionContainer)
        frame.Name = "Selection"
        frame.BackgroundColor3 = Color3.fromRGB(19, 35, 93)
        frame.BackgroundTransparency = 0.35
        frame.BorderSizePixel = 0
        frame.Position = UDim2.fromOffset(math.floor(x), math.floor(y))
        frame.Size = UDim2.fromOffset(math.ceil(width), math.ceil(height))
        frame.ZIndex = selectionContainer.ZIndex

        selectionFrames[#selectionFrames + 1] = frame
    end

    local cursor = Instance.new("Frame", richText)
    cursor.Name = "Cursor"
    cursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    cursor.BorderSizePixel = 0
    cursor.Size = UDim2.fromOffset(1, 18)
    cursor.Position = UDim2.fromOffset(0, 0)
    cursor.ZIndex = richText.ZIndex + 2
    cursor.Visible = false

    local function getTextSize(text)
        if text == "" then
            return Vector2.zero
        end

        local params = Instance.new("GetTextBoundsParams")
        params.Text = text
        params.Font = rawText.FontFace
        params.Size = rawText.TextSize
        params.Width = math.huge

        local success, result = pcall(function()
            return TextService:GetTextBoundsAsync(params)
        end)

        params:Destroy()

        if success then
            return result
        end

        return TextService:GetTextSize(
            text,
            rawText.TextSize,
            rawText.Font,
            Vector2.new(math.huge, math.huge)
        )
    end

    local function getLineHeight()
        local height = getTextSize("Ag").Y

        if height <= 0 then
            height = rawText.TextSize
        end

        return height
    end

    local function getLines(raw)
        local lines = {}
        local startPos = 1

        for line in (raw .. "\n"):gmatch("(.-)\n") do
            local endPos = startPos + #line - 1

            lines[#lines + 1] = {
                text = line,
                startPos = startPos,
                endPos = endPos,
            }

            startPos = endPos + 2
        end

        if #lines == 0 then
            lines[1] = {
                text = "",
                startPos = 1,
                endPos = 0,
            }
        end

        return lines
    end

    local function getLineX(lineText)
        local lineSize = getTextSize(lineText)

        if rawText.TextXAlignment == Enum.TextXAlignment.Center then
            return (rawText.AbsoluteSize.X - lineSize.X) / 2
        elseif rawText.TextXAlignment == Enum.TextXAlignment.Right then
            return rawText.AbsoluteSize.X - lineSize.X
        end

        return 0
    end

    local function getLineY(lineIndex, totalLines, lineHeight)
        local y = (lineIndex - 1) * lineHeight

        if rawText.TextYAlignment == Enum.TextYAlignment.Center then
            y += (rawText.AbsoluteSize.Y - totalLines * lineHeight) / 2
        elseif rawText.TextYAlignment == Enum.TextYAlignment.Bottom then
            y += rawText.AbsoluteSize.Y - totalLines * lineHeight
        end

        return y
    end

    local function updateSelection()
        clearSelection()

        local raw = rawText.Text
        local selectionStart = rawText.SelectionStart
        local cursorPosition = rawText.CursorPosition

        if selectionStart == -1 or cursorPosition == -1 then
            return
        end

        if selectionStart == cursorPosition then
            return
        end

        local startPos = math.min(selectionStart, cursorPosition)
        local endPos = math.max(selectionStart, cursorPosition) - 1

        if endPos < startPos then
            return
        end

        local lines = getLines(raw)
        local lineHeight = getLineHeight()

        for lineIndex, line in ipairs(lines) do
            local overlapStart = math.max(startPos, line.startPos)
            local overlapEnd = math.min(endPos, line.endPos)

            if overlapStart <= overlapEnd then
                local beforeText = raw:sub(
                    line.startPos,
                    overlapStart - 1
                )

                local selectedText = raw:sub(
                    overlapStart,
                    overlapEnd
                )

                local beforeSize = getTextSize(beforeText)
                local selectedSize = getTextSize(selectedText)

                local x = getLineX(line.text) + beforeSize.X
                local y = getLineY(
                    lineIndex,
                    #lines,
                    lineHeight
                )

                createSelectionFrame(
                    x,
                    y,
                    selectedSize.X,
                    lineHeight
                )
            end
        end
    end

    local function updateCursor()
        local raw = rawText.Text
        local cursorPosition = rawText.CursorPosition

        if cursorPosition < 1 then
            cursor.Visible = false
            return
        end

        local beforeCursor = raw:sub(1, cursorPosition - 1)
        local lines = getLines(beforeCursor)
        local currentLine = lines[#lines].text
        local lineHeight = getLineHeight()
        local textWidth = getTextSize(currentLine).X

        local x = getLineX(currentLine) + textWidth - 2
        local y = getLineY(#lines, #lines, lineHeight)

        cursor.Position = UDim2.fromOffset(
            math.floor(math.max(0, x)),
            math.floor(y)
        )

        cursor.Size = UDim2.fromOffset(
            1,
            math.floor(lineHeight)
        )

        cursor.Visible = rawText:IsFocused()
    end

    local cursorBlinkId = 0

    local function stopCursorBlink()
        cursorBlinkId += 1
        cursor.Visible = false
    end

    local function startCursorBlink()
        cursorBlinkId += 1

        local thisBlinkId = cursorBlinkId

        cursor.Visible = true

        task.spawn(function()
            while thisBlinkId == cursorBlinkId and rawText:IsFocused() do
                task.wait(0.5)

                if thisBlinkId ~= cursorBlinkId then
                    break
                end

                if not rawText:IsFocused() then
                    break
                end

                cursor.Visible = not cursor.Visible
            end

            if thisBlinkId == cursorBlinkId then
                cursor.Visible = false
            end
        end)
    end

    local function resetCursorBlink()
        if not rawText:IsFocused() then
            stopCursorBlink()
            return
        end

        updateCursor()
        startCursorBlink()
    end

    local function updateRich()
        local raw = rawText.Text
        local selStart = rawText.SelectionStart
        local selPos = rawText.CursorPosition

        local actualStart, actualEnd = nil, nil
        if selStart ~= -1 and selPos ~= -1 and selStart ~= selPos then
            actualStart = math.min(selStart, selPos)
            actualEnd = math.max(selStart, selPos) - 1
        end

        richText.Text = syntaxHighlight(raw, actualStart, actualEnd)

        updateSelection()
        updateCursor()

        if not rawText:IsFocused() then
            cursor.Visible = false
        end
    end

    rawText:GetPropertyChangedSignal("Text"):Connect(function()
        updateRich()
        resetCursorBlink()
    end)

    rawText:GetPropertyChangedSignal("CursorPosition"):Connect(function()
        updateRich()
        resetCursorBlink()
    end)

    rawText:GetPropertyChangedSignal("SelectionStart"):Connect(function()
        updateRich()
        resetCursorBlink()
    end)

    rawText:GetPropertyChangedSignal("TextSize"):Connect(function()
        richText.TextSize = rawText.TextSize
        updateRich()
        resetCursorBlink()
    end)

    rawText:GetPropertyChangedSignal("FontFace"):Connect(function()
        richText.FontFace = rawText.FontFace
        updateRich()
        resetCursorBlink()
    end)

    rawText:GetPropertyChangedSignal("TextXAlignment"):Connect(function()
        richText.TextXAlignment = rawText.TextXAlignment
        updateRich()
        resetCursorBlink()
    end)

    rawText:GetPropertyChangedSignal("TextYAlignment"):Connect(function()
        richText.TextYAlignment = rawText.TextYAlignment
        updateRich()
        resetCursorBlink()
    end)

    rawText:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        updateRich()
        resetCursorBlink()
    end)

    richText:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        updateRich()
        resetCursorBlink()
    end)

    rawText.Focused:Connect(function()
        updateRich()
        startCursorBlink()
    end)

    rawText.FocusLost:Connect(function()
        stopCursorBlink()
        clearSelection()
    end)

    function mod:SetRaw(raw)
        rawText.Text = raw
    end

    function mod:GetRaw()
        return rawText.ContentText
    end
    local abraham = false
    function mod:Destroy()
        numscroll:Destroy()
        scrollingFrame:Destroy()
        abraham = true
    end
    while abraham do
        return
    end
    updateRich()
    return mod
end
return module
