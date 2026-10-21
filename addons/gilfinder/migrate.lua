-- A: migrate every saved section before config merges defaults. Explicit modes win.
local migrate = {}
function migrate.convert(source)
    local global = source:match('<global>(.-)</global>') or ''
    local inherited = global:match('<visibility>%s*(%a+)%s*</visibility>')
    if inherited ~= 'always' and inherited ~= 'change' and inherited ~= 'input' then
        inherited = global:match('<autohide>%s*false%s*</autohide>') and 'always' or 'change'
    end
    local changed = false
    local output = source:gsub('(<settings[^>]*>)(.-)(</settings>)', function(root, inside, ending)
        inside = inside:gsub('(<([%a_][%w_]*)>)(.-)(</%2>)', function(open, name, body, close)
            local legacy = body:match('<autohide>%s*(%a+)%s*</autohide>')
            if not legacy then return open .. body .. close end
            changed = true
            if not body:find('<visibility>') then
                local mode = legacy == 'false' and 'always' or (inherited ~= 'always' and inherited or 'change')
                body = body:gsub('<autohide>%s*%a+%s*</autohide>', '<visibility>' .. mode .. '</visibility>', 1)
            end
            body = body:gsub('[ \t]*<autohide>%s*%a+%s*</autohide>[ \t]*\r?\n?', '')
            return open .. body .. close
        end)
        return root .. inside .. ending
    end)
    return output, changed
end
function migrate.run()
    local files = require('files')
    local file = files.new('data/settings.xml', true)
    if not file:exists() then return end
    local source = file:read()
    local output, changed = migrate.convert(source)
    if not changed then return end
    local backup = files.new('data/settings-before-wallet.xml', true)
    if not backup:exists() then backup:write(source) end
    file:write(output)
end
return migrate
