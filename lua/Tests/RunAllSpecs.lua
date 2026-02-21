local specs = {
    { Name = "RelationshipPack", Mod = "Tests.RelationshipPack_spec" },
    { Name = "QuestPack", Mod = "Tests.QuestPack_spec" },
    { Name = "BuffPack", Mod = "Tests.BuffPack_spec" },
    { Name = "InventoryPack", Mod = "Tests.InventoryPack_spec" },
    { Name = "PackTemplate", Mod = "Tests.PackTemplate_spec" },
    { Name = "EconomyPack", Mod = "Tests.Economy_spec" },
    { Name = "I18n", Mod = "Tests.I18n_spec" },
}

local function jsonEscape(s)
    s = tostring(s)
    s = s:gsub("\\", "\\\\")
    s = s:gsub("\"", "\\\"")
    s = s:gsub("\n", "\\n")
    s = s:gsub("\r", "\\r")
    s = s:gsub("\t", "\\t")
    return s
end

local function toJson(v)
    local t = type(v)
    if t == "nil" then
        return "null"
    end
    if t == "number" or t == "boolean" then
        return tostring(v)
    end
    if t == "string" then
        return "\"" .. jsonEscape(v) .. "\""
    end
    if t == "table" then
        local isArray = true
        local count = 0
        for k, _ in pairs(v) do
            count = count + 1
            if type(k) ~= "number" then
                isArray = false
                break
            end
        end
        if isArray then
            local parts = {}
            for i = 1, #v do
                parts[#parts + 1] = toJson(v[i])
            end
            return "[" .. table.concat(parts, ",") .. "]"
        end
        local parts = {}
        for k, val in pairs(v) do
            parts[#parts + 1] = "\"" .. jsonEscape(k) .. "\":" .. toJson(val)
        end
        return "{" .. table.concat(parts, ",") .. "}"
    end
    return "\"" .. jsonEscape(tostring(v)) .. "\""
end

local function writeJson(path, payload)
    if not path or path == "" then
        return
    end
    local dir = string.match(path, "^(.*)[/\\][^/\\]+$")
    if dir and dir ~= "" then
        os.execute('mkdir "' .. dir .. '" >nul 2>nul')
    end
    local f, err = io.open(path, "w")
    if not f then
        print("[WARN] cannot write json report: " .. tostring(err))
        return
    end
    f:write(toJson(payload))
    f:close()
end

local function runOne(spec)
    local startedAt = os.clock()
    local okRequire, suite = pcall(require, spec.Mod)
    if not okRequire then
        return {
            name = spec.Name,
            ok = false,
            error = "require failed: " .. tostring(suite),
            duration_ms = math.floor((os.clock() - startedAt) * 1000),
        }
    end

    local okRun, err = pcall(suite.Run)
    if not okRun then
        return {
            name = spec.Name,
            ok = false,
            error = tostring(err),
            duration_ms = math.floor((os.clock() - startedAt) * 1000),
        }
    end
    return {
        name = spec.Name,
        ok = true,
        error = nil,
        duration_ms = math.floor((os.clock() - startedAt) * 1000),
    }
end

local function main()
    local startedAt = os.clock()
    local passed = 0
    local results = {}
    for _, spec in ipairs(specs) do
        local item = runOne(spec)
        results[#results + 1] = item
        if item.ok then
            print(string.format("[PASS] %s", spec.Name))
            passed = passed + 1
        else
            print(string.format("[FAIL] %s -> %s", spec.Name, tostring(item.error)))
        end
    end
    print(string.format("SUMMARY %d/%d", passed, #specs))

    local report = {
        summary = {
            passed = passed,
            total = #specs,
            failed = #specs - passed,
            duration_ms = math.floor((os.clock() - startedAt) * 1000),
        },
        results = results,
    }
    local jsonOut = (arg and arg[1]) or os.getenv("EDUSDK_TEST_JSON")
    writeJson(jsonOut, report)

    if passed ~= #specs then
        os.exit(1)
    end
end

main()
