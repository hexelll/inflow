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
    end
end
