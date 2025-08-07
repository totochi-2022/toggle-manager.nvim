-- Configuration management for toggle-manager

local M = {}

-- Store registered toggle definitions
local toggle_definitions = {}

-- Register toggle definitions
function M.register_definitions(definitions)
    toggle_definitions = definitions
end

-- Get toggle definitions
function M.get_definitions()
    return toggle_definitions
end

-- Initialize toggles with saved states
function M.initialize_toggles()
    -- Load saved default states
    local defaults_file = vim.fn.stdpath('data') .. '/toggle-manager/defaults.json'
    local file = io.open(defaults_file, 'r')
    if file then
        local content = file:read('*a')
        file:close()
        local ok, saved_defaults = pcall(vim.fn.json_decode, content)
        if ok and type(saved_defaults) == 'table' then
            -- Apply saved default states
            for key, state in pairs(saved_defaults) do
                if toggle_definitions[key] then
                    local set_ok, err = pcall(toggle_definitions[key].set_state, state)
                    if not set_ok then
                        print("Warning: Failed to set toggle '" .. key .. "': " .. tostring(err))
                    end
                end
            end
        end
    else
        -- First time: apply default_state for each toggle
        for key, def in pairs(toggle_definitions) do
            local set_ok, err = pcall(def.set_state, def.default_state)
            if not set_ok then
                print("Warning: Failed to initialize toggle '" .. key .. "': " .. tostring(err))
            end
        end
    end
end

-- Save current states as defaults
function M.save_defaults()
    local current_defaults = {}
    
    if not toggle_definitions or vim.tbl_isempty(toggle_definitions) then
        print('⚠️  No toggle definitions found!')
        return
    end
    
    for key, def in pairs(toggle_definitions) do
        local current_state = def.get_state()
        current_defaults[key] = current_state
    end
    
    -- Create directory if it doesn't exist
    local defaults_file = vim.fn.stdpath('data') .. '/toggle-manager/defaults.json'
    local dir = vim.fn.fnamemodify(defaults_file, ':h')
    if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, 'p')
    end
    
    local file = io.open(defaults_file, 'w')
    if file then
        file:write(vim.fn.json_encode(current_defaults))
        file:close()
        print('✅ Current states saved as defaults!')
    end
end

return M