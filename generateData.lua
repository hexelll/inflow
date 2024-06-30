args = {...}
handle = fs.open("data.txt","w")
data = {
x = args[1],
y = args[2],
z = args[3],
name = args[4],
id = os.getComputerID()
}
handle.write(textutils.serialise(data))
handle.close()
