-- Love CallBacks
function love.load()
	print("load the game")

	-- hero
	print("\tload hero")
	hero = {}
	hero.x = 300
	hero.y = 450
	hero.width = 30
	hero.height = 15
	hero.speed = 150
	hero.go_left = false
	hero.go_right = false
	hero.shots = {} -- holds our fired shots
	hero.shoot = function()
		local shot = {}
		shot.x = hero.x+hero.width/2
		shot.y = hero.y
		shot.width = 2
		shot.height = 5
		shot.speed = 100
		table.insert(hero.shots, shot)
	end
	print("\t -- hero loaded -- ")

	-- var
	print("\tload var")
	is_win = false
	print("\t -- var loaded -- ")

	math.randomseed(os.time())
	math.random()
	math.random()

	-- enemies
	print("\tload enemies")
	enemies = {}
	for i=0,7 do
		local enemy = {}
		enemy.width = 40
		enemy.height = 20
		enemy.x = i*(enemy.width + 60)
		enemy.y = enemy.height + 100
		enemy.speed = 50
		enemy.go_left = false
		enemy.shots = {}
		enemy.shoot = function()
			local shot = {}
			shot.x = enemy.x+enemy.width/2
			shot.y = enemy.y+enemy.height
			shot.width = 2
			shot.height = 5
			shot.speed = enemy.speed*2
			table.insert(enemy.shots, shot)
		end
		table.insert(enemies, enemy)
	end
	print("\t -- enemies loaded -- ")

	-- screen
	print("\tload screen")
	screen = {}
	screen.width = 800
	love.window.setMode(screen.width, 800)
	love.window.setTitle("invaders")
	print("\t -- screen loaded -- ")
	print("-- game loaded -- ")
end


function love.update(dt)
	if hero.go_right and hero.x + hero.width < screen.width then
		hero.x = hero.x + hero.speed*dt
	end
	if hero.go_left and hero.x > 0 then
		hero.x = hero.x - hero.speed*dt
	end

	t = enemies[1].speed
	local once = false
	print("---------------------------- DEBUT ----------------------------------")
	for i,v in ipairs(enemies) do
		-- let them fall down slowly
		if v.go_left then
			v.x = v.x - v.speed*dt
		else
			v.x = v.x + v.speed*dt
		end

		if v.x <= 0 or v.x + v.width >= screen.width and not once then
			print("une seule fois ici grace a "..i)
			once = true
			for ii, vv in ipairs(enemies) do
				vv.y = vv.y + 5
				vv.go_left = not vv.go_left
				vv.speed = vv.speed*1.02
			end
		end

		-- shot ?
		local r = math.random()
		rand = r
		if r < 0.025 and #v.shots == 0 then
			v.shoot()
		end
		local remShot = {}
		for ii, vv in ipairs(v.shots) do
			vv.y = vv.y + dt*vv.speed
			
			if vv.y + vv.height > 465 then
				table.insert(remShot, ii)
			end

			if CheckCollision(vv.x, vv.y, vv.width, vv.height, hero.x, hero.y, hero.width, hero.height) then
				love.event.quit()
			end

		end
		for ii,vv in ipairs(remShot) do
			table.remove(v.shots, vv)
		end

		-- check for collision with ground
		if v.y + v.height > 465 then
			love.event.quit()
		end
		if CheckCollision(v.x, v.y, v.width, v.height, hero.x, hero.y, hero.width, hero.height) then
			love.event.quit()
		end

	end
	print("--------------------------- FIN ---------------------------------")

	local remEnemy = {}
	local remShot = {}
	-- update those shots
	for i,v in ipairs(hero.shots) do
		-- move them up up up
		v.y = v.y - dt * v.speed

		-- mark shots that are not visible for removal
		if v.y < 0 then
			table.insert(remShot, i)
		end

		-- check for collision with enemies
		for ii,vv in ipairs(enemies) do
			if CheckCollision(v.x ,v.y ,v.width ,v.height ,vv.x ,vv.y ,vv.width ,vv.height) then
				-- mark that enemy for removal
				table.insert(remEnemy, ii)
				-- mark the shot to be removed
				table.insert(remShot, i)
			end
		end
	end



	-- remove the marked enemies
	for i,v in ipairs(remEnemy) do
		table.remove(enemies, v)
	end

	for i,v in ipairs(remShot) do
		table.remove(hero.shots, v)
	end

	print("nb enemies: "..#enemies)
	if #enemies == 0 then
		is_win = true
		love.event.quit()
	end
end

function love.quit()
	if is_win then
		print("You win !")
	else
		print("You lose")
	end
end

function love.keypressed(key)
	--here we are going to create some keyboard events
	if key == "right" then --press the right arrow key to push the ball to the right
		hero.go_right = true
	end
	if key == "left" then --press the left arrow key to push the ball to the left
		hero.go_left = true
	end
end


function love.keyreleased(key)
	if key == "right" then
		hero.go_right = false
	end
	if key == "left" then
		hero.go_left = false
	end
	--print(#hero.shots)
	if key == " " and #hero.shots < 300000000000 then
		hero.shoot()
	end
end


function love.draw()
	love.graphics.print(hero.x.." | "..hero.y.."\n"..t.."\n"..#enemies.."\n"..rand, 10, 10)

	-- let's draw some ground
	love.graphics.setColor(0,155,0,255)
	love.graphics.rectangle("fill", 0, 465, 800, 150)

	-- let's draw our hero
	love.graphics.setColor(155,0,0,255)
	love.graphics.rectangle("fill", hero.x,hero.y, hero.width, hero.height)

	-- draw our enemies
	love.graphics.setColor(0,255,255,255)
	for i,v in ipairs(enemies) do
		love.graphics.rectangle("fill", v.x, v.y, v.width, v.height)
		for ii, vv in ipairs(v.shots) do
			love.graphics.rectangle("fill", vv.x, vv.y, vv.width, vv.height)
		end
	end

	love.graphics.setColor(255,255,255,255)
	for i,v in ipairs(hero.shots) do
		love.graphics.rectangle("fill", v.x, v.y, v.width, v.height)
	end
end


-- my func

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
	return x1 < x2+w2 and
	x2 < x1+w1 and
	y1 < y2+h2 and
	y2 < y1+h1
end

