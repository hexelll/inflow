local eventHandler = {}

eventHandler.getReact = function(case,lookUp)
    for i,e in pairs(lookUp) do
        if case == e.event then
            return e.react
        end
    end
    return function()end
end

eventHandler.handleEvents = function(eventLookUp)
    local eventData = {os.pullEventRaw()}
    local event = eventData[1]
    eventHandler.queue = {}
    table.insert(eventHandler.queue,
    function()
        eventHandler.getReact(event,eventLookUp)(eventData)
    end)
    parallel.waitForAll(table.unpack(eventHandler.queue))
end

eventHandler.loop = function()
    while true do
        eventHandler.handleEvents(eventHandler.eventLookUp)
    end
end

return eventHandler