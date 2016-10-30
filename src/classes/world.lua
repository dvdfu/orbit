local Class    = require 'modules.hump.class'
local Signal   = require 'modules.hump.signal'
local Vector   = require 'modules.hump.vector'
local Camera   = require 'src.camera'
local Bit      = require 'src.classes.bit'
local Planet   = require 'src.classes.planet'
local Player   = require 'src.classes.player'
local Body     = require 'src.mixins.body'
local Asteroid = require 'src.classes.asteroid'

local World = Class {
    NUM_PLANETS = 2,

    -- Generation Parameters
    PLANET_STARTING_POSITION = { low = -10, high = 10 },
    PLANET_RADIUS = { low = 100, high = 200 },
    PLANET_RADIUS_SHRINK_FACTOR = 3,
    SPACE_SHADER = love.graphics.newShader([[
        uniform vec2 iResolution;
        uniform float iGlobalTime;
        uniform vec2 iMouse;

        #define iterations 17
        #define formuparam 0.53

        #define volsteps 10
        #define stepsize 0.1

        #define zoom   0.800
        #define tile   1
        #define speed  0.010

        #define brightness 0.001
        #define darkmatter 0.300
        #define distfading 0.730
        #define saturation 0.850

        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        	// get coords and direction
        	vec2 uv = screen_coords.xy / iResolution - 0.5;
        	uv.y *= iResolution.y / iResolution.x;
        	vec3 dir = vec3(uv * zoom, 1.0);
        	float time = iGlobalTime * speed + 0.25;

        	// mouse rotation
        	float a1 = 0.5 + iMouse.x / iResolution.x * 2.0;
        	float a2 = 0.8 + iMouse.y / iResolution.y * 2.0;
        	mat2 rot1 = mat2(cos(a1), sin(a1), -sin(a1), cos(a1));
        	mat2 rot2 = mat2(cos(a2), sin(a2), -sin(a2), cos(a2));
        	dir.xz *= rot1;
        	dir.xy *= rot2;
        	vec3 from = vec3(1.0, 0.5, 0.5);
        	from += vec3(time * 2.0, time, -2.0);
        	from.xz *= rot1;
        	from.xy *= rot2;

        	// volumetric rendering
        	float s = 0.1, fade = 1.0;
        	vec3 v = vec3(0.0);
        	for (int r = 0; r < volsteps; r++) {
        		vec3 p = from + s * dir * 0.5;
        		p = abs(vec3(tile) - mod(p, vec3(tile * 2.0))); // tiling fold
        		float pa, a = pa = 0.0;
        		for (int i = 0; i < iterations; i++) {
        			p = abs(p) / dot(p, p)-formuparam; // the magic formula
        			a += abs(length(p) - pa); // absolute sum of average change
        			pa = length(p);
        		}
        		float dm = max(0.0, darkmatter - a * a * 0.001); // dark matter
        		a *= a * a; // add contrast
        		if (r > 6) fade *= 1.0 - dm; // dark matter, don't render near
        		//v += vec3(dm,dm * 0.5, 0.0);
        		v += fade;
        		v += vec3(s, s * s, s * s * s * s) * a * brightness * fade; // coloring based on distance
        		fade *= distfading; // distance fading
        		s += stepsize;
        	}
        	v = mix(vec3(length(v)), v, saturation); //color adjust
        	return vec4(v * 0.01, 1.0);
        }

        vec4 position(mat4 transform_projection, vec4 vertex_position) {
            return transform_projection * vertex_position;
        }
    ]])
}

local function getInRange(range)
    return RNG:random(range.low, range.high)
end

local function beginContact(a, b, coll)
    local aData = a:getUserData()
    local bData = b:getUserData()

    if aData and bData then
        aData.collide(bData)
        bData.collide(aData)
    end
end

local function endContact(a, b, coll)
    local aData = a:getUserData()
    local bData = b:getUserData()

    if aData and bData then
        aData.endCollide(bData)
        bData.endCollide(aData)
    end
end

local function preSolve(a, b, coll) end

local function postSolve(a, b, coll, normal, tangent) end

local function contactFilter(a, b)
    local aData = a:getUserData()
    local bData = b:getUserData()

    if aData.tag == 'Bit' then
        if bData.object == aData.object.owner then return false end
    end

    if bData.tag == 'Bit' then
        if aData.object == bData.object.owner then return false end
    end

    return true
end

function World:init()
    Signal.register('cam_shake', function(shake)
        self.camera:shake(shake)
    end)

    self.physicsWorld = love.physics.newWorld(0, 0, true)
    self.physicsWorld:setCallbacks(beginContact, endContact, preSolve, postSolve)
    self.physicsWorld:setContactFilter(contactFilter)

    self.camera = Camera(8)
    self.planets = {}
    self.players = {}
    self.objects = {}
    self.asteroids = {}

    self:generate()
end

function World:generate()
    self:generatePlanets()

    for i = 1, 10 do
        local bit = Bit(self.physicsWorld, self.planets, nil, 0, 0)
        table.insert(self.objects, bit)
    end

    for i = 1, 5 do
        local asteroid = Asteroid(self.physicsWorld, self.planets, RNG:random(-self.radius, self.radius), RNG:random(-self.radius, self.radius), RNG:random(15, 30))
        table.insert(self.objects, asteroid)
        table.insert(self.asteroids, asteroid)
    end
end

function World:generatePlanets()
    local joysticks = love.joystick.getJoystickCount()
    local fakePlanets = {}
    local genWorld = love.physics.newWorld(0, 0, true)
    genWorld:setCallbacks(beginContact, endContact, preSolve, postSolve)

    for i = 1, joysticks + World.NUM_PLANETS do
        local x = getInRange(World.PLANET_STARTING_POSITION);
        local y = getInRange(World.PLANET_STARTING_POSITION)
        local radius = getInRange(World.PLANET_RADIUS)
        local planet = Body(genWorld, x, y, radius, true)
        table.insert(fakePlanets, planet)
    end

    while true do
        genWorld:update(1)

        local allAsleep = true
        for _, v in pairs(fakePlanets) do
            if v.body:isAwake() then
                allAsleep = false
            end
        end

        if allAsleep then break end
    end

    self.radius = 0

    for i = 1, joysticks + World.NUM_PLANETS do
        local v = Vector(fakePlanets[i].body:getX(), fakePlanets[i].body:getY())
        local planet = Planet(self.physicsWorld, v.x, v.y, fakePlanets[i].radius / World.PLANET_RADIUS_SHRINK_FACTOR, false)

        table.insert(self.planets, planet)
        table.insert(self.objects, planet)

        if v:len() + fakePlanets[i].radius > self.radius then
            self.radius = v:len() + fakePlanets[i].radius
        end

        if i <= joysticks then
            local player = Player(i, self.physicsWorld, self, planet, self.planets, RNG:random(2 * math.pi))
            table.insert(self.objects, player)
            table.insert(self.players, player)
        end
    end

    for i = joysticks + 1, joysticks + World.NUM_PLANETS do
    end

    genWorld:destroy()
end

function World:addObject(object)
    table.insert(self.objects, object)
end

function World:update(dt)
    self.physicsWorld:update(dt)

    for key, object in pairs(self.objects) do
        if object:isDead() then
            if object.fixture:getUserData().tag == 'Asteroid' then
                for i = 1, 3 do
                    local bit = Bit(self.physicsWorld, self.planets, nil, object.body:getX(), object.body:getY())
                    table.insert(self.objects, bit)
                end
            elseif object.fixture:getUserData().tag == 'Player' then
                table.remove(self.players, object.id)
            end
            object.body:destroy()
            table.remove(self.objects, key)
        else
            object:update(dt)
        end
    end

    self:handleCamera()
end

function World:handleCamera()
    self.cameraPre = self.camera.pos

    local cameraVec = Vector()
    local playerDist = 0
    for _, player in pairs(self.players) do
        cameraVec = cameraVec + player.pos
        if player.pos:len() > playerDist then
            -- gets the farthest player distance
            playerDist = player.pos:len()
        end
    end

    cameraVec = cameraVec / #self.players
    self.camera:follow(cameraVec)

    local zoom = math.min(1, 400 / (50 + playerDist))
    self.camera:zoomTo(zoom)
    self.camera:update(dt)
end

function World:draw()
    World.SPACE_SHADER:send('iResolution', {
        love.graphics.getWidth(),
        love.graphics.getHeight()
    })
    World.SPACE_SHADER:send('iMouse', {
        self.camera.pos.x / 100,
        self.camera.pos.y / 100
    })
    World.SPACE_SHADER:send('iGlobalTime', 0)
    -- love.graphics.setShader(World.SPACE_SHADER)
    -- love.graphics.rectangle('fill', 0, 0, love.graphics.getDimensions())
    -- love.graphics.setShader()

    self.camera:draw(function()
        love.graphics.circle('line', 0, 0, self.radius)

        for _, object in pairs(self.objects) do
            object:draw()
        end
    end)
end

return World
