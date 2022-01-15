BASE_LOG_PREFIX 	= '[WL] '

function log(msg)
	print(BASE_LOG_PREFIX .. msg)
end

function err(msg)
	display('[X] '..msg, COLOR_RED)
end

function warning(msg)
	display('[W] '..msg, COLOR_DYELLOW)
end

function display(text, color)
	color = color or COLOR_LGREEN

	print('> '..text)

	Say(nil, color..text, false)
end
