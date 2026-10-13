-- Debuffed icon presentation, test batch 2.4.
-- Author: A (2026-10-13)
-- Presentation only. All debuff evidence, durations, overwrites and removals
-- continue to come exclusively from Xathe's original Debuffed tracker.
-- XivParty icon filenames are STATUS IDs, not the spells that applied them.

local images = require('images')
local texts = require('texts')

local clock_ok, socket = pcall(require, 'socket')
-- LuaSocket is included with Windower/XivParty. A monotonic frame clock is
-- preferable for visual fades; never use this time to modify debuff tracking.
local function visual_time()
    if clock_ok and socket and socket.gettime then return socket.gettime() end
    return os.clock()
end

local IconRenderer = {}
IconRenderer.__index = IconRenderer

local MAX_ALLOWED = 64 -- higher limits cost more image and text primitives
local PAD = 6
local TITLE_H = 21
local TIMER_DROP = 8      -- reserve room below icons for the half-overlapping label
local FADE_SEC = 0.32     -- only visual; expired debuffs are not inferred here
local PULSE_HOLD = 1.20  -- brief startup confirmation
local PULSE_FADE = 0.65
local MANUAL_HOLD = 12.0  -- show 11, 10, ... 0 for one second each
local EDIT_CYCLE = 71    -- 1:10, 1:09, ... 0:00, then reset
local EXIT_FADE = 0.36  -- all visible primitives fade before reload/unload
local PREVIEW_ALPHA = 205

-- This startup-only sampler is deliberately independent of tracking. It
-- uses 32 familiar status IDs from the installed XivParty icons. They are
-- NOT recorded as effects on any mob; the real display uses the tracker.
-- Dia is first in both the preview and the default live-effect priority.
local PREVIEW_EFFECTS = {
    134, 2, 3, 4, 5, 6, 7, 8,
    9, 10, 11, 12, 13, 15, 16, 21,
    28, 31, 128, 129, 130, 131, 132, 133,
    135, 136, 137, 138, 139, 140, 141, 142,
}

-- Every slot has a sample image on startup; for counts above the 32
-- original preview images, repeat the sampler rather than shipping icons.
local function preview_effect(index)
    return PREVIEW_EFFECTS[(index - 1) % #PREVIEW_EFFECTS + 1]
end

local function slot_count(settings)
    return math.max(1, math.min(MAX_ALLOWED, math.floor(tonumber(settings.slots) or 16)))
end

-- 'wrap' is the capacity along the primary layout axis. Zero disables wrapping.
local function grid_dimensions(settings)
    local count = slot_count(settings)
    local wrap = math.floor(tonumber(settings.wrap) or 16)
    local primary = wrap <= 0 and count or math.max(1, math.min(count, wrap))
    if settings.layout == 'vertical' then
        return math.ceil(count / primary), primary
    end
    return primary, math.ceil(count / primary)
end

local function icon_base(iconpath)
    local path = iconpath or '../XivParty/assets/buffIcons/'
    if path:sub(-1) ~= '/' and path:sub(-1) ~= '\\' then path = path .. '/' end
    if path:match('^%a:[/\\]') or path:sub(1, 1) == '/' or path:sub(1, 2) == '\\\\' then
        return path
    end
    return windower.addon_path .. path
end

local function text_style(size, bold, font, italic)
    return {
        pos = {x = 0, y = 0},
        bg = {visible = false},
        flags = {draggable = false, bold = bold or false, italic = italic or false, right = false},
        padding = 0,
        text = {
            font = font or 'Verdana', size = size, alpha = 255,
            red = 255, green = 255, blue = 255,
            stroke = {width = 1, alpha = 255, red = 0, green = 0, blue = 0},
        },
    }
end

local function make_sprite(effect, timer_size)
    local image = images.new('', {
        pos = {x = 0, y = 0}, size = {width = 24, height = 24},
        texture = {fit = false, path = ''}, draggable = false,
    })
    image:hide()
    local timer = texts.new('${value}', text_style(timer_size, true, 'Arial', true))
    timer:hide()
    local fallback = texts.new('${label}', text_style(10, true))
    fallback:hide()
    return {
        effect = effect, image = image, timer = timer, fallback = fallback,
        icon_path = nil, load_frames = 0, active = false, fade_start = nil,
        timer_label = '', dx = 0, dy = 0, has_icon = false,
    }
end

local function destroy_sprite(sprite)
    images.destroy(sprite.image)
    texts.destroy(sprite.timer)
    texts.destroy(sprite.fallback)
end

local function alpha_for(sprite, now)
    if not sprite.fade_start then return 255 end
    return math.floor(255 * math.max(0, 1 - (now - sprite.fade_start) / FADE_SEC))
end

local function timer_label(remains)
    if not remains or remains <= 0 then return nil end
    -- Match the native icon readout: completed hours/minutes only, then
    -- integer seconds when under a minute. All real durations remain estimates.
    if remains >= 3600 then return tostring(math.floor(remains / 3600)) .. 'h' end
    if remains >= 60 then return tostring(math.floor(remains / 60)) .. 'm' end
    -- Avoid printing '60' during the fractional second just below 1 minute.
    return tostring(math.max(1, math.floor(remains)))
end

function IconRenderer.new(settings)
    local self = setmetatable({}, IconRenderer)
    self.settings = settings
    self.sprites = {}     -- keyed by status effect, so a removed icon can fade
    self.entries = {}
    self.target = nil
    self.asset_base = icon_base(settings.iconpath)
    self.visible = false
    self.drag_dirty = false
    self.pulse_started = nil
    self.pulse_mode = nil
    self.guide_opacity = nil -- avoid 32 unnecessary primitive updates per idle frame
    self.guide_style = nil
    self.guide_warmup_frames = 0
    self.edit_started = nil -- edit preview timer starts at 1:10 when edit is enabled

    -- This hit rectangle retains the FULL configured slot footprint even with no
    -- debuffs. Alpha zero is still mouse-draggable in Windower's image API.
    self.backdrop = images.new('', {
        pos = {x = settings.pos.x, y = settings.pos.y},
        size = {width = 940, height = 45},
        color = {red = 0, green = 0, blue = 0, alpha = 0},
        texture = {path = windower.addon_path .. 'assets/white.png', fit = false},
        draggable = true,
    })
    self.backdrop:hide()

    -- Create the sample textures at LOAD time, not two frames into the
    -- animation. In a live Windower client, changing a hidden primitive's
    -- texture immediately before showing it may race the texture upload.
    -- Keep guide images separate from the tracker and never invent effects.
    -- The outlines, sample textures, and sample countdowns are separate
    -- layers. In edit mode the lovely individual edit squares remain visible
    -- behind slightly transparent previews of real buff icons.
    self.guides = {}
    self.samples = {}
    self.sample_timers = {}
    self.sample_paths = {}
    self.sample_alpha = nil
    self.sample_timer_alpha = nil
    self.sample_timer_label = nil
    self.pulse_mode = nil
    self.exit_started = nil
    self:resize_guides()

    self.heading = texts.new('${label}', text_style(12, true))
    self.heading:hide()
    return self
end

-- Rebuild only guides that were added/removed. The default is 16,
-- and existing images are retained across wrapping/size changes.
function IconRenderer:resize_guides()
    local desired = slot_count(self.settings)
    for i = #self.guides, desired + 1, -1 do
        images.destroy(self.guides[i])
        images.destroy(self.samples[i])
        texts.destroy(self.sample_timers[i])
        self.guides[i], self.samples[i], self.sample_timers[i], self.sample_paths[i] = nil, nil, nil, nil
    end
    for i = #self.guides + 1, desired do
        local outline_path = windower.addon_path .. 'assets/empty_slot.png'
        local candidate = self.asset_base .. tostring(preview_effect(i)) .. '.png'
        local sample_path = windower.file_exists(candidate) and candidate or outline_path
        local guide = images.new('', {
            pos = {x = 0, y = 0}, size = {width = 24, height = 24},
            color = {red = 195, green = 212, blue = 230, alpha = 0},
            texture = {path = outline_path, fit = false}, draggable = false,
        })
        guide:hide()
        local sample = images.new('', {
            pos = {x = 0, y = 0}, size = {width = 24, height = 24},
            color = {red = 255, green = 255, blue = 255, alpha = 0},
            texture = {path = sample_path, fit = false}, draggable = false,
        })
        sample:hide()
        local timer = texts.new('${value}', text_style(tonumber(self.settings.timersize) or 8, true, 'Arial', true))
        timer:hide()
        self.guides[i], self.samples[i] = guide, sample
        self.sample_timers[i], self.sample_paths[i] = timer, sample_path
    end
    self.guide_style, self.guide_opacity = nil, nil
    self.sample_alpha, self.sample_timer_alpha, self.sample_timer_label = nil, nil, nil
end

function IconRenderer:resize_guides_if_needed()
    if #self.guides ~= slot_count(self.settings) then self:resize_guides() end
end

function IconRenderer:set_timer_style()
    local size = tonumber(self.settings.timersize) or 8
    for _, timer in ipairs(self.sample_timers) do
        timer:font('Arial')
        timer:size(size)
        timer:bold(true)
        timer:italic(true)
    end
    for _, sprite in pairs(self.sprites) do
        sprite.timer:font('Arial')
        sprite.timer:size(size)
        sprite.timer:bold(true)
        sprite.timer:italic(true)
    end
end

function IconRenderer:has_icons()
    return windower.file_exists(self.asset_base .. '13.png')
end

-- Returns a count and a concrete sample path for in-game chat diagnostics.
function IconRenderer:preview_diagnostics()
    local count = 0
    for i = 1, slot_count(self.settings) do
        if windower.file_exists(self.asset_base .. tostring(preview_effect(i)) .. '.png') then
            count = count + 1
        end
    end
    local x, y = self.backdrop:pos()
    return count, slot_count(self.settings), x, y, self.asset_base .. '134.png'
end

function IconRenderer:set_icon_path(path)
    self.asset_base = icon_base(path)
    for i, sample in ipairs(self.samples) do
        local candidate = self.asset_base .. tostring(preview_effect(i)) .. '.png'
        local path = windower.file_exists(candidate) and candidate
            or (windower.addon_path .. 'assets/empty_slot.png')
        if self.sample_paths[i] ~= path then sample:path(path); self.sample_paths[i] = path end
    end
    for _, sprite in pairs(self.sprites) do sprite.icon_path = nil; sprite.load_frames = 0 end
end

function IconRenderer:set_position(x, y)
    self.backdrop:pos(x, y)
    if self.visible then self:layout() end
end

function IconRenderer:start_intro()
    -- The automatic login pulse remains brief to avoid covering game UI.
    self.pulse_started = visual_time()
    self.pulse_mode = 'intro'
    self.guide_opacity = nil
end

function IconRenderer:preview()
    -- Manual preview lasts 12 seconds with fake 11..0 countdown labels.
    -- These labels never affect tracked enemy debuffs.
    self.pulse_started = visual_time()
    self.pulse_mode = 'manual'
    self.guide_opacity, self.sample_timer_label = nil, nil
end

function IconRenderer:begin_exit()
    if not self.exit_started then self.exit_started = visual_time() end
end

function IconRenderer:exit_factor()
    if not self.exit_started then return 1 end
    return math.max(0, 1 - (visual_time() - self.exit_started) / EXIT_FADE)
end

function IconRenderer:exit_ready()
    return self.exit_started and (visual_time() - self.exit_started >= EXIT_FADE)
end

function IconRenderer:hide()
    if not self.visible and next(self.sprites) == nil then return end
    self.visible = false
    self.pulse_started = nil
    self.pulse_mode = nil
    self.edit_started = nil
    self.guide_opacity = nil
    self.sample_alpha = nil
    self.sample_timer_alpha = nil
    self.sample_timer_label = nil
    self.backdrop:hide()
    self.heading:hide()
    for _, guide in ipairs(self.guides) do guide:hide() end
    for _, sample in ipairs(self.samples) do sample:hide() end
    for _, timer in ipairs(self.sample_timers) do timer:hide() end
    for effect, sprite in pairs(self.sprites) do
        destroy_sprite(sprite)
        self.sprites[effect] = nil
    end
    self.entries = {}
    self.target = nil
end

function IconRenderer:layout()
    if not self.visible then return end
    local s = self.settings
    local size = tonumber(s.iconsize) or 24
    local gap = tonumber(s.iconspacing) or 5
    local vertical = s.layout == 'vertical'
    self:resize_guides_if_needed()
    local columns, rows = grid_dimensions(s)
    -- Editing reveals the slot outlines plus translucent sample icons/timers.
    -- Target name remains a separate optional display feature.
    local has_heading = s.targetname and self.target ~= nil and not s.edit
    local title_h = has_heading and TITLE_H or 0
    local width = 2 * PAD + columns * size + (columns - 1) * gap
    local height = 2 * PAD + title_h + rows * size + (rows - 1) * gap + TIMER_DROP

    local x, y = self.backdrop:pos()
    self.backdrop:size(width, height)
    -- Editing does not silently override the user's transparent background.
    self.backdrop:alpha(tonumber(s.background_alpha) or 0)
    self.backdrop:show()

    if has_heading then
        self.heading.label = '[' .. self.target.name .. ']'
        self.heading:pos(x + PAD, y + 2)
        self.heading:show()
    else
        self.heading:hide()
    end

    for i, guide in ipairs(self.guides) do
        local column = vertical and math.floor((i - 1) / rows) or ((i - 1) % columns)
        local line = vertical and ((i - 1) % rows) or math.floor((i - 1) / columns)
        local dx = PAD + column * (size + gap)
        local dy = PAD + title_h + line * (size + gap)
        guide:pos(x + dx, y + dy)
        guide:size(size, size)
        -- The sample sits 1px inside its outline, preserving a visible box.
        self.samples[i]:pos(x + dx + 1, y + dy + 1)
        self.samples[i]:size(math.max(1, size - 2), math.max(1, size - 2))
        self:position_sample_timer(i, x + dx, y + dy, size)
    end

    for i, entry in ipairs(self.entries) do
        if i > slot_count(s) then break end
        local sprite = self.sprites[entry.effect]
        if sprite then
            local column = vertical and math.floor((i - 1) / rows) or ((i - 1) % columns)
            local line = vertical and ((i - 1) % rows) or math.floor((i - 1) / columns)
            sprite.dx = PAD + column * (size + gap)
            sprite.dy = PAD + title_h + line * (size + gap)
            self:position_sprite(sprite)
        end
    end
    -- Fading sprites keep their previous slot until their fade is complete.
    for _, sprite in pairs(self.sprites) do
        if not sprite.active then self:position_sprite(sprite) end
    end
end

function IconRenderer:position_sample_timer(i, sx, sy, size)
    local timer = self.sample_timers[i]
    local label = self.sample_timer_label or '1:10'
    local width = nil
    local ok, actual = pcall(function() return timer:extents() end)
    if ok and type(actual) == 'number' and actual > 0 then width = actual end
    width = width or (#label * (tonumber(self.settings.timersize) or 8) * 0.6)
    timer:pos(sx + math.floor((size - width) / 2 + 0.5)
        + (tonumber(self.settings.timerx) or 0),
        sy + size - 5 + (tonumber(self.settings.timery) or -3))
end

function IconRenderer:position_sprite(sprite)
    local x, y = self.backdrop:pos()
    local size = tonumber(self.settings.iconsize) or 24
    local sx, sy = x + sprite.dx, y + sprite.dy
    sprite.image:pos(sx, sy)
    sprite.image:size(size, size)
    sprite.fallback:pos(sx, sy + math.floor(size / 3))

    local label = sprite.timer_label
    if label and label ~= '' then
        -- Actual text extents let one-, two- and three-digit values remain
        -- visually centered. On a failed measurement, use an approximation.
        local measured = nil
        local ok, width = pcall(function() return sprite.timer:extents() end)
        if ok and type(width) == 'number' and width > 0 then measured = width end
        measured = measured or (#label * 6)
        local tx = sx + math.floor((size - measured) / 2 + 0.5)
            + (tonumber(self.settings.timerx) or 0)
        local ty = sy + size - 5 + (tonumber(self.settings.timery) or -3)
        -- Slightly overlapping the icon, independently adjustable in X/Y.
        sprite.timer:pos(tx, ty)
    end
end

function IconRenderer:render(target, entries)
    entries = entries or {}
    local now = visual_time()
    if not self.visible then
        self.visible = true
        self:start_intro() -- brief login animation; //db preview is longer
    end
    self.target = target
    self.entries = entries

    local displayed = {}
    for i, entry in ipairs(entries) do
        if i > slot_count(self.settings) then break end
        displayed[entry.effect] = true
        local sprite = self.sprites[entry.effect]
        if not sprite then
            sprite = make_sprite(entry.effect, tonumber(self.settings.timersize) or 8)
            self.sprites[entry.effect] = sprite
        end
        sprite.active = true
        sprite.fade_start = nil
        local path = self.asset_base .. tostring(entry.effect) .. '.png'
        sprite.has_icon = windower.file_exists(path)
        if sprite.has_icon then
            if sprite.icon_path ~= path then
                sprite.image:path(path)
                sprite.icon_path = path
                sprite.load_frames = 2 -- hide initial untextured frames
            end
        else
            sprite.fallback.label = (res.buffs[entry.effect] or {}).en or entry.name or tostring(entry.effect)
        end
        local label = self.settings.timers and timer_label(entry.remains) or nil
        sprite.timer_label = label or ''
        if label then sprite.timer.value = label end
    end

    for effect, sprite in pairs(self.sprites) do
        if not displayed[effect] and sprite.active then
            sprite.active = false
            sprite.fade_start = now -- fade its last rendered icon/timer in place
        end
    end
    self:layout()
    self:tick()
end

-- Determine sample layering independently of any real tracked effects.
-- A normal preview counts 11..0 and fades; edit mode runs a 1:10 loop.
-- Outline squares remain beneath the samples in edit mode.
function IconRenderer:tick()
    if not self.visible then return end
    local now = visual_time()
    local guide_alpha, sample_alpha, timer_alpha = 0, 0, 0
    local dummy_label = nil
    local edit = self.settings.edit
    local pulse_active = false

    if self.pulse_started then
        local elapsed = math.max(0, now - self.pulse_started)
        local manual = self.pulse_mode == 'manual'
        local hold = manual and MANUAL_HOLD or PULSE_HOLD
        if elapsed < hold + PULSE_FADE then
            pulse_active = true
            local factor = (elapsed < hold) and 1
                or math.max(0, 1 - (elapsed - hold) / PULSE_FADE)
            sample_alpha = math.floor(PREVIEW_ALPHA * factor)
            if manual then
                dummy_label = tostring(math.max(0, 11 - math.floor(math.min(elapsed, 11.999))))
                timer_alpha = math.floor(245 * factor)
            end
            if edit then guide_alpha = 145 end
        else
            self.pulse_started, self.pulse_mode = nil, nil
        end
    end

    if edit then
        if not self.edit_started then self.edit_started = now end
    else
        self.edit_started = nil
    end
    if not pulse_active and edit then
        sample_alpha, guide_alpha, timer_alpha = 155, 145, 220
        -- 70,69,...0,70; no network or tracking data is involved.
        local elapsed = math.floor(math.max(0, now - self.edit_started))
        local second = 70 - (elapsed % EDIT_CYCLE)
        dummy_label = timer_label(second) or '0'
    end

    local exit_factor = 1
    if self.exit_started then
        exit_factor = math.max(0, 1 - (now - self.exit_started) / EXIT_FADE)
        guide_alpha = math.floor(guide_alpha * exit_factor)
        sample_alpha = math.floor(sample_alpha * exit_factor)
        timer_alpha = math.floor(timer_alpha * exit_factor)
        self.heading:alpha(math.floor(255 * exit_factor))
        self.backdrop:alpha(math.floor((tonumber(self.settings.background_alpha) or 0) * exit_factor))
    end

    if self.guide_opacity ~= guide_alpha then
        for _, guide in ipairs(self.guides) do
            if guide_alpha > 0 then guide:alpha(guide_alpha); guide:show()
            else guide:hide() end
        end
        self.guide_opacity = guide_alpha
    end
    if self.sample_alpha ~= sample_alpha then
        for _, sample in ipairs(self.samples) do
            if sample_alpha > 0 then sample:alpha(sample_alpha); sample:show()
            else sample:hide() end
        end
        self.sample_alpha = sample_alpha
    end
    if self.sample_timer_label ~= dummy_label then
        self.sample_timer_label = dummy_label
        if dummy_label then
            for _, timer in ipairs(self.sample_timers) do timer.value = dummy_label end
            -- Text width depends on whether label is 11, 9 or 1m.
            self:layout()
        end
    end
    if self.sample_timer_alpha ~= timer_alpha then
        for _, timer in ipairs(self.sample_timers) do
            if timer_alpha > 0 and dummy_label then
                timer:alpha(timer_alpha)
                timer:stroke_alpha(timer_alpha)
                timer:show()
            else timer:hide() end
        end
        self.sample_timer_alpha = timer_alpha
    end

    for effect, sprite in pairs(self.sprites) do
        local opacity = math.floor(alpha_for(sprite, now) * exit_factor)
        if opacity <= 0 then
            if self.exit_started then
                sprite.image:hide(); sprite.timer:hide(); sprite.fallback:hide()
            else
                destroy_sprite(sprite)
                self.sprites[effect] = nil
            end
        else
            if sprite.load_frames > 0 then sprite.load_frames = sprite.load_frames - 1 end
            if sprite.last_alpha ~= opacity then
                sprite.image:alpha(opacity)
                sprite.timer:alpha(opacity)
                sprite.timer:stroke_alpha(opacity)
                sprite.fallback:alpha(opacity)
                sprite.fallback:stroke_alpha(opacity)
                sprite.last_alpha = opacity
            end
            -- Edit mode demonstrates the configured layout using sample
            -- debuffs rather than painting real effects over dummy icons.
            local live_visible = not self.settings.edit
            local show_icon = live_visible and sprite.has_icon and sprite.load_frames == 0
            local show_fallback = live_visible and not sprite.has_icon
            local show_timer = live_visible and sprite.timer_label ~= ''
            if sprite.icon_visible ~= show_icon then
                if show_icon then sprite.image:show() else sprite.image:hide() end
                sprite.icon_visible = show_icon
            end
            if sprite.fallback_visible ~= show_fallback then
                if show_fallback then sprite.fallback:show() else sprite.fallback:hide() end
                sprite.fallback_visible = show_fallback
            end
            if sprite.timer_visible ~= show_timer then
                if show_timer then sprite.timer:show() else sprite.timer:hide() end
                sprite.timer_visible = show_timer
            end
        end
    end
end

function IconRenderer:sync_position()
    if not self.visible then return end
    local x, y = self.backdrop:pos()
    if x ~= self.settings.pos.x or y ~= self.settings.pos.y then
        self.settings.pos.x = x
        self.settings.pos.y = y
        self.drag_dirty = true
        self.last_moved = visual_time()
        self:layout()
    elseif self.drag_dirty and visual_time() - (self.last_moved or 0) > 0.65 then
        self.settings:save()
        self.drag_dirty = false
    end
    self:tick() -- animation is frame-driven, independent of 0.1s tracking poll
end

function IconRenderer:destroy()
    if self.drag_dirty then self.settings:save() end
    self:hide()
    for _, guide in ipairs(self.guides) do images.destroy(guide) end
    for _, sample in ipairs(self.samples) do images.destroy(sample) end
    for _, timer in ipairs(self.sample_timers) do texts.destroy(timer) end
    self.guides, self.samples, self.sample_timers = {}, {}, {}
    texts.destroy(self.heading)
    images.destroy(self.backdrop)
end

return IconRenderer
