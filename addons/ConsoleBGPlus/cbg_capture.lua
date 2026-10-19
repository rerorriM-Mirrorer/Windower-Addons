-- Observe a completed PNG rather than assuming screenshot conversion succeeded.
-- No screenshot settings are changed; custom/organized folders can be supplied.
local capture = {}
local signature = '\137PNG\13\10\26\10'
local trailer = '\0\0\0\0IEND\174\66\96\130'
local function listing(directory)
    if type(windower.get_dir) ~= 'function' then return nil, 'Directory API unavailable.' end
    local ok, names = pcall(windower.get_dir, directory)
    if not ok or type(names) ~= 'table' then return nil, 'Cannot inspect screenshot folder: ' .. directory end
    local result = {}
    for _, name in pairs(names) do
        -- get_dir returns names; never follow nested paths or sibling directories.
        if type(name) == 'string' and name:lower():match('%.png$')
            and not name:find('[/\\]') then result[name] = true end
    end
    return result
end
function capture.start(directory, target, now)
    local before, err = listing(directory)
    if not before then return nil, err end
    local existing = io.open(target, 'rb')
    if existing then existing:close(); return nil, 'Capture destination already exists.' end
    return {directory = directory:gsub('[/\\]*$', '/'), target = target,
        before = before, started = now, next_poll = now}
end
function capture.poll(job, now)
    if now - job.started >= 20 then
        return nil, 'No completed PNG detected in ' .. job.directory .. '; auto capture paused. Check Windower screenshot settings/folder, then retry.'
    end
    if now < job.next_poll then return end
    job.next_poll = now + 0.25
    local names, err = listing(job.directory)
    if not names then return nil, err end
    local candidate
    for name in pairs(names) do
        if not job.before[name] then
            if candidate then return nil, 'Multiple new PNGs detected; cannot match this test safely. Auto capture paused.' end
            candidate = name
        end
    end
    if not candidate then return end
    local source = io.open(job.directory .. candidate, 'rb')
    if not source then return end
    local size = source:seek('end')
    if not size or size < 20 or size > 64 * 1024 * 1024 then source:close(); return end
    source:seek('set', 0)
    local header = source:read(8)
    source:seek('end', -12)
    local ending = source:read(12)
    if header ~= signature or ending ~= trailer then source:close(); return end
    source:seek('set', 0)
    local bytes = source:read(size)
    source:close()
    if not bytes or #bytes ~= size then return end
    local output, open_error = io.open(job.target, 'wb')
    if not output then return nil, 'Cannot save matched screenshot: ' .. tostring(open_error) end
    local wrote, write_error = output:write(bytes)
    local closed, close_error = output:close()
    if not wrote or not closed then return nil, 'Screenshot copy failed: ' .. tostring(write_error or close_error) end
    return job.target
end
return capture
