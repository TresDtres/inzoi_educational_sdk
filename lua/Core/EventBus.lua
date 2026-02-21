local EventBus = {}
EventBus.__index = EventBus

function EventBus.New()
    local o = {
        _handlers = {},
    }
    return setmetatable(o, EventBus)
end

function EventBus:Subscribe(eventName, fn)
    if self._handlers[eventName] == nil then
        self._handlers[eventName] = {}
    end
    table.insert(self._handlers[eventName], fn)
end

function EventBus:Emit(eventName, payload)
    local handlers = self._handlers[eventName]
    if not handlers then
        return
    end
    for _, fn in ipairs(handlers) do
        fn(payload)
    end
end

return EventBus
