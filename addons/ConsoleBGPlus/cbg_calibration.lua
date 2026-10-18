-- Addon text is a proxy for the native console, not a console font getter.
-- Measurements are opt-in, rendered invisibly, and accepted only after settling.
local calibration = {}
local sample = 'Agjpqy 0123456789'

function calibration.key(font, size)
    return 'font_' .. font:lower():gsub('.', function(c) return string.format('%02x', string.byte(c)) end) .. '_' .. size
end

function calibration.new()
    local active, frames, stable, previous = false, 0, 0, nil
    local names = {'ConsoleBGPlus_probe_single', 'ConsoleBGPlus_probe_multi'}
    local probe = {}
    function probe.cancel()
        if active then for _, name in ipairs(names) do windower.text.delete(name) end end
        active, previous = false, nil
    end
    function probe.start(font, size)
        probe.cancel()
        active, frames, stable = true, 0, 0
        for index, name in ipairs(names) do
            windower.text.create(name)
            windower.text.set_font(name, font)
            windower.text.set_font_size(name, size)
            windower.text.set_text(name, index == 1 and sample or sample .. '\n' .. sample .. '\n' .. sample)
            windower.text.set_italic(name, false)
            windower.text.set_bold(name, false)
            windower.text.set_right_justified(name, false)
            windower.text.set_bg_visibility(name, false)
            windower.text.set_bg_border_size(name, 0)
            windower.text.set_stroke_width(name, 0)
            windower.text.set_color(name, 0, 255, 255, 255)
            windower.text.set_location(name, 0, 0)
            windower.text.set_visibility(name, true)
        end
    end
    function probe.poll()
        if not active then return end
        frames = frames + 1
        local _, single = windower.text.get_extents(names[1])
        local _, multi = windower.text.get_extents(names[2])
        if frames >= 4 and type(single) == 'number' and type(multi) == 'number'
            and single > 0 and multi > single and multi < 1024 then
            local spacing = (multi - single) / 2
            if spacing >= 4 and spacing <= 128 then
                local key = single .. ':' .. multi
                stable = previous == key and stable + 1 or 0
                previous = key
                if stable >= 3 then
                    probe.cancel()
                    return {single = single, multi = multi, spacing = spacing}
                end
            end
        else stable, previous = 0, nil end
        if frames >= 90 then
            probe.cancel()
            return nil, 'Font measurements did not settle; saved layout was preserved.'
        end
    end
    return probe
end

return calibration
