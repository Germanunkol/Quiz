
local Menu = {}

local quizzes = {}

local errorString = nil
local defaultFile = require("defaultFile")

local smallButtonWidth = 300
local smallButtonHeight = 60

function Menu:load()
	local files = love.filesystem.getDirectoryItems( "." )

	quizzes = {}
	Button:clear()
	self.category = nil
	CURRENT_QUIZ = nil

	for i, f in pairs( files ) do
		local category = f:match( "(.*)%.txt" )
		if category then
			if category:sub(1,1) ~= "." then
				table.insert( quizzes, category )
			end
		end
	end

	if #quizzes == 0 then
		errorString = "No questions found!\n\nPlease put your quiz questions into the folder:\n" ..
			love.filesystem.getSaveDirectory() .. ".\n\nAn example file has been created:\n" ..
			love.filesystem.getSaveDirectory() .. "/Questions.txt"

		if not love.filesystem.exists( "Questions.txt" ) then
			love.filesystem.write( "Questions.txt", defaultFile )
		end
		return
	end

	for i, category in pairs( quizzes ) do
		Button:new( (love.graphics.getWidth() - smallButtonWidth)/2,
			love.graphics.getHeight()/2 - 180 + i*(smallButtonHeight+20),
			smallButtonWidth, smallButtonHeight,
			category, self:chooseCategory( category ) )
	end
end

function Menu:chooseCategory( category )
	return function()
		CURRENT_QUIZ = Quiz:new( category .. ".txt" )
	end
end

function Menu:getCategory()
	return self.category
end

function Menu:draw()
	if not errorString then
		love.graphics.setFont( FONT_LARGE )
		love.graphics.setColor( 255, 255, 255 )
		love.graphics.printf( "Willkommen!\nWähle eine Kategorie:",
		20, love.graphics.getHeight()/2 - 200, love.graphics.getWidth()-40, "center" )
	else
		love.graphics.printf( errorString, 20, 50, love.graphics.getWidth()/2 )
	end
end

return Menu
