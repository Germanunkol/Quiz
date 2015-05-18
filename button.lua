local buttonList = {}

local Button = {}
Button.__index = Button

local defaultCol = {255, 128, 64}

function Button:new( x, y, w, h, label, event )
	local o = {}
	setmetatable( o, self )
	o.x = x
	o.y = y
	o.w = w
	o.h = h
	o.label = label
	o.event = event
	o.active = true
	o.col = defaultCol

	local wW, wH = FONT_SMALL:getWrap( o.label, o.w )
	o.hOffset = (h - wH*FONT_SMALL:getHeight())/2

	table.insert( buttonList, o )

	return o
end

function Button:draw()
	love.graphics.setColor( self.col[1], self.col[2], self.col[3], 64 )
	love.graphics.rectangle( "fill", self.x, self.y, self.w, self.h )
	if self.highlight then
		love.graphics.setColor( 255, 255, 255 )	
	else
		love.graphics.setColor( self.col[1], self.col[2], self.col[3], 255 )
	end
	if self.active then
		love.graphics.rectangle( "line", self.x, self.y, self.w, self.h )
	end
	love.graphics.printf( self.label, self.x + 10, self.y + self.hOffset, self.w - 20, "center" )
end

function Button:setColour( col )
	self.col = col
end

function Button:setActive( active )
	self.active = active
	self.highlight = false
end

function Button:setPosition( x, y )
	self.x, self.y = x, y
end
function Button:setLabel( new )
	self.label = new
	local wW, wH = FONT_SMALL:getWrap( self.label, self.w )
	self.hOffset = (self.h - wH*FONT_SMALL:getHeight())/2
end

function Button:drawAll()
	for k, v in ipairs( buttonList ) do
		v:draw()
	end
end

function Button:isInside( x, y )
	return x > self.x and y > self.y and
		x < self.x + self.w and y < self.y + self.h
end

function Button:mousepressed( x, y )
	for k = #buttonList,1,-1 do
		local b = buttonList[k]
		if b.active and b:isInside( x, y ) then
			if b.event then b.event() end
			return
		end
	end
end

function Button:mousemoved( x, y )
	for k, v in ipairs( buttonList ) do
		v.highlight = false
	end
	for k = #buttonList,1,-1 do
		local b = buttonList[k]
		if b.active and  b:isInside( x, y ) then
			b.highlight = true
			return
		end
	end
end

function Button:clear()
	buttonList = {}
end

return Button
