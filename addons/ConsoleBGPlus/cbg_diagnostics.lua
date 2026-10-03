-- Records visibility/layout observations without writing to the console.
-- Console output would itself trigger displayactivity and spoil the trace.
local diagnostics = {}
local native_fields = {
    'profile_name', 'branch', 'ffxi_version', 'launcher_version', 'hook_version',
    'x_res', 'y_res', 'ui_x_res', 'ui_y_res', 'window_x_pos', 'window_y_pos',
}
local setting_groups = {'pos', 'extents', 'bg', 'gradient', 'border', 'glow', 'input', 'labels', 'console'}

local function clean(value)
    return tostring(value):gsub('[\r\n\t]', ' ')
end

local function sample(context)
    local r, v = context.rectangle, context.viewport
    return string.format('console_visible=%s frame_visible=%s preview=%s edit=%s frame=%d,%d,%d,%d viewport=%d,%d',
        tostring(context.console_visible), tostring(context.frame_visible), tostring(context.preview),
        tostring(context.edit), r.x, r.y, r.width, r.height, v.width, v.height)
end

local function header(context, version)
    local lines = {'ConsoleBG+ v' .. version,
        'UTC: ' .. os.date('!%Y-%m-%dT%H:%M:%SZ'), sample(context),
        'The frame size includes input.padding pixels of extra bottom space.',
        'Native position below is the last position written by this addon, not a queried position.',
        'Native console font, input text, output buffer, fade delay, and fade opacity: no documented getters.',
        'Input visibility currently follows console visibility; it does not establish typing focus.',
        'Layout uses retained positive label bounds; raw native bounds can be 0x0 while hidden.',
        'No console input or output text is recorded.', '', '[Windower settings]'}
    for _, key in ipairs(native_fields) do
        if context.native_settings[key] ~= nil then
            lines[#lines + 1] = key .. '=' .. clean(context.native_settings[key])
        end
    end
    local keys = {}
    for key in pairs(context.native_settings) do keys[#keys + 1] = clean(key) end
    table.sort(keys)
    lines[#lines + 1] = 'available_keys=' .. table.concat(keys, ', ')
    lines[#lines + 1] = ''
    lines[#lines + 1] = '[ConsoleBG+ saved settings]'
    for _, group in ipairs(setting_groups) do
        local values, names = context.settings[group] or {}, {}
        for key, value in pairs(values) do
            if type(value) ~= 'table' and type(value) ~= 'function' then names[#names + 1] = key end
        end
        table.sort(names)
        for _, key in ipairs(names) do
            lines[#lines + 1] = group .. '.' .. clean(key) .. '=' .. clean(values[key])
        end
    end
    local p = context.native_position
    lines[#lines + 1] = ''
    lines[#lines + 1] = '[Layout measurements]'
    lines[#lines + 1] = 'native_position_written=' .. (p and (p.x .. ',' .. p.y) or 'none')
    lines[#lines + 1] = 'position_setter=' .. clean(context.position_setter)
    lines[#lines + 1] = 'divider_y=' .. clean(context.rectangle.divider_y or 'hidden')
    lines[#lines + 1] = 'divider_visible=' .. clean(context.rectangle.divider_visible or false)
    for name, label in pairs(context.label_measurements) do
        lines[#lines + 1] = name .. '_label=' .. label.width .. 'x' .. label.height
            .. ' (' .. clean(label.source) .. ')'
        lines[#lines + 1] = name .. '_native_bounds=' .. clean(label.native_width)
            .. 'x' .. clean(label.native_height)
    end
    lines[#lines + 1] = 'primitive_count=' .. context.primitive_count
    return table.concat(lines, '\n') .. '\n'
end

function diagnostics.new(root, version)
    if root:sub(-1) ~= '/' and root:sub(-1) ~= '\\' then root = root .. '/' end
    local directory = root .. 'data/'
    local recorder = {path = directory .. 'visibility.log', active = false}
    local file, previous, entries = nil, nil, 0

    local function open(path)
        if windower.create_dir then windower.create_dir(directory) end
        return io.open(path, 'w')
    end

    function recorder.stop()
        recorder.active = false
        local result, err = true, nil
        if file then result, err = file:close() end
        file, previous = nil, nil
        return result, err
    end

    function recorder.snapshot(context)
        local path = directory .. 'diagnostics.txt'
        local output, err = open(path)
        if not output then return nil, err end
        local written, write_error = output:write(header(context, version))
        local closed, close_error = output:close()
        if not written or not closed then return nil, write_error or close_error end
        return path
    end

    function recorder.observe(context)
        if not recorder.active then return end
        local state = sample(context)
        if state == previous then return end
        local written, err = file:write(string.format('%s frame=%d %s\n',
            os.date('!%Y-%m-%dT%H:%M:%SZ'), context.frame, state))
        local flushed, flush_error
        if written then flushed, flush_error = file:flush() end
        if not written or not flushed then
            recorder.stop()
            return nil, err or flush_error
        end
        previous, entries = state, entries + 1
        -- Keep a forgotten trace bounded. Timestamps have one-second
        -- precision; frame numbers provide ordering, not a fade-curve clock.
        if entries >= 512 then
            recorder.stop()
            return nil, 'Trace stopped after 512 state changes.'
        end
        return true
    end

    function recorder.start(context)
        recorder.stop()
        local err
        file, err = open(recorder.path)
        if not file then return nil, err end
        local written, write_error = file:write(header(context, version), '\n[Visibility and layout transitions]\n')
        if not written then recorder.stop(); return nil, write_error end
        recorder.active, previous, entries = true, nil, 0
        return recorder.observe(context)
    end

    return recorder
end

return diagnostics
