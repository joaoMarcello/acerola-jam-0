local GC = _G.JM.GameObject

---@enum FaceElement.Elements
local Element = {
    eye_left = 1,
    eye_right = 2,
    ear_left = 3,
    ear_right = 4,
    nose = 5,
    mouth = 6,
}

local tile = _G.TILE or 16

local IMGS

local QUADS


---@class FaceElement : GameObject
local FaceElement = setmetatable({}, GC)
FaceElement.__index = FaceElement
FaceElement.IDS = Element

---@param face Face
---@param id_element FaceElement.Elements
---@param id number|nil
---@param direction 1|-1|nil
function FaceElement:new(face, id_element, id, direction)
    id = id or 1
    direction = direction or 1
    local obj = GC:new(0, 0, 32, 32, 10)
    setmetatable(obj, self)
    return FaceElement.__constructor__(obj, face, id_element, id, direction)
end

function FaceElement:__constructor__(face, id_element, id, direction)
    self.id = id
    self.direction = 1 --direction

    if id_element == Element.eye_left then
        self.direction = -1
    end

    ---@type FaceElement.Elements
    self.id_element = id_element

    ---@type Face
    self.face = face

    --
    self.update = FaceElement.update
    self.draw = FaceElement.draw
    return self
end

local function count_elements(t)
    local c = 0
    for _, _ in next, t do
        c = c + 1
    end
    return c
end

function FaceElement:load()
    local lgx = love.graphics

    IMGS = IMGS or {
        [Element.eye_left] = lgx.newImage("/data/img/eye_atlas.png"),
        [Element.nose] = lgx.newImage("/data/img/nose_atlas.png"),
        [Element.mouth] = lgx.newImage("/data/img/mouth_atlas.png"),
    }
    IMGS[Element.eye_right] = IMGS[Element.eye_left]

    local w1, h1 = IMGS[Element.eye_left]:getDimensions()
    local w2, h2 = IMGS[Element.nose]:getDimensions()
    local w3, h3 = IMGS[Element.mouth]:getDimensions()

    QUADS = QUADS or {
        [Element.eye_left] = {
            [1] = lgx.newQuad(0, 0, 32, 32, w1, h1),
            [2] = lgx.newQuad(32, 0, 32, 32, w1, h1),
            [3] = lgx.newQuad(64, 0, 32, 32, w1, h1),
            ---
            [4] = lgx.newQuad(0, 32, 32, 32, w1, h1),
            [5] = lgx.newQuad(32, 32, 32, 32, w1, h1),
            [6] = lgx.newQuad(64, 32, 32, 32, w1, h1),
            ---
            [7] = lgx.newQuad(0, 64, 32, 32, w1, h1),
            [8] = lgx.newQuad(32, 64, 32, 32, w1, h1),
            [9] = lgx.newQuad(64, 64, 32, 32, w1, h1),
        },
        ---
        ---
        [Element.nose] = {
            [1] = lgx.newQuad(0, 0, 32, 32, w2, h2),
            [2] = lgx.newQuad(32, 0, 32, 32, w2, h2),
            [3] = lgx.newQuad(64, 0, 32, 32, w2, h2),
            ---
            [4] = lgx.newQuad(0, 32, 32, 32, w2, h2),
            [5] = lgx.newQuad(32, 32, 32, 32, w2, h2),
            [6] = lgx.newQuad(64, 32, 32, 32, w2, h2),
        },
        ---
        ---
        [Element.mouth] = {
            [1] = lgx.newQuad(0, 0, 48, 32, w3, h3),
            [2] = lgx.newQuad(48, 0, 48, 32, w3, h3),
            [3] = lgx.newQuad(96, 0, 48, 32, w3, h3),
            ---
            [4] = lgx.newQuad(0, 32, 48, 32, w3, h3),
            [5] = lgx.newQuad(48, 32, 48, 32, w3, h3),
            [6] = lgx.newQuad(96, 32, 48, 32, w3, h3),
        },
        ---
        ---
    }
    QUADS[Element.eye_right] = QUADS[Element.eye_left]

    FaceElement.MAX_EYE_ID = count_elements(QUADS[Element.eye_left])
    FaceElement.MAX_NOSE_ID = count_elements(QUADS[Element.nose])
    FaceElement.MAX_MOUTH_ID = count_elements(QUADS[Element.mouth])
end

function FaceElement:init()

end

function FaceElement:get_draw_position()
    local id = self.id_element

    if id == Element.eye_left then
        local x, y = self.face:get_eye_position()
        return x, y
        ---
    elseif id == Element.eye_right then
        local _, _, x2, y2 = self.face:get_eye_position()
        return x2, y2
        ---
    elseif id == Element.nose then
        return self.face:get_nose_position()
        ---
    elseif id == Element.mouth then
        return self.face:get_mouth_position()
        ---
    end
end

function FaceElement:update(dt)
    GC.update(self, dt)

    self.x, self.y = self:get_draw_position()
end

---@param self FaceElement
local function element_draw(self)
    local lgx = love.graphics
    lgx.setColor(1, 1, 1)

    local x, y = self.x, self.y

    ---@type love.Quad
    local quad = QUADS[self.id_element][self.id]
    local _, _, w, h = quad:getViewport()

    lgx.draw(IMGS[self.id_element], quad,
        x + w * 0.5,          -- px
        y + h * 0.5,          -- py
        0, self.direction, 1, -- rotation, scale_x, scale_y
        w * 0.5,              -- ox
        h * 0.5               -- oy
    )

    lgx.setColor(1, 0, 0)
    -- lgx.rectangle("line", self:rect())
end

function FaceElement:draw()
    return GC.draw(self, element_draw)
end

return FaceElement
