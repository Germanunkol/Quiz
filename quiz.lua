local Quiz = {}
Quiz.__index = Quiz

local errorString
local NUM_QUESTIONS = 10

local defaultFile = require("defaultFile")
local questionFormat = "([^%s].-)\n%s+(.-)\n%s+(.-)\n%s+(.-)\n%s+(.-)\n"

local buttonWidth = 500
local buttonHeight = 110

local smallButtonWidth = 300
local smallButtonHeight = 60

local correctAnswerCol = { 100, 255, 100 }
local wrongAnswerCol = { 255, 64, 64 }

function Quiz:new( filename )

	buttonWidth = love.graphics.getWidth()/2 - 60

	local q = {
		currentCash = 0,
		curQuestion = 0,
		currentQuestion = 0,
		questions = {},
		replyButtons = {},
	}
	setmetatable( q, self )

	local qFile = love.filesystem.read( filename )
	local qFileNoComments = ""

	Button:clear()

	if qFile then

		for line in qFile:gmatch("(.-)\r?\n") do
			line = line:match("([^#]*).-")		-- remove everything behind a comment
			if #line > 0 and (line:find("[^%s]") ~= nil) then		-- only add non-empty lines
				qFileNoComments = qFileNoComments .. line .. "\n"
			end
		end

		for qe, a1, a2, a3, a4 in qFileNoComments:gmatch( questionFormat ) do
			--[[print( "Question:", q )
			print( "\t", a1 )
			print( "\t", a2 )
			print( "\t", a3 )
			print( "\t", a4 )]]
			Quiz.addQuestion( q, qe, a1, a2, a3, a4 )
			print( qe, a1, a2, a3, a4 )
		end
	end

	if #q.questions == 0 then
		errorString = "No questions found!\n\nPlease put your quiz questions into the file:\n" ..
			love.filesystem.getSaveDirectory() .. "/" .. filename .. "."

		if not love.filesystem.exists( filename ) then
			love.filesystem.write( filename, defaultFile )
		end
	else
		QUIZ_STARTED = true
		Quiz.restart( q )
	end

	local numQuestions = #q.questions
	for i = #q.questions, NUM_QUESTIONS+1, -1 do
		table.remove( q.questions, i )
	end

	return q
end

function Quiz:draw()
	love.graphics.setFont( FONT_LARGE )
	if #self.questions > 0 then
		if not self.won then
			love.graphics.setColor( 255, 128, 64 )	
			love.graphics.printf( "Frage " .. self.curQuestion .. " ( von " .. #self.questions .. ")",
			0, 50, love.graphics.getWidth(), "center" )

			-- Draw the queston:
			love.graphics.setColor( 255, 255, 255 )
			love.graphics.printf( self.questions[self.curQuestion].q,
			20, love.graphics.getHeight()/2 - 150, love.graphics.getWidth()-40, "center" )

			if self.lost then
				love.graphics.setColor( wrongAnswerCol )
				love.graphics.printf( "Leider falsch! Richtig wäre gewesen:\n" ..
				self.questions[self.curQuestion].a1,
				20, love.graphics.getHeight() - 100, love.graphics.getWidth()-40, "center" )
			end
		else
			love.graphics.setColor( correctAnswerCol )
			love.graphics.printf( "Gewonnen!",
				20, love.graphics.getHeight()/2 - 150, love.graphics.getWidth()-40, "center" )
		end
	else
		love.graphics.printf( errorString, 20, 50, love.graphics.getWidth()/2 )
	end
end

function Quiz:addQuestion( q, a1, a2, a3, a4 )
	local newQuestion = {
		q = q,
		a1 = a1,
		a2 = a2,
		a3 = a3,
		a4 = a4,
		a5 = a5,
	}

	local pos = math.random( 1, #self.questions+1 )
	table.insert( self.questions, pos, newQuestion )
end

function Quiz:nextQuestion()
	self.curQuestion = self.curQuestion + 1
	Button:clear()
	if self.curQuestion <= #self.questions then
		local w2 = love.graphics.getWidth()/2
		local h = love.graphics.getHeight() - 400
		local id

		local positions = {
			{
				x = w2 -buttonWidth - 10,
				y = h,
				label = "a) "
			},
			{
				x = w2 + 10,
				y = h,
				label = "b) "
			},
			{
				x = w2 - buttonWidth - 10,
				y = h + buttonHeight + 20,
				label = "c) "
			},
			{
				x = w2 + 10,
				y = h + buttonHeight + 20,
				label = "d) "
			},
		}

		self.replyButtons = {}

		self.replyButtons[1] = Button:new( 0, 0, buttonWidth, buttonHeight,
			self.questions[self.curQuestion].a1, reply( 1 ) )

		self.replyButtons[2] = Button:new( 0, 0,	buttonWidth, buttonHeight,
			self.questions[self.curQuestion].a2, reply( 2 ) )

		self.replyButtons[3] = Button:new( 0, 0, buttonWidth, buttonHeight,
			self.questions[self.curQuestion].a3, reply( 3 ) )

		self.replyButtons[4] = Button:new( 0, 0, buttonWidth, buttonHeight,
			self.questions[self.curQuestion].a4, reply( 4 ) )

		-- Shuffle the buttons:
		for k = 1, 4 do
			local randomPos = math.random( 1, #positions )
			self.replyButtons[k]:setPosition( positions[randomPos].x, positions[randomPos].y )
			self.replyButtons[k]:setLabel( positions[randomPos].label .. self.replyButtons[k].label );
			table.remove( positions, randomPos )
		end
	else
		self.won = true
		Button:new( love.graphics.getWidth() - smallButtonWidth - 20,
			love.graphics.getHeight() - smallButtonHeight - 20,
			smallButtonWidth, smallButtonHeight, "Nochmal starten", function() Quiz:close() end )
	end
end

function Quiz:deactivateButtons()
	for k = 1, #self.replyButtons do
		self.replyButtons[k]:setActive( false )
	end
end

function reply( num )
	return function()
		Quiz.deactivateButtons( CURRENT_QUIZ )
		if num == 1 then
			CURRENT_QUIZ.replyButtons[num]:setColour( correctAnswerCol )
			Button:new( love.graphics.getWidth() - smallButtonWidth - 20,
			 	love.graphics.getHeight() - smallButtonHeight - 20,
				smallButtonWidth, smallButtonHeight, "Weiter", function() CURRENT_QUIZ:nextQuestion() end )
		else
			CURRENT_QUIZ.replyButtons[num]:setColour( wrongAnswerCol )
			Button:new( love.graphics.getWidth() - smallButtonWidth - 20,
				love.graphics.getHeight() - smallButtonHeight - 20,
				smallButtonWidth, smallButtonHeight, "Nochmal versuchen", function() CURRENT_QUIZ:close() end )
			CURRENT_QUIZ.lost = true
		end
	end
end

function Quiz:restart()
	self.won = false
	self.lost = false
	self.curQuestion = 0
	self:nextQuestion()
end

function Quiz:close()
	Menu:load()
end

return Quiz
