-- A: read buttons/POV only; never acquire, remap, or consume controller input.
local controller = {status = 'unavailable'}
local ok, ffi = pcall(require, 'ffi')
if not ok or ffi.os ~= 'Windows' then
    function controller.held() return false end
    return controller
end
function controller.focused() return nil end
local loaded, api = pcall(function()
    ffi.cdef[[
        typedef struct {
            unsigned int size, flags, x, y, z, r, u, v;
            unsigned int buttons, button_number, pov, reserved1, reserved2;
        } GT_JOYINFOEX;
        unsigned int __stdcall joyGetPosEx(unsigned int id, GT_JOYINFOEX *info);
        void * __stdcall GetForegroundWindow(void);
        unsigned long __stdcall GetWindowThreadProcessId(void *window, unsigned long *pid);
        unsigned long __stdcall GetCurrentProcessId(void);
    ]]
    return {joy = ffi.load('winmm'), user = ffi.load('user32'), kernel = ffi.load('kernel32')}
end)
if not loaded then
    function controller.held() return false end
    return controller
end
local info = ffi.new('GT_JOYINFOEX')
local pid = ffi.new('unsigned long[1]')
local selected, next_scan = nil, 0
controller.status = 'searching'
function controller.focused()
    api.user.GetWindowThreadProcessId(api.user.GetForegroundWindow(), pid)
    return pid[0] == api.kernel.GetCurrentProcessId()
end
function controller.held(now)
    -- Each client wakes only when it is the foreground process.
    if not controller.focused() then return false end
    info.size, info.flags = ffi.sizeof(info), 0xC0 -- buttons + POV, no axes
    if selected == nil and now >= next_scan then
        next_scan = now + 2
        for id = 0, 15 do
            if api.joy.joyGetPosEx(id, info) == 0 then selected = id; break end
        end
        controller.status = selected ~= nil and ('joystick ' .. selected) or 'no joystick detected'
    end
    if selected == nil then return false end
    if api.joy.joyGetPosEx(selected, info) ~= 0 then
        selected = nil
        controller.status = 'disconnected'
        return false
    end
    local pov = tonumber(info.pov)
    return info.buttons ~= 0 or (pov >= 0 and pov < 36000)
end
return controller
