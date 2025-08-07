-- Highlight management for toggle-manager

local M = {}

-- Create preset highlight groups
local function create_preset_highlights()
    local presets = {
        -- Create from existing colors
        ToggleError = function()
            local hl = vim.api.nvim_get_hl(0, { name = 'DiagnosticError' })
            return { fg = '#000000', bg = hl.fg or '#FF0000', bold = true }
        end,
        ToggleWarn = function()
            local hl = vim.api.nvim_get_hl(0, { name = 'DiagnosticWarn' })
            return { fg = '#000000', bg = hl.fg or '#FFAA00', bold = true }
        end,
        ToggleInfo = function()
            local hl = vim.api.nvim_get_hl(0, { name = 'DiagnosticInfo' })
            return { fg = '#000000', bg = hl.fg or '#0088FF', bold = true }
        end,
        ToggleHint = function()
            local hl = vim.api.nvim_get_hl(0, { name = 'DiagnosticHint' })
            return { fg = '#000000', bg = hl.fg or '#888888', bold = true }
        end,
        ToggleGreen = function()
            local hl = vim.api.nvim_get_hl(0, { name = 'MoreMsg' })
            return { fg = '#000000', bg = hl.fg or '#00AA00', bold = true }
        end,
        ToggleGray = function()
            local hl = vim.api.nvim_get_hl(0, { name = 'NonText' })
            return { fg = '#000000', bg = hl.fg or '#808080', bold = true }
        end,
        ToggleVisual = function()
            local hl = vim.api.nvim_get_hl(0, { name = 'Visual' })
            return { fg = '#000000', bg = hl.bg or '#4444AA', bold = true }
        end,
    }
    
    for name, get_colors in pairs(presets) do
        vim.api.nvim_set_hl(0, name, get_colors())
    end
end

-- Create or get dynamic highlight group
function M.get_or_create_highlight(color_def, toggle_name, state_index)
    if type(color_def) == 'string' then
        -- Use existing highlight group name
        return color_def
    elseif type(color_def) == 'table' then
        -- Create dynamic highlight group when fg/bg specified
        local hl_name = string.format('Toggle_%s_%d', toggle_name, state_index)
        local hl_opts = { bold = color_def.bold ~= false }  -- Default is true
        
        -- Process fg
        if color_def.fg then
            if type(color_def.fg) == 'string' then
                if color_def.fg:match('^#') then
                    hl_opts.fg = color_def.fg  -- Direct value
                else
                    -- Get color from highlight group
                    local src_hl = vim.api.nvim_get_hl(0, { name = color_def.fg })
                    hl_opts.fg = src_hl.fg and string.format('#%06x', src_hl.fg) or '#000000'
                end
            end
        else
            hl_opts.fg = '#000000'  -- Default
        end
        
        -- Process bg
        if color_def.bg then
            if type(color_def.bg) == 'string' then
                if color_def.bg:match('^#') then
                    hl_opts.bg = color_def.bg  -- Direct value
                else
                    -- Get color from highlight group (use fg as bg)
                    local src_hl = vim.api.nvim_get_hl(0, { name = color_def.bg })
                    hl_opts.bg = src_hl.fg and string.format('#%06x', src_hl.fg) or 
                               (src_hl.bg and string.format('#%06x', src_hl.bg) or '#808080')
                end
            end
        else
            hl_opts.bg = '#808080'  -- Default
        end
        
        vim.api.nvim_set_hl(0, hl_name, hl_opts)
        return hl_name
    end
    return 'Normal'
end

-- Initialize highlight system
function M.init()
    -- Create preset highlights on initialization
    vim.defer_fn(create_preset_highlights, 100)
    
    -- Recreate highlight groups when colorscheme changes
    vim.api.nvim_create_autocmd('ColorScheme', {
        callback = function()
            vim.defer_fn(create_preset_highlights, 50)
        end
    })
end

return M