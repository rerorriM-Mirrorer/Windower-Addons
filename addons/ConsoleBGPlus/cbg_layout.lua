-- ConsoleBG+ frame geometry. Texture pixels remain at their native scale.
local layout = {}

local function bounded(value, fallback, minimum, maximum)
    local number = tonumber(value)
    if not number or number ~= number or number == math.huge or number == -math.huge then
        number = fallback
    end
    return math.floor(math.max(minimum, math.min(maximum, number)) + 0.5)
end

function layout.build(settings, viewport, title_width)
    local screen_width = bounded(viewport.width, 1920, 1, 32768)
    local screen_height = bounded(viewport.height, 1080, 1, 32768)
    local minimum_width = math.min(120, screen_width)
    local minimum_height = math.min(40, screen_height)
    local x = bounded(settings.pos.x, 32, 0, screen_width - minimum_width)
    local y = bounded(settings.pos.y, 16, 0, screen_height - minimum_height)
    local requested_width = settings.extents.x
    if settings.extents.mode == 'screen' then requested_width = screen_width - x * 2 end
    local width = bounded(requested_width, 1070, minimum_width, screen_width - x)
    local height = bounded(settings.extents.y, 344, minimum_height, screen_height - y)
    local fill_alpha = bounded(settings.bg.alpha, 255, 0, 255)
    local top_alpha = bounded(settings.gradient.top, 110, 0, 255)
    local bottom_alpha = bounded(settings.gradient.bottom, 235, 0, 255)
    local border_alpha = bounded(settings.border.alpha, 240, 0, 255)
    local glow = settings.glow or {}
    local glow_alpha = bounded(glow.alpha, 36, 0, 255)
    local red = bounded(settings.bg.red, 255, 0, 255)
    local green = bounded(settings.bg.green, 255, 0, 255)
    local blue = bounded(settings.bg.blue, 255, 0, 255)
    local pieces = {}
    local rectangle = {x = x, y = y, width = width, height = height}

    local function piece(texture, px, py, pw, ph, alpha, repeat_x, repeat_y)
        if pw <= 0 or ph <= 0 then return end
        pieces[#pieces + 1] = {
            texture = texture, x = px, y = py, width = pw, height = ph,
            alpha = bounded(alpha, 255, 0, 255), red = red, green = green, blue = blue,
            repeat_x = repeat_x or 1, repeat_y = repeat_y or 1,
        }
    end

    -- A viewport too small for the native corners gets a single clipped tile.
    if width < 84 or height < 18 then
        piece('mid_center', x, y, width, height, bottom_alpha * fill_alpha / 255,
            width / 4, height / 4)
        return pieces, rectangle
    end

    local top_height, bottom_height, side_width, left_cap, right_cap = 10, 8, 3, 20, 64
    local body_y = y + top_height
    local body_height = height - top_height - bottom_height
    -- At most 56 bands. Multiples of four preserve the horizontal stripe phase.
    local band_height = math.max(4, math.ceil(body_height / 224) * 4)
    local offset = 0
    while offset < body_height do
        local rows = math.min(band_height, body_height - offset)
        local progress = (offset + rows / 2) / body_height
        local alpha = (top_alpha + (bottom_alpha - top_alpha) * progress) * fill_alpha / 255
        piece('mid_left', x, body_y + offset, side_width, rows, alpha, 1, rows / 4)
        piece('mid_center', x + side_width, body_y + offset, width - side_width - right_cap,
            rows, alpha, (width - side_width - right_cap) / 4, rows / 4)
        piece('mid_right', x + width - right_cap, body_y + offset,
            right_cap, rows, alpha, 1, rows / 4)
        offset = offset + rows
    end

    if glow_alpha > 0 and fill_alpha > 0 then
        local glow_height = bounded(glow.height, 24, 4, math.max(4, body_height))
        -- Align the glow with the existing four-pixel stripe pattern.
        local start = math.max(0, math.floor((body_height - glow_height) / 4) * 4)
        offset = start
        while offset < body_height do
            local rows = math.min(4, body_height - offset)
            local progress = (offset - start + rows / 2) / (body_height - start)
            local fill_progress = (offset + rows / 2) / body_height
            local opacity = top_alpha + (bottom_alpha - top_alpha) * fill_progress
            local alpha = glow_alpha * progress * progress * fill_alpha * opacity / (255 * 255)
            piece('glow_left', x, body_y + offset, side_width, rows, alpha, 1, rows / 4)
            piece('glow_center', x + side_width, body_y + offset, width - side_width - right_cap,
                rows, alpha, (width - side_width - right_cap) / 4, rows / 4)
            piece('glow_right', x + width - right_cap, body_y + offset,
                right_cap, rows, alpha, 1, rows / 4)
            offset = offset + rows
        end
    end

    piece('top_left', x, y, left_cap, top_height, border_alpha)
    piece('top_center', x + left_cap, y, width - left_cap - right_cap,
        top_height, border_alpha, (width - left_cap - right_cap) / 4, 1)
    piece('top_right', x + width - right_cap, y, right_cap, top_height, border_alpha)
    local bottom_y = y + height - bottom_height
    piece('bottom_left', x, bottom_y, left_cap, bottom_height, border_alpha)
    piece('bottom_center', x + left_cap, bottom_y, width - left_cap - right_cap,
        bottom_height, border_alpha, (width - left_cap - right_cap) / 4, 1)
    piece('bottom_right', x + width - right_cap, bottom_y,
        right_cap, bottom_height, border_alpha)

    title_width = bounded(title_width, 40, 1, 256)
    if width >= title_width + 84 then
        local title_x = x + width - right_cap - title_width - 16
        piece('title_plate', title_x, y, title_width + 8, top_height,
            border_alpha, (title_width + 8) / 4, 1)
        rectangle.title_slot = {x = title_x + 4, y = math.max(0, y - 4)}
    end

    if settings.input.enabled == true then
        local input_height = bounded(settings.input.height, 26, 12, math.max(12, body_height - 4))
        local divider_y = math.max(body_y, bottom_y - input_height)
        piece('divider_left', x, divider_y, left_cap, 2, border_alpha)
        piece('divider_center', x + left_cap, divider_y, width - left_cap - right_cap, 2,
            border_alpha, (width - left_cap - right_cap) / 4, 1)
        piece('divider_right', x + width - right_cap, divider_y, right_cap, 2, border_alpha)
        if divider_y - body_y >= 12 then
            local tab_width = math.min(64, width - side_width - right_cap - 4)
            local tab_x = settings.input.tab == 'left' and (x + side_width)
                or math.max(x + side_width, x + width - right_cap - tab_width - 8)
            local tab_y = divider_y - 12
            piece('tab_left', tab_x, tab_y, 3, 12, border_alpha)
            piece('tab_center', tab_x + 3, tab_y, tab_width - 7, 12, border_alpha, tab_width - 7, 1)
            piece('tab_right', tab_x + tab_width - 4, tab_y, 4, 12, border_alpha)
            rectangle.input_tab = {x = tab_x, y = tab_y, width = tab_width, height = 12}
        end
    end

    return pieces, rectangle
end

return layout
