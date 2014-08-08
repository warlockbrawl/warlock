
require('class')
heap = require('heap')
require('set')

h = heap()

h:insert(1.0, 'qua')
h:insert(0.0, 'bua')
h:insert(1.0, 'cua')
h:insert(2.0, 'dua')

while (not h:empty()) and h:top() < 1.5 do
	local time, top = h:top()

	print('top: '..top..' ('..time..')')

	h:pop()
end

a = {qua= 'bua'}
b = {qua= 'bua'}

print(a==a)
print(a==b)

t = {}

table.insert(t, 'qua')
table.insert(t, 'bua')

tt = {}

tt[t] = 'qua'

print(tt[t])

s = Set:new()

s:add(t)
s:add(tt)
s:add('qua')

s:foreach(function(x) print(x) end)



s:remove(tt)

print('--')

s:foreach(function(x) print(x) end)


function printer(msg)
	return function()
		print('prt '..msg)
	end
end

function perio(args, task)
	print('perio '..args.qua)
	task.ammo = task.ammo - 1
	if task.ammo <= 0 then
		task:cancel()
	end

end


function main()
	print('main')

	game = Game:new()

	g_t = 0

	function game:time()
		return g_t
	end

	game:initTaskManager()

	game:addTask{func=printer('1_qua'), time=0.75}

	game:addTask{func=perio, period=0.5, attributes={ammo=3}, args={qua=5}}
	game:addTask{func=printer('2_qua'), time=3.0}

	for t = 0.1, 5, 0.1 do
		g_t = t
		print(g_t)
		game:tickTaskManager()
	end


end

