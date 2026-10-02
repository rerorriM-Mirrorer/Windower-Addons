-- ConsoleBG+ frame geometry. Texture pixels remain at their native scale.
local layout = {}

local function bounded(value, fallback, minimum, maximum)
    local number = tonumber(value)
    if not number or number ~= number or number == math.huge or number == -math.huge then
        number = fallback
    end
    return math.floor(math.max(minimum, math.min(maximum, number)) + 0.5)
end

function layout.build(settings, viewport)
    local screen_width = bounded(viewport.width, 1920, 1, 32768)
    local screen_height = bounded(viewport.height, 1080, 1, 32768)
    local minimum_width = math.min(120, screen_width)
    local minimum_height = math.min(40, screen_height)
    local x = bounded(settings.pos.x, 32, 0, screen_width - minimum_width)
    local y = bounded(settings.pos.y, 16, 0, screen_height - minimum_height)
    local width = bounded(settings.extents.x, 1070, minimum_width, screen_width - x)
    local height = bounded(settings.extents.y, 344, minimum_height, screen_height - y)
    local fill_alpha = bounded(settings.bg.alpha, 255, 0, 255)
    local top_alpha = bounded(settings.gradient.top, 110, 0, 255)
    local bottom_alpha = bounded(settings.gradient.bottom, 235, 0, 255)
    local border_alpha = bounded(settings.border.alpha, 240, 0, 255)
    local red = bounded(settings.bg.red, 255, 0, 255)
    local green = bounded(settings.bg.green, 255, 0, 255)
    local blue = bounded(settings.bg.blue, 255, 0, 255)
    local pieces = {}

    local function piece(texture, px, py, pw, ph, alpha, repeat_x, repeat_y)
        if pw <= 0 or ph <= 0 then return end
        pieces[#pieces + 1] = {
            texture = texture, x = px, y = py, width = pw, height = ph,
            alpha = bounded(alpha, 255, 0, 255), red = red, green = green, blue = blue,
            repeat_x = repeat_x or 1, repeat_y = repeat_y or 1,
        }
    end

    -- A viewport too small for the native corners gets a single clipped tile.
    if width < 40 or height < 18 then
        piece('mid_center', x, y, width, height, bottom_alpha * fill_alpha / 255,
            width / 4, height / 4)
        return pieces, {x = x, y = y, width = width, height = height}
    end

    local top_height, bottom_height, side_width, corner_width = 10, 8, 3, 20
    local body_y = y + top_height
    local body_height = height - top_height - bottom_height
    -- At most 64 bands. Multiples of four preserve the horizontal stripe phase.
    local band_height = math.max(4, math.ceil(body_height / 256) * 4)
    local offset = 0
    while offset < body_height do
        local rows = math.min(band_height, body_height - offset)
        local progress = (offset + rows / 2) / body_height
        local alpha = (top_alpha + (bottom_alpha - top_alpha) * progress) * fill_alpha / 255
        piece('mid_left', x, body_y + offset, side_width, rows, alpha, 1, rows / 4)
        piece('mid_center', x + side_width, body_y + offset, width - side_width * 2,
            rows, alpha, (width - side_width * 2) / 4, rows / 4)
        piece('mid_right', x + width - side_width, body_y + offset,
            side_width, rows, alpha, 1, rows / 4)
        offset = offset + rows
    end

    piece('top_left', x, y, corner_width, top_height, border_alpha)
    piece('top_center', x + corner_width, y, width - corner_width * 2,
        top_height, border_alpha, (width - corner_width * 2) / 4, 1)
    piece('top_right', x + width - corner_width, y, corner_width, top_height, border_alpha)
    local bottom_y = y + height - bottom_height
    piece('bottom_left', x, bottom_y, corner_width, bottom_height, border_alpha)
    piece('bottom_center', x + corner_width, bottom_y, width - corner_width * 2,
        bottom_height, border_alpha, (width - corner_width * 2) / 4, 1)
    piece('bottom_right', x + width - corner_width, bottom_y,
        corner_width, bottom_height, border_alpha)

    if settings.input.enabled == true then
        local input_height = bounded(settings.input.height, 26, 12, math.max(12, body_height - 4))
        local divider_y = math.max(body_y, bottom_y - input_height)
        piece('divider', x + side_width, divider_y, width - side_width * 2, 2,
            border_alpha, (width - side_width * 2) / 4, 1)
    end

    return pieces, {x = x, y = y, width = width, height = height}
end

return layout
