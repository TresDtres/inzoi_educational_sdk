local Context = {}
Context.__index = Context

function Context.New(params)
    params = params or {}
    local o = {
        Actor = params.Actor,
        Target = params.Target,
        World = params.World,
        Time = params.Time or 0,
        Tags = params.Tags or {},
        Stats = params.Stats or {},
        Buffs = params.Buffs or {},
        Meta = params.Meta or {},
        RNG = params.RNG or math.random,
    }
    return setmetatable(o, Context)
end

function Context:HasTag(tagName)
    return self.Tags[tagName] == true
end

function Context:HasBuff(buffId)
    return self.Buffs[buffId] == true
end

function Context:GetStat(name, fallback)
    local v = self.Stats[name]
    if v == nil then
        return fallback
    end
    return v
end

return Context
