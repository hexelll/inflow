--x,y = position on screen, 
--pattern = thing to replace all chars with
--start = string to put before read chars
--s = starting string used internally by function
--i = used as a timer internally by function
local function sinsert(s1,s2,i)
    return string.sub(s1,1,i)..s2..string.sub(s1,i+1,#s1)
end

function readln(x,y,w,tab,pattern,lim,start,s,i)
    start = start or ""
    i = i or #start
    local width,height = term.getSize()
    local cx,cy = term.getCursorPos()
    x = x or cx
    y = y or cy
    local rnString = s or ""
    local eventData = {os.pullEvent()}
    local eventName = eventData[1]
    if eventName == "char" then
        local char = eventData[2]
        if lim then
            local has = false
            for _,c in pairs(lim) do
                if c == char then
                    has = true
                end
            end
            if has then
                rnString = sinsert(rnString,char,i-#start)
                i = i + 1
            end
        else
            rnString = sinsert(rnString,char,i-#start)
            i = i + 1
        end
    elseif eventName == "key" then
        local key = eventData[2]
        if key == keys.backspace then
            if i>=1 then
                rnString = string.sub(rnString,1,i-1-#start)..string.sub(rnString,i+1-#start,#rnString)
                if i >= #start+1 then i = i - 1 end
            end
        elseif key == keys.left then
            if i >= #start+1 then i=i-1 end
        elseif key == keys.right then
            if i < #rnString+#start then i = i + 1 end
        elseif key == keys.enter then
            return rnString
        elseif key == keys.delete then
            if i>=1 then
                rnString = string.sub(rnString,1,i-#start)..string.sub(rnString,i+2-#start,#rnString)
            end
        end
    elseif eventName == "paste" then
		      rnString = sinsert(rnString,eventData[2],i-#start)
		      i = i + #eventData[2]
    elseif eventName == "mouse_click" then
        mx,my = eventData[3],eventData[4]
        if mx >= x and mx <= x+#rnString and my == y then
            i = mx-x
        end
    end
    
    if w then
        term.setCursorPos(x,y)
        term.clearLine()
        term.write(start)
        if pattern then term.write(string.gsub(rnString,".",pattern)) 
        else term.write(rnString) end
        term.setCursorPos(i+1,y)
        term.write("_")
    elseif tab then
        tab.text = string.sub(rnString,1,i).."_"..string.sub(rnString,i+2,#rnString)
        if tab.onInput then
            rnString=tab:onInput()
        end
    end
    return readln(x,y,w,tab,pattern,lim,start,rnString,i)
end

return readln