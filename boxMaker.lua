width,height = term.getSize()

shapes = {
    top_left_corner = '\151',
    left_vert_line = '\149',
    top_hor_line = '\131',
}
iShapes = {
    top_right_corner = '\148',
    right_vert_line = '\149',
    bottom_hor_line = '\143',
    bottom_left_corner = '\138',
    bottom_right_corner = '\133'
}

function drawI(i,bg,win)
    win.setTextColor(bg)    
    win.setBackgroundColor(colors.white)
    win.write(i)
    win.setBackgroundColor(colors.black)
    win.setTextColor(colors.white)
end
function drawR(i,bg,win)
    win.setBackgroundColor(bg)
    win.setTextColor(colors.white)
    win.write(i)
end

function drawBox(bg,x,y,len,hg,win)
    win = win or window.create(term.current(),1,1,width,height)
    win.setCursorPos(x,y)
    hg = hg-1
    len = len-1
    drawR(shapes.top_left_corner,bg,win)
    for i=1,len-1 do
        drawR(shapes.top_hor_line,bg,win)
    end
    drawI(iShapes.top_right_corner,bg,win)
    for j = 1,hg-1 do
        win.setCursorPos(x,y+j)
        drawR(shapes.left_vert_line,bg,win)
        win.setCursorPos(x+len,y+j)
        drawI(iShapes.right_vert_line,bg,win)
        for k=1,len-1 do
            win.setCursorPos(x+k,y+j)
            win.setBackgroundColor(bg)
            win.write(" ")
        end
    end
    win.setCursorPos(x,y+hg)
    drawI(iShapes.bottom_left_corner,bg,win)
    for i=1,len-1 do
        drawI(iShapes.bottom_hor_line,bg,win)
    end
    drawI(iShapes.bottom_right_corner,bg,win)
end

function boxedText(text,x,y,bg,fg,len,h,win)
    win = win or window.create(term.current(),1,1,width,height)
    len_ = len or #text + 2
    bg = bg or colors.black
    fg = fg or colors.white
    drawBox(bg,x-1,y-1,len_,h,win)
    if len_ then
        win.setCursorPos(x+(len_-#text-2)/2,y)
    else
        win.setCursorPos(x,y)
    end
    win.setBackgroundColor(bg)
    win.setTextColor(fg)
    win.write(text)
end

return {boxedText = boxedText,drawBox = drawBox}
