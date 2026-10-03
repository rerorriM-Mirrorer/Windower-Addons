-- ConsoleBG+ frame geometry. Texture pixels remain at their native scale.
local layout = {}

local function bounded(value, fallback, minimum, maximum)
    local number = tonumber(value)
    if not number or number ~= number or number == math.huge or number == -math.huge then
        number = fallback
    end
    return math.floor(math.max(minimum, math.min(maximum, number)) + 0.5)
end

function layout.build(settings, viewport, title_width, input_width, editing, input_text_height)
    local screen_width = bounded(viewport.width, 1920, 1, 32768)
    local screen_height = bounded(viewport.height, 1080, 1, 32768)
    local minimum_width = math.min(120, screen_width)
    local minimum_height = math.min(40, screen_height)
    local x = bounded(settings.pos.x, 32, 0, screen_width - minimum_width)
    local y = bounded(settings.pos.y, 16, 0, screen_height - minimum_height)
    local requested_width = settings.extents.x
    if settings.extents.mode == 'screen' then requested_width = screen_width - x * 2 end
    local width = bounded(requested_width, 1070, minimum_width, screen_width - x)
    local padding = bounded(settings.input.padding, 4, 0, 32)
    local height = bounded((tonumber(settings.extents.y) or 344) + padding, 348,
        minimum_height, screen_height - y)
    local fill_alpha = bounded(settings.bg.alpha, 255, 0, 255)
    local top_alpha = bounded(settings.gradient.top, 100, 0, 255)
    local bottom_alpha = bounded(settings.gradient.bottom, 250, 0, 255)
    local border_alpha = bounded(settings.border.alpha, 240, 0, 255)
    local glow = settings.glow or {}
    local glow_alpha = bounded(glow.alpha, 200, 0, 255)
    local red = bounded(settings.bg.red, 255, 0, 255)
    local green = bounded(settings.bg.green, 255, 0, 255)
    local blue = bounded(settings.bg.blue, 255, 0, 255)
    local pieces = {}
    local rectangle = {x = x, y = y, width = width, height = height, padding = padding}

    local function rail_alpha(progress)
        if settings.border.linked ~= true then return border_alpha end
        return border_alpha * fill_alpha * (top_alpha + (bottom_alpha - top_alpha) * progress)
            / (255 * 255)
    end
    rectangle.title_alpha, rectangle.input_alpha = bounded(rail_alpha(0), 240, 0, 255),
        bounded(rail_alpha(1), 240, 0, 255)

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
    -- Draw one continuous fill, including beneath the rails. The rail
    -- textures contain only the silver pixels, so their opacity cannot
    -- introduce a second dark strip or cut off the bottom glow.
    local body_y, body_height = y, height
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

    local top_rail_alpha, bottom_rail_alpha = rail_alpha(0), rail_alpha(1)
    piece('top_left', x, y, left_cap, top_height, top_rail_alpha)
    title_width = bounded(title_width, 40, 1, 256)
    local top_start, top_end = x + left_cap, x + width - right_cap
    if width >= title_width + left_cap + right_cap + 40 then
        local core_width = title_width + 4
        local core_x = top_end - core_width - 16
        local notch_x, notch_end = core_x - 8, core_x + core_width + 8
        piece('top_center', top_start, y, notch_x - top_start, top_height,
            top_rail_alpha, (notch_x - top_start) / 4, 1)
        piece('title_left', notch_x, y, 8, top_height, top_rail_alpha)
        piece('title_right', core_x + core_width, y, 8, top_height, top_rail_alpha)
        piece('top_center', notch_end, y, top_end - notch_end, top_height,
            top_rail_alpha, (top_end - notch_end) / 4, 1)
        rectangle.title_slot = {x = core_x + 2, y = math.max(0, y - 4)}
    else
        piece('top_center', top_start, y, top_end - top_start,
            top_height, top_rail_alpha, (top_end - top_start) / 4, 1)
    end
    piece('top_right', x + width - right_cap, y, right_cap, top_height, top_rail_alpha)
    local bottom_y = y + height - bottom_height
    piece('bottom_left', x, bottom_y, left_cap, bottom_height, bottom_rail_alpha)
    piece('bottom_center', x + left_cap, bottom_y, width - left_cap - right_cap,
        bottom_height, bottom_rail_alpha, (width - left_cap - right_cap) / 4, 1)
    piece('bottom_right', x + width - right_cap, bottom_y,
        right_cap, bottom_height, bottom_rail_alpha)

    if settings.input.enabled == true then
        local inside_top = y + top_height
        local input_height = bounded(settings.input.height, 14, 6,
            math.max(6, height - top_height - bottom_height - 4))
        local divider_y = math.max(inside_top, bottom_y - input_height)
        local divider_alpha = rail_alpha((divider_y - body_y) / body_height)
        rectangle.divider_y = divider_y
        rectangle.divider_visible = settings.input.divider ~= false
        rectangle.input_alpha = bounded(divider_alpha, 240, 0, 255)
        if rectangle.divider_visible then
            piece('divider_left', x, divider_y, left_cap, 2, divider_alpha)
            piece('divider_center', x + left_cap, divider_y, width - left_cap - right_cap, 2,
                divider_alpha, (width - left_cap - right_cap) / 4, 1)
            piece('divider_right', x + width - right_cap, divider_y, right_cap, 2, divider_alpha)
        end
        local tab_height = math.max(10, bounded(input_text_height, 10, 1, 60))
        if divider_y - inside_top >= tab_height then
            local tab_width = math.min(bounded(input_width, 25, 1, 256) + 8,
                width - side_width - right_cap - 4)
            tab_width = math.max(8, tab_width)
            local tab_x = settings.input.tab == 'left' and (x + side_width)
                or math.max(x + side_width, x + width - right_cap - tab_width - 8)
            local tab_y = divider_y - tab_height
            if settings.labels.input_style == 'native' then
                piece('tab_left', tab_x, tab_y, 3, tab_height, divider_alpha)
                piece('tab_center', tab_x + 3, tab_y, tab_width - 7, tab_height, divider_alpha,
                    tab_width - 7, 1)
                piece('tab_right', tab_x + tab_width - 4, tab_y, 4, tab_height, divider_alpha)
            end
            rectangle.input_tab = {x = tab_x, y = tab_y, width = tab_width, height = tab_height}
        end
    end

    if editing then
        piece('resize_handle', x + width - 16, y + height - 16, 14, 14, 255)
    end

    return pieces, rectangle
end

return layout
