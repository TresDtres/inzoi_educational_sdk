--[[
Architecture Validator (Educational SDK)

Goals:
1) Detect cross-pack require statements
2) Detect circular dependencies
3) Detect Conditions that modify state
4) Detect Packs without corresponding test files

Usage:
  lua inzoi_educational_sdk/tools/architecture_validator.lua
  lua inzoi_educational_sdk/tools/architecture_validator.lua inzoi_educational_sdk/artifacts/architecture_report.json

Notes:
- This is a static heuristic validator for educational governance.
- It is intentionally conservative and extensible.
]]

local M = {}

-- ---------------------------
-- Utility helpers
-- ---------------------------

local function is_windows()
    return package.config:sub(1, 1) == "\\"
end

local function normalize_path(p)
    return (p or ""):gsub("\\", "/")
end

local function basename(p)
    local n = normalize_path(p)
    return n:match("([^/]+)$") or n
end

local function read_file(path)
    local f = io.open(path, "r")
    if not f then
        return nil
    end
    local c = f:read("*a")
    f:close()
    return c
end

local function ensure_parent_dir(path)
    local p = normalize_path(path)
    local dir = p:match("^(.*)/[^/]+$")
    if not dir or dir == "" then
        return
    end
    if is_windows() then
        os.execute('mkdir "' .. dir:gsub("/", "\\") .. '" >nul 2>nul')
    else
        os.execute('mkdir -p "' .. dir .. '" >/dev/null 2>/dev/null')
    end
end

local function list_lua_files(root)
    local files = {}
    local cmd
    if is_windows() then
        cmd = 'dir /b /s "' .. root:gsub("/", "\\") .. '\\*.lua"'
    else
        cmd = 'find "' .. root .. '" -type f -name "*.lua"'
    end

    local pipe = io.popen(cmd)
    if not pipe then
        return files
    end
    for line in pipe:lines() do
        files[#files + 1] = normalize_path(line)
    end
    pipe:close()
    return files
end

local function parse_requires(content)
    local deps, seen = {}, {}
    if not content then
        return deps
    end

    for mod in content:gmatch('require%s*%(%s*["\']([%w%._%-]+)["\']%s*%)') do
        if not seen[mod] then
            deps[#deps + 1] = mod
            seen[mod] = true
        end
    end
    for mod in content:gmatch('require%s+["\']([%w%._%-]+)["\']') do
        if not seen[mod] then
            deps[#deps + 1] = mod
            seen[mod] = true
        end
    end
    return deps
end

local function to_module_name(path)
    local n = normalize_path(path)
    local rel = n:match("/lua/(.+)%.lua$")
    if not rel then
        return nil
    end
    return (rel:gsub("/", "."))
end

-- ---------------------------
-- Scan phase
-- ---------------------------

local function scan_workspace(root)
    local data = {
        files = {},
        modules = {},       -- module -> { path, deps = {} }
        packs = {},         -- pack -> true
        tests = {},         -- lowercase filename -> true
    }

    data.files = list_lua_files(root .. "/lua")

    for _, path in ipairs(data.files) do
        local content = read_file(path) or ""
        local mod = to_module_name(path)
        local deps = parse_requires(content)
        if mod then
            data.modules[mod] = { path = path, deps = deps }
        end

        local pack = path:match("/lua/Packs/([^/]+)/")
        if pack then
            data.packs[pack] = true
        end

        if path:match("/lua/Tests/[^/]+%.lua$") then
            data.tests[basename(path):lower()] = true
        end
    end

    return data
end

-- ---------------------------
-- Rule scanners
-- ---------------------------

local function scan_cross_pack_requires(data)
    local findings = {}
    for mod, info in pairs(data.modules) do
        local owner = mod:match("^Packs%.([^%.]+)%.")
        if owner then
            for _, dep in ipairs(info.deps) do
                local target = dep:match("^Packs%.([^%.]+)%.")
                if target and target ~= owner then
                    findings[#findings + 1] = {
                        file = info.path,
                        module = mod,
                        owner_pack = owner,
                        required_module = dep,
                        target_pack = target,
                        message = "Cross-pack require detected",
                    }
                end
            end
        end
    end
    return findings
end

local function scan_circular_dependencies(data)
    local findings = {}
    local visiting, visited = {}, {}
    local stack = {}

    local function push(v)
        stack[#stack + 1] = v
    end

    local function pop()
        stack[#stack] = nil
    end

    local function index_of(v)
        for i = 1, #stack do
            if stack[i] == v then
                return i
            end
        end
        return nil
    end

    local function dfs(node)
        visiting[node] = true
        push(node)

        local info = data.modules[node]
        if info then
            for _, dep in ipairs(info.deps) do
                if data.modules[dep] then
                    if visiting[dep] then
                        local start_idx = index_of(dep) or 1
                        local cycle = {}
                        for i = start_idx, #stack do
                            cycle[#cycle + 1] = stack[i]
                        end
                        cycle[#cycle + 1] = dep
                        findings[#findings + 1] = {
                            cycle = cycle,
                            message = "Circular dependency detected",
                        }
                    elseif not visited[dep] then
                        dfs(dep)
                    end
                end
            end
        end

        pop()
        visiting[node] = nil
        visited[node] = true
    end

    for mod_name, _ in pairs(data.modules) do
        if not visited[mod_name] then
            dfs(mod_name)
        end
    end

    return findings
end

local function line_suggests_ctx_mutation(line)
    -- Must target ctx on the left-hand side.
    if line:match("^%s*ctx%s*%.+.-=") or line:match("^%s*ctx%s*%[.-%]%s*=") then
        if not line:find("==", 1, true)
            and not line:find(">=", 1, true)
            and not line:find("<=", 1, true)
            and not line:find("~=", 1, true) then
            return true
        end
    end

    -- Common mutating helpers using ctx as receiver.
    if line:match("table%.insert%s*%(%s*ctx%.") then
        return true
    end
    if line:match("table%.remove%s*%(%s*ctx%.") then
        return true
    end
    if line:match("rawset%s*%(%s*ctx%s*,") then
        return true
    end

    return false
end

local function scan_conditions_mutation(data)
    local findings = {}
    for _, path in ipairs(data.files) do
        if path:match("/lua/Packs/[^/]+/Conditions%.lua$") then
            local content = read_file(path) or ""
            local line_no = 0
            for line in content:gmatch("([^\n]*)\n?") do
                line_no = line_no + 1
                if line_suggests_ctx_mutation(line) then
                    findings[#findings + 1] = {
                        file = path,
                        line = line_no,
                        snippet = line,
                        message = "Condition appears to mutate state",
                    }
                end
            end
        end
    end
    return findings
end

local function has_pack_test(data, pack)
    local p = pack:lower()
    local candidates = {
        p .. "_spec.lua",
        p .. "pack_spec.lua",
    }
    for _, c in ipairs(candidates) do
        if data.tests[c] then
            return true
        end
    end
    return false
end

local function scan_missing_pack_tests(data)
    local findings = {}
    for pack, _ in pairs(data.packs) do
        if not has_pack_test(data, pack) then
            findings[#findings + 1] = {
                pack = pack,
                message = "Pack has no corresponding test spec",
            }
        end
    end
    table.sort(findings, function(a, b) return a.pack < b.pack end)
    return findings
end

-- ---------------------------
-- Report phase
-- ---------------------------

local function json_escape(s)
    s = tostring(s)
    s = s:gsub("\\", "\\\\")
    s = s:gsub('"', '\\"')
    s = s:gsub("\n", "\\n")
    s = s:gsub("\r", "\\r")
    s = s:gsub("\t", "\\t")
    return s
end

local function to_json(v)
    local t = type(v)
    if t == "nil" then
        return "null"
    elseif t == "number" or t == "boolean" then
        return tostring(v)
    elseif t == "string" then
        return '"' .. json_escape(v) .. '"'
    elseif t == "table" then
        local is_array = true
        local max_k = 0
        for k, _ in pairs(v) do
            if type(k) ~= "number" then
                is_array = false
                break
            end
            if k > max_k then
                max_k = k
            end
        end
        local parts = {}
        if is_array then
            for i = 1, max_k do
                parts[#parts + 1] = to_json(v[i])
            end
            return "[" .. table.concat(parts, ",") .. "]"
        else
            for k, val in pairs(v) do
                parts[#parts + 1] = '"' .. json_escape(k) .. '":' .. to_json(val)
            end
            return "{" .. table.concat(parts, ",") .. "}"
        end
    end
    return '"' .. json_escape(tostring(v)) .. '"'
end

local function print_findings(title, findings, formatter)
    print(string.format("%s: %d", title, #findings))
    for _, item in ipairs(findings) do
        print("  - " .. formatter(item))
    end
end

local function build_report(results)
    local total =
        #results.cross_pack_requires +
        #results.circular_dependencies +
        #results.conditions_mutations +
        #results.missing_pack_tests

    return {
        summary = {
            total_issues = total,
            cross_pack_requires = #results.cross_pack_requires,
            circular_dependencies = #results.circular_dependencies,
            conditions_mutations = #results.conditions_mutations,
            missing_pack_tests = #results.missing_pack_tests,
        },
        issues = results,
    }
end

local function write_json(path, report)
    ensure_parent_dir(path)
    local f, err = io.open(path, "w")
    if not f then
        io.stderr:write("[WARN] Unable to write JSON report: " .. tostring(err) .. "\n")
        return false
    end
    f:write(to_json(report))
    f:close()
    return true
end

-- ---------------------------
-- Main
-- ---------------------------

function M.run(json_out_path)
    local root = "inzoi_educational_sdk"
    local data = scan_workspace(root)

    local results = {
        cross_pack_requires = scan_cross_pack_requires(data),
        circular_dependencies = scan_circular_dependencies(data),
        conditions_mutations = scan_conditions_mutation(data),
        missing_pack_tests = scan_missing_pack_tests(data),
    }

    local report = build_report(results)

    print("Architecture Validator Summary")
    print("=============================")
    print_findings("Cross-pack requires", results.cross_pack_requires, function(i)
        return string.format("%s requires %s", i.owner_pack, i.required_module)
    end)
    print_findings("Circular dependencies", results.circular_dependencies, function(i)
        return table.concat(i.cycle, " -> ")
    end)
    print_findings("Condition mutations", results.conditions_mutations, function(i)
        return string.format("%s:%d | %s", i.file, i.line or 0, i.snippet or "")
    end)
    print_findings("Missing pack tests", results.missing_pack_tests, function(i)
        return i.pack
    end)

    local has_issues = report.summary.total_issues > 0
    if json_out_path and json_out_path ~= "" then
        local ok = write_json(json_out_path, report)
        if ok then
            print("JSON report: " .. json_out_path)
        end
    end

    if has_issues then
        print("Result: FAIL")
        return 1
    end
    print("Result: PASS")
    return 0
end

local exit_code = M.run(arg and arg[1] or nil)
os.exit(exit_code)
