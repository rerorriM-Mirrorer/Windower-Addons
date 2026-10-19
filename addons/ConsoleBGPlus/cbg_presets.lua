-- Local live references, not universal Windows font metrics. Apply explicitly;
-- installed faces and other resolutions still require visual acceptance.
local presets = {}
function presets.get(font, size)
    if font:lower() ~= 'arial rounded mt bold' then return nil end
    if size == 12 then
        -- Native screenshot suggests ~18px pitch versus the 19px addon proxy.
        -- Keep trims neutral until this inferred native fit is visually checked.
        return {
            source = 'trial-reference', rows = 16, spacing = 18, single = 0, multi = 0,
            top = 15, bottom = 4, height = 333, input = 19,
            title = 8, label = 7, label_y = 2,
            offset_x = 50, offset_y = 15, labelfont = 'Arial Rounded MT Bold',
            top_extra = 0, bottom_trim = 0,
        }
    end
    if size ~= 8 and size ~= 10 then return nil end
    local small = size == 8
    return {
        source = small and 'reference' or 'trial-reference', rows = 16,
        spacing = small and 12.4 or 15.3, single = 0, multi = 0,
        top = 15, bottom = small and 0 or 1,
        height = small and 234 or 284, input = small and 13 or 16,
        title = small and 6 or 7, label = 6, label_y = small and 1 or 2,
        offset_x = 50, offset_y = 15, labelfont = 'Arial Rounded MT Bold',
        top_extra = 5, bottom_trim = small and 3 or 5,
    }
end
return presets
