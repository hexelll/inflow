p = peripheral
modem = p.find("modem",function(name,modem)
    return modem.isWireless()
end)

rednet.open(p.getName(modem))

data = fs.open("data.txt","r").readAll()

while true do
    local event,sender,message,protocol = os.pullEvent("rednet_message")
    if protocol == "find" then
        rednet.send(sender,data,"find")
    elseif protocol == "file" then
        contents = textutils.unserialise(message)
        file = contents.fileContents
        fileName = contents.name
        h = fs.open(fileName,"w")
        h.write(file)
        h.close()
        if contents.run then
            shell.openTab(fileName)
        end
    end
end
