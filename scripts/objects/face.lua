local GC = _G.JM.GameObject
local FaceElement = require "scripts.objects.face_element"

local tile = _G.TILE or 16
local random = love.math.random

---@enum Face.Gender
local Gender = {
    male = 1,
    female = 2,
}

---@type table <love.Image>
local IMGS

---@type love.Image|any
local ribbon_img

---@class Face : GameObject
local Face = setmetatable({}, GC)
Face.__index = Face
Face.Gender = Gender

---@param gender Face.Gender
function Face:new(gender)
    local x = tile * 2
    if gender == Gender.female then x = 16 * 12 end
    local obj = GC:new(x, tile * 2, tile * 5, tile * 7)
    setmetatable(obj, self)
    return Face.__constructor__(obj, gender)
end

function Face:__constructor__(gender)
    self.gender = gender
    self.id = 1

    self.components = {}

    if self.gender == Gender.male then
        self:set_eye("left", random(1, FaceElement.MAX_EYE_ID))
        self:set_eye("right", random(1, FaceElement.MAX_EYE_ID))
        self:set_mouth(random(1, FaceElement.MAX_MOUTH_ID))
        self:set_nose(random(1, FaceElement.MAX_NOSE_ID))
        ---
    else
        self.id = 2
    end

    ---@type JM.Effect.Float
    local eff = self:apply_effect("float", { range = 2, pixelmode = true, speed = 1.5 })
    eff.__rad = random(1, 8) * (math.pi * 0.25)
    --
    self.update = Face.update
    self.draw = Face.draw
    return self
end

function Face:load()
    local lgx = love.graphics
    FaceElement:load()

    IMGS = IMGS or {
        [1] = lgx.newImage("/data/img/face_01.png"),
        [2] = lgx.newImage("/data/img/face_02.png"),
    }

    ribbon_img = ribbon_img or lgx.newImage("/data/img/ribbon.png")
end

function Face:finish()
    FaceElement:finish()
end

function Face:init()

end

---@param position "left"|"right"
function Face:set_eye(position, id)
    local obj = FaceElement:new(self,
        position == "left" and FaceElement.IDS.eye_left
        or FaceElement.IDS.eye_right,
        id,
        random() < 0.5 and 1 or -1
    )
    table.insert(self.components, obj)
end

function Face:set_nose(id)
    local obj = FaceElement:new(self, FaceElement.IDS.nose, id, random() < 0.5 and 1 or -1)
    table.insert(self.components, obj)
end

function Face:set_mouth(id)
    local obj = FaceElement:new(self, FaceElement.IDS.mouth, id, 1)
    table.insert(self.components, obj)
end

function Face:get_eye_position()
    local x, y, w, h = self:rect()
    y = y + tile * 1.75
    local middle = x + w * 0.5
    return (middle - tile * 2), y, (middle), y
end

function Face:get_nose_position()
    local x, y, w, h = self:rect()
    return (x + w * 0.5 - tile), (y + tile * 3.25)
end

function Face:get_mouth_position()
    local x, y, w, h = self:rect()
    return (x + w * 0.5 - tile * 1.5), (y + h - tile * 2)
end

function Face:update(dt)
    GC.update(self, dt)

    local N = #self.components
    local list = self.components
    for i = 1, N do
        ---@type FaceElement
        local obj = list[i]
        obj:update(dt)
    end
end

---@param self Face
local function face_draw(self)
    local lgx = love.graphics
    -- lgx.setColor(JM_Utils:get_rgba3("62992e"))
    -- lgx.rectangle("fill", self.x, self.y, self.w, self.h)

    lgx.setColor(1, 1, 1)
    do
        ---@type love.Image
        local img = IMGS[self.id]
        local w, h = img:getDimensions()
        lgx.draw(IMGS[self.id], self.x + self.w * 0.5 - w * 0.5, self.y + self.h * 0.5 - h * 0.5)
    end

    local list = self.components
    local N = #list

    for i = 1, N do
        ---@type FaceElement
        local obj = list[i]
        obj:draw()
    end

    lgx.setColor(0, 0, 1, 0.25)
    local x1, y1, x2, y2 = self:get_eye_position()
    lgx.rectangle("line", x1, y1, 32, 32)
    lgx.rectangle("line", x2, y2, 32, 32)
    x1, y1 = self:get_nose_position()
    lgx.rectangle("line", x1, y1, 32, 32)
    x1, y1 = self:get_mouth_position()
    lgx.rectangle("line", x1, y1, 48, 32)
    lgx.rectangle("line", self.x, self.y, self.w, self.h)

    if self.gender == Gender.female then
        lgx.setColor(1, 1, 1)
        lgx.draw(ribbon_img, self.x + self.w - 32, self.y - 16)
    end
end

function Face:draw()
    return GC.draw(self, face_draw)
end

return Face
