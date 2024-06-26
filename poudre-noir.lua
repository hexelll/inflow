local buttonAPI = require "buttonAPI"
local eventHandler = require "eventHandler"
local readln = require "/readln"

term.setPaletteColour(colors.red,0xCF0000)
term.setPaletteColour(colors.orange,0xFD7D1F)
term.setPaletteColour(colors.cyan,0x00BCA4)

width,height = term.getSize()

my_win = window.create(term.current(),1,1,width,height)

bundle = {}

dir = "north"

function makeReader(bundle,parent,text,textbg,bg,lim,x,y)
    local textB = buttonAPI.mkbutton(
        {
            active = false,
            x = x-#text,
            y = y,
            text = text,
            bg = textbg,
            onTick = function(self)
                if parent.clicked then
                    self.active = true
                else
                    self.active = false
                end
            end
        }
    ).addTo(bundle)
    local reader = buttonAPI.mkbutton(
        {
            active = false,
            x = x,
            y = y,
            text = " ",
            onTick = function(self)
                self.length = #self.text
                if parent.clicked then
                    self.active = true
                else
                    self.active = false
                end
            end,
            onDown = function(self,but,mx,my)
                if self.active and self:isIn(mx,my) then
                    self.bg = textbg
                    self.text = readln(self.x,self.y,false,self,false,lim,false,self.text,mx-self.x)
                    if self.text == "" then self.text = " " end
                    if string.sub(self.text,#self.text,#self.text) == " " and #self.text ~= 1 then
                        self.text = string.sub(self.text,1,#self.text-1)
                    end
                    self.bg = bg
                end
            end
        }
    ).addTo(bundle)
    return reader
end

function makeHeader(bundle,parent,text,textbg)
    return buttonAPI.mkbutton(
        {
            active = parent.active,
            text = text,
            x = parent.x-#text,
            y = parent.y,
            bg = textbg,
            onTick = function(self)
                self.active = parent.active
            end
        }
    ).addTo(bundle)
end

function worldToMap(dir,centerx,centery,refx,refy,x,y,zoom)
    mapx = x-refx
    mapy = y-refy
    if dir == "south" then
        mapx = -mapx
        mapy = -mapy
    elseif dir == "west" then
        mapx,mapy = -mapy,mapx
    elseif dir == "east" then
        mapy = -mapy
    end
    return {x = zoom*mapx*1/3+centerx,
            y = zoom*mapy*1/4+centery}
end

function mapToWorld(dir,centerx,centery,ref,refy,x,y,zoom)
    if dir == "south" then
        x = -x
        y = -y
    elseif dir == "west" then
        x,y = -y,x
    elseif dir == "east" then
        y = -y
    end
    return {
        x = 3*((x-centerx)/zoom)+refx,
        y = 4*((y-centery)/zoom)+refy
    }
end

function addMapPoint(text,data,bundle,parent,dir,centerx,centery,state,x,y)
    refx,refy,zoom = state.x,state.y,state.zoom
    local pos = worldToMap(dir,centerx,centery,refx,refy,x,y,zoom)
    return buttonAPI.mkbutton{
        x = math.floor(pos.x),
        y = math.floor(pos.y),
        text = text,
        data = data,
        active = false,
        selected = false,
        bg = colors.black,
        onDown = function(self,but,mx,my)
            if but == 1 and self:isIn(mx,my) then
                if self.clicked then
                    self.selected = false
                    self.clicked = false
                    self.fg = colors.white
                else
                    self.selected = true
                    self.clicked = true
                    self.fg = colors.cyan
                end
            end
        end,
        onTick = function(self)
            refx,refy,zoom = state.x,state.y,state.zoom
            pos = worldToMap(dir,centerx,centery,refx,refy,x,y,zoom)
            self.x = math.floor(pos.x)
            self.y = math.floor(pos.y)
            self.active = parent.clicked
            if not self.isIn({
                isBoxed = false,
                x = mapRenderer.x,
                y = mapRenderer.y,
                height = mapRenderer.height-2,
                length = mapRenderer.length-2,
                }
                ,self.x
                ,self.y) then
                self.active = false
            end
        end
    }.addTo(bundle)
end

bg = buttonAPI.mkbutton(
    {
        text = "",
        x = 3,
        y = 3,
        length = width-2,
        height = height-2,
        bg = colors.cyan,
        isBoxed = true
    }
).addTo(bundle,#bundle+1)
config = buttonAPI.mkbutton(
    {
        text = "config ",
        y = bg.y,
        onDown = function(self,but,mx,my)
            if self:isIn(mx,my) then
                if not self.clicked then
                    self.bg = colors.lightGray
                    self.clicked = true
                    map.clicked = false
                    map.bg = colors.gray
                else
                    self.bg = colors.gray
                    self.clicked = false
                end
            end
        end,
    }
).addTo(bundle)
config.x = width - config.length
makeHeader(bundle,config,"o|",colors.orange)

map = buttonAPI.mkbutton(
    {
        text = "map ",
        y = bg.y+2,
        onDown = function(self,but,mx,my)
            if self:isIn(mx,my) then
                if not self.clicked then
                    self.bg = colors.lightGray
                    self.clicked = true
                    config.clicked = false
                    config.bg = colors.gray
                else
                    self.bg = colors.gray
                    self.clicked = false
                end
            end
        end,
    }
).addTo(bundle)
map.x = width - map.length
makeHeader(bundle,map,"o|",colors.orange)

mapRenderer = buttonAPI.mkbutton(
    {
        active = false,
        text = "",
        isBoxed = true,
        x = bg.x+1,
        y = bg.y+1,
        height = 13,
        length = 30,
        bg = colors.black,
        onTick = function(self)
            self.active = map.clicked
        end
    }
).addTo(bundle)

function simpleMapAdd(text,data,dir,state,x,y)
    return addMapPoint(text,data,bundle,map,dir,(mapRenderer.x+mapRenderer.length)/2,(mapRenderer.y+mapRenderer.height)/2,state,x,y)
end

local mapState = {
    x = 0,
    y = 0,
    zoom = 1,
}

computer = simpleMapAdd("x",{},dir,mapState,6,2)

point = simpleMapAdd("o",{},dir,mapState,-14,-5)

cursor = buttonAPI.mkbutton{
    text = "+",
    active = false,
    bg = colors.black,
    onTick = function(self)
        self.active = map.clicked
    end
}.addTo(bundle)
cursor.x = math.floor((mapRenderer.x+mapRenderer.length)/2)+1
cursor.y = math.floor((mapRenderer.y+mapRenderer.height)/2)+1

indicator = buttonAPI.mkbutton(
    {
        active = false,
        text = "[zoom:"..tostring(mapState.zoom).." x:"..tostring(mapState.x+1).." z:"..tostring(mapState.y+1).."]",
        x = mapRenderer.x,
        y = mapRenderer.y,
        bg = colors.orange,
        onTick = function(self)
            self.active = map.clicked
            self.text = "[zoom:"..tostring(mapState.zoom).." x:"..tostring(mapState.x+1).." z:"..tostring(mapState.y+1).."]"
        end
    }
).addTo(bundle)

remove = buttonAPI.mkbutton{
    x = mapRenderer.x,
    y = mapRenderer.y + mapRenderer.height-1,
    text = "|remove|",
    bg = colors.gray,
    onTick = function(self)
        self.active = map.clicked
    end,
    onDown = function(self,but,mx,my)
        if self:isIn(mx,my) then
            self.bg = colors.lightGray
            self.clicked = true
            for i=1,#bundle do
                v = bundle[i] or {}
                if v.selected then
                    table.remove(bundle,i)
                    break
                end
            end
        end
    end,
    onUp = function(self,mx,my)
        if self.clicked then
            self.clicked = false
            self.bg = colors.gray
        end
    end
}.addTo(bundle)

readx = makeReader(bundle,config,"x|",colors.orange,colors.gray,{'0','1','2','3','4','5','6','7','8','9'},bg.x+3,bg.y)
ready = makeReader(bundle,config,"y|",colors.orange,colors.gray,{'0','1','2','3','4','5','6','7','8','9'},bg.x+3,bg.y+2)
readz = makeReader(bundle,config,"z|",colors.orange,colors.gray,{'0','1','2','3','4','5','6','7','8','9'},bg.x+3,bg.y+4)

local pre = {
    x = 0,
    y = 0
}

eventHandler.eventLookUp = {
    {
        event = "mouse_click",
        react = function(eventData)
            local but,mx,my = eventData[2],eventData[3],eventData[4]
            pre = {x=mx,y=my}
            buttonAPI.handle(bundle,"down",but,mx,my)
            if but == 2 and map.clicked then
                if mapRenderer:isIn(mx,my) then
                    pos = mapToWorld(dir,(mapRenderer.x+mapRenderer.length)/2,(mapRenderer.y+mapRenderer.height)/2,mapState.x,mapState.y,mx,my,mapState.zoom)
                    simpleMapAdd("T",{},dir,mapState,pos.x,pos.y)
                end
            end
        end,
    },
    {
        event = "mouse_up",
        react = function(eventData)
            local but,mx,my = eventData[2],eventData[3],eventData[4]
            pre = {x=mx,y=my}
            buttonAPI.handle(bundle,"up",but,mx,my)
        end
    },
    {
        event = "mouse_drag",
        react = function(eventData)
            local but,mx,my = eventData[2],eventData[3],eventData[4]
            mapState.x = mapState.x-(mx-pre.x)*4
            mapState.y = mapState.y-(my-pre.y)*4
            pre = {x = mx,y = my}
            buttonAPI.handle(bundle,"drag",but,mx,my)
        end
    },
    {
        event = "mouse_scroll",
        react = function(eventData)
            local dir, x, y = eventData[2],eventData[3],eventData[4]
            if mapState.zoom - dir*0.25 > 0 then
                mapState.zoom = mapState.zoom - dir*0.25
            end
            buttonAPI.handle(bundle,"scroll",dir,x,y)
        end
    },
    {
        event = "key",
        react = function(eventData)
            local key = keys.getName(eventData[2])
            if key == "w" then
                mapState.y = mapState.y-1
            elseif key == "s" then
                mapState.y = mapState.y+1
            elseif key == "a" then
                mapState.x = mapState.x-1
            elseif key == "d" then
                mapState.x = mapState.x+1
            end
        end
    }
}

parallel.waitForAny(
eventHandler.loop,
function()
    while true do
        buttonAPI.render(bundle,my_win)
        sleep()
    end
end
)

