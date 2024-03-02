local path = ...
local JM = _G.JM
local Face = require "scripts.objects.face"

do
    _G.SUBPIXEL = _G.SUBPIXEL or 3
    _G.CANVAS_FILTER = _G.CANVAS_FILTER or 'linear'
    _G.TILE = _G.TILE or 16
end

---@class GameState.Game : JM.Scene
local State = JM.Scene:new {
    canvas_w = _G.SCREEN_WIDTH or 320,
    canvas_h = _G.SCREEN_HEIGHT or 180,
    tile = _G.TILE,
    subpixel = _G.SUBPIXEL or 3,
    canvas_filter = _G.CANVAS_FILTER or 'linear',
    cam_scale = 1,
    use_canvas_layer = true,
}

State:set_color(JM_Utils:hex_to_rgba_float("902e99"))
--============================================================================
---@class GameState.Game.Data
local data = {}

--============================================================================

function State:__get_data__()
    return data
end

local function load()
    Face:load()
end

local function finish()
    Face:finish()
end

local function init(args)
    JM.GameObject:init_state(State)
    data.face_man = Face:new(Face.Gender.male)
    data.face_woman = Face:new(Face.Gender.female)

    data.scene_canvas = data.scene_canvas or State:create_canvas()
    data.extra_canvas = data.extra_canvas or State:create_canvas()
    data.result_canvas = data.result_canvas or State:create_canvas()

    data.layer = data.layer or State:newLayer { factor_x = 0, factor_y = 0 }
end

local function textinput(t)

end

local function keypressed(key)
    if key == 'o' then
        State.camera:toggle_grid()
        State.camera:toggle_world_bounds()
    end

    if key == 'r' then
        return State:change_gamestate(State, { skip_finish = true, skip_load = true, skip_transition = true })
    end
end

local function keyreleased(key)

end

local function mousepressed(x, y, button, istouch, presses)

end

local function mousereleased(x, y, button, istouch, presses)

end

local function mousemoved(x, y, dx, dy, istouch)

end

local function touchpressed(id, x, y, dx, dy, pressure)

end

local function touchreleased(id, x, y, dx, dy, pressure)

end

local function gamepadpressed(joystick, button)

end

local function gamepadreleased(joystick, button)

end

local function gamepadaxis(joystick, axis, value)
end

local function update(dt)
    data.face_man:update(dt)
    data.face_woman:update(dt)
end

--========================================================================
local code = love.filesystem.read("/jm-love2d-package/data/shader/bloom_blur_horiz.glsl")
local blur_horiz = love.graphics.newShader(code)
blur_horiz:send("canvas_w", 512.0)

code = love.filesystem.read("/jm-love2d-package/data/shader/bloom_blur_vert.glsl")
local blur_vert = love.graphics.newShader(code)
blur_vert:send("canvas_h", 288.0)

code = love.filesystem.read("/jm-love2d-package/data/shader/bloom.glsl")
local bloom = love.graphics.newShader(code)
bloom:send("threshold", 0.75) --0.75

code = love.filesystem.read("/jm-love2d-package/data/shader/bloom_combine.glsl")
local combine = love.graphics.newShader(code)
combine:send("bloomintensity", 0.5) --0.4

local shaders = { bloom, blur_horiz, blur_vert }
--========================================================================
local function draw_scene(cam)
    local lgx = love.graphics
    lgx.setColor(1, 1, 1)
    return lgx.draw(data.scene_canvas, 0, 0, 0, 1 / State.subpixel)
end

---@param cam JM.Camera.Camera
local function bloom_draw(cam)
    local lgx = love.graphics
    lgx.setCanvas(data.scene_canvas)
    lgx.clear()

    ---===========================
    data.face_man:draw()
    data.face_woman:draw()
    ---===========================


    local layer = data.layer
    layer.custom_draw = draw_scene
    layer.skip_clear = true
    layer.skip_draw = false
    layer:set_shader(shaders)
    layer:draw(cam, State.canvas_layer, data.extra_canvas, data.result_canvas)

    lgx.setCanvas(State.canvas)
    lgx.setColor(1, 1, 1)
    combine:send("bloomtex", data.result_canvas)
    lgx.setShader(combine)

    cam:detach()
    lgx.draw(data.scene_canvas, 0, 0, 0, 1 / State.subpixel)
    lgx.setShader()
    cam:attach(nil, State.subpixel)

    local font = JM:get_font()
    lgx.setColor(JM_Utils:get_rgba3("e6c45c"))
    lgx.rectangle("fill", 0, 0, 128 * 2, 28)
    font:push()
    -- font:set_font_size(6)
    font:printx("um dois três <color-hex=bf3526>testando</color no-space>, um dois três...", 32, 8)
    font:pop()
end

local function normal_draw(cam)
    data.face_man:draw()
    data.face_woman:draw()

    local lgx = love.graphics
    local font = JM:get_font()
    lgx.setColor(JM_Utils:get_rgba3("e6c45c"))
    lgx.rectangle("fill", 0, 0, 128 * 2, 28)
    font:push()
    -- font:set_font_size(6)
    font:printx("um dois tres testando, um dois três...", 32, 8)
    font:pop()
end

---@param cam JM.Camera.Camera
local draw = function(cam)
    return bloom_draw(cam)
    -- return normal_draw(cam)
end
--============================================================================
State:implements {
    load = load,
    init = init,
    finish = finish,
    textinput = textinput,
    keypressed = keypressed,
    keyreleased = keyreleased,
    mousepressed = mousepressed,
    mousereleased = mousereleased,
    mousemoved = mousemoved,
    touchpressed = touchpressed,
    touchreleased = touchreleased,
    gamepadpressed = gamepadpressed,
    gamepadreleased = gamepadreleased,
    gamepadaxis = gamepadaxis,
    update = update,
    draw = draw,
}

return State
