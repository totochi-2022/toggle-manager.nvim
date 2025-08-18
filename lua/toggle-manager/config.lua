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
            -- 矛盾チェック：保存された状態と現在の定義を比較
            local cleaned_defaults = {}
            local needs_cleanup = false
            
            for key, saved_state in pairs(saved_defaults) do
                local def = toggle_definitions[key]
                if def then
                    -- 定義が存在する場合
                    if def.readonly == true or type(def.set_state) ~= 'function' then
                        -- readonlyまたはset_stateがない場合は保存状態を無視
                        print("Info: Ignoring saved state for readonly toggle '" .. key .. "'")
                        needs_cleanup = true
                    elseif def.states and vim.tbl_contains(def.states, saved_state) then
                        -- 有効な状態の場合は保持
                        cleaned_defaults[key] = saved_state
                    else
                        -- 無効な状態の場合はデフォルトに戻す
                        print("Warning: Invalid saved state '" .. tostring(saved_state) .. "' for toggle '" .. key .. "', using default")
                        cleaned_defaults[key] = def.default_state
                        needs_cleanup = true
                    end
                else
                    -- 定義が存在しない場合（削除されたトグル）
                    print("Info: Removing saved state for deleted toggle '" .. key .. "'")
                    needs_cleanup = true
                end
            end
            
            -- クリーンアップが必要な場合、ファイルを更新
            if needs_cleanup then
                M.save_cleaned_defaults(cleaned_defaults)
            end
            
            -- Apply cleaned default states
            for key, state in pairs(cleaned_defaults) do
                local def = toggle_definitions[key]
                if def and type(def.set_state) == 'function' then
                    local set_ok, err = pcall(def.set_state, state)
                    if not set_ok then
                        print("Warning: Failed to set toggle '" .. key .. "': " .. tostring(err))
                    end
                end
            end
        end
    else
        -- First time: apply default_state for each toggle
        for key, def in pairs(toggle_definitions) do
            if type(def.set_state) == 'function' then
                local set_ok, err = pcall(def.set_state, def.default_state)
                if not set_ok then
                    print("Warning: Failed to initialize toggle '" .. key .. "': " .. tostring(err))
                end
            end
        end
    end
end

-- Save cleaned defaults (internal function)
function M.save_cleaned_defaults(cleaned_defaults)
    local defaults_file = vim.fn.stdpath('data') .. '/toggle-manager/defaults.json'
    local dir = vim.fn.fnamemodify(defaults_file, ':h')
    if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, 'p')
    end
    
    local file = io.open(defaults_file, 'w')
    if file then
        file:write(vim.fn.json_encode(cleaned_defaults))
        file:close()
        print('✅ Cleaned up toggle states file')
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
        -- readonlyのトグルは保存しない
        if def.readonly ~= true and type(def.set_state) == 'function' then
            local current_state = def.get_state()
            current_defaults[key] = current_state
        end
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