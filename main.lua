
CURRENT_QUIZ = nil

Button = require("button")
Quiz = require("quiz")
Menu = require("menu")

FONT_SMALL = love.graphics.newFont( 18 )
FONT_LARGE = love.graphics.newFont( 23 )

function love.load()
	love.window.setMode( 0, 0, {fullscreen=true})

	math.randomseed(os.time())

	Menu:load()

	love.graphics.setLineWidth(2)
end

function love.draw()

	if CURRENT_QUIZ then
		CURRENT_QUIZ:draw()
	else
		Menu:draw()
	end
	love.graphics.setFont( FONT_SMALL )
	Button:drawAll()
end

function love.update( dt )
	Button:mousemoved( love.mouse.getPosition() )
end

function love.mousepressed( x, y, button )
	Button:mousepressed( x, y )
end
